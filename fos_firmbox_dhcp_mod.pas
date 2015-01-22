unit fos_firmbox_dhcp_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fre_hal_schemes,fre_dbbusiness;

type

{ TFRE_FIRMBOX_DHCP_MOD }

  TFRE_FIRMBOX_DHCP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects           (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects       (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    procedure       SetupAppModuleStructure    ; override;
  public
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_DHCP_MOD);
end;

{ TFRE_FIRMBOX_DHCP_MOD }

class procedure TFRE_FIRMBOX_DHCP_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_DHCP_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('dhcp_description')
end;

class procedure TFRE_FIRMBOX_DHCP_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'dhcp_description','DHCP','DHCP','DHCP');

  end;
end;

class procedure TFRE_FIRMBOX_DHCP_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  inherited InstallUserDBObjects(conn, currentVersionId);
end;

procedure TFRE_FIRMBOX_DHCP_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  dc       : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_customer_objname'),true,dt_string,true,true,1,'',FetchModuleTextShort(session,'grid_customer_default_value'),nil,false,'domainid');
      AddOneToOnescheme('default_domainname','default_domainname','DEFAULT DOMAINNAME');
      AddFulltextFilterOnTransformed(['customer','default_domainname']);
    end;

    dc := session.NewDerivedCollection('DHCP_SERVICES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],FetchModuleTextShort(session,'grid_dhcp_services_cap'),nil,nil);//,CWSF(@WEB_ServiceSC));
      //SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('service',['TFRE_DB_DHCP']);
    end;

  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc: IFRE_DB_DERIVED_COLLECTION;
begin
  CheckClassVisibility4AnyDomain(ses);

  dc:=ses.FetchDerivedCollection('DHCP_SERVICES_GRID');

  Result:=dc.GetDisplayDescription;
end;

end.

