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
  Classes, SysUtils,FOS_TOOL_INTERFACES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,fre_basesubfeed_server,fre_system,
  fre_dbbase,fre_zfs,fre_scsi,fre_hal_disk,fre_base_parser;

const
  cIOSTATFILEHACKMIST     = '/zones/firmos/myiostat.sh';
  cIOSTATFILEHACKMIST_LOC = 'sh -c /zones/firmos/myiostat.sh';
  cZPOOLSTATUS            = 'zpool status 1';
  cGET_ZPOOL_IOSTAT       = 'zpool iostat -v 1';

type

  TFRE_DISKSUB_FEED_SERVER        = class;

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

  { TFRE_ZPOOL_STATUS_PARSER }

  TFRE_ZPOOL_STATUS_PARSER=class(TFOS_PARSER_PROC)
  private
    fsubfeeder        : TFRE_DISKSUB_FEED_SERVER;
  protected
    procedure   MyOutStreamCallBack          (const stream:TStream); override;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
  end;

  { TFRE_ZPOOL_IOSTAT_PARSER }

  TFRE_ZPOOL_IOSTAT_PARSER=class(TFOS_PARSER_PROC)
  private
     fsubfeeder          : TFRE_DISKSUB_FEED_SERVER;
  protected
     procedure   MySetup ; override;
     procedure   MyOutStreamCallBack (const stream:TStream); override;
  public
    constructor Create                       (const subfeeder:TFRE_DISKSUB_FEED_SERVER);
  end;

  { TFRE_DISKSUB_FEED_SERVER }

  TFRE_DISKSUB_FEED_SERVER=class(TFRE_BASESUBFEED_SERVER)
  private
    FDataTimer                               : IFRE_APSC_TIMER;
    FDiskIoStatMon                           : TFRE_IOSTAT_PARSER;
    FPoolStatusMon                           : TFRE_ZPOOL_STATUS_PARSER;
    FPoolIostatMon                           : TFRE_ZPOOL_IOSTAT_PARSER;
    Fdiskenclosurethread                     : TDiskAndEnclosureThread;

    procedure  StartDiskAndEnclosureThread   ;
    procedure  StartIostatParser             ;
    procedure  StartZpoolStatusParser        ;
    procedure  StartZpoolIOStatParser        ;

  protected
    procedure  Setup           ; override;
    destructor Destroy         ; override;
    procedure  DataParsed      (const timer : IFRE_APSC_TIMER ; const flag1,flag2 : boolean);
  public
  end;


implementation

{ TFRE_DISKSUB_FEED_SERVER }

procedure TFRE_DISKSUB_FEED_SERVER.StartDiskAndEnclosureThread;
begin
  Fdiskenclosurethread:=TDiskAndEnclosureThread.Create(self);
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartIostatParser;
begin
  FDiskIoStatMon := TFRE_IOSTAT_PARSER.Create(self);
  FDiskIoStatMon.Enable;
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartZpoolStatusParser;
begin
  FPoolStatusMon := TFRE_ZPOOL_STATUS_PARSER.Create(self);
  FPoolStatusMon.Enable;
end;

procedure TFRE_DISKSUB_FEED_SERVER.StartZpoolIOStatParser;
begin
  FPoolIostatMon := TFRE_ZPOOL_IOSTAT_PARSER.Create(self);
  FPoolIostatMon.Enable;
end;

procedure TFRE_DISKSUB_FEED_SERVER.Setup;
begin
  fre_dbbase.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;

  FCfg.SpecialFile := cFRE_UX_SOCKS_DIR+'disksub';
  FCfg.Id          := 'DiskSub';
  FCfg.Port        := '44101';
  FCfg.IP          := '0.0.0.0';
  inherited Setup;
//  GFRE_SC.AddTimer('FAKEPARSE',1000,@DataParsed);

//  StartDiskAndEnclosureThread;
//  StartIostatParser;
  StartZpoolStatusParser;
//  StartZpoolIOStatParser;
end;

destructor TFRE_DISKSUB_FEED_SERVER.Destroy;
begin
  writeln('DESTROYING SUBFEEDER');

  if Assigned(FDiskIoStatMon) then
    FDiskIoStatMon.Free;
  if Assigned(FPoolStatusMon) then
    FPoolStatusMon.Free;
  if Assigned(FPoolIostatMon) then
    FPoolIostatMon.Free;

  if Assigned(Fdiskenclosurethread) then
    begin
      writeln('TERMINATE THREAD');
      Fdiskenclosurethread.Terminate;
