unit fre_disksubfeed_client;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2013, FirmOS Business Solutions GmbH
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

      * Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the documentation
        and/or other materials provided with the distribution.
      * Neither the name of the <FirmOS Business Solutions GmbH> nor the names
        of its contributors may be used to endorse or promote products derived
        from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
(§LIC_END)
}

{$mode objfpc}{$H+}
{$codepage UTF8}
{$modeswitch nestedprocvars}
{$interfaces corba}

interface

uses
  Classes, SysUtils,FOS_TOOL_INTERFACES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,fre_basedbo_server,fre_system,fre_db_core,
  fre_dbbase,fre_zfs,fre_scsi,fre_hal_disk_enclosure_pool_mangement,fre_base_parser
  {$IFDEF SOLARIS}
  ,fosillu_hal_dbo_common, fosillu_hal_dbo_zfs_pool;
  {$ELSE}
  ;
  {$ENDIF}

const
  cIOSTAT                    = 'iostat -rxnsmde 1';
  cKSTATLINK                 = 'kstat -j link 1';
  //cKSTATLINK                 = 'iostat 1';
  cKSTATLINK_REMOTE          = 'kstat -C link 1';
  cIOSTATFILEHACKMIST_REMOTE = 'sh -c /zones/firmos/myiostat_e.sh';
  cZPOOLSTATUS               = 'zpool status 1';
  cGET_ZPOOL_IOSTAT          = 'zpool iostat -v 1';
  cReadSGLogIntervalSec      = 120;

  cZpoolQueryIntervalMSec     = 1000;
  cEnclosureQueryIntervalMSec = 5000;
  cMpathQueryIntervalMSec     = 5000;
  cZDSIntervalMSec            = 5000;

  DoubleLineEnd              = LineEnding+LineEnding;

type

  TFRE_DISKSUB_FEED_SERVER        = class;

  { TFRE_SINGLE_CMD_THREAD }

  TFRE_SINGLE_CMD_THREAD=class(TTHREAD)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
    fsleep_period     : NativeInt;
    ftimed_event      : IFOS_TE;
    fid               : string;
  protected
    procedure   Execute  ; override;
  public
    procedure   Terminate;
    procedure   MyInit   ; virtual;
    procedure   MyFinit  ; virtual;
    procedure   MyLoop   ; virtual;
    constructor Create   (const subfeeder:TFRE_DISKSUB_FEED_SERVER ; const id : string ; const sleep_period:nativeint);
    destructor  Destroy; override;
  end;

  { TMPathAdmThread }

  TMPathAdmThread=class(TFRE_SINGLE_CMD_THREAD)
  public
    procedure   MyLoop   ; override;
  end;

  { TZpoolThread }

  TZpoolThread=class(TFRE_SINGLE_CMD_THREAD)
  public
    procedure   MyLoop ; override;
  end;

  { TZDSThread }

  TZDSThread=class(TFRE_SINGLE_CMD_THREAD)
  public
    procedure   MyLoop ; override;
  end;

  { TDiskAndEnclosureThread }

  TDiskAndEnclosureThread=class(TFRE_SINGLE_CMD_THREAD)
  public
    procedure   MyLoop ; override;
  end;

  { TFRE_IOSTAT_PARSER }

  TFRE_IOSTAT_PARSER=class(TFOS_PARSER_PROC)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
  protected
    procedure   MyOutStreamCallBack          (const stream:TStream); override;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
  end;

  { TFRE_LINKSTAT_PARSER }

  TFRE_LINKSTAT_PARSER=class(TFOS_PARSER_PROC)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
    currentstring     : string;
  protected
    procedure   MyOutStreamCallBack          (const stream:TStream); override;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
  end;

  { TFRE_DISKSUB_FEED_SERVER }

  TFRE_DISKSUB_FEED_SERVER=class(TFRE_DBO_SERVER)
  private
    FDataTimer                               : IFRE_APSC_TIMER;
    FDiskIoStatMon                           : TFRE_IOSTAT_PARSER;
    FLinkStatMon                             : TFRE_LINKSTAT_PARSER;
    Fdiskenclosurethread                     : TDiskAndEnclosureThread;
    FMpathAdmThread                          : TMPathAdmThread;
    FZpoolThread                             : TZpoolThread;
    FZDSThread                               : TZDSThread;

    procedure  _TerminateThreads             ;
    procedure  _WaitForAndFreeThreads        ;

    procedure  StartDiskAndEnclosureThread   ;
    procedure  StartIostatParser             ;
    procedure  StartLinkstatParser           ;
    procedure  StartMpathAdmThread           ;
    procedure  StartZPoolThread              ;
    procedure  StartZDSThread                ;

  protected
    procedure  Setup           ; override;
    destructor Destroy         ; override;
    procedure  DataParsed      (const timer : IFRE_APSC_TIMER ; const flag1,flag2 : boolean);
  public
    function   IOStat_GetData  : IFRE_DB_Object;
  end;


