unit fos_firmbox_fileserver_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fre_zfs,fre_hal_schemes,fre_dbbusiness;

type

{ TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD }

  TFILESHARE_ROLETYPE = (rtRead,rtWrite);

  TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _getRolename               (const share_id: TFRE_DB_NameType; const roletype: TFILESHARE_ROLETYPE): TFRE_DB_NameType;
    function        _setShareRoles             (const input:IFRE_DB_Object; const change_read,change_write,read,write:boolean; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION) : IFRE_DB_Object;
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure    ; override;
    class procedure InstallDBObjects           (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects       (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  public
    procedure       CalculateReadWriteAccess   (const conn : IFRE_DB_CONNECTION ; const dependency_input : IFRE_DB_Object; const input_object : IFRE_DB_Object ; const transformed_object : IFRE_DB_Object);
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentShareGroups     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentVFShares        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddVFS                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreVFS               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSMenu                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSContent             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSSC                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSDelete              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSDeleteConfirmed     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddVFSShare            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreVFSShare          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareMenu           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareContent        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_VFSShareSC             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD);

  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD }

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD._getRolename(const share_id: TFRE_DB_NameType; const roletype: TFILESHARE_ROLETYPE): TFRE_DB_NameType;
begin
  abort; // rethink
  //case roletype of
    //rtRead  : result := FREDB_Get_Rightname_UID('FSREAD',FREDB_H2G(share_id));
    //rtWrite : result := FREDB_Get_Rightname_UID('FSWRITE',FREDB_H2G(share_id));
  // else
  //   raise EFRE_DB_Exception.Create('Undefined Roletype for Fileshare');
  //end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD._setShareRoles(const input: IFRE_DB_Object; const change_read, change_write, read, write: boolean; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dependend     : TFRE_DB_StringArray;
  share_s       : string;
  share_id      : TFRE_DB_GUID;
  share         : IFRE_DB_Object;
  rrole         : TFRE_DB_NameType;
  wrole         : TFRE_DB_NameType;
  group         : IFRE_DB_GROUP;
  groupid       : TFRE_DB_GUID;
  i             : NativeInt;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.FieldExists('share_id') then begin
    share_s  := input.Field('share_id').asstring;
  end else begin
    dependend  := GetDependencyFiltervalues(input,'uids_ref');
    if length(dependend)=0 then begin
      Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'share_group_in_diag_cap'),FetchModuleTextShort(ses,'share_group_in_no_share_msg'),fdbmt_warning,nil);
      exit;
    end;
    share_s   := dependend[0];
  end;
  share_id := FREDB_H2G(share_s);

  CheckDbResult(conn.Fetch(share_id,share),FetchModuleTextShort(ses,'Share not found!'));


  for i := 0 to input.Field('selected').ValueCount-1 do begin
    groupid := FREDB_H2G(input.Field('selected').AsStringItem[i]);
    if (conn.sys.FetchGroupById(groupid,group)<>edb_OK) then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'Group not found!'));

    rrole := _getRolename(share_s,rtRead);
    if conn.sys.RoleExists(rrole,group.DomainID)=false then raise EFRE_DB_Exception.Create('No Read Role for Fileshare !');

    wrole := _getRolename(share_s,rtWrite);
    if conn.sys.RoleExists(wrole,group.DomainID)=false then raise EFRE_DB_Exception.Create('No Write Role for Fileshare !');

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
  InitModuleDesc('fileserver_virtual_description')
end;

class procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'fileserver_virtual_description','Virtual NAS','Virtual NAS','Virtual NAS');

    CreateModuleText(conn,'tb_create_vfs','Create');
    CreateModuleText(conn,'tb_delete_vfs','Delete');
    CreateModuleText(conn,'cm_delete_vfs','Delete');
    CreateModuleText(conn,'grid_vfs_name','Fileserver');
    CreateModuleText(conn,'grid_vfs_customer','Customer');
    CreateModuleText(conn,'storage_virtual_filer_shares','Shares');
    CreateModuleText(conn,'storage_virtual_filer_content','Virtual NAS Properties');
    CreateModuleText(conn,'vfs_content_header','Details about the selected virtual NAS.');
    CreateModuleText(conn,'vfs_add_diag_cap','New Virtual Fileserver');
    CreateModuleText(conn,'vfs_delete_diag_cap','Confirm: Delete Virtual Fileserver');
    CreateModuleText(conn,'vfs_delete_diag_msg','The virtual fileserver %vfs_str% will be deleted permanently! Please confirm to continue.');

    CreateModuleText(conn,'vfs_create_error_exists_cap','Error: Add VFS Service');
    CreateModuleText(conn,'vfs_create_error_exists_msg','The Fileserver Service already exists!');

    CreateModuleText(conn,'vfs_share_create_error_exists_cap','Error: Add Share');
    CreateModuleText(conn,'vfs_share_create_error_exists_msg','The Share already exists!');

    CreateModuleText(conn,'vfs_share','Share');
    CreateModuleText(conn,'vfs_share_refer','Refer');
    CreateModuleText(conn,'vfs_share_used','Used');
    CreateModuleText(conn,'vfs_share_quota','Quota');
    CreateModuleText(conn,'tb_create_vfs_share','Create');
    CreateModuleText(conn,'tb_delete_vfs_share','Delete');
    CreateModuleText(conn,'cm_delete_vfs_share','Delete');
    CreateModuleText(conn,'storage_virtual_filer_share_properties','Share Properties');
    CreateModuleText(conn,'storage_virtual_filer_share_groups','Groups');
    CreateModuleText(conn,'storage_virtual_filer_share_user','User');
    CreateModuleText(conn,'vfs_share_content_header','Details about the selected share.');
    CreateModuleText(conn,'vfs_share_add_diag_cap','New Fileshare');
    CreateModuleText(conn,'vfs_share_add_no_fs_msg','Please select a virtual NAS first before adding a share.');
    CreateModuleText(conn,'vfs_share_delete_diag_cap','Confirm: Delete share');
    CreateModuleText(conn,'vfs_share_delete_diag_msg','The share %share_str% will be deleted permanently! Please confirm to continue.');
    CreateModuleText(conn,'share_group_in_diag_cap','Adding Access to Group');
    CreateModuleText(conn,'share_group_in_no_share_msg','Please select a share first before adding group access.');

    CreateModuleText(conn,'share_group_in','Groups with access to the fileshare.');
    CreateModuleText(conn,'share_group_out','Groups without access to the fileshare.');
    CreateModuleText(conn,'share_group_read','Read Access');
    CreateModuleText(conn,'share_group_write','Write Access');
    CreateModuleText(conn,'share_group_group','Group');
    CreateModuleText(conn,'share_group_desc','Description');

    CreateModuleText(conn,'tb_share_group_setread_on','Set Read Access');
    CreateModuleText(conn,'tb_share_group_setread_off','Clear Read Access');
    CreateModuleText(conn,'tb_share_group_setwrite_on','Set Write Access');
    CreateModuleText(conn,'tb_share_group_setwrite_off','Clear Write Access');

    CreateModuleText(conn,'cm_share_group_setread_on','Set Read Access');
    CreateModuleText(conn,'cm_share_group_setread_off','Clear Read Access');
    CreateModuleText(conn,'cm_share_group_setwrite_on','Set Write Access');
    CreateModuleText(conn,'cm_share_group_setwrite_off','Clear Write Access');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
  end;
end;

class procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
var
  coll: IFRE_DB_COLLECTION;
begin
  inherited InstallUserDBObjects(conn, currentVersionId);
  if not conn.CollectionExists(CFRE_DB_FILESHARE_COLLECTION) then begin
    coll:=conn.CreateCollection(CFRE_DB_FILESHARE_COLLECTION);
  end else begin
    coll:=conn.GetCollection(CFRE_DB_FILESHARE_COLLECTION);
  end;
  if not coll.IndexExists('def') then begin
    coll.DefineIndexOnField('objname',fdbft_String,true,true,'def',false);
  end;
end;

procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.CalculateReadWriteAccess(const conn: IFRE_DB_CONNECTION; const dependency_input: IFRE_DB_Object; const input_object: IFRE_DB_Object; const transformed_object: IFRE_DB_Object);
var sel_guid,rr,wr : string;
    sel_guidg      : TFRE_DB_GUID;
    group_id       : TFRE_DB_GUID;
    true_icon      : string;
    false_icon     : string;
