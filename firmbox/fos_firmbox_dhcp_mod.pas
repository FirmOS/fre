unit fos_firmbox_dhcp_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fos_firmbox_subnet_ip_mod,
  fre_hal_schemes,fre_dbbusiness;

type

{ TFRE_FIRMBOX_DHCP_MOD }

  TFRE_FIRMBOX_DHCP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    fSubnetIPMod    : TFRE_FIRMBOX_SUBNET_IP_MOD;
    function        _AddModifyTemplate          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
    function        _AddModifySubnetEntry       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const dbo:IFRE_DB_Object):IFRE_DB_Object;
    function        _AddModifyFixedEntry        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const dbo:IFRE_DB_Object):IFRE_DB_Object;
    procedure       _StoreHandleTemplates       (const conn: IFRE_DB_CONNECTION; const input:IFRE_DB_Object; const entryObj: IFRE_DB_Object; const isModify: Boolean);
    procedure       _AddModifyHandleTemplates   (const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_Usersession; const dbo: IFRE_DB_Object; const res: TFRE_DB_FORM_DESC; const store: TFRE_DB_STORE_DESC; const isSubnet: Boolean);
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
    function        WEB_AddStandardOption       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreStandardOption     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddCustomOption         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreCustomOption       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteOption            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CleanupTemplateDiag     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CleanupAddOptionDiag    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

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
  dc          : IFRE_DB_DERIVED_COLLECTION;
  group       : TFRE_DB_INPUT_GROUP_DESC;
  block       : TFRE_DB_INPUT_BLOCK_DESC;
  baseAddIPSf : TFRE_DB_SERVER_FUNC_DESC;
  addIPSf     : TFRE_DB_SERVER_FUNC_DESC;
  opSf        : TFRE_DB_SERVER_FUNC_DESC;
  i           : Integer;
