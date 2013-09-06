unit fos_firmbox_fileserver;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$codepage utf-8}

interface

uses
  Classes, SysUtils,FOS_TOOL_INTERFACES,
  FRE_DB_COMMON,
  FRE_DBBUSINESS,
  fre_hal_schemes,
  FRE_DB_INTERFACE,
  FRE_SYSTEM;

type

  { TFRE_DB_FILESERVER }

  TFRE_DB_FILESERVER=class(TFRE_DB_SERVICE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_GLOBAL_FILESERVER }

  TFRE_DB_GLOBAL_FILESERVER=class(TFRE_DB_SERVICE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_VIRTUAL_FILESERVER }

  TFRE_DB_VIRTUAL_FILESERVER=class(TFRE_DB_SERVICE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_ZFS_SNAPSHOT }

  TFRE_DB_ZFS_SNAPSHOT=class(TFRE_DB_ObjectEx)
  public
  protected
    class procedure RegisterSystemScheme    (const scheme : IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects        (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_ZFS_DATASET }

  TFRE_DB_ZFS_DATASET=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  published
    procedure CALC_GetDisplayName  (const setter : IFRE_DB_CALCFIELD_SETTER);
  end;

  { TFRE_DB_ZFS_DATASET_FILE }

  TFRE_DB_ZFS_DATASET_FILE=class(TFRE_DB_ZFS_DATASET)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_ZFS_DATASET_ZVOL }

  TFRE_DB_ZFS_DATASET_ZVOL=class(TFRE_DB_ZFS_DATASET)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_NFS_FILESHARE }

  TFRE_DB_NFS_FILESHARE=class(TFRE_DB_ZFS_DATASET_FILE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  published
    class function  IMC_NewOperation(const input:IFRE_DB_Object):IFRE_DB_Object;override;
  end;

  { TFRE_DB_LUN }

  TFRE_DB_LUN=class(TFRE_DB_ZFS_DATASET_ZVOL)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_VIRTUAL_FILESHARE }

  TFRE_DB_VIRTUAL_FILESHARE=class(TFRE_DB_ZFS_DATASET)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  published
    procedure CALC_GetIcons(const setter: IFRE_DB_CALCFIELD_SETTER);
  end;

  { TFRE_DB_NFS_ACCESS }

  TFRE_DB_NFS_ACCESS=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_LUN_VIEW }

  TFRE_DB_LUN_VIEW=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION); override;
  end;


procedure Register_DB_Extensions;

implementation

{ TFRE_DB_ZFS_SNAPSHOT }

class procedure TFRE_DB_ZFS_SNAPSHOT.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.Classname);
  scheme.GetSchemeField('objname').required:=true;                      // zfs snapshot
  scheme.AddSchemeField('parentid',fdbft_ObjLink);                      // parent id e.g. fileshare,lun
  scheme.AddSchemeField('creation',fdbft_DateTimeUTC);
  scheme.AddSchemeField('used_mb',fdbft_UInt32);
  scheme.AddSchemeField('refer_mb',fdbft_UInt32);
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_ZFS_SNAPSHOT_main_group');
  group.AddInput('objname','$scheme_TFRE_DB_ZFS_SNAPSHOT_snapshot',true);
  group.AddInput('desc.txt','$scheme_TFRE_DB_ZFS_SNAPSHOT_description',false);
  group.AddInput('creation','$scheme_TFRE_DB_ZFS_SNAPSHOT_creation',true);
  group.AddInput('used_mb','$scheme_TFRE_DB_ZFS_SNAPSHOT_used',true);
  group.AddInput('refer_mb','$scheme_TFRE_DB_ZFS_SNAPSHOT_refer',true);
end;

class procedure TFRE_DB_ZFS_SNAPSHOT.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
 conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_SNAPSHOT_main_group','Snapshot Properties'));
 conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_SNAPSHOT_snapshot','ZFS Snapshot'));
 conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_SNAPSHOT_description','Description'));
 conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_SNAPSHOT_creation','Creation Timestamp'));
 conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_SNAPSHOT_used','Used [MB]'));
 conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_SNAPSHOT_refer','Refer [MB]'));
