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
  private
    function        _AddModifyPool             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
    function        _getPoolName               (const dbo:IFRE_DB_Object):String;
    function        _AddModifyRule             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
    function        _getRuleName               (const dbo:IFRE_DB_Object):String;
    function        _AddModifyNAT              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
    function        _getNATName                (const dbo:IFRE_DB_Object):String;
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

    function        WEB_AddPool                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyPool             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StorePool              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeletePool             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeletePoolConfirmed    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolsSC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolsMenu              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddRule                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyRule             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreRule              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteRule             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteRuleConfirmed    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RulesSC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RulesMenu              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddNAT                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyNAT              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreNAT               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteNAT              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteNATConfirmed     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NATSC                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NATMenu                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_FIREWALL_MOD);
end;

{ TFRE_FIRMBOX_FIREWALL_MOD }

function TFRE_FIRMBOX_FIREWALL_MOD._AddModifyPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  scheme    : IFRE_DB_SchemeObject;
  res       : TFRE_DB_FORM_DIALOG_DESC;
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  diagCap   : TFRE_DB_String;
  dbo       : IFRE_DB_Object;
  poolDBO   : IFRE_DB_Object;
begin
  sf:=CWSF(@WEB_StorePool);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_POOL,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('poolId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'pool_modify_diag_cap');
  end else begin
    //CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('dependency.uid_ref.filtervalues').AsStringItem[0]),dbo));

    //if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_POOL,dbo.DomainID) then
    //  raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_POOL) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    //sf.AddParam.Describe('firewallId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'pool_create_diag_cap');
  end;
  GetSystemScheme(TFRE_DB_FIREWALL_POOL,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),poolDBO));
    res.FillWithObjectValues(poolDBO,ses);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD._getPoolName(const dbo: IFRE_DB_Object): String;
begin
  Result:=dbo.Field('number').AsString;
end;

function TFRE_FIRMBOX_FIREWALL_MOD._AddModifyRule(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  scheme    : IFRE_DB_SchemeObject;
  res       : TFRE_DB_FORM_DIALOG_DESC;
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  diagCap   : TFRE_DB_String;
  dbo       : IFRE_DB_Object;
  ruleDBO   : IFRE_DB_Object;
begin
  sf:=CWSF(@WEB_StoreRule);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_RULE,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('ruleId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'rule_modify_diag_cap');
  end else begin
    //CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('dependency.uid_ref.filtervalues').AsStringItem[0]),dbo));

    //if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_RULE,dbo.DomainID) then
    //  raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_RULE) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    //sf.AddParam.Describe('firewallId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'rule_create_diag_cap');
  end;
  GetSystemScheme(TFRE_DB_FIREWALL_RULE,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),ruleDBO));
    res.FillWithObjectValues(ruleDBO,ses);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD._getRuleName(const dbo: IFRE_DB_Object): String;
begin
  Result:=dbo.Field('number').AsString;
end;

function TFRE_FIRMBOX_FIREWALL_MOD._AddModifyNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  scheme    : IFRE_DB_SchemeObject;
  res       : TFRE_DB_FORM_DIALOG_DESC;
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  diagCap   : TFRE_DB_String;
  dbo       : IFRE_DB_Object;
  natDBO    : IFRE_DB_Object;
begin
  sf:=CWSF(@WEB_StoreNAT);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_NAT,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('natId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'nat_modify_diag_cap');
  end else begin
    //CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('dependency.uid_ref.filtervalues').AsStringItem[0]),dbo));

    //if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_NAT,dbo.DomainID) then
    //  raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_NAT) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    //sf.AddParam.Describe('firewallId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'nat_create_diag_cap');
  end;
  GetSystemScheme(TFRE_DB_FIREWALL_NAT,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),natDBO));
    res.FillWithObjectValues(natDBO,ses);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD._getNATName(const dbo: IFRE_DB_Object): String;
begin
  Result:=dbo.Field('number').AsString;
