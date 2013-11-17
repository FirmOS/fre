unit fos_firmbox_servicesapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON;

type

  { TFRE_FIRMBOX_SERVICES_APP }

  TFRE_FIRMBOX_SERVICES_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    procedure       _UpdateSitemap            (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_FIRMBOX_MAILSERVER_MOD }

  TFRE_FIRMBOX_MAILSERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_WEBSERVER_MOD }

  TFRE_FIRMBOX_WEBSERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_DATABASE_MOD }

  TFRE_FIRMBOX_DATABASE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;
procedure Register_DB_Extensions;

implementation


{ TFRE_FIRMBOX_MAILSERVER_MOD }

class procedure TFRE_FIRMBOX_MAILSERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_MAILSERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$mailserver_description')
end;


function TFRE_FIRMBOX_MAILSERVER_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;

{ TFRE_FIRMBOX_WEBSERVER_MOD }

class procedure TFRE_FIRMBOX_WEBSERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_WEBSERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$webserver_description')
end;


function TFRE_FIRMBOX_WEBSERVER_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;

{ TFRE_FIRMBOX_DATABASE_MOD }

class procedure TFRE_FIRMBOX_DATABASE_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;

procedure TFRE_FIRMBOX_DATABASE_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$database_description')
end;


function TFRE_FIRMBOX_DATABASE_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;


{ TFRE_FIRMBOX_SERVICES_APP }

procedure TFRE_FIRMBOX_SERVICES_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  AddApplicationModule(TFRE_FIRMBOX_MAILSERVER_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_WEBSERVER_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_DATABASE_MOD.create);
end;

//function TFRE_FIRMBOX_SERVICES_APP.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
//var admin_app_rg : IFRE_DB_ROLE;
//     user_app_rg : IFRE_DB_ROLE;
//    guest_app_rg : IFRE_DB_ROLE;
//    old_version  : TFRE_DB_String;
//begin
//  case _CheckVersion(conn,old_version) of
//   NotInstalled : begin
//                     _SetAppdataVersion(conn,_ActualVersion);
//                     admin_app_rg  := _CreateAppRole('ADMIN','firmbox SERVICESAPP ADMIN','firmbox SERVICESAPP Administration Rights');
//                     user_app_rg   := _CreateAppRole('USER','firmbox SERVICESAPP USER','firmbox SERVICESAPP Default User Rights');
//                     guest_app_rg  := _CreateAppRole('GUEST','firmbox SERVICESAPP GUEST','firmbox SERVICESAPP Default Guest User Rights');
//                     _AddAppRight(admin_app_rg ,'ADMIN');
//                     _AddAppRight(user_app_rg  ,'START');
//
////                     _AddAppRight(guest_app_rg ,'START','firmbox SERVICESAPP Start','Startup of COREBORX SERVICESAPP');
//
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['main']));
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['mailserver']));
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['webmail']));
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['webserver']));
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['database']));
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['pgsql']));
//                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['mysql']));
//
//                     conn.StoreRole(admin_app_rg,ObjectName,CFRE_DB_SYS_DOMAIN_NAME);
//                     conn.StoreRole(user_app_rg,ObjectName,CFRE_DB_SYS_DOMAIN_NAME);
//                     conn.StoreRole(guest_app_rg,ObjectName,CFRE_DB_SYS_DOMAIN_NAME);
//
//                     // add preconfigured groups
//
//                     CreateAppText(conn,'$description','Services','Services','Services');
//                     CreateAppText(conn,'$mailserver_description','Mailserver','Mailserver','Mailserver');
//                     CreateAppText(conn,'$webserver_description','Webserver','Webserver','Webserver');
//                     CreateAppText(conn,'$database_description','Database','Database','Database');
//                  end;
//   SameVersion  : begin
//                     writeln('Version '+old_version+' already installed');
//                  end;
//   OtherVersion : begin
//                     writeln('Old Version '+old_version+' found, updateing');
//                     // do some update stuff
//                     _SetAppdataVersion(conn,_ActualVersion);
//                  end;
//  else
//   raise EFRE_DB_Exception.Create('Undefined App _CheckVersion result');
//  end;
//end;

procedure TFRE_FIRMBOX_SERVICES_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services',FetchAppTextShort(session,'$sitemap_main'),'images_apps/firmbox_services/tool_white.svg','',0,conn.SYS.CheckClassRight4AnyDomain(sr_FETCH,ClassType));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Mailserver','Mailserver','images_apps/firmbox_services/letter_white.svg','MAILSERVER',0,CheckAppRightModule(conn,'mailserver'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Mailserver/Webmail','Webmail','images_apps/firmbox_services/letter_white.svg','',0,CheckAppRightModule(conn,'webmail'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Webserver','Webserver','images_apps/firmbox_services/webportal_white.svg','WEBSERVER',0,CheckAppRightModule(conn,'webserver'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Database','Database','images_apps/firmbox_services/db_white.svg','DATABASE',0,CheckAppRightModule(conn,'database'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Database/PostgreSQL','PostgreSQL','images_apps/firmbox_services/db_white.svg','',0,CheckAppRightModule(conn,'pgsql'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Database/MySQL','MySQL','images_apps/firmbox_services/db_white.svg','',0,CheckAppRightModule(conn,'mysql'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(ClassName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_FIRMBOX_SERVICES_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_SERVICES_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFRE_FIRMBOX_SERVICES_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFRE_FIRMBOX_SERVICES_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      CreateAppText(conn,'$caption','Services','Services','Services');
      currentVersionId:='1.0';
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
end;


procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_MAILSERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_WEBSERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_DATABASE_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_SERVICES_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;


end.