end;

{ TFRE_DB_LUN_VIEW }

class procedure TFRE_DB_LUN_VIEW.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.ClassName);
  scheme.AddSchemeField('fileshare',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('initiatorgroup',fdbft_String);
  scheme.AddSchemeField('targetgroup',fdbft_String);
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_LUN_VIEW_main');
  group.AddInput('initiatorgroup','$scheme_TFRE_DB_LUN_VIEW_initiatorgroup');
  group.AddInput('targetgroup','$scheme_TFRE_DB_LUN_VIEW_targetgroup');
end;

class procedure TFRE_DB_LUN_VIEW.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_LUN_VIEW_main','View Parameter'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_LUN_VIEW_initiatorgroup','Initiator Group'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_LUN_VIEW_targetgroup','Target Group'));
end;

{ TFRE_DB_ZFS_DATASET_ZVOL }

class procedure TFRE_DB_ZFS_DATASET_ZVOL.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ZFS_DATASET.Classname);
  scheme.AddSchemeField('size_mb',fdbft_UInt32);
  scheme.AddSchemeField('primarycache',fdbft_String).SetupFieldDef(true,false,'cache');
  scheme.AddSchemeField('secondarycache',fdbft_String).SetupFieldDef(true,false,'cache');
  group:=scheme.AddInputGroup('volume').Setup('$scheme_TFRE_DB_ZFS_DATASET_ZVOL_volume_group');
  group.AddInput('size_mb','$scheme_TFRE_DB_ZFS_DATASET_ZVOL_size');
  group.AddInput('primarycache','$scheme_TFRE_DB_ZFS_DATASET_ZVOL_primarycache');
  group.AddInput('secondarycache','$scheme_TFRE_DB_ZFS_DATASET_ZVOL_secondarycache');
end;

class procedure TFRE_DB_ZFS_DATASET_ZVOL.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_ZVOL_volume_group','Volume Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_ZVOL_primarycache','Primary Cache'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_ZVOL_secondarycache','Secondary Cache'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_ZVOL_size','Size [MB]'));
end;

{ TFRE_DB_ZFS_DATASET_FILE }

class procedure TFRE_DB_ZFS_DATASET_FILE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ZFS_DATASET.Classname);
  scheme.AddSchemeField('quota_mb',fdbft_UInt32);
  scheme.AddSchemeField('referenced_mb',fdbft_UInt32);
  scheme.AddSchemeField('refer_mb',fdbft_UInt32);
  scheme.AddSchemeField('used_mb',fdbft_UInt32);
  scheme.AddSchemeField('accesstime',fdbft_Boolean);
  scheme.AddSchemeField('allowdevices',fdbft_Boolean);
  scheme.AddSchemeField('allowexecution',fdbft_Boolean);
  scheme.AddSchemeField('allowsetuid',fdbft_Boolean);
  scheme.AddSchemeField('aclinheritance',fdbft_String).SetupFieldDef(true,false,'aclinheritance');
  scheme.AddSchemeField('aclmode',fdbft_String).SetupFieldDef(true,false,'aclmode');
  scheme.AddSchemeField('canmount',fdbft_String).SetupFieldDef(true,false,'canmount');
  scheme.AddSchemeField('extendedattr',fdbft_Boolean);

  group:=scheme.AddInputGroup('file').Setup('$scheme_TFRE_DB_ZFS_DATASET_FILE_file_group');
  group.AddInput('quota_mb','$scheme_TFRE_DB_ZFS_DATASET_FILE_quota');
  group.AddInput('referenced_mb','$scheme_TFRE_DB_ZFS_DATASET_FILE_referenced');
  group.AddInput('accesstime','$scheme_TFRE_DB_ZFS_DATASET_FILE_accesstime');
  group.AddInput('allowdevices','$scheme_TFRE_DB_ZFS_DATASET_FILE_allowdevices');
  group.AddInput('allowexecution','$scheme_TFRE_DB_ZFS_DATASET_FILE_allowexecution');
  group.AddInput('allowsetuid','$scheme_TFRE_DB_ZFS_DATASET_FILE_allowsetuid');
  group.AddInput('snapshots','$scheme_TFRE_DB_ZFS_DATASET_FILE_snapshots');
  group.AddInput('aclinheritance','$scheme_TFRE_DB_ZFS_DATASET_FILE_aclinheritance');
  group.AddInput('aclmode','$scheme_TFRE_DB_ZFS_DATASET_FILE_aclmode');
  group.AddInput('canmount','$scheme_TFRE_DB_ZFS_DATASET_FILE_canmount');
  group.AddInput('extendedattr','$scheme_TFRE_DB_ZFS_DATASET_FILE_extendedattr');

