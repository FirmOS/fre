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
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_GLOBAL_FILESERVER }

  TFRE_DB_GLOBAL_FILESERVER=class(TFRE_DB_SERVICE)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_VIRTUAL_FILESERVER }

  TFRE_DB_VIRTUAL_FILESERVER=class(TFRE_DB_SERVICE)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_ZFS_SNAPSHOT }

  TFRE_DB_ZFS_SNAPSHOT=class(TFRE_DB_ObjectEx)
  public
  protected
    class procedure RegisterSystemScheme (const scheme : IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_ZFS_DATASET }

  TFRE_DB_ZFS_DATASET=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    procedure CALC_GetDisplayName        (const setter : IFRE_DB_CALCFIELD_SETTER);
  end;

  { TFRE_DB_ZFS_DATASET_FILE }

  TFRE_DB_ZFS_DATASET_FILE=class(TFRE_DB_ZFS_DATASET)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_ZFS_DATASET_ZVOL }

  TFRE_DB_ZFS_DATASET_ZVOL=class(TFRE_DB_ZFS_DATASET)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_NFS_FILESHARE }

  TFRE_DB_NFS_FILESHARE=class(TFRE_DB_ZFS_DATASET_FILE)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
  end;

  { TFRE_DB_LUN }

  TFRE_DB_LUN=class(TFRE_DB_ZFS_DATASET_ZVOL)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_VIRTUAL_FILESHARE }

  TFRE_DB_VIRTUAL_FILESHARE=class(TFRE_DB_ZFS_DATASET)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    procedure CALC_GetIcons              (const setter: IFRE_DB_CALCFIELD_SETTER);
  end;

  { TFRE_DB_NFS_ACCESS }

  TFRE_DB_NFS_ACCESS=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFRE_DB_LUN_VIEW }

  TFRE_DB_LUN_VIEW=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
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
  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('objname',GetTranslateableTextKey('scheme_snapshot'),true);
  group.AddInput('desc.txt',GetTranslateableTextKey('scheme_description'),false);
  group.AddInput('creation',GetTranslateableTextKey('scheme_creation'),true);
  group.AddInput('used_mb',GetTranslateableTextKey('scheme_used'),true);
  group.AddInput('refer_mb',GetTranslateableTextKey('scheme_refer'),true);
end;

class procedure TFRE_DB_ZFS_SNAPSHOT.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main_group','Snapshot Properties');
    StoreTranslateableText(conn,'scheme_snapshot','ZFS Snapshot');
    StoreTranslateableText(conn,'scheme_description','Description');
    StoreTranslateableText(conn,'scheme_creation','Creation Timestamp');
    StoreTranslateableText(conn,'scheme_used','Used [MB]');
    StoreTranslateableText(conn,'scheme_refer','Refer [MB]');
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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
  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main'));
  group.AddInput('initiatorgroup',GetTranslateableTextKey('scheme_initiatorgroup'));
  group.AddInput('targetgroup',GetTranslateableTextKey('scheme_targetgroup'));
end;

class procedure TFRE_DB_LUN_VIEW.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited;
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main','View Parameter');
    StoreTranslateableText(conn,'scheme_initiatorgroup','Initiator Group');
    StoreTranslateableText(conn,'scheme_targetgroup','Target Group');
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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
  group:=scheme.AddInputGroup('volume').Setup(GetTranslateableTextKey('scheme_volume_group'));
  group.AddInput('size_mb',GetTranslateableTextKey('scheme_size'));
  group.AddInput('primarycache',GetTranslateableTextKey('scheme_primarycache'));
  group.AddInput('secondarycache',GetTranslateableTextKey('scheme_secondarycache'));
end;

class procedure TFRE_DB_ZFS_DATASET_ZVOL.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
var
  enum: IFRE_DB_Enum;
