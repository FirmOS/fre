unit fos_firmbox_vmapp;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_SYSRIGHT_CONSTANTS,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fos_firmbox_vm_machines_mod;

type

  { TFRE_FIRMBOX_VM_APP }

  TFRE_FIRMBOX_VM_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure   ; override;
    function        InstallAppDefaults          (const conn : IFRE_DB_SYS_CONNECTION):TFRE_DB_Errortype; override;
    function        InstallSystemGroupsAndRoles (const conn : IFRE_DB_SYS_CONNECTION; const domain : TFRE_DB_NameType):TFRE_DB_Errortype; override;
    procedure       _UpdateSitemap              (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
    function        CFG_ApplicationUsesRights : boolean; override;
    function        _ActualVersion            : TFRE_DB_String; override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
  published
    function  WEB_VM_Feed_Update              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;



procedure Register_DB_Extensions;

implementation



{ TFRE_FIRMBOX_VM_APP }

procedure TFRE_FIRMBOX_VM_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitAppDesc('firmbox_vm','$description');
  AddApplicationModule(TFRE_FIRMBOX_VM_NETWORK_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_MACHINES_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_RESOURCES_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_STATUS_MOD.create);
end;

function TFRE_FIRMBOX_VM_APP.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
var  old_version  : TFRE_DB_String;

  procedure _InstallAllDomains(const obj:IFRE_DB_Object);
  begin
    InstallSystemGroupsandRoles(conn,obj.Field('objname').asstring);
  end;

begin
  case _CheckVersion(conn,old_version) of
    NotInstalled : begin
                      _SetAppdataVersion(conn,_ActualVersion);
                      conn.ForAllDomains(@_InstallAllDomains);

                      CreateAppText(conn,'$description','Virtualization','Virtualization','Virtualization');
                      CreateAppText(conn,'$status_description','Status','Status','Status');
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
                      CreateAppText(conn,'$machines_update','Update','','Update list');

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

                      CreateAppText(conn,'$vm_new_caption','New Virtual Machine');
                      CreateAppText(conn,'$vm_new_save','Create');

                      CreateAppText(conn,'$vm_name','Name');
                      CreateAppText(conn,'$vm_mem','RAM (kB)');
                      CreateAppText(conn,'$vm_cpu','CPUs');
                      CreateAppText(conn,'$vm_sc','Sound card');

                      CreateAppText(conn,'$vm_ide0','IDE Drive 0');
                      CreateAppText(conn,'$vm_ide1','IDE Drive 1');
                      CreateAppText(conn,'$vm_ide2','IDE Drive 2');
                      CreateAppText(conn,'$vm_ide3','IDE Drive 3');

                      CreateAppText(conn,'$vm_disk_chooser','Disk');
                      CreateAppText(conn,'$vm_iso_chooser','ISO (CD/DVD)');

                      CreateAppText(conn,'$vm_ide_option_disk','Hard Disk');
                      CreateAppText(conn,'$vm_ide_option_iso','Mount ISO CD/DVD');

                      CreateAppText(conn,'$vm_upload_iso','Upload ISO file');
                      CreateAppText(conn,'$vm_create_new_disk','Create new disk');

                      CreateAppText(conn,'$vm_new_disk_name','Disk name');
                      CreateAppText(conn,'$vm_new_disk_size','Disk size');

                      CreateAppText(conn,'$vm_advanced','Advanced settings');
                      CreateAppText(conn,'$vm_keyboard_layout_auto','Automatic');
                      CreateAppText(conn,'$vm_keyboard_layout','Keyboard layout');

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

function TFRE_FIRMBOX_VM_APP.InstallSystemGroupsAndRoles(const conn: IFRE_DB_SYS_CONNECTION; const domain: TFRE_DB_NameType): TFRE_DB_Errortype;
var
  role: IFRE_DB_ROLE;
begin

  role := _CreateAppRole('view_vms','View VMs','Allowed to view VMs');
  _AddAppRight(role,'view_vms','View VMs','Allowed to view VMs.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['vmcontroller']));
  CheckDbResult(conn.StoreRole(role,ObjectName,domain),'InstallSystemGroupsAndRoles');

  role := _CreateAppRole('admin_vms','Admin VMs','Allowed to administer VMs');
  _AddAppRight(role,'view_vms','View VMs','Allowed to view VMs.');
  _AddAppRight(role,'admin_vms','Admin VMs','Allowed to administer VMs.');
  _AddAppRightModules(role,GFRE_DBI.ConstructStringArray(['vmcontroller','vmresources','vmnetwork','interfaces','vmstatus']));//FIXXME - add more roles
  CheckDbResult(conn.StoreRole(role,ObjectName,domain),'InstallSystemGroupsAndRoles');

  _AddSystemGroups(conn,domain);

  CheckDbResult(conn.ModifyGroupRoles(Get_Groupname_App_Group_Subgroup(ObjectName,'USER'+'@'+domain),GFRE_DBI.ConstructStringArray([Get_Rightname_App_Role_SubRole(ObjectName,'view_vms'+'@'+domain)])),'InstallSystemGroupsAndRoles');
  CheckDbResult(conn.ModifyGroupRoles(Get_Groupname_App_Group_Subgroup(ObjectName,'ADMIN'+'@'+domain),GFRE_DBI.ConstructStringArray([Get_Rightname_App_Role_SubRole(ObjectName,'view_vms'+'@'+domain),Get_Rightname_App_Role_SubRole(ObjectName,'admin_vms'+'@'+domain)])),'InstallSystemGroupsAndRoles');

end;

procedure TFRE_FIRMBOX_VM_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization',FetchAppText(conn,'$description').Getshort,'images_apps/firmbox_vm/monitor_white.svg','',0,CheckAppRightModule(conn,'vmcontroller') or CheckAppRightModule(conn,'vmnetwork') or CheckAppRightModule(conn,'vmstatus'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/Machines',FetchAppText(conn,'$machines_description').Getshort,'images_apps/firmbox_vm/server_white.svg','VMCONTROLLER',0,CheckAppRightModule(conn,'vmcontroller'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VMResources',FetchAppText(conn,'$vm_resources_description').Getshort,'images_apps/firmbox_vm/server_white.svg','VMRESOURCES',0,CheckAppRightModule(conn,'vmresources'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VMResources/Disks',FetchAppText(conn,'$vm_disk_resources_description').Getshort,'images_apps/firmbox_vm/server_white.svg','VMRESOURCES:DISKS',0,CheckAppRightModule(conn,'vmresources'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VMResources/ISOs',FetchAppText(conn,'$vm_iso_resources_description').Getshort,'images_apps/firmbox_vm/server_white.svg','VMRESOURCES:ISOS',0,CheckAppRightModule(conn,'vmresources'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VSwitch',FetchAppText(conn,'$vnetwork_description').Getshort,'images_apps/firmbox_vm/network_white.svg','VMNETWORK',0,CheckAppRightModule(conn,'vmnetwork'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VSwitch/Interfaces','Interfaces','images_apps/firmbox_vm/plug_white.svg','',0,CheckAppRightModule(conn,'interfaces'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/Status',FetchAppText(conn,'$status_description').Getshort,'images_apps/firmbox_vm/monitor_white.svg','VMSTATUS',0,CheckAppRightModule(conn,'vmstatus'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;
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
  _UpdateSitemap(session);
end;

function TFRE_FIRMBOX_VM_APP.CFG_ApplicationUsesRights: boolean;
begin
  result := true;
end;

function TFRE_FIRMBOX_VM_APP._ActualVersion: TFRE_DB_String;
begin
  Result:='1.0';
end;

class procedure TFRE_FIRMBOX_VM_APP.RegisterSystemScheme( const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

function TFRE_FIRMBOX_VM_APP.WEB_VM_Feed_Update(const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
begin
//  if not conn.CheckRight(Get_Rightname('view_vms')) then raise EFRE_DB_Exception.Create(app.FetchAppText(ses,'$error_no_access').Getshort); //FIXME: Use the right right for the feeder
  result := DelegateInvoke('VMCONTROLLER','VM_Feed_Update',input);
end;

procedure Register_DB_Extensions;
begin
  fos_firmbox_vm_machines_mod.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

end.


