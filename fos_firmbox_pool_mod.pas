unit fos_firmbox_pool_mod;

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
  fre_zfs,
  fre_system,
  //fre_hal_schemes,
  //fre_dbbusiness,
  FRE_DB_COMMON;

type

  { TFOS_FIRMBOX_POOL_MOD }

  TFOS_FIRMBOX_POOL_MOD = class (TFRE_DB_APPLICATION_MODULE)
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
    //function        _PoolObjContent                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  protected
    procedure       SetupAppModuleStructure             ; override;
  public
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects                    (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);override;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       MyServerInitializeModule            (const admin_dbc : IFRE_DB_CONNECTION); override;
    procedure       removeNew                           (const ids: TFRE_DB_StringArray;const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION);
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    //function        WEB_PoolObjNotes                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    //function        WEB_PoolObjNoContent                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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
    //function        WEB_CreatePool                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    //function        WEB_CreatePoolDiag                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_POOL_MOD);
end;

{ TFOS_FIRMBOX_POOL_MOD }

procedure TFOS_FIRMBOX_POOL_MOD._addDisksToPool(const menu: TFRE_DB_MENU_DESC; const pool: TFRE_DB_ZFS_ROOTOBJ; const target: TFRE_DB_ZFS_OBJ; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
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

procedure TFOS_FIRMBOX_POOL_MOD._replaceDisks(const menu: TFRE_DB_MENU_DESC; const newId: String; const conn: IFRE_DB_CONNECTION);
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

function TFOS_FIRMBOX_POOL_MOD._getZFSObj(const conn: IFRE_DB_CONNECTION; const id: String): TFRE_DB_ZFS_OBJ;
var
  dbObj: IFRE_DB_Object;
begin
  conn.Fetch(FREDB_H2G(id),dbObj);
  Result:=dbObj.Implementor_HC as TFRE_DB_ZFS_OBJ;
end;

function TFOS_FIRMBOX_POOL_MOD._getPoolByName(const conn: IFRE_DB_CONNECTION; const name: String): TFRE_DB_ZFS_ROOTOBJ;
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

function TFOS_FIRMBOX_POOL_MOD._getUnassignedPool(const conn: IFRE_DB_CONNECTION): TFRE_DB_ZFS_UNASSIGNED;
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

class procedure TFOS_FIRMBOX_POOL_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_POOL_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('pools_description')
end;

class procedure TFOS_FIRMBOX_POOL_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateDiskDataCollections(conn);
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;
end;

class procedure TFOS_FIRMBOX_POOL_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId:='1.0';

    CreateModuleText(conn,'pools_grid_caption','Caption');
    //CreateModuleText(conn,'pools_grid_iops_r','IOPS R [1/s]');
    //CreateModuleText(conn,'pools_grid_iops_w','IOPS W [1/s]');
    //CreateModuleText(conn,'pools_grid_transfer_r','Read [MB/s]');
    //CreateModuleText(conn,'pools_grid_transfer_w','Write [MB/s]');
    CreateModuleText(conn,'layout_grid_caption','Caption');

    //CreateModuleText(conn,'tb_create_pool','Create Pool');
    //CreateModuleText(conn,'create_pool_diag_cap','Create Pool');
    //CreateModuleText(conn,'create_pool_diag_name','Name');
    //CreateModuleText(conn,'create_pool_error_cap','Error creating a new pool');
    //CreateModuleText(conn,'create_pool_error_not_unique','The name of the pool has to be unique. Please choose another one.');
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

    //CreateModuleText(conn,'poolobj_content_tab','Details');
    //CreateModuleText(conn,'poolobj_notes_tab','Notes');
    //CreateModuleText(conn,'poolobj_no_content_tab','General');
    //CreateModuleText(conn,'poolobj_no_content_content','Please select exactly one pool object to get detailed information.');
  end;
end;

procedure TFOS_FIRMBOX_POOL_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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
      AddOneToOnescheme('uid','uid','',dt_string,false);
      //AddMultiToOnescheme(TFRE_DB_NameTypeArray.create('pool_uid','uid'),'pool_uid','',dt_string,false);
      //AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_READ_OPS','iops_r',FetchModuleTextShort(session,'pools_grid_iops_r'));
      //AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_WRITE_OPS','iops_w',FetchModuleTextShort(session,'pools_grid_iops_w'));
      //AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_READ_BYTES','transfer_r',FetchModuleTextShort(session,'pools_grid_transfer_r'));
      //AddMatchingReferencedField('TFRE_DB_ZPOOL_IOSTAT<ZFS_OBJ_ID','ZIO_TYPE_WRITE_BYTES','transfer_w',FetchModuleTextShort(session,'pools_grid_transfer_w'));
      AddOneToOnescheme('_disabledrag_','','',dt_string,false);
      AddOneToOnescheme('_disabledrop_','','',dt_string,false);
      AddOneToOnescheme('dndclass','','',dt_string,false);
    end;

    pools_grid := session.NewDerivedCollection('POOL_DISKS');
    with pools_grid do begin
      SetDeriveParent           (conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION));
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_Multiselect],'',nil,'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_PoolStructureSC),nil,CWSF(@WEB_TreeDrop));
      SetParentToChildLinkField ('<PARENT_IN_ZFS_UID');

      SetDeriveTransformation   (tr_Grid);
      SetDefaultOrderField      ('caption',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Grid);

    with tr_Grid do begin
      AddOneToOnescheme('uid','','',dt_string,false);
      AddMultiToOnescheme(TFRE_DB_NameTypeArray.Create('caption_layout','caption','displayname'),'caption_layout',FetchModuleTextShort(session,'pools_grid_caption'),dt_string,true,false,false,1,'icon_layout');
      AddMultiToOnescheme(TFRE_DB_NameTypeArray.Create('icon_layout','icon'),'icon_layout','',dt_string,false,false,false,1,'','',FREDB_getThemedResource('images_apps/firmbox_storage/Undefined.png'));
      AddOneToOnescheme('_disabledrag_','','',dt_string,false);
      AddOneToOnescheme('_disabledrop_','','',dt_string,false);
      AddOneToOnescheme('dndclass','','',dt_string,false);
    end;

    layout_grid := session.NewDerivedCollection('ENCLOSURE_DISKS');
    with layout_grid do begin
      SetDeriveParent           (conn.GetMachinesCollection);
      SetDisplayType            (cdt_Listview,[cdgf_Children,cdgf_Multiselect],'',nil,'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_LayoutSC),nil,CWSF(@WEB_TreeDrop));
      SetParentToChildLinkField ('<PARENT_IN_ENCLOSURE_UID');

      SetDeriveTransformation   (tr_Grid);
      SetDefaultOrderField      ('caption_layout',true);
    end;
  end;
end;

procedure TFOS_FIRMBOX_POOL_MOD.MyServerInitializeModule(const admin_dbc: IFRE_DB_CONNECTION);
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

procedure TFOS_FIRMBOX_POOL_MOD.removeNew(const ids: TFRE_DB_StringArray; const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION);
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
  ua:=_getUnassignedPool(conn);
  for i := 0 to High(ids) do begin
    zfsObj:=_getZFSObj(conn,ids[i]);
    pool:=zfsObj.getPool(conn);
    if assigned(ua) and (pool.getId=ua.getId) then continue; //skip: already unassigned
    if not zfsObj.getIsNew then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_remove_not_new'));
    _handleObj(zfsObj);
  end;
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  pool_grid  : TFRE_DB_VIEW_LIST_DESC;
  layout_grid: TFRE_DB_VIEW_LIST_DESC;
  coll       : IFRE_DB_DERIVED_COLLECTION;
  menu       : TFRE_DB_MENU_DESC;
  submenu    : TFRE_DB_SUBMENU_DESC;
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  subsubmenu : TFRE_DB_SUBMENU_DESC;
  poolDbo    : IFRE_DB_Object;
  pDC        : IFRE_DB_DERIVED_COLLECTION;
  eDC        : IFRE_DB_DERIVED_COLLECTION;
begin
  CheckClassVisibility4AnyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedZfsObjs');

  if not input.FieldExists('selected') then
    raise EFRE_DB_Exception.Create('Missing input parameter selected');

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),poolDbo));

  pDC:=ses.FetchDerivedCollection('POOL_DISKS');
  pDC.Filters.RemoveFilter('pool');
  pDC.Filters.AddRootNodeFilter('pool','uid',poolDbo.UID,dbnf_OneValueFromFilter,true);
  pool_grid:=pDC.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  eDC:=ses.FetchDerivedCollection('ENCLOSURE_DISKS');
  eDC.Filters.RemoveFilter('machine');
  eDC.Filters.AddRootNodeFilter('machine','uid',poolDbo.Field('machineid').AsObjectLink,dbnf_OneValueFromFilter);
  layout_grid:=eDC.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then begin
    pool_grid.SetDragClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    layout_grid.SetDragClasses(TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    pool_grid.SetDropGrid(pool_grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));
    layout_grid.SetDropGrid(pool_grid,TFRE_DB_StringArray.create('TFRE_DB_ZFS_VDEV','TFRE_DB_ZFS_LOG','TFRE_DB_ZFS_CACHE','TFRE_DB_ZFS_SPARE','TFRE_DB_ZFS_DATASTORAGE','TFRE_DB_ZFS_POOL','TFRE_DB_ZFS_UNASSIGNED'),TFRE_DB_StringArray.create('TFRE_DB_ZFS_BLOCKDEVICE'));

    menu:=TFRE_DB_MENU_DESC.create.Describe;
    menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_save_config'),'',CWSF(@WEB_SaveConfig),false,'pool_save');
    menu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_reset_config'),'',CWSF(@WEB_ResetConfig),true,'pool_reset');

    submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_pools'),'');
    //submenu.AddEntry.Describe(FetchModuleTextShort(ses,'tb_create_pool'),'',CWSF(@WEB_CreatePoolDiag));
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

  //Result:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(layout_grid,pool_grid,_PoolObjContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,true,1,3,3);
  Result:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(pool_grid,layout_grid,nil,nil,nil,true,3,2);
