unit fos_dbcorebox_machine;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$codepage utf-8}

interface

uses
  Classes, SysUtils,FOS_TOOL_INTERFACES,
  FRE_DB_COMMON,
  FRE_DBBUSINESS,
  FRE_DB_INTERFACE,
  FRE_SYSTEM;

type

  { TFRE_DB_ServiceGroup }

  TFRE_DB_ServiceGroup=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  TFRE_DB_Service=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_MACHINE }

  TFRE_DB_MACHINE=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_GetDisplayAddress  (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_GetDisplayName     (const input: IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_MACHINE_SETTING }

  TFRE_DB_MACHINE_SETTING=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_MACHINE_SETTING_POWER }

  TFRE_DB_MACHINE_SETTING_POWER=class(TFRE_DB_MACHINE_SETTING)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_Shutdown           (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_Reboot             (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_MACHINE_SETTING_HOSTNAME }

  TFRE_DB_MACHINE_SETTING_HOSTNAME=class(TFRE_DB_MACHINE_SETTING)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_MACHINE_SETTING_MAIL }

  TFRE_DB_MACHINE_SETTING_MAIL=class(TFRE_DB_MACHINE_SETTING)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_MACHINE_SETTING_TIME }

  TFRE_DB_MACHINE_SETTING_TIME=class(TFRE_DB_MACHINE_SETTING)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_FC_PORT }

  TFRE_DB_FC_PORT=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_DATALINK }

  TFRE_DB_DATALINK=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_Menu               (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_DATALINK_PHYS }

  TFRE_DB_DATALINK_PHYS=class(TFRE_DB_DATALINK)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_Menu               (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_AddVNIC            (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_DATALINK_VNIC }

  TFRE_DB_DATALINK_VNIC=class(TFRE_DB_DATALINK)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_Menu               (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_Delete             (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_DATALINK_STUB }

  TFRE_DB_DATALINK_STUB=class(TFRE_DB_DATALINK)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_Menu               (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_AddVNIC            (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_Delete             (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_DATALINK_AGGR }

  TFRE_DB_DATALINK_AGGR=class(TFRE_DB_DATALINK)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_Menu               (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_AddVNIC            (const input:IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_Delete             (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_TESTER }

  TFRE_DB_TESTER=class(TFRE_DB_MACHINE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects    (const conn:IFRE_DB_SYS_CONNECTION); override;
  end;

  { TFRE_DB_VMACHINE }

  TFRE_DB_VMACHINE=class(TFRE_DB_MACHINE)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_GetDisplayName     (const input:IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_ZONE }

  TFRE_DB_ZONE=class(TFRE_DB_MACHINE)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION); override;
  published
    function        IMI_GetDisplayName     (const input: IFRE_DB_Object): IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

{ TFRE_DB_ZONE }

class procedure TFRE_DB_ZONE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_MACHINE.ClassName);
end;

class procedure TFRE_DB_ZONE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

function TFRE_DB_ZONE.IMI_GetDisplayName(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := GFRE_DBI.NewObject;
  result.Field(CalcFieldResultKey(fdbft_String)).AsString:='Zone '+Field('objname').AsString;
end;

{ TFRE_DB_MACHINE_SETTING_TIME }

class procedure TFRE_DB_MACHINE_SETTING_TIME.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_MACHINE_SETTING.Classname);
  scheme.AddSchemeField('region',fdbft_String).required:=true;
  scheme.AddSchemeField('timezone',fdbft_String).required:=true;
  scheme.AddSchemeField('ntpserver',fdbft_String);
  group:=scheme.AddInputGroup('setting').Setup('$scheme_TFRE_DB_MACHINE_SETTING_TIME_setting');
  group.AddInput('region','$scheme_TFRE_DB_MACHINE_SETTING_TIME_region');
  group.AddInput('timezone','$scheme_TFRE_DB_MACHINE_SETTING_TIME_timezone');
  group.AddInput('ntpserver','$scheme_TFRE_DB_MACHINE_SETTING_TIME_ntpserver');
end;

class procedure TFRE_DB_MACHINE_SETTING_TIME.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_TIME_setting','Setting'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_TIME_region','Region'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_TIME_timezone','Timezone'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_TIME_ntpserver','NTP Server'));
end;

{ TFRE_DB_MACHINE_SETTING_MAIL }

class procedure TFRE_DB_MACHINE_SETTING_MAIL.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_MACHINE_SETTING.Classname);
  scheme.AddSchemeField('smtpserver',fdbft_String).required:=true;
  scheme.AddSchemeField('smtpuser',fdbft_String);
  scheme.AddSchemeField('smtppassword',fdbft_String);
  scheme.AddSchemeField('mailfrom',fdbft_String).required:=true;
  scheme.AddSchemeField('mailto',fdbft_String).required:=true;
  group:=scheme.AddInputGroup('setting').Setup('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_setting');
  group.AddInput('smtpserver','$scheme_TFRE_DB_MACHINE_SETTING_MAIL_smtpserver');
  group.AddInput('smtpuser','$scheme_TFRE_DB_MACHINE_SETTING_MAIL_smtpuser');
  group.AddInput('smtppassword','$scheme_TFRE_DB_MACHINE_SETTING_MAIL_smtppassword');
  group.AddInput('mailfrom','$scheme_TFRE_DB_MACHINE_SETTING_MAIL_mailfrom');
  group.AddInput('mailto','$scheme_TFRE_DB_MACHINE_SETTING_MAIL_mailto');
end;

class procedure TFRE_DB_MACHINE_SETTING_MAIL.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_setting','Mail Parameters'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_smtpserver','SMTP Server'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_smtpuser','SMTP User'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_smtppassword','SMTP Password'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_mailfrom','Mail from'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_MAIL_mailto','Mail to'));
end;

