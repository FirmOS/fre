unit fos_firmbox_infrastructureapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE;

type

  { TFRE_FIRMBOX_INFRASTRUCTURE_APP }

  TFRE_FIRMBOX_INFRASTRUCTURE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    procedure       _UpdateSitemap            (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
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
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure','Infrastructure','images_apps/firmbox_infrastructure/infrastructure_white.svg','',0,conn.SYS.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_INFRASTRUCTURE_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Computer','Devices','images_apps/firmbox_infrastructure/computer_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/AP','Wifi','images_apps/firmbox_infrastructure/wireless_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Network','Network','images_apps/firmbox_infrastructure/network_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/VPN','VPN','images_apps/firmbox_infrastructure/house_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Portsecurity','Portsecurity','images_apps/firmbox_infrastructure/security_white.svg','',0,false);
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Infrastructure/Assets','Assets','images_apps/firmbox_infrastructure/handheld_white.svg','',0,false);
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  Session.GetSessionAppData(ClassName).Field('SITEMAP').AsObject := SiteMapData;
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
  if session.IsInteractiveSession then
   _UpdateSitemap(session);
end;

class procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFRE_FIRMBOX_INFRASTRUCTURE_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      CreateAppText(conn,'caption','Infrastructure','Infrastructure','Infrastructure');
      currentVersionId:='1.0';
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
end;


end.


end.