begin
  sf:=CWSF(@WEB_StoreTemplate);

  baseAddIPSf:=CWSF(@fSubnetIPMod.WEB_AddIP);
  baseAddIPSf.AddParam.Describe('cbclass',self.ClassName);
  baseAddIPSf.AddParam.Describe('cbuidpath',FREDB_CombineString(self.GetUIDPath,','));
  CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_TEMPLATE,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    if not ses.GetSessionModuleData(ClassName).FieldExists('templateDiagData') then begin //FIRST CALL - REFILL templateDiagData
      for i := 0 to dbo.Field('standard_options').ValueCount - 1 do begin
        ses.GetSessionModuleData(ClassName).FieldPathCreate('templateDiagData.standard').AddObject(dbo.Field('standard_options').AsObjectItem[i].CloneToNewObject());
      end;
      for i := 0 to dbo.Field('custom_options').ValueCount - 1 do begin
        ses.GetSessionModuleData(ClassName).FieldPathCreate('templateDiagData.custom').AddObject(dbo.Field('custom_options').AsObjectItem[i].CloneToNewObject());
      end;
    end;

    sf.AddParam.Describe('templateId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'template_modify_diag_cap');
    baseAddIPSf.AddParam.Describe('cbfunc','ModifyTemplate');
    baseAddIPSf.AddParam.Describe('selected',dbo.UID_String);
  end else begin
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_TEMPLATE,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('dhcpId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'template_create_diag_cap');
    baseAddIPSf.AddParam.Describe('cbfunc','AddTemplate');
    baseAddIPSf.AddParam.Describe('selected',service.UID_String);
  end;

  dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_IP_CHOOSER_DC);
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
  dc.Filters.RemoveFilter('scheme');
  dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4.ClassName]);

  GetSystemScheme(TFRE_DB_DHCP_TEMPLATE,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600,false);

  group:=res.AddSchemeFormGroup(scheme.GetInputGroup('general'),ses);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'router_block'));
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('router'),ses,[],'',false,true);
  if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
    addIPSf:=baseAddIPSf.CloneToNewObject(true).Implementor_HC as TFRE_DB_SERVER_FUNC_DESC;
    addIPSf.AddParam.Describe('field','routers');
    addIPSf.AddParam.Describe('ipversion','ipv4');
    block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_new_ip_button'),addIPSf,true);
  end;
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'dns_block'));
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('dns'),ses,[],'',false,true);
  if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
    addIPSf:=baseAddIPSf.CloneToNewObject(true).Implementor_HC as TFRE_DB_SERVER_FUNC_DESC;
    addIPSf.AddParam.Describe('field','ien116-name-servers');
    addIPSf.AddParam.Describe('ipversion','ipv4');
    block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_new_ip_button'),addIPSf,true);
  end;

  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'dns_block'),'dns2');
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('dns'),ses,[],'dns2',false,true);
  if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
    addIPSf:=baseAddIPSf.CloneToNewObject(true).Implementor_HC as TFRE_DB_SERVER_FUNC_DESC;
    addIPSf.AddParam.Describe('field','dns2.ien116-name-servers');
    addIPSf.AddParam.Describe('ipversion','ipv4');
    block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_new_ip_button'),addIPSf,true);
  end;

  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'ntp_block'));
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('ntp'),ses,[],'',false,true);
  if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
    addIPSf:=baseAddIPSf.CloneToNewObject(true).Implementor_HC as TFRE_DB_SERVER_FUNC_DESC;
    addIPSf.AddParam.Describe('field','ntp-servers');
    addIPSf.AddParam.Describe('ipversion','ipv4');
    block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_new_ip_button'),addIPSf,true);
  end;
  group.AddSchemeFormGroup(scheme.GetInputGroup('settings'),ses,false,false,'',true,true);

  group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'dhcp_template_diag_advanced_group'),true,input.Field('advancedCollapsed').AsBoolean);

  if ses.GetSessionModuleData(ClassName).FieldExists('templateDiagData') then begin
    for i := 0 to ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field('standard').ValueCount-1 do begin
      block:=group.AddBlock.Describe(StringReplace(FetchModuleTextShort(ses,'dhcp_template_diag_standard_option_label'),'%number_str%',ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.standard').AsObjectItem[i].Field('number').AsString,[rfReplaceAll]));
      block.AddInput.Describe('',ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.standard').AsObjectItem[i].UID_String,false,false,true,false,
                              ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.standard').AsObjectItem[i].Field('value').AsString);
      opSf:=CWSF(@WEB_DeleteOption);
      opSf.AddParam.Describe('selected',input.Field('selected').AsString);
      opSf.AddParam.Describe('idx',IntToStr(i));
      opSf.AddParam.Describe('type','standard');
      block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_delete_option'),opSf,true);
    end;

    for i := 0 to ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field('custom').ValueCount-1 do begin
      group.AddInput.Describe(FetchModuleTextShort(ses,'dhcp_template_diag_custom_option_label'),ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.custom').AsObjectItem[i].UID_String+'_d',false,false,true,false,
                              ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.custom').AsObjectItem[i].Field('declaration').AsString);
      block:=group.AddBlock.Describe('','',true);
      block.AddInput.Describe('',ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.custom').AsObjectItem[i].UID_String+'_u',false,false,true,false,
                              ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.custom').AsObjectItem[i].Field('usage').AsString);
      opSf:=CWSF(@WEB_DeleteOption);
      opSf.AddParam.Describe('selected',input.Field('selected').AsString);
      opSf.AddParam.Describe('idx',IntToStr(i));
      opSf.AddParam.Describe('type','custom');
      block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_delete_option'),opSf,true);
    end;
  end;

  block:=group.AddBlock.Describe();
  opSf:=CWSF(@WEB_AddStandardOption);
  opSf.AddParam.Describe('selected',input.Field('selected').AsString);
  block.AddInputButton().Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_add_standard_option'),opSf,true);
  opSf:=CWSF(@WEB_AddCustomOption);
  opSf.AddParam.Describe('selected',input.Field('selected').AsString);
  block.AddInputButton().Describe('',FetchModuleTextShort(ses,'dhcp_template_diag_add_custom_option'),opSf,true);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  res.AddButton.Describe(FetchModuleTextShort(ses,'dhcp_template_diag_close_button'),CWSF(@WEB_CleanupTemplateDiag),fdbbt_close);

  if isModify then begin
    res.FillWithObjectValues(dbo,ses);
    if dbo.Field('ien116-name-servers').ValueCount>1 then begin
      res.SetElementValue('dns2.ien116-name-servers',FREDB_G2H(dbo.Field('ien116-name-servers').AsObjectLinkItem[1]));
    end;
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
  addSubnetSf : TFRE_DB_SERVER_FUNC_DESC;
  group       : TFRE_DB_INPUT_GROUP_DESC;
  block       : TFRE_DB_INPUT_BLOCK_DESC;
begin
  sf:=CWSF(@WEB_StoreSubnetEntry);

  addSubnetSf:=CWSF(@fSubnetIPMod.WEB_AddSubnet);
  addSubnetSf.AddParam.Describe('cbclass',self.ClassName);
  addSubnetSf.AddParam.Describe('cbuidpath',FREDB_CombineString(self.GetUIDPath,','));
  CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
  if Assigned(dbo) then begin
    isModify:=true;
    if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_SUBNET,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('entryId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'subnet_entry_modify_diag_cap');
    addSubnetSf.AddParam.Describe('cbfunc','ModifyEntry');
    addSubnetSf.AddParam.Describe('selected',dbo.UID_String);
  end else begin
    isModify:=false;
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_SUBNET,service.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,service.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,service.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,service.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('dhcpId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'subnet_entry_create_diag_cap');
    addSubnetSf.AddParam.Describe('cbfunc','AddSubnetEntry');
    addSubnetSf.AddParam.Describe('selected',service.UID_String);
  end;

  dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_SUBNET_CHOOSER_DC);
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
  dc.Filters.RemoveFilter('scheme');
  dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4_SUBNET.ClassName]);

  dc := ses.FetchDerivedCollection('DHCP_TEMPLATE_CHOOSER');
  dc.Filters.RemoveFilter('service');
  dc.Filters.AddUIDFieldFilter('service','dhcp_uid',[service.UID],dbnf_OneValueFromFilter);

  GetSystemScheme(TFRE_DB_DHCP_SUBNET,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  group:=res.AddSchemeFormGroup(scheme.GetInputGroup('general'),ses);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'subnet_block'));
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('subnet'),ses,[],'',false,true);
  if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
    addSubnetSf.AddParam.Describe('field','subnet');
    addSubnetSf.AddParam.Describe('ipversion','ipv4');
    block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_subnet_diag_new_subnet_button'),addSubnetSf,true);
  end;

  _AddModifyHandleTemplates(conn,ses,dbo,res,dc.GetStoreDescription as TFRE_DB_STORE_DESC,true);

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
  addIPSf     : TFRE_DB_SERVER_FUNC_DESC;
  group       : TFRE_DB_INPUT_GROUP_DESC;
  block       : TFRE_DB_INPUT_BLOCK_DESC;
begin
  sf:=CWSF(@WEB_StoreFixedEntry);

  addIPSf:=CWSF(@fSubnetIPMod.WEB_AddIP);
  addIPSf.AddParam.Describe('cbclass',self.ClassName);
  addIPSf.AddParam.Describe('cbuidpath',FREDB_CombineString(self.GetUIDPath,','));
  CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));
  if Assigned(dbo) then begin
    isModify:=true;
    if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_FIXED,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('entryId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'fixed_entry_modify_diag_cap');

    addIPSf.AddParam.Describe('cbfunc','ModifyEntry');
    addIPSf.AddParam.Describe('selected',dbo.UID_String);
  end else begin
    isModify:=false;
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_FIXED,service.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,service.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,service.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,service.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('dhcpId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'fixed_entry_create_diag_cap');

    addIPSf.AddParam.Describe('cbfunc','AddFixedEntry');
    addIPSf.AddParam.Describe('selected',service.UID_String);
  end;

  dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_IP_CHOOSER_DC);
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
  dc.Filters.RemoveFilter('scheme');
  dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4.ClassName]);

  dc := ses.FetchDerivedCollection('DHCP_TEMPLATE_CHOOSER');
  dc.Filters.RemoveFilter('service');
  dc.Filters.AddUIDFieldFilter('service','dhcp_uid',[service.UID],dbnf_OneValueFromFilter);

  GetSystemScheme(TFRE_DB_DHCP_FIXED,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  group:=res.AddSchemeFormGroup(scheme.GetInputGroup('general'),ses);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'ip_block'));
  block.AddSchemeFormGroupInputs(scheme.GetInputGroup('ip'),ses,[],'',false,true);
  if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
    addIPSf.AddParam.Describe('field','ip');
    addIPSf.AddParam.Describe('ipversion','ipv4');
    block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_fixed_diag_new_ip_button'),addIPSf,true);
  end;

  _AddModifyHandleTemplates(conn,ses,dbo,res,dc.GetStoreDescription as TFRE_DB_STORE_DESC,false);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    res.FillWithObjectValues(dbo,ses);
  end;

  Result:=res;
