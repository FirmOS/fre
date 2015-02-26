unit fos_firmbox_dns_mod;

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
  fre_hal_schemes,
  FRE_DB_COMMON,
  fre_dbbusiness;

const

  CFOS_DB_DNS_RECORDS_COLLECTION      = 'dns_records';

  CFOS_DB_DNS_CUSTOMERS_DCOLL         = 'dns_customers_chooser';

  CPARAM_GLOBAL                       = 'global';
  CPARAM_DOMAINID                     = 'service_domain';
type

  { TFOS_FIRMBOX_DNS_MOD }

  TFOS_FIRMBOX_DNS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _AddModifyResourceRecord            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
    function        _AddModifyNameserver                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;

    procedure       _getClasses                         (const global:Boolean; var networkDomainClass,resourceRecordClass,nameserverClass: TFRE_DB_ObjectClassEx);
    procedure       _showGlobal                         (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; var domains,nameserver:Boolean);
    procedure       _showLocal                          (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; var domains,nameserver:Boolean);
  protected
    procedure       SetupAppModuleStructure             ; override;
  public
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       CalculateDescription                (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
    procedure       CalculateNameserverGridFields       (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
    function        isEnabled                           (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;

    function        WEB_DomainsContent                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DomainDetailsContent            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DomainRecordsContent            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainsMenu              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainsSC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddNetworkDomain                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddNetworkDomainDetails         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateNetworkDomain             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_UpdateNetworkDomain             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainDelete             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NetworkDomainDeleteConfirmed    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddResourceRecord               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyResourceRecord            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreResourceRecord             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordDelete            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordDeleteConfirmed   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordsMenu             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ResourceRecordsSC               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_NameserverContent               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NameserverMenu                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddNameserver                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyNameserver                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreNameserver                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NameserverDelete                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_NameserverDeleteConfirmed       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SetAsDefault                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_DB_NETWORK_DOMAIN }

  TFOS_DB_NETWORK_DOMAIN=class(TFRE_DB_SUBSERVICE)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_PROVIDER_NETWORK_DOMAIN }

  TFOS_DB_PROVIDER_NETWORK_DOMAIN=class(TFOS_DB_NETWORK_DOMAIN)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_DNS_RESOURCE_RECORD }

  TFOS_DB_DNS_RESOURCE_RECORD=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD }

  TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD=class(TFOS_DB_DNS_RESOURCE_RECORD)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_DNS_NAMESERVER_RECORD }

  TFOS_DB_DNS_NAMESERVER_RECORD=class(TFOS_DB_DNS_RESOURCE_RECORD)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD }

  TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD=class(TFOS_DB_DNS_NAMESERVER_RECORD)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_NETWORK_DOMAIN);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_PROVIDER_NETWORK_DOMAIN);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_DNS_RESOURCE_RECORD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_DNS_NAMESERVER_RECORD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD);

  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_DNS_MOD);

  //GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD }

class procedure TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;

class procedure TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
end;

{ TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD }

class procedure TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetOverlayRights4UserClass('WEBUSER',[sr_FETCH]);
end;

class procedure TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
end;

{ TFOS_DB_PROVIDER_NETWORK_DOMAIN }

class procedure TFOS_DB_PROVIDER_NETWORK_DOMAIN.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;

class procedure TFOS_DB_PROVIDER_NETWORK_DOMAIN.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited InstallDBObjects(conn, currentVersionId, newVersionId);
end;

{ TFOS_DB_DNS_NAMESERVER_RECORD }

class procedure TFOS_DB_DNS_NAMESERVER_RECORD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group: IFRE_DB_InputGroupSchemeDefinition;
  enum : IFRE_DB_Enum;
begin
  inherited RegisterSystemScheme(scheme);

  enum:=GFRE_DBI.NewEnum('dns_nameserver_type').Setup(GFRE_DBI.CreateText('$dns_nameserver_type','Nameserver Type'));
  enum.addEntry('NS',GetTranslateableTextKey('dns_rr_ns'));
  GFRE_DBI.RegisterSysEnum(enum);

  scheme.SetParentSchemeByName('TFOS_DB_DNS_RESOURCE_RECORD');
  scheme.GetSchemeField('type').SetupFieldDef(true,false,'dns_nameserver_type');
  scheme.AddSchemeField('default',fdbft_Int16);

  group:=scheme.ReplaceInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('host',GetTranslateableTextKey('scheme_host'));
  group.AddInput('value',GetTranslateableTextKey('scheme_value'),false,false,'','',false,dh_chooser_combo,coll_NONE,false,'ip');
  group.AddInput('ttl',GetTranslateableTextKey('scheme_ttl'));
end;

class procedure TFOS_DB_DNS_NAMESERVER_RECORD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.1';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';

    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_host','Host');
    StoreTranslateableText(conn,'scheme_value','Value');
    StoreTranslateableText(conn,'scheme_ttl','Time to live');

    StoreTranslateableText(conn,'dns_rr_ns','NS (Name server record)');
  end;
  if (currentVersionId='1.0') then begin
    currentVersionId := '1.1';

    DeleteTranslateableText(conn,'scheme_host');
    DeleteTranslateableText(conn,'scheme_value');
    StoreTranslateableText(conn,'scheme_host','Hostname');
    StoreTranslateableText(conn,'scheme_value','IPv4');
  end;
end;

{ TFOS_DB_DNS_RESOURCE_RECORD }

