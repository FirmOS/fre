unit fos_firmbox_dns_mod;

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
  FRE_DB_COMMON;

const

  CFOS_DB_NETWORK_DOMAINS_COLLECTION            = 'network_domains';
  CFOS_DB_DNS_RECORDS_COLLECTION                = 'dns_records';

type

  { TFOS_FIRMBOX_DNS_MOD }

  TFOS_FIRMBOX_DNS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain         (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    class procedure InstallUserDBObjects4SysDomain      (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    function        _AddModifyResourceRecord            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DomainDetailsContent            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DomainRecordsContent            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainsMenu              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainsSC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddNetworkDomain                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateNetworkDomain             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_UpdateNetworkDomain             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainDelete             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainDeleteConfirmed    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddResourceRecord               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyResourceRecord            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreResourceRecord             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordDelete            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordDeleteConfirmed   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordsMenu             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_FIRMBOX_NAMESERVER_MOD }

  TFOS_FIRMBOX_NAMESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain         (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    class procedure InstallUserDBObjects4SysDomain      (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    function        _AddModifyNameserver                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       CalculateGridFields                 (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object);
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NameserverMenu                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddNameserver                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyNameserver                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreNameserver                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NameserverDelete                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NameserverDeleteConfirmed       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SetAsDefault                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_DB_NETWORK_DOMAIN }

  TFOS_DB_NETWORK_DOMAIN=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_DNS_RESOURCE_RECORD }

  TFOS_DB_DNS_RESOURCE_RECORD=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_DNS_NAMESERVER_RECORD }

  TFOS_DB_DNS_NAMESERVER_RECORD=class(TFOS_DB_DNS_RESOURCE_RECORD)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_NETWORK_DOMAIN);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_DNS_RESOURCE_RECORD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_DNS_NAMESERVER_RECORD);

  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_DNS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_NAMESERVER_MOD);

  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_DB_DNS_NAMESERVER_RECORD }

class procedure TFOS_DB_DNS_NAMESERVER_RECORD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group: IFRE_DB_InputGroupSchemeDefinition;
  enum : IFRE_DB_Enum;
begin
  inherited RegisterSystemScheme(scheme);

  enum:=GFRE_DBI.NewEnum('dns_nameserver_type').Setup(GFRE_DBI.CreateText('$dns_nameserver_type','Nameserver Type'));
  enum.addEntry('NS',GetTranslateableTextKey('dns_rr_ns'));
  GFRE_DBI.RegisterSysEnum(enum);

  scheme.SetParentSchemeByName('TFOS_DB_DNS_RESOURCE_RECORD');
  scheme.GetSchemeField('type').SetupFieldDef(true,false,'dns_nameserver_type');
  scheme.AddSchemeField('default',fdbft_Int16);

  group:=scheme.ReplaceInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('host',GetTranslateableTextKey('scheme_host'));
  group.AddInput('value',GetTranslateableTextKey('scheme_value'));
  group.AddInput('ttl',GetTranslateableTextKey('scheme_ttl'));
end;

class procedure TFOS_DB_DNS_NAMESERVER_RECORD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';

    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_host','Host');
    StoreTranslateableText(conn,'scheme_value','Value');
    StoreTranslateableText(conn,'scheme_ttl','Time to live');

    StoreTranslateableText(conn,'dns_rr_ns','NS (Name server record)');
  end;
end;

{ TFOS_FIRMBOX_GLOBAL_NS_MOD }

class procedure TFOS_FIRMBOX_NAMESERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_NAMESERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('nameserver_description')
end;

class procedure TFOS_FIRMBOX_NAMESERVER_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    //TFOS_FIRMBOX_NAMESERVER_MOD;
    CreateModuleText(conn,'nameserver_description','Nameserver','Nameserver','Nameserver');

    CreateModuleText(conn,'grid_records_host','Host');
    CreateModuleText(conn,'grid_records_value','Value');
    CreateModuleText(conn,'grid_records_ttl','TTL');

    CreateModuleText(conn,'nameserver_create_diag_cap','New Nameserver');
    CreateModuleText(conn,'nameserver_modify_diag_cap','Modify Nameserver');
    CreateModuleText(conn,'nameserver_delete_diag_cap','Delete Nameserver');
    CreateModuleText(conn,'nameserver_delete_diag_msg','Delete Nameserver %rr_str%?');

    CreateModuleText(conn,'tb_create_nameserver','New');
    CreateModuleText(conn,'tb_modify_nameserver','Modify');
    CreateModuleText(conn,'tb_delete_nameserver','Delete');
    CreateModuleText(conn,'tb_set_as_default_1','Set as Default 1');
    CreateModuleText(conn,'tb_set_as_default_2','Set as Default 2');
    CreateModuleText(conn,'cm_modify_nameserver','Modify');
    CreateModuleText(conn,'cm_delete_nameserver','Delete');
    CreateModuleText(conn,'cm_set_as_default_1','Set as Default 1');
    CreateModuleText(conn,'cm_set_as_default_2','Set as Default 2');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
  end;
end;

class procedure TFOS_FIRMBOX_NAMESERVER_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';
  end;
end;

class procedure TFOS_FIRMBOX_NAMESERVER_MOD.InstallUserDBObjects4SysDomain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallUserDBObjects4SysDomain(conn, currentVersionId, domainUID);
  InstallUserDBObjects4Domain(conn,currentVersionId,domainUID);
end;

function TFOS_FIRMBOX_NAMESERVER_MOD._AddModifyNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  sf       : TFRE_DB_SERVER_FUNC_DESC;
  diagCap  : TFRE_DB_String;
  recordDBO: IFRE_DB_Object;
  scheme   : IFRE_DB_SchemeObject;
  res      : TFRE_DB_FORM_DIALOG_DESC;
