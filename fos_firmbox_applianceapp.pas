unit fos_firmbox_applianceapp;


{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  fre_hal_schemes,
  FRE_DB_INTERFACE,fos_stats_control_interface,fos_firmbox_vm_machines_mod,
  fre_system,
  FRE_DB_COMMON,
  fre_zfs;

type
   TAppliancePerformanceData = record
     cpu_aggr_sys       : Single;
     cpu_aggr_sys_user  : Single;
     net_aggr_rx_bytes  : single;
     net_aggr_tx_bytes  : single;
     disk_aggr_wps      : single;
     disk_aggr_rps      : single;
     vmstat_memory_free : single;
     vmstat_memory_swap : single;
     cache_relMisses    : single;
     cache_relHits      : single;
   end;


var G_HACK_SHARE_OBJECT : IFRE_DB_Object;
    G_AppliancePerformanceBuffer     : array [0..179] of TAppliancePerformanceData;
    G_AppliancePerformanceCurrentIdx : NativeInt=1;

type

  { TFRE_FIRMBOX_APPLIANCE_APP }

  TFRE_FIRMBOX_APPLIANCE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure     ; override;
    procedure       _UpdateSitemap                (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize           (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion            (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme          (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects              (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain       (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
  published
    function        WEB_RAW_DATA_FEED             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RAW_DATA_FEED30           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_APPLIANCE_STATUS_MOD }

  TFRE_FIRMBOX_APPLIANCE_STATUS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    FtotalSwap,FtotalRam : Integer; //in kb
    FtotalNet            : Integer; //in byte
    procedure       _fillPoolCollection       (const conn: IFRE_DB_CONNECTION; const data: IFRE_DB_Object);
    procedure       _SendData                 (const session: IFRE_DB_UserSession);
    procedure       _HandleRegisterSend       (session : TFRE_DB_UserSession);
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
    procedure       MyServerInitializeModule  (const admin_dbc : IFRE_DB_CONNECTION); override;
    procedure       UpdateDiskCollection      (const pool_disks : IFRE_DB_COLLECTION ; const data:IFRE_DB_Object);  //obsolete, change to new collection
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CPUStatusStopStart    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CPUStatusInit         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetStatusStopStart    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetStatusInit         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RAMStatusStopStart    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RAMStatusInit         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DiskStatusStopStart   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DiskStatusInit        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CacheStatusStopStart  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CacheStatusInit       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RAW_UPDATE            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RAW_UPDATE30          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD }

  TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  public
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentSystem         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentDatalink       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentFC             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SYSTEMContent         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SYSTEMMenu            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkContent       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkMenu          (const input:IFRE_DB_OBject; const ses: IFRE_DB_Usersession ; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DatalinkCreateAggr    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_FCContent             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_FCMenu                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD }

  TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  public
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

var __idxCPU,__idxRAM,__idxCache,__idxDisk,__idxNet: NativeInt; //FIXXXME - remove me
    __SendAdded : boolean;

{ TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD }

class procedure TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$analytics_description')
end;

procedure TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitializeModule(session);
end;

function TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  result := GFRE_DB_NIL_DESC;
end;

{ TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD }

class procedure TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$settings_description')
end;

procedure TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var datalink_dc       : IFRE_DB_DERIVED_COLLECTION;
    datalink_tr_Grid  : IFRE_DB_SIMPLE_TRANSFORM;
    fc_dc             : IFRE_DB_DERIVED_COLLECTION;
    fc_tr_Grid        : IFRE_DB_SIMPLE_TRANSFORM;
    system_dc         : IFRE_DB_DERIVED_COLLECTION;
    system_tr_Grid    : IFRE_DB_SIMPLE_TRANSFORM;
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
    datalink_dc := session.NewDerivedCollection('APPLIANCE_SETTINGS_MOD_DATALINK_GRID');
    with datalink_dc do begin
      SetDeriveParent(conn.GetCollection('datalink'));
      SetDeriveTransformation(datalink_tr_Grid);
//      AddBooleanFieldFilter('zoned','zoned',false);
      AddBooleanFieldFilter('showglobal','showglobal',true,false);
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_DatalinkMenu),nil,CWSF(@WEB_DatalinkContent));
      SetParentToChildLinkField ('<PARENTID');
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,system_tr_Grid);
    with system_tr_Grid do begin
      AddOneToOnescheme('objname','Name',app.FetchAppTextShort(session,'$system_name'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$system_desc'));
    end;
    system_dc := session.NewDerivedCollection('APPLIANCE_SETTINGS_MOD_SYSTEM_GRID');
    with system_dc do begin
      SetDeriveParent(conn.GetCollection('setting'));
      SetDeriveTransformation(system_tr_Grid);
      SetDisplayType(cdt_Listview,[],'',nil,'',CWSF(@WEB_SYSTEMMenu),nil,CWSF(@WEB_SYSTEMContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,fc_tr_Grid);
    with fc_tr_Grid do begin
      AddOneToOnescheme('objname','wwn',app.FetchAppTextShort(session,'$fc_wwn'));
      AddOneToOnescheme('targetmode','targetmode',app.FetchAppTextShort(session,'$fc_targetmode'));
      AddOneToOnescheme('state','state',app.FetchAppTextShort(session,'$fc_state'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$fc_desc'));
    end;
    fc_dc := session.NewDerivedCollection('APPLIANCE_SETTINGS_MOD_FC_GRID');
    with fc_dc do begin
      SetDeriveParent(conn.GetCollection('hba'));
      SetDeriveTransformation(fc_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_FCMenu),nil,CWSF(@WEB_FCContent));
    end;

  end;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sub_sec_s       : TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  sub_sec_s        := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);

  sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentSystem),app.FetchAppTextShort(ses,'$appliance_settings_system'),1,'system');
  sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentDatalink),app.FetchAppTextShort(ses,'$appliance_settings_datalink'),2,'datalink');
//  sub_sec_s.AddSection.Describe(TFRE_DB_HTML_DESC.create.Describe('iscsi'),app.FetchAppTextShort(conn,'$appliance_settings_iscsi'),3,'iscsi');
  //sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentFC),app.FetchAppTextShort(ses,'$appliance_settings_fibrechannel'),4,'fibrechannel');

  result := sub_sec_s;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_ContentSystem(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  grid_system     : TFRE_DB_VIEW_LIST_DESC;
  dc_system       : IFRE_DB_DERIVED_COLLECTION;
  system_content  : TFRE_DB_FORM_PANEL_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_system                := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_SYSTEM_GRID');
  grid_system              := dc_system.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  system_content           :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$system_content_header'));
  system_content.contentId :='SYSTEM_CONTENT';
  Result                   := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_system,system_content,nil,nil,nil,true,1,4);
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_ContentDatalink(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  grid_datalink   : TFRE_DB_VIEW_LIST_DESC;
  dc_datalink     : IFRE_DB_DERIVED_COLLECTION;
  datalink_content: TFRE_DB_FORM_PANEL_DESC;
  txt             : IFRE_DB_TEXT;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_datalink                := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_DATALINK_GRID');
  grid_datalink              := dc_datalink.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_DATALINK_AGGR) then begin
    txt:=app.FetchAppTextFull(ses,'$create_aggr');
    grid_datalink.AddButton.Describe(CWSF(@WEB_DatalinkCreateAggr),'images_apps/firmbox_appliance/create_aggr.png',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;

  datalink_content           := TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$datalink_content_header'));
  datalink_content.contentId :='DATALINK_CONTENT';
  Result                     := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_datalink,datalink_content,nil,nil,nil,true,1,1);
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_ContentFC(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  grid_fc         : TFRE_DB_VIEW_LIST_DESC;
  dc_fc           : IFRE_DB_DERIVED_COLLECTION;
  fc_content      : TFRE_DB_FORM_PANEL_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_fc               := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_FC_GRID');
  grid_fc             := dc_fc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  fc_content          :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$fc_content_header'));
  fc_content.contentId:='FC_HBA_CONTENT';
  Result              := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_fc,fc_content,nil,nil,nil,true,2);
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_SYSTEMContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  so            : IFRE_DB_Object;
  sel_guid      : TGUID;
  menu          : TFRE_DB_MENU_DESC;

begin
  if input.Field('SELECTED').ValueCount>0  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_SYSTEM_GRID');
    if dc.Fetch(sel_guid,so) then begin
      GetSystemSchemeByName(so.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$system_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('setting'),GetSession(input));
      panel.FillWithObjectValues(so,GetSession(input));
      if so.SchemeClass=TFRE_DB_MACHINE_SETTING_POWER.ClassName then
        begin
          menu:=TFRE_DB_MENU_DESC.create.Describe;
          menu.AddEntry.Describe(app.FetchAppTextShort(ses,'$system_reboot'),'',TFRE_DB_SERVER_FUNC_DESC.create.Describe(so,'Reboot'));
          menu.AddEntry.Describe(app.FetchAppTextShort(ses,'$system_shutdown'),'',TFRE_DB_SERVER_FUNC_DESC.create.Describe(so,'Shutdown'));
          panel.SetMenu(menu);
        end
      else
        panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(so,'saveOperation'),fdbbt_submit);
      panel.contentId:='SYSTEM_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$system_content_header'));
    panel.contentId:='SYSTEM_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_SYSTEMMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_DatalinkContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  dl            : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  if input.Field('SELECTED').ValueCount=1  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_DATALINK_GRID');
    if dc.Fetch(sel_guid,dl) then begin
      GetSystemSchemeByName(dl.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$datalink_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(dl,ses);
      panel.contentId:='DATALINK_CONTENT';
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(dl,'saveOperation'),fdbbt_submit);
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$datalink_content_header'));
    panel.contentId:='DATALINK_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_DatalinkMenu(const input: IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  dl            : IFRE_DB_Object;
  sel_guid      : TGUID;
  sclass        : TFRE_DB_NameType;