class procedure TFOS_DB_DNS_RESOURCE_RECORD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group      : IFRE_DB_InputGroupSchemeDefinition;
  enum       : IFRE_DB_Enum;
  schemeField: IFRE_DB_FieldSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);

  enum:=GFRE_DBI.NewEnum('dns_resource_record_type').Setup(GFRE_DBI.CreateText('$dns_resource_record_type','Resource Record Type'));
  enum.addEntry('A',GetTranslateableTextKey('dns_rr_a'));
  enum.addEntry('AAAA',GetTranslateableTextKey('dns_rr_aaaa'));
  enum.addEntry('CNAME',GetTranslateableTextKey('dns_rr_cname'));
  enum.addEntry('MX',GetTranslateableTextKey('dns_rr_mx'));
  enum.addEntry('TXT',GetTranslateableTextKey('dns_rr_txt'));
  enum.addEntry('SPF',GetTranslateableTextKey('dns_rr_spf'));
  enum.addEntry('SRV',GetTranslateableTextKey('dns_rr_srv'));
  //enum.addEntry('NS',GetTranslateableTextKey('dns_rr_ns'));
  GFRE_DBI.RegisterSysEnum(enum);

  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('network_domain',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('network_domain_default',fdbft_ObjLink);
  scheme.AddSchemeField('host',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('value',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('ttl',fdbft_Int64);

  scheme.AddSchemeField('priority',fdbft_String);
  scheme.AddSchemeField('weight',fdbft_String);
  scheme.AddSchemeField('port',fdbft_Int64);

  schemeField:=scheme.AddSchemeField('type',fdbft_String).SetupFieldDef(true,false,'dns_resource_record_type');
  schemeField.addEnumDepField('priority','MX',fdv_visible);
  schemeField.addEnumDepField('priority','SRV',fdv_visible);
  schemeField.addEnumDepField('weight','SRV',fdv_visible);
  schemeField.addEnumDepField('port','SRV',fdv_visible);

  schemeField.addEnumDepField('value','CNAME',fdv_none,fdes_none,GetTranslateableTextKey('scheme_value_cname'));
  schemeField.addEnumDepField('value','TXT',fdv_none,fdes_none,GetTranslateableTextKey('scheme_value_txt'));
  schemeField.addEnumDepField('value','A',fdv_none,fdes_none,GetTranslateableTextKey('scheme_value_a'),'ip');
  schemeField.addEnumDepField('value','AAAA',fdv_none,fdes_none,GetTranslateableTextKey('scheme_value_aaaa'),'ipv6');

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('host',GetTranslateableTextKey('scheme_host'));
  group.AddInput('type',GetTranslateableTextKey('scheme_type'));
  group.AddInput('value',GetTranslateableTextKey('scheme_value'));
  group.AddInput('ttl',GetTranslateableTextKey('scheme_ttl'));
  group.AddInput('priority',GetTranslateableTextKey('scheme_priority'));
  group.AddInput('weight',GetTranslateableTextKey('scheme_weight'));
  group.AddInput('port',GetTranslateableTextKey('scheme_port'));

  group:=scheme.AddInputGroup('main_default').Setup(GetTranslateableTextKey('scheme_main_default_group'));
  group.AddInput('value',GetTranslateableTextKey('scheme_value_a'),false,false,'','',false,dh_chooser_combo,coll_NONE,false,'ip');
  group.AddInput('ttl',GetTranslateableTextKey('scheme_ttl'));
end;

class procedure TFOS_DB_DNS_RESOURCE_RECORD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.1';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';

    StoreTranslateableText(conn,'scheme_main_group','General Information');
    StoreTranslateableText(conn,'scheme_host','Host');
    StoreTranslateableText(conn,'scheme_type','Type');
    StoreTranslateableText(conn,'scheme_value','Value');
    StoreTranslateableText(conn,'scheme_ttl','Time to live');
    StoreTranslateableText(conn,'scheme_priority','Priority');
    StoreTranslateableText(conn,'scheme_weight','Weight');
    StoreTranslateableText(conn,'scheme_port','Port');

    StoreTranslateableText(conn,'dns_rr_a','A (Address Record IPv4)');
    StoreTranslateableText(conn,'dns_rr_aaaa','AAAA (Address Record IPv6)');
    StoreTranslateableText(conn,'dns_rr_cname','CNAME (Canonical name record)');
    StoreTranslateableText(conn,'dns_rr_mx','MX (Mail exchange record)');
    StoreTranslateableText(conn,'dns_rr_txt','TXT (Text record)');
    StoreTranslateableText(conn,'dns_rr_spf','SPF (Sender Policy Framework)');
    StoreTranslateableText(conn,'dns_rr_srv','SRV (Service locator)');
    StoreTranslateableText(conn,'dns_rr_ns','NS (Name server record)');

  end;
  if (currentVersionId='1.0') then begin
    currentVersionId := '1.1';

    StoreTranslateableText(conn,'scheme_value_cname','Alias');
    StoreTranslateableText(conn,'scheme_value_txt','Text');
    StoreTranslateableText(conn,'scheme_value_a','IPv4');
    StoreTranslateableText(conn,'scheme_value_aaaa','IPv6');

    StoreTranslateableText(conn,'scheme_main_default_group','Domain A Record');
    DeleteTranslateableText(conn,'scheme_host');
    StoreTranslateableText(conn,'scheme_host','Hostname');
  end;
end;

{ TFOS_DB_NETWORK_DOMAIN }

class procedure TFOS_DB_NETWORK_DOMAIN.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  params: IFRE_DB_Object;
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_SERVICE');
  scheme.AddSchemeField('customer',fdbft_ObjLink).SetupFieldDef(true);
  scheme.AddSchemeField('dns1',fdbft_ObjLink).SetupFieldDef(true);
  scheme.AddSchemeField('dns2',fdbft_ObjLink);
  scheme.AddSchemeField('default',fdbft_ObjLink);

  group:=scheme.ReplaceInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('objname',GetTranslateableTextKey('scheme_name'));

  group:=scheme.AddInputGroup('main_customer').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('customer',GetTranslateableTextKey('scheme_customer'),false,false,'',CFOS_DB_DNS_CUSTOMERS_DCOLL,true);
  group.AddInput('objname',GetTranslateableTextKey('scheme_name'));
end;

class procedure TFOS_DB_NETWORK_DOMAIN.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.1';

  if (currentVersionId='') then begin
    currentVersionId := '1.0';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'scheme_name','Name');
  end;
  if (currentVersionId='1.0') then begin
    currentVersionId := '1.1';

    StoreTranslateableText(conn,'scheme_customer','Customer');
  end;
end;

{ TFOS_FIRMBOX_DNS_MOD }

class procedure TFOS_FIRMBOX_DNS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_DNS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('dns_description')
end;

class procedure TFOS_FIRMBOX_DNS_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.2';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    //TFOS_FIRMBOX_DNS_MOD;
    CreateModuleText(conn,'dns_description','DNS','DNS','DNS');

    CreateModuleText(conn,'grid_network_domains_name','Name');
    CreateModuleText(conn,'grid_network_domains_default','Default');
    CreateModuleText(conn,'grid_records_host','Host');
    CreateModuleText(conn,'grid_records_type','Type');
    CreateModuleText(conn,'grid_records_value','Value');
    CreateModuleText(conn,'grid_records_ttl','TTL');

    CreateModuleText(conn,'tb_create_network_domain','Add');
    CreateModuleText(conn,'tb_delete_network_domain','Delete');
    CreateModuleText(conn,'cm_delete_network_domain','Delete');

    CreateModuleText(conn,'tb_create_resource_record','Add');
    CreateModuleText(conn,'tb_delete_resource_record','Delete');
    CreateModuleText(conn,'tb_modify_resource_record','Modify');
    CreateModuleText(conn,'cm_delete_resource_record','Delete');
    CreateModuleText(conn,'cm_modify_resource_record','Modify');

    CreateModuleText(conn,'network_domain_create_diag_cap','New Domain');
    CreateModuleText(conn,'network_domain_create_dns1','DNS 1');
    CreateModuleText(conn,'network_domain_create_dns2','DNS 2');
    CreateModuleText(conn,'network_domain_create_default','Default');

    CreateModuleText(conn,'network_domain_edit_dns1','DNS 1');
    CreateModuleText(conn,'network_domain_edit_dns2','DNS 2');
    CreateModuleText(conn,'network_domain_edit_default','Default');

    CreateModuleText(conn,'network_domain_create_error_exists_cap','Create Network Domain');
    CreateModuleText(conn,'network_domain_create_error_exists_msg','Network Domain already exists. Please choose a different network domain name.');
    CreateModuleText(conn,'network_domain_delete_diag_cap','Delete Network Domain');
    CreateModuleText(conn,'network_domain_delete_diag_msg','Delete Network Domain %nw_domain_str%?');

    CreateModuleText(conn,'network_domain_content_section_details','Details');
    CreateModuleText(conn,'network_domain_content_section_records','Records');

    CreateModuleText(conn,'resource_record_create_diag_cap','Create Resource Record');
    CreateModuleText(conn,'resource_record_modify_diag_cap','Modify Resource Record');
    CreateModuleText(conn,'resource_record_delete_diag_cap','Delete Resource Record');
    CreateModuleText(conn,'resource_record_delete_diag_msg','Delete Resource Record %rr_str%?');

    CreateModuleText(conn,'info_domain_details_select_one','Please select a network domain to get detailed information about it.');

    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
    CreateModuleText(conn,'error_host_name_at_caption','Error saving Resource Record');
    CreateModuleText(conn,'error_host_name_at_msg','"@" is reserved and therefore not allowed as Hostname. Please choose another Hostname. If you wanted to set the domain default please edit the domain.');
  end;
  if currentVersionId='0.1' then begin
    currentVersionId := '0.2';

    CreateModuleText(conn,'chooser_customer','Customer');
    CreateModuleText(conn,'grid_network_domains_customer','Customer');
    CreateModuleText(conn,'grid_customer_default_value','No Customer assigned');

    DeleteTranslateableText(conn,'network_domain_create_default');
    DeleteTranslateableText(conn,'network_domain_edit_default');
    DeleteModuleText(conn,'grid_records_host');
    CreateModuleText(conn,'grid_records_host','Hostname');

    DeleteModuleText(conn,'grid_network_domains_default');
    CreateModuleText(conn,'grid_network_domains_default_value','Domain A Record: %value%');
    CreateModuleText(conn,'grid_network_domains_default_ttl',' (TTL: %ttl%)');

    CreateModuleText(conn,'grid_nameserver_records_host','Host');
    CreateModuleText(conn,'grid_nameserver_records_value','Value');
    CreateModuleText(conn,'grid_nameserver_records_ttl','TTL');

    CreateModuleText(conn,'nameserver_create_diag_cap','New Nameserver');
    CreateModuleText(conn,'nameserver_modify_diag_cap','Modify Nameserver');
    CreateModuleText(conn,'nameserver_delete_diag_cap','Delete Nameserver');
    CreateModuleText(conn,'nameserver_delete_diag_msg','Delete Nameserver %rr_str%?');

    CreateModuleText(conn,'tb_create_nameserver','New');
    CreateModuleText(conn,'tb_modify_nameserver','Modify');
    CreateModuleText(conn,'tb_delete_nameserver','Delete');
    CreateModuleText(conn,'tb_set_as_default_1','Set as Default 1');
    CreateModuleText(conn,'tb_set_as_default_2','Set as Default 2');
    CreateModuleText(conn,'cm_modify_nameserver','Modify');
    CreateModuleText(conn,'cm_delete_nameserver','Delete');
    CreateModuleText(conn,'cm_set_as_default_1','Set as Default 1');
    CreateModuleText(conn,'cm_set_as_default_2','Set as Default 2');

    CreateModuleText(conn,'grid_nameserver_customer','Customer');

    CreateModuleText(conn,'global_domains_section','Global Domains');
    CreateModuleText(conn,'domains_section','Private Domains');
    CreateModuleText(conn,'global_nameserver_section','Global Nameserver');
    CreateModuleText(conn,'nameserver_section','Private Nameserver');

    CreateModuleText(conn,'network_domain_create_customer','Customer');
    CreateModuleText(conn,'nameserver_create_customer_group','Customer');
    CreateModuleText(conn,'nameserver_create_customer','Customer');
    CreateModuleText(conn,'button_select_customer','Select');
  end;
end;

class procedure TFOS_FIRMBOX_DNS_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
var
  coll   : IFRE_DB_COLLECTION;
  idx_def: TFRE_DB_INDEX_DEF;
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';
    if not conn.CollectionExists(CFOS_DB_DNS_RECORDS_COLLECTION) then begin
      coll := conn.CreateCollection(CFOS_DB_DNS_RECORDS_COLLECTION);
      CheckDbResult(coll.DefineIndexOnField('uniquephysicalid',fdbft_String,true,true,'def',false));
    end;
  end;
  if currentVersionId='0.1' then begin
    currentVersionId := '0.2';
    if conn.CollectionExists('network_domains') then begin
      conn.DeleteCollection('network_domains');
    end;
  end;

  coll:=conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION);

  idx_def:= coll.GetIndexDefinition('def');
  if lowercase(idx_def.FieldName)='name' then begin
    coll.DropIndex('def');
    CheckDbResult(coll.DefineIndexOnField('uniquephysicalid',fdbft_String,true,true,'def',false));
  end;

end;

function TFOS_FIRMBOX_DNS_MOD._AddModifyResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean): IFRE_DB_Object;
var
  scheme                 : IFRE_DB_SchemeObject;
  res                    : TFRE_DB_FORM_DIALOG_DESC;
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  diagCap                : TFRE_DB_String;
  recordDBO              : IFRE_DB_Object;
  dbo                    : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  sf:=CWSF(@WEB_StoreResourceRecord);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    global:=dbo.Implementor_HC is TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
    _getClasses(global,ndClass,rrClass,nsClass);

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,rrClass,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('rrecordId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'resource_record_modify_diag_cap');
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('dependency.uid_ref.filtervalues').AsStringItem[0]),dbo));

    global:=dbo.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
    _getClasses(global,ndClass,rrClass,nsClass);

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('networkDomainId',dbo.UID_String);
    diagCap:=FetchModuleTextShort(ses,'resource_record_create_diag_cap');
  end;
  GetSystemScheme(rrClass,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),recordDBO));
    res.FillWithObjectValues(recordDBO,ses);
  end;

  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD._AddModifyNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  recordDBO              : IFRE_DB_Object;
  scheme                 : IFRE_DB_SchemeObject;
  res                    : TFRE_DB_FORM_DIALOG_DESC;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  global                 : Boolean;
  dbo                    : IFRE_DB_Object;
  customer_dc            : IFRE_DB_DERIVED_COLLECTION;
  store                  : TFRE_DB_STORE_DESC;
  group                  : TFRE_DB_INPUT_GROUP_DESC;
  domains                : TFRE_DB_GUIDArray;
