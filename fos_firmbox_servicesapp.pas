unit fos_firmbox_servicesapp;

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
  FRE_DB_COMMON,
  fre_system,
  fre_zfs,fre_hal_schemes,
  fos_firmbox_vm_machines_mod;

type

  { TFOS_FIRMBOX_SERVICES_APP }

  TFOS_FIRMBOX_SERVICES_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure     ; override;
    procedure       _UpdateSitemap                (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize           (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion            (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme          (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects              (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain       (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    class procedure InstallUserDBObjects          (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_FIRMBOX_MANAGED_SERVICES_MOD }

  TFOS_FIRMBOX_MANAGED_SERVICES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    function        _getServiceContent                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):TFRE_DB_CONTENT_DESC;
    function        _getPoolCount                       (const conn: IFRE_DB_CONNECTION; const machineId: TFRE_DB_GUID; var pool:TFRE_DB_ZFS_POOL; const store: TFRE_DB_STORE_DESC): Integer;
    function        _hasPool                            (const conn: IFRE_DB_CONNECTION; const machineId: TFRE_DB_GUID): Boolean;
  public
    VM: TFRE_FIRMBOX_VM_MACHINES_MOD;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    function        GetToolbarMenu                      (const ses: IFRE_DB_Usersession): TFRE_DB_CONTENT_DESC; override;
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentNoSel                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentMultiSel                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentUnknownSel               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentDomainSel                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentZoneSel                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddVM                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddNAS                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddDNS                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddZone                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ServicesMenu                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ServicesSC                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_MANAGED_SERVICES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_MACHINES_MOD);

  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_SERVICES_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_FIRMBOX_MANAGED_SERVICES_MOD }

class procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('managed_services_description')
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD._getServiceContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): TFRE_DB_CONTENT_DESC;
var
  res               : TFRE_DB_CONTENT_DESC;
  subsec            : TFRE_DB_SUBSECTIONS_DESC;
  serviceObj        : IFRE_DB_Object;
  addServiceDisabled: Boolean;
  addZoneDisabled   : Boolean;
  machineId         : TFRE_DB_GUID;
  hlt               : boolean;
  addDNSDisabled    : Boolean;
  addNASDisabled    : Boolean;
  zone              : TFRE_DB_ZONE;
  pool              : TFRE_DB_ZFS_POOL;

begin
  addServiceDisabled:=true;
  addDNSDisabled:=true;
  addNASDisabled:=true;
  addZoneDisabled:=true;
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedService') then begin
    if ses.GetSessionModuleData(ClassName).Field('selectedService').ValueCount=1 then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),serviceObj));
      if serviceObj.IsA('TFRE_DB_SERVICE_DOMAIN') then begin
        machineId:=serviceObj.Field('serviceParent').AsObjectLink;

        addZoneDisabled:=not _hasPool(conn,machineId);
        subsec:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe;
        subsec.AddSection.Describe(CWSF(@WEB_ContentDomainSel),FetchModuleTextShort(ses,'domain_sel_general_tab'),1);
        res:=subsec;
      end else
      if serviceObj.IsA(TFRE_DB_ZONE,zone) then begin
        addServiceDisabled:=false;
        if not zone.hasNAS(conn) then begin
          addNASDisabled:=false;
        end;
        if not zone.hasDNS(conn) then begin
          addDNSDisabled:=false;
        end;
        subsec:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe;
        subsec.AddSection.Describe(CWSF(@WEB_ContentZoneSel),FetchModuleTextShort(ses,'zone_sel_general_tab'),1);
        res:=subsec;
      end else
      if serviceObj.IsA('TFRE_DB_VMACHINE') then begin
        input.Field('selectedVM').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedService').AsStringItem[0];
        res:=VM.WEB_VM_Details(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC;
      end else begin
        subsec:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe;
        subsec.AddSection.Describe(CWSF(@WEB_ContentUnknownSel),FetchModuleTextShort(ses,'unknown_sel_general_tab'),1);
        res:=subsec;
      end;
    end else begin
      subsec:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe;
      subsec.AddSection.Describe(CWSF(@WEB_ContentMultiSel),FetchModuleTextShort(ses,'multi_sel_general_tab'),1);
      res:=subsec;
    end;
  end else begin
    subsec:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe;
    subsec.AddSection.Describe(CWSF(@WEB_ContentNoSel),FetchModuleTextShort(ses,'no_sel_general_tab'),1);
    res:=subsec;
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_service',addServiceDisabled));
  if not addServiceDisabled then begin
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_service_nas',addNASDisabled));
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_service_dns',addDNSDisabled));
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_zone',addZoneDisabled));
  res.contentId:='SERVICE_DETAILS';
  Result:=res;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD._getPoolCount(const conn: IFRE_DB_CONNECTION; const machineId: TFRE_DB_GUID; var pool:TFRE_DB_ZFS_POOL; const store: TFRE_DB_STORE_DESC): Integer;
var
  poolCount: NativeInt;
  coll     : IFRE_DB_COLLECTION;

  procedure _getPools(const obj:IFRE_DB_Object);
  var
    poolObj: TFRE_DB_ZFS_POOL;
  begin
    if obj.IsA(TFRE_DB_ZFS_POOL,poolObj) then begin
      if not poolObj.getIsNew and (poolObj.MachineID=machineId) then begin
        poolCount:=poolCount+1;
        if Assigned(store) then store.AddEntry.Describe(poolObj.caption,poolObj.UID_String);
        pool:=poolObj;
      end;
    end;
  end;

begin
  poolCount:=0;
  coll:=conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  coll.ForAll(@_getPools);
  Result:=poolCount;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD._hasPool(const conn: IFRE_DB_CONNECTION; const machineId: TFRE_DB_GUID): Boolean;
var
  coll     : IFRE_DB_COLLECTION;
  hlt      : Boolean;

  procedure _checkPools(const obj:IFRE_DB_Object; var halt:Boolean);
  var
    poolObj: TFRE_DB_ZFS_POOL;
  begin
    if obj.IsA(TFRE_DB_ZFS_POOL,poolObj) then begin
      if not poolObj.getIsNew and (poolObj.MachineID=machineId) then begin
        Result:=true;
        halt:=true;
      end;
    end;
  end;

begin
  Result:=false;
  coll:=conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  coll.ForAllBreak(@_checkPools,hlt);
end;

procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  grid     : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('displayname','displayname',FetchModuleTextShort(session,'grid_managed_services_name'),dt_string,true,true);
    end;
    grid := session.NewDerivedCollection('MANAGED_SERVICES_GRID');
    with grid do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_MACHINE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',nil,'',CWSF(@WEB_ServicesMenu),nil,CWSF(@WEB_ServicesSC));
      SetParentToChildLinkField ('<SERVICEPARENT');
      SetDefaultOrderField('displayname',true);
    end;
  end;
end;

class procedure TFOS_FIRMBOX_MANAGED_SERVICES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';

    CreateModuleText(conn,'grid_managed_services_name','Name');

    CreateModuleText(conn,'no_sel_general_tab','General');
    CreateModuleText(conn,'multi_sel_general_tab','General');
    CreateModuleText(conn,'unknown_sel_general_tab','General');

    CreateModuleText(conn,'zone_sel_general_tab','General');
    CreateModuleText(conn,'domain_sel_general_tab','General');

    CreateModuleText(conn,'no_sel_general_content','Please select a service to get detailed information about it.');
    CreateModuleText(conn,'multi_sel_general_content','Please select exactly one service to get detailed information about it.');
    CreateModuleText(conn,'unknown_sel_general_content','No detailed information available for %service_name%.');
    CreateModuleText(conn,'domain_sel_general_content','No detailed information available for %domain_name%.');

    CreateModuleText(conn,'zone_panel_cap','Properties');

    CreateModuleText(conn,'tb_add_zone','Add Zone');
    CreateModuleText(conn,'cb_add_zone','Add Zone');

    CreateModuleText(conn,'tb_add_service','Add Service');
    CreateModuleText(conn,'tb_add_service_vm','Virtual Machine');
    CreateModuleText(conn,'tb_add_service_nas','Virtual NAS');
    CreateModuleText(conn,'tb_add_service_dns','DNS Server');
    CreateModuleText(conn,'cb_add_service_vm','Add Virtual Machine');
    CreateModuleText(conn,'cb_add_service_nas','Add Virtual NAS');
    CreateModuleText(conn,'cb_add_service_dns','Add DNS Server');

    CreateModuleText(conn,'add_zone_diag_cap','Add Zone');
    CreateModuleText(conn,'add_zone_diag_location_group','Pools');
    CreateModuleText(conn,'add_zone_diag_pool','Pool');
    CreateModuleText(conn,'add_nas_diag_cap','Add NAS');
    CreateModuleText(conn,'add_dns_diag_cap','Add DNS');

  end;
   
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetToolbarMenu(const ses: IFRE_DB_Usersession): TFRE_DB_CONTENT_DESC;
var
  res    : TFRE_DB_MENU_DESC;
  submenu: TFRE_DB_SUBMENU_DESC;
  hasMenu: Boolean;
  conn   : IFRE_DB_CONNECTION;
begin
  conn:=ses.GetDBConnection;
  hasMenu:=false;
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE)) or
     (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DNS)) or
     (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NAS)) then begin
    hasMenu:=true;
    submenu:=res.AddMenu.Describe(FetchModuleTextShort(ses,'tb_add_service'),'',true,'add_service');
    if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE)) then begin
      submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_service_vm'),'',CWSF(@WEB_AddVM));
    end;
    if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NAS)) then begin
      submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_service_nas'),'',CWSF(@WEB_AddNAS),true,'add_service_nas');
    end;
    if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DNS)) then begin
      submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_service_dns'),'',CWSF(@WEB_AddDNS),true,'add_service_dns');
    end;
  end;
  if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZONE)) then begin
    hasMenu:=true;
    res.AddEntry.Describe(FetchModuleTextShort(ses,'tb_add_zone'),'',CWSF(@WEB_AddZone),true,'add_zone');
  end;
  if hasMenu then begin;
    Result:=res;
  end else begin
    Result:=nil;
  end;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc  : IFRE_DB_DERIVED_COLLECTION;
  grid: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);
  ses.GetSessionModuleData(ClassName).DeleteField('selectedService');

  dc:=ses.FetchDerivedCollection('MANAGED_SERVICES_GRID');
  grid:=dc.GetDisplayDescription().Implementor_HC as TFRE_DB_VIEW_LIST_DESC;

  Result:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(grid,_getServiceContent(input,ses,app,conn));
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ContentNoSel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  Result:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'no_sel_general_content'));
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ContentMultiSel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  Result:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'multi_sel_general_content'));
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ContentUnknownSel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  serviceObj: IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),serviceObj));
  Result:=TFRE_DB_HTML_DESC.create.Describe(StringReplace(FetchModuleTextShort(ses,'unknown_sel_general_content'),'%service_name%',serviceObj.Field('objname').AsString,[rfReplaceAll]));
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ContentDomainSel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  serviceObj: IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),serviceObj));
  Result:=TFRE_DB_HTML_DESC.create.Describe(StringReplace(FetchModuleTextShort(ses,'domain_sel_general_content'),'%domain_name%',serviceObj.Field('objname').AsString,[rfReplaceAll]));
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ContentZoneSel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme : IFRE_DB_SchemeObject;
  res    : TFRE_DB_FORM_PANEL_DESC;
  zoneObj: IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_DB_ZONE)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),zoneObj));

  GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZONE',scheme);
  res:=TFRE_DB_FORM_PANEL_DESC.create.Describe(FetchModuleTextShort(ses,'zone_panel_cap'),true,conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZONE));
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  res.FillWithObjectValues(zoneObj,ses);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CSFT('saveOperation',zoneObj),fdbbt_submit);
  Result:=res;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_AddVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('zoneId').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedService').AsString;
  Result:=VM.WEB_NewVM(input,ses,app,conn);
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_AddNAS(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme    : IFRE_DB_SchemeObject;
  zoneObj   : IFRE_DB_Object;
  res       : TFRE_DB_FORM_DIALOG_DESC;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NAS)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),zoneObj));
  if (zoneObj.Implementor_HC as TFRE_DB_ZONE).hasNAS(conn) then
    raise EFRE_DB_Exception.Create('The given Zone has already a NAS service');

  GFRE_DBI.GetSystemSchemeByName('TFRE_DB_NAS',scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_nas_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  res.AddInput.Describe('','serviceParent',false,false,false,true,ses.GetSessionModuleData(ClassName).Field('selectedService').AsString);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CSCF('TFRE_DB_NAS','newOperation','collection',CFOS_DB_SERVICES_COLLECTION),fdbbt_submit);
  Result:=res;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_AddDNS(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme    : IFRE_DB_SchemeObject;
  zoneObj   : IFRE_DB_Object;
  res       : TFRE_DB_FORM_DIALOG_DESC;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DNS)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),zoneObj));
  if (zoneObj.Implementor_HC as TFRE_DB_ZONE).hasDNS(conn) then
    raise EFRE_DB_Exception.Create('The given Zone has already a DNS service');

  GFRE_DBI.GetSystemSchemeByName('TFRE_DB_DNS',scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_dns_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  res.AddInput.Describe('','serviceParent',false,false,false,true,ses.GetSessionModuleData(ClassName).Field('selectedService').AsString);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CSCF('TFRE_DB_DNS','newOperation','collection',CFOS_DB_SERVICES_COLLECTION),fdbbt_submit);
  Result:=res;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_AddZone(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme    : IFRE_DB_SchemeObject;
  zoneObj   : IFRE_DB_Object;
  res       : TFRE_DB_FORM_DIALOG_DESC;
  store     : TFRE_DB_STORE_DESC;
  group     : TFRE_DB_INPUT_GROUP_DESC;
  pool      : TFRE_DB_ZFS_POOL;
  machineId : TFRE_DB_GUID;
  domainObj : IFRE_DB_Object;
  poolCount : Integer;

begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_DB_ZONE)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZONE',scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_zone_diag_cap'),600);

  CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedService').AsString),domainObj));
  machineId:=domainObj.Field('serviceParent').AsObjectLink;

  store:=TFRE_DB_STORE_DESC.create.Describe();
  poolCount:=_getPoolCount(conn,machineId,pool,store);
  if poolCount=0 then raise EFRE_DB_Exception.Create('No Pool(s) configured.');
  if poolCount=1 then begin
    res.AddInput.Describe('','pool',false,false,false,true,pool.UID_String);
  end else begin
    group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'add_zone_diag_location_group'));
    group.AddChooser.Describe(FetchModuleTextShort(ses,'add_zone_diag_pool'),'pool',store,dh_chooser_combo,true);
  end;

  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  res.AddInput.Describe('','serviceParent',false,false,false,true,ses.GetSessionModuleData(ClassName).Field('selectedService').AsString);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CSCF('TFRE_DB_ZONE','newOperation','collection',CFOS_DB_ZONES_COLLECTION),fdbbt_submit);
  Result:=res;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ServicesMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  serviceObj: IFRE_DB_Object;
  zone      : TFRE_DB_ZONE;
  domain    : TFRE_DB_SERVICE_DOMAIN;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),serviceObj));
    if serviceObj.IsA(TFRE_DB_ZONE,zone) then begin
      if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE)) or
         (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DNS)) or
         (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NAS)) then begin
        if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE)) then begin
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cb_add_service_vm'),'',CWSF(@WEB_AddVM));
        end;
        if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NAS)) then begin
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cb_add_service_nas'),'',CWSF(@WEB_AddNAS),zone.hasNAS(conn));
        end;
        if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DNS)) then begin
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cb_add_service_dns'),'',CWSF(@WEB_AddDNS),zone.hasDNS(conn));
        end;
      end;
    end else
    if serviceObj.IsA(TFRE_DB_SERVICE_DOMAIN,domain) then begin
      if (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZONE)) then begin
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cb_add_zone'),'',CWSF(@WEB_AddZone),not _hasPool(conn,domain.Field('serviceParent').AsObjectLink));
      end;
    end;
  end;
  Result:=res;