begin
  GetSystemScheme(TFOS_DB_DNS_NAMESERVER_RECORD,scheme);

  sf:=CWSF(@WEB_StoreNameserver);
  if isModify then begin
    sf.AddParam.Describe('rrecordId',input.Field('selected').AsString);
    diagCap:=FetchModuleTextShort(ses,'nameserver_modify_diag_cap');
  end else begin
    diagCap:=FetchModuleTextShort(ses,'nameserver_create_diag_cap');
  end;
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsString),recordDBO));
    res.FillWithObjectValues(recordDBO,ses);
  end;

  Result:=res;
end;

procedure TFOS_FIRMBOX_NAMESERVER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app         : TFRE_DB_APPLICATION;
  conn        : IFRE_DB_CONNECTION;
  transform   : IFRE_DB_SIMPLE_TRANSFORM;
  records_grid: IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('host','host',FetchModuleTextShort(session,'grid_records_host'),dt_string,true,true,false,1,'icon');
      AddOneToOnescheme('value','value',FetchModuleTextShort(session,'grid_records_value'),dt_string);
      AddOneToOnescheme('ttl','ttl',FetchModuleTextShort(session,'grid_records_ttl'),dt_number);
      AddOneToOnescheme('type','type','',dt_string,false);
      AddOneToOnescheme('icon','icon','',dt_string,false);
      AddOneToOnescheme('default','default','',dt_number,false);
      SetFinalRightTransformFunction(@CalculateGridFields);
    end;

    records_grid := session.NewDerivedCollection('NAMESERVER_RECORDS_GRID');
    with records_grid do begin
      SetDeriveParent(conn.GetDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION));
      SetUseDependencyAsRefLinkFilter(['RECORDS>TFOS_DB_DNS_RESOURCE_RECORD'],false,'uid');
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',nil,'',CWSF(@WEB_NameserverMenu));
      SetDefaultOrderField('host',true);
      Filters.AddStringFieldFilter('TYPE_FILTER','type','NS',dbft_EXACT);
    end;
  end;
end;

procedure TFOS_FIRMBOX_NAMESERVER_MOD.CalculateGridFields(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object);
begin
  if transformed_object.FieldExists('default') then begin
    if transformed_object.Field('default').AsInt16=1 then begin
      transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/firmbox_dns/nameserver_default_1.svg');
    end else begin
      transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/firmbox_dns/nameserver_default_2.svg');
    end;
  end else begin
    transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/firmbox_dns/nameserver.svg');
  end;
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc_records  : IFRE_DB_DERIVED_COLLECTION;
  records_grid: TFRE_DB_VIEW_LIST_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_records:=ses.FetchDerivedCollection('NAMESERVER_RECORDS_GRID');
  records_grid:=dc_records.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_NAMESERVER_RECORD) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_AddNameserver),'',FetchModuleTextShort(ses,'tb_create_nameserver'),FetchModuleTextHint(ses,'tb_create_nameserver'));
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_NameserverDelete),'',FetchModuleTextShort(ses,'tb_delete_nameserver'),FetchModuleTextHint(ses,'tb_delete_nameserver'),fdgbd_single);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_NAMESERVER_RECORD) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_ModifyNameserver),'',FetchModuleTextShort(ses,'tb_modify_nameserver'),FetchModuleTextHint(ses,'tb_modify_nameserver'),fdgbd_single);
    sf:=CWSF(@WEB_SetAsDefault);
    sf.AddParam.Describe('default','1');
    records_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_set_as_default_1'),FetchModuleTextHint(ses,'tb_set_as_default_1'),fdgbd_single);
    sf:=CWSF(@WEB_SetAsDefault);
    sf.AddParam.Describe('default','2');
    records_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_set_as_default_2'),FetchModuleTextHint(ses,'tb_set_as_default_2'),fdgbd_single);
  end;

  Result:=records_grid;
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_NameserverMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_MENU_DESC;
  func: TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_NAMESERVER_RECORD) then begin
    func:=CWSF(@WEB_NameserverDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_nameserver'),'',func);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_NAMESERVER_RECORD) then begin
    func:=CWSF(@WEB_ModifyNameserver);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_nameserver'),'',func);
    func:=CWSF(@WEB_SetAsDefault);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    func.AddParam.Describe('default','1');
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_set_as_default_1'),'',func);
    func:=CWSF(@WEB_SetAsDefault);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    func.AddParam.Describe('default','2');
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_set_as_default_2'),'',func);
  end;
  Result:=res;
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_AddNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_NAMESERVER_RECORD) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=_AddModifyNameserver(input,ses,app,conn,false);
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_ModifyNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_NAMESERVER_RECORD) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=_AddModifyNameserver(input,ses,app,conn,true);
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_StoreNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject : IFRE_DB_SchemeObject;
  nameserverObj: TFOS_DB_DNS_NAMESERVER_RECORD;
  isNew        : Boolean;
  resourceColl : IFRE_DB_COLLECTION;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_NAMESERVER_RECORD) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_DNS_NAMESERVER_RECORD,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_DNS_NAMESERVER_RECORD]);

  if input.FieldExists('rrecordId') then begin
    CheckDbResult(conn.FetchAs(FREDB_String2Guid(input.Field('rrecordId').AsString),TFOS_DB_DNS_NAMESERVER_RECORD,nameserverObj));
    isNew:=false;
  end else begin
    resourceColl:=conn.GetDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION);
    nameserverObj:=TFOS_DB_DNS_NAMESERVER_RECORD.CreateForDB;
    nameserverObj.Field('type').AsString:='NS';
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,nameserverObj,true,conn);

  if isNew then begin
    CheckDbResult(resourceColl.Store(nameserverObj));
  end else begin
    CheckDbResult(conn.Update(nameserverObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();

end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_NameserverDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg    : String;
  rrecord    : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_NAMESERVER_RECORD) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_NameserverDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'nameserver_delete_diag_cap');

  CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsStringArr[0]),rrecord));
  msg:=StringReplace(FetchModuleTextShort(ses,'nameserver_delete_diag_msg'),'%rr_str%',rrecord.Field('host').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_NameserverDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i       : NativeInt;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_NAMESERVER_RECORD) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Delete(FREDB_H2G(input.Field('selected').AsStringArr[i])));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_NAMESERVER_MOD.WEB_SetAsDefault(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  nsObj    : TFOS_DB_DNS_NAMESERVER_RECORD;
  nsObjUID : TGUID;
  obj      : IFRE_DB_Object;
  configObj: TFRE_DB_APPLICATION_CONFIG;
  isNew    : Boolean;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_NAMESERVER_RECORD) and conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_APPLICATION_CONFIG)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));


  if conn.AdmGetApplicationConfigCollection.GetIndexedObj('TFOS_FIRMBOX_NAMESERVER_MOD',obj) then begin
    isNew:=false;
    configObj:=obj.Implementor_HC as TFRE_DB_APPLICATION_CONFIG;
  end else begin
    isNew:=true;
    configObj:=TFRE_DB_APPLICATION_CONFIG.CreateForDB;
    configObj.Field('id').AsString:='TFOS_FIRMBOX_NAMESERVER_MOD';
  end;
  if configObj.FieldExists('default_'+input.Field('default').AsString) then begin //REMOVE OLD DEFAULT OBJ SET FOR THE GIVEN SLOT
    CheckDbResult(conn.FetchAs(configObj.Field('default_'+input.Field('default').AsString).AsGUID,TFOS_DB_DNS_NAMESERVER_RECORD,nsObj));
    nsObj.DeleteField('default');
    CheckDbResult(conn.Update(nsObj));
  end;
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFOS_DB_DNS_NAMESERVER_RECORD,nsObj));
  if nsObj.FieldExists('default') then begin //REMOVE NEW OBJ FROM CONFIG IF ALREADY USED AS (A DIFFRENT) DEFAULT
    configObj.DeleteField('default_'+IntToStr(nsObj.Field('default').AsInt16));
  end;
  nsObj.Field('default').AsInt16:=FREDB_String2NativeInt(input.Field('default').AsString);
  CheckDbResult(conn.Update(nsObj.CloneToNewObject()));
  configObj.Field('default_'+input.Field('default').AsString).AsGUID:=nsObj.UID;
  if isNew then begin
    CheckDbResult(conn.AdmGetApplicationConfigCollection.Store(configObj));
  end else begin
    CheckDbResult(conn.Update(configObj));
  end;
  Result:=GFRE_DB_NIL_DESC;
