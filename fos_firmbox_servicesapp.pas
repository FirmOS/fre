unit fos_firmbox_servicesapp;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH

  Licence conditions
(§LIC_END)
}

{$codepage UTF8}
{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fre_system,
  fre_zfs;

const

  CFOS_DB_SERVICE_DOMAINS_COLLECTION   = 'services_domains';
  CFOS_DB_ZONES_COLLECTION             = 'zones';
  CFOS_DB_MANAGED_SERVICES_COLLECTION  = 'managed_services';

type

  { TFOS_FIRMBOX_SERVICES_APP }

  TFOS_FIRMBOX_SERVICES_APP=class(TFRE_DB_APPLICATION)
  private

    procedure       SetupApplicationStructure     ; override;
    procedure       _UpdateSitemap                (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize           (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion            (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme          (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects              (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain       (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    class procedure InstallUserDBObjects          (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_FIRMBOX_MANAGED_SERVICES_MOD }

  TFOS_FIRMBOX_MANAGED_SERVICES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    class procedure InstallDBObjects              (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_MANAGED_SERVICES_MOD);

  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_SERVICES_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_FIRMBOX_MANAGED_SERVICES_MOD }

class procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$managed_services_description')
end;

procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  grid     : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    if session.IsInteractiveSession then begin
      GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
      with transform do begin
        AddOneToOnescheme('displayname','displayname',app.FetchAppTextShort(session,'$grid_managed_services_name'),dt_string,true,true);
      end;
      grid := session.NewDerivedCollection('MANAGED_SERVICES_GRID');
      with grid do begin
        SetDeriveParent(conn.GetCollection(CFRE_DB_MACHINE_COLLECTION));
        SetDeriveTransformation(transform);
        SetDisplayType(cdt_Listview,[cdgf_Children],'');
        //SetDisplayType(cdt_Listview,[cdgf_Children],'',nil,'',CWSF(@WEB_ProductsMenu),nil,CWSF(@WEB_ProductsSC));
        SetParentToChildLinkField ('<SERVICEPARENT');
        SetDefaultOrderField('displayname',true);
      end;
    end;
  end;
end;

class procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc  : IFRE_DB_DERIVED_COLLECTION;
  grid: TFRE_DB_VIEW_LIST_DESC;
begin
  dc:=ses.FetchDerivedCollection('MANAGED_SERVICES_GRID');
  grid:=dc.GetDisplayDescription().Implementor_HC as TFRE_DB_VIEW_LIST_DESC;
  Result:=grid;
end;

{ TFOS_FIRMBOX_SERVICES_APP }

procedure TFOS_FIRMBOX_SERVICES_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('$description');
  AddApplicationModule(TFOS_FIRMBOX_MANAGED_SERVICES_MOD.create);
end;

procedure TFOS_FIRMBOX_SERVICES_APP._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services',FetchAppTextShort(session,'$sitemap_main'),'images_apps/firmbox_services/main_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_FIRMBOX_SERVICES_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Managed',FetchAppTextShort(session,'$sitemap_managed_services'),'images_apps/firmbox_services/managed_services_white.svg',TFOS_FIRMBOX_MANAGED_SERVICES_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_FIRMBOX_MANAGED_SERVICES_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFOS_FIRMBOX_SERVICES_APP.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFOS_FIRMBOX_SERVICES_APP.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      currentVersionId:='1.0';

      CreateAppText(conn,'$caption','Services','Services','Services');
      CreateAppText(conn,'$managed_services_description','Managed Services','Managed Services','Managed Services');

      CreateAppText(conn,'$sitemap_main','Services','','Services');
      CreateAppText(conn,'$sitemap_managed_services','Managed','','Managed');

      CreateAppText(conn,'$grid_managed_services_name','Name');

      //FIXXME - CHECK
      CreateAppText(conn,'$error_no_access','Access denied'); //global text?
      CreateAppText(conn,'$button_save','Save'); //global text?
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
  VersionInstallCheck(currentVersionId,newVersionId);
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then
    begin
      //ADMINS
      CheckDbResult(conn.AddGroup('SERVICESADMINS','Admins of Firmbox Services','Services Admins',domainUID),'could not create admins group');

      CheckDbResult(conn.AddRolesToGroup('SERVICESADMINS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_FIRMBOX_SERVICES_APP.GetClassRoleNameFetch,
        TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Admins');

      CheckDbResult(conn.AddRolesToGroup('SERVICESADMINS',domainUID, TFRE_DB_NOTE.GetClassStdRoles),'could not add roles TFRE_DB_NOTE for group Admins');

      //MANAGERS
      CheckDbResult(conn.AddGroup('SERVICESMANAGERS','Managers of Firmbox Services','Services Managers',domainUID),'could not create managers group');

      CheckDbResult(conn.AddRolesToGroup('SERVICESMANAGERS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_FIRMBOX_SERVICES_APP.GetClassRoleNameFetch,
        TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Managers');

      CheckDbResult(conn.AddRolesToGroup('SERVICESMANAGERS',domainUID, TFRE_DB_NOTE.GetClassStdRoles),'could not add roles TFRE_DB_NOTE for group Managers');

      //VIEWERS
      CheckDbResult(conn.AddGroup('SERVICESVIEWERS','Viewers of Firmbox Services','Services Viewers',domainUID),'could not create viewers group');

      CheckDbResult(conn.AddRolesToGroup('SERVICESVIEWERS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_FIRMBOX_SERVICES_APP.GetClassRoleNameFetch,
        TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Viewers');

      CheckDbResult(conn.AddRolesToGroup('SERVICESVIEWERS',domainUID,TFRE_DB_StringArray.Create(
        TFRE_DB_NOTE.GetClassRoleNameFetch
      )),'could not add roles for group Viewers');

    end;
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
var
  coll     : IFRE_DB_COLLECTION;
begin
    if currentVersionId='' then begin
      currentVersionId := '1.0';
      coll := conn.CreateCollection(CFOS_DB_MANAGED_SERVICES_COLLECTION,false);
      //coll.DefineIndexOnField('name',fdbft_String,true,true);
      coll := conn.CreateCollection(CFOS_DB_SERVICE_DOMAINS_COLLECTION,false);
      coll := conn.CreateCollection(CFOS_DB_ZONES_COLLECTION,false);
    end;
end;

end.

