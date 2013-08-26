unit FOS_DBCOREBOX_SERVICESAPP;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_SYSRIGHT_CONSTANTS,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON;

type

  { TFRE_DBCOREBOX_SERVICES_APP }

  TFRE_DBCOREBOX_SERVICES_APP=class(TFRE_DB_APPLICATION)
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

  { TFRE_DBCOREBOX_MAILSERVER_MOD }

  TFRE_DBCOREBOX_MAILSERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DBCOREBOX_WEBSERVER_MOD }

  TFRE_DBCOREBOX_WEBSERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DBCOREBOX_DATABASE_MOD }

  TFRE_DBCOREBOX_DATABASE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;
procedure Register_DB_Extensions;

implementation


{ TFRE_DBCOREBOX_MAILSERVER_MOD }

class procedure TFRE_DBCOREBOX_MAILSERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_MAILSERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('MAILSERVER','$mailserver_description')
end;


function TFRE_DBCOREBOX_MAILSERVER_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;

{ TFRE_DBCOREBOX_WEBSERVER_MOD }

class procedure TFRE_DBCOREBOX_WEBSERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_WEBSERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('WEBSERVER','$webserver_description')
end;


function TFRE_DBCOREBOX_WEBSERVER_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;

{ TFRE_DBCOREBOX_DATABASE_MOD }

class procedure TFRE_DBCOREBOX_DATABASE_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;

procedure TFRE_DBCOREBOX_DATABASE_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('DATABASE','$database_description')
end;


function TFRE_DBCOREBOX_DATABASE_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;


{ TFRE_DBCOREBOX_SERVICES_APP }

procedure TFRE_DBCOREBOX_SERVICES_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('corebox_services','$description');
  AddApplicationModule(TFRE_DBCOREBOX_MAILSERVER_MOD.create);
  AddApplicationModule(TFRE_DBCOREBOX_WEBSERVER_MOD.create);
  AddApplicationModule(TFRE_DBCOREBOX_DATABASE_MOD.create);
end;

function TFRE_DBCOREBOX_SERVICES_APP.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
var admin_app_rg : IFRE_DB_ROLE;
     user_app_rg : IFRE_DB_ROLE;
    guest_app_rg : IFRE_DB_ROLE;
    old_version  : TFRE_DB_String;
begin
  case _CheckVersion(conn,old_version) of
   NotInstalled : begin
                     _SetAppdataVersion(conn,_ActualVersion);
                     admin_app_rg  := _CreateAppRole('ADMIN','COREBOX SERVICESAPP ADMIN','Corebox SERVICESAPP Administration Rights');
                     user_app_rg   := _CreateAppRole('USER','COREBOX SERVICESAPP USER','Corebox SERVICESAPP Default User Rights');
                     guest_app_rg  := _CreateAppRole('GUEST','COREBOX SERVICESAPP GUEST','Corebox SERVICESAPP Default Guest User Rights');
                     _AddAppRight(admin_app_rg ,'ADMIN'  ,'COREBOX SERVICESAPP Admin','Administration of Corebox SERVICESAPP');
                     _AddAppRight(user_app_rg  ,'START'  ,'COREBOX SERVICESAPP Start','Startup of Corebox SERVICESAPP');

//                     _AddAppRight(guest_app_rg ,'START','COREBOX SERVICESAPP Start','Startup of COREBORX SERVICESAPP');

                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['main']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['mailserver']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['webmail']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['webserver']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['database']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['pgsql']));
                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['mysql']));

                     conn.StoreRole(ObjectName,cSYS_DOMAIN,admin_app_rg);
                     conn.StoreRole(ObjectName,cSYS_DOMAIN,user_app_rg);
                     conn.StoreRole(ObjectName,cSYS_DOMAIN,guest_app_rg);

                     _AddSystemGroups(conn,cSYS_DOMAIN);

                     CreateAppText(conn,'$description','Services','Services','Services');
                     CreateAppText(conn,'$mailserver_description','Mailserver','Mailserver','Mailserver');
                     CreateAppText(conn,'$webserver_description','Webserver','Webserver','Webserver');
                     CreateAppText(conn,'$database_description','Database','Database','Database');
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

procedure TFRE_DBCOREBOX_SERVICES_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services',FetchAppText(conn,'$sitemap_main').Getshort,'images_apps/corebox_services/tool_white.svg','',0,CheckAppRightModule(conn,'main'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Mailserver','Mailserver','images_apps/corebox_services/letter_white.svg','MAILSERVER',0,CheckAppRightModule(conn,'mailserver'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Mailserver/Webmail','Webmail','images_apps/corebox_services/letter_white.svg','',0,CheckAppRightModule(conn,'webmail'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Webserver','Webserver','images_apps/corebox_services/webportal_white.svg','WEBSERVER',0,CheckAppRightModule(conn,'webserver'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Database','Database','images_apps/corebox_services/db_white.svg','DATABASE',0,CheckAppRightModule(conn,'database'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Database/PostgreSQL','PostgreSQL','images_apps/corebox_services/db_white.svg','',0,CheckAppRightModule(conn,'pgsql'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Database/MySQL','MySQL','images_apps/corebox_services/db_white.svg','',0,CheckAppRightModule(conn,'mysql'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;                           session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_DBCOREBOX_SERVICES_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_DBCOREBOX_SERVICES_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  _UpdateSitemap(session);
end;

function TFRE_DBCOREBOX_SERVICES_APP.CFG_ApplicationUsesRights: boolean;
begin
  result := true;
end;

function TFRE_DBCOREBOX_SERVICES_APP._ActualVersion: TFRE_DB_String;
begin
  Result := '1.0';
end;

class procedure TFRE_DBCOREBOX_SERVICES_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_MAILSERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_WEBSERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_DATABASE_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_SERVICES_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;


end.