end;

{ TFOS_DB_DNS_RESOURCE_RECORD }

class procedure TFOS_DB_DNS_RESOURCE_RECORD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group      : IFRE_DB_InputGroupSchemeDefinition;
  enum       : IFRE_DB_Enum;
  schemeField: IFRE_DB_FieldSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);

  enum:=GFRE_DBI.NewEnum('dns_resource_record_type').Setup(GFRE_DBI.CreateText('$dns_resource_record_type','Resource Record Type'));
  enum.addEntry('A',GetTranslateableTextKey('dns_rr_a'));
  enum.addEntry('AAAA',GetTranslateableTextKey('dns_rr_aaaa'));
  enum.addEntry('CNAME',GetTranslateableTextKey('dns_rr_cname'));
  enum.addEntry('MX',GetTranslateableTextKey('dns_rr_mx'));
  enum.addEntry('TXT',GetTranslateableTextKey('dns_rr_txt'));
  enum.addEntry('SPF',GetTranslateableTextKey('dns_rr_spf'));
  enum.addEntry('SRV',GetTranslateableTextKey('dns_rr_srv'));
  //enum.addEntry('NS',GetTranslateableTextKey('dns_rr_ns'));
  GFRE_DBI.RegisterSysEnum(enum);

  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('host',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('value',fdbft_String);
  scheme.AddSchemeField('ttl',fdbft_Int64);

  scheme.AddSchemeField('priority',fdbft_String);
  scheme.AddSchemeField('weight',fdbft_String);
  scheme.AddSchemeField('port',fdbft_Int64);

  schemeField:=scheme.AddSchemeField('type',fdbft_String).SetupFieldDef(true,false,'dns_resource_record_type');
  schemeField.addVisDepField('priority','MX');
  schemeField.addVisDepField('priority','SRV');
  schemeField.addVisDepField('weight','SRV');
  schemeField.addVisDepField('port','SRV');

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('host',GetTranslateableTextKey('scheme_host'));
  group.AddInput('type',GetTranslateableTextKey('scheme_type'));
  group.AddInput('value',GetTranslateableTextKey('scheme_value'));
  group.AddInput('ttl',GetTranslateableTextKey('scheme_ttl'));
  group.AddInput('priority',GetTranslateableTextKey('scheme_priority'));
  group.AddInput('weight',GetTranslateableTextKey('scheme_weight'));
  group.AddInput('port',GetTranslateableTextKey('scheme_port'));
end;

class procedure TFOS_DB_DNS_RESOURCE_RECORD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';

    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_host','Host');
    StoreTranslateableText(conn,'scheme_type','Type');
    StoreTranslateableText(conn,'scheme_value','Value');
    StoreTranslateableText(conn,'scheme_ttl','Time to live');
    StoreTranslateableText(conn,'scheme_priority','Priority');
    StoreTranslateableText(conn,'scheme_weight','Weight');
    StoreTranslateableText(conn,'scheme_port','Port');

    StoreTranslateableText(conn,'dns_rr_a','A (Address Record IPv4)');
    StoreTranslateableText(conn,'dns_rr_aaaa','AAAA (Address Record IPv6)');
    StoreTranslateableText(conn,'dns_rr_cname','CNAME (Canonical name record)');
    StoreTranslateableText(conn,'dns_rr_mx','MX (Mail exchange record)');
    StoreTranslateableText(conn,'dns_rr_txt','TXT (Text record)');
    StoreTranslateableText(conn,'dns_rr_spf','SPF (Sender Policy Framework)');
    StoreTranslateableText(conn,'dns_rr_srv','SRV (Service locator)');
    StoreTranslateableText(conn,'dns_rr_ns','NS (Name server record)');

  end;
end;

{ TFOS_DB_NETWORK_DOMAIN }

class procedure TFOS_DB_NETWORK_DOMAIN.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  params: IFRE_DB_Object;
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('name',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('dns',fdbft_ObjLink).SetupFieldDef(true,true);
  scheme.AddSchemeField('default',fdbft_ObjLink);
  scheme.AddSchemeField('records',fdbft_ObjLink).setMultiValues(true);

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('name',GetTranslateableTextKey('scheme_name'));
end;

class procedure TFOS_DB_NETWORK_DOMAIN.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'scheme_name','Name');
  end;
  if (currentVersionId='1.0') then begin
  //next update code
  end;

   
end;

{ TFOS_FIRMBOX_DNS_MOD }

class procedure TFOS_FIRMBOX_DNS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_DNS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('dns_description')
end;

class procedure TFOS_FIRMBOX_DNS_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    //TFOS_FIRMBOX_DNS_MOD;
    CreateModuleText(conn,'dns_description','DNS','DNS','DNS');

    CreateModuleText(conn,'grid_network_domains_name','Name');
    CreateModuleText(conn,'grid_network_domains_default','Default');
    CreateModuleText(conn,'grid_network_domains_default_type','Type');
    CreateModuleText(conn,'grid_records_host','Host');
    CreateModuleText(conn,'grid_records_type','Type');
    CreateModuleText(conn,'grid_records_value','Value');
    CreateModuleText(conn,'grid_records_ttl','TTL');

    CreateModuleText(conn,'tb_create_network_domain','Add');
    CreateModuleText(conn,'tb_delete_network_domain','Delete');
    CreateModuleText(conn,'cm_delete_network_domain','Delete');

    CreateModuleText(conn,'tb_create_resource_record','Add');
    CreateModuleText(conn,'tb_delete_resource_record','Delete');
    CreateModuleText(conn,'tb_modify_resource_record','Modify');
    CreateModuleText(conn,'cm_delete_resource_record','Delete');
    CreateModuleText(conn,'cm_modify_resource_record','Modify');

    CreateModuleText(conn,'network_domain_create_diag_cap','New Domain');
    CreateModuleText(conn,'network_domain_create_dns1','DNS 1');
    CreateModuleText(conn,'network_domain_create_dns2','DNS 2');
    CreateModuleText(conn,'network_domain_create_default','Default');

    CreateModuleText(conn,'network_domain_edit_dns1','DNS 1');
    CreateModuleText(conn,'network_domain_edit_dns2','DNS 2');
    CreateModuleText(conn,'network_domain_edit_default','Default');
    CreateModuleText(conn,'network_domain_edit_default_chooser','Host');
    CreateModuleText(conn,'network_domain_edit_default_postfix_val_A','(A)');
    CreateModuleText(conn,'network_domain_edit_default_postfix_val_AAAA','(AAAA)');

    CreateModuleText(conn,'network_domain_create_error_exists_cap','Create Network Domain');
    CreateModuleText(conn,'network_domain_create_error_exists_msg','Network Domain already exists. Please choose a different network domain name.');
    CreateModuleText(conn,'network_domain_delete_diag_cap','Delete Network Domain');
    CreateModuleText(conn,'network_domain_delete_diag_msg','Delete Network Domain %nw_domain_str%?');

    CreateModuleText(conn,'network_domain_content_section_details','Details');
    CreateModuleText(conn,'network_domain_content_section_records','Records');

    CreateModuleText(conn,'resource_record_create_diag_cap','Create Resource Record');
    CreateModuleText(conn,'resource_record_modify_diag_cap','Modify Resource Record');
    CreateModuleText(conn,'resource_record_delete_diag_cap','Delete Resource Record');
    CreateModuleText(conn,'resource_record_delete_diag_msg','Delete Resource Record %rr_str%?');

    CreateModuleText(conn,'info_domain_details_select_one','Please select a network domain to get detailed information about it.');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
  end;
   
end;

class procedure TFOS_FIRMBOX_DNS_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
var
  coll: IFRE_DB_COLLECTION;
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    if not conn.DomainCollectionExists(CFOS_DB_NETWORK_DOMAINS_COLLECTION) then begin
      coll := conn.CreateDomainCollection(CFOS_DB_NETWORK_DOMAINS_COLLECTION,false,'',FREDB_G2H(domainUID));
      coll.DefineIndexOnField('name',fdbft_String,true,true);
      coll := conn.CreateDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION,false,'',FREDB_G2H(domainUID));
      coll.DefineIndexOnField('name',fdbft_String,true,true);
    end;
  end;