begin
  inherited;
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_volume_group','Volume Properties');
    StoreTranslateableText(conn,'scheme_primarycache','Primary Cache');
    StoreTranslateableText(conn,'scheme_secondarycache','Secondary Cache');
    StoreTranslateableText(conn,'scheme_size','Size [MB]');

    StoreTranslateableText(conn,'enum_cache_none','None');
    StoreTranslateableText(conn,'enum_cache_all','All');
    StoreTranslateableText(conn,'enum_cache_metadata','Metadata');

    enum:=GFRE_DBI.NewEnum('cache').Setup(GFRE_DBI.CreateText('$enum_cache','Cache'));
    enum.addEntry('none',GetTranslateableTextKey('enum_cache_none'));
    enum.addEntry('all',GetTranslateableTextKey('enum_cache_all'));
    enum.addEntry('metadata',GetTranslateableTextKey('enum_cache_metadata'));
    GFRE_DBI.RegisterSysEnum(enum);
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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

  group:=scheme.AddInputGroup('file').Setup(GetTranslateableTextKey('scheme_file_group'));
  group.AddInput('quota_mb',GetTranslateableTextKey('scheme_quota'));
  group.AddInput('referenced_mb',GetTranslateableTextKey('scheme_referenced'));
  group.AddInput('accesstime',GetTranslateableTextKey('scheme_accesstime'));
  group.AddInput('allowdevices',GetTranslateableTextKey('scheme_allowdevices'));
  group.AddInput('allowexecution',GetTranslateableTextKey('scheme_allowexecution'));
  group.AddInput('allowsetuid',GetTranslateableTextKey('scheme_allowsetuid'));
  group.AddInput('snapshots',GetTranslateableTextKey('scheme_snapshots'));
  group.AddInput('aclinheritance',GetTranslateableTextKey('scheme_aclinheritance'));
  group.AddInput('aclmode',GetTranslateableTextKey('scheme_aclmode'));
  group.AddInput('canmount',GetTranslateableTextKey('scheme_canmount'));
  group.AddInput('extendedattr',GetTranslateableTextKey('scheme_extendedattr'));

end;

class procedure TFRE_DB_ZFS_DATASET_FILE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
var
  enum: IFRE_DB_Enum;
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_file_group','File Properties');
    StoreTranslateableText(conn,'scheme_refer','Refer [MB]');
    StoreTranslateableText(conn,'scheme_quota','Quota [MB]');
    StoreTranslateableText(conn,'scheme_used','Used [MB]');
    StoreTranslateableText(conn,'scheme_referenced','Referenced Quota [MB]');
    StoreTranslateableText(conn,'scheme_accesstime','Access Time');
    StoreTranslateableText(conn,'scheme_allowdevices','Allow Devices');
    StoreTranslateableText(conn,'scheme_allowexecution','Allow Execution');
    StoreTranslateableText(conn,'scheme_allowsetuid','Allow Set UID');
    StoreTranslateableText(conn,'scheme_snapshots','Show Snapshots');
    StoreTranslateableText(conn,'scheme_aclinheritance','ACL Inheritance');
    StoreTranslateableText(conn,'scheme_aclmode','ACL Mode');
    StoreTranslateableText(conn,'scheme_canmount','Can Mount');
    StoreTranslateableText(conn,'scheme_extendedattr','Extended Attributes');

    StoreTranslateableText(conn,'enum_aclinheritance_discard','Discard');
    StoreTranslateableText(conn,'enum_aclinheritance_noallow','NoAllow');
    StoreTranslateableText(conn,'enum_aclinheritance_restricted','Restricted');
    StoreTranslateableText(conn,'enum_aclinheritance_passthrough','Passthrough');
    StoreTranslateableText(conn,'enum_aclinheritance_passthroughx','Passthrough-X');

    enum:=GFRE_DBI.NewEnum('aclinheritance').Setup(GFRE_DBI.CreateText('$enum_aclinheritance','ACL Inheritance'));
    enum.addEntry('discard',GetTranslateableTextKey('enum_aclinheritance_discard'));
    enum.addEntry('noallow',GetTranslateableTextKey('enum_aclinheritance_noallow'));
    enum.addEntry('restricted',GetTranslateableTextKey('enum_aclinheritance_restricted'));
    enum.addEntry('passthrough',GetTranslateableTextKey('enum_aclinheritance_passthrough'));
    enum.addEntry('passthrough-x',GetTranslateableTextKey('enum_aclinheritance_passthroughx'));
    GFRE_DBI.RegisterSysEnum(enum);

    StoreTranslateableText(conn,'enum_aclmode_discard','Discard');
    StoreTranslateableText(conn,'enum_aclmode_groupmask','Groupmask');
    StoreTranslateableText(conn,'enum_aclinheritance_passthrough','Passthrough');

    enum:=GFRE_DBI.NewEnum('aclmode').Setup(GFRE_DBI.CreateText('$enum_aclmode','ACL Mode'));
    enum.addEntry('discard',GetTranslateableTextKey('enum_aclmode_discard'));
    enum.addEntry('groupmask',GetTranslateableTextKey('enum_aclmode_groupmask'));
    enum.addEntry('passthrough',GetTranslateableTextKey('enum_aclinheritance_passthrough'));
    GFRE_DBI.RegisterSysEnum(enum);

    StoreTranslateableText(conn,'enum_canmount_off','Off');
    StoreTranslateableText(conn,'enum_canmount_on','On');
    StoreTranslateableText(conn,'enum_canmount_noauto','NoAuto');

    enum:=GFRE_DBI.NewEnum('canmount').Setup(GFRE_DBI.CreateText('$enum_canmount','Can Mount'));
    enum.addEntry('off',GetTranslateableTextKey('enum_canmount_off'));
    enum.addEntry('on',GetTranslateableTextKey('enum_canmount_on'));
    enum.addEntry('noauto',GetTranslateableTextKey('enum_canmount_noauto'));
    GFRE_DBI.RegisterSysEnum(enum);

  end;
  VersionInstallCheck(currentVersionId,newVersionId);