begin
  Result:=GFRE_DB_NIL_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_DATALINK_VNIC)
    or conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_DATALINK_VNIC)
    or conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_DATALINK_AGGR)
    or conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_DATALINK_STUB) then
    begin
      if input.Field('SELECTED').ValueCount=1  then begin
        sel_guid := input.Field('SELECTED').AsGUID;
        dc       := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_DATALINK_GRID');
        if dc.Fetch(sel_guid,dl) then begin
          sclass := dl.SchemeClass;
          writeln(schemeclass);
          if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_DATALINK_VNIC) then
            input.Field('add_vnic').AsString    := app.FetchAppTextShort(ses,'$datalink_add_vnic');
          if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_DATALINK_VNIC) then
            input.Field('delete_vnic').AsString := app.FetchAppTextShort(ses,'$datalink_delete_vnic');
          if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_DATALINK_AGGR) then
            input.Field('delete_aggr').AsString := app.FetchAppTextShort(ses,'$datalink_delete_aggr');
          if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_DATALINK_STUB) then
            input.Field('delete_stub').AsString := app.FetchAppTextShort(ses,'$datalink_delete_stub');
          result := dl.Invoke('Menu',input,ses,app,conn);
        end;
      end;
  end;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_DatalinkCreateAggr(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_DATALINK_AGGR) then
    raise EFRE_DB_Exception.Create('No access to edit settings!');

  GetSystemScheme(TFRE_DB_DATALINK_AGGR,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$aggr_add_diag_cap'),600,true,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
  res.SetElementValue('objname','aggr');

  serverfunc := TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_DATALINK_AGGR.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','datalink');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_FCContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  fc            : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  if input.Field('SELECTED').ValueCount>0  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('APPLIANCE_SETTINGS_MOD_FC_GRID');
    if dc.Fetch(sel_guid,fc) then begin
      GetSystemSchemeByName(fc.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$fc_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(fc,ses);
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(fc,'saveOperation'),fdbbt_submit);
      panel.contentId:='FC_HBA_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$fc_content_header'));
    panel.contentId:='FC_HBA_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.WEB_FCMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := GFRE_DB_NIL_DESC;