end;

class procedure TFOS_FIRMBOX_DNS_MOD.InstallUserDBObjects4SysDomain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallUserDBObjects4SysDomain(conn, currentVersionId, domainUID);
  InstallUserDBObjects4Domain(conn,currentVersionId,domainUID);
end;

function TFOS_FIRMBOX_DNS_MOD._AddModifyResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  diagCap    : TFRE_DB_String;
  recordDBO  : IFRE_DB_Object;
  typeChooser: TFRE_DB_INPUT_CHOOSER_DESC;
  formInput  : TFRE_DB_INPUT_DESC;
begin
  GetSystemScheme(TFOS_DB_DNS_RESOURCE_RECORD,scheme);

  sf:=CWSF(@WEB_StoreResourceRecord);
  if isModify then begin
    sf.AddParam.Describe('rrecordId',input.Field('selected').AsString);
    diagCap:=FetchModuleTextShort(ses,'resource_record_modify_diag_cap');
  end else begin
    sf.AddParam.Describe('networkDomainId',input.FieldPath('dependency.uid_ref.filtervalues').AsStringItem[0]);
    diagCap:=FetchModuleTextShort(ses,'resource_record_create_diag_cap');
  end;
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsString),recordDBO));
    res.FillWithObjectValues(recordDBO,ses);
  end;

  Result:=res;
