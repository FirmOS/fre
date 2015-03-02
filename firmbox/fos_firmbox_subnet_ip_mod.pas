unit fos_firmbox_subnet_ip_mod;

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

{ TFRE_FIRMBOX_SUBNET_IP_MOD }

  TFRE_FIRMBOX_SUBNET_IP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _getStoreResult             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const newObj: IFRE_DB_Object): IFRE_DB_Object;
  protected
    procedure       SetupAppModuleStructure     ; override;
  public
    class procedure RegisterSystemScheme        (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule   (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_AddIP                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreIP                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddSubnet               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreSubnet             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_CleanupAdd              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_SUBNET_IP_MOD);
end;

{ TFRE_FIRMBOX_SUBNET_IP_MOD }

class procedure TFRE_FIRMBOX_SUBNET_IP_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

function TFRE_FIRMBOX_SUBNET_IP_MOD._getStoreResult(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const newObj: IFRE_DB_Object): IFRE_DB_Object;
var
  newInput : IFRE_DB_Object;
  cbuidpath: TFRE_DB_StringArray;
  res      : TFRE_DB_FORM_DESC;
begin
  //SET INTO DATA
  ses.GetSessionModuleData(ClassName).Field('Add_sourceDiagData').AsObject.FieldPath(input.Field('field').AsString).AsString:=newObj.UID_String;
  //CLOSE ADD DIALOG
  ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe());

  Result:=GFRE_DB_NIL_DESC;

  //CREATE SOURCE
  newInput:=GFRE_DBI.NewObject;
  newInput.Field('selected').AsString:=input.Field('selected').AsString;
  FREDB_SeperateString(input.Field('cbuidpath').AsString,',',cbuidpath);

  res:=ses.InternalSessInvokeMethod(input.Field('cbclass').AsString,input.Field('cbfunc').AsString,FREDB_StringArray2UidArray(cbuidpath),newInput).Implementor_HC as TFRE_DB_FORM_DESC;
  if res.Implementor_HC is TFRE_DB_FORM_DIALOG_DESC then begin
    ses.SendServerClientRequest(TFRE_DB_CLOSE_DIALOG_DESC.create.Describe()); //CLOSE SOURCE DIALOG
  end;

  res.FillWithObjectValues(ses.GetSessionModuleData(ClassName).Field('Add_sourceDiagData').AsObject,ses,'',false);
  Result:=res;
  WEB_CleanupAdd(input,ses,app,conn);
end;

procedure TFRE_FIRMBOX_SUBNET_IP_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('subnet_ip_description')
end;

class procedure TFRE_FIRMBOX_SUBNET_IP_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'subnet_ip_description','Subnet/IP','Subnet/IP','Subnet/IP');

    CreateModuleText(conn,'add_ipv4_diag_caption','New IPv4');
    CreateModuleText(conn,'add_ipv6_diag_caption','New IPv6');

    CreateModuleText(conn,'add_ip_diag_subnet_chooser_new','New');
    CreateModuleText(conn,'add_ip_diag_subnet','Subnet');
    CreateModuleText(conn,'add_ip_diag_new_subnet_label','');
    CreateModuleText(conn,'add_ip_diag_new_subnet_base_ip','Base IP');
    CreateModuleText(conn,'add_ip_diag_new_subnet_subnet_bits','Subnet');
    CreateModuleText(conn,'add_ip_diag_ip','IP');
    CreateModuleText(conn,'add_ip_diag_close_button','Close');

    CreateModuleText(conn,'ip_store_error_exists_cap','Error');
    CreateModuleText(conn,'ip_store_error_exists_msg','Error: The given IP already exists!');
    CreateModuleText(conn,'ip_store_error_base_exists_wrong_type_cap','Error');
    CreateModuleText(conn,'ip_store_error_base_exists_wrong_type_msg','Error: The given Base IP already exists and is not declared as Base IP!');
  end;
  CreateModuleText(conn,'add_ipv4_subnet_diag_caption','New IPv4 Subnet');
  CreateModuleText(conn,'add_ipv6_subnet_diag_caption','New IPv6 Subnet');

  CreateModuleText(conn,'add_subnet_diag_base_ip','Base IP');
  CreateModuleText(conn,'add_subnet_diag_subnet_bits','Subnet');
  CreateModuleText(conn,'add_subnet_diag_close_button','Close');
end;

