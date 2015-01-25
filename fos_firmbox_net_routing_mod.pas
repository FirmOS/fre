unit fos_firmbox_net_routing_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fre_hal_schemes,fre_dbbusiness,fre_zfs;

type

{ TFRE_FIRMBOX_NET_ROUTING_MOD }

  TFRE_FIRMBOX_NET_ROUTING_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _getDetails                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):TFRE_DB_CONTENT_DESC;
    function        _getZoneDetails            (const zone: TFRE_DB_ZONE;const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):TFRE_DB_CONTENT_DESC;
    function        _canDelete                 (const input:IFRE_DB_Object; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _canDelegate               (const input:IFRE_DB_Object; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _canDelegate               (const input:IFRE_DB_Object; const conn: IFRE_DB_CONNECTION; var dbo: IFRE_DB_Object):Boolean;
    function        _canAddVNIC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _canAddVNIC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; var dbo: IFRE_DB_Object):Boolean;
    procedure       _canAddHostnet             (const input:IFRE_DB_Object; const conn: IFRE_DB_CONNECTION; var ipv4,ipv6: Boolean);
    procedure       _canAddHostnet             (const input:IFRE_DB_Object; const conn: IFRE_DB_CONNECTION; var ipv4,ipv6: Boolean; var dbo: IFRE_DB_Object);
    function        _delegateRightsCheck       (const zDomainId: TFRE_DB_GUID; const serviceClass: ShortString; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _getZone                   (const dbo: IFRE_DB_Object; const conn: IFRE_DB_CONNECTION): TFRE_DB_ZONE;
    procedure       _updateDatalinkGridTB      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION);
  protected
    procedure       SetupAppModuleStructure    ; override;
  public
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects           (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects       (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    procedure       CalcZoneChooserLabel       (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
    procedure       CalculateIcon              (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_Add                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Store                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Delete                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteConfirmed        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridMenu               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridSC                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkGridSC         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkGridMenu       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Delegate               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreDelegation        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddVNIC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreVNIC              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddHostnet             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreHostnet           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    //function        WEB_IFSC                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    //function        WEB_ContentIF              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    //function        WEB_SliderChanged          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_NET_ROUTING_MOD);
end;

{ TFRE_FIRMBOX_NET_ROUTING_MOD }

function TFRE_FIRMBOX_NET_ROUTING_MOD._getDetails(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): TFRE_DB_CONTENT_DESC;
var
  res   : TFRE_DB_CONTENT_DESC;
  dbo   : IFRE_DB_Object;
  hcObj : TObject;
  form: TFRE_DB_FORM_PANEL_DESC;
  scheme: IFRE_DB_SchemeObject;
begin
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    hcObj:=dbo.Implementor_HC;
    if (hcObj is TFRE_DB_ZONE) then begin
      res:=_getZoneDetails(hcObj as TFRE_DB_ZONE,input,ses,app,conn);
    end else begin
      form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,false);
      GFRE_DBI.GetSystemSchemeByName(dbo.Implementor_HC.ClassName,scheme);
      form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      form.FillWithObjectValues(dbo,ses);

      res:=form;
    end;
  end else begin
    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_details_select_one'));
  end;
  res.contentId:='netRoutingDetails';
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._getZoneDetails(const zone: TFRE_DB_ZONE; const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): TFRE_DB_CONTENT_DESC;
var
  res          : TFRE_DB_VIEW_LIST_DESC;
  dc           : IFRE_DB_DERIVED_COLLECTION;
  menu         : TFRE_DB_MENU_DESC;
  canAdd       : Boolean;
  template     : TFRE_DB_FBZ_TEMPLATE;
  i            : Integer;
  serviceClass : String;
  exClass      : TFRE_DB_ObjectClassEx;
  conf         : IFRE_DB_Object;
  sf           : TFRE_DB_SERVER_FUNC_DESC;
  submenu      : TFRE_DB_SUBMENU_DESC;
  canDelete    : Boolean;
  canDelegate  : Boolean;
  isGlobal     : Boolean;
  canAddHostnet: Boolean;
  canAddVNIC   : Boolean;
begin
  CheckClassVisibility4MyDomain(ses);
  isGlobal:=(zone is TFRE_DB_GLOBAL_ZONE);

  ses.GetSessionModuleData(ClassName).DeleteField('selected');
  ses.GetSessionModuleData(ClassName).Field('selectedZoneId').AsString:=zone.UID_String;

  if isGlobal then begin
    dc:=ses.FetchDerivedCollection('DATALINK_GRID_GZ');
  end else begin
    dc:=ses.FetchDerivedCollection('DATALINK_GRID');
  end;
  dc.Filters.RemoveFilter('zone');
  dc.Filters.AddRootNodeFilter('zone','uid',conn.GetReferences(zone.UID,false,'','datalinkParent'),dbnf_OneValueFromFilter);
  res:=dc.GetDisplayDescription.Implementor_HC as TFRE_DB_VIEW_LIST_DESC;

  canAdd:=false;
  canDelete:=false;
  canDelegate:=false;
  menu:=TFRE_DB_MENU_DESC.create.Describe;
  submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_add'),'');

  CheckDbResult(conn.FetchAs(zone.Field('templateid').AsObjectLink,TFRE_DB_FBZ_TEMPLATE,template));

  for i := 0 to template.Field('serviceclasses').ValueCount -1 do begin
    serviceClass:=template.Field('serviceclasses').AsStringArr[i];
    if serviceClass=TFRE_DB_DATALINK_VNIC.ClassName then continue;
    exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
    conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
    if conf.Field('type').AsString='datalink' then begin
      canDelete:=canDelete or conn.SYS.CheckClassRight4DomainId(sr_DELETE,serviceClass,zone.DomainID);
      canDelegate:=isGlobal and (canDelegate or _delegateRightsCheck(zone.DomainID,serviceClass,conn));
      if conn.SYS.CheckClassRight4DomainId(sr_STORE,serviceClass,zone.DomainID) then begin
        canAdd:=true;
        sf:=CWSF(@WEB_Add);
        sf.AddParam.Describe('serviceClass',serviceClass);
        sf.AddParam.Describe('zoneId',zone.UID_String);
        submenu.AddEntry.Describe(conf.Field('caption').AsString,'',sf,false,'add_'+serviceClass);
      end;
    end;
  end;
  canAddHostnet:=conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_IPV4_HOSTNET) or conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_IPV6_HOSTNET);
  canAddVNIC:=conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DATALINK_VNIC,zone.DomainID);

  if canAdd or canDelete or canDelegate or canAddVNIC or canAddHostnet then begin
    if not canAdd then begin
      menu:=TFRE_DB_MENU_DESC.create.Describe;
    end;
    if canDelete then begin
      menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_delete'),'',CWSF(@WEB_Delete),true,'net_routing_delete');
    end;
    if canDelegate then begin
      menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_delegate'),'',CWSF(@WEB_Delegate),true,'net_routing_delegate');
    end;
    if canAddVNIC then begin
      menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_vnic'),'',CWSF(@WEB_AddVNIC),true,'net_routing_add_vnic');
    end;
    if canAddHostnet then begin
      submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_add_hostnet'),'');
      if conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_IPV4_HOSTNET) then begin
        sf:=CWSF(@WEB_AddHostnet);
        sf.AddParam.Describe('serviceClass',TFRE_DB_IPV4_HOSTNET.ClassName);
        submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_hostnet_ipv4'),'',sf,true,'net_routing_add_ipv4');
      end;
      if conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_IPV6_HOSTNET) then begin
        sf:=CWSF(@WEB_AddHostnet);
        sf.AddParam.Describe('serviceClass',TFRE_DB_IPV6_HOSTNET.ClassName);
        submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_hostnet_ipv6'),'',sf,true,'net_routing_add_ipv6');
      end;
    end;
    res.SetMenu(menu);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._canDelete(const input: IFRE_DB_Object; const conn: IFRE_DB_CONNECTION): Boolean;