end;

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

    CreateModuleText(conn,'pool_create_diag_cap','Add Firewall Pool');
    CreateModuleText(conn,'pool_modify_diag_cap','Modify Firewall Pool');
    CreateModuleText(conn,'pool_delete_diag_cap','Delete Firewall Pool');
    CreateModuleText(conn,'pool_delete_diag_msg','Delete Firewall Pool %pool_str% and all its entries?');

    CreateModuleText(conn,'pool_delete_error_used_diag_cap','Delete Firewall Pool');
    CreateModuleText(conn,'pool_delete_error_used_diag_msg','Firewall Pool cannot be deleted because it is used in at least on Firewall Rule.');

    CreateModuleText(conn,'tb_create_pool','Add');
    CreateModuleText(conn,'tb_modify_pool','Modify');
    CreateModuleText(conn,'tb_delete_pool','Delete');
    CreateModuleText(conn,'cm_modify_pool','Modify');
    CreateModuleText(conn,'cm_delete_pool','Delete');

    CreateModuleText(conn,'rule_create_diag_cap','Add Firewall Rule');
    CreateModuleText(conn,'rule_modify_diag_cap','Modify Firewall Rule');
    CreateModuleText(conn,'rule_delete_diag_cap','Delete Firewall Rule');
    CreateModuleText(conn,'rule_delete_diag_msg','Delete Firewall Rule %rule_str%?');

    CreateModuleText(conn,'tb_create_rule','Add');
    CreateModuleText(conn,'tb_modify_rule','Modify');
    CreateModuleText(conn,'tb_delete_rule','Delete');
    CreateModuleText(conn,'cm_modify_rule','Modify');
    CreateModuleText(conn,'cm_delete_rule','Delete');

    CreateModuleText(conn,'nat_create_diag_cap','Add Firewall NAT');
    CreateModuleText(conn,'nat_modify_diag_cap','Modify Firewall NAT');
    CreateModuleText(conn,'nat_delete_diag_cap','Delete Firewall NAT');
    CreateModuleText(conn,'nat_delete_diag_msg','Delete Firewall NAT %nat_str%?');

    CreateModuleText(conn,'tb_create_nat','Add');
    CreateModuleText(conn,'tb_modify_nat','Modify');
    CreateModuleText(conn,'tb_delete_nat','Delete');
    CreateModuleText(conn,'cm_modify_nat','Modify');
    CreateModuleText(conn,'cm_delete_nat','Delete');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
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
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_RulesMenu),nil,CWSF(@WEB_RulesSC));
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
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_NATMenu),nil,CWSF(@WEB_NATSC));
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
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_PoolsMenu),nil,CWSF(@WEB_PoolsSC));
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
var
  res: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('FIREWALL_POOLS_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_POOL) then begin
    res.AddButton.Describe(CWSF(@WEB_AddPool),'',FetchModuleTextShort(ses,'tb_create_pool'),FetchModuleTextHint(ses,'tb_create_pool'));
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_FIREWALL_POOL) then begin
    res.AddButton.DescribeManualType('modify_pool',CWSF(@WEB_ModifyPool),'',FetchModuleTextShort(ses,'tb_modify_pool'),FetchModuleTextHint(ses,'tb_modify_pool'),true);
  end;
  if (conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_FIREWALL_POOL) and
      conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_GROUP) and
      conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_TABLE)) then begin
    res.AddButton.DescribeManualType('delete_pool',CWSF(@WEB_DeletePool),'',FetchModuleTextShort(ses,'tb_delete_pool'),FetchModuleTextHint(ses,'tb_delete_pool'),true);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ContentRules(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('FIREWALL_RULES_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_RULE) then begin
    res.AddButton.Describe(CWSF(@WEB_AddRule),'',FetchModuleTextShort(ses,'tb_create_rule'),FetchModuleTextHint(ses,'tb_create_rule'));
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_FIREWALL_RULE) then begin
    res.AddButton.DescribeManualType('modify_rule',CWSF(@WEB_ModifyRule),'',FetchModuleTextShort(ses,'tb_modify_rule'),FetchModuleTextHint(ses,'tb_modify_rule'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_FIREWALL_RULE) then begin
    res.AddButton.DescribeManualType('delete_rule',CWSF(@WEB_DeleteRule),'',FetchModuleTextShort(ses,'tb_delete_rule'),FetchModuleTextHint(ses,'tb_delete_rule'),true);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ContentNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('FIREWALL_NAT_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_NAT) then begin
    res.AddButton.Describe(CWSF(@WEB_AddNAT),'',FetchModuleTextShort(ses,'tb_create_nat'),FetchModuleTextHint(ses,'tb_create_nat'));
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_FIREWALL_NAT) then begin
    res.AddButton.DescribeManualType('modify_nat',CWSF(@WEB_ModifyNAT),'',FetchModuleTextShort(ses,'tb_modify_nat'),FetchModuleTextHint(ses,'tb_modify_nat'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_FIREWALL_NAT) then begin
    res.AddButton.DescribeManualType('delete_nat',CWSF(@WEB_DeleteNAT),'',FetchModuleTextShort(ses,'tb_delete_nat'),FetchModuleTextHint(ses,'tb_delete_nat'),true);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_AddPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyPool(input,ses,app,conn,false);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ModifyPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyPool(input,ses,app,conn,true);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_StorePool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_DeletePool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg   : String;
  pool      : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),pool));

  if not (conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOL,pool.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_GROUP,pool.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_TABLE,pool.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if (conn.GetReferencesCount(pool.UID,false,'','pool_in') + conn.GetReferencesCount(pool.UID,false,'','pool_out'))>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'pool_delete_error_used_diag_cap'),FetchModuleTextShort(ses,'pool_delete_error_used_diag_msg'),fdbmt_error);
    exit;
  end;

  sf:=CWSF(@WEB_DeletePoolConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'pool_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'pool_delete_diag_msg'),'%pool_str%',_getPoolName(pool),[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_DeletePoolConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i,j  : NativeInt;
  pool : IFRE_DB_Object;
  refs : TFRE_DB_GUIDArray;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),pool));

      if not (conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOL,pool.DomainID) and
              conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_GROUP,pool.DomainID) and
              conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_TABLE,pool.DomainID)) then
          raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      refs:=conn.GetReferences(pool.UID,False,'','firewallpool_id');
      for j := 0 to High(refs) do begin
        CheckDbResult(conn.Delete(refs[j]));
      end;

      CheckDbResult(conn.Delete(pool.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_PoolsSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  modify_disabled : Boolean;
  del_disabled    : Boolean;
  pool            : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  modify_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),pool));
    if pool.Implementor_HC is TFRE_DB_FIREWALL_POOL then begin
      //ses.GetSessionModuleData(ClassName).Field('selectedPool').AsStringArr:=input.Field('selected').AsStringArr;
      if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_POOL,pool.DomainID) then begin
        modify_disabled:=false;
      end;
      if (conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOL,pool.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_GROUP,pool.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_TABLE,pool.DomainID)) then begin
        del_disabled:=false;
      end;
    end else begin
      //ses.GetSessionModuleData(ClassName).DeleteField('selectedPool');
    end;
  end else begin
    //ses.GetSessionModuleData(ClassName).DeleteField('selectedPool');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('modify_pool',modify_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_pool',del_disabled));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_PoolsMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_MENU_DESC;
  func  : TFRE_DB_SERVER_FUNC_DESC;
  pool  : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),pool));

  if pool.Implementor_HC is TFRE_DB_FIREWALL_POOL then begin
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_POOL,pool.DomainID) then begin
      func:=CWSF(@WEB_ModifyPool);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_pool'),'',func);
    end;
    if (conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOL,pool.DomainID) and
        conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_GROUP,pool.DomainID) and
        conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_POOLENTRY_TABLE,pool.DomainID)) then begin
      func:=CWSF(@WEB_DeletePool);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_pool'),'',func);
    end;
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_AddRule(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyRule(input,ses,app,conn,false);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ModifyRule(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyRule(input,ses,app,conn,true);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_StoreRule(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_DeleteRule(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg   : String;
  rule      : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),rule));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_RULE,rule.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_DeleteRuleConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'rule_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'rule_delete_diag_msg'),'%rule_str%',_getRuleName(rule),[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_DeleteRuleConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i    : NativeInt;
  rule : IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),rule));

      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_RULE,rule.DomainID) then
          raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(rule.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_RulesSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  modify_disabled : Boolean;
  del_disabled    : Boolean;
  rule            : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  modify_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),rule));
    //ses.GetSessionModuleData(ClassName).Field('selectedRule').AsStringArr:=input.Field('selected').AsStringArr;
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_RULE,rule.DomainID) then begin
      modify_disabled:=false;
    end;
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_RULE,rule.DomainID) then begin
      del_disabled:=false;
    end;
  end else begin
    //ses.GetSessionModuleData(ClassName).DeleteField('selectedRule');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('modify_rule',modify_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_rule',del_disabled));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_RulesMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_MENU_DESC;
  func  : TFRE_DB_SERVER_FUNC_DESC;
  rule  : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),rule));

  if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_RULE,rule.DomainID) then begin
    func:=CWSF(@WEB_ModifyRule);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_rule'),'',func);
  end;
  if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_RULE,rule.DomainID) then begin
    func:=CWSF(@WEB_DeleteRule);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_rule'),'',func);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_AddNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyNAT(input,ses,app,conn,false);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ModifyNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyNAT(input,ses,app,conn,true);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_StoreNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_DeleteNAT(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg   : String;
  nat       : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),nat));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_NAT,nat.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_DeleteNATConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'nat_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'nat_delete_diag_msg'),'%nat_str%',_getRuleName(nat),[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_DeleteNATConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i    : NativeInt;
  nat  : IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),nat));

      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_NAT,nat.DomainID) then
          raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(nat.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_NATSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  modify_disabled : Boolean;
  del_disabled    : Boolean;
  nat             : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  modify_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),nat));
    //ses.GetSessionModuleData(ClassName).Field('selectedNAT').AsStringArr:=input.Field('selected').AsStringArr;
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_NAT,nat.DomainID) then begin
      modify_disabled:=false;
    end;
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_NAT,nat.DomainID) then begin
      del_disabled:=false;
    end;
  end else begin
    //ses.GetSessionModuleData(ClassName).DeleteField('selectedNAT');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('modify_nat',modify_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_nat',del_disabled));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_NATMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_MENU_DESC;
  func  : TFRE_DB_SERVER_FUNC_DESC;
  nat   : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),nat));

  if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_NAT,nat.DomainID) then begin
    func:=CWSF(@WEB_ModifyNAT);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_nat'),'',func);
  end;
  if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_FIREWALL_NAT,nat.DomainID) then begin
    func:=CWSF(@WEB_DeleteNAT);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_nat'),'',func);
  end;
  Result:=res;
end;


end.