procedure TFRE_FIRMBOX_SUBNET_IP_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app          : TFRE_DB_APPLICATION;
  conn         : IFRE_DB_CONNECTION;
  transform    : IFRE_DB_SIMPLE_TRANSFORM;
  dc           : IFRE_DB_DERIVED_COLLECTION;
  servicesGrid : IFRE_DB_DERIVED_COLLECTION;

begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

  end;
end;

function TFRE_FIRMBOX_SUBNET_IP_MOD.WEB_AddIP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res           : TFRE_DB_FORM_DIALOG_DESC;
  sf            : TFRE_DB_SERVER_FUNC_DESC;
  dbo           : IFRE_DB_Object;
  store         : TFRE_DB_STORE_DESC;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  block         : TFRE_DB_INPUT_BLOCK_DESC;
  validator     : IFRE_DB_ClientFieldValidator;
  chooser       : TFRE_DB_INPUT_CHOOSER_DESC;
  maxSubnetBits : Integer;
begin
  sf:=CWSF(@WEB_StoreIP);

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
  sf.AddParam.Describe('selected',input.Field('selected').AsString);
  sf.AddParam.Describe('ipversion',input.Field('ipversion').AsString);
  sf.AddParam.Describe('field',input.Field('field').AsString);
  sf.AddParam.Describe('cbclass',input.Field('cbclass').AsString);
  sf.AddParam.Describe('cbfunc',input.Field('cbfunc').AsString);
  sf.AddParam.Describe('cbuidpath',input.Field('cbuidpath').AsString);

  ses.GetSessionModuleData(ClassName).Field('Add_sourceDiagData').AsObject:=input.Field('data').AsObject.CloneToNewObject();

  dc:=ses.FetchDerivedCollection('FIREWALL_SUBNET_CHOOSER_DC');
  dc.Filters.RemoveFilter('domain');
  dc.Filters.AddUIDFieldFilter('domain','domainid',[dbo.DomainID],dbnf_OneValueFromFilter);
  dc.Filters.RemoveFilter('scheme');

  if input.Field('ipversion').AsString='ipv4' then begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_ipv4_diag_caption'),600,false,true,false);
    dc.Filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV4_SUBNET.ClassName,TFRE_DB_IPV4_SUBNET_DEFAULT.ClassName]);
    GFRE_DBI.GetSystemClientFieldValidator('ip',validator);
    maxSubnetBits:=32;
  end else begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_ipv6_diag_caption'),600,false,true,false);
    dc.Filters.AddSchemeObjectFilter('scheme',[TFRE_DB_IPV6_SUBNET.ClassName,TFRE_DB_IPV6_SUBNET_DEFAULT.ClassName]);
    GFRE_DBI.GetSystemClientFieldValidator('ipv6',validator);
    maxSubnetBits:=128;
  end;

  store:=dc.GetStoreDescription as TFRE_DB_STORE_DESC;
  store.AddEntry.Describe(FetchModuleTextShort(ses,'add_ip_diag_subnet_chooser_new'),'_new_');
  chooser:=res.AddChooser.Describe(FetchModuleTextShort(ses,'add_ip_diag_subnet'),'subnet',store,dh_chooser_combo,true,false,true);
  chooser.addDependentInput('new_subnet_block','_new_',fdv_visible);
  block:=res.AddBlock.Describe(FetchModuleTextShort(ses,'add_ip_diag_new_subnet_label'),'new_subnet_block');
  block.AddInput(10).Describe(FetchModuleTextShort(ses,'add_ip_diag_new_subnet_base_ip'),'base_ip',true,true,false,false,'',validator);
  block.AddNumber(5).Describe(FetchModuleTextShort(ses,'add_ip_diag_new_subnet_subnet_bits'),'subnet_bits',true,true,false,false,'',0,TFRE_DB_Real64Array.create(0,maxSubnetBits));

  res.AddInput.Describe(FetchModuleTextShort(ses,'add_ip_diag_ip'),'ip',true,true,false,false,'',validator);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  res.AddButton.Describe(FetchModuleTextShort(ses,'add_ip_diag_close_button'),CWSF(@WEB_CleanupAdd),fdbbt_close);
  Result:=res;
end;

function TFRE_FIRMBOX_SUBNET_IP_MOD.WEB_StoreIP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_FORM_DESC;
  dbo       : IFRE_DB_Object;
  subnet    : TFRE_DB_IP_SUBNET;
  baseIp    : TFRE_DB_IP;
  ipcoll    : IFRE_DB_COLLECTION;
  ipDbo     : IFRE_DB_ObjectArray;
  IP        : TFRE_DB_IP;
  isIP4     : Boolean;
  cbuidpath : TFRE_DB_StringArray;
  newInput  : IFRE_DB_Object;