end;

{ TFRE_FIRMBOX_APPLIANCE_STATUS_MOD }

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD._fillPoolCollection(const conn: IFRE_DB_CONNECTION; const data: IFRE_DB_Object);
var
  coll      : IFRE_DB_COLLECTION;
  pool_space: IFRE_DB_Object;
  upObj     : IFRE_DB_Object;

  procedure _addValues(const obj: IFRE_DB_Object);
  begin
    case obj.Field('name').AsString of
      'used' : begin
                 obj.Field('value').AsReal32 := data.FieldPath(cDEBUG_ZPOOL_NAME+'.used').AsInt64;
                 obj.Field('value_lbl').AsString := GFRE_BT.ByteToString(data.FieldPath(cDEBUG_ZPOOL_NAME+'.used').AsInt64);
               end;
      'avail': begin
                 obj.Field('value').AsReal32 := data.FieldPath(cDEBUG_ZPOOL_NAME+'.available').AsInt64;
                 obj.Field('value_lbl').AsString := GFRE_BT.ByteToString(data.FieldPath(cDEBUG_ZPOOL_NAME+'.available').AsInt64);
               end;
      'ref'  : begin
                 obj.Field('value').AsReal32 := data.FieldPath(cDEBUG_ZPOOL_NAME+'.referenced').AsInt64;
                 obj.Field('value_lbl').AsString := GFRE_BT.ByteToString(data.FieldPath(cDEBUG_ZPOOL_NAME+'.referenced').AsInt64);
               end;
    end;
    CheckDbResult(coll.Update(obj),'Update pool space');
  end;

begin
  coll := conn.GetCollection('ZONES_SPACE');
  //coll.ForAll(@_addValues);
end;

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD._SendData(const session: IFRE_DB_UserSession);
var
  res        : TFRE_DB_LIVE_CHART_DATA_AT_IDX_DESC;
  totalCache : Int64;
begin
  if __idxCPU>-1 then begin
    with G_AppliancePerformanceBuffer[G_AppliancePerformanceCurrentIdx] do
      res:=TFRE_DB_LIVE_CHART_DATA_AT_IDX_DESC.create.Describe('appl_stat_cpu',__idxCPU,TFRE_DB_Real32Array.create(cpu_aggr_sys,cpu_aggr_sys_user));
    inc(__idxCPU);
    session.SendServerClientRequest(res);
  end;
  if __idxNet>-1 then begin
    with G_AppliancePerformanceBuffer[G_AppliancePerformanceCurrentIdx] do
      res:=TFRE_DB_LIVE_CHART_DATA_AT_IDX_DESC.create.Describe('appl_stat_net',__idxNet,TFRE_DB_Real32Array.create(net_aggr_rx_bytes,net_aggr_tx_bytes));
    inc(__idxNet);
    session.SendServerClientRequest(res);
  end;
  if __idxDisk>-1 then begin
    with G_AppliancePerformanceBuffer[G_AppliancePerformanceCurrentIdx] do
      res:=TFRE_DB_LIVE_CHART_DATA_AT_IDX_DESC.create.Describe('appl_stat_disk',__idxDisk,TFRE_DB_Real32Array.create(disk_aggr_wps,disk_aggr_rps));
    inc(__idxDisk);
    session.SendServerClientRequest(res);
  end;
  if __idxRAM>-1 then begin
    with G_AppliancePerformanceBuffer[G_AppliancePerformanceCurrentIdx] do
      res:=TFRE_DB_LIVE_CHART_DATA_AT_IDX_DESC.create.Describe('appl_stat_ram',__idxRAM,TFRE_DB_Real32Array.create(vmstat_memory_free,vmstat_memory_swap));
    inc(__idxRAM);
    session.SendServerClientRequest(res);
  end;
  if __idxCache>-1 then begin
    with G_AppliancePerformanceBuffer[G_AppliancePerformanceCurrentIdx] do
      res:=TFRE_DB_LIVE_CHART_DATA_AT_IDX_DESC.create.Describe('appl_stat_cache',__idxCache,TFRE_DB_Real32Array.create(cache_relMisses,cache_relHits));
    inc(__idxCache);
    session.SendServerClientRequest(res);
  end;
end;

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD._HandleRegisterSend(session : TFRE_DB_UserSession);
begin
  if (__idxRAM=-1) and (__idxCache=-1) and (__idxDisk=-1) and (__idxNet=-1) and (__idxCPU=-1) then
    begin
      if __SendAdded then
        begin
          session.RemoveTaskMethod('ASM');
          __SendAdded := false;
          writeln('DISABLE SEND');
        end;
    end
  else
    if not __SendAdded then
      begin
        session.RegisterTaskMethod(@_SendData,1000,'ASM');
        __SendAdded := true;
        writeln('ENABLE SEND');
     end;
