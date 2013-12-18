unit fos_firmbox_storageapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_ZFS,
  FRE_DB_INTERFACE,fos_stats_control_interface,FOS_VM_CONTROL_INTERFACE,
  fos_firmbox_vm_machines_mod,fos_firmbox_fileserver, fre_scsi,
  FRE_DB_COMMON;

var
    DISKI_HACK : IFOS_STATS_CONTROL;
    //VM_HACK    : IFOS_VM_HOST_CONTROL;

type

  { TFRE_FIRMBOX_STORAGE_APP }

  TFRE_FIRMBOX_STORAGE_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    procedure       _UpdateSitemap              (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize         (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion          (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme        (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain     (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;

  published
    function        WEB_RAW_DISK_FEED           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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
    function        _getZFSTreeObj                      (const conn: IFRE_DB_CONNECTION; const zfsObj: TFRE_DB_ZFS_OBJ):IFRE_DB_Object;
    function        _getLayoutTreeObj                   (const conn: IFRE_DB_CONNECTION; const obj: IFRE_DB_Object):IFRE_DB_Object;
    procedure       _unassignDisk                       (const upool:TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
    function        _getNextVdevNum                     (const siblings: IFRE_DB_ObjectArray): Integer;
    procedure       _getMultiselectionActions           (const conn: IFRE_DB_CONNECTION; const selected :TFRE_DB_StringArray;var fnIdentifyOn,fnIdentifyOff,fnRemove,fnAssign,fnSwitchOffline,fnSwitchOnline,fnSwitchOfflineDisabled,fnSwitchOnlineDisabled:Boolean);
    procedure       _updateToolbar                      (const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession);
    procedure       _updateToolbarAssignAndReplaceEntry (const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION);
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    function        Usage                               (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession):TFRE_DB_CONTENT_DESC;
    function        ServiceTime                         (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession):TFRE_DB_CONTENT_DESC;
    function        BusyTime                            (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession):TFRE_DB_CONTENT_DESC;
    function        ReadBW                              (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession):TFRE_DB_CONTENT_DESC;
    function        WriteBW                             (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession):TFRE_DB_CONTENT_DESC;
    procedure       UpdateDiskCollection                (const pool_disks : IFRE_DB_COLLECTION ; const data:IFRE_DB_Object);
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       MyServerInitializeModule            (const admin_dbc : IFRE_DB_CONNECTION); override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolStructureSC                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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
    function        WEB_PoolLayout                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PoolNotes                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ZFSTreeGridData                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_LayoutTreeGridData              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_TreeDrop                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridMenu                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_UpdatePoolsTree                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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


  { TFRE_FIRMBOX_STORAGE_SYNC_MOD }

  TFRE_FIRMBOX_STORAGE_SYNC_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD }

  TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _GetFileServerID          (conn : IFRE_DB_CONNECTION): TGuid;
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

  { TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD }

  TFILESHARE_ROLETYPE = (rtRead,rtWrite);

  TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _getVFSNames               (const vfss: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
    function        _getShareNames             (const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
    function        _getRolename               (const share_id: TFRE_DB_NameType; const roletype: TFILESHARE_ROLETYPE): TFRE_DB_NameType;
    function        _setShareRoles             (const input:IFRE_DB_Object; const change_read,change_write,read,write:boolean; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION) : IFRE_DB_Object;
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure    ; override;
  public
    procedure       CalculateReadWriteAccess   (const conn : IFRE_DB_CONNECTION ; const dependency_input : IFRE_DB_Object; const input_object : IFRE_DB_Object ; const transformed_object : IFRE_DB_Object);
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentShareGroups     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentVFShares        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateVFS              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSMenu                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSContent             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSDelete              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSDeleteConfirmed     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateVFSShare         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareMenu           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareContent        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareDelete         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupMenu      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupSetRead   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupSetWrite  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupClearRead (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupClearWrite(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupInDrop    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareGroupOutDrop   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_FIRMBOX_BACKUP_MOD }

  TFRE_FIRMBOX_BACKUP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure   ; override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentSnapshot       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SnapshotMenu          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteSnapshot        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;

implementation

var __idx: NativeInt; //FIXXXME - remove me

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_BACKUP_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORAGE_POOLS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORAGE_SYNC_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORAGE_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD }

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD._getVFSNames(const vfss: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
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

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD._getShareNames(const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
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

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD._getRolename(const share_id: TFRE_DB_NameType; const roletype: TFILESHARE_ROLETYPE): TFRE_DB_NameType;
begin
  case roletype of
    rtRead  : result := FREDB_Get_Rightname_UID('FSREAD',GFRE_BT.HexString_2_GUID(share_id));
    rtWrite : result := FREDB_Get_Rightname_UID('FSWRITE',GFRE_BT.HexString_2_GUID(share_id));
   else
     raise EFRE_DB_Exception.Create('Undefined Roletype for Fileshare');
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD._setShareRoles(const input: IFRE_DB_Object; const change_read, change_write, read, write: boolean; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.FieldExists('share_id') then begin
    share_s  := input.Field('share_id').asstring;
  end else begin
    dependend  := GetDependencyFiltervalues(input,'uids_ref');
    if length(dependend)=0 then begin
      Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$share_group_in_diag_cap'),app.FetchAppTextShort(ses,'$share_group_in_no_share_msg'),fdbmt_warning,nil);
      exit;
    end;
    share_s   := dependend[0];
  end;
  share_id := GFRE_BT.HexString_2_GUID(share_s);

  CheckDbResult(conn.Fetch(share_id,share),app.FetchAppTextShort(ses,'Share not found!'));


  for i := 0 to input.Field('selected').ValueCount-1 do begin
    groupid := GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]);
    if (conn.sys.FetchGroupById(groupid,group)<>edb_OK) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'Group not found!'));

    rrole := _getRolename(share_s,rtRead);
    if conn.sys.RoleExists(rrole+'@'+group.GetDomain(conn))=false then raise EFRE_DB_Exception.Create('No Read Role for Fileshare !');

    wrole := _getRolename(share_s,rtWrite);
    if conn.sys.RoleExists(wrole+'@'+group.GetDomain(conn))=false then raise EFRE_DB_Exception.Create('No Write Role for Fileshare !');

    if change_read then begin
      if read then begin
         abort;
//        conn.sys.AddRolesToGroup(group.ObjectName+'@'+group.GetDomain(conn),GFRE_DBI.ConstructStringArray([rrole+'@'+group.GetDomain(conn)]));
      end else begin
        abort;
//        conn.RemoveGroupRoles(group.ObjectName+'@'+group.GetDomain(conn),GFRE_DBI.ConstructStringArray([rrole+'@'+group.GetDomain(conn)]),true);
      end;
    end;
    if change_write then begin
      if write then begin
        abort;
//        conn.AddGroupRoles(group.ObjectName+'@'+group.GetDomain(conn),GFRE_DBI.ConstructStringArray([wrole+'@'+group.GetDomain(conn)]));
      end else begin
        abort;
//        conn.RemoveGroupRoles(group.ObjectName+'@'+group.GetDomain(conn),GFRE_DBI.ConstructStringArray([wrole+'@'+group.GetDomain(conn)]),true);
      end;
    end;
  end;

//  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('DROP','Adding share roles to '+ input.Field('selected').AsStringDump,fdbmt_info);
  Result:=GFRE_DB_NIL_DESC;
end;

class procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$fileserver_virtual_description')
end;

procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.CalculateReadWriteAccess(const conn: IFRE_DB_CONNECTION; const dependency_input: IFRE_DB_Object; const input_object: IFRE_DB_Object; const transformed_object: IFRE_DB_Object);
var sel_guid,rr,wr : string;
    sel_guidg      : TGUID;
    group_id       : TGUID;
    true_icon      : string;
    false_icon     : string;
begin
  sel_guid  := dependency_input.FieldPath('UIDS_REF.FILTERVALUES').AsString;
  sel_guidg := GFRE_BT.HexString_2_GUID(sel_guid);
  group_id  := input_object.uid;

  rr := FREDB_Get_Rightname_UID_STR('FSREAD',sel_guid);
  wr := FREDB_Get_Rightname_UID_STR('FSWRITE',sel_guid);

  true_icon  := FREDB_getThemedResource('images_apps/firmbox_storage/access_true.png');
  false_icon := FREDB_getThemedResource('images_apps/firmbox_storage/access_false.png');
end;

procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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
      AddOneToOnescheme('objname','Fileserver',app.FetchAppTextShort(session,'$vfs_name'));
      AddOneToOnescheme('pool','pool',app.FetchAppTextShort(session,'$vfs_pool'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$vfs_desc'));
      AddOneToOnescheme('ip','ip',app.FetchAppTextShort(session,'$vfs_ip'));
      AddOneToOnescheme('domain','domain',app.FetchAppTextShort(session,'$vfs_domain'));
    end;
    fs_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
    with fs_dc do begin
      SetDeriveParent(conn.Collection('service'));
      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_VIRTUAL_FILESERVER.ClassName));
      SetDeriveTransformation(fs_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_VFSMenu),nil,CWSF(@WEB_VFSContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,share_tr_Grid);
    with share_tr_Grid do begin
      AddOneToOnescheme('objname','share',app.FetchAppTextShort(session,'$vfs_share'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$vfs_share_desc'));
      AddOneToOnescheme('icons','',app.FetchAppTextShort(session,'$vfs_share_icon'),dt_icon);
      AddOneToOnescheme('refer_mb','refer',app.FetchAppTextShort(session,'$vfs_share_refer'));
      AddOneToOnescheme('used_mb','used',app.FetchAppTextShort(session,'$vfs_share_used'));
      AddOneToOnescheme('quota_mb','avail',app.FetchAppTextShort(session,'$vfs_share_avail'));
    end;
    share_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
    with share_dc do begin
      //SetDeriveParent(conn.Collection('fileshare'));
      SetReferentialLinkMode('TFRE_DB_VIRTUAL_FILESHARE|FILESERVER',false);
      //AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_VIRTUAL_FILESHARE.ClassName));
      SetDeriveTransformation(share_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_VFSShareMenu),nil,CWSF(@WEB_VFSShareContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,groupin_tr_Grid);
    with groupin_tr_Grid do begin
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$share_group_desc'));
      AddOneToOnescheme('read','',app.FetchAppTextShort(session,'$share_group_read'),dt_Icon);
      AddOneToOnescheme('write','',app.FetchAppTextShort(session,'$share_group_write'),dt_Icon);
//      AddOneToOnescheme('objname','group',app.FetchAppTextShort(session,'$share_group_group'));
      SetCustomTransformFunction(@CalculateReadWriteAccess);
    end;
    groupin_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
    with groupin_dc do begin
      SetDeriveParent(session.GetDBConnection.AdmGetGroupCollection);
      SetDeriveTransformation(groupin_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_Multiselect],app.FetchAppTextShort(session,'$share_group_in'),nil,'',CWSF(@WEB_VFSShareGroupMenu),nil,nil,nil,CWSF(@WEB_VFSShareGroupInDrop));
    end;

    //GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,groupout_tr_Grid);
    //with groupout_tr_Grid do begin
    //  AddOneToOnescheme('objname','group',app.FetchAppTextShort(session,'$share_group_group'));
    //  AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, app.FetchAppTextShort(session,'$share_group_desc'));
    //end;
    //groupout_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
    //with groupout_dc do begin
    //  SetDeriveParent(session.GetDBConnection.AdmGetGroupCollection);
    //  SetDeriveTransformation(groupout_tr_Grid);
    //  SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'$share_group_out'),nil,'',nil,nil,nil,nil,CSF(@WEB_VFSShareGroupOutDrop));
    //end;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  vfs           : TFRE_DB_LAYOUT_DESC;
  sub_sec_fs    : TFRE_DB_SUBSECTIONS_DESC;
  grid_fs       : TFRE_DB_VIEW_LIST_DESC;
  dc_fs         : IFRE_DB_DERIVED_COLLECTION;
  dc_share      : IFRE_DB_DERIVED_COLLECTION;
  txt           : IFRE_DB_TEXT;

begin
  CheckClassVisibility(ses);

  sub_sec_fs   := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  dc_fs       := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
  grid_fs     := dc_fs.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    txt:=app.FetchAppTextFull(ses,'$create_vfs');
    grid_fs.AddButton.Describe(CWSF(@WEB_CreateVFS),'images_apps/firmbox_storage/create_vfs.png',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;


  dc_share    := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
  //FIXXME Heli - make it working
  grid_fs.AddFilterEvent(dc_share.getDescriptionStoreId(),'uids');

  sub_sec_fs.AddSection.Describe(CWSF(@WEB_ContentVFShares),app.FetchAppTextShort(ses,'$storage_virtual_filer_shares'),1,'shares');
  sub_sec_fs.AddSection.Describe(CWSF(@WEB_VFSContent),app.FetchAppTextShort(ses,'$storage_virtual_filer_content'),2,'vfs');

  vfs          := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_fs,sub_sec_fs,nil,nil,nil,true,1,3);

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,vfs,nil,TFRE_DB_HTML_DESC.create.Describe('<b>'+app.FetchAppTextShort(ses,'$virtual_info')+'</b>'));
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_ContentShareGroups(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  dc_group_in   : IFRE_DB_DERIVED_COLLECTION;
  //grid_group_in : TFRE_DB_VIEW_LIST_DESC;
  //dc_group_out  : IFRE_DB_DERIVED_COLLECTION;
  //grid_group_out: TFRE_DB_VIEW_LIST_DESC;
  //share_group   : TFRE_DB_LAYOUT_DESC;
begin
  CheckClassVisibility(ses);

  dc_group_in   := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
  result        := dc_group_in.GetDisplayDescription;

  //dc_group_out  := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
  //grid_group_out:= dc_group_out.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  //
//  if conn.CheckAppRight('edit_vfs_share',app.ObjectName) then begin
//    grid_group_out.SetDropGrid(grid_group_in,nil,TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
////  grid_group_in.SetDragObjClasses(TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
//    grid_group_in.SetDropGrid(grid_group_out,nil,TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
////  grid_group_out.SetDragObjClasses(TFRE_DB_StringArray.create('TFRE_DB_GROUP'));
//  end;

  //share_group   := //TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(nil,grid_group_out,nil,grid_group_in,nil,true,-1,1,-1,1);
  //Result        := share_group;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_ContentVFShares(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sub_sec_share : TFRE_DB_SUBSECTIONS_DESC;
  dc_group_in   : IFRE_DB_DERIVED_COLLECTION;
  dc_group_out  : IFRE_DB_DERIVED_COLLECTION;
  share         : TFRE_DB_LAYOUT_DESC;
  txt           : IFRE_DB_TEXT;
  dc_share      : IFRE_DB_DERIVED_COLLECTION;
  grid_share    : TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility(ses);

  dc_share    := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
  grid_share  := dc_share.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE) then
    begin
      txt:=app.FetchAppTextFull(ses,'$create_vfs_share');
      grid_share.AddButton.Describe(CWSF(@WEB_CreateVFSShare),'images_apps/firmbox_storage/create_vfs_share.png',txt.Getshort,txt.GetHint);
      txt.Finalize;
    end;

  sub_sec_share := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  sub_sec_share.AddSection.Describe(CWSF(@WEB_VFSShareContent),app.FetchAppTextShort(ses,'$storage_virtual_filer_share_properties'),1,'shareproperties');
  sub_sec_share.AddSection.Describe(CWSF(@WEB_ContentShareGroups),app.FetchAppTextShort(ses,'$storage_virtual_filer_share_groups'),1,'sharegroups');

  dc_group_in   := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
  //dc_group_out  := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
  //FIXXME Heli - make it working
  grid_share.AddFilterEvent(dc_group_in.getDescriptionStoreId,'uids');
  //grid_share.AddFilterEvent(dc_group_out.getDescriptionStoreId,'uids');

  share         := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_share,sub_sec_share,nil,nil,nil,true,2,3);
  Result        := share;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_CreateVFS(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin

  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESERVER) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GFRE_DBI.GetSystemScheme(TFRE_DB_VIRTUAL_FILESERVER,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$vfs_add_diag_cap'),600,0,true,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
  res.SetElementValue('pool','zones');
  serverfunc := CSCF(TFRE_DB_VIRTUAL_FILESERVER.ClassName,'NewOperation','collection','service');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;


function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESERVER) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_VFSDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$vfs_delete'),'images_apps/firmbox_storage/delete_vfs.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  vfs           : IFRE_DB_Object;
  sel_guid      : TGUID;
  dom_guid      : TGUID;
  dc_groupin    : IFRE_DB_DERIVED_COLLECTION;
begin
  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
    if dc.Fetch(sel_guid,vfs) then begin
      GFRE_DBI.GetSystemSchemeByName(vfs.SchemeClass,scheme);
      dom_guid := vfs.Field('domainid').AsGUID;
      dc_groupin := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
      dc_groupin.AddUIDFieldFilter('*domain*','domainid',TFRE_DB_GUIDArray.Create(dom_guid),dbnf_EXACT,false);

      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$vfs_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(vfs,ses);
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(vfs,'saveOperation'),fdbbt_submit);
      panel.contentId:='VIRTUAL_FS_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$vfs_content_header'));
    panel.contentId:='VIRTUAL_FS_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  sf:=CWSF(@WEB_VFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'$vfs_delete_diag_cap');
  msg:=_getVFSNames(input.Field('selected').AsStringArr,conn);
  msg:=StringReplace(app.FetchAppTextShort(ses,'$vfs_delete_diag_msg'),'%vfs_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      CheckDbResult(conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i])),'The object is referenced');
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_CreateVFSShare(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
  fileserver : TFRE_DB_String;
  dependend  : TFRE_DB_StringArray;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  dependend  := GetDependencyFiltervalues(input,'uids_ref');
  if length(dependend)=0 then begin
     Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$vfs_share_add_diag_cap'),app.FetchAppTextShort(ses,'$vfs_share_add_no_fs_msg'),fdbmt_warning,nil);
     exit;
  end;
  fileserver := dependend[0];


  GFRE_DBI.GetSystemScheme(TFRE_DB_VIRTUAL_FILESHARE,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$vfs_share_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  res.AddSchemeFormGroup(scheme.GetInputGroup('share'),ses,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('file'),ses,true,true);
  res.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);
  res.SetElementValue('fileserver',fileserver);
  res.SetElementValue('pool','zones');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_VIRTUAL_FILESHARE.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_VFSShareDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$vfs_share_delete'),'images_apps/firmbox_storage/delete_vfs_share.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  share         : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  CheckClassVisibility(ses);

  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
    if dc.Fetch(sel_guid,share) then begin
      GFRE_DBI.GetSystemSchemeByName(share.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$vfs_share_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('share'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('file'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);
      panel.FillWithObjectValues(share,ses);
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(share,'saveOperation'),fdbbt_submit);
      panel.contentId:='VIRTUAL_SHARE_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$vfs_share_content_header'));
    panel.contentId:='VIRTUAL_SHARE_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  sf:=CWSF(@WEB_VFSShareDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'$vfs_share_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,conn);
  msg:=StringReplace(app.FetchAppTextShort(ses,'$vfs_share_delete_diag_msg'),'%share_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;


function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  share_id  : TFRE_DB_NameType;
  dependend : TFRE_DB_StringArray;
begin
  dependend  := GetDependencyFiltervalues(input,'uids_ref');
  if length(dependend)=0 then begin
     Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$share_group_in_diag_cap'),app.FetchAppTextShort(ses,'$share_group_in_no_share_msg'),fdbmt_warning,nil);
     exit;
  end;
  share_id   := dependend[0];

  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_VFSShareGroupSetRead);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$share_group_setread_on'),'images_apps/firmbox_storage/share_access_set_on.png',func);
    func:=CWSF(@WEB_VFSShareGroupSetWrite);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$share_group_setwrite_on'),'images_apps/firmbox_storage/share_access_set_on.png',func);
    func:=CWSF(@WEB_VFSShareGroupClearRead);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$share_group_setread_off'),'images_apps/firmbox_storage/share_access_set_off.png',func);
    func:=CWSF(@WEB_VFSShareGroupClearWrite);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$share_group_setwrite_off'),'images_apps/firmbox_storage/share_access_set_off.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupSetRead(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result :=_setShareRoles(input,true,false,true,false,ses,app,conn);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupSetWrite(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result :=_setShareRoles(input,false,true,false,true,ses,app,conn);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupClearRead(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result :=_setShareRoles(input,true,false,false,false,ses,app,conn);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupClearWrite(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result :=_setShareRoles(input,false,true,false,false,ses,app,conn);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupInDrop(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := _setShareRoles(input,true,true,true,true,ses,app,conn);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareGroupOutDrop(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := _setShareRoles(input,true,true,false,false,ses,app,conn);
end;

{ TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD }

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD._GetFileServerID(conn: IFRE_DB_CONNECTION): TGuid;
var coll  : IFRE_DB_COLLECTION;
    id    : TGuid;
    hlt   : boolean;

  procedure _get(const obj:IFRE_DB_Object ; var halt : boolean);
  begin
    if obj.IsA(TFRE_DB_GLOBAL_FILESERVER.ClassName) then begin
      id   := obj.UID;
      halt := true;
    end;
  end;

begin
  coll := conn.Collection('service');
  hlt  := false;
  coll.ForAllBreak(@_get,hlt);
  if not hlt then
    raise EFRE_DB_Exception.Create(edb_ERROR,'GLOBAL FILESERVER ID NOT FOUND ????');
  result := id;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD._getShareNames(const shares: TFRE_DB_StringArray; const conn: IFRE_DB_CONNECTION): String;
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

class procedure TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$fileserver_global_description')
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
    fileserverid  : TGUID;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,nfs_tr_Grid);
    with nfs_tr_Grid do begin
      AddOneToOnescheme('objname','export',app.FetchAppTextShort(session,'$nfs_export'));
      AddOneToOnescheme('pool','pool',app.FetchAppTextShort(session,'$nfs_pool'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$nfs_desc'));
      AddOneToOnescheme('refer_mb','refer',app.FetchAppTextShort(session,'$nfs_refer'));
      AddOneToOnescheme('used_mb','used',app.FetchAppTextShort(session,'$nfs_used'));
      AddOneToOnescheme('quota_mb','avail',app.FetchAppTextShort(session,'$nfs_avail'));
    end;
    nfs_share_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
    with nfs_share_dc do begin
      SetDeriveParent(conn.Collection('fileshare'));
      fileserverId:= _GetFileserverID(conn);
      AddUIDFieldFilter('Fileserver','fileserver',TFRE_DB_GUIDArray.Create(fileserverId),dbnf_EXACT,false);
      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_NFS_FILESHARE.ClassName));
      SetDeriveTransformation(nfs_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,'',CWSF(@WEB_NFSMenu),nil,CWSF(@WEB_NFSContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,nfs_access_tr_Grid);
    with nfs_access_tr_Grid do begin
      AddOneToOnescheme('accesstype','accesstype',app.FetchAppTextShort(session,'$nfs_accesstype'));
      AddOneToOnescheme('subnet','subnet',app.FetchAppTextShort(session,'$nfs_accesssubnet'));
    end;
    nfs_access_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_ACCESS_GRID');
    with nfs_access_dc do begin
      SetReferentialLinkMode('TFRE_DB_NFS_ACCESS|FILESHARE',false);
//      SetDeriveParent(conn.Collection('fileshare_access'));
      SetDeriveTransformation(nfs_access_tr_Grid);
//      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_NFS_ACCESS.ClassName));
      SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'$nfs_access'),nil,'',CWSF(@WEB_NFSAccessMenu),nil,nil,nil,nil);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,lun_tr_Grid);
    with lun_tr_Grid do begin
      AddOneToOnescheme('objname','LUN',app.FetchAppTextShort(session,'$lun_guid'));
      AddOneToOnescheme('pool','pool',app.FetchAppTextShort(session,'$lun_pool'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$lun_desc'));
      AddOneToOnescheme('size_mb','size',app.FetchAppTextShort(session,'$lun_size'));
    end;
    lun_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
    with lun_dc do begin
      SetDeriveParent(conn.Collection('fileshare'));
      fileserverId:= _GetFileserverID(conn);
      AddUIDFieldFilter('Fileserver','fileserver',TFRE_DB_GUIDArray.Create(fileserverId),dbnf_EXACT,false);
      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_LUN.ClassName));
      SetDeriveTransformation(lun_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',nil,'',CWSF(@WEB_LUNMenu),nil,CWSF(@WEB_LUNContent));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,lun_view_tr_Grid);
    with lun_view_tr_Grid do begin
      AddOneToOnescheme('initiatorgroup','initiatorgroup',app.FetchAppTextShort(session,'$lun_view_initiatorgroup'));
      AddOneToOnescheme('targetgroup','targetgroup',app.FetchAppTextShort(session,'$lun_view_targetgroup'));
    end;
    lun_view_dc := session.NewDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_VIEW_GRID');
    with lun_view_dc do begin
      SetReferentialLinkMode('TFRE_DB_LUN_VIEW|FILESHARE',false);
//      SetDeriveParent(conn.Collection('fileshare_access'));
      SetDeriveTransformation(lun_view_tr_Grid);
//      AddSchemeFilter('SCH',TFRE_DB_StringArray.Create(TFRE_DB_LUN_VIEW.ClassName));
      SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'$lun_view'),nil,'',CWSF(@WEB_LUNViewMenu),nil,nil,nil,nil);
    end;

  end;
end;


function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sub_sec_s     : TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility(ses);

  sub_sec_s        := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentFilerNFS),app.FetchAppTextShort(ses,'$storage_global_filer_nfs'),1,'nfs');
  sub_sec_s.AddSection.Describe(CWSF(@WEB_ContentFilerLUN),app.FetchAppTextShort(ses,'$storage_global_filer_lun'),1,'lun');

  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,sub_sec_s,nil,TFRE_DB_HTML_DESC.create.Describe('<b>'+app.FetchAppTextShort(ses,'$global_info')+'</b>'));

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
  CheckClassVisibility(ses);

  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  dc_share_nfs := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
  grid_nfs     := dc_share_nfs.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NFS_FILESHARE) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_create_nfs_export');
    grid_nfs.AddButton.Describe(CWSF(@WEB_CreateNFSExport),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_delete_nfs_export');
    grid_nfs.AddButton.Describe(CWSF(@WEB_NFSDelete),'',txt.Getshort,txt.GetHint,fdgbd_multi);
    txt.Finalize;
  end;

  dc_share_nfs_access := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_ACCESS_GRID');
  grid_nfs_access     := dc_share_nfs_access.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if  conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NFS_ACCESS) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_create_nfs_access');
    grid_nfs_access.AddButton.Describe(CWSF(@WEB_NFSAccessCreate),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if  conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_modify_nfs_access');
    grid_nfs_access.AddButton.Describe(CWSF(@WEB_NFSAccessModify),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;
  if  conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_delete_nfs_access');
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
  CheckClassVisibility(ses);

  dc_lun     := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
  grid_lun   := dc_lun.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_LUN) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_create_lun');
    grid_lun.AddButton.Describe(CWSF(@WEB_CreateLUN),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN) then begin
    txt:=app.FetchAppTextFull(ses,'$tb_delete_lun');
    grid_lun.AddButton.Describe(CWSF(@WEB_LUNDelete),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;

  dc_lun_view   := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_VIEW_GRID');
  grid_lun_view := dc_lun_view.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_LUN_VIEW)  then begin
    txt:=app.FetchAppTextFull(ses,'$tb_create_lun_view');
    grid_lun_view.AddButton.Describe(CWSF(@WEB_CreateLUNView),'',txt.Getshort,txt.GetHint);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW)  then begin
    txt:=app.FetchAppTextFull(ses,'$tb_lunview_modify');
    grid_lun_view.AddButton.Describe(CWSF(@WEB_LUNViewModify),'',txt.Getshort,txt.GetHint,fdgbd_single);
    txt.Finalize;
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN_VIEW)  then begin
    txt:=app.FetchAppTextFull(ses,'$tb_lunview_delete');
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
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NFS_FILESHARE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GetSystemScheme(TFRE_DB_NFS_FILESHARE,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$nfs_add_diag_cap'),600);
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
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessCreate(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_NFS_ACCESS) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GetSystemScheme(TFRE_DB_NFS_ACCESS,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$nfsaccess_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
//  res.SetElementValue('fileshare','');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare_access');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  nfs           : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  if input.Field('SELECTED').ValueCount>0  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_NFS_GRID');
    if dc.Fetch(sel_guid,nfs) then begin
      GetSystemSchemeByName(nfs.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$nfs_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('nfs'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('file'),ses,true,true);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);
      panel.FillWithObjectValues(nfs,ses);
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(nfs,'saveOperation'),fdbbt_submit);
      panel.contentId := 'GLOBAL_NFS_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$nfs_content_header'));
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
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_NFSDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_delete_nfs_export'),'',func);
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then
     raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  sf:=CWSF(@WEB_NFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'$nfs_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppTextShort(ses,'$nfs_delete_diag_msg'),'%share_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_FILESHARE) then
     raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
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
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) or conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS) then
      begin
        func:=CWSF(@WEB_NFSAccessModify);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_modify_nfs_access'),'',func);
      end;
    if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) then
      begin
        func:=CWSF(@WEB_NFSAccessDelete);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_delete_nfs_access'),'',func);
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS)
    then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_delete_single_select'));

  sf:=CWSF(@WEB_NFSAccessDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'$nfs_access_delete_diag_cap');
  CheckDbResult(conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[0]),obj),'TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessDelete');

  msg:=StringReplace(app.FetchAppTextShort(ses,'$nfs_access_delete_diag_msg'),'%access_type%',obj.Field('accesstype').AsString,[rfReplaceAll]);
  msg:=StringReplace(msg,'%access_host%',obj.Field('subnet').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i: Integer;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_NFS_ACCESS) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessModify(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
  obj        : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_NFS_ACCESS)
    then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_modify_single_select'));

  GetSystemScheme(TFRE_DB_NFS_ACCESS,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$nfsaccess_modify_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);

  CheckDbResult(conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('selected').AsString),obj),'TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_NFSAccessModify');
  res.FillWithObjectValues(obj,ses);

  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_NFS_FILESHARE.ClassName,'SaveOperation');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_CreateLUN(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_LUN)
    then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GetSystemScheme(TFRE_DB_LUN,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$lun_add_diag_cap'),600);
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
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_CreateLUNView(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_LUN_VIEW)
    then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  GetSystemScheme(TFRE_DB_LUN_VIEW,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$lunview_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
//  res.SetElementValue('fileshare','');
  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN_VIEW.ClassName,'NewOperation');
  serverFunc.AddParam.Describe('collection','fileshare_access');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_LUNDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_delete_lun'),'',func);
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
  sel_guid      : TGUID;

begin
  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('GLOBAL_FILESERVER_MOD_LUN_GRID');
    if dc.Fetch(sel_guid,nfs) then begin
      GetSystemSchemeByName(nfs.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$lun_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('lun'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('volume'),ses,true,false);
      panel.AddSchemeFormGroup(scheme.GetInputGroup('advanced'),ses,true,true);
      panel.FillWithObjectValues(nfs,ses);
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(nfs,'saveOperation'),fdbbt_submit);
      panel.contentId:='GLOBAL_LUN_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$lun_content_header'));
    panel.contentId:='GLOBAL_LUN_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg: String;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_delete_single_select'));

  sf:=CWSF(@WEB_LUNDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'$lun_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppTextShort(ses,'$lun_delete_diag_msg'),'%guid_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
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
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) or conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW) then
      begin
        func:=CWSF(@WEB_LUNViewModify);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_lunview_modify'),'',func);
      end;
    if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
      begin
        func:=CWSF(@WEB_LUNViewDelete);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_lunview_delete'),'',func);
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_delete_single_select'));

  sf:=CWSF(@WEB_LUNViewDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=app.FetchAppTextShort(ses,'$lunview_delete_diag_cap');
  msg:=_getShareNames(input.Field('selected').AsStringArr,GetDBConnection(input));
  msg:=StringReplace(app.FetchAppTextShort(ses,'$lunview_delete_diag_msg'),'%guid_str%',msg,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i: Integer;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      //FIXXME: Errorhandling
      conn.Delete(GFRE_BT.HexString_2_GUID(input.Field('selected').AsStringItem[i]));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewModify(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
  obj        : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_modify_single_select'));

  GetSystemScheme(TFRE_DB_LUN_VIEW,scheme);
  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$lunview_modify_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);

  CheckDbResult(conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('selected').AsString),obj),'TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.WEB_LUNViewModify');
  res.FillWithObjectValues(obj,ses);

  serverfunc :=TFRE_DB_SERVER_FUNC_DESC.create.Describe(TFRE_DB_LUN_VIEW.ClassName,'SaveOperation');
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),serverfunc,fdbbt_submit);
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
  InitModuleDesc('$backup_description')
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
//      AddOneToOnescheme('parentid','parentid',app.FetchAppTextShort(ses,'$backup_parent'));
      AddMatchingReferencedField('parentid','displayname','parent',app.FetchAppTextShort(session,'$backup_share'));
      AddOneToOnescheme('creation','creation',app.FetchAppTextShort(session,'$backup_creation'),dt_date);
      AddOneToOnescheme('used_mb','used',app.FetchAppTextShort(session,'$backup_used'));
      AddOneToOnescheme('refer_mb','refer',app.FetchAppTextShort(session,'$backup_refer'));
