unit fos_firmbox_vm_machines_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_SYSRIGHT_CONSTANTS,
  FRE_DB_INTERFACE,
  FOS_VM_CONTROL_INTERFACE,
  fre_hal_schemes,
  fre_system,
  FRE_DB_COMMON;

//var
//     cVM_HostUser:string   = ''; // 'root';
//     cVMHostMachine:string = ''; // '10.1.0.116';

type

  { TFRE_FIRMBOX_VM_MACHINES_MOD }

  TFRE_FIRMBOX_VM_MACHINES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function  getAvailableRAM           :Integer;
    function  getMinimumRAM             :Integer;
    function  getRAMSteps               :Integer;
    function  getAvailableCPU           :Integer;
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule (const session   : TFRE_DB_UserSession);override;
    procedure       MyServerInitializeModule  (const admin_dbc : IFRE_DB_CONNECTION); override;
    procedure       _GetSelectedVMData        (session : IFRE_DB_UserSession ; const selected : TGUID; var vmkey,vnc_port,vnc_host,vm_state: String);
  published
    function  WEB_VM_Feed_Update        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowInfo           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowVNC            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowPerf           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_ContentNote           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_Details            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_NewVM                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_CreateVM              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StartVM               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVM                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVMF               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_UpdateVM              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_RESOURCES_MOD }

  TFRE_FIRMBOX_VM_RESOURCES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MyServerInitializeModule  (const admin_dbc : IFRE_DB_CONNECTION); override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentDisks          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentISOs           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateDisk            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteDisk            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_UploadISO             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteISO             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_NETWORK_MOD }

  TFRE_FIRMBOX_VM_NETWORK_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkContent       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkMenu          (const input:IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkCreateStub    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_STATUS_MOD }

  TFRE_FIRMBOX_VM_STATUS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_DISK }

  TFRE_FIRMBOX_VM_DISK = class (TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_FIRMBOX_VM_ISO }

  TFRE_FIRMBOX_VM_ISO = class (TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_MACHINES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_RESOURCES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_STATUS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_NETWORK_MOD);

  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_DISK);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_ISO);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_VM_ISO }

class procedure TFRE_FIRMBOX_VM_ISO.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddSchemeField('isoid',fdbft_String).required:=true;
  scheme.AddSchemeField('name',fdbft_String).required:=true;

  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_FIRMBOX_VM_ISO_main_group');
  group.AddInput('isoid','$scheme_TFRE_FIRMBOX_VM_ISO_id');
  group.AddInput('name','$scheme_TFRE_FIRMBOX_VM_ISO_name');
end;

class procedure TFRE_FIRMBOX_VM_ISO.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  inherited InstallDBObjects(conn);
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_FIRMBOX_VM_ISO_main_group','General Information'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_FIRMBOX_VM_ISO_id','ID'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_FIRMBOX_VM_ISO_name','Name'));
end;

{ TFRE_FIRMBOX_VM_DISK }

class procedure TFRE_FIRMBOX_VM_DISK.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddSchemeField('diskid',fdbft_String).required:=true;
  scheme.AddSchemeField('name',fdbft_String).required:=true;

  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_FIRMBOX_VM_DISK_main_group');
  group.AddInput('diskid','$scheme_TFRE_FIRMBOX_VM_DISK_id');
  group.AddInput('name','$scheme_TFRE_FIRMBOX_VM_DISK_name');
end;

class procedure TFRE_FIRMBOX_VM_DISK.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  inherited InstallDBObjects(conn);
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_FIRMBOX_VM_DISK_main_group','General Information'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_FIRMBOX_VM_DISK_id','ID'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_FIRMBOX_VM_DISK_name','Name'));
end;

{ TFRE_FIRMBOX_VM_RESOURCES_MOD }

class procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('VMRESOURCES','$vm_resources_description');
end;

procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
var
  vm_disks: IFRE_DB_COLLECTION;
  vm_isos : IFRE_DB_COLLECTION;
begin
  inherited MyServerInitializeModule(admin_dbc);

  vm_disks := admin_dbc.Collection('VM_DISKS',true,true);
  vm_disks.DefineIndexOnField('diskid',fdbft_String,true,true);

  vm_isos := admin_dbc.Collection('VM_ISOS',true,true);
  vm_isos.DefineIndexOnField('isoid',fdbft_String,true,true);
end;

procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app     : TFRE_DB_APPLICATION;
  conn    : IFRE_DB_CONNECTION;
  tr_Grid : IFRE_DB_SIMPLE_TRANSFORM;
  isosp   : IFRE_DB_COLLECTION;
  isos    : IFRE_DB_DERIVED_COLLECTION;
  diskp   : IFRE_DB_COLLECTION;
  disks   : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  app:=GetEmbeddingApp;
  conn := session.GetDBConnection;

  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);
    tr_Grid.AddOneToOnescheme('name','',app.FetchAppText(session,'$gc_iso_name').Getshort);

    isosp := conn.Collection('VM_ISOS',false);
    isos:= session.NewDerivedCollection('VM_ISOS_DERIVED');
    with isos do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(isosp);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);
    tr_Grid.AddOneToOnescheme('name','',app.FetchAppText(session,'$gc_disk_name').Getshort);

    diskp := conn.Collection('VM_DISKS',false);
    disks:= session.NewDerivedCollection('VM_DISKS_DERIVED');
    with disks do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(diskp);
    end;
  end;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_SUBSECTIONS_DESC;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  res.AddSection.Describe(CWSF(@WEB_ContentDisks),app.FetchAppText(ses,'$vm_resources_disks').Getshort,1,'DISKS');
  res.AddSection.Describe(CWSF(@WEB_ContentISOs),app.FetchAppText(ses,'$vm_resources_isos').Getshort,2,'ISOS');
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_ContentDisks(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  coll := ses.FetchDerivedCollection('VM_DISKS_DERIVED');
  res := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res.AddButton.Describe(CWSF(@WEB_CreateDisk),'/images_apps/hal/add_disk.png',app.FetchAppText(ses,'$vm_resources_add_disk').Getshort,app.FetchAppText(ses,'$vm_resources_add_disk').GetHint);
  res.AddButton.Describe(CWSF(@WEB_DeleteDisk),'/images_apps/hal/delete_disk.png',app.FetchAppText(ses,'$vm_resources_delete_disk').Getshort,app.FetchAppText(ses,'$vm_resources_delete_disk').GetHint,fdgbd_multi);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_ContentISOs(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  coll := ses.FetchDerivedCollection('VM_ISOS_DERIVED');
  res := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res.AddButton.Describe(CWSF(@WEB_UploadISO),'/images_apps/hal/add_iso.png',app.FetchAppText(ses,'$vm_resources_add_iso').Getshort,app.FetchAppText(ses,'$vm_resources_add_iso').GetHint);
  res.AddButton.Describe(CWSF(@WEB_DeleteISO),'/images_apps/hal/delete_iso.png',app.FetchAppText(ses,'$vm_resources_delete_iso').Getshort,app.FetchAppText(ses,'$vm_resources_delete_iso').GetHint,fdgbd_multi);

  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_CreateDisk(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_DIALOG_DESC;
  scheme    : IFRE_DB_SchemeObject;
  serverFunc: TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  GFRE_DBI.GetSystemSchemeByName('TFRE_FIRMBOX_VM_DISK',scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(ses,'ADD_DISK').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  serverFunc:=CSCF('TFRE_FIRMBOX_VM_DISK','NewOperation','collection','VM_DISKS');
  res.AddButton.Describe(app.FetchAppText(ses,'$button_save').Getshort,serverFunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_DeleteDisk(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj: IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('SELECTED').AsStringItem[0]),obj);
  Result:=(obj.Implementor_HC as TFRE_FIRMBOX_VM_DISK).Invoke_DBIMI_Method('deleteOperation',input,ses,app,conn);
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_UploadISO(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_DIALOG_DESC;
  serverFunc: TFRE_DB_SERVER_FUNC_DESC;
  scheme: IFRE_DB_SchemeObject;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  GFRE_DBI.GetSystemSchemeByName('TFRE_FIRMBOX_VM_ISO',scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(ses,'UPLOAD_ISO').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  serverFunc:=CSCF('TFRE_FIRMBOX_VM_ISO','NewOperation','collection','VM_ISOS');
  res.AddButton.Describe(app.FetchAppText(ses,'$button_save').Getshort,serverFunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_DeleteISO(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj: IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('SELECTED').AsStringItem[0]),obj);
  Result:=(obj.Implementor_HC as TFRE_FIRMBOX_VM_ISO).Invoke_DBIMI_Method('deleteOperation',input,ses,app,conn);
end;

{ TFRE_FIRMBOX_VM_STATUS_MOD }

class procedure TFRE_FIRMBOX_VM_STATUS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_VM_STATUS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('VMSTATUS','$status_description');
end;


function TFRE_FIRMBOX_VM_STATUS_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  Result:=TFRE_DB_HTML_DESC.create.Describe('Feature disabled in Demo Mode.');//FIXXME: Please implement me
end;

{ TFRE_FIRMBOX_VM_NETWORK_MOD }

class procedure TFRE_FIRMBOX_VM_NETWORK_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_VM_NETWORK_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('VMNETWORK','$vnetwork_description');
end;

procedure TFRE_FIRMBOX_VM_NETWORK_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var datalink_dc       : IFRE_DB_DERIVED_COLLECTION;
    datalink_tr_Grid  : IFRE_DB_SIMPLE_TRANSFORM;
    app               : TFRE_DB_APPLICATION;
    conn              : IFRE_DB_CONNECTION;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,datalink_tr_Grid);
    with datalink_tr_Grid do begin
      //AddOneToOnescheme('icon','',app.FetchAppText(conn,'$datalink_icon').GetShort,dt_icon);
      AddOneToOnescheme('objname','linkname',app.FetchAppText(conn,'$datalink_name').Getshort,dt_string,1,'icon');
//      AddOneToOnescheme('zoned','zoned',app.FetchAppText(conn,'$datalink_zoned').Getshort);
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$datalink_desc').Getshort);
    end;
    datalink_dc := session.NewDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    with datalink_dc do begin
      SetDeriveParent(conn.Collection('datalink'));
      SetDeriveTransformation(datalink_tr_Grid);
      AddBooleanFieldFilter('showvirtual','showvirtual',true,false);
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_DatalinkMenu),nil,CWSF(@WEB_DatalinkContent));
      SetChildToParentLinkField ('parentid');
    end;
  end;
end;


function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  grid_datalink   : TFRE_DB_VIEW_LIST_DESC;
  dc_datalink     : IFRE_DB_DERIVED_COLLECTION;
  datalink_content: TFRE_DB_FORM_PANEL_DESC;
  txt             : IFRE_DB_TEXT;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  dc_datalink                := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
  grid_datalink              := dc_datalink.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  txt:=app.FetchAppText(ses,'$datalink_create_stub');
  grid_datalink.AddButton.Describe(CWSF(@WEB_DatalinkCreateStub),'images_apps/hal/create_stub.png',txt.Getshort,txt.GetHint);

  datalink_content           := TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(ses,'$datalink_content_header').ShortText);
  datalink_content.contentId :='DATALINK_CONTENT';
  Result                     := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_datalink,datalink_content,nil,nil,nil,true,1,1);
end;

function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_DatalinkContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  dl            : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    if dc.Fetch(sel_guid,dl) then begin
      GFRE_DBI.GetSystemSchemeByName(dl.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(ses,'$datalink_content_header').ShortText);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(dl,ses);
      panel.contentId:='DATALINK_CONTENT';
//      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(dl,'saveOperation'),fdbbt_submit);
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(ses,'$datalink_content_header').ShortText);
    panel.contentId:='DATALINK_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_DatalinkMenu(const input: IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  dc        : IFRE_DB_DERIVED_COLLECTION;
  dl        : IFRE_DB_Object;
  sel_guid  : TGUID;
  sclass    : TFRE_DB_NameType;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  Result:=GFRE_DB_NIL_DESC;
  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    if dc.Fetch(sel_guid,dl) then begin
      sclass := dl.SchemeClass;
      writeln(schemeclass);
      input.Field('add_vnic').AsString    := app.FetchAppText(ses,'$datalink_add_vnic').Getshort;
      input.Field('delete_vnic').AsString := app.FetchAppText(ses,'$datalink_delete_vnic').Getshort;
      input.Field('delete_aggr').AsString := app.FetchAppText(ses,'$datalink_delete_aggr').Getshort;
      input.Field('delete_stub').AsString := app.FetchAppText(ses,'$datalink_delete_stub').Getshort;
      result := dl.Invoke('Menu',input,ses,app,conn);
    end;
  end;