begin
  if input.FieldExists('selected') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('parentId').AsString),dbo));
  end;

  if input.Field('ipversion').AsString='ipv4' then begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isIP4:=true;
  end else begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isIP4:=false;
  end;

  ipcoll:=conn.GetCollection(CFRE_DB_IP_COLLECTION);

  if ipcoll.GetIndexedObjsFieldval(input.FieldPath('data.ip'),ipDbo,'def',FREDB_G2H(dbo.DomainID))>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'ip_store_error_exists_cap'),FetchModuleTextShort(ses,'ip_store_error_exists_msg'),fdbmt_error);
    exit;
  end;

  if input.FieldPath('data.subnet').AsString='_new_' then begin
    //create new subnet
    if isIP4 then begin
      subnet:=TFRE_DB_IPV4_SUBNET.CreateForDB;
    end else begin
      subnet:=TFRE_DB_IPV6_SUBNET.CreateForDB;
    end;
    subnet.SetDomainID(dbo.DomainID);
    subnet.Field('subnet_bits').AsInt16:=input.FieldPath('data.subnet_bits').AsInt16;
    CheckDbResult(conn.GetCollection(CFRE_DB_SUBNET_COLLECTION).Store(subnet.CloneToNewObject()));

    if ipcoll.GetIndexedObjsFieldval(input.FieldPath('data.base_ip'),ipDbo,'def',FREDB_G2H(dbo.DomainID))>0 then begin
      if ipDbo[0].Field('ip_type').AsString<>'BASE' then begin
        Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'ip_store_error_base_exists_wrong_type_cap'),FetchModuleTextShort(ses,'ip_store_error_base_exists_wrong_type_msg'),fdbmt_error);
        exit;
      end;
      baseIp:=ipDbo[0].Implementor_HC as TFRE_DB_IP;
    end else begin
      if isIP4 then begin
        baseIp:=TFRE_DB_IPV4.CreateForDB;
      end else begin
        baseIp:=TFRE_DB_IPV6.CreateForDB;
      end;
      baseIp.SetDomainID(dbo.DomainID);
      baseIp.Field('ip').AsString:=input.FieldPath('data.base_ip').AsString;
      baseIp.ObjectName:=baseIp.Field('ip').AsString;
      baseIp.Field('subnet').AsObjectLink:=subnet.UID;
      baseIp.Field('ip_type').AsString:='BASE';
      CheckDbResult(ipcoll.Store(baseIp.CloneToNewObject()));
    end;

    subnet.Field('base_ip').AsObjectLink:=baseIp.UID;
    subnet.ObjectName:=baseIp.Field('ip').AsString + '/' + subnet.Field('subnet_bits').AsString;
    CheckDbResult(conn.Update(subnet.CloneToNewObject));
  end else begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.FieldPath('data.subnet').AsString),TFRE_DB_IP_SUBNET,subnet));
  end;

  if isIP4 then begin
    IP:=TFRE_DB_IPV4.CreateForDB;
  end else begin
    IP:=TFRE_DB_IPV6.CreateForDB;
  end;
  IP.SetDomainID(dbo.DomainID);
  IP.Field('ip').AsString:=input.FieldPath('data.ip').AsString;
  IP.ObjectName:=IP.Field('ip').AsString;
  IP.Field('subnet').AsObjectLink:=subnet.UID;
  IP.Field('ip_type').AsString:='IP';
  CheckDbResult(ipcoll.Store(IP.CloneToNewObject()));

  Result:=_getStoreResult(input,ses,app,conn,IP);
end;

