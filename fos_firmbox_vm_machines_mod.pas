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
    procedure       _GetSelectedVMData        (const conn: IFRE_DB_CONNECTION ; const selected : TGUID; var vmkey,vnc_port,vnc_host,vm_state: String);
  public
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
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
  end;

  { TFRE_FIRMBOX_VM_RESOURCES_MOD }

  TFRE_FIRMBOX_VM_RESOURCES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  public
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
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
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
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
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_FIRMBOX_VM_ISO }

  TFRE_FIRMBOX_VM_ISO = class (TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_MACHINES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_RESOURCES_MOD);
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

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('isoid',GetTranslateableTextKey('scheme_id'));
  group.AddInput('name',GetTranslateableTextKey('scheme_name'));
end;

class procedure TFRE_FIRMBOX_VM_ISO.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  StoreTranslateableText(conn,'scheme_main_group','General Information');
  StoreTranslateableText(conn,'scheme_id','ID');
  StoreTranslateableText(conn,'scheme_name','Name');
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

class procedure TFRE_FIRMBOX_VM_DISK.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  StoreTranslateableText(conn,'scheme_main_group','General Information');
  StoreTranslateableText(conn,'scheme_id','ID');
  StoreTranslateableText(conn,'scheme_name','Name');
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
  InitModuleDesc('$vm_resources_description');
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
    tr_Grid.AddOneToOnescheme('name','',app.FetchAppTextShort(session,'$gc_iso_name'));

    isosp := conn.Collection('VM_ISOS',false);
    isos:= session.NewDerivedCollection('VM_ISOS_DERIVED');
    with isos do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(isosp);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);
    tr_Grid.AddOneToOnescheme('name','',app.FetchAppTextShort(session,'$gc_disk_name'));

    diskp := conn.Collection('VM_DISKS',false);
    disks:= session.NewDerivedCollection('VM_DISKS_DERIVED');
    with disks do begin
      SetDeriveTransformation(tr_Grid);
      SetDisplayType(cdt_Listview,[],'',TFRE_DB_StringArray.create('name'));
      SetDeriveParent(diskp);
    end;
  end;
end;

class procedure TFRE_FIRMBOX_VM_RESOURCES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility(ses);

  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  res.AddSection.Describe(CWSF(@WEB_ContentDisks),app.FetchAppTextShort(ses,'$vm_resources_disks'),1,'DISKS');
  res.AddSection.Describe(CWSF(@WEB_ContentISOs),app.FetchAppTextShort(ses,'$vm_resources_isos'),2,'ISOS');
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_ContentDisks(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VM_DISK)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  coll := ses.FetchDerivedCollection('VM_DISKS_DERIVED');
  res := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res.AddButton.Describe(CWSF(@WEB_CreateDisk),'/images_apps/hal/add_disk.png',app.FetchAppTextShort(ses,'$vm_resources_add_disk'),app.FetchAppTextHint(ses,'$vm_resources_add_disk'));
  res.AddButton.Describe(CWSF(@WEB_DeleteDisk),'/images_apps/hal/delete_disk.png',app.FetchAppTextShort(ses,'$vm_resources_delete_disk'),app.FetchAppTextHint(ses,'$vm_resources_delete_disk'),fdgbd_multi);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_ContentISOs(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VM_ISO)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  coll := ses.FetchDerivedCollection('VM_ISOS_DERIVED');
  res := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  res.AddButton.Describe(CWSF(@WEB_UploadISO),'/images_apps/hal/add_iso.png',app.FetchAppTextShort(ses,'$vm_resources_add_iso'),app.FetchAppTextHint(ses,'$vm_resources_add_iso'));
  res.AddButton.Describe(CWSF(@WEB_DeleteISO),'/images_apps/hal/delete_iso.png',app.FetchAppTextShort(ses,'$vm_resources_delete_iso'),app.FetchAppTextHint(ses,'$vm_resources_delete_iso'),fdgbd_multi);

  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_CreateDisk(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_DIALOG_DESC;
  scheme    : IFRE_DB_SchemeObject;
  serverFunc: TFRE_DB_SERVER_FUNC_DESC;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_FIRMBOX_VM_DISK)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GFRE_DBI.GetSystemSchemeByName('TFRE_FIRMBOX_VM_DISK',scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'ADD_DISK'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  serverFunc:=CSCF('TFRE_FIRMBOX_VM_DISK','NewOperation','collection','VM_DISKS');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverFunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_DeleteDisk(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj: IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_FIRMBOX_VM_DISK)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('SELECTED').AsStringItem[0]),obj);
  Result:=(obj.Implementor_HC as TFRE_FIRMBOX_VM_DISK).Invoke_DBIMI_Method('deleteOperation',input,ses,app,conn);
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_UploadISO(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_DIALOG_DESC;
  serverFunc: TFRE_DB_SERVER_FUNC_DESC;
  scheme: IFRE_DB_SchemeObject;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_FIRMBOX_VM_ISO)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GFRE_DBI.GetSystemSchemeByName('TFRE_FIRMBOX_VM_ISO',scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'UPLOAD_ISO'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  serverFunc:=CSCF('TFRE_FIRMBOX_VM_ISO','NewOperation','collection','VM_ISOS');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverFunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VM_RESOURCES_MOD.WEB_DeleteISO(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  obj: IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_FIRMBOX_VM_ISO)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('SELECTED').AsStringItem[0]),obj);
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
  InitModuleDesc('$vnetwork_description');
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
      //AddOneToOnescheme('icon','',app.FetchAppTextShort(conn,'$datalink_icon'),dt_icon);
      AddOneToOnescheme('objname','linkname',app.FetchAppTextShort(session,'$datalink_name'),dt_string,true,false,false,1,'icon');
