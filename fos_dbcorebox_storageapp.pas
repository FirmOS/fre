unit FOS_DBCOREBOX_STORAGEAPP;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,fos_dbcorebox_vm_machines_mod,
  FRE_DB_SYSRIGHT_CONSTANTS,FRE_ZFS,FOS_DBCOREBOX_FILESERVER,
  FRE_DB_INTERFACE,fos_stats_control_interface,FOS_VM_CONTROL_INTERFACE,
  FRE_DB_COMMON;

var
    DISKI_HACK : IFOS_STATS_CONTROL;
    VM_HACK    : IFOS_VM_HOST_CONTROL;
    ZPOOL_IOSTAT_UPDATE: TFRE_DB_UPDATE_STORE_DESC;

type

  { TFRE_DBCOREBOX_STORAGE_APP }

  TFRE_DBCOREBOX_STORAGE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    function        InstallAppDefaults          (const conn : IFRE_DB_SYS_CONNECTION):TFRE_DB_Errortype; override;
    function        InstallSystemGroupsandRoles (const conn : IFRE_DB_SYS_CONNECTION; const domain : TFRE_DB_NameType):TFRE_DB_Errortype; override;
    procedure       _UpdateSitemap              (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize         (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion          (const session: TFRE_DB_UserSession); override;
    function        CFG_ApplicationUsesRights   : boolean; override;
    function        _ActualVersion              : TFRE_DB_String; override;
  public
    class procedure RegisterSystemScheme        (const scheme:IFRE_DB_SCHEMEOBJECT); override;
  published
    function        IMI_RAW_DISK_FEED           (const data:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DBCOREBOX_STORAGE_POOLS_MOD }

  TFRE_DBCOREBOX_STORAGE_POOLS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _addDisksToPool            (const pool: TFRE_DB_ZFS_ROOTOBJ; const target:TFRE_DB_ZFS_OBJ; const disks: TFRE_DB_StringArray; const app: TFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: TFRE_DB_UserSession):TFRE_DB_MENU_DESC;
    function        _getPool                   (const conn: IFRE_DB_CONNECTION; const id: String): TFRE_DB_ZFS_ROOTOBJ;
    function        _getPoolByName             (const conn: IFRE_DB_CONNECTION; const name: String): TFRE_DB_ZFS_ROOTOBJ;
    function        _getUnassignedPool         (const conn: IFRE_DB_CONNECTION): TFRE_DB_ZFS_UNASSIGNED;
    function        _getTreeObj                (const zfsObj: TFRE_DB_ZFS_OBJ):IFRE_DB_Object;
    procedure       _unassignDisk              (const upool:TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: TFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: TFRE_DB_UserSession);
    function        _SendData                  (const Input:IFRE_DB_Object):IFRE_DB_Object;
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    function        Usage                     (const input:IFRE_DB_Object):TFRE_DB_CONTENT_DESC;
    function        ServiceTime               (const input:IFRE_DB_Object):TFRE_DB_CONTENT_DESC;
    function        BusyTime                  (const input:IFRE_DB_Object):TFRE_DB_CONTENT_DESC;
    function        ReadBW                    (const input:IFRE_DB_Object):TFRE_DB_CONTENT_DESC;
    function        WriteBW                   (const input:IFRE_DB_Object):TFRE_DB_CONTENT_DESC;
    procedure       UpdateDiskCollection      (const pool_disks : IFRE_DB_COLLECTION ; const data:IFRE_DB_Object);
    procedure       UpdateZpool               (const zpool: TFRE_DB_ZFS_ROOTOBJ; const data:IFRE_DB_Object; const updateDescr: TFRE_DB_UPDATE_STORE_DESC);
  public
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
    procedure       MyServerInitializeModule  (const admin_dbc : IFRE_DB_CONNECTION); override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_PoolLayout            (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_PoolSpace             (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_PoolNotes             (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_PoolNotesLoad         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_PoolNotesSave         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_TreeGridData          (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_TreeDrop              (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_GridMenu              (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_UpdatePoolsTree       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreatePool            (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreatePoolDiag        (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ImportPoolDiag        (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_AssignSpareDisk       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_AssignCacheDisk       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_AssignLogDisk         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_AssignStorageDisk     (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_RemoveNew             (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ChangeRaidLevel       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_DestroyPool           (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_DestroyPoolConfirmed  (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_Identify_on           (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_Identify_off          (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_SwitchOffline         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_SwitchOnline          (const input: IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_SaveConfig            (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ResetConfig           (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_Replace               (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_RAW_DISK_FEED         (const data:IFRE_DB_Object):IFRE_DB_Object;
  end;


  { TFRE_DBCOREBOX_STORAGE_SYNCH_MOD }

  TFRE_DBCOREBOX_STORAGE_SYNCH_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD }

  TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _GetFileServerID          (conn : IFRE_DB_CONNECTION): TGuid;
    function        _getShareNames            (const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  public
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ContentFilerNFS       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ContentFilerLUN       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreateNFSExport       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreateNFSAccess       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_NFSContent            (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_NFSMenu               (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_NFSDelete             (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_NFSDeleteConfirmed    (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_NFSAccessMenu         (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_NFSAccessDelete       (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_NFSAccessModify       (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_CreateLUN             (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreateLUNView         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_LUNMenu               (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_LUNContent            (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_LUNDelete             (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_LUNDeleteConfirmed    (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_LUNViewMenu           (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_LUNViewDelete         (const input:IFRE_DB_OBject):IFRE_DB_Object;
    function        IMI_LUNViewModify         (const input:IFRE_DB_OBject):IFRE_DB_Object;
  end;

  { TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD }

  TFILESHARE_ROLETYPE = (rtRead,rtWrite);

  TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _getVFSNames               (const vfss: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
    function        _getShareNames             (const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
    function        _getRolename               (const share_id: TFRE_DB_NameType; const roletype: TFILESHARE_ROLETYPE): TFRE_DB_NameType;
    function        _setShareRoles             (const input:IFRE_DB_Object; const change_read,change_write,read,write:boolean) : IFRE_DB_Object;
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure    ; override;
  public
    procedure       CalculateReadWriteAccess   (const conn : IFRE_DB_CONNECTION ; const dependency_input : IFRE_DB_Object; const input_object : IFRE_DB_Object ; const transformed_object : IFRE_DB_Object);
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        IMI_Content                (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ContentShareGroups     (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ContentVFShares        (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreateVFS              (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSMenu                (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSContent             (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSDelete              (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSDeleteConfirmed     (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_CreateVFSShare         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareMenu           (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareContent        (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareDelete         (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareDeleteConfirmed(const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupMenu      (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupSetRead   (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupSetWrite  (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupClearRead (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupClearWrite(const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupInDrop    (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_VFSShareGroupOutDrop   (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DBCOREBOX_BACKUP_MOD }

  TFRE_DBCOREBOX_BACKUP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ContentSnapshot       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_ContentSchedule       (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_SnapshotMenu          (const input:IFRE_DB_Object):IFRE_DB_Object;
    function        IMI_DeleteSnapshot        (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;

implementation

var __idx: NativeInt; //FIXXXME - remove me

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_BACKUP_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_STORAGE_POOLS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_STORAGE_SYNCH_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DBCOREBOX_STORAGE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD }

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD._getVFSNames(const vfss: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
var
  i     : NativeInt;
  vfs   : IFRE_DB_Object;
begin
   result := '';
  for i := 0 to Length(vfss) - 1 do begin
    conn.Fetch(GFRE_BT.HexString_2_GUID(vfss[i]),vfs);
    if i>0 then begin
      result := result +', ';
    end;
    result := result + vfs.Field('objname').AsString;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD._getShareNames(const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
var
  i     : NativeInt;
  share : IFRE_DB_Object;
begin
   result := '';
  for i := 0 to Length(shares) - 1 do begin
    conn.Fetch(GFRE_BT.HexString_2_GUID(shares[i]),share);
    if i>0 then begin
      result := result +', ';
    end;
    result := result + share.Field('objname').AsString;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD._getRolename(const share_id: TFRE_DB_NameType; const roletype: TFILESHARE_ROLETYPE): TFRE_DB_NameType;
begin
  case roletype of
    rtRead  : result := FREDB_Get_Rightname_UID('FSREAD',GFRE_BT.HexString_2_GUID(share_id));
    rtWrite : result := FREDB_Get_Rightname_UID('FSWRITE',GFRE_BT.HexString_2_GUID(share_id));
   else
     raise EFRE_DB_Exception.Create('Undefined Roletype for Fileshare');
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD._setShareRoles(const input: IFRE_DB_Object; const change_read, change_write, read, write: boolean): IFRE_DB_Object;
var
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  dependend     : TFRE_DB_StringArray;
  share_s       : string;
  share_id      : TGuid;
  share         : IFRE_DB_Object;
  rrole         : TFRE_DB_NameType;
  wrole         : TFRE_DB_NameType;
  group         : IFRE_DB_GROUP;
  groupid       : TGuid;
  i             : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;

  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
//  GFRE_BT.SeperateString(input.Field('selected').AsString,',',sIdPath);

  if input.FieldExists('share_id') then begin
    share_s  := input.Field('share_id').asstring;
  end else begin
    dependend  := GetDependencyFiltervalues(input,'uids_ref');
    if length(dependend)=0 then begin
      Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$share_group_in_diag_cap').Getshort,app.FetchAppText(conn,'$share_group_in_no_share_msg').Getshort,fdbmt_warning,nil);
      exit;
    end;
    share_s   := dependend[0];
  end;
  share_id := GFRE_BT.HexString_2_GUID(share_s);

  if conn.Fetch(share_id,share)=false then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'Share not found!').Getshort);


  for i := 0 to input.Field('selected').ValueCount-1 do begin
    groupid := GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]);
    if (conn.FetchGroupById(groupid,group)<>edb_OK) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'Group not found!').Getshort);
//    writeln( group.ObjectName,'->',GFRE_DBI.StringArray2String(group.GetRoleNames));

    rrole := _getRolename(share_s,rtRead);
    if conn.RoleExists(rrole+'@'+group.Domain)=false then raise EFRE_DB_Exception.Create('No Read Role for Fileshare !');

    wrole := _getRolename(share_s,rtWrite);
    if conn.RoleExists(wrole+'@'+group.Domain)=false then raise EFRE_DB_Exception.Create('No Write Role for Fileshare !');

    if change_read then begin
      if read then begin
        conn.AddGroupRoles(group.ObjectName+'@'+group.Domain,GFRE_DBI.ConstructStringArray([rrole+'@'+group.Domain]));
      end else begin
        conn.RemoveGroupRoles(group.ObjectName+'@'+group.Domain,GFRE_DBI.ConstructStringArray([rrole+'@'+group.Domain]),true);
      end;
    end;
    if change_write then begin
      if write then begin
        conn.AddGroupRoles(group.ObjectName+'@'+group.Domain,GFRE_DBI.ConstructStringArray([wrole+'@'+group.Domain]));
      end else begin
        conn.RemoveGroupRoles(group.ObjectName+'@'+group.Domain,GFRE_DBI.ConstructStringArray([wrole+'@'+group.Domain]),true);
      end;
    end;
  end;

//  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DROP','Adding share roles to '+ input.Field('selected').AsStringDump,fdbmt_info);
  Result:=GFRE_DB_NIL_DESC;
end;

class procedure TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('STORAGE_FILESERVER_VIRTUAL','$fileserver_virtual_description')
end;

procedure TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.CalculateReadWriteAccess(const conn: IFRE_DB_CONNECTION; const dependency_input: IFRE_DB_Object; const input_object: IFRE_DB_Object; const transformed_object: IFRE_DB_Object);
var sel_guid,rr,wr : string;
    sel_guidg      : TGUID;
    group_id       : TGUID;
    true_icon      : string;
    false_icon     : string;
begin
  //writeln('MY OWN TRANSFORM');
  //writeln('------');
  //writeln(dependency_input.DumpToString());
  //writeln('------');
  //writeln(input_object.DumpToString());
  //writeln('------');
  //transformed_object.field('read').AsBoolean:=true;
  //transformed_object.field('write').AsBoolean:=false;
  //writeln('------');
  //writeln(transformed_object.DumpToString());
  //writeln('------');
  //
  sel_guid  := dependency_input.FieldPath('UIDS_REF.FILTERVALUES').AsString;
  sel_guidg := GFRE_BT.HexString_2_GUID(sel_guid);
  group_id  := input_object.uid;
    //begin
    //  writeln('-------------- SHARE ----');
    //  writeln(obj.DumpToString());
    //  writeln('-------------- SHARE ----');
    //end;

  rr := FREDB_Get_Rightname_UID_STR('FSREAD',sel_guid);
  wr := FREDB_Get_Rightname_UID_STR('FSWRITE',sel_guid);

  true_icon  := getThemedResource('images_apps/corebox_storage/access_true.png');
  false_icon := getThemedResource('images_apps/corebox_storage/access_false.png');
  if conn.CheckRightForGroup(rr,group_id) then
    transformed_object.field('read').Asstring  := true_icon
  else
    transformed_object.field('read').Asstring  := false_icon;

  if conn.CheckRightForGroup(wr,group_id) then
    transformed_object.field('write').Asstring  := true_icon
  else
    transformed_object.field('write').Asstring  := false_icon;

end;

procedure TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var fs_dc           : IFRE_DB_DERIVED_COLLECTION;
    fs_tr_Grid      : IFRE_DB_SIMPLE_TRANSFORM;
    share_dc        : IFRE_DB_DERIVED_COLLECTION;
    share_tr_Grid   : IFRE_DB_SIMPLE_TRANSFORM;
    groupin_dc      : IFRE_DB_DERIVED_COLLECTION;
    groupin_tr_Grid : IFRE_DB_SIMPLE_TRANSFORM;
    groupout_dc     : IFRE_DB_DERIVED_COLLECTION;
    groupout_tr_Grid: IFRE_DB_SIMPLE_TRANSFORM;

    app             : TFRE_DB_APPLICATION;
    conn            : IFRE_DB_CONNECTION;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,fs_tr_Grid);
    with fs_tr_Grid do begin
      AddOneToOnescheme('objname','Fileserver',app.FetchAppText(conn,'$vfs_name').Getshort);
      AddOneToOnescheme('pool','pool',app.FetchAppText(conn,'$vfs_pool').Getshort);
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$vfs_desc').Getshort);
      AddOneToOnescheme('ip','ip',app.FetchAppText(conn,'$vfs_ip').Getshort);
      AddOneToOnescheme('domain','domain',app.FetchAppText(conn,'$vfs_domain').Getshort);
    end;
    fs_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
    with fs_dc do begin
      SetDeriveParent(conn.Collection('service'));
      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_VIRTUAL_FILESERVER.ClassName));
      SetDeriveTransformation(fs_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CSF(@IMI_VFSMenu),nil,CSF(@IMI_VFSContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,share_tr_Grid);
    with share_tr_Grid do begin
      AddOneToOnescheme('objname','share',app.FetchAppText(conn,'$vfs_share').Getshort);
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$vfs_share_desc').Getshort);
      AddOneToOnescheme('icons','',app.FetchAppText(conn,'$vfs_share_icon').GetShort,dt_icon);
      AddOneToOnescheme('refer_mb','refer',app.FetchAppText(conn,'$vfs_share_refer').Getshort);
      AddOneToOnescheme('used_mb','used',app.FetchAppText(conn,'$vfs_share_used').Getshort);
      AddOneToOnescheme('quota_mb','avail',app.FetchAppText(conn,'$vfs_share_avail').Getshort);
    end;
    share_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
    with share_dc do begin
      //SetDeriveParent(conn.Collection('fileshare'));
      SetReferentialLinkMode('TFRE_DB_VIRTUAL_FILESHARE|FILESERVER',false);
      //AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_VIRTUAL_FILESHARE.ClassName));
      SetDeriveTransformation(share_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CSF(@IMI_VFSShareMenu),nil,CSF(@IMI_VFSShareContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,groupin_tr_Grid);
    with groupin_tr_Grid do begin
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$share_group_desc').Getshort);
      AddOneToOnescheme('read','',app.FetchAppText(conn,'$share_group_read').Getshort,dt_Icon);
      AddOneToOnescheme('write','',app.FetchAppText(conn,'$share_group_write').Getshort,dt_Icon);
//      AddOneToOnescheme('objname','group',app.FetchAppText(conn,'$share_group_group').Getshort);
      SetCustomTransformFunction(@CalculateReadWriteAccess);
    end;
    groupin_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
    with groupin_dc do begin
      SetDeriveParent(session.GetDBConnection.AdmGetGroupCollection);
      SetDeriveTransformation(groupin_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_enableMultiselect],app.FetchAppText(conn,'$share_group_in').Getshort,nil,'',CSF(@IMI_VFSShareGroupMenu),nil,nil,nil,CSF(@IMI_VFSShareGroupInDrop));
    end;

    //GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,groupout_tr_Grid);
    //with groupout_tr_Grid do begin
    //  AddOneToOnescheme('objname','group',app.FetchAppText(conn,'$share_group_group').Getshort);
    //  AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$share_group_desc').Getshort);
    //end;
    //groupout_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
    //with groupout_dc do begin
    //  SetDeriveParent(session.GetDBConnection.AdmGetGroupCollection);
    //  SetDeriveTransformation(groupout_tr_Grid);
    //  SetDisplayType(cdt_Listview,[],app.FetchAppText(conn,'$share_group_out').Getshort,nil,'',nil,nil,nil,nil,CSF(@IMI_VFSShareGroupOutDrop));
    //end;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  vfs           : TFRE_DB_LAYOUT_DESC;
  sub_sec_fs    : TFRE_DB_SUBSECTIONS_DESC;
  grid_fs       : TFRE_DB_VIEW_LIST_DESC;
  dc_fs         : IFRE_DB_DERIVED_COLLECTION;
  dc_share      : IFRE_DB_DERIVED_COLLECTION;

  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  txt           : IFRE_DB_TEXT;

begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_fileserver_virtual') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sub_sec_fs   := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);

  dc_fs       := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
  grid_fs     := dc_fs.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs')) then begin
    txt:=app.FetchAppText(conn,'$create_vfs');
    grid_fs.AddButton.Describe(CSF(@IMI_CreateVFS),'images_apps/corebox_storage/create_vfs.png',txt.Getshort,txt.GetHint);
  end;


  dc_share    := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
  //FIXXME Heli - make it working
  grid_fs.AddFilterEvent(dc_share.getDescriptionStoreId(),'uids');

  sub_sec_fs.AddSection.Describe(CSF(@IMI_ContentVFShares),app.FetchAppText(conn,'$storage_virtual_filer_shares').Getshort,1,'shares');
  sub_sec_fs.AddSection.Describe(CSF(@IMI_VFSContent),app.FetchAppText(conn,'$storage_virtual_filer_content').Getshort,2,'vfs');

  vfs          := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_fs,sub_sec_fs,nil,nil,nil,true,1,3);

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,vfs,nil,TFRE_DB_HTML_DESC.create.Describe('<b>Overview of virtual NAS fileservers and shares.</b>'));
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_ContentShareGroups(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  dc_group_in   : IFRE_DB_DERIVED_COLLECTION;
  //grid_group_in : TFRE_DB_VIEW_LIST_DESC;
  //dc_group_out  : IFRE_DB_DERIVED_COLLECTION;
  //grid_group_out: TFRE_DB_VIEW_LIST_DESC;
  //share_group   : TFRE_DB_LAYOUT_DESC;
begin
  writeln('CSG: ');
  writeln(input.DumpToString);
  if not CheckAppRightModule(input,'storage_fileserver_virtual') then
    raise EFRE_DB_Exception.Create(FetchAppText(input,'$error_no_access').Getshort);

  dc_group_in   := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
  result        := dc_group_in.GetDisplayDescription;

  //dc_group_out  := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
  //grid_group_out:= dc_group_out.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  //
//  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then begin
//    grid_group_out.SetDropGrid(grid_group_in,nil,TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
////  grid_group_in.SetDragObjClasses(TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
//    grid_group_in.SetDropGrid(grid_group_out,nil,TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
////  grid_group_out.SetDragObjClasses(TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
//  end;

  //share_group   := //TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,grid_group_out,nil,grid_group_in,nil,true,-1,1,-1,1);
  //Result        := share_group;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_ContentVFShares(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn          : IFRE_DB_CONNECTION;
  app           : TFRE_DB_APPLICATION;
  sub_sec_share : TFRE_DB_SUBSECTIONS_DESC;
  dc_group_in   : IFRE_DB_DERIVED_COLLECTION;
  dc_group_out  : IFRE_DB_DERIVED_COLLECTION;
  share         : TFRE_DB_LAYOUT_DESC;
  txt           : IFRE_DB_TEXT;
  dc_share      : IFRE_DB_DERIVED_COLLECTION;
  grid_share    : TFRE_DB_VIEW_LIST_DESC;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_fileserver_virtual') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  dc_share    := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
  grid_share  := dc_share.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then begin
    txt:=app.FetchAppText(conn,'$create_vfs_share');
    grid_share.AddButton.Describe(CSF(@IMI_CreateVFSShare),'images_apps/corebox_storage/create_vfs_share.png',txt.Getshort,txt.GetHint);
  end;

  sub_sec_share := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  sub_sec_share.AddSection.Describe(CSF(@IMI_VFSShareContent),app.FetchAppText(conn,'$storage_virtual_filer_share_properties').Getshort,1,'shareproperties');
  sub_sec_share.AddSection.Describe(CSF(@IMI_ContentShareGroups),app.FetchAppText(conn,'$storage_virtual_filer_share_groups').Getshort,1,'sharegroups');

  dc_group_in   := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
  //dc_group_out  := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
  //FIXXME Heli - make it working
  grid_share.AddFilterEvent(dc_group_in.getDescriptionStoreId,'uids');
  //grid_share.AddFilterEvent(dc_group_out.getDescriptionStoreId,'uids');

  share         := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_share,sub_sec_share,nil,nil,nil,true,2,3);
  Result        := share;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_CreateVFS(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  conn.GetScheme(TFRE_DB_VIRTUAL_FILESERVER.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$vfs_add_diag_cap').Getshort,600,0,true,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
  res.SetElementValue('pool','zones');
  serverfunc := CSCF(TFRE_DB_VIRTUAL_FILESERVER.ClassName,'NewOperation','collection','service');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;


function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSMenu(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_VFSDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$vfs_delete').Getshort,'images_apps/corebox_storage/delete_vfs.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSContent(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  vfs           : IFRE_DB_Object;
  sel_guid      : TGUID;
  dom_guid      : TGUID;
  dc_groupin    : IFRE_DB_DERIVED_COLLECTION;
begin
  conn     := GetDBConnection(input);
  app      := GetEmbeddingApp;

  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
    if dc.FetchFromParent(sel_guid,vfs) then begin
      conn.GetScheme(vfs.SchemeClass,scheme);
      dom_guid := vfs.Field('domainid').AsGUID;
      writeln('DOMAINID :',GFRE_BT.GUID_2_HexString(dom_guid));
      dc_groupin := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
      dc_groupin.AddUIDFieldFilter('*domain*','domainid',TFRE_DB_GUIDArray.Create(dom_guid),dbnf_EXACT,false);

      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$vfs_content_header').ShortText);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
      panel.FillWithObjectValues(vfs,GetSession(input));
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(vfs,'saveOperation'),fdbbt_submit);
      panel.contentId:='VIRTUAL_FS_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$vfs_content_header').ShortText);
    panel.contentId:='VIRTUAL_FS_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSDelete(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sf:=CSF(@IMI_VFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppText(conn,'$vfs_delete_diag_cap').Getshort;
  msg:=_getVFSNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppText(conn,'$vfs_delete_diag_msg').Getshort,'%vfs_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSDeleteConfirmed(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  i      : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i:= 0 to input.Field('selected').ValueCount-1 do begin
    //FIXXME: Errorhandling
    CheckDbResult(conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i])),'The object is referenced');
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_CreateVFSShare(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
  fileserver : TFRE_DB_String;
  dependend  : TFRE_DB_StringArray;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  dependend  := GetDependencyFiltervalues(input,'uids_ref');
  if length(dependend)=0 then begin
     Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$vfs_share_add_diag_cap').Getshort,app.FetchAppText(conn,'$vfs_share_add_no_fs_msg').Getshort,fdbmt_warning,nil);
     exit;
  end;
  fileserver := dependend[0];


  conn.GetScheme(TFRE_DB_VIRTUAL_FILESHARE.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$vfs_share_add_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
  res.AddSchemeFormGroup(scheme.GetInputGroup('share'),GetSession(input),true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('file'),GetSession(input),true,true);
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),GetSession(input),true,true);
  res.SetElementValue('fileserver',fileserver);
  res.SetElementValue('pool','zones');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_VIRTUAL_FILESHARE.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareMenu(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_VFSShareDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$vfs_share_delete').Getshort,'images_apps/corebox_storage/delete_vfs_share.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareContent(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  share         : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  conn     := GetDBConnection(input);
  app      := GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'view_vfs_share')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
    if dc.FetchFromParent(sel_guid,share) then begin
      conn.GetScheme(share.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$vfs_share_content_header').ShortText);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('share'),GetSession(input),true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('file'),GetSession(input),true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),GetSession(input),true,true);
      panel.FillWithObjectValues(share,GetSession(input));
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(share,'saveOperation'),fdbbt_submit);
      panel.contentId:='VIRTUAL_SHARE_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$vfs_share_content_header').ShortText);
    panel.contentId:='VIRTUAL_SHARE_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareDelete(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sf:=CSF(@IMI_VFSShareDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppText(conn,'$vfs_share_delete_diag_cap').Getshort;
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppText(conn,'$vfs_share_delete_diag_msg').Getshort,'%share_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareDeleteConfirmed(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  i      : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i:= 0 to input.Field('selected').ValueCount-1 do begin
    //FIXXME: Errorhandling
    conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
  end;
  result := GFRE_DB_NIL_DESC;
end;


function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupMenu(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
  share_id  : TFRE_DB_NameType;
  dependend : TFRE_DB_StringArray;
begin
  dependend  := GetDependencyFiltervalues(input,'uids_ref');
  if length(dependend)=0 then begin
     Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$share_group_in_diag_cap').Getshort,app.FetchAppText(conn,'$share_group_in_no_share_msg').Getshort,fdbmt_warning,nil);
     exit;
  end;
  share_id   := dependend[0];

  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_vfs_share')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_VFSShareGroupSetRead);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$share_group_setread_on').Getshort,'images_apps/corebox_storage/share_access_set_on.png',func);
    func:=CSF(@IMI_VFSShareGroupSetWrite);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$share_group_setwrite_on').Getshort,'images_apps/corebox_storage/share_access_set_on.png',func);
    func:=CSF(@IMI_VFSShareGroupClearRead);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$share_group_setread_off').Getshort,'images_apps/corebox_storage/share_access_set_off.png',func);
    func:=CSF(@IMI_VFSShareGroupClearWrite);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$share_group_setwrite_off').Getshort,'images_apps/corebox_storage/share_access_set_off.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupSetRead(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=_setShareRoles(input,true,false,true,false);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupSetWrite(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=_setShareRoles(input,false,true,false,true);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupClearRead(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=_setShareRoles(input,true,false,false,false);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupClearWrite(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=_setShareRoles(input,false,true,false,false);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupInDrop(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := _setShareRoles(input,true,true,true,true);
end;

function TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.IMI_VFSShareGroupOutDrop(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := _setShareRoles(input,true,true,false,false);
end;

{ TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD }

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD._GetFileServerID(conn: IFRE_DB_CONNECTION): TGuid;
var coll  : IFRE_DB_COLLECTION;
    id    : TGuid;

  function _get(const obj:IFRE_DB_Object):boolean;
  begin
    if obj.IsA(TFRE_DB_GLOBAL_FILESERVER.ClassName) then begin
      id     := obj.UID;
      result := true;
    end else begin
      result := false;
    end;
  end;

begin
  coll   := conn.Collection('service');
  coll.ForAllBreak(@_get);
  result := id;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD._getShareNames(const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
var
  i     : NativeInt;
  share : IFRE_DB_Object;
begin
   result := '';
  for i := 0 to Length(shares) - 1 do begin
    conn.Fetch(GFRE_BT.HexString_2_GUID(shares[i]),share);
    if i>0 then begin
      result := result +', ';
    end;
    result := result + share.Field('objname').AsString;
  end;
end;

class procedure TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('STORAGE_FILESERVER_GLOBAL','$fileserver_global_description')
end;

procedure TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var nfs_share_dc       : IFRE_DB_DERIVED_COLLECTION;
    nfs_tr_Grid        : IFRE_DB_SIMPLE_TRANSFORM;
    nfs_access_dc      : IFRE_DB_DERIVED_COLLECTION;
    nfs_access_tr_Grid : IFRE_DB_SIMPLE_TRANSFORM;
    lun_dc             : IFRE_DB_DERIVED_COLLECTION;
    lun_tr_Grid        : IFRE_DB_SIMPLE_TRANSFORM;
    lun_view_dc        : IFRE_DB_DERIVED_COLLECTION;
    lun_view_tr_Grid   : IFRE_DB_SIMPLE_TRANSFORM;

    app           : TFRE_DB_APPLICATION;
    conn          : IFRE_DB_CONNECTION;
    fileserverid  : TGUID;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,nfs_tr_Grid);
    with nfs_tr_Grid do begin
      AddOneToOnescheme('objname','export',app.FetchAppText(conn,'$nfs_export').Getshort);
      AddOneToOnescheme('pool','pool',app.FetchAppText(conn,'$nfs_pool').Getshort);
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$nfs_desc').Getshort);
      AddOneToOnescheme('refer_mb','refer',app.FetchAppText(conn,'$nfs_refer').Getshort);
      AddOneToOnescheme('used_mb','used',app.FetchAppText(conn,'$nfs_used').Getshort);
      AddOneToOnescheme('quota_mb','avail',app.FetchAppText(conn,'$nfs_avail').Getshort);
    end;
    nfs_share_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
    with nfs_share_dc do begin
      SetDeriveParent(conn.Collection('fileshare'));
      fileserverId:= _GetFileserverID(conn);
      AddUIDFieldFilter('Fileserver','fileserver',TFRE_DB_GUIDArray.Create(fileserverId),dbnf_EXACT,false);
      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_NFS_FILESHARE.ClassName));
      SetDeriveTransformation(nfs_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CSF(@IMI_NFSMenu),nil,CSF(@IMI_NFSContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,nfs_access_tr_Grid);
    with nfs_access_tr_Grid do begin
      AddOneToOnescheme('accesstype','accesstype',app.FetchAppText(conn,'$nfs_accesstype').Getshort);
      AddOneToOnescheme('subnet','subnet',app.FetchAppText(conn,'$nfs_accesssubnet').Getshort);
    end;
    nfs_access_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_ACCESS_GRID');
    with nfs_access_dc do begin
      SetReferentialLinkMode('TFRE_DB_NFS_ACCESS|FILESHARE',false);
//      SetDeriveParent(conn.Collection('fileshare_access'));
      SetDeriveTransformation(nfs_access_tr_Grid);
//      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_NFS_ACCESS.ClassName));
      SetDisplayType(cdt_Listview,[],app.FetchAppText(conn,'$nfs_access').Getshort,nil,'',CSF(@IMI_NFSAccessMenu),nil,nil,nil,nil);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,lun_tr_Grid);
    with lun_tr_Grid do begin
      AddOneToOnescheme('objname','LUN',app.FetchAppText(conn,'$lun_guid').Getshort);
      AddOneToOnescheme('pool','pool',app.FetchAppText(conn,'$lun_pool').Getshort);
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$lun_desc').Getshort);
      AddOneToOnescheme('size_mb','size',app.FetchAppText(conn,'$lun_size').Getshort);
    end;
    lun_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
    with lun_dc do begin
      SetDeriveParent(conn.Collection('fileshare'));
      fileserverId:= _GetFileserverID(conn);
      AddUIDFieldFilter('Fileserver','fileserver',TFRE_DB_GUIDArray.Create(fileserverId),dbnf_EXACT,false);
      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_LUN.ClassName));
      SetDeriveTransformation(lun_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CSF(@IMI_LUNMenu),nil,CSF(@IMI_LUNContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,lun_view_tr_Grid);
    with lun_view_tr_Grid do begin
      AddOneToOnescheme('initiatorgroup','initiatorgroup',app.FetchAppText(conn,'$lun_view_initiatorgroup').Getshort);
      AddOneToOnescheme('targetgroup','targetgroup',app.FetchAppText(conn,'$lun_view_targetgroup').Getshort);
    end;
    lun_view_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_VIEW_GRID');
    with lun_view_dc do begin
      SetReferentialLinkMode('TFRE_DB_LUN_VIEW|FILESHARE',false);
//      SetDeriveParent(conn.Collection('fileshare_access'));
      SetDeriveTransformation(lun_view_tr_Grid);
//      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_LUN_VIEW.ClassName));
      SetDisplayType(cdt_Listview,[],app.FetchAppText(conn,'$lun_view').Getshort,nil,'',CSF(@IMI_LUNViewMenu),nil,nil,nil,nil);
    end;

  end;
end;


function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  sub_sec_s     : TFRE_DB_SUBSECTIONS_DESC;

begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_fileserver_global') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sub_sec_s        := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  sub_sec_s.AddSection.Describe(CSF(@IMI_ContentFilerNFS),app.FetchAppText(conn,'$storage_global_filer_nfs').Getshort,1,'nfs');
  sub_sec_s.AddSection.Describe(CSF(@IMI_ContentFilerLUN),app.FetchAppText(conn,'$storage_global_filer_lun').Getshort,1,'lun');

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,sub_sec_s,nil,TFRE_DB_HTML_DESC.create.Describe('<b>Overview of global SAN/NAS shares and LUNs.</b>'));

end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_ContentFilerNFS(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn                : IFRE_DB_CONNECTION;
  app                 : TFRE_DB_APPLICATION;
  dc_share_nfs_access : IFRE_DB_DERIVED_COLLECTION;
  grid_nfs_access     : TFRE_DB_VIEW_LIST_DESC;
  txt                 : IFRE_DB_TEXT;
  nfs_rightside       : TFRE_DB_LAYOUT_DESC;
  nfs                 : TFRE_DB_LAYOUT_DESC;
  dc_share_nfs        : IFRE_DB_DERIVED_COLLECTION;
  grid_nfs            : TFRE_DB_VIEW_LIST_DESC;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_fileserver_global') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  dc_share_nfs := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
  grid_nfs     := dc_share_nfs.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then begin
    txt:=app.FetchAppText(conn,'$create_nfs_export');
    grid_nfs.AddButton.Describe(CSF(@IMI_CreateNFSExport),'images_apps/corebox_storage/create_nfs_export.png',txt.Getshort,txt.GetHint);
  end;

  dc_share_nfs_access := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_ACCESS_GRID');
  grid_nfs_access     := dc_share_nfs_access.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then begin
    txt:=app.FetchAppText(conn,'$create_nfs_access');
    grid_nfs_access.AddButton.Describe(CSF(@IMI_CreateNFSAccess),'images_apps/corebox_storage/create_nfs_access.png',txt.Getshort,txt.GetHint);
  end;

  dc_share_nfs := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
  grid_nfs.AddFilterEvent(dc_share_nfs_access.getDescriptionStoreId(),'uids');

  nfs_rightside := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,IMI_NFSContent(input).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,grid_nfs_access,true,-1,2,-1,-1,1);
  nfs           := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_nfs,nfs_rightside,nil,nil,nil,true,2);
  Result        := nfs;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_ContentFilerLUN(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn          : IFRE_DB_CONNECTION;
  app           : TFRE_DB_APPLICATION;
  dc_lun        : IFRE_DB_DERIVED_COLLECTION;
  grid_lun      : TFRE_DB_VIEW_LIST_DESC;
  txt           : IFRE_DB_TEXT;
  dc_lun_view   : IFRE_DB_DERIVED_COLLECTION;
  grid_lun_view : TFRE_DB_VIEW_LIST_DESC;
  lun_rightside : TFRE_DB_LAYOUT_DESC;
  lun           : TFRE_DB_LAYOUT_DESC;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_fileserver_global') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  dc_lun     := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
  grid_lun   := dc_lun.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then begin
    txt:=app.FetchAppText(conn,'$create_lun');
    grid_lun.AddButton.Describe(CSF(@IMI_CreateLUN),'images_apps/corebox_storage/create_lun.png',txt.Getshort,txt.GetHint);
  end;

  dc_lun_view   := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_VIEW_GRID');
  grid_lun_view := dc_lun_view.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then begin
    txt:=app.FetchAppText(conn,'$create_lun_view');
    grid_lun_view.AddButton.Describe(CSF(@IMI_CreateLUNView),'images_apps/corebox_storage/create_lun_view.png',txt.Getshort,txt.GetHint);
  end;

  grid_lun.AddFilterEvent(dc_lun_view.getDescriptionStoreId(),'uids');

  lun_rightside := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,IMI_LUNContent(input).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,grid_lun_view,true,-1,2,-1,-1,1);

  lun        := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_lun,lun_rightside,nil,nil,nil,true,2);
  Result     := lun;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_CreateNFSExport(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  conn.GetScheme(TFRE_DB_NFS_FILESHARE.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$nfs_add_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('nfs'),GetSession(input),true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('file'),GetSession(input),true,true);
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),GetSession(input),true,true);

  res.SetElementValue('pool','zones');
  res.SetElementValue('logbias','latency');
  res.SetElementValue('compression','on');
  res.SetElementValue('aclinheritance','restricted');
  res.SetElementValue('aclmode','discard');
  res.SetElementValue('canmount','on');
  res.SetElementValue('copies','1');
  res.SetElementValue('sync','standard');
  res.SetElementValue('recordsize_kb','128');

  serverfunc := TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'NewOperation'); //TODO -> Shortcut
  serverFunc.AddParam.Describe('collection','fileshare');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_CreateNFSAccess(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  conn.GetScheme(TFRE_DB_NFS_ACCESS.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$nfsaccess_add_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
//  res.SetElementValue('fileshare','');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare_access');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSContent(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  nfs           : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  conn     := GetDBConnection(input);
  app      := GetEmbeddingApp;

  if input.Field('SELECTED').ValueCount>0  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
    if dc.FetchFromParent(sel_guid,nfs) then begin
      conn.GetScheme(nfs.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$nfs_content_header').ShortText);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('nfs'),GetSession(input),true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('file'),GetSession(input),true,true);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),GetSession(input),true,true);
      panel.FillWithObjectValues(nfs,GetSession(input));
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(nfs,'saveOperation'),fdbbt_submit);
      panel.contentId := 'GLOBAL_NFS_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$nfs_content_header').ShortText);
    panel.contentId := 'GLOBAL_NFS_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSMenu(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
  dtxt      : IFRE_DB_TEXT;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_NFSDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$nfs_delete').Getshort,'images_apps/corebox_storage/delete_nfs.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSDelete(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sf:=CSF(@IMI_NFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppText(conn,'$nfs_delete_diag_cap').Getshort;
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppText(conn,'$nfs_delete_diag_msg').Getshort,'%share_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSDeleteConfirmed(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  i      : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i:= 0 to input.Field('selected').ValueCount-1 do begin
    //FIXXME: Errorhandling
    conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSAccessMenu(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
  dtxt      : IFRE_DB_TEXT;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_NFSAccessDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$nfsaccess_delete').Getshort,'images_apps/corebox_storage/delete_nfsaccess.png',func);
    func:=CSF(@IMI_NFSAccessModify);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$nfsaccess_modify').Getshort,'images_apps/corebox_storage/modify_nfsaccess.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSAccessDelete(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  i      : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i:= 0 to input.Field('selected').ValueCount-1 do begin
    //FIXXME: Errorhandling
    conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_NFSAccessModify(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_nfs_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  conn.GetScheme(TFRE_DB_NFS_ACCESS.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$nfsaccess_modify_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
//  res.SetElementValue('fileshare','');

serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'SaveOperation');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_CreateLUN(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  conn.GetScheme(TFRE_DB_LUN.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$lun_add_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('lun'),GetSession(input),true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('volume'),GetSession(input),true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),GetSession(input),true,true);

  res.SetElementValue('pool','zones');
  res.SetElementValue('logbias','latency');
  res.SetElementValue('compression','on');
  res.SetElementValue('copies','1');
  res.SetElementValue('sync','standard');
  res.SetElementValue('recordsize_kb','128');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_CreateLUNView(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  conn.GetScheme(TFRE_DB_LUN_VIEW.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$lunview_add_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
//  res.SetElementValue('fileshare','');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN_VIEW.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare_access');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNMenu(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_LUNDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$lun_delete').Getshort,'images_apps/corebox_storage/delete_lun.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNContent(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  nfs           : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  conn     := GetDBConnection(input);
  app      := GetEmbeddingApp;

  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
    if dc.FetchFromParent(sel_guid,nfs) then begin
      conn.GetScheme(nfs.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$lun_content_header').ShortText);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('lun'),GetSession(input),true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('volume'),GetSession(input),true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),GetSession(input),true,true);
      panel.FillWithObjectValues(nfs,GetSession(input));
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(nfs,'saveOperation'),fdbbt_submit);
      panel.contentId:='GLOBAL_LUN_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$lun_content_header').ShortText);
    panel.contentId:='GLOBAL_LUN_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNDelete(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sf:=CSF(@IMI_NFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppText(conn,'$lun_delete_diag_cap').Getshort;
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppText(conn,'$lun_delete_diag_msg').Getshort,'%guid_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNDeleteConfirmed(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  i      : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i:= 0 to input.Field('selected').ValueCount-1 do begin
    //FIXXME: Errorhandling
    conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNViewMenu(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_LUNViewDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$lunview_delete').Getshort,'images_apps/corebox_storage/delete_lunview.png',func);
    func:=CSF(@IMI_LUNViewModify);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$lunview_modify').Getshort,'images_apps/corebox_storage/modify_lunview.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNViewDelete(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  i      : NativeInt;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i:= 0 to input.Field('selected').ValueCount-1 do begin
    //FIXXME: Errorhandling
    conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.IMI_LUNViewModify(const input: IFRE_DB_OBject): IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  conn       : IFRE_DB_CONNECTION;
  app        : TFRE_DB_APPLICATION;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  app:=GetEmbeddingApp;
  conn:=GetDBConnection(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'edit_lun_global')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  conn.GetScheme(TFRE_DB_LUN_VIEW.ClassName,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$lunview_modify_diag_cap').Getshort,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input),false,false);
//  res.SetElementValue('fileshare','');

  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN_VIEW.ClassName,'SaveOperation');
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,serverfunc,fdbbt_submit);
  Result:=res;
end;

{ TFRE_DBCOREBOX_BACKUP_MOD }

class procedure TFRE_DBCOREBOX_BACKUP_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_BACKUP_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('STORAGE_BACKUP','$backup_description')
end;

procedure TFRE_DBCOREBOX_BACKUP_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);

var snap_dc            : IFRE_DB_DERIVED_COLLECTION;
    snap_tr_Grid       : IFRE_DB_SIMPLE_TRANSFORM;
    app           : TFRE_DB_APPLICATION;
    conn          : IFRE_DB_CONNECTION;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,snap_tr_Grid);
    with snap_tr_Grid do begin
//      AddOneToOnescheme('parentid','parentid',app.FetchAppText(conn,'$backup_parent').Getshort);
      AddMatchingReferencedField('parentid','displayname','parent',app.FetchAppText(conn,'$backup_share').Getshort);
      AddOneToOnescheme('creation','creation',app.FetchAppText(conn,'$backup_creation').Getshort,dt_date);
      AddOneToOnescheme('used_mb','used',app.FetchAppText(conn,'$backup_used').Getshort);
      AddOneToOnescheme('refer_mb','refer',app.FetchAppText(conn,'$backup_refer').Getshort);
//      AddOneToOnescheme('objname','snapshot',app.FetchAppText(conn,'$backup_snapshot').Getshort);
      AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppText(conn,'$backup_desc').Getshort);
    end;
    snap_dc := session.NewDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
    with snap_dc do begin
      SetDeriveParent(conn.Collection('snapshot'));
      SetDeriveTransformation(snap_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable,cdgf_enableMultiselect],'',nil,'',CSF(@IMI_SnapshotMenu),nil,CSF(@IMI_ContentSnapshot));
    end;
  end;
end;

function TFRE_DBCOREBOX_BACKUP_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  snap          : TFRE_DB_LAYOUT_DESC;
  grid_snap     : TFRE_DB_VIEW_LIST_DESC;
  dc_snap       : IFRE_DB_DERIVED_COLLECTION;
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  backup        : TFRE_DB_LAYOUT_DESC;
  sub_sec       : TFRE_DB_SUBSECTIONS_DESC;
  txt           : IFRE_DB_TEXT;

begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_backup') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  sub_sec   := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);

  dc_snap       := GetSession(input).FetchDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
  grid_snap     := dc_snap.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'delete_backup')) then begin
    txt:=app.FetchAppText(conn,'$backup_snapshot_delete');
    grid_snap.AddButton.Describe(CSF(@IMI_DeleteSnapshot),'images_apps/corebox_storage/delete_snapshot.png',txt.Getshort,txt.GetHint,fdgbd_multi);
  end;

  sub_sec.AddSection.Describe(CSF(@IMI_ContentSnapshot),app.FetchAppText(conn,'$backup_snapshot_properties').Getshort,1,'backup_properties');
  sub_sec.AddSection.Describe(CSF(@IMI_ContentSchedule),app.FetchAppText(conn,'$backup_schedule_properties').Getshort,2,'backup_schedule');

  //    CSF(@IMI_ContentSnapshot)
  backup  := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_snap,sub_sec,nil,nil,nil,true,1,1);
  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,backup,nil,TFRE_DB_HTML_DESC.create.Describe('<b>Overview of backup snapshots of shares, block devices and virtual machines.</b>'));
end;

function TFRE_DBCOREBOX_BACKUP_MOD.IMI_ContentSnapShot(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  app           : TFRE_DB_APPLICATION;
  conn          : IFRE_DB_CONNECTION;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  snap          : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  conn     := GetDBConnection(input);
  app      := GetEmbeddingApp;

  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := GetSession(input).FetchDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
    if dc.FetchFromParent(sel_guid,snap) then begin
      conn.GetScheme(snap.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$backup_content_header').ShortText);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),GetSession(input));
      panel.FillWithObjectValues(snap,GetSession(input));
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(snap,'saveOperation'),fdbbt_submit);
      panel.contentId:='BACKUP_SNAP_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppText(conn,'$backup_content_header').ShortText);
    panel.contentId:='BACKUP_SNAP_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_DBCOREBOX_BACKUP_MOD.IMI_ContentSchedule(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := TFRE_DB_HTML_DESC.Create.Describe('Definition of backup schedules')
end;

function TFRE_DBCOREBOX_BACKUP_MOD.IMI_SnapshotMenu(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  conn      : IFRE_DB_CONNECTION;
  app       : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'delete_backup')) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CSF(@IMI_DeleteSnapshot);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppText(conn,'$backup_snapshot_delete').Getshort,'images_apps/corebox_storage/delete_snapshot.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_DBCOREBOX_BACKUP_MOD.IMI_DeleteSnapshot(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  app       : TFRE_DB_APPLICATION;
  conn      : IFRE_DB_CONNECTION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$backup_snapshot_delete_diag_cap').Getshort,app.FetchAppText(conn,'$backup_snapshot_delete_diag_msg').Getshort,fdbmt_info,nil);
end;


{ TFRE_DBCOREBOX_STORAGE_POOLS_MOD }

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD._addDisksToPool(const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_OBJ; const disks: TFRE_DB_StringArray; const app: TFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: TFRE_DB_UserSession): TFRE_DB_MENU_DESC;
var
  res      : TFRE_DB_MENU_DESC;
  pools    : IFRE_DB_COLLECTION;
  count    : Integer;
  firstPool: IFRE_DB_Object;
  disk     : TFRE_DB_ZFS_OBJ;
  idPath   : TFRE_DB_StringArray;

  procedure _addDatastorageMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const expandStorage: Boolean; const storageRL: TFRE_DB_ZFS_RAID_LEVEL; const addStorage: IFRE_DB_ObjectArray);
  var
    i          : Integer;
    vdev       : TFRE_DB_ZFS_VDEV;
    sub,subsub : TFRE_DB_MENU_DESC;
    sf         : TFRE_DB_SERVER_FUNC_DESC;
    raid_str   : String;
  begin
    if expandStorage then begin
      if storageRL<>zfs_rl_undefined then begin
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('expand','true');
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[storageRL]);
        case storageRL of
          zfs_rl_stripe: raid_str:=app.FetchAppText(conn,'$add_disks_rl_stripe').Getshort;
          zfs_rl_mirror: raid_str:=app.FetchAppText(conn,'$add_disks_rl_mirror').Getshort;
          zfs_rl_z1: raid_str:=app.FetchAppText(conn,'$add_disks_rl_z1').Getshort;
          zfs_rl_z2: raid_str:=app.FetchAppText(conn,'$add_disks_rl_z2').Getshort;
          zfs_rl_z3: raid_str:=app.FetchAppText(conn,'$add_disks_rl_z3').Getshort;
        end;
        menu.AddEntry.Describe(StringReplace(app.FetchAppText(conn,'$add_disks_storage_ex_same').Getshort,'%raid_level%',raid_str,[rfReplaceAll]),'images_apps/corebox_storage/expand_storage_disks_same.png',sf);
      end;
      sub:=menu.AddMenu.Describe(app.FetchAppText(conn,'$add_disks_storage_ex_other').Getshort,'images_apps/corebox_storage/expand_storage_disks_other.png');
    end else begin
      sub:=menu.AddMenu.Describe(app.FetchAppText(conn,'$add_disks_storage').Getshort,'images_apps/corebox_storage/add_storage_disks.png');
    end;
    if storageRL<>zfs_rl_stripe then begin
      sf:=CSF(@IMI_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
      sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_stripe').Getshort,'images_apps/corebox_storage/expand_storage_disks_s.png',sf);
    end;
    if storageRL<>zfs_rl_mirror then begin
      sf:=CSF(@IMI_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
      sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_mirror').Getshort,'images_apps/corebox_storage/expand_storage_disks_m.png',sf);
    end;
    if storageRL<>zfs_rl_z1 then begin
      sf:=CSF(@IMI_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
      sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_z1').Getshort,'images_apps/corebox_storage/expand_storage_disks_z1.png',sf);
    end;
    if storageRL<>zfs_rl_z2 then begin
      sf:=CSF(@IMI_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
      sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_z2').Getshort,'images_apps/corebox_storage/expand_storage_disks_z2.png',sf);
    end;
    if storageRL<>zfs_rl_z3 then begin
      sf:=CSF(@IMI_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
      sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_z3').Getshort,'images_apps/corebox_storage/expand_storage_disks_z3.png',sf);
    end;
    if Length(addStorage)>1 then begin
      sub:=menu.AddMenu.Describe(app.FetchAppText(conn,'$add_disks_storage').Getshort,'images_apps/corebox_storage/add_storage_disks.png');
    end else begin
      sub:=menu;
    end;
    for i := 0 to Length(addStorage) - 1 do begin
      vdev:=addStorage[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
      if vdev.raidLevel=zfs_rl_undefined then begin
        subsub:=sub.AddMenu.Describe(StringReplace(app.FetchAppText(conn,'$add_disks_storage_to').Getshort,'%vdev%',vdev.caption,[rfReplaceAll]),'images_apps/corebox_storage/add_storage_disks.png');
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
        subsub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_stripe').Getshort,'images_apps/corebox_storage/add_storage_disks_s.png',sf);
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
        subsub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_mirror').Getshort,'images_apps/corebox_storage/add_storage_disks_m.png',sf);
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
        subsub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_z1').Getshort,'images_apps/corebox_storage/add_storage_disks_z1.png',sf);
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
        subsub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_z2').Getshort,'images_apps/corebox_storage/add_storage_disks_z2.png',sf);
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
        subsub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_z3').Getshort,'images_apps/corebox_storage/add_storage_disks_z3.png',sf);
      end else begin
        sf:=CSF(@IMI_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sub.AddEntry.Describe(StringReplace(app.FetchAppText(conn,'$add_disks_storage_to').Getshort,'%vdev%',vdev.caption,[rfReplaceAll]),'images_apps/corebox_storage/add_storage_disks.png',sf);
      end;
    end;
  end;

  procedure _addCacheMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ);
  var
    sf : TFRE_DB_SERVER_FUNC_DESC;
  begin
    sf:=CSF(@IMI_AssignCacheDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    menu.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_cache').Getshort,'images_apps/corebox_storage/add_cache_disks.png',sf);
  end;

  procedure _addLogMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const expandLog: Boolean; const addLog: IFRE_DB_ObjectArray);
  var
    i    : Integer;
    vdev : TFRE_DB_ZFS_VDEV;
    sub  : TFRE_DB_MENU_DESC;
    sf   : TFRE_DB_SERVER_FUNC_DESC;
  begin
    if expandLog then begin
      sub:=menu.AddMenu.Describe(app.FetchAppText(conn,'$add_disks_log_ex').Getshort,'images_apps/corebox_storage/expand_log_disks.png');
    end else begin
      sub:=menu.AddMenu.Describe(app.FetchAppText(conn,'$add_disks_log').Getshort,'images_apps/corebox_storage/add_log_disks.png');
    end;
    sf:=CSF(@IMI_AssignLogDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('expand','true');
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
    sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_stripe').Getshort,'images_apps/corebox_storage/expand_storage_disks_s.png',sf);
    sf:=CSF(@IMI_AssignLogDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('expand','true');
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
    sub.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_rl_mirror').Getshort,'images_apps/corebox_storage/expand_storage_disks_m.png',sf);
    if Length(addLog)>1 then begin
      sub:=menu.AddMenu.Describe(app.FetchAppText(conn,'$add_disks_log').Getshort,'images_apps/corebox_storage/add_log_disks.png');
    end else begin
      sub:=menu;
    end;
    for i := 0 to Length(addLog) - 1 do begin
      vdev:=addLog[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
      sf:=CSF(@IMI_AssignLogDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('add',vdev.getId);
      sub.AddEntry.Describe(StringReplace(app.FetchAppText(conn,'$add_disks_log_to').Getshort,'%vdev%',vdev.caption,[rfReplaceAll]),'images_apps/corebox_storage/add_log_disks.png',sf);
    end;
  end;

  procedure _addSpareMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ);
  var
    sf : TFRE_DB_SERVER_FUNC_DESC;
  begin
    sf:=CSF(@IMI_AssignSpareDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    menu.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_spare').Getshort,'images_apps/corebox_storage/add_spare_disks.png',sf);
  end;

  procedure _addVdevMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_VDEV);
  var
    parent : IFRE_DB_Object;
    sf     : TFRE_DB_SERVER_FUNC_DESC;
  begin
    parent:=target.Parent;
    if parent.Implementor_HC is TFRE_DB_ZFS_LOG then begin
      sf:=CSF(@IMI_AssignLogDisk);
    end else
    if parent.Implementor_HC is TFRE_DB_ZFS_DATASTORAGE then begin
      sf:=CSF(@IMI_AssignStorageDisk);
    end else begin
      raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_vdev_unknown_parent_type').Getshort);
    end;
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('add',target.getId);
    menu.AddEntry.Describe(app.FetchAppText(conn,'$add_disks_vdev').Getshort,'images_apps/corebox_storage/add_disks_vdev.png',sf);
  end;

  procedure _addPoolMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_DISKCONTAINER);
  var
    children        : IFRE_DB_ObjectArray;
    storageChildren : IFRE_DB_ObjectArray;
    logChildren     : IFRE_DB_ObjectArray;
    storage         : TFRE_DB_ZFS_DATASTORAGE;
    i,j             : Integer;
    expandLog       : Boolean;
    addLog          : IFRE_DB_ObjectArray;
    expandStorage   : Boolean;
    storageRL       : TFRE_DB_ZFS_RAID_LEVEL;
    vdev            : TFRE_DB_ZFS_VDEV;
    addStorage      : IFRE_DB_ObjectArray;
    raid_str        : String;
    sf              : TFRE_DB_SERVER_FUNC_DESC;
  begin
    children:=pool.getChildren;
    expandStorage:=false;
    expandLog:=false;
    storageRL:=zfs_rl_undefined;
    for i := 0 to length(children) - 1 do begin
      if children[i].Implementor_HC is TFRE_DB_ZFS_DATASTORAGE then begin
        storage:=children[i].Implementor_HC as TFRE_DB_ZFS_DATASTORAGE;
        storageChildren:=storage.getChildren;
        if Length(storageChildren)>0 then begin
          expandStorage:=True;
          if (storageChildren[0].Implementor_HC is TFRE_DB_ZFS_VDEV) then begin
            storageRL:=(storageChildren[0].Implementor_HC as TFRE_DB_ZFS_VDEV).raidLevel;
          end else begin  //BLOCKDEVICE
            storageRL:=zfs_rl_stripe;
          end;
          for j := 0 to Length(storageChildren) - 1 do begin
            if (storageChildren[j].Implementor_HC is TFRE_DB_ZFS_VDEV) then begin
              vdev:=storageChildren[j].Implementor_HC as TFRE_DB_ZFS_VDEV;
              if storageRL<>vdev.raidLevel then begin
                storageRL:=zfs_rl_undefined;
              end;
              if vdev.acceptsNewChildren then begin
                SetLength(addStorage,Length(addStorage)+1);
                addStorage[Length(addStorage)-1]:=storageChildren[j];
              end;
            end else begin  //BLOCKDEVICE
              if storageRL<>zfs_rl_stripe then begin
                storageRL:=zfs_rl_undefined;
              end;
            end;
          end;
        end;
      end else
      if children[i].Implementor_HC is TFRE_DB_ZFS_LOG then begin
        logChildren:=(children[i].Implementor_HC as TFRE_DB_ZFS_LOG).getChildren;
        for j := 0 to Length(logChildren) - 1 do begin
          expandLog:=true;
          if (logChildren[j].Implementor_HC is TFRE_DB_ZFS_VDEV) then begin
            if (logChildren[j].Implementor_HC as TFRE_DB_ZFS_VDEV).acceptsNewChildren then begin
              SetLength(addLog,Length(addLog)+1);
              addLog[Length(addLog)-1]:=logChildren[j];
            end;
          end;
        end;
      end;
    end;

    if target.Implementor_HC is TFRE_DB_ZFS_POOL then begin
      _addDatastorageMenu(menu,pool,expandStorage,storageRL,addStorage);
      _addCacheMenu(menu,pool);
      _addLogMenu(menu,pool,expandLog,addLog);
      _addSpareMenu(menu,pool);
    end else
    if target is TFRE_DB_ZFS_DATASTORAGE then begin
      _addDatastorageMenu(menu,pool,expandStorage,storageRL,addStorage);
    end else
    if target is TFRE_DB_ZFS_VDEV then begin
      if target.acceptsNewChildren then begin
        _addVdevMenu(menu,pool,target as TFRE_DB_ZFS_VDEV);
      end;
    end else
    if target is TFRE_DB_ZFS_CACHE then begin
      _addCacheMenu(menu,pool);
    end else
    if target is TFRE_DB_ZFS_LOG then begin
      _addLogMenu(menu,pool,expandLog,addLog);
    end else
    if target is TFRE_DB_ZFS_SPARE then begin
      _addSpareMenu(menu,pool);
    end;
  end;

  function _countPools(const obj: IFRE_DB_Object):Boolean;
  begin
    Result:=false;
    if obj.Implementor_HC is TFRE_DB_ZFS_POOL then begin
      count:=count+1;
      if count=1 then begin
        firstPool:=obj;
      end else begin
        Result:=true;
      end;
    end;
  end;

  procedure _addPools(const obj: IFRE_DB_Object);
  var
    sub : TFRE_DB_MENU_DESC;
    pool: TFRE_DB_ZFS_POOL;
  begin
    if obj.Implementor_HC is TFRE_DB_ZFS_POOL then begin
      pool:=obj.Implementor_HC as TFRE_DB_ZFS_POOL;
      sub:=res.AddMenu.Describe(StringReplace(app.FetchAppText(conn,'$add_disks_pool').Getshort,'%pool%',pool.caption,[rfReplaceAll]),'images_apps/corebox_storage/add_pool_disks.png');
      _addPoolMenu(sub,pool,pool);
    end;
  end;

begin
  if Assigned(target) then begin
    if target.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED then begin
      _unassignDisk(target.Implementor_HC as TFRE_DB_ZFS_UNASSIGNED,disks,app,conn,session);
      Result:=TFRE_DB_MENU_DESC.create.Describe;
    end else begin
      if target.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
        res:=TFRE_DB_MENU_DESC.create.Describe;
        FREDB_SeperateString(disks[0],',',idPath);
        disk:=_getPool(conn,idPath[0]).getPoolItem(TFRE_DB_StringArray(idPath));
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_replace').Getshort,'images_apps/corebox_storage/cm_replace.png',CSF(@IMI_Replace),(target.Parent.Implementor_HC as TFRE_DB_ZFS_OBJ).getId=(disk.Parent.Implementor_HC as TFRE_DB_ZFS_OBJ).getId);
        Result:=res;
      end else begin
        res:=TFRE_DB_MENU_DESC.create.Describe;
        _addPoolMenu(res,pool,target as TFRE_DB_ZFS_DISKCONTAINER);
        Result:=res;
      end;
    end;
  end else begin
    pools := conn.Collection('ZFS_POOLS');
    count:=0;
    pools.ForAllBreak(@_countPools);
    res:=TFRE_DB_MENU_DESC.create.Describe;
    case count of
      0: ; //return empty menu
      1: begin
          _addPoolMenu(res,firstPool.Implementor_HC as TFRE_DB_ZFS_POOL,firstPool.Implementor_HC as TFRE_DB_ZFS_POOL);
         end;
      else begin
        pools.ForAll(@_addPools);
      end;
    end;
    Result:=res;
  end;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD._getPool(const conn: IFRE_DB_CONNECTION; const id: String): TFRE_DB_ZFS_ROOTOBJ;
var
  pools : IFRE_DB_COLLECTION;
  dbObj : IFRE_DB_Object;
begin
  pools := conn.Collection('ZFS_POOLS');
  if pools.Fetch(GFRE_BT.HexString_2_GUID(id),dbObj) then begin
    Result:=dbobj.Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  end else begin
    Result:=Nil;
  end;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD._getPoolByName(const conn: IFRE_DB_CONNECTION; const name: String): TFRE_DB_ZFS_ROOTOBJ;
var
  pools : IFRE_DB_COLLECTION;
  pool  : TFRE_DB_ZFS_ROOTOBJ;

  function _checkPool(const obj: IFRE_DB_Object):Boolean;
  begin
    if (obj.Implementor_HC as TFRE_DB_ZFS_ROOTOBJ).getPoolName=LowerCase(name) then begin
      Result:=true;
      pool:=obj.Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
    end else begin
      Result:=false;
    end;
  end;

begin
  pool := nil;
  pools := conn.Collection('ZFS_POOLS');
  pools.ForAllBreak(@_checkPool);
  Result:=pool;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD._getUnassignedPool(const conn: IFRE_DB_CONNECTION): TFRE_DB_ZFS_UNASSIGNED;
var
  pools : IFRE_DB_COLLECTION;
  ua    : TFRE_DB_ZFS_UNASSIGNED;

  function _checkPool(const obj: IFRE_DB_Object):Boolean;
  begin
    if obj.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED then begin
      Result:=true;
      ua:=obj.Implementor_HC as TFRE_DB_ZFS_UNASSIGNED;
    end else begin
      Result:=false;
    end;
  end;

begin
  pools := conn.Collection('ZFS_POOLS');
  pools.ForAllBreak(@_checkPool);
  Result:=ua;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD._getTreeObj(const zfsObj: TFRE_DB_ZFS_OBJ): IFRE_DB_Object;
var
  entry : IFRE_DB_Object;
begin
  entry:=GFRE_DBI.NewObject;
  if zfsObj.mayHaveChildren then begin
    entry.Field('children').AsString:='UNCHECKED';
    entry.Field('_disabledrop_').AsBoolean:=not (zfsObj.Implementor_HC as TFRE_DB_ZFS_DISKCONTAINER).acceptsNewChildren;
  end else begin
    if not ((zfsObj.Implementor_HC is TFRE_DB_ZFS_POOL) or (zfsObj.Parent.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) or zfsObj.isNew) then begin
      entry.Field('_disabledrag_').AsBoolean:=true;
    end;
  end;
  entry.Field('uidpath').AsStringArr:=Self.GetUIDPath;
  entry.Field('_funcclassname_').AsString:='TFRE_DBCOREBOX_STORAGE_POOLS_MOD';
  entry.Field('_childrenfunc_').AsString:='TreeGridData';
  entry.Field('objectclass').AsString:=zfsObj.ClassName;
  entry.Field('id').AsString:=zfsObj.getId;
  entry.Field('caption').AsString:=zfsObj.caption;
  entry.Field('iops_r').AsString:=zfsObj.iopsR;
  entry.Field('iops_w').AsString:=zfsObj.iopsW;
  entry.Field('transfer_r').AsString:=zfsObj.transferR;
  entry.Field('transfer_w').AsString:=zfsObj.transferW;
  if zfsObj.isNew then begin
    entry.Field('icon').AsString:=getThemedResource('images_apps/corebox_storage/'+zfsObj.ClassName+'_new.png');
  end else begin
    if zfsObj.isModified then begin
      entry.Field('icon').AsString:=getThemedResource('images_apps/corebox_storage/'+zfsObj.ClassName+'_mod.png');
    end else begin
      if (zfsObj is TFRE_DB_ZFS_BLOCKDEVICE) and (zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline then begin
        entry.Field('icon').AsString:=getThemedResource('images_apps/corebox_storage/'+zfsObj.ClassName+'_offline.png');
      end else begin
        entry.Field('icon').AsString:=getThemedResource('images_apps/corebox_storage/'+zfsObj.ClassName+'.png');
      end;
    end;
  end;
  Result:=entry;
end;

class procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('STORAGE_POOLS','$pools_description')
end;

procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  ast,rbw,wbw,busy,
  sp,struct            : IFRE_DB_DERIVED_COLLECTION;
  disks,cap            : IFRE_DB_COLLECTION;
  trans                : IFRE_DB_SIMPLE_TRANSFORM;
  idx                  : Integer;
  labels               : TFRE_DB_StringArray;

  procedure _AddDisk(const obj:IFRE_DB_Object);
  begin
    labels[idx]:=obj.Field('caption').AsString;
    idx:=idx+1;
  end;

begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    //_buildPoolsCollection(session);

    disks := session.GetDBConnection.Collection('POOL_DISKS',false);

    idx:=0;
    //SetLength(labels,disks.Count);
    //disks.ForAll(@_AddDisk);

    //GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,trans);
    //with trans do begin
    //  AddOneToOnescheme('caption','','Caption');
    //  AddOneToOnescheme('iops_r','','IOPS R [1/s]');
    //  AddOneToOnescheme('iops_w','','IOPS W [1/s]');
    //  AddOneToOnescheme('transfer_r','','Read [MB/s]');
    //  AddOneToOnescheme('transfer_w','','Write [MB/s]');
    //  AddConstString('children','UNCHECKED'); //FIXXME
    //end;
    //
    //struct:= session.NewDerivedCollection('POOL_STRUCTURE');
    //struct.SetDeriveParent(disks);
    //struct.SetDisplayType(cdt_Listview,[cdgf_Children],'');
    //struct.SetDeriveTransformation(trans);

    ast   := session.NewDerivedCollection('POOL_AST');
    ast.SetDeriveParent(disks);
    ast.AddOrderField('1','diskid',true);
    ast.SetDisplayTypeChart('Pool Disk Avg. Service Time (ms)',fdbct_column,TFRE_DB_StringArray.Create('ast'),false,false,labels,false,20);
    SetLength(labels,ast.Count);
    ast.ForAll(@_AddDisk);
    ast.SetDisplayTypeChart('Pool Disk Avg. Service Time (ms)',fdbct_column,TFRE_DB_StringArray.Create('ast'),false,false,labels,false,20); // Hack for labels, must be redone

    rbw   := session.NewDerivedCollection('POOL_RBW');
    rbw.SetDeriveParent(disks);
    rbw.AddOrderField('1','diskid',true);
    rbw.SetDisplayTypeChart('Raw Disk Bandwidth Read (kBytes/s)',fdbct_column,TFRE_DB_StringArray.Create('rbw'),false,false,labels,false,160000);
    wbw   := session.NewDerivedCollection('POOL_WBW');
    wbw.SetDeriveParent(disks);
    wbw.AddOrderField('1','diskid',true);
    wbw.SetDisplayTypeChart('Raw Disk Bandwidth Write (kBytes/s)',fdbct_column,TFRE_DB_StringArray.Create('wbw'),false,false,labels,false,160000);
    busy   := session.NewDerivedCollection('POOL_BUSY');
    busy.SetDeriveParent(disks);
    busy.AddOrderField('1','diskid',true);
    busy.SetDisplayTypeChart('Raw Disk Busy Times [%]',fdbct_column,TFRE_DB_StringArray.Create('b'),false,false,labels,false,100);
  end;
end;

procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
var
  pool_disks    : IFRE_DB_COLLECTION;
  pool_capacity : IFRE_DB_COLLECTION;

  procedure _buildPoolsCollection;
  var
    zfs_pool         : IFRE_DB_COLLECTION;
    zfs              : TFRE_DB_ZFS;
    zfs_res          : Integer;
    zfs_error        : TFRE_DB_String;
    pool             : IFRE_DB_Object;
    disk             : TFRE_DB_ZFS_BLOCKDEVICE;
    disks_unassigned : TFRE_DB_ZFS_UNASSIGNED;
    i                : Integer;
    storeObj         : IFRE_DB_Object;

  begin
    zfs_pool:=admin_dbc.Collection('ZFS_POOLS',true);

    zfs:=TFRE_DB_ZFS.create;
    if cVM_HostUser<>'' then begin
      zfs.SetRemoteSSH(cVM_HostUser, cVMHostMachine, SetDirSeparators(cFRE_SERVER_DEFAULT_DIR + '/ssl/user/id_rsa'));
    end;
    zfs_res:=zfs.GetPoolStatus('zones',zfs_error,pool);
    zfs.Free;
    zfs_pool.ClearCollection;
    CheckDbResult(zfs_pool.Store(pool),'Store current pool configuration');


    disks_unassigned:=TFRE_DB_ZFS_UNASSIGNED.create;
    disks_unassigned.caption:='Unassigned';
    for i := 0 to 9 do begin
      disk:=disks_unassigned.addBlockdevice;
      disk.caption:='disk0'+IntToStr(i);
    end;
    storeObj:=disks_unassigned;
    CheckDbResult(zfs_pool.Store(storeObj),'Store unassigned disks');
  end;


begin
  inherited MyServerInitializeModule(admin_dbc);

  DISKI_HACK := Get_Stats_Control(cVM_HostUser,cVMHostMachine);
  VM_HACK    := Get_VM_Host_Control(cVM_HostUser,cVMHostMachine);

  pool_disks := admin_dbc.Collection('POOL_DISKS',true,true);
  pool_disks.DefineIndexOnField('diskid',fdbft_String,true,true);
  UpdateDiskCollection(pool_disks,DISKI_HACK.Get_Disk_Data_Once);

  _buildPoolsCollection();

end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  main      : TFRE_DB_LAYOUT_DESC;
  grid      : TFRE_DB_VIEW_LIST_DESC;
  store     : TFRE_DB_STORE_DESC;
  glayout   : TFRE_DB_VIEW_LIST_LAYOUT_DESC;
  secs      : TFRE_DB_SUBSECTIONS_DESC;
  coll      : IFRE_DB_DERIVED_COLLECTION;
  app       : TFRE_DB_APPLICATION;
  conn      : IFRE_DB_CONNECTION;
  session   : TFRE_DB_UserSession;

begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  session:=GetSession(input);
  if not app.CheckAppRightModule(conn,'storage_pools') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  secs:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  secs.AddSection.Describe(CSF(@IMI_PoolLayout),app.FetchAppText(conn,'$pool_layout_tab').Getshort,1,'layout');
  secs.AddSection.Describe(CSF(@IMI_PoolSpace),app.FetchAppText(conn,'$pool_status_tab').Getshort,2,'space');
  secs.AddSection.Describe(CSF(@IMI_PoolNotes),app.FetchAppText(conn,'$pool_notes_tab').Getshort,4,'notes');

  session.RegisterTaskMethod(@_SendData,1000);

  store    := TFRE_DB_STORE_DESC.create.Describe('id',CSF(@IMI_TreeGridData),TFRE_DB_StringArray.create('caption'),nil,nil,'pools_store');
  glayout  := TFRE_DB_VIEW_LIST_LAYOUT_DESC.create.Describe();
  glayout.AddDataElement.Describe('caption','Caption',dt_string,2,true,false,'icon');
  glayout.AddDataElement.Describe('iops_r','IOPS R [1/s]',dt_number);
  glayout.AddDataElement.Describe('iops_w','IOPS W [1/s]',dt_number);
  glayout.AddDataElement.Describe('transfer_r','Read [MB/s]',dt_number);
  glayout.AddDataElement.Describe('transfer_w','Write [MB/s]',dt_number);

  grid    := TFRE_DB_VIEW_LIST_DESC.create.Describe(store,glayout,CSF(@IMI_GridMenu),'',[cdgf_Children,cdgf_enableMultiselect],nil,nil,nil,CSF(@IMI_TreeDrop));
  grid.SetDropGrid(grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
  grid.SetDragObjClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));

  grid.AddButton.Describe(CSF(@IMI_CreatePoolDiag),'images_apps/corebox_storage/create_pool.png',app.FetchAppText(conn,'$create_pool').Getshort);
  grid.AddButton.Describe(CSF(@IMI_ImportPoolDiag),'images_apps/corebox_storage/import_pool.png',app.FetchAppText(conn,'$import_pool').Getshort);
  grid.AddButton.DescribeManualType('pool_save',CSF(@IMI_SaveConfig),'images_apps/corebox_storage/save_config.png',app.FetchAppText(conn,'$save_config').Getshort,'',true);
  grid.AddButton.DescribeManualType('pool_reset',CSF(@IMI_ResetConfig),'images_apps/corebox_storage/reset_config.png',app.FetchAppText(conn,'$reset_config').Getshort,'',true);
  //grid.AddButton.Describe(CSF(@IMI_UpdatePoolsTree),'images_apps/corebox_storage/update.png','Update');
  main    := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid,secs,nil,nil,nil,true,2);
  //main    := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(coll.GetDisplayDescription,secs,nil,nil,nil,true,2);
  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,main,nil,TFRE_DB_HTML_DESC.create.Describe('<b>Overview of disks and pools and their status. Update interval: 10s. The average IO size is 128kByte.</b>'));
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_PoolLayout(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn                  : IFRE_DB_CONNECTION;
  app                   : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_pools') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  Result:=TFRE_DB_HTML_DESC.create.Describe('Feature disabled in Demo Mode.');
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_PoolSpace(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res,center,top,bottom : TFRE_DB_LAYOUT_DESC;
  html                  : TFRE_DB_HTML_DESC;
  conn                  : IFRE_DB_CONNECTION;
  app                   : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_pools') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  html:=TFRE_DB_HTML_DESC.create.Describe('<strong>Pool Company Data</strong> ONLINE (optimal health)<br />Full dataintegrity is verified. Currently there are no optimizations necessary.');
  //top:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(Usage(input),ServiceTime(input),nil,nil,nil,false,1,1);
  top:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(BusyTime(input),ServiceTime(input),nil,nil,nil,false,1,1);
  bottom:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(ReadBW(input),WriteBW(input),nil,nil,nil,false,1,1);
  center:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,bottom,nil,top,nil,false,-1,1,-1,1);
  res:=TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,center,nil,html);
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_PoolNotes(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn                  : IFRE_DB_CONNECTION;
  app                   : TFRE_DB_APPLICATION;
  load_func             : TFRE_DB_SERVER_FUNC_DESC;
  save_func             : TFRE_DB_SERVER_FUNC_DESC;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;

  if not app.CheckAppRightModule(conn,'storage_pools') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  load_func   := CSF(@IMI_NoteLoad);
  save_func   := CSF(@IMI_NoteSave);
//  load_func.AddParam.Describe('linkid',input.Field('SELECTED').asstring);
//  save_func.AddParam.Describe('linkid',input.Field('SELECTED').asstring);

  load_func.AddParam.Describe('linkid','zones');
  save_func.AddParam.Describe('linkid','zones');

  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CSF(@IMI_NoteStartEdit),CSF(@IMI_NoteStopEdit));
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_PoolNotesLoad(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  writeln('LOAD EDITOR DATA');
  writeln('----------------------------------------');
  writeln(input.DumpToString);
  Result:=TFRE_DB_EDITOR_DATA_DESC.create.Describe('Loaded editor data.');

end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_PoolNotesSave(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_TreeGridData(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res       : TFRE_DB_STORE_DATA_DESC;
  app       : TFRE_DB_APPLICATION;
  conn      : IFRE_DB_CONNECTION;
  pools     : IFRE_DB_COLLECTION;
  count     : Integer;
  dbObj     : IFRE_DB_Object;
  poolObj   : TFRE_DB_ZFS_ROOTOBJ;
  parentObj : TFRE_DB_ZFS_OBJ;
  children  : IFRE_DB_ObjectArray;
  i         : Integer;
  zfs_obj   : TFRE_DB_ZFS_OBJ;
  idPath    : TFOSStringArray;
  ua        : IFRE_DB_Object;

  procedure _ProcessPools(const obj:IFRE_DB_Object);
  var
    zfsObj: TFRE_DB_ZFS_OBJ;
  begin
    zfsObj:=obj.Implementor_HC as TFRE_DB_ZFS_OBJ;
    if zfsObj is TFRE_DB_ZFS_UNASSIGNED then begin
      ua:=_getTreeObj(zfsObj);
    end else begin
      res.addEntry(_getTreeObj(zfsObj));
    end;
    count:=count+1;
  end;

begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_pools') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  if input.FieldExists('parentid') then begin
    writeln('Parent: ',input.Field('parentid').asstring);
    GFRE_BT.SeperateString(input.Field('parentid').AsString,',',idPath);
    poolObj:=_getPool(conn,idPath[0]);
    parentObj:=poolObj.getPoolItem(TFRE_DB_StringArray(idPath));
    if not Assigned(parentObj) then raise EFRE_DB_Exception.Create('Parent object not found.');
    children:=parentObj.getChildren;
    res:=TFRE_DB_STORE_DATA_DESC.create.Describe(Length(children));
    for i := 0 to Length(children) - 1 do begin
      zfs_obj:=children[i].Implementor_HC as TFRE_DB_ZFS_OBJ;
      res.addEntry(_getTreeObj(zfs_obj));
    end;
  end else begin
    count:=0;
    pools := conn.Collection('ZFS_POOLS');
    res:=TFRE_DB_STORE_DATA_DESC.create;
    pools.ForAll(@_ProcessPools);
    if Assigned(ua) then begin
      res.addEntry(ua);
    end;
    res.Describe(count);
  end;
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_TreeDrop(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  app        : TFRE_DB_APPLICATION;
  conn       : IFRE_DB_CONNECTION;
  session    : TFRE_DB_UserSession;
  dbobj      : IFRE_DB_Object;
  tpool,spool: TFRE_DB_ZFS_ROOTOBJ;
  disk       : TFRE_DB_ZFS_OBJ;
  target     : TFRE_DB_ZFS_OBJ;
  sIdPath,tIdPath:TFOSStringArray;

  storeup    : TFRE_DB_UPDATE_STORE_DESC;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

//  GFRE_BT.SeperateString(input.Field('selected').AsString,',',sIdPath);
  GFRE_BT.SeperateString(input.Field('target').AsString,',',tIdPath);

//  pools.Fetch(GFRE_BT.HexString_2_GUID(sIdPath[0]),dbObj);
//  spool:=dbobj.Implementor_HC as TFRE_DB_ZFS_POOL;
//  disk:=spool.getPoolItem(TFRE_DB_StringArray(sIdPath));
  tpool:=_getPool(conn,tIdPath[0]);
  target:=tpool.getPoolItem(TFRE_DB_StringArray(tIdPath)).Implementor_HC as TFRE_DB_ZFS_OBJ;

  Result:=_AddDisksToPool(tpool,target,input.Field('selected').AsStringArr,app,conn,session);

//  storeup:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
//  storeup.addDeletedEntry(disk.getId);
//  session.SendServerClientRequest(storeup);
//  Result:=GFRE_DB_NIL_DESC;

  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DROP','Drop: '+disk.DumpToString()+ ' into ' + target.DumpToString(),fdbmt_info);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_GridMenu(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res,sub: TFRE_DB_MENU_DESC;
  app    : TFRE_DB_APPLICATION;
  conn   : IFRE_DB_CONNECTION;
  idPath : TFOSStringArray;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  zfsObj : TFRE_DB_ZFS_OBJ;
  i      : Integer;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  rl     : TFRE_DB_ZFS_RAID_LEVEL;
  session: TFRE_DB_UserSession;

  fnIdentifyOn,fnIdentifyOFf, fnRemove, fnAssign, fnSwitchOffline, fnSwitchOnline: Boolean;
  fnSwitchOfflineDisabled, fnSwitchOnlineDisabled: Boolean;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then begin
    if input.Field('selected').ValueCount>1 then begin //multiselection
      fnIdentifyOn:=true;
      fnIdentifyOFf:=true;
      fnRemove:=true;
      fnAssign:=true;
      fnSwitchOffline:=true;
      fnSwitchOnline:=true;
      fnSwitchOfflineDisabled:=false;
      fnSwitchOnlineDisabled:=false;

      for i := 0 to input.Field('selected').ValueCount - 1 do begin
        GFRE_BT.SeperateString(input.Field('selected').AsStringItem[i],',',idPath);
        pool:=_getPool(conn,idPath[0]);
        zfsObj:=pool.getPoolItem(TFRE_DB_StringArray(idPath));
        if zfsObj is TFRE_DB_ZFS_BLOCKDEVICE then begin //check if all selected objects are disks
          if (zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline then begin
            fnSwitchOfflineDisabled:=true;
          end else begin
            fnSwitchOnlineDisabled:=true;
          end;
        end else begin
          fnIdentifyOn:=false;
          fnIdentifyOff:=false;
          fnSwitchOffline:=false;
          fnSwitchOnline:=false;
          fnAssign:=false;
        end;
        if zfsObj.isNew then begin //check if all selected objects are new => delete is possible
          fnSwitchOfflineDisabled:=true;
          fnSwitchOnlineDisabled:=true;
        end else begin
          fnRemove:=false;
        end;
        if pool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED then begin
          fnSwitchOfflineDisabled:=true;
          fnSwitchOnlineDisabled:=true;
        end else begin
          fnAssign:=false;
        end;
      end;
      if fnAssign then begin;
        res:=_addDisksToPool(nil,nil,input.Field('selected').AsStringArr,app,conn,session);
      end;
      if fnRemove then begin
        sf:=CSF(@IMI_RemoveNew);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(StringReplace(app.FetchAppText(conn,'$cm_multiple_remove').Getshort,'%num%',IntToStr(input.field('selected').ValueCount),[rfReplaceAll]),'images_apps/corebox_storage/cm_multiple_remove.png',sf);
      end;
      if fnIdentifyOn then begin
        sf:=CSF(@IMI_Identify_on);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_identify_on').Getshort,'images_apps/corebox_storage/cm_identify.png',sf);
      end;
      if fnIdentifyOff then begin
        sf:=CSF(@IMI_Identify_off);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_identify_off').Getshort,'images_apps/corebox_storage/cm_identify.png',sf);
      end;
      if fnSwitchOffline then begin
        sf:=CSF(@IMI_SwitchOffline);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_switch_offline').Getshort,'images_apps/corebox_storage/cm_switch_offline.png',sf,fnSwitchOfflineDisabled);
      end;
      if fnSwitchOnline then begin
        sf:=CSF(@IMI_SwitchOnline);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_switch_online').Getshort,'images_apps/corebox_storage/cm_switch_online.png',sf,fnSwitchOnlineDisabled);
      end;
      Result:=res;
    end else begin //single selection
      GFRE_BT.SeperateString(input.Field('selected').AsString,',',idPath);
      pool:=_getPool(conn,idPath[0]);
      zfsObj:=pool.getPoolItem(TFRE_DB_StringArray(idPath));
      if (pool is TFRE_DB_ZFS_UNASSIGNED) and (Length(idPath)>1) then begin
        res:=_addDisksToPool(nil,nil,input.Field('selected').AsStringArr,app,conn,session);
      end else begin
        if (zfsObj is TFRE_DB_ZFS_BLOCKDEVICE) and not zfsObj.isNew then begin
          if (zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline then begin
            sf:=CSF(@IMI_SwitchOnline);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            res.AddEntry.Describe(app.FetchAppText(conn,'$cm_switch_online').Getshort,'images_apps/corebox_storage/cm_switch_online.png',sf);
          end else begin
            sf:=CSF(@IMI_SwitchOffline);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            res.AddEntry.Describe(app.FetchAppText(conn,'$cm_switch_offline').Getshort,'images_apps/corebox_storage/cm_switch_offline.png',sf);
          end;
        end;
      end;
      if zfsObj.isNew then begin
        sf:=CSF(@IMI_RemoveNew);
        sf.AddParam.Describe('selected',input.Field('selected').AsString);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_remove').Getshort,'images_apps/corebox_storage/cm_remove.png',sf);
        if (zfsObj is TFRE_DB_ZFS_VDEV) and (zfsObj.Parent.Implementor_HC is TFRE_DB_ZFS_DATASTORAGE) then begin
          sub:=res.AddMenu.Describe(app.FetchAppText(conn,'$cm_change_raid_level').Getshort,'images_apps/corebox_storage/cm_change_raid_level.png');
          rl:=(zfsObj as TFRE_DB_ZFS_VDEV).raidLevel;
          if rl<>zfs_rl_mirror then begin
            sf:=CSF(@IMI_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppText(conn,'$cm_rl_mirror').Getshort,'images_apps/corebox_storage/cm_rl_mirror.png',sf);
          end;
          if rl<>zfs_rl_z1 then begin
            sf:=CSF(@IMI_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppText(conn,'$cm_rl_z1').Getshort,'images_apps/corebox_storage/cm_rl_z1.png',sf);
          end;
          if rl<>zfs_rl_z2 then begin
            sf:=CSF(@IMI_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppText(conn,'$cm_rl_z2').Getshort,'images_apps/corebox_storage/cm_rl_z2.png',sf);
          end;
          if rl<>zfs_rl_z3 then begin
            sf:=CSF(@IMI_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppText(conn,'$cm_rl_z3').Getshort,'images_apps/corebox_storage/cm_rl_z3.png',sf);
          end;
        end;
      end else begin
        if zfsObj is TFRE_DB_ZFS_POOL then begin
          sf:=CSF(@IMI_DestroyPool);
          sf.AddParam.Describe('pool',input.Field('selected').AsString);
          res.AddEntry.Describe(StringReplace(app.FetchAppText(conn,'$cm_destroy_pool').Getshort,'%pool%',zfsObj.caption,[rfReplaceAll]),'images_apps/corebox_storage/cm_destroy_pool.png',sf,zfsObj.isModified);
        end;
      end;
      if zfsObj is TFRE_DB_ZFS_BLOCKDEVICE then begin
        sf:=CSF(@IMI_Identify_on);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_identify_on').Getshort,'images_apps/corebox_storage/cm_identify.png',sf);
        sf:=CSF(@IMI_Identify_off);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppText(conn,'$cm_identify_off').Getshort,'images_apps/corebox_storage/cm_identify.png',sf);
      end;
    end;
    Result:=res;
  end;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_UpdatePoolsTree(const input: IFRE_DB_Object): IFRE_DB_Object;
var disk_data   : IFRE_DB_Object;
    pool_disks  : IFRE_DB_COLLECTION;
begin
  //FIXXXME - please implement me!
  pool_disks := GetDBConnection(input).Collection('POOL_DISKS',false,true);
  //disk_data := DISKI_HACK.Get_Disk_Data;
  UpdateDiskCollection(pool_disks,disk_data);
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_CreatePool(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  app     : TFRE_DB_APPLICATION;
  conn    : IFRE_DB_CONNECTION;
  session : TFRE_DB_UserSession;
  pools   : IFRE_DB_COLLECTION;
  nameOk  : Boolean;
  lastObj : IFRE_DB_Object;
  newPool : TFRE_DB_ZFS_POOL;
  storeObj: IFRE_DB_Object;
  dstore  : TFRE_DB_ZFS_DATASTORAGE;
  storeup : TFRE_DB_UPDATE_STORE_DESC;
  prevId  : String;
  tmp_uid : TGuid;

  procedure _checkPoolName(const obj:IFRE_DB_Object);
  begin
    if LowerCase(input.FieldPath('data.pool_name').AsString)=LowerCase(obj.Field('pool').AsString) then begin
      nameOk:=false;
    end;
    if (obj.Implementor_HC is TFRE_DB_ZFS_POOL) and not (obj.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then begin
      lastObj:=obj;
    end;
  end;

begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  pools := conn.Collection('ZFS_POOLS');
  nameOk:=true;
  pools.ForAll(@_checkPoolName);
  if not nameOk then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$create_pool_error_cap').Getshort,app.FetchAppText(conn,'$create_pool_error_not_unique').Getshort,fdbmt_error);
    exit;
  end;
  newPool:=TFRE_DB_ZFS_POOL.create;
  newPool.caption:=input.FieldPath('data.pool_name').AsString;
  newPool.isNew:=true;
  dstore:=newPool.addDatastorage;
  dstore.caption:=input.FieldPath('data.pool_name').AsString;
  dstore.isNew:=true;
  storeObj:=newPool;
  tmp_uid:=newPool.UID;
  CheckDbResult(pools.Store(storeObj),'Add new pool');
  pools.Fetch(tmp_uid,storeObj);
  newPool:=storeObj.Implementor_HC as TFRE_DB_ZFS_POOL;
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));

  storeup:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  if Assigned(lastObj) then begin
    prevId:=(lastObj.Implementor_HC as TFRE_DB_ZFS_OBJ).getId;
  end else begin
    prevId:='';
  end;
  storeup.addNewEntry(_getTreeObj(newPool),prevId);
  session.SendServerClientRequest(storeup);

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_CreatePoolDiag(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  res  :TFRE_DB_DIALOG_DESC;
  app  : TFRE_DB_APPLICATION;
  conn : IFRE_DB_CONNECTION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppText(conn,'$create_pool_diag_cap').Getshort);
  res.AddInput.Describe(app.FetchAppText(conn,'$create_pool_diag_name').Getshort,'pool_name',true);
  res.AddButton.Describe(app.FetchAppText(conn,'$button_save').Getshort,CSF(@IMI_CreatePool),fdbbt_submit);
  result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_ImportPoolDiag(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  app  : TFRE_DB_APPLICATION;
  conn : IFRE_DB_CONNECTION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$import_pool_diag_cap').Getshort,app.FetchAppText(conn,'$import_pool_diag_msg').Getshort,fdbmt_info,nil);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_AssignSpareDisk(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tspare  : TFRE_DB_ZFS_SPARE;
  i       : Integer;
  idPath  : TFOSStringArray;
  disk    : TFRE_DB_ZFS_OBJ;
  pools   : IFRE_DB_COLLECTION;
  res     : TFRE_DB_UPDATE_STORE_DESC;
  lastIdx : String;
  session : TFRE_DB_UserSession;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  pools := conn.Collection('ZFS_POOLS');
  tpool:=_getPool(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  tspare:=tpool.GetSpare;
  if Assigned(tspare) then begin
    tspare.isModified:=true;
    res.addUpdatedEntry(_getTreeObj(tspare));
  end else begin
    lastIdx:=tpool.getLastChildId;
    tspare:=tpool.addSpare;
    tspare.isNew:=true;
    tspare.caption:=app.FetchAppText(conn,'$new_spare_caption').Getshort;
    res.addNewEntry(_getTreeObj(tspare),lastIdx,tpool.getId);
  end;
  res.addUpdatedEntry(_getTreeObj(tpool));
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=tspare.getLastChildId;
    GFRE_BT.SeperateString(input.Field('disks').AsStringItem[i],',',idPath);
    spool:=_getPool(conn,idPath[0]);
    disk:=spool.removePoolItem(TFRE_DB_StringArray(idPath));
    if not (disk.isNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_not_new').Getshort);
    res.addDeletedEntry(disk.getId);
    disk:=tspare.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.isNew:=true;
    res.addNewEntry(_getTreeObj(disk),lastIdx,tspare.getId);
    CheckDbResult(pools.Update(spool),'Assign spare');
  end;
  CheckDbResult(pools.Update(tpool),'Assign spare');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_AssignCacheDisk(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tcache  : TFRE_DB_ZFS_CACHE;
  i       : Integer;
  idPath  : TFOSStringArray;
  disk    : TFRE_DB_ZFS_OBJ;
  pools   : IFRE_DB_COLLECTION;
  res     : TFRE_DB_UPDATE_STORE_DESC;
  lastIdx : String;
  session : TFRE_DB_UserSession;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  pools := conn.Collection('ZFS_POOLS');
  tpool:=_getPool(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  tcache:=tpool.GetCache;
  if Assigned(tcache) then begin
    tcache.isModified:=true;
    res.addUpdatedEntry(_getTreeObj(tcache));
  end else begin
    lastIdx:=tpool.getLastChildId;
    tcache:=tpool.addCache;
    tcache.isNew:=true;
    tcache.caption:=app.FetchAppText(conn,'$new_cache_caption').Getshort;
    res.addNewEntry(_getTreeObj(tcache),lastIdx,tpool.getId);
  end;
  res.addUpdatedEntry(_getTreeObj(tpool));
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=tcache.getLastChildId;
    GFRE_BT.SeperateString(input.Field('disks').AsStringItem[i],',',idPath);
    spool:=_getPool(conn,idPath[0]);
    disk:=spool.removePoolItem(TFRE_DB_StringArray(idPath));
    if not (disk.isNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_not_new').Getshort);
    res.addDeletedEntry(disk.getId);
    disk:=tcache.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.isNew:=true;
    res.addNewEntry(_getTreeObj(disk),lastIdx,tcache.getId);
    CheckDbResult(pools.Update(spool),'Assign cache');
  end;
  CheckDbResult(pools.Update(tpool),'Assign cache');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_AssignLogDisk(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tlog    : TFRE_DB_ZFS_LOG;
  vdev    : TFRE_DB_ZFS_DISKCONTAINER;
  i       : Integer;
  idPath  : TFOSStringArray;
  disk    : TFRE_DB_ZFS_OBJ;
  pools   : IFRE_DB_COLLECTION;
  res     : TFRE_DB_UPDATE_STORE_DESC;
  lastIdx : String;
  children: IFRE_DB_ObjectArray;
  num     : Integer;
  session : TFRE_DB_UserSession;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  pools := conn.Collection('ZFS_POOLS');
  tpool:=_getPool(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  tlog:=tpool.GetLog;
  if Assigned(tlog) then begin
    tlog.isModified:=true;
    res.addUpdatedEntry(_getTreeObj(tlog));
    if input.FieldExists('expand') and input.Field('expand').AsBoolean then begin
      lastIdx:=tlog.getLastChildId;
      if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
        vdev:=tlog;
      end else begin
        vdev:=tlog.addVdev;
        num:=1;
        children:=tlog.getChildren;
        for i := 0 to Length(children) - 1 do begin
          if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and (children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).isNew then begin
            num:=num+1;
          end;
        end;
        vdev.caption:=StringReplace(app.FetchAppText(conn,'$log_vdev_caption_'+input.Field('rl').AsString).Getshort,'%num%',IntToStr(num),[rfReplaceAll]);
        vdev.isNew:=true;
        vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
        res.addNewEntry(_getTreeObj(vdev),lastIdx,tlog.getId);
      end;
    end else begin
      children:=tlog.getChildren;
      vdev:=nil;
      for i := 0 to Length(children) - 1 do begin
        if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and ((children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).getId=input.Field('add').AsString) then begin
          vdev:=children[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
        end;
      end;
      if not Assigned(vdev) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_vdev_not_found').Getshort);
      vdev.isModified:=true;
      res.addUpdatedEntry(_getTreeObj(vdev));
    end;
  end else begin
    lastIdx:=tpool.getLastChildId;
    tlog:=tpool.addLog;
    tlog.isNew:=true;
    tlog.caption:=app.FetchAppText(conn,'$new_log_caption').Getshort;
    res.addNewEntry(_getTreeObj(tlog),lastIdx,tpool.getId);
    if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
      vdev:=tlog;
    end else begin
      vdev:=tlog.addVdev;
      vdev.isNew:=true;
      vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
      vdev.caption:=StringReplace(app.FetchAppText(conn,'$log_vdev_caption_'+input.Field('rl').AsString).Getshort,'%num%','1',[rfReplaceAll]);
      res.addNewEntry(_getTreeObj(vdev),'',tlog.getId);
    end;
  end;
  res.addUpdatedEntry(_getTreeObj(tpool));
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=vdev.getLastChildId;
    GFRE_BT.SeperateString(input.Field('disks').AsStringItem[i],',',idPath);
    spool:=_getPool(conn,idPath[0]);
    disk:=spool.removePoolItem(TFRE_DB_StringArray(idPath));
    if not (disk.isNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_not_new').Getshort);
    res.addDeletedEntry(disk.getId);
    disk:=vdev.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.isNew:=true;
    res.addNewEntry(_getTreeObj(disk),lastIdx,vdev.getId);
    CheckDbResult(pools.Update(spool),'Assign log');
  end;
  CheckDbResult(pools.Update(tpool),'Assign log');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_AssignStorageDisk(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tstorage: TFRE_DB_ZFS_DATASTORAGE;
  vdev    : TFRE_DB_ZFS_DISKCONTAINER;
  i       : Integer;
  idPath  : TFOSStringArray;
  disk    : TFRE_DB_ZFS_OBJ;
  pools   : IFRE_DB_COLLECTION;
  res     : TFRE_DB_UPDATE_STORE_DESC;
  lastIdx : String;
  children: IFRE_DB_ObjectArray;
  num     : Integer;
  session : TFRE_DB_UserSession;
begin
  session  := GetSession(input);
  conn     := GetDBConnection(input);
  app      := GetEmbeddingApp;
  pools    := conn.Collection('ZFS_POOLS');
  tpool    := _getPool(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res      := TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  tstorage := tpool.GetDatastorage;
  if Assigned(tstorage) then begin
    tstorage.isModified:=true;
    res.addUpdatedEntry(_getTreeObj(tstorage));
    if input.FieldExists('rl') and (String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe) then begin
      vdev := tstorage;
    end else begin
      if input.FieldExists('expand') and input.Field('expand').AsBoolean then begin
        lastIdx  := tstorage.getLastChildId;
        vdev     := tstorage.addVdev;
        num      := 1;
        children := tstorage.getChildren;
        for i := 0 to Length(children) - 1 do begin
          if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and (children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).isNew then begin
            num:=num+1;
          end;
        end;
        vdev.caption:=StringReplace(app.FetchAppText(conn,'$storage_vdev_caption_'+input.Field('rl').AsString).Getshort,'%num%',IntToStr(num),[rfReplaceAll]);
        vdev.isNew:=true;
        vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
        res.addNewEntry(_getTreeObj(vdev),lastIdx,tstorage.getId);
      end else begin
        children:=tstorage.getChildren;
        vdev:=nil;
        for i := 0 to Length(children) - 1 do begin
          if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and ((children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).getId=input.Field('add').AsString) then begin
            vdev:=children[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
          end;
        end;
        if not Assigned(vdev) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_vdev_not_found').Getshort);
      end;
    end;
    vdev.isModified:=true;
    res.addUpdatedEntry(_getTreeObj(vdev));
  end else begin
    lastIdx:=tpool.getLastChildId;
    tstorage:=tpool.addDatastorage;
    tstorage.isNew:=true;
    tstorage.caption:=tpool.caption;
    res.addNewEntry(_getTreeObj(tstorage),lastIdx,tpool.getId);
    if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
      vdev:=tstorage;
    end else begin
      vdev:=tstorage.addVdev;
      vdev.isNew:=true;
      vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
      vdev.caption:=StringReplace(app.FetchAppText(conn,'$storage_vdev_caption_'+input.Field('rl').AsString).Getshort,'%num%','1',[rfReplaceAll]);
    end;
    res.addNewEntry(_getTreeObj(vdev),'',tstorage.getId);
  end;
  res.addUpdatedEntry(_getTreeObj(tpool));
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=vdev.getLastChildId;
    GFRE_BT.SeperateString(input.Field('disks').AsStringItem[i],',',idPath);
    spool:=_getPool(conn,idPath[0]);
    disk:=spool.removePoolItem(TFRE_DB_StringArray(idPath));
    if not (disk.isNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_assign_not_new').Getshort);
    res.addDeletedEntry(disk.getId);
    disk:=vdev.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.isNew:=true;
    res.addNewEntry(_getTreeObj(disk),lastIdx,vdev.getId);
    CheckDbResult(pools.Update(spool),'Assign storage - source');
  end;
  CheckDbResult(pools.Update(tpool),'Assign storage - target');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_RemoveNew(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  pool    : TFRE_DB_ZFS_ROOTOBJ;
  ua      : TFRE_DB_ZFS_UNASSIGNED;
  zfsObj  : TFRE_DB_ZFS_OBJ;
  idPath  : TFOSStringArray;
  i       : Integer;
  pools   : IFRE_DB_COLLECTION;
  res     : TFRE_DB_UPDATE_STORE_DESC;
  session : TFRE_DB_UserSession;

  procedure _handleObj(const zfsObj: TFRE_DB_ZFS_OBJ);
  var
    children : IFRE_DB_ObjectArray;
    i        : Integer;
    lastIdx  : String;
  begin
    children:=zfsObj.getChildren;
    for i := 0 to Length(children) - 1 do begin
      _handleObj(children[i].Implementor_HC as TFRE_DB_ZFS_OBJ);
    end;
    res.addDeletedEntry(zfsObj.getId);
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      lastIdx:=ua.getLastChildId;
      zfsObj.isNew:=False;
      zfsObj.isModified:=False;
      ua.addBlockdevice(zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
      res.addNewEntry(_getTreeObj(zfsObj),lastIdx,ua.getId);
    end;
  end;

begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  pools := conn.Collection('ZFS_POOLS');
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  ua:=_getUnassignedPool(conn);
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    GFRE_BT.SeperateString(input.Field('selected').AsStringItem[i],',',idPath);
    pool:=_getPool(conn,idPath[0]);
    if Assigned(pool) then begin
      if Length(idPath)>1 then begin
        zfsObj:=pool.removePoolItem(TFRE_DB_StringArray(idPath));
      end else begin
        zfsObj:=pool;
      end;
      if pool.getId=ua.getId then begin
        continue; //skip: already unassigned
      end;
      if not zfsObj.isNew then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_remove_not_new').Getshort);
      if Assigned(zfsObj) then begin
        _handleObj(zfsObj);
      end;
      if Length(idPath)>1 then begin
        CheckDbResult(pools.Update(pool),'Remove new');
      end else begin
        pools.Remove(pool.UID);
      end;
    end;
  end;
  CheckDbResult(pools.Update(ua),'Remove new');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_ChangeRaidLevel(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  pool    : TFRE_DB_ZFS_ROOTOBJ;
  i,num   : Integer;
  idPath  : TFOSStringArray;
  vdev    : TFRE_DB_ZFS_VDEV;
  pools   : IFRE_DB_COLLECTION;
  res     : TFRE_DB_UPDATE_STORE_DESC;
  session : TFRE_DB_UserSession;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  pools := conn.Collection('ZFS_POOLS');
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  GFRE_BT.SeperateString(input.Field('selected').AsString,',',idPath);
  pool:=_getPool(conn,idPath[0]);
  vdev:=pool.getPoolItem(TFRE_DB_StringArray(idPath)).Implementor_HC as TFRE_DB_ZFS_VDEV;
  if not vdev.isNew then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_change_rl_not_new').Getshort);
  vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
  for i := 0 to vdev.ParentField.ValueCount - 1 do begin
    if vdev.ParentField.AsObjectItem[i].UID_String=vdev.UID_String then begin
      num:=i+1;
      break;
    end;
  end;
  vdev.caption:=StringReplace(app.FetchAppText(conn,'$storage_vdev_caption_'+input.Field('rl').AsString).Getshort,'%num%',IntToStr(num),[rfReplaceAll]);
  res.addUpdatedEntry(_getTreeObj(vdev));
  CheckDbResult(pools.Update(pool),'Change raid level');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  Result:=res;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_DestroyPool(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  pool:=_getPool(conn,input.Field('pool').AsString);
  sf:=CSF(@IMI_DestroyPoolConfirmed);
  sf.AddParam.Describe('pool',input.Field('pool').AsString);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppText(conn,'$confirm_destroy_caption').Getshort,StringReplace(app.FetchAppText(conn,'$confirm_destroy_msg').Getshort,'%pool%',pool.caption,[rfReplaceAll]),fdbmt_confirm,sf);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_DestroyPoolConfirmed(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  pool:=_getPool(conn,input.Field('pool').AsString);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Destroy Pool confirmed','Please implement me',fdbmt_info);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_Identify_on(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  idPath : TFOSStringArray;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
  session: TFRE_DB_UserSession;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  session:=GetSession(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    GFRE_BT.SeperateString(input.Field('selected').AsStringItem[i],',',idPath);
    pool:=_getPool(conn,idPath[0]);
    disk:=pool.getPoolItem(TFRE_DB_StringArray(idPath)) as TFRE_DB_ZFS_BLOCKDEVICE;
    writeln('DISK ',disk.field('name').AsString);
    writeln('IDENT : ',VM_HACK.DS_IdentifyDisk(disk.field('name').AsString,false));
  end;
  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_Identify_off(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  idPath : TFOSStringArray;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
  session: TFRE_DB_UserSession;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  session:=GetSession(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    GFRE_BT.SeperateString(input.Field('selected').AsStringItem[i],',',idPath);
    pool:=_getPool(conn,idPath[0]);
    disk:=pool.getPoolItem(TFRE_DB_StringArray(idPath)) as TFRE_DB_ZFS_BLOCKDEVICE;
    writeln('DISK ',disk.field('name').AsString);
    writeln('IDENT : ',VM_HACK.DS_IdentifyDisk(disk.field('name').AsString,true));
  end;
  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
  result := GFRE_DB_NIL_DESC;
end;


function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_SwitchOffline(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  idPath : TFOSStringArray;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
  pools  : IFRE_DB_COLLECTION;
  update : TFRE_DB_UPDATE_STORE_DESC;
  session: TFRE_DB_UserSession;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  session:=GetSession(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  pools := conn.Collection('ZFS_POOLS');
  update:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    GFRE_BT.SeperateString(input.Field('selected').AsStringItem[i],',',idPath);
    pool:=_getPool(conn,idPath[0]);
    disk:=pool.getPoolItem(TFRE_DB_StringArray(idPath)) as TFRE_DB_ZFS_BLOCKDEVICE;
    disk.isOffline:=true;
    update.addUpdatedEntry(_getTreeObj(disk));
    CheckDbResult(pools.Update(pool),'Switch offline');
  end;
  session.SendServerClientRequest(update);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_SwitchOnline(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  idPath : TFOSStringArray;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
  pools  : IFRE_DB_COLLECTION;
  update : TFRE_DB_UPDATE_STORE_DESC;
  session: TFRE_DB_UserSession;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  session:=GetSession(input);
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  pools := conn.Collection('ZFS_POOLS');
  update:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    GFRE_BT.SeperateString(input.Field('selected').AsStringItem[i],',',idPath);
    pool:=_getPool(conn,idPath[0]);
    disk:=pool.getPoolItem(TFRE_DB_StringArray(idPath)) as TFRE_DB_ZFS_BLOCKDEVICE;
    disk.isOffline:=false;
    update.addUpdatedEntry(_getTreeObj(disk));
    CheckDbResult(pools.Update(pool),'Switch online');
  end;
  session.SendServerClientRequest(update);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Online','Switch online (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD._unassignDisk(const upool: TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: TFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: TFRE_DB_UserSession);
var
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  i       : Integer;
  idPath  : TFOSStringArray;
  disk    : TFRE_DB_ZFS_OBJ;
  pools   : IFRE_DB_COLLECTION;
  update  : TFRE_DB_UPDATE_STORE_DESC;
  lastIdx : String;
begin
  pools := conn.Collection('ZFS_POOLS');
  update:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');

  for i := 0 to Length(disks) - 1 do begin
    GFRE_BT.SeperateString(disks[i],',',idPath);
    spool:=_getPool(conn,idPath[0]);
    if spool.getId=upool.getId then begin
      continue; //skip: already unassigned
    end;
    lastIdx:=upool.getLastChildId;
    disk:=spool.removePoolItem(TFRE_DB_StringArray(idPath));
    if not disk.isNew then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_unassign_not_new').Getshort);
    update.addDeletedEntry(disk.getId);
    disk:=upool.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    if disk.isNew then begin
      disk.isNew:=False;
      disk.isModified:=False;
    end else begin
      disk.isModified:=True;
    end;
    update.addNewEntry(_getTreeObj(disk),lastIdx,upool.getId);
    CheckDbResult(pools.Update(spool),'Unassign Disk');
  end;
  CheckDbResult(pools.Update(upool),'Unassign Disk');
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',false));
  session.SendServerClientRequest(update);
end;


function TFRE_DBCOREBOX_STORAGE_POOLS_MOD._SendData(const Input: IFRE_DB_Object): IFRE_DB_Object;
var
  session : TFRE_DB_UserSession;
begin
  session:=GetSession(Input);
  if Assigned(ZPOOL_IOSTAT_UPDATE) then begin
    session.SendServerClientRequest(ZPOOL_IOSTAT_UPDATE);
    ZPOOL_IOSTAT_UPDATE:=nil;
  end;
  __idx:=__idx+1;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_SaveConfig(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn   : IFRE_DB_CONNECTION;
  app    : TFRE_DB_APPLICATION;
  session: TFRE_DB_UserSession;
begin
  session:=GetSession(input);
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',true));
  session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',true));
  result:=TFRE_DB_MESSAGE_DESC.create.Describe('SAVE','Save Config',fdbmt_info);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_ResetConfig(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  session : TFRE_DB_UserSession;
  conn    : IFRE_DB_CONNECTION;
  app     : TFRE_DB_APPLICATION;
  storeup : TFRE_DB_UPDATE_STORE_DESC;
  pools   : IFRE_DB_COLLECTION;
  lastId  : String;

  procedure _addRemove(const obj: IFRE_DB_Object);
  begin
    storeup.addDeletedEntry((obj.Implementor_HC as TFRE_DB_ZFS_OBJ).getId);
  end;

  procedure _addObj(const obj: IFRE_DB_Object);
  var
    zfsObj: TFRE_DB_ZFS_OBJ;
  begin
    zfsObj:=obj.Implementor_HC as TFRE_DB_ZFS_OBJ;
    storeup.addNewEntry(_getTreeObj(zfsObj),lastId);
    lastId:=zfsObj.getId;
  end;

begin

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Disabled','Feature disabled in demonstration mode',fdbmt_info);

  //session:=GetSession(input);
  //conn:=GetDBConnection(input);
  //app:=GetEmbeddingApp;
  //if not conn.CheckRight(Get_Rightname_App(app.ObjectName,'administer_pools')) then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);
  //
  //storeup:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  //pools := conn.Collection('ZFS_POOLS');
  //pools.ForAll(@_addRemove);
  //_buildPoolsCollection(conn);
  //lastId:='';
  //pools.ForAll(@_addObj);
  //session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_save',true));
  //session.SendServerClientRequest(TFRE_DB_SET_BUTTON_STATE_DESC.create.Describe('pool_reset',true));
  //Result:=storeup;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_Replace(const input: IFRE_DB_Object): IFRE_DB_Object;
var
  conn: IFRE_DB_CONNECTION;
  app : TFRE_DB_APPLICATION;
begin
  conn:=GetDBConnection(input);
  app:=GetEmbeddingApp;
  if not app.CheckAppRightModule(conn,'storage_pools') then raise EFRE_DB_Exception.Create(app.FetchAppText(conn,'$error_no_access').Getshort);

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Replace','Please implement me',fdbmt_info);
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.IMI_RAW_DISK_FEED(const data: IFRE_DB_Object): IFRE_DB_Object;
var pool_disks : IFRE_DB_COLLECTION;
    dbc        : IFRE_DB_CONNECTION;
    pools      : IFRE_DB_COLLECTION;
    storeup    : TFRE_DB_UPDATE_STORE_DESC;
    //Disks.Field(diskid).AsObject.Field('rps').AsReal32    := StrToFloat(line[0]);
    //Disks.Field(diskid).AsObject.Field('wps').AsReal32    := StrToFloat(line[1]);
    //Disks.Field(diskid).AsObject.Field('krps').AsReal32   := StrToFloat(line[2]);
    //Disks.Field(diskid).AsObject.Field('kwps').AsReal32   := StrToFloat(line[3]);
    //Disks.Field(diskid).AsObject.Field('wait').AsReal32   := StrToFloat(line[4]);
    //Disks.Field(diskid).AsObject.Field('actv').AsReal32   := StrToFloat(line[5]);
    //Disks.Field(diskid).AsObject.Field('wsvc_t').AsReal32 := StrToFloat(line[6]);
    //Disks.Field(diskid).AsObject.Field('actv_t').AsReal32 := StrToFloat(line[7]);
    //Disks.Field(diskid).AsObject.Field('perc_w').AsReal32 := StrToFloat(line[8]);
    //Disks.Field(diskid).AsObject.Field('perc_b').AsReal32 := StrToFloat(line[9]);

  procedure _updatePool(const field: IFRE_DB_Field);
  var
    pool: TFRE_DB_ZFS_ROOTOBJ;
  begin
    if field.FieldType=fdbft_GUID then exit;
    pool:=_getPoolByName(dbc,field.FieldName);
    if assigned(pool) then
      begin
        UpdateZpool(pool,field.AsObject,storeup);
        CheckDbResult(pools.Update(pool),'Update pool');
      end;
  end;

begin
  dbc := GetDBConnection(data);
  pool_disks := dbc.Collection('POOL_DISKS',false,true);
  UpdateDiskCollection(pool_disks,data.Field('DISK').AsObject);

  storeup:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
  pools := dbc.Collection('ZFS_POOLS');
  data.Field('ZPOOLIO').AsObject.ForAllFields(@_updatePool);
  ZPOOL_IOSTAT_UPDATE:=storeup;
  result := GFRE_DB_NIL_DESC;
end;


function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.Usage(const input:IFRE_DB_Object): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := GetSession(input).FetchDerivedCollection('POOL_SPACE');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.ServiceTime(const input:IFRE_DB_Object): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := GetSession(input).FetchDerivedCollection('POOL_AST');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.BusyTime(const input: IFRE_DB_Object): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := GetSession(input).FetchDerivedCollection('POOL_BUSY');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.ReadBW(const input:IFRE_DB_Object): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := GetSession(input).FetchDerivedCollection('POOL_RBW');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_DBCOREBOX_STORAGE_POOLS_MOD.WriteBW(const input:IFRE_DB_Object): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := GetSession(input).FetchDerivedCollection('POOL_WBW');
  Result:=coll.GetDisplayDescription;
end;

procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD.UpdateDiskCollection(const pool_disks: IFRE_DB_COLLECTION; const data: IFRE_DB_Object);
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
  debugs := '';
  pool_disks.StartBlockUpdating;
  try
    data.ForAllFields(@UpdateDisks);
  finally
    pool_disks.FinishBlockUpdating;
  end;
end;

procedure TFRE_DBCOREBOX_STORAGE_POOLS_MOD.UpdateZpool(const zpool: TFRE_DB_ZFS_ROOTOBJ; const data: IFRE_DB_Object; const updateDescr: TFRE_DB_UPDATE_STORE_DESC);
var
  zfsObj : TFRE_DB_ZFS_OBJ;

  procedure _updateZfsObject(const field: IFRE_DB_Field);
  var
    zfsObj: TFRE_DB_ZFS_OBJ;
  begin
    if field.FieldType=fdbft_GUID then exit;

    zfsObj:=zpool.getItemByCaption(field.FieldName);
    if Assigned(zfsObj) then begin
      zfsObj.iopsR:=field.AsObject.Field('iops_r').AsString;
      zfsObj.iopsW:=field.AsObject.Field('iops_w').AsString;
      zfsObj.transferR:=field.AsObject.Field('transfer_r').AsString;
      zfsObj.transferW:=field.AsObject.Field('transfer_w').AsString;
      updateDescr.addUpdatedEntry(_getTreeObj(zfsObj));
    end;
  end;

begin
  data.ForAllFields(@_updateZfsObject);
end;

{ TFRE_DBCOREBOX_STORAGE_SYNCH_MOD }

class procedure TFRE_DBCOREBOX_STORAGE_SYNCH_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DBCOREBOX_STORAGE_SYNCH_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('STORAGE_SYNC','$synch_description')
end;


function TFRE_DBCOREBOX_STORAGE_SYNCH_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me.');
end;


{ TFRE_DBCOREBOX_STORAGE_APP }

procedure TFRE_DBCOREBOX_STORAGE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('corebox_storage','$description');
  AddApplicationModule(TFRE_DBCOREBOX_STORAGE_POOLS_MOD.create);
  AddApplicationModule(TFRE_DBCOREBOX_STORAGE_SYNCH_MOD.create);
  AddApplicationModule(TFRE_DBCOREBOX_GLOBAL_FILESERVER_MOD.create);
  AddApplicationModule(TFRE_DBCOREBOX_VIRTUAL_FILESERVER_MOD.create);
  AddApplicationModule(TFRE_DBCOREBOX_BACKUP_MOD.create);
end;

function TFRE_DBCOREBOX_STORAGE_APP.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
var
  old_version  : TFRE_DB_String;

  procedure _InstallAllDomains(const obj:IFRE_DB_Object);
  begin
    InstallSystemGroupsandRoles(conn,obj.Field('objname').asstring);
  end;


begin
  case _CheckVersion(conn,old_version) of
    NotInstalled : begin
                      _SetAppdataVersion(conn,_ActualVersion);
                      conn.ForAllDomains(@_InstallAllDomains);

                      CreateAppText(conn,'$description','Storage','Storage','Storage');
                      CreateAppText(conn,'$pools_description','Pools','Pools','Pools');
                      CreateAppText(conn,'$synch_description','Synchronization','Synchronization','Synchronization');
                      CreateAppText(conn,'$backup_description','Backup','Backup','Backup');
                      CreateAppText(conn,'$fileserver_global_description','Global SAN/NAS','Global SAN/NAS','Global SAN/NAS');
                      CreateAppText(conn,'$fileserver_virtual_description','Virtual NAS','Virtual NAS','Virtual NAS');

                      CreateAppText(conn,'$sitemap_main','Storage','','Storage');
                      CreateAppText(conn,'$sitemap_pools','Pools','','Pools');
                      CreateAppText(conn,'$sitemap_pools_layout','Layout','','Layout');
                      CreateAppText(conn,'$sitemap_pools_status','Status','','Status');
                      CreateAppText(conn,'$sitemap_pools_space','Space','','Space');
                      CreateAppText(conn,'$sitemap_synchronize','Synchronize','','Synchronize');
                      CreateAppText(conn,'$sitemap_synchronize_fc','FibreChannel','','FibreChannel');
                      CreateAppText(conn,'$sitemap_synchronize_iscsi','iSCSI','','iSCSI');
                      CreateAppText(conn,'$sitemap_fileserver','SAN/NAS','','SAN/NAS');
                      CreateAppText(conn,'$sitemap_fileserver_global','Global SAN/NAS','','Global NFS, iSCSI, FC');
                      CreateAppText(conn,'$sitemap_fileserver_virtual','Virtual NAS','','Virtual Fileserver');
                      CreateAppText(conn,'$sitemap_backup','Backup','','Backup');
                      CreateAppText(conn,'$sitemap_filebrowser','Filebrowser','','Filebrowser');

                      CreateAppText(conn,'$pool_layout_tab','Layout');
                      CreateAppText(conn,'$pool_status_tab','Status');
                      CreateAppText(conn,'$pool_space_tab','Space');
                      CreateAppText(conn,'$pool_notes_tab','Note');

                      CreateAppText(conn,'$create_pool','Create Pool');
                      CreateAppText(conn,'$create_pool_diag_cap','Create Pool');
                      CreateAppText(conn,'$create_pool_diag_name','Name');
                      CreateAppText(conn,'$create_pool_error_cap','Error creating a new pool');
                      CreateAppText(conn,'$create_pool_error_not_unique','The name of the pool has to be unique. Please choose another one.');
                      CreateAppText(conn,'$import_pool','Import Pool');
                      CreateAppText(conn,'$import_pool_diag_cap','Import Pool');
                      CreateAppText(conn,'$import_pool_diag_msg','Feature disabled in Demo Mode.');
                      CreateAppText(conn,'$save_config','Save');
                      CreateAppText(conn,'$reset_config','Reset');
                      CreateAppText(conn,'$new_spare_caption','spare');
                      CreateAppText(conn,'$new_log_caption','log');
                      CreateAppText(conn,'$log_vdev_caption_rl_mirror','mirror (%num%)');
                      CreateAppText(conn,'$new_cache_caption','cache');
                      CreateAppText(conn,'$storage_vdev_caption_rl_mirror','mirror (%num%)');
                      CreateAppText(conn,'$storage_vdev_caption_rl_z1','raid-z1 (%num%)');
                      CreateAppText(conn,'$storage_vdev_caption_rl_z2','raid-z2 (%num%)');
                      CreateAppText(conn,'$storage_vdev_caption_rl_z3','raid-z3 (%num%)');
                      CreateAppText(conn,'$error_assign_not_new','You can only assign disks which are not in use yet.');
                      CreateAppText(conn,'$error_unassign_not_new','You can only unassign disks which are not in use yet.');
                      CreateAppText(conn,'$error_assign_vdev_not_found','Assign disks: Vdev not found.');
                      CreateAppText(conn,'$error_assign_vdev_unknown_parent_type','Parent of Vdev does not support disk drops.');
                      CreateAppText(conn,'$error_remove_not_new','You can only remove zfs elements which are not in use yet.');
                      CreateAppText(conn,'$error_change_rl_not_new','You can only change the raid level of a vdev which is not in use yet.');

                      CreateAppText(conn,'$add_disks_pool','Assign to %pool%...');
                      CreateAppText(conn,'$add_disks_storage_ex_same','Expand storage (%raid_level%)');
                      CreateAppText(conn,'$add_disks_storage_ex_other','Expand storage...');
                      CreateAppText(conn,'$add_disks_storage','Add as storage...');
                      CreateAppText(conn,'$add_disks_storage_to','Add as storage to "%vdev%"');
                      CreateAppText(conn,'$add_disks_vdev','Add to vdev');
                      CreateAppText(conn,'$add_disks_cache','Add as read cache (L2ARC)');
                      CreateAppText(conn,'$add_disks_log','Add as write cache (ZIL)...');
                      CreateAppText(conn,'$add_disks_log_to','Add as write cache (ZIL) to "%vdev%"');
                      CreateAppText(conn,'$add_disks_log_ex','Expand write cache (ZIL)...');
                      CreateAppText(conn,'$add_disks_spare','Add as spare');
                      CreateAppText(conn,'$add_disks_rl_mirror','Mirror');
                      CreateAppText(conn,'$add_disks_rl_stripe','Stripe');
                      CreateAppText(conn,'$add_disks_rl_z1','Raid-Z1');
                      CreateAppText(conn,'$add_disks_rl_z2','Raid-Z2');
                      CreateAppText(conn,'$add_disks_rl_z3','Raid-Z3');

                      CreateAppText(conn,'$confirm_destroy_caption','Destroy pool');
                      CreateAppText(conn,'$confirm_destroy_msg','This operation is irreversible! Destroy pool %pool% anyway?');

                      CreateAppText(conn,'$cm_replace','Replace');
                      CreateAppText(conn,'$cm_switch_offline','Switch offline');
                      CreateAppText(conn,'$cm_switch_online','Switch online');
                      CreateAppText(conn,'$cm_identify_on','Identify ON');
                      CreateAppText(conn,'$cm_identify_off','Identify OFF');
                      CreateAppText(conn,'$cm_multiple_remove','Remove %num% items');
                      CreateAppText(conn,'$cm_remove','Remove item');
                      CreateAppText(conn,'$cm_change_raid_level','Change raid level...');
                      CreateAppText(conn,'$cm_rl_mirror','Mirror');
                      CreateAppText(conn,'$cm_rl_z1','Raid-Z1');
                      CreateAppText(conn,'$cm_rl_z2','Raid-Z2');
                      CreateAppText(conn,'$cm_rl_z3','Raid-Z3');
                      CreateAppText(conn,'$cm_destroy_pool','Destroy pool %pool%');

                      CreateAppText(conn,'$storage_global_filer_nfs','NFS Exports','NFS Exports','NFS Exports');
                      CreateAppText(conn,'$storage_global_filer_lun','LUN Targets','LUN Targets','LUN Targets');

                      CreateAppText(conn,'$nfs_export','Export');
                      CreateAppText(conn,'$nfs_refer','Refer');
                      CreateAppText(conn,'$nfs_used','Used');
                      CreateAppText(conn,'$nfs_avail','Avail');
                      CreateAppText(conn,'$nfs_pool','Diskpool');
                      CreateAppText(conn,'$nfs_desc','Description');
                      CreateAppText(conn,'$nfs_content_header','Details about the selected NFS export');

                      CreateAppText(conn,'$nfs_access','NFS Access');
                      CreateAppText(conn,'$nfs_accesstype','Accesstype');
                      CreateAppText(conn,'$nfs_accesssubnet','Host/Subnet');
                      CreateAppText(conn,'$create_nfs_access','Create Access');
                      CreateAppText(conn,'$nfsaccess_delete','Delete Access');
                      CreateAppText(conn,'$nfsaccess_modify','Modify Access');

                      CreateAppText(conn,'$create_nfs_export','Create Export');
                      CreateAppText(conn,'$nfs_delete','Delete share');
                      CreateAppText(conn,'$nfs_delete_diag_cap','Confirm: Delete share(s)');
                      CreateAppText(conn,'$nfs_delete_diag_msg','The share(s) %share_str% will be deleted permanently! Please confirm to continue.');
                      CreateAppText(conn,'$nfs_add_diag_cap','New NFS Share');
                      CreateAppText(conn,'$nfsaccess_add_diag_cap','New NFS Access');
                      CreateAppText(conn,'$nfsaccess_modify_diag_cap','Modify NFS Access');

                      CreateAppText(conn,'$create_lun','Create LUN');
                      CreateAppText(conn,'$lun_view','LUN Views');
                      CreateAppText(conn,'$lun_guid','GUID');
                      CreateAppText(conn,'$lun_pool','Diskpool');
                      CreateAppText(conn,'$lun_desc','Description');
                      CreateAppText(conn,'$lun_size','Size [MB]');
                      CreateAppText(conn,'$lun_delete','Delete LUN');
                      CreateAppText(conn,'$lun_delete_diag_cap','Confirm: Delete LUN(s)');
                      CreateAppText(conn,'$lun_delete_diag_msg','The LUN(s) %guid_str% will be deleted permanently! Please confirm to continue.');
                      CreateAppText(conn,'$lun_content_header','Details about the selected LUN');
                      CreateAppText(conn,'$lun_add_diag_cap','New LUN');

                      CreateAppText(conn,'$lun_view_initiatorgroup','Initiators');
                      CreateAppText(conn,'$lun_view_targetgroup','Targets');
                      CreateAppText(conn,'$create_lun_view','Create View');
                      CreateAppText(conn,'$lunview_delete','Delete View');
                      CreateAppText(conn,'$lunview_modify','Modify View');
                      CreateAppText(conn,'$lunview_add_diag_cap','New LUN View');
                      CreateAppText(conn,'$lunview_modify_diag_cap','Modify LUN View');

                      CreateAppText(conn,'$create_vfs','Create Virtual NAS');
                      CreateAppText(conn,'$vfs_delete','Delete Virtual NAS');
                      CreateAppText(conn,'$vfs_name','Fileserver');
                      CreateAppText(conn,'$vfs_pool','Diskpool');
                      CreateAppText(conn,'$vfs_desc','Description');
                      CreateAppText(conn,'$vfs_ip','IP/Subnet');
                      CreateAppText(conn,'$vfs_domain','Domain');
                      CreateAppText(conn,'$storage_virtual_filer_shares','Shares');
                      CreateAppText(conn,'$storage_virtual_filer_content','Virtual NAS Properties');
                      CreateAppText(conn,'$vfs_content_header','Details about the selected virtual NAS.');
                      CreateAppText(conn,'$vfs_add_diag_cap','New Virtual Fileserver');
                      CreateAppText(conn,'$vfs_delete_diag_cap','Confirm: Delete Virtual Fileserver(s)');
                      CreateAppText(conn,'$vfs_delete_diag_msg','The virtual fileserver(s) %vfs_str% will be deleted permanently! Please confirm to continue.');

                      CreateAppText(conn,'$vfs_share','Share');
                      CreateAppText(conn,'$vfs_share_desc','Description');
                      CreateAppText(conn,'$vfs_share_refer','Refer');
                      CreateAppText(conn,'$vfs_share_used','Used');
                      CreateAppText(conn,'$vfs_share_avail','Avail');
                      CreateAppText(conn,'$vfs_share_icon','Sharing');
                      CreateAppText(conn,'$create_vfs_share','Create Share');
                      CreateAppText(conn,'$vfs_share_delete','Delete Share');
                      CreateAppText(conn,'$storage_virtual_filer_share_properties','Share Properties');
                      CreateAppText(conn,'$storage_virtual_filer_share_groups','Groups');
                      CreateAppText(conn,'$storage_virtual_filer_share_user','User');
                      CreateAppText(conn,'$vfs_share_content_header','Details about the selected share.');
                      CreateAppText(conn,'$vfs_share_add_diag_cap','New Fileshare');
                      CreateAppText(conn,'$vfs_share_add_no_fs_msg','Please select a virtual NAS first before adding a share.');
                      CreateAppText(conn,'$vfs_share_delete_diag_cap','Confirm: Delete share(s)');
                      CreateAppText(conn,'$vfs_share_delete_diag_msg','The share(s) %share_str% will be deleted permanently! Please confirm to continue.');
                      CreateAppText(conn,'$share_group_in_diag_cap','Adding Access to Group');
                      CreateAppText(conn,'$share_group_in_no_share_msg','Please select a share first before adding group access.');

                      CreateAppText(conn,'$share_group_in','Groups with access to the fileshare.');
                      CreateAppText(conn,'$share_group_out','Groups without access to the fileshare.');
                      CreateAppText(conn,'$share_group_read','Read Access');
                      CreateAppText(conn,'$share_group_write','Write Access');
                      CreateAppText(conn,'$share_group_group','Group');
                      CreateAppText(conn,'$share_group_desc','Description');

                      CreateAppText(conn,'$share_group_setread_on','Set Read Access');
                      CreateAppText(conn,'$share_group_setread_off','Clear Read Access');
                      CreateAppText(conn,'$share_group_setwrite_on','Set Write Access');
                      CreateAppText(conn,'$share_group_setwrite_off','Clear Write Access');

                      CreateAppText(conn,'$backup_share','Source');
                      CreateAppText(conn,'$backup_snapshot','ZFS Snapshot');
                      CreateAppText(conn,'$backup_desc','Description');
                      CreateAppText(conn,'$backup_creation','Creation Timestamp');
                      CreateAppText(conn,'$backup_used','Used [MB]');
                      CreateAppText(conn,'$backup_refer','Refer [MB]');
                      CreateAppText(conn,'$backup_snapshot_properties','Snapshot Properties');
                      CreateAppText(conn,'$backup_schedule_properties','Schedule Properties');
                      CreateAppText(conn,'$backup_content_header','Details about the selected snapshot.');
                      CreateAppText(conn,'$backup_snapshot_delete','Delete');
                      CreateAppText(conn,'$backup_snapshot_delete_diag_cap','Confirm: Delete snapshot(s)');
                      CreateAppText(conn,'$backup_snapshot_delete_diag_msg','Feature disabled in Demo Mode.');

                      //FIXXME - CHECK
                      CreateAppText(conn,'$error_no_access','Access denied'); //global text?
                      CreateAppText(conn,'$error_not_found','Not found'); //global text?
                      CreateAppText(conn,'$button_save','Save'); //global text?
                   end;
    SameVersion  : begin
                      writeln('Version '+old_version+' already installed');
                   end;
    OtherVersion : begin
                      writeln('Old Version '+old_version+' found, updateing');
                      // do some update stuff
                      _SetAppdataVersion(conn,_ActualVersion);
                   end;
  else
    raise EFRE_DB_Exception.Create('Undefined App _CheckVersion result');
  end;

end;

function TFRE_DBCOREBOX_STORAGE_APP.InstallSystemGroupsandRoles(const conn: IFRE_DB_SYS_CONNECTION; const domain: TFRE_DB_NameType): TFRE_DB_Errortype;
var
  role         : IFRE_DB_ROLE;
begin
  if domain=cSYS_DOMAIN then begin
    role := _CreateAppRole('view_pools','View pools','Allowed to view pools and pool statistics.');
    _AddAppRight(role,'view_pools','View pools','Allowed to view pools and pool statistics.');
    _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_pools']));
    conn.StoreRole(ObjectName,domain,role);

    role := _CreateAppRole('administer_pools','Administer pools','Allowed to administer pools.');
    _AddAppRight(role,'view_pools','View pools','Allowed to view pools and pool statistics.');
    _AddAppRight(role,'administer_pools','Administer pools','Allowed to administer pools.');
    _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_pools']));
    conn.StoreRole(ObjectName,domain,role);

    role := _CreateAppRole('view_fileserver_global','View SAN/NAS','Allowed to view SAN/NAS.');
    _AddAppRight(role,'view_fileserver_global','View SAN/NAS','Allowed to view SAN/NAS.');
    _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_global']));
    conn.StoreRole(ObjectName,domain,role);

    role := _CreateAppRole('edit_nfs_global','Edit global NFS fileshares','Allowed to create/edit NFS fileshares.');
    _AddAppRight(role,'view_fileserver_global','View SAN/NAS','Allowed to view SAN/NAS.');
    _AddAppRight(role,'edit_nfs_global','Edit NFS fileshares','Allowed to create/edit NFS fileshares.');
    _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_global']));
    conn.StoreRole(ObjectName,domain,role);

    role := _CreateAppRole('edit_lun_global','Edit global LUN','Allowed to create/edit LUN.');
    _AddAppRight(role,'view_fileserver_global','View SAN/NAS','Allowed to view SAN/NAS.');
    _AddAppRight(role,'edit_lun_global','Edit LUN','Allowed to create/edit LUN.');
    _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_global']));
    conn.StoreRole(ObjectName,domain,role);
  end;

  role := _CreateAppRole('view_fileserver_virtual','View virtual fileserver','Allowed to view virtual NAS.');
  _AddAppRight(role,'view_fileserver_virtual','View virtual fileserver','Allowed to view virtual NAS.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_virtual']));
  conn.StoreRole(ObjectName,domain,role);

  role := _CreateAppRole('edit_vfs','Edit virtual fileservers','Allowed to create/edit virtual fileservers.');
  _AddAppRight(role,'view_fileserver_virtual','View virtual fileserver','Allowed to view virtual NAS.');
  _AddAppRight(role,'edit_vfs','Edit virtual fileservers','Allowed to create/edit virtual fileservers.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_virtual']));
  conn.StoreRole(ObjectName,domain,role);

  role := _CreateAppRole('view_vfs_share','view virtual fileserver shares','Allowed to view virtual fileserver shares.');
  _AddAppRight(role,'view_vfs_share','View virtual fileserver share','Allowed to view virtual fileserver shares.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_virtual']));
  conn.StoreRole(ObjectName,domain,role);

  role := _CreateAppRole('edit_vfs_share','Edit virtual fileserver shares','Allowed to create/edit virtual fileserver shares.');
  _AddAppRight(role,'view_vfs_share','View virtual fileserver share','Allowed to view virtual fileserver shares.');
  _AddAppRight(role,'edit_vfs_share','Edit virtual fileserver shares','Allowed to create/edit virtual fileserver shares.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_fileserver_virtual']));
  conn.StoreRole(ObjectName,domain,role);


  role := _CreateAppRole('view_backup','View backups','Allowed to view backups.');
  _AddAppRight(role,'view_backup','Allowed to view backups.','Allowed to view backups.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_backup']));
  conn.StoreRole(ObjectName,domain,role);

  role := _CreateAppRole('delete_backup','Delete backups','Allowed to delete backups.');
  _AddAppRight(role,'view_backup','Allowed to view backups.','Allowed to view backups.');
  _AddAppRight(role,'delete_backup','Allowed to delete backups.','Allowed to delete backups.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['storage_backup']));
  conn.StoreRole(ObjectName,domain,role);

  _AddSystemGroups(conn,domain);

  if domain=cSYS_DOMAIN then begin
    conn.ModifyGroupRoles(Get_Groupname_App_Group_Subgroup(ObjectName,'USER'+'@'+domain),GFRE_DBI.ConstructStringArray([Get_Rightname_App_Role_SubRole(ObjectName,'view_pools'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'view_fileserver_global'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'view_fileserver_virtual'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'view_vfs_share'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'view_backup'+'@'+domain)]));
    conn.ModifyGroupRoles(Get_Groupname_App_Group_Subgroup(ObjectName,'ADMIN'+'@'+domain),GFRE_DBI.ConstructStringArray([Get_Rightname_App_Role_SubRole(ObjectName,'administer_pools'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'edit_nfs_global'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'edit_lun_global'+'@'+domain),
                          Get_Rightname_App_Role_SubRole(ObjectName,'edit_vfs'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'edit_vfs_share'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'delete_backup'+'@'+domain)]));
  end else begin
    conn.ModifyGroupRoles(Get_Groupname_App_Group_Subgroup(ObjectName,'USER'+'@'+domain),GFRE_DBI.ConstructStringArray([Get_Rightname_App_Role_SubRole(ObjectName,'view_fileserver_virtual'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'view_vfs_share'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'view_backup'+'@'+domain)]));
    conn.ModifyGroupRoles(Get_Groupname_App_Group_Subgroup(ObjectName,'ADMIN'+'@'+domain),GFRE_DBI.ConstructStringArray([Get_Rightname_App_Role_SubRole(ObjectName,'edit_vfs'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'edit_vfs_share'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'delete_backup'+'@'+domain)]));
  end;
end;

procedure TFRE_DBCOREBOX_STORAGE_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage',FetchAppText(conn,'$sitemap_main').Getshort,'images_apps/corebox_storage/files_white.svg','',0,CheckAppRightModule(conn,'storage_pools') or CheckAppRightModule(conn,'storage_sync') or CheckAppRightModule(conn,'storage_fileserver_global') or CheckAppRightModule(conn,'storage_fileserver_virtual') or CheckAppRightModule(conn,'storage_sync'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools',FetchAppText(conn,'$sitemap_pools').Getshort,'images_apps/corebox_storage/disk_white.svg','STORAGE_POOLS',0,CheckAppRightModule(conn,'storage_pools'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools/Status',FetchAppText(conn,'$sitemap_pools_status').Getshort,'images_apps/corebox_storage/monitor_white.svg','STORAGE_POOLS:status',0,CheckAppRightModule(conn,'storage_pools'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools/Space',FetchAppText(conn,'$sitemap_pools_space').Getshort,'images_apps/corebox_storage/piechart_white.svg','STORAGE_POOLS:space',0,CheckAppRightModule(conn,'storage_pools'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools/Layout',FetchAppText(conn,'$sitemap_pools_layout').Getshort,'images_apps/corebox_storage/piechart_white.svg','STORAGE_POOLS:layout',0,CheckAppRightModule(conn,'storage_pools'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Global',FetchAppText(conn,'$sitemap_fileserver_global').Getshort,'images_apps/corebox_storage/files_global_white.svg','STORAGE_FILESERVER_GLOBAL',0,CheckAppRightModule(conn,'storage_fileserver_global'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Virtual',FetchAppText(conn,'$sitemap_fileserver_virtual').Getshort,'images_apps/corebox_storage/files_virtual_white.svg','STORAGE_FILESERVER_VIRTUAL',0,CheckAppRightModule(conn,'storage_fileserver_virtual'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Backup',FetchAppText(conn,'$sitemap_backup').Getshort,'images_apps/corebox_storage/clock_white.svg','STORAGE_BACKUP',0,CheckAppRightModule(conn,'storage_backup') or CheckAppRightModule(conn,'storage_filebrowser'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Backup/Filebrowser',FetchAppText(conn,'$sitemap_filebrowser').Getshort,'images_apps/corebox_storage/filebrowser_white.svg','',0,CheckAppRightModule(conn,'storage_filebrowser'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Synchronize',FetchAppText(conn,'$sitemap_synchronize').Getshort,'images_apps/corebox_storage/sync_white.svg','STORAGE_SYNC',0,CheckAppRightModule(conn,'storage_sync'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Synchronize/FibreChannel',FetchAppText(conn,'$sitemap_synchronize_fc').Getshort,'images_apps/corebox_storage/sync_white.svg','',0,CheckAppRightModule(conn,'storage_sync'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Synchronize/iSCSI',FetchAppText(conn,'$sitemap_synchronize_iscsi').Getshort,'images_apps/corebox_storage/sync_white.svg','',0,CheckAppRightModule(conn,'storage_sync'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_DBCOREBOX_STORAGE_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_DBCOREBOX_STORAGE_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  _UpdateSitemap(session);
end;

function TFRE_DBCOREBOX_STORAGE_APP.CFG_ApplicationUsesRights: boolean;
begin
  result := true;
end;

function TFRE_DBCOREBOX_STORAGE_APP._ActualVersion: TFRE_DB_String;
begin
  Result := '1.0';
end;

class procedure TFRE_DBCOREBOX_STORAGE_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

function TFRE_DBCOREBOX_STORAGE_APP.IMI_RAW_DISK_FEED(const data: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := DelegateInvoke('STORAGE_POOLS','RAW_DISK_FEED',data);
end;


end.


end.