end;

procedure TFOS_FIRMBOX_DNS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app         : TFRE_DB_APPLICATION;
  conn        : IFRE_DB_CONNECTION;
  transform   : IFRE_DB_SIMPLE_TRANSFORM;
  domains_grid: IFRE_DB_DERIVED_COLLECTION;
  records_grid: IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('name','name',FetchModuleTextShort(session,'grid_network_domains_name'),dt_string,true,true);
      AddMatchingReferencedField('default','host','default',FetchModuleTextShort(session,'grid_network_domains_default'));
      AddMatchingReferencedField('default','type','default_type',FetchModuleTextShort(session,'grid_network_domains_default_type'));
    end;
    domains_grid := session.NewDerivedCollection('NETWORK_DOMAINS_GRID');
    with domains_grid do begin
      SetDeriveParent(conn.GetDomainCollection(CFOS_DB_NETWORK_DOMAINS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',nil,'',CWSF(@WEB_NetworkDomainsMenu),nil,CWSF(@WEB_NetworkDomainsSC));
      SetDefaultOrderField('name',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('host','host',FetchModuleTextShort(session,'grid_records_host'),dt_string,true,true);
      AddOneToOnescheme('type','type',FetchModuleTextShort(session,'grid_records_type'),dt_string);
      AddOneToOnescheme('value','value',FetchModuleTextShort(session,'grid_records_value'),dt_string);
      AddOneToOnescheme('ttl','ttl',FetchModuleTextShort(session,'grid_records_ttl'),dt_number);
      AddOneToOnescheme('type','type_native','',dt_string,false);
    end;

    records_grid := session.NewDerivedCollection('DNS_RECORDS_GRID');
    with records_grid do begin
      SetDeriveParent(conn.GetDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION));
      SetUseDependencyAsRefLinkFilter(['RECORDS>TFOS_DB_DNS_RESOURCE_RECORD'],false,'uid');
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',nil,'',CWSF(@WEB_ResourceRecordsMenu));
      SetDefaultOrderField('host',true);
      Filters.AddStringFieldFilter('TYPE_FILTER','type_native','NS',dbft_EXACT,false);
    end;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc,dc_records : IFRE_DB_DERIVED_COLLECTION;
  domains_grid  : TFRE_DB_VIEW_LIST_DESC;
  domain_content: TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedDomain');
  dc:=ses.FetchDerivedCollection('NETWORK_DOMAINS_GRID');
  domains_grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    domains_grid.AddButton.Describe(CWSF(@WEB_AddNetworkDomain),'',FetchModuleTextShort(ses,'tb_create_network_domain'),FetchModuleTextHint(ses,'tb_create_network_domain'));
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    domains_grid.AddButton.Describe(CWSF(@WEB_NetworkDomainDelete),'',FetchModuleTextShort(ses,'tb_delete_network_domain'),FetchModuleTextHint(ses,'tb_delete_network_domain'),fdgbd_single);
  end;

  dc_records:=ses.FetchDerivedCollection('DNS_RECORDS_GRID');
  domains_grid.AddFilterEvent(dc_records.getDescriptionStoreId(),'uid');

  domain_content:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  domain_content.AddSection.Describe(CWSF(@WEB_DomainDetailsContent),FetchModuleTextShort(ses,'network_domain_content_section_details'),1);
  domain_content.AddSection.Describe(CWSF(@WEB_DomainRecordsContent),FetchModuleTextShort(ses,'network_domain_content_section_records'),2);

  Result:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(domains_grid,domain_content,nil,nil,nil,true,1,1);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_DomainDetailsContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme,rr_scheme: IFRE_DB_SchemeObject;
  res             : TFRE_DB_CONTENT_DESC;
  form            : TFRE_DB_FORM_PANEL_DESC;
  editable        : Boolean;
  nw_domain       : IFRE_DB_Object;
  resource        : IFRE_DB_Object;
  defaultG        : TFRE_DB_INPUT_GROUP_DESC;
  i               : Integer;
  rrecord         : IFRE_DB_Object;
  defaultStore    : TFRE_DB_STORE_DESC;
  sf              : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedDomain') and (ses.GetSessionModuleData(ClassName).Field('selectedDomain').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_String2Guid(ses.GetSessionModuleData(ClassName).Field('selectedDomain').AsStringItem[0]),nw_domain));

    GetSystemScheme(TFOS_DB_NETWORK_DOMAIN,scheme);
    GetSystemScheme(TFOS_DB_DNS_RESOURCE_RECORD,rr_scheme);
    editable:=(conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and
               conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD) and
               conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_RESOURCE_RECORD) and
               conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD));
    form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,editable);
    form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'domain');

    form.AddSchemeFormGroup(rr_scheme.GetInputGroup('main'),ses,false,false,'dns1',true).SetCaption(FetchModuleTextShort(ses,'network_domain_edit_dns1'));
    form.AddSchemeFormGroup(rr_scheme.GetInputGroup('main'),ses,false,false,'dns2',false).SetCaption(FetchModuleTextShort(ses,'network_domain_edit_dns2'));

    form.FillWithObjectValues(nw_domain,ses,'domain');

    defaultStore:=TFRE_DB_STORE_DESC.create.Describe();
    for i := 0 to nw_domain.Field('records').ValueCount - 1 do begin
      CheckDbResult(conn.Fetch(nw_domain.Field('records').AsObjectLinkItem[i],rrecord));
      if ((rrecord.Field('type').AsString='A') or (rrecord.Field('type').AsString='AAAA')) then begin
        defaultStore.AddEntry.Describe(rrecord.Field('host').AsString + ' ' + FetchModuleTextShort(ses,'network_domain_edit_default_postfix_val_'+rrecord.Field('type').AsString),rrecord.UID_String);
      end;
    end;

    defaultG:=form.AddGroup.Describe(FetchModuleTextShort(ses,'network_domain_edit_default'));
    defaultG.AddChooser.Describe(FetchModuleTextShort(ses,'network_domain_edit_default_chooser'),'default_host',defaultStore);

    if nw_domain.FieldExists('default') then begin
      form.SetElementValue('default_host',FREDB_G2H(nw_domain.Field('default').AsObjectLink));
    end;
    if nw_domain.FieldExists('dns') then begin
      CheckDbResult(conn.Fetch(nw_domain.Field('dns').AsObjectLinkArray[0],resource));
      form.FillWithObjectValues(resource,ses,'dns1');
      form.SetElementDisabled('dns1.type');
      if nw_domain.Field('dns').ValueCount>1 then begin
        CheckDbResult(conn.Fetch(nw_domain.Field('dns').AsObjectLinkArray[1],resource));
        form.FillWithObjectValues(resource,ses,'dns2');
        form.SetElementDisabled('dns2.type');
      end else begin
        form.SetElementValueDisabled('dns2.type','NS');
      end;
    end else begin
      form.SetElementValueDisabled('dns1.type','NS');
      form.SetElementValueDisabled('dns2.type','NS');
    end;

    sf:=CWSF(@WEB_UpdateNetworkDomain);
    sf.AddParam.Describe('nwDomainId',nw_domain.UID_String);
    form.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
    res:=form;
  end else begin
    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_domain_details_select_one'));
  end;
  res.contentId:='NW_DOMAIN_DETAILS';
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_DomainRecordsContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc_records  : IFRE_DB_DERIVED_COLLECTION;
  records_grid: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_records:=ses.FetchDerivedCollection('DNS_RECORDS_GRID');
  records_grid:=dc_records.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and  conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    records_grid.AddButton.DescribeManualType('add_record',CWSF(@WEB_AddResourceRecord),'',FetchModuleTextShort(ses,'tb_create_resource_record'),FetchModuleTextHint(ses,'tb_create_resource_record'),not (ses.GetSessionModuleData(ClassName).FieldExists('selectedDomain') and (ses.GetSessionModuleData(ClassName).Field('selectedDomain').ValueCount=1)));
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_ResourceRecordDelete),'',FetchModuleTextShort(ses,'tb_delete_resource_record'),FetchModuleTextHint(ses,'tb_delete_resource_record'),fdgbd_single);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_ModifyResourceRecord),'',FetchModuleTextShort(ses,'tb_modify_resource_record'),FetchModuleTextHint(ses,'tb_modify_resource_record'),fdgbd_single);
  end;

  Result:=records_grid;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainsMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_MENU_DESC;
  func: TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_NetworkDomainDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_network_domain'),'',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainsSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  add_disabled: Boolean;