{ TFRE_DB_MACHINE_SETTING_HOSTNAME }

class procedure TFRE_DB_MACHINE_SETTING_HOSTNAME.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_MACHINE_SETTING.Classname);
  scheme.AddSchemeField('hostname',fdbft_String);
  scheme.AddSchemeField('domainname',fdbft_String);
  group:=scheme.AddInputGroup('setting').Setup('$scheme_TFRE_DB_MACHINE_SETTING_HOSTNAME_setting');
  group.AddInput('hostname','$scheme_TFRE_DB_MACHINE_SETTING_HOSTNAME_hostname');
  group.AddInput('domainname','$scheme_TFRE_DB_MACHINE_SETTING_HOSTNAME_domainname');
end;

class procedure TFRE_DB_MACHINE_SETTING_HOSTNAME.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_HOSTNAME_setting','Setting'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_HOSTNAME_hostname','Hostname'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_HOSTNAME_domainname','Domainname'));
end;

{ TFRE_DB_MACHINE_SETTING_POWER }

class procedure TFRE_DB_MACHINE_SETTING_POWER.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_MACHINE_SETTING.Classname);
  scheme.AddSchemeField('uptime',fdbft_String);
  group:=scheme.AddInputGroup('setting').Setup('$scheme_TFRE_DB_MACHINE_SETTING_POWER_setting');
  group.AddInput('uptime','$scheme_TFRE_DB_MACHINE_SETTING_POWER_uptime',true);
end;

class procedure TFRE_DB_MACHINE_SETTING_POWER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_POWER_setting','Setting'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_POWER_uptime','Uptime'));
end;

function TFRE_DB_MACHINE_SETTING_POWER.IMI_Shutdown(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Shutdown','Shutdown disabled in Demo Mode',fdbmt_info,nil);
end;

function TFRE_DB_MACHINE_SETTING_POWER.IMI_Reboot(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe('Reboot','Reboot disabled in Demo Mode',fdbmt_info,nil);
end;

{ TFRE_DB_MACHINE_SETTING }

class procedure TFRE_DB_MACHINE_SETTING.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.Classname);
  scheme.GetSchemeField('objname').required:=true;
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_MACHINE_SETTING_main');
  group.AddInput('objname','$scheme_TFRE_DB_MACHINE_SETTING_name',true);
  group.AddInput('desc.txt','$scheme_TFRE_DB_MACHINE_SETTING_description',true);
end;

class procedure TFRE_DB_MACHINE_SETTING.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_main','Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_name','Name'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_SETTING_description','Description'));
end;

{ TFRE_DB_FC_PORT }