//      AddOneToOnescheme('zoned','zoned',app.FetchAppTextShort(conn,'$datalink_zoned'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$datalink_desc'));
    end;
    datalink_dc := session.NewDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    with datalink_dc do begin
      SetDeriveParent(conn.Collection('datalink'));
      SetDeriveTransformation(datalink_tr_Grid);
      AddBooleanFieldFilter('showvirtual','showvirtual',true,false);
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_DatalinkMenu),nil,CWSF(@WEB_DatalinkContent));
      SetParentToChildLinkField ('<PARENTID');
    end;
  end;
end;

class procedure TFRE_FIRMBOX_VM_NETWORK_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;


function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  grid_datalink   : TFRE_DB_VIEW_LIST_DESC;
  dc_datalink     : IFRE_DB_DERIVED_COLLECTION;
  datalink_content: TFRE_DB_FORM_PANEL_DESC;
  txt             : IFRE_DB_TEXT;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VM_NETWORK_MOD)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  dc_datalink                := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
  grid_datalink              := dc_datalink.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  txt:=app.FetchAppTextFull(ses,'$datalink_create_stub');
  grid_datalink.AddButton.Describe(CWSF(@WEB_DatalinkCreateStub),'images_apps/hal/create_stub.png',txt.Getshort,txt.GetHint);
  txt.Finalize;

  datalink_content           := TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$datalink_content_header'));
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
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VM_NETWORK_MOD)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    if dc.Fetch(sel_guid,dl) then begin
      GFRE_DBI.GetSystemSchemeByName(dl.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$datalink_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(dl,ses);
      panel.contentId:='DATALINK_CONTENT';
//      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(dl,'saveOperation'),fdbbt_submit);
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$datalink_content_header'));
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
  if not (conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_DB_DATALINK)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  Result:=GFRE_DB_NIL_DESC;
  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
    if dc.Fetch(sel_guid,dl) then begin
      sclass := dl.SchemeClass;
      writeln(schemeclass);
      input.Field('add_vnic').AsString    := app.FetchAppTextShort(ses,'$datalink_add_vnic');
      input.Field('delete_vnic').AsString := app.FetchAppTextShort(ses,'$datalink_delete_vnic');
      input.Field('delete_aggr').AsString := app.FetchAppTextShort(ses,'$datalink_delete_aggr');
      input.Field('delete_stub').AsString := app.FetchAppTextShort(ses,'$datalink_delete_stub');
      result := dl.Invoke('Menu',input,ses,app,conn);
    end;
  end;
end;

function TFRE_FIRMBOX_VM_NETWORK_MOD.WEB_DatalinkCreateStub(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DATALINK_STUB)) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

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
  InitModuleDesc('$machines_description');
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
      AddOneToOnescheme('Objname','',app.FetchAppTextShort(session,'$gc_vm_name'),dt_string,true,false,false,4);
      AddOneToOnescheme('MType','',app.FetchAppTextShort(session,'$gc_vm_type'));
      AddOneToOnescheme('MStateIcon','',app.FetchAppTextShort(session,'$gc_vm_state'),dt_icon);
      AddOneToOnescheme('PERFPCPU','',app.FetchAppTextShort(session,'$gc_vm_cpu'),dt_number,true,false,false,2);
      AddOneToOnescheme('PERFPMEM','',app.FetchAppTextShort(session,'$gc_vm_used_mem'),dt_number,true,false,false,2);
      AddOneToOnescheme('PERFRSS','',app.FetchAppTextShort(session,'$gc_vm_paged_mem'),dt_number,true,false,false,2);
      AddOneToOnescheme('PERFVSZ','',app.FetchAppTextShort(session,'$gc_vm_virtual_mem'),dt_number,true,false,false,2);
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