end;

function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_DatalinkCreateStub(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);//FIXXME: Please implement me
end;


{ TFRE_FIRMBOX_VM_MACHINES_MOD }

function TFRE_FIRMBOX_VM_MACHINES_MOD.getAvailableRAM: Integer;
begin
  Result:=64*1024; //FIXXME: please implement me
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.getMinimumRAM: Integer;
begin
  Result:=1024; //FIXXME: please implement me
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.getRAMSteps: Integer;
begin
  Result:=1024; //FIXXME: please implement me
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.getAvailableCPU: Integer;
begin
  Result:=4; //FIXXME - please implement me
end;

class procedure TFRE_FIRMBOX_VM_MACHINES_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_VM_MACHINES_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  writeln('setup app module vm machines mod');
  InitModuleDesc('VMCONTROLLER','$machines_description');
end;

procedure TFRE_FIRMBOX_VM_MACHINES_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  vmc        : IFRE_DB_DERIVED_COLLECTION;
  vmcp       : IFRE_DB_COLLECTION;
  tr_Grid    : IFRE_DB_SIMPLE_TRANSFORM;
  vmo        : IFRE_DB_Object;
  vm         : IFRE_DB_Object;
  uvm        : IFRE_DB_Object;
  i          : Integer;
  app        : TFRE_DB_APPLICATION;
  conn       : IFRE_DB_CONNECTION;
  isosp      : IFRE_DB_COLLECTION;
  isos       : IFRE_DB_DERIVED_COLLECTION;
  disksp     : IFRE_DB_COLLECTION;
  disks      : IFRE_DB_DERIVED_COLLECTION;
  scsp       : IFRE_DB_COLLECTION;
  scs        : IFRE_DB_DERIVED_COLLECTION;
  keyboardsp : IFRE_DB_COLLECTION;
  keyboards  : IFRE_DB_DERIVED_COLLECTION;
  transform  : IFRE_DB_SIMPLE_TRANSFORM;
