unit fos_firmbox_vm_machines_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FOS_VM_CONTROL_INTERFACE,
  fre_hal_schemes,fre_zfs,
  fre_system,
  fre_dbbusiness,
  FRE_DB_COMMON;

const

  CFRE_DB_VM_DISKS_COLLECTION      = 'VM_DISKS';
  CFRE_DB_VM_ISOS_COLLECTION       = 'VM_ISOS';

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
    function  _addVMChooseZone          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    procedure _cleanupAddModifyVMTmpData(const ses: IFRE_DB_Usersession);
    function  _addModifyVM              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; isModify: Boolean):IFRE_DB_Object;
  protected
    procedure       SetupAppModuleStructure         ; override;
  public
    class procedure InstallDBObjects                (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects            (const conn:IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    function  canAddVM                              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
    function  canModifyVM                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const service: TFRE_DB_VMACHINE): Boolean;
  published
    class procedure RegisterSystemScheme            (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       MySessionInitializeModule       (const session   : TFRE_DB_UserSession);override;
    function  WEB_VM_Feed_Update                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_Content                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function  WEB_VM_ShowInfo                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowVNC                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowPerf                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_ContentNote                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VMSC                              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_Details                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddVM                             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_ModifyVM                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddModifyVMCleanup                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddModifyVMConfigureNetwork       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddModifyVMConfigureNetworkStore  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddModifyVMConfigureNetworkCleanup(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StoreVM                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StartVM                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVM                            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVMF                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_RESOURCES_MOD }

  TFRE_FIRMBOX_VM_RESOURCES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure   ; override;
  public
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects      (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
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
    procedure       SetupAppModuleStructure   ; override;
  public
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_DatalinkContent       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkMenu          (const input:IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkCreateStub    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_DISK }

  TFRE_FIRMBOX_VM_DISK = class (TFRE_DB_ObjectEx)
  public
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_FIRMBOX_VM_ISO }

  TFRE_FIRMBOX_VM_ISO = class (TFRE_DB_ObjectEx)
  public
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_dbbusiness.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_MACHINES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_RESOURCES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_NETWORK_MOD);

  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_DISK);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_ISO);
  //GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_VM_ISO }

class procedure TFRE_FIRMBOX_VM_ISO.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddSchemeField('isoid',fdbft_String).required:=true;
  scheme.AddSchemeField('name',fdbft_String).required:=true;

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('isoid',GetTranslateableTextKey('scheme_id'));
  group.AddInput('name',GetTranslateableTextKey('scheme_name'));
end;

class procedure TFRE_FIRMBOX_VM_ISO.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_id','ID');
    StoreTranslateableText(conn,'scheme_name','Name');
  end;
   
end;

{ TFRE_FIRMBOX_VM_DISK }

class procedure TFRE_FIRMBOX_VM_DISK.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddSchemeField('diskid',fdbft_String).required:=true;
  scheme.AddSchemeField('name',fdbft_String).required:=true;

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('diskid',GetTranslateableTextKey('scheme_id'));
  group.AddInput('name',GetTranslateableTextKey('scheme_name'));
end;

class procedure TFRE_FIRMBOX_VM_DISK.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_id','ID');
    StoreTranslateableText(conn,'scheme_name','Name');
  end;
   
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
  InitModuleDesc('vm_resources_description');
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
    tr_Grid.AddOneToOnescheme('name','',FetchModuleTextShort(session,'gc_iso_name'));

    isosp := conn.GetCollection('VM_ISOS');
    isos:= session.NewDerivedCollection('VM_ISOS_DERIVED');
    with isos do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[],'');
      SetDeriveParent(isosp);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);
    tr_Grid.AddOneToOnescheme('name','',FetchModuleTextShort(session,'gc_disk_name'));

    diskp := conn.GetCollection('VM_DISKS');
    disks:= session.NewDerivedCollection('VM_DISKS_DERIVED');
    with disks do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[],'');
      SetDeriveParent(diskp);
    end;
  end;
end;

class procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';
  if currentVersionId='' then begin
    currentVersionId := '0.9';

    CreateModuleText(conn,'vm_resources_disks','Disks');
    CreateModuleText(conn,'vm_resources_isos','ISOs');
    CreateModuleText(conn,'vm_resources_add_disk','Create','','Create a new disk');
    CreateModuleText(conn,'vm_resources_delete_disk','Remove','','Remove selected disk');
    CreateModuleText(conn,'vm_resources_add_iso','Upload','','Upload a new ISO');
    CreateModuleText(conn,'vm_resources_delete_iso','Remove','','Remove selected ISO');

    CreateModuleText(conn,'gc_disk_name','Disk name');
    CreateModuleText(conn,'gc_iso_name','ISO name');

    CreateModuleText(conn,'disk_add_diag_cap','Create Disk');
    CreateModuleText(conn,'iso_upload_diag_cap','Upload ISO');
  end;
end;

class procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
var
  coll: IFRE_DB_COLLECTION;
begin
  inherited InstallUserDBObjects(conn, currentVersionId);
   if currentVersionId='' then begin
     currentVersionId:='0.9';
     coll:=conn.CreateCollection(CFRE_DB_VM_ISOS_COLLECTION);
     coll.DefineIndexOnField('isoid',fdbft_String,true,true);

     coll:=conn.CreateCollection(CFRE_DB_VM_DISKS_COLLECTION);
     coll.DefineIndexOnField('diskid',fdbft_String,true,true);
   end;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  res.AddSection.Describe(CWSF(@WEB_ContentDisks),FetchModuleTextShort(ses,'vm_resources_disks'),1,'DISKS');
  res.AddSection.Describe(CWSF(@WEB_ContentISOs),FetchModuleTextShort(ses,'vm_resources_isos'),2,'ISOS');
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_ContentDisks(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_DISK)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll := ses.FetchDerivedCollection('VM_DISKS_DERIVED');
  res := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res.AddButton.Describe(CWSF(@WEB_CreateDisk),'/images_apps/hal/add_disk.png',FetchModuleTextShort(ses,'vm_resources_add_disk'),FetchModuleTextHint(ses,'vm_resources_add_disk'));
  res.AddButton.Describe(CWSF(@WEB_DeleteDisk),'/images_apps/hal/delete_disk.png',FetchModuleTextShort(ses,'vm_resources_delete_disk'),FetchModuleTextHint(ses,'vm_resources_delete_disk'),fdgbd_multi);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_ContentISOs(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_ISO)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll := ses.FetchDerivedCollection('VM_ISOS_DERIVED');
  res := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res.AddButton.Describe(CWSF(@WEB_UploadISO),'/images_apps/hal/add_iso.png',FetchModuleTextShort(ses,'vm_resources_add_iso'),FetchModuleTextHint(ses,'vm_resources_add_iso'));
  res.AddButton.Describe(CWSF(@WEB_DeleteISO),'/images_apps/hal/delete_iso.png',FetchModuleTextShort(ses,'vm_resources_delete_iso'),FetchModuleTextHint(ses,'vm_resources_delete_iso'),fdgbd_multi);

  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_CreateDisk(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_FORM_DIALOG_DESC;
  scheme    : IFRE_DB_SchemeObject;
  serverFunc: TFRE_DB_SERVER_FUNC_DESC;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_FIRMBOX_VM_DISK)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GFRE_DBI.GetSystemSchemeByName('TFRE_FIRMBOX_VM_DISK',scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'disk_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  serverFunc:=CSCF('TFRE_FIRMBOX_VM_DISK','NewOperation','collection','VM_DISKS');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverFunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_DeleteDisk(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj: IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_FIRMBOX_VM_DISK)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  conn.Fetch(FREDB_H2G(input.Field('SELECTED').AsStringItem[0]),obj);
  Result:=(obj.Implementor_HC as TFRE_FIRMBOX_VM_DISK).Invoke_DBIMI_Method('deleteOperation',input,ses,app,conn);
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_UploadISO(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_FORM_DIALOG_DESC;
  serverFunc: TFRE_DB_SERVER_FUNC_DESC;
  scheme: IFRE_DB_SchemeObject;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_FIRMBOX_VM_ISO)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GFRE_DBI.GetSystemSchemeByName('TFRE_FIRMBOX_VM_ISO',scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'iso_upload_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  serverFunc:=CSCF('TFRE_FIRMBOX_VM_ISO','NewOperation','collection','VM_ISOS');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverFunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_DeleteISO(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj: IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_FIRMBOX_VM_ISO)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  conn.Fetch(FREDB_H2G(input.Field('SELECTED').AsStringItem[0]),obj);
  Result:=(obj.Implementor_HC as TFRE_FIRMBOX_VM_ISO).Invoke_DBIMI_Method('deleteOperation',input,ses,app,conn);
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
  InitModuleDesc('vnetwork_description');
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
      //AddOneToOnescheme('icon','',app.FetchAppTextShort(conn,'datalink_icon'),dt_icon);
      AddOneToOnescheme('objname','linkname',app.FetchAppTextShort(session,'datalink_name'),dt_string,true,false,false,true,1,'icon');
//      AddOneToOnescheme('zoned','zoned',app.FetchAppTextShort(conn,'datalink_zoned'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'datalink_desc'));
    end;
    datalink_dc := session.NewDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    with datalink_dc do begin
      SetDeriveParent(conn.GetCollection('datalink'));
      SetDeriveTransformation(datalink_tr_Grid);
      Filters.AddBooleanFieldFilter('showvirtual','showvirtual',true);
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',CWSF(@WEB_DatalinkMenu),nil,CWSF(@WEB_DatalinkContent));
      SetParentToChildLinkField ('<PARENTID');
    end;
  end;
end;

class procedure TFRE_FIRMBOX_VM_NETWORK_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;
end;


function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  grid_datalink   : TFRE_DB_VIEW_LIST_DESC;
  dc_datalink     : IFRE_DB_DERIVED_COLLECTION;
  datalink_content: TFRE_DB_FORM_PANEL_DESC;
  txt             : IFRE_DB_TEXT;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_NETWORK_MOD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  dc_datalink                := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
  grid_datalink              := dc_datalink.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  txt:=app.FetchAppTextFull(ses,'datalink_create_stub');
  grid_datalink.AddButton.Describe(CWSF(@WEB_DatalinkCreateStub),'images_apps/hal/create_stub.png',txt.Getshort,txt.GetHint);
  txt.Finalize;

  datalink_content           := TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'datalink_content_header'));
  datalink_content.contentId :='DATALINK_CONTENT';
  Result                     := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_datalink,datalink_content,nil,nil,nil,true,1,1);