begin
  sf:=CWSF(@WEB_StoreNameserver);
  if isModify then begin
    res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'nameserver_modify_diag_cap'),600);
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    global:=dbo.Implementor_HC is TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
    _getClasses(global,ndClass,rrClass,nsClass);

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,nsClass,dbo.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('rrecordId',input.Field('selected').AsString);
  end else begin
    res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'nameserver_create_diag_cap'),600);
    global:=input.Field(CPARAM_GLOBAL).AsString='true';
    _getClasses(global,ndClass,rrClass,nsClass);

    if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,nsClass) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe(CPARAM_GLOBAL,input.Field(CPARAM_GLOBAL).AsString);
    if not global then begin
      domains:=conn.SYS.GetDomainsForClassRight(sr_STORE,nsClass);
      if Length(domains)=1 then begin
        sf.AddParam.Describe(CPARAM_DOMAINID,FREDB_G2H(domains[0]));
      end else begin
        customer_dc:=ses.FetchDerivedCollection(CFOS_DB_DNS_CUSTOMERS_DCOLL);
        customer_dc.Filters.RemoveFilter('rights');
        customer_dc.Filters.AddStdClassRightFilter('rights','servicedomain','','','TFOS_DB_DNS_NAMESERVER_RECORD',[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
        store:=customer_dc.GetStoreDescription as TFRE_DB_STORE_DESC;

        group:=res.AddGroup.Describe(FetchModuleTextShort(ses,'nameserver_create_customer_group'));
        group.AddChooser.Describe(FetchModuleTextShort(ses,'nameserver_create_customer'),'customer',store,dh_chooser_combo,true,false,true);
      end;
    end;
  end;
  GetSystemScheme(nsClass,scheme);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),recordDBO));
    res.FillWithObjectValues(recordDBO,ses);
  end;

  Result:=res;
end;

procedure TFOS_FIRMBOX_DNS_MOD._getClasses(const global: Boolean; var networkDomainClass, resourceRecordClass, nameserverClass: TFRE_DB_ObjectClassEx);
begin
  if global then begin
    networkDomainClass:=TFOS_DB_PROVIDER_NETWORK_DOMAIN;
    resourceRecordClass:=TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
    nameserverClass:=TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
  end else begin
    networkDomainClass:=TFOS_DB_NETWORK_DOMAIN;
    resourceRecordClass:=TFOS_DB_DNS_RESOURCE_RECORD;
    nameserverClass:=TFOS_DB_DNS_NAMESERVER_RECORD;
  end;
end;

procedure TFOS_FIRMBOX_DNS_MOD._showGlobal(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; var domains, nameserver: Boolean);
var
  dc: IFRE_DB_DERIVED_COLLECTION;
begin
  domains:=false;
  nameserver:=false;

  if conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_PROVIDER_NETWORK_DOMAIN) and conn.SYS.CheckClassRight4AnyDomain(sr_UPDATE,TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD) then begin //PROVIDER
    domains:=true;
    nameserver:=true;
    exit;
  end;
  dc:=ses.FetchDerivedCollection('GLOBAL_NETWORK_DOMAINS_GRID');
  if dc.ItemCount>0 then begin
    domains:=true;
  end;
end;

procedure TFOS_FIRMBOX_DNS_MOD._showLocal(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; var domains, nameserver: Boolean);
var
  dc: IFRE_DB_DERIVED_COLLECTION;
begin
  domains:=false;
  nameserver:=false;

  if conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_NETWORK_DOMAIN) and conn.SYS.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_DNS_NAMESERVER_RECORD) then begin //PROVIDER
    domains:=true;
    nameserver:=true;
    exit;
  end;

  dc:=ses.FetchDerivedCollection('NAMESERVER_CHOOSER');
  dc.Filters.RemoveFilter('service_type');
  dc.Filters.RemoveFilter('service_domain');
  dc.Filters.AddSchemeObjectFilter('service_type',['TFOS_DB_DNS_NAMESERVER_RECORD']);

  if dc.ItemCount>0 then begin
    if conn.SYS.CheckClassRight4AnyDomain(sr_UPDATE,TFOS_DB_DNS_NAMESERVER_RECORD) then begin
      nameserver:=true;
    end;
    if conn.SYS.CheckClassRight4AnyDomain(sr_FETCH,TFOS_DB_NETWORK_DOMAIN) then begin
      domains:=true;
    end;
  end;
end;

