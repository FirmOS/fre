unit fos_firmbox_adminapp;

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
  FRE_DBBASE,
  fre_system,fre_dbbusiness,
  fos_firmbox_vm_machines_mod,fre_hal_schemes,fre_zfs,
  fos_firmbox_dns_mod,fos_firmbox_fileserver_mod,fos_firmbox_net_routing_mod,fos_firmbox_dhcp_mod,fos_firmbox_groupware_mod,fos_firmbox_webserver_mod,fos_firmbox_pool_mod,
  fos_mos_monitoring_mod,fos_infrastructure_mod,fos_firmbox_firewall_mod,
  fos_firmbox_subnet_ip_mod,
  fre_accesscontrol_common,fre_monitoring_common;
  //fos_citycom_voip_mod,
  //fos_firmbox_applianceapp,fos_firmbox_storageapp,fos_firmbox_servicesapp,fos_firmbox_vmapp,
  //fre_hal_disk_enclosure_pool_mangement,fos_vm_control_interface,fre_scsi,fre_diff_transport

type

  { TFRE_FIRMBOX_ADMIN_AC_MOD }

  TFRE_FIRMBOX_ADMIN_AC_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure      ; override;
  public
    class procedure InstallDBObjects             (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain  (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  end;

  { TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD }

  TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure      ; override;
  public
    class procedure InstallDBObjects             (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain  (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  end;

  { TFRE_FIRMBOX_ADMIN_MON_MOD }

  TFRE_FIRMBOX_ADMIN_MON_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure      ; override;
  public
    class procedure InstallDBObjects             (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain  (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  end;

  { TFRE_FIRMBOX_ADMIN_VM_MOD }

  TFRE_FIRMBOX_ADMIN_VM_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure      ; override;
  public
    class procedure InstallDBObjects             (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain  (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  end;

  { TFRE_FIRMBOX_ADMIN_SERVICES_MOD }

  TFRE_FIRMBOX_ADMIN_SERVICES_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    fDNSMod         : TFOS_FIRMBOX_DNS_MOD;
    function        isDNSEnabled                 (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    procedure       SetupAppModuleStructure      ; override;
  public
    class procedure InstallDBObjects             (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain  (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  end;

  { TFRE_FIRMBOX_ADMIN_NETWORK_MOD }

  TFRE_FIRMBOX_ADMIN_NETWORK_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure      ; override;
  public
    class procedure InstallDBObjects             (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain  (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  end;

  { TFRE_FIRMBOX_ADMIN_APP }

  TFRE_FIRMBOX_ADMIN_APP=class(TFRE_DB_APPLICATION)
  private
    procedure       _UpdateSitemap                (const session: TFRE_DB_UserSession);
  protected
    fservicesMod    : TFRE_FIRMBOX_ADMIN_SERVICES_MOD;
    procedure       SetupApplicationStructure     ; override;
    procedure       MySessionInitialize           (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion            (const session: TFRE_DB_UserSession); override;
  public
    class procedure RegisterSystemScheme          (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects              (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    function        IsMultiDomainApp              : Boolean; override;
  published
    function        WEB_DATA_FEED                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

{ TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD }

class procedure TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    CreateModuleText(conn,StdSitemapModuleTitleKey,'Infrastructure','Infrastructure','Infrastructure');
  end;
end;

class procedure TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
var
  group     : IFRE_DB_GROUP;
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CheckDbResult(conn.SYS.AddGroup('INFRASTRUCTURE_ADMINS','Infrastructure Admins','Infrastructure Admins',domainUID,true),'could not create Infrastructure admins group');

    CheckDbResult(conn.SYS.AddRole('INFRASTRUCTURE_ADMIN','Allowed to admin the Infrastructure module','',domainUID),'could not add role INFRASTRUCTURE_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD.GetClassRoleNameFetch,
      TFOS_INFRASTRUCTURE_MOD.GetClassRoleNameFetch,
      TFOS_FIRMBOX_POOL_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_VM_MACHINES_MOD.GetClassRoleNameFetch
    )));

    //INFRASTRUCTURE
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_DATACENTER.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_MACHINE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_ZONE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_ZFS_POOL.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_ZFS_DATASET_FILE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_ZFS_DATASET_PARENT.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_ZFS_DATASTORAGE.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_FBZ_TEMPLATE.GetClassStdRoles(false,false,false,true)));
    //SERVICES - GLOBAL
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_GLOBAL_FILESERVER.GetClassStdRoles));

    //SERVICES - ZONE
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_VROOTSERVER.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_SSH_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_LDAP_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_VIRTUAL_FILESERVER.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_DNS.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_DHCP.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_VPN.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_IMAP_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_MTA_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_POSTGRES_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_MYSQL_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_HTTP_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_PHPFPM_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_FIREWALL_SERVICE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_IPV4.GetClassStdRoles()));

    //SERVICES - VM
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_VMACHINE.GetClassStdRoles()));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_VMACHINE_NIC.GetClassStdRoles()));
    //CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_IPV4_HOSTNET.GetClassStdRoles()));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_DATALINK_VNIC.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_VMACHINE_DISK.GetClassStdRoles()));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_IMAGE_FILE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('INFRASTRUCTURE_ADMIN',domainUID,TFRE_DB_ZFS_DATASET_ZVOL.GetClassStdRoles(false,false,false,true)));

    CheckDbResult(conn.SYS.AddRolesToGroup('INFRASTRUCTURE_ADMINS',domainUID,TFRE_DB_StringArray.Create('INFRASTRUCTURE_ADMIN')),'could not add roles for group Infrastructure Admins');

    if conn.GetDefaultDomainUID<>domainUID then begin
      CheckDbResult(conn.SYS.FetchGroup('INFRASTRUCTURE_ADMINS',domainUID,group));
      group.isDisabled:=true;
      CheckDbResult(conn.SYS.UpdateGroup(group));
    end;
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD.SetupAppModuleStructure;
begin
  AddApplicationModule(TFOS_INFRASTRUCTURE_MOD.create);
end;

{ TFRE_FIRMBOX_ADMIN_MON_MOD }

class procedure TFRE_FIRMBOX_ADMIN_MON_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    CreateModuleText(conn,StdSitemapModuleTitleKey,'Monitoring','Monitoring','Monitoring');
  end;
end;

class procedure TFRE_FIRMBOX_ADMIN_MON_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CheckDbResult(conn.SYS.AddGroup('PHYS_MON_ADMINS','Physical Monitoring Admins','Physical Monitoring Admins',domainUID,true),'could not create Physical Monitoring admins group');

    CheckDbResult(conn.SYS.AddRole('PHYS_MON_ADMIN','Allowed to admin the Physical Monitoring module','',domainUID),'could not add role PHYS_MON_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('PHYS_MON_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_MON_MOD.GetClassRoleNameFetch,
      TFOS_CITYCOM_MOS_PHYSICAL_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRolesToGroup('PHYS_MON_ADMINS',domainUID,TFRE_DB_StringArray.Create('PHYS_MON_ADMIN')),'could not add roles for group Physical Monitoring Admins');

    CheckDbResult(conn.SYS.AddGroup('LOGICAL_MON_ADMINS','Logical Monitoring Admins','Logical Monitoring Admins',domainUID,true),'could not create Logical Monitoring admins group');

    CheckDbResult(conn.SYS.AddRole('LOGICAL_MON_ADMIN','Allowed to admin the Logical Monitoring module','',domainUID),'could not add role LOGICAL_MON_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('LOGICAL_MON_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_MON_MOD.GetClassRoleNameFetch,
      TFOS_CITYCOM_MOS_LOGICAL_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRolesToGroup('LOGICAL_MON_ADMINS',domainUID,TFRE_DB_StringArray.Create('LOGICAL_MON_ADMIN')),'could not add roles for group Logical Monitoring Admins');

    CheckDbResult(conn.SYS.AddGroup('JOB_MON_ADMINS','Jobs Monitoring Admins','Jobs Monitoring Admins',domainUID,true),'could not create Jobs Monitoring admins group');

    CheckDbResult(conn.SYS.AddRole('JOB_MON_ADMIN','Allowed to admin the Jobs Monitoring module','',domainUID),'could not add role JOB_MON_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('JOB_MON_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_MON_MOD.GetClassRoleNameFetch,
      TFRE_COMMON_JOBS_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRolesToGroup('JOB_MON_ADMINS',domainUID,TFRE_DB_StringArray.Create('JOB_MON_ADMIN')),'could not add roles for group Job Monitoring Admins');
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_MON_MOD.SetupAppModuleStructure;
begin
  AddApplicationModule(TFOS_CITYCOM_MOS_PHYSICAL_MOD.create);
  AddApplicationModule(TFOS_CITYCOM_MOS_LOGICAL_MOD.create);
  AddApplicationModule(TFRE_COMMON_WF_MOD.create);
  AddApplicationModule(TFRE_COMMON_JOBS_MOD.create);
end;

{ TFRE_FIRMBOX_ADMIN_SERVICES_MOD }

function TFRE_FIRMBOX_ADMIN_SERVICES_MOD.isDNSEnabled(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=fDNSMod.isEnabled(ses,conn);
end;

class procedure TFRE_FIRMBOX_ADMIN_SERVICES_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
var textobj: IFRE_DB_TEXT;
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    CreateModuleText(conn,StdSitemapModuleTitleKey,'Services','Services','Services');
  end;
end;

class procedure TFRE_FIRMBOX_ADMIN_SERVICES_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
var
  group     : IFRE_DB_GROUP;
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CheckDbResult(conn.SYS.AddGroup('SERVICE_PROVIDER_ADMINS','Services Admins','Services Admins',domainUID,true),'could not create Services admins group');

    CheckDbResult(conn.SYS.AddRole('SERVICE_PROVIDER_ADMIN','Allowed to administrate the Services','',domainUID),'could not add role SERVICE_PROVIDER_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_SERVICES_MOD.GetClassRoleNameFetch,
      TFOS_FIRMBOX_DNS_MOD.GetClassRoleNameFetch,
      TFOS_FIRMBOX_WEBSERVER_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.GetClassRoleNameFetch,
      TFOS_FIRMBOX_GROUPWARE_MOD.GetClassRoleNameFetch
    )));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFOS_DB_NETWORK_DOMAIN.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFOS_DB_DNS_RESOURCE_RECORD.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFOS_DB_DNS_NAMESERVER_RECORD.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFRE_DB_APPLICATION_CONFIG.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFOS_DB_PROVIDER_NETWORK_DOMAIN.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFRE_DB_VIRTUAL_FILESHARE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('SERVICE_PROVIDER_ADMIN',domainUID,TFRE_DB_VIRTUAL_FILESERVER.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRolesToGroup('SERVICE_PROVIDER_ADMINS',domainUID,TFRE_DB_StringArray.Create('SERVICE_PROVIDER_ADMIN')),'could not add roles for group Services Admins');

    //CUSTOMER and IT CONSULTANT
    CheckDbResult(conn.SYS.AddGroup('DNS_ADMINS','DNS Admins','DNS Admins',domainUID,true),'could not create DNS admins group');

    CheckDbResult(conn.SYS.AddRole('DNS_ADMIN','Allowed to administrate the DNS entries','',domainUID),'could not add role DNS_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_SERVICES_MOD.GetClassRoleNameFetch,
      TFOS_FIRMBOX_DNS_MOD.GetClassRoleNameFetch
    )));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFOS_DB_NETWORK_DOMAIN.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFOS_DB_PROVIDER_NETWORK_DOMAIN.GetClassStdRoles(false,true,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFOS_DB_DNS_RESOURCE_RECORD.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFOS_DB_DNS_NAMESERVER_RECORD.GetClassStdRoles(false,true,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('DNS_ADMIN',domainUID,TFRE_DB_APPLICATION_CONFIG.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRolesToGroup('DNS_ADMINS',domainUID,TFRE_DB_StringArray.Create('DNS_ADMIN')),'could not add roles for group DNS managers');

    if conn.GetDefaultDomainUID<>domainUID then begin
      CheckDbResult(conn.SYS.FetchGroup('SERVICE_PROVIDER_ADMINS',domainUID,group));
      group.isDisabled:=true;
      CheckDbResult(conn.SYS.UpdateGroup(group));
    end;
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_SERVICES_MOD.SetupAppModuleStructure;
begin
  AddApplicationModule(TFOS_FIRMBOX_WEBSERVER_MOD.create);
  AddApplicationModule(TFOS_FIRMBOX_GROUPWARE_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.create);
  fDNSMod:=TFOS_FIRMBOX_DNS_MOD.create;
  AddApplicationModule(fDNSMod);
end;

{ TFRE_FIRMBOX_ADMIN_NETWORK_MOD }

class procedure TFRE_FIRMBOX_ADMIN_NETWORK_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    CreateModuleText(conn,StdSitemapModuleTitleKey,'Network','Network','Network');
  end;
end;

class procedure TFRE_FIRMBOX_ADMIN_NETWORK_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CheckDbResult(conn.SYS.AddGroup('NETWORK_ROUTING_ADMINS','Network Admins','Network Admins',domainUID,true),'could not create Network admins group');

    CheckDbResult(conn.SYS.AddRole('NETWORK_ROUTING_ADMIN','Allowed to administrate the Network','',domainUID),'could not add role NETWORK_ROUTING_ADMIN');

    //Network/Routing Admins - all zones (incl. global zone)
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_NETWORK_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_NET_ROUTING_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_FIREWALL_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_PHYS.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_AGGR.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_IPMP.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_IPTUN.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_STUB.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_BRIDGE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_SIMNET.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATALINK_VNIC.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_IPV4_ROUTE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_IPV6_ROUTE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_DATACENTER.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_MACHINE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_ZONE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_GLOBAL_ZONE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_FBZ_TEMPLATE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_IPV4.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_IPV6.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_IPV4_DHCP.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_ADMIN',domainUID,TFRE_DB_IPV6_SLAAC.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRolesToGroup('NETWORK_ROUTING_ADMINS',domainUID,TFRE_DB_StringArray.Create('NETWORK_ROUTING_ADMIN')),'could not add roles for group Network Admins');

    //Network/Routing Admins
    CheckDbResult(conn.SYS.AddGroup('NETWORK_ROUTING_CLIENT_ADMINS','Client Network Admins','Client Network Admins',domainUID,true),'could not create Client Network admins group');
    CheckDbResult(conn.SYS.AddRole('NETWORK_ROUTING_CLIENT_ADMIN','Allowed to administrate Client Networks','',domainUID),'could not add role NETWORK_ROUTING_CLIENT_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_NETWORK_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_NET_ROUTING_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_PHYS.GetClassStdRoles(false,true,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_AGGR.GetClassStdRoles(false,true,false,true)));
    //CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_IPMP.GetClassStdRoles)); //no rights needed
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_IPTUN.GetClassStdRoles));
    //CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_STUB.GetClassStdRoles)); //no rights needed
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_BRIDGE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_SIMNET.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATALINK_VNIC.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_DATACENTER.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_MACHINE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_ZONE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_GLOBAL_ZONE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_FBZ_TEMPLATE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_IPV4.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_IPV6.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_IPV4_DHCP.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_ROUTING_CLIENT_ADMIN',domainUID,TFRE_DB_IPV6_SLAAC.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRolesToGroup('NETWORK_ROUTING_CLIENT_ADMINS',domainUID,TFRE_DB_StringArray.Create('NETWORK_ROUTING_CLIENT_ADMIN')),'could not add roles for group Network Client Admins');

    //Firewall Admins
    CheckDbResult(conn.SYS.AddGroup('NETWORK_FIREWALL_ADMINS','Firewall Admins','Firewall Admins',domainUID,true),'could not create Firewall admins group');

    CheckDbResult(conn.SYS.AddRole('NETWORK_FIREWALL_ADMIN','Allowed to administrate the Firewall','',domainUID),'could not add role NETWORK_DHCP_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_NETWORK_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_FIREWALL_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_SUBNET_IP_MOD.GetClassRoleNameFetch
    )));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_FIREWALL_SERVICE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_FIREWALL_NAT.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_FIREWALL_RULE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_FIREWALL_POOL.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_FIREWALL_POOLENTRY_GROUP.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_FIREWALL_POOLENTRY_TABLE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_IPV4.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_IPV4_SUBNET.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_IPV6.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_IPV6_SUBNET.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_PHYS.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_AGGR.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_IPMP.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_IPTUN.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_STUB.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_BRIDGE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_SIMNET.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_FIREWALL_ADMIN',domainUID,TFRE_DB_DATALINK_VNIC.GetClassStdRoles(false,false,false,true)));

    CheckDbResult(conn.SYS.AddRolesToGroup('NETWORK_FIREWALL_ADMINS',domainUID,TFRE_DB_StringArray.Create('NETWORK_FIREWALL_ADMIN')),'could not add roles for group Firewall Admins');

    //DHCP Admins
    CheckDbResult(conn.SYS.AddGroup('NETWORK_DHCP_ADMINS','DHCP Admins','DHCP Admins',domainUID,true),'could not create DHCP admins group');

    CheckDbResult(conn.SYS.AddRole('NETWORK_DHCP_ADMIN','Allowed to administrate DHCP','',domainUID),'could not add role NETWORK_DHCP_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_NETWORK_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_DHCP_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DHCP.GetClassStdRoles(false,true,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DHCP_TEMPLATE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DHCP_ENTRY_TEMPLATE_RELATION.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DHCP_SUBNET.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DHCP_FIXED.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_IPV4.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_IPV4_SUBNET.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_IPV6.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_IPV6_SUBNET.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_PHYS.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_AGGR.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_IPMP.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_IPTUN.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_STUB.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_BRIDGE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_SIMNET.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('NETWORK_DHCP_ADMIN',domainUID,TFRE_DB_DATALINK_VNIC.GetClassStdRoles(false,false,false,true)));

    CheckDbResult(conn.SYS.AddRolesToGroup('NETWORK_DHCP_ADMINS',domainUID,TFRE_DB_StringArray.Create('NETWORK_DHCP_ADMIN')),'could not add roles for group DHCP Admins');
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_NETWORK_MOD.SetupAppModuleStructure;
begin
  AddApplicationModule(TFRE_FIRMBOX_NET_ROUTING_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_FIREWALL_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_DHCP_MOD.create);
end;

{ TFRE_FIRMBOX_ADMIN_VM_MOD }

class procedure TFRE_FIRMBOX_ADMIN_VM_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    CreateModuleText(conn,StdSitemapModuleTitleKey,'Virtualisation','Virtualisation','Virtualisation');
  end;
end;

class procedure TFRE_FIRMBOX_ADMIN_VM_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CheckDbResult(conn.SYS.AddGroup('VM_ADMINS','VM Admins','VM Admins',domainUID,true),'could not create VM admins group');

    CheckDbResult(conn.SYS.AddRole('VM_ADMIN','Allowed to create, modify and delete VMs','',domainUID),'could not add role VM_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_VM_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_VM_MACHINES_MOD.GetClassRoleNameFetch,
      TFRE_FIRMBOX_VM_RESOURCES_MOD.GetClassRoleNameFetch
    )));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_VMACHINE.GetClassStdRoles));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_ZONE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_VMACHINE_NIC.GetClassStdRoles()));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_DATALINK_VNIC.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_VMACHINE_DISK.GetClassStdRoles()));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_IMAGE_FILE.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_ZFS_DATASET_ZVOL.GetClassStdRoles(false,false,false,true)));
    CheckDbResult(conn.SYS.AddRoleRightsToRole('VM_ADMIN',domainUID,TFRE_DB_IPV4.GetClassStdRoles));

    CheckDbResult(conn.SYS.AddRolesToGroup('VM_ADMINS',domainUID,TFRE_DB_StringArray.Create('VM_ADMIN')),'could not add roles for group VM Admins');
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_VM_MOD.SetupAppModuleStructure;
begin
  //AddApplicationModule(TFRE_FIRMBOX_VM_NETWORK_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_MACHINES_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_VM_RESOURCES_MOD.create);