end;

function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_DatalinkContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  dl            : IFRE_DB_Object;
  sel_guid      : TFRE_DB_GUID;

begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_NETWORK_MOD)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    if dc.FetchInDerived(sel_guid,dl) then begin
      GFRE_DBI.GetSystemSchemeByName(dl.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'datalink_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(dl,ses);
      panel.contentId:='DATALINK_CONTENT';
//      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(dl,'saveOperation'),fdbbt_submit);
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'datalink_content_header'));
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
  sel_guid  : TFRE_DB_GUID;
  sclass    : TFRE_DB_NameType;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_DATALINK)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=GFRE_DB_NIL_DESC;
  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    if dc.FetchInDerived(sel_guid,dl) then begin
      sclass := dl.SchemeClass;
      writeln(schemeclass);
      input.Field('add_vnic').AsString    := app.FetchAppTextShort(ses,'datalink_add_vnic');
      input.Field('delete_vnic').AsString := app.FetchAppTextShort(ses,'datalink_delete_vnic');
      input.Field('delete_aggr').AsString := app.FetchAppTextShort(ses,'datalink_delete_aggr');
      input.Field('delete_stub').AsString := app.FetchAppTextShort(ses,'datalink_delete_stub');
      result := dl.Invoke('Menu',input,ses,app,conn);
    end;
  end;
end;

function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_DatalinkCreateStub(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_DATALINK_STUB)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

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
  InitModuleDesc('machines_description');
end;