end;

procedure TFRE_FIRMBOX_DHCP_MOD._StoreHandleTemplates(const conn: IFRE_DB_CONNECTION; const input: IFRE_DB_Object; const entryObj: IFRE_DB_Object; const isModify: Boolean);
var
  i           : Integer;
  tPostFix    : String;
  coll        : IFRE_DB_COLLECTION;
  relObj      : TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION;
  relObjExists: Boolean;
  relObjs     : TFRE_DB_ObjLinkArray;
begin
  coll:=conn.GetCollection(CFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION_COLLECTION);

  relObjs:=entryObj.Field('template').AsObjectLinkArray;
  if isModify then begin
    entryObj.DeleteField('template');
    CheckDbResult(conn.Update(entryObj.CloneToNewObject));
  end;
  for i := 0 to 3 do begin
    tPostFix:=IntToStr(i);
    if Length(relObjs)>i then begin
      CheckDbResult(conn.FetchAs(relObjs[i],TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,relObj));
      relObjExists:=true;
    end else begin
      relObjExists:=false;
    end;
    if input.FieldPathExists('data.template_'+tPostFix+'.template') and not input.FieldPath('data.template_'+tPostFix+'.template').IsSpecialClearMarked then begin
      if not relObjExists then begin
        relObj:=TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION.CreateForDB;
      end;
      relObj.Field('template').AsObjectLink:=FREDB_H2G(input.FieldPath('data.template_'+tPostFix+'.template').AsString);

      if input.FieldPathExists('data.template_'+tPostFix+'.class_value') and not input.FieldPath('data.template_'+tPostFix+'.class_value').IsSpecialClearMarked then begin
        relObj.Field('class_value').AsString:=input.FieldPath('data.template_'+tPostFix+'.class_value').AsString;
        if input.FieldPathExists('data.template_'+tPostFix+'.class_type') and not input.FieldPath('data.template_'+tPostFix+'.class_type').IsSpecialClearMarked then begin
          relObj.Field('class_type').AsString:=input.FieldPath('data.template_'+tPostFix+'.class_type').AsString;
        end else begin
          relObj.Field('class_type').AsString:='user_class';
        end;
      end else begin
        if relObjExists then begin
          relObj.DeleteField('class_type');
          relObj.DeleteField('class_value');
        end;
      end;
      if relObjExists then begin
        CheckDbResult(conn.Update(relObj));
      end else begin
        CheckDbResult(coll.Store(relObj));
      end;
      entryObj.Field('template').AddObjectLink(relObj.UID);
    end else begin
      if relObjExists then begin //NO LONGER USED => DELETE
        CheckDbResult(conn.Delete(relObj.UID));
      end;
    end;
    input.Field('data').AsObject.DeleteField('template_'+tPostFix);
  end;