end;

{ TFRE_FIRMBOX_ADMIN_AC_MOD }

class procedure TFRE_FIRMBOX_ADMIN_AC_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    CreateModuleText(conn,StdSitemapModuleTitleKey,'Access Control','Access Control','Access Control');
  end;
end;

class procedure TFRE_FIRMBOX_ADMIN_AC_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CheckDbResult(conn.SYS.AddGroup('AC_ADMINS','Access Control Admins','Access Control Admins',domainUID,true),'could not create AC admins group');

    CheckDbResult(conn.SYS.AddRole('AC_USER_ADMIN','Allowed to create, modify and delete Users','',domainUID),'could not add role AC_USER_ADMIN');
    CheckDbResult(conn.SYS.AddRole('AC_GROUP_ADMIN','Allowed to create, modify and delete Groups','',domainUID),'could not add role AC_GROUP_ADMIN');
    CheckDbResult(conn.SYS.AddRole('AC_USERGROUP_ADMIN','Allowed to modify Users and assign Groups to Users','',domainUID),'could not add role AC_USERGROUP_ADMIN');

    CheckDbResult(conn.SYS.AddRoleRightsToRole('AC_USER_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_AC_MOD.GetClassRoleNameFetch,
      'ADMINUSER'
    )));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('AC_GROUP_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_AC_MOD.GetClassRoleNameFetch,
      'ADMINGROUP'
    )));

    CheckDbResult(conn.SYS.AddRoleRightsToRole('AC_USERGROUP_ADMIN',domainUID,TFRE_DB_StringArray.Create(
      TFRE_FIRMBOX_ADMIN_APP.GetClassRoleNameFetch,
      TFRE_FIRMBOX_ADMIN_AC_MOD.GetClassRoleNameFetch,
      'ADMINUSERGROUP'
    )));

    CheckDbResult(conn.SYS.AddRolesToGroup('AC_ADMINS',domainUID,TFRE_DB_StringArray.Create('AC_USER_ADMIN','AC_GROUP_ADMIN','AC_USERGROUP_ADMIN')),'could not add roles for group Admins');
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_AC_MOD.SetupAppModuleStructure;
begin
  AddApplicationModule(TFRE_COMMON_USER_MOD.create);
  AddApplicationModule(TFRE_COMMON_GROUP_MOD.create);
  AddApplicationModule(TFRE_COMMON_ROLE_MOD.create);