procedure TFRE_FIRMBOX_VM_MACHINES_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  vmc        : IFRE_DB_DERIVED_COLLECTION;
  app        : TFRE_DB_APPLICATION;
  conn       : IFRE_DB_CONNECTION;
  dc         : IFRE_DB_DERIVED_COLLECTION;
  transform  : IFRE_DB_SIMPLE_TRANSFORM;

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
    app:=GetEmbeddingApp;
    conn := session.GetDBConnection;
    fre_hal_schemes.InitDerivedCollections(session,conn);

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'gc_vm_customer'),true,dt_string,true,true,4,'',FetchModuleTextShort(session,'gc_vm_customer_default_value'),nil,'',false,'domainid');
      AddOneToOnescheme('Objname','',FetchModuleTextShort(session,'gc_vm_name'),dt_string,true,false,false,true,4);
      AddOneToOnescheme('MType','',FetchModuleTextShort(session,'gc_vm_type'));
      AddOneToOnescheme('StateIcon','',FetchModuleTextShort(session,'gc_vm_state'),dt_icon);
      AddOneToOnescheme('PERFPCPU','',FetchModuleTextShort(session,'gc_vm_cpu'),dt_number,true,false,false,true,2);
      AddOneToOnescheme('PERFPMEM','',FetchModuleTextShort(session,'gc_vm_used_mem'),dt_number,true,false,false,true,2);
      AddOneToOnescheme('PERFRSS','',FetchModuleTextShort(session,'gc_vm_paged_mem'),dt_number,true,false,false,true,2);
      AddOneToOnescheme('PERFVSZ','',FetchModuleTextShort(session,'gc_vm_virtual_mem'),dt_number,true,false,false,true,2);
    end;
    vmc  := session.NewDerivedCollection('VM_GRID');
    with VMC do begin
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ColumnResizeable],'',nil,nil,CWSF(@WEB_VMSC));
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      Filters.AddSchemeObjectFilter('service',[TFRE_DB_VMACHINE.ClassName]);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('label');
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_string,true,true,1,'','',nil,'',false,'domainid');
      AddMatchingReferencedField(['TEMPLATEID>TFRE_DB_FBZ_TEMPLATE'],'serviceclasses');
      AddOneToOnescheme('disabledSCs');
      SetSimpleFuncTransformNested(@_setCaption,[FetchModuleTextShort(session,'zone_chooser_value'),FetchModuleTextShort(session,'zone_chooser_value_no_customer')]);
    end;

    dc := session.NewDerivedCollection('VM_ZONE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','domainid','','',TFRE_DB_VMACHINE.ClassName,[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
      Filters.AddStringFieldFilter('serviceclasses','serviceclasses',TFRE_DB_VMACHINE.ClassName,dbft_EXACTVALUEINARRAY);
      Filters.AddStringFieldFilter('disabledSCs','disabledSCs',TFRE_DB_VMACHINE.ClassName,dbft_EXACTVALUEINARRAY,false,true);
    end;
  end;
end;

class procedure TFRE_FIRMBOX_VM_MACHINES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
   newVersionId:='0.9.2';
   if currentVersionId='' then begin
     currentVersionId:='0.9';

     CreateModuleText(conn,'gc_vm_name','Name');
     CreateModuleText(conn,'gc_vm_type','Type');
     CreateModuleText(conn,'gc_vm_state','State');
     CreateModuleText(conn,'gc_vm_cpu','CPU');
     CreateModuleText(conn,'gc_vm_used_mem','Used Mem');
     CreateModuleText(conn,'gc_vm_paged_mem','Paged Mem');
     CreateModuleText(conn,'gc_vm_virtual_mem','Virtual Mem');

     CreateModuleText(conn,'machines_new_vm','New','','New VM');
     CreateModuleText(conn,'machines_start','Start','','Start the selected VM');
     CreateModuleText(conn,'machines_stop','Stop','','Stop the selected VM');
     CreateModuleText(conn,'machines_kill','Kill','','Stop the selected VM (FORCED)');

     CreateModuleText(conn,'vm_new_caption','New Virtual Machine');
     CreateModuleText(conn,'vm_new_save','Create');

     CreateModuleText(conn,'vm_name','Name');
     CreateModuleText(conn,'vm_mem','RAM (kB)');
     CreateModuleText(conn,'vm_cpu','CPUs');
     CreateModuleText(conn,'vm_sc','Sound card');

     CreateModuleText(conn,'vm_ide0','IDE Drive 0');
     CreateModuleText(conn,'vm_ide1','IDE Drive 1');
     CreateModuleText(conn,'vm_ide2','IDE Drive 2');
     CreateModuleText(conn,'vm_ide3','IDE Drive 3');

     CreateModuleText(conn,'vm_ide_type','Type');

     CreateModuleText(conn,'vm_disk_chooser','Disk');
     CreateModuleText(conn,'vm_iso_chooser','ISO (CD/DVD)');

     CreateModuleText(conn,'vm_ide_option_disk','Hard Disk');
     CreateModuleText(conn,'vm_ide_option_iso','Mount ISO CD/DVD');

     CreateModuleText(conn,'vm_upload_iso','Upload ISO file');
     CreateModuleText(conn,'vm_create_new_disk','Create new disk');

     CreateModuleText(conn,'vm_new_disk_name','Disk name');
     CreateModuleText(conn,'vm_new_disk_size','Disk size');

     CreateModuleText(conn,'vm_advanced','Advanced settings');
     CreateModuleText(conn,'vm_keyboard_layout_auto','Automatic');
     CreateModuleText(conn,'vm_keyboard_layout','Keyboard layout');

     CreateModuleText(conn,'machines_no_info','- could not get info -');

     CreateModuleText(conn,'vm_details_config','Configuration');
     CreateModuleText(conn,'vm_details_console','Console');
     CreateModuleText(conn,'vm_details_perf','Performance');
     CreateModuleText(conn,'vm_details_note','Note');
   end;
   if currentVersionId='0.9' then begin
     currentVersionId:='0.9.1';
     DeleteModuleText(conn,'vm_new_save');
     DeleteModuleText(conn,'vm_name');
     DeleteModuleText(conn,'vm_mem');
     DeleteModuleText(conn,'vm_cpu');
     DeleteModuleText(conn,'vm_sc');
     DeleteModuleText(conn,'vm_ide0');
     DeleteModuleText(conn,'vm_ide1');
     DeleteModuleText(conn,'vm_ide2');
     DeleteModuleText(conn,'vm_ide3');
     DeleteModuleText(conn,'vm_ide_type');
     DeleteModuleText(conn,'vm_disk_chooser');
     DeleteModuleText(conn,'vm_iso_chooser');
     DeleteModuleText(conn,'vm_ide_option_disk');
     DeleteModuleText(conn,'vm_ide_option_iso');
     DeleteModuleText(conn,'vm_upload_iso');
     DeleteModuleText(conn,'vm_create_new_disk');
     DeleteModuleText(conn,'vm_new_disk_name');
     DeleteModuleText(conn,'vm_new_disk_size');
     DeleteModuleText(conn,'vm_advanced');
     DeleteModuleText(conn,'vm_keyboard_layout_auto');
     DeleteModuleText(conn,'vm_keyboard_layout');

     CreateModuleText(conn,'gc_vm_customer','Customer');
     CreateModuleText(conn,'gc_vm_customer_default_value','No Customer assigned');
     CreateModuleText(conn,'zone_chooser_label','Zone');
     CreateModuleText(conn,'vm_create_error_exists_cap','Error: Add VM Service');
     CreateModuleText(conn,'vm_create_error_exists_msg','A VM with the given name already exists in the choosen zone!');
     CreateModuleText(conn,'zone_chooser_value','%zone_str% (%customer_str%)');
     CreateModuleText(conn,'zone_chooser_value_no_customer','%zone_str%');

     CreateModuleText(conn,'vm_create_error_cap','Error: Add VM Service');
     CreateModuleText(conn,'vm_create_error_msg_cpu_config','Cores * Threads * Sockets can not exceed 64.');
     CreateModuleText(conn,'vm_create_error_msg_net_interface_used','Each network interface can be used only once.');
     CreateModuleText(conn,'vm_create_error_msg_net_interface_used_by_vm','The VNIC %vnic_str% is already used by another VM.');

     CreateModuleText(conn,'vm_form_network_group','Network');
     CreateModuleText(conn,'vm_form_network_1','Interface 1');
     CreateModuleText(conn,'vm_form_network_2','Interface 2');
     CreateModuleText(conn,'vm_form_network_3','Interface 3');
     CreateModuleText(conn,'vm_form_network_4','Interface 4');

     CreateModuleText(conn,'vm_form_network_advanced_button','Advanced');
     CreateModuleText(conn,'vm_form_network_advanced_diag_cap','Advanced Network Settings');
     CreateModuleText(conn,'vm_form_network_advanced_diag_ok','OK');

     CreateModuleText(conn,'vm_form_network_advanced_ip_net','IP/Subnet');
     CreateModuleText(conn,'vm_form_network_advanced_gateway','Gateway');
     CreateModuleText(conn,'vm_form_network_advanced_dns1','DNS1');
     CreateModuleText(conn,'vm_form_network_advanced_dns2','DNS2');
     CreateModuleText(conn,'vm_form_network_advanced_hostname','Hostname');

     CreateModuleText(conn,'vm_form_drives_group','Drives');
     CreateModuleText(conn,'vm_form_hdd1','Hard Disk 1');
     CreateModuleText(conn,'vm_form_hdd2','Hard Disk 2');
     CreateModuleText(conn,'vm_form_hdd3','Hard Disk 3');
     CreateModuleText(conn,'vm_form_hdd4','Hard Disk 4');
     CreateModuleText(conn,'vm_form_hdd5','Hard Disk 5');
     CreateModuleText(conn,'vm_form_hdd6','Hard Disk 6');
     CreateModuleText(conn,'vm_form_hdd7','Hard Disk 7');
     CreateModuleText(conn,'vm_form_hdd8','Hard Disk 8');

     CreateModuleText(conn,'vm_form_hdd_new_option','New');
     CreateModuleText(conn,'vm_form_hdd_new_caption','Caption');
     CreateModuleText(conn,'vm_form_hdd_new_size','Size (GB)');

     CreateModuleText(conn,'vm_form_cd1','CD Rom 1');
     CreateModuleText(conn,'vm_form_cd2','CD Rom 2');

     CreateModuleText(conn,'vm_form_usb','USB Stick');

     CreateModuleText(conn,'vm_form_floppy1','Floppy A');
     CreateModuleText(conn,'vm_form_floppy2','Floppy B');
   end;
   if currentVersionId='0.9.1' then begin
     currentVersionId:='0.9.2';
     CreateModuleText(conn,'machines_modify_vm','Modify','','Modify VM');
     CreateModuleText(conn,'vm_modify_caption','Modfiy Virtual Machine');
     DeleteModuleText(conn,'vm_form_network_advanced_ip_net');
     CreateModuleText(conn,'vm_form_network_advanced_ip','IP');
   end;
end;

class procedure TFRE_FIRMBOX_VM_MACHINES_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  inherited InstallUserDBObjects(conn, currentVersionId);
   if currentVersionId='' then begin
     currentVersionId:='0.9';
   end;
   if conn.CollectionExists('VIRTUAL_MACHINE') then begin
     conn.DeleteCollection('VIRTUAL_MACHINE');
   end;
   if conn.CollectionExists('VM_SOUND_CARDS') then begin
     conn.DeleteCollection('VM_SOUND_CARDS');
   end;
   if conn.CollectionExists('VM_KEYBOARDS') then begin
     conn.DeleteCollection('VM_KEYBOARDS');
   end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_Feed_Update(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  GFRE_DBI.LogInfo(dblc_APPLICATION,'START FEED UPDATE');
  VM_UpdateCollection(conn,conn.GetCollection(CFOS_DB_SERVICES_COLLECTION),input.CloneToNewObject(),TFRE_DB_VMACHINE.ClassName,TFRE_DB_ZONE.ClassName);
  GFRE_DBI.LogInfo(dblc_APPLICATION,'START FEED UPDATE DONE');
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  coll   : IFRE_DB_DERIVED_COLLECTION;
  list   : TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  coll := ses.FetchDerivedCollection('VM_GRID');
  list := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE) then begin
    list.AddButton.Describe(CWSF(@WEB_AddVM), '',FetchModuleTextShort(ses,'machines_new_vm'),FetchModuleTextHint(ses,'machines_new_vm'));
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then begin
    list.AddButton.DescribeManualType('modify_vm',CWSF(@WEB_ModifyVM)         , '',FetchModuleTextShort(ses,'machines_modify_vm'),FetchModuleTextHint(ses,'machines_modify_vm'),true);
    list.AddButton.DescribeManualType('start_vm',CWSF(@WEB_StartVM)       , '',FetchModuleTextShort(ses,'machines_start'),FetchModuleTextHint(ses,'machines_start'),true);
    list.AddButton.DescribeManualType('stop_vm',CWSF(@WEB_StopVM)        , '',FetchModuleTextShort(ses,'machines_stop'),FetchModuleTextHint(ses,'machines_stop'),true);
    list.AddButton.DescribeManualType('kill_vm',CWSF(@WEB_StopVMF)       , '',FetchModuleTextShort(ses,'machines_kill'),FetchModuleTextHint(ses,'machines_kill'),true);
  end;
  Result := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(list,nil,nil,nil,nil,true,2);
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowInfo(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var vmcc  : IFRE_DB_COLLECTION;
    vmkey : string;
      obj : IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  vmkey := input.Field('vmkey').AsString;
  vmcc  := conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  if vmcc.GetIndexedObj(vmkey,obj) then begin
    result := TFRE_DB_HTML_DESC.create.Describe(FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+obj.DumpToString+'</pre>'));
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'machines_no_info'));
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowVNC(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vmkey              : string;
  vmcc               : IFRE_DB_COLLECTION;
  obj                : IFRE_DB_Object;
  vhObj              : TFRE_DB_VHOST;
  urlSep             : TFOSStringArray;
  prot,host,port,path: String;
  tmp                : String;
  i                  : Integer;
  vmObj              : TFRE_DB_VMACHINE;
begin
  CheckClassVisibility4MyDomain(ses);       //FIXXME
  vmkey  := input.Field('uniquephysicalid').AsString;
  VMCC := conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  if vmcc.GetIndexedObj(vmkey,obj) then begin
    vhObj:=obj.Implementor_HC as TFRE_DB_VHOST;
    if true then begin //UpperCase(vmObj.state)='RUNNING' then begin
      if vhObj is TFRE_DB_VMACHINE then begin
        vmObj:=vhObj as TFRE_DB_VMACHINE;
        result := TFRE_DB_VNC_DESC.create.Describe(vmObj.vncHost,vmObj.vncPort);
      end else begin
        tmp:=vmObj.Field('SHELL').AsString;
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
      result := TFRE_DB_HTML_DESC.create.Describe(FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+vmObj.DumpToString+'</pre>'));
    end;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'machines_no_info'));
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowPerf(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  result := TFRE_DB_HTML_DESC.create.Describe('Feature disabled in Demo Mode.'); //FIXXME: please implement me
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_ContentNote(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  load_func             : TFRE_DB_SERVER_FUNC_DESC;
  save_func             : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_NOTE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  writeln('CONTENTNOTE');
  writeln(input.DumpToString);

  load_func   := CWSF(@WEB_NoteLoad);
  save_func   := CWSF(@WEB_NoteSave);
  load_func.AddParam.Describe('linkid',input.Field('linkid').asstring);
  save_func.AddParam.Describe('linkid',input.Field('linkid').asstring);

  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CWSF(@WEB_NoteStartEdit),CWSF(@WEB_NoteStopEdit));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VMSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  startDisabled : Boolean;
  stopDisabled  : Boolean;
  killDisabled  : Boolean;
  modifyDisabled: Boolean;
  service       : TFRE_DB_VMACHINE;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  startDisabled:=true;
  stopDisabled:=true;
  killDisabled:=true;
  modifyDisabled:=true;
  ses.GetSessionModuleData(ClassName).Field('selectedVM').AsStringArr:=input.Field('selected').AsStringArr;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_VMACHINE,service));
    if canModifyVM(input,ses,app,conn,service) then begin
      modifyDisabled:=false;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_VMACHINE,service.DomainID) then begin
      startDisabled:=false;
      stopDisabled:=false;
      killDisabled:=false;
    end;
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('modify_vm',modifyDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('start_vm',startDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('stop_vm',stopDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('kill_vm',killDisabled));

  Result:=WEB_VM_Details(input,ses,app,conn);
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_Details(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var   vm_sub       : TFRE_DB_SUBSECTIONS_DESC;
      sf           : TFRE_DB_SERVER_FUNC_DESC;
      vmo          : TFRE_DB_VMACHINE;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedVM') and (ses.GetSessionModuleData(ClassName).Field('selectedVM').ValueCount=1)  then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedVM').AsString),TFRE_DB_VMACHINE,vmo));
    vm_sub := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
    sf := CWSF(@WEB_VM_ShowInfo); sf.AddParam.Describe('uniquephysicalid',vmo.Field('uniquephysicalid').AsString);
    vm_sub.AddSection.Describe(sf,FetchModuleTextShort(ses,'vm_details_config'),2);
    if vmo.vncHost<>'' then
      begin
        sf := CWSF(@WEB_VM_ShowVNC); sf.AddParam.Describe('uniquephysicalid',vmo.Field('uniquephysicalid').AsString);
        vm_sub.AddSection.Describe(sf,FetchModuleTextShort(ses,'vm_details_console'),1);
      end;
    vm_sub.AddSection.Describe(CWSF(@WEB_VM_ShowPerf),FetchModuleTextShort(ses,'vm_details_perf'),3);
    sf := CWSF(@WEB_ContentNote); sf.AddParam.Describe('linkid',ses.GetSessionModuleData(ClassName).Field('selectedVM').AsString);
    vm_sub.AddSection.Describe(sf,FetchModuleTextShort(ses,'vm_details_note'),4);
    result := vm_sub;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('');
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  Result:=_addModifyVM(input,ses,app,conn,false);
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_ModifyVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_addModifyVM(input,ses,app,conn,true);
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddModifyVMCleanup(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);
  _cleanupAddModifyVMTmpData(ses);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD._addVMChooseZone(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_FORM_DIALOG_DESC;
  sf : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'vm_new_caption'),600,true,true,false);

  sf:=CWSF(@WEB_AddVM);

  res.AddChooser.Describe(FetchModuleTextShort(ses,'zone_chooser_label'),'zone',ses.FetchDerivedCollection('VM_ZONE_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

procedure TFRE_FIRMBOX_VM_MACHINES_MOD._cleanupAddModifyVMTmpData(const ses: IFRE_DB_Usersession);
var
  i: Integer;
begin
  for i := 1 to 4 do begin
    ses.GetSessionModuleData(ClassName).DeleteField('AddVMNC_net' + IntToStr(i));
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD._addModifyVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; isModify: Boolean): IFRE_DB_Object;
var
  group                : TFRE_DB_INPUT_GROUP_DESC;
  sf,cusf              : TFRE_DB_SERVER_FUNC_DESC;
  scheme               : IFRE_DB_SchemeObject;
  res                  : TFRE_DB_FORM_DIALOG_DESC;
  dc                   : IFRE_DB_DERIVED_COLLECTION;
  ch                   : TFRE_DB_INPUT_CHOOSER_DESC;
  block                : TFRE_DB_INPUT_BLOCK_DESC;
  nicScheme            : IFRE_DB_SchemeObject;
  button               : TFRE_DB_INPUT_BUTTON_DESC;
  zone                 : TFRE_DB_ZONE;
  diskScheme           : IFRE_DB_SchemeObject;
  i                    : Integer;
  idx_str              : String;
  service              : TFRE_DB_VMACHINE;
  zoneId               : TFRE_DB_GUID;
  netObj               : IFRE_DB_Object;
  cdbo                 : IFRE_DB_Object;
  diskObj              : IFRE_DB_Object;
  caption: TFRE_DB_String;
begin
  CheckClassVisibility4MyDomain(ses);

  _cleanupAddModifyVMTmpData(ses);

  sf:=CWSF(@WEB_StoreVM);

  dc:=ses.FetchDerivedCollection(CFRE_DB_VMACHINE_VNIC_CHOOSER_DC);
  if isModify then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedVM').AsString),TFRE_DB_VMACHINE,service));

    if not canModifyVM(input,ses,app,conn,service) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    zoneId:=service.Field('zoneid').AsObjectLink;

    dc.Filters.RemoveFilter('used');
    dc.Filters.AddUIDFieldFilter('used','vmid',[service.UID,CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
    sf.AddParam.Describe('serviceId',service.UID_String);

    caption:=FetchModuleTextShort(ses,'vm_modify_caption');
  end else begin
    if input.FieldPathExists('data.zone') then begin
      zoneId:=FREDB_H2G(input.FieldPath('data.zone').AsString);
    end else begin
      if input.FieldExists('zoneId') then begin
        zoneId:=FREDB_H2G(input.Field('zoneId').AsString);
      end else begin
        Result:=_addVMChooseZone(input,ses,app,conn);
        exit;
      end;
    end;
    CheckDbResult(conn.FetchAs(zoneId,TFRE_DB_ZONE,zone));

    if not canAddVM(input,ses,app,conn,zone) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('zoneId',FREDB_G2H(zoneId));

    dc.Filters.RemoveFilter('used');
    dc.Filters.AddUIDFieldFilter('used','vmid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);

    caption:=FetchModuleTextShort(ses,'vm_new_caption');
  end;
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(caption,600,false,true,false);
  dc.Filters.RemoveFilter('zone');
  dc.Filters.AddUIDFieldFilter('zone','zid',[zoneId],dbnf_OneValueFromFilter);
  dc:=ses.FetchDerivedCollection(CFRE_DB_VMACHINE_HDD_CHOOSER_DC);
  dc.Filters.RemoveFilter('zone');
  dc.Filters.AddUIDFieldFilter('zone','zid',[zoneId],dbnf_OneValueFromFilter);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  sf:=CWSF(@WEB_AddModifyVMCleanup);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('close')),sf,fdbbt_close);

  GetSystemScheme(TFRE_DB_VMACHINE,scheme);
  GetSystemScheme(TFRE_DB_VMACHINE_NIC,nicScheme);
  GetSystemScheme(TFRE_DB_VMACHINE_DISK,diskScheme);
  group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,true,false);

  //NETWORK
  group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_form_network_group'),true,false);

  for i := 0 to 3 do begin
    idx_str:=IntToStr(i+1);
    block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_network_'+idx_str),'net'+idx_str);
    block.AddSchemeFormGroupInputs(nicScheme.GetInputGroup('main'),ses,[],'net'+idx_str,false);
    sf:=CWSF(@WEB_AddModifyVMConfigureNetwork);
    sf.AddParam.Describe('id','net'+idx_str);
    cusf:=CWSF(@WEB_AddModifyVMConfigureNetworkCleanup);
    cusf.AddParam.Describe('id','net'+idx_str);
    button:=block.AddInputButton(5).Describe('',FetchModuleTextShort(ses,'vm_form_network_advanced_button'),sf,false,cusf);
    ch:=(block.GetFormElement('net'+idx_str+'.nic').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
    if (i<3) then begin
      ch.addDependentInput('net'+IntToStr(i+2),'',fdv_hidden);
    end;
    ch.AddDependence(button.contentId,false);
  end;

  //DRIVES
  group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_form_drives_group'),true,false);

  for i := 0 to 7 do begin
    idx_str:=IntToStr(i+1);
    block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_hdd'+idx_str),'hdd'+idx_str);
    block.AddSchemeFormGroupInputs(diskScheme.GetInputGroup('main_hdd'),ses,[],'hdd'+idx_str,false);
    res.SetElementGroupRequired('hdd'+idx_str+'.hdd_type');
    ch:=(block.GetFormElement('hdd'+idx_str+'.file').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
    if (i<7) then begin
      ch.addDependentInput('hdd'+IntToStr(i+2),'',fdv_hidden);
    end;
    ch.addDependentInput('hdd'+idx_str+'_new','_new_',fdv_visible);
    block:=group.AddBlock.Describe('','hdd'+idx_str+'_new',true);
    block.AddInput().Describe(FetchModuleTextShort(ses,'vm_form_hdd_new_caption'),'hdd'+idx_str+'.cap',true);
    block.AddNumber().Describe(FetchModuleTextShort(ses,'vm_form_hdd_new_size'),'hdd'+idx_str+'.size',true,false,false,false,'',0);
  end;
  //add new option once since it is always the same store within the form
  ch.addOption(FetchModuleTextShort(ses,'vm_form_hdd_new_option'),'_new_');

  for i := 0 to 1 do begin
    idx_str:=IntToStr(i+1);
    block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_cd'+idx_str),'cd'+idx_str);
    block.AddSchemeFormGroupInputs(diskScheme.GetInputGroup('main'),ses,[],'cd'+idx_str,false);
    if (i=0) then begin
      ch:=(block.GetFormElement('cd'+idx_str+'.file').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
      ch.addDependentInput('cd'+IntToStr(i+2),'',fdv_hidden);
    end;
  end;

  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_usb'),'usb');
  block.AddSchemeFormGroupInputs(diskScheme.GetInputGroup('main'),ses,[],'usb',false);

  for i := 0 to 1 do begin
    idx_str:=IntToStr(i+1);
    block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_floppy'+idx_str),'floppy'+idx_str);
    block.AddSchemeFormGroupInputs(diskScheme.GetInputGroup('main'),ses,[],'floppy'+idx_str,false);
    if (i=0) then begin
      ch:=(block.GetFormElement('floppy'+idx_str+'.file').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
      ch.addDependentInput('floppy'+IntToStr(i+2),'',fdv_hidden);
    end;
  end;

  //ADVANCED
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);

  //FILL
  if isModify then begin
    res.FillWithObjectValues(service,ses);

    //NETWORK
    for i := 0 to service.Field('interface').ValueCount - 1 do begin
      CheckDbResult(conn.Fetch(service.Field('interface').AsObjectLinkItem[i],netObj));
      idx_str:=IntToStr(i+1);
      res.FillWithObjectValues(netObj,ses,'net'+idx_str);
      ses.GetSessionModuleData(ClassName).FieldPathCreate('AddVMNC_net' + idx_str+'.hostname').AsString:=netObj.Field('hostname').AsString;
      if netObj.FieldExists('ip') then begin
        conn.Fetch(netObj.Field('ip').AsObjectLink,cdbo);
        ses.GetSessionModuleData(ClassName).FieldPathCreate('AddVMNC_net' + idx_str+'.ip').AsString:=cdbo.Field('ip').AsString;
      end;
      if netObj.FieldExists('gateway') then begin
        conn.Fetch(netObj.Field('gateway').AsObjectLink,cdbo);
        ses.GetSessionModuleData(ClassName).FieldPathCreate('AddVMNC_net' + idx_str+'.gateway').AsString:=cdbo.Field('ip').AsString;
      end;
      if netObj.FieldExists('dns1') then begin
        conn.Fetch(netObj.Field('dns1').AsObjectLink,cdbo);
        ses.GetSessionModuleData(ClassName).FieldPathCreate('AddVMNC_net' + idx_str+'.dns1').AsString:=cdbo.Field('ip').AsString;
      end;
      if netObj.FieldExists('dns2') then begin
        conn.Fetch(netObj.Field('dns2').AsObjectLink,cdbo);
        ses.GetSessionModuleData(ClassName).FieldPathCreate('AddVMNC_net' + idx_str+'.dns2').AsString:=cdbo.Field('ip').AsString;
      end;
    end;
    //DRIVES
    for i := 0 to service.Field('hdd').ValueCount - 1 do begin
      CheckDbResult(conn.Fetch(service.Field('hdd').AsObjectLinkItem[i],diskObj));
      idx_str:=IntToStr(i+1);
      res.FillWithObjectValues(diskObj,ses,'hdd'+idx_str);
    end;
    for i := 0 to service.Field('cd').ValueCount - 1 do begin
      CheckDbResult(conn.Fetch(service.Field('cd').AsObjectLinkItem[i],diskObj));
      idx_str:=IntToStr(i+1);
      res.FillWithObjectValues(diskObj,ses,'cd'+idx_str);
    end;
    for i := 0 to service.Field('usb').ValueCount - 1 do begin
      CheckDbResult(conn.Fetch(service.Field('usb').AsObjectLinkItem[i],diskObj));
      idx_str:=IntToStr(i+1);
      res.FillWithObjectValues(diskObj,ses,'usb'+idx_str);
    end;
    for i := 0 to service.Field('floppy').ValueCount - 1 do begin
      CheckDbResult(conn.Fetch(service.Field('floppy').AsObjectLinkItem[i],diskObj));
      idx_str:=IntToStr(i+1);
      res.FillWithObjectValues(diskObj,ses,'floppy'+idx_str);
    end;

  end else begin
    res.SetElementValue('cores','1');
    res.SetElementValue('threads','1');
    res.SetElementValue('sockets','1');
    (res.GetFormElement('ram').Implementor_HC as TFRE_DB_INPUT_NUMBER_DESC).setMinMax(getMinimumRAM,getAvailableRAM);
    res.SetElementValue('ram',IntToStr(getMinimumRAM));
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.canAddVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
begin
  Result:=(conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE,zone.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE_NIC,zone.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,zone.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE_DISK,zone.DomainID));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.canModifyVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const service: TFRE_DB_VMACHINE): Boolean;
begin
  Result:=(conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_VMACHINE,service.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE_NIC,service.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VMACHINE_NIC,service.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4,service.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_IPV4,service.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE_DISK,service.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VMACHINE_DISK,service.DomainID));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddModifyVMConfigureNetwork(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res      : TFRE_DB_FORM_DIALOG_DESC;
  scheme   : IFRE_DB_SchemeObject;
  sf       : TFRE_DB_SERVER_FUNC_DESC;
  validator: IFRE_DB_ClientFieldValidator;
begin
  CheckClassVisibility4MyDomain(ses);

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_diag_cap'),600,true,true,false);

  GetSystemScheme(TFRE_DB_IPV4,scheme);
  res.AddInput.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_hostname'),'hostname'); //FIXXME - use chooser
  GFRE_DBI.GetSystemClientFieldValidator('ip',validator);
  res.AddInput.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_ip'),'ip',false,false,false,false,'',validator);
  res.AddInput.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_gateway'),'gateway',false,false,false,false,'',validator);
  res.AddInput.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_dns1'),'dns1',false,false,false,false,'',validator);
  res.AddInput.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_dns2'),'dns2',false,false,false,false,'',validator);

  sf:=CWSF(@WEB_AddModifyVMConfigureNetworkStore);
  sf.AddParam.Describe('id',input.Field('id').AsString);
  res.AddButton.Describe(FetchModuleTextShort(ses,'vm_form_network_advanced_diag_ok'),sf,fdbbt_submit);

  if ses.GetSessionModuleData(ClassName).FieldExists('AddVMNC_' + input.Field('id').AsString) then begin
    res.FillWithObjectValues(ses.GetSessionModuleData(ClassName).Field('AddVMNC_' + input.Field('id').AsString).AsObject,ses);
  end;

  Result:=res;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddModifyVMConfigureNetworkStore(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  ses.GetSessionModuleData(ClassName).Field('AddVMNC_' + input.Field('id').AsString).AsObject:=input.Field('data').AsObject.CloneToNewObject();
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddModifyVMConfigureNetworkCleanup(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  ses.GetSessionModuleData(ClassName).DeleteField('AddVMNC_' + input.Field('id').AsString);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StoreVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll,compsColl   : IFRE_DB_COLLECTION;
  vmService        : TFRE_DB_VMACHINE;
  zone             : TFRE_DB_ZONE;
  idx              : String;
  schemeObject     : IFRE_DB_SchemeObject;
  data             : IFRE_DB_Object;
  i,j              : Integer;
  netInterfaces    : TFRE_DB_GUIDArray;
  netInterfaceObjs : IFRE_DB_ObjectArray;
  hddObjs          : IFRE_DB_ObjectArray;
  cdObjs           : IFRE_DB_ObjectArray;
  usbObjs          : IFRE_DB_ObjectArray;
  floppyObjs       : IFRE_DB_ObjectArray;
  interfaceGuid    : TFRE_DB_GUID;
  netObj           : IFRE_DB_Object;
  nicScheme        : IFRE_DB_SchemeObject;
  nicObj           : TFRE_DB_VMACHINE_NIC;
  configObj        : IFRE_DB_Object;
  ip               : TFRE_DB_IPV4;
  ipScheme         : IFRE_DB_SchemeObject;
  hnColl           : IFRE_DB_COLLECTION;
  idx_str          : String;
  diskObj          : TFRE_DB_VMACHINE_DISK;
  diskScheme       : IFRE_DB_SchemeObject;
  isModify         : Boolean;
  vnic             : IFRE_DB_Object;
  refs             : TFRE_DB_GUIDArray;
  vnicConf         : IFRE_DB_ObjectArray;
  interfaceArray   : TFRE_DB_ObjLinkArray;
  hddArray         : TFRE_DB_ObjLinkArray;
  cdArray          : TFRE_DB_ObjLinkArray;
  usbArray         : TFRE_DB_ObjLinkArray;
  floppyArray      : TFRE_DB_ObjLinkArray;
  ipDbo            : IFRE_DB_ObjectArray;
begin
  coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  data:=input.Field('data').AsObject;
  if input.FieldExists('serviceId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('serviceId').AsString),TFRE_DB_VMACHINE,vmService));

    if not canModifyVM(input,ses,app,conn,vmService) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    CheckDbResult(conn.FetchAs(vmService.Field('zoneId').AsObjectLink,TFRE_DB_ZONE,zone));

    if data.FieldExists('objname') and (data.Field('objname').AsString<>vmService.ObjectName) then begin
      idx:=TFRE_DB_VMACHINE.ClassName + '_' + data.Field('objname').AsString + '@' + zone.UID_String;
      vmService.Field('uniquephysicalid').asstring := idx;
      if coll.ExistsIndexedText(idx)<>0 then begin
        Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_exists_cap'),FetchModuleTextShort(ses,'vm_create_error_exists_msg'),fdbmt_error);
        exit;
      end;
    end;

    interfaceArray:=vmService.Field('interface').AsObjectLinkArray;
    vmService.DeleteField('interface');
    hddArray:=vmService.Field('hdd').AsObjectLinkArray;
    vmService.DeleteField('hdd');
    cdArray:=vmService.Field('cd').AsObjectLinkArray;
    vmService.DeleteField('cd');
    usbArray:=vmService.Field('usb').AsObjectLinkArray;
    vmService.DeleteField('usb');
    floppyArray:=vmService.Field('floppy').AsObjectLinkArray;
    vmService.DeleteField('floppy');
    isModify:=true;
  end else begin
    if input.FieldExists('zoneId') then begin
      CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));

      if not canAddVM(input,ses,app,conn,zone) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      vmService:=TFRE_DB_VMACHINE.CreateForDB;
      vmService.SetDomainID(zone.DomainID);
      vmService.Field('serviceParent').AsObjectLink:=zone.UID;
      vmService.Field('zoneid').AsObjectLink:=zone.UID;
      idx:=TFRE_DB_VMACHINE.ClassName + '_' + data.Field('objname').AsString + '@' + zone.UID_String;
      vmService.Field('uniquephysicalid').asstring := idx;
      if coll.ExistsIndexedText(idx)<>0 then begin
        Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_exists_cap'),FetchModuleTextShort(ses,'vm_create_error_exists_msg'),fdbmt_error);
        exit;
      end;

      isModify:=false;
    end else begin
      raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required parameter serviceId or zoneId');
    end;
  end;
  GetSystemScheme(TFRE_DB_VMACHINE,schemeObject);

  compsColl:=conn.GetCollection(CFRE_DB_VM_COMPONENTS_COLLECTION);
  hnColl:=conn.GetCollection(CFRE_DB_IP_COLLECTION);

  GetSystemScheme(TFRE_DB_VMACHINE_NIC,nicScheme);
  GetSystemScheme(TFRE_DB_VMACHINE_DISK,diskScheme);
  GetSystemScheme(TFRE_DB_IPV4,ipScheme);

  //check cpu config
  if (data.Field('cores').AsInt16 * data.Field('threads').AsInt16 * data.Field('sockets').AsInt16>64) then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_cap'),FetchModuleTextShort(ses,'vm_create_error_msg_cpu_config'),fdbmt_error);
    exit;
  end;
  //check network
  SetLength(netInterfaces,0);
  SetLength(netInterfaceObjs,4);
  SetLength(hddObjs,0);
  SetLength(cdObjs,0);
  SetLength(usbObjs,0);
  SetLength(floppyObjs,0);
  for i := 0 to 3 do begin
    idx_str:=IntToStr(i+1);
    netObj:=data.Field('net'+idx_str).AsObject;
    if netObj.FieldExists('nic') and not netObj.Field('nic').IsSpecialClearMarked then begin
      //check if already used
      interfaceGuid:=FREDB_H2G(netObj.Field('nic').AsString);
      for j := 0 to High(netInterfaces) do begin
        if netInterfaces[j]=interfaceGuid then begin
          Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_cap'),FetchModuleTextShort(ses,'vm_create_error_msg_net_interface_used'),fdbmt_error);
          exit;
        end;
      end;
      SetLength(netInterfaces,Length(netInterfaces)+1);
      netInterfaces[Length(netInterfaces)-1]:=interfaceGuid;
      nicObj:=TFRE_DB_VMACHINE_NIC.CreateForDB;
      nicObj.SetDomainID(zone.DomainID);
      nicScheme.SetObjectFieldsWithScheme(netObj,nicObj,true,conn);
      nicObj.Field('uniquephysicalid').asstring := nicObj.Field('nic').AsString + '@' + zone.UID_String;
      netInterfaceObjs[Length(netInterfaces)-1]:=nicObj;
    end;
    data.DeleteField('net'+idx_str);
  end;

  //DRIVES
  for i := 0 to 7 do begin //HDD
    idx_str:=IntToStr(i+1);

    if data.FieldExists('hdd'+idx_str) then begin
      configObj:=data.Field('hdd'+idx_str).AsObject;
      if (configObj.Field('file').AsString = '_new_') then begin
      //create new zvol
      end else begin
        if not configObj.Field('file').IsSpecialClearMarked then begin
          //link existing zvol/file
          diskObj:=TFRE_DB_VMACHINE_DISK.CreateForDB;
          diskObj.SetDomainID(zone.DomainID);
          diskObj.Field('hdd_type').AsString:='disk';
          diskObj.Field('uniquephysicalid').AsString:='hdd'+idx_str+'@'+vmService.UID_String;
          configObj.DeleteField('cap');
          configObj.DeleteField('size');
          diskScheme.SetObjectFieldsWithScheme(configObj,diskObj,true,conn);

          SetLength(hddObjs,Length(hddObjs)+1);
          hddObjs[Length(hddObjs)-1]:=diskObj;
        end;
      end;
    end;
    data.DeleteField('hdd'+idx_str);
  end;

  for i := 0 to 1 do begin //CD
    idx_str:=IntToStr(i+1);

    if data.FieldExists('cd'+idx_str) then begin
      configObj:=data.FieldPath('cd'+idx_str).AsObject;
      if not configObj.Field('file').IsSpecialClearMarked then begin
        //link existing file
        diskObj:=TFRE_DB_VMACHINE_DISK.CreateForDB;
        diskObj.SetDomainID(zone.DomainID);
        diskObj.Field('hdd_type').AsString:='cdrom';
        diskObj.Field('uniquephysicalid').AsString:='cd'+idx_str+'@'+vmService.UID_String;
        diskScheme.SetObjectFieldsWithScheme(configObj,diskObj,true,conn);

        SetLength(cdObjs,Length(cdObjs)+1);
        cdObjs[Length(cdObjs)-1]:=diskObj;
      end;
    end;
    data.DeleteField('cd'+idx_str);
  end;

  //USB
  if data.FieldExists('usb') then begin
    configObj:=data.Field('usb').AsObject;
    if not configObj.Field('file').IsSpecialClearMarked then begin
      //link existing file
      diskObj:=TFRE_DB_VMACHINE_DISK.CreateForDB;
      diskObj.SetDomainID(zone.DomainID);
      diskObj.Field('hdd_type').AsString:='usb';
      diskObj.Field('uniquephysicalid').AsString:='usb@'+vmService.UID_String;
      diskScheme.SetObjectFieldsWithScheme(configObj,diskObj,true,conn);

      SetLength(usbObjs,Length(usbObjs)+1);
      usbObjs[Length(usbObjs)-1]:=diskObj;
    end;
  end;
  data.DeleteField('usb');

  for i := 0 to 1 do begin //Floppy
    idx_str:=IntToStr(i+1);

    if data.FieldExists('floppy'+idx_str) then begin
      configObj:=data.Field('floppy'+idx_str).AsObject;
      if not configObj.Field('file').IsSpecialClearMarked then begin
        //link existing file
        diskObj:=TFRE_DB_VMACHINE_DISK.CreateForDB;
        diskObj.SetDomainID(zone.DomainID);
        diskObj.Field('hdd_type').AsString:='floppy';
        diskObj.Field('uniquephysicalid').AsString:='floppy'+idx_str+'@'+vmService.UID_String;
        diskScheme.SetObjectFieldsWithScheme(configObj,diskObj,true,conn);

        SetLength(floppyObjs,Length(floppyObjs)+1);
        floppyObjs[Length(floppyObjs)-1]:=diskObj;
      end;
    end;
    data.DeleteField('floppy'+idx_str);
  end;

  schemeObject.SetObjectFieldsWithScheme(data,vmService,not isModify,conn);

  for i := 0 to High(netInterfaces) do begin
    if compsColl.GetIndexedObjsFieldval(netInterfaceObjs[i].Field('uniquephysicalid'),vnicConf)>0 then begin
      if isModify then begin
        refs:=conn.GetReferences(vnicConf[0].UID,false,TFRE_DB_VMACHINE.ClassName,'interface');
        if (refs[0]<>vmService.UID) then begin
          CheckDbResult(conn.Fetch(netInterfaceObjs[i].Field('nic').AsObjectLink,vnic));
        end else begin
          vnic:=nil;
        end;
      end else begin
        CheckDbResult(conn.Fetch(netInterfaceObjs[i].Field('nic').AsObjectLink,vnic));
      end;
      if Assigned(vnic) then begin
        Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_cap'),StringReplace(FetchModuleTextShort(ses,'vm_create_error_msg_net_interface_used_by_vm'),'%vnic_str%',vnic.Field('objname').AsString,[rfReplaceAll]),fdbmt_error);
        exit;
      end;
    end;
  end;

  if isModify then begin
    CheckDbResult(conn.Update(vmService.CloneToNewObject()));
    //delete old config
    for i := 0 to High(interfaceArray) do begin
      CheckDbResult(conn.Delete(interfaceArray[i]));
    end;
  end;

  for i := 0 to High(netInterfaces) do begin
    if ses.GetSessionModuleData(ClassName).FieldExists('AddVMNC_net' + IntToStr(i+1)) then begin
      configObj:=ses.GetSessionModuleData(ClassName).Field('AddVMNC_net' + IntToStr(i+1)).AsObject;
      if configObj.FieldExists('hostname') and not configObj.Field('hostname').IsSpecialClearMarked then begin
        netInterfaceObjs[i].Field('hostname').AsString:=configObj.Field('hostname').AsString;
      end;
      if configObj.FieldExists('ip') and not configObj.FieldPath('ip').IsSpecialClearMarked then begin
        if hnColl.GetIndexedObjsFieldval(configObj.FieldPath('ip'),ipDbo,'def',FREDB_G2H(zone.DomainID))>0 then begin
          netInterfaceObjs[i].Field('ip').AsObjectLink:=ipDbo[0].UID;
        end else begin
          ip:=TFRE_DB_IPV4.CreateForDB;
          ip.SetDomainID(zone.DomainID);
          ipScheme.SetObjectFieldsWithScheme(configObj.Field('ip').AsObject,ip,true,conn);
          CheckDbResult(hnColl.Store(ip.CloneToNewObject()));
          netInterfaceObjs[i].Field('ip').AsObjectLink:=ip.UID;
        end;
      end;
      if configObj.FieldExists('gateway') and not configObj.Field('gateway').IsSpecialClearMarked then begin
        if hnColl.GetIndexedObjsFieldval(configObj.Field('gateway'),ipDbo,'def',FREDB_G2H(zone.DomainID))>0 then begin
          netInterfaceObjs[i].Field('gateway').AsObjectLink:=ipDbo[0].UID;
        end else begin
          ip:=TFRE_DB_IPV4.CreateForDB;
          ip.SetDomainID(zone.DomainID);
          ip.Field('ip').AsString:=configObj.Field('gateway').AsString;
          CheckDbResult(hnColl.Store(ip.CloneToNewObject()));
          netInterfaceObjs[i].Field('gateway').AsObjectLink:=ip.UID;
        end;
      end;
      if configObj.FieldExists('dns1') and not configObj.Field('dns1').IsSpecialClearMarked then begin
        if hnColl.GetIndexedObjsFieldval(configObj.Field('dns1'),ipDbo,'def',FREDB_G2H(zone.DomainID))>0 then begin
          netInterfaceObjs[i].Field('dns1').AsObjectLink:=ipDbo[0].UID;
        end else begin
          ip:=TFRE_DB_IPV4.CreateForDB;
          ip.SetDomainID(zone.DomainID);
          ip.Field('ip').AsString:=configObj.Field('dns1').AsString;
          ip.Field('zoneId').AsObjectLink:=zone.UID;
          CheckDbResult(hnColl.Store(ip.CloneToNewObject()));
          netInterfaceObjs[i].Field('dns_ip0').AsObjectLink:=ip.UID;
        end;
      end;
      if configObj.FieldExists('dns2') and not configObj.Field('dns2').IsSpecialClearMarked then begin
        if hnColl.GetIndexedObjsFieldval(configObj.Field('dns2'),ipDbo,'def',FREDB_G2H(zone.DomainID))>0 then begin
          netInterfaceObjs[i].Field('dns2').AsObjectLink:=ipDbo[0].UID;
        end else begin
          ip:=TFRE_DB_IPV4.CreateForDB;
          ip.SetDomainID(zone.DomainID);
          ip.Field('ip').AsString:=configObj.Field('dns2').AsString;
          ip.Field('zoneId').AsObjectLink:=zone.UID;
          CheckDbResult(hnColl.Store(ip.CloneToNewObject()));
          netInterfaceObjs[i].Field('dns_ip1').AsObjectLink:=ip.UID;
        end;
      end;
    end;
    CheckDbResult(compsColl.Store(netInterfaceObjs[i].CloneToNewObject()));
    vmService.Field('interface').AddObjectLink(netInterfaceObjs[i].UID);
  end;

  if isModify then begin
    //delete old config
    for i := 0 to High(hddArray) do begin
      CheckDbResult(conn.Delete(hddArray[i]));
    end;
    for i := 0 to High(cdArray) do begin
      CheckDbResult(conn.Delete(cdArray[i]));
    end;
    for i := 0 to High(usbArray) do begin
      CheckDbResult(conn.Delete(usbArray[i]));
    end;
    for i := 0 to High(floppyArray) do begin
      CheckDbResult(conn.Delete(floppyArray[i]));
    end;
  end;

  //Store disks
  for i := 0 to High(hddObjs) do begin
    CheckDbResult(compsColl.Store(hddObjs[i]));
    vmService.Field('hdd').AddObjectLink(hddObjs[i].UID);
  end;
  for i := 0 to High(cdObjs) do begin
    CheckDbResult(compsColl.Store(cdObjs[i]));
    vmService.Field('cd').AddObjectLink(cdObjs[i].UID);
  end;
  for i := 0 to High(usbObjs) do begin
    CheckDbResult(compsColl.Store(usbObjs[i]));
    vmService.Field('usb').AddObjectLink(usbObjs[i].UID);
  end;
  for i := 0 to High(floppyObjs) do begin
    CheckDbResult(compsColl.Store(floppyObjs[i]));
    vmService.Field('floppy').AddObjectLink(floppyObjs[i].UID);
  end;

  if isModify then begin
    CheckDbResult(conn.Update(vmService.CloneToNewObject()));
  end else begin
    CheckDbResult(coll.Store(vmService.CloneToNewObject()));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StartVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vmc: IFOS_VM_HOST_CONTROL;
  vmo: TFRE_DB_VMACHINE;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','START VM',fdbmt_info);
  //exit;
  if input.FieldExists('SELECTED') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_VMACHINE,vmo));
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Start(vmo.Field('uniquephysicalid').AsString);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StopVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vmc: IFOS_VM_HOST_CONTROL;
  vmo: TFRE_DB_VMACHINE;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','STOP VM',fdbmt_info);
  //exit;
  if input.FieldExists('SELECTED') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_VMACHINE,vmo));
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Halt(vmo.Field('uniquephysicalid').AsString);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_StopVMF(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vmc: IFOS_VM_HOST_CONTROL;
  vmo: TFRE_DB_VMACHINE;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.FieldExists('SELECTED') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_VMACHINE,vmo));
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Halt(vmo.Field('uniquephysicalid').AsString,true);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

end.