end;

class procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$status_description')
end;

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  DC_CHARTDATA_ZONES  : IFRE_DB_DERIVED_COLLECTION;
  CHARTDATA           : IFRE_DB_COLLECTION;

  busy,ast,rbw,wbw    : IFRE_DB_DERIVED_COLLECTION;
  disks               : IFRE_DB_COLLECTION;
  labels              : TFRE_DB_StringArray;
  idx                 : NativeInt;
  conn                : IFRE_DB_CONNECTION;

  procedure _AddDisk(const obj:IFRE_DB_Object);
  var diskname : string;
  begin
    diskname := obj.Field('caption').AsString;
    if Pos('C',diskname)=1 then begin
      labels[idx]:='D '+inttostr(idx);
    end else begin
      if Pos('RAM',diskname)=1 then begin
        labels[idx]:='RD';
      end else begin
        labels[idx]:=diskname;
      end;
    end;
    idx:=idx+1;
  end;

begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    conn:=session.GetDBConnection;
    __idxCPU:=-1;__idxRAM:=-1;__idxCache:=-1;__idxDisk:=-1;__idxNet:=-1;
    CHARTDATA := conn.getCollection('ZONES_SPACE');
    DC_CHARTDATA_ZONES := session.NewDerivedCollection('DC_ZONES_SPACE');
    with DC_CHARTDATA_ZONES do begin
      SetDeriveParent(CHARTDATA);
      SetDisplayTypeChart('Space on Diskpool',fdbct_pie,TFRE_DB_StringArray.Create('value'),True,True,nil,true);
    end;

    disks := conn.GetCollection('POOL_DISKS');
    idx:=0;

    ast   := session.NewDerivedCollection('APP_POOL_AST');
    ast.SetDeriveParent(disks);
    ast.SetDefaultOrderField('diskid',true);
    ast.SetDisplayTypeChart('Pool Disk Avg. Service Time (ms)',fdbct_column,TFRE_DB_StringArray.Create('ast'),false,false,labels,false,20);
    SetLength(labels,ast.Count);
    ast.ForAll(@_AddDisk);
    ast.SetDisplayTypeChart('Pool Disk Avg. Service Time (ms)',fdbct_column,TFRE_DB_StringArray.Create('ast'),false,false,labels,false,20); // Hack for labels, must be redone

    rbw   := session.NewDerivedCollection('APP_POOL_RBW');
    rbw.SetDeriveParent(disks);
    rbw.SetDefaultOrderField('diskid',true);
    rbw.SetDisplayTypeChart('Raw Disk Bandwidth Read (kBytes/s)',fdbct_column,TFRE_DB_StringArray.Create('rbw'),false,false,labels,false,400000);

    wbw   := session.NewDerivedCollection('APP_POOL_WBW');
    wbw.SetDeriveParent(disks);
    wbw.SetDefaultOrderField('diskid',true);
    wbw.SetDisplayTypeChart('Raw Disk Bandwidth Write (kBytes/s)',fdbct_column,TFRE_DB_StringArray.Create('wbw'),false,false,labels,false,400000);

    busy  := session.NewDerivedCollection('APP_POOL_BUSY');
    busy.SetDeriveParent(disks);
    busy.SetDefaultOrderField('diskid',true);
    busy.SetDisplayTypeChart('Raw Disk Busy Times [%]',fdbct_column,TFRE_DB_StringArray.Create('b'),false,false,labels,false,100);

  end;
end;

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
var
  coll      : IFRE_DB_COLLECTION;
  used      : Extended;
  avail     : Extended;
  ref       : Extended;
  space     : IFRE_DB_Object;
  DISKI_HACK: IFOS_STATS_CONTROL;
  zfs_data  : IFRE_DB_Object;
begin
  inherited MyServerInitializeModule(admin_dbc);

  //FIXXME heli
  FtotalRam:=221242708; //in kb
  FtotalSwap:=338566808; //may change? mysessioninitializemodule better? feeder?
  FtotalNet:=100*1024*1024*2;//100MB * 2 Devices

  coll := admin_dbc.CreateCollection('ZONES_SPACE',true);
  coll.DefineIndexOnField('name',fdbft_String,true,true);

  space := GFRE_DBI.NewObject;
  space.Field('name').AsString := 'used';
  space.Field('value_col').AsString := '#3A6D9E';
  space.Field('value_leg').AsString := 'Used';
  CheckDbResult(coll.Store(space),'Add zones space');
  space := GFRE_DBI.NewObject;
  space.Field('name').AsString := 'avail';
  space.Field('value_col').AsString := '#70A258';
  space.Field('value_leg').AsString := 'Available';
  CheckDbResult(coll.Store(space),'Add zones space');
  space := GFRE_DBI.NewObject;
  space.Field('name').AsString := 'ref';
  space.Field('value_col').AsString := '#EDAF49';
  space.Field('value_leg').AsString := 'Referred';
  CheckDbResult(coll.Store(space),'Add zones space');

  //FIRMBOX TESTMODE STARTUP SPEED ENHANCEMENT
  //DISKI_HACK := Get_Stats_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);    //RZNORD
  //_fillPoolCollection(admin_dbc,DISKI_HACK.Get_ZFS_Data_Once);

  coll := admin_dbc.CreateCollection('LIVE_STATUS',true);
  coll.DefineIndexOnField('feedname',fdbft_String,true,true);
end;

