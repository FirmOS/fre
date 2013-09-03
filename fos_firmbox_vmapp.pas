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
    function        InstallSystemGroupsandRoles (const conn : IFRE_DB_SYS_CONNECTION; const domain : TFRE_DB_NameType):TFRE_DB_Errortype; override;
    procedure       _UpdateSitemap              (const session: TFRE_DB_UserSession);
  protected
    procedure       MySessionInitialize       (const session: TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
    function        CFG_ApplicationUsesRights : boolean; override;
    function        _ActualVersion            : TFRE_DB_String; override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
  published
    function  IMI_VM_Feed_Update               (const input:IFRE_DB_Object) : IFRE_DB_Object;
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

                      CreateAppText(conn,'$machines_new_vm','New','','New VM');
                      CreateAppText(conn,'$machines_start','Start','','Start the selected VM');
                      CreateAppText(conn,'$machines_stop','Stop','','Stop the selected VM');
                      CreateAppText(conn,'$machines_kill','Kill','','Stop the selected VM (FORCED)');
                      CreateAppText(conn,'$machines_update','Update','','Update list');
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

function TFRE_FIRMBOX_VM_APP.InstallSystemGroupsandRoles(const conn: IFRE_DB_SYS_CONNECTION; const domain: TFRE_DB_NameType): TFRE_DB_Errortype;
var admin_app_rg : IFRE_DB_ROLE;
     user_app_rg : IFRE_DB_ROLE;
    guest_app_rg : IFRE_DB_ROLE;
begin
  admin_app_rg  := _CreateAppRole('ADMIN','firmbox VMAPP ADMIN','firmbox VMAPP Administration Rights');      // TODO: REWORK
  user_app_rg   := _CreateAppRole('USER','firmbox VMAPP USER','firmbox VMAPP Default User Rights');
  guest_app_rg  := _CreateAppRole('GUEST','firmbox VMAPP GUEST','firmbox VMAPP Default Guest User Rights');
  _AddAppRight(admin_app_rg ,'ADMIN'  ,'firmbox VMAPP Admin','Administration of firmbox VMAPP');
  _AddAppRight(user_app_rg  ,'START'  ,'firmbox VMAPP Start','Startup of firmbox VMAPP');
  _AddAppRight(admin_app_rg,'edit_vmnetwork','Edit Virtual Network','Edit Virtual Network');

//  _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['main']));
  _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['vmcontroller']));  //TODO check rights handling (module identifier)
  _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['vmnetwork']));
  _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['interfaces']));
  _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['vmstatus']));

  _AddAppRightModules(user_app_rg,GFRE_DBI.ConstructStringArray(['vmcontroller']));
  _AddAppRightModules(user_app_rg,GFRE_DBI.ConstructStringArray(['vmstatus']));

  conn.StoreRole(ObjectName,domain,admin_app_rg);
  conn.StoreRole(ObjectName,domain,user_app_rg);
  conn.StoreRole(ObjectName,domain,guest_app_rg);

  _AddSystemGroups(conn,domain);
end;

procedure TFRE_FIRMBOX_VM_APP._UpdateSitemap( const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization','Virtualization','images_apps/firmbox_vm/monitor_white.svg','',0,CheckAppRightModule(conn,'vmcontroller') or CheckAppRightModule(conn,'vmnetwork') or CheckAppRightModule(conn,'vmstatus'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/Machines','Machines','images_apps/firmbox_vm/server_white.svg','VMCONTROLLER',0,CheckAppRightModule(conn,'vmcontroller'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VSwitch','Virtual Network','images_apps/firmbox_vm/network_white.svg','VMNETWORK',0,CheckAppRightModule(conn,'vmnetwork'));
//  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/VSwitch/Interfaces','Interfaces','images_apps/firmbox_vm/plug_white.svg','',0,CheckAppRightModule(conn,'interfaces'));
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Virtualization/Status','Status','images_apps/firmbox_vm/monitor_white.svg','VMSTATUS',0,CheckAppRightModule(conn,'vmstatus'));
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

function TFRE_FIRMBOX_VM_APP.IMI_VM_Feed_Update(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := DelegateInvoke('VMCONTROLLER','VM_Feed_Update',input);
end;

procedure Register_DB_Extensions;
begin
  fos_firmbox_vm_machines_mod.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_VM_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

end.