implementation

{ TZDSThread }

procedure TZDSThread.MyLoop;
var resdbo     : IFRE_DB_Object;
    z          : TFRE_DB_ZFS;
    error      : string;
    zfsfs      : IFRE_DB_Object;
    time       : NativeInt;
begin
  GFRE_DB.LogDebug(dblc_APPLICATION,'>ZFS DS STAT RUNNING');
  time := fosillu_zfs_GetZFSFilesystems(error,zfsfs);
  resdbo := GFRE_DBI.NewObject;
  resdbo.Field('subfeed').asstring      := 'ZDS';
  resdbo.Field('resultcode').AsInt32    := 0;
  resdbo.Field('error').asstring        := error;
  resdbo.Field('data').AsObject         := zfsfs;
  resdbo.Field('runtime').AsInt64       := time;
  resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
  //writeln('SWL: ZDS STATUS:',resdbo.DumpToString());
  fsubfeeder.PushDataToClients(resdbo);
  GFRE_DB.LogDebug(dblc_APPLICATION,'<ZFS DS STAT RUNNING - '+inttostr(time)+' ms');
end;

{ TDiskAndEnclosureThread }

procedure TDiskAndEnclosureThread.MyLoop;
var so    : TFRE_DB_SCSI;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
    resdbo: IFRE_DB_Object;
    next_log : TFRE_DB_DateTime64;
    read_log : boolean;
begin
  //writeln('ENC LOOP');
  next_log := GFRE_DT.Now_UTC;
  so     := TFRE_DB_SCSI.create;
  try
    so.SetRemoteSSH(cFRE_REMOTE_USER, cFRE_REMOTE_HOST, SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
    if next_log<GFRE_DT.Now_UTC then
      begin
        read_log := true;
        next_log := GFRE_DT.Now_UTC+(cReadSGLogIntervalSec*1000);
      end
    else
      read_log := false;

    res    := so.GetSG3DiskAndEnclosureInformation(fsubfeeder.IOStat_GetData,error,obj,read_log);
    resdbo := GFRE_DBI.NewObject;
    resdbo.Field('subfeed').asstring      := 'DISKENCLOSURE';
    resdbo.Field('resultcode').AsInt32    := res;
    resdbo.Field('error').asstring        := error;
    resdbo.Field('data').AsObject         := obj;
    resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;

    fsubfeeder.PushDataToClients(resdbo);
    GFRE_DB.LogDebug(dblc_APPLICATION,'ENCLOSURESTAT RUNNING');
  finally
    so.Free;
  end;
end;

{ TFRE_SINGLE_CMD_THREAD }

procedure TFRE_SINGLE_CMD_THREAD.Execute;
var startt,endt : TFRE_DB_DateTime64;
begin
  MyInit;
  try
    try
      repeat
        if Terminated then
          exit;
        MyLoop;
        startt := GFRE_DT.Now_UTC;
        //writeln('>>DEBUG : ',fid,', WAITFOR ',GFRE_DT.ToStrUTC(startt),' ',fsleep_period);
        ftimed_event.WaitFor(fsleep_period);
        endt  := GFRE_DT.Now_UTC;
        //writeln('<<DEBUG : ',fid,' WAITFOR ',GFRE_DT.ToStrUTC(endt),' lasted ',endt-startt,' for period ',fsleep_period);
      until Terminated;
    finally
      try
        MyFinit;
      except
        on e:exception do
          GFRE_DB.LogEmergency(dblc_EXCEPTION,'subfeeder thread [%s] finit failed due to [%s]',[fid,e.Message]);
      end;
    end;
  except
    on e:exception do
      GFRE_DB.LogEmergency(dblc_EXCEPTION,'subfeeder thread [%s] terminated due to [%s]',[fid,e.Message]);
  end;
end;

procedure TFRE_SINGLE_CMD_THREAD.Terminate;
begin
  inherited Terminate;
  ftimed_event.SetEvent;
end;

procedure TFRE_SINGLE_CMD_THREAD.MyInit;
begin
  //writeln('MY INIT ',ClassName);
end;

procedure TFRE_SINGLE_CMD_THREAD.MyFinit;
begin
  //writeln('MY FINIT ',ClassName);
end;

procedure TFRE_SINGLE_CMD_THREAD.MyLoop;
begin

end;

constructor TFRE_SINGLE_CMD_THREAD.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER; const id: string; const sleep_period: nativeint);
begin
  fsubfeeder    := subfeeder;
  fsleep_period := sleep_period;
  fid           := id;
  GFRE_TF.Get_TimedEvent(ftimed_event);
  Inherited Create(false);