procedure TFOS_FIRMBOX_DNS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app          : TFRE_DB_APPLICATION;
  conn         : IFRE_DB_CONNECTION;
  transform    : IFRE_DB_SIMPLE_TRANSFORM;
  domains_grid : IFRE_DB_DERIVED_COLLECTION;
  records_grid : IFRE_DB_DERIVED_COLLECTION;
  namesever_ch : IFRE_DB_DERIVED_COLLECTION;
  enum         : IFRE_DB_Enum;
  dns_customers: IFRE_DB_DERIVED_COLLECTION;
  multidomain  : Boolean;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('host','label');
      AddOneToOnescheme('type','type','',dt_string,false);
      AddOneToOnescheme('domainid','servicedomain','',dt_string,false);
    end;

    namesever_ch:= session.NewDerivedCollection('NAMESERVER_CHOOSER');
    with namesever_ch do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      Filters.AddStringFieldFilter('TYPE_FILTER','type','NS',dbft_EXACT);
    end;

    multidomain:=Length(conn.SYS.GetDomainsForClassRight(sr_FETCH,TFOS_DB_PROVIDER_NETWORK_DOMAIN))>1;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_network_domains_customer'),multidomain,dt_string,true,true,1,'',FetchModuleTextShort(session,'grid_customer_default_value'),nil,false,'domainid');
      AddOneToOnescheme('objname','name',FetchModuleTextShort(session,'grid_network_domains_name'),dt_string,true,true);
      AddOneToOnescheme('default','default','',dt_description);
      AddMatchingReferencedField('<NETWORK_DOMAIN_DEFAULT','value','default_value','',false);
      AddMatchingReferencedField('<NETWORK_DOMAIN_DEFAULT','ttl','default_ttl','',false);
      SetFinalRightTransformFunction(@CalculateDescription,[FetchModuleTextShort(session,'grid_network_domains_default_value'),FetchModuleTextShort(session,'grid_network_domains_default_ttl')]);
      AddFulltextFilterOnTransformed(['name']);
    end;
    domains_grid := session.NewDerivedCollection('GLOBAL_NETWORK_DOMAINS_GRID');
    with domains_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_NetworkDomainsMenu),nil,CWSF(@WEB_NetworkDomainsSC));
      SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('service',['TFOS_DB_PROVIDER_NETWORK_DOMAIN']);
    end;

    multidomain:=Length(conn.SYS.GetDomainsForClassRight(sr_FETCH,TFOS_DB_NETWORK_DOMAIN))>1;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_network_domains_customer'),multidomain,dt_string,true,true,1,'',FetchModuleTextShort(session,'grid_customer_default_value'),nil,false,'domainid');
      AddOneToOnescheme('objname','name',FetchModuleTextShort(session,'grid_network_domains_name'),dt_string,true,true);
      AddOneToOnescheme('default','default','',dt_description);
      AddMatchingReferencedField('<NETWORK_DOMAIN_DEFAULT','value','default_value','',false);
      AddMatchingReferencedField('<NETWORK_DOMAIN_DEFAULT','ttl','default_ttl','',false);
      SetFinalRightTransformFunction(@CalculateDescription,[FetchModuleTextShort(session,'grid_network_domains_default_value'),FetchModuleTextShort(session,'grid_network_domains_default_ttl')]);
      AddFulltextFilterOnTransformed(['name']);
    end;
    domains_grid := session.NewDerivedCollection('NETWORK_DOMAINS_GRID');
    with domains_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_NetworkDomainsMenu),nil,CWSF(@WEB_NetworkDomainsSC));
      SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('service',['TFOS_DB_NETWORK_DOMAIN']);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('host','host',FetchModuleTextShort(session,'grid_records_host'),dt_string,true,true);
      GFRE_DBI.GetSystemEnum('dns_resource_record_type',enum);
      AddOneToOnescheme('type','type',FetchModuleTextShort(session,'grid_records_type'),dt_string,true,true,true,true,1,'','','',enum.getCaptions(conn));
      AddOneToOnescheme('value','value',FetchModuleTextShort(session,'grid_records_value'),dt_string);
      AddOneToOnescheme('ttl','ttl',FetchModuleTextShort(session,'grid_records_ttl'),dt_number);
      AddOneToOnescheme('type','type_native','',dt_string,false);
      AddMatchingReferencedFieldArray(['NETWORK_DOMAIN>'],'uid','nd_uid','',false);
      AddFulltextFilterOnTransformed(['host','value']);
    end;

    records_grid := session.NewDerivedCollection('DNS_RECORDS_GRID');
    with records_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION));
      SetUseDependencyAsUidFilter('nd_uid',false,'uid');
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_ResourceRecordsMenu),nil,CWSF(@WEB_ResourceRecordsSC));
      SetDefaultOrderField('host',true);
      Filters.AddStringFieldFilter('TYPE_FILTER','type_native','NS',dbft_EXACT,false);
      Filters.AddStringFieldFilter('DEFAULT','host','@',dbft_EXACT,false);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'chooser_customer'),dt_string,true,true,false,true,3);
      AddOneToOnescheme('servicedomain','','',dt_string,false);
    end;

    dns_customers := session.NewDerivedCollection(CFOS_DB_DNS_CUSTOMERS_DCOLL);
    with dns_customers do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_CUSTOMERS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('host','host',FetchModuleTextShort(session,'grid_nameserver_records_host'),dt_string,true,true,false,true,1,'icon');
      AddOneToOnescheme('value','value',FetchModuleTextShort(session,'grid_nameserver_records_value'),dt_string);
      AddOneToOnescheme('ttl','ttl',FetchModuleTextShort(session,'grid_nameserver_records_ttl'),dt_number);
      AddOneToOnescheme('type','type','',dt_string,false);
      AddOneToOnescheme('icon','icon','',dt_string,false);
      AddOneToOnescheme('default','default','',dt_number,false);
      AddMatchingReferencedFieldArray(['<RECORDS'],'uid','nd_uid','',false);
      SetFinalRightTransformFunction(@CalculateNameserverGridFields,[]);
    end;

    multidomain:=Length(conn.SYS.GetDomainsForClassRight(sr_UPDATE,TFOS_DB_DNS_NAMESERVER_RECORD))>1;

    records_grid := session.NewDerivedCollection('GLOBAL_NAMESERVER_RECORDS_GRID');
    with records_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION));
      SetUseDependencyAsUidFilter('nd_uid');
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',CWSF(@WEB_NameserverMenu));
      SetDefaultOrderField('host',true);
      Filters.AddStringFieldFilter('TYPE_FILTER','type','NS',dbft_EXACT);
      Filters.AddSchemeObjectFilter('service',[TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD.ClassName]);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_nameserver_customer'),multidomain,dt_string,true,true,1,'',FetchModuleTextShort(session,'grid_customer_default_value'),nil,false,'domainid');
      AddOneToOnescheme('host','host',FetchModuleTextShort(session,'grid_nameserver_records_host'),dt_string,true,true,false,true,1,'icon');
      AddOneToOnescheme('value','value',FetchModuleTextShort(session,'grid_nameserver_records_value'),dt_string);
      AddOneToOnescheme('ttl','ttl',FetchModuleTextShort(session,'grid_nameserver_records_ttl'),dt_number);
      AddOneToOnescheme('type','type','',dt_string,false);
      AddOneToOnescheme('icon','icon','',dt_string,false);
      AddOneToOnescheme('default','default','',dt_number,false);
      AddMatchingReferencedFieldArray(['<RECORDS'],'uid','nd_uid','',false);
      SetFinalRightTransformFunction(@CalculateNameserverGridFields,[]);
    end;

    records_grid := session.NewDerivedCollection('NAMESERVER_RECORDS_GRID');
    with records_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION));
      SetUseDependencyAsUidFilter('nd_uid');
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',CWSF(@WEB_NameserverMenu));
      if multidomain then begin
        SetDefaultOrderField('customer',true);
      end else begin
        SetDefaultOrderField('host',true);
      end;
      Filters.AddStringFieldFilter('TYPE_FILTER','type','NS',dbft_EXACT);
      Filters.AddSchemeObjectFilter('service',[TFOS_DB_DNS_NAMESERVER_RECORD.ClassName]);
    end;

  end;
end;