end;



procedure TFRE_FIRMBOX_ADMIN_APP.SetupApplicationStructure;
begin
  inherited SetupApplicationStructure;
  InitApp('description','images_apps/firmbox_admin/main.svg');
  AddApplicationModule(TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_ADMIN_NETWORK_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_ADMIN_MON_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_ADMIN_AC_MOD.create);
  AddApplicationModule(TFRE_FIRMBOX_ADMIN_VM_MOD.create);
  fservicesMod:=TFRE_FIRMBOX_ADMIN_SERVICES_MOD.create;
  AddApplicationModule(fservicesMod);
end;

procedure TFRE_FIRMBOX_ADMIN_APP._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData    : IFRE_DB_Object;
  conn           : IFRE_DB_CONNECTION;
  disableApp     : Boolean;
  disableSection : Boolean;
  entryEnabled   : Boolean;
begin
  conn:=session.GetDBConnection; //FIXXME
  SiteMapData:=GFRE_DBI.NewObject;
  disableApp:=true;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin',FetchAppTextShort(session,'sitemap_main'),'images_apps/firmbox_admin/main.svg','',0,true);
  //NETWORK
  if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_ADMIN_NETWORK_MOD) then begin //FIXXME
    disableSection:=true;
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Network',FetchAppTextShort(session,'sitemap_network'),'images_apps/firmbox_admin/network.svg',TFRE_FIRMBOX_ADMIN_NETWORK_MOD.ClassName,0,true);
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_NET_ROUTING_MOD) then begin
      disableSection:=false;
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Network/NetsRouting',FetchAppTextShort(session,'sitemap_netsrouting'),'images_apps/firmbox_admin/netsrouting.svg',TFRE_FIRMBOX_ADMIN_NETWORK_MOD.ClassName+':'+TFRE_FIRMBOX_NET_ROUTING_MOD.ClassName,0,true);
    end;
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_FIREWALL_MOD) then begin
      disableSection:=false;
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Network/Firewall',FetchAppTextShort(session,'sitemap_firewall'),'images_apps/firmbox_admin/firewall.svg',TFRE_FIRMBOX_ADMIN_NETWORK_MOD.ClassName+':'+TFRE_FIRMBOX_FIREWALL_MOD.ClassName,0,true);
    end;
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Network/VPN',FetchAppTextShort(session,'sitemap_vpn'),'images_apps/firmbox_admin/vpn.svg',TFRE_FIRMBOX_ADMIN_NETWORK_MOD.ClassName,0,true);
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_DHCP_MOD) then begin
      disableSection:=false;
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Network/DHCP',FetchAppTextShort(session,'sitemap_dhcp'),'images_apps/firmbox_admin/dhcp.svg',TFRE_FIRMBOX_ADMIN_NETWORK_MOD.ClassName+':'+TFRE_FIRMBOX_DHCP_MOD.ClassName,0,true);
    end;
    if disableSection then begin
      FREDB_SiteMap_DisableEntry(SiteMapData,'Admin/Network');
    end else begin
      disableApp:=false;
    end;
  end;
  //INFRASTRUCTURE
  if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD) then begin //FIXXME
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Infrastructure',FetchAppTextShort(session,'sitemap_infrastructure'),'images_apps/firmbox_admin/infrastructure.svg',TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD.ClassName,0,true);
    disableApp:=false;
  end;
  //MONITORING
  if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_ADMIN_MON_MOD) then begin //FIXXME
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Monitoring',FetchAppTextShort(session,'sitemap_monitoring'),'images_apps/firmbox_admin/monitoring.svg',TFRE_FIRMBOX_ADMIN_MON_MOD.ClassName,0,true);
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Monitoring/Physical',FetchAppTextShort(session,'sitemap_monitoring_physical'),'images_apps/firmbox_admin/monphysical.svg',TFRE_FIRMBOX_ADMIN_MON_MOD.ClassName+':'+TFOS_CITYCOM_MOS_PHYSICAL_MOD.ClassName,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFOS_CITYCOM_MOS_PHYSICAL_MOD));
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Monitoring/Logical',FetchAppTextShort(session,'sitemap_monitoring_logical'),'images_apps/firmbox_admin/monlogical.svg',TFRE_FIRMBOX_ADMIN_MON_MOD.ClassName+':'+TFOS_CITYCOM_MOS_LOGICAL_MOD.ClassName,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFOS_CITYCOM_MOS_LOGICAL_MOD));
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Monitoring/Jobs',FetchAppTextShort(session,'sitemap_monitoring_jobs'),'images_apps/firmbox_admin/monjobs.svg',TFRE_FIRMBOX_ADMIN_MON_MOD.ClassName+':'+TFRE_COMMON_JOBS_MOD.ClassName,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_COMMON_JOBS_MOD));
    disableApp:=false;
  end;
  //SERVICES
  if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_ADMIN_SERVICES_MOD) then begin
    disableSection:=true;
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services',FetchAppTextShort(session,'sitemap_services'),'images_apps/firmbox_admin/services.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName,0,true);
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFOS_FIRMBOX_WEBSERVER_MOD) then begin
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Webserver',FetchAppTextShort(session,'sitemap_webserver'),'images_apps/firmbox_admin/webserver.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_WEBSERVER_MOD.ClassName,0,true);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Webserver/VirtualDomains',FetchAppTextShort(session,'sitemap_webdomains'),'images_apps/firmbox_admin/webdomain.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_WEBSERVER_MOD.ClassName,0,true);
    end;
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFOS_FIRMBOX_GROUPWARE_MOD) then begin
      disableSection:=false;
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Groupware',FetchAppTextShort(session,'sitemap_groupware'),'images_apps/firmbox_admin/groupware.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_GROUPWARE_MOD.ClassName,0,true);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Groupware/Mailserver',FetchAppTextShort(session,'sitemap_mailserver'),'images_apps/firmbox_admin/mailserver.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_GROUPWARE_MOD.ClassName,0,true);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Groupware/Calender',FetchAppTextShort(session,'sitemap_calender'),'images_apps/firmbox_admin/calender.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_GROUPWARE_MOD.ClassName,0,true);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Groupware/Antispam',FetchAppTextShort(session,'sitemap_antispam'),'images_apps/firmbox_admin/antispam.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_GROUPWARE_MOD.ClassName,0,true);
    end;
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD) then begin
      disableSection:=false;
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Fileserver',FetchAppTextShort(session,'sitemap_fileserver'),'images_apps/firmbox_admin/fileserver.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.ClassName,0,true);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Fileserver/Fileshares',FetchAppTextShort(session,'sitemap_fileshares'),'images_apps/firmbox_admin/fileshares.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.ClassName,0,true);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/Fileserver/Timeversions',FetchAppTextShort(session,'sitemap_filetimeversions'),'images_apps/firmbox_admin/timeversions.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFRE_FIRMBOX_VIRTUAL_FILESERVER_MOD.ClassName,0,true);
    end;
    if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFOS_FIRMBOX_DNS_MOD) then begin
      entryEnabled:=fservicesMod.isDNSEnabled(session,conn);
      FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Services/DNS',FetchAppTextShort(session,'sitemap_dns'),'images_apps/firmbox_admin/dns.svg',TFRE_FIRMBOX_ADMIN_SERVICES_MOD.ClassName+':'+TFOS_FIRMBOX_DNS_MOD.ClassName,0,entryEnabled);
      disableSection:=disableSection and not entryEnabled;
    end;
    if disableSection then begin
      FREDB_SiteMap_DisableEntry(SiteMapData,'Admin/Services');
    end else begin
      disableApp:=false;
    end;
  end;
  //ACCESS CONTROL
  if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_ADMIN_AC_MOD) then begin //FIXXME
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/AccessControl',FetchAppTextShort(session,'sitemap_accesscontrol'),'images_apps/firmbox_admin/accesscontrol.svg',TFRE_FIRMBOX_ADMIN_AC_MOD.ClassName,0,true);
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/AccessControl/Users',FetchAppTextShort(session,'sitemap_users'),'images_apps/firmbox_admin/user.svg',TFRE_FIRMBOX_ADMIN_AC_MOD.ClassName+':'+TFRE_COMMON_USER_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_COMMON_USER_MOD));
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/AccessControl/Groups',FetchAppTextShort(session,'sitemap_groups'),'images_apps/firmbox_admin/group.svg',TFRE_FIRMBOX_ADMIN_AC_MOD.ClassName+':'+TFRE_COMMON_GROUP_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_COMMON_GROUP_MOD));
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/AccessControl/Roles',FetchAppTextShort(session,'sitemap_roles'),'images_apps/firmbox_admin/role.svg',TFRE_FIRMBOX_ADMIN_AC_MOD.ClassName+':'+TFRE_COMMON_ROLE_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_COMMON_ROLE_MOD));
    disableApp:=false;
  end;
  //VM
  if conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_ADMIN_VM_MOD) then begin //FIXXME
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Virtualisation',FetchAppTextShort(session,'sitemap_virtualisation'),'images_apps/firmbox_admin/virtualisation.svg',TFRE_FIRMBOX_ADMIN_VM_MOD.ClassName,0,true);
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Virtualisation/Datastore',FetchAppTextShort(session,'sitemap_datastore'),'images_apps/firmbox_admin/datastore.svg',TFRE_FIRMBOX_ADMIN_VM_MOD.ClassName+':'+TFRE_FIRMBOX_VM_RESOURCES_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VM_RESOURCES_MOD));
    FREDB_SiteMap_AddRadialEntry(SiteMapData,'Admin/Virtualisation/VM',FetchAppTextShort(session,'sitemap_vm'),'images_apps/firmbox_admin/vm.svg',TFRE_FIRMBOX_ADMIN_VM_MOD.ClassName+':'+TFRE_FIRMBOX_VM_MACHINES_MOD.Classname,0,conn.sys.CheckClassRight4AnyDomain(sr_FETCH,TFRE_FIRMBOX_VM_MACHINES_MOD));
    disableApp:=false;
  end;
  if disableApp then begin
    FREDB_SiteMap_DisableEntry(SiteMapData,'Admin');
  end;
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