end;

class procedure TFRE_DB_ZFS_DATASET_FILE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_file_group','File Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_refer','Refer [MB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_quota','Quota [MB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_used','Used [MB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_referenced','Referenced Quota [MB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_accesstime','Access Time'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_allowdevices','Allow Devices'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_allowexecution','Allow Execution'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_allowsetuid','Allow Set UID'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_snapshots','Show Snapshots'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_aclinheritance','ACL Inheritance'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_aclmode','ACL Mode'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_canmount','Can Mount'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_FILE_extendedattr','Extended Attributes'));
end;

{ TFRE_DB_LUN }

class procedure TFRE_DB_LUN.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddSchemeField('writeback',fdbft_Boolean);
  scheme.AddSchemeField('writeprotect',fdbft_Boolean);
  group:=scheme.AddInputGroup('lun').Setup('$scheme_TFRE_DB_LUN_lun_group');
  group.AddInput('writeback','$scheme_TFRE_DB_LUN_writeback');
  group.AddInput('writeprotect','$scheme_TFRE_DB_LUN_writeprotect');
end;

class procedure TFRE_DB_LUN.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_LUN_lun_group','LUN Parameter'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_LUN_writeback','Writeback'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_LUN_writeprotect','Writeprotect'));
end;

{ TFRE_DB_NFS_ACCESS }

class procedure TFRE_DB_NFS_ACCESS.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.ClassName);
  scheme.AddSchemeField('fileshare',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('accesstype',fdbft_String).SetupFieldDef(true,false,'nfs_access');
  scheme.AddSchemeField('subnet',fdbft_String).SetupFieldDef(true);
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_NFS_ACCESS_main');
  group.AddInput('accesstype','$scheme_TFRE_DB_NFS_ACCESS_accesstype');
  group.AddInput('subnet','$scheme_TFRE_DB_NFS_ACCESS_subnet');
end;

class procedure TFRE_DB_NFS_ACCESS.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_ACCESS_main','Access Parameter'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_ACCESS_accesstype','Access Type'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_ACCESS_subnet','Subnet/Host'));
end;

{ TFRE_DB_VIRTUAL_FILESHARE }

class procedure TFRE_DB_VIRTUAL_FILESHARE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ZFS_DATASET_FILE.ClassName);
  scheme.AddSchemeField('cifs',fdbft_Boolean);
  scheme.AddSchemeField('nfs',fdbft_Boolean);
  scheme.AddSchemeField('afp',fdbft_Boolean);
  scheme.AddSchemeField('ftp',fdbft_Boolean);
  scheme.AddSchemeField('webdav',fdbft_Boolean);
  scheme.AddCalcSchemeField('icons',fdbft_String,@CALC_GetIcons);
  group:=scheme.AddInputGroup('share').Setup('$scheme_TFRE_DB_VIRTUAL_FILESHARE_share');
  group.AddInput('objname','$scheme_TFRE_DB_VIRTUAL_FILESHARE_sharename');
  group.AddInput('cifs','$scheme_TFRE_DB_VIRTUAL_FILESHARE_cifs');
  group.AddInput('afp','$scheme_TFRE_DB_VIRTUAL_FILESHARE_afp');
  group.AddInput('ftp','$scheme_TFRE_DB_VIRTUAL_FILESHARE_ftp');
  group.AddInput('webdav','$scheme_TFRE_DB_VIRTUAL_FILESHARE_webdav');
end;

class procedure TFRE_DB_VIRTUAL_FILESHARE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESHARE_share','Share Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESHARE_sharename','Share Name'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESHARE_cifs','CIFS (Windows File Sharing)'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESHARE_afp','AFP (Apple Filing Protocol)'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESHARE_ftp','FTP (File Transfer Protocol)'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESHARE_webdav','WebDAV'));
end;

procedure TFRE_DB_VIRTUAL_FILESHARE.CALC_GetIcons(const setter: IFRE_DB_CALCFIELD_SETTER);
var    licon    : TFRE_DB_String;

  procedure AddIcon(const fieldname: string);
  begin
   if FieldExists(fieldname) then begin
    if Field(fieldname).AsBoolean then begin
     if length(licon)>0 then begin
      licon := licon +',';
     end;
     licon := licon + 'images_apps/firmbox_storage/'+fieldname+'.png';
    end;
   end;
  end;

begin
  licon := '';
  AddIcon('cifs');
  AddIcon('afp');
  AddIcon('nfs');
  AddIcon('ftp');
  AddIcon('webdav');
  setter.SetAsString(licon);
end;

{ TFRE_DB_NFS_FILESHARE }

class procedure TFRE_DB_NFS_FILESHARE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ZFS_DATASET_FILE.ClassName);
  scheme.AddSchemeField('anonymous',fdbft_Boolean);
  scheme.AddSchemeField('anonymousrw',fdbft_Boolean);
  scheme.AddSchemeField('auth',fdbft_String).SetupFieldDef(true,false,'nfs_auth');
  group:=scheme.AddInputGroup('nfs').Setup('$scheme_TFRE_DB_NFS_FILESHARE_NFS_group');
  group.AddInput('objname','$scheme_TFRE_DB_NFS_FILESHARE_export');
  group.AddInput('anonymous','$scheme_TFRE_DB_NFS_FILESHARE_anonymous');
  group.AddInput('anonymousrw','$scheme_TFRE_DB_NFS_FILESHARE_anonymousrw');
  group.AddInput('auth','$scheme_TFRE_DB_NFS_FILESHARE_auth');
end;

class procedure TFRE_DB_NFS_FILESHARE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_FILESHARE_NFS_group','NFS Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_FILESHARE_export','Export name'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_FILESHARE_anonymous','Anonymous access'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_FILESHARE_anonymousrw','Anonymous RW access'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_NFS_FILESHARE_auth','Authentication'));
end;