class procedure TFRE_DB_FC_PORT.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.Classname);
  scheme.GetSchemeField('objname').required:=true;
  scheme.AddSchemeField('targetmode',fdbft_boolean);
  scheme.AddSchemeField('portnr',fdbft_UInt16);
  scheme.AddSchemeField('manufacturer',fdbft_String);
  scheme.AddSchemeField('model',fdbft_String);
  scheme.AddSchemeField('firmware',fdbft_String);
  scheme.AddSchemeField('biosversion',fdbft_String);
  scheme.AddSchemeField('serial',fdbft_String);
  scheme.AddSchemeField('driver',fdbft_String);
  scheme.AddSchemeField('driverversion',fdbft_String);
  scheme.AddSchemeField('porttype',fdbft_String);
  scheme.AddSchemeField('state',fdbft_String);
  scheme.AddSchemeField('supportedspeeds',fdbft_String);
  scheme.AddSchemeField('currentspeed',fdbft_String);
  scheme.AddSchemeField('nodewwn',fdbft_String);

  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_FC_PORT_main');
  group.AddInput('objname','$scheme_TFRE_DB_FC_PORT_wwn',true);
  group.AddInput('desc.txt','$scheme_TFRE_DB_FC_PORT_description');
  group.AddInput('targetmode','$scheme_TFRE_DB_FC_PORT_targetmode');
  group.AddInput('portnr','$scheme_TFRE_DB_FC_PORT_portnr',true);
  group.AddInput('manufacturer','$scheme_TFRE_DB_FC_PORT_manufacturer',true);
  group.AddInput('model','$scheme_TFRE_DB_FC_PORT_model',true);
  group.AddInput('firmware','$scheme_TFRE_DB_FC_PORT_firmware',true);
  group.AddInput('biosversion','$scheme_TFRE_DB_FC_PORT_biosversion',true);
  group.AddInput('serial','$scheme_TFRE_DB_FC_PORT_serial',true);
  group.AddInput('driver','$scheme_TFRE_DB_FC_PORT_driver',true);
  group.AddInput('driverversion','$scheme_TFRE_DB_FC_PORT_driverversion',true);
  group.AddInput('porttype','$scheme_TFRE_DB_FC_PORT_porttype',true);
  group.AddInput('state','$scheme_TFRE_DB_FC_PORT_state',true);
  group.AddInput('supportedspeeds','$scheme_TFRE_DB_FC_PORT_supportedspeeds',true);
  group.AddInput('currentspeed','$scheme_TFRE_DB_FC_PORT_currentspeed',true);
  group.AddInput('nodewwn','$scheme_TFRE_DB_FC_PORT_nodewwn',true);
end;

class procedure TFRE_DB_FC_PORT.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_main','FC Adapter Port'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_wwn','Port WWN'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_description','Description'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_targetmode','Targetmode'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_portnr','Port ID'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_manufacturer','Manufacturer'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_model','Model'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_firmware','Firmware'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_biosversion','Bios Version'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_serial','Serial Number'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_driver','Driver'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_driverversion','Driver Version'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_porttype','Port Type'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_state','State'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_supportedspeeds','Supported Speeds'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_currentspeed','Current Speed'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_FC_PORT_nodewwn','Node WWN'));

end;

{ TFRE_DB_DATALINK_STUB }

class procedure TFRE_DB_DATALINK_STUB.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_DATALINK.ClassName);
end;

class procedure TFRE_DB_DATALINK_STUB.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

function TFRE_DB_DATALINK_STUB.IMI_Menu(const input: IFRE_DB_Object): IFRE_DB_Object;
var res       : TFRE_DB_MENU_DESC;
    func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  func:=CSF(@IMI_Delete);
  res.AddEntry.Describe(input.Field('delete_stub').asstring,'images_apps/corebox_appliance/delete_stub.png',func);
  func:=CSF(@IMI_AddVNIC);
  res.AddEntry.Describe(input.Field('add_vnic').asstring,'images_apps/corebox_appliance/add_vnic.png',func);
  Result:=res;
end;

function TFRE_DB_DATALINK_STUB.IMI_AddVNIC(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);
end;

function TFRE_DB_DATALINK_STUB.IMI_Delete(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);
end;

{ TFRE_DB_DATALINK_AGGR }

class procedure TFRE_DB_DATALINK_AGGR.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_DATALINK.ClassName);
end;

class procedure TFRE_DB_DATALINK_AGGR.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

function TFRE_DB_DATALINK_AGGR.IMI_Menu(const input: IFRE_DB_Object): IFRE_DB_Object;
var res       : TFRE_DB_MENU_DESC;
    func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  func:=CSF(@IMI_Delete);
  res.AddEntry.Describe(input.Field('delete_aggr').asstring,'images_apps/corebox_appliance/delete_aggr.png',func);
  func:=CSF(@IMI_AddVNIC);
  res.AddEntry.Describe(input.Field('add_vnic').asstring,'images_apps/corebox_appliance/add_vnic.png',func);
  Result:=res;
end;

function TFRE_DB_DATALINK_AGGR.IMI_AddVNIC(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);
end;

function TFRE_DB_DATALINK_AGGR.IMI_Delete(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);
end;

{ TFRE_DB_DATALINK_VNIC }

class procedure TFRE_DB_DATALINK_VNIC.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_DATALINK.ClassName);
end;

class procedure TFRE_DB_DATALINK_VNIC.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

