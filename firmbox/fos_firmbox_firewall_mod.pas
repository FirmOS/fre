unit fos_firmbox_firewall_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fre_hal_schemes,fre_zfs;

type

{ TFRE_FIRMBOX_FIREWALL_MOD }

  TFRE_FIRMBOX_FIREWALL_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure    ; override;
  public
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects           (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_ContentPools           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentRules           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentNAT             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_FIREWALL_MOD);
end;

{ TFRE_FIRMBOX_FIREWALL_MOD }

procedure TFRE_FIRMBOX_FIREWALL_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('firewall_description')
end;

class procedure TFRE_FIRMBOX_FIREWALL_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

class procedure TFRE_FIRMBOX_FIREWALL_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'firewall_description','Firewall','Firewall','Firewall');

    CreateModuleText(conn,'pools_tab','Pools');
    CreateModuleText(conn,'rules_tab','Rules');
    CreateModuleText(conn,'nat_tab','NAT');
  end;
end;

procedure TFRE_FIRMBOX_FIREWALL_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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
      AddOneToOnescheme('number','','NUMBER');
      AddFulltextFilterOnTransformed(['number']);
    end;

    dc := session.NewDerivedCollection('FIREWALL_RULES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FIREWALL_RULE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,nil);
      SetDefaultOrderField('number',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('number','','NUMBER');
      AddFulltextFilterOnTransformed(['number']);
    end;

    dc := session.NewDerivedCollection('FIREWALL_NAT_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FIREWALL_NAT_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,nil);
      SetDefaultOrderField('number',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('number','','NUMBER');
      AddFulltextFilterOnTransformed(['number']);
    end;

    dc := session.NewDerivedCollection('FIREWALL_POOLS_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FIREWALL_POOL_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,nil);
      SetDefaultOrderField('number',true);
    end;

  end;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  res.AddSection.Describe(CWSF(@WEB_ContentRules),FetchModuleTextShort(ses,'rules_tab'),1);
  res.AddSection.Describe(CWSF(@WEB_ContentNAT),FetchModuleTextShort(ses,'nat_tab'),2);
  res.AddSection.Describe(CWSF(@WEB_ContentPools),FetchModuleTextShort(ses,'pools_tab'),3);
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ContentPools(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  Result:=ses.FetchDerivedCollection('FIREWALL_POOLS_GRID').GetDisplayDescription;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ContentRules(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  Result:=ses.FetchDerivedCollection('FIREWALL_RULES_GRID').GetDisplayDescription;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ContentNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  Result:=ses.FetchDerivedCollection('FIREWALL_NAT_GRID').GetDisplayDescription;
end;


end.

