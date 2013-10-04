unit fos_firmbox_infrastructureapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_SYSRIGHT_CONSTANTS,
  FRE_DB_INTERFACE;

type

  { TFRE_FIRMBOX_INFRASTRUCTURE_APP }

  TFRE_FIRMBOX_INFRASTRUCTURE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    function        InstallAppDefaults        (const conn : IFRE_DB_SYS_CONNECTION):TFRE_DB_Errortype; override;
    procedure       _UpdateSitemap            (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
    function        CFG_ApplicationUsesRights : boolean; override;
    function        _ActualVersion            : TFRE_DB_String; override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
  published
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_INFRASTRUCTURE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_INFRASTRUCTURE_APP }

procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  writeln('init appdesc firmbox_infrastructure');
  InitAppDesc('firmbox_infrastructure','$description');
end;

function TFRE_FIRMBOX_INFRASTRUCTURE_APP.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
var admin_app_rg : IFRE_DB_ROLE;
     user_app_rg : IFRE_DB_ROLE;
    guest_app_rg : IFRE_DB_ROLE;
    appdata      : IFRE_DB_APPDATA;
    old_version  : TFRE_DB_String;
begin
  writeln('firmbox_infrastructure install appdefault role');

  case _CheckVersion(conn,old_version) of
   NotInstalled : begin
                     _SetAppdataVersion(conn,_ActualVersion);
                     admin_app_rg  := _CreateAppRole('ADMIN','firmbox INFRASTRUCTUREAPP ADMIN','firmbox INFRASTRUCTUREAPP Administration Rights');
                     user_app_rg   := _CreateAppRole('USER','firmbox INFRASTRUCTUREAPP USER','firmbox INFRASTRUCTUREAPP Default User Rights');
                     guest_app_rg  := _CreateAppRole('GUEST','firmbox INFRASTRUCTUREAPP GUEST','firmbox INFRASTRUCTUREAPP Default Guest User Rights');
                     _AddAppRight(admin_app_rg ,'ADMIN'  ,'firmbox INFRASTRUCTUREAPP Admin','Administration of firmbox INFRASTRUCTUREAPP');
                     _AddAppRight(user_app_rg  ,'START'  ,'firmbox INFRASTRUCTUREAPP Start','Startup of firmbox INFRASTRUCTUREAPP');

 //                    _AddAppRight(guest_app_rg ,'START','firmbox INFRASTRUCTUREAPP Start','Startup of COREBORX INFRASTRUCTUREAPP');
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['main']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['computer']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['ap']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['network']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['vpn']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['portsecurity']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['assets']));

                     CheckDbResult(conn.StoreRole(admin_app_rg,ObjectName,cSYS_DOMAIN),'Error creating default admin role for '+Objectname);
                     CheckDbResult(conn.StoreRole(user_app_rg,ObjectName,cSYS_DOMAIN),'Error creating default user role for '+Objectname);
                     CheckDbResult(conn.StoreRole(guest_app_rg,ObjectName,cSYS_DOMAIN),'Error creating default guest role for '+Objectname);

                     _AddSystemGroups(conn,cSYS_DOMAIN);

                     CreateAppText(conn,'$description','Infrastructure','Infrastructure','Infrastructure');
                  end;
   SameVersion  : begin
                     writeln('Version '+old_version+' already installed');
                  end;
   OtherVersion : begin
                     writeln('Old Version '+old_version+' found, updateing');
                     // do some update stuff
                     _SetAppdataVersion(conn,_ActualVersion);
                  end;
  else
   raise EFRE_DB_Exception.Create('Undefined App _CheckVersion result');
  end;
end;

procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
  i            : integer;

  //INFRA -> COMPUTER/GERÄTEVERWALTUNG | AP'S L2 (LANCOM | UBNT)  | NETZWERK | INFRASTRUKTUR | SWITCH PORTSECURITY | ASSETS | VPN
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure','Infrastructure','images_apps/firmbox_infrastructure/infrastructure_white.svg','',0,CheckAppRightModule(conn,'main'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Computer','Devices','images_apps/firmbox_infrastructure/computer_white.svg','',0,CheckAppRightModule(conn,'computer'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/AP','Wifi','images_apps/firmbox_infrastructure/wireless_white.svg','',0,CheckAppRightModule(conn,'ap'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Network','Network','images_apps/firmbox_infrastructure/network_white.svg','',0,CheckAppRightModule(conn,'network'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/VPN','VPN','images_apps/firmbox_infrastructure/house_white.svg','',0,CheckAppRightModule(conn,'vpn'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Portsecurity','Portsecurity','images_apps/firmbox_infrastructure/security_white.svg','',0,CheckAppRightModule(conn,'portsecurity'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Assets','Assets','images_apps/firmbox_infrastructure/handheld_white.svg','',0,CheckAppRightModule(conn,'assets'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  Session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  _UpdateSitemap(session);
end;

function TFRE_FIRMBOX_INFRASTRUCTURE_APP.CFG_ApplicationUsesRights: boolean;
begin
  result := true;
end;

function TFRE_FIRMBOX_INFRASTRUCTURE_APP._ActualVersion: TFRE_DB_String;
begin
  Result := '1.0';
end;

class procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;


end.


end.

