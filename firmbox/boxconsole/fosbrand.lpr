program fosbrand;

{$mode objfpc}{$H+}

{$LIBRARYPATH ../../lib}

{$LINKLIB libdladm}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, fosillu_libzonecfg,fre_process,
  FRE_SYSTEM,FOS_DEFAULT_IMPLEMENTATION,FOS_TOOL_INTERFACES,FOS_FCOM_TYPES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,
  FRE_DB_CORE,fre_dbbase, fre_dbbusiness, FRE_CONFIGURATION,fre_hal_schemes, fre_zfs,fosillu_dladm,fosillu_libdladm
  { you can add units after this };

type

  { TFRE_fosbrand }

  TFRE_fosbrand = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   WriteHelp; virtual;
  end;

{ TFRE_fos_brand }

procedure TFRE_fosbrand.DoRun;
var
  ErrorMsg      : String;
  i             : NativeInt;
  state         : NativeInt;
  cmd           : NativeInt;
  pre           : boolean;
  tmpvnic       : string;
  zone_name     : string;
  zone_dbo_file : string;
  zone_dbo      : IFRE_DB_Object;
  zone_path     : string;
  zone          : TFRE_DB_ZONE;
  dlres         : dladm_status_t;

begin
  InitMinimal(false);
  fre_dbbase.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DB.Initialize_Extension_ObjectsBuild;

  dlres := dladm_open(@GILLU_DLADM);
  if dlres<>DLADM_STATUS_OK then
    raise Exception.Create('could not initialze libdlam');

  for i:=0 to ParamCount do
  begin
    write(inttostr(i)+'=['+ParamStr(i)+'] ');
  end;
  writeln;

  pre        := Pos('pre',ParamStr(1))>0;
  state      := strtoint(ParamStr(4));
  cmd        := strtoint(ParamStr(5));
  zone_name  := ParamStr(2);
  zone_path  := ParamStr(3);
  zone_dbo_file := Copy(zone_path,1,Pos('/domains',zone_path)-1)+'/zones/'+zone_name+'/zone.dbo';
  writeln('SWL: ',zone_dbo_file);
  zone_dbo  := GFRE_DBI.CreateFromFile(zone_dbo_file);
//  writeln('SWL ZONE:',zone_dbo.DumpToString());
//  0=[/usr/lib/brand/fbz/fosbrand] 1=[--post] 2=[15a56c904a7f00248929bfdb576a45c9] 3=[/syspool/parentds/domains/be866bbf47fe770522885cf5e884bf0d/15a56c904a7f00248929bfdb576a45c9] 4=[2] 5=[0]
  // --post 15a56c904a7f00248929bfdb576a45c9 /syspool/parentds/domains/be866bbf47fe770522885cf5e884bf0d/15a56c904a7f00248929bfdb576a45c9 2 0

  if (state=ZONE_STATE_INSTALLED) and (pre=false) and (cmd=0) then
    begin
      zone := (zone_dbo.Implementor_HC as TFRE_DB_ZONE);
      zone.BootingHookConfigure;
    end;

  // stop program loop
  Terminate;
end;

constructor TFRE_fosbrand.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TFRE_fosbrand.Destroy;
begin
  inherited Destroy;
end;

procedure TFRE_fosbrand.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TFRE_fosbrand;
begin
  Application:=TFRE_fosbrand.Create(nil);
  Application.Title:='fos_brand';
  Application.Run;
  Application.Free;
end.