end;

{ TFRE_DB_LUN }

class procedure TFRE_DB_LUN.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddSchemeField('writeback',fdbft_Boolean);
  scheme.AddSchemeField('writeprotect',fdbft_Boolean);
  group:=scheme.AddInputGroup('lun').Setup(GetTranslateableTextKey('scheme_lun_group'));
  group.AddInput('writeback',GetTranslateableTextKey('scheme_writeback'));
  group.AddInput('writeprotect',GetTranslateableTextKey('scheme_writeprotect'));
end;

class procedure TFRE_DB_LUN.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn,currentVersionId,newVersionId);
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_lun_group','LUN Parameter');
    StoreTranslateableText(conn,'scheme_writeback','Writeback');
    StoreTranslateableText(conn,'scheme_writeprotect','Writeprotect');
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
end;

{ TFRE_DB_NFS_ACCESS }

class procedure TFRE_DB_NFS_ACCESS.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group : IFRE_DB_InputGroupSchemeDefinition;
  enum  : IFRE_DB_Enum;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.ClassName);
  scheme.AddSchemeField('fileshare',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('accesstype',fdbft_String).SetupFieldDef(true,false,'nfs_access');
  scheme.AddSchemeField('subnet',fdbft_String).SetupFieldDef(true);
  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main'));
  group.AddInput('accesstype',GetTranslateableTextKey('scheme_accesstype'));
  group.AddInput('subnet',GetTranslateableTextKey('scheme_subnet'));

  enum:=GFRE_DBI.NewEnum('nfs_access').Setup(GFRE_DBI.CreateText('$enum_nfs_access','NFS Access'));
  enum.addEntry('rw',GetTranslateableTextKey('enum_nfs_access_rw'));
  enum.addEntry('ro',GetTranslateableTextKey('enum_nfs_access_ro'));
  enum.addEntry('root',GetTranslateableTextKey('enum_nfs_access_root'));
  GFRE_DBI.RegisterSysEnum(enum);

end;

class procedure TFRE_DB_NFS_ACCESS.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn,currentVersionId,newVersionId);
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main','Access Parameter');
    StoreTranslateableText(conn,'scheme_accesstype','Access Type');
    StoreTranslateableText(conn,'scheme_subnet','Subnet/Host');

    StoreTranslateableText(conn,'enum_nfs_access','NFS Access');
    StoreTranslateableText(conn,'enum_nfs_access_rw','Read-Write');
    StoreTranslateableText(conn,'enum_nfs_access_ro','Read-Only');
    StoreTranslateableText(conn,'enum_nfs_access_root','Root');

  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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
  group:=scheme.AddInputGroup('share').Setup(GetTranslateableTextKey('scheme_share'));
  group.AddInput('objname',GetTranslateableTextKey('scheme_sharename'));
  group.AddInput('cifs',GetTranslateableTextKey('scheme_cifs'));
  group.AddInput('afp',GetTranslateableTextKey('scheme_afp'));
  group.AddInput('ftp',GetTranslateableTextKey('scheme_ftp'));
  group.AddInput('webdav',GetTranslateableTextKey('scheme_webdav'));