function TFRE_DB_DATALINK_VNIC.IMI_Menu(const input: IFRE_DB_Object): IFRE_DB_Object;
var res       : TFRE_DB_MENU_DESC;
    func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  func:=CSF(@IMI_Delete);
  res.AddEntry.Describe(input.Field('delete_vnic').asstring,'images_apps/corebox_appliance/delete_vnic.png',func);
  Result:=res;
end;

function TFRE_DB_DATALINK_VNIC.IMI_Delete(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);
end;

{ TFRE_DB_DATALINK_PHYS }

class procedure TFRE_DB_DATALINK_PHYS.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_DATALINK.ClassName);
end;

class procedure TFRE_DB_DATALINK_PHYS.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

function TFRE_DB_DATALINK_PHYS.IMI_Menu(const input: IFRE_DB_Object): IFRE_DB_Object;
var res       : TFRE_DB_MENU_DESC;
    func      : TFRE_DB_SERVER_FUNC_DESC;
begin
  if Field('parentid').ValueCount=0 then
    begin
      res:=TFRE_DB_MENU_DESC.create.Describe;
      func:=CSF(@IMI_AddVNIC);
      res.AddEntry.Describe(input.Field('add_vnic').asstring,'images_apps/corebox_appliance/add_vnic.png',func);
      Result:=res;
    end
  else
    result := GFRE_DB_NIL_DESC;
end;

function TFRE_DB_DATALINK_PHYS.IMI_AddVNIC(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result :=  TFRE_DB_MESSAGE_DESC.create.Describe('','Feature disabled in Demo Mode',fdbmt_info,nil);
end;

{ TFRE_DB_DATALINK }

class procedure TFRE_DB_DATALINK.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.Classname);
  scheme.GetSchemeField('objname').required:=true;
  scheme.AddSchemeField('parentid',fdbft_ObjLink).multiValues:=false;
  scheme.AddSchemeField('ip_net',fdbft_String).SetupFieldDef(false,false,'','ip');
  scheme.AddSchemeField('mtu',fdbft_Uint16);
  scheme.AddSchemeField('vlan',fdbft_Uint16);
  scheme.AddSchemeField('showvirtual',fdbft_Boolean).required:=true;
  scheme.AddSchemeField('showglobal',fdbft_Boolean).required:=true;
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_DATALINK_main_group');
  group.AddInput('objname','$scheme_TFRE_DB_DATALINK_name',true);
  group.AddInput('desc.txt','$scheme_TFRE_DB_DATALINK_description');
  group.AddInput('ip_net','$scheme_TFRE_DB_DATALINK_ip_net');
  group.AddInput('mtu','$scheme_TFRE_DB_DATALINK_mtu');
  group.AddInput('vlan','$scheme_TFRE_DB_DATALINK_vlan');
end;

class procedure TFRE_DB_DATALINK.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_DATALINK_main_group','Link Properties'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_DATALINK_name','Link Name'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_DATALINK_description','Description'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_DATALINK_ip_net','IP/Subnet'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_DATALINK_mtu','MTU'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_DATALINK_vlan','Vlan'));
end;

function TFRE_DB_DATALINK.IMI_Menu(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  writeln('DATALINK MENU');
  result := GFRE_DB_NIL_DESC;
end;

{ TFRE_DB_TESTER }

class procedure TFRE_DB_TESTER.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;

class procedure TFRE_DB_TESTER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;


class procedure TFRE_DB_VMACHINE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_MACHINE.ClassName);
end;

class procedure TFRE_DB_VMACHINE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
end;