function TFRE_FIRMBOX_SUBNET_IP_MOD.WEB_CleanupAdd(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  ses.GetSessionModuleData(ClassName).DeleteField('Add_sourceDiagData');
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_SUBNET_IP_MOD.WEB_AddSubnet(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res           : TFRE_DB_FORM_DIALOG_DESC;
  sf            : TFRE_DB_SERVER_FUNC_DESC;
  validator     : IFRE_DB_ClientFieldValidator;
  maxSubnetBits : Integer;
  dbo           : IFRE_DB_Object;

begin
  sf:=CWSF(@WEB_StoreSubnet);

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
  sf.AddParam.Describe('selected',input.Field('selected').AsString);
  sf.AddParam.Describe('ipversion',input.Field('ipversion').AsString);
  sf.AddParam.Describe('field',input.Field('field').AsString);
  sf.AddParam.Describe('cbclass',input.Field('cbclass').AsString);
  sf.AddParam.Describe('cbfunc',input.Field('cbfunc').AsString);
  sf.AddParam.Describe('cbuidpath',input.Field('cbuidpath').AsString);

  ses.GetSessionModuleData(ClassName).Field('Add_sourceDiagData').AsObject:=input.Field('data').AsObject.CloneToNewObject();


  if input.Field('ipversion').AsString='ipv4' then begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_ipv4_subnet_diag_caption'),600,false,true,false);
    GFRE_DBI.GetSystemClientFieldValidator('ip',validator);
    maxSubnetBits:=32;
  end else begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_ipv6_subnet_diag_caption'),600,false,true,false);
    GFRE_DBI.GetSystemClientFieldValidator('ipv6',validator);
    maxSubnetBits:=128;
  end;

  res.AddInput.Describe(FetchModuleTextShort(ses,'add_subnet_diag_base_ip'),'base_ip',true,true,false,false,'',validator);
  res.AddNumber.Describe(FetchModuleTextShort(ses,'add_subnet_diag_subnet_bits'),'subnet_bits',true,true,false,false,'',0,TFRE_DB_Real64Array.create(0,maxSubnetBits));

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  res.AddButton.Describe(FetchModuleTextShort(ses,'add_subnet_diag_close_button'),CWSF(@WEB_CleanupAdd),fdbbt_close);
  Result:=res;
end;

function TFRE_FIRMBOX_SUBNET_IP_MOD.WEB_StoreSubnet(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dbo       : IFRE_DB_Object;
  subnet    : TFRE_DB_IP_SUBNET;
  baseIp    : TFRE_DB_IP;
  ipcoll    : IFRE_DB_COLLECTION;
  ipDbo     : IFRE_DB_ObjectArray;
  isIP4     : Boolean;
begin
  if input.FieldExists('selected') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('parentId').AsString),dbo));
  end;

  if input.Field('ipversion').AsString='ipv4' then begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isIP4:=true;
  end else begin
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6,dbo.DomainID) and
            conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6_SUBNET,dbo.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isIP4:=false;
  end;

  ipcoll:=conn.GetCollection(CFRE_DB_IP_COLLECTION);

  if isIP4 then begin
    subnet:=TFRE_DB_IPV4_SUBNET.CreateForDB;
  end else begin
    subnet:=TFRE_DB_IPV6_SUBNET.CreateForDB;
  end;
  subnet.SetDomainID(dbo.DomainID);
  subnet.Field('subnet_bits').AsInt16:=input.FieldPath('data.subnet_bits').AsInt16;
  CheckDbResult(conn.GetCollection(CFRE_DB_SUBNET_COLLECTION).Store(subnet.CloneToNewObject()));

  if ipcoll.GetIndexedObjsFieldval(input.FieldPath('data.base_ip'),ipDbo,'def',FREDB_G2H(dbo.DomainID))>0 then begin
    if ipDbo[0].Field('ip_type').AsString<>'BASE' then begin
      Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'ip_store_error_base_exists_wrong_type_cap'),FetchModuleTextShort(ses,'ip_store_error_base_exists_wrong_type_msg'),fdbmt_error);
      exit;
    end;
    baseIp:=ipDbo[0].Implementor_HC as TFRE_DB_IP;
  end else begin
    if isIP4 then begin
      baseIp:=TFRE_DB_IPV4.CreateForDB;
    end else begin
      baseIp:=TFRE_DB_IPV6.CreateForDB;
    end;
    baseIp.SetDomainID(dbo.DomainID);
    baseIp.Field('ip').AsString:=input.FieldPath('data.base_ip').AsString;
    baseIp.ObjectName:=baseIp.Field('ip').AsString;
    baseIp.Field('subnet').AsObjectLink:=subnet.UID;
    baseIp.Field('ip_type').AsString:='BASE';
    CheckDbResult(ipcoll.Store(baseIp.CloneToNewObject()));
  end;

  subnet.Field('base_ip').AsObjectLink:=baseIp.UID;
  subnet.ObjectName:=baseIp.Field('ip').AsString + '/' + subnet.Field('subnet_bits').AsString;
  CheckDbResult(conn.Update(subnet.CloneToNewObject));

  Result:=_getStoreResult(input,ses,app,conn,subnet);
end;

end.