begin
  abort; // rethink
  sel_guid  := dependency_input.FieldPath('UIDS_REF.FILTERVALUES').AsString; //FIXXME - may not be set
  sel_guidg := FREDB_H2G(sel_guid);
  group_id  := input_object.uid;

  //rr := FREDB_Get_Rightname_UID_STR('FSREAD',sel_guid);
  //wr := FREDB_Get_Rightname_UID_STR('FSWRITE',sel_guid);

  true_icon  := FREDB_getThemedResource('images_apps/firmbox_storage/access_true.png');
  false_icon := FREDB_getThemedResource('images_apps/firmbox_storage/access_false.png');
end;

procedure TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  fs_dc           : IFRE_DB_DERIVED_COLLECTION;
  transform       : IFRE_DB_SIMPLE_TRANSFORM;
  share_dc        : IFRE_DB_DERIVED_COLLECTION;
  groupin_dc      : IFRE_DB_DERIVED_COLLECTION;
  groupout_dc     : IFRE_DB_DERIVED_COLLECTION;
  vfs_customers   : IFRE_DB_DERIVED_COLLECTION;

  app             : TFRE_DB_APPLICATION;
  conn            : IFRE_DB_CONNECTION;

begin
  inherited;
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField('CUSTOMER>TFOS_DB_CITYCOM_CUSTOMER','objname','customer',FetchModuleTextShort(session,'grid_vfs_customer'),true,dt_string,true);
      AddOneToOnescheme('name','',FetchModuleTextShort(session,'grid_vfs_name'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description','',true,false,false,dt_description);
      AddFulltextFilterOnTransformed(['customer','name']);
    end;
    fs_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
    with fs_dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      Filters.AddSchemeObjectFilter('service',['TFRE_DB_VIRTUAL_FILESERVER']);
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,'',CWSF(@WEB_VFSMenu),nil,CWSF(@WEB_VFSSC));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('name','',FetchModuleTextShort(session,'vfs_share'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', '',true,false,false,dt_description);
      AddOneToOnescheme('used_mb','used',FetchModuleTextShort(session,'vfs_share_used'));
      AddOneToOnescheme('refer_mb','refer',FetchModuleTextShort(session,'vfs_share_refer'));
      AddOneToOnescheme('quota_mb','quota',FetchModuleTextShort(session,'vfs_share_quota'));
      AddFulltextFilterOnTransformed(['name']);
    end;
    share_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
    with share_dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_FILESHARE_COLLECTION));
      Filters.AddSchemeObjectFilter('service',['TFRE_DB_VIRTUAL_FILESHARE']);
      SetUseDependencyAsRefLinkFilter(['TFRE_DB_VIRTUAL_FILESHARE<FILESERVER'],false,'uid');
      // SetReferentialLinkMode(['TFRE_DB_VIRTUAL_FILESHARE<FILESERVER']); CHANGE TO REFLINKFILTER MODE
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,'',CWSF(@WEB_VFSShareMenu),nil,CWSF(@WEB_VFSShareSC));
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('desc.txt') ,'description', FetchModuleTextShort(session,'share_group_desc'));
      AddOneToOnescheme('read','',FetchModuleTextShort(session,'share_group_read'),dt_Icon);
      AddOneToOnescheme('write','',FetchModuleTextShort(session,'share_group_write'),dt_Icon);
