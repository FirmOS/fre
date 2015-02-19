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
    function        canAddFirewall             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_ContentPools           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentRules           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentNAT             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddFirewall            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateFirewall         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ServiceSC              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

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
  service   : IFRE_DB_Object;
begin
  sf:=CWSF(@WEB_StorePool);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_POOL,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('poolId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'pool_modify_diag_cap');
  end else begin
    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID,service));

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_POOL,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('firewallId',service.UID_String);
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
  service   : IFRE_DB_Object;
begin
  sf:=CWSF(@WEB_StoreRule);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_RULE,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('ruleId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'rule_modify_diag_cap');
  end else begin
    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID,service));

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_RULE,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('firewallId',service.UID_String);
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
  service   : IFRE_DB_Object;
  dc        : IFRE_DB_DERIVED_COLLECTION;
  group     : TFRE_DB_INPUT_GROUP_DESC;
  block     : TFRE_DB_INPUT_BLOCK_DESC;
begin
  sf:=CWSF(@WEB_StoreNAT);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_NAT,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('natId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'nat_modify_diag_cap');
  end else begin
    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID,service));

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_NAT,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('firewallId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'nat_create_diag_cap');
  end;
  GetSystemScheme(TFRE_DB_FIREWALL_NAT,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'nat_diag_src_block'));
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('src'),ses);

  dc := ses.FetchDerivedCollection(CFRE_DB_FIREWALL_INTERFACE_CHOOSER_DC);
  dc.Filters.RemoveFilter('zone');
  dc.Filters.AddUIDFieldFilter('zone','zuid',service.Field('serviceParent').AsObjectLink,dbnf_OneValueFromFilter);
  dc := ses.FetchDerivedCollection(CFRE_DB_FIREWALL_IP_CHOOSER_DC);
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);

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

    CreateModuleText(conn,'tb_create_firewall','Add');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');

    CreateModuleText(conn,'firewall_new_caption','New Firewall');
    CreateModuleText(conn,'zone_chooser_label','Zone');
    CreateModuleText(conn,'zone_chooser_value','%zone_str% (%customer_str%)');
    CreateModuleText(conn,'zone_chooser_value_no_customer','%zone_str%');

    CreateModuleText(conn,'service_grid_objname','Name');
    CreateModuleText(conn,'service_grid_zone','Zone');

    CreateModuleText(conn,'nat_diag_src_block','Source');
  end;
end;

