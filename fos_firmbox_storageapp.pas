unit fos_firmbox_storageapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_ZFS,
  FRE_DB_INTERFACE,fos_stats_control_interface,FOS_VM_CONTROL_INTERFACE,
  fos_firmbox_vm_machines_mod, fre_scsi,fre_hal_disk_enclosure_pool_mangement, fre_hal_schemes,
  fos_firmbox_fileserver_mod,
  FRE_DB_COMMON;

var
    DISKI_HACK : IFOS_STATS_CONTROL;
    //VM_HACK    : IFOS_VM_HOST_CONTROL;

type

  { TFRE_FIRMBOX_STORAGE_APP }

  TFRE_FIRMBOX_STORAGE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure   ; override;
    procedure       _UpdateSitemap              (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize         (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion          (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme        (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain     (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    class procedure InstallDBObjects4SysDomain  (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    class procedure InstallUserDBObjects        (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;

  published
    function        WEB_DISK_DATA_FEED          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_STORAGE_POOLS_MOD }

  TFRE_FIRMBOX_STORAGE_POOLS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    procedure       _addDisksToPool                     (const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target:TFRE_DB_ZFS_OBJ; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
    procedure       _replaceDisks                       (const menu: TFRE_DB_MENU_DESC; const newId: String; const conn: IFRE_DB_CONNECTION);
    function        _getZFSObj                          (const conn: IFRE_DB_CONNECTION; const id: String): TFRE_DB_ZFS_OBJ;
    function        _getPoolByName                      (const conn: IFRE_DB_CONNECTION; const name: String): TFRE_DB_ZFS_ROOTOBJ;
    function        _getUnassignedPool                  (const conn: IFRE_DB_CONNECTION): TFRE_DB_ZFS_UNASSIGNED;
    procedure       _unassignDisk                       (const upool:TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
    function        _getNextVdevNum                     (const siblings: IFRE_DB_ObjectArray): Integer;
    procedure       _getMultiselectionActions           (const conn: IFRE_DB_CONNECTION; const selected :TFRE_DB_StringArray;var fnIdentifyOn,fnIdentifyOff,fnRemove,fnAssign,fnSwitchOffline,fnSwitchOnline,fnSwitchOfflineDisabled,fnSwitchOnlineDisabled:Boolean);
    procedure       _updateToolbars                     (const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession);
    procedure       _updateToolbarAssignAndReplaceEntry (const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION);
    function        _PoolObjContent                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
  public
    class procedure InstallDBObjects                    (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       MyServerInitializeModule            (const admin_dbc : IFRE_DB_CONNECTION); override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolObjNotes                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolObjNoContent                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolStructureSC                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LayoutSC                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBAssign                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBSwitchOnline                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBSwitchOffline                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBIdentifyOn                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBIdentifyOff                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBRemoveNew                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBChangeRaidLevel               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBDestroyPool                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBExportPool                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TBScrubPool                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TreeDrop                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridMenu                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreatePool                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreatePoolDiag                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ImportPoolDiag                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AssignSpareDisk                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AssignCacheDisk                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AssignLogDisk                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AssignStorageDisk               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RemoveNew                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ChangeRaidLevel                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DestroyPool                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DestroyPoolConfirmed            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ScrubPool                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExportPool                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_IdentifyOn                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_IdentifyOff                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SwitchOffline                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SwitchOnline                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SaveConfig                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResetConfig                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Replace                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

  end;

  { TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD }

  TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _GetFileServerID          (conn : IFRE_DB_CONNECTION): TFRE_DB_GUID;
    function        _getShareNames            (const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  public
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentFilerNFS          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentFilerLUN          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateNFSExport          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSAccessCreate          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSContent               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSMenu                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSDelete                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSDeleteConfirmed       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSAccessMenu            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSAccessDelete          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSAccessDeleteConfirmed (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NFSAccessModify          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateLUN                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateLUNView            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNMenu                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNContent               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNDelete                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNDeleteConfirmed       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNViewMenu              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNViewDelete            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNViewDeleteConfirmed   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LUNViewModify            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


  { TFRE_FIRMBOX_BACKUP_MOD }

  TFRE_FIRMBOX_BACKUP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure    ; override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentSnapshot        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SnapshotMenu           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteSnapshot         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteSnapshotConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD }

  TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure    ; override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_BACKUP_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORAGE_POOLS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORAGE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD }

class procedure TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('backup_scheduler_description')
end;

procedure TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitializeModule(session);
end;

function TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me');
end;

{ TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD }

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD._GetFileServerID(conn: IFRE_DB_CONNECTION): TFRE_DB_GUID;
var coll  : IFRE_DB_COLLECTION;
    id    : TFRE_DB_GUID;
    hlt   : boolean;

  procedure _get(const obj:IFRE_DB_Object ; var halt : boolean);
  begin
    if obj.IsA(TFRE_DB_GLOBAL_FILESERVER.ClassName) then begin
      id   := obj.UID;
      halt := true;
    end;
  end;

begin
  coll := conn.GetCollection('service');
  hlt  := false;
  coll.ForAllBreak(@_get,hlt);
  if not hlt then
    Result:=CFRE_DB_NullGUID;
    //raise EFRE_DB_Exception.Create(edb_ERROR,'GLOBAL FILESERVER ID NOT FOUND ????');
  result := id;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD._getShareNames(const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
var
  i     : NativeInt;
  share : IFRE_DB_Object;
begin
   result := '';
  for i := 0 to Length(shares) - 1 do begin
    conn.Fetch(FREDB_H2G(shares[i]),share);
    if i>0 then begin
      result := result +', ';
    end;
    result := result + share.Field('objname').AsString;
  end;
end;

class procedure TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('fileserver_global_description')
end;

procedure TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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
    fileserverid  : TFRE_DB_GUID;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,nfs_tr_Grid);
    with nfs_tr_Grid do begin
      AddOneToOnescheme('objname','export',app.FetchAppTextShort(session,'nfs_export'));
      AddOneToOnescheme('pool','pool',app.FetchAppTextShort(session,'nfs_pool'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'nfs_desc'));
      AddOneToOnescheme('refer_mb','refer',app.FetchAppTextShort(session,'nfs_refer'));
      AddOneToOnescheme('used_mb','used',app.FetchAppTextShort(session,'nfs_used'));
      AddOneToOnescheme('quota_mb','avail',app.FetchAppTextShort(session,'nfs_avail'));
    end;
    nfs_share_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
    with nfs_share_dc do begin
      SetDeriveParent(conn.GetCollection('fileshare'));
      fileserverId:= _GetFileserverID(conn);
      Filters.AddUIDFieldFilter('Fileserver','fileserver',TFRE_DB_GUIDArray.Create(fileserverId),dbnf_EXACT);
      filters.AddSchemeObjectFilter('SCH',[TFRE_DB_NFS_FILESHARE.ClassName]);
      SetDeriveTransformation(nfs_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,'',CWSF(@WEB_NFSMenu),nil,CWSF(@WEB_NFSContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,nfs_access_tr_Grid);
    with nfs_access_tr_Grid do begin
      AddOneToOnescheme('accesstype','accesstype',app.FetchAppTextShort(session,'nfs_accesstype'));
      AddOneToOnescheme('subnet','subnet',app.FetchAppTextShort(session,'nfs_accesssubnet'));
    end;
    nfs_access_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_ACCESS_GRID');
    with nfs_access_dc do begin
//      SetReferentialLinkMode(['TFRE_DB_NFS_ACCESS<FILESHARE']); change to reflink filter mode
//      SetDeriveParent(conn.Collection('fileshare_access'));
      SetDeriveTransformation(nfs_access_tr_Grid);
//      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_NFS_ACCESS.ClassName));
      SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'nfs_access'),nil,'',CWSF(@WEB_NFSAccessMenu),nil,nil,nil,nil);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,lun_tr_Grid);
    with lun_tr_Grid do begin
      AddOneToOnescheme('objname','LUN',app.FetchAppTextShort(session,'lun_guid'));
      AddOneToOnescheme('pool','pool',app.FetchAppTextShort(session,'lun_pool'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'lun_desc'));
      AddOneToOnescheme('size_mb','size',app.FetchAppTextShort(session,'lun_size'));
    end;
    lun_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
    with lun_dc do begin
      SetDeriveParent(conn.GetCollection('fileshare'));
      fileserverId:= _GetFileserverID(conn);
      Filters.AddUIDFieldFilter('Fileserver','fileserver',TFRE_DB_GUIDArray.Create(fileserverId),dbnf_EXACT);
      Filters.AddSchemeObjectFilter('SCH',[TFRE_DB_LUN.ClassName]);
      SetDeriveTransformation(lun_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_LUNMenu),nil,CWSF(@WEB_LUNContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,lun_view_tr_Grid);
    with lun_view_tr_Grid do begin
      AddOneToOnescheme('initiatorgroup','initiatorgroup',app.FetchAppTextShort(session,'lun_view_initiatorgroup'));
      AddOneToOnescheme('targetgroup','targetgroup',app.FetchAppTextShort(session,'lun_view_targetgroup'));
    end;
    lun_view_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_VIEW_GRID');
    with lun_view_dc do begin
      //SetReferentialLinkMode(['TFRE_DB_LUN_VIEW<FILESHARE']); change to reflink filter mode
//      SetDeriveParent(conn.Collection('fileshare_access'));
      SetDeriveTransformation(lun_view_tr_Grid);
//      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_LUN_VIEW.ClassName));
      SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'lun_view'),nil,'',CWSF(@WEB_LUNViewMenu),nil,nil,nil,nil);
    end;

  end;
end;


function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sub_sec_s     : TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  sub_sec_s        := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentFilerNFS),app.FetchAppTextShort(ses,'storage_global_filer_nfs'),1,'nfs');
  sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentFilerLUN),app.FetchAppTextShort(ses,'storage_global_filer_lun'),1,'lun');

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,sub_sec_s,nil,TFRE_DB_HTML_DESC.create.Describe('<b>'+app.FetchAppTextShort(ses,'global_info')+'</b>'));

end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_ContentFilerNFS(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  dc_share_nfs_access : IFRE_DB_DERIVED_COLLECTION;
  grid_nfs_access     : TFRE_DB_VIEW_LIST_DESC;
  txt                 : IFRE_DB_TEXT;
  nfs_rightside       : TFRE_DB_LAYOUT_DESC;
  nfs                 : TFRE_DB_LAYOUT_DESC;
  dc_share_nfs        : IFRE_DB_DERIVED_COLLECTION;
  grid_nfs            : TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  dc_share_nfs := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
  grid_nfs     := dc_share_nfs.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_NFS_FILESHARE) then begin
    txt:=app.FetchAppTextFull(ses,'tb_create_nfs_export');
    grid_nfs.AddButton.Describe(CWSF(@WEB_CreateNFSExport),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then begin
    txt:=app.FetchAppTextFull(ses,'tb_delete_nfs_export');
    grid_nfs.AddButton.Describe(CWSF(@WEB_NFSDelete),'',txt.Getshort,txt.GetHint,fdgbd_multi);
    txt.Finalize;
  end;

  dc_share_nfs_access := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_ACCESS_GRID');
  grid_nfs_access     := dc_share_nfs_access.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if  conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_NFS_ACCESS) then begin
    txt:=app.FetchAppTextFull(ses,'tb_create_nfs_access');
    grid_nfs_access.AddButton.Describe(CWSF(@WEB_NFSAccessCreate),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if  conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS) then begin
    txt:=app.FetchAppTextFull(ses,'tb_modify_nfs_access');
    grid_nfs_access.AddButton.Describe(CWSF(@WEB_NFSAccessModify),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;
  if  conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) then begin
    txt:=app.FetchAppTextFull(ses,'tb_delete_nfs_access');
    grid_nfs_access.AddButton.Describe(CWSF(@WEB_NFSAccessDelete),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;

  dc_share_nfs := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
  grid_nfs.AddFilterEvent(dc_share_nfs_access.getDescriptionStoreId(),'uids');

  nfs_rightside := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,WEB_NFSContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,grid_nfs_access,true,-1,2,-1,-1,1);
  nfs           := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_nfs,nfs_rightside,nil,nil,nil,true,2);
  Result        := nfs;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_ContentFilerLUN(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  dc_lun        : IFRE_DB_DERIVED_COLLECTION;
  grid_lun      : TFRE_DB_VIEW_LIST_DESC;
  txt           : IFRE_DB_TEXT;
  dc_lun_view   : IFRE_DB_DERIVED_COLLECTION;
  grid_lun_view : TFRE_DB_VIEW_LIST_DESC;
  lun_rightside : TFRE_DB_LAYOUT_DESC;
  lun           : TFRE_DB_LAYOUT_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_lun     := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
  grid_lun   := dc_lun.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_LUN) then begin
    txt:=app.FetchAppTextFull(ses,'tb_create_lun');
    grid_lun.AddButton.Describe(CWSF(@WEB_CreateLUN),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN) then begin
    txt:=app.FetchAppTextFull(ses,'tb_delete_lun');
    grid_lun.AddButton.Describe(CWSF(@WEB_LUNDelete),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;

  dc_lun_view   := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_VIEW_GRID');
  grid_lun_view := dc_lun_view.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_LUN_VIEW)  then begin
    txt:=app.FetchAppTextFull(ses,'tb_create_lun_view');
    grid_lun_view.AddButton.Describe(CWSF(@WEB_CreateLUNView),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW)  then begin
    txt:=app.FetchAppTextFull(ses,'tb_lunview_modify');
    grid_lun_view.AddButton.Describe(CWSF(@WEB_LUNViewModify),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN_VIEW)  then begin
    txt:=app.FetchAppTextFull(ses,'tb_lunview_delete');
    grid_lun_view.AddButton.Describe(CWSF(@WEB_LUNViewDelete),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;

  grid_lun.AddFilterEvent(dc_lun_view.getDescriptionStoreId(),'uids');

  lun_rightside := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,WEB_LUNContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,grid_lun_view,true,-1,2,-1,-1,1);

  lun        := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_lun,lun_rightside,nil,nil,nil,true,2);
  Result     := lun;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_CreateNFSExport(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_NFS_FILESHARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_NFS_FILESHARE,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'nfs_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('nfs'),ses,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('file'),ses,true,true);
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);

  //res.SetElementValue('pool','zones'); //FIXXME - get a pool
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
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessCreate(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_NFS_ACCESS) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_NFS_ACCESS,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'nfsaccess_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
//  res.SetElementValue('fileshare','');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare_access');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  nfs           : IFRE_DB_Object;
  sel_guid      : TFRE_DB_GUID;