end;

class procedure TFRE_DB_VIRTUAL_FILESHARE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn,currentVersionId,newVersionId);
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_share','Share Properties');
    StoreTranslateableText(conn,'scheme_sharename','Share Name');
    StoreTranslateableText(conn,'scheme_cifs','CIFS (Windows File Sharing)');
    StoreTranslateableText(conn,'scheme_afp','AFP (Apple Filing Protocol)');
    StoreTranslateableText(conn,'scheme_ftp','FTP (File Transfer Protocol)');
    StoreTranslateableText(conn,'scheme_webdav','WebDAV');
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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
  group:=scheme.AddInputGroup('nfs').Setup(GetTranslateableTextKey('scheme_NFS_group'));
  group.AddInput('objname',GetTranslateableTextKey('scheme_export'));
  group.AddInput('anonymous',GetTranslateableTextKey('scheme_anonymous'));
  group.AddInput('anonymousrw',GetTranslateableTextKey('scheme_anonymousrw'));
  group.AddInput('auth',GetTranslateableTextKey('scheme_auth'));
end;

class procedure TFRE_DB_NFS_FILESHARE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
var
  enum: IFRE_DB_Enum;
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_NFS_group','NFS Properties');
    StoreTranslateableText(conn,'scheme_export','Export name');
    StoreTranslateableText(conn,'scheme_anonymous','Anonymous access');
    StoreTranslateableText(conn,'scheme_anonymousrw','Anonymous RW access');
    StoreTranslateableText(conn,'scheme_auth','Authentication');

    StoreTranslateableText(conn,'enum_nfs_auth_sys','System users AUTH_SYS');
    StoreTranslateableText(conn,'enum_nfs_auth_none','Nobody AUTH_NONE');
    StoreTranslateableText(conn,'enum_nfs_auth_des','Public key AUTH_DES');
    StoreTranslateableText(conn,'enum_nfs_auth_k5','Kerberos V5');
    StoreTranslateableText(conn,'enum_nfs_auth_k5c','Kerberos V5 with checksums');
    StoreTranslateableText(conn,'enum_nfs_auth_k5ce','Kerberos V5 with checksums and encryption');

    enum:=GFRE_DBI.NewEnum('nfs_auth').Setup(GFRE_DBI.CreateText('$enum_nfs_auth','NFS Auth'));
    enum.addEntry('sys',GetTranslateableTextKey('enum_nfs_auth_sys'));
    enum.addEntry('none',GetTranslateableTextKey('enum_nfs_auth_none'));
    enum.addEntry('des',GetTranslateableTextKey('enum_nfs_auth_des'));
    enum.addEntry('k5',GetTranslateableTextKey('enum_nfs_auth_k5'));
    enum.addEntry('k5c',GetTranslateableTextKey('enum_nfs_auth_k5c'));
    enum.addEntry('k5ce',GetTranslateableTextKey('enum_nfs_auth_k5ce'));
    GFRE_DBI.RegisterSysEnum(enum);
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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

  group:=scheme.ReplaceInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('objname',GetTranslateableTextKey('scheme_fileservername'),false);
  group.AddInput('pool',GetTranslateableTextKey('scheme_pool'),true);
  group.AddInput('desc.txt',GetTranslateableTextKey('scheme_description'));
  group.AddInput('ip',GetTranslateableTextKey('scheme_ip'));
  group.AddInput('interface',GetTranslateableTextKey('scheme_interface'));
  group.AddInput('vlan',GetTranslateableTextKey('scheme_vlan'));