end;

destructor TFRE_SINGLE_CMD_THREAD.Destroy;
begin
  ftimed_event.Finalize;
  inherited Destroy;
end;

{ TFRE_LINKSTAT_PARSER }

procedure TFRE_LINKSTAT_PARSER.MyOutStreamCallBack(const stream: TStream);
var st           : TStringStream;
    str          : string;
    epos,newpos  : NativeInt;
    i: Integer;

    procedure ParseOneBlock;
    var new_feedobj   : IFRE_DB_Object;
        lcount        : NativeInt;
        zonename      : string;
    begin
      //writeln('>>>> PARSEBLOCK ',Length(currentstring));
      new_feedobj := GFRE_DB.JSONObject2Object(currentstring,false);
      new_feedobj.Field('subfeed').asstring      := 'LINKSTAT';
      new_feedobj.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
      fsubfeeder.PushDataToClients(new_feedobj);
      GFRE_DB.LogDebug(dblc_APPLICATION,'LINKSTAT RUNNING');
      //writeln(new_feedobj.DumpToString);
    end;

begin
  stream.Position:=0;
  SetLength(str,stream.Size);
  stream.Read(str[1],stream.Size);
  currentstring := currentstring+str;
  repeat
    epos := pos(DoubleLineEnd,currentstring);
    if epos>0 then
      begin
        str           := currentstring;
        currentstring := Copy(str,1,epos-1);
        str           := Copy(str,epos+2,MaxInt);
        ParseOneBlock;
        currentstring := str;
        epos          := pos(DoubleLineEnd,currentstring);
      end
    else
     begin
       break;
     end;
  until false;
  GFRE_DB.LogDebug(dblc_APPLICATION,'LINKSTAT RUNNING');
  stream.Size:=0;
end;

