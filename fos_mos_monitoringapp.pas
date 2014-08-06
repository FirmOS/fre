unit fos_mos_monitoringapp;

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
  FRE_DB_COMMON,
  fre_hal_disk_enclosure_pool_mangement,
  fre_zfs,
  fre_scsi,
  fre_hal_schemes,
  fre_diff_transport,
  fre_monitoring,
  fre_hal_mos;

type

  { TFOS_CITYCOM_MONITORING_APP }

  TFOS_CITYCOM_MONITORING_APP=class(TFRE_DB_APPLICATION)
  private

    procedure       SetupApplicationStructure     ; override;
    procedure       _UpdateSitemap                (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize           (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion            (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme          (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects              (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain       (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    class procedure InstallDBObjects4SysDomain    (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    class procedure InstallUserDBObjects          (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_DISK_DATA_FEED            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_MOS_DATA_FEED             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_CITYCOM_MOS_HIERARCHICAL_MOD }

  TFOS_CITYCOM_MOS_HIERARCHICAL_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _getMOSObjContent                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridMenu                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridSC                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_CITYCOM_MOS_STRUCTURAL_MOD }

  TFOS_CITYCOM_MOS_STRUCTURAL_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_MOS_HIERARCHICAL_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_MOS_STRUCTURAL_MOD);

  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_MONITORING_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_CITYCOM_MOS_STRUCTURAL_MOD }

class procedure TFOS_CITYCOM_MOS_STRUCTURAL_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_CITYCOM_MOS_STRUCTURAL_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('structural_description')
end;

class procedure TFOS_CITYCOM_MOS_STRUCTURAL_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;

end;

function TFOS_CITYCOM_MOS_STRUCTURAL_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  try
    Result:=TFRE_DB_SVG_DESC.create.Describe(GFRE_BT.StringFromFile('structure.svg'),'monitoring_structure');
  except
    on E:Exception do begin
      Result:=TFRE_DB_HTML_DESC.create.Describe('Error on reading the monitoring structure file. Please place a valid structure.svg file into the binary directoy.');
    end;
  end;
end;

{ TFOS_CITYCOM_MOS_HIERARCHICAL_MOD }

function TFOS_CITYCOM_MOS_HIERARCHICAL_MOD._getMOSObjContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_CONTENT_DESC;
  mosObj: IFRE_DB_Object;
begin
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsStringArr[0]),mosObj));
    writeln('SWL: MOSOBJ',mosobj.DumpToString());
    if mosObj.MethodExists('MOSContent') then begin
      res:=mosObj.Invoke('MOSContent',input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC;
    end else begin
      res:=TFRE_DB_HTML_DESC.create.Describe(app.FetchAppTextShort(ses,'info_content_no_details'));
    end;
  end else begin
    res:=TFRE_DB_HTML_DESC.create.Describe(app.FetchAppTextShort(ses,'info_content_select_one'));
  end;
  res.contentId:='MOS_OBJ_CONTENT';
  Result:=res;
end;

class procedure TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('hierarchical_description')
end;

class procedure TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;

end;

procedure TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app       : TFRE_DB_APPLICATION;
  conn      : IFRE_DB_CONNECTION;
  transform : IFRE_DB_SIMPLE_TRANSFORM;
  dc: IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('caption_mos','',app.FetchAppTextShort(session,'grid_name'));
      AddOneToOnescheme('status_icon_mos','',app.FetchAppTextShort(session,'grid_status'),dt_icon);
    end;
    dc := session.NewDerivedCollection('MONITORING_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_MOS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',nil,'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_GridSC));
      SetParentToChildLinkField ('<MOSPARENTIDS');
    end;
  end;
end;

function TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc     : IFRE_DB_DERIVED_COLLECTION;
  grid   : TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc:=ses.FetchDerivedCollection('MONITORING_GRID');
  grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  Result:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,grid,_getMOSObjContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,true,-1,1,1);
end;

function TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.WEB_GridMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  mosObj: IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_String2Guid(input.Field('selected').AsStringArr[0]),mosObj));
    if mosObj.MethodExists('MOSMenu') then begin
      Result:=mosObj.Invoke('MOSMenu',input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC;
    end else begin
      Result:=GFRE_DB_NIL_DESC;
    end;
  end;
end;

function TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.WEB_GridSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  Result:=_getMOSObjContent(input,ses,app,conn);
end;

{ TFOS_CITYCOM_MONITORING_APP }

procedure TFOS_CITYCOM_MONITORING_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('description');
  AddApplicationModule(TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.create);
  AddApplicationModule(TFOS_CITYCOM_MOS_STRUCTURAL_MOD.create);
end;

procedure TFOS_CITYCOM_MONITORING_APP._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'MOS',FetchAppTextShort(session,'sitemap_main'),'images_apps/citycom_monitoring/main_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_CITYCOM_MONITORING_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'MOS/Hierarchical',FetchAppTextShort(session,'sitemap_hierarchical'),'images_apps/citycom_monitoring/hierarchical_white.svg',TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_CITYCOM_MOS_HIERARCHICAL_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'MOS/Structural',FetchAppTextShort(session,'sitemap_structural'),'images_apps/citycom_monitoring/structural_white.svg',TFOS_CITYCOM_MOS_STRUCTURAL_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFOS_CITYCOM_MOS_STRUCTURAL_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFOS_CITYCOM_MONITORING_APP.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFOS_CITYCOM_MONITORING_APP.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFOS_CITYCOM_MONITORING_APP.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFOS_CITYCOM_MONITORING_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
  newVersionId:='1.0';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';
    CreateAppText(conn,'caption','Monitoring','Monitoring','Monitoring');
    CreateAppText(conn,'sitemap_main','Main','','Main');
    CreateAppText(conn,'sitemap_hierarchical','Hierarchical','','Hierarchical');
    CreateAppText(conn,'sitemap_structural','Structural','','Structural');

    //TFOS_CITYCOM_MOS_HIERARCHICAL_MOD;
    CreateAppText(conn,'hierarchical_description','Hierarchical','Hierarchical','Hierarchical');
    CreateAppText(conn,'info_content_select_one','Please select one object to get detailed information about it.');
    CreateAppText(conn,'info_content_no_details','There are no details available for the selected object.');

    CreateAppText(conn,'grid_name','Name');
    CreateAppText(conn,'grid_status','Status');

    //TFOS_CITYCOM_MOS_STRUCTURAL_MOD;
    CreateAppText(conn,'structural_description','Structural','Structural','Structural');

  end;
  if (currentVersionId='1.0') then begin
    //next update code
   end;

end;

class procedure TFOS_CITYCOM_MONITORING_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then
    begin
      //ADMINS
      CheckDbResult(conn.AddGroup('MOSADMINS','Admins of Citycom Monitoring','Monitoring Admins',domainUID),'could not create admins group');

      CheckDbResult(conn.AddRolesToGroup('MOSADMINS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_CITYCOM_MONITORING_APP.GetClassRoleNameFetch,
        TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.GetClassRoleNameFetch,
        TFOS_CITYCOM_MOS_STRUCTURAL_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Admins');

      CheckDbResult(conn.AddRolesToGroup('MOSADMINS',domainUID, TFRE_DB_VIRTUALMOSOBJECT.GetClassStdRoles),'could not add roles TFRE_DB_VIRTUALSERVICE for group Admins');
      CheckDbResult(conn.AddRolesToGroup('MOSADMINS',domainUID, TFRE_DB_ZFS_POOL.GetClassStdRoles(false,false,false,true)),'could not add roles TFRE_DB_ZFS_POOL for group Admins');
      CheckDbResult(conn.AddRolesToGroup('MOSADMINS',domainUID, TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles(false,false,false,true)),'could not add roles TFRE_DB_ZFS_POOL for group Admins');

      //MANAGERS
      CheckDbResult(conn.AddGroup('MOSMANAGERS','Managers of Citycom Monitoring','Monitoring Managers',domainUID),'could not create managers group');

      CheckDbResult(conn.AddRolesToGroup('MOSMANAGERS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_CITYCOM_MONITORING_APP.GetClassRoleNameFetch,
        TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.GetClassRoleNameFetch,
        TFOS_CITYCOM_MOS_STRUCTURAL_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Managers');

      CheckDbResult(conn.AddRolesToGroup('MOSMANAGERS',domainUID, TFRE_DB_VIRTUALMOSOBJECT.GetClassStdRoles(true,true,false,true)),'could not add roles TFRE_DB_VIRTUALSERVICE for group Managers');

      //VIEWERS
      CheckDbResult(conn.AddGroup('MOSVIEWERS','Viewers of Citycom Monitoring','Monitoring Viewers',domainUID),'could not create viewers group');

      CheckDbResult(conn.AddRolesToGroup('MOSVIEWERS',domainUID,TFRE_DB_StringArray.Create(
        TFOS_CITYCOM_MONITORING_APP.GetClassRoleNameFetch,
        TFOS_CITYCOM_MOS_HIERARCHICAL_MOD.GetClassRoleNameFetch,
        TFOS_CITYCOM_MOS_STRUCTURAL_MOD.GetClassRoleNameFetch
      )),'could not add roles for group Viewers');

      CheckDbResult(conn.AddRolesToGroup('MOSVIEWERS',domainUID, TFRE_DB_VIRTUALMOSOBJECT.GetClassStdRoles(false,false,false,true)),'could not add roles TFRE_DB_VIRTUALSERVICE for group Viewers');
    end;
end;

class procedure TFOS_CITYCOM_MONITORING_APP.InstallDBObjects4SysDomain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then
    begin
      //FEEDER
      CheckDbResult(conn.AddGroup('MONITORFEEDER','Group for Storage Data Feeder','Storage Feeder',domainUID),'could not create Storage feeder group');

      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID,TFRE_DB_StringArray.Create(
        TFOS_CITYCOM_MONITORING_APP.GetClassRoleNameFetch
        )),'could not add roles for group MONITORFEEDER');

      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_VIRTUALMOSOBJECT.GetClassStdRoles),'could not add roles TFRE_DB_VIRTUALMOSOBJECT for group MONITOREFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_MOS_SNMP.GetClassStdRoles),'could not add roles TFRE_DB_MOS_SNMP for group MONITOREFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_MACHINE.GetClassStdRoles),'could not add roles TFRE_DB_MACHINE for group MONITOREFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_POOL.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_POOL for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_BLOCKDEVICE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_BLOCKDEVICE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_VDEVCONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_VDEVCONTAINER for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_DISKREPLACECONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DISKREPLACECONTAINER for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_DISKSPARECONTAINER.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DISKSPARECONTAINER for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_VDEV.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_VDEVfor group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_DATASTORAGE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_LOG.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_LOG for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_CACHE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_CACHE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_SPARE.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_SPARE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ZFS_UNASSIGNED.GetClassStdRoles),'could not add roles TFRE_DB_ZFS_SPARE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_PHYS_DISK.GetClassStdRoles),'could not add roles TFRE_DB_PHYS_DISK for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_UNDEFINED_BLOCKDEVICE.GetClassStdRoles),'could not add roles TFRE_DB_UNDEFINED_BLOCKDEVICE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_SAS_DISK.GetClassStdRoles),'could not add roles TFRE_DB_SAS_DISK for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_SATA_DISK.GetClassStdRoles),'could not add roles TFRE_DB_SATA_DISK for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_ENCLOSURE.GetClassStdRoles),'could not add roles TFRE_DB_ENCLOSURE for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_SAS_EXPANDER.GetClassStdRoles),'could not add roles TFRE_DB_SAS_EXPANDER for group MONITORFEEDER');
      CheckDbResult(conn.AddRolesToGroup('MONITORFEEDER',domainUID, TFRE_DB_DRIVESLOT.GetClassStdRoles),'could not add roles TFRE_DB_DRIVESLOT for group MONITORFEEDER');

    end;