class function TFRE_DB_NFS_FILESHARE.IMC_NewOperation(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=inherited IMC_NewOperation(input);
end;

{ TFRE_DB_VIRTUAL_FILESERVER }

class procedure TFRE_DB_VIRTUAL_FILESERVER.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_FILESERVER.Classname);
  scheme.GetSchemeField('objname').required:=true;
  scheme.AddSchemeField('ip',fdbft_String).required:=true;
  scheme.AddSchemeField('pool',fdbft_String).required:=true;
  scheme.AddSchemeField('interface',fdbft_String);
  scheme.AddSchemeField('vlan',fdbft_UInt16);
  scheme.AddSchemeField('domainid',fdbft_GUID);

  group:=scheme.ReplaceInputGroup('main').Setup('$scheme_TFRE_DB_VIRTUAL_FILESERVER_main_group');
  group.AddInput('objname','$scheme_TFRE_DB_VIRTUAL_FILESERVER_fileservername',false);
  group.AddInput('pool','$scheme_TFRE_DB_VIRTUAL_FILESERVER_pool',false);
  //group.AddInput('pool','$scheme_TFRE_DB_VIRTUAL_FILESERVER_pool',true); -> FISH TO FIX FOR CHRIS
  group.AddInput('desc.txt','$scheme_TFRE_DB_VIRTUAL_FILESERVER_description');
  group.AddInput('ip','$scheme_TFRE_DB_VIRTUAL_FILESERVER_ip');
  group.AddInput('interface','$scheme_TFRE_DB_VIRTUAL_FILESERVER_interface');
  group.AddInput('vlan','$scheme_TFRE_DB_VIRTUAL_FILESERVER_vlan');