constructor TFRE_LINKSTAT_PARSER.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
var cmd:string;
begin
  if cFRE_REMOTE_HOST='' then
    cmd := cKSTATLINK
  else
    cmd := cKSTATLINK_REMOTE;
  inherited Create(cFRE_REMOTE_USER,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'),cFRE_REMOTE_HOST,cmd);
  fsubfeeder := subfeeder;
end;

procedure TZpoolThread.MyLoop;
var pools    : IFRE_DB_Object;
    error    : string;
    res      : integer;
    resdbo   : IFRE_DB_Object;
    poollist : IFRE_DB_Object;

    {$IFDEF SOLARIS}
    procedure _PoolIterator(const obj: IFRE_DB_Object);
    var pool : IFRE_DB_Object;
    begin
      if res=0 then
        begin
          res :=  fosillu_zfs_GetPoolStatusDBO(obj.Field('name').asstring,error,pool);
          pools.Field(obj.Field('name').asstring).AsObject:=pool;
        end;
    end;
    {$ENDIF}

begin
   //writeln('ZPOOL LOOP');
  {$IFDEF SOLARIS}
  pools  := GFRE_DBI.NewObject;
  res    := fosillu_zfs_GetActivePoolsDBO(error,poollist);
  try
  //     writeln('SWL:POOLLIST',poollist.DumpToString());
    if res=0 then
        poollist.ForAllObjects(@_PoolIterator);
  finally
    poollist.Finalize;
  end;
  {$ENDIF}
  resdbo := GFRE_DBI.NewObject;
  resdbo.Field('subfeed').asstring      := 'ZPOOLSTATUS';
  resdbo.Field('resultcode').AsInt32    := res;
  resdbo.Field('error').asstring        := error;
  resdbo.Field('data').AsObject         := pools;
  resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
//writeln('SWL: ZPOOLSTATUS:',resdbo.DumpToString());
  fsubfeeder.PushDataToClients(resdbo);
  GFRE_DB.LogDebug(dblc_APPLICATION,'ZFS POOL STAT RUNNING');
end;

{ TMPathAdmThread }

procedure TMPathAdmThread.MyLoop;
var so    : TFRE_DB_SCSI;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
    resdbo: IFRE_DB_Object;
begin
  //writeln('MPA LOOP');
  so     := TFRE_DB_SCSI.create;
  try
    so.SetRemoteSSH(cFRE_REMOTE_USER, cFRE_REMOTE_HOST, SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
    res    := so.GetMpathAdmLUInformation(error,obj);
    resdbo := GFRE_DBI.NewObject;
    resdbo.Field('subfeed').asstring      := 'MPATH';
    resdbo.Field('resultcode').AsInt32    := res;
    resdbo.Field('error').asstring        := error;
    resdbo.Field('data').AsObject         := obj;
    resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
    fsubfeeder.PushDataToClients(resdbo);
    GFRE_DB.LogDebug(dblc_APPLICATION,'MPATH STAT RUNNING');
  finally
    so.Free;
  end;
end;


{ TFRE_DISKSUB_FEED_SERVER }

procedure TFRE_DISKSUB_FEED_SERVER._TerminateThreads;
begin
  if Assigned(Fdiskenclosurethread) then
      Fdiskenclosurethread.Terminate;
  if Assigned(FMpathAdmThread) then
      FMpathAdmThread.Terminate;
  if Assigned(FZpoolThread) then
      FZpoolThread.Terminate;
  if Assigned(FZDSThread) then
      FZDSThread.Terminate;
end;

procedure TFRE_DISKSUB_FEED_SERVER._WaitForAndFreeThreads;
begin
  if Assigned(Fdiskenclosurethread) then
    begin
      Fdiskenclosurethread.WaitFor;
      Fdiskenclosurethread.Free;
      Fdiskenclosurethread:=nil;
    end;
  if Assigned(FMpathAdmThread) then
    begin
      FMpathAdmThread.WaitFor;
      FMpathAdmThread.Free;
      FMpathAdmThread:=nil;
    end;
  if Assigned(FZpoolThread) then
    begin
      FZpoolThread.WaitFor;
      FZpoolThread.Free;
      FZpoolThread:=nil;
    end;
  if Assigned(FZDSThread) then
    begin
      FZDSThread.WaitFor;
      FZDSThread.Free;
      FZDSThread:=nil;
    end;
end;


procedure TFRE_DISKSUB_FEED_SERVER.StartDiskAndEnclosureThread;
begin
  Fdiskenclosurethread:=TDiskAndEnclosureThread.Create(self,'enclosure',cEnclosureQueryIntervalMSec);
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartIostatParser;
begin
  FDiskIoStatMon := TFRE_IOSTAT_PARSER.Create(self);
  FDiskIoStatMon.Enable;
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartLinkstatParser;
begin
  FLinkStatMon := TFRE_LINKSTAT_PARSER.Create(self);
  FLinkStatMon.Enable;
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartMpathAdmThread;
begin
  FMpathAdmThread:=TMPathAdmThread.Create(self,'mpath',cMpathQueryIntervalMSec);
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartZPoolThread;
begin
  FZpoolThread:=TZpoolThread.Create(self,'zpool',cZpoolQueryIntervalMSec);
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartZDSThread;
begin
  FZDSThread:=TZDSThread.Create(self,'zds',cZDSIntervalMSec);
end;


procedure TFRE_DISKSUB_FEED_SERVER.Setup;
var lang:string;
    z   : TFRE_DB_ZFS;
begin

  fre_dbbase.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;
  GFRE_DB.Initialize_Extension_ObjectsBuild;

  //z := TFRE_DB_ZFS.Create;
  //z.GetSnapshots('',false,false);
  //writeln(z.DumpToString());
  //writeln('---');

  //z.EmbedDatasets;

  //writeln(z.DumpToString);
  //halt;

  {$IFDEF SOLARIS}
  InitIllumosLibraryHandles;
  {$ENDIF}

  FDBO_Srv_Cfg.SpecialFile := cFRE_UX_SOCKS_DIR+'disksub';
  FDBO_Srv_Cfg.Id          := 'DiskSub';
  FDBO_Srv_Cfg.Port        := '44101';
  FDBO_Srv_Cfg.IP          := '0.0.0.0';
  inherited Setup;

  //lang:=GetEnvironmentVariable('LANG');
  //if (lang<>'C') then
  //  begin
  //    GFRE_DBI.LogError(dblc_APPLICATION,'Environment LANG for this feeder must be C, instead of %s ',[lang]);
  //    writeln('Environment LANG for this feeder must be C, instead of ',lang);
  //    abort;
  //  end;

  try
    StartIostatParser;
    StartDiskAndEnclosureThread;
    StartZpoolThread;
    StartMpathAdmThread;
    StartLinkstatParser;
    StartZDSThread;
  except on e:Exception do begin
    GFRE_DBI.LogError(dblc_APPLICATION,'COULD NOT START SUBSUBFEEDER %s',[e.Message]);
  end; end;
end;

destructor TFRE_DISKSUB_FEED_SERVER.Destroy;
begin
  GFRE_DBI.LogDebug(dblc_APPLICATION,'DESTROYING SUBFEEDER');

  if Assigned(FDiskIoStatMon) then
    FDiskIoStatMon.Free;

  if Assigned(FLinkStatMon) then
    FLinkStatMon.Free;

  _TerminateThreads;
  _WaitForAndFreeThreads;
  {$IFDEF SOLARIS}
  FinishIllumosLibraryHandles;
  {$ENDIF}
  inherited Destroy;
end;

procedure TFRE_DISKSUB_FEED_SERVER.DataParsed(const timer: IFRE_APSC_TIMER; const flag1, flag2: boolean);
var obj : IFRE_DB_Object;
begin
   obj := GFRE_DBI.NewObject;
   obj.Field('MyData_TS').AsDateTimeUTC := GFRE_DT.Now_UTC;
   obj.Field('MyData_Dta').AsUInt32 := random(10000);
   PushDataToClients(obj);
end;

function TFRE_DISKSUB_FEED_SERVER.IOStat_GetData: IFRE_DB_Object;
begin
  if assigned(FDiskIoStatMon) then
      result := FDiskIoStatMon.Get_Data_Object
  else
    GFRE_BT.CriticalAbort('IOStatMon not assigned in IOStat_Getdata');
end;


{ TFRE_IOSTAT_PARSER }

procedure TFRE_IOSTAT_PARSER.MyOutStreamCallBack(const stream: TStream);
var st : TStringStream;
    sl : TStringlist;
    i  : integer;
    s  : string;
    lc : integer;
    resdbo : IFRE_DB_Object;

  //  r/s,w/s,kr/s,kw/s,wait,actv,wsvc_t,asvc_t,%w,%b,device
  procedure _UpdateDisk;
  var devicename : string[30];
      diskiostat : TFRE_DB_IOSTAT;
  begin
    devicename := Fline[14];
    diskiostat := TFRE_DB_IOSTAT.Create;
    diskiostat.Field('rps').AsReal32    := StrToFloat(Fline[0]);
    diskiostat.Field('wps').AsReal32    := StrToFloat(Fline[1]);
    diskiostat.Field('krps').AsReal32   := StrToFloat(Fline[2]);
    diskiostat.Field('kwps').AsReal32   := StrToFloat(Fline[3]);
    diskiostat.Field('wait').AsReal32   := StrToFloat(Fline[4]);
    diskiostat.Field('actv').AsReal32   := StrToFloat(Fline[5]);
    diskiostat.Field('wsvc_t').AsReal32 := StrToFloat(Fline[6]);
    diskiostat.Field('actv_t').AsReal32 := StrToFloat(Fline[7]);
    diskiostat.Field('perc_w').AsReal32 := StrToFloat(Fline[8]);
    diskiostat.Field('perc_b').AsReal32 := StrToFloat(Fline[9]);
    diskiostat.Field('err_sw').AsUint32  := StrToInt(Fline[10]);
    diskiostat.Field('err_hw').AsUint32  := StrToInt(Fline[11]);
    diskiostat.Field('err_trn').AsUint32  := StrToInt(Fline[12]);
    diskiostat.Field('err_tot').AsUint32  := StrToInt(Fline[13]);
    diskiostat.Field('iodevicename').AsString := devicename;
    FData.Field(devicename).AsObject          := diskiostat;
  end;

begin
  stream.Position:=0;
  st := TStringStream.Create('');
  try
    st.CopyFrom(stream,stream.Size);
    stream.Size:=0;
    FLines.DelimitedText := st.DataString;
    if Flines.count>0 then begin
      if pos('extended',Flines[0])=1 then begin
        lc := FLines.Count;
        for i := 2 to lc-2 do begin
          Fline.DelimitedText := Flines[i];
          if pos('extended',Fline[0])=1 then begin
            Continue;
          end;
          if pos('r/s',Fline[0])=1 then begin
            continue;
          end;
          FLock.Acquire;
          try
            try
              _UpdateDisk;
            except on E:Exception do begin
              GFRE_DBI.LogError(dblc_APPLICATION,'Iostat Parser Error: %s',[e.Message]);
              GFRE_DBI.LogError(dblc_APPLICATION,'Iostat Text: %s',[Fline.DelimitedText]);
            end;end;
          finally
            FLock.Release;
          end;
        end;
      end;
    end else begin
      GFRE_DBI.LogInfo(dblc_APPLICATION,'Iostat IGNORING JUNK: %d [%s]',[st.Size,st.DataString]);
    end;
  finally
    st.Free;
  end;
  resdbo := GFRE_DBI.NewObject;
  resdbo.Field('subfeed').asstring      := 'IOSTAT';
  resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
  resdbo.Field('data').AsObject         := Get_Data_Object;
//  writeln('SWL:IOSTAT',resdbo.DumpToString());
  GFRE_DB.LogDebug(dblc_APPLICATION,'IOSTAT RUNNING');
  fsubfeeder.PushDataToClients(resdbo);
end;

constructor TFRE_IOSTAT_PARSER.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
var cmd:string;
begin
  if cFRE_REMOTE_HOST='' then
    cmd := cIOSTAT
  else
    cmd := cIOSTATFILEHACKMIST_REMOTE;
  inherited Create(cFRE_REMOTE_USER,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'),cFRE_REMOTE_HOST,cmd);
  fsubfeeder := subfeeder;
end;



initialization

end.