class procedure TFRE_FIRMBOX_ADMIN_APP.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);

  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    GFRE_DBI.LogNotice(dblc_APPLICATION,'INSTALLING '+ClassName+' Version '+currentVersionId);

    CreateAppText(conn,'caption','Administration','Administration','Administration');
    CreateAppText(conn,'sitemap_main','Administration','','Administration');
    CreateAppText(conn,'sitemap_network','Network','','Network');
    CreateAppText(conn,'sitemap_netsrouting','Nets/Routing','','Nets/Routing');
    CreateAppText(conn,'sitemap_firewall','Firewall','','Firewall');
    CreateAppText(conn,'sitemap_vpn','VPN','','VPN');
    CreateAppText(conn,'sitemap_dhcp','DHCP','','DHCP');
    CreateAppText(conn,'sitemap_virtualisation','Virtualisation','','Virtualisation');
    CreateAppText(conn,'sitemap_vm','Virtual Machines','','Virtual Machines');
    CreateAppText(conn,'sitemap_datastore','Datastore','','Datastore');
    CreateAppText(conn,'sitemap_services','Services','','Services');
    CreateAppText(conn,'sitemap_groupware','Groupware','','Groupware');
    CreateAppText(conn,'sitemap_mailserver','Mailserver','','Mailserver');
    CreateAppText(conn,'sitemap_calender','Calender','','Calender');
    CreateAppText(conn,'sitemap_antispam','AntiSpam','','AntiSpam');
    CreateAppText(conn,'sitemap_webserver','Webserver','','Webserver');
    CreateAppText(conn,'sitemap_webdomains','Virtual Domains','','Virtual Domains');
    CreateAppText(conn,'sitemap_dns','DNS','','DNS');
    CreateAppText(conn,'sitemap_fileserver','Fileserver','','Fileserver');
    CreateAppText(conn,'sitemap_fileshares','Fileshares','','Fileshares');
    CreateAppText(conn,'sitemap_filetimeversions','Timeversions','','Timeversions');
    CreateAppText(conn,'sitemap_accesscontrol','Access Control','','Access Control');
    CreateAppText(conn,'sitemap_users','Users','','Users');
    CreateAppText(conn,'sitemap_groups','Groups','','Groups');
    CreateAppText(conn,'sitemap_roles','Roles','','Roles');
    CreateAppText(conn,'sitemap_monitoring','Monitoring','','Monitoring');
    CreateAppText(conn,'sitemap_monitoring_physical','Physical','','Physical');
    CreateAppText(conn,'sitemap_monitoring_logical','Logical','','Logical');
    CreateAppText(conn,'sitemap_monitoring_jobs','Jobs','','Jobs');
    CreateAppText(conn,'sitemap_infrastructure','Infrastructure','','Infrastructure');
    CreateAppText(conn,'workflows_description','Workflows','Workflows','Workflows');
    CreateAppText(conn,'jobs_description','Jobs','Jobs','Jobs');

    //TFRE_FIRMBOX_VM_MACHINES_MOD
    CreateAppText(conn,'machines_description','Virtual Machines','Virtual Machines','Virtual Machines');
    //TFRE_FIRMBOX_VM_RESOURCES_MOD
    CreateAppText(conn,'vm_resources_description','Datastore','Datastore','Datastore');
    //TFRE_COMMON_USER_MOD
    CreateAppText(conn,'user_description','Users','Users','Users');
    //TFRE_COMMON_GROUP_MOD
    CreateAppText(conn,'group_description','Groups','Groups','Groups');
    //TFRE_COMMON_ROLE_MOD
    CreateAppText(conn,'role_description','Roles','Roles','Roles');
  end;
