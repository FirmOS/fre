unit fos_firmbox_vm_machines_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FOS_VM_CONTROL_INTERFACE,
  fre_hal_schemes,
  fre_system,
  fre_dbbusiness,
  FRE_DB_COMMON;

const

  //CFRE_DB_VM_COLLECTION            = 'VIRTUAL_MACHINES';
  //CFRE_DB_VM_SC_COLLECTION         = 'VM_SOUND_CARDS';
  //CFRE_DB_VM_KB_COLLECTION         = 'VM_KEYBOARDS';

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
  protected
    procedure       SetupAppModuleStructure   ; override;
  public
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects      (const conn:IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    function  canAddVM                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
  published
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       MySessionInitializeModule (const session   : TFRE_DB_UserSession);override;
    function  WEB_VM_Feed_Update              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_Content                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function  WEB_VM_ShowInfo                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowVNC                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowPerf                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_ContentNote                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VMSC                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_Details                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddVM                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddVMConfigureDrives        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddVMConfigureNetwork       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_AddVMConfigureNetworkCleanup(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_CreateVM                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StartVM                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVM                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVMF                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_RESOURCES_MOD }

  TFRE_FIRMBOX_VM_RESOURCES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  public
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects      (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
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
  public
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkContent       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkMenu          (const input:IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkCreateStub    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_VM_DISK }

  TFRE_FIRMBOX_VM_DISK = class (TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_FIRMBOX_VM_ISO }

  TFRE_FIRMBOX_VM_ISO = class (TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_dbbusiness.Register_DB_Extensions;

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
      AddOneToOnescheme('objname','linkname',app.FetchAppTextShort(session,'datalink_name'),dt_string,true,false,false,1,'icon');
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
  app:=GetEmbeddingApp;
  conn := session.GetDBConnection;

  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'gc_vm_customer'),true,dt_string,true,true,4,'',FetchModuleTextShort(session,'gc_vm_customer_default_value'),nil,false,'domainid');
      AddOneToOnescheme('Objname','',FetchModuleTextShort(session,'gc_vm_name'),dt_string,true,false,false,4);
      AddOneToOnescheme('MType','',FetchModuleTextShort(session,'gc_vm_type'));
      AddOneToOnescheme('StateIcon','',FetchModuleTextShort(session,'gc_vm_state'),dt_icon);
      AddOneToOnescheme('PERFPCPU','',FetchModuleTextShort(session,'gc_vm_cpu'),dt_number,true,false,false,2);
      AddOneToOnescheme('PERFPMEM','',FetchModuleTextShort(session,'gc_vm_used_mem'),dt_number,true,false,false,2);
      AddOneToOnescheme('PERFRSS','',FetchModuleTextShort(session,'gc_vm_paged_mem'),dt_number,true,false,false,2);
      AddOneToOnescheme('PERFVSZ','',FetchModuleTextShort(session,'gc_vm_virtual_mem'),dt_number,true,false,false,2);
    end;
    vmc  := session.NewDerivedCollection('VMC');
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
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_string,true,true,1,'','',nil,false,'domainid');
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

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      //AddMatchingReferencedField(['DATALINKPARENT>>TFRE_DB_ZONE'],'uid','zid','',false);
      AddMatchingReferencedFieldArray(['DATALINKPARENT>>TFRE_DB_ZONE'],'uid','zid','',false);
    end;
    dc := session.NewDerivedCollection(CFRE_DB_VMACHINE_VNIC_CHOOSER_DC);
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      Filters.AddSchemeObjectFilter('type',[TFRE_DB_DATALINK_VNIC.ClassName]);
    end;
  end;
end;

class procedure TFRE_FIRMBOX_VM_MACHINES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
   newVersionId:='0.9.1';
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

     CreateModuleText(conn,'vm_form_network_configure_button','Configure');
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
  text   : IFRE_DB_TEXT;
