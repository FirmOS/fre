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
  private
    function        _AddModifyTemplate          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
    function        _AddModifySubnetEntry       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const dbo:IFRE_DB_Object):IFRE_DB_Object;
    function        _AddModifyFixedEntry        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const dbo:IFRE_DB_Object):IFRE_DB_Object;
  protected
    procedure       SetupAppModuleStructure     ; override;
  public
    class procedure RegisterSystemScheme        (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule   (const session : TFRE_DB_UserSession);override;
    function        canAddDHCP                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
  published
    function        WEB_Content                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_ContentGeneral          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentTemplates        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentEntries          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddDHCP                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateDHCP              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreDHCP               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ServiceSC               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddTemplate             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyTemplate          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreTemplate           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteTemplate          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteTemplateConfirmed (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TemplateSC              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TemplateMenu            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddSubnetEntry          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddFixedEntry           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyEntry             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreSubnetEntry        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreFixedEntry         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteEntry             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteEntryConfirmed    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_EntrySC                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_EntryMenu               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFRE_FIRMBOX_DHCP_MOD._AddModifyTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  diagCap     : TFRE_DB_String;
  dbo         : IFRE_DB_Object;
  service     : IFRE_DB_Object;
begin
  sf:=CWSF(@WEB_StoreTemplate);

  CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_TEMPLATE,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('templateId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'template_modify_diag_cap');
  end else begin
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_TEMPLATE,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('dhcpId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'template_create_diag_cap');
  end;

  GetSystemScheme(TFRE_DB_DHCP_TEMPLATE,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    res.FillWithObjectValues(dbo,ses);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD._AddModifySubnetEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const dbo:IFRE_DB_Object): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  diagCap     : TFRE_DB_String;
  isModify    : Boolean;
  service     : IFRE_DB_Object;
  dc          : IFRE_DB_DERIVED_COLLECTION;
begin
  sf:=CWSF(@WEB_StoreSubnetEntry);

  CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
  if Assigned(dbo) then begin
    isModify:=true;
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_SUBNET,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('entryId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'subnet_entry_modify_diag_cap');
  end else begin
    isModify:=false;
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_SUBNET,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('dhcpId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'subnet_entry_create_diag_cap');
  end;

  dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_SUBNET_CHOOSER_DC);
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
  dc.Filters.RemoveFilter('scheme');
  dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4_SUBNET.ClassName]);

  GetSystemScheme(TFRE_DB_DHCP_SUBNET,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    res.FillWithObjectValues(dbo,ses);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD._AddModifyFixedEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const dbo:IFRE_DB_Object): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  diagCap     : TFRE_DB_String;
  isModify    : Boolean;
  service     : IFRE_DB_Object;
  dc          : IFRE_DB_DERIVED_COLLECTION;
begin
  sf:=CWSF(@WEB_StoreFixedEntry);

  CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
  if Assigned(dbo) then begin
    isModify:=true;
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_FIXED,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('entryId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'fixed_entry_modify_diag_cap');
  end else begin
    isModify:=false;
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_FIXED,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('dhcpId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'fixed_entry_create_diag_cap');
  end;

  dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_IP_CHOOSER_DC);
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
  dc.Filters.RemoveFilter('scheme');
  dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4.ClassName]);

  GetSystemScheme(TFRE_DB_DHCP_FIXED,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    res.FillWithObjectValues(dbo,ses);
  end;

  Result:=res;
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

    CreateModuleText(conn,'general_tab','General');
    CreateModuleText(conn,'hosts_tab','Ranges/Hosts');
    CreateModuleText(conn,'templates_tab','Templates');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
    CreateModuleText(conn,'dhcp_details_select_one','Please select a dhcp service to get detailed information');

    CreateModuleText(conn,'service_grid_objname','Name');
    CreateModuleText(conn,'service_grid_zone','Zone');

    CreateModuleText(conn,'tb_create_dhcp','Add');

    CreateModuleText(conn,'dhcp_new_caption','New DHCP Server');

    CreateModuleText(conn,'zone_chooser_label','Zone');
    CreateModuleText(conn,'zone_chooser_value','%zone_str% (%customer_str%)');
    CreateModuleText(conn,'zone_chooser_value_no_customer','%zone_str%');

    CreateModuleText(conn,'templates_grid_objname','Name');

    CreateModuleText(conn,'tb_create_template','Add');
    CreateModuleText(conn,'tb_modify_template','Modify');
    CreateModuleText(conn,'tb_delete_template','Delete');
    CreateModuleText(conn,'cm_modify_template','Modify');
    CreateModuleText(conn,'cm_delete_template','Delete');

    CreateModuleText(conn,'template_create_diag_cap','Add DHCP Template');
    CreateModuleText(conn,'template_modify_diag_cap','Modify DHCP Template');
    CreateModuleText(conn,'template_delete_diag_cap','Delete DHCP Template');
    CreateModuleText(conn,'template_delete_diag_msg','Delete DHCP Template %template_str%?');

    CreateModuleText(conn,'template_delete_error_used_diag_cap','Delete DHCP Template');
    CreateModuleText(conn,'template_delete_error_used_diag_msg','DHCP Template cannot be deleted because it is used by at least on DHCP entry.');

    CreateModuleText(conn,'entries_grid_objname','Name');

    CreateModuleText(conn,'tb_create_subnet_entry','Add Subnet');
    CreateModuleText(conn,'tb_create_fixed_entry','Add Fixed');
    CreateModuleText(conn,'tb_modify_entry','Modify');
    CreateModuleText(conn,'tb_delete_entry','Delete');
    CreateModuleText(conn,'cm_modify_entry','Modify');
    CreateModuleText(conn,'cm_delete_entry','Delete');

    CreateModuleText(conn,'subnet_entry_create_diag_cap','Add Subnet');
    CreateModuleText(conn,'fixed_entry_create_diag_cap','Add Fixed IP');
    CreateModuleText(conn,'subnet_entry_modify_diag_cap','Modify Subnet');
    CreateModuleText(conn,'fixed_entry_modify_diag_cap','Modify Fixed IP');
    CreateModuleText(conn,'subnet_entry_delete_diag_cap','Delete Subnet');
    CreateModuleText(conn,'fixed_entry_delete_diag_cap','Delete Fixed IP');
    CreateModuleText(conn,'subnet_entry_delete_diag_msg','Delete Subnet %entry_str%?');
    CreateModuleText(conn,'fixed_entry_delete_diag_msg','Delete Fixed IP %entry_str%?');
  end;
end;

procedure TFRE_FIRMBOX_DHCP_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app          : TFRE_DB_APPLICATION;
  conn         : IFRE_DB_CONNECTION;
  transform    : IFRE_DB_SIMPLE_TRANSFORM;
  dc           : IFRE_DB_DERIVED_COLLECTION;
  servicesGrid : IFRE_DB_DERIVED_COLLECTION;

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
      AddOneToOnescheme('objname');
      AddOneToOnescheme('label');
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_string,true,true,1,'','',nil,false,'domainid');
      AddMatchingReferencedField(['TEMPLATEID>TFRE_DB_FBZ_TEMPLATE'],'serviceclasses');
      AddMatchingReferencedField(['TFRE_DB_DHCP<SERVICEPARENT'],'uid','dhcp','',false,dt_string,false,false,1,'','OK');
      AddOneToOnescheme('disabledSCs');
      SetSimpleFuncTransformNested(@_setCaption,[FetchModuleTextShort(session,'zone_chooser_value'),FetchModuleTextShort(session,'zone_chooser_value_no_customer')]);
    end;

    dc := session.NewDerivedCollection('DHCP_ZONE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','domainid','','',TFRE_DB_DHCP.ClassName,[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
      Filters.AddStringFieldFilter('serviceclasses','serviceclasses',TFRE_DB_DHCP.ClassName,dbft_EXACTVALUEINARRAY);
      Filters.AddStringFieldFilter('disabledSCs','disabledSCs',TFRE_DB_DHCP.ClassName,dbft_EXACTVALUEINARRAY,false,true);
      Filters.AddStringFieldFilter('used','dhcp','OK',dbft_EXACT);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'service_grid_objname'));
      AddMatchingReferencedFieldArray(['SERVICEPARENT>TFRE_DB_ZONE'],'objname','zone',FetchModuleTextShort(session,'service_grid_zone'));
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_description,false,false,1,'','',nil,false,'domainid');
    end;

    servicesGrid := session.NewDerivedCollection('DHCP_SERVICES_GRID');
    with servicesGrid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,nil,CWSF(@WEB_ServiceSC));
      SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('service',[TFRE_DB_DHCP.ClassName]);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'templates_grid_objname'));
      AddMatchingReferencedFieldArray(['DHCP_ID>TFRE_DB_DHCP'],'uid','dhcp_uid','',false);
    end;

    dc := session.NewDerivedCollection('DHCP_TEMPLATES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DHCP_TEMPLATE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',CWSF(@WEB_TemplateMenu),nil,CWSF(@WEB_TemplateSC));
      SetUseDependencyAsUidFilter('dhcp_uid');
      servicesGrid.AddSelectionDependencyEvent(CollectionName);
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'entries_grid_objname'));
      AddMatchingReferencedFieldArray(['DHCP_ID>TFRE_DB_DHCP'],'uid','dhcp_uid','',false);
    end;

    dc := session.NewDerivedCollection('DHCP_ENTRIES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DHCP_ENTRY_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',CWSF(@WEB_EntryMenu),nil,CWSF(@WEB_EntrySC));
      SetUseDependencyAsUidFilter('dhcp_uid');
      servicesGrid.AddSelectionDependencyEvent(CollectionName);
      SetDefaultOrderField('objname',true);
    end;

  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.canAddDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP,zone.DomainID);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  subs        : TFRE_DB_SUBSECTIONS_DESC;
  dc          : IFRE_DB_DERIVED_COLLECTION;
  servicesDC  : IFRE_DB_DERIVED_COLLECTION;
  layout      : TFRE_DB_LAYOUT_DESC;
  servicesGrid: TFRE_DB_VIEW_LIST_DESC;
  service     : IFRE_DB_Object;
  tg          : IFRE_DB_DERIVED_COLLECTION;