begin
  inherited MySessionInitializeModule(session);
  app:=GetEmbeddingApp;
  conn := session.GetDBConnection;

  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);
    with tr_Grid do begin
      AddOneToOnescheme('Objname','',app.FetchAppText(conn,'$gc_vm_name').Getshort,dt_string,4);
      AddOneToOnescheme('MType','',app.FetchAppText(conn,'$gc_vm_type').Getshort);
      AddOneToOnescheme('MStateIcon','',app.FetchAppText(conn,'$gc_vm_state').Getshort,dt_icon);
      AddOneToOnescheme('PERFPCPU','',app.FetchAppText(conn,'$gc_vm_cpu').Getshort,dt_number,2);
      AddOneToOnescheme('PERFPMEM','',app.FetchAppText(conn,'$gc_vm_used_mem').Getshort,dt_number,2);
      AddOneToOnescheme('PERFRSS','',app.FetchAppText(conn,'$gc_vm_paged_mem').Getshort,dt_number,2);
      AddOneToOnescheme('PERFVSZ','',app.FetchAppText(conn,'$gc_vm_virtual_mem').Getshort,dt_number,2);
    end;
    vmcp := session.GetDBConnection.Collection('virtualmachine',false);
    vmc  := session.NewDerivedCollection('VMC');
    with VMC do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ColumnResizeable],'',nil,'',nil,nil,CWSF(@WEB_VM_Details));
      SetDeriveParent(vmcp);
      AddRightFilterForEntryAndUser('RF','VMLIST');
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    transform.AddOneToOnescheme('name');

    isosp := conn.Collection('VM_ISOS',false);
    isos:= session.NewDerivedCollection('VM_CH_ISOS_DERIVED');
    with isos do begin
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(isosp);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    transform.AddOneToOnescheme('name');

    disksp := session.GetDBConnection.Collection('VM_DISKS',false);
    disks:= session.NewDerivedCollection('VM_CH_DISKS_DERIVED');
    with disks do begin
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(disksp);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    transform.AddOneToOnescheme('name');

    scsp := session.GetDBConnection.Collection('VM_SCS',false);
    scs:= session.NewDerivedCollection('VM_CH_SCS_DERIVED');
    with scs do begin
      SetDeriveTransformation(transform);
      AddOrderField('scs_order','order',true);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(scsp);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    transform.AddOneToOnescheme('name');

    keyboardsp := session.GetDBConnection.Collection('VM_KEYBOARDS',false);
    keyboards:= session.NewDerivedCollection('VM_CH_KEYBOARDS_DERIVED');
    with keyboards do begin
      SetDeriveTransformation(transform);
      AddOrderField('keyboard_order','order',true);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(keyboardsp);
    end;

  end;
end;

procedure TFRE_FIRMBOX_VM_MACHINES_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
var
  vm_disks    : IFRE_DB_COLLECTION;
  vm_isos     : IFRE_DB_COLLECTION;
  vm_sc       : IFRE_DB_COLLECTION;
  vm_keyboards: IFRE_DB_COLLECTION;
  storeObj    : IFRE_DB_Object;