procedure TFRE_FIRMBOX_VM_MACHINES_MOD._GetSelectedVMData(const conn: IFRE_DB_CONNECTION; const selected: TGUID; var vmkey, vnc_port, vnc_host, vm_state: String);
var coll     : IFRE_DB_COLLECTION;
    vmo      : IFRE_DB_Object;
begin
  coll := conn.Collection('virtualmachine');
  if coll.Fetch(selected,vmo) then begin
    vmkey    := vmo.Field('MKEY').AsString;
    vnc_port := vmo.Field('VNC_PORT').AsString;
    vnc_host := vmo.Field('VNC_HOST').AsString;
    vm_state := vmo.Field('MSTATE').AsString;
    writeln('VMO: ',vmkey,' ',vnc_port,' ', vm_state);
  end;
end;

class procedure TFRE_FIRMBOX_VM_MACHINES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_Feed_Update(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var// vmc     : IFOS_VM_HOST_CONTROL;
    vmo     : IFRE_DB_Object;
    vm      : IFRE_DB_Object;
    vmcc    : IFRE_DB_COLLECTION;
begin
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
  CheckClassVisibility(ses);

  coll := ses.FetchDerivedCollection('VMC');
  list := coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE) then begin
    text:=app.FetchAppTextFull(ses,'$machines_new_vm');
    list.AddButton.Describe(CWSF(@WEB_NewVM)         , '/images_apps/hal/add_vm.png',text.Getshort,text.GetHint);
    text.Finalize;
  end;
  text:=app.FetchAppTextFull(ses,'$machines_start');
  list.AddButton.Describe(CWSF(@WEB_StartVM)       , '/images_apps/hal/start_vm.png',text.Getshort,text.GetHint,fdgbd_single);
  text.Finalize;
  text:=app.FetchAppTextFull(ses,'$machines_stop');
  list.AddButton.Describe(CWSF(@WEB_StopVM)        , '/images_apps/hal/stop_vm.png',text.Getshort,text.GetHint,fdgbd_single);
  text.Finalize;
  text:=app.FetchAppTextFull(ses,'$machines_kill');
  list.AddButton.Describe(CWSF(@WEB_StopVMF)       , '/images_apps/hal/stop_vm.png',text.Getshort,text.GetHint,fdgbd_single);
  text.Finalize;
  main := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(list,nil,nil,nil,nil,true,2);

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,main,nil,TFRE_DB_HTML_DESC.create.Describe(app.FetchAppTextShort(ses,'$machines_content_header')));
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowInfo(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var vmcc  : IFRE_DB_COLLECTION;
    vmkey : string;
      obj : IFRE_DB_Object;
begin
  CheckClassVisibility(ses);

  vmkey := input.Field('vmkey').AsString;
  conn.CollectionAsIntf('virtualmachine',IFRE_DB_COLLECTION,VMCC,true,true);
  if vmcc.GetIndexedObj(vmkey,obj) then begin
    result := TFRE_DB_HTML_DESC.create.Describe(FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+obj.DumpToString+'</pre>'));
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe(app.FetchAppTextShort(ses,'$machines_no_info'));
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
  CheckClassVisibility(ses);
  vmkey  := input.Field('vmkey').AsString;
  VMCC := conn.Collection('virtualmachine',false);
  if vmcc.GetIndexedObj(vmkey,obj) then begin
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
    result := TFRE_DB_HTML_DESC.create.Describe(app.FetchAppTextShort(ses,'$machines_no_info'));
  end;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_VM_ShowPerf(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  CheckClassVisibility(ses);

  result := TFRE_DB_HTML_DESC.create.Describe('Feature disabled in Demo Mode.'); //FIXXME: please implement me
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_ContentNote(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  load_func             : TFRE_DB_SERVER_FUNC_DESC;
  save_func             : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_DB_NOTE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

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
  if not conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    _GetSelectedVMData(conn,sel_guid,vmkey,vncp,vnch,vmstate);
    vm_sub := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
    sf := CWSF(@WEB_VM_ShowInfo); sf.AddParam.Describe('VMKEY',vmkey);
    vm_sub.AddSection.Describe(sf,app.FetchAppTextShort(ses,'$vm_details_config'),2);
    if vncp<>'' then
      begin
        sf := CWSF(@WEB_VM_ShowVNC); sf.AddParam.Describe('VNC_PORT',vncp) ; sf.AddParam.Describe('VNC_HOST',vnch); sf.AddParam.Describe('VMKEY',vmkey);
        vm_sub.AddSection.Describe(sf,app.FetchAppTextShort(ses,'$vm_details_console'),1);
      end;
    vm_sub.AddSection.Describe(CWSF(@WEB_VM_ShowPerf),app.FetchAppTextShort(ses,'$vm_details_perf'),3);
    sf := CWSF(@WEB_ContentNote); sf.AddParam.Describe('linkid',input.Field('SELECTED').asstring);
    vm_sub.AddSection.Describe(sf,app.FetchAppTextShort(ses,'$vm_details_note'),4);
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  vm_isos := ses.FetchDerivedCollection('VM_CH_ISOS_DERIVED');
  vm_disks:= ses.FetchDerivedCollection('VM_CH_DISKS_DERIVED');
  vm_scs:= ses.FetchDerivedCollection('VM_CH_SCS_DERIVED');
  vm_keyboards:= ses.FetchDerivedCollection('VM_CH_KEYBOARDS_DERIVED');

  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$vm_new_caption'));
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$vm_new_save'),CWSF(@WEB_CreateVM),fdbbt_submit);

  res.AddInput.Describe(app.FetchAppTextShort(ses,'$vm_name'),'name',true);
  maxRAM:=getAvailableRAM; minRAM:=getMinimumRAM; stepRAM:=getRAMSteps;
  res.AddNumber.DescribeSlider(app.FetchAppTextShort(ses,'$vm_mem'),'mem',minRAM,maxRAM,true,IntToStr(minRAM),2, round((maxRAM-minRAM) / stepRAM) + 1);

  maxCPU:=getAvailableCPU;
  res.AddNumber.DescribeSlider(app.FetchAppTextShort(ses,'$vm_cpu'),'cpu',1,maxCPU,true,IntToStr(maxCPU),0,maxCPU);

  res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_sc'),'sc',vm_scs.GetStoreDescription as TFRE_DB_STORE_DESC,true,dh_chooser_combo,true);

  idestore:=TFRE_DB_STORE_DESC.create.Describe();
  idestore.AddEntry.Describe(app.FetchAppTextShort(ses,'$vm_ide_option_disk'),'disk');
  idestore.AddEntry.Describe(app.FetchAppTextShort(ses,'$vm_ide_option_iso'),'iso');

  isostore:=vm_isos.GetStoreDescription as TFRE_DB_STORE_DESC;
  isostore.AddEntry.Describe(app.FetchAppTextShort(ses,'$vm_upload_iso'),'upload');

  diskstore:=vm_disks.GetStoreDescription as TFRE_DB_STORE_DESC;
  diskstore.AddEntry.Describe(app.FetchAppTextShort(ses,'$vm_create_new_disk'),'create');

  chooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_ide0'),'ide0',idestore,true,dh_chooser_combo,false,false,false,'disk');

  diskchooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_disk_chooser'),'disk0',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_name'),'diskname0',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_size'),'disksize0',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_iso_chooser'),'iso0',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  chooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_ide1'),'ide1',idestore,true,dh_chooser_combo,false,false,false,'iso');

  diskchooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_disk_chooser'),'disk1',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_name'),'diskname1',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_size'),'disksize1',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_iso_chooser'),'iso1',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  chooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_ide2'),'ide2',idestore);

  diskchooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_disk_chooser'),'disk2',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_name'),'diskname2',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_size'),'disksize2',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_iso_chooser'),'iso2',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  chooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_ide3'),'ide3',idestore);

  diskchooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_disk_chooser'),'disk3',diskstore,true,dh_chooser_combo,true);
  chooser.addDependentInput(diskchooser,'disk');
  diskchooser.addDependentInput(res.AddInput.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_name'),'diskname3',true),'create');
  diskchooser.addDependentInput(res.AddNumber.Describe(app.FetchAppTextShort(ses,'$vm_new_disk_size'),'disksize3',true,false,false,false,'40'),'create');
  isochooser:=res.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_iso_chooser'),'iso3',isostore,true,dh_chooser_combo,true);
  chooser.addDependentInput(isochooser,'iso');

  group:=res.AddGroup.Describe(app.FetchAppTextShort(ses,'$vm_advanced'),true,true);

  keyboardstore:=vm_keyboards.GetStoreDescription as TFRE_DB_STORE_DESC;
  keyboardstore.AddEntry.Describe(app.FetchAppTextShort(ses,'$vm_keyboard_layout_auto'),'auto');
  group.AddChooser.Describe(app.FetchAppTextShort(ses,'$vm_keyboard_layout'),'keybord_layout',keyboardstore,true,dh_chooser_combo,true);

  Result:=res;
end;

function TFRE_FIRMBOX_VM_MACHINES_MOD.WEB_CreateVM(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','START VM',fdbmt_info);
  //exit;
  if input.FieldExists('SELECTED') then begin
    _GetSelectedVMData(conn,input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','STOP VM',fdbmt_info);
  //exit;
  if input.FieldExists('SELECTED') then begin
    _GetSelectedVMData(conn,input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VMACHINE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.FieldExists('SELECTED') then begin
    _GetSelectedVMData(conn,input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    vmc.VM_Halt(vmkey,true);
    vmc.Finalize;
  end;
  result := GFRE_DB_NIL_DESC;
end;

end.