end;

class procedure TFRE_DB_VIRTUAL_FILESERVER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main_group','Virtual Fileserver Properties');
    StoreTranslateableText(conn,'scheme_fileservername','Servername');
    StoreTranslateableText(conn,'scheme_pool','Diskpool');
    StoreTranslateableText(conn,'scheme_description','Description');
    StoreTranslateableText(conn,'scheme_ip','IP');
    StoreTranslateableText(conn,'scheme_interface','Interface');
    StoreTranslateableText(conn,'scheme_vlan','Vlan');
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
end;


{ TFRE_DB_GLOBAL_FILESERVER }

class procedure TFRE_DB_GLOBAL_FILESERVER.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_FILESERVER.Classname);
end;

class procedure TFRE_DB_GLOBAL_FILESERVER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
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

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('fileserver','',true,true);
  group.AddInput('pool',GetTranslateableTextKey('scheme_pool'),true);
  group.AddInput('desc.txt',GetTranslateableTextKey('scheme_description'));
  group:=scheme.AddInputGroup('advanced').Setup(GetTranslateableTextKey('scheme_advanced_group'));
  group.AddInput('reservation_mb',GetTranslateableTextKey('scheme_reservation'));
  group.AddInput('refres_mb',GetTranslateableTextKey('scheme_refres'));
  group.AddInput('recordsize_kb',GetTranslateableTextKey('scheme_recordsize'));
  group.AddInput('logbias',GetTranslateableTextKey('scheme_logbias'));
  group.AddInput('deduplication',GetTranslateableTextKey('scheme_deduplication'));
  group.AddInput('checksum',GetTranslateableTextKey('scheme_checksum'));
  group.AddInput('compression',GetTranslateableTextKey('scheme_compression'));
  group.AddInput('readonly',GetTranslateableTextKey('scheme_readonly'));
  group.AddInput('copies',GetTranslateableTextKey('scheme_copies'));
  group.AddInput('sync',GetTranslateableTextKey('scheme_sync'));

end;

