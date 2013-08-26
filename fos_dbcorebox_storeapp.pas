unit FOS_DBCOREBOX_STOREAPP;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_SYSRIGHT_CONSTANTS,
  FRE_DB_INTERFACE;

type

  { TFRE_DBCOREBOX_STORE_APP }

  TFRE_DBCOREBOX_STORE_APP=class(TFRE_DB_APPLICATION)
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
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_STORE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_DBCOREBOX_STORE_APP }

procedure TFRE_DBCOREBOX_STORE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('corebox_store','$description');
end;

function TFRE_DBCOREBOX_STORE_APP.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
var admin_app_rg : IFRE_DB_ROLE;
     user_app_rg : IFRE_DB_ROLE;
    guest_app_rg : IFRE_DB_ROLE;
    old_version  : TFRE_DB_String;
begin
  case _CheckVersion(conn,old_version) of
    NotInstalled : begin
                      _SetAppdataVersion(conn,_ActualVersion);
                      admin_app_rg  := _CreateAppRole('ADMIN','COREBOX STOREAPP ADMIN','Corebox STOREAPP Administration Rights');
                      user_app_rg   := _CreateAppRole('USER','COREBOX STOREAPP USER','Corebox STOREAPP Default User Rights');
                      guest_app_rg  := _CreateAppRole('GUEST','COREBOX STOREAPP GUEST','Corebox STOREAPP Default Guest User Rights');
                      _AddAppRight(admin_app_rg ,'ADMIN'  ,'COREBOX STOREAPP Admin','Administration of Corebox STOREAPP');
                      _AddAppRight(user_app_rg  ,'START'  ,'COREBOX STOREAPP Start','Startup of Corebox STOREAPP');

                      _AddAppRight(guest_app_rg ,'START','COREBOX STOREAPP Start','Startup of COREBORX STOREAPP');
                      _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['main']));
                      _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['modules']));
                      _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['space']));
                      _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['machines']));
                      _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['ram']));
                      _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['cpu']));

                      conn.StoreRole(ObjectName,cSYS_DOMAIN,admin_app_rg);
                      conn.StoreRole(ObjectName,cSYS_DOMAIN,user_app_rg);
                      conn.StoreRole(ObjectName,cSYS_DOMAIN,guest_app_rg);

                      _AddSystemGroups(conn,cSYS_DOMAIN);

                      CreateAppText(conn,'$description','Store','Store','Store');
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

procedure TFRE_DBCOREBOX_STORE_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  //STORE(SALES) -> APP ( Funktionsmodule / Speicherplatz Kaufen / VM RAM / Virtuelle CPU's / BACKUPSPACE )
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store','Store','images_apps/corebox_store/store_white.svg','',0,CheckAppRightModule(conn,'main'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Modules','Modules','images_apps/corebox_store/puzzle_white.svg','',0,CheckAppRightModule(conn,'modules'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Backupspace','Backupspace','images_apps/corebox_store/clock_white.svg','',0,CheckAppRightModule(conn,'space'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Machines','Machines','images_apps/corebox_store/server_white.svg','',0,CheckAppRightModule(conn,'machines'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Machines/RAM','RAM','images_apps/corebox_store/microchip_white.svg','',0,CheckAppRightModule(conn,'ram'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Machines/CPU','CPU','images_apps/corebox_store/gauge_white.svg','',0,CheckAppRightModule(conn,'cpu'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);      session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_DBCOREBOX_STORE_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_DBCOREBOX_STORE_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  _UpdateSitemap(session);
end;

function TFRE_DBCOREBOX_STORE_APP.CFG_ApplicationUsesRights: boolean;
begin
  result := true;
end;

function TFRE_DBCOREBOX_STORE_APP._ActualVersion: TFRE_DB_String;
begin
  Result :='1.0';
end;

class procedure TFRE_DBCOREBOX_STORE_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;


end.