end;

function TFRE_FIRMBOX_ADMIN_APP.IsMultiDomainApp: Boolean;
begin
  Result:=true;
end;

function TFRE_FIRMBOX_ADMIN_APP.WEB_DATA_FEED(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  writeln('SWL: WEB DATAFEED',input.DumpToString);
//  writeln('SWL: WEB DISK DATAFEED');
  CheckDbResult(conn.DifferentialBulkUpdate(input));
  result := GFRE_DB_NIL_DESC;
end;

procedure TFRE_FIRMBOX_ADMIN_APP.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_FIRMBOX_ADMIN_APP.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

class procedure TFRE_FIRMBOX_ADMIN_APP.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
end;

procedure Register_DB_Extensions;
begin
  FRE_DBBASE.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;

  fos_firmbox_vm_machines_mod.Register_DB_Extensions;
  fre_accesscontrol_common.Register_DB_Extensions;
  fre_monitoring_common.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fos_firmbox_webserver_mod.Register_DB_Extensions;
  fos_firmbox_dns_mod.Register_DB_Extensions;
  fos_firmbox_fileserver_mod.Register_DB_Extensions;
  fos_firmbox_net_routing_mod.Register_DB_Extensions;
  fos_firmbox_dhcp_mod.Register_DB_Extensions;
  fos_mos_monitoring_mod.Register_DB_Extensions;
  fos_firmbox_groupware_mod.Register_DB_Extensions;
  fos_infrastructure_mod.Register_DB_Extensions;
  fos_firmbox_firewall_mod.Register_DB_Extensions;
  fos_firmbox_subnet_ip_mod.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_APP); //Register the App first since the modules need the fetch role to create roles and groups

  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_NETWORK_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_SERVICES_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_VM_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_AC_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_MON_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_ADMIN_INFRASTRUCTURE_MOD);
end;

end.