begin
  if input.Field('SELECTED').ValueCount>0  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
    if dc.FetchInDerived(sel_guid,nfs) then begin
      GetSystemSchemeByName(nfs.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'nfs_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('nfs'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('file'),ses,true,true);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);
      panel.FillWithObjectValues(nfs,ses);
      panel.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),TFRE_DB_SERVER_FUNC_DESC.create.Describe(nfs,'saveOperation'),fdbbt_submit);
      panel.contentId := 'GLOBAL_NFS_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'nfs_content_header'));
    panel.contentId := 'GLOBAL_NFS_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  dtxt      : IFRE_DB_TEXT;
begin
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_NFSDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'cm_delete_nfs_export'),'',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_NFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'nfs_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppTextShort(ses,'nfs_delete_diag_msg'),'%share_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(FREDB_H2G(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  dtxt      : IFRE_DB_TEXT;
begin
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) or conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS) then
      begin
        func:=CWSF(@WEB_NFSAccessModify);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'cm_modify_nfs_access'),'',func);
      end;
    if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) then
      begin
        func:=CWSF(@WEB_NFSAccessDelete);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'cm_delete_nfs_access'),'',func);
      end;
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf : TFRE_DB_SERVER_FUNC_DESC;
  cap: TFRE_DB_String;
  msg: String;
  obj: IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS)
    then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_NFSAccessDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'nfs_access_delete_diag_cap');
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringItem[0]),obj),'TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessDelete');

  msg:=StringReplace(app.FetchAppTextShort(ses,'nfs_access_delete_diag_msg'),'%access_type%',obj.Field('accesstype').AsString,[rfReplaceAll]);
  msg:=StringReplace(msg,'%access_host%',obj.Field('subnet').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i: Integer;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(FREDB_H2G(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessModify(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
  obj        : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS)
    then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'error_modify_single_select'));

  GetSystemScheme(TFRE_DB_NFS_ACCESS,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'nfsaccess_modify_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),obj),'TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessModify');
  res.FillWithObjectValues(obj,ses);

  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'SaveOperation');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_CreateLUN(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_LUN)
    then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_LUN,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'lun_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('lun'),ses,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('volume'),ses,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);

  res.SetElementValue('pool','zones');
  res.SetElementValue('logbias','latency');
  res.SetElementValue('compression','on');
  res.SetElementValue('copies','1');
  res.SetElementValue('sync','standard');
  res.SetElementValue('recordsize_kb','128');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_CreateLUNView(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_LUN_VIEW)
    then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_LUN_VIEW,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'lunview_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
//  res.SetElementValue('fileshare','');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN_VIEW.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare_access');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_LUNDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'cm_delete_lun'),'',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  nfs           : IFRE_DB_Object;
  sel_guid      : TFRE_DB_GUID;

begin
  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
    if dc.FetchInDerived(sel_guid,nfs) then begin
      GetSystemSchemeByName(nfs.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'lun_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('lun'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('volume'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);
      panel.FillWithObjectValues(nfs,ses);
      panel.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),TFRE_DB_SERVER_FUNC_DESC.create.Describe(nfs,'saveOperation'),fdbbt_submit);
      panel.contentId:='GLOBAL_LUN_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'lun_content_header'));
    panel.contentId:='GLOBAL_LUN_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_LUNDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'lun_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppTextShort(ses,'lun_delete_diag_msg'),'%guid_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(FREDB_H2G(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) or conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW) then
      begin
        func:=CWSF(@WEB_LUNViewModify);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'cm_lunview_modify'),'',func);
      end;
    if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
      begin
        func:=CWSF(@WEB_LUNViewDelete);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'cm_lunview_delete'),'',func);
      end;
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap    : TFRE_DB_String;
  msg    : String;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_LUNViewDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'lunview_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppTextShort(ses,'lunview_delete_diag_msg'),'%guid_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i: Integer;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(FREDB_H2G(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewModify(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
  obj        : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'error_modify_single_select'));

  GetSystemScheme(TFRE_DB_LUN_VIEW,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'lunview_modify_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),obj),'TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewModify');
  res.FillWithObjectValues(obj,ses);

  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN_VIEW.ClassName,'SaveOperation');
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

{ TFRE_FIRMBOX_BACKUP_MOD }

class procedure TFRE_FIRMBOX_BACKUP_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_BACKUP_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('backup_description')
end;

procedure TFRE_FIRMBOX_BACKUP_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);

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
//      AddOneToOnescheme('parentid','parentid',app.FetchAppTextShort(ses,'backup_parent'));
      AddMatchingReferencedField('parentid','displayname','parent',app.FetchAppTextShort(session,'backup_share'));
      AddOneToOnescheme('creation','creation',app.FetchAppTextShort(session,'backup_creation'),dt_date);
      AddOneToOnescheme('used_mb','used',app.FetchAppTextShort(session,'backup_used'));
      AddOneToOnescheme('refer_mb','refer',app.FetchAppTextShort(session,'backup_refer'));
//      AddOneToOnescheme('objname','snapshot',app.FetchAppTextShort(ses,'backup_snapshot'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'backup_desc'));
    end;
    snap_dc := session.NewDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
    with snap_dc do begin
      SetDeriveParent(conn.GetCollection('snapshot'));
      SetDeriveTransformation(snap_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,'',CWSF(@WEB_SnapshotMenu),nil,CWSF(@WEB_ContentSnapshot));
    end;
  end;
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  snap          : TFRE_DB_LAYOUT_DESC;
  grid_snap     : TFRE_DB_VIEW_LIST_DESC;
  dc_snap       : IFRE_DB_DERIVED_COLLECTION;
  backup        : TFRE_DB_LAYOUT_DESC;
  sub_sec       : TFRE_DB_SUBSECTIONS_DESC;
  txt           : IFRE_DB_TEXT;