//      Fdiskenclosurethread.WaitFor;
//      Fdiskenclosurethread.Free;
    end;

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

{ TFRE_ZPOOL_IOSTAT_PARSER }

procedure TFRE_ZPOOL_IOSTAT_PARSER.MyOutStreamCallBack(const stream: TStream);
var st       : TStringStream;
    sl       : TStringlist;
    i,j      : integer;
    s        : string;
    lc       : integer;
    SA       : TFOSStringArray;
    pool_name: String;
    np       : Boolean;
    rz_cout  : Integer;
    resdbo   : IFRE_DB_Object;

  //                               capacity     operations    bandwidth
  // pool                       alloc   free   read  write   read  write
  procedure _UpdateZpoolIostat;
  var zfsObjId : string[30];
  begin
    zfsObjId := Fline[0];
    if np then begin
      pool_name := zfsObjId;
      np:=false;
    end;
    if pos('raidz',LowerCase(zfsObjId))=1 then begin //FIXXME - HACK
      zfsObjId:=zfsObjId+'-'+IntToStr(rz_cout);
      rz_cout:=rz_cout+1;
    end;
    FData.Field(pool_name).AsObject.Field(zfsObjId).AsObject.Field('iops_r').AsString     := Fline[3];//can be -
    FData.Field(pool_name).AsObject.Field(zfsObjId).AsObject.Field('iops_w').AsString     := Fline[4];
    FData.Field(pool_name).AsObject.Field(zfsObjId).AsObject.Field('transfer_r').AsString := Fline[5];//in K,M
    FData.Field(pool_name).AsObject.Field(zfsObjId).AsObject.Field('transfer_w').AsString := Fline[6];//
  end;

begin
  stream.Position:=0;
  st := TStringStream.Create('');
  try
    st.CopyFrom(stream,stream.Size);
    stream.Size:=0;
    FLines.DelimitedText := st.DataString;
    if Flines.count>0 then begin
      if pos('capacity',Flines[0])>1 then begin
        lc := FLines.Count;
        for i := 2 to lc-4 do begin
          s := FLines[i];
          if s='' then begin
            continue;
          end;
          GFRE_BT.SeperateString(s,' ',SA);
          fline.Clear;
          for j := 0 to high(sa) do begin
            if sa[j]<>'' then FLine.Add(sa[j]);
          end;
          if pos('-',Fline[0])=1 then begin
            np:=true;
            rz_cout:=0;
            continue;
          end;
          if FLine.count<>7 then
            continue;
            //raise EFRE_Exception.Create('zpool iostat parser error, unexpected val count ' + IntToStr(fline.Count)+' '+fline.text);
          FLock.Acquire;
          try
            try
              _UpdateZpoolIostat;
            except on E:Exception do begin
              writeln(ClassName,'>>>Mickey Parser Error---');
              s:= Fline.DelimitedText;
              writeln(s);
              writeln(Classname,'<<<Mickey Parser Error---');
            end;end;
          finally
            FLock.Release;
          end;
        end;
      end;
    end else begin
      writeln(ClassName,'*IGNORING JUNK : ',st.Size,': [',st.DataString,']');
    end;
  finally
    st.Free;
  end;
  resdbo := GFRE_DBI.NewObject;
  resdbo.Field('subfeed').asstring   := 'ZPOOLIOSTAT';
  resdbo.Field('data').AsObject      := Get_Data_Object;
  fsubfeeder.PushDataToClients(resdbo);
end;

