unit fos_firmbox_storeapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE;

type

  { TFRE_FIRMBOX_STORE_APP }

  TFRE_FIRMBOX_STORE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    procedure       _UpdateSitemap            (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain   (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_STORE_APP }

procedure TFRE_FIRMBOX_STORE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('$description');
end;


procedure TFRE_FIRMBOX_STORE_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  //STORE(SALES) -> APP ( Funktionsmodule / Speicherplatz Kaufen / VM RAM / Virtuelle CPU's / BACKUPSPACE )
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store','Store','images_apps/firmbox_store/store_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_STORE_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Modules','Modules','images_apps/firmbox_store/puzzle_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Backupspace','Backupspace','images_apps/firmbox_store/clock_white.svg','',0,true);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Machines','Machines','images_apps/firmbox_store/server_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Machines/RAM','RAM','images_apps/firmbox_store/microchip_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Store/Machines/CPU','CPU','images_apps/firmbox_store/gauge_white.svg','',0,false);
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_FIRMBOX_STORE_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_STORE_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFRE_FIRMBOX_STORE_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFRE_FIRMBOX_STORE_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      CreateAppText(conn,'$caption','Store','Store','Store');
      currentVersionId:='1.0';
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
end;

class procedure TFRE_FIRMBOX_STORE_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);
end;


end.