begin
  CheckClassVisibility4MyDomain(ses);

  sub_sec   := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);

  dc_snap       := ses.FetchDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
  grid_snap     := dc_snap.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

    if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_SNAPSHOT) then begin
    txt:=app.FetchAppTextFull(ses,'backup_snapshot_delete');
    grid_snap.AddButton.Describe(CWSF(@WEB_DeleteSnapshot),'',txt.Getshort,txt.GetHint,fdgbd_multi);
    txt.Finalize;
  end;

  sub_sec.AddSection.Describe(CWSF(@WEB_ContentSnapshot),app.FetchAppTextShort(ses,'backup_snapshot_properties'),1,'backup_properties');

  //    CSF(@WEB_ContentSnapshot)
  backup  := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_snap,sub_sec,nil,nil,nil,true,1,1);
  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,backup,nil,TFRE_DB_HTML_DESC.create.Describe('<b>'+app.FetchAppTextShort(ses,'backup_info')+'</b>'));
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_ContentSnapShot(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  snap          : IFRE_DB_Object;
  sel_guid      : TFRE_DB_GUID;

begin
  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
    if dc.FetchInDerived(sel_guid,snap) then begin
      GetSystemSchemeByName(snap.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'backup_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(snap,ses);
      panel.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),TFRE_DB_SERVER_FUNC_DESC.create.Describe(snap,'saveOperation'),fdbbt_submit);
      panel.contentId:='BACKUP_SNAP_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'backup_content_header'));
    panel.contentId:='BACKUP_SNAP_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_SnapshotMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_SNAPSHOT) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_DeleteSnapshot);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'backup_snapshot_delete'),'',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_DeleteSnapshot(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  obj       : IFRE_DB_Object;
  msg       : String;
  parentObj : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_SNAPSHOT) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_DeleteSnapshotConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringItem[0]),obj),'TFRE_FIRMBOX_BACKUP_MOD.WEB_DeleteSnapshot');
  CheckDbResult(conn.Fetch(obj.Field('parentId').AsGUID,parentObj),'TFRE_FIRMBOX_BACKUP_MOD.WEB_DeleteSnapshot');

  msg:=StringReplace(app.FetchAppTextShort(ses,'backup_snapshot_delete_diag_msg'),'%snapshot_str%',parentObj.Field('displayname').AsString + ' ('+obj.Field('creation').AsString+')',[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'backup_snapshot_delete_diag_cap'),msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_DeleteSnapshotConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i: Integer;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_SNAPSHOT) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(FREDB_H2G(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;


{ TFRE_FIRMBOX_STORAGE_POOLS_MOD }

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._addDisksToPool(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_OBJ; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
var
  count    : Integer;
  firstPool: IFRE_DB_Object;
  disk     : TFRE_DB_ZFS_OBJ;
  pools    : IFRE_DB_COLLECTION;
  sf       : TFRE_DB_SERVER_FUNC_DESC;
  hlt      : boolean;


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
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('expand','true');
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[storageRL]);
        case storageRL of
          zfs_rl_stripe: raid_str:=FetchModuleTextShort(session,'add_disks_rl_stripe');
          zfs_rl_mirror: raid_str:=FetchModuleTextShort(session,'add_disks_rl_mirror');
          zfs_rl_z1: raid_str:=FetchModuleTextShort(session,'add_disks_rl_z1');
          zfs_rl_z2: raid_str:=FetchModuleTextShort(session,'add_disks_rl_z2');
          zfs_rl_z3: raid_str:=FetchModuleTextShort(session,'add_disks_rl_z3');
        end;
        menu.AddEntry.Describe(StringReplace(FetchModuleTextShort(session,'add_disks_storage_ex_same'),'%raid_level%',raid_str,[rfReplaceAll]),'',sf);
      end;
      sub:=menu.AddMenu.Describe(FetchModuleTextShort(session,'add_disks_storage_ex_other'),'');
    end else begin
      sub:=menu.AddMenu.Describe(FetchModuleTextShort(session,'add_disks_storage'),'');
    end;
    if storageRL<>zfs_rl_stripe then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
      sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_stripe'),'',sf);
    end;
    if storageRL<>zfs_rl_mirror then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
      sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_mirror'),'',sf);
    end;
    if storageRL<>zfs_rl_z1 then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
      sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_z1'),'',sf);
    end;
    if storageRL<>zfs_rl_z2 then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
      sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_z2'),'',sf);
    end;
    if storageRL<>zfs_rl_z3 then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
      sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_z3'),'',sf);
    end;
    if Length(addStorage)>1 then begin
      sub:=menu.AddMenu.Describe(FetchModuleTextShort(session,'add_disks_storage'),'');
    end else begin
      sub:=menu;
    end;
    for i := 0 to Length(addStorage) - 1 do begin
      vdev:=addStorage[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
      if vdev.raidLevel=zfs_rl_undefined then begin
        subsub:=sub.AddMenu.Describe(StringReplace(FetchModuleTextShort(session,'add_disks_storage_to'),'%vdev%',vdev.caption,[rfReplaceAll]),'');
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
        subsub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_stripe'),'',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
        subsub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_mirror'),'',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
        subsub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_z1'),'',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
        subsub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_z2'),'',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
        subsub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_z3'),'',sf);
      end else begin
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sub.AddEntry.Describe(StringReplace(FetchModuleTextShort(session,'add_disks_storage_to'),'%vdev%',vdev.caption,[rfReplaceAll]),'',sf);
      end;
    end;
  end;

  procedure _addCacheMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ);
  var
    sf : TFRE_DB_SERVER_FUNC_DESC;
  begin
    sf:=CWSF(@WEB_AssignCacheDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    menu.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_cache'),'',sf);
  end;

  procedure _addLogMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const expandLog: Boolean; const addLog: IFRE_DB_ObjectArray);
  var
    i    : Integer;
    vdev : TFRE_DB_ZFS_VDEV;
    sub  : TFRE_DB_MENU_DESC;
    sf   : TFRE_DB_SERVER_FUNC_DESC;
  begin
    if expandLog then begin
      sub:=menu.AddMenu.Describe(FetchModuleTextShort(session,'add_disks_log_ex'),'');
    end else begin
      sub:=menu.AddMenu.Describe(FetchModuleTextShort(session,'add_disks_log'),'');
    end;
    sf:=CWSF(@WEB_AssignLogDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('expand','true');
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
    sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_stripe'),'',sf);
    sf:=CWSF(@WEB_AssignLogDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('expand','true');
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
    sub.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_rl_mirror'),'',sf);
    if Length(addLog)>1 then begin
      sub:=menu.AddMenu.Describe(FetchModuleTextShort(session,'add_disks_log'),'');
    end else begin
      sub:=menu;
    end;
    for i := 0 to Length(addLog) - 1 do begin
      vdev:=addLog[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
      sf:=CWSF(@WEB_AssignLogDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('add',vdev.getId);
      sub.AddEntry.Describe(StringReplace(FetchModuleTextShort(session,'add_disks_log_to'),'%vdev%',vdev.caption,[rfReplaceAll]),'',sf);
    end;
  end;

  procedure _addSpareMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ);
  var
    sf : TFRE_DB_SERVER_FUNC_DESC;
  begin
    sf:=CWSF(@WEB_AssignSpareDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    menu.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_spare'),'',sf);
  end;

  procedure _addVdevMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_VDEV);
  var
    parent : TFRE_DB_ZFS_OBJ;
    sf     : TFRE_DB_SERVER_FUNC_DESC;
  begin
    parent:=target.getZFSParent(conn);
    if parent.Implementor_HC is TFRE_DB_ZFS_LOG then begin
      sf:=CWSF(@WEB_AssignLogDisk);
    end else
    if parent.Implementor_HC is TFRE_DB_ZFS_DATASTORAGE then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
    end else begin
      raise EFRE_DB_Exception.Create(FetchModuleTextShort(session,'error_assign_vdev_unknown_parent_type'));
    end;
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('add',target.getId);
    menu.AddEntry.Describe(FetchModuleTextShort(session,'add_disks_vdev'),'',sf);
  end;

  procedure _addPoolMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_OBJ);
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
    children:=pool.getZFSChildren(conn);
    expandStorage:=false;
    expandLog:=false;
    storageRL:=zfs_rl_undefined;
    for i := 0 to length(children) - 1 do begin
      if children[i].Implementor_HC is TFRE_DB_ZFS_DATASTORAGE then begin
        storage:=children[i].Implementor_HC as TFRE_DB_ZFS_DATASTORAGE;
        storageChildren:=storage.getZFSChildren(conn);
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
              if vdev.acceptsNewZFSChildren(conn) then begin
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
        logChildren:=(children[i].Implementor_HC as TFRE_DB_ZFS_LOG).getZFSChildren(conn);
        for j := 0 to Length(logChildren) - 1 do begin
          expandLog:=true;
          if (logChildren[j].Implementor_HC is TFRE_DB_ZFS_VDEV) then begin
            if (logChildren[j].Implementor_HC as TFRE_DB_ZFS_VDEV).acceptsNewZFSChildren(conn) then begin
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
      if target.acceptsNewZFSChildren(conn) then begin
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

  procedure  _countPools(const obj: IFRE_DB_Object ; var halt : boolean);
  begin
    if obj.Implementor_HC is TFRE_DB_ZFS_POOL then
      begin
        count:=count+1;
        if count=1 then
          firstPool:=obj
        else
          halt := true;
      end;
  end;

  procedure _addPools(const obj: IFRE_DB_Object);
  var
    sub : TFRE_DB_MENU_DESC;
    pool: TFRE_DB_ZFS_POOL;
  begin
    if obj.Implementor_HC is TFRE_DB_ZFS_POOL then begin
      pool:=obj.Implementor_HC as TFRE_DB_ZFS_POOL;
      sub:=menu.AddMenu.Describe(StringReplace(FetchModuleTextShort(session,'add_disks_pool'),'%pool%',pool.caption,[rfReplaceAll]),'');
      _addPoolMenu(sub,pool,pool);
    end;
  end;

begin
  if Assigned(target) then begin
    if target.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED then begin
      _unassignDisk(target.Implementor_HC as TFRE_DB_ZFS_UNASSIGNED,disks,app,conn,session);
    end else begin
      if target.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
        disk:=_getZFSObj(conn,disks[0]);
        sf:=CWSF(@WEB_Replace);
        sf.AddParam.Describe('old',target.getId);
        sf.AddParam.Describe('new',disk.getId);
        menu.AddEntry.Describe(FetchModuleTextShort(session,'cm_replace'),'',sf,target.getZFSParent(conn).getId=disk.getZFSParent(conn).getId);
      end else begin
        _addPoolMenu(menu,pool,target as TFRE_DB_ZFS_OBJ);
      end;
    end;
  end else begin
    pools := conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
    count := 0;
    hlt   := false;
    pools.ForAllBreak(@_countPools,hlt);
    case count of
      0: ; //return empty menu
      1: begin
          _addPoolMenu(menu,firstPool.Implementor_HC as TFRE_DB_ZFS_POOL,firstPool.Implementor_HC as TFRE_DB_ZFS_POOL);
         end;
      else begin
        pools.ForAll(@_addPools);
      end;
    end;
  end;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._replaceDisks(const menu: TFRE_DB_MENU_DESC; const newId: String; const conn: IFRE_DB_CONNECTION);
var
  blockdevicecollection: IFRE_DB_COLLECTION;

  procedure _checkBD(const obj: IFRE_DB_Object);
  var
    bd : TFRE_DB_ZFS_BLOCKDEVICE;
    sf : TFRE_DB_SERVER_FUNC_DESC;
  begin
    if (obj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE) then begin
      bd:=obj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE;
      writeln('SWL: DUMP BD',bd.DumpToString());
      if (bd.getPool(conn).Implementor_HC is TFRE_DB_ZFS_POOL) then begin
        sf:=CWSF(@WEB_Replace);
        sf.AddParam.Describe('old',bd.getId);
        if newId<>'' then begin
          sf.AddParam.Describe('new',newId);
        end;
        menu.AddEntry.Describe(bd.caption,'',sf);
      end;
    end;
  end;

begin
  blockdevicecollection:=conn.GetCollection(CFRE_DB_ZFS_BLOCKDEVICE_COLLECTION);
  blockdevicecollection.ForAll(@_checkBD);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getZFSObj(const conn: IFRE_DB_CONNECTION; const id: String): TFRE_DB_ZFS_OBJ;
var
  dbObj: IFRE_DB_Object;
begin
  conn.Fetch(FREDB_H2G(id),dbObj);
  Result:=dbObj.Implementor_HC as TFRE_DB_ZFS_OBJ;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getPoolByName(const conn: IFRE_DB_CONNECTION; const name: String): TFRE_DB_ZFS_ROOTOBJ;
var
  pools : IFRE_DB_COLLECTION;
  pool  : TFRE_DB_ZFS_ROOTOBJ;
  hlt   : boolean;

  procedure _checkPool(const obj: IFRE_DB_Object ; var halt : boolean);
  begin
    if lowercase((obj.Implementor_HC as TFRE_DB_ZFS_ROOTOBJ).getPoolName)=LowerCase(name) then begin
      halt:=true;
      pool:=obj.Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
    end;
  end;

begin
  pool  := nil;
  pools := conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  hlt   := false;
  pools.ForAllBreak(@_checkPool,hlt);
  Result:=pool;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getUnassignedPool(const conn: IFRE_DB_CONNECTION): TFRE_DB_ZFS_UNASSIGNED;
var
  pools : IFRE_DB_COLLECTION;
  ua    : TFRE_DB_ZFS_UNASSIGNED;
  hlt   : boolean;

  procedure _checkPool(const obj: IFRE_DB_Object ; var halt : boolean);
  begin
    if obj.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED then
      begin
        halt := true;
        ua:=obj.Implementor_HC as TFRE_DB_ZFS_UNASSIGNED;
      end;
  end;

begin
  ua:=nil;
  pools := conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  hlt   := false;
  pools.ForAllBreak(@_checkPool,hlt);
  Result:=ua;
end;

class procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('pools_description')
end;

class procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId:='1.0';

    CreateModuleText(conn,'pools_grid_caption','Caption');
    CreateModuleText(conn,'pools_grid_iops_r','IOPS R [1/s]');
    CreateModuleText(conn,'pools_grid_iops_w','IOPS W [1/s]');
    CreateModuleText(conn,'pools_grid_transfer_r','Read [MB/s]');
    CreateModuleText(conn,'pools_grid_transfer_w','Write [MB/s]');
    CreateModuleText(conn,'layout_grid_caption','Caption');

    CreateModuleText(conn,'tb_create_pool','Create Pool');
    CreateModuleText(conn,'create_pool_diag_cap','Create Pool');
    CreateModuleText(conn,'create_pool_diag_name','Name');
    CreateModuleText(conn,'create_pool_error_cap','Error creating a new pool');
    CreateModuleText(conn,'create_pool_error_not_unique','The name of the pool has to be unique. Please choose another one.');
    CreateModuleText(conn,'tb_import_pool','Import Pool');
    CreateModuleText(conn,'import_pool_diag_cap','Import Pool');
    CreateModuleText(conn,'import_pool_diag_msg','Feature disabled in Demo Mode.');
    CreateModuleText(conn,'tb_export_pool','Export Pool');
    CreateModuleText(conn,'tb_scrub_pool','Scrub Pool');
    CreateModuleText(conn,'tb_save_config','Save');
    CreateModuleText(conn,'tb_reset_config','Reset');
    CreateModuleText(conn,'tb_pools','Pool');
    CreateModuleText(conn,'tb_blockdevices','Disk');
    CreateModuleText(conn,'tb_switch_offline','Switch offline');
    CreateModuleText(conn,'tb_switch_online','Switch online');
    CreateModuleText(conn,'tb_identify_on','Identify on');
    CreateModuleText(conn,'tb_identify_off','Identify off');
    CreateModuleText(conn,'tb_assign','Assign');
    CreateModuleText(conn,'tb_replace','Replace');
    CreateModuleText(conn,'tb_remove','Remove');
    CreateModuleText(conn,'tb_change_rl','Change RL');
    CreateModuleText(conn,'tb_rl_mirror','Mirror');
    CreateModuleText(conn,'tb_rl_z1','Raid-Z1');
    CreateModuleText(conn,'tb_rl_z2','Raid-Z2');
    CreateModuleText(conn,'tb_rl_z3','Raid-Z3');
    CreateModuleText(conn,'tb_destroy_pool','Destroy');
    CreateModuleText(conn,'new_spare_caption','spare');
    CreateModuleText(conn,'new_log_caption','log');
    CreateModuleText(conn,'log_vdev_caption_rl_mirror','mirror-%num%');
    CreateModuleText(conn,'new_cache_caption','cache');
    CreateModuleText(conn,'storage_vdev_caption_rl_mirror','mirror-%num%');
    CreateModuleText(conn,'storage_vdev_caption_rl_z1','raidz1-%num%');
    CreateModuleText(conn,'storage_vdev_caption_rl_z2','raidz2-%num%');
    CreateModuleText(conn,'storage_vdev_caption_rl_z3','raidz3-%num%');
    CreateModuleText(conn,'error_assign_not_new','You can only assign disks which are not in use yet.');
    CreateModuleText(conn,'error_unassign_not_new','You can only unassign disks which are not in use yet.');
    CreateModuleText(conn,'error_assign_vdev_not_found','Assign disks: Vdev not found.');
    CreateModuleText(conn,'error_assign_vdev_unknown_parent_type','Parent of Vdev does not support disk drops.');
    CreateModuleText(conn,'error_remove_not_new','You can only remove zfs elements which are not in use yet.');
    CreateModuleText(conn,'error_change_rl_not_new','You can only change the raid level of a vdev which is not in use yet.');

    CreateModuleText(conn,'add_disks_pool','Assign to %pool%...');
    CreateModuleText(conn,'add_disks_storage_ex_same','Expand storage (%raid_level%)');
    CreateModuleText(conn,'add_disks_storage_ex_other','Expand storage...');
    CreateModuleText(conn,'add_disks_storage','Add as storage...');
    CreateModuleText(conn,'add_disks_storage_to','Add as storage to "%vdev%"');
    CreateModuleText(conn,'add_disks_vdev','Add to vdev');
    CreateModuleText(conn,'add_disks_cache','Add as read cache (L2ARC)');
    CreateModuleText(conn,'add_disks_log','Add as write cache (ZIL)...');
    CreateModuleText(conn,'add_disks_log_to','Add as write cache (ZIL) to "%vdev%"');
    CreateModuleText(conn,'add_disks_log_ex','Expand write cache (ZIL)...');
    CreateModuleText(conn,'add_disks_spare','Add as spare');
    CreateModuleText(conn,'add_disks_rl_mirror','Mirror');
    CreateModuleText(conn,'add_disks_rl_stripe','Stripe');
    CreateModuleText(conn,'add_disks_rl_z1','Raid-Z1');
    CreateModuleText(conn,'add_disks_rl_z2','Raid-Z2');
    CreateModuleText(conn,'add_disks_rl_z3','Raid-Z3');

    CreateModuleText(conn,'confirm_destroy_caption','Destroy pool');
    CreateModuleText(conn,'confirm_destroy_msg','This operation is irreversible! Destroy pool %pool% anyway?');

    CreateModuleText(conn,'cm_replace','Replace');
    CreateModuleText(conn,'cm_switch_offline','Switch offline');
    CreateModuleText(conn,'cm_switch_online','Switch online');
    CreateModuleText(conn,'cm_identify_on','Identify ON');
    CreateModuleText(conn,'cm_identify_off','Identify OFF');
    CreateModuleText(conn,'cm_multiple_remove','Remove %num% items');
    CreateModuleText(conn,'cm_remove','Remove item');
    CreateModuleText(conn,'cm_change_raid_level','Change raid level...');
    CreateModuleText(conn,'cm_rl_mirror','Mirror');
    CreateModuleText(conn,'cm_rl_z1','Raid-Z1');
    CreateModuleText(conn,'cm_rl_z2','Raid-Z2');
    CreateModuleText(conn,'cm_rl_z3','Raid-Z3');
    CreateModuleText(conn,'cm_destroy_pool','Destroy pool %pool%');
    CreateModuleText(conn,'cm_export_pool','Export pool %pool%');
    CreateModuleText(conn,'cm_scrub_pool','Scrub pool %pool%');

    CreateModuleText(conn,'poolobj_content_tab','Details');
    CreateModuleText(conn,'poolobj_notes_tab','Notes');
    CreateModuleText(conn,'poolobj_no_content_tab','General');
    CreateModuleText(conn,'poolobj_no_content_content','Please select exactly one pool object to get detailed information.');
  end;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  conn       : IFRE_DB_CONNECTION;
  tr_Grid    : IFRE_DB_SIMPLE_TRANSFORM;
  pools_grid : IFRE_DB_DERIVED_COLLECTION;
  layout_grid: IFRE_DB_DERIVED_COLLECTION;


begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);

    with tr_Grid do begin
      AddMultiToOnescheme(TFRE_DB_NameTypeArray.Create('caption','displayname'),'caption',FetchModuleTextShort(session,'pools_grid_caption'),dt_string,true,false,false,2,'icon');
      AddOneToOnescheme('icon','','',dt_string,false,false,false,1,'','',FREDB_getThemedResource('images_apps/firmbox_storage/Undefined.png'));
      AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_READ_OPS','iops_r',FetchModuleTextShort(session,'pools_grid_iops_r'));
      AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_WRITE_OPS','iops_w',FetchModuleTextShort(session,'pools_grid_iops_w'));
      AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_READ_BYTES','transfer_r',FetchModuleTextShort(session,'pools_grid_transfer_r'));
      AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_WRITE_BYTES','transfer_w',FetchModuleTextShort(session,'pools_grid_transfer_w'));
      AddOneToOnescheme('_disabledrag_','','',dt_string,false);
      AddOneToOnescheme('_disabledrop_','','',dt_string,false);
      AddOneToOnescheme('dndclass','','',dt_string,false);
    end;

    pools_grid := session.NewDerivedCollection('POOL_DISKS');
    with pools_grid do begin
      SetDeriveParent           (conn.GetCollection(cFRE_DB_MACHINE_COLLECTION));
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_Multiselect],'',nil,'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_PoolStructureSC),nil,CWSF(@WEB_TreeDrop));
      SetParentToChildLinkField ('<PARENT_IN_ZFS_UID');

      SetDeriveTransformation   (tr_Grid);
      SetDefaultOrderField      ('caption',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);

    with tr_Grid do begin
      AddMultiToOnescheme(TFRE_DB_NameTypeArray.Create('caption_layout','caption','displayname'),'caption_layout',FetchModuleTextShort(session,'pools_grid_caption'),dt_string,true,false,false,1,'icon_layout');
      AddMultiToOnescheme(TFRE_DB_NameTypeArray.Create('icon_layout','icon'),'icon_layout','',dt_string,false,false,false,1,'','',FREDB_getThemedResource('images_apps/firmbox_storage/Undefined.png'));
      AddOneToOnescheme('_disabledrag_','','',dt_string,false);
      AddOneToOnescheme('_disabledrop_','','',dt_string,false);
      AddOneToOnescheme('dndclass','','',dt_string,false);
    end;

    layout_grid := session.NewDerivedCollection('ENCLOSURE_DISKS');
    with layout_grid do begin
      SetDeriveParent           (conn.GetCollection(cFRE_DB_MACHINE_COLLECTION));
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_Multiselect],'',nil,'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_LayoutSC),nil,CWSF(@WEB_TreeDrop));
      SetParentToChildLinkField ('<PARENT_IN_ENCLOSURE_UID');

      SetDeriveTransformation   (tr_Grid);
      SetDefaultOrderField      ('caption_layout',true);
    end;
  end;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
var
  pool_disks    : IFRE_DB_COLLECTION;
  pool_capacity : IFRE_DB_COLLECTION;



begin
  inherited MyServerInitializeModule(admin_dbc);

  //STARTUP SPEED_ENHANCEMENT
  //DISKI_HACK := Get_Stats_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  //VM_HACK    := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);

  pool_disks := admin_dbc.CreateCollection('POOL_DISKS',true);
  pool_disks.DefineIndexOnField('diskid',fdbft_String,true,true);

  //// Used to fix display in startup case, when no feeder has made initial data
//  UpdateDiskCollection(pool_disks,DISKI_HACK.Get_Disk_Data_Once);

end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool_grid  : TFRE_DB_VIEW_LIST_DESC;
  layout_grid: TFRE_DB_VIEW_LIST_DESC;
  coll       : IFRE_DB_DERIVED_COLLECTION;
  menu       : TFRE_DB_MENU_DESC;
  submenu    : TFRE_DB_SUBMENU_DESC;
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  subsubmenu : TFRE_DB_SUBMENU_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedZfsObjs');

  pool_grid:=ses.FetchDerivedCollection('POOL_DISKS').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  layout_grid:=ses.FetchDerivedCollection('ENCLOSURE_DISKS').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then begin
    pool_grid.SetDragClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    layout_grid.SetDragClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    pool_grid.SetDropGrid(pool_grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    layout_grid.SetDropGrid(pool_grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));

    menu:=TFRE_DB_MENU_DESC.create.Describe;
    menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_save_config'),'',CWSF(@WEB_SaveConfig),false,'pool_save');
    menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_reset_config'),'',CWSF(@WEB_ResetConfig),true,'pool_reset');

    submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_pools'),'');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_create_pool'),'',CWSF(@WEB_CreatePoolDiag));
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_import_pool'),'',CWSF(@WEB_ImportPoolDiag));
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_export_pool'),'',CWSF(@WEB_TBExportPool),true,'pool_export');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_scrub_pool'),'',CWSF(@WEB_TBScrubPool),true,'pool_scrub');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_destroy_pool'),'',CWSF(@WEB_TBDestroyPool),true,'pool_destroy');

    submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_blockdevices'),'');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_identify_on'),'',CWSF(@WEB_TBIdentifyOn),true,'pool_iden_on');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_identify_off'),'',CWSF(@WEB_TBIdentifyOff),true,'pool_iden_off');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_switch_online'),'',CWSF(@WEB_TBSwitchOnline),true,'pool_switch_online');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_switch_offline'),'',CWSF(@WEB_TBSwitchOffline),true,'pool_switch_offline');

    subsubmenu:=submenu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_assign'),'',true,'pool_assign');
    _addDisksToPool(subsubmenu,nil,nil,nil,app,conn,ses);

    subsubmenu:=submenu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_replace'),'',true,'pool_replace');
    _replaceDisks(subsubmenu,'',conn);

    submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_change_rl'),'');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_rl_mirror'),'',sf,true,'pool_rl_mirror');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_rl_z1'),'',sf,true,'pool_rl_z1');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_rl_z2'),'',sf,true,'pool_rl_z2');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_rl_z3'),'',sf,true,'pool_rl_z3');

    menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_remove'),'',CWSF(@WEB_TBRemoveNew),true,'pool_remove');

    pool_grid.SetMenu(menu);

    menu:=TFRE_DB_MENU_DESC.create.Describe;

    submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_blockdevices'),'');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_identify_on'),'',CWSF(@WEB_TBIdentifyOn),true,'layout_iden_on');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_identify_off'),'',CWSF(@WEB_TBIdentifyOff),true,'layout_iden_off');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_switch_online'),'',CWSF(@WEB_TBSwitchOnline),true,'layout_switch_online');
    submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_switch_offline'),'',CWSF(@WEB_TBSwitchOffline),true,'layout_switch_offline');

    subsubmenu:=submenu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_assign'),'',true,'layout_assign');
    _addDisksToPool(subsubmenu,nil,nil,nil,app,conn,ses);

    subsubmenu:=submenu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_replace'),'',true,'layout_replace');
    _replaceDisks(subsubmenu,'',conn);

    layout_grid.SetMenu(menu);
  end;

  Result:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(layout_grid,pool_grid,_PoolObjContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,true,1,3,3);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_PoolObjNoContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'poolobj_no_content_content'));
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_PoolStructureSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedZfsObjs')
  end;

  _updateToolbars(conn,ses);
  if ses.isUpdatableContentVisible('pool_obj_content') then begin
    Result:=_PoolObjContent(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_LayoutSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedLayoutObjs').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedLayoutObjs')
  end;

  _updateToolbars(conn,ses);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBAssign(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
  //FIXXME implement me
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBSwitchOnline(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_SwitchOnline(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBSwitchOffline(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_SwitchOffline(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBIdentifyOn(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_IdentifyOn(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBIdentifyOff(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_IdentifyOff(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBRemoveNew(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_RemoveNew(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBChangeRaidLevel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_ChangeRaidLevel(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBDestroyPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_DestroyPool(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBExportPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('pool').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsString;
  Result:=WEB_ExportPool(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBScrubPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('pool').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsString;
  Result:=WEB_ScrubPool(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TreeDrop(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  dbobj      : IFRE_DB_Object;
  disk       : TFRE_DB_ZFS_OBJ;
  target     : TFRE_DB_ZFS_OBJ;
  tpool      : TFRE_DB_ZFS_ROOTOBJ;
  res        : TFRE_DB_MENU_DESC;

  storeup    : TFRE_DB_UPDATE_STORE_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

//  GFRE_BT.SeperateString(input.Field('selected').AsString,',',sIdPath);

//  pools.Fetch(FREDB_H2G(sIdPath[0]),dbObj);
//  spool:=dbobj.Implementor_HC as TFRE_DB_ZFS_POOL;
//  disk:=spool.getPoolItem(TFRE_DB_StringArray(sIdPath));

  target:=_getZFSObj(conn,input.Field('target').AsString).Implementor_HC as TFRE_DB_ZFS_OBJ;
  tpool :=target.getPool(conn);

  res:=TFRE_DB_MENU_DESC.create.Describe;
  _AddDisksToPool(res,tpool,target,input.Field('selected').AsStringArr,app,conn,ses);
  Result:=res;

//  storeup:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store');
//  storeup.addDeletedEntry(disk.getId);
//  session.SendServerClientRequest(storeup);
//  Result:=GFRE_DB_NIL_DESC;

  //Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DROP','Drop: '+disk.DumpToString()+ ' into ' + target.DumpToString(),fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_GridMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res,sub: TFRE_DB_MENU_DESC;
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  zfsObj : TFRE_DB_ZFS_OBJ;
  i      : Integer;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  rl     : TFRE_DB_ZFS_RAID_LEVEL;
  fnIdentifyOn,fnIdentifyOff, fnRemove, fnAssign, fnSwitchOffline, fnSwitchOnline: Boolean;
  fnSwitchOfflineDisabled, fnSwitchOnlineDisabled: Boolean;
  dbObj: IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then begin
    if input.Field('selected').ValueCount>1 then begin //multiselection
      _getMultiselectionActions(conn,input.Field('selected').AsStringArr,fnIdentifyOn,fnIdentifyOff,fnRemove,fnAssign,fnSwitchOffline,fnSwitchOnline,fnSwitchOfflineDisabled,fnSwitchOnlineDisabled);
      if fnAssign then begin;
        _addDisksToPool(res,nil,nil,input.Field('selected').AsStringArr,app,conn,ses);
      end;
      if fnRemove then begin
        sf:=CWSF(@WEB_RemoveNew);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(StringReplace(FetchModuleTextShort(ses,'cm_multiple_remove'),'%num%',IntToStr(input.field('selected').ValueCount),[rfReplaceAll]),'',sf);
      end;
      if fnIdentifyOn then begin
        sf:=CWSF(@WEB_IdentifyOn);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_identify_on'),'',sf);
      end;
      if fnIdentifyOff then begin
        sf:=CWSF(@WEB_IdentifyOff);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_identify_off'),'',sf);
      end;
      if fnSwitchOffline then begin
        sf:=CWSF(@WEB_SwitchOffline);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_switch_offline'),'',sf,fnSwitchOfflineDisabled);
      end;
      if fnSwitchOnline then begin
        sf:=CWSF(@WEB_SwitchOnline);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_switch_online'),'',sf,fnSwitchOnlineDisabled);
      end;
      Result:=res;
    end else begin //single selection
      conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbObj);
      if dbObj.Implementor_HC is TFRE_DB_ZFS_OBJ then begin
        zfsObj:=dbObj.Implementor_HC as TFRE_DB_ZFS_OBJ;
        pool:=zfsObj.getPool(conn);
        if (pool is TFRE_DB_ZFS_UNASSIGNED) and (zfsObj is TFRE_DB_ZFS_BLOCKDEVICE) then begin
          _addDisksToPool(res,nil,nil,input.Field('selected').AsStringArr,app,conn,ses);
          sub:=res.AddMenu.Describe(FetchModuleTextShort(ses,'cm_replace'),'');
          _replaceDisks(sub,input.Field('selected').AsString,conn);
        end else begin
          if (zfsObj is TFRE_DB_ZFS_BLOCKDEVICE) and not zfsObj.getIsNew then begin
            if (zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline then begin
              sf:=CWSF(@WEB_SwitchOnline);
              sf.AddParam.Describe('selected',input.Field('selected').AsString);
              res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_switch_online'),'',sf);
            end else begin
              sf:=CWSF(@WEB_SwitchOffline);
              sf.AddParam.Describe('selected',input.Field('selected').AsString);
              res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_switch_offline'),'',sf);
            end;
          end;
        end;
        if zfsObj.getisNew then begin
          sf:=CWSF(@WEB_RemoveNew);
          sf.AddParam.Describe('selected',input.Field('selected').AsString);
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_remove'),'',sf);
          if (zfsObj is TFRE_DB_ZFS_VDEV) and (zfsObj.getZFSParent(conn).Implementor_HC is TFRE_DB_ZFS_DATASTORAGE) then begin
            sub:=res.AddMenu.Describe(FetchModuleTextShort(ses,'cm_change_raid_level'),'');
            rl:=(zfsObj as TFRE_DB_ZFS_VDEV).raidLevel;
            if rl<>zfs_rl_mirror then begin
              sf:=CWSF(@WEB_ChangeRaidLevel);
              sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
              sf.AddParam.Describe('selected',input.Field('selected').AsString);
              sub.AddEntry.Describe(FetchModuleTextShort(ses,'cm_rl_mirror'),'',sf);
            end;
            if rl<>zfs_rl_z1 then begin
              sf:=CWSF(@WEB_ChangeRaidLevel);
              sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
              sf.AddParam.Describe('selected',input.Field('selected').AsString);
              sub.AddEntry.Describe(FetchModuleTextShort(ses,'cm_rl_z1'),'',sf);
            end;
            if rl<>zfs_rl_z2 then begin
              sf:=CWSF(@WEB_ChangeRaidLevel);
              sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
              sf.AddParam.Describe('selected',input.Field('selected').AsString);
              sub.AddEntry.Describe(FetchModuleTextShort(ses,'cm_rl_z2'),'',sf);
            end;
            if rl<>zfs_rl_z3 then begin
              sf:=CWSF(@WEB_ChangeRaidLevel);
              sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
              sf.AddParam.Describe('selected',input.Field('selected').AsString);
              sub.AddEntry.Describe(FetchModuleTextShort(ses,'cm_rl_z3'),'',sf);
            end;
          end;
        end else begin
          if zfsObj is TFRE_DB_ZFS_POOL then begin
            sf:=CWSF(@WEB_ScrubPool);
            sf.AddParam.Describe('pool',input.Field('selected').AsString);
            res.AddEntry.Describe(StringReplace(FetchModuleTextShort(ses,'cm_scrub_pool'),'%pool%',zfsObj.caption,[rfReplaceAll]),'',sf,zfsObj.getIsModified);
            sf:=CWSF(@WEB_ExportPool);
            sf.AddParam.Describe('pool',input.Field('selected').AsString);
            res.AddEntry.Describe(StringReplace(FetchModuleTextShort(ses,'cm_export_pool'),'%pool%',zfsObj.caption,[rfReplaceAll]),'',sf,zfsObj.getIsModified);
            sf:=CWSF(@WEB_DestroyPool);
            sf.AddParam.Describe('pool',input.Field('selected').AsString);
            res.AddEntry.Describe(StringReplace(FetchModuleTextShort(ses,'cm_destroy_pool'),'%pool%',zfsObj.caption,[rfReplaceAll]),'',sf,zfsObj.getIsModified);
          end;
        end;
        if zfsObj.canIdentify then begin
          sf:=CWSF(@WEB_IdentifyOn);
          sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_identify_on'),'',sf);
          sf:=CWSF(@WEB_IdentifyOff);
          sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_identify_off'),'',sf);
        end;
      end;
    end;
    Result:=res;
  end;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_CreatePool(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pools   : IFRE_DB_COLLECTION;
  vdevs   : IFRE_DB_COLLECTION;
  nameOk  : Boolean;
  lastObj : IFRE_DB_Object;
  newPool : TFRE_DB_ZFS_POOL;
  dstore  : TFRE_DB_ZFS_DATASTORAGE;
  muid    : TFRE_DB_GUID;

  procedure _checkPoolName(const obj:IFRE_DB_Object);
  begin
    if LowerCase(input.FieldPath('data.pool_name').AsString)=LowerCase(obj.Field('objname').AsString) then begin
      nameOk:=false;
    end;
    if (obj.Implementor_HC is TFRE_DB_ZFS_POOL) and not (obj.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then begin
      lastObj:=obj;
    end;
  end;

begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldPathExists('data.pool_name') then
    raise EFRE_DB_Exception.Create('WEB_CreatePool: Missing parameter pool_name');

  pools := conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  vdevs := conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);
  nameOk:=true;
  lastObj:=nil;
  pools.ForAll(@_checkPoolName);
  if not nameOk then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'create_pool_error_cap'),FetchModuleTextShort(ses,'create_pool_error_not_unique'),fdbmt_error);
    exit;
  end;

  newPool:=TFRE_DB_ZFS_POOL.CreateForDB;
  newPool.SetName(input.FieldPath('data.pool_name').AsString);

  //TODO: Select Machine depended on selection
  if conn.GetCollection(cFRE_DB_MACHINE_COLLECTION).GetIndexedUID('firmbox',muid,'def') then
    begin
      newpool.parentInZFSId := muid;
      newpool.MachineID := muid;
    end
  else
    raise EFRE_DB_Exception.Create('WEB_CreatePool: No Machine for new pool found');

  newPool.setIsNew;

  dstore:=newPool.createDatastorage;
  dstore.SetName(input.FieldPath('data.pool_name').AsString);
  dstore.setIsNew;

  CheckDbResult(pools.Store(newPool),'Add new pool');
  CheckDbResult(vdevs.Store(dstore),'Add new pool');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_CreatePoolDiag(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res  :TFRE_DB_FORM_DIALOG_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'create_pool_diag_cap'));
  res.AddInput.Describe(FetchModuleTextShort(ses,'create_pool_diag_name'),'pool_name',true);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CWSF(@WEB_CreatePool),fdbbt_submit);
  result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ImportPoolDiag(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'import_pool_diag_cap'),FetchModuleTextShort(ses,'import_pool_diag_msg'),fdbmt_info,nil);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_AssignSpareDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tspare  : TFRE_DB_ZFS_SPARE;
  i       : Integer;
  disk    : TFRE_DB_ZFS_OBJ;
  vdevs   : IFRE_DB_COLLECTION;

begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  tpool:=_getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  tspare:=tpool.GetSpare(conn);
  if Assigned(tspare) then begin
    tspare.setIsModified;
    CheckDbResult(conn.Update(tspare.CloneToNewObject()),'Assign spare');
  end else begin
    tspare:=tpool.createSpare;
    tspare.setIsNew;
    tspare.SetName(FetchModuleTextShort(ses,'new_spare_caption'));
    vdevs:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);
    CheckDbResult(vdevs.Store(tspare.CloneToNewObject()),'Assign spare');
  end;
  tpool.setIsModified;
  CheckDbResult(conn.Update(tpool),'Assign spare');
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    disk:=_getZFSObj(conn,input.Field('disks').AsStringArr[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_assign_not_new'));
    disk.removeFromPool;
    disk:=tspare.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    CheckDbResult(conn.Update(disk),'Assign spare');
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_AssignCacheDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tcache  : TFRE_DB_ZFS_CACHE;
  i       : Integer;
  disk    : TFRE_DB_ZFS_OBJ;
  vdevs   : IFRE_DB_COLLECTION;

begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  tpool:=_getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  tcache:=tpool.GetCache(conn);
  if Assigned(tcache) then begin
    tcache.setIsModified;
    CheckDbResult(conn.Update(tcache.CloneToNewObject()),'Assign cache');
  end else begin
    tcache:=tpool.createCache;
    tcache.setIsNew;
    tcache.SetName(FetchModuleTextShort(ses,'new_cache_caption'));
    vdevs:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);
    CheckDbResult(vdevs.Store(tcache.CloneToNewObject()),'Assign cache');
  end;
  tpool.setIsModified;
  CheckDbResult(conn.Update(tpool),'Assign spare');
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    disk:=_getZFSObj(conn,input.Field('disks').AsStringItem[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_assign_not_new'));
    disk:=tcache.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    CheckDbResult(conn.Update(disk),'Assign cache');
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_AssignLogDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tlog    : TFRE_DB_ZFS_LOG;
  vdev    : TFRE_DB_ZFS_DISKCONTAINER;
  i       : Integer;
  disk    : TFRE_DB_ZFS_OBJ;
  children: IFRE_DB_ObjectArray;
  vdevs   : IFRE_DB_COLLECTION;

begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  vdevs:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);

  tpool:=_getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  tlog:=tpool.GetLog(conn);
  if Assigned(tlog) then begin
    tlog.setIsModified;
    CheckDbResult(conn.Update(tlog.CloneToNewObject),'Assign log');
    if input.FieldExists('expand') and input.Field('expand').AsBoolean then begin
      if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
        vdev:=tlog;
      end else begin
        vdev:=tlog.createVdev;
        vdev.setname(StringReplace(FetchModuleTextShort(ses,'log_vdev_caption_'+input.Field('rl').AsString),'%num%',IntToStr(_getNextVdevNum(tlog.getZFSChildren(conn))),[rfReplaceAll]));
        vdev.setIsNew;
        vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
        CheckDbResult(vdevs.Store(vdev.CloneToNewObject()),'Assign log');
      end;
    end else begin
      children:=tlog.getZFSChildren(conn);
      vdev:=nil;
      for i := 0 to Length(children) - 1 do begin
        if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and ((children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).getId=input.Field('add').AsString) then begin
          vdev:=children[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
        end;
      end;
      if not Assigned(vdev) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_assign_vdev_not_found'));
      vdev.setIsModified;
      CheckDbResult(conn.Update(vdev.CloneToNewObject),'Assign log');
    end;
  end else begin
    tlog:=tpool.createLog;
    tlog.setIsNew;
    tlog.setName(FetchModuleTextShort(ses,'new_log_caption'));
    CheckDbResult(vdevs.Store(tlog.CloneToNewObject()),'Assign log');
    if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
      vdev:=tlog;
    end else begin
      vdev:=tlog.createVdev;
      vdev.setIsNew;
      vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
      vdev.SetName(StringReplace(FetchModuleTextShort(ses,'log_vdev_caption_'+input.Field('rl').AsString),'%num%','0',[rfReplaceAll]));
      CheckDbResult(vdevs.Store(vdev.CloneToNewObject()),'Assign log');
    end;
  end;
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    disk:=_getZFSObj(conn,input.Field('disks').AsStringItem[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_assign_not_new'));
    disk.removeFromPool;
    disk:=vdev.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    CheckDbResult(conn.Update(disk),'Assign log');
  end;
  tpool.setIsModified;
  CheckDbResult(conn.Update(tpool),'Assign log');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_AssignStorageDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  tpool      : TFRE_DB_ZFS_POOL;
  spool      : TFRE_DB_ZFS_ROOTOBJ;
  tstorage   : TFRE_DB_ZFS_DATASTORAGE;
  vdev       : TFRE_DB_ZFS_DISKCONTAINER;
  i          : Integer;
  disk       : TFRE_DB_ZFS_OBJ;
  children   : IFRE_DB_ObjectArray;
  vdevs      : IFRE_DB_COLLECTION;

begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  vdevs:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);

  tpool    := _getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  tstorage := tpool.GetDatastorage(conn);
  if Assigned(tstorage) then begin
    tstorage.setIsModified;
    CheckDbResult(conn.Update(tstorage.CloneToNewObject),'Assign storage disk');
    if input.FieldExists('rl') and (String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe) then begin
      vdev := tstorage;
    end else begin
      if input.FieldExists('expand') and input.Field('expand').AsBoolean then begin
        vdev     := tstorage.createVdev;
        vdev.SetName(StringReplace(FetchModuleTextShort(ses,'storage_vdev_caption_'+input.Field('rl').AsString),'%num%',IntToStr(_getNextVdevNum(tstorage.getZFSChildren(conn))),[rfReplaceAll]));
        vdev.setIsNew;
        vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
        CheckDbResult(vdevs.store(vdev.CloneToNewObject),'Assign storage disk');
      end else begin
        children:=tstorage.getZFSChildren(conn);
        vdev:=nil;
        for i := 0 to Length(children) - 1 do begin
          if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and ((children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).getId=input.Field('add').AsString) then begin
            vdev:=children[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
          end;
        end;
        if not Assigned(vdev) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_assign_vdev_not_found'));
        vdev.setIsModified;
        CheckDbResult(conn.Update(vdev.CloneToNewObject),'Assign storage disk');
      end;
    end;
  end else begin
    tstorage:=tpool.createDatastorage;
    tstorage.setIsNew;
    tstorage.setname(tpool.caption);
    CheckDbResult(vdevs.store(tstorage.CloneToNewObject),'Assign storage disk');
    if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
      vdev:=tstorage;
    end else begin
      vdev:=tstorage.createVdev;
      vdev.setIsNew;
      vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
      vdev.setname(StringReplace(FetchModuleTextShort(ses,'storage_vdev_caption_'+input.Field('rl').AsString),'%num%','0',[rfReplaceAll]));
      CheckDbResult(vdevs.store(vdev.CloneToNewObject),'Assign storage disk');
    end;
  end;
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    disk:=_getZFSObj(conn,input.Field('disks').AsStringItem[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_assign_not_new'));
    disk.removeFromPool;
    disk:=vdev.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    CheckDbResult(conn.Update(disk),'Assign storage disk');
  end;
  tpool.setIsModified;
  CheckDbResult(conn.Update(tpool),'Assign storage disk');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_RemoveNew(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool    : TFRE_DB_ZFS_ROOTOBJ;
  ua      : TFRE_DB_ZFS_UNASSIGNED;
  zfsObj  : TFRE_DB_ZFS_OBJ;
  i       : Integer;

  procedure _handleObj(const zfsObj: TFRE_DB_ZFS_OBJ);
  var
    children : IFRE_DB_ObjectArray;
    i        : Integer;
    pools    : IFRE_DB_COLLECTION;
    vdevs    : IFRE_DB_COLLECTION;
  begin
    children:=zfsObj.getZFSChildren(conn);
    for i := 0 to Length(children) - 1 do begin
      _handleObj(children[i].Implementor_HC as TFRE_DB_ZFS_OBJ);
    end;
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      zfsObj.setIsNew(false);
      zfsObj.setIsModified(false);
      zfsObj.removeFromPool;
      ua.addBlockdevice(zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
      CheckDbResult(conn.Update(zfsObj),'Remove new disk');
    end else begin
      if zfsObj.Implementor_HC is TFRE_DB_ZFS_POOL then begin
        pools:=conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
        CheckDbResult(pools.Remove(zfsObj.UID));
      end else begin
        vdevs:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);
        CheckDbResult(vdevs.Remove(zfsObj.UID));
      end;
    end;
  end;

begin

  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  ua:=_getUnassignedPool(conn);
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    pool:=zfsObj.getPool(conn);
    if assigned(ua) and (pool.getId=ua.getId) then continue; //skip: already unassigned
    if not zfsObj.getIsNew then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_remove_not_new'));
    _handleObj(zfsObj);
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ChangeRaidLevel(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i,num    : Integer;
  vdev     : TFRE_DB_ZFS_VDEV;
  idx      : SizeInt;
begin
  vdev:=_getZFSObj(conn,input.Field('selected').AsString).Implementor_HC as TFRE_DB_ZFS_VDEV;
  if not vdev.getIsNew then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_change_rl_not_new'));
  vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
  idx:=Pos('-',vdev.caption)+1;
  num:=StrToInt(Copy(vdev.caption,idx,Length(vdev.caption)-idx+1));
  vdev.setname(StringReplace(FetchModuleTextShort(ses,'storage_vdev_caption_'+input.Field('rl').AsString),'%num%',IntToStr(num),[rfReplaceAll]));
  CheckDbResult(conn.Update(vdev),'Change raid level');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
  _updateToolbars(conn,ses);
  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_DestroyPool(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  sf:=CWSF(@WEB_DestroyPoolConfirmed);
  sf.AddParam.Describe('pool',input.Field('pool').AsString);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'confirm_destroy_caption'),StringReplace(FetchModuleTextShort(ses,'confirm_destroy_msg'),'%pool%',pool.caption,[rfReplaceAll]),fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_DestroyPoolConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool   : TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;

    _updateToolbarAssignAndReplaceEntry(conn,ses,app);
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Destroy Pool confirmed','Please implement me',fdbmt_info);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;


function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ScrubPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  pool: TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Scrub Pool','Please implement me',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ExportPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  pool: TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Export Pool','Please implement me',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_IdentifyOn(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  disk   : TFRE_DB_ZFS_OBJ;
  i      : Integer;
begin
  CheckClassVisibility4MyDomain(ses);

  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    disk:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if disk.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      //VM_HACK.DS_IdentifyDisk(disk.field('name').AsString,false);
    end;
  end;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_IdentifyOff(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  disk   : TFRE_DB_ZFS_OBJ;
  i      : Integer;
begin
  CheckClassVisibility4MyDomain(ses);

  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    disk:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if disk.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      //VM_HACK.DS_IdentifyDisk(disk.field('name').AsString,true);
    end;
  end;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;


function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_SwitchOffline(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  zfsObj : TFRE_DB_ZFS_OBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      disk:=zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE;
      disk.isOffline:=true;
      CheckDbResult(conn.Update(disk),'Switch offline');
    end;
  end;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_SwitchOnline(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  zfsObj : TFRE_DB_ZFS_OBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      disk:=zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE;
      disk.isOffline:=false;
      CheckDbResult(conn.Update(disk),'Switch online');
    end;
  end;
  _updateToolbars(conn,ses);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Online','Switch online (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._unassignDisk(const upool: TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
var
  spool      : TFRE_DB_ZFS_ROOTOBJ;
  i          : Integer;
  disk       : TFRE_DB_ZFS_OBJ;

begin
  for i := 0 to Length(disks) - 1 do begin
    disk:=_getZFSObj(conn,disks[i]);
    spool:=disk.getPool(conn);
    if spool.getId=upool.getId then continue; //skip: already unassigned
    if not disk.getIsNew then raise EFRE_DB_Exception.Create(FetchModuleTextShort(session,'error_unassign_not_new'));

    disk.removeFromPool;
    disk:=upool.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    if disk.getIsNew then begin
      disk.setIsNew(false);
      disk.setIsModified(false);
    end else begin
      disk.setIsModified(true);
    end;
    CheckDbResult(conn.Update(disk),'Unassign Disk');
  end;
  session.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getNextVdevNum(const siblings: IFRE_DB_ObjectArray): Integer;
var
  num         : Integer;
  sibling_cap : TFRE_DB_String;
  idx         : SizeInt;
  sibling_num : Integer;
  i           : Integer;
begin
  num:=0;
  for i := 0 to Length(siblings) - 1 do begin
    if (siblings[i].Implementor_HC is TFRE_DB_ZFS_VDEV) then begin
      sibling_cap:=(siblings[i].Implementor_HC as TFRE_DB_ZFS_VDEV).caption;
      idx:=Pos('-',sibling_cap)+1;
      sibling_num:=StrToInt(Copy(sibling_cap,idx,Length(sibling_cap)-idx+1));
      if sibling_num>num then begin
        num:=sibling_num;
      end;
    end;
  end;
  Result:=num+1;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._getMultiselectionActions(const conn: IFRE_DB_CONNECTION; const selected: TFRE_DB_StringArray; var fnIdentifyOn, fnIdentifyOff, fnRemove, fnAssign, fnSwitchOffline, fnSwitchOnline, fnSwitchOfflineDisabled, fnSwitchOnlineDisabled: Boolean);
var
  i     : Integer;
  zfsObj: TFRE_DB_ZFS_OBJ;
  pool  : TFRE_DB_ZFS_ROOTOBJ;
  dbObj : IFRE_DB_Object;
begin
  fnIdentifyOn:=true;
  fnIdentifyOFf:=true;
  fnRemove:=true;
  fnAssign:=true;
  fnSwitchOffline:=true;
  fnSwitchOnline:=true;
  fnSwitchOfflineDisabled:=false;
  fnSwitchOnlineDisabled:=false;

  for i := 0 to Length(selected) - 1 do begin
    conn.Fetch(FREDB_H2G(selected[i]),dbObj);
    if dbObj.Implementor_HC is TFRE_DB_ZFS_OBJ then begin
      zfsObj:=dbObj.Implementor_HC as TFRE_DB_ZFS_OBJ;
    end else begin
      fnIdentifyOn:=false;
      fnIdentifyOFf:=false;
      fnRemove:=false;
      fnAssign:=false;
      fnSwitchOffline:=false;
      fnSwitchOnline:=false;
      fnSwitchOfflineDisabled:=true;
      fnSwitchOnlineDisabled:=true;
      exit;
    end;
    fnIdentifyOn:=fnIdentifyOn and zfsObj.canIdentify;
    pool:=zfsObj.getPool(conn);
    if zfsObj is TFRE_DB_ZFS_BLOCKDEVICE then begin //check if all selected objects are disks
      if (zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline then begin
        fnSwitchOfflineDisabled:=true;
      end else begin
        fnSwitchOnlineDisabled:=true;
      end;
    end else begin
      fnSwitchOffline:=false;
      fnSwitchOnline:=false;
      fnSwitchOfflineDisabled:=true;
      fnSwitchOnlineDisabled:=true;
      fnAssign:=false;
    end;
    if zfsObj.getIsNew then begin //check if all selected objects are new => delete is possible
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
  fnIdentifyOff:=fnIdentifyOn;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._updateToolbars(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession);
var
  fnIdentifyOn,fnIdentifyOff, fnRemove, fnAssign, fnSwitchOffline, fnSwitchOnline: Boolean;
  fnSwitchOfflineDisabled, fnSwitchOnlineDisabled: Boolean;
  fnDestroy,fnExport,fnScrub,fnReplace: Boolean;
  fnRLMirrorDisabled,fnRLZ1Disabled,fnRLZ2Disabled,fnRLZ3Disabled: Boolean;
  zfsObj: TFRE_DB_ZFS_OBJ;
  vdev: TFRE_DB_ZFS_VDEV;
  selected: TFRE_DB_StringArray;
  selectedfield: TFRE_DB_NameType;
  idPrefix: String;
  i: Integer;
  dbObj: IFRE_DB_Object;
begin

  for i := 0 to 1 do begin
    if i=0 then begin
      selectedfield:='selectedZfsObjs';
      idPrefix:='pool';
    end else begin
      selectedfield:='selectedLayoutObjs';
      idPrefix:='layout';
    end;

    fnIdentifyOn:=false;
    fnIdentifyOff:=false;
    fnAssign:=false;
    fnReplace:=false;
    fnSwitchOfflineDisabled:=true;
    fnSwitchOnlineDisabled:=true;
    fnRemove:=false;
    fnDestroy:=false;
    fnExport:=false;
    fnScrub:=false;
    fnRLMirrorDisabled:=true;
    fnRLZ1Disabled:=true;
    fnRLZ2Disabled:=true;
    fnRLZ3Disabled:=true;
    fnRemove:=false;

    if ses.GetSessionModuleData(ClassName).FieldExists(selectedfield) then begin
      selected:=ses.GetSessionModuleData(ClassName).Field(selectedfield).AsStringArr;
      if Length(selected)>1 then begin
        _getMultiselectionActions(conn,selected,fnIdentifyOn,fnIdentifyOff,fnRemove,fnAssign,fnSwitchOffline,fnSwitchOnline,fnSwitchOfflineDisabled,fnSwitchOnlineDisabled);
      end else begin
        conn.Fetch(FREDB_H2G(selected[0]),dbObj);
        if dbObj.Implementor_HC is TFRE_DB_ZFS_OBJ then begin
          zfsObj:=dbObj.Implementor_HC as TFRE_DB_ZFS_OBJ;
          writeln('SWL:ZFSDUMP',zfsObj.DumpToString);
          if zfsObj.getisNew then begin
            fnRemove:=true;
            if (zfsObj is TFRE_DB_ZFS_VDEV) and (zfsObj.getZFSParent(conn).Implementor_HC is TFRE_DB_ZFS_DATASTORAGE) then begin
               vdev:=zfsObj as TFRE_DB_ZFS_VDEV;
               fnRLMirrorDisabled:=(vdev.raidLevel=zfs_rl_mirror);
               fnRLZ1Disabled:=(vdev.raidLevel=zfs_rl_z1);
               fnRLZ2Disabled:=(vdev.raidLevel=zfs_rl_z2);
               fnRLZ3Disabled:=(vdev.raidLevel=zfs_rl_z3);
            end;
          end else begin
            if (zfsObj is TFRE_DB_ZFS_POOL) and not zfsObj.getIsModified then begin
              fnDestroy:=true;
              fnScrub:=true;
              fnExport:=true;
            end;
            if zfsObj is TFRE_DB_ZFS_BLOCKDEVICE then begin
              fnSwitchOfflineDisabled:=(zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline;
              fnSwitchOnlineDisabled:=not fnSwitchOfflineDisabled;
              if (zfsObj.getZFSParent(conn).Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then begin
                fnAssign:=true;
                fnReplace:=true;
              end;
            end;
          end;
          fnIdentifyOn:=zfsObj.canIdentify;
          fnIdentifyOff:=fnIdentifyOn;
        end;
      end;
    end;

    if i=0 then begin
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_remove',not fnRemove));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_destroy',not fnDestroy));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_scrub',not fnScrub));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_export',not fnExport));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_rl_mirror',fnRLMirrorDisabled));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_rl_z1',fnRLZ1Disabled));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_rl_z2',fnRLZ2Disabled));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_rl_z3',fnRLZ3Disabled));
      ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_remove',not fnRemove));
    end;
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_switch_online',fnSwitchOnlineDisabled));
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_switch_offline',fnSwitchOfflineDisabled));
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_iden_on',not fnIdentifyOn));
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_iden_off',not fnIdentifyOff));
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_assign',not fnAssign));
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus(idPrefix+'_replace',not fnReplace));
  end;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._updateToolbarAssignAndReplaceEntry(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION);
var
  menu: TFRE_DB_MENU_DESC;
  res : TFRE_DB_UPDATE_UI_ELEMENT_DESC;
begin
  menu:=TFRE_DB_MENU_DESC.create.Describe;
  _addDisksToPool(menu,nil,nil,nil,app,conn,ses);
  res:=TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeSubmenu('pool_assign',menu.Implementor_HC as TFRE_DB_MENU_DESC);
  ses.SendServerClientRequest(res);
  menu:=TFRE_DB_MENU_DESC.create.Describe; //FIXXME - is there a better solution
  _addDisksToPool(menu,nil,nil,nil,app,conn,ses); //FIXXME - is there a better solution
  res:=TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeSubmenu('layout_assign',menu);
  ses.SendServerClientRequest(res);
  menu:=TFRE_DB_MENU_DESC.create.Describe;
  _replaceDisks(menu,'',conn);
  res:=TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeSubmenu('pool_replace',menu.Implementor_HC as TFRE_DB_MENU_DESC);
  ses.SendServerClientRequest(res);
  menu:=TFRE_DB_MENU_DESC.create.Describe; //FIXXME - is there a better solution
  _replaceDisks(menu,'',conn); //FIXXME - is there a better solution
  res:=TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeSubmenu('layout_replace',menu);
  ses.SendServerClientRequest(res);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._PoolObjContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_SUBSECTIONS_DESC;
  zfsObj: IFRE_DB_Object;
begin
  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedZfsObjs') and (ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').ValueCount=1) then begin

    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr[0]),zfsObj));
    if zfsObj.MethodExists('ZFSContent') then begin
      res.AddSection.Describe(CSFT('ZFSContent',zfsObj),FetchModuleTextShort(ses,'poolobj_content_tab'),2);
    end;
    res.AddSection.Describe(CWSF(@WEB_PoolObjNotes),FetchModuleTextShort(ses,'poolobj_notes_tab'),2);
  end else begin
    res.AddSection.Describe(CWSF(@WEB_PoolObjNoContent),FetchModuleTextShort(ses,'poolobj_no_content_tab'),1);
  end;
  res.contentId:='pool_obj_content';
  Result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_PoolObjNotes(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  load_func             : TFRE_DB_SERVER_FUNC_DESC;
  save_func             : TFRE_DB_SERVER_FUNC_DESC;
begin
  load_func   := CWSF(@WEB_NoteLoad);
  save_func   := CWSF(@WEB_NoteSave);

  load_func.AddParam.Describe('linkid',ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringItem[0]);
  save_func.AddParam.Describe('linkid',ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringItem[0]);

  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CWSF(@WEB_NoteStartEdit),CWSF(@WEB_NoteStopEdit));
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_SaveConfig(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i       :   NativeInt;
  zfsobj  :   TFRE_DB_ZFS_OBJ;
  em_pool :   TFRE_DB_ZFS_POOL;
  zfs     :   TFRE_DB_ZFS;
  res     :   IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
//  writeln('SWL:',input.DumpToString());
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if (zfsobj.Implementor_HC is TFRE_DB_ZFS_POOL) then begin
        em_pool:=TFRE_DB_ZFS_POOL.CreateEmbeddedPoolObjectfromDB(conn,zfsobj.UID,True);
        zfs := TFRE_DB_ZFS.create;
        try
          zfs.CreateDiskPool(em_pool,res);
        finally
          zfs.free;
        end;
      end;
    zfsobj.Finalize;
  end;



//  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',true));
//  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',true));



  result:=TFRE_DB_MESSAGE_DESC.create.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),'Save Config',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ResetConfig(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pools   : IFRE_DB_COLLECTION;
  reqobj  : IFRE_DB_Object;
  opd     : IFRE_DB_Object;

  procedure GotAnswer(const ses: IFRE_DB_UserSession; const new_input: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const ocid: Qword; const opaquedata: IFRE_DB_Object);
  var res : TFRE_DB_MESSAGE_DESC;
      app : IFRE_DB_APPLICATION;
      conn: IFRE_DB_CONNECTION;
  begin
    if status=cdcs_OK then
      begin
        opaquedata.Finalize;
      end
    else
      begin
        if status=cdcs_TIMEOUT then
          ses.SendServerClientAnswer(TFRE_DB_MESSAGE_DESC.create.Describe('Error','TIMEOUT on requesting disk data',fdbmt_error),ocid);
        if status=cdcs_ERROR then
          ses.SendServerClientAnswer(TFRE_DB_MESSAGE_DESC.create.Describe('Error','ERROR on requesting disk data',fdbmt_error),ocid);
        opaquedata.Finalize;
      end;
  end;

begin

//  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Disabled','Feature disabled in demonstration mode',fdbmt_info);
  reqobj := GFRE_DBI.NewObject;
  opd    := GFRE_DBI.NewObject;


  if ses.InvokeRemoteRequest('TFRE_BOX_FEED_CLIENT','REQUESTDISKDATA',reqobj,@GotAnswer,opd)<>edb_OK then
    raise EFRE_DB_Exception.Create('could not invoke ARTEFEED delete measurement command');

  result := GFRE_DB_SUPPRESS_SYNC_ANSWER;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_Replace(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldExists('new') then begin
    input.Field('new').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr[0];
  end;

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Replace','Please implement me ('+input.Field('new').AsString+'=>'+input.Field('old').AsString+')',fdbmt_info);
end;

{ TFRE_FIRMBOX_STORAGE_APP }

procedure TFRE_FIRMBOX_STORAGE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitApp('description');
  AddApplicationModule(TFRE_FIRMBOX_STORAGE_POOLS_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_BACKUP_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD.create);
end;

procedure TFRE_FIRMBOX_STORAGE_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage',FetchAppTextShort(session,'sitemap_main'),'images_apps/firmbox_storage/files_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools',FetchAppTextShort(session,'sitemap_pools'),'images_apps/firmbox_storage/disk_white.svg',TFRE_FIRMBOX_STORAGE_POOLS_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_POOLS_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Global',FetchAppTextShort(session,'sitemap_fileserver_global'),'images_apps/firmbox_storage/files_global_white.svg',TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Virtual',FetchAppTextShort(session,'sitemap_fileserver_virtual'),'images_apps/firmbox_storage/files_virtual_white.svg',TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Backup',FetchAppTextShort(session,'sitemap_backup'),'images_apps/firmbox_storage/clock_white.svg',TFRE_FIRMBOX_BACKUP_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_BACKUP_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Backup/Filebrowser',FetchAppTextShort(session,'sitemap_filebrowser'),'images_apps/firmbox_storage/filebrowser_white.svg',TFRE_FIRMBOX_BACKUP_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_BACKUP_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Scheduler',FetchAppTextShort(session,'sitemap_backup_scheduler'),'images_apps/firmbox_storage/clock_white.svg',TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_BACKUP_SCHEDULER_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_FIRMBOX_STORAGE_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_STORAGE_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFRE_FIRMBOX_STORAGE_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFRE_FIRMBOX_STORAGE_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId:='1.0';

    CreateAppText(conn,'caption','Storage','Storage','Storage');
    CreateAppText(conn,'pools_description','Pools','Pools','Pools');
    CreateAppText(conn,'synch_description','Synchronization','Synchronization','Synchronization');
    CreateAppText(conn,'backup_description','Snapshots','Snapshots','Snapshots');
    CreateAppText(conn,'backup_scheduler_description','Snapshot Schedulers','Snapshot Schedulers','Snapshot Schedulers');
    CreateAppText(conn,'fileserver_global_description','Global SAN/NAS','Global SAN/NAS','Global SAN/NAS');

    CreateAppText(conn,'sitemap_main','Storage','','Storage');
    CreateAppText(conn,'sitemap_pools','Pools','','Pools');
    CreateAppText(conn,'sitemap_fileserver','SAN/NAS','','SAN/NAS');
    CreateAppText(conn,'sitemap_fileserver_global','Global SAN/NAS','','Global NFS, iSCSI, FC');
    CreateAppText(conn,'sitemap_fileserver_virtual','Virtual NAS','','Virtual Fileserver');
    CreateAppText(conn,'sitemap_backup','Snapshots','','Snapshots');
    CreateAppText(conn,'sitemap_filebrowser','Filebrowser','','Filebrowser');
    CreateAppText(conn,'sitemap_backup_scheduler','Snapshot Schedulers','','Snapshot Schedulers');

    CreateAppText(conn,'global_info','Overview of global SAN/NAS shares and LUNs.');
    CreateAppText(conn,'backup_info','Overview of snapshots for shares, block devices and virtual machines.');

    CreateAppText(conn,'storage_global_filer_nfs','NFS Exports','NFS Exports','NFS Exports');
    CreateAppText(conn,'storage_global_filer_lun','LUN Targets','LUN Targets','LUN Targets');

    CreateAppText(conn,'nfs_export','Export');
    CreateAppText(conn,'nfs_refer','Refer');
    CreateAppText(conn,'nfs_used','Used');
    CreateAppText(conn,'nfs_avail','Avail');
    CreateAppText(conn,'nfs_pool','Diskpool');
    CreateAppText(conn,'nfs_desc','Description');
    CreateAppText(conn,'nfs_content_header','Details about the selected NFS export');

    CreateAppText(conn,'nfs_access','NFS Access');
    CreateAppText(conn,'nfs_accesstype','Accesstype');
    CreateAppText(conn,'nfs_accesssubnet','Host/Subnet');
    CreateAppText(conn,'tb_create_nfs_access','Create access');
    CreateAppText(conn,'tb_delete_nfs_access','Delete access');
    CreateAppText(conn,'tb_modify_nfs_access','Modify access');
    CreateAppText(conn,'cm_delete_nfs_access','Delete access');
    CreateAppText(conn,'cm_modify_nfs_access','Modify access');

    CreateAppText(conn,'nfs_access_delete_diag_cap','Confirm: Delete NFS access');
    CreateAppText(conn,'nfs_access_delete_diag_msg','The NFS %access_type% access for %access_host% will be deleted permanently! Please confirm to continue.');

    CreateAppText(conn,'tb_create_nfs_export','Create export');
    CreateAppText(conn,'tb_delete_nfs_export','Delete export');
    CreateAppText(conn,'cm_delete_nfs_export','Delete share');
    CreateAppText(conn,'nfs_delete_diag_cap','Confirm: Delete share');
    CreateAppText(conn,'nfs_delete_diag_msg','The share %share_str% will be deleted permanently! Please confirm to continue.');
    CreateAppText(conn,'nfs_add_diag_cap','New NFS Share');
    CreateAppText(conn,'nfsaccess_add_diag_cap','New NFS Access');
    CreateAppText(conn,'nfsaccess_modify_diag_cap','Modify NFS Access');

    CreateAppText(conn,'tb_create_lun','Create LUN');
    CreateAppText(conn,'tb_delete_lun','Delete LUN');
    CreateAppText(conn,'cm_delete_lun','Delete LUN');
    CreateAppText(conn,'lun_view','LUN Views');
    CreateAppText(conn,'lun_guid','GUID');
    CreateAppText(conn,'lun_pool','Diskpool');
    CreateAppText(conn,'lun_desc','Description');
    CreateAppText(conn,'lun_size','Size [MB]');
    CreateAppText(conn,'lun_delete_diag_cap','Confirm: Delete LUN');
    CreateAppText(conn,'lun_delete_diag_msg','The LUN %guid_str% will be deleted permanently! Please confirm to continue.');
    CreateAppText(conn,'lun_content_header','Details about the selected LUN');
    CreateAppText(conn,'lun_add_diag_cap','New LUN');

    CreateAppText(conn,'lun_view_initiatorgroup','Initiators');
    CreateAppText(conn,'lun_view_targetgroup','Targets');
    CreateAppText(conn,'tb_create_lun_view','Create View');
    CreateAppText(conn,'tb_lunview_delete','Delete View');
    CreateAppText(conn,'tb_lunview_modify','Modify View');
    CreateAppText(conn,'cm_lunview_delete','Delete View');
    CreateAppText(conn,'cm_lunview_modify','Modify View');
    CreateAppText(conn,'lunview_delete_diag_cap','Confirm: Delete View');
    CreateAppText(conn,'lunview_delete_diag_msg','The View %guid_str% will be deleted permanently! Please confirm to continue.');
    CreateAppText(conn,'lunview_add_diag_cap','New LUN View');
    CreateAppText(conn,'lunview_modify_diag_cap','Modify LUN View');

    CreateAppText(conn,'backup_share','Source');
    CreateAppText(conn,'backup_snapshot','ZFS Snapshot');
    CreateAppText(conn,'backup_desc','Description');
    CreateAppText(conn,'backup_creation','Creation Timestamp');
    CreateAppText(conn,'backup_used','Used [MB]');
    CreateAppText(conn,'backup_refer','Refer [MB]');
    CreateAppText(conn,'backup_snapshot_properties','Snapshot Properties');
    CreateAppText(conn,'backup_content_header','Details about the selected snapshot.');
    CreateAppText(conn,'backup_snapshot_delete','Delete');
    CreateAppText(conn,'backup_snapshot_delete_diag_cap','Confirm: Delete snapshot');
    CreateAppText(conn,'backup_snapshot_delete_diag_msg','The snapshot %snapshot_str% will be deleted permanently! Please confirm to continue.');

    CreateAppText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
    CreateAppText(conn,'error_modify_single_select','Exactly one object has to be selected to modify.');

  end;
end;

class procedure TFRE_FIRMBOX_STORAGE_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then begin
    currentVersionId:='1.0';

    CheckDbResult(conn.AddGroup('STORAGEFEEDER','Group for Storage Data Feeder','Storage Feeder',domainUID),'could not create Storage feeder group');
  end;
  if currentVersionId='1.0' then begin
    currentVersionId:='1.1';

    CheckDbResult(conn.DeleteGroup('STORAGEFEEDER',domainUID));
  end;
end;

class procedure TFRE_FIRMBOX_STORAGE_APP.InstallDBObjects4SysDomain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
var
  group: IFRE_DB_GROUP;
begin
  inherited InstallDBObjects4SysDomain(conn, currentVersionId, domainUID);

  if currentVersionId='' then begin
    currentVersionId:='1.0';
    CheckDbResult(conn.AddGroup('STORAGEFEEDER','Group for Storage Data Feeder','Storage Feeder',domainUID),'could not create Storage feeder group');

    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_STORAGE_APP.GetClassRoleNameFetch
    )),'could not add roles for group STORAGEFEEDER');

    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_UNCONFIGURED_MACHINE.GetClassStdRoles),'could not add roles TFRE_DB_UNCONFIGURED_MACHINE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_MACHINE.GetClassStdRoles),'could not add roles TFRE_DB_MACHINE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_POOL.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_POOL for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_BLOCKDEVICE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_BLOCKDEVICE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_VDEVCONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_VDEVCONTAINER for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_DISKREPLACECONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DISKREPLACECONTAINER for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_DISKSPARECONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DISKSPARECONTAINER for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_VDEV.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_VDEVfor group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DATASTORAGE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_LOG.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_LOG for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_CACHE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_CACHE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_SPARE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_SPARE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_UNASSIGNED.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_SPARE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_PHYS_DISK.GetClassStdRoles),'could not add roles TFRE_DB_PHYS_DISK for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_UNDEFINED_BLOCKDEVICE.GetClassStdRoles),'could not add roles TFRE_DB_UNDEFINED_BLOCKDEVICE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SAS_DISK.GetClassStdRoles),'could not add roles TFRE_DB_SAS_DISK for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SATA_DISK.GetClassStdRoles),'could not add roles TFRE_DB_SATA_DISK for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ENCLOSURE.GetClassStdRoles),'could not add roles TFRE_DB_ENCLOSURE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SAS_EXPANDER.GetClassStdRoles),'could not add roles TFRE_DB_SAS_EXPANDER for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_DRIVESLOT.GetClassStdRoles),'could not add roles TFRE_DB_DRIVESLOT for group STORAGEFEEDER');

    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_FILEBLOCKDEVICE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_FILEBLOCKDEVICE for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZPOOL_IOSTAT.GetClassStdRoles),'could not add roles TFRE_DB_ZPOOL_IOSTAT for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_IOSTAT.GetClassStdRoles),'could not add roles TFRE_DB_IOSTAT for group STORAGEFEEDER');
    CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SG_LOGS.GetClassStdRoles),'could not add roles TFRE_DB_SG_LOGS for group STORAGEFEEDER');
  end;
  if currentVersionId='1.0' then begin
    currentVersionId:='1.1';

    CheckDbResult(conn.AddRole('STORAGEADMIN','Allowed to create, modify and delete Pools','',domainUID),'could not add role STORAGEADMIN');

    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_STORAGE_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_STORAGE_POOLS_MOD.GetClassRoleNameFetch
    )));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_UNCONFIGURED_MACHINE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_MACHINE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_POOL.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_BLOCKDEVICE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_VDEVCONTAINER.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_DISKREPLACECONTAINER.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_DISKSPARECONTAINER.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_VDEV.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_LOG.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_CACHE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_SPARE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_UNASSIGNED.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_PHYS_DISK.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_UNDEFINED_BLOCKDEVICE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_SAS_DISK.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_SATA_DISK.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ENCLOSURE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_DRIVESLOT.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZFS_FILEBLOCKDEVICE.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_ZPOOL_IOSTAT.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_IOSTAT.GetClassStdRoles));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_SG_LOGS.GetClassStdRoles));

    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_NOTE.GetClassStdRoles));

    CheckDbResult(conn.AddRole('STORAGEVIEWER','Allowed to view Pools','',domainUID),'could not add role STORAGEVIEWER');

    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_STORAGE_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_STORAGE_POOLS_MOD.GetClassRoleNameFetch
    )));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_UNCONFIGURED_MACHINE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_MACHINE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_POOL.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_BLOCKDEVICE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_VDEVCONTAINER.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_DISKREPLACECONTAINER.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_DISKSPARECONTAINER.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_VDEV.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_LOG.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_CACHE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_SPARE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_UNASSIGNED.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_PHYS_DISK.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_UNDEFINED_BLOCKDEVICE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_SAS_DISK.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_SATA_DISK.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ENCLOSURE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_DRIVESLOT.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZFS_FILEBLOCKDEVICE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_ZPOOL_IOSTAT.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_IOSTAT.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.AddRoleRightsToRole('STORAGEVIEWER',domainUID,TFRE_DB_SG_LOGS.GetClassStdRoles(false,false,false,true)));

    CheckDbResult(conn.AddRoleRightsToRole('STORAGEADMIN',domainUID,TFRE_DB_NOTE.GetClassStdRoles(false,false,false,true)));

    CheckDbResult(conn.AddGroup('STORAGEADMINS','Admins of the Firmbox Storage','Storage Admins',domainUID,true),'could not create admins group');
    CheckDbResult(conn.AddRolesToGroup('STORAGEADMINS',domainUID,TFRE_DB_StringArray.Create('STORAGEADMIN')),'could not add role STORAGEADMIN for group Admins');

    CheckDbResult(conn.AddGroup('STORAGEVIEWERS','Viewers of the Firmbox Storage','Storage Viewers',domainUID,true),'could not create viewers group');
    CheckDbResult(conn.AddRolesToGroup('STORAGEVIEWERS',domainUID,TFRE_DB_StringArray.Create('STORAGEVIEWER')),'could not add role STORAGEVIEWER for group Viewers');

    CheckDbResult(conn.FetchGroup('STORAGEFEEDER',domainUID,group));
    group.isInternal:=true;
    group.isProtected:=true;
    CheckDbResult(conn.UpdateGroup(group));

  end;
end;

class procedure TFRE_FIRMBOX_STORAGE_APP.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateDiskDataCollections(conn);
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;
end;

function TFRE_FIRMBOX_STORAGE_APP.WEB_DISK_DATA_FEED(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  result := Common_Disk_DataFeed(input,ses,app,conn);
end;



end.