end;

function TFOS_FIRMBOX_MANAGED_SERVICES_MOD.WEB_ServicesSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0) then begin
    ses.GetSessionModuleData(ClassName).Field('selectedService').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedService');
  end;
  Result:=_getServiceContent(input,ses,app,conn);
end;

{ TFOS_FIRMBOX_SERVICES_APP }

procedure TFOS_FIRMBOX_SERVICES_APP.SetupApplicationStructure;
var
  services: TFOS_FIRMBOX_MANAGED_SERVICES_MOD;
  vm_machines: TFRE_FIRMBOX_VM_MACHINES_MOD;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('description');
  services:=TFOS_FIRMBOX_MANAGED_SERVICES_MOD.create;
  vm_machines:=TFRE_FIRMBOX_VM_MACHINES_MOD.create;
  services.VM:=vm_machines;
  AddApplicationModule(services);
end;

procedure TFOS_FIRMBOX_SERVICES_APP._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services',FetchAppTextShort(session,'sitemap_main'),'images_apps/firmbox_services/main_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_FIRMBOX_SERVICES_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Services/Managed',FetchAppTextShort(session,'sitemap_managed_services'),'images_apps/firmbox_services/managed_services_white.svg',TFOS_FIRMBOX_MANAGED_SERVICES_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_FIRMBOX_MANAGED_SERVICES_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFOS_FIRMBOX_SERVICES_APP.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFOS_FIRMBOX_SERVICES_APP.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      currentVersionId:='1.0';

      CreateAppText(conn,'caption','Services','Services','Services');
      CreateAppText(conn,'managed_services_description','Managed Services','Managed Services','Managed Services');

      CreateAppText(conn,'sitemap_main','Services','','Services');
      CreateAppText(conn,'sitemap_managed_services','Managed','','Managed');

    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
   
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then
    begin
      //ADMINS
      CheckDbResult(conn.AddGroup('SERVICESADMINS','Admins of Firmbox Services','Services Admins',domainUID),'could not create admins group');

      CheckDbResult(conn.AddRolesToGroup('SERVICESADMINS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_FIRMBOX_SERVICES_APP.GetClassRoleNameFetch,
        TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Admins');

      CheckDbResult(conn.AddRolesToGroup('SERVICESADMINS',domainUID, TFRE_DB_NOTE.GetClassStdRoles),'could not add roles TFRE_DB_NOTE for group Admins');

      //MANAGERS
      CheckDbResult(conn.AddGroup('SERVICESMANAGERS','Managers of Firmbox Services','Services Managers',domainUID),'could not create managers group');

      CheckDbResult(conn.AddRolesToGroup('SERVICESMANAGERS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_FIRMBOX_SERVICES_APP.GetClassRoleNameFetch,
        TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Managers');

      CheckDbResult(conn.AddRolesToGroup('SERVICESMANAGERS',domainUID, TFRE_DB_NOTE.GetClassStdRoles),'could not add roles TFRE_DB_NOTE for group Managers');

      //VIEWERS
      CheckDbResult(conn.AddGroup('SERVICESVIEWERS','Viewers of Firmbox Services','Services Viewers',domainUID),'could not create viewers group');

      CheckDbResult(conn.AddRolesToGroup('SERVICESVIEWERS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_FIRMBOX_SERVICES_APP.GetClassRoleNameFetch,
        TFOS_FIRMBOX_MANAGED_SERVICES_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Viewers');

      CheckDbResult(conn.AddRolesToGroup('SERVICESVIEWERS',domainUID,TFRE_DB_StringArray.Create(
        TFRE_DB_NOTE.GetClassRoleNameFetch
      )),'could not add roles for group Viewers');

    end;
end;

class procedure TFOS_FIRMBOX_SERVICES_APP.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
    CreateServicesCollections(conn);
    if currentVersionId='' then begin
      currentVersionId := '1.0';
    end;
end;

end.