end;

procedure TFRE_FIRMBOX_DHCP_MOD._AddModifyHandleTemplates(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_Usersession; const dbo: IFRE_DB_Object; const res: TFRE_DB_FORM_DESC; const store: TFRE_DB_STORE_DESC; const isSubnet: Boolean);
var
  default   : String;
  defaultCV : String;
  defaultCT : String;
  i         : Integer;
  ch        : TFRE_DB_INPUT_CHOOSER_DESC;
  block     : TFRE_DB_INPUT_BLOCK_DESC;
  cstore    : TFRE_DB_STORE_DESC;
  relObj    : TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION;
  postFix   : String;
begin
  if isSubnet then begin
    cstore:=TFRE_DB_STORE_DESC.create.Describe('id');
    cstore.AddEntry.Describe(FetchModuleTextShort(ses,'template_type_user_class'),'user_class');
    cstore.AddEntry.Describe(FetchModuleTextShort(ses,'template_type_client_id'),'client_id');
  end;

  for i := 0 to 3 do begin
    if Assigned(dbo) and (dbo.Field('template').ValueCount>i) then begin
      CheckDbResult(conn.FetchAs(dbo.Field('template').AsObjectLinkItem[i],TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION,relObj));
      default:=FREDB_G2H(relObj.Field('template').AsObjectLink);
      defaultCV:=relObj.Field('class_value').AsString;
      defaultCT:=relObj.Field('class_type').AsString;
    end else begin
      default:='';
      defaultCV:='';
      defaultCT:='';
    end;
    postFix:=IntToStr(i);
    block:=res.AddBlock.Describe(FetchModuleTextShort(ses,'template_chooser_label'),'template_'+postFix);

    ch:=block.AddChooser.Describe('','template_'+postFix+'.template',store,dh_chooser_combo,false,false,true,false,default);
    if isSubnet then begin
      block.AddChooser(5).Describe('','template_'+postFix+'.class_type',cstore,dh_chooser_combo,true,false,false,false,defaultCT);
      block.AddInput(5).Describe('','template_'+postFix+'.class_value',false,false,false,false,defaultCV);
    end else begin
      block.AddInput(5).Describe(FetchModuleTextShort(ses,'template_user_class_label'),'template_'+postFix+'.class_value',false,false,false,false,defaultCV);
    end;
    if i<3 then begin
      ch.addDependentInput('template_'+IntToStr(i+1),'',fdv_hidden);
    end;
  end;