function TFRE_DB_VMACHINE.IMI_GetDisplayName(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := GFRE_DBI.NewObject;
  result.Field(CalcFieldResultKey(fdbft_String)).AsString:='VM '+Field('objname').AsString;
end;


class procedure TFRE_DB_MACHINE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName(TFRE_DB_ObjectEx.ClassName);
  scheme.GetSchemeField('objname').required:=true;
  scheme.AddSchemeField('ip',fdbft_String);
  scheme.AddSchemeField('service',fdbft_ObjLink);
  scheme.AddSchemeFieldSubscheme('position','TFRE_DB_GEOPOSITION').required:=false;
  scheme.AddSchemeFieldSubscheme('address','TFRE_DB_ADDRESS').required:=false;
  scheme.AddCalculatedField('displayaddress','GetDisplayAddress',cft_OnStoreUpdate);
  scheme.AddSchemeField('domainid',fdbft_GUID);
  scheme.AddCalculatedField ('displayname','GetDisplayName',cft_OnStoreUpdate);

  group:=scheme.AddInputGroup('address').Setup('$scheme_TFRE_DB_MACHINE_address_group');
  group.UseInputGroup('TFRE_DB_ADDRESS','main','address');
  group.UseInputGroup('TFRE_DB_GEOPOSITION','main','position');

end;

class procedure TFRE_DB_MACHINE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  inherited InstallDBObjects(conn);
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_MACHINE_address_group','Site Address'));
end;

function TFRE_DB_MACHINE.IMI_GetDisplayAddress(const input: IFRE_DB_Object): IFRE_DB_Object;
var s    :  string;
begin
  result := GFRE_DBI.NewObject;
  s      := '';
  if FieldExists('address') then begin
    s := trim(Field('address').AsObject.Field('co').AsString);
    if length(s)>0 then begin
      s:= s + ', ';
    end;
    s := s+Field('address').AsObject.Field('zip').asstring+' '+Field('address').AsObject.Field('city').asstring+', '+Field('address').AsObject.Field('street').asstring+' '+Field('address').AsObject.Field('nr').asstring;
  end else begin
    s := '';
  end;
  result.Field(CalcFieldResultKey(fdbft_String)).AsString:=s;
end;

function TFRE_DB_MACHINE.IMI_GetDisplayName(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  result := GFRE_DBI.NewObject;
  result.Field(CalcFieldResultKey(fdbft_String)).AsString:='Machine '+Field('objname').AsString;
end;

class procedure TFRE_DB_Service.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName  ('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('machineid',fdbft_ObjLink);
  scheme.AddSchemeField('servicegroup',fdbft_ObjLink);
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_SERVICE_main_group');
  group.AddInput('machineid','',false,true);
end;

class procedure TFRE_DB_Service.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  inherited InstallDBObjects(conn);
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_SERVICE_main_group','General Information'));
end;

class procedure TFRE_DB_ServiceGroup.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName  ('TFRE_DB_OBJECTEX');
  scheme.GetSchemeField('objname').required:=true;
  scheme.AddSchemeField('customerid',fdbft_ObjLink);
  scheme.AddSchemeField('monitoring',fdbft_Objlink);
  group:=scheme.AddInputGroup('main').Setup('$scheme_TFRE_DB_SERVICEGROUP_main_group');
  group.AddInput('objname','$scheme_TFRE_DB_SERVICEGROUP_name');
  group.AddInput('customerid','');
end;

class procedure TFRE_DB_ServiceGroup.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION);
begin
  inherited InstallDBObjects(conn);
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_SERVICEGROUP_main_group','General Information'));
  conn.StoreTranslateableText(GFRE_DBI.CreateText('$scheme_TFRE_DB_SERVICEGROUP_name','Name'));
end;

procedure Register_DB_Extensions;
var validator : IFRE_DB_ClientFieldValidator;
    enum      : IFRE_DB_Enum;
begin
  validator:=GFRE_DBI.NewClientFieldValidator('ip').Setup('^([1-9][0-9]{0,1}|1[013-9][0-9]|12[0-689]|2[01][0-9]|22[0-3])([.]([1-9]{0,1}[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])){2}[.]([1-9][0-9]{0,1}|[1-9]{0,1}[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-4])(\/([89]|[12][0-9]|3[0-2])|$)$',
                                                    GFRE_DBI.CreateText('$validator_ip','IP Validator'),
                                                    GFRE_DBI.CreateText('$validator_help_ip','1.0.0.1 - 223.255.255.254 excluding 127.x.x.x'),
                                                    '\d\.\/');
  GFRE_DBI.RegisterSysClientFieldValidator(validator);
  validator:=GFRE_DBI.NewClientFieldValidator('mac').Setup('^([0-9a-fA-F]{2}(:|$)){6}$',
                                                     GFRE_DBI.CreateText('$validator_help_mac','MAC Validator'),
                                                     GFRE_DBI.CreateText('$validator_mac','00:01:02:03:04:05'),
                                                     '\da-fA-F:');
  GFRE_DBI.RegisterSysClientFieldValidator(validator);

  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MACHINE_SETTING);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MACHINE_SETTING_POWER);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MACHINE_SETTING_MAIL);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MACHINE_SETTING_TIME);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MACHINE_SETTING_HOSTNAME);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_FC_PORT);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_DATALINK);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_DATALINK_PHYS);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_DATALINK_VNIC);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_DATALINK_AGGR);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_DATALINK_STUB);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ServiceGroup);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_Service);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_Machine);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_VMachine);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ZONE);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_Tester);
  GFRE_DBI.Initialize_Extension_Objects;
end;


end.