end;

class procedure TFRE_DB_VIRTUAL_FILESERVER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin

  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_main_group','Virtual Fileserver Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_fileservername','Servername'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_pool','Diskpool'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_description','Description'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_ip','IP'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_interface','Interface'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_VIRTUAL_FILESERVER_vlan','Vlan'));
end;


{ TFRE_DB_GLOBAL_FILESERVER }

class procedure TFRE_DB_GLOBAL_FILESERVER.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_FILESERVER.Classname);
end;

class procedure TFRE_DB_GLOBAL_FILESERVER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin

end;

{ TFRE_DB_ZFS_DATASET }

class procedure TFRE_DB_ZFS_DATASET.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.Classname);
  scheme.GetSchemeField('objname').required:=true;
  scheme.AddSchemeField('fileserver',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('pool',fdbft_String).required:=true;
  scheme.AddSchemeField('reservation_mb',fdbft_UInt32);
  scheme.AddSchemeField('refres_mb',fdbft_UInt32);
  scheme.AddSchemeField('recordsize_kb',fdbft_UInt16);
  scheme.AddSchemeField('readonly',fdbft_Boolean);
  scheme.AddSchemeField('logbias',fdbft_String).SetupFieldDef(true,false,'logbias');
  scheme.AddSchemeField('deduplication',fdbft_Boolean);
  scheme.AddSchemeField('checksum',fdbft_Boolean);
  scheme.AddSchemeField('compression',fdbft_String).SetupFieldDef(true,false,'compression');
  scheme.AddSchemeField('snapshots',fdbft_Boolean);
  scheme.AddSchemeField('copies',fdbft_String).SetupFieldDef(true,false,'copies');
  scheme.AddSchemeField('sync',fdbft_String).SetupFieldDef(true,false,'sync');
  scheme.AddSchemeField('fileservername',fdbft_String);
  scheme.AddCalcSchemeField ('displayname',fdbft_String,@CALC_GetDisplayName);

  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_ZFS_DATASET_main_group');
  group.AddInput('fileserver','',true,true);
  group.AddInput('pool','$scheme_TFRE_DB_ZFS_DATASET_pool',true);
  group.AddInput('desc.txt','$scheme_TFRE_DB_ZFS_DATASET_description');
  group:=scheme.AddInputGroup('advanced').Setup('$scheme_TFRE_DB_ZFS_DATASET_advanced_group');
  group.AddInput('reservation_mb','$scheme_TFRE_DB_ZFS_DATASET_reservation');
  group.AddInput('refres_mb','$scheme_TFRE_DB_ZFS_DATASET_refres');
  group.AddInput('recordsize_kb','$scheme_TFRE_DB_ZFS_DATASET_recordsize');
  group.AddInput('logbias','$scheme_TFRE_DB_ZFS_DATASET_logbias');
  group.AddInput('deduplication','$scheme_TFRE_DB_ZFS_DATASET_deduplication');
  group.AddInput('checksum','$scheme_TFRE_DB_ZFS_DATASET_checksum');
  group.AddInput('compression','$scheme_TFRE_DB_ZFS_DATASET_compression');
  group.AddInput('readonly','$scheme_TFRE_DB_ZFS_DATASET_readonly');
  group.AddInput('copies','$scheme_TFRE_DB_ZFS_DATASET_copies');
  group.AddInput('sync','$scheme_TFRE_DB_ZFS_DATASET_sync');

end;

class procedure TFRE_DB_ZFS_DATASET.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_main_group','General Information'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_pool','Diskpool'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_description','Description'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_advanced_group','Advanced Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_reservation','Reservation [MB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_refres','Ref. Reservation [MB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_recordsize','Recordsize [kB]'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_logbias','Log Bias'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_deduplication','Deduplication'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_checksum','Checksum'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_compression','Compression'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_readonly','Read-Only'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_copies','Copies'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_ZFS_DATASET_sync','Sync'));
end;

procedure TFRE_DB_ZFS_DATASET.CALC_GetDisplayName(const setter: IFRE_DB_CALCFIELD_SETTER);
begin
  setter.SetAsString(Field('fileservername').AsString+'/'+Field('objname').AsString);
end;

{ TFRE_DB_FILESERVER }

class procedure TFRE_DB_FILESERVER.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_SERVICE.Classname);
end;

