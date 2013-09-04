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
//     cVMHostMachine:string = ''; // '10.1.0.130';

type

  { TFRE_FIRMBOX_VM_MACHINES_MOD }

  TFRE_FIRMBOX_VM_MACHINES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme      (const scheme    : IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule (const session   : TFRE_DB_UserSession);override;
    procedure       _GetSelectedVMData        (session : TFRE_DB_UserSession ; const selected : TGUID; var vmkey,vnc_port,vnc_host,vm_state: String);
  published
    function  WEB_VM_Feed_Update        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowInfo           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowVNC            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_ShowPerf           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_ContentNote           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_VM_Details            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_NewVM                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StartVM               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVM                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_StopVMF               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  WEB_UpdateVM              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_MACHINES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_STATUS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_NETWORK_MOD);
  GFRE_DBI.Initialize_Extension_Objects;
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

  dc_datalink                := GetSession(input).FetchDerivedCollection('VM_NETWORK_MOD_DATALINK_GRID');
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
  vmc     : IFRE_DB_DERIVED_COLLECTION;
  vmcp    : IFRE_DB_COLLECTION;
  tr_Grid : IFRE_DB_SIMPLE_TRANSFORM;
  vmo     : IFRE_DB_Object;
  vm      : IFRE_DB_Object;
  uvm     : IFRE_DB_Object;
  i       : Integer;
  app     : TFRE_DB_APPLICATION;
  conn    : IFRE_DB_CONNECTION;
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
  end;
end;


procedure TFRE_FIRMBOX_VM_MACHINES_MOD._GetSelectedVMData(session: TFRE_DB_UserSession; const selected: TGUID; var vmkey, vnc_port, vnc_host, vm_state: String);
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
var vmc     : IFOS_VM_HOST_CONTROL;
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

  load_func   := CSF(@IMI_NoteLoad);
  save_func   := CSF(@IMI_NoteSave);
  load_func.AddParam.Describe('linkid',input.Field('linkid').asstring);
  save_func.AddParam.Describe('linkid',input.Field('linkid').asstring);

  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CSF(@IMI_NoteStartEdit),CSF(@IMI_NoteStopEdit));
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
    _GetSelectedVMData(GetSession(input),sel_guid,vmkey,vncp,vnch,vmstate);
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
begin
  if not conn.CheckRight(Get_Rightname('admin_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DEMO','NEW VM',fdbmt_info); //FIXXME: please implement me
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
    _GetSelectedVMData(GetSession(input),input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
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
    _GetSelectedVMData(GetSession(input),input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
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
    _GetSelectedVMData(GetSession(input),input.Field('SELECTED').AsGUID,vmkey,vncp,vnch,vmstate);
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

