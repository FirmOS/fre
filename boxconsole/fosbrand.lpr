program fosbrand;

{$mode objfpc}{$H+}

{$LIBRARYPATH ../../lib}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, fosillu_libzonecfg,fre_process,
  FRE_SYSTEM,FOS_DEFAULT_IMPLEMENTATION,FOS_TOOL_INTERFACES,FOS_FCOM_TYPES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,
  FRE_DB_CORE,fre_dbbase, FRE_DB_EMBEDDED_IMPL, FRE_CONFIGURATION,fre_hal_schemes, fre_zfs
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
begin
  InitMinimal(false);
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;



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
//  0=[/usr/lib/brand/fbz/fosbrand] 1=[--post] 2=[15a56c904a7f00248929bfdb576a45c9] 3=[/syspool/domains/df842e6d890b0fb5bb3a1b8db0cc8dc6/15a56c904a7f00248929bfdb576a45c9] 4=[2] 5=[0]

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