constructor TFRE_ZPOOL_IOSTAT_PARSER.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
begin
  inherited Create(cFRE_REMOTE_USER,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'),cFRE_REMOTE_HOST,cGET_ZPOOL_IOSTAT);
  fsubfeeder := subfeeder;
end;




procedure TFRE_ZPOOL_IOSTAT_PARSER.MySetup;
begin
  FLine.Delimiter:=' ';
end;



{ TFRE_ZPOOL_STATUS_PARSER }

procedure TFRE_ZPOOL_STATUS_PARSER.MyOutStreamCallBack(const stream: TStream);

type
    TpoolparseState = (pp_notfound,pp_found);

var st     : TStringStream;
    obj    : IFRE_DB_Object;
    resdbo : IFRE_DB_Object;
    plines : TStringList;
    i      : NativeInt;
    pstate : TpoolparseState;
    pool   : TFRE_DB_ZFS_POOL;

begin
  obj := GFRE_DBI.NewObject;

  pstate := pp_notfound;
  stream.Position:=0;
  st     := TStringStream.Create('');
  plines := TStringList.Create;
  try
    st.CopyFrom(stream,stream.Size);
    stream.Size:=0;
    flines.Text:=st.DataString;
    for i:=0 to flines.Count-1 do begin
      case pstate of
        pp_notfound:
          begin
            if Pos('pool:',flines[i])>0 then
              begin
                plines.Add(flines[i]);
                pstate := pp_found;
              end;
          end;
        pp_found:
          begin
            plines.add(flines[i]);
            if Pos('errors:',flines[i])>0 then
              begin
                if ParseZpool(plines.Text,pool) then
                  obj.Field(pool.Field('pool').asstring).AsObject:=pool;
                plines.Clear;
                pstate := pp_notfound;
              end;
          end;
      end;
    end;
  finally
    plines.Free;
    st.free;
  end;
  resdbo := GFRE_DBI.NewObject;
  resdbo.Field('subfeed').asstring   := 'ZPOOLSTATUS';
  resdbo.Field('data').AsObject      := obj;
  fsubfeeder.PushDataToClients(resdbo);
end;

constructor TFRE_ZPOOL_STATUS_PARSER.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
begin
  inherited Create(cFRE_REMOTE_USER,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'),cFRE_REMOTE_HOST,cZPOOLSTATUS);
  fsubfeeder := subfeeder;
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
begin
  writeln('exec');
  repeat
    so     := TFRE_DB_SCSI.create;
    try
      so.SetRemoteSSH(cFRE_REMOTE_USER, cFRE_REMOTE_HOST, SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
      res    := so.GetSG3DiskAndEnclosureInformation(error,obj);
  //    res    := so.GetDiskInformation(error,obj);
      resdbo := GFRE_DBI.NewObject;
      resdbo.Field('subfeed').asstring   := 'DISKENCLOSURE';
      resdbo.Field('resultcode').AsInt32 := res;
      resdbo.Field('error').asstring     := error;
      resdbo.Field('data').AsObject      := obj;
//      writeln('SAVE');
//      resdbo.SaveToFile('DISKENC');
      fsubfeeder.PushDataToClients(resdbo);
      sleep(5000);
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
    obj    : IFRE_DB_Object;
    resdbo : IFRE_DB_Object;

  //  r/s,w/s,kr/s,kw/s,wait,actv,wsvc_t,asvc_t,%w,%b,device
  procedure _UpdateDisk;
  var devicename : string[30];
      diskiostat : TFRE_DB_IOSTAT;
  begin
    devicename := Fline[10];
    diskiostat := TFRE_DB_IOSTAT.Create;
    try
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
    except on E:Exception do begin
      writeln(ClassName,'>>>Mickey Parser Error---');
      s:= Fline.DelimitedText;
      writeln(s);
      writeln(Classname,'<<<Mickey Parser Error---');
    end;end;
    diskiostat.Field('iodevicename').AsString := devicename;
    obj.Field(devicename).AsObject          := diskiostat;
  end;

begin
  obj := GFRE_DBI.NewObject;
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
          _UpdateDisk;
        end;
      end;
    end else begin
      writeln(ClassName,'*IGNORING JUNK : ',st.Size,': [',st.DataString,']');
    end;
  finally
    st.Free;
  end;
  resdbo := GFRE_DBI.NewObject;
  resdbo.Field('subfeed').asstring   := 'IOSTAT';
  resdbo.Field('data').AsObject      := obj;
  fsubfeeder.PushDataToClients(resdbo);
end;

constructor TFRE_IOSTAT_PARSER.Create(const subfeeder: TFRE_DISKSUB_FEED_SERVER);
var cmd:string;
begin
  if cFRE_REMOTE_HOST<>'' then
    cmd := cIOSTATFILEHACKMIST
  else
    cmd := cIOSTATFILEHACKMIST_LOC;

  inherited Create(cFRE_REMOTE_USER,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'),cFRE_REMOTE_HOST,cmd);
  fsubfeeder := subfeeder;
end;



initialization

end.
