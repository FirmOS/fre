unit fos_firmbox_vmapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fos_firmbox_vm_machines_mod,
  fre_hal_schemes;

type

  { TFRE_FIRMBOX_VM_APP }

  TFRE_FIRMBOX_VM_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure   ; override;
    procedure       _UpdateSitemap              (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain   (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
    class procedure InstallDBObjects4SysDomain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
  published
    function  WEB_VM_Feed_Update              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;



procedure Register_DB_Extensions;

implementation



{ TFRE_FIRMBOX_VM_APP }

procedure TFRE_FIRMBOX_VM_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('$description');
  AddApplicationModule(TFRE_FIRMBOX_VM_NETWORK_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_MACHINES_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_RESOURCES_MOD.create);
end;

procedure TFRE_FIRMBOX_VM_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization',FetchAppTextShort(session,'$caption'),'images_apps/firmbox_vm/monitor_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_APP));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VSwitch',FetchAppTextShort(session,'$vnetwork_description'),'images_apps/firmbox_vm/network_white.svg',TFRE_FIRMBOX_VM_NETWORK_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_NETWORK_MOD));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VSwitch/Interfaces','Interfaces','images_apps/firmbox_vm/plug_white.svg','',0,CheckAppRightModule(conn,'interfaces'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/Machines',FetchAppTextShort(session,'$machines_description'),'images_apps/firmbox_vm/server_white.svg',TFRE_FIRMBOX_VM_MACHINES_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_MACHINES_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VMResources',FetchAppTextShort(session,'$vm_resources_description'),'images_apps/firmbox_vm/server_white.svg',TFRE_FIRMBOX_VM_RESOURCES_MOD.Classname,0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_RESOURCES_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VMResources/Disks',FetchAppTextShort(session,'$vm_disk_resources_description'),'images_apps/firmbox_vm/server_white.svg',TFRE_FIRMBOX_VM_RESOURCES_MOD.Classname+':DISKS',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_RESOURCES_MOD));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VMResources/ISOs',FetchAppTextShort(session,'$vm_iso_resources_description'),'images_apps/firmbox_vm/server_white.svg',TFRE_FIRMBOX_VM_RESOURCES_MOD.Classname+':ISOS',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_FIRMBOX_VM_RESOURCES_MOD));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(ClassName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_FIRMBOX_VM_APP.MySessionInitialize(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_VM_APP.MySessionPromotion(  const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;


class procedure TFRE_FIRMBOX_VM_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

class procedure TFRE_FIRMBOX_VM_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited;

  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      CreateAppText(conn,'$caption','Virtualization','Virtualization','Virtualization');
      CreateAppText(conn,'$vnetwork_description','Virtual Network','Virtual Network','Virtual Network');
      CreateAppText(conn,'$machines_description','Machines','Machines','Machines');
      CreateAppText(conn,'$vm_resources_description','VM Resources','VM Resources','VM Resources');
      CreateAppText(conn,'$vm_disk_resources_description','Disks','Disks','Disks');
      CreateAppText(conn,'$vm_iso_resources_description','ISOs','ISOs','ISOs');

      CreateAppText(conn,'$datalink_content_header','Details about the selected Network Interface');
      CreateAppText(conn,'$datalink_name','Name');
      CreateAppText(conn,'$datalink_zoned','Zoned');
      CreateAppText(conn,'$datalink_desc','Description');
      CreateAppText(conn,'$datalink_add_vnic','Add new Virtual Interface');
      CreateAppText(conn,'$datalink_delete_vnic','Delete Virtual Interface');
      CreateAppText(conn,'$datalink_delete_stub','Delete Virtual Switch');
      CreateAppText(conn,'$datalink_delete_aggr','Delete Aggregation');
      CreateAppText(conn,'$datalink_create_stub','Create Virtual Switch');

      CreateAppText(conn,'$vmnetwork_no_access','No Access to settings!');

      CreateAppText(conn,'$machines_content_header','<b>Overview of all configured virtual machines.</b>');
      CreateAppText(conn,'$machines_no_info','- could not get info -');

      CreateAppText(conn,'$machines_new_vm','New','','New VM');
      CreateAppText(conn,'$machines_start','Start','','Start the selected VM');
      CreateAppText(conn,'$machines_stop','Stop','','Stop the selected VM');
      CreateAppText(conn,'$machines_kill','Kill','','Stop the selected VM (FORCED)');

      CreateAppText(conn,'$vm_details_config','Configuration');
      CreateAppText(conn,'$vm_details_console','Console');
      CreateAppText(conn,'$vm_details_perf','Performance');
      CreateAppText(conn,'$vm_details_note','Note');

      CreateAppText(conn,'$gc_vm_name','Name');
      CreateAppText(conn,'$gc_vm_type','Type');
      CreateAppText(conn,'$gc_vm_state','State');
      CreateAppText(conn,'$gc_vm_cpu','CPU');
      CreateAppText(conn,'$gc_vm_used_mem','Used Mem');
      CreateAppText(conn,'$gc_vm_paged_mem','Paged Mem');
      CreateAppText(conn,'$gc_vm_virtual_mem','Virtual Mem');

      CreateAppText(conn,'$vm_resources_disks','Disks');
      CreateAppText(conn,'$vm_resources_isos','ISOs');
      CreateAppText(conn,'$vm_resources_add_disk','Create','','Create a new disk');
      CreateAppText(conn,'$vm_resources_delete_disk','Remove','','Remove selected disk');
      CreateAppText(conn,'$vm_resources_add_iso','Upload','','Upload a new ISO');
      CreateAppText(conn,'$vm_resources_delete_iso','Remove','','Remove selected ISO');

      CreateAppText(conn,'$gc_disk_name','Disk name');
      CreateAppText(conn,'$gc_iso_name','ISO name');

      CreateAppText(conn,'$button_save','Save');
      CreateAppText(conn,'$error_no_access','Access denied');

      currentVersionId:='1.0';
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
end;

class procedure TFRE_FIRMBOX_VM_APP.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);

  if currentVersionId='' then begin
    currentVersionId:='1.0';
    CheckDbResult(conn.AddGroup('VMVIEWER','Group for VM Viewer','VM Viewer',domainUID),'could not create VM viewer group');

    CheckDbResult(conn.AddRolesToGroup('VMVIEWER',domainUID,TFRE_DB_StringArray.Create(
       TFRE_FIRMBOX_VM_APP.GetClassRoleNameFetch,
        TFRE_FIRMBOX_VM_MACHINES_MOD.GetClassRoleNameFetch
      )),'could not add GUI roles for group VMVIEWER');

    CheckDbResult(conn.AddRolesToGroup('VMVIEWER',domainUID, TFRE_DB_VMACHINE.GetClassStdRoles(false,false,false,true)),'could not add roles of TFRE_DB_VMACHINE to group VMVIEWER');
  end;
end;

class procedure TFRE_FIRMBOX_VM_APP.InstallDBObjects4SysDomain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4SysDomain(conn, currentVersionId, domainUID);

  if currentVersionId='' then begin
    currentVersionId:='1.0';
    CheckDbResult(conn.AddGroup('VMFEEDER','Group for VM Data Feeder','VM Feeder',domainUID,true,true),'could not create VM feeder group');

    CheckDbResult(conn.AddRolesToGroup('VMFEEDER',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_VM_APP.GetClassRoleNameFetch
      )),'could not add roles for group VMFEEDER');
  end;
end;

function TFRE_FIRMBOX_VM_APP.WEB_VM_Feed_Update(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
//  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppTextShort(ses,'$error_no_access')); //FIXME: Use the right right for the feeder
  result := DelegateInvoke('VMCONTROLLER','VM_Feed_Update',input);
end;

procedure Register_DB_Extensions;
begin
  fos_firmbox_vm_machines_mod.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

end.