procedure TFRE_FIRMBOX_FIREWALL_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app         : TFRE_DB_APPLICATION;
  conn        : IFRE_DB_CONNECTION;
  transform   : IFRE_DB_SIMPLE_TRANSFORM;
  dc          : IFRE_DB_DERIVED_COLLECTION;
  servicesGrid: IFRE_DB_DERIVED_COLLECTION;

  procedure _setCaption(const input,transformed_object : IFRE_DB_Object;const langres: TFRE_DB_StringArray);
  var
    str: String;
  begin
    if transformed_object.Field('customer').AsString<>'' then begin
      str:=StringReplace(langres[0],'%zone_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
      str:=StringReplace(str,'%customer_str%',transformed_object.Field('customer').AsString,[rfReplaceAll]);
    end else begin
      str:=StringReplace(langres[1],'%zone_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
    end;
    transformed_object.Field('label').AsString:=str;
  end;

begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;
    fre_hal_schemes.InitDerivedCollections(session,conn);

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'service_grid_objname'));
      AddMatchingReferencedFieldArray(['SERVICEPARENT>TFRE_DB_ZONE'],'objname','zone',FetchModuleTextShort(session,'service_grid_zone'));
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_description,false,false,1,'','',nil,false,'domainid');
    end;

    servicesGrid := session.NewDerivedCollection('FIREWALL_SERVICES_GRID');
    with servicesGrid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',nil,nil,CWSF(@WEB_ServiceSC));
      Filters.AddSchemeObjectFilter('service',[TFRE_DB_FIREWALL_SERVICE.ClassName]);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('label');
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_string,true,true,1,'','',nil,false,'domainid');
      AddMatchingReferencedField(['TEMPLATEID>TFRE_DB_FBZ_TEMPLATE'],'serviceclasses');
      AddMatchingReferencedField(['TFRE_DB_FIREWALL_SERVICE<SERVICEPARENT'],'uid','firewall','',false,dt_string,false,false,1,'','OK');
      AddOneToOnescheme('disabledSCs');
      SetSimpleFuncTransformNested(@_setCaption,[FetchModuleTextShort(session,'zone_chooser_value'),FetchModuleTextShort(session,'zone_chooser_value_no_customer')]);
    end;

    dc := session.NewDerivedCollection('FIREWALL_ZONE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','domainid','','',TFRE_DB_FIREWALL_SERVICE.ClassName,[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
      Filters.AddStringFieldFilter('serviceclasses','serviceclasses',TFRE_DB_FIREWALL_SERVICE.ClassName,dbft_EXACTVALUEINARRAY);
      Filters.AddStringFieldFilter('disabledSCs','disabledSCs',TFRE_DB_FIREWALL_SERVICE.ClassName,dbft_EXACTVALUEINARRAY,false,true);
      Filters.AddStringFieldFilter('used','firewall','OK',dbft_EXACT);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('number','','NUMBER');
      AddMatchingReferencedFieldArray(['FIREWALL_ID>TFRE_DB_FIREWALL_SERVICE'],'uid','fw_uid','',false);
      AddFulltextFilterOnTransformed(['number']);
    end;

    dc := session.NewDerivedCollection('FIREWALL_RULES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FIREWALL_RULE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_RulesMenu),nil,CWSF(@WEB_RulesSC));
      SetUseDependencyAsUidFilter('fw_uid');
      servicesGrid.AddSelectionDependencyEvent(CollectionName);
      SetDefaultOrderField('number',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('number','','NUMBER');
      AddMatchingReferencedFieldArray(['FIREWALL_ID>TFRE_DB_FIREWALL_SERVICE'],'uid','fw_uid','',false);
      AddFulltextFilterOnTransformed(['number']);
    end;

    dc := session.NewDerivedCollection('FIREWALL_NAT_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FIREWALL_NAT_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_NATMenu),nil,CWSF(@WEB_NATSC));
      SetUseDependencyAsUidFilter('fw_uid');
      servicesGrid.AddSelectionDependencyEvent(CollectionName);
      SetDefaultOrderField('number',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('number','','NUMBER');
      AddMatchingReferencedFieldArray(['FIREWALL_ID>TFRE_DB_FIREWALL_SERVICE'],'uid','fw_uid','',false);
      AddFulltextFilterOnTransformed(['number']);
    end;

    dc := session.NewDerivedCollection('FIREWALL_POOLS_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FIREWALL_POOL_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_PoolsMenu),nil,CWSF(@WEB_PoolsSC));
      SetUseDependencyAsUidFilter('fw_uid');
      servicesGrid.AddSelectionDependencyEvent(CollectionName);
      SetDefaultOrderField('number',true);
    end;
  end;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.canAddFirewall(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_SERVICE,zone.DomainID);
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  subs        : TFRE_DB_SUBSECTIONS_DESC;
  layout      : TFRE_DB_LAYOUT_DESC;
  servicesDC  : IFRE_DB_DERIVED_COLLECTION;
  servicesGrid: TFRE_DB_VIEW_LIST_DESC;
  service     : IFRE_DB_Object;
  frg         : IFRE_DB_DERIVED_COLLECTION;
  fng         : IFRE_DB_DERIVED_COLLECTION;
  fpg         : IFRE_DB_DERIVED_COLLECTION;
begin
  CheckClassVisibility4AnyDomain(ses);

  frg:=ses.FetchDerivedCollection('FIREWALL_RULES_GRID');
  frg.Filters.RemoveFilter('service');
  fng:=ses.FetchDerivedCollection('FIREWALL_NAT_GRID');
  fng.Filters.RemoveFilter('service');
  fpg:=ses.FetchDerivedCollection('FIREWALL_POOLS_GRID');
  fpg.Filters.RemoveFilter('service');
  ses.GetSessionModuleData(ClassName).DeleteField('selectedFirewall');

  subs:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  subs.AddSection.Describe(CWSF(@WEB_ContentRules),FetchModuleTextShort(ses,'rules_tab'),1);
  subs.AddSection.Describe(CWSF(@WEB_ContentNAT),FetchModuleTextShort(ses,'nat_tab'),2);
  subs.AddSection.Describe(CWSF(@WEB_ContentPools),FetchModuleTextShort(ses,'pools_tab'),3);
  servicesDC:=ses.FetchDerivedCollection('FIREWALL_SERVICES_GRID');
  if (Length(conn.sys.GetDomainsForClassRight(sr_FETCH,TFRE_DB_FIREWALL_SERVICE))>1) or //multidomain
     conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_SERVICE) or           //can add service
     (servicesDC.ItemCount>1) then begin                                                //has more than one service
    layout:=TFRE_DB_LAYOUT_DESC.create.Describe();
    servicesGrid:=servicesDC.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
    if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_SERVICE) then begin
      servicesGrid.AddButton.Describe(CWSF(@WEB_AddFirewall),'',FetchModuleTextShort(ses,'tb_create_firewall'));
    end;
    layout.SetLayout(servicesGrid,subs);
    Result:=layout;
  end else begin
    if servicesDC.ItemCount=1 then begin //set service filters
      service:=servicesDC.First;
      ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID:=service.UID;
      frg.Filters.AddUIDFieldFilter('service','fw_uid',[service.UID],dbnf_OneValueFromFilter);
      fng.Filters.AddUIDFieldFilter('service','fw_uid',[service.UID],dbnf_OneValueFromFilter);
      fpg.Filters.AddUIDFieldFilter('service','fw_uid',[service.UID],dbnf_OneValueFromFilter);
    end else begin
      frg.Filters.AddUIDFieldFilter('service','fw_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
      fng.Filters.AddUIDFieldFilter('service','fw_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
      fpg.Filters.AddUIDFieldFilter('service','fw_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
    end;
    Result:=subs;
  end;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ContentPools(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res        : TFRE_DB_VIEW_LIST_DESC;
  addDisabled: Boolean;
  service    : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('FIREWALL_POOLS_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_POOL) then begin
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedFirewall') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID,service));
      addDisabled:=not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_POOL,service.DomainID);
    end else begin
      addDisabled:=true;
    end;
    res.AddButton.DescribeManualType('add_pool',CWSF(@WEB_AddPool),'',FetchModuleTextShort(ses,'tb_create_pool'),FetchModuleTextHint(ses,'tb_create_pool'),addDisabled);
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
  res        : TFRE_DB_VIEW_LIST_DESC;
  addDisabled: Boolean;
  service    : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('FIREWALL_RULES_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_RULE) then begin
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedFirewall') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID,service));
      addDisabled:=not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_RULE,service.DomainID);
    end else begin
      addDisabled:=true;
    end;
    res.AddButton.DescribeManualType('add_rule',CWSF(@WEB_AddRule),'',FetchModuleTextShort(ses,'tb_create_rule'),FetchModuleTextHint(ses,'tb_create_rule'),addDisabled);
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
  res        : TFRE_DB_VIEW_LIST_DESC;
  addDisabled: Boolean;
  service    : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('FIREWALL_NAT_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_FIREWALL_NAT) then begin
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedFirewall') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID,service));
      addDisabled:=not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_NAT,service.DomainID);
    end else begin
      addDisabled:=true;
    end;
    res.AddButton.DescribeManualType('add_nat',CWSF(@WEB_AddNAT),'',FetchModuleTextShort(ses,'tb_create_nat'),FetchModuleTextHint(ses,'tb_create_nat'),addDisabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_FIREWALL_NAT) then begin
    res.AddButton.DescribeManualType('modify_nat',CWSF(@WEB_ModifyNAT),'',FetchModuleTextShort(ses,'tb_modify_nat'),FetchModuleTextHint(ses,'tb_modify_nat'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_FIREWALL_NAT) then begin
    res.AddButton.DescribeManualType('delete_nat',CWSF(@WEB_DeleteNAT),'',FetchModuleTextShort(ses,'tb_delete_nat'),FetchModuleTextHint(ses,'tb_delete_nat'),true);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_AddFirewall(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_FORM_DIALOG_DESC;
  sf    : TFRE_DB_SERVER_FUNC_DESC;
  zoneId: TFRE_DB_String;
  zone  : TFRE_DB_ZONE;
  scheme: IFRE_DB_SchemeObject;
begin
  CheckClassVisibility4MyDomain(ses);

  GetSystemScheme(TFRE_DB_FIREWALL_SERVICE,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'firewall_new_caption'),600,true,true,false);

  sf:=CWSF(@WEB_CreateFirewall);

  if input.FieldPathExists('data.zone') then begin
    zoneId:=input.FieldPath('data.zone').AsString;
  end else begin
    if input.FieldExists('zoneId') then begin
      zoneId:=input.Field('zoneId').AsString;
      sf.AddParam.Describe('zoneId',zoneId);

      CheckDbResult(conn.FetchAs(FREDB_H2G(zoneId),TFRE_DB_ZONE,zone));
      if not canAddFirewall(input,ses,app,conn,zone) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    end else begin
      res.AddChooser.Describe(FetchModuleTextShort(ses,'zone_chooser_label'),'zone',ses.FetchDerivedCollection('FIREWALL_ZONE_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true);
    end;
  end;
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'',true,true);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_CreateFirewall(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zoneId  : TFRE_DB_String;
  zone    : TFRE_DB_ZONE;
  scheme  : IFRE_DB_SchemeObject;
  firewall: TFRE_DB_FIREWALL_SERVICE;
begin
  if input.FieldPathExists('data.zone') then begin
    zoneId:=input.FieldPath('data.zone').AsString;
    input.Field('data').AsObject.DeleteField('zone');
  end else begin
    if input.FieldExists('zoneId') then begin
      zoneId:=input.Field('zoneId').AsString;
    end else begin
      raise EFRE_DB_Exception.Create('Missing parameter: data.zone or zoneId');
    end;
  end;

  CheckDbResult(conn.FetchAs(FREDB_H2G(zoneId),TFRE_DB_ZONE,zone));
  if not canAddFirewall(input,ses,app,conn,zone) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_FIREWALL_SERVICE,scheme);
  firewall:=TFRE_DB_FIREWALL_SERVICE.CreateForDB;
  firewall.SetDomainID(zone.DomainID);
  firewall.Field('serviceParent').AsObjectLink:=zone.UID;
  firewall.Field('uniquephysicalid').AsString:=TFRE_DB_FIREWALL_SERVICE.ClassName + '@' + zone.UID_String;
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,firewall,true,conn);

  CheckDbResult(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION).Store(firewall));
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_FIREWALL_MOD.WEB_ServiceSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  addPoolDisabled: Boolean;
  addRuleDisabled: Boolean;
  addNATDisabled : Boolean;
  service        : IFRE_DB_Object;
begin
  addPoolDisabled:=true;
  addRuleDisabled:=true;
  addNATDisabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),service));
    ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID:=service.UID;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_RULE,service.DomainID) then begin
      addRuleDisabled:=false;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_NAT,service.DomainID) then begin
      addNATDisabled:=false;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_POOL,service.DomainID) then begin
      addPoolDisabled:=false;
    end;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedFirewall');
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.Create.DescribeStatus('add_pool',addPoolDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.Create.DescribeStatus('add_rule',addRuleDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.Create.DescribeStatus('add_nat',addNATDisabled));
  Result:=GFRE_DB_NIL_DESC;
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
var
  scheme   : IFRE_DB_SchemeObject;
  poolObj  : TFRE_DB_FIREWALL_POOL;
  isNew    : Boolean;
  service  : IFRE_DB_Object;
begin
  GetSystemScheme(TFRE_DB_FIREWALL_POOL,scheme);

  if input.FieldExists('poolId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('poolId').AsString),TFRE_DB_FIREWALL_POOL,poolObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_POOL,poolObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('firewallId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_POOL,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    poolObj:=TFRE_DB_FIREWALL_POOL.CreateForDB;
    poolObj.SetDomainID(service.DomainID);
    poolObj.Field('firewall_id').AsObjectLink:=service.UID;
    isNew:=true;
  end;

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,poolObj,isNew,conn);

  if isNew then begin
    CheckDbResult(conn.GetCollection(CFRE_DB_FIREWALL_POOL_COLLECTION).Store(poolObj));
  end else begin
    CheckDbResult(conn.Update(poolObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
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
var
  scheme   : IFRE_DB_SchemeObject;
  ruleObj  : TFRE_DB_FIREWALL_RULE;
  isNew    : Boolean;
  service  : IFRE_DB_Object;
begin
  GetSystemScheme(TFRE_DB_FIREWALL_RULE,scheme);

  if input.FieldExists('ruleId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('ruleId').AsString),TFRE_DB_FIREWALL_RULE,ruleObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_RULE,ruleObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('firewallId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_RULE,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    ruleObj:=TFRE_DB_FIREWALL_RULE.CreateForDB;
    ruleObj.SetDomainID(service.DomainID);
    ruleObj.Field('firewall_id').AsObjectLink:=service.UID;
    isNew:=true;
  end;

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,ruleObj,isNew,conn);

  if isNew then begin
    CheckDbResult(conn.GetCollection(CFRE_DB_FIREWALL_RULE_COLLECTION).Store(ruleObj));
  end else begin
    CheckDbResult(conn.Update(ruleObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
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
var
  scheme   : IFRE_DB_SchemeObject;
  natObj   : TFRE_DB_FIREWALL_NAT;
  isNew    : Boolean;
  service  : IFRE_DB_Object;
begin
  GetSystemScheme(TFRE_DB_FIREWALL_NAT,scheme);

  if input.FieldExists('natId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('natId').AsString),TFRE_DB_FIREWALL_NAT,natObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_FIREWALL_NAT,natObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('firewallId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_FIREWALL_NAT,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    natObj:=TFRE_DB_FIREWALL_NAT.CreateForDB;
    natObj.SetDomainID(service.DomainID);
    natObj.Field('firewall_id').AsObjectLink:=service.UID;
    isNew:=true;
  end;

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,natObj,isNew,conn);

  if isNew then begin
    CheckDbResult(conn.GetCollection(CFRE_DB_FIREWALL_NAT_COLLECTION).Store(natObj));
  end else begin
    CheckDbResult(conn.Update(natObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
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