class procedure TFRE_DB_FILESERVER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

procedure Register_DB_Extensions;
var enum : IFRE_DB_Enum;
begin
  enum:=GFRE_DBI.NewEnum('nfs_access').Setup(GFRE_DBI.CreateText('$enum_nfs_access','NFS Access'));
  enum.addEntry('rw',GFRE_DBI.CreateText('$enum_nfs_access_rw','Read-Write'));
  enum.addEntry('ro',GFRE_DBI.CreateText('$enum_nfs_access_ro','Read-Only'));
  enum.addEntry('root',GFRE_DBI.CreateText('$enum_nfs_access_root','Root'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('nfs_auth').Setup(GFRE_DBI.CreateText('$enum_nfs_auth','NFS Auth'));
  enum.addEntry('sys',GFRE_DBI.CreateText('$enum_nfs_auth_sys','System users AUTH_SYS'));
  enum.addEntry('none',GFRE_DBI.CreateText('$enum_nfs_auth_none','Nobody AUTH_NONE'));
  enum.addEntry('des',GFRE_DBI.CreateText('$enum_nfs_auth_des','Public key AUTH_DES'));
  enum.addEntry('k5',GFRE_DBI.CreateText('$enum_nfs_auth_k5','Kerberos V5'));
  enum.addEntry('k5c',GFRE_DBI.CreateText('$enum_nfs_auth_k5c','Kerberos V5 with checksums'));
  enum.addEntry('k5ce',GFRE_DBI.CreateText('$enum_nfs_auth_k5ce','Kerberos V5 with checksums and encryption'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('logbias').Setup(GFRE_DBI.CreateText('$enum_logbias','Log Bias'));
  enum.addEntry('latency',GFRE_DBI.CreateText('$enum_logbias_latency','Latency'));
  enum.addEntry('throughput',GFRE_DBI.CreateText('$enum_logbias_throughput','Throughput'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('compression').Setup(GFRE_DBI.CreateText('$enum_compression','Compression'));
  enum.addEntry('off',GFRE_DBI.CreateText('$enum_compression_off','Off'));
  enum.addEntry('on',GFRE_DBI.CreateText('$enum_compression_on','On'));
  enum.addEntry('gzip',GFRE_DBI.CreateText('$enum_compression_gzip','Gzip'));
  enum.addEntry('gzip-1',GFRE_DBI.CreateText('$enum_compression_gzip-1','Gzip-1'));
  enum.addEntry('gzip-2',GFRE_DBI.CreateText('$enum_compression_gzip-2','Gzip-2'));
  enum.addEntry('gzip-3',GFRE_DBI.CreateText('$enum_compression_gzip-3','Gzip-3'));
  enum.addEntry('gzip-4',GFRE_DBI.CreateText('$enum_compression_gzip-4','Gzip-4'));
  enum.addEntry('gzip-5',GFRE_DBI.CreateText('$enum_compression_gzip-5','Gzip-5'));
  enum.addEntry('gzip-6',GFRE_DBI.CreateText('$enum_compression_gzip-6','Gzip-6'));
  enum.addEntry('gzip-7',GFRE_DBI.CreateText('$enum_compression_gzip-7','Gzip-7'));
  enum.addEntry('gzip-8',GFRE_DBI.CreateText('$enum_compression_gzip-8','Gzip-8'));
  enum.addEntry('gzip-9',GFRE_DBI.CreateText('$enum_compression_gzip-9','Gzip-9'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('aclinheritance').Setup(GFRE_DBI.CreateText('$enum_aclinheritance','ACL Inheritance'));
  enum.addEntry('discard',GFRE_DBI.CreateText('$enum_aclinheritance_discard','Discard'));
  enum.addEntry('noallow',GFRE_DBI.CreateText('$enum_aclinheritance_noallow','NoAllow'));
  enum.addEntry('restricted',GFRE_DBI.CreateText('$enum_aclinheritance_restricted','Restricted'));
  enum.addEntry('passthrough',GFRE_DBI.CreateText('$enum_aclinheritance_passthrough','Passthrough'));
  enum.addEntry('passthrough-x',GFRE_DBI.CreateText('$enum_aclinheritance_passthroughx','Passthrough-X'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('aclmode').Setup(GFRE_DBI.CreateText('$enum_aclmode','ACL Mode'));
  enum.addEntry('discard',GFRE_DBI.CreateText('$enum_aclmode_discard','Discard'));
  enum.addEntry('groupmask',GFRE_DBI.CreateText('$enum_aclmode_groupmask','Groupmask'));
  enum.addEntry('passthrough',GFRE_DBI.CreateText('$enum_aclinheritance_passthrough','Passthrough'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('canmount').Setup(GFRE_DBI.CreateText('$enum_canmount','Can Mount'));
  enum.addEntry('off',GFRE_DBI.CreateText('$enum_canmount_off','Off'));
  enum.addEntry('on',GFRE_DBI.CreateText('$enum_canmount_on','On'));
  enum.addEntry('noauto',GFRE_DBI.CreateText('$enum_canmount_noauto','NoAuto'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('copies').Setup(GFRE_DBI.CreateText('$enum_copies','Copies'));
  enum.addEntry('1',GFRE_DBI.CreateText('$enum_copies_1','1'));
  enum.addEntry('2',GFRE_DBI.CreateText('$enum_copies_2','2'));
  enum.addEntry('3',GFRE_DBI.CreateText('$enum_copies_3','3'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('sync').Setup(GFRE_DBI.CreateText('$enum_sync','Sync Mode'));
  enum.addEntry('standard',GFRE_DBI.CreateText('$enum_sync_standard','Standard'));
  enum.addEntry('always',GFRE_DBI.CreateText('$enum_sync_always','Always'));
  enum.addEntry('disabled',GFRE_DBI.CreateText('$enum_sync_disabled','Disabled'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('cache').Setup(GFRE_DBI.CreateText('$enum_cache','Cache'));
  enum.addEntry('none',GFRE_DBI.CreateText('$enum_cache_none','None'));
  enum.addEntry('all',GFRE_DBI.CreateText('$enum_cache_all','All'));
  enum.addEntry('metadata',GFRE_DBI.CreateText('$enum_cache_metadata','Metadata'));
  GFRE_DBI.RegisterSysEnum(enum);

  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ZFS_DATASET);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ZFS_DATASET_FILE);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ZFS_DATASET_ZVOL);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ZFS_SNAPSHOT);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_NFS_ACCESS);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_NFS_FILESHARE);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_LUN_VIEW);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_LUN);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_VIRTUAL_FILESHARE);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_FILESERVER);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_GLOBAL_FILESERVER);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_VIRTUAL_FILESERVER);
  GFRE_DBI.Initialize_Extension_Objects;
end;


end.

