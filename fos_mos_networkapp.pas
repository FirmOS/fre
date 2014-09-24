unit fos_mos_networkapp;

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
  fos_firmbox_dns_mod;

type

  { TFOS_CITYCOM_NETWORK_APP }

  TFOS_CITYCOM_NETWORK_APP=class(TFRE_DB_APPLICATION)
  private

    procedure       SetupApplicationStructure     ; override;
    procedure       _UpdateSitemap                (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize           (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion            (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme          (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects              (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain       (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    class procedure InstallUserDBObjects          (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fos_firmbox_dns_mod.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_NETWORK_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_CITYCOM_NETWORK_APP }

procedure TFOS_CITYCOM_NETWORK_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitApp('description');
  AddApplicationModule(TFOS_FIRMBOX_DNS_MOD.create);
end;

procedure TFOS_CITYCOM_NETWORK_APP._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'NETWORK',FetchAppTextShort(session,'sitemap_main'),'images_apps/citycom_network/main_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_CITYCOM_NETWORK_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'NETWORK/DNS',FetchAppTextShort(session,'sitemap_dns'),'images_apps/citycom_network/dns_white.svg',TFOS_FIRMBOX_DNS_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_FIRMBOX_DNS_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFOS_CITYCOM_NETWORK_APP.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFOS_CITYCOM_NETWORK_APP.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFOS_CITYCOM_NETWORK_APP.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFOS_CITYCOM_NETWORK_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
  newVersionId:='0.1';

  if (currentVersionId='') then begin
    currentVersionId := '0.1';
    CreateAppText(conn,'caption','Network','Network','Network');
    CreateAppText(conn,'sitemap_main','Main','','Main');
    CreateAppText(conn,'sitemap_dns','DNS','','DNS');
  end;
end;

class procedure TFOS_CITYCOM_NETWORK_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then begin
    currentVersionId:='0.1';
    //ADMINS
    CheckDbResult(conn.AddGroup('NETWORKADMINS','Admins of Citycom Network','Network Admins',domainUID),'could not create admins group');

    CheckDbResult(conn.AddRolesToGroup('NETWORKADMINS',domainUID,TFRE_DB_StringArray.Create(
      TFOS_CITYCOM_NETWORK_APP.GetClassRoleNameFetch,
      TFOS_FIRMBOX_DNS_MOD.GetClassRoleNameFetch
    )),'could not add roles for group Admins');

    CheckDbResult(conn.AddRolesToGroup('NETWORKADMINS',domainUID, TFOS_DB_NETWORK_DOMAIN.GetClassStdRoles),'could not add roles TFOS_DB_NETWORK_DOMAIN for group Admins');
    CheckDbResult(conn.AddRolesToGroup('NETWORKADMINS',domainUID, TFOS_DB_DNS_RESOURCE_RECORD.GetClassStdRoles),'could not add roles TFOS_DB_DNS_RESOURCE_RECORD for group Admins');

    //MANAGERS
    CheckDbResult(conn.AddGroup('NETWORKMANAGERS','Managers of Citycom Network','Network Managers',domainUID),'could not create managers group');

    CheckDbResult(conn.AddRolesToGroup('NETWORKMANAGERS',domainUID,TFRE_DB_StringArray.Create(
      TFOS_CITYCOM_NETWORK_APP.GetClassRoleNameFetch,
      TFOS_FIRMBOX_DNS_MOD.GetClassRoleNameFetch
    )),'could not add roles for group Managers');

    CheckDbResult(conn.AddRolesToGroup('NETWORKMANAGERS',domainUID, TFOS_DB_NETWORK_DOMAIN.GetClassStdRoles(true,true,false,true)),'could not add roles TFOS_DB_NETWORK_DOMAIN for group Managers');
    CheckDbResult(conn.AddRolesToGroup('NETWORKMANAGERS',domainUID, TFOS_DB_DNS_RESOURCE_RECORD.GetClassStdRoles(true,true,false,true)),'could not add roles TFOS_DB_DNS_RESOURCE_RECORD for group Managers');

    //VIEWERS
    CheckDbResult(conn.AddGroup('NETWORKVIEWERS','Viewers of Citycom Network','Network Viewers',domainUID),'could not create viewers group');

    CheckDbResult(conn.AddRolesToGroup('NETWORKVIEWERS',domainUID,TFRE_DB_StringArray.Create(
      TFOS_CITYCOM_NETWORK_APP.GetClassRoleNameFetch,
      TFOS_FIRMBOX_DNS_MOD.GetClassRoleNameFetch
    )),'could not add roles for group Viewers');

    CheckDbResult(conn.AddRolesToGroup('NETWORKVIEWERS',domainUID, TFOS_DB_NETWORK_DOMAIN.GetClassStdRoles(false,false,false,true)),'could not add roles TFOS_DB_NETWORK_DOMAIN for group Viewers');
    CheckDbResult(conn.AddRolesToGroup('NETWORKVIEWERS',domainUID, TFOS_DB_DNS_RESOURCE_RECORD.GetClassStdRoles(false,false,false,true)),'could not add roles TFOS_DB_DNS_RESOURCE_RECORD for group Viewers');
  end;

end;

class procedure TFOS_CITYCOM_NETWORK_APP.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';
  end;
end;

end.