//      AddOneToOnescheme('objname','group',FetchModuleTextShort(session,'share_group_group'));
      //SetCustomTransformFunction(@CalculateReadWriteAccess);
    end;
    groupin_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
    with groupin_dc do begin
      SetDeriveParent(session.GetDBConnection.AdmGetGroupCollection);
      SetUseDependencyAsRefLinkFilter(['TFRE_DB_VIRTUAL_FILESHARE<GROUPID'],false,'uid');
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Multiselect],FetchModuleTextShort(session,'share_group_in'),nil,'',CWSF(@WEB_VFSShareGroupMenu),nil,nil,nil,CWSF(@WEB_VFSShareGroupInDrop));
    end;

    //GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,groupout_tr_Grid);
    //with groupout_tr_Grid do begin
    //  AddOneToOnescheme('objname','group',FetchModuleTextShort(session,'share_group_group'));
    //  AddCollectorscheme('%s',GFRE_DBI.ConstructStringArray(['desc.txt']) ,'description', false, FetchModuleTextShort(session,'share_group_desc'));
    //end;
    //groupout_dc := session.NewDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
    //with groupout_dc do begin
    //  SetDeriveParent(session.GetDBConnection.AdmGetGroupCollection);
    //  SetDeriveTransformation(groupout_tr_Grid);
    //  SetDisplayType(cdt_Listview,[],FetchModuleTextShort(session,'share_group_out'),nil,'',nil,nil,nil,nil,CSF(@WEB_VFSShareGroupOutDrop));
    //end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'chooser_customer'),dt_string,true,true,false,3);
      AddOneToOnescheme('servicedomain','','',dt_string,false);
    end;

    vfs_customers := session.NewDerivedCollection(CFOS_DB_VFS_CUSTOMERS_DCOLL);
    with vfs_customers do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_CUSTOMERS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','servicedomain','','','TFRE_DB_VIRTUAL_FILESHARE',[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
    end;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_Content(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sub_sec_fs    : TFRE_DB_SUBSECTIONS_DESC;
  grid_fs       : TFRE_DB_VIEW_LIST_DESC;
  dc_fs         : IFRE_DB_DERIVED_COLLECTION;
  dc_share      : IFRE_DB_DERIVED_COLLECTION;

begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedVFS');

  sub_sec_fs   := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  dc_fs       := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_FS_GRID');
  grid_fs     := dc_fs.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    grid_fs.AddButton.Describe(CWSF(@WEB_AddVFS),'',FetchModuleTextShort(ses,'tb_create_vfs'),FetchModuleTextHint(ses,'tb_create_vfs'));
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER) then begin
    grid_fs.AddButton.DescribeManualType('delete_vfs',CWSF(@WEB_VFSDelete),'',FetchModuleTextShort(ses,'tb_delete_vfs'),FetchModuleTextHint(ses,'tb_delete_vfs'),true);
  end;

  dc_share    := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
  grid_fs.AddFilterEvent(dc_share.getDescriptionStoreId(),'uid');

  sub_sec_fs.AddSection.Describe(CWSF(@WEB_ContentVFShares),FetchModuleTextShort(ses,'storage_virtual_filer_shares'),1,'shares');
  sub_sec_fs.AddSection.Describe(CWSF(@WEB_VFSContent),FetchModuleTextShort(ses,'storage_virtual_filer_content'),2,'vfs');

  Result:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_fs,sub_sec_fs,nil,nil,nil,true,1,3);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_ContentShareGroups(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  dc_group_in   : IFRE_DB_DERIVED_COLLECTION;
  grid          : TFRE_DB_VIEW_LIST_DESC;
  //grid_group_in : TFRE_DB_VIEW_LIST_DESC;
  //dc_group_out  : IFRE_DB_DERIVED_COLLECTION;
  //grid_group_out: TFRE_DB_VIEW_LIST_DESC;
  //share_group   : TFRE_DB_LAYOUT_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_group_in   := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
  grid          := dc_group_in.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  //share_id = ses.GetSessionModuleData(ClassName).Field('selectedVFSShare')

  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    grid.AddButton.Describe(CWSF(@WEB_VFSShareGroupSetRead),'',FetchModuleTextShort(ses,'tb_share_group_setread_on'),FetchModuleTextHint(ses,'tb_share_group_setread_on'),fdgbd_single);
    grid.AddButton.Describe(CWSF(@WEB_VFSShareGroupSetWrite),'',FetchModuleTextShort(ses,'tb_share_group_setwrite_on'),FetchModuleTextHint(ses,'tb_share_group_setwrite_on'),fdgbd_single);
    grid.AddButton.Describe(CWSF(@WEB_VFSShareGroupClearRead),'',FetchModuleTextShort(ses,'tb_share_group_setread_off'),FetchModuleTextHint(ses,'tb_share_group_setread_off'),fdgbd_single);
    grid.AddButton.Describe(CWSF(@WEB_VFSShareGroupClearWrite),'',FetchModuleTextShort(ses,'tb_share_group_setwrite_off'),FetchModuleTextHint(ses,'tb_share_group_setwrite_off'),fdgbd_single);
  end;
  Result:=grid;


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
  dc_share      : IFRE_DB_DERIVED_COLLECTION;
  grid_share    : TFRE_DB_VIEW_LIST_DESC;
  vfs           : IFRE_DB_Object;
  add_disabled  : Boolean;
begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedVFSShare');

  add_disabled:=true;
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedVFS') and (ses.GetSessionModuleData(ClassName).Field('selectedVFS').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedVFS').AsGUID,vfs));
    if conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE,vfs.DomainID) then begin
      add_disabled:=false;
    end;
  end;

  dc_share    := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GRID');
  grid_share  := dc_share.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    grid_share.AddButton.DescribeManualType('add_share',CWSF(@WEB_AddVFSShare),'',FetchModuleTextShort(ses,'tb_create_vfs_share'),FetchModuleTextHint(ses,'tb_create_vfs_share'),add_disabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    grid_share.AddButton.DescribeManualType('delete_share',CWSF(@WEB_VFSShareDelete),'',FetchModuleTextShort(ses,'tb_delete_vfs_share'),FetchModuleTextHint(ses,'tb_delete_vfs_share'),true);
  end;

  sub_sec_share := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
  sub_sec_share.AddSection.Describe(CWSF(@WEB_VFSShareContent),FetchModuleTextShort(ses,'storage_virtual_filer_share_properties'),1,'shareproperties');
  sub_sec_share.AddSection.Describe(CWSF(@WEB_ContentShareGroups),FetchModuleTextShort(ses,'storage_virtual_filer_share_groups'),1,'sharegroups');

  dc_group_in   := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_IN_GRID');
  //dc_group_out  := ses.FetchDerivedCollection('VIRTUAL_FILESERVER_MOD_SHARE_GROUP_OUT_GRID');
  grid_share.AddFilterEvent(dc_group_in.getDescriptionStoreId,'uid');
  //grid_share.AddFilterEvent(dc_group_out.getDescriptionStoreId,'uid');

  Result:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(grid_share,sub_sec_share,nil,nil,nil,true,2,3);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_AddVFS(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  serverfunc : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_VIRTUAL_FILESERVER) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GFRE_DBI.GetSystemScheme(TFRE_DB_VIRTUAL_FILESERVER,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'vfs_add_diag_cap'),600,true,true,false);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false);
  serverfunc := CWSF(@WEB_StoreVFS);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),serverfunc,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_StoreVFS(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  coll        : IFRE_DB_COLLECTION;
  vfsService  : TFRE_DB_VIRTUAL_FILESERVER;
  idx         : String;
  customer    : IFRE_DB_Object;
  isNew       : Boolean;
begin
  if not GFRE_DBI.GetSystemScheme(TFRE_DB_VIRTUAL_FILESERVER,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_VIRTUAL_FILESERVER]);

  if input.FieldExists('serviceId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('serviceId').AsString),TFRE_DB_VIRTUAL_FILESERVER,vfsService));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_VIRTUAL_FILESERVER,vfsService.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin

    CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('data.customer').AsString),customer));
    if not customer.FieldExists('servicedomain') then
      raise EFRE_DB_Exception.Create(edb_ERROR,'The given customer has no service domain set!');

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VIRTUAL_FILESERVER,customer.Field('servicedomain').AsObjectLink) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
    idx:='VFS_'+customer.Field('servicedomain').AsString;//FIXXME - use uid of zone
    if coll.ExistsIndexed(idx) then begin
      Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vfs_create_error_exists_cap'),FetchModuleTextShort(ses,'vfs_create_error_exists_msg'),fdbmt_error);
      exit;
    end;

    vfsService:=TFRE_DB_VIRTUAL_FILESERVER.CreateForDB;
    vfsService.SetDomainID(customer.Field('servicedomain').AsObjectLink);
    vfsService.Field('objname').AsString:=idx;
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,vfsService,isNew,conn);

  if isNew then begin
    CheckDbResult(coll.Store(vfsService));
  end else begin
    CheckDbResult(conn.Update(vfsService));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  dbo       : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER,dbo.DomainID) then begin
      func:=CWSF(@WEB_VFSDelete);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_vfs'),'',func);
    end;
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  vfs           : IFRE_DB_Object;
  sel_guid      : TFRE_DB_GUID;
  sf            : TFRE_DB_SERVER_FUNC_DESC;
  editable      : Boolean;