procedure TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.UpdateDiskCollection(const pool_disks: IFRE_DB_COLLECTION; const data: IFRE_DB_Object);
var       debugs   : string;
  procedure UpdateDisks(const field:IFRE_DB_Field);
  var diskname : string;
      disk     : IFRE_DB_Object;
      disko    : IFRE_DB_Object;
  begin
    if field.FieldType=fdbft_Object then begin
      try
        diskname := field.FieldName;
        disko    := field.AsObject;
        if diskname='DISK_AGGR' then
          exit;
        if pool_disks.GetIndexedObj(diskname,disk) then begin
          disk.Field('caption').AsString := diskname;
          disk.Field('ast').AsReal32 := disko.Field('actv_t').AsReal32;
          disk.Field('wbw').AsReal32 := disko.Field('kwps').AsReal32;
          disk.Field('rbw').AsReal32 := disko.Field('krps').AsReal32;;
          disk.Field('b').AsReal32   := disko.Field('perc_b').AsReal32;
          //writeln('>> ',format('%30.30s AST %05.1f WBW  %05.1f  RBW   %05.1f   BUSY %05.1f',[disk.Field('caption').AsString,disk.Field('ast').AsReal32,disk.Field('wbw').AsReal32,disk.Field('rbw').AsReal32,disk.Field('b').AsReal32]));
          pool_disks.Update(disk);
        end else begin
          disk := GFRE_DBI.NewObject;
          disk.Field('diskid').AsString  := diskname;
          disk.Field('caption').AsString := diskname;
          disk.Field('ast_uid').AsGUID := disk.UID;
          disk.Field('wbw_uid').AsGUID := disk.UID;
          disk.Field('rbw_uid').AsGUID := disk.UID;
          disk.Field('b_uid').AsGUID := disk.UID;
          disk.Field('ast').AsReal32 := disko.Field('actv_t').AsReal32;
          disk.Field('wbw').AsReal32 := disko.Field('kwps').AsReal32;
          disk.Field('rbw').AsReal32 := disko.Field('krps').AsReal32;;
          disk.Field('b').AsReal32   := disko.Field('perc_b').AsReal32;;
          pool_disks.Store(disk);
        end;
      except on e:exception do begin
        writeln('>UPDATE DISK ERROR : ',e.Message);
      end;end;
    end;
  end;

begin
  //obsolete
  exit;
  debugs := '';
  pool_disks.StartBlockUpdating;
  try
    data.ForAllFields(@UpdateDisks);
  finally
    pool_disks.FinishBlockUpdating;
  end;
end;