begin
  inherited MyServerInitializeModule(admin_dbc);

  vm_disks := admin_dbc.Collection('VM_DISKS',true,true);
  vm_disks.DefineIndexOnField('diskid',fdbft_String,true,true);

  vm_isos := admin_dbc.Collection('VM_ISOS',true,true);
  vm_isos.DefineIndexOnField('isoid',fdbft_String,true,true);

  vm_sc   := admin_dbc.Collection('VM_SCS',true,true);
  vm_sc.DefineIndexOnField('scid',fdbft_String,true,true);

  vm_keyboards := admin_dbc.Collection('VM_KEYBOARDS',true,true);
  vm_keyboards.DefineIndexOnField('keyboardid',fdbft_String,true,true);

  //FIXXME: remove test code
  storeObj := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_DISK);
  storeObj.Field('diskid').AsString:='d1';
  storeObj.Field('name').AsString:='d1 name';
  CheckDbResult(vm_disks.Store(storeObj),'Store VM disk');

  storeObj := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_DISK);
  storeObj.Field('diskid').AsString:='d2';
  storeObj.Field('name').AsString:='d2 name';
  CheckDbResult(vm_disks.Store(storeObj),'Store VM disk');

  storeObj := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_ISO);
  storeObj.Field('isoid').AsString:='i1';
  storeObj.Field('name').AsString:='iso1 name';
  CheckDbResult(vm_isos.Store(storeObj),'Store VM iso');

  storeObj := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_ISO);
  storeObj.Field('isoid').AsString:='i2';
  storeObj.Field('name').AsString:='iso2 name';
  CheckDbResult(vm_isos.Store(storeObj),'Store VM iso');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('keyboardid').AsString:='en-gb';
  storeObj.Field('name').AsString:='English (GB)';
  storeObj.Field('order').AsString:='1';
  CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('keyboardid').AsString:='en-us';
  storeObj.Field('name').AsString:='English (US)';
  storeObj.Field('order').AsString:='2';
  CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('keyboardid').AsString:='fr';
  storeObj.Field('name').AsString:='French';
  storeObj.Field('order').AsString:='3';
  CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('keyboardid').AsString:='de';
  storeObj.Field('name').AsString:='German';
  storeObj.Field('order').AsString:='4';
  CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('keyboardid').AsString:='it';
  storeObj.Field('name').AsString:='Italian';
  storeObj.Field('order').AsString:='5';
  CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('keyboardid').AsString:='es';
  storeObj.Field('name').AsString:='Spanish';
  storeObj.Field('order').AsString:='6';
  CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

  //FIXXME: move to correct location or read from qemu help
  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('scid').AsString:='ac97';
  storeObj.Field('name').AsString:='Intel 82801AA AC97 Audio';
  storeObj.Field('order').AsString:='1';
  CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('scid').AsString:='sb16';
  storeObj.Field('name').AsString:='Creative Sound Blaster 16';
  storeObj.Field('order').AsString:='2';
  CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('scid').AsString:='es1370';
  storeObj.Field('name').AsString:='ENSONIQ AudioPCI ES1370';
  storeObj.Field('order').AsString:='3';
  CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

  storeObj:=GFRE_DBI.NewObject;
  storeObj.Field('scid').AsString:='hda';
  storeObj.Field('name').AsString:='Intel HD Audio';
  storeObj.Field('order').AsString:='4';
  CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

end;


procedure TFRE_FIRMBOX_VM_MACHINES_MOD._GetSelectedVMData(session: IFRE_DB_UserSession; const selected: TGUID; var vmkey, vnc_port, vnc_host, vm_state: String);
var DC_VMC     : IFRE_DB_DERIVED_COLLECTION;
      vmo        : IFRE_DB_Object;