begin
  CheckClassVisibility4MyDomain(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedDomain').AsStringArr:=input.Field('selected').AsStringArr;
    if input.Field('selected').ValueCount=1 then begin
      add_disabled:=false;
    end else begin
      add_disabled:=true;
    end;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedDomain');
    add_disabled:=true;
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_record',add_disabled));
  if ses.isUpdatableContentVisible('NW_DOMAIN_DETAILS') then begin
    Result:=WEB_DomainDetailsContent(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_AddNetworkDomain(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme,rr_scheme: IFRE_DB_SchemeObject;
  res             : TFRE_DB_FORM_DIALOG_DESC;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFOS_DB_NETWORK_DOMAIN,scheme);
  GetSystemScheme(TFOS_DB_DNS_RESOURCE_RECORD,rr_scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'network_domain_create_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'domain');

  res.AddSchemeFormGroup(rr_scheme.GetInputGroup('main'),ses,false,false,'dns1',true).SetCaption(FetchModuleTextShort(ses,'network_domain_create_dns1'));
  res.AddSchemeFormGroup(rr_scheme.GetInputGroup('main'),ses,false,false,'dns2',false).SetCaption(FetchModuleTextShort(ses,'network_domain_create_dns2'));
  res.AddSchemeFormGroup(rr_scheme.GetInputGroup('main'),ses,false,false,'default',false).SetCaption(FetchModuleTextShort(ses,'network_domain_create_default'));
  res.SetElementValueDisabled('dns1.type','NS');
  res.SetElementValueDisabled('dns2.type','NS');
  res.SetElementValueDisabled('default.type','A');

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CWSF(@WEB_CreateNetworkDomain),fdbbt_submit);
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_CreateNetworkDomain(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  domain        : TFOS_DB_NETWORK_DOMAIN;
  resource      : TFOS_DB_DNS_RESOURCE_RECORD;
  schemeObject  : IFRE_DB_SchemeObject;
  schemeObjectRR: IFRE_DB_SchemeObject;
  domainColl    : IFRE_DB_COLLECTION;
  resourceColl  : IFRE_DB_COLLECTION;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldPathExists('data.domain') then raise EFRE_DB_Exception.Create('Missing input data: network domain');
  if not input.FieldPathExists('data.domain.name') then raise EFRE_DB_Exception.Create('Missing required input data: network domain name');
  if not input.FieldPathExists('data.dns1') then raise EFRE_DB_Exception.Create('Missing input data: dns1');

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_NETWORK_DOMAIN,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_NETWORK_DOMAIN]);

  domainColl:=conn.GetDomainCollection(CFOS_DB_NETWORK_DOMAINS_COLLECTION);
  resourceColl:=conn.GetDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION);

  if domainColl.ExistsIndexed(input.FieldPath('data.domain.name').AsString) then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'network_domain_create_error_exists_cap'),FetchModuleTextShort(ses,'network_domain_create_error_exists_msg'),fdbmt_error);
    exit;
  end;

  domain:=TFOS_DB_NETWORK_DOMAIN.CreateForDB;
  schemeObject.SetObjectFieldsWithScheme(input.FieldPath('data.domain').AsObject,domain,true,conn);

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_DNS_RESOURCE_RECORD,schemeObjectRR) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_DNS_RESOURCE_RECORD]);

  resource:=TFOS_DB_DNS_RESOURCE_RECORD.CreateForDB;
  input.FieldPath('data.dns1').AsObject.Field('type').AsString:='NS';
  schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.dns1').AsObject,resource,true,conn);
  domain.Field('dns').AddObjectLink(resource.UID);
  CheckDbResult(resourceColl.Store(resource));
  if input.FieldPathExists('data.dns2') then begin
    resource:=TFOS_DB_DNS_RESOURCE_RECORD.CreateForDB;
    input.FieldPath('data.dns2').AsObject.Field('type').AsString:='NS';
    schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.dns2').AsObject,resource,true,conn);
    domain.Field('dns').AddObjectLink(resource.UID);
    CheckDbResult(resourceColl.Store(resource));
  end;
  if input.FieldPathExists('data.default') then begin
    resource:=TFOS_DB_DNS_RESOURCE_RECORD.CreateForDB;
    input.FieldPath('data.default').AsObject.Field('type').AsString:='A';
    schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.default').AsObject,resource,true,conn);
    domain.Field('default').AsObjectLink:=resource.UID;
    domain.Field('records').AddObjectLink(resource.UID);
    CheckDbResult(resourceColl.Store(resource));
  end;

  CheckDbResult(domainColl.Store(domain));
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_UpdateNetworkDomain(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  resource      : TFOS_DB_DNS_RESOURCE_RECORD;
  schemeObject  : IFRE_DB_SchemeObject;
  schemeObjectRR: IFRE_DB_SchemeObject;
  resourceColl  : IFRE_DB_COLLECTION;
  nw_domain     : IFRE_DB_Object;
  resourceDBO   : IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and
          conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD) and
          conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_RESOURCE_RECORD) and
          conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('nwDomainId').AsString),nw_domain));

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_NETWORK_DOMAIN,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_NETWORK_DOMAIN]);

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_DNS_RESOURCE_RECORD,schemeObjectRR) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_DNS_RESOURCE_RECORD]);

  resourceColl:=conn.GetDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION);

  CheckDbResult(conn.Fetch(nw_domain.Field('dns').AsObjectLinkItem[0],resourceDBO));
  if input.FieldPathExists('data.dns1') then begin
    schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.dns1').AsObject,resourceDBO,false,conn);
    CheckDbResult(conn.Update(resourceDBO));
  end;
  if nw_domain.Field('dns').ValueCount>1 then begin
    CheckDbResult(conn.Fetch(nw_domain.Field('dns').AsObjectLinkItem[1],resourceDBO));
    if input.FieldPathExists('data.dns2') then begin
      schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.dns2').AsObject,resourceDBO,false,conn);
      CheckDbResult(conn.Update(resourceDBO));
    end;
  end else begin
    if input.FieldPathExists('data.dns2') then begin
      resource:=TFOS_DB_DNS_RESOURCE_RECORD.CreateForDB;
      input.FieldPath('data.dns2').AsObject.Field('type').AsString:='NS';
      schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.dns2').AsObject,resource,true,conn);
      nw_domain.Field('dns').AddObjectLink(resource.UID);
      CheckDbResult(resourceColl.Store(resource));
    end;
  end;
  if input.FieldPathExists('data.default_host') then begin
    if input.FieldPath('data.default_host').AsString=cFRE_DB_SYS_CLEAR_VAL_STR then begin
      nw_domain.DeleteField('default');
    end else begin
      nw_domain.Field('default').AsObjectLink:=FREDB_String2Guid(input.FieldPath('data.default_host').AsString);
    end;
  end;

  if input.FieldPathExists('data.domain') then begin
    schemeObject.SetObjectFieldsWithScheme(input.FieldPath('data.domain').AsObject,nw_domain,false,conn);
  end;
  CheckDbResult(conn.Update(nw_domain));

  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
  domain : IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_NetworkDomainDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'network_domain_delete_diag_cap');

  CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsStringArr[0]),domain));
  msg:=StringReplace(FetchModuleTextShort(ses,'network_domain_delete_diag_msg'),'%nw_domain_str%',domain.Field('name').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i,j          : NativeInt;
  nwDomainId   : TGuid;
  domain       : IFRE_DB_Object;
  resources    : TFRE_DB_ObjLinkArray;
  dns          : TFRE_DB_ObjLinkArray;
  default      : TGuid;
  defaultExists: Boolean;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      nwDomainId:=FREDB_String2Guid(input.Field('selected').AsStringArr[i]);
      CheckDbResult(conn.Fetch(nwDomainId,domain));
      resources:=domain.Field('records').AsObjectLinkArray;
      dns:=domain.Field('dns').AsObjectLinkArray;
      if domain.FieldExists('default') then begin
        default:=domain.Field('default').AsObjectLink;
        defaultExists:=true;
      end else begin
        defaultExists:=false;
      end;
      CheckDbResult(conn.Delete(nwDomainId));
      for j := 0 to Length(resources) - 1 do begin
        CheckDbResult(conn.Delete(resources[j]));
      end;
      for j := 0 to Length(dns) - 1 do begin
        CheckDbResult(conn.Delete(dns[j]));
      end;
      if defaultExists then begin
        CheckDbResult(conn.Delete(default));
      end;
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_AddResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and  conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not (input.FieldPathExists('dependency.uid_ref.filtervalues') and (input.FieldPath('dependency.uid_ref.filtervalues').ValueCount=1)) then
    raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'Error: Network Domain Id is missing.'));

  Result:=_AddModifyResourceRecord(input,ses,app,conn,false);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ModifyResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and  conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=_AddModifyResourceRecord(input,ses,app,conn,true);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_StoreResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  domain        : IFRE_DB_Object;
  resource      : TFOS_DB_DNS_RESOURCE_RECORD;
  schemeObject  : IFRE_DB_SchemeObject;
  resourceColl  : IFRE_DB_COLLECTION;
  isNew: Boolean;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and  conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_DNS_RESOURCE_RECORD,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_DNS_RESOURCE_RECORD]);

  if not (input.FieldExists('networkDomainId') or input.FieldExists('rrecordId')) then
    raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'Error: Network Domain Id or Resource Record Id has to be passed to WEB_StoreResourceRecord.'));

  if input.FieldExists('rrecordId') then begin
    CheckDbResult(conn.FetchAs(FREDB_String2Guid(input.Field('rrecordId').AsString),TFOS_DB_DNS_RESOURCE_RECORD,resource));
    isNew:=false;
  end else begin
    resourceColl:=conn.GetDomainCollection(CFOS_DB_DNS_RECORDS_COLLECTION);
    resource:=TFOS_DB_DNS_RESOURCE_RECORD.CreateForDB;
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,resource,true,conn);

  if isNew then begin
    CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('networkDomainId').AsString),domain));
    domain.Field('records').AddObjectLink(resource.UID);
    CheckDbResult(resourceColl.Store(resource));
    CheckDbResult(conn.Update(domain));
  end else begin
    CheckDbResult(conn.Update(resource));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg    : String;
  rrecord    : IFRE_DB_Object;
  nwDomainUid: TFRE_DB_String;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  if input.FieldExists('uid_ref') then begin
    nwDomainUid:=input.Field('uid_ref').AsString;
  end else begin
    if input.FieldPathExists('dependency.uid_ref.filtervalues') and (input.FieldPath('dependency.uid_ref.filtervalues').ValueCount=1) then begin
      nwDomainUid:=input.FieldPath('dependency.uid_ref.filtervalues').AsString;
    end else begin
      raise EFRE_DB_Exception.Create('Exactly on network domain has to be passed to WEB_ResourceRecordDelete!');
    end;
  end;

  sf:=CWSF(@WEB_ResourceRecordDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  sf.AddParam.Describe('nwDomainId',nwDomainUid);
  cap:=FetchModuleTextShort(ses,'resource_record_delete_diag_cap');

  CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsStringArr[0]),rrecord));
  msg:=StringReplace(FetchModuleTextShort(ses,'resource_record_delete_diag_msg'),'%rr_str%',rrecord.Field('host').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i       : NativeInt;
  recordId: TGuid;
  domain  : IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('nwDomainId').AsString),domain));
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      recordId:=FREDB_String2Guid(input.Field('selected').AsStringArr[i]);
      domain.Field('records').RemoveObjectLinkByUID(recordId);
      if domain.FieldExists('default') and (domain.Field('default').AsObjectLink=recordId) then begin
        domain.DeleteField('default');
      end;
      CheckDbResult(conn.Update(domain));
      CheckDbResult(conn.Delete(recordId));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordsMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_MENU_DESC;
  func: TFRE_DB_SERVER_FUNC_DESC;
begin
  if input.FieldPathExists('dependency.uid_ref.filtervalues') and
       (input.FieldPath('dependency.uid_ref.filtervalues').ValueCount=1) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
      func:=CWSF(@WEB_ResourceRecordDelete);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      func.AddParam.Describe('uid_ref',input.FieldPath('dependency.uid_ref.filtervalues').AsString);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_resource_record'),'',func);
    end;
    if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_NETWORK_DOMAIN) and conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_DNS_RESOURCE_RECORD) then begin
      func:=CWSF(@WEB_ModifyResourceRecord);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_resource_record'),'',func);
    end;
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

end.