function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res,sub1,sub2      : TFRE_DB_LAYOUT_DESC;
  c1                 : TFRE_DB_LAYOUT_DESC;
  c2,c3,c4,c5,c6     : TFRE_DB_LIVE_CHART_DESC;
  main               : TFRE_DB_LAYOUT_DESC;
  sub3,sub4          : TFRE_DB_LAYOUT_DESC;
  left               : TFRE_DB_LAYOUT_DESC;
  right              : TFRE_DB_LAYOUT_DESC;
  sub1l              : TFRE_DB_LAYOUT_DESC;
  sub2l              : TFRE_DB_LAYOUT_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  c1:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,ses.FetchDerivedCollection('DC_ZONES_SPACE').GetDisplayDescription,nil,nil,nil,false);
  c2:=TFRE_DB_LIVE_CHART_DESC.create.DescribeLine('appl_stat_cpu',2,120,CWSF(@WEB_CPUStatusStopStart),0,100,app.FetchAppTextShort(ses,'$overview_caption_cpu'),TFRE_DB_StringArray.create('f00','0f0'),
        TFRE_DB_StringArray.create(app.FetchAppTextShort(ses,'$overview_cpu_system_legend'),app.FetchAppTextShort(ses,'$overview_cpu_user_legend')),11,CWSF(@WEB_CPUStatusInit));
  c3:=TFRE_DB_LIVE_CHART_DESC.create.DescribeLine('appl_stat_net',2,120,CWSF(@WEB_NetStatusStopStart),0,100,app.FetchAppTextShort(ses,'$overview_caption_net'),TFRE_DB_StringArray.create('f00','0f0'),
        TFRE_DB_StringArray.create(app.FetchAppTextShort(ses,'$overview_net_receive_legend'),app.FetchAppTextShort(ses,'$overview_net_transmit_legend')),11,CWSF(@WEB_NetStatusInit));
  c4:=TFRE_DB_LIVE_CHART_DESC.create.DescribeLine('appl_stat_disk',2,120,CWSF(@WEB_DiskStatusStopStart),0,30,app.FetchAppTextShort(ses,'$overview_caption_disk'),TFRE_DB_StringArray.create('f00','0f0'),
        TFRE_DB_StringArray.create(app.FetchAppTextShort(ses,'$overview_disk_write_legend'),app.FetchAppTextShort(ses,'$overview_disk_read_legend')),11,CWSF(@WEB_DiskStatusInit));
  c5:=TFRE_DB_LIVE_CHART_DESC.create.DescribeLine('appl_stat_ram',2,120,CWSF(@WEB_RAMStatusStopStart),0,100,app.FetchAppTextShort(ses,'$overview_caption_ram'),TFRE_DB_StringArray.create('f00','0f0'),
        TFRE_DB_StringArray.create(app.FetchAppTextShort(ses,'$overview_ram_ram_legend'),app.FetchAppTextShort(ses,'$overview_ram_swap_legend')),11,CWSF(@WEB_RAMStatusInit));
  c6:=TFRE_DB_LIVE_CHART_DESC.create.DescribeLine('appl_stat_cache',2,120,CWSF(@WEB_CacheStatusStopStart),0,100,app.FetchAppTextShort(ses,'$overview_caption_cache'),TFRE_DB_StringArray.create('f00','0f0'),
        TFRE_DB_StringArray.create(app.FetchAppTextShort(ses,'$overview_cache_misses_legend'),app.FetchAppTextShort(ses,'$overview_cache_hits_legend')),11,CWSF(@WEB_CacheStatusInit));

  sub1l:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(c2,c5,nil,nil,nil,false,1,1);
  sub1:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(sub1l,c1,nil,nil,nil,false,2,1);

  sub2l:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(c3,c4,nil,nil,nil,false,1,1);
  sub2:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(sub2l,c6,nil,nil,nil,false,2,1);
  left:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,sub2,nil,sub1,nil,false,-1,1,-1,1);

  sub3:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(GetSession(input).FetchDerivedCollection('APP_POOL_BUSY').GetDisplayDescription,GetSession(input).FetchDerivedCollection('APP_POOL_AST').GetDisplayDescription,nil,nil,nil,false,1,1);
  sub4:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(GetSession(input).FetchDerivedCollection('APP_POOL_WBW').GetDisplayDescription,GetSession(input).FetchDerivedCollection('APP_POOL_RBW').GetDisplayDescription,nil,nil,nil,false,1,1);
  right:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,sub4,nil,sub3,nil,false,-1,1,-1,1);

  res:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(left,right,nil,nil,nil,false,3,2);
  result := res;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_CPUStatusStopStart(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if input.Field('action').AsString='start' then
      __idxCPU:=0
    else
      __idxCPU:=-1;
  _HandleRegisterSend(GetSession(input));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_CPUStatusInit(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  data  : TFRE_DB_LIVE_CHART_DATA_ARRAY;
  i     : Integer;
  start : Integer;
  bufidx: Integer;
begin
  SetLength(data,2);
  SetLength(data[0],122);
  SetLength(data[1],122);
  start:=G_AppliancePerformanceCurrentIdx - 121;
  if start<0 then begin
    start:=Length(G_AppliancePerformanceBuffer) + start;
  end;
  for i := 0 to 121 do begin
    bufidx := (start + i) mod Length(G_AppliancePerformanceBuffer);
    data[0][i]:=G_AppliancePerformanceBuffer[bufidx].cpu_aggr_sys;
    data[1][i]:=G_AppliancePerformanceBuffer[bufidx].cpu_aggr_sys_user;
  end;
  Result:=TFRE_DB_LIVE_CHART_INIT_DATA_DESC.create.Describe(data);
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_NetStatusStopStart(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if input.Field('action').AsString='start' then
      __idxNet:=0
    else
      __idxNet:=-1;
  _HandleRegisterSend(GetSession(input));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_NetStatusInit(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  data  : TFRE_DB_LIVE_CHART_DATA_ARRAY;
  i     : Integer;
  start : Integer;
  bufidx: Integer;
begin
  SetLength(data,2);
  SetLength(data[0],122);
  SetLength(data[1],122);
  start:=G_AppliancePerformanceCurrentIdx - 121;
  if start<0 then begin
    start:=Length(G_AppliancePerformanceBuffer) + start;
  end;
  for i := 0 to 121 do begin
    bufidx := (start + i) mod Length(G_AppliancePerformanceBuffer);
    data[0][i]:=G_AppliancePerformanceBuffer[bufidx].net_aggr_rx_bytes;
    data[1][i]:=G_AppliancePerformanceBuffer[bufidx].net_aggr_tx_bytes;
  end;
  Result:=TFRE_DB_LIVE_CHART_INIT_DATA_DESC.create.Describe(data);
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_RAMStatusStopStart(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if input.Field('action').AsString='start' then
    __idxRAM:=0
  else
    __idxRAM:=-1;
  _HandleRegisterSend(GetSession(input));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_RAMStatusInit(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  data  : TFRE_DB_LIVE_CHART_DATA_ARRAY;
  i     : Integer;
  start : Integer;
  bufidx: Integer;
begin
  SetLength(data,2);
  SetLength(data[0],122);
  SetLength(data[1],122);
  start:=G_AppliancePerformanceCurrentIdx - 121;
  if start<0 then begin
    start:=Length(G_AppliancePerformanceBuffer) + start;
  end;
  for i := 0 to 121 do begin
    bufidx := (start + i) mod Length(G_AppliancePerformanceBuffer);
    data[0][i]:=G_AppliancePerformanceBuffer[bufidx].vmstat_memory_free;
    data[1][i]:=G_AppliancePerformanceBuffer[bufidx].vmstat_memory_swap;
  end;
  Result:=TFRE_DB_LIVE_CHART_INIT_DATA_DESC.create.Describe(data);
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_DiskStatusStopStart(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if input.Field('action').AsString='start' then
      __idxDisk:=0
    else
      __idxDisk:=-1;
  _HandleRegisterSend(GetSession(input));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_DiskStatusInit(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  data  : TFRE_DB_LIVE_CHART_DATA_ARRAY;
  i     : Integer;
  start : Integer;
  bufidx: Integer;
begin
  SetLength(data,2);
  SetLength(data[0],122);
  SetLength(data[1],122);
  start:=G_AppliancePerformanceCurrentIdx - 121;
  if start<0 then begin
    start:=Length(G_AppliancePerformanceBuffer) + start;
  end;
  for i := 0 to 121 do begin
    bufidx := (start + i) mod Length(G_AppliancePerformanceBuffer);
    data[0][i]:=G_AppliancePerformanceBuffer[bufidx].disk_aggr_wps;
    data[1][i]:=G_AppliancePerformanceBuffer[bufidx].disk_aggr_rps;
  end;
  Result:=TFRE_DB_LIVE_CHART_INIT_DATA_DESC.create.Describe(data);
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_CacheStatusStopStart(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if input.Field('action').AsString='start' then
      __idxCache:=0
    else
      __idxCache:=-1;
  _HandleRegisterSend(GetSession(input));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_CacheStatusInit(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
//  data  : TFRE_DB_LIVE_CHART_INIT_DATA_ARRAY;
  i     : Integer;
  start : Integer;
  bufidx: Integer;
begin
  //SetLength(data,2);
  //SetLength(data[0],122);
  //SetLength(data[1],122);
  //start:=G_AppliancePerformanceCurrentIdx - 121;
  //if start<0 then begin
  //  start:=Length(G_AppliancePerformanceBuffer) + start;
  //end;
  //for i := 0 to 121 do begin
  //  bufidx := (start + i) mod Length(G_AppliancePerformanceBuffer);
  //  data[0][i]:=G_AppliancePerformanceBuffer[bufidx].cache_relMisses;
  //  data[1][i]:=G_AppliancePerformanceBuffer[bufidx].cache_relHits;
  //end;
  //Result:=TFRE_DB_LIVE_CHART_INIT_DATA_DESC.create.Describe(data);
  RESULT := TFRE_DB_MESSAGE_DESC.create.Describe('FIX','IT - CACHESTATUSINIT',fdbmt_info);
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_RAW_UPDATE(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var LIVE_DATA  : IFRE_DB_COLLECTION;
    LD         : IFRE_DB_Object;
    totalCache : Int64;
begin
  if assigned(G_HACK_SHARE_OBJECT) then
    begin
      G_HACK_SHARE_OBJECT.Finalize;
      G_HACK_SHARE_OBJECT:=nil;
    end;
  G_HACK_SHARE_OBJECT := input.CloneToNewObject();
  inc(G_AppliancePerformanceCurrentIdx);
  if G_AppliancePerformanceCurrentIdx>High(G_AppliancePerformanceBuffer) then
    G_AppliancePerformanceCurrentIdx:=0;

  with G_AppliancePerformanceBuffer[G_AppliancePerformanceCurrentIdx] do
    with G_HACK_SHARE_OBJECT do
      begin
        if FieldPathExists('cpu.cpu_aggr.sys') then
          begin
            cpu_aggr_sys       := FieldPath('cpu.cpu_aggr.sys').AsReal32;
            cpu_aggr_sys_user  := (FieldPath('cpu.cpu_aggr.sys').AsReal32 + FieldPath('cpu.cpu_aggr.usr').AsReal32);
          end;
        if FieldPathExists('net.net_aggr.rx.bytes') then
          begin
            net_aggr_rx_bytes  := FieldPath('net.net_aggr.rx.bytes').AsInt32/FtotalNet*100;
            net_aggr_tx_bytes  := FieldPath('net.net_aggr.tx.bytes').AsInt32/FtotalNet*100;
          end;
        if FieldPathExists('disk.disk_aggr.wps') then
          begin
            disk_aggr_wps      := FieldPath('disk.disk_aggr.wps').AsInt32 / 1000;
            disk_aggr_rps      := FieldPath('disk.disk_aggr.rps').AsInt32 / 1000;
          end;
        if FieldPathExists('vmstat.memory_free') then
          begin
            vmstat_memory_free := (1-(FieldPath('vmstat.memory_free').AsInt32 / FtotalRam))  * 100;
            vmstat_memory_swap := (1-(FieldPath('vmstat.memory_swap').AsInt32 / FtotalSwap)) * 100;
          end;
        if FieldPathExists('cache.relHits') then
          begin
            totalCache         := FieldPath('cache.relHits').AsInt64 +FieldPath('cache.relMisses').AsInt64;
            if totalCache=0 then
              totalCache:=1;
            cache_relMisses    := FieldPath('cache.relMisses').AsInt64 / totalCache * 100;
            cache_relHits      := FieldPath('cache.relHits').AsInt64 / totalCache * 100;
          end;
      end;


  //LIVE_DATA := GetDBConnection(raw_data).Collection('LIVE_STATUS',false,false);
  //if LIVE_DATA.GetIndexedObj('live',ld) then
  //  begin
  //     ld.Field('data').AsObject := raw_data.CloneToNewObject;
  //     //LIVE_DATA.Update(ld);
  //  end
  //else
  //  begin
  //    ld := GFRE_DBI.NewObject;
  //    ld.Field('feedname').AsString:='live';
  //    ld.Field('data').AsObject := raw_data.CloneToNewObject;
  //    writeln(ld.DumpToString());
  //    LIVE_DATA.Store(ld);
  //    Abort;
  //    halt;
  //  end;
  //
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.WEB_RAW_UPDATE30(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  coll   : IFRE_DB_COLLECTION;
begin
   //TURN OFF SAFETY
  //_fillPoolCollection(ses.GetDBConnection,input.Field('zfs').AsObject);
  result := GFRE_DB_NIL_DESC;
end;

{ TFRE_FIRMBOX_APPLIANCE_APP }

procedure TFRE_FIRMBOX_APPLIANCE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('$description');
  AddApplicationModule(TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.create);
  //AddApplicationModule(TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD.create);
end;

procedure TFRE_FIRMBOX_APPLIANCE_APP._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Status',FetchAppTextShort(session,'$sitemap_main'),'images_apps/firmbox_appliance/appliance_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_APPLIANCE_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Status/Overview',FetchAppTextShort(session,'$sitemap_status'),'images_apps/firmbox_appliance/status_white.svg',TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_APPLIANCE_STATUS_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Status/Settings',FetchAppTextShort(session,'$sitemap_settings'),'images_apps/firmbox_appliance/settings_white.svg',TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD));
  //FREDB_SiteMap_AddRadialEntry(SiteMapData,'Status/Analytics',FetchAppTextShort(session,'$sitemap_analytics'),'images_apps/firmbox_appliance/analytics_white.svg',TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD.ClassName,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_FIRMBOX_APPLIANCE_APP.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_APPLIANCE_APP.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFRE_FIRMBOX_APPLIANCE_APP.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFRE_FIRMBOX_APPLIANCE_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited;

  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      currentVersionId := '1.0';
      CreateAppText(conn,'$caption','Appliance','Appliance','Appliance');
      CreateAppText(conn,'$sitemap_main','Appliance','','Appliance');
      CreateAppText(conn,'$sitemap_status','Overview','','Overview');
      CreateAppText(conn,'$sitemap_settings','Settings','','Settings');
      CreateAppText(conn,'$sitemap_analytics','Analytics','','Analytics');
      CreateAppText(conn,'$status_description','Status','Appliance Status','Overall status of appliance');
      CreateAppText(conn,'$settings_description','Settings','Appliance Settings','Global settings of appliance');
      CreateAppText(conn,'$analytics_description','Analytics','Appliance Analytics','Analytics of appliance');

      CreateAppText(conn,'$appliance_settings_system','System');
      CreateAppText(conn,'$appliance_settings_datalink','Network');
      CreateAppText(conn,'$appliance_settings_iscsi','iSCSI');
      CreateAppText(conn,'$appliance_settings_fibrechannel','Fibre Channel');

      CreateAppText(conn,'$system_content_header','Details about the selected Setting');
      CreateAppText(conn,'$system_name','Setting');
      CreateAppText(conn,'$system_desc','Description');
      CreateAppText(conn,'$system_reboot','Reboot');
      CreateAppText(conn,'$system_shutdown','Shutdown');

      CreateAppText(conn,'$datalink_content_header','Details about the selected Network Interface');
      CreateAppText(conn,'$datalink_name','Name');
      CreateAppText(conn,'$datalink_zoned','Zoned');
      CreateAppText(conn,'$datalink_desc','Description');
      CreateAppText(conn,'$create_aggr','Create Aggregation');
      CreateAppText(conn,'$aggr_add_diag_cap','New Interface Aggregation');
      CreateAppText(conn,'$datalink_add_vnic','Add new Virtual Interface');
      CreateAppText(conn,'$datalink_delete_vnic','Delete Virtual Interface');
      CreateAppText(conn,'$datalink_delete_aggr','Delete Aggregation');
      CreateAppText(conn,'$datalink_delete_stub','Delete Virtual Switch');

      CreateAppText(conn,'$fc_content_header','Details about the selected Fibre Channel port');
      CreateAppText(conn,'$fc_wwn','Port WWN');
      CreateAppText(conn,'$fc_targetmode','Target Mode');
      CreateAppText(conn,'$fc_state','State');
      CreateAppText(conn,'$fc_desc','Description');

      CreateAppText(conn,'$overview_caption_cpu','CPU Load (4 Intel E5-4620@2.20GHz)');
      CreateAppText(conn,'$overview_cpu_system_legend','System [%]');
      CreateAppText(conn,'$overview_cpu_user_legend','User [%]');
      CreateAppText(conn,'$overview_caption_net','Network');
      CreateAppText(conn,'$overview_net_receive_legend','Receive [%]');
      CreateAppText(conn,'$overview_net_transmit_legend','Transmit [%]');
      CreateAppText(conn,'$overview_caption_disk','Disk I/O (Device Aggregation)');
      CreateAppText(conn,'$overview_disk_read_legend','Read [kIOPS]');
      CreateAppText(conn,'$overview_disk_write_legend','Write [kIOPS]');
      CreateAppText(conn,'$overview_caption_ram','Memory Usage (256GB RAM, 256GB Swap)');
      CreateAppText(conn,'$overview_ram_ram_legend','RAM [%]');
      CreateAppText(conn,'$overview_ram_swap_legend','Swap [%]');
      CreateAppText(conn,'$overview_caption_cache','Cache (Adaptive Read Cache)');
      CreateAppText(conn,'$overview_cache_hits_legend','Hits [%]');
      CreateAppText(conn,'$overview_cache_misses_legend','Misses [%]');

      CreateAppText(conn,'$button_save','Save'); //global text?
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
  VersionInstallCheck(currentVersionId,newVersionId);
end;

class procedure TFRE_FIRMBOX_APPLIANCE_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then
    begin
      currentVersionId := '1.0';

      CheckDbResult(conn.AddGroup('APPLIANCEFEEDER','Group for Appliance Data Feeder','VM Feeder',domainUID),'could not create Appliance feeder group');

      CheckDbResult(conn.AddRolesToGroup('APPLIANCEFEEDER',domainUID,TFRE_DB_StringArray.Create(
        TFRE_FIRMBOX_APPLIANCE_APP.GetClassRoleNameFetch
        )),'could not add roles for group APPLIANCEFEEDER');
    end;
end;

function TFRE_FIRMBOX_APPLIANCE_APP.WEB_RAW_DATA_FEED(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := DelegateInvoke(TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.ClassName,'RAW_UPDATE',input);
end;

function TFRE_FIRMBOX_APPLIANCE_APP.WEB_RAW_DATA_FEED30(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := DelegateInvoke(TFRE_FIRMBOX_APPLIANCE_STATUS_MOD.ClassName,'RAW_UPDATE30',input);
end;

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_APPLIANCE_ANALYTICS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_APPLIANCE_SETTINGS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_APPLIANCE_STATUS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_APPLIANCE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

end.