begin
  CheckClassVisibility4AnyDomain(ses);

  tg:=ses.FetchDerivedCollection('DHCP_TEMPLATES_GRID');
  tg.Filters.RemoveFilter('service');
  ses.GetSessionModuleData(ClassName).DeleteField('selectedDHCP');

  subs:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  subs.AddSection.Describe(CWSF(@WEB_ContentGeneral),FetchModuleTextShort(ses,'general_tab'),1);
  subs.AddSection.Describe(CWSF(@WEB_ContentEntries),FetchModuleTextShort(ses,'hosts_tab'),2);
  subs.AddSection.Describe(CWSF(@WEB_ContentTemplates),FetchModuleTextShort(ses,'templates_tab'),3);
  servicesDC:=ses.FetchDerivedCollection('DHCP_SERVICES_GRID');
  if (Length(conn.sys.GetDomainsForClassRight(sr_FETCH,TFRE_DB_DHCP))>1) or //multidomain
     conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP) or           //can add service
     (servicesDC.ItemCount>1) then begin                                    //has more than one service
    layout:=TFRE_DB_LAYOUT_DESC.create.Describe();
    servicesGrid:=servicesDC.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
    if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP) then begin
      servicesGrid.AddButton.Describe(CWSF(@WEB_AddDHCP),'',FetchModuleTextShort(ses,'tb_create_dhcp'));
    end;
    layout.SetLayout(servicesGrid,subs);
    Result:=layout;
  end else begin
    if servicesDC.ItemCount=1 then begin //set service filters
      service:=servicesDC.First;
      ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID:=service.UID;
      tg.Filters.AddUIDFieldFilter('service','dhcp_uid',[service.UID],dbnf_OneValueFromFilter);
    end else begin
      tg.Filters.AddUIDFieldFilter('service','dhcp_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
    end;
    Result:=subs;
  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ContentGeneral(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_PANEL_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  service     : IFRE_DB_Object;
  editable    : Boolean;
  dc          : IFRE_DB_DERIVED_COLLECTION;
begin
  CheckClassVisibility4AnyDomain(ses);

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedDHCP') and (ses.GetSessionModuleData(ClassName).Field('selectedDHCP').ValueCount=1) then begin

    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));

    editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP,service.DomainID);

    GetSystemScheme(TFRE_DB_DHCP,scheme);
    res:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',false,editable);
    res.AddSchemeFormGroup(scheme.GetInputGroup('main_edit'),ses);
    res.FillWithObjectValues(service,ses);

    dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_IP_CHOOSER_DC);
    dc.Filters.RemoveFilter('domain');
    dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
    dc.Filters.RemoveFilter('scheme');
    dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4.ClassName]);

    if editable then begin
      sf:=CWSF(@WEB_StoreDHCP);
      sf.AddParam.Describe('serviceId',service.UID_String);
      res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
    end;
    Result:=res;
  end else begin
    Result:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'dhcp_details_select_one'));
  end;
  (Result.Implementor_HC as TFRE_DB_CONTENT_DESC).contentId:='DHCP_GENERAL';
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ContentTemplates(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res        : TFRE_DB_VIEW_LIST_DESC;
  addDisabled: Boolean;
  service    : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('DHCP_TEMPLATES_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP_TEMPLATE) then begin
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedDHCP') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
      addDisabled:=not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_TEMPLATE,service.DomainID);
    end else begin
      addDisabled:=true;
    end;
    res.AddButton.DescribeManualType('add_template',CWSF(@WEB_AddTemplate),'',FetchModuleTextShort(ses,'tb_create_template'),FetchModuleTextHint(ses,'tb_create_template'),addDisabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_DHCP_TEMPLATE) then begin
    res.AddButton.DescribeManualType('modify_template',CWSF(@WEB_ModifyTemplate),'',FetchModuleTextShort(ses,'tb_modify_template'),FetchModuleTextHint(ses,'tb_modify_template'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_DHCP_TEMPLATE) then begin
    res.AddButton.DescribeManualType('delete_template',CWSF(@WEB_DeleteTemplate),'',FetchModuleTextShort(ses,'tb_delete_template'),FetchModuleTextHint(ses,'tb_delete_template'),true);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ContentEntries(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res              : TFRE_DB_VIEW_LIST_DESC;
  addSubnetDisabled: Boolean;
  addFixedDisabled : Boolean;
  service          : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('DHCP_ENTRIES_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP_SUBNET) then begin
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedDHCP') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
      addSubnetDisabled:=not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_SUBNET,service.DomainID);
    end else begin
      addSubnetDisabled:=true;
    end;
    res.AddButton.DescribeManualType('add_subnet_entry',CWSF(@WEB_AddSubnetEntry),'',FetchModuleTextShort(ses,'tb_create_subnet_entry'),FetchModuleTextHint(ses,'tb_create_subnet_entry'),addSubnetDisabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP_FIXED) then begin
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedDHCP') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
      addFixedDisabled:=not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_FIXED,service.DomainID);
    end else begin
      addFixedDisabled:=true;
    end;
    res.AddButton.DescribeManualType('add_fixed_entry',CWSF(@WEB_AddFixedEntry),'',FetchModuleTextShort(ses,'tb_create_fixed_entry'),FetchModuleTextHint(ses,'tb_create_fixed_entry'),addFixedDisabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_DHCP_SUBNET) or conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_DHCP_FIXED) then begin
    res.AddButton.DescribeManualType('modify_entry',CWSF(@WEB_ModifyEntry),'',FetchModuleTextShort(ses,'tb_modify_entry'),FetchModuleTextHint(ses,'tb_modify_entry'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_DHCP_SUBNET) or conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_DHCP_FIXED) then begin
    res.AddButton.DescribeManualType('delete_entry',CWSF(@WEB_DeleteEntry),'',FetchModuleTextShort(ses,'tb_delete_entry'),FetchModuleTextHint(ses,'tb_delete_entry'),true);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_FORM_DIALOG_DESC;
  sf    : TFRE_DB_SERVER_FUNC_DESC;
  zoneId: TFRE_DB_String;
  zone  : TFRE_DB_ZONE;
  scheme: IFRE_DB_SchemeObject;
begin
  CheckClassVisibility4MyDomain(ses);

  GetSystemScheme(TFRE_DB_DHCP,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'dhcp_new_caption'),600,true,true,false);

  sf:=CWSF(@WEB_CreateDHCP);

  if input.FieldPathExists('data.zone') then begin
    zoneId:=input.FieldPath('data.zone').AsString;
  end else begin
    if input.FieldExists('zoneId') then begin
      zoneId:=input.Field('zoneId').AsString;
      sf.AddParam.Describe('zoneId',zoneId);

      CheckDbResult(conn.FetchAs(FREDB_H2G(zoneId),TFRE_DB_ZONE,zone));
      if not canAddDHCP(input,ses,app,conn,zone) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    end else begin
      res.AddChooser.Describe(FetchModuleTextShort(ses,'zone_chooser_label'),'zone',ses.FetchDerivedCollection('DHCP_ZONE_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true);
    end;
  end;

  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'',true,true);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_CreateDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zoneId  : TFRE_DB_String;
  zone    : TFRE_DB_ZONE;
  scheme  : IFRE_DB_SchemeObject;
  dhcp    : TFRE_DB_DHCP;
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
  if not canAddDHCP(input,ses,app,conn,zone) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_DHCP,scheme);
  dhcp:=TFRE_DB_DHCP.CreateForDB;
  dhcp.SetDomainID(zone.DomainID);
  dhcp.Field('serviceParent').AsObjectLink:=zone.UID;
  dhcp.Field('uniquephysicalid').AsString:=TFRE_DB_DHCP.ClassName + '@' + zone.UID_String;
  dhcp.Field('all_interfaces').AsBoolean:=true;
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,dhcp,true,conn);

  CheckDbResult(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION).Store(dhcp));
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  service     : TFRE_DB_DHCP;