//      AddOneToOnescheme('objname','snapshot',app.FetchAppTextShort(ses,'$backup_snapshot'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', app.FetchAppTextShort(session,'$backup_desc'));
    end;
    snap_dc := session.NewDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
    with snap_dc do begin
      SetDeriveParent(conn.Collection('snapshot'));
      SetDeriveTransformation(snap_tr_Grid);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable,cdgf_Multiselect],'',nil,'',CWSF(@WEB_SnapshotMenu),nil,CWSF(@WEB_ContentSnapshot));
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
  CheckClassVisibility(ses);

  sub_sec   := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);

  dc_snap       := ses.FetchDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
  grid_snap     := dc_snap.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

    if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_LUN_VIEW) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_SNAPSHOT) then begin
    txt:=app.FetchAppTextFull(ses,'$backup_snapshot_delete');
    grid_snap.AddButton.Describe(CWSF(@WEB_DeleteSnapshot),'images_apps/firmbox_storage/delete_snapshot.png',txt.Getshort,txt.GetHint,fdgbd_multi);
    txt.Finalize;
  end;

  sub_sec.AddSection.Describe(CWSF(@WEB_ContentSnapshot),app.FetchAppTextShort(ses,'$backup_snapshot_properties'),1,'backup_properties');

  //    CSF(@WEB_ContentSnapshot)
  backup  := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_snap,sub_sec,nil,nil,nil,true,1,1);
  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,backup,nil,TFRE_DB_HTML_DESC.create.Describe('<b>'+app.FetchAppTextShort(ses,'$backup_info')+'</b>'));
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_ContentSnapShot(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  dc            : IFRE_DB_DERIVED_COLLECTION;
  snap          : IFRE_DB_Object;
  sel_guid      : TGUID;

begin
  if input.FieldExists('SELECTED') and (input.Field('SELECTED').ValueCount>0)  then begin
    sel_guid := input.Field('SELECTED').AsGUID;
    dc       := ses.FetchDerivedCollection('BACKUP_MOD_SNAPSHOT_GRID');
    if dc.Fetch(sel_guid,snap) then begin
      GetSystemSchemeByName(snap.SchemeClass,scheme);
      panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$backup_content_header'));
      panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      panel.FillWithObjectValues(snap,ses);
      panel.AddButton.Describe('Save',TFRE_DB_SERVER_FUNC_DESC.create.Describe(snap,'saveOperation'),fdbbt_submit);
      panel.contentId:='BACKUP_SNAP_CONTENT';
      Result:=panel;
    end;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(app.FetchAppTextShort(ses,'$backup_content_header'));
    panel.contentId:='BACKUP_SNAP_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_SnapshotMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_SNAPSHOT) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_DeleteSnapshot);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(app.FetchAppTextShort(ses,'$backup_snapshot_delete'),'images_apps/firmbox_storage/delete_snapshot.png',func);
    Result:=res;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_BACKUP_MOD.WEB_DeleteSnapshot(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$backup_snapshot_delete_diag_cap'),app.FetchAppTextShort(ses,'$backup_snapshot_delete_diag_msg'),fdbmt_info,nil);
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
          zfs_rl_stripe: raid_str:=app.FetchAppTextShort(session,'$add_disks_rl_stripe');
          zfs_rl_mirror: raid_str:=app.FetchAppTextShort(session,'$add_disks_rl_mirror');
          zfs_rl_z1: raid_str:=app.FetchAppTextShort(session,'$add_disks_rl_z1');
          zfs_rl_z2: raid_str:=app.FetchAppTextShort(session,'$add_disks_rl_z2');
          zfs_rl_z3: raid_str:=app.FetchAppTextShort(session,'$add_disks_rl_z3');
        end;
        menu.AddEntry.Describe(StringReplace(app.FetchAppTextShort(session,'$add_disks_storage_ex_same'),'%raid_level%',raid_str,[rfReplaceAll]),'images_apps/firmbox_storage/expand_storage_disks_same.png',sf);
      end;
      sub:=menu.AddMenu.Describe(app.FetchAppTextShort(session,'$add_disks_storage_ex_other'),'images_apps/firmbox_storage/expand_storage_disks_other.png');
    end else begin
      sub:=menu.AddMenu.Describe(app.FetchAppTextShort(session,'$add_disks_storage'),'images_apps/firmbox_storage/add_storage_disks.png');
    end;
    if storageRL<>zfs_rl_stripe then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
      sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_stripe'),'images_apps/firmbox_storage/expand_storage_disks_s.png',sf);
    end;
    if storageRL<>zfs_rl_mirror then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
      sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_mirror'),'images_apps/firmbox_storage/expand_storage_disks_m.png',sf);
    end;
    if storageRL<>zfs_rl_z1 then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
      sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_z1'),'images_apps/firmbox_storage/expand_storage_disks_z1.png',sf);
    end;
    if storageRL<>zfs_rl_z2 then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
      sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_z2'),'images_apps/firmbox_storage/expand_storage_disks_z2.png',sf);
    end;
    if storageRL<>zfs_rl_z3 then begin
      sf:=CWSF(@WEB_AssignStorageDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('expand','true');
      sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
      sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_z3'),'images_apps/firmbox_storage/expand_storage_disks_z3.png',sf);
    end;
    if Length(addStorage)>1 then begin
      sub:=menu.AddMenu.Describe(app.FetchAppTextShort(session,'$add_disks_storage'),'images_apps/firmbox_storage/add_storage_disks.png');
    end else begin
      sub:=menu;
    end;
    for i := 0 to Length(addStorage) - 1 do begin
      vdev:=addStorage[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
      if vdev.raidLevel=zfs_rl_undefined then begin
        subsub:=sub.AddMenu.Describe(StringReplace(app.FetchAppTextShort(session,'$add_disks_storage_to'),'%vdev%',vdev.caption,[rfReplaceAll]),'images_apps/firmbox_storage/add_storage_disks.png');
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
        subsub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_stripe'),'images_apps/firmbox_storage/add_storage_disks_s.png',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
        subsub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_mirror'),'images_apps/firmbox_storage/add_storage_disks_m.png',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
        subsub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_z1'),'images_apps/firmbox_storage/add_storage_disks_z1.png',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
        subsub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_z2'),'images_apps/firmbox_storage/add_storage_disks_z2.png',sf);
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
        subsub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_z3'),'images_apps/firmbox_storage/add_storage_disks_z3.png',sf);
      end else begin
        sf:=CWSF(@WEB_AssignStorageDisk);
        sf.AddParam.Describe('disks',disks);
        sf.AddParam.Describe('pool',pool.getId);
        sf.AddParam.Describe('add',vdev.getId);
        sub.AddEntry.Describe(StringReplace(app.FetchAppTextShort(session,'$add_disks_storage_to'),'%vdev%',vdev.caption,[rfReplaceAll]),'images_apps/firmbox_storage/add_storage_disks.png',sf);
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
    menu.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_cache'),'images_apps/firmbox_storage/add_cache_disks.png',sf);
  end;

  procedure _addLogMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const expandLog: Boolean; const addLog: IFRE_DB_ObjectArray);
  var
    i    : Integer;
    vdev : TFRE_DB_ZFS_VDEV;
    sub  : TFRE_DB_MENU_DESC;
    sf   : TFRE_DB_SERVER_FUNC_DESC;
  begin
    if expandLog then begin
      sub:=menu.AddMenu.Describe(app.FetchAppTextShort(session,'$add_disks_log_ex'),'images_apps/firmbox_storage/expand_log_disks.png');
    end else begin
      sub:=menu.AddMenu.Describe(app.FetchAppTextShort(session,'$add_disks_log'),'images_apps/firmbox_storage/add_log_disks.png');
    end;
    sf:=CWSF(@WEB_AssignLogDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('expand','true');
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_stripe]);
    sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_stripe'),'images_apps/firmbox_storage/expand_storage_disks_s.png',sf);
    sf:=CWSF(@WEB_AssignLogDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('expand','true');
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
    sub.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_rl_mirror'),'images_apps/firmbox_storage/expand_storage_disks_m.png',sf);
    if Length(addLog)>1 then begin
      sub:=menu.AddMenu.Describe(app.FetchAppTextShort(session,'$add_disks_log'),'images_apps/firmbox_storage/add_log_disks.png');
    end else begin
      sub:=menu;
    end;
    for i := 0 to Length(addLog) - 1 do begin
      vdev:=addLog[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
      sf:=CWSF(@WEB_AssignLogDisk);
      sf.AddParam.Describe('disks',disks);
      sf.AddParam.Describe('pool',pool.getId);
      sf.AddParam.Describe('add',vdev.getId);
      sub.AddEntry.Describe(StringReplace(app.FetchAppTextShort(session,'$add_disks_log_to'),'%vdev%',vdev.caption,[rfReplaceAll]),'images_apps/firmbox_storage/add_log_disks.png',sf);
    end;
  end;

  procedure _addSpareMenu(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ);
  var
    sf : TFRE_DB_SERVER_FUNC_DESC;
  begin
    sf:=CWSF(@WEB_AssignSpareDisk);
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    menu.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_spare'),'images_apps/firmbox_storage/add_spare_disks.png',sf);
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
      raise EFRE_DB_Exception.Create(app.FetchAppTextShort(session,'$error_assign_vdev_unknown_parent_type'));
    end;
    sf.AddParam.Describe('disks',disks);
    sf.AddParam.Describe('pool',pool.getId);
    sf.AddParam.Describe('add',target.getId);
    menu.AddEntry.Describe(app.FetchAppTextShort(session,'$add_disks_vdev'),'images_apps/firmbox_storage/add_disks_vdev.png',sf);
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
      sub:=menu.AddMenu.Describe(StringReplace(app.FetchAppTextShort(session,'$add_disks_pool'),'%pool%',pool.caption,[rfReplaceAll]),'images_apps/firmbox_storage/add_pool_disks.png');
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
        menu.AddEntry.Describe(app.FetchAppTextShort(session,'$cm_replace'),'images_apps/firmbox_storage/cm_replace.png',sf,target.getZFSParent(conn).getId=disk.getZFSParent(conn).getId);
      end else begin
        _addPoolMenu(menu,pool,target as TFRE_DB_ZFS_OBJ);
      end;
    end;
  end else begin
    pools := conn.Collection(CFRE_DB_ZFS_POOL_COLLECTION);
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
  blockdevicecollection:=conn.Collection(CFRE_DB_ZFS_BLOCKDEVICE_COLLECTION);
  blockdevicecollection.ForAll(@_checkBD);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getZFSObj(const conn: IFRE_DB_CONNECTION; const id: String): TFRE_DB_ZFS_OBJ;
var
  dbObj: IFRE_DB_Object;
begin
  conn.Fetch(GFRE_BT.HexString_2_GUID(id),dbObj);
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
  pools := conn.Collection('pool');
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
  pools := conn.Collection(CFRE_DB_ZFS_POOL_COLLECTION);
  hlt   := false;
  pools.ForAllBreak(@_checkPool,hlt);
  Result:=ua;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getZFSTreeObj(const conn: IFRE_DB_CONNECTION; const zfsObj: TFRE_DB_ZFS_OBJ): IFRE_DB_Object;
var
  entry : IFRE_DB_Object;
begin
  entry:=GFRE_DBI.NewObject;
  entry.Field('children').AsString:=zfsObj.Field('children').AsString;
  entry.Field('_disabledrag_').AsBoolean:=zfsObj.Field('_disabledrag_').AsBoolean;
  entry.Field('_disabledrop_').AsBoolean:=zfsObj.Field('_disabledrop_').AsBoolean;
  entry.Field('uidpath').AsStringArr:=Self.GetUIDPath;
  entry.Field('_funcclassname_').AsString:=ClassName;
  entry.Field('_childrenfunc_').AsString:='ZFSTreeGridData';
  entry.Field('dndclass').AsString:=zfsObj.Field('dndclass').AsString;
  entry.Field('id').AsString:=zfsObj.getId;
  entry.Field('caption').AsString:=zfsObj.Field('caption').AsString;
  entry.Field('iops_r').AsString:=zfsObj.iopsR;
  entry.Field('iops_w').AsString:=zfsObj.iopsW;
  entry.Field('transfer_r').AsString:=zfsObj.transferR;
  entry.Field('transfer_w').AsString:=zfsObj.transferW;
  entry.Field('icon').AsString:=zfsObj.Field('icon').AsString;
  Result:=entry;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD._getLayoutTreeObj(const conn: IFRE_DB_CONNECTION; const obj: IFRE_DB_Object): IFRE_DB_Object;
var
  entry : IFRE_DB_Object;
begin
  entry:=GFRE_DBI.NewObject;
  entry.Field('uidpath').AsStringArr:=Self.GetUIDPath;
  entry.Field('id').AsString:=obj.UID_String;
  entry.Field('_funcclassname_').AsString:=ClassName;
  entry.Field('_childrenfunc_').AsString:='LayoutTreeGridData';
  entry.Field('caption').AsString:=obj.Field('caption_layout').AsString;
  entry.Field('children').AsString:=obj.Field('children').AsString;
  entry.Field('icon').AsString:=obj.Field('icon_layout').AsString;
  entry.Field('dndclass').AsString:=obj.Field('dndclass').AsString;
  entry.Field('_disabledrag_').AsBoolean:=obj.FieldExists('_disabledrag_') and obj.Field('_disabledrag_').AsBoolean;
  Result:=entry;
end;

class procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$pools_description')
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
var
  pool_disks    : IFRE_DB_COLLECTION;
  pool_capacity : IFRE_DB_COLLECTION;



begin
  inherited MyServerInitializeModule(admin_dbc);

  //STARTUP SPEED_ENHANCEMENT
  //DISKI_HACK := Get_Stats_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  //VM_HACK    := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);

  pool_disks := admin_dbc.Collection('POOL_DISKS',true,true);
  pool_disks.DefineIndexOnField('diskid',fdbft_String,true,true);

  //// Used to fix display in startup case, when no feeder has made initial data
//  UpdateDiskCollection(pool_disks,DISKI_HACK.Get_Disk_Data_Once);

end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  main       : TFRE_DB_LAYOUT_DESC;
  pool_grid  : TFRE_DB_VIEW_LIST_DESC;
  layout_grid: TFRE_DB_VIEW_LIST_DESC;
  store      : TFRE_DB_STORE_DESC;
  store_l    : TFRE_DB_STORE_DESC;
  glayout    : TFRE_DB_VIEW_LIST_LAYOUT_DESC;
  glayout_l  : TFRE_DB_VIEW_LIST_LAYOUT_DESC;
  secs       : TFRE_DB_SUBSECTIONS_DESC;
  coll       : IFRE_DB_DERIVED_COLLECTION;
  menu       : TFRE_DB_MENU_DESC;
  submenu    : TFRE_DB_SUBMENU_DESC;
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  subsubmenu : TFRE_DB_SUBMENU_DESC;
begin
  CheckClassVisibility(ses);

  secs:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  secs.AddSection.Describe(CWSF(@WEB_PoolLayout),app.FetchAppTextShort(ses,'$pool_layout_tab'),1,'layout');
  secs.AddSection.Describe(CWSF(@WEB_PoolNotes),app.FetchAppTextShort(ses,'$pool_notes_tab'),2,'notes');

  store    := TFRE_DB_STORE_DESC.create.Describe('id',CWSF(@WEB_ZFSTreeGridData),TFRE_DB_StringArray.create('caption'),nil,nil,'pools_store');
  glayout  := TFRE_DB_VIEW_LIST_LAYOUT_DESC.create.Describe();
  glayout.AddDataElement.Describe('caption','Caption',dt_string,false,false,2,true,false,'icon');
  glayout.AddDataElement.Describe('iops_r','IOPS R [1/s]',dt_number);
  glayout.AddDataElement.Describe('iops_w','IOPS W [1/s]',dt_number);
  glayout.AddDataElement.Describe('transfer_r','Read [MB/s]',dt_number);
  glayout.AddDataElement.Describe('transfer_w','Write [MB/s]',dt_number);

  pool_grid:=TFRE_DB_VIEW_LIST_DESC.create.Describe(store,glayout,CWSF(@WEB_GridMenu),'',[cdgf_Children,cdgf_Multiselect],nil,CWSF(@WEB_PoolStructureSC),nil,CWSF(@WEB_TreeDrop));

  store_l    := TFRE_DB_STORE_DESC.create.Describe('id',CWSF(@WEB_LayoutTreeGridData),TFRE_DB_StringArray.create('caption'),nil,nil,'layout_store');
  glayout_l  := TFRE_DB_VIEW_LIST_LAYOUT_DESC.create.Describe();
  glayout_l.AddDataElement.Describe('caption','Caption',dt_string,false,false,2,true,false,'icon');
  layout_grid:=TFRE_DB_VIEW_LIST_DESC.create.Describe(store_l,glayout_l,nil,'',[cdgf_Children,cdgf_Multiselect],nil,nil,nil,CWSF(@WEB_TreeDrop));

  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then begin
    pool_grid.SetDragClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    layout_grid.SetDragClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    pool_grid.SetDropGrid(pool_grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    layout_grid.SetDropGrid(pool_grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));

    menu:=TFRE_DB_MENU_DESC.create.Describe;
    menu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_save_config'),'',CWSF(@WEB_SaveConfig),true,'pool_save');
    menu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_reset_config'),'',CWSF(@WEB_ResetConfig),true,'pool_reset');

    submenu:=menu.AddMenu.Describe(app.FetchAppTextShort(ses,'$tb_pools'),'');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_create_pool'),'',CWSF(@WEB_CreatePoolDiag));
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_import_pool'),'',CWSF(@WEB_ImportPoolDiag));
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_export_pool'),'',CWSF(@WEB_TBExportPool),true,'pool_export');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_scrub_pool'),'',CWSF(@WEB_TBScrubPool),true,'pool_scrub');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_destroy_pool'),'',CWSF(@WEB_TBDestroyPool),true,'pool_destroy');

    submenu:=menu.AddMenu.Describe(app.FetchAppTextShort(ses,'$tb_blockdevices'),'');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_identify_on'),'',CWSF(@WEB_TBIdentifyOn),true,'pool_iden_on');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_identify_off'),'',CWSF(@WEB_TBIdentifyOff),true,'pool_iden_off');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_switch_online'),'',CWSF(@WEB_TBSwitchOnline),true,'pool_switch_online');
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_switch_offline'),'',CWSF(@WEB_TBSwitchOffline),true,'pool_switch_offline');

    subsubmenu:=submenu.AddMenu.Describe(app.FetchAppTextShort(ses,'$tb_assign'),'',true,'pool_assign');
    _addDisksToPool(subsubmenu,nil,nil,nil,app,conn,ses);

    subsubmenu:=submenu.AddMenu.Describe(app.FetchAppTextShort(ses,'$tb_replace'),'',true,'pool_replace');
    _replaceDisks(subsubmenu,'',conn);

    submenu:=menu.AddMenu.Describe(app.FetchAppTextShort(ses,'$tb_change_rl'),'');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_rl_mirror'),'',sf,true,'pool_rl_mirror');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_rl_z1'),'',sf,true,'pool_rl_z1');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_rl_z2'),'',sf,true,'pool_rl_z2');
    sf:=CWSF(@WEB_TBChangeRaidLevel);
    sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
    submenu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_rl_z3'),'',sf,true,'pool_rl_z3');

    menu.AddEntry.Describe(app.FetchAppTextShort(ses,'$tb_remove'),'',CWSF(@WEB_TBRemoveNew),true,'pool_remove');

    pool_grid.SetMenu(menu);
    layout_grid.SetMenu(TFRE_DB_MENU_DESC.create.Describe);
  end;

  main    := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(layout_grid,pool_grid,secs,nil,nil,true,1,3,3);
  result  := TFRE_DB_LAYOUT_DESC.create.Describe.SetAutoSizedLayout(nil,main,nil,TFRE_DB_HTML_DESC.create.Describe('<b>'+app.FetchAppTextShort(ses,'$pools_info')+'</b>'));
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_PoolStructureSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedZfsObjs')
  end;

  _updateToolbar(conn,ses);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBAssign(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));
  //FIXXME implement me
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBSwitchOnline(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_SwitchOnline(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBSwitchOffline(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_SwitchOffline(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBIdentifyOn(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_IdentifyOn(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBIdentifyOff(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_IdentifyOff(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBRemoveNew(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_RemoveNew(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBChangeRaidLevel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_ChangeRaidLevel(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBDestroyPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_DestroyPool(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBExportPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('pool').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsString;
  Result:=WEB_ExportPool(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_TBScrubPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  input.Field('pool').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsString;
  Result:=WEB_ScrubPool(input,ses,app,conn);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_PoolLayout(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  CheckClassVisibility(ses);
  Result:=TFRE_DB_HTML_DESC.create.Describe('Feature disabled in Demo Mode.');
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_PoolNotes(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  load_func             : TFRE_DB_SERVER_FUNC_DESC;
  save_func             : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_NOTE) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  load_func   := CWSF(@WEB_NoteLoad);
  save_func   := CWSF(@WEB_NoteSave);

  load_func.AddParam.Describe('linkid','zones');
  save_func.AddParam.Describe('linkid','zones');

  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CWSF(@WEB_NoteStartEdit),CWSF(@WEB_NoteStopEdit));
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ZFSTreeGridData(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_STORE_DATA_DESC;
  pools     : IFRE_DB_COLLECTION;
  count     : Integer;
  dbObj     : IFRE_DB_Object;
  parentObj : TFRE_DB_ZFS_OBJ;
  children  : IFRE_DB_ObjectArray;
  i         : Integer;
  zfs_obj   : TFRE_DB_ZFS_OBJ;
  ua        : IFRE_DB_Object;

  procedure _ProcessPools(const obj:IFRE_DB_Object);
  var
    zfsObj: TFRE_DB_ZFS_OBJ;
  begin
    zfsObj:=obj.Implementor_HC as TFRE_DB_ZFS_OBJ;
    //if zfsObj is TFRE_DB_ZFS_UNASSIGNED then begin
    //  ua:=_getZFSTreeObj(conn,zfsObj);
    //end else begin
      res.addEntry(_getZFSTreeObj(conn,zfsObj));
    //end;
    count:=count+1;
  end;

begin
  CheckClassVisibility(ses);

  if input.FieldExists('parentid') then begin
    parentObj:=_getZFSObj(conn,input.Field('parentid').AsString);

    if not Assigned(parentObj) then raise EFRE_DB_Exception.Create('Parent object not found.');
    children:=parentObj.getZFSChildren(conn);
    res:=TFRE_DB_STORE_DATA_DESC.create.Describe(Length(children));
    for i := 0 to Length(children) - 1 do begin
      zfs_obj:=children[i].Implementor_HC as TFRE_DB_ZFS_OBJ;
      res.addEntry(_getZFSTreeObj(conn,zfs_obj));
    end;
  end else begin
    count:=0;
    pools := conn.Collection(CFRE_DB_ZFS_POOL_COLLECTION);
    res:=TFRE_DB_STORE_DATA_DESC.create;
    //ua := nil;
    pools.ForAll(@_ProcessPools);
    //if Assigned(ua) then begin
    //  res.addEntry(ua);
    //end;
    res.Describe(count);
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_LayoutTreeGridData(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  enclosures: IFRE_DB_COLLECTION;
  count     : Integer;
  res       : TFRE_DB_STORE_DATA_DESC;
  dbObj     : IFRE_DB_Object;
  refs      : TFRE_DB_GUIDArray;
  obj       : IFRE_DB_Object;
  i         : Integer;

  procedure _ProcessEnclosures(const obj:IFRE_DB_Object);
  begin
    res.addEntry(_getLayoutTreeObj(conn,obj));
    count:=count+1;
  end;

begin
  CheckClassVisibility(ses);

  if input.FieldExists('parentid') then begin
    conn.Fetch(GFRE_BT.HexString_2_GUID(input.Field('parentid').AsString),dbObj);
    if not Assigned(dbObj) then raise EFRE_DB_Exception.Create('Parent object not found.');

    refs:=conn.GetReferences(dbObj.UID,false,''); //get refs of spezific field (parent_in_zfs_uid)

    res:=TFRE_DB_STORE_DATA_DESC.create;
    count:=0;
    for i := 0 to Length(refs) - 1 do begin
      CheckDbResult(conn.Fetch(refs[i],obj),'TFRE_DB_ZFS_OBJ.getChildren');
      if obj.Implementor_HC is TFRE_DB_PHYS_DISK then begin
        res.addEntry(_getLayoutTreeObj(conn,obj));
      end;
    end;
    res.Describe(count);
  end else begin
    count:=0;
    enclosures := conn.Collection(CFRE_DB_ENCLOSURE_COLLECTION);
    res:=TFRE_DB_STORE_DATA_DESC.create;
    enclosures.ForAll(@_ProcessEnclosures);
    res.Describe(count);
  end;
  Result:=res;
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
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

//  GFRE_BT.SeperateString(input.Field('selected').AsString,',',sIdPath);

//  pools.Fetch(GFRE_BT.HexString_2_GUID(sIdPath[0]),dbObj);
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
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then begin
    if input.Field('selected').ValueCount>1 then begin //multiselection
      _getMultiselectionActions(conn,input.Field('selected').AsStringArr,fnIdentifyOn,fnIdentifyOff,fnRemove,fnAssign,fnSwitchOffline,fnSwitchOnline,fnSwitchOfflineDisabled,fnSwitchOnlineDisabled);
      if fnAssign then begin;
        _addDisksToPool(res,nil,nil,input.Field('selected').AsStringArr,app,conn,ses);
      end;
      if fnRemove then begin
        sf:=CWSF(@WEB_RemoveNew);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(StringReplace(app.FetchAppTextShort(ses,'$cm_multiple_remove'),'%num%',IntToStr(input.field('selected').ValueCount),[rfReplaceAll]),'images_apps/firmbox_storage/cm_multiple_remove.png',sf);
      end;
      if fnIdentifyOn then begin
        sf:=CWSF(@WEB_IdentifyOn);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_identify_on'),'images_apps/firmbox_storage/cm_identify.png',sf);
      end;
      if fnIdentifyOff then begin
        sf:=CWSF(@WEB_IdentifyOff);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_identify_off'),'images_apps/firmbox_storage/cm_identify.png',sf);
      end;
      if fnSwitchOffline then begin
        sf:=CWSF(@WEB_SwitchOffline);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_switch_offline'),'images_apps/firmbox_storage/cm_switch_offline.png',sf,fnSwitchOfflineDisabled);
      end;
      if fnSwitchOnline then begin
        sf:=CWSF(@WEB_SwitchOnline);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_switch_online'),'images_apps/firmbox_storage/cm_switch_online.png',sf,fnSwitchOnlineDisabled);
      end;
      Result:=res;
    end else begin //single selection
      zfsObj:=_getZFSObj(conn,input.Field('selected').AsString);
      pool:=zfsObj.getPool(conn);
      if (pool is TFRE_DB_ZFS_UNASSIGNED) and (zfsObj is TFRE_DB_ZFS_BLOCKDEVICE) then begin
        _addDisksToPool(res,nil,nil,input.Field('selected').AsStringArr,app,conn,ses);
        sub:=res.AddMenu.Describe(app.FetchAppTextShort(ses,'$cm_replace'),'images_apps/firmbox_storage/cm_replace.png');
        _replaceDisks(sub,input.Field('selected').AsString,conn);
      end else begin
        if (zfsObj is TFRE_DB_ZFS_BLOCKDEVICE) and not zfsObj.getIsNew then begin
          if (zfsObj as TFRE_DB_ZFS_BLOCKDEVICE).isOffline then begin
            sf:=CWSF(@WEB_SwitchOnline);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_switch_online'),'images_apps/firmbox_storage/cm_switch_online.png',sf);
          end else begin
            sf:=CWSF(@WEB_SwitchOffline);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_switch_offline'),'images_apps/firmbox_storage/cm_switch_offline.png',sf);
          end;
        end;
      end;
      if zfsObj.getisNew then begin
        sf:=CWSF(@WEB_RemoveNew);
        sf.AddParam.Describe('selected',input.Field('selected').AsString);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_remove'),'images_apps/firmbox_storage/cm_remove.png',sf);
        if (zfsObj is TFRE_DB_ZFS_VDEV) and (zfsObj.getZFSParent(conn).Implementor_HC is TFRE_DB_ZFS_DATASTORAGE) then begin
          sub:=res.AddMenu.Describe(app.FetchAppTextShort(ses,'$cm_change_raid_level'),'images_apps/firmbox_storage/cm_change_raid_level.png');
          rl:=(zfsObj as TFRE_DB_ZFS_VDEV).raidLevel;
          if rl<>zfs_rl_mirror then begin
            sf:=CWSF(@WEB_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_mirror]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_rl_mirror'),'images_apps/firmbox_storage/cm_rl_mirror.png',sf);
          end;
          if rl<>zfs_rl_z1 then begin
            sf:=CWSF(@WEB_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z1]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_rl_z1'),'images_apps/firmbox_storage/cm_rl_z1.png',sf);
          end;
          if rl<>zfs_rl_z2 then begin
            sf:=CWSF(@WEB_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z2]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_rl_z2'),'images_apps/firmbox_storage/cm_rl_z2.png',sf);
          end;
          if rl<>zfs_rl_z3 then begin
            sf:=CWSF(@WEB_ChangeRaidLevel);
            sf.AddParam.Describe('rl',CFRE_DB_ZFS_RAID_LEVEL[zfs_rl_z3]);
            sf.AddParam.Describe('selected',input.Field('selected').AsString);
            sub.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_rl_z3'),'images_apps/firmbox_storage/cm_rl_z3.png',sf);
          end;
        end;
      end else begin
        if zfsObj is TFRE_DB_ZFS_POOL then begin
          sf:=CWSF(@WEB_ScrubPool);
          sf.AddParam.Describe('pool',input.Field('selected').AsString);
          res.AddEntry.Describe(StringReplace(app.FetchAppTextShort(ses,'$cm_scrub_pool'),'%pool%',zfsObj.caption,[rfReplaceAll]),'',sf,zfsObj.getIsModified);
          sf:=CWSF(@WEB_ExportPool);
          sf.AddParam.Describe('pool',input.Field('selected').AsString);
          res.AddEntry.Describe(StringReplace(app.FetchAppTextShort(ses,'$cm_export_pool'),'%pool%',zfsObj.caption,[rfReplaceAll]),'',sf,zfsObj.getIsModified);
          sf:=CWSF(@WEB_DestroyPool);
          sf.AddParam.Describe('pool',input.Field('selected').AsString);
          res.AddEntry.Describe(StringReplace(app.FetchAppTextShort(ses,'$cm_destroy_pool'),'%pool%',zfsObj.caption,[rfReplaceAll]),'images_apps/firmbox_storage/cm_destroy_pool.png',sf,zfsObj.getIsModified);
        end;
      end;
      if zfsObj.canIdentify then begin
        sf:=CWSF(@WEB_IdentifyOn);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_identify_on'),'images_apps/firmbox_storage/cm_identify.png',sf);
        sf:=CWSF(@WEB_IdentifyOff);
        sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(app.FetchAppTextShort(ses,'$cm_identify_off'),'images_apps/firmbox_storage/cm_identify.png',sf);
      end;
    end;
    Result:=res;
  end;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_UpdatePoolsTree(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var disk_data   : IFRE_DB_Object;
    pool_disks  : IFRE_DB_COLLECTION;
begin
  //FIXXXME - please implement me!
  pool_disks := GetDBConnection(input).Collection('POOL_DISKS',false,true);
//  disk_data := DISKI_HACK.Get_Disk_Data;
//  UpdateDiskCollection(pool_disks,disk_data);
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_CreatePool(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pools   : IFRE_DB_COLLECTION;
  vdevs   : IFRE_DB_COLLECTION;
  nameOk  : Boolean;
  lastObj : IFRE_DB_Object;
  newPool : TFRE_DB_ZFS_POOL;
  dstore  : TFRE_DB_ZFS_DATASTORAGE;

  storeup : TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update
  prevId  : String; //FIXXME - remove store update

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
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if not input.FieldPathExists('data.pool_name') then
    raise EFRE_DB_Exception.Create('WEB_CreatePool: Missing parameter pool_name');

  pools := conn.Collection(CFRE_DB_ZFS_POOL_COLLECTION);
  vdevs := conn.Collection(CFRE_DB_ZFS_VDEV_COLLECTION);
  nameOk:=true;
  pools.ForAll(@_checkPoolName);
  if not nameOk then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$create_pool_error_cap'),app.FetchAppTextShort(ses,'$create_pool_error_not_unique'),fdbmt_error);
    exit;
  end;

  newPool:=TFRE_DB_ZFS_POOL.create;
  newPool.caption:=input.FieldPath('data.pool_name').AsString;
  newPool.setIsNew;

  if Assigned(lastObj) then begin //FIXXME - remove store update
    prevId:=(lastObj.Implementor_HC as TFRE_DB_ZFS_OBJ).getId; //FIXXME - remove store update
  end else begin //FIXXME - remove store update
    prevId:=''; //FIXXME - remove store update
  end; //FIXXME - remove store update

  dstore:=newPool.createDatastorage;
  dstore.caption:=newPool.caption;
  dstore.setIsNew;

  storeup:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  storeup.addNewEntry(_getZFSTreeObj(conn,newPool),prevId); //FIXXME - remove store update

  CheckDbResult(pools.Store(newPool),'Add new pool');
  CheckDbResult(vdevs.Store(dstore),'Add new pool');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  ses.SendServerClientRequest(storeup);

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_CreatePoolDiag(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res  :TFRE_DB_DIALOG_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  res:=TFRE_DB_DIALOG_DESC.create.Describe(app.FetchAppTextShort(ses,'$create_pool_diag_cap'));
  res.AddInput.Describe(app.FetchAppTextShort(ses,'$create_pool_diag_name'),'pool_name',true);
  res.AddButton.Describe(app.FetchAppTextShort(ses,'$button_save'),CWSF(@WEB_CreatePool),fdbbt_submit);
  result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ImportPoolDiag(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$import_pool_diag_cap'),app.FetchAppTextShort(ses,'$import_pool_diag_msg'),fdbmt_info,nil);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_AssignSpareDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tspare  : TFRE_DB_ZFS_SPARE;
  i       : Integer;
  disk    : TFRE_DB_ZFS_OBJ;
  vdevs   : IFRE_DB_COLLECTION;

  res,lres: TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update
  lastIdx : String; //FIXXME - remove store update
begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  tpool:=_getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  lres:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('layout_store'); //FIXXME - remove store update
  tspare:=tpool.GetSpare(conn);
  if Assigned(tspare) then begin
    tspare.setIsModified;
    res.addUpdatedEntry(_getZFSTreeObj(conn,tspare));
    CheckDbResult(conn.Update(tspare.CloneToNewObject()),'Assign spare');
  end else begin
    lastIdx:=tpool.getLastChildId(conn); //FIXXME - remove store update
    tspare:=tpool.createSpare;
    tspare.caption:=app.FetchAppTextShort(ses,'$new_spare_caption');
    tspare.setIsNew;
    res.addNewEntry(_getZFSTreeObj(conn,tspare),lastIdx,tpool.getId); //FIXXME - remove store update
    vdevs:=conn.Collection(CFRE_DB_ZFS_VDEV_COLLECTION);
    CheckDbResult(vdevs.Store(tspare.CloneToNewObject()),'Assign spare');
  end;
  tpool.setIsModified;
  res.addUpdatedEntry(_getZFSTreeObj(conn,tpool)); //FIXXME - remove store update
  CheckDbResult(conn.Update(tpool),'Assign spare');
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=tspare.getLastChildId(conn); //FIXXME - remove store update
    disk:=_getZFSObj(conn,input.Field('disks').AsStringArr[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_assign_not_new'));
    disk.removeFromPool;
    res.addDeletedEntry(disk.getId);
    disk:=tspare.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    res.addNewEntry(_getZFSTreeObj(conn,disk),lastIdx,tspare.getId); //FIXXME - remove store update
    lres.addUpdatedEntry(_getLayoutTreeObj(conn,disk)); //FIXXME - remove store update
    CheckDbResult(conn.Update(disk),'Assign spare');
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  ses.SendServerClientRequest(lres);  //FIXXME - remove store update

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_AssignCacheDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  tpool   : TFRE_DB_ZFS_POOL;
  spool   : TFRE_DB_ZFS_ROOTOBJ;
  tcache  : TFRE_DB_ZFS_CACHE;
  i       : Integer;
  disk    : TFRE_DB_ZFS_OBJ;
  vdevs   : IFRE_DB_COLLECTION;

  res,lres: TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update
  lastIdx : String; //FIXXME - remove store update
begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  lres:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('layout_store'); //FIXXME - remove store update
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  tpool:=_getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  tcache:=tpool.GetCache(conn);
  if Assigned(tcache) then begin
    tcache.setIsModified;
    res.addUpdatedEntry(_getZFSTreeObj(conn,tcache)); //FIXXME - remove store update
    CheckDbResult(conn.Update(tcache.CloneToNewObject()),'Assign cache');
  end else begin
    lastIdx:=tpool.getLastChildId(conn); //FIXXME - remove store update
    tcache:=tpool.createCache;
    tcache.setIsNew;
    tcache.caption:=app.FetchAppTextShort(ses,'$new_cache_caption');
    res.addNewEntry(_getZFSTreeObj(conn,tcache),lastIdx,tpool.getId); //FIXXME - remove store update
    vdevs:=conn.Collection(CFRE_DB_ZFS_VDEV_COLLECTION);
    CheckDbResult(vdevs.Store(tcache.CloneToNewObject()),'Assign cache');
  end;
  tpool.setIsModified;
  res.addUpdatedEntry(_getZFSTreeObj(conn,tpool)); //FIXXME - remove store update
  CheckDbResult(conn.Update(tpool),'Assign spare');
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=tcache.getLastChildId(conn); //FIXXME - remove store update
    disk:=_getZFSObj(conn,input.Field('disks').AsStringItem[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_assign_not_new'));
    res.addDeletedEntry(disk.getId); //FIXXME - remove store update
    disk:=tcache.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    res.addNewEntry(_getZFSTreeObj(conn,disk),lastIdx,tcache.getId); //FIXXME - remove store update
    lres.addUpdatedEntry(_getLayoutTreeObj(conn,disk)); //FIXXME - remove store update
    CheckDbResult(conn.Update(disk),'Assign cache');
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  ses.SendServerClientRequest(lres);  //FIXXME - remove store update

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=res;
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

  res,lres: TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update
  lastIdx : String; //FIXXME - remove store update

begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  vdevs:=conn.Collection(CFRE_DB_ZFS_VDEV_COLLECTION);

  tpool:=_getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  lres:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('layout_store'); //FIXXME - remove store update
  tlog:=tpool.GetLog(conn);
  if Assigned(tlog) then begin
    tlog.setIsModified;
    res.addUpdatedEntry(_getZFSTreeObj(conn,tlog)); //FIXXME - remove store update
    CheckDbResult(conn.Update(tlog.CloneToNewObject),'Assign log');
    if input.FieldExists('expand') and input.Field('expand').AsBoolean then begin
      lastIdx:=tlog.getLastChildId(conn); //FIXXME - remove store update
      if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
        vdev:=tlog;
      end else begin
        vdev:=tlog.createVdev;
        vdev.caption:=StringReplace(app.FetchAppTextShort(ses,'$log_vdev_caption_'+input.Field('rl').AsString),'%num%',IntToStr(_getNextVdevNum(tlog.getZFSChildren(conn))),[rfReplaceAll]);
        vdev.setIsNew;
        vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
        res.addNewEntry(_getZFSTreeObj(conn,vdev),lastIdx,tlog.getId); //FIXXME - remove store update
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
      if not Assigned(vdev) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_assign_vdev_not_found'));
      vdev.setIsModified;
      res.addUpdatedEntry(_getZFSTreeObj(conn,vdev)); //FIXXME - remove store update
      CheckDbResult(conn.Update(vdev.CloneToNewObject),'Assign log');
    end;
  end else begin
    lastIdx:=tpool.getLastChildId(conn);
    tlog:=tpool.createLog;
    tlog.setIsNew;
    tlog.caption:=app.FetchAppTextShort(ses,'$new_log_caption');
    res.addNewEntry(_getZFSTreeObj(conn,tlog),lastIdx,tpool.getId); //FIXXME - remove store update
    CheckDbResult(vdevs.Store(tlog.CloneToNewObject()),'Assign log');
    if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
      vdev:=tlog;
    end else begin
      vdev:=tlog.createVdev;
      vdev.setIsNew;
      vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
      vdev.caption:=StringReplace(app.FetchAppTextShort(ses,'$log_vdev_caption_'+input.Field('rl').AsString),'%num%','0',[rfReplaceAll]);
      res.addNewEntry(_getZFSTreeObj(conn,vdev),'',tlog.getId); //FIXXME - remove store update
      CheckDbResult(vdevs.Store(vdev.CloneToNewObject()),'Assign log');
    end;
  end;
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=vdev.getLastChildId(conn); //FIXXME - remove store update
    disk:=_getZFSObj(conn,input.Field('disks').AsStringItem[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_assign_not_new'));
    disk.removeFromPool;
    res.addDeletedEntry(disk.getId);
    disk:=vdev.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    res.addNewEntry(_getZFSTreeObj(conn,disk),lastIdx,vdev.getId); //FIXXME - remove store update
    lres.addUpdatedEntry(_getLayoutTreeObj(conn,disk)); //FIXXME - remove store update
    CheckDbResult(conn.Update(disk),'Assign log');
  end;
  tpool.setIsModified;
  res.addUpdatedEntry(_getZFSTreeObj(conn,tpool)); //FIXXME - remove store update
  CheckDbResult(conn.Update(tpool),'Assign log');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  ses.SendServerClientRequest(lres);  //FIXXME - remove store update

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=res;
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

  res,lres        : TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update
  lastIdx    : String; //FIXXME - remove store update

begin
  if input.Field('disks').ValueCount=0 then begin
    input.Field('disks').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  end;

  vdevs:=conn.Collection(CFRE_DB_ZFS_VDEV_COLLECTION);

  tpool    := _getZFSObj(conn,input.Field('pool').AsString) as TFRE_DB_ZFS_POOL;
  res      := TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  lres     := TFRE_DB_UPDATE_STORE_DESC.create.Describe('layout_store'); //FIXXME - remove store update
  tstorage := tpool.GetDatastorage(conn);
  if Assigned(tstorage) then begin
    tstorage.setIsModified;
    res.addUpdatedEntry(_getZFSTreeObj(conn,tstorage)); //FIXXME - remove store update
    CheckDbResult(conn.Update(tstorage.CloneToNewObject),'Assign storage disk');
    if input.FieldExists('rl') and (String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe) then begin
      vdev := tstorage;
    end else begin
      if input.FieldExists('expand') and input.Field('expand').AsBoolean then begin
        lastIdx  := tstorage.getLastChildId(conn); //FIXXME - remove store update
        vdev     := tstorage.createVdev;
        vdev.caption:=StringReplace(app.FetchAppTextShort(ses,'$storage_vdev_caption_'+input.Field('rl').AsString),'%num%',IntToStr(_getNextVdevNum(tstorage.getZFSChildren(conn))),[rfReplaceAll]);
        vdev.setIsNew;
        vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
        res.addNewEntry(_getZFSTreeObj(conn,vdev),lastIdx,tstorage.getId); //FIXXME - remove store update
        CheckDbResult(vdevs.store(vdev.CloneToNewObject),'Assign storage disk');
      end else begin
        children:=tstorage.getZFSChildren(conn);
        vdev:=nil;
        for i := 0 to Length(children) - 1 do begin
          if (children[i].Implementor_HC is TFRE_DB_ZFS_VDEV) and ((children[i].Implementor_HC as TFRE_DB_ZFS_VDEV).getId=input.Field('add').AsString) then begin
            vdev:=children[i].Implementor_HC as TFRE_DB_ZFS_VDEV;
          end;
        end;
        if not Assigned(vdev) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_assign_vdev_not_found'));
        vdev.setIsModified;
        res.addUpdatedEntry(_getZFSTreeObj(conn,vdev)); //FIXXME - remove store update
        CheckDbResult(conn.Update(vdev.CloneToNewObject),'Assign storage disk');
      end;
    end;
  end else begin
    lastIdx:=tpool.getLastChildId(conn); //FIXXME - remove store update
    tstorage:=tpool.createDatastorage;
    tstorage.setIsNew;
    tstorage.caption:=tpool.caption;
    res.addNewEntry(_getZFSTreeObj(conn,tstorage),lastIdx,tpool.getId); //FIXXME - remove store update
    CheckDbResult(vdevs.store(tstorage.CloneToNewObject),'Assign storage disk');
    if String2DBZFSRaidLevelType(input.Field('rl').AsString)=zfs_rl_stripe then begin
      vdev:=tstorage;
    end else begin
      vdev:=tstorage.createVdev;
      vdev.setIsNew;
      vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
      vdev.caption:=StringReplace(app.FetchAppTextShort(ses,'$storage_vdev_caption_'+input.Field('rl').AsString),'%num%','0',[rfReplaceAll]);
      res.addNewEntry(_getZFSTreeObj(conn,vdev),'',tstorage.getId); //FIXXME - remove store update
      CheckDbResult(vdevs.store(vdev.CloneToNewObject),'Assign storage disk');
    end;
  end;
  for i := 0 to input.Field('disks').ValueCount - 1 do begin
    lastIdx:=vdev.getLastChildId(conn); //FIXXME - remove store update
    disk:=_getZFSObj(conn,input.Field('disks').AsStringItem[i]);
    spool:=disk.getPool(conn);
    if not (disk.getIsNew or spool.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_assign_not_new'));
    disk.removeFromPool;
    res.addDeletedEntry(disk.getId); //FIXXME - remove store update
    disk:=vdev.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    disk.setIsNew;
    res.addNewEntry(_getZFSTreeObj(conn,disk),lastIdx,vdev.getId); //FIXXME - remove store update
    lres.addUpdatedEntry(_getLayoutTreeObj(conn,disk)); //FIXXME - remove store update
    CheckDbResult(conn.Update(disk),'Assign storage disk');
  end;
  tpool.setIsModified;
  res.addUpdatedEntry(_getZFSTreeObj(conn,tpool)); //FIXXME - remove store update
  CheckDbResult(conn.Update(tpool),'Assign storage disk');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
  ses.SendServerClientRequest(lres);  //FIXXME - remove store update

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_RemoveNew(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool    : TFRE_DB_ZFS_ROOTOBJ;
  ua      : TFRE_DB_ZFS_UNASSIGNED;
  zfsObj  : TFRE_DB_ZFS_OBJ;
  i       : Integer;
  res,lres: TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update

  procedure _handleObj(const zfsObj: TFRE_DB_ZFS_OBJ);
  var
    children : IFRE_DB_ObjectArray;
    i        : Integer;
    pools    : IFRE_DB_COLLECTION;
    vdevs    : IFRE_DB_COLLECTION;
    lastIdx  : String; //FIXXME - remove store update
  begin
    children:=zfsObj.getZFSChildren(conn);
    for i := 0 to Length(children) - 1 do begin
      _handleObj(children[i].Implementor_HC as TFRE_DB_ZFS_OBJ);
    end;
    res.addDeletedEntry(zfsObj.getId); //FIXXME - remove store update
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      lastIdx:=ua.getLastChildId(conn); //FIXXME - remove store update
      res.addDeletedEntry(zfsObj.getId);
      zfsObj.setIsNew(false);
      zfsObj.setIsModified(false);
      zfsObj.removeFromPool;
      ua.addBlockdevice(zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
      res.addNewEntry(_getZFSTreeObj(conn,zfsObj),lastIdx,ua.getId); //FIXXME - remove store update
      lres.addUpdatedEntry(_getLayoutTreeObj(conn,zfsObj)); //FIXXME - remove store update
      CheckDbResult(conn.Update(zfsObj),'Remove new disk');
    end else begin
      if zfsObj.Implementor_HC is TFRE_DB_ZFS_POOL then begin
        pools:=conn.Collection(CFRE_DB_ZFS_POOL_COLLECTION);
        res.addDeletedEntry(zfsObj.getId);
        pools.Remove(zfsObj.UID);
      end else begin
        vdevs:=conn.Collection(CFRE_DB_ZFS_VDEV_COLLECTION);
        res.addDeletedEntry(zfsObj.getId);
        vdevs.Remove(zfsObj.UID);
      end;
    end;
  end;

begin
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  lres:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('layout_store'); //FIXXME - remove store update
  ua:=_getUnassignedPool(conn);
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    pool:=zfsObj.getPool(conn);
    if pool.getId=ua.getId then continue; //skip: already unassigned
    if not zfsObj.getIsNew then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_remove_not_new'));
    _handleObj(zfsObj);
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
  ses.SendServerClientRequest(lres);  //FIXXME - remove store update

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ChangeRaidLevel(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i,num    : Integer;
  vdev     : TFRE_DB_ZFS_VDEV;
  res      : TFRE_DB_UPDATE_STORE_DESC;
  idx      : SizeInt;
begin
  res:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  vdev:=_getZFSObj(conn,input.Field('selected').AsString).Implementor_HC as TFRE_DB_ZFS_VDEV;
  if not vdev.getIsNew then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_change_rl_not_new'));
  vdev.raidLevel:=String2DBZFSRaidLevelType(input.Field('rl').AsString);
  idx:=Pos('-',vdev.caption)+1;
  num:=StrToInt(Copy(vdev.caption,idx,Length(vdev.caption)-idx+1));
  vdev.caption:=StringReplace(app.FetchAppTextShort(ses,'$storage_vdev_caption_'+input.Field('rl').AsString),'%num%',IntToStr(num),[rfReplaceAll]);
  res.addUpdatedEntry(_getZFSTreeObj(conn,vdev)); //FIXXME - remove store update
  CheckDbResult(conn.Update(vdev),'Change raid level');
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
  _updateToolbar(conn,ses);
  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=res;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_DestroyPool(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool   : TFRE_DB_ZFS_ROOTOBJ;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  sf:=CWSF(@WEB_DestroyPoolConfirmed);
  sf.AddParam.Describe('pool',input.Field('pool').AsString);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(app.FetchAppTextShort(ses,'$confirm_destroy_caption'),StringReplace(app.FetchAppTextShort(ses,'$confirm_destroy_msg'),'%pool%',pool.caption,[rfReplaceAll]),fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_DestroyPoolConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool   : TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

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
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Scrub Pool','Please implement me',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ExportPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  pool: TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Export Pool','Please implement me',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_IdentifyOn(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  disk   : TFRE_DB_ZFS_OBJ;
  i      : Integer;
begin
  CheckClassVisibility(ses);

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
  CheckClassVisibility(ses);

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
  update : TFRE_DB_UPDATE_STORE_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  update:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      disk:=zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE;
      disk.isOffline:=true;
      update.addUpdatedEntry(_getZFSTreeObj(conn,disk)); //FIXXME - remove store update
      CheckDbResult(conn.Update(disk),'Switch offline');
    end;
  end;
  ses.SendServerClientRequest(update); //FIXXME - remove store update
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Offline','Switch offline (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_SwitchOnline(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  zfsObj : TFRE_DB_ZFS_OBJ;
  disk   : TFRE_DB_ZFS_BLOCKDEVICE;
  i      : Integer;
  update : TFRE_DB_UPDATE_STORE_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  update:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  for i := 0 to input.Field('selected').ValueCount - 1 do begin
    zfsObj:=_getZFSObj(conn,input.Field('selected').AsStringItem[i]);
    if zfsObj.Implementor_HC is TFRE_DB_ZFS_BLOCKDEVICE then begin
      disk:=zfsObj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE;
      disk.isOffline:=false;
      update.addUpdatedEntry(_getZFSTreeObj(conn,disk)); //FIXXME - remove store update
      CheckDbResult(conn.Update(disk),'Switch online');
    end;
  end;
  _updateToolbar(conn,ses);
  ses.SendServerClientRequest(update); //FIXXME - remove store update
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Switch Online','Switch online (' + IntToStr(input.Field('selected').ValueCount)+'). Please implement me.',fdbmt_info);
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._unassignDisk(const upool: TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
var
  spool      : TFRE_DB_ZFS_ROOTOBJ;
  i          : Integer;
  disk       : TFRE_DB_ZFS_OBJ;

  update,lres: TFRE_DB_UPDATE_STORE_DESC; //FIXXME - remove store update
  lastIdx    : String; //FIXXME - remove store update
begin
  update:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('pools_store'); //FIXXME - remove store update
  lres:=TFRE_DB_UPDATE_STORE_DESC.create.Describe('layout_store'); //FIXXME - remove store update

  for i := 0 to Length(disks) - 1 do begin
    disk:=_getZFSObj(conn,disks[i]);
    spool:=disk.getPool(conn);
    if spool.getId=upool.getId then continue; //skip: already unassigned
    if not disk.getIsNew then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(session,'$error_unassign_not_new'));

    update.addDeletedEntry(disk.getId);
    lastIdx:=upool.getLastChildId(conn); //FIXXME - remove store update
    disk.removeFromPool;
    disk:=upool.addBlockdevice(disk.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
    if disk.getIsNew then begin
      disk.setIsNew(false);
      disk.setIsModified(false);
    end else begin
      disk.setIsModified(true);
    end;
    update.addNewEntry(_getZFSTreeObj(conn,disk),lastIdx,upool.getId); //FIXXME - remove store update
    lres.addUpdatedEntry(_getLayoutTreeObj(conn,disk));
    CheckDbResult(conn.Update(disk),'Unassign Disk');
  end;
  session.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  session.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
  session.SendServerClientRequest(lres);  //FIXXME - remove store update
  session.SendServerClientRequest(update); //FIXXME - remove store update
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
    zfsObj:=_getZFSObj(conn,selected[i]);
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

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._updateToolbar(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession);
var
  fnIdentifyOn,fnIdentifyOff, fnRemove, fnAssign, fnSwitchOffline, fnSwitchOnline: Boolean;
  fnSwitchOfflineDisabled, fnSwitchOnlineDisabled: Boolean;
  fnDestroy,fnExport,fnScrub,fnReplace: Boolean;
  fnRLMirrorDisabled,fnRLZ1Disabled,fnRLZ2Disabled,fnRLZ3Disabled: Boolean;
  zfsObj: TFRE_DB_ZFS_OBJ;
  vdev: TFRE_DB_ZFS_VDEV;
  selected: TFRE_DB_StringArray;
begin
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

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedZfsObjs') then begin
    selected:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
    if Length(selected)>1 then begin
      _getMultiselectionActions(conn,selected,fnIdentifyOn,fnIdentifyOff,fnRemove,fnAssign,fnSwitchOffline,fnSwitchOnline,fnSwitchOfflineDisabled,fnSwitchOnlineDisabled);
    end else begin
      zfsObj:=_getZFSObj(conn,selected[0]);
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

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_switch_online',fnSwitchOnlineDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_switch_offline',fnSwitchOfflineDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_iden_on',not fnIdentifyOn));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_iden_off',not fnIdentifyOff));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_assign',not fnAssign));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_replace',not fnReplace));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_remove',not fnRemove));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_destroy',not fnDestroy));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_scrub',not fnScrub));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_export',not fnExport));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_rl_mirror',fnRLMirrorDisabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_rl_z1',fnRLZ1Disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_rl_z2',fnRLZ2Disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_rl_z3',fnRLZ3Disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_remove',not fnRemove));
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD._updateToolbarAssignAndReplaceEntry(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION);
var
  menu: TFRE_DB_MENU_DESC;
  res : TFRE_DB_UPDATE_UI_ELEMENT_DESC;
begin
  menu:=TFRE_DB_MENU_DESC.create.Describe;
  _addDisksToPool(menu,nil,nil,nil,app,conn,ses);
  res:=TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeSubmenu('pool_assign',menu);
  ses.SendServerClientRequest(res);
  menu:=TFRE_DB_MENU_DESC.create.Describe;
  _replaceDisks(menu,'',conn);
  res:=TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeSubmenu('pool_replace',menu);
  ses.SendServerClientRequest(res);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_SaveConfig(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',true));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',true));
  result:=TFRE_DB_MESSAGE_DESC.create.Describe('SAVE','Save Config',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_ResetConfig(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
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
    storeup.addNewEntry(_getZFSTreeObj(conn,zfsObj),lastId);
    lastId:=zfsObj.getId;
  end;

begin

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Disabled','Feature disabled in demonstration mode',fdbmt_info);

end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WEB_Replace(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access'));

  if not input.FieldExists('new') then begin
    input.Field('new').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr[0];
  end;

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Replace','Please implement me ('+input.Field('new').AsString+'=>'+input.Field('old').AsString+')',fdbmt_info);
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.Usage(const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := ses.FetchDerivedCollection('POOL_SPACE');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.ServiceTime(const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := ses.FetchDerivedCollection('POOL_AST');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.BusyTime(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := ses.FetchDerivedCollection('POOL_BUSY');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.ReadBW(const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := ses.FetchDerivedCollection('POOL_RBW');
  Result:=coll.GetDisplayDescription;
end;

function TFRE_FIRMBOX_STORAGE_POOLS_MOD.WriteBW(const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession): TFRE_DB_CONTENT_DESC;
var
  coll : IFRE_DB_DERIVED_COLLECTION;
begin
  coll := ses.FetchDerivedCollection('POOL_WBW');
  Result:=coll.GetDisplayDescription;
end;

procedure TFRE_FIRMBOX_STORAGE_POOLS_MOD.UpdateDiskCollection(const pool_disks: IFRE_DB_COLLECTION; const data: IFRE_DB_Object);
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

{ TFRE_FIRMBOX_STORAGE_SYNC_MOD }

class procedure TFRE_FIRMBOX_STORAGE_SYNC_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_STORAGE_SYNC_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$synch_description')
end;


function TFRE_FIRMBOX_STORAGE_SYNC_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('Please implement me.');
end;


{ TFRE_FIRMBOX_STORAGE_APP }

procedure TFRE_FIRMBOX_STORAGE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('$description');
  AddApplicationModule(TFRE_FIRMBOX_STORAGE_POOLS_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_STORAGE_SYNC_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_BACKUP_MOD.create);
end;

procedure TFRE_FIRMBOX_STORAGE_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage',FetchAppTextShort(session,'$sitemap_main'),'images_apps/firmbox_storage/files_white.svg','',0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools',FetchAppTextShort(session,'$sitemap_pools'),'images_apps/firmbox_storage/disk_white.svg',TFRE_FIRMBOX_STORAGE_POOLS_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_POOLS_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Global',FetchAppTextShort(session,'$sitemap_fileserver_global'),'images_apps/firmbox_storage/files_global_white.svg',TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_GLOBAL_FILESERVER_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Virtual',FetchAppTextShort(session,'$sitemap_fileserver_virtual'),'images_apps/firmbox_storage/files_virtual_white.svg',TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Backup',FetchAppTextShort(session,'$sitemap_backup'),'images_apps/firmbox_storage/clock_white.svg',TFRE_FIRMBOX_BACKUP_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_BACKUP_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Backup/Filebrowser',FetchAppTextShort(session,'$sitemap_filebrowser'),'images_apps/firmbox_storage/filebrowser_white.svg',TFRE_FIRMBOX_BACKUP_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_BACKUP_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Synchronize',FetchAppTextShort(session,'$sitemap_synchronize'),'images_apps/firmbox_storage/sync_white.svg',TFRE_FIRMBOX_STORAGE_SYNC_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_SYNC_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Synchronize/FibreChannel',FetchAppTextShort(session,'$sitemap_synchronize_fc'),'images_apps/firmbox_storage/sync_white.svg',TFRE_FIRMBOX_STORAGE_SYNC_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_SYNC_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Synchronize/iSCSI',FetchAppTextShort(session,'$sitemap_synchronize_iscsi'),'images_apps/firmbox_storage/sync_white.svg',TFRE_FIRMBOX_STORAGE_SYNC_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_STORAGE_SYNC_MOD));
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

class procedure TFRE_FIRMBOX_STORAGE_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      CreateAppText(conn,'$caption','Storage','Storage','Storage');
      CreateAppText(conn,'$pools_description','Pools','Pools','Pools');
      CreateAppText(conn,'$synch_description','Synchronization','Synchronization','Synchronization');
      CreateAppText(conn,'$backup_description','Backup','Backup','Backup');
      CreateAppText(conn,'$fileserver_global_description','Global SAN/NAS','Global SAN/NAS','Global SAN/NAS');
      CreateAppText(conn,'$fileserver_virtual_description','Virtual NAS','Virtual NAS','Virtual NAS');

      CreateAppText(conn,'$pools_info','Overview of disks and pools and their status.');
      CreateAppText(conn,'$global_info','Overview of global SAN/NAS shares and LUNs.');
      CreateAppText(conn,'$virtual_info','Overview of virtual NAS fileservers and shares.');
      CreateAppText(conn,'$backup_info','Overview of backup snapshots of shares, block devices and virtual machines.');

      CreateAppText(conn,'$sitemap_main','Storage','','Storage');
      CreateAppText(conn,'$sitemap_pools','Pools','','Pools');
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

      CreateAppText(conn,'$error_delete_single_select','Exactly one object has to be selected for deletion.');
      CreateAppText(conn,'$error_modify_single_select','Exactly one object has to be selected to modify.');

      CreateAppText(conn,'$tb_create_pool','Create Pool');
      CreateAppText(conn,'$create_pool_diag_cap','Create Pool');
      CreateAppText(conn,'$create_pool_diag_name','Name');
      CreateAppText(conn,'$create_pool_error_cap','Error creating a new pool');
      CreateAppText(conn,'$create_pool_error_not_unique','The name of the pool has to be unique. Please choose another one.');
      CreateAppText(conn,'$tb_import_pool','Import Pool');
      CreateAppText(conn,'$import_pool_diag_cap','Import Pool');
      CreateAppText(conn,'$import_pool_diag_msg','Feature disabled in Demo Mode.');
      CreateAppText(conn,'$tb_export_pool','Export Pool');
      CreateAppText(conn,'$tb_scrub_pool','Scrub Pool');
      CreateAppText(conn,'$tb_save_config','Save');
      CreateAppText(conn,'$tb_reset_config','Reset');
      CreateAppText(conn,'$tb_pools','Pool');
      CreateAppText(conn,'$tb_blockdevices','Disk');
      CreateAppText(conn,'$tb_switch_offline','Switch offline');
      CreateAppText(conn,'$tb_switch_online','Switch online');
      CreateAppText(conn,'$tb_identify_on','Identify on');
      CreateAppText(conn,'$tb_identify_off','Identify off');
      CreateAppText(conn,'$tb_assign','Assign');
      CreateAppText(conn,'$tb_replace','Replace');
      CreateAppText(conn,'$tb_remove','Remove');
      CreateAppText(conn,'$tb_change_rl','Change RL');
      CreateAppText(conn,'$tb_rl_mirror','Mirror');
      CreateAppText(conn,'$tb_rl_z1','Raid-Z1');
      CreateAppText(conn,'$tb_rl_z2','Raid-Z2');
      CreateAppText(conn,'$tb_rl_z3','Raid-Z3');
      CreateAppText(conn,'$tb_destroy_pool','Destroy');
      CreateAppText(conn,'$new_spare_caption','spare');
      CreateAppText(conn,'$new_log_caption','log');
      CreateAppText(conn,'$log_vdev_caption_rl_mirror','mirror-%num%');
      CreateAppText(conn,'$new_cache_caption','cache');
      CreateAppText(conn,'$storage_vdev_caption_rl_mirror','mirror-%num%');
      CreateAppText(conn,'$storage_vdev_caption_rl_z1','raidz1-%num%');
      CreateAppText(conn,'$storage_vdev_caption_rl_z2','raidz2-%num%');
      CreateAppText(conn,'$storage_vdev_caption_rl_z3','raidz3-%num%');
      CreateAppText(conn,'$error_assign_not_new','You can only assign disks which are not in use yet.');
      CreateAppText(conn,'$error_unassign_not_new','You can only unassign disks which are not in use yet.');
      CreateAppText(conn,'$error_assign_vdev_not_found','Assign disks: Vdev not found.');
      CreateAppText(conn,'$error_assign_vdev_unknown_parent_type','Parent of Vdev does not support disk drops.');
      CreateAppText(conn,'$error_remove_not_new','You can only remove zfs elements which are not in use yet.');
      CreateAppText(conn,'$error_change_rl_not_new','You can only change the raid level of a vdev which is not in use yet.');
      CreateAppText(conn,'$unassigned_disks','Unassigned disks');


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
      CreateAppText(conn,'$cm_export_pool','Export pool %pool%');
      CreateAppText(conn,'$cm_scrub_pool','Scrub pool %pool%');

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
      CreateAppText(conn,'$tb_create_nfs_access','Create access');
      CreateAppText(conn,'$tb_delete_nfs_access','Delete access');
      CreateAppText(conn,'$tb_modify_nfs_access','Modify access');
      CreateAppText(conn,'$cm_delete_nfs_access','Delete access');
      CreateAppText(conn,'$cm_modify_nfs_access','Modify access');

      CreateAppText(conn,'$nfs_access_delete_diag_cap','Confirm: Delete NFS access');
      CreateAppText(conn,'$nfs_access_delete_diag_msg','The NFS %access_type% access for %access_host% will be deleted permanently! Please confirm to continue.');

      CreateAppText(conn,'$tb_create_nfs_export','Create export');
      CreateAppText(conn,'$tb_delete_nfs_export','Delete export');
      CreateAppText(conn,'$cm_delete_nfs_export','Delete share');
      CreateAppText(conn,'$nfs_delete_diag_cap','Confirm: Delete share');
      CreateAppText(conn,'$nfs_delete_diag_msg','The share %share_str% will be deleted permanently! Please confirm to continue.');
      CreateAppText(conn,'$nfs_add_diag_cap','New NFS Share');
      CreateAppText(conn,'$nfsaccess_add_diag_cap','New NFS Access');
      CreateAppText(conn,'$nfsaccess_modify_diag_cap','Modify NFS Access');

      CreateAppText(conn,'$tb_create_lun','Create LUN');
      CreateAppText(conn,'$tb_delete_lun','Delete LUN');
      CreateAppText(conn,'$cm_delete_lun','Delete LUN');
      CreateAppText(conn,'$lun_view','LUN Views');
      CreateAppText(conn,'$lun_guid','GUID');
      CreateAppText(conn,'$lun_pool','Diskpool');
      CreateAppText(conn,'$lun_desc','Description');
      CreateAppText(conn,'$lun_size','Size [MB]');
      CreateAppText(conn,'$lun_delete_diag_cap','Confirm: Delete LUN');
      CreateAppText(conn,'$lun_delete_diag_msg','The LUN %guid_str% will be deleted permanently! Please confirm to continue.');
      CreateAppText(conn,'$lun_content_header','Details about the selected LUN');
      CreateAppText(conn,'$lun_add_diag_cap','New LUN');

      CreateAppText(conn,'$lun_view_initiatorgroup','Initiators');
      CreateAppText(conn,'$lun_view_targetgroup','Targets');
      CreateAppText(conn,'$tb_create_lun_view','Create View');
      CreateAppText(conn,'$tb_lunview_delete','Delete View');
      CreateAppText(conn,'$tb_lunview_modify','Modify View');
      CreateAppText(conn,'$cm_lunview_delete','Delete View');
      CreateAppText(conn,'$cm_lunview_modify','Modify View');
      CreateAppText(conn,'$lunview_delete_diag_cap','Confirm: Delete View');
      CreateAppText(conn,'$lunview_delete_diag_msg','The View %guid_str% will be deleted permanently! Please confirm to continue.');
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
      CreateAppText(conn,'$backup_content_header','Details about the selected snapshot.');
      CreateAppText(conn,'$backup_snapshot_delete','Delete');
      CreateAppText(conn,'$backup_snapshot_delete_diag_cap','Confirm: Delete snapshot(s)');
      CreateAppText(conn,'$backup_snapshot_delete_diag_msg','Feature disabled in Demo Mode.');

      //FIXXME - CHECK
      CreateAppText(conn,'$error_no_access','Access denied'); //global text?
      CreateAppText(conn,'$error_not_found','Not found'); //global text?
      CreateAppText(conn,'$button_save','Save'); //global text?

      currentVersionId:='1.0';
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
end;

class procedure TFRE_FIRMBOX_STORAGE_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  CheckDbResult(conn.AddGroup('STORAGEFEEDER','Group for Storage Data Feeder','Storage Feeder',domainUID),'could not create Storage feeder group');

  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID,TFRE_DB_StringArray.Create(
    TFRE_FIRMBOX_STORAGE_APP.GetClassRoleNameFetch
    )),'could not add roles for group STORAGEFEEDER');

  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_POOL.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_POOL for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_BLOCKDEVICE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_BLOCKDEVICE for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_VDEVCONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_VDEVCONTAINER for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_VDEV.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_VDEVfor group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DATASTORAGE for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_LOG.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_LOG for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_CACHE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_CACHE for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_SPARE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_SPARE for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ZFS_UNASSIGNED.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_SPARE for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_PHYS_DISK.GetClassStdRoles),'could not add roles TFRE_DB_PHYS_DISK for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SAS_DISK.GetClassStdRoles),'could not add roles TFRE_DB_SAS_DISK for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SATA_DISK.GetClassStdRoles),'could not add roles TFRE_DB_SATA_DISK for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_ENCLOSURE.GetClassStdRoles),'could not add roles TFRE_DB_ENCLOSURE for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_SAS_EXPANDER.GetClassStdRoles),'could not add roles TFRE_DB_SAS_EXPANDER for group STORAGEFEEDER');
  CheckDbResult(conn.AddRolesToGroup('STORAGEFEEDER',domainUID, TFRE_DB_DRIVESLOT.GetClassStdRoles),'could not add roles TFRE_DB_DRIVESLOT for group STORAGEFEEDER');

end;

function TFRE_FIRMBOX_STORAGE_APP.WEB_RAW_DISK_FEED(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  result := DelegateInvoke('STORAGE_POOLS','RAW_DISK_FEED',input);
end;

function TFRE_FIRMBOX_STORAGE_APP.WEB_DISK_DATA_FEED(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var unassigned_disks     : TFRE_DB_ZFS_UNASSIGNED;
    ua_obj               : IFRE_DB_Object;
    poolcollection       : IFRE_DB_COLLECTION;
    blockdevicecollection: IFRE_DB_COLLECTION;
    enclosurecollection  : IFRE_DB_COLLECTION;
    expandercollection   : IFRE_DB_COLLECTION;
    driveslotcollection  : IFRE_DB_COLLECTION;

    unassigned_uid       : TGUID;
    devices              : IFRE_DB_Object;
    enclosures           : IFRE_DB_Object;
    pools                : IFRE_DB_Object;

    procedure            _UpdateEnclosures(const obj:IFRE_DB_Object);
    var enclosure        : TFRE_DB_ENCLOSURE;
        db_enclosure     : TFRE_DB_ENCLOSURE;
        dbo              : IFRE_DB_Object;

      procedure _UpdateDriveSlots(const obj:IFRE_DB_Object);
      var driveslot      : TFRE_DB_DRIVESLOT;
          db_driveslot   : TFRE_DB_DRIVESLOT;
      begin
        driveslot        := (obj.Implementor_HC as TFRE_DB_DRIVESLOT);
        if driveslotcollection.GetIndexedObj(driveslot.DeviceIdentifier,dbo,CFRE_DB_DRIVESLOT_ID_INDEX) then
          begin
            db_driveslot.SetAllSimpleObjectFieldsFromObject(driveslot);
            db_driveslot.ParentInEnclosureUID  := enclosure.UID;
            CheckDbResult(driveslotcollection.Update(db_driveslot),'could not update driveslot');
          end
        else
          begin
            db_driveslot                      := driveslot.CloneToNewObject(false).Implementor_HC as TFRE_DB_DRIVESLOT;
            db_driveslot.ParentInEnclosureUID := enclosure.UID;
            CheckDbResult(driveslotcollection.Store(db_driveslot),'could not store driveslot');
          end;
      end;

      procedure _UpdateExpanders(const obj:IFRE_DB_Object);
      var expander       : TFRE_DB_SAS_EXPANDER;
          db_expander    : TFRE_DB_SAS_EXPANDER;
      begin
        expander         := (obj.Implementor_HC as TFRE_DB_SAS_EXPANDER);
        if expandercollection.GetIndexedObj(expander.DeviceIdentifier,dbo,CFRE_DB_EXPANDER_ID_INDEX) then
          begin
            db_expander.SetAllSimpleObjectFieldsFromObject(expander);
            db_expander.ParentInEnclosureUID  := enclosure.UID;
            CheckDbResult(expandercollection.Update(db_expander),'could not update expander');
          end
        else
          begin
            db_expander                       := expander.CloneToNewObject(false).Implementor_HC as TFRE_DB_SAS_EXPANDER;
            db_expander.ParentInEnclosureUID  := enclosure.UID;
            CheckDbResult(expandercollection.Store(db_expander),'could not store expander');
          end;
      end;

    begin
      enclosure      := (obj.Implementor_HC as TFRE_DB_ENCLOSURE);
      if enclosurecollection.GetIndexedObj(enclosure.DeviceIdentifier,dbo,CFRE_DB_ENCLOSURE_ID_INDEX) then
        begin
          db_enclosure := dbo.Implementor_HC as TFRE_DB_ENCLOSURE;
          db_enclosure.SetAllSimpleObjectFieldsFromObject(enclosure);
          CheckDbResult(enclosurecollection.Update(db_enclosure),'could not update enclosure');
        end
      else
        begin
          db_enclosure := TFRE_DB_ENCLOSURE.CreateForDB;
          db_enclosure.Field('UID').asGuid := enclosure.UID;
          db_enclosure.SetAllSimpleObjectFieldsFromObject(enclosure);
          CheckDbResult(enclosurecollection.Store(db_enclosure),'could not store enclosure');
        end;
      enclosure.Field('slots').AsObject.ForAllObjects(@_UpdateDriveSlots);
      enclosure.Field('expanders').AsObject.ForAllObjects(@_UpdateExpanders);
    end;


    procedure            _UpdateDisks(const obj:IFRE_DB_Object);
    var  disk               : TFRE_DB_PHYS_DISK;
         db_disk            : TFRE_DB_PHYS_DISK;
         dbo                : IFRE_DB_Object;
    begin
      disk := (obj.Implementor_HC as TFRE_DB_PHYS_DISK);
      if blockdevicecollection.GetIndexedObj(disk.DeviceIdentifier,dbo,CFRE_DB_ZFS_BLOCKDEVICE_DEV_ID_INDEX) then
        begin
          db_disk  := dbo.Implementor_HC as TFRE_DB_PHYS_DISK;
          db_disk.Fw_revision := disk.Fw_revision;
          db_disk.DeviceName  := disk.DeviceName;
          if db_disk.FieldExists('target_port') then
            db_disk.Field('target_port').AsStringArr := disk.Field('target_port').asstringArr;
          CheckDbResult(blockdevicecollection.Update(db_disk),'could not update disk');
        end
      else
        begin
          dbo      := disk.CloneToNewObject;
          db_disk  := dbo.Implementor_HC as TFRE_DB_PHYS_DISK;
          db_disk.caption :=  disk.Devicename; // device.WWN+' ('+device.Manufacturer+' '+device.Model_number+' '+device.Serial_number+')';
          unassigned_disks.addBlockdevice(db_disk);
          CheckDbResult(blockdevicecollection.Store(db_disk),'store blockdevice in disk');
        end;
    end;

    procedure _InsertDisksIntoSlots(const obj:IFRE_DB_Object);
    var disk           : TFRE_DB_PHYS_DISK;
        targetports    : TFRE_DB_StringArray;
        i              : integer;
        guida          : TFRE_DB_GUIDArray;
        slotguid       : TGUID;
        index_name     : string;
        dbo            : IFRE_DB_Object;
        db_disk        : TFRE_DB_PHYS_DISK;
        sdbo           : IFRE_DB_Object;
        db_slot        : TFRE_DB_DRIVESLOT;

        procedure _CheckSlot;
        begin
          if slotguid=CFRE_DB_NullGUID then
            begin
              if length(guida)<>1 then
                raise EFRE_DB_Exception.Create(edb_ERROR,'index for driveslot delivered more than on driveslot for targetport '+targetports[i])
              else
                begin
                  slotguid := guida[0];
                end;
            end
          else
            begin
              if length(guida)<>1 then
                raise EFRE_DB_Exception.Create(edb_ERROR,'index for driveslot delivered more than on driveslot for targetport '+targetports[i]);
              if slotguid <> guida[0] then
                raise EFRE_DB_Exception.Create(edb_ERROR,'index for driveslot delivered different driveslots for targetport '+targetports[i]);
            end;
        end;

    begin
      if (obj.Implementor_HC is TFRE_DB_PHYS_DISK) then
        begin
          disk        := (obj.Implementor_HC as TFRE_DB_PHYS_DISK);
          targetports := disk.GetTargetPorts;
          slotguid    := CFRE_DB_NullGUID;
          for i:=low(targetports) to high(targetports) do
            begin
              if driveslotcollection.GetIndexedUIDs(targetports[i],guida,CFRE_DB_DRIVESLOT_TP1_INDEX) then
                _CheckSlot
              else
                if driveslotcollection.GetIndexedUIDs(targetports[i],guida,CFRE_DB_DRIVESLOT_TP2_INDEX) then
                  _CheckSlot;
            end;
          if slotguid<>CFRE_DB_NullGUID then
            begin
              if not blockdevicecollection.Fetch(disk.UID,dbo) then
                 raise EFRE_DB_Exception.Create(edb_ERROR,'could not fetch disk '+disk.UID_String);
              if not driveslotcollection.Fetch(slotguid,sdbo) then
                 raise EFRE_DB_Exception.Create(edb_ERROR,'could not fetch driveslot '+GFRE_BT.GUID_2_HexString(slotguid));
              db_slot := sdbo.Implementor_HC as TFRE_DB_DRIVESLOT;
              db_disk := dbo.Implementor_HC as TFRE_DB_PHYS_DISK;
              db_disk.ParentInEnclosureUID:= slotguid;
              db_disk.EnclosureUID        := db_slot.ParentInEnclosureUID;
              db_disk.EnclosureNr         := db_slot.EnclosureNr;
              db_disk.SlotNr              := db_slot.SlotNr;
              CheckDbResult(blockdevicecollection.Update(dbo),'update blockdevice with slot information');
              sdbo.Finalize;
            end;
        end;
    end;

    procedure _UpdatePools(const obj:IFRE_DB_Object);
    var pool : TFRE_DB_ZFS_POOL;
    begin
      pool := (obj.Implementor_HC as TFRE_DB_ZFS_POOL);
      pool.FlatEmbeddedAndStoreInCollections(conn);
    end;

begin
  poolcollection         := conn.Collection(CFRE_DB_ZFS_POOL_COLLECTION);
  blockdevicecollection  := conn.Collection(CFRE_DB_ZFS_BLOCKDEVICE_COLLECTION);
  enclosurecollection    := conn.Collection(CFRE_DB_ENCLOSURE_COLLECTION);
  expandercollection     := conn.Collection(CFRE_DB_SAS_EXPANDER_COLLECTION);
  driveslotcollection    := conn.Collection(CFRE_DB_DRIVESLOT_COLLECTION);

  enclosures             := input.Field('enclosures').AsObject;
  enclosures.ForAllObjects(@_UpdateEnclosures);

  if not poolcollection.GetIndexedObj('UNASSIGNED',ua_obj) then
    begin
      unassigned_disks := TFRE_DB_ZFS_UNASSIGNED.CreateForDB;
      unassigned_disks.setZFSGuid('UNASSIGNED');
      unassigned_disks.caption:= app.FetchAppTextShort(ses,'$unassigned_disks');
      unassigned_uid   := unassigned_disks.UID;
      unassigned_disks.poolId := unassigned_uid;
      CheckDbResult(poolcollection.Store(unassigned_disks),'could not store pool for unassigned disks');
      poolcollection.Fetch(unassigned_uid,ua_obj);
    end;
  unassigned_disks := (ua_obj.Implementor_HC as TFRE_DB_ZFS_UNASSIGNED);

  devices := input.Field('disks').AsObject;
  devices.ForAllObjects(@_UpdateDisks);

  // assign disks to driveslots

  blockdevicecollection.ForAll(@_InsertDisksIntoSlots);

  pools := input.Field('pools').AsObject;
  pools.ForAllObjects(@_UpdatePools);

  result := GFRE_DB_NIL_DESC;
end;



end.