end;

class procedure TFOS_CITYCOM_MONITORING_APP.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateMonitoringCollections(conn);
  CreateDiskDataCollections(conn);
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;
end;

function TFOS_CITYCOM_MONITORING_APP.WEB_DISK_DATA_FEED(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  result := Common_Disk_DataFeed(input,ses,app,conn);
end;

function TFOS_CITYCOM_MONITORING_APP.WEB_MOS_DATA_FEED(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i             : NativeInt;
  moscollection : IFRE_DB_COLLECTION;
  mos_parent_id : TGuid;

  procedure _processUpdates(const updatestep:TFRE_DB_UPDATE_TRANSPORT);
  var update_type : TFRE_DB_ObjCompareEventType;
     obj_id       : TGuid;
     target_obj   : IFRE_DB_Object;
     res          : TFRE_DB_Errortype;


      procedure _setStatus(const db_mos:TFRE_DB_VIRTUALMOSOBJECT);
      begin
        if db_mos.Field('res_boolean').AsBoolean then
          db_mos.SetMOSStatus(fdbstat_ok,nil,nil,nil,conn)
        else
          db_mos.SetMOSStatus(fdbstat_error,nil,nil,nil,conn);
      end;

      procedure _updateAddVirtualMos(const mosobj:TFRE_DB_VIRTUALMOSOBJECT);
      var key_mos      : TFRE_DB_NameType;
          db_mos       : TFRE_DB_VIRTUALMOSOBJECT;
          dbo          : IFRE_DB_Object;



         procedure __insertmos;
         begin
           dbo := mosobj.CloneToNewObject();
           db_mos  := dbo.Implementor_HC as TFRE_DB_VIRTUALMOSOBJECT;
           db_mos.Field('mosparentIds').AsObjectLink := mos_parent_id;
//           db_machine.Field('caption_mos').AsString:=machinename;
           CheckDbResult(moscollection.Store(db_mos),'store mos in moscollection');
           conn.Fetch(mosobj.UID,dbo);
           db_mos  := dbo.Implementor_HC as TFRE_DB_VIRTUALMOSOBJECT;
           _setStatus(db_mos);
           GFRE_DBI.LogInfo(dblc_APPLICATION,'Added Mos Object [%s] uid [%s] to db', [key_mos,mosobj.UID_String]);
         end;

         procedure __deletemos;
         begin
           CheckDbResult(conn.Delete(dbo.UID),'could not delete mos uid ['+dbo.UID_String+']');
         end;

         procedure __updatemos;
         begin
           db_mos  := dbo.Implementor_HC as TFRE_DB_VIRTUALMOSOBJECT;
           db_mos.SetAllSimpleObjectFieldsFromObject(mosobj);
           _setStatus(db_mos);
//           CheckDbResult(moscollection.update(db_mos),'update mos in moscollection');
         end;

      begin
        key_mos     := mosobj.GetMOSKey;
        if moscollection.GetIndexedObj(key_mos,dbo) then
          begin
            if dbo.UID<>mosobj.UID then          // delete if UID is not matching
              begin
                __deletemos;
                __insertmos;
              end
            else
              begin
                __updatemos;
              end;
          end
        else
          begin
            __insertmos;
          end;
      end;


  begin
    writeln('SWL: UPDATESTEP ',updatestep.DumpToString);
    update_type   := updatestep.GetType;
    if updatestep.GetIsChild=false then        // root object with machines
      begin
        case update_type of
         cev_FieldDeleted:
           begin
             raise EFRE_DB_Exception.Create(edb_ERROR,'Unsupported field delete for subobjects in root object [%s] ',[updatestep.DumpToString()]);
           end;
         cev_FieldAdded:
           begin
             if updatestep.GetNewField.FieldType<>fdbft_Object then
               begin
                 raise EFRE_DB_Exception.Create(edb_ERROR,'Unsupported field add for simple fields in root object [%s] ',[updatestep.DumpToString()]);
               end
             else
               begin
                 if (updatestep.GetNewField.AsObject.Implementor_HC is TFRE_DB_VIRTUALMOSOBJECT) then
                   begin
                     _updateAddVirtualMos ((updatestep.GetNewField.AsObject.Implementor_HC as TFRE_DB_VIRTUALMOSOBJECT));
                   end
                 else
                   raise EFRE_DB_Exception.Create(edb_ERROR,'Unsupported field add for other subobjects than TFRE_DB_VIRTUALMOSOBJECT [%s] ',[updatestep.DumpToString()]);
               end;
           end;
         cev_FieldChanged:
           begin
             raise EFRE_DB_Exception.Create(edb_ERROR,'Unsupported field change for subobjects in root class [%s] ',[updatestep.DumpToString()]);
           end;
        else
          raise EFRE_DB_Exception.Create(edb_ERROR,'Invalid Update Type [%s] for id [%s]',[Inttostr(Ord(updatestep.GetType)),FREDB_G2H(updatestep.UID)]);
        end;
      end
    else
      begin
        obj_id        := updatestep.UID;
        CheckDbResult(conn.Fetch(obj_id,target_obj),'could not fetch object for update');
        case update_type of
         cev_FieldDeleted:
           begin
             if updatestep.GetOldField.FieldType<>fdbft_Object then
               begin
                 writeln('SWL GENERIC DELETE SIMPLE FIELD:',updatestep.GetUpdateScheme,' ',updatestep.GetOldFieldName);
                 target_obj.DeleteField(updatestep.GetOldFieldName);
                 CheckDBResult(conn.Update(target_obj),'could not update generic object after field delete');
               end
             else
               begin
                 writeln('SWL GENERIC DELETE OBJECT:',updatestep.DumpToString);
               end;
           end;
         cev_FieldAdded:
           begin
             writeln('SWL GENERIC ADD:',updatestep.DumpToString);
             if updatestep.GetNewField.FieldType<>fdbft_Object then
               begin
                 writeln('SWL GENERIC ADD SIMPLE FIELD:',updatestep.GetUpdateScheme,' ',updatestep.GetNewFieldName);
                 target_obj.Field(updatestep.GetNewFieldName).CloneFromField(updatestep.GetNewField);
                 CheckDBResult(conn.Update(target_obj),'could not update generic object after field add');
               end
             else
               begin
                 writeln('SWL GENERIC ADD OBJECT:',updatestep.DumpToString);
               end;
           end;
         cev_FieldChanged:
           begin
             if updatestep.GetNewField.FieldType<>fdbft_Object then
               begin
                 res := conn.Fetch(updatestep.UID,target_obj);
                 if res=edb_NOT_FOUND then
                   begin
                     GFRE_DBI.LogWarning(dblc_APPLICATION,'could not fetch object for field update',[FREDB_G2H(updatestep.UID)]);
                     exit;
                   end;
                 writeln('SWL GENERIC UPDATE:',target_obj.SchemeClass,' ',updatestep.GetNewFieldName);

                 target_obj.Field(updatestep.GetNewFieldName).CloneFromField(updatestep.GetNewField);
                 if (target_obj.Implementor_HC is TFRE_DB_VIRTUALMOSOBJECT) then
                   _setStatus((target_obj.Implementor_HC as TFRE_DB_VIRTUALMOSOBJECT));
                 CheckDBResult(conn.Update(target_obj),'could not update generic object');
               end;
           end
        else
          raise EFRE_DB_Exception.Create(edb_ERROR,'Invalid Update Type [%s] for id [%s]',[Inttostr(Ord(updatestep.GetType)),FREDB_G2H(obj_id)]);
        end;
      end;
    end;

begin
  moscollection:= conn.GetCollection(CFRE_DB_MOS_COLLECTION);
  if moscollection.GetIndexedUID('RZNORD',mos_parent_id)=false then
    raise EFRE_DB_Exception.Create(edb_ERROR,'Could not find RZNORD mos object');
  if input.FieldExists('UPDATE') then
    begin
      for i := 0 to input.Field('UPDATE').ValueCount-1 do
        begin
          _processUpdates((input.Field('UPDATE').AsObjectItem[i].Implementor_HC as TFRE_DB_UPDATE_TRANSPORT));
        end;
    end;
  result := GFRE_DB_NIL_DESC;
end;

end.

