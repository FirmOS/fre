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
  Classes, SysUtils,FOS_TOOL_INTERFACES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,fre_basedbo_server,fre_system,
  fre_dbbase,fre_zfs,fre_scsi,fre_hal_disk_enclosure_pool_mangement,fre_base_parser,fosillu_hal_dbo_common, fosillu_hal_dbo_zfs_pool;

const
  cIOSTAT                    = 'iostat -rxnsmde 1';
  cIOSTATFILEHACKMIST_REMOTE = 'sh -c /zones/firmos/myiostat_e.sh';
  cZPOOLSTATUS               = 'zpool status 1';
  cGET_ZPOOL_IOSTAT          = 'zpool iostat -v 1';
  cReadSGLogIntervalSec      = 120;
  cZpoolQueryIntervalMSec    = 1000;

type

  TFRE_DISKSUB_FEED_SERVER        = class;

  { TMPathAdmThread }

  TMPathAdmThread=class(TThread)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
    procedure   Execute                      ; override;
  end;

  { TZpoolThread }

  TZpoolThread=class(TThread)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
    procedure   Execute                      ; override;
  end;

  { TDiskAndEnclosureThread }

  TDiskAndEnclosureThread=class(TThread)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
    procedure   Execute                      ; override;
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

  { TFRE_DISKSUB_FEED_SERVER }

  TFRE_DISKSUB_FEED_SERVER=class(TFRE_DBO_SERVER)
  private
    FDataTimer                               : IFRE_APSC_TIMER;
    FDiskIoStatMon                           : TFRE_IOSTAT_PARSER;
    Fdiskenclosurethread                     : TDiskAndEnclosureThread;
    FMpathAdmThread                          : TMPathAdmThread;
    FZpoolThread                             : TZpoolThread;

    procedure  _TerminateThreads             ;
    procedure  _WaitForAndFreeThreads        ;

    procedure  StartDiskAndEnclosureThread   ;
    procedure  StartIostatParser             ;
    procedure  StartMpathAdmThread           ;
    procedure  StartZPoolThread              ;

  protected
    procedure  Setup           ; override;
    destructor Destroy         ; override;
    procedure  DataParsed      (const timer : IFRE_APSC_TIMER ; const flag1,flag2 : boolean);
  public
    function   IOStat_GetData  : IFRE_DB_Object;
  end;


implementation

{ TZpoolThread }

constructor TZpoolThread.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
begin
  inherited Create(false);
  fsubfeeder := subfeeder;
end;

procedure TZpoolThread.Execute;
var pools    : IFRE_DB_Object;
    error    : string;
    res      : integer;
    resdbo   : IFRE_DB_Object;
    poollist : IFRE_DB_Object;


    procedure _PoolIterator(const obj: IFRE_DB_Object);
    var pool : IFRE_DB_Object;
    begin
      if res=0 then
        begin
          res :=  fosillu_zfs_GetPoolStatusDBO(obj.Field('name').asstring,error,pool);
          pools.Field(obj.Field('name').asstring).AsObject:=pool;
        end;
    end;

begin
  repeat
    try
      pools  := GFRE_DBI.NewObject;
      res    := fosillu_zfs_GetActivePoolsDBO(error,poollist);
 //     writeln('SWL:POOLLIST',poollist.DumpToString());
      if res=0 then
        begin
          poollist.ForAllObjects(@_PoolIterator);
        end;

      resdbo := GFRE_DBI.NewObject;
      resdbo.Field('subfeed').asstring      := 'ZPOOLSTATUS';
      resdbo.Field('resultcode').AsInt32    := res;
      resdbo.Field('error').asstring        := error;
      resdbo.Field('data').AsObject         := pools;
      resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
     writeln('SWL: ZPOOLSTATUS:',resdbo.DumpToString());
      fsubfeeder.PushDataToClients(resdbo);

      if not Terminated then
         sleep(cZpoolQueryIntervalMSec);
    except on E:Exception do begin
      GFRE_DBI.LogError(dblc_APPLICATION,'ZPoolThread Exception %s',[e.Message]);
      raise;
    end; end;
  until Terminated;
end;

{ TMPathAdmThread }

constructor TMPathAdmThread.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
begin
  inherited Create(false);
  fsubfeeder := subfeeder;
end;

procedure TMPathAdmThread.Execute;
var so    : TFRE_DB_SCSI;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
    resdbo: IFRE_DB_Object;