class procedure TFRE_DB_ZFS_DATASET.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
var
  enum: IFRE_DB_Enum;
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_pool','Diskpool');
    StoreTranslateableText(conn,'scheme_description','Description');
    StoreTranslateableText(conn,'scheme_advanced_group','Advanced Properties');
    StoreTranslateableText(conn,'scheme_reservation','Reservation [MB]');
    StoreTranslateableText(conn,'scheme_refres','Ref. Reservation [MB]');
    StoreTranslateableText(conn,'scheme_recordsize','Recordsize [kB]');
    StoreTranslateableText(conn,'scheme_logbias','Log Bias');
    StoreTranslateableText(conn,'scheme_deduplication','Deduplication');
    StoreTranslateableText(conn,'scheme_checksum','Checksum');
    StoreTranslateableText(conn,'scheme_compression','Compression');
    StoreTranslateableText(conn,'scheme_readonly','Read-Only');
    StoreTranslateableText(conn,'scheme_copies','Copies');
    StoreTranslateableText(conn,'scheme_sync','Sync');

    StoreTranslateableText(conn,'enum_logbias_latency','Latency');
    StoreTranslateableText(conn,'enum_logbias_throughput','Throughput');

    enum:=GFRE_DBI.NewEnum('logbias').Setup(GFRE_DBI.CreateText('$enum_logbias','Log Bias'));
    enum.addEntry('latency',GetTranslateableTextKey('enum_logbias_latency'));
    enum.addEntry('throughput',GetTranslateableTextKey('enum_logbias_throughput'));
    GFRE_DBI.RegisterSysEnum(enum);

    StoreTranslateableText(conn,'enum_compression_off','Off');
    StoreTranslateableText(conn,'enum_compression_on','On');
    StoreTranslateableText(conn,'enum_compression_gzip','Gzip');
    StoreTranslateableText(conn,'enum_compression_gzip-1','Gzip-1');
    StoreTranslateableText(conn,'enum_compression_gzip-2','Gzip-2');
    StoreTranslateableText(conn,'enum_compression_gzip-3','Gzip-3');
    StoreTranslateableText(conn,'enum_compression_gzip-4','Gzip-4');
    StoreTranslateableText(conn,'enum_compression_gzip-5','Gzip-5');
    StoreTranslateableText(conn,'enum_compression_gzip-6','Gzip-6');
    StoreTranslateableText(conn,'enum_compression_gzip-7','Gzip-7');
    StoreTranslateableText(conn,'enum_compression_gzip-8','Gzip-8');
    StoreTranslateableText(conn,'enum_compression_gzip-9','Gzip-9');

    enum:=GFRE_DBI.NewEnum('compression').Setup(GFRE_DBI.CreateText('$enum_compression','Compression'));
    enum.addEntry('off',GetTranslateableTextKey('enum_compression_off'));
    enum.addEntry('on',GetTranslateableTextKey('enum_compression_on'));
    enum.addEntry('gzip',GetTranslateableTextKey('enum_compression_gzip'));
    enum.addEntry('gzip-1',GetTranslateableTextKey('enum_compression_gzip-1'));
    enum.addEntry('gzip-2',GetTranslateableTextKey('enum_compression_gzip-2'));
    enum.addEntry('gzip-3',GetTranslateableTextKey('enum_compression_gzip-3'));
    enum.addEntry('gzip-4',GetTranslateableTextKey('enum_compression_gzip-4'));
    enum.addEntry('gzip-5',GetTranslateableTextKey('enum_compression_gzip-5'));
    enum.addEntry('gzip-6',GetTranslateableTextKey('enum_compression_gzip-6'));
    enum.addEntry('gzip-7',GetTranslateableTextKey('enum_compression_gzip-7'));
    enum.addEntry('gzip-8',GetTranslateableTextKey('enum_compression_gzip-8'));
    enum.addEntry('gzip-9',GetTranslateableTextKey('enum_compression_gzip-9'));
    GFRE_DBI.RegisterSysEnum(enum);

    StoreTranslateableText(conn,'enum_copies_1','1');
    StoreTranslateableText(conn,'enum_copies_2','2');
    StoreTranslateableText(conn,'enum_copies_3','3');

    enum:=GFRE_DBI.NewEnum('copies').Setup(GFRE_DBI.CreateText('$enum_copies','Copies'));
    enum.addEntry('1',GetTranslateableTextKey('enum_copies_1'));
    enum.addEntry('2',GetTranslateableTextKey('enum_copies_2'));
    enum.addEntry('3',GetTranslateableTextKey('enum_copies_3'));
    GFRE_DBI.RegisterSysEnum(enum);

    StoreTranslateableText(conn,'enum_sync_standard','Standard');
    StoreTranslateableText(conn,'enum_sync_always','Always');
    StoreTranslateableText(conn,'enum_sync_disabled','Disabled');

    enum:=GFRE_DBI.NewEnum('sync').Setup(GFRE_DBI.CreateText('$enum_sync','Sync Mode'));
    enum.addEntry('standard',GetTranslateableTextKey('enum_sync_standard'));
    enum.addEntry('always',GetTranslateableTextKey('enum_sync_always'));
    enum.addEntry('disabled',GetTranslateableTextKey('enum_sync_disabled'));
    GFRE_DBI.RegisterSysEnum(enum);
  end;
  VersionInstallCheck(currentVersionId,newVersionId);
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

class procedure TFRE_DB_FILESERVER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;

procedure Register_DB_Extensions;
begin
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