begin
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedVFS') and (ses.GetSessionModuleData(ClassName).Field('selectedVFS').ValueCount=1)  then begin
    sel_guid := ses.GetSessionModuleData(ClassName).Field('selectedVFS').AsGUID;
    CheckDbResult(conn.Fetch(sel_guid,vfs));

    GFRE_DBI.GetSystemSchemeByName(vfs.SchemeClass,scheme);

    editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_VIRTUAL_FILESERVER,vfs.DomainID);

    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(FetchModuleTextShort(ses,'vfs_content_header'),true,editable);
    panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
    panel.FillWithObjectValues(vfs,ses);
    if editable then begin
      panel.SetElementDisabled('customer');
      sf:=CWSF(@WEB_StoreVFS);
      sf.AddParam.Describe('serviceId',vfs.UID_String);
      panel.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
    end;
    panel.contentId:='VIRTUAL_FS_CONTENT';
    Result:=panel;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(FetchModuleTextShort(ses,'vfs_content_header'));
    panel.contentId:='VIRTUAL_FS_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  del_disabled: Boolean;
  dbo         : IFRE_DB_Object;
  add_disabled: Boolean;
begin
  del_disabled:=true;
  add_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    if (input.Field('selected').ValueCount=1) then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
      if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER,dbo.DomainID) then begin
        del_disabled:=false;
      end;
      if conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE,dbo.DomainID) then begin
        add_disabled:=false;
      end;
    end;
    ses.GetSessionModuleData(ClassName).Field('selectedVFS').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedVFS')
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_vfs',del_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_share',add_disabled));
  if ses.isUpdatableContentVisible('VIRTUAL_FS_CONTENT') then begin
    Result:=WEB_VFSContent(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf        : TFRE_DB_SERVER_FUNC_DESC;
  fileserver: IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),fileserver));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER,fileserver.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_VFSDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'vfs_delete_diag_cap'),StringReplace(FetchModuleTextShort(ses,'vfs_delete_diag_msg'),'%vfs_str%',fileserver.Field('name').AsString,[rfReplaceAll]),fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i         : NativeInt;
  fileserver: IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),fileserver));
      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESERVER,fileserver.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(fileserver.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_AddVFSShare(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  scheme     : IFRE_DB_SchemeObject;
  res        : TFRE_DB_FORM_DIALOG_DESC;
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  fileserver : IFRE_DB_Object;
  dependend  : TFRE_DB_StringArray;
begin
  dependend  := GetDependencyFiltervalues(input,'uid_ref');
  if length(dependend)=0 then begin
     Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'vfs_share_add_diag_cap'),FetchModuleTextShort(ses,'vfs_share_add_no_fs_msg'),fdbmt_warning,nil);
     exit;
  end;
  CheckDbResult(conn.Fetch(FREDB_H2G(dependend[0]),fileserver));

  if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE,fileserver.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GFRE_DBI.GetSystemScheme(TFRE_DB_VIRTUAL_FILESHARE,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'vfs_share_add_diag_cap'),600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  sf:=CWSF(@WEB_StoreVFSShare);
  sf.AddParam.Describe('serviceId',fileserver.UID_String);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_StoreVFSShare(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject : IFRE_DB_SchemeObject;
  shareObj     : TFRE_DB_VIRTUAL_FILESHARE;
  isNew        : Boolean;
  shareColl    : IFRE_DB_COLLECTION;
  service      : IFRE_DB_Object;
  idx          : String;
begin
  if not GFRE_DBI.GetSystemScheme(TFRE_DB_VIRTUAL_FILESHARE,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_VIRTUAL_FILESHARE]);

  if input.FieldExists('shareId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('shareId').AsString),TFRE_DB_VIRTUAL_FILESHARE,shareObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE,shareObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('serviceId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_VIRTUAL_FILESHARE,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    shareColl:=conn.GetCollection(CFRE_DB_FILESHARE_COLLECTION);
    idx:='FS_'+ input.FieldPath('data.name').AsString + '@' + service.UID_String;
    if shareColl.ExistsIndexed(idx) then begin
      Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'vfs_share_create_error_exists_cap'),FetchModuleTextShort(ses,'vfs_share_create_error_exists_msg'),fdbmt_error);
      exit;
    end;
    shareObj:=TFRE_DB_VIRTUAL_FILESHARE.CreateForDB;
    shareObj.SetDomainID(service.DomainID);
    shareObj.Field('objname').AsString:=idx;
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,shareObj,isNew,conn);

  if isNew then begin
    shareObj.Field('fileserver').AsObjectLink:=service.UID;
    CheckDbResult(shareColl.Store(shareObj));
  end else begin
    CheckDbResult(conn.Update(shareObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareMenu(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  res       : TFRE_DB_MENU_DESC;
  func      : TFRE_DB_SERVER_FUNC_DESC;
  dbo       : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE,dbo.DomainID) then begin
      func:=CWSF(@WEB_VFSShareDelete);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_vfs_share'),'',func);
    end;
  end;
  Result:=res;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareContent(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  html          : TFRE_DB_HTML_DESC;
  panel         : TFRE_DB_FORM_PANEL_DESC;
  scheme        : IFRE_DB_SchemeObject;
  share         : IFRE_DB_Object;
  sel_guid      : TFRE_DB_GUID;
  sf            : TFRE_DB_SERVER_FUNC_DESC;
  editable      : Boolean;

begin
  CheckClassVisibility4MyDomain(ses);

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedVFSShare') and (ses.GetSessionModuleData(ClassName).Field('selectedVFSShare').ValueCount=1)  then begin
    sel_guid := ses.GetSessionModuleData(ClassName).Field('selectedVFSShare').AsGUID;

    CheckDbResult(conn.Fetch(sel_guid,share));
    editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE,share.DomainID);

    GFRE_DBI.GetSystemSchemeByName(share.SchemeClass,scheme);
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(FetchModuleTextShort(ses,'vfs_share_content_header'),true,editable);
    panel.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
    panel.FillWithObjectValues(share,ses);
    if editable then begin
      sf:=CWSF(@WEB_StoreVFSShare);
      sf.AddParam.Describe('shareId',share.UID_String);
      panel.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),TFRE_DB_SERVER_FUNC_DESC.create.Describe(share,'saveOperation'),fdbbt_submit);
    end;
    panel.contentId:='VIRTUAL_SHARE_CONTENT';
    Result:=panel;
  end else begin
    panel :=TFRE_DB_FORM_PANEL_DESC.Create.Describe(FetchModuleTextShort(ses,'vfs_share_content_header'));
    panel.contentId:='VIRTUAL_SHARE_CONTENT';
    Result:=panel;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  del_disabled: Boolean;
  dbo         : IFRE_DB_Object;