begin
  GetSystemScheme(TFRE_DB_DHCP,scheme);

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('serviceId').AsString),TFRE_DB_DHCP,service));
  if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP,service.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,service,false,conn);
  CheckDbResult(conn.Update(service));

  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ServiceSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  addTemplateDisabled: Boolean;
  addSubnetDisabled  : Boolean;
  addFixedDisabled   : Boolean;
  service            : IFRE_DB_Object;
begin
  addTemplateDisabled:=true;
  addSubnetDisabled:=true;
  addFixedDisabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),service));
    ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID:=service.UID;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_TEMPLATE,service.DomainID) then begin
      addTemplateDisabled:=false;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_SUBNET,service.DomainID) then begin
      addSubnetDisabled:=false;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_FIXED,service.DomainID) then begin
      addFixedDisabled:=false;
    end;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedDHCP');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.Create.DescribeStatus('add_template',addTemplateDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.Create.DescribeStatus('add_subnet_entry',addSubnetDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.Create.DescribeStatus('add_fixed_entry',addFixedDisabled));

  if ses.isUpdatableContentVisible('DHCP_GENERAL') then begin
    Result:=WEB_ContentGeneral(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyTemplate(input,ses,app,conn,false);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ModifyTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyTemplate(input,ses,app,conn,true);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  templateObj : TFRE_DB_DHCP_TEMPLATE;
  isNew       : Boolean;
  service     : IFRE_DB_Object;

begin
  GetSystemScheme(TFRE_DB_DHCP_TEMPLATE,scheme);

  if input.FieldExists('templateId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('templateId').AsString),TFRE_DB_DHCP_TEMPLATE,templateObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_TEMPLATE,templateObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('dhcpId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_TEMPLATE,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    templateObj:=TFRE_DB_DHCP_TEMPLATE.CreateForDB;
    templateObj.SetDomainID(service.DomainID);
    templateObj.Field('dhcp_id').AsObjectLink:=service.UID;
    isNew:=true;
  end;

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,templateObj,isNew,conn);

  if isNew then begin
    CheckDbResult(conn.GetCollection(CFRE_DB_DHCP_TEMPLATE_COLLECTION).Store(templateObj));
  end else begin
    CheckDbResult(conn.Update(templateObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_DeleteTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg   : String;
  template  : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),template));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_TEMPLATE,template.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if conn.GetReferencesCount(template.UID,false,'','')>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'template_delete_error_used_diag_cap'),FetchModuleTextShort(ses,'template_delete_error_used_diag_msg'),fdbmt_error);
    exit;
  end;

  sf:=CWSF(@WEB_DeleteTemplateConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'template_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'template_delete_diag_msg'),'%template_str%',template.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_DeleteTemplateConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i        : NativeInt;
  template : IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),template));

      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_TEMPLATE,template.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(template.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_TemplateSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  modify_disabled : Boolean;
  del_disabled    : Boolean;
  template        : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  modify_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),template));
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_TEMPLATE,template.DomainID) then begin
      modify_disabled:=false;
    end;
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_TEMPLATE,template.DomainID) then begin
      del_disabled:=false;
    end;
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('modify_template',modify_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_template',del_disabled));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_TemplateMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res      : TFRE_DB_MENU_DESC;
  func     : TFRE_DB_SERVER_FUNC_DESC;
  template : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),template));

  if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_TEMPLATE,template.DomainID) then begin
    func:=CWSF(@WEB_ModifyTemplate);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_template'),'',func);
  end;
  if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_TEMPLATE,template.DomainID) then begin
    func:=CWSF(@WEB_DeleteTemplate);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_template'),'',func);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddSubnetEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifySubnetEntry(input,ses,app,conn,nil);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddFixedEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyFixedEntry(input,ses,app,conn,nil);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ModifyEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dbo: IFRE_DB_Object;
begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
  if dbo.Implementor_HC is TFRE_DB_DHCP_SUBNET then begin
    Result:=_AddModifySubnetEntry(input,ses,app,conn,dbo);
  end else begin
    Result:=_AddModifyFixedEntry(input,ses,app,conn,dbo);
  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreSubnetEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  entryObj    : TFRE_DB_DHCP_SUBNET;
  isNew       : Boolean;
  service     : IFRE_DB_Object;

begin
  GetSystemScheme(TFRE_DB_DHCP_SUBNET,scheme);

  if input.FieldExists('entryId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('entryId').AsString),TFRE_DB_DHCP_SUBNET,entryObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_SUBNET,entryObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('dhcpId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_SUBNET,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    entryObj:=TFRE_DB_DHCP_SUBNET.CreateForDB;
    entryObj.SetDomainID(service.DomainID);
    entryObj.Field('dhcp_id').AsObjectLink:=service.UID;
    isNew:=true;
  end;

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,entryObj,isNew,conn);

  if isNew then begin
    CheckDbResult(conn.GetCollection(CFRE_DB_DHCP_ENTRY_COLLECTION).Store(entryObj));
  end else begin
    CheckDbResult(conn.Update(entryObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreFixedEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  entryObj    : TFRE_DB_DHCP_FIXED;
  isNew       : Boolean;
  service     : IFRE_DB_Object;

begin
  GetSystemScheme(TFRE_DB_DHCP_FIXED,scheme);

  if input.FieldExists('entryId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('entryId').AsString),TFRE_DB_DHCP_FIXED,entryObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_FIXED,entryObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('dhcpId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_FIXED,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    entryObj:=TFRE_DB_DHCP_FIXED.CreateForDB;
    entryObj.SetDomainID(service.DomainID);
    entryObj.Field('dhcp_id').AsObjectLink:=service.UID;
    isNew:=true;
  end;

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,entryObj,isNew,conn);

  if isNew then begin
    CheckDbResult(conn.GetCollection(CFRE_DB_DHCP_ENTRY_COLLECTION).Store(entryObj));
  end else begin
    CheckDbResult(conn.Update(entryObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_DeleteEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg   : String;
  entry     : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),entry));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,entry.Implementor_HC.ClassType,entry.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_DeleteEntryConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  if entry.Implementor_HC is TFRE_DB_DHCP_SUBNET then begin
    cap:=FetchModuleTextShort(ses,'subnet_entry_delete_diag_cap');
    msg:=FetchModuleTextShort(ses,'subnet_entry_delete_diag_msg');
  end else begin
    cap:=FetchModuleTextShort(ses,'fixed_entry_delete_diag_cap');
    msg:=FetchModuleTextShort(ses,'fixed_entry_delete_diag_msg');
  end;
  msg:=StringReplace(msg,'%entry_str%',entry.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_DeleteEntryConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i        : NativeInt;
  entry    : IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),entry));

      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,entry.Implementor_HC.ClassType,entry.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(entry.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_EntrySC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  modify_disabled : Boolean;
  del_disabled    : Boolean;
  entry           : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  modify_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),entry));
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,entry.Implementor_HC.ClassType,entry.DomainID) then begin
      modify_disabled:=false;
    end;
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,entry.Implementor_HC.ClassType,entry.DomainID) then begin
      del_disabled:=false;
    end;
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('modify_entry',modify_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_entry',del_disabled));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_EntryMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res      : TFRE_DB_MENU_DESC;
  func     : TFRE_DB_SERVER_FUNC_DESC;
  entry    : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),entry));

  if conn.sys.CheckClassRight4DomainId(sr_UPDATE,entry.Implementor_HC.ClassType,entry.DomainID) then begin
    func:=CWSF(@WEB_ModifyEntry);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_entry'),'',func);
  end;
  if conn.sys.CheckClassRight4DomainId(sr_DELETE,entry.Implementor_HC.ClassType,entry.DomainID) then begin
    func:=CWSF(@WEB_DeleteEntry);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_entry'),'',func);
  end;
  Result:=res;
end;

end.