begin
  DC_VMC := session.FetchDerivedCollection('VMC');
  if DC_VMC.Fetch(selected,vmo) then begin
    vmkey    := vmo.Field('MKEY').AsString;
    vnc_port := vmo.Field('VNC_PORT').AsString;
    vnc_host := vmo.Field('VNC_HOST').AsString;
    vm_state := vmo.Field('MSTATE').AsString;
    writeln('VMO: ',vmkey,' ',vnc_port,' ', vm_state);
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_Feed_Update(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var// vmc     : IFOS_VM_HOST_CONTROL;
    vmo     : IFRE_DB_Object;
    vm      : IFRE_DB_Object;
    vmcc    : IFRE_DB_COLLECTION;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  GFRE_DBI.LogInfo(dblc_APPLICATION,'START FEED UPDATE');
  conn.CollectionAsIntf('virtualmachine',IFRE_DB_COLLECTION,vmcc,false);
  VM_UpdateCollection(conn,vmcc,input.CloneToNewObject(),TFRE_DB_VMACHINE.ClassName,TFRE_DB_ZONE.ClassName);
  GFRE_DBI.LogInfo(dblc_APPLICATION,'START FEED UPDATE DONE');
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  coll   : IFRE_DB_DERIVED_COLLECTION;
  list   : TFRE_DB_VIEW_LIST_DESC;
  main   : TFRE_DB_LAYOUT_DESC;
  text   : IFRE_DB_TEXT;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  coll := ses.FetchDerivedCollection('VMC');
  list := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname('admin_vms')) then begin
    text:=app.FetchAppText(ses,'$machines_new_vm');
    list.AddButton.Describe(CWSF(@WEB_NewVM)         , '/images_apps/hal/add_vm.png',text.Getshort,text.GetHint);
  end;
  text:=app.FetchAppText(ses,'$machines_start');
  list.AddButton.Describe(CWSF(@WEB_StartVM)       , '/images_apps/hal/start_vm.png',text.Getshort,text.GetHint,fdgbd_single);
  text:=app.FetchAppText(ses,'$machines_stop');
  list.AddButton.Describe(CWSF(@WEB_StopVM)        , '/images_apps/hal/stop_vm.png',text.Getshort,text.GetHint,fdgbd_single);
  text:=app.FetchAppText(ses,'$machines_kill');
  list.AddButton.Describe(CWSF(@WEB_StopVMF)       , '/images_apps/hal/stop_vm.png',text.Getshort,text.GetHint,fdgbd_single);
  text:=app.FetchAppText(ses,'$machines_update');
  list.AddButton.Describe(CWSF(@WEB_UpdateVM), '',text.Getshort,text.GetHint);
  main := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(list,nil,nil,nil,nil,true,2);

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,main,nil,TFRE_DB_HTML_DESC.create.Describe(app.FetchAppText(ses,'$machines_content_header').Getshort));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowInfo(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var vmcc  : IFRE_DB_COLLECTION;
    vmkey : string;
      obj : IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  vmkey := input.Field('vmkey').AsString;
  conn.CollectionAsIntf('virtualmachine',IFRE_DB_COLLECTION,VMCC,true,true);
  if vmcc.GetIndexedObj(vmkey,obj) then begin
    result := TFRE_DB_HTML_DESC.create.Describe(FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+obj.DumpToString+'</pre>'));
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe(app.FetchAppText(ses,'$machines_no_info').Getshort);
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowVNC(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vmkey              : string;
  vmcc               : IFRE_DB_COLLECTION;
  obj                : IFRE_DB_Object;
  urlSep             : TFOSStringArray;
  prot,host,port,path: String;
  tmp                : String;
  i                  : Integer;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  writeln('VNC INPUT ',input.DumpToString);
  vmkey  := input.Field('vmkey').AsString;
  VMCC := conn.Collection('virtualmachine',false);
  if vmcc.GetIndexedObj(vmkey,obj) then begin
    writeln(':::',obj.DumpToString());
    if obj.Field('MSTATE').AsString='running' then begin
      if obj.Field('MTYPE').AsString='KVM' then begin
        result := TFRE_DB_VNC_DESC.create.Describe(input.Field('VNC_HOST').AsString,input.Field('VNC_PORT').AsUInt32);
      end else begin
        tmp:=obj.Field('SHELL').AsString;
        if Pos('://',tmp)>0 then begin
          GFRE_BT.SeperateString(tmp,'://',urlSep);
          prot:=urlSep[0];
          tmp:=urlSep[1];
        end else begin
          prot:='http';
        end;
        GFRE_BT.SeperateString(tmp,':',urlSep);
        if Length(urlSep)>=2 then
          begin
            host:=urlSep[0];
            tmp:=urlSep[1];
            GFRE_BT.SeperateString(tmp,'/',urlSep);
            port:=urlSep[0];
            path:='';
            for i := 1 to Length(urlSep) - 1 do begin
              path:=path+'/'+urlSep[i];
            end;
            result := TFRE_DB_SHELL_DESC.create.Describe(host,StrToInt(port),path,prot);
          end;
      end;
    end else begin
      result := TFRE_DB_HTML_DESC.create.Describe(FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+obj.DumpToString+'</pre>'));
    end;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe(app.FetchAppText(ses,'$machines_no_info').Getshort);
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowPerf(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  result := TFRE_DB_HTML_DESC.create.Describe('Feature disabled in Demo Mode.'); //FIXXME: please implement me
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_ContentNote(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  load_func             : TFRE_DB_SERVER_FUNC_DESC;
  save_func             : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  writeln('CONTENTNOTE');
  writeln(input.DumpToString);

  load_func   := CWSF(@WEB_NoteLoad);
  save_func   := CWSF(@WEB_NoteSave);
  load_func.AddParam.Describe('linkid',input.Field('linkid').asstring);
  save_func.AddParam.Describe('linkid',input.Field('linkid').asstring);

  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CWSF(@WEB_NoteStartEdit),CWSF(@WEB_NoteStopEdit));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_Details(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var   vm_sub       : TFRE_DB_SUBSECTIONS_DESC;
      vmo          : IFRE_DB_Object;
      sf           : TFRE_DB_SERVER_FUNC_DESC;
      sel_guid     : TGUID;
      vmkey,vncp,
      vnch,vmstate : string;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    _GetSelectedVMData(ses,sel_guid,vmkey,vncp,vnch,vmstate);
    vm_sub := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
    sf := CWSF(@WEB_VM_ShowInfo); sf.AddParam.Describe('VMKEY',vmkey);
    vm_sub.AddSection.Describe(sf,app.FetchAppText(ses,'$vm_details_config').Getshort,2);
    sf := CWSF(@WEB_VM_ShowVNC); sf.AddParam.Describe('VNC_PORT',vncp) ; sf.AddParam.Describe('VNC_HOST',vnch); sf.AddParam.Describe('VMKEY',vmkey);
    vm_sub.AddSection.Describe(sf,app.FetchAppText(ses,'$vm_details_console').Getshort,1);
    vm_sub.AddSection.Describe(CWSF(@WEB_VM_ShowPerf),app.FetchAppText(ses,'$vm_details_perf').Getshort,3);
    sf := CWSF(@WEB_ContentNote); sf.AddParam.Describe('linkid',input.Field('SELECTED').asstring);
    vm_sub.AddSection.Describe(sf,app.FetchAppText(ses,'$vm_details_note').Getshort,4);
    result := vm_sub;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('');
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_NewVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res                  : TFRE_DB_DIALOG_DESC;
  maxRAM,minRAM,stepRAM: Integer;
  maxCPU               : Integer;
  idestore             : TFRE_DB_STORE_DESC;
  isostore             : TFRE_DB_STORE_DESC;
  diskstore            : TFRE_DB_STORE_DESC;
  keyboardstore        : TFRE_DB_STORE_DESC;
  vm_disks             : IFRE_DB_DERIVED_COLLECTION;
  vm_isos              : IFRE_DB_DERIVED_COLLECTION;
  vm_scs               : IFRE_DB_DERIVED_COLLECTION;
  vm_keyboards         : IFRE_DB_DERIVED_COLLECTION;
  chooser              : TFRE_DB_INPUT_CHOOSER_DESC;
  diskchooser          : TFRE_DB_INPUT_CHOOSER_DESC;
  isochooser           : TFRE_DB_INPUT_CHOOSER_DESC;
  group                : TFRE_DB_INPUT_GROUP_DESC;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);

  vm_isos := ses.FetchDerivedCollection('VM_CH_ISOS_DERIVED');
  vm_disks:= ses.FetchDerivedCollection('VM_CH_DISKS_DERIVED');
  vm_scs:= ses.FetchDerivedCollection('VM_CH_SCS_DERIVED');
  vm_keyboards:= ses.FetchDerivedCollection('VM_CH_KEYBOARDS_DERIVED');

  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(ses,'$vm_new_caption').Getshort);
  res.AddButton.Describe(app.FetchAppText(ses,'$vm_new_save').Getshort,CWSF(@WEB_CreateVM),fdbbt_submit);

  res.AddInput.Describe(app.FetchAppText(ses,'$vm_name').Getshort,'name',true);
  maxRAM:=getAvailableRAM; minRAM:=getMinimumRAM; stepRAM:=getRAMSteps;
  res.AddNumber.DescribeSlider(app.FetchAppText(ses,'$vm_mem').Getshort,'mem',minRAM,maxRAM,IntToStr(minRAM),2, round((maxRAM-minRAM) / stepRAM) + 1);

  maxCPU:=getAvailableCPU;
  res.AddNumber.DescribeSlider(app.FetchAppText(ses,'$vm_cpu').Getshort,'cpu',1,maxCPU,IntToStr(maxCPU),0,maxCPU);

  res.AddChooser.Describe(app.FetchAppText(ses,'$vm_sc').Getshort,'sc',vm_scs.GetStoreDescription as TFRE_DB_STORE_DESC,true,dh_chooser_combo,true);

  idestore:=TFRE_DB_STORE_DESC.create.Describe();
  idestore.AddEntry.Describe(app.FetchAppText(ses,'$vm_ide_option_disk').Getshort,'disk');
  idestore.AddEntry.Describe(app.FetchAppText(ses,'$vm_ide_option_iso').Getshort,'iso');

  isostore:=vm_isos.GetStoreDescription as TFRE_DB_STORE_DESC;
  isostore.AddEntry.Describe(app.FetchAppText(ses,'$vm_upload_iso').Getshort,'upload');

  diskstore:=vm_disks.GetStoreDescription as TFRE_DB_STORE_DESC;
  diskstore.AddEntry.Describe(app.FetchAppText(ses,'$vm_create_new_disk').Getshort,'create');

  chooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_ide0').Getshort,'ide0',idestore,true,dh_chooser_combo,false,false,false,'disk');

  diskchooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_disk_chooser').Getshort,'disk0',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppText(ses,'$vm_new_disk_name').Getshort,'diskname0',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppText(ses,'$vm_new_disk_size').Getshort,'disksize0',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_iso_chooser').Getshort,'iso0',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  chooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_ide1').Getshort,'ide1',idestore,true,dh_chooser_combo,false,false,false,'iso');

  diskchooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_disk_chooser').Getshort,'disk1',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppText(ses,'$vm_new_disk_name').Getshort,'diskname1',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppText(ses,'$vm_new_disk_size').Getshort,'disksize1',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_iso_chooser').Getshort,'iso1',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  chooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_ide2').Getshort,'ide2',idestore);

  diskchooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_disk_chooser').Getshort,'disk2',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppText(ses,'$vm_new_disk_name').Getshort,'diskname2',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppText(ses,'$vm_new_disk_size').Getshort,'disksize2',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_iso_chooser').Getshort,'iso2',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  chooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_ide3').Getshort,'ide3',idestore);

  diskchooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_disk_chooser').Getshort,'disk3',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppText(ses,'$vm_new_disk_name').Getshort,'diskname3',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppText(ses,'$vm_new_disk_size').Getshort,'disksize3',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppText(ses,'$vm_iso_chooser').Getshort,'iso3',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  group:=res.AddGroup.Describe(app.FetchAppText(ses,'$vm_advanced').Getshort,true,true);

  keyboardstore:=vm_keyboards.GetStoreDescription as TFRE_DB_STORE_DESC;
  keyboardstore.AddEntry.Describe(app.FetchAppText(ses,'$vm_keyboard_layout_auto').Getshort,'auto');
  group.AddChooser.Describe(app.FetchAppText(ses,'$vm_keyboard_layout').Getshort,'keybord_layout',keyboardstore,true,dh_chooser_combo,true);

  Result:=res;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_CreateVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  //FIXXME: please implement me
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StartVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var   vmc   : IFOS_VM_HOST_CONTROL;
      vmkey : string;
      vncp  : string;
      vnch  : string;
    vmstate : string;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','START VM',fdbmt_info);
  //exit;
  if input.FieldExists('SELECTED') then begin
    _GetSelectedVMData(ses,input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Start(vmkey);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StopVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var   vmc     : IFOS_VM_HOST_CONTROL;
      vmkey   : string;
      vncp    : string;
      vnch    : string;
      vmstate : string;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','STOP VM',fdbmt_info);
  //exit;
  if input.FieldExists('SELECTED') then begin
    _GetSelectedVMData(ses,input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Halt(vmkey);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StopVMF(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var   vmc     : IFOS_VM_HOST_CONTROL;
      vmkey   : string;
      vncp    : string;
      vnch    : string;
      vmstate : string;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  if input.FieldExists('SELECTED') then begin
    _GetSelectedVMData(ses,input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Halt(vmkey,true);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_UpdateVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vmc : IFOS_VM_HOST_CONTROL;
  vmo : IFRE_DB_Object;
  vmcc: IFRE_DB_COLLECTION;
begin
  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  writeln('GET - UPDATE DATA');
  vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  vmc.VM_ListMachines(vmo);
  writeln('GOT - UPDATE DATA1');
  vmc.Finalize;
  writeln('GOT - UPDATE DATA2');
  vmcc := conn.Collection('virtualmachine',false);
  writeln('START COLL UPDATE');
  VM_UpdateCollection(conn,vmcc,vmo,TFRE_DB_VMACHINE.ClassName,TFRE_DB_ZONE.ClassName);
  writeln('DONE COLL UPDATE');
  Result := GFRE_DB_NIL_DESC;
end;

end.