begin
  repeat
    so     := TFRE_DB_SCSI.create;
    try
      so.SetRemoteSSH(cFRE_REMOTE_USER, cFRE_REMOTE_HOST, SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
      try
        res    := so.GetMpathAdmLUInformation(error,obj);
        resdbo := GFRE_DBI.NewObject;
        resdbo.Field('subfeed').asstring      := 'MPATH';
        resdbo.Field('resultcode').AsInt32    := res;
        resdbo.Field('error').asstring        := error;
        resdbo.Field('data').AsObject         := obj;
        resdbo.Field('machinename').Asstring  := cFRE_MACHINE_NAME;
        fsubfeeder.PushDataToClients(resdbo);
        if not Terminated then
          sleep(10000);
      except on E:Exception do begin
        GFRE_DBI.LogError(dblc_APPLICATION,'MPathAdmThreadException %s',[e.Message]);
        raise;
      end; end;
    finally
      so.Free;
    end;
  until Terminated;
end;


{ TFRE_DISKSUB_FEED_SERVER }

procedure TFRE_DISKSUB_FEED_SERVER._TerminateThreads;
begin
  if Assigned(Fdiskenclosurethread) then
    begin
      Fdiskenclosurethread.Terminate;
    end;
  if Assigned(FMpathAdmThread) then
    begin
      FMpathAdmThread.Terminate;
    end;
  if Assigned(FZpoolThread) then
    begin
      FZpoolThread.Terminate;
    end;
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
end;


procedure TFRE_DISKSUB_FEED_SERVER.StartDiskAndEnclosureThread;
begin
  Fdiskenclosurethread:=TDiskAndEnclosureThread.Create(self);
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartIostatParser;
begin
  FDiskIoStatMon := TFRE_IOSTAT_PARSER.Create(self);
  FDiskIoStatMon.Enable;
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartMpathAdmThread;
begin
  FMpathAdmThread:=TMPathAdmThread.Create(self);
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartZPoolThread;
begin
  FZpoolThread:=TZpoolThread.Create(self);
end;



procedure TFRE_DISKSUB_FEED_SERVER.Setup;
var lang:string;
begin

  fre_dbbase.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;

  InitIllumosLibraryHandles;

  FDBO_Srv_Cfg.SpecialFile := cFRE_UX_SOCKS_DIR+'disksub';
  FDBO_Srv_Cfg.Id          := 'DiskSub';
  FDBO_Srv_Cfg.Port        := '44101';
  FDBO_Srv_Cfg.IP          := '0.0.0.0';
  inherited Setup;

  lang:=GetEnvironmentVariable('LANG');
  if (lang<>'C') then
    begin
      GFRE_DBI.LogError(dblc_APPLICATION,'Environment LANG for this feeder must be C, instead of %s ',[lang]);
      writeln('Environment LANG for this feeder must be C, instead of ',lang);
      abort;
    end;

try
    StartIostatParser;
    StartDiskAndEnclosureThread;
    StartZpoolThread;
    StartMpathAdmThread;
  except on e:Exception do begin
    GFRE_DBI.LogError(dblc_APPLICATION,'COULD NOT START SUBSUBFEEDER %s',[e.Message]);
  end; end;

end;

destructor TFRE_DISKSUB_FEED_SERVER.Destroy;
begin
  GFRE_DBI.LogInfo(dblc_APPLICATION,'DESTROYING SUBFEEDER');

  if Assigned(FDiskIoStatMon) then
    FDiskIoStatMon.Free;

  _TerminateThreads;
  _WaitForAndFreeThreads;

  FinishIllumosLibraryHandles;
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


{ TDiskAndEnclosureThread }

constructor TDiskAndEnclosureThread.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
begin
  inherited Create(false);
  fsubfeeder := subfeeder;
end;

procedure TDiskAndEnclosureThread.Execute;
var so    : TFRE_DB_SCSI;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
    resdbo: IFRE_DB_Object;
    next_log : TFRE_DB_DateTime64;
    read_log : boolean;
begin
  next_log := GFRE_DT.Now_UTC;
  repeat
    so     := TFRE_DB_SCSI.create;
    try
      so.SetRemoteSSH(cFRE_REMOTE_USER, cFRE_REMOTE_HOST, SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
      try
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
        if not Terminated then
          sleep(10000);
      except on E:Exception do begin
        GFRE_DBI.LogError(dblc_APPLICATION,'DiskAndEnclosureThreadException %s',[e.Message]);
        raise;
      end; end;
    finally
      so.Free;
    end;
  until Terminated;
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