end;

procedure TFRE_FIRMBOX_DHCP_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('dhcp_description');

  fSubnetIPMod:=TFRE_FIRMBOX_SUBNET_IP_MOD.create;
  AddApplicationModule(fSubnetIPMod);
end;

class procedure TFRE_FIRMBOX_DHCP_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.2';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'dhcp_description','DHCP','DHCP','DHCP');

  end;

  if currentVersionId='0.1' then begin
    currentVersionId := '0.2';
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
    CreateModuleText(conn,'entries_grid_details','Details');
    CreateModuleText(conn,'entries_grid_details_fixed','Mac: %mac_str% IP: %ip_str%');
    CreateModuleText(conn,'entries_grid_details_subnet','Subnet: %subnet_str% Range: %range_start_str% - %range_end_str%');

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

    CreateModuleText(conn,'dhcp_general_new_ip_button','New IP');
    CreateModuleText(conn,'local_address_block','Local Address');

    CreateModuleText(conn,'template_chooser_label','Template');
    CreateModuleText(conn,'template_user_class_label','UserClass');
    CreateModuleText(conn,'template_type_user_class','UserClass');
    CreateModuleText(conn,'template_type_client_id','ClientID');

    CreateModuleText(conn,'dhcp_fixed_diag_new_ip_button','New IP');
    CreateModuleText(conn,'ip_block','IP');

    CreateModuleText(conn,'dhcp_subnet_diag_new_subnet_button','New Subnet');
    CreateModuleText(conn,'subnet_block','Subnet');

    CreateModuleText(conn,'dhcp_template_diag_new_ip_button','New IP');
    CreateModuleText(conn,'router_block','Router');
    CreateModuleText(conn,'dns_block','Name Server');
    CreateModuleText(conn,'ntp_block','NTP Server');

    CreateModuleText(conn,'dhcp_template_diag_advanced_group','Advanced');
    CreateModuleText(conn,'dhcp_template_diag_add_standard_option','Add Standard Option');
    CreateModuleText(conn,'dhcp_template_diag_add_custom_option','Add Custom Option');

    CreateModuleText(conn,'dhcp_template_diag_close_button','Close');
    CreateModuleText(conn,'dhcp_template_diag_standard_option_label','Standard Option %number_str%');
    CreateModuleText(conn,'dhcp_template_diag_custom_option_label','Custom Option');
    CreateModuleText(conn,'dhcp_template_diag_delete_option','Delete');

    CreateModuleText(conn,'dhcp_template_add_standard_option_diag_cap','Add Standard Option');
    CreateModuleText(conn,'dhcp_template_add_standard_option_number','Number');
    CreateModuleText(conn,'dhcp_template_add_standard_option_value','Value');
    CreateModuleText(conn,'dhcp_template_add_custom_option_diag_cap','Add Custom Option');
    CreateModuleText(conn,'dhcp_template_add_custom_option_declaration','Declaration');
    CreateModuleText(conn,'dhcp_template_add_custom_option_usage','Usage');
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

  procedure _setEntryDetails(const input,transformed_object : IFRE_DB_Object;const langres: TFRE_DB_StringArray);
  var
    str: String;
  begin
    if (transformed_object.Field('subnet_ip').AsString<>'') then begin
      str:=StringReplace(langres[1],'%subnet_str%',transformed_object.Field('subnet_ip').AsString + '/' + transformed_object.Field('subnet_bits').AsString,[rfReplaceAll]);
      str:=StringReplace(str,'%range_start_str%',input.Field('range_start').AsString,[rfReplaceAll]);
      str:=StringReplace(str,'%range_end_str%',input.Field('range_end').AsString,[rfReplaceAll]);
    end else begin
      str:=StringReplace(langres[0],'%mac_str%',input.Field('mac').AsString,[rfReplaceAll]);
      str:=StringReplace(str,'%ip_str%',transformed_object.Field('fixed_ip').AsString,[rfReplaceAll]);
    end;
    transformed_object.Field('details').AsString:=str;
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
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'entries_grid_objname'));
      AddMatchingReferencedFieldArray(['DHCP_ID>TFRE_DB_DHCP'],'uid','dhcp_uid','',false);
    end;

    dc := session.NewDerivedCollection('DHCP_TEMPLATE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DHCP_TEMPLATE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
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
      AddOneToOnescheme('details','',FetchModuleTextShort(session,'entries_grid_details'),dt_string);
      AddMatchingReferencedFieldArray(['SUBNET>','BASE_IP>'],'ip','subnet_ip','',false);
      AddMatchingReferencedFieldArray(['SUBNET>'],'subnet_bits','subnet_bits','',false);
      AddMatchingReferencedFieldArray(['IP>'],'ip','fixed_ip','',false);
      AddMatchingReferencedFieldArray(['DHCP_ID>TFRE_DB_DHCP'],'uid','dhcp_uid','',false);
      SetSimpleFuncTransformNested(@_setEntryDetails,[FetchModuleTextShort(session,'entries_grid_details_fixed'),FetchModuleTextShort(session,'entries_grid_details_subnet')]);
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
  group       : TFRE_DB_INPUT_GROUP_DESC;
  block       : TFRE_DB_INPUT_BLOCK_DESC;
  addIPSf     : TFRE_DB_SERVER_FUNC_DESC;

begin
  CheckClassVisibility4AnyDomain(ses);

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedDHCP') and (ses.GetSessionModuleData(ClassName).Field('selectedDHCP').ValueCount=1) then begin

    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedDHCP').AsGUID,service));

    editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_DHCP,service.DomainID);

    GetSystemScheme(TFRE_DB_DHCP,scheme);
    res:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',false,editable);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
    block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'local_address_block'));
    block.AddSchemeFormGroupInputs(scheme.GetInputGroup('local_address'),ses,[],'',false,true);
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,service.DomainID) then begin
      addIPSf:=CWSF(@fSubnetIPMod.WEB_AddIP);
      addIPSf.AddParam.Describe('cbclass',self.ClassName);
      addIPSf.AddParam.Describe('cbuidpath',FREDB_CombineString(self.GetUIDPath,','));
      addIPSf.AddParam.Describe('cbfunc','ContentGeneral');
      addIPSf.AddParam.Describe('field','local_address');
      addIPSf.AddParam.Describe('ipversion','ipv4');
      addIPSf.AddParam.Describe('selected',service.UID_String);
      block.AddInputButton(3).Describe('',FetchModuleTextShort(ses,'dhcp_general_new_ip_button'),addIPSf,true);
    end;
    group.AddSchemeFormGroup(scheme.GetInputGroup('settings'),ses,false,false,'',true,true);

    res.FillWithObjectValues(service,ses);

    dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_IP_CHOOSER_DC);
    dc.Filters.RemoveFilter('domain');
    dc.Filters.AddUIDFieldFilter('domain','domainid',service.DomainID,dbnf_OneValueFromFilter);
    dc.Filters.RemoveFilter('scheme');
    dc.filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4.ClassName]);

    dc := ses.FetchDerivedCollection(CFRE_DB_DHCP_INTERFACE_CHOOSER_DC);
    dc.Filters.RemoveFilter('zone');
    dc.Filters.AddUIDFieldFilter('zone','zuid',service.Field('serviceParent').AsObjectLink,dbnf_OneValueFromFilter);

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
  WEB_CleanupTemplateDiag(input,ses,app,conn);
  input.Field('advancedCollapsed').AsBoolean:=true;
  Result:=_AddModifyTemplate(input,ses,app,conn,false);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ModifyTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  WEB_CleanupTemplateDiag(input,ses,app,conn);
  input.Field('advancedCollapsed').AsBoolean:=true;
  Result:=_AddModifyTemplate(input,ses,app,conn,true);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreTemplate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  templateObj : TFRE_DB_DHCP_TEMPLATE;
  isNew       : Boolean;
  service     : IFRE_DB_Object;
  i: Integer;

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

  if input.FieldPathExists('data.dns2.ien116-name-servers') and not input.FieldPath('data.dns2.ien116-name-servers').IsSpecialClearMarked then begin
    input.FieldPathCreate('data.ien116-name-servers').AddString(input.FieldPath('data.dns2.ien116-name-servers').AsString);
  end;
  input.Field('data').AsObject.DeleteField('dns2');

  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,templateObj,isNew,conn);

  templateObj.DeleteField('standard_options');
  templateObj.DeleteField('custom_options');
  if ses.GetSessionModuleData(ClassName).FieldExists('templateDiagData') then begin
    for i := 0 to ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field('standard').ValueCount-1 do begin
      templateObj.Field('standard_options').AddObject(ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.standard').AsObjectItem[i].CloneToNewObject());
    end;
    for i := 0 to ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field('custom').ValueCount-1 do begin
      templateObj.Field('custom_options').AddObject(ses.GetSessionModuleData(ClassName).FieldPath('templateDiagData.custom').AsObjectItem[i].CloneToNewObject());
    end;
  end;

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

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddStandardOption(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_FORM_DIALOG_DESC;
  sf : TFRE_DB_SERVER_FUNC_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);
  ses.GetSessionModuleData(ClassName).Field('Add_templateDiagData').AsObject:=input.Field('data').AsObject.CloneToNewObject();

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'dhcp_template_add_standard_option_diag_cap'),600,false);
  res.AddNumber.Describe(FetchModuleTextShort(ses,'dhcp_template_add_standard_option_number'),'number',true,false,false,false,'',0);
  res.AddInput.Describe(FetchModuleTextShort(ses,'dhcp_template_add_standard_option_value'),'value',true);

  sf:=CWSF(@WEB_StoreStandardOption);
  sf.AddParam.Describe('selected',input.Field('selected').AsString);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  res.AddButton.Describe(FetchModuleTextShort(ses,'dhcp_template_diag_close_button'),CWSF(@WEB_CleanupAddOptionDiag),fdbbt_close);

  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreStandardOption(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj : IFRE_DB_Object;
  res : TFRE_DB_FORM_DIALOG_DESC;
begin
  obj:=GFRE_DBI.NewObject;
  obj.Field('number').AsInt32:=input.FieldPath('data.number').AsInt32;
  obj.Field('value').AsString:=input.FieldPath('data.value').AsString;
  ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field('standard').AddObject(obj);
  ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe); //CLOSE ADD
  ses.GetSessionModuleData(ClassName).Field('templateDiagRefresh').AsBoolean:=true;
  ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe); //CLOSE TEMPLATE DIAG

  input.DeleteField('data');
  input.Field('advancedCollapsed').AsBoolean:=false;
  res:=_AddModifyTemplate(input,ses,app,conn,input.Field('selected').AsString<>'').Implementor_HC as TFRE_DB_FORM_DIALOG_DESC ; //REBUILD TEMPLATE DIAG
  res.FillWithObjectValues(ses.GetSessionModuleData(ClassName).Field('Add_templateDiagData').AsObject,ses,'',false);
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddCustomOption(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_FORM_DIALOG_DESC;
  sf : TFRE_DB_SERVER_FUNC_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);
  ses.GetSessionModuleData(ClassName).Field('Add_templateDiagData').AsObject:=input.Field('data').AsObject.CloneToNewObject();

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'dhcp_template_add_custom_option_diag_cap'),600,false);
  res.AddInput.Describe(FetchModuleTextShort(ses,'dhcp_template_add_custom_option_declaration'),'declaration',true);
  res.AddInput.Describe(FetchModuleTextShort(ses,'dhcp_template_add_custom_option_usage'),'usage',true);

  sf:=CWSF(@WEB_StoreCustomOption);
  sf.AddParam.Describe('selected',input.Field('selected').AsString);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  res.AddButton.Describe(FetchModuleTextShort(ses,'dhcp_template_diag_close_button'),CWSF(@WEB_CleanupAddOptionDiag),fdbbt_close);

  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_StoreCustomOption(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj  : IFRE_DB_Object;
  res  : TFRE_DB_FORM_DIALOG_DESC;
begin
  obj:=GFRE_DBI.NewObject;
  obj.Field('declaration').AsString:=input.FieldPath('data.declaration').AsString;
  obj.Field('usage').AsString:=input.FieldPath('data.usage').AsString;
  ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field('custom').AddObject(obj);
  ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe); //CLOSE ADD
  ses.GetSessionModuleData(ClassName).Field('templateDiagRefresh').AsBoolean:=true;
  ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe); //CLOSE TEMPLATE DIAG

  input.DeleteField('data');
  input.Field('advancedCollapsed').AsBoolean:=false;
  res:=_AddModifyTemplate(input,ses,app,conn,input.Field('selected').AsString<>'').Implementor_HC as TFRE_DB_FORM_DIALOG_DESC ; //REBUILD TEMPLATE DIAG
  res.FillWithObjectValues(ses.GetSessionModuleData(ClassName).Field('Add_templateDiagData').AsObject,ses,'',false);
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_DeleteOption(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res  : TFRE_DB_FORM_DIALOG_DESC;
begin
  ses.GetSessionModuleData(ClassName).Field('templateDiagData').AsObject.Field(input.Field('type').AsString).RemoveObject(input.Field('idx').AsInt32);

  ses.GetSessionModuleData(ClassName).Field('templateDiagRefresh').AsBoolean:=true;
  ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe); //CLOSE TEMPLATE DIAG

  input.Field('advancedCollapsed').AsBoolean:=false;
  res:=_AddModifyTemplate(input,ses,app,conn,input.Field('selected').AsString<>'').Implementor_HC as TFRE_DB_FORM_DIALOG_DESC ; //REBUILD TEMPLATE DIAG
  res.FillWithObjectValues(input.Field('data').AsObject,ses,'',false);
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_CleanupTemplateDiag(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if ses.GetSessionModuleData(ClassName).FieldExists('templateDiagRefresh') then begin
    ses.GetSessionModuleData(ClassName).DeleteField('templateDiagRefresh');
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('templateDiagData');
  end;
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_CleanupAddOptionDiag(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  ses.GetSessionModuleData(ClassName).DeleteField('Add_templateDiagData');
  Result:=GFRE_DB_NIL_DESC;
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

  _StoreHandleTemplates(conn,input,entryObj,not isNew);

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

  _StoreHandleTemplates(conn,input,entryObj,not isNew);

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

