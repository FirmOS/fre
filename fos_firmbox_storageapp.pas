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
  fos_firmbox_fileserver_mod, fos_firmbox_pool_mod,
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
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_POOL_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_STORAGE_APP);
  //GFRE_DBI.Initialize_Extension_Objects;
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
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_NFSMenu),nil,CWSF(@WEB_NFSContent));
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
      SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'nfs_access'),CWSF(@WEB_NFSAccessMenu),nil,nil,nil,nil);
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
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'',CWSF(@WEB_LUNMenu),nil,CWSF(@WEB_LUNContent));
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
      SetDisplayType(cdt_Listview,[],app.FetchAppTextShort(session,'lun_view'),CWSF(@WEB_LUNViewMenu),nil,nil,nil,nil);
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
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_SnapshotMenu),nil,CWSF(@WEB_ContentSnapshot));
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

{ TFRE_FIRMBOX_STORAGE_APP }

procedure TFRE_FIRMBOX_STORAGE_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitApp('description');
  AddApplicationModule(TFOS_FIRMBOX_POOL_MOD.create);
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
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Storage/Pools',FetchAppTextShort(session,'sitemap_pools'),'images_apps/firmbox_storage/disk_white.svg',TFOS_FIRMBOX_POOL_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_FIRMBOX_POOL_MOD));
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

  newVersionId:='1.1';

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
  if (currentVersionId='1.0') then begin
    currentVersionId:='1.1';

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
      TFOS_FIRMBOX_POOL_MOD.GetClassRoleNameFetch
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
      TFOS_FIRMBOX_POOL_MOD.GetClassRoleNameFetch
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
  if currentVersionId='1.0' then begin
    currentVersionId := '1.1';
  end;
end;



end.