procedure TFOS_FIRMBOX_DNS_MOD.CalculateDescription(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
var
  descr: String;
begin
  if transformed_object.field('default_value').AsString<>'' then begin
    descr:=StringReplace(langres[0],'%value%',transformed_object.Field('default_value').AsString,[rfReplaceAll]);
    if transformed_object.Field('default_ttl').AsString<>'' then begin
      descr:=descr + StringReplace(langres[1],'%ttl%',transformed_object.Field('default_ttl').AsString,[rfReplaceAll]);;
    end;
    transformed_object.Field('default').AsString:=descr;
  end;
end;

procedure TFOS_FIRMBOX_DNS_MOD.CalculateNameserverGridFields(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
begin
  if transformed_object.FieldExists('default') then begin
    if transformed_object.Field('default').AsInt16=1 then begin
      transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/firmbox_dns/nameserver_default_1.svg');
    end else begin
      transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/firmbox_dns/nameserver_default_2.svg');
    end;
  end else begin
    transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/firmbox_dns/nameserver.svg');
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.isEnabled(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
var
  domains,nameserver: Boolean;
begin
  _showGlobal(ses,conn,domains,nameserver);
  Result:=domains or nameserver;
  if not Result then begin
    _showLocal(ses,conn,domains,nameserver);
    Result:=domains or nameserver;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc,dc_records : IFRE_DB_DERIVED_COLLECTION;
  domains_grid  : TFRE_DB_VIEW_LIST_DESC;
  domain_content: TFRE_DB_SUBSECTIONS_DESC;

  subsecs       : TFRE_DB_SUBSECTIONS_DESC;
  sf            : TFRE_DB_SERVER_FUNC_DESC;
  count         : Integer;
  gD,gN,lD,lN   : Boolean;
begin
  CheckClassVisibility4AnyDomain(ses);

  _showGlobal(ses,conn,gD,gN);
  _showLocal(ses,conn,lD,lN);

  count:=0;
  if gD then begin
    count:=count+1;
  end;
  if gN then begin
    count:=count+1;
  end;
  if lD then begin
    count:=count+1;
  end;
  if lD then begin
    count:=count+1;
  end;

  if count=0 then begin
    Result:=TFRE_DB_HTML_DESC.create.Describe('');
    exit;
  end;

  subsecs:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  if gD then begin
    if count=1 then begin
      input.Field(CPARAM_GLOBAL).AsString:='true';
      Result:=WEB_DomainsContent(input,ses,app,conn);
      exit;
    end;
    sf:=CWSF(@WEB_DomainsContent);
    sf.AddParam.Describe(CPARAM_GLOBAL,'true');
    subsecs.AddSection.Describe(sf,FetchModuleTextShort(ses,'global_domains_section'),1);
  end;
  if lD then begin
    if count=1 then begin
      input.Field(CPARAM_GLOBAL).AsString:='false';
      Result:=WEB_DomainsContent(input,ses,app,conn);
      exit;
    end;
    sf:=CWSF(@WEB_DomainsContent);
    sf.AddParam.Describe(CPARAM_GLOBAL,'false');
    subsecs.AddSection.Describe(sf,FetchModuleTextShort(ses,'domains_section'),2);
  end;
  if gN then begin
    if count=1 then begin
      input.Field(CPARAM_GLOBAL).AsString:='true';
      Result:=WEB_NameserverContent(input,ses,app,conn);
      exit;
    end;
    sf:=CWSF(@WEB_NameserverContent);
    sf.AddParam.Describe(CPARAM_GLOBAL,'true');
    subsecs.AddSection.Describe(sf,FetchModuleTextShort(ses,'global_nameserver_section'),3);
  end;
  if lN then begin
    if count=1 then begin
      input.Field(CPARAM_GLOBAL).AsString:='false';
      Result:=WEB_NameserverContent(input,ses,app,conn);
      exit;
    end;
    sf:=CWSF(@WEB_NameserverContent);
    sf.AddParam.Describe(CPARAM_GLOBAL,'false');
    subsecs.AddSection.Describe(sf,FetchModuleTextShort(ses,'nameserver_section'),4);
  end;

  Result:=subsecs;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NameserverContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc_records             : IFRE_DB_DERIVED_COLLECTION;
  records_grid           : TFRE_DB_VIEW_LIST_DESC;
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  CheckClassVisibility4AnyDomain(ses);

  global:=input.Field(CPARAM_GLOBAL).AsString='true';
  _getClasses(global,ndClass,rrClass,nsClass);

  if global then begin
    dc_records:=ses.FetchDerivedCollection('GLOBAL_NAMESERVER_RECORDS_GRID');
  end else begin
    dc_records:=ses.FetchDerivedCollection('NAMESERVER_RECORDS_GRID');
  end;

  records_grid:=dc_records.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4MyDomain(sr_STORE,nsClass) then begin
    sf:=CWSF(@WEB_AddNameserver);
    sf.AddParam.Describe(CPARAM_GLOBAL,input.Field(CPARAM_GLOBAL).AsString);
    records_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_create_nameserver'),FetchModuleTextHint(ses,'tb_create_nameserver'));
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,nsClass) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_NameserverDelete),'',FetchModuleTextShort(ses,'tb_delete_nameserver'),FetchModuleTextHint(ses,'tb_delete_nameserver'),fdgbd_single);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,nsClass) then begin
    records_grid.AddButton.Describe(CWSF(@WEB_ModifyNameserver),'',FetchModuleTextShort(ses,'tb_modify_nameserver'),FetchModuleTextHint(ses,'tb_modify_nameserver'),fdgbd_single);
    sf:=CWSF(@WEB_SetAsDefault);
    sf.AddParam.Describe('default','1');
    records_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_set_as_default_1'),FetchModuleTextHint(ses,'tb_set_as_default_1'),fdgbd_single);
    sf:=CWSF(@WEB_SetAsDefault);
    sf.AddParam.Describe('default','2');
    records_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_set_as_default_2'),FetchModuleTextHint(ses,'tb_set_as_default_2'),fdgbd_single);
  end;

  Result:=records_grid;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NameserverMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res                    : TFRE_DB_MENU_DESC;
  func                   : TFRE_DB_SERVER_FUNC_DESC;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  dbo                    : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

  global:=dbo.Implementor_HC is TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
  _getClasses(global,ndClass,rrClass,nsClass);

  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,nsClass) then begin
    func:=CWSF(@WEB_NameserverDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_nameserver'),'',func);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,nsClass) then begin
    func:=CWSF(@WEB_ModifyNameserver);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_nameserver'),'',func);
    func:=CWSF(@WEB_SetAsDefault);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    func.AddParam.Describe('default','1');
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_set_as_default_1'),'',func);
    func:=CWSF(@WEB_SetAsDefault);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    func.AddParam.Describe('default','2');
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_set_as_default_2'),'',func);
  end;
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_AddNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyNameserver(input,ses,app,conn,false);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ModifyNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyNameserver(input,ses,app,conn,true);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_StoreNameserver(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject           : IFRE_DB_SchemeObject;
  nameserverObj          : TFOS_DB_DNS_NAMESERVER_RECORD;
  isNew                  : Boolean;
  resourceColl           : IFRE_DB_COLLECTION;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  global                 : Boolean;
  dbo                    : IFRE_DB_Object;
  customer               : IFRE_DB_Object;
begin
  if input.FieldExists('rrecordId') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('rrecordId').AsString),dbo));
    nameserverObj:=dbo.Implementor_HC as TFOS_DB_DNS_NAMESERVER_RECORD;

    global:=dbo.Implementor_HC is TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
    _getClasses(global,ndClass,rrClass,nsClass);

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,nsClass,nameserverObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    global:=input.Field(CPARAM_GLOBAL).AsString='true';
    _getClasses(global,ndClass,rrClass,nsClass);

    resourceColl:=conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION);
    nameserverObj:= nsClass.CreateForDB as TFOS_DB_DNS_NAMESERVER_RECORD;

    if global then begin
      if not conn.sys.CheckClassRight4MyDomain(sr_STORE,nsClass) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    end else begin
      if input.FieldExists(CPARAM_DOMAINID) then begin
        nameserverObj.SetDomainID(FREDB_H2G(input.Field(CPARAM_DOMAINID).AsString));
      end else begin
        if input.FieldPathExists('data.customer') then begin
          CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('data.customer').AsString),customer));
          if not conn.sys.CheckClassRight4DomainId(sr_STORE,nsClass,customer.DomainID) then
            raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
          if not customer.FieldExists('servicedomain') then
            raise EFRE_DB_Exception.Create(edb_ERROR,'The given customer has no service domain set!');
          input.Field('data').AsObject.DeleteField('customer');
          nameserverObj.SetDomainID(customer.Field('servicedomain').AsObjectLink);
        end else begin
          raise EFRE_DB_Exception.Create('Input parameter customer missing!');
        end;
      end;
    end;

    nameserverObj.Field('uniquephysicalid').AsString:=input.FieldPath('data.host').AsString+'@'+FREDB_G2H(nameserverObj.DomainID) + BoolToStr(global,'_GLOBAL','');
    nameserverObj.ObjectName:=input.FieldPath('data.host').AsString;
    nameserverObj.Field('type').AsString:='NS';
    isNew:=true;
  end;
  if not GFRE_DBI.GetSystemScheme(nsClass,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[nsClass.ClassName]);

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,nameserverObj,isNew,conn);

  if isNew then begin
    CheckDbResult(resourceColl.Store(nameserverObj));
  end else begin
    CheckDbResult(conn.Update(nameserverObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NameserverDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg                : String;
  rrecord                : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),rrecord));
  global:=rrecord.Implementor_HC is TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
  _getClasses(global,ndClass,rrClass,nsClass);

  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,nsClass) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_NameserverDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'nameserver_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'nameserver_delete_diag_msg'),'%rr_str%',rrecord.Field('host').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NameserverDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i                      : NativeInt;
  rrecord                : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),rrecord));

      global:=rrecord.Implementor_HC is TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
      _getClasses(global,ndClass,rrClass,nsClass);

      if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,nsClass) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(rrecord.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_SetAsDefault(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  nsObj,dbo              : IFRE_DB_Object;
  nsObjUID               : TFRE_DB_GUID;
  obj                    : IFRE_DB_Object;
  configObj              : TFRE_DB_APPLICATION_CONFIG;
  isNew                  : Boolean;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  cfgPreFix              : String;
begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),nsObj));

  global:=nsObj.Implementor_HC is TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD;
  _getClasses(global,ndClass,rrClass,nsClass);
  cfgPreFix:='default_';
  if global then begin
    cfgPreFix:=cfgPreFix+'global_';
  end;

  if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,nsClass,nsObj.DomainID) and conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_APPLICATION_CONFIG,nsObj.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if conn.AdmGetApplicationConfigCollection.GetIndexedObj('TFOS_FIRMBOX_DNS_MOD@'+FREDB_G2H(nsObj.DomainID),obj) then begin
    isNew:=false;
    configObj:=obj.Implementor_HC as TFRE_DB_APPLICATION_CONFIG;
  end else begin
    isNew:=true;
    configObj:=TFRE_DB_APPLICATION_CONFIG.CreateForDB;
    configObj.SetDomainID(nsObj.DomainID);
    configObj.Field('id').AsString:='TFOS_FIRMBOX_DNS_MOD@'+FREDB_G2H(nsObj.DomainID);
  end;
  if configObj.FieldExists(cfgPreFix+input.Field('default').AsString) then begin //REMOVE OLD DEFAULT OBJ SET FOR THE GIVEN SLOT
    CheckDbResult(conn.Fetch(configObj.Field(cfgPreFix+input.Field('default').AsString).AsGUID,dbo));
    dbo.DeleteField('default');
    CheckDbResult(conn.Update(dbo));
  end;
  if nsObj.FieldExists('default') then begin //REMOVE NEW OBJ FROM CONFIG IF ALREADY USED AS (A DIFFRENT) DEFAULT
    configObj.DeleteField(cfgPreFix+IntToStr(nsObj.Field('default').AsInt16));
  end;
  nsObj.Field('default').AsInt16:=FREDB_String2NativeInt(input.Field('default').AsString);
  CheckDbResult(conn.Update(nsObj.CloneToNewObject()));
  configObj.Field(cfgPreFix+input.Field('default').AsString).AsGUID:=nsObj.UID;
  if isNew then begin
    CheckDbResult(conn.AdmGetApplicationConfigCollection.Store(configObj));
  end else begin
    CheckDbResult(conn.Update(configObj));
  end;
  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_DomainsContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc,dc_records          : IFRE_DB_DERIVED_COLLECTION;
  domains_grid           : TFRE_DB_VIEW_LIST_DESC;
  domain_content         : TFRE_DB_SUBSECTIONS_DESC;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  global                 : Boolean;
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  global:=input.Field(CPARAM_GLOBAL).AsString='true';
  _getClasses(global,ndClass,rrClass,nsClass);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedDomain');
  if global then begin
    dc:=ses.FetchDerivedCollection('GLOBAL_NETWORK_DOMAINS_GRID');
  end else begin
    dc:=ses.FetchDerivedCollection('NETWORK_DOMAINS_GRID');
  end;

  domains_grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,ndClass) and conn.sys.CheckClassRight4AnyDomain(sr_STORE,rrClass) then begin
    sf:=CWSF(@WEB_AddNetworkDomain);
    sf.AddParam.Describe(CPARAM_GLOBAL,input.Field(CPARAM_GLOBAL).AsString);
    domains_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_create_network_domain'),FetchModuleTextHint(ses,'tb_create_network_domain'));
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,ndClass) and conn.sys.CheckClassRight4AnyDomain(sr_DELETE,rrClass) then begin
    domains_grid.AddButton.DescribeManualType('del_network_domain',CWSF(@WEB_NetworkDomainDelete),'',FetchModuleTextShort(ses,'tb_delete_network_domain'),FetchModuleTextHint(ses,'tb_delete_network_domain'),true);
  end;

  dc_records:=ses.FetchDerivedCollection('DNS_RECORDS_GRID');
  domains_grid.AddFilterEvent(dc_records.getDescriptionStoreId(),'uid');

  domain_content:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  domain_content.AddSection.Describe(CWSF(@WEB_DomainDetailsContent),FetchModuleTextShort(ses,'network_domain_content_section_details'),1);
  sf:=CWSF(@WEB_DomainRecordsContent);
  sf.AddParam.Describe(CPARAM_GLOBAL,input.Field(CPARAM_GLOBAL).AsString);
  domain_content.AddSection.Describe(sf,FetchModuleTextShort(ses,'network_domain_content_section_records'),2);

  Result:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(domains_grid,domain_content,nil,nil,nil,true,1,1);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_DomainDetailsContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme,rr_scheme        : IFRE_DB_SchemeObject;
  res                     : TFRE_DB_CONTENT_DESC;
  form                    : TFRE_DB_FORM_PANEL_DESC;
  editable                : Boolean;
  nw_domain               : IFRE_DB_Object;
  defaultG                : TFRE_DB_INPUT_GROUP_DESC;
  rrecord                 : IFRE_DB_Object;
  sf                      : TFRE_DB_SERVER_FUNC_DESC;
  store                   : TFRE_DB_STORE_DESC;
  domain_def              : TFRE_DB_GUIDArray;
  global                  : Boolean;
  ndClass,rrClass,nsClass : TFRE_DB_ObjectClassEx;
  nameserver_dc           : IFRE_DB_DERIVED_COLLECTION;