var
  dbo: IFRE_DB_Object;
begin
  Result:=false;
  if (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    Result:=conn.sys.CheckClassRight4DomainId(sr_DELETE,dbo.Implementor_HC.ClassType,dbo.DomainID) and (conn.GetReferencesCount(dbo.UID,false)=0);
  end;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._canDelegate(const input: IFRE_DB_Object; const conn: IFRE_DB_CONNECTION): Boolean;
var
  dbo  : IFRE_DB_Object;
begin
  Result:=_canDelegate(input,conn,dbo);
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._canDelegate(const input: IFRE_DB_Object; const conn: IFRE_DB_CONNECTION; var dbo: IFRE_DB_Object): Boolean;
var
  hcObj: TObject;
begin
  Result:=false;
  if (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.GetReferencesCount(dbo.UID,true,'TFRE_DB_ZONE','datalinkParent')>0 then begin
      exit; //already delegated
    end;
    hcObj:=dbo.Implementor_HC;
    if (hcObj is TFRE_DB_DATALINK_PHYS) or (hcObj is TFRE_DB_DATALINK_SIMNET) then begin //only if empty
      if (conn.GetReferencesCount(dbo.UID,false,'TFRE_DB_DATALINK_VNIC','datalinkParent')=0) and (conn.GetReferencesCount(dbo.UID,true,'TFRE_DB_DATALINK_AGGR','datalinkParent')=0) then begin
        Result:=_delegateRightsCheck(dbo.DomainID,hcObj.ClassName,conn);
      end;
    end else
    if hcObj is TFRE_DB_DATALINK_AGGR then begin
      Result:=_delegateRightsCheck(dbo.DomainID,TFRE_DB_DATALINK_AGGR.ClassName,conn) and
              _delegateRightsCheck(dbo.DomainID,TFRE_DB_DATALINK_PHYS.ClassName,conn) and
              _delegateRightsCheck(dbo.DomainID,TFRE_DB_DATALINK_SIMNET.ClassName,conn);
    end else
    if hcObj is TFRE_DB_DATALINK_VNIC then begin
      Result:=_delegateRightsCheck(dbo.DomainID,TFRE_DB_DATALINK_VNIC.ClassName,conn);
    end;
  end;
  Result:=Result and _delegateRightsCheck(dbo.DomainID,TFRE_DB_IPV4_HOSTNET.ClassName,conn) and _delegateRightsCheck(dbo.DomainID,TFRE_DB_IPV6_HOSTNET.ClassName,conn);
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._canAddVNIC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
var
  dbo  : IFRE_DB_Object;
begin
  Result:=_canAddVNIC(input,ses,conn,dbo);
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._canAddVNIC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; var dbo: IFRE_DB_Object): Boolean;
var
  zone     : TFRE_DB_ZONE;
  parentDbo: IFRE_DB_Object;
begin
  Result:=false;
  if (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DATALINK_VNIC,dbo.DomainID) then exit;

    if dbo.Implementor_HC is TFRE_DB_DATALINK_VNIC then begin
      exit; //vinc can not be added to a vinc
    end;

    CheckDbResult(conn.Fetch(dbo.Field('datalinkParent').AsObjectLinkArray[0],parentDbo));
    if parentDbo.Implementor_HC is TFRE_DB_DATALINK_AGGR then begin
      exit; //vnic has to be added on the aggregation
    end;

    CheckDbResult(conn.FetchAs(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedZoneId').AsString),TFRE_DB_ZONE,zone));
    if (zone is TFRE_DB_GLOBAL_ZONE) and (conn.GetReferencesCount(dbo.UID,true,'TFRE_DB_ZONE','datalinkParent')>0) then begin
      exit; //delegated interface - vnic has to be added there
    end;
  end;
  Result:=true;
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD._canAddHostnet(const input: IFRE_DB_Object; const conn: IFRE_DB_CONNECTION; var ipv4, ipv6: Boolean);
var
  dbo  : IFRE_DB_Object;
begin
  _canAddHostnet(input,conn,ipv4,ipv6,dbo);
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD._canAddHostnet(const input: IFRE_DB_Object; const conn: IFRE_DB_CONNECTION; var ipv4, ipv6: Boolean; var dbo: IFRE_DB_Object);
var
  parentDbo: IFRE_DB_Object;
begin
  ipv4:=false;
  ipv6:=false;
  if (input.Field('selected').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    CheckDbResult(conn.Fetch(dbo.Field('datalinkParent').AsObjectLinkArray[0],parentDbo));
    if parentDbo.Implementor_HC is TFRE_DB_DATALINK_AGGR then begin
      exit; //hostnet has to be added on the aggregation
    end;

    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_HOSTNET,dbo.DomainID) then begin
      ipv4:=true;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV6_HOSTNET,dbo.DomainID) then begin
      ipv6:=true;
    end;
  end;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._delegateRightsCheck(const zDomainId: TFRE_DB_GUID; const serviceClass: ShortString; const conn: IFRE_DB_CONNECTION): Boolean;
var
  ddomains: TFRE_DB_GUIDArray;
  i       : Integer;
begin
  Result:=false;
  if conn.SYS.CheckClassRight4DomainId(sr_DELETE,serviceClass,zDomainId) then begin
    ddomains:=conn.SYS.GetDomainsForClassRight(sr_STORE,serviceClass);
    for i := 0 to High(ddomains) do begin
      if ddomains[i]<>zDomainId then begin
        Result:=true;
        break;
      end;
    end;
  end;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD._getZone(const dbo: IFRE_DB_Object; const conn:IFRE_DB_CONNECTION): TFRE_DB_ZONE;
var
  parentObj : IFRE_DB_Object;
  parentUids: TFRE_DB_ObjLinkArray;
begin
  parentObj:=dbo;
  repeat
    parentUids:=parentObj.Field('datalinkParent').AsObjectLinkArray;
    CheckDbResult(conn.Fetch(parentUids[0],parentObj));
    if (parentObj.Implementor_HC is TFRE_DB_GLOBAL_ZONE) and (Length(parentUids)>1) then begin //in case of 2 parents the other one should be a client zone
      CheckDbResult(conn.Fetch(parentUids[1],parentObj));
    end;
  until parentObj.Implementor_HC is TFRE_DB_ZONE;
  Result:=parentObj.Implementor_HC as TFRE_DB_ZONE;
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD._updateDatalinkGridTB(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION);
var
  delDisabled     : Boolean;
  delegateDisabled: Boolean;
  vnicDisabled    : Boolean;
  ipv4Enabled     : Boolean;
  ipv6Enabled     : Boolean;
begin
  delDisabled:=true;
  delegateDisabled:=true;
  vnicDisabled:=true;
  ipv4Enabled:=false;
  ipv6Enabled:=false;
  if ses.GetSessionModuleData(ClassName).FieldExists('selected') then begin
    input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selected').AsStringArr;
    delDisabled:=not _canDelete(input,conn);
    delegateDisabled:=not _canDelegate(input,conn);
    vnicDisabled:=not _canAddVNIC(input,ses,conn);
    _canAddHostnet(input,conn,ipv4Enabled,ipv6Enabled);
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('net_routing_delete',delDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('net_routing_delegate',delegateDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('net_routing_add_vnic',vnicDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('net_routing_add_ipv4',not ipv4Enabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('net_routing_add_ipv6',not ipv6Enabled));
end;

class procedure TFRE_FIRMBOX_NET_ROUTING_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('net_routing_description')
end;

class procedure TFRE_FIRMBOX_NET_ROUTING_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'net_routing_description','Networks','Networks','Networks');

    CreateModuleText(conn,'grid_name','Name');
    CreateModuleText(conn,'grid_delegation_zone','Delegated to');

    CreateModuleText(conn,'tb_add','Add');
    CreateModuleText(conn,'tb_delete','Delete');
    CreateModuleText(conn,'tb_delegate','Delegate');
    CreateModuleText(conn,'cm_delete','Delete');
    CreateModuleText(conn,'cm_delegate','Delegate');
    CreateModuleText(conn,'tb_add_vnic','Add VNIC');
    CreateModuleText(conn,'cm_add_vnic','Add VNIC');
    CreateModuleText(conn,'tb_add_hostnet','Add Hostnet');
    CreateModuleText(conn,'tb_add_hostnet_ipv4','IPv4');
    CreateModuleText(conn,'tb_add_hostnet_ipv6','IPv6');
    CreateModuleText(conn,'cm_add_hostnet_ipv4','Add IPv4');
    CreateModuleText(conn,'cm_add_hostnet_ipv6','Add IPv6');

    CreateModuleText(conn,'info_details_select_one','Please select an object to get detailed information about it.');

    CreateModuleText(conn,'add_datalink_diag_cap','Add %datalink_str%');
    CreateModuleText(conn,'add_vnic_diag_cap','Add VNIC');
    CreateModuleText(conn,'add_hostnet_diag_cap','Add hostnet');

    CreateModuleText(conn,'datalink_create_error_exists_cap','Error: Add datalink');
    CreateModuleText(conn,'datalink_create_error_exists_msg','A %datalink_str% datalink with the given name already exists!');
    CreateModuleText(conn,'vnic_create_error_exists_cap','Error: Add VNIC');
    CreateModuleText(conn,'vnic_create_error_exists_msg','A VNIC with the given name already exists within this zone!');
    CreateModuleText(conn,'hostnet_create_error_exists_cap','Error: Add Hostnet');
    CreateModuleText(conn,'hostnet_create_error_exists_msg','A hostnet with the given properties already exists!');

    CreateModuleText(conn,'delete_datalink_diag_cap','Remove Datalink');
    CreateModuleText(conn,'delete_datalink_diag_msg','Remove datalink "%datalink_str%"?');
    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');

    CreateModuleText(conn,'delegate_datalink_diag_cap','Delegate Interface');
    CreateModuleText(conn,'delegate_datalink_diag_no_zone_msg','There are no zones available for delgation.');
    CreateModuleText(conn,'delegate_datalink_diag_zone','Zone');
    CreateModuleText(conn,'delegate_interface_zone_value','%zone_str% (%customer_str%)');
    CreateModuleText(conn,'delegate_interface_zone_value_no_customer','%zone_str%');
  end;
end;

class procedure TFRE_FIRMBOX_NET_ROUTING_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  inherited InstallUserDBObjects(conn, currentVersionId);
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  dc       : IFRE_DB_DERIVED_COLLECTION;
  i        : Integer;
  filterClasses: TFRE_DB_StringArray;
  hFilterClasses: TFRE_DB_StringArray;

  procedure _setSortOrder(const input,transformed_object : IFRE_DB_Object);
  begin
    if input.IsA(TFRE_DB_GLOBAL_ZONE) then begin
      transformed_object.Field('_sortorder_').AsString:='A'+input.Field('objname').AsString;
    end else begin
      transformed_object.Field('_sortorder_').AsString:='B'+input.Field('objname').AsString;
    end;
  end;


begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_name'),dt_string,true,false,false,1,'icon');
      AddOneToOnescheme('_sortorder_','','',dt_string,false);
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_description,false,false,1,'','',nil,false,'domainid');
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      AddOneToOnescheme('icon','','',dt_string,false);
      SetSimpleFuncTransformNested(@_setSortOrder);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
    end;
    dc := session.NewDerivedCollection('NET_ZONES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_GridSC));
      SetParentToChildLinkField ('<SERVICEPARENT',[TFRE_DB_ZFS_POOL.ClassName,TFRE_DB_ZFS_DATASET_FILE.ClassName,TFRE_DB_ZFS_DATASET_PARENT.ClassName],[],[TFRE_DB_GLOBAL_ZONE.ClassName,TFRE_DB_ZONE.ClassName]);
      Filters.AddSchemeObjectFilter('schemes',[TFRE_DB_DATACENTER.ClassName,TFRE_DB_MACHINE.ClassName,TFRE_DB_ZFS_POOL.ClassName,TFRE_DB_GLOBAL_ZONE.ClassName,TFRE_DB_ZONE.ClassName]);
      SetDefaultOrderField('_sortorder_',true);
    end;

    filterClasses:=TFRE_DB_DATALINK.getAllDataLinkClasses;
    hFilterClasses:=TFRE_DB_IP_HOSTNET.getAllHostnetClasses;
    for i := 0 to High(hFilterClasses) do begin
      SetLength(filterClasses,Length(filterClasses)+1);
      filterClasses[Length(filterClasses)-1]:=hFilterClasses[i];
    end;
    SetLength(filterClasses,Length(filterClasses)+2);
    filterClasses[Length(filterClasses)-2]:=TFRE_DB_ZONE.ClassName;
    filterClasses[Length(filterClasses)-1]:=TFRE_DB_GLOBAL_ZONE.ClassName;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_name'),dt_string,true,false,false,1,'icon');
      AddMatchingReferencedField(['DATALINKPARENT>TFRE_DB_ZONE'],'objname','czone',FetchModuleTextShort(session,'grid_delegation_zone'),true,dt_string);
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      AddOneToOnescheme('serviceparent','','',dt_string,false);
      AddOneToOnescheme('icon','','',dt_string,false);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
    end;
    dc := session.NewDerivedCollection('DATALINK_GRID_GZ');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',CWSF(@WEB_DatalinkGridMenu),nil,CWSF(@WEB_DatalinkGridSC));
      SetParentToChildLinkField ('<DATALINKPARENT',[TFRE_DB_GLOBAL_ZONE.ClassName,TFRE_DB_ZONE.ClassName]);
      Filters.AddSchemeObjectFilter('schemes',filterClasses);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_name'),dt_string,true,false,false,1,'icon');
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      AddOneToOnescheme('serviceparent','','',dt_string,false);
      AddOneToOnescheme('icon','','',dt_string,false);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
    end;
    dc := session.NewDerivedCollection('DATALINK_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',CWSF(@WEB_DatalinkGridMenu),nil,CWSF(@WEB_DatalinkGridSC));
      SetParentToChildLinkField ('<DATALINKPARENT',[TFRE_DB_GLOBAL_ZONE.ClassName,TFRE_DB_ZONE.ClassName]);
      Filters.AddSchemeObjectFilter('schemes',filterClasses);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('hostid');
      SetFinalRightTransformFunction(@CalcZoneChooserLabel,[FetchModuleTextShort(session,'delegate_interface_zone_value'),FetchModuleTextShort(session,'delegate_interface_zone_value_no_customer')]);
    end;
    dc := session.NewDerivedCollection('ZONE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('scheme',[TFRE_DB_GLOBAL_ZONE.ClassName],false);
      Filters.AddStdClassRightFilter('rightsip4','domainid','','',TFRE_DB_IPV4_HOSTNET.ClassName,[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
      Filters.AddStdClassRightFilter('rightsip6','domainid','','',TFRE_DB_IPV4_HOSTNET.ClassName,[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
    end;

  end;
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD.CalcZoneChooserLabel(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
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

procedure TFRE_FIRMBOX_NET_ROUTING_MOD.CalculateIcon(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
begin
  transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/classicons/'+LowerCase(transformed_object.Field('sc').AsString)+'.svg');
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_LAYOUT_DESC;
  grid      : TFRE_DB_VIEW_LIST_DESC;
  content   : TFRE_DB_CONTENT_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selected');

  grid:=ses.FetchDerivedCollection('NET_ZONES_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(grid,_getDetails(input,ses,app,conn),nil,nil,nil,true,1,2);
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_Add(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zone        : TFRE_DB_ZONE;
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  serviceClass: shortstring;
  exClass     : TFRE_DB_ObjectClassEx;
  conf        : IFRE_DB_Object;
begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));
  serviceClass:=input.Field('serviceClass').AsString;
  if not conn.SYS.CheckClassRight4DomainId(sr_STORE,serviceClass,zone.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
  conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(StringReplace(FetchModuleTextShort(ses,'add_datalink_diag_cap'),'%datalink_str%',conf.Field('caption').AsString,[rfReplaceAll]),600);
  GFRE_DBI.GetSystemSchemeByName(serviceClass,scheme);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  sf:=CWSF(@WEB_Store);
  sf.AddParam.Describe('zoneId',zone.UID_String);
  sf.AddParam.Describe('serviceClass',serviceClass);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_Store(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  zone        : TFRE_DB_ZONE;
  dbo         : IFRE_DB_Object;
  coll        : IFRE_DB_COLLECTION;
  exClass     : TFRE_DB_ObjectClassEx;
  conf        : IFRE_DB_Object;
  serviceClass: TFRE_DB_String;
  idx         : String;
  vdc         : IFRE_DB_DERIVED_COLLECTION;
  parentObj: IFRE_DB_Object;
begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));
  if not conn.SYS.CheckClassRight4DomainId(sr_STORE,input.Field('serviceClass').AsString,zone.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldPathExists('data.objname') then
    raise EFRE_DB_Exception.Create('Missing input parameter objname!');

  serviceClass:=input.Field('serviceClass').AsString;
  exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
  conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
  idx:=serviceClass + '_' + input.FieldPath('data.objname').AsString + '@' + zone.UID_String;
  coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  if coll.ExistsIndexedText(idx)<>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'datalink_create_error_exists_cap'),StringReplace(FetchModuleTextShort(ses,'datalink_create_error_exists_msg'),'%datalink_str%',conf.Field('caption').AsString,[rfReplaceAll]),fdbmt_error);
    exit;
  end;

  GFRE_DBI.GetSystemSchemeByName(serviceClass,scheme);
  dbo:=GFRE_DBI.NewObjectSchemeByName(serviceClass);
  dbo.Field('serviceParent').AsObjectLink:=zone.UID;
  dbo.Field('datalinkParent').AsObjectLink:=zone.UID;
  dbo.Field('uniquephysicalid').AsString:=idx;
  dbo.SetDomainID(zone.DomainID);
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,dbo,true,conn);

  CheckDbResult(coll.Store(dbo));
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_Delete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg     : String;
  dbo         : IFRE_DB_Object;
begin
  if not input.FieldExists('selected') then begin
    input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selected').AsStringArr;
  end;
  if not _canDelete(input,conn) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_DeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'delete_datalink_diag_cap');

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),dbo));
  msg:=StringReplace(FetchModuleTextShort(ses,'delete_datalink_diag_msg'),'%datalink_str%',dbo.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_DeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i           : NativeInt;
  service     : TFRE_DB_SERVICE;
  serviceClass: String;
  oospz       : Boolean;
begin
  if not _canDelete(input,conn) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsStringArr[i]),TFRE_DB_SERVICE,service));
      serviceClass:=service.ClassName;
      oospz:=service.OnlyOneServicePerZone;
      CheckDbResult(conn.Delete(service.UID));
      if oospz then begin
        ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_'+serviceClass,false));
      end;
    end;
  end;
  ses.GetSessionModuleData(ClassName).DeleteField('selected');
  _updateDatalinkGridTB(input,ses,app,conn);
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_GridMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_GridSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_getDetails(input,ses,app,conn);
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_DatalinkGridSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if input.FieldExists('selected') then begin
    ses.GetSessionModuleData(ClassName).Field('selected').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selected');
  end;
  _updateDatalinkGridTB(input,ses,app,conn);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_DatalinkGridMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res        : TFRE_DB_MENU_DESC;
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  ipv4Enabled: Boolean;
  ipv6Enabled: Boolean;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if _canDelete(input,conn) then begin
    sf:=CWSF(@WEB_Delete);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete'),'',sf);
  end;
  if _canDelegate(input,conn) then begin
    sf:=CWSF(@WEB_Delegate);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delegate'),'',sf);
  end;
  if _canAddVNIC(input,ses,conn) then begin
    sf:=CWSF(@WEB_AddVNIC);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_add_vnic'),'',sf);
  end;
  _canAddHostnet(input,conn,ipv4Enabled,ipv6Enabled);
  if ipv4Enabled then begin
    sf:=CWSF(@WEB_AddHostnet);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    sf.AddParam.Describe('seviceClass',TFRE_DB_IPV4_HOSTNET.ClassName);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_add_hostnet_ipv4'),'',sf);
  end;
  if ipv6Enabled then begin
    sf:=CWSF(@WEB_AddHostnet);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    sf.AddParam.Describe('seviceClass',TFRE_DB_IPV6_HOSTNET.ClassName);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_add_hostnet_ipv6'),'',sf);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_Delegate(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res      : TFRE_DB_FORM_DIALOG_DESC;
  dc       : IFRE_DB_DERIVED_COLLECTION;
  dbo      : IFRE_DB_Object;
  zone     : TFRE_DB_ZONE;
  sf       : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not input.FieldExists('selected') then begin
    input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selected').AsStringArr;
  end;
  if not _canDelegate(input,conn,dbo) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  zone:=_getZone(dbo,conn);

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'delegate_datalink_diag_cap'));
  dc:=ses.FetchDerivedCollection('ZONE_CHOOSER');
  dc.Filters.RemoveFilter('machine');
  dc.Filters.RemoveFilter('rights');
  dc.Filters.RemoveFilter('rightsPH');
  dc.Filters.RemoveFilter('rightsSIM');
  dc.Filters.AddAutoDependencyFilter('machine',['<HOSTID'],[zone.Field('hostid').AsObjectLink]);
  dc.Filters.AddStdClassRightFilter('rights','domainid','','',dbo.Implementor_HC.ClassName,[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
  if dbo.Implementor_HC is TFRE_DB_DATALINK_AGGR then begin
    dc.Filters.AddStdClassRightFilter('rightsPH','domainid','','',TFRE_DB_DATALINK_PHYS.ClassName,[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
    dc.Filters.AddStdClassRightFilter('rightsSIM','domainid','','',TFRE_DB_DATALINK_SIMNET.ClassName,[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
  end;

  if dc.ItemCount=0 then begin
    res.AddDescription.Describe('',FetchModuleTextShort(ses,'delegate_datalink_diag_no_zone_msg'));
  end else begin
    res.AddChooser.Describe(FetchModuleTextShort(ses,'delegate_datalink_diag_zone'),'dzone',dc.GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC);
    sf:=CWSF(@WEB_StoreDelegation);
    sf.AddParam.Describe('selected',dbo.UID_String);
    res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_StoreDelegation(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zone    : TFRE_DB_ZONE;
  dbo     : IFRE_DB_Object;
  refs    : TFRE_DB_GUIDArray;
  i       : Integer;
  datalink: IFRE_DB_Object;

  procedure _handleHostnets(const parentDbo: IFRE_DB_Object; const newDomainId: TFRE_DB_GUID);
  var
    i      : Integer;
    hostnet: IFRE_DB_Object;
    refs   : TFRE_DB_GUIDArray;
  begin
    refs:=conn.GetReferences(parentDbo.UID,false,'','datalinkParent');
    for i := 0 to High(refs) do begin
      CheckDbResult(conn.Fetch(refs[i],hostnet));
      hostnet.SetDomainID(newDomainId);
      CheckDbResult(conn.Update(hostnet));
    end;
  end;

begin
  if not _canDelegate(input,conn,dbo) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldPathExists('data.dzone') then
    raise EFRE_DB_Exception.Create('Missing input parameter zone!');

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.FieldPath('data.dzone').AsString),TFRE_DB_ZONE,zone));

  if dbo.DomainID<>zone.DomainID then begin
    dbo.SetDomainID(zone.DomainID);
    if dbo.Implementor_HC is TFRE_DB_DATALINK_AGGR then begin
      refs:=conn.GetReferences(dbo.UID,false,'','datalinkParent');
      for i := 0 to High(refs) do begin //handle datalinks of the aggregation
        CheckDbResult(conn.Fetch(refs[i],datalink));
        datalink.SetDomainID(zone.DomainID);
        CheckDbResult(conn.Update(datalink.CloneToNewObject()));
        _handleHostnets(datalink,zone.DomainID);
      end;
    end else begin
      _handleHostnets(dbo,zone.DomainID);
    end;
  end;
  dbo.Field('datalinkParent').AddObjectLink(zone.UID);
  dbo.Field('serviceParent').AddObjectLink(zone.UID);

  CheckDbResult(conn.Update(dbo));
  _updateDatalinkGridTB(input,ses,app,conn);
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_AddVNIC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  dbo         : IFRE_DB_Object;
begin
  if not input.FieldExists('selected') then begin
    input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selected').AsStringArr;
  end;
  if not _canAddVNIC(input,ses,conn,dbo) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_vnic_diag_cap'),600);
  GFRE_DBI.GetSystemSchemeByName(TFRE_DB_DATALINK_VNIC.ClassName,scheme);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  sf:=CWSF(@WEB_StoreVNIC);
  sf.AddParam.Describe('selected',dbo.UID_String);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_StoreVNIC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  zone        : TFRE_DB_ZONE;
  dbo         : IFRE_DB_Object;
  coll        : IFRE_DB_COLLECTION;
  idx         : String;
  vnic        : TFRE_DB_DATALINK_VNIC;
begin
  if not _canAddVNIC(input,ses,conn,dbo) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldPathExists('data.objname') then
    raise EFRE_DB_Exception.Create('Missing input parameter objname!');

  zone:=_getZone(dbo,conn);
  idx:=TFRE_DB_DATALINK_VNIC.ClassName + '_' + input.FieldPath('data.objname').AsString + '@' + zone.UID_String;
  coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  if coll.ExistsIndexedText(idx)<>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vnic_create_error_exists_cap'),FetchModuleTextShort(ses,'vnic_create_error_exists_msg'),fdbmt_error);
    exit;
  end;

  GFRE_DBI.GetSystemSchemeByName(TFRE_DB_DATALINK_VNIC.ClassName,scheme);
  vnic:=TFRE_DB_DATALINK_VNIC.CreateForDB;
  vnic.Field('serviceParent').AsObjectLink:=dbo.UID;
  vnic.Field('datalinkParent').AsObjectLink:=dbo.UID;
  vnic.SetDomainID(dbo.DomainID);
  vnic.Field('uniquephysicalid').AsString:=idx;
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,vnic,true,conn);

  CheckDbResult(coll.Store(vnic));

  _updateDatalinkGridTB(input,ses,app,conn);
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;
function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_AddHostnet(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  dbo         : IFRE_DB_Object;
  ipv4Enabled : Boolean;
  ipv6Enabled : Boolean;
  serviceClass: TFRE_DB_String;
begin
  if not input.FieldExists('selected') then begin
    input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selected').AsStringArr;
  end;

  _canAddHostnet(input,conn,ipv4Enabled,ipv6Enabled,dbo);

  serviceClass:=input.Field('serviceClass').AsString;
  if not ((ipv4Enabled and (serviceClass=TFRE_DB_IPV4_HOSTNET.ClassName)) or (ipv6Enabled and (serviceClass=TFRE_DB_IPV6_HOSTNET.ClassName))) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_hostnet_diag_cap'),600);
  GFRE_DBI.GetSystemSchemeByName(serviceClass,scheme);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  sf:=CWSF(@WEB_StoreHostnet);
  sf.AddParam.Describe('selected',dbo.UID_String);
  sf.AddParam.Describe('serviceClass',serviceClass);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_StoreHostnet(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  ipv4Enabled : Boolean;
  ipv6Enabled : Boolean;
  scheme      : IFRE_DB_SchemeObject;
  dbo         : IFRE_DB_Object;
  coll        : IFRE_DB_COLLECTION;
  serviceClass: TFRE_DB_String;
  idx         : String;
  hostnet     : IFRE_DB_Object;
begin
  _canAddHostnet(input,conn,ipv4Enabled,ipv6Enabled,dbo);

  serviceClass:=input.Field('serviceClass').AsString;
  if not ((ipv4Enabled and (serviceClass=TFRE_DB_IPV4_HOSTNET.ClassName)) or (ipv6Enabled and (serviceClass=TFRE_DB_IPV6_HOSTNET.ClassName))) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  serviceClass:=input.Field('serviceClass').AsString;
  GFRE_DBI.GetSystemSchemeByName(serviceClass,scheme);
  hostnet:=GFRE_DBI.NewObjectSchemeByName(serviceClass);
  if input.FieldPathExists('data.dhcp') and input.FieldPath('data.dhcp').AsBoolean then begin
    hostnet.Field('objname').AsString:='DHCP';
  end else
  if input.FieldPathExists('data.slaac') and input.FieldPath('data.slaac').AsBoolean then begin
    hostnet.Field('objname').AsString:='SLAAC';
  end else
  if input.FieldPathExists('data.ip_net') then begin
    hostnet.Field('objname').AsString:=input.FieldPath('data.ip_net').AsString;
  end;

  if hostnet.Field('objname').AsString='' then
    raise EFRE_DB_Exception.Create('Missing input parameters (dhcp=true or slaac=true or ip_net<>'') to create objname!');

  idx:=serviceClass + '_' + hostnet.Field('objname').AsString + '@' + dbo.UID_String;
  coll:=conn.GetCollection(CFRE_DB_IP_COLLECTION);
  if coll.ExistsIndexedText(idx)<>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'hostnet_create_error_exists_cap'),FetchModuleTextShort(ses,'hostnet_create_error_exists_msg'),fdbmt_error);
    exit;
  end;

  hostnet.Field('serviceParent').AsObjectLink:=dbo.UID;
  hostnet.Field('datalinkParent').AsObjectLink:=dbo.UID;
  hostnet.Field('uniquephysicalid').AsString:=idx;
  hostnet.SetDomainID(dbo.DomainID);
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,hostnet,true,conn);

  CheckDbResult(coll.Store(hostnet));
  _updateDatalinkGridTB(input,ses,app,conn);
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

//function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_IFSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
//begin
//  CheckClassVisibility4AnyDomain(ses);
//
//  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
//    ses.GetSessionModuleData(ClassName).Field('selectedIF').AsStringArr:=input.Field('selected').AsStringArr;
//  end else begin
//    ses.GetSessionModuleData(ClassName).DeleteField('selectedIF');
//  end;
//
//  Result:=WEB_ContentIF(input,ses,app,conn);
//end;
//
//function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_ContentIF(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
//var
//  res   : TFRE_DB_CONTENT_DESC;
//  ifObj : IFRE_DB_Object;
//  form  : TFRE_DB_FORM_PANEL_DESC;
//  scheme: IFRE_DB_SchemeObject;
//  slider: TFRE_DB_FORM_PANEL_DESC;
//  group : TFRE_DB_INPUT_GROUP_DESC;
//begin
//  if ses.GetSessionModuleData(ClassName).FieldExists('selectedIF') and (ses.GetSessionModuleData(ClassName).Field('selectedIF').ValueCount=1) then begin
//    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedIF').AsStringItem[0]),ifObj));
//
//    //editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,ifObj.Implementor_HC.ClassType,ifObj.DomainID);
//
//    if not GFRE_DBI.GetSystemScheme(ifObj.Implementor_HC.ClassType,scheme) then
//      raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[ifObj.Implementor_HC.ClassType]);
//
//    form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,false);
//    form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
//    form.FillWithObjectValues(ifObj,ses);
//
//    if (ifObj.Field('type').AsString='internet') then begin
//      slider:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,true,CWSF(@WEB_SliderChanged),500);
//      slider.contentId:='slider_form';
//      group:=slider.AddGroup.Describe(FetchModuleTextShort(ses,'bandwidth_group'));
//      group.AddNumber.DescribeSlider('','slider',10,100,true,'20',0,10);
//
//      res:=TFRE_DB_LAYOUT_DESC.create.Describe().SetAutoSizedLayout(nil,form,nil,slider);
//    end else begin
//      res:=form;
//    end;
//  end else begin
//    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_if_details_select_one'));
//  end;
//
//  res.contentId:='IF_DETAILS';
//  Result:=res;
//end;
//
//function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_SliderChanged(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
//var machineid : TFRE_DB_GUID;
//    inp,opd    : IFRE_DB_Object;
//
//   procedure GotAnswer(const ses: IFRE_DB_UserSession; const new_input: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const ocid: Qword; const opaquedata: IFRE_DB_Object);
//   var
//     res     : TFRE_DB_CONTENT_DESC;
//     i       : NativeInt;
//     cnt     : NativeInt;
//     newnew  : IFRE_DB_Object;
//
//   begin
//     case status of
//       cdcs_OK:
//         begin
////           res:=TFRE_DB_MESSAGE_DESC.create.Describe('BW','SETUP OK',fdbmt_info);
//           res := GFRE_DB_NIL_DESC;
//         end;
//       cdcs_TIMEOUT:
//         begin
//           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COMMUNICATION TIMEOUT SET BW',fdbmt_error); { FIXXME }
//         end;
//       cdcs_ERROR:
//         begin
//           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT SET BW ['+new_input.Field('ERROR').AsString+']',fdbmt_error); { FIXXME }
//         end;
//     end;
//     ses.SendServerClientAnswer(res,ocid);
//     cnt := 0;
//   end;
//
//
//begin
//  writeln('SWL: SLIDER CHANGED', input.DumpToString);
//  inp := GFRE_DBI.NewObject;
//  inp.Field('BW').Asstring :=input.field('SLIDER').asstring;
//  if ses.InvokeRemoteRequestMachineMac('00:25:90:82:bf:ae','TFRE_BOX_FEED_CLIENT','UPDATEBANDWIDTH',inp,@GotAnswer,nil)=edb_OK then  //FIXXME
//    begin
//      Result := GFRE_DB_SUPPRESS_SYNC_ANSWER;
//      exit;
//    end
//  else
//    begin
//      Result := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT SET BANDWIDTH',fdbmt_error); { FIXXME }
//      inp.Finalize;
//    end
//end;

end.