begin
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    if (input.Field('selected').ValueCount=1) then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
      if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE,dbo.DomainID) then begin
        del_disabled:=false;
      end;
    end;
    ses.GetSessionModuleData(ClassName).Field('selectedVFSShare').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedVFSShare');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_share',del_disabled));
  if ses.isUpdatableContentVisible('VIRTUAL_SHARE_CONTENT') then begin
    Result:=WEB_VFSShareContent(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareDelete(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  sf     : TFRE_DB_SERVER_FUNC_DESC;
  share  : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),share));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE,share.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_VFSShareDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'vfs_share_delete_diag_cap'),StringReplace(FetchModuleTextShort(ses,'vfs_share_delete_diag_msg'),'%share_str%',share.Field('name').AsString,[rfReplaceAll]),fdbmt_confirm,sf);
end;

function TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.WEB_VFSShareDeleteConfirmed(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
var
  i      : NativeInt;
  share  : IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),share));
      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_VIRTUAL_FILESHARE,share.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(share.UID));
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
     Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'share_group_in_diag_cap'),FetchModuleTextShort(ses,'share_group_in_no_share_msg'),fdbmt_warning,nil);
     exit;
  end;
  share_id   := dependend[0];

  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFRE_DB_VIRTUAL_FILESHARE) then begin
    res:=TFRE_DB_MENU_DESC.create.Describe;
    func:=CWSF(@WEB_VFSShareGroupSetRead);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_share_group_setread_on'),'',func);
    func:=CWSF(@WEB_VFSShareGroupSetWrite);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_share_group_setwrite_on'),'',func);
    func:=CWSF(@WEB_VFSShareGroupClearRead);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_share_group_setread_off'),'',func);
    func:=CWSF(@WEB_VFSShareGroupClearWrite);
    func.AddParam.Describe('share_id',share_id);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_share_group_setwrite_off'),'',func);
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

end.