end;

//function TFOS_FIRMBOX_POOL_MOD.WEB_PoolObjNoContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
//begin
//  Result:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'poolobj_no_content_content'));
//end;

function TFOS_FIRMBOX_POOL_MOD.WEB_PoolStructureSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedZfsObjs')
  end;

  _updateToolbars(conn,ses);
  //if ses.isUpdatableContentVisible('pool_obj_content') then begin
  //  Result:=_PoolObjContent(input,ses,app,conn);
  //end else begin
    Result:=GFRE_DB_NIL_DESC;
  //end;
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_LayoutSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_TBAssign(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
  //FIXXME implement me
  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBSwitchOnline(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_SwitchOnline(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBSwitchOffline(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_SwitchOffline(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBIdentifyOn(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_IdentifyOn(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBIdentifyOff(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_IdentifyOff(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBRemoveNew(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_RemoveNew(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBChangeRaidLevel(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_ChangeRaidLevel(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBDestroyPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('selected').AsStringArr:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr;
  Result:=WEB_DestroyPool(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBExportPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('pool').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsString;
  Result:=WEB_ExportPool(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TBScrubPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('pool').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsString;
  Result:=WEB_ScrubPool(input,ses,app,conn);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_TreeDrop(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_GridMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

//function TFOS_FIRMBOX_POOL_MOD.WEB_CreatePool(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
//var
//  pools   : IFRE_DB_COLLECTION;
//  vdevs   : IFRE_DB_COLLECTION;
//  nameOk  : Boolean;
//  lastObj : IFRE_DB_Object;
//  newPool : TFRE_DB_ZFS_POOL;
//  dstore  : TFRE_DB_ZFS_DATASTORAGE;
//  muid    : TFRE_DB_GUID;
//
//  procedure _checkPoolName(const obj:IFRE_DB_Object);
//  begin
//    if LowerCase(input.FieldPath('data.pool_name').AsString)=LowerCase(obj.Field('objname').AsString) then begin
//      nameOk:=false;
//    end;
//    if (obj.Implementor_HC is TFRE_DB_ZFS_POOL) and not (obj.Implementor_HC is TFRE_DB_ZFS_UNASSIGNED) then begin
//      lastObj:=obj;
//    end;
//  end;
//
//begin
//  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
//    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
//
//  if not input.FieldPathExists('data.pool_name') then
//    raise EFRE_DB_Exception.Create('WEB_CreatePool: Missing parameter pool_name');
//
//  pools := conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
//  vdevs := conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);
//  nameOk:=true;
//  lastObj:=nil;
//  pools.ForAll(@_checkPoolName);
//  if not nameOk then begin
//    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'create_pool_error_cap'),FetchModuleTextShort(ses,'create_pool_error_not_unique'),fdbmt_error);
//    exit;
//  end;
//
//  newPool:=TFRE_DB_ZFS_POOL.CreateForDB;
//  newPool.SetName(input.FieldPath('data.pool_name').AsString);
//
//  //TODO: Select Machine depended on selection
//  if conn.GetCollection(cFRE_DB_MACHINE_COLLECTION).GetIndexedUID('firmbox',muid,'def') then
//    begin
//      newpool.parentInZFSId := muid;
//      newpool.MachineID := muid;
//    end
//  else
//    raise EFRE_DB_Exception.Create('WEB_CreatePool: No Machine for new pool found');
//
//  newPool.setIsNew;
//
//  dstore:=newPool.createDatastorage;
//  dstore.SetName(input.FieldPath('data.pool_name').AsString);
//  dstore.setIsNew;
//
//  CheckDbResult(pools.Store(newPool),'Add new pool');
//  CheckDbResult(vdevs.Store(dstore),'Add new pool');
//  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
//  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));
//
//  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
//
//  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
//end;
//
//function TFOS_FIRMBOX_POOL_MOD.WEB_CreatePoolDiag(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
//var
//  res  :TFRE_DB_FORM_DIALOG_DESC;
//begin
//  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
//    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
//
//  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'create_pool_diag_cap'));
//  res.AddInput.Describe(FetchModuleTextShort(ses,'create_pool_diag_name'),'pool_name',true);
//  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CWSF(@WEB_CreatePool),fdbbt_submit);
//  result:=res;
//end;

function TFOS_FIRMBOX_POOL_MOD.WEB_ImportPoolDiag(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'import_pool_diag_cap'),FetchModuleTextShort(ses,'import_pool_diag_msg'),fdbmt_info,nil);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_AssignSpareDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_AssignCacheDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_AssignLogDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_AssignStorageDisk(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_RemoveNew(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin

  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));


  removeNew(input.Field('selected').AsStringArr,ses,conn);

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_save',false));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('pool_reset',false));

  _updateToolbarAssignAndReplaceEntry(conn,ses,app);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_ChangeRaidLevel(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_DestroyPool(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_DestroyPoolConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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


function TFOS_FIRMBOX_POOL_MOD.WEB_ScrubPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  pool: TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Scrub Pool','Please implement me',fdbmt_info);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_ExportPool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  pool: TFRE_DB_ZFS_ROOTOBJ;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  pool:=_getZFSObj(conn,input.Field('pool').AsString).Implementor_HC as TFRE_DB_ZFS_ROOTOBJ;
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Export Pool','Please implement me',fdbmt_info);
end;

function TFOS_FIRMBOX_POOL_MOD.WEB_IdentifyOn(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_IdentifyOff(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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


function TFOS_FIRMBOX_POOL_MOD.WEB_SwitchOffline(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_SwitchOnline(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

procedure TFOS_FIRMBOX_POOL_MOD._unassignDisk(const upool: TFRE_DB_ZFS_UNASSIGNED; const disks: TFRE_DB_StringArray; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const session: IFRE_DB_UserSession);
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

function TFOS_FIRMBOX_POOL_MOD._getNextVdevNum(const siblings: IFRE_DB_ObjectArray): Integer;
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

procedure TFOS_FIRMBOX_POOL_MOD._getMultiselectionActions(const conn: IFRE_DB_CONNECTION; const selected: TFRE_DB_StringArray; var fnIdentifyOn, fnIdentifyOff, fnRemove, fnAssign, fnSwitchOffline, fnSwitchOnline, fnSwitchOfflineDisabled, fnSwitchOnlineDisabled: Boolean);
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

procedure TFOS_FIRMBOX_POOL_MOD._updateToolbars(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession);
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

procedure TFOS_FIRMBOX_POOL_MOD._updateToolbarAssignAndReplaceEntry(const conn: IFRE_DB_CONNECTION; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION);
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

//function TFOS_FIRMBOX_POOL_MOD._PoolObjContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
//var
//  res   : TFRE_DB_SUBSECTIONS_DESC;
//  zfsObj: IFRE_DB_Object;
//begin
//  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
//  if ses.GetSessionModuleData(ClassName).FieldExists('selectedZfsObjs') and (ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').ValueCount=1) then begin
//
//    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr[0]),zfsObj));
//    if zfsObj.MethodExists('ZFSContent') then begin
//      res.AddSection.Describe(CSFT('ZFSContent',zfsObj),FetchModuleTextShort(ses,'poolobj_content_tab'),2);
//    end;
//    res.AddSection.Describe(CWSF(@WEB_PoolObjNotes),FetchModuleTextShort(ses,'poolobj_notes_tab'),2);
//  end else begin
//    res.AddSection.Describe(CWSF(@WEB_PoolObjNoContent),FetchModuleTextShort(ses,'poolobj_no_content_tab'),1);
//  end;
//  res.contentId:='pool_obj_content';
//  Result:=res;
//end;

//function TFOS_FIRMBOX_POOL_MOD.WEB_PoolObjNotes(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
//var
//  load_func             : TFRE_DB_SERVER_FUNC_DESC;
//  save_func             : TFRE_DB_SERVER_FUNC_DESC;
//begin
//  load_func   := CWSF(@WEB_NoteLoad);
//  save_func   := CWSF(@WEB_NoteSave);
//
//  load_func.AddParam.Describe('linkid',ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringItem[0]);
//  save_func.AddParam.Describe('linkid',ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringItem[0]);
//
//  Result:=TFRE_DB_EDITOR_DESC.create.Describe(load_func,save_func,CWSF(@WEB_NoteStartEdit),CWSF(@WEB_NoteStopEdit));
//end;

function TFOS_FIRMBOX_POOL_MOD.WEB_SaveConfig(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_ResetConfig(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_FIRMBOX_POOL_MOD.WEB_Replace(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_ZFS_POOL) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldExists('new') then begin
    input.Field('new').AsString:=ses.GetSessionModuleData(ClassName).Field('selectedZfsObjs').AsStringArr[0];
  end;

  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Replace','Please implement me ('+input.Field('new').AsString+'=>'+input.Field('old').AsString+')',fdbmt_info);
end;

end.