begin
  CheckClassVisibility4MyDomain(ses);

  coll := ses.FetchDerivedCollection('VMC');
  list := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_VMACHINE) then begin
    text:=FetchModuleTextFull(ses,'machines_new_vm');
    list.AddButton.Describe(CWSF(@WEB_AddVM)         , '',text.Getshort,text.GetHint);
    text.Finalize;
  end;
  text:=FetchModuleTextFull(ses,'machines_start');
  list.AddButton.Describe(CWSF(@WEB_StartVM)       , '',text.Getshort,text.GetHint,fdgbd_single);
  text.Finalize;
  text:=FetchModuleTextFull(ses,'machines_stop');
  list.AddButton.Describe(CWSF(@WEB_StopVM)        , '',text.Getshort,text.GetHint,fdgbd_single);
  text.Finalize;
  text:=FetchModuleTextFull(ses,'machines_kill');
  list.AddButton.Describe(CWSF(@WEB_StopVMF)       , '',text.Getshort,text.GetHint,fdgbd_single);
  text.Finalize;
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
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selectedVM').AsStringArr:=input.Field('selected').AsStringArr;
  Result:=WEB_VM_Details(input,ses,app,conn);
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_Details(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var   vm_sub       : TFRE_DB_SUBSECTIONS_DESC;
      sf           : TFRE_DB_SERVER_FUNC_DESC;
      vmo          : TFRE_DB_VMACHINE;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.FieldExists('selectedVM') and (input.Field('selectedVM').ValueCount>0)  then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selectedVM').AsString),TFRE_DB_VMACHINE,vmo));
    vm_sub := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
    sf := CWSF(@WEB_VM_ShowInfo); sf.AddParam.Describe('uniquephysicalid',vmo.Field('uniquephysicalid').AsString);
    vm_sub.AddSection.Describe(sf,FetchModuleTextShort(ses,'vm_details_config'),2);
    if vmo.vncHost<>'' then
      begin
        sf := CWSF(@WEB_VM_ShowVNC); sf.AddParam.Describe('uniquephysicalid',vmo.Field('uniquephysicalid').AsString);
        vm_sub.AddSection.Describe(sf,FetchModuleTextShort(ses,'vm_details_console'),1);
      end;
    vm_sub.AddSection.Describe(CWSF(@WEB_VM_ShowPerf),FetchModuleTextShort(ses,'vm_details_perf'),3);
    sf := CWSF(@WEB_ContentNote); sf.AddParam.Describe('linkid',input.Field('selectedVM').asstring);
    vm_sub.AddSection.Describe(sf,FetchModuleTextShort(ses,'vm_details_note'),4);
    result := vm_sub;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('');
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddVM(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  idestore             : TFRE_DB_STORE_DESC;
  isostore             : TFRE_DB_STORE_DESC;
  diskstore            : TFRE_DB_STORE_DESC;
  keyboardstore        : TFRE_DB_STORE_DESC;
  vm_disks             : IFRE_DB_DERIVED_COLLECTION;
  vm_isos              : IFRE_DB_DERIVED_COLLECTION;
  chooser              : TFRE_DB_INPUT_CHOOSER_DESC;
  diskchooser          : TFRE_DB_INPUT_CHOOSER_DESC;
  isochooser           : TFRE_DB_INPUT_CHOOSER_DESC;
  group                : TFRE_DB_INPUT_GROUP_DESC;
  sf,cusf              : TFRE_DB_SERVER_FUNC_DESC;
  scheme               : IFRE_DB_SchemeObject;
  res                  : TFRE_DB_FORM_DIALOG_DESC;
  dc                   : IFRE_DB_DERIVED_COLLECTION;
  zoneId               : TFRE_DB_String;
  ch                   : TFRE_DB_INPUT_CHOOSER_DESC;
  block                : TFRE_DB_INPUT_BLOCK_DESC;
  nicScheme            : IFRE_DB_SchemeObject;
  button               : TFRE_DB_INPUT_BUTTON_DESC;
  zone                 : TFRE_DB_ZONE;
begin
  CheckClassVisibility4MyDomain(ses);

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'vm_new_caption'),600,true,true,false);

  sf:=CWSF(@WEB_CreateVM);

  if input.FieldPathExists('data.zone') then begin
    zoneId:=input.FieldPath('data.zone').AsString;
  end else begin
    if input.FieldExists('zoneId') then begin
      zoneId:=input.Field('zoneId').AsString;
    end else begin
      Result:=_addVMChooseZone(input,ses,app,conn);
      exit;
    end;
  end;
  sf.AddParam.Describe('zoneId',zoneId);
  CheckDbResult(conn.FetchAs(FREDB_H2G(zoneId),TFRE_DB_ZONE,zone));

  if not canAddVM(input,ses,app,conn,zone) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  GetSystemScheme(TFRE_DB_VMACHINE,scheme);
  GetSystemScheme(TFRE_DB_VMACHINE_NIC,nicScheme);
  group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,true,false);
  res.SetElementValue('cores','1');
  res.SetElementValue('threads','1');
  res.SetElementValue('sockets','1');
  (res.GetFormElement('ram').Implementor_HC as TFRE_DB_INPUT_NUMBER_DESC).setMinMax(getMinimumRAM,getAvailableRAM);
  res.SetElementValue('ram',IntToStr(getMinimumRAM));

  dc:=ses.FetchDerivedCollection(CFRE_DB_VMACHINE_VNIC_CHOOSER_DC);
  dc.Filters.RemoveFilter('zone');
  dc.Filters.AddUIDFieldFilter('zone','zid',[FREDB_H2G(zoneId)],dbnf_OneValueFromFilter);

  group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_form_network_group'),true,false);

  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_network_1'),'net1');
  block.AddSchemeFormGroupInputs(nicScheme.GetInputGroup('main'),ses,'net1',false);
  sf:=CWSF(@WEB_AddVMConfigureNetwork);
  sf.AddParam.Describe('id','net1');
  cusf:=CWSF(@WEB_AddVMConfigureNetworkCleanup);
  cusf.AddParam.Describe('id','net1');
  button:=block.AddInputButton(5).Describe('',FetchModuleTextShort(ses,'vm_form_network_configure_button'),sf,cusf);
  ch:=(block.GetFormElement('net1.nic').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
  ch.addDependentInput('net2','',fdv_hidden);
  ch.AddDependence(button.contentId,false);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_network_2'),'net2');
  block.AddSchemeFormGroupInputs(nicScheme.GetInputGroup('main'),ses,'net2',false);
  sf:=CWSF(@WEB_AddVMConfigureNetwork);
  sf.AddParam.Describe('id','net2');
  cusf:=CWSF(@WEB_AddVMConfigureNetworkCleanup);
  cusf.AddParam.Describe('id','net1');
  button:=block.AddInputButton(5).Describe('',FetchModuleTextShort(ses,'vm_form_network_configure_button'),sf,cusf);
  ch:=(block.GetFormElement('net2.nic').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
  ch.addDependentInput('net3','',fdv_hidden);
  ch.AddDependence(button.contentId,false);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_network_3'),'net3');
  block.AddSchemeFormGroupInputs(nicScheme.GetInputGroup('main'),ses,'net3',false);
  sf:=CWSF(@WEB_AddVMConfigureNetwork);
  sf.AddParam.Describe('id','net3');
  cusf:=CWSF(@WEB_AddVMConfigureNetworkCleanup);
  cusf.AddParam.Describe('id','net1');
  button:=block.AddInputButton(5).Describe('',FetchModuleTextShort(ses,'vm_form_network_configure_button'),sf,cusf);
  ch:=(block.GetFormElement('net3.nic').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
  ch.addDependentInput('net4','',fdv_hidden);
  ch.AddDependence(button.contentId,false);
  block:=group.AddBlock.Describe(FetchModuleTextShort(ses,'vm_form_network_4'),'net4');
  block.AddSchemeFormGroupInputs(nicScheme.GetInputGroup('main'),ses,'net4',false);
  sf:=CWSF(@WEB_AddVMConfigureNetwork);
  sf.AddParam.Describe('id','net4');
  cusf:=CWSF(@WEB_AddVMConfigureNetworkCleanup);
  cusf.AddParam.Describe('id','net1');
  button:=block.AddInputButton(5).Describe('',FetchModuleTextShort(ses,'vm_form_network_configure_button'),sf,cusf);
  ch:=(block.GetFormElement('net4.nic').Implementor_HC as TFRE_DB_INPUT_CHOOSER_DESC);
  ch.AddDependence(button.contentId,false);

  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);

  Result:=res;

  //res.AddInput.Describe(FetchModuleTextShort(ses,'vm_name'),'name',true);
  //maxRAM:=getAvailableRAM; minRAM:=getMinimumRAM; stepRAM:=getRAMSteps;
  //res.AddNumber.DescribeSlider(FetchModuleTextShort(ses,'vm_mem'),'mem',minRAM,maxRAM,true,IntToStr(minRAM),2, round((maxRAM-minRAM) / stepRAM) + 1);
  //
  //maxCPU:=getAvailableCPU;
  //res.AddNumber.DescribeSlider(FetchModuleTextShort(ses,'vm_cpu'),'cpu',1,maxCPU,true,IntToStr(maxCPU),0,maxCPU);
  //
  //res.AddChooser.Describe(FetchModuleTextShort(ses,'vm_sc'),'sc',vm_scs.GetStoreDescription as TFRE_DB_STORE_DESC);
  //
  //idestore:=TFRE_DB_STORE_DESC.create.Describe();
  //idestore.AddEntry.Describe(FetchModuleTextShort(ses,'vm_ide_option_disk'),'disk');
  //idestore.AddEntry.Describe(FetchModuleTextShort(ses,'vm_ide_option_iso'),'iso');
  //
  //isostore:=vm_isos.GetStoreDescription as TFRE_DB_STORE_DESC;
  ////isostore.AddEntry.Describe(FetchModuleTextShort(ses,'vm_upload_iso'),'upload');
  //
  //diskstore:=vm_disks.GetStoreDescription as TFRE_DB_STORE_DESC;
  //diskstore.AddEntry.Describe(FetchModuleTextShort(ses,'vm_create_new_disk'),'create');
  //
  //group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_ide0'));
  //chooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_ide_type'),'ide0',idestore,dh_chooser_combo,false,false,false,false,'disk');
  //
  //diskchooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_disk_chooser'),'disk0',diskstore,dh_chooser_combo,true);
  //chooser.addDependentInput('disk0','disk',fdv_visible);
  //group.AddInput.Describe(FetchModuleTextShort(ses,'vm_new_disk_name'),'diskname0',true);
  //group.AddNumber.Describe(FetchModuleTextShort(ses,'vm_new_disk_size'),'disksize0',true,false,false,false,'40');
  //diskchooser.addDependentInput('diskname0','create',fdv_visible);
  //diskchooser.addDependentInput('disksize0','create',fdv_visible);
  //isochooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_iso_chooser'),'iso0',isostore,dh_chooser_combo,true);
  //chooser.addDependentInput('iso0','iso',fdv_visible);
  //
  //group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_ide1'));
  ////chooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_ide_type'),'ide1',idestore,true,dh_chooser_combo,false,false,false,'iso');
  //chooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_ide_type'),'ide1',idestore);
  //
  //diskchooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_disk_chooser'),'disk1',diskstore,dh_chooser_combo,true);
  //chooser.addDependentInput('disk1','disk',fdv_visible);
  //group.AddInput.Describe(FetchModuleTextShort(ses,'vm_new_disk_name'),'diskname1',true);
  //group.AddNumber.Describe(FetchModuleTextShort(ses,'vm_new_disk_size'),'disksize1',true,false,false,false,'40');
  //diskchooser.addDependentInput('diskname1','create',fdv_visible);
  //diskchooser.addDependentInput('disksize1','create',fdv_visible);
  //isochooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_iso_chooser'),'iso1',isostore,dh_chooser_combo,true);
  //chooser.addDependentInput('iso1','iso',fdv_visible);
  //
  //group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_ide2'));
  //chooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_ide_type'),'ide2',idestore);
  //
  //diskchooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_disk_chooser'),'disk2',diskstore,dh_chooser_combo,true);
  //chooser.addDependentInput('disk2','disk',fdv_visible);
  //group.AddInput.Describe(FetchModuleTextShort(ses,'vm_new_disk_name'),'diskname2',true);
  //group.AddNumber.Describe(FetchModuleTextShort(ses,'vm_new_disk_size'),'disksize2',true,false,false,false,'40');
  //diskchooser.addDependentInput('diskname2','create',fdv_visible);
  //diskchooser.addDependentInput('disksize2','create',fdv_visible);
  //isochooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_iso_chooser'),'iso2',isostore,dh_chooser_combo,true);
  //chooser.addDependentInput('iso2','iso',fdv_visible);
  //
  //group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_ide3'));
  //chooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_ide_type'),'ide3',idestore);
  //
  //diskchooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_disk_chooser'),'disk3',diskstore,dh_chooser_combo,true);
  //chooser.addDependentInput('disk3','disk',fdv_visible);
  //group.AddInput.Describe(FetchModuleTextShort(ses,'vm_new_disk_name'),'diskname3',true);
  //group.AddNumber.Describe(FetchModuleTextShort(ses,'vm_new_disk_size'),'disksize3',true,false,false,false,'40');
  //diskchooser.addDependentInput('diskname3','create',fdv_visible);
  //diskchooser.addDependentInput('disksize3','create',fdv_visible);
  //isochooser:=group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_iso_chooser'),'iso3',isostore,dh_chooser_combo,true);
  //chooser.addDependentInput('iso3','iso',fdv_visible);
  //
  //group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'vm_advanced'),true,true);
  //
  //keyboardstore:=vm_keyboards.GetStoreDescription as TFRE_DB_STORE_DESC;
  //keyboardstore.AddEntry.Describe(FetchModuleTextShort(ses,'vm_keyboard_layout_auto'),'auto');
  //group.AddChooser.Describe(FetchModuleTextShort(ses,'vm_keyboard_layout'),'keybord_layout',keyboardstore,dh_chooser_combo,true);
  //
  //Result:=res;
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

function TFRE_FIRMBOX_VM_MACHINES_MOD.canAddVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
begin
  Result:=(conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE,zone.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE_NIC,zone.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_IPV4_HOSTNET,zone.DomainID) and
           conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VMACHINE_DISK,zone.DomainID));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddVMConfigureDrives(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddVMConfigureNetwork(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_AddVMConfigureNetworkCleanup(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_CreateVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sdomain          : TFRE_DB_GUID;
  coll,nicColl     : IFRE_DB_COLLECTION;
  vmService        : TFRE_DB_VMACHINE;
  zone             : TFRE_DB_ZONE;
  idx              : String;
  schemeObject     : IFRE_DB_SchemeObject;
  data             : IFRE_DB_Object;
  i,j              : Integer;
  netInterfaces    : TFRE_DB_GUIDArray;
  netInterfaceObjs : IFRE_DB_ObjectArray;
  interfaceGuid    : TFRE_DB_GUID;
  netObj           : IFRE_DB_Object;
  nicScheme        : IFRE_DB_SchemeObject;
  nicObj           : TFRE_DB_VMACHINE_NIC;
  vnic             : IFRE_DB_Object;
begin
  if input.FieldPathExists('data.zone') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.FieldPath('data.zone').AsString),TFRE_DB_ZONE,zone));
    input.Field('data').AsObject.DeleteField('zone');
  end else begin
    if input.FieldExists('zoneId') then begin
      CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));
    end else begin
      raise EFRE_DB_Exception.Create(edb_ERROR,'No domain Id given for new VM Service');
    end;
  end;
  sdomain:=zone.DomainID;

  if not canAddVM(input,ses,app,conn,zone) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  nicColl:=conn.GetCollection(CFRE_DB_VM_COMPONENTS_COLLECTION);

  GetSystemScheme(TFRE_DB_VMACHINE,schemeObject);
  GetSystemScheme(TFRE_DB_VMACHINE_NIC,nicScheme);

  data:=input.Field('data').AsObject;
  //check cpu config
  if (data.Field('cores').AsInt16 * data.Field('threads').AsInt16 * data.Field('sockets').AsInt16>64) then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_cap'),FetchModuleTextShort(ses,'vm_create_error_msg_cpu_config'),fdbmt_error);
    exit;
  end;
  //check network
  SetLength(netInterfaces,0);
  SetLength(netInterfaceObjs,4);
  for i := 1 to 4 do begin
    netObj:=data.Field('net'+IntToStr(i)).AsObject;
    if netObj.FieldExists('nic') and (netObj.Field('nic').AsString<>cFRE_DB_SYS_CLEAR_VAL_STR) then begin
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
      nicScheme.SetObjectFieldsWithScheme(netObj,nicObj,true,conn);
      netInterfaceObjs[Length(netInterfaces)-1]:=nicObj;
    end;
    data.DeleteField('net'+IntToStr(i));
  end;

  vmService:=TFRE_DB_VMACHINE.CreateForDB;
  vmService.SetDomainID(sdomain);
  schemeObject.SetObjectFieldsWithScheme(data,vmService,true,conn);
  vmService.Field('serviceParent').AsObjectLink:=zone.UID;
  vmService.Field('zoneid').AsObjectLink:=zone.UID;
  idx:=TFRE_DB_VMACHINE.ClassName + '_' + vmService.ObjectName + '@' + zone.UID_String;
  vmService.Field('uniquephysicalid').asstring := idx;

  if coll.ExistsIndexedText(idx)<>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_exists_cap'),FetchModuleTextShort(ses,'vm_create_error_exists_msg'),fdbmt_error);
    exit;
  end;
  for i := 0 to High(netInterfaces) do begin
    if nicColl.ExistsIndexedText(netInterfaceObjs[i].Field('nic').AsString + '@' + zone.UID_String)<>0 then begin
      CheckDbResult(conn.Fetch(netInterfaceObjs[i].Field('nic').AsObjectLink,vnic));
      Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vm_create_error_cap'),StringReplace(FetchModuleTextShort(ses,'vm_create_error_msg_net_interface_used_by_vm'),'%vnic_str%',vnic.Field('objname').AsString,[rfReplaceAll]),fdbmt_error);
      exit;
    end;
  end;

  CheckDbResult(coll.Store(vmService.CloneToNewObject()));
  for i := 0 to High(netInterfaces) do begin
    netInterfaceObjs[i].Field('serviceParent').AsObjectLink:=vmService.UID;
    netInterfaceObjs[i].Field('uniquephysicalid').asstring := netInterfaceObjs[i].Field('nic').AsString + '@' + zone.UID_String;
    CheckDbResult(nicColl.Store(netInterfaceObjs[i]));
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