begin
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedDomain') and (ses.GetSessionModuleData(ClassName).Field('selectedDomain').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedDomain').AsStringItem[0]),nw_domain));

    global:=nw_domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
    _getClasses(global,ndClass,rrClass,nsClass);

    if not (conn.sys.CheckClassRight4DomainId(sr_FETCH,ndClass,nw_domain.DomainID) and conn.sys.CheckClassRight4DomainId(sr_FETCH,rrClass,nw_domain.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    GetSystemScheme(ndClass,scheme);
    GetSystemScheme(rrClass,rr_scheme);
    editable:=(conn.sys.CheckClassRight4DomainId(sr_UPDATE,ndClass,nw_domain.DomainID) and
               conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,nw_domain.DomainID) and
               conn.sys.CheckClassRight4DomainId(sr_UPDATE,rrClass,nw_domain.DomainID) and
               conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,nw_domain.DomainID));
    form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,editable);
    form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'domain');

    nameserver_dc:=ses.FetchDerivedCollection('NAMESERVER_CHOOSER');
    nameserver_dc.Filters.RemoveFilter('service_type');
    nameserver_dc.Filters.RemoveFilter('service_domain');
    if global then begin
      nameserver_dc.Filters.AddSchemeObjectFilter('service_type',['TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD']);
    end else begin
      nameserver_dc.Filters.AddSchemeObjectFilter('service_type',['TFOS_DB_DNS_NAMESERVER_RECORD']);
      nameserver_dc.Filters.AddStringFieldFilter('service_domain','servicedomain',FREDB_G2H(nw_domain.DomainID),dbft_EXACT);
    end;
    store:=nameserver_dc.GetStoreDescription as TFRE_DB_STORE_DESC;

    form.AddChooser.Describe(FetchModuleTextShort(ses,'network_domain_edit_dns1'),'domain.dns1',store,dh_chooser_combo,true,false,true);
    form.AddChooser.Describe(FetchModuleTextShort(ses,'network_domain_edit_dns2'),'domain.dns2',store);

    form.FillWithObjectValues(nw_domain,ses,'domain');

    form.AddSchemeFormGroup(rr_scheme.GetInputGroup('main_default'),ses,false,false,'default',false);

    domain_def:=conn.GetReferences(nw_domain.UID,false,rrClass.ClassName,'network_domain_default');
    if Length(domain_def)>0 then begin
      CheckDbResult(conn.Fetch(domain_def[0],rrecord));
      form.FillWithObjectValues(rrecord,ses,'default');
    end;

    if editable then begin
      sf:=CWSF(@WEB_UpdateNetworkDomain);
      sf.AddParam.Describe('nwDomainId',nw_domain.UID_String);
      form.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
    end;
    res:=form;
  end else begin
    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_domain_details_select_one'));
  end;
  res.contentId:='NW_DOMAIN_DETAILS';
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_DomainRecordsContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc_records             : IFRE_DB_DERIVED_COLLECTION;
  records_grid           : TFRE_DB_VIEW_LIST_DESC;
  add_enabled            : Boolean;
  nw_domain              : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  CheckClassVisibility4AnyDomain(ses);

  global:=input.Field(CPARAM_GLOBAL).AsString='true';
  _getClasses(global,ndClass,rrClass,nsClass);

  dc_records:=ses.FetchDerivedCollection('DNS_RECORDS_GRID');
  records_grid:=dc_records.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  add_enabled:=ses.GetSessionModuleData(ClassName).FieldExists('selectedDomain') and (ses.GetSessionModuleData(ClassName).Field('selectedDomain').ValueCount=1);
  if add_enabled then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedDomain').AsString),nw_domain));
    add_enabled:=add_enabled and conn.sys.CheckClassRight4DomainId(sr_UPDATE,ndClass,nw_domain.DomainID) and  conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,nw_domain.DomainID);
  end;

  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,rrClass) then begin
    records_grid.AddButton.DescribeManualType('add_record',CWSF(@WEB_AddResourceRecord),'',FetchModuleTextShort(ses,'tb_create_resource_record'),FetchModuleTextHint(ses,'tb_create_resource_record'),not add_enabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,rrClass) then begin
    records_grid.AddButton.DescribeManualType('del_record',CWSF(@WEB_ResourceRecordDelete),'',FetchModuleTextShort(ses,'tb_delete_resource_record'),FetchModuleTextHint(ses,'tb_delete_resource_record'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,rrClass) then begin
    records_grid.AddButton.DescribeManualType('mod_record',CWSF(@WEB_ModifyResourceRecord),'',FetchModuleTextShort(ses,'tb_modify_resource_record'),FetchModuleTextHint(ses,'tb_modify_resource_record'),true);
  end;

  Result:=records_grid;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainsMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res                    : TFRE_DB_MENU_DESC;
  func                   : TFRE_DB_SERVER_FUNC_DESC;
  nw_domain              : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),nw_domain));
  global:=nw_domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
  _getClasses(global,ndClass,rrClass,nsClass);

  if conn.sys.CheckClassRight4DomainId(sr_DELETE,ndClass,nw_domain.DomainID) and conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,nw_domain.DomainID) then begin
    func:=CWSF(@WEB_NetworkDomainDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_network_domain'),'',func);
  end;
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainsSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  add_disabled           : Boolean;
  nw_domain              : IFRE_DB_Object;
  del_disabled           : Boolean;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  CheckClassVisibility4AnyDomain(ses);

  add_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedDomain').AsStringArr:=input.Field('selected').AsStringArr;
    if input.Field('selected').ValueCount=1 then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),nw_domain));
      global:=nw_domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
      _getClasses(global,ndClass,rrClass,nsClass);

      if conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,nw_domain.DomainID) then begin
        add_disabled:=false;
      end;
      if conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,nw_domain.DomainID) then begin
        del_disabled:=false;
      end;
    end;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedDomain');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_record',add_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('del_network_domain',del_disabled));
  if ses.isUpdatableContentVisible('NW_DOMAIN_DETAILS') then begin
    Result:=WEB_DomainDetailsContent(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_AddNetworkDomain(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  customer_dc            : IFRE_DB_DERIVED_COLLECTION;
  customer               : IFRE_DB_Object;
  store                  : TFRE_DB_STORE_DESC;
  res                    : TFRE_DB_FORM_DIALOG_DESC;
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
begin
  ses.GetSessionModuleData(ClassName).DeleteField('selectedCustomerAND');

  customer_dc:=ses.FetchDerivedCollection(CFOS_DB_DNS_CUSTOMERS_DCOLL);
  customer_dc.Filters.RemoveFilter('rights');

  if input.Field(CPARAM_GLOBAL).AsString='true' then begin
    customer_dc.Filters.AddStdClassRightFilter('rights','servicedomain','','','TFOS_DB_PROVIDER_NETWORK_DOMAIN',[sr_STORE],conn.SYS.GetCurrentUserTokenClone);
    Result:=WEB_AddNetworkDomainDetails(input,ses,app,conn);
    exit;
  end;
  customer_dc.Filters.AddStdClassRightFilter('rights','servicedomain','','','TFOS_DB_NETWORK_DOMAIN',[sr_STORE],conn.SYS.GetCurrentUserTokenClone);

  if (customer_dc.ItemCount=0) then begin
    Result:=WEB_AddNetworkDomainDetails(input,ses,app,conn);
    exit;
  end;
  if (customer_dc.ItemCount=1) then begin
    customer:=customer_dc.First;
    ses.GetSessionModuleData(ClassName).Field('selectedCustomerAND').AsGUID:=customer.UID;
    Result:=WEB_AddNetworkDomainDetails(input,ses,app,conn);
    exit;
  end;

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'network_domain_create_diag_cap'),600,true,true,false);
  store:=customer_dc.GetStoreDescription as TFRE_DB_STORE_DESC;
  res.AddChooser.Describe(FetchModuleTextShort(ses,'network_domain_create_customer'),'customer',store,dh_chooser_combo,true,false,true);
  sf:=CWSF(@WEB_AddNetworkDomainDetails);
  sf.AddParam.Describe(CPARAM_GLOBAL,input.Field(CPARAM_GLOBAL).AsString);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FetchModuleTextShort(ses,'button_select_customer')),sf,fdbbt_submit);

  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_AddNetworkDomainDetails(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme,rr_scheme       : IFRE_DB_SchemeObject;
  res                    : TFRE_DB_FORM_DIALOG_DESC;
  store                  : TFRE_DB_STORE_DESC;
  obj                    : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  nameserver_dc          : IFRE_DB_DERIVED_COLLECTION;
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  cfgPreFix              : String;
  customer_dc            : IFRE_DB_DERIVED_COLLECTION;
  customer               : IFRE_DB_Object;
  customer_uid           : TFRE_DB_GUID;
  dID                    : TFRE_DB_GUID_String;
  multidomain            : Boolean;
begin
  global:=input.Field(CPARAM_GLOBAL).AsString='true';
  _getClasses(global,ndClass,rrClass,nsClass);

  if not (conn.sys.CheckClassRight4AnyDomain(sr_STORE,ndClass) and conn.sys.CheckClassRight4AnyDomain(sr_STORE,rrClass)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  customer_dc:=ses.FetchDerivedCollection(CFOS_DB_DNS_CUSTOMERS_DCOLL);

  GetSystemScheme(ndClass,scheme);
  GetSystemScheme(rrClass,rr_scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'network_domain_create_diag_cap'),600,true,true,false);

  multidomain:=global or (Length(conn.SYS.GetDomainsForClassRight(sr_FETCH,ndClass))>1);

  if multidomain then begin
    res.AddSchemeFormGroup(scheme.GetInputGroup('main_customer'),ses,false,false,'domain');
  end else begin
    res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'domain');
  end;

  nameserver_dc:=ses.FetchDerivedCollection('NAMESERVER_CHOOSER');
  nameserver_dc.Filters.RemoveFilter('service_type');
  nameserver_dc.Filters.RemoveFilter('service_domain');
  store:=nameserver_dc.GetStoreDescription as TFRE_DB_STORE_DESC;

  res.AddChooser.Describe(FetchModuleTextShort(ses,'network_domain_create_dns1'),'domain.dns1',store,dh_chooser_combo,true,false,true);
  res.AddChooser.Describe(FetchModuleTextShort(ses,'network_domain_create_dns2'),'domain.dns2',store);

  sf:=CWSF(@WEB_CreateNetworkDomain);
  sf.AddParam.Describe(CPARAM_GLOBAL,input.Field(CPARAM_GLOBAL).AsString);
  if global then begin
    cfgPreFix:='default_global_';
    dID:=ses.GetDomainUID_String;
    nameserver_dc.Filters.AddSchemeObjectFilter('service_type',['TFOS_DB_PROVIDER_DNS_NAMESERVER_RECORD']);
  end else begin
    cfgPreFix:='default_';
    if ses.GetSessionModuleData(ClassName).FieldExists('selectedCustomerAND') then begin
      CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedCustomerAND').AsGUID,customer));
    end else begin
      if input.FieldPathExists('data.customer') then begin
        CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('data.customer').AsString),customer));
      end else begin
        raise EFRE_DB_Exception.Create('No servicedomain found!');
      end;
    end;
    if multidomain then begin
      res.SetElementValue('domain.customer',customer.UID_String);
      res.SetElementDisabled('domain.customer');
    end;

    sf.AddParam.Describe('customer',customer.UID_String);

    dID:=FREDB_G2H(customer.Field('servicedomain').AsObjectLink);
    nameserver_dc.Filters.AddSchemeObjectFilter('service_type',['TFOS_DB_DNS_NAMESERVER_RECORD']);
    nameserver_dc.Filters.AddStringFieldFilter('service_domain','servicedomain',FREDB_G2H(customer.Field('servicedomain').AsObjectLink),dbft_EXACT);
  end;
  if conn.AdmGetApplicationConfigCollection.GetIndexedObj('TFOS_FIRMBOX_DNS_MOD@'+dID,obj) then begin
    if obj.FieldExists(cfgPreFix+'1') then begin
      res.SetElementValue('domain.dns1',obj.Field(cfgPreFix+'1').AsString);
    end;
    if obj.FieldExists(cfgPreFix+'2') then begin
      res.SetElementValue('domain.dns2',obj.Field(cfgPreFix+'2').AsString);
    end;
  end;

  res.AddSchemeFormGroup(rr_scheme.GetInputGroup('main_default'),ses,false,false,'default',false);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_CreateNetworkDomain(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  domain                 : TFOS_DB_NETWORK_DOMAIN;
  resource               : TFOS_DB_DNS_RESOURCE_RECORD;
  schemeObject           : IFRE_DB_SchemeObject;
  schemeObjectRR         : IFRE_DB_SchemeObject;
  serviceColl            : IFRE_DB_COLLECTION;
  resourceColl           : IFRE_DB_COLLECTION;
  idx                    : String;
  customer               : IFRE_DB_Object;
  sdomain                : TFRE_DB_GUID;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if not input.FieldPathExists('data.domain') then raise EFRE_DB_Exception.Create('Missing input data: network domain');
  if not input.FieldPathExists('data.domain.objname') then raise EFRE_DB_Exception.Create('Missing required input data: network domain name');
  if not input.FieldPathExists('data.domain.dns1') then raise EFRE_DB_Exception.Create('Missing input data: dns1');

  global:=input.Field(CPARAM_GLOBAL).AsString='true';
  _getClasses(global,ndClass,rrClass,nsClass);

  if input.FieldExists('customer') then begin
    input.FieldPathCreate('data.domain.customer').AsString:=input.Field('customer').AsString;
  end;
  if input.FieldPathExists('data.domain.customer') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('data.domain.customer').AsString),customer));
    if not customer.FieldExists('servicedomain') then
      raise EFRE_DB_Exception.Create(edb_ERROR,'The given customer has no service domain set!');

    input.FieldPath('data.domain').AsObject.DeleteField('customer');
    sdomain:=customer.Field('servicedomain').AsObjectLink;
  end else begin
    raise EFRE_DB_Exception.Create(edb_ERROR,'No domain Id given for new DNS Service');
  end;

  if not (conn.sys.CheckClassRight4DomainId(sr_STORE,ndClass,sdomain) and conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,sdomain)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not GFRE_DBI.GetSystemScheme(ndClass,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[ndClass.ClassName]);

  serviceColl:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  resourceColl:=conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION);

  idx:='DNS_'+input.FieldPath('data.domain.objname').AsString + '@' + FREDB_G2H(sdomain) + BoolToStr(global,'_GLOBAL','');
  if serviceColl.ExistsIndexed(idx) then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'network_domain_create_error_exists_cap'),FetchModuleTextShort(ses,'network_domain_create_error_exists_msg'),fdbmt_error);
    exit;
  end;

  domain:=ndClass.CreateForDB as TFOS_DB_NETWORK_DOMAIN;
  schemeObject.SetObjectFieldsWithScheme(input.FieldPath('data.domain').AsObject,domain,true,conn);
  domain.Field('uniquephysicalid').AsString:=idx;
  domain.SetDomainID(sdomain);

  if not GFRE_DBI.GetSystemScheme(rrClass,schemeObjectRR) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[rrClass.ClassName]);

  CheckDbResult(serviceColl.Store(domain.CloneToNewObject()));
  if input.FieldPathExists('data.default.value') then begin
    resource:=rrClass.CreateForDB as TFOS_DB_DNS_RESOURCE_RECORD;
    resource.SetDomainID(domain.DomainID);
    input.FieldPath('data.default').AsObject.Field('type').AsString:='A';
    input.FieldPath('data.default').AsObject.Field('host').AsString:='@';
    schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.default').AsObject,resource,true,conn);
    resource.Field('network_domain').AsObjectLink:=domain.UID;
    resource.Field('network_domain_default').AsObjectLink:=domain.UID;
    resource.Field('uniquephysicalid').AsString:='@' + domain.Field('uniquephysicalid').AsString;
    CheckDbResult(resourceColl.Store(resource));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_UpdateNetworkDomain(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  resource               : TFOS_DB_DNS_RESOURCE_RECORD;
  schemeObject           : IFRE_DB_SchemeObject;
  schemeObjectRR         : IFRE_DB_SchemeObject;
  resourceColl           : IFRE_DB_COLLECTION;
  nw_domain              : IFRE_DB_Object;
  resourceDBO            : IFRE_DB_Object;
  defaultUID             : TFRE_DB_GUID;
  domain_def             : TFRE_DB_GUIDArray;
  i                      : Integer;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  dbo                    : IFRE_DB_Object;
  isNew                  : Boolean;
begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('nwDomainId').AsString),nw_domain));
  global:=nw_domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
  _getClasses(global,ndClass,rrClass,nsClass);

  if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,ndClass,nw_domain.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,nw_domain.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_UPDATE,rrClass,nw_domain.DomainID) and
          conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,nw_domain.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));


  if not GFRE_DBI.GetSystemScheme(ndClass,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[ndClass.ClassName]);

  if not GFRE_DBI.GetSystemScheme(rrClass,schemeObjectRR) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[rrClass.ClassName]);

  resourceColl:=conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION);

  if input.FieldPathExists('data.domain') then begin
    schemeObject.SetObjectFieldsWithScheme(input.FieldPath('data.domain').AsObject,nw_domain,false,conn);
  end;

  if input.FieldPathExists('data.default') then begin
    domain_def:=conn.GetReferences(nw_domain.UID,false,rrClass.ClassName,'network_domain_default');

    if input.FieldPathExists('data.default.value') and (input.FieldPath('data.default.value').AsString=cFRE_DB_SYS_CLEAR_VAL_STR) then begin //delete default
      for i := 0 to Length(domain_def) - 1 do begin
        CheckDbResult(conn.Delete(domain_def[i]));
      end;
    end else begin
      if Length(domain_def)>0 then begin
        isNew:=false;
        CheckDbResult(conn.Fetch(domain_def[0],dbo));
        resource:=dbo.Implementor_HC as TFOS_DB_DNS_RESOURCE_RECORD;
      end else begin
        isNew:=true;
        resource:=rrClass.CreateForDB as TFOS_DB_DNS_RESOURCE_RECORD;
        resource.SetDomainID(nw_domain.DomainID);
        resource.Field('network_domain').AsObjectLink:=nw_domain.UID;
        resource.Field('network_domain_default').AsObjectLink:=nw_domain.UID;
        resource.Field('uniquephysicalid').AsString:='@' + nw_domain.Field('uniquephysicalid').AsString;
        input.FieldPath('data.default').AsObject.Field('type').AsString:='A';
        input.FieldPath('data.default').AsObject.Field('host').AsString:='@';
      end;
      schemeObjectRR.SetObjectFieldsWithScheme(input.FieldPath('data.default').AsObject,resource,isNew,conn);
      if isNew then begin
        CheckDbResult(resourceColl.Store(resource));
      end else begin
        CheckDbResult(resourceColl.Update(resource));
      end;
    end;
  end;

  CheckDbResult(conn.Update(nw_domain));

  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg                : String;
  domain                 : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),domain));
  global:=domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
  _getClasses(global,ndClass,rrClass,nsClass);

  if not (conn.sys.CheckClassRight4DomainId(sr_DELETE,ndClass,domain.DomainID) and conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,domain.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_NetworkDomainDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'network_domain_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'network_domain_delete_diag_msg'),'%nw_domain_str%',domain.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_NetworkDomainDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i,j                    : NativeInt;
  nwDomainId             : TFRE_DB_GUID;
  domain                 : IFRE_DB_Object;
  refs                   : TFRE_DB_GUIDArray;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      nwDomainId:=FREDB_H2G(input.Field('selected').AsStringArr[i]);
      CheckDbResult(conn.Fetch(nwDomainId,domain));
      global:=domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
      _getClasses(global,ndClass,rrClass,nsClass);

      if not (conn.sys.CheckClassRight4DomainId(sr_DELETE,ndClass,domain.DomainID) and conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,domain.DomainID)) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      refs:=conn.GetReferences(domain.UID,false,rrClass.ClassName,'network_domain');
      for j := 0 to High(refs) do begin
        CheckDbResult(conn.Delete(refs[j]));
      end;
      CheckDbResult(conn.Delete(nwDomainId));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_AddResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not (input.FieldPathExists('dependency.uid_ref.filtervalues') and (input.FieldPath('dependency.uid_ref.filtervalues').ValueCount=1)) then
    raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'Error: Network Domain Id is missing.'));

  Result:=_AddModifyResourceRecord(input,ses,app,conn,false);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ModifyResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_AddModifyResourceRecord(input,ses,app,conn,true);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_StoreResourceRecord(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  domain                 : IFRE_DB_Object;
  resource               : TFOS_DB_DNS_RESOURCE_RECORD;
  schemeObject           : IFRE_DB_SchemeObject;
  resourceColl           : IFRE_DB_COLLECTION;
  isNew                  : Boolean;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
  dbo                    : IFRE_DB_Object;
begin
  if not (input.FieldExists('networkDomainId') or input.FieldExists('rrecordId')) then
    raise EFRE_DB_Exception.Create('Error: Network Domain Id or Resource Record Id has to be passed to WEB_StoreResourceRecord.');

  if input.FieldPathExists('data.host') and (input.FieldPath('data.host').AsString='@') then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'error_host_name_at_caption'),FetchModuleTextShort(ses,'error_host_name_at_msg'),fdbmt_error);
    exit;
  end;

  if input.FieldExists('rrecordId') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('rrecordId').AsString),dbo));

    global:=dbo.Implementor_HC is TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
    _getClasses(global,ndClass,rrClass,nsClass);
    resource:=dbo.Implementor_HC as TFOS_DB_DNS_RESOURCE_RECORD;

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,rrClass,resource.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('networkDomainId').AsString),domain));

    global:=domain.Implementor_HC is TFOS_DB_PROVIDER_NETWORK_DOMAIN;
    _getClasses(global,ndClass,rrClass,nsClass);

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,rrClass,domain.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    resourceColl:=conn.GetCollection(CFOS_DB_DNS_RECORDS_COLLECTION);
    resource:=rrClass.CreateForDB as TFOS_DB_DNS_RESOURCE_RECORD;
    resource.SetDomainID(domain.DomainID);
    resource.Field('network_domain').AsObjectLink:=domain.UID;
    resource.Field('uniquephysicalid').AsString:=input.FieldPath('data.host').AsString + '@' + domain.Field('uniquephysicalid').AsString;
    isNew:=true;
  end;

  if not GFRE_DBI.GetSystemScheme(rrClass,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[rrClass.ClassName]);
  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,resource,isNew,conn);

  if isNew then begin
    CheckDbResult(resourceColl.Store(resource));
  end else begin
    CheckDbResult(conn.Update(resource));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf                     : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg                : String;
  rrecord                : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),rrecord));

  global:=rrecord.Implementor_HC is TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
  _getClasses(global,ndClass,rrClass,nsClass);

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,rrecord.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_ResourceRecordDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'resource_record_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'resource_record_delete_diag_msg'),'%rr_str%',rrecord.Field('host').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i                      : NativeInt;
  rrecord                : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),rrecord));

      global:=rrecord.Implementor_HC is TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
      _getClasses(global,ndClass,rrClass,nsClass);

      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,rrecord.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(rrecord.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordsMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res                    : TFRE_DB_MENU_DESC;
  func                   : TFRE_DB_SERVER_FUNC_DESC;
  rrecord                : IFRE_DB_Object;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),rrecord));

  global:=rrecord.Implementor_HC is TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
  _getClasses(global,ndClass,rrClass,nsClass);

  if conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,rrecord.DomainID) then begin
    func:=CWSF(@WEB_ResourceRecordDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_resource_record'),'',func);
  end;
  if conn.sys.CheckClassRight4DomainId(sr_UPDATE,rrClass,rrecord.DomainID) then begin
    func:=CWSF(@WEB_ModifyResourceRecord);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_resource_record'),'',func);
  end;
  Result:=res;
end;

function TFOS_FIRMBOX_DNS_MOD.WEB_ResourceRecordsSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  mod_disabled           : Boolean;
  rrecord                : IFRE_DB_Object;
  del_disabled           : Boolean;
  global                 : Boolean;
  ndClass,rrClass,nsClass: TFRE_DB_ObjectClassEx;
begin
  CheckClassVisibility4AnyDomain(ses);

  mod_disabled:=true;
  del_disabled:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    if input.Field('selected').ValueCount=1 then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),rrecord));

      global:=rrecord.Implementor_HC is TFOS_DB_PROVIDER_DNS_RESOURCE_RECORD;
      _getClasses(global,ndClass,rrClass,nsClass);

      if conn.sys.CheckClassRight4DomainId(sr_UPDATE,rrClass,rrecord.DomainID) then begin
        mod_disabled:=false;
      end;
      if conn.sys.CheckClassRight4DomainId(sr_DELETE,rrClass,rrecord.DomainID) then begin
        del_disabled:=false;
      end;
    end;
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('mod_record',mod_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('del_record',del_disabled));
  Result:=GFRE_DB_NIL_DESC;
end;

end.

