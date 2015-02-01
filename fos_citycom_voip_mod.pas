unit fos_citycom_voip_mod;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH

  Licence conditions     
(§LIC_END)
}

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  fre_system,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,fre_hal_schemes,
  fre_dbbusiness;

const

  CFOS_DB_VOIP_PHONEBOOK_COLLECTION    = 'voip_phonebook';
  CFOS_DB_VOIP_EXTENSIONS_COLLECTION   = 'voip_extensions';
  CFOS_DB_VOIP_HARDWARE_COLLECTION     = 'voip_hardware';
  CFOS_DB_VOIP_EXT_EXP_REL_COLLECTION  = 'voip_ext_exp_rel';

  CFOS_DB_VOIP_TELEPHONE_DCOLL         = 'voip_telephone_chooser';

  CFOS_VOIP_INT_PREFIX                 = 43;

type

  { TFOS_CITYCOM_VOIP_PHONEBOOK_MOD }

  TFOS_CITYCOM_VOIP_PHONEBOOK_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain         (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    class procedure InstallUserDBObjects4SysDomain      (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    function        _addModifyEntry                     (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean):IFRE_DB_Object;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddEntry                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_EntryDelete                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_EntryDeleteConfirmed            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyEntry                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreEntry                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PBMenu                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PBSC                            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_CITYCOM_VOIP_EXTENSIONS_MOD }

  TFOS_CITYCOM_VOIP_EXTENSIONS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  type
    TFRE_VOIP_CMD_MODE = (voipInsert,voipUpdate,voipDelete);

  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    function        _addModifyExtension                 (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean):IFRE_DB_Object;
    function        _sendCPEDHCPData                    (const extension_uid: TFRE_DB_GUID; const ses: IFRE_DB_UserSession; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _sendVOIPEntryData                  (const cmd_mode: TFRE_VOIP_CMD_MODE; const extNumber:TFRE_DB_String; const extension,serviceObj,telephone: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       CalculateDescription                (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddExtension                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExtensionDelete                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExtensionDeleteConfirmed        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyExtension                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreExtension                  (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExtensionKeys                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreExtensionKeys              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_MangeExpansions                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExtMenu                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExtSC                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ConfigureExpCount               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreExpCount                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_RemoveExp                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExpInMenu                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ExpOutMenu                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_CITYCOM_VOIP_SERVICE_MOD }

  TFOS_CITYCOM_VOIP_SERVICE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    fExtensionsMod: TFOS_CITYCOM_VOIP_EXTENSIONS_MOD;
    class procedure RegisterSystemScheme           (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects               (const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects           (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects4Domain    (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    class procedure InstallUserDBObjects4SysDomain (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
    procedure       SetupAppModuleStructure        ; override;
    function        _AddModifyHW                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify:Boolean):IFRE_DB_Object;
  public
    procedure       MySessionInitializeModule      (const session : TFRE_DB_UserSession);override;
    function        getPhonebookSubPath            (const conn: IFRE_DB_CONNECTION): String;
    function        getExtensionsSubPath           (const conn: IFRE_DB_CONNECTION): String;
  published
    function        WEB_Content                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentCustomers           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentHardware            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ServiceContent             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddService                 (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateService              (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_UpdateService              (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ServiceSC                  (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddHW                      (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ModifyHW                   (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreHW                    (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_HWDelete                   (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_HWDeleteConfirmed          (const input:IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_HWMenu                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY }

  TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects     (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_CITYCOM_VOIP_EXTENSION }

  TFOS_DB_CITYCOM_VOIP_EXTENSION=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  published
    function WEB_SaveOperation             (const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object; override;
  end;

  { TFOS_DB_CITYCOM_VOIP_SERVICE }

  TFOS_DB_CITYCOM_VOIP_SERVICE=class(TFRE_DB_SUBSERVICE)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID); override;
  public
    class function  GetCaption             (const conn:IFRE_DB_CONNECTION): String; override;
  end;

  { TFOS_DB_CITYCOM_VOIP_HARDWARE }

  TFOS_DB_CITYCOM_VOIP_HARDWARE=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

  { TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL }

  TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL=class(TFRE_DB_ObjectEx)
  protected
    class procedure RegisterSystemScheme   (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects       (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_CITYCOM_VOIP_SERVICE);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_CITYCOM_VOIP_EXTENSION);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_CITYCOM_VOIP_HARDWARE);
  GFRE_DBI.RegisterObjectClassEx(TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL);

  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_VOIP_SERVICE_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_VOIP_PHONEBOOK_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_VOIP_EXTENSIONS_MOD);

  //GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL }

class procedure TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group: IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);

  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('expansion',fdbft_ObjLink).SetupFieldDef(true);
  scheme.AddSchemeField('count',fdbft_Int16).SetupFieldDef(true);

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('count',GetTranslateableTextKey('scheme_count'));
end;

class procedure TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';

  if (currentVersionId='') then begin
    currentVersionId := '0.9';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'scheme_count','Count');
  end;
end;

{ TFOS_DB_CITYCOM_VOIP_HARDWARE }

class procedure TFOS_DB_CITYCOM_VOIP_HARDWARE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group: IFRE_DB_InputGroupSchemeDefinition;
  enum : IFRE_DB_Enum;
begin
  inherited RegisterSystemScheme(scheme);

  enum:=GFRE_DBI.NewEnum('voip_hardware_type').Setup(GFRE_DBI.CreateText('$voip_hardware_type','Hardware Type'));
  enum.addEntry('TEL',GetTranslateableTextKey('voip_hardware_tel'));
  enum.addEntry('EXP',GetTranslateableTextKey('voip_hardware_exp'));
  GFRE_DBI.RegisterSysEnum(enum);

  enum:=GFRE_DBI.NewEnum('voip_key_action').Setup(GFRE_DBI.CreateText('$voip_key_action','Key Action'));
  enum.addEntry('T',GetTranslateableTextKey('voip_key_action_local'));
  enum.addEntry('N',GetTranslateableTextKey('voip_key_action_none'));
  enum.addEntry('L',GetTranslateableTextKey('voip_key_action_ldap'));
  enum.addEntry('D',GetTranslateableTextKey('voip_key_action_direct_call'));
  enum.addEntry('C',GetTranslateableTextKey('voip_key_action_call_forward'));
  enum.addEntry('V',GetTranslateableTextKey('voip_key_action_call_forward_variable'));
  enum.addEntry('P',GetTranslateableTextKey('voip_key_action_partner_key'));
  GFRE_DBI.RegisterSysEnum(enum);

  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('sqlId',fdbft_Int64).Required:=true;
  scheme.AddSchemeField('type',fdbft_String).SetupFieldDef(true,false,'voip_hardware_type');
  scheme.AddSchemeField('keys',fdbft_Int16).SetupFieldDef(true);

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));

  group.AddInput('objname',GetTranslateableTextKey('scheme_name'));
  group.AddInput('type',GetTranslateableTextKey('scheme_type'));
  group.AddInput('keys',GetTranslateableTextKey('scheme_keys'));
end;

class procedure TFOS_DB_CITYCOM_VOIP_HARDWARE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';

  if (currentVersionId='') then begin
    currentVersionId := '0.9';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'voip_hardware_tel','Telephone');
    StoreTranslateableText(conn,'voip_hardware_exp','Expansion');

    StoreTranslateableText(conn,'voip_key_action_local','Action locally Defined');
    StoreTranslateableText(conn,'voip_key_action_none','None');
    StoreTranslateableText(conn,'voip_key_action_ldap','LDAP');
    StoreTranslateableText(conn,'voip_key_action_direct_call','Direct Call');
    StoreTranslateableText(conn,'voip_key_action_call_forward','Call Forward');
    StoreTranslateableText(conn,'voip_key_action_call_forward_variable','Call Forward Variable');
    StoreTranslateableText(conn,'voip_key_action_partner_key','Partner Key');

    StoreTranslateableText(conn,'scheme_name','Name');
    StoreTranslateableText(conn,'scheme_type','Type');
    StoreTranslateableText(conn,'scheme_keys','Keys');
  end;
end;

{ TFOS_CITYCOM_VOIP_SERVICE_MOD }

class procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

class procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'grid_voip_services_cap','Main Numbers');
    CreateModuleText(conn,'voip_create_diag_cap','Add VoIP Service');
    CreateModuleText(conn,'voip_create_error_exists_cap','Error: Add VoIP Service');
    CreateModuleText(conn,'voip_create_error_exists_msg','The given number already exists!');
    CreateModuleText(conn,'customer_chooser_label','Customer');

    CreateModuleText(conn,'grid_customer_objname','Customer');
    CreateModuleText(conn,'grid_customer_default_value','No Customer assigned');

    CreateModuleText(conn,'grid_number','Main Number');
    CreateModuleText(conn,'tb_add_service','Add');

    CreateModuleText(conn,'grid_hw_name','Name');
    CreateModuleText(conn,'grid_hw_type','Type');
    CreateModuleText(conn,'grid_hw_keys','Keys');

    CreateModuleText(conn,'hardware_create_diag_cap','New Hardware');
    CreateModuleText(conn,'hardware_modify_diag_cap','Modify Hardware');

    CreateModuleText(conn,'tb_add_hardware','Add');
    CreateModuleText(conn,'tb_modify_hardware','Modify');
    CreateModuleText(conn,'tb_delete_hardware','Delete');

    CreateModuleText(conn,'cm_modify_hardware','Modify');
    CreateModuleText(conn,'cm_delete_hardware','Delete');

    CreateModuleText(conn,'voip_content_section_customers','Customers');
    CreateModuleText(conn,'voip_content_section_hardware','Hardware');

    CreateModuleText(conn,'voip_content_section_service','VoIP Details');
    CreateModuleText(conn,'info_service_details_select_one','Please select a VoIP service to get detailed information about it.');
    CreateModuleText(conn,'info_service_details_no_service','There is no VoIP service configured on the system.');
  end;
end;

class procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateServicesCollections(conn);
end;

class procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

  end;
end;

class procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.InstallUserDBObjects4SysDomain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  inherited InstallUserDBObjects4SysDomain(conn, currentVersionId, domainUID);
  InstallUserDBObjects4Domain(conn,currentVersionId,domainUID);
end;

procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.SetupAppModuleStructure;
begin
  fExtensionsMod:=TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.create;
  AddApplicationModule(fExtensionsMod);
  AddApplicationModule(TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.create);
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD._AddModifyHW(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  sf       : TFRE_DB_SERVER_FUNC_DESC;
  diagCap  : TFRE_DB_String;
  hwDBO    : IFRE_DB_Object;
  scheme   : IFRE_DB_SchemeObject;
  res      : TFRE_DB_FORM_DIALOG_DESC;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_HARDWARE,scheme) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_HARDWARE]);

  sf:=CWSF(@WEB_StoreHW);
  if isModify then begin
    sf.AddParam.Describe('hwId',input.Field('selected').AsString);
    diagCap:=FetchModuleTextShort(ses,'hardware_modify_diag_cap');
  end else begin
    diagCap:=FetchModuleTextShort(ses,'hardware_create_diag_cap');
  end;
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),hwDBO));
    res.FillWithObjectValues(hwDBO,ses);
  end;

  Result:=res;
end;

procedure TFOS_CITYCOM_VOIP_SERVICE_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app            : TFRE_DB_APPLICATION;
  conn           : IFRE_DB_CONNECTION;
  transform      : IFRE_DB_SIMPLE_TRANSFORM;
  voip_services  : IFRE_DB_DERIVED_COLLECTION;
  voip_customers : IFRE_DB_DERIVED_COLLECTION;
  voip_telephones: IFRE_DB_DERIVED_COLLECTION;
  voip_hardware  : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_customer_objname'),true,dt_string,true,true,1,'',FetchModuleTextShort(session,'grid_customer_default_value'),nil,false,'domainid');
      AddCollectorscheme('+%s%s%s',TFRE_DB_NameTypeArray.create('international_prefix','national_prefix','number'),'number',FetchModuleTextShort(session,'grid_number'));
      AddFulltextFilterOnTransformed(['customer','number']);
    end;

    voip_services := session.NewDerivedCollection('VOIP_SERVICES_GRID');
    with voip_services do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],FetchModuleTextShort(session,'grid_voip_services_cap'),nil,nil,CWSF(@WEB_ServiceSC));
      SetDefaultOrderField('customer',true);
      Filters.AddSchemeObjectFilter('service',[TFOS_DB_CITYCOM_VOIP_SERVICE.ClassName]);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','objname',FetchModuleTextShort(session,'grid_hw_name'));
      AddOneToOnescheme('type','type',FetchModuleTextShort(session,'grid_hw_type'));
      AddOneToOnescheme('keys','keys',FetchModuleTextShort(session,'grid_hw_keys'));
    end;

    voip_hardware := session.NewDerivedCollection('VOIP_HARDWARE_GRID');
    with voip_hardware do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_HARDWARE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',CWSF(@WEB_HWMenu));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('servicedomain','','',dt_string,false);
    end;

    voip_customers := session.NewDerivedCollection('VOIP_CUSTOMER_CHOOSER');
    with voip_customers do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_CUSTOMERS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','servicedomain','','','TFOS_DB_CITYCOM_VOIP_SERVICE',[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('type','','',dt_string,false);
    end;

    voip_telephones := session.NewDerivedCollection(CFOS_DB_VOIP_TELEPHONE_DCOLL);
    with voip_telephones do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_HARDWARE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddStringFieldFilter('TYPE_FILTER','type','TEL',dbft_EXACT);
    end;
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.getPhonebookSubPath(const conn: IFRE_DB_CONNECTION): String;
begin
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE) or conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    Result:='VOIP_CUSTOMER'+':'+TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.ClassName;
  end else begin
    Result:=TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.ClassName;
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.getExtensionsSubPath(const conn: IFRE_DB_CONNECTION): String;
begin
  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE) or conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    Result:='VOIP_CUSTOMER'+':'+TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.ClassName;
  end else begin
    Result:=TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.ClassName;
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res     : TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE) or conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
    if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE) then begin
      res.AddSection.Describe(CWSF(@WEB_ContentCustomers),FetchModuleTextShort(ses,'voip_content_section_customers'),1,'VOIP_CUSTOMER');
    end;
    if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
      res.AddSection.Describe(CWSF(@WEB_ContentHardware),FetchModuleTextShort(ses,'voip_content_section_hardware'),2);
    end;
    Result:=res;
  end else begin
    Result:=WEB_ContentCustomers(input,ses,app,conn);
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_ContentCustomers(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  subsec        : TFRE_DB_SUBSECTIONS_DESC;
  customers     : TFRE_DB_VIEW_LIST_DESC;
  coll          : IFRE_DB_DERIVED_COLLECTION;
  ext_Grid      : IFRE_DB_DERIVED_COLLECTION;
  ext_admin_Grid: IFRE_DB_DERIVED_COLLECTION;
  pb_Grid       : IFRE_DB_DERIVED_COLLECTION;
  voip_service  : IFRE_DB_Object;
  admin         : Boolean;
begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedVoIP');

  subsec:=inherited WEB_Content(input,ses,app,conn).Implementor_HC as TFRE_DB_SUBSECTIONS_DESC;
  subsec.AddSection.Describe(CWSF(@WEB_ServiceContent),FetchModuleTextShort(ses,'voip_content_section_service'),0);

  coll:=ses.FetchDerivedCollection('VOIP_SERVICES_GRID');
  ext_Grid := ses.FetchDerivedCollection('VOIP_EXTENSIONS_GRID');
  ext_admin_Grid := ses.FetchDerivedCollection('VOIP_EXTENSIONS_ADMIN_GRID');
  pb_Grid := ses.FetchDerivedCollection('VOIP_PHONEBOOK_GRID');
  admin:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE);

  if admin or (coll.ItemCount>1) then begin

    customers:=coll.GetDisplayDescription  as TFRE_DB_VIEW_LIST_DESC;
    if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE) then begin
      customers.AddButton.Describe(CWSF(@WEB_AddService),'',FetchModuleTextShort(ses,'tb_add_service'),FetchModuleTextHint(ses,'tb_add_service'));
    end;

    ext_admin_Grid.SetUseDependencyAsRefLinkFilter(['TFOS_DB_CITYCOM_VOIP_EXTENSION<VOIP_SERVICE'],false,'uid');
    customers.AddFilterEvent(ext_admin_Grid.getDescriptionStoreId(),'uid');
    ext_Grid.SetUseDependencyAsRefLinkFilter(['TFOS_DB_CITYCOM_VOIP_EXTENSION<VOIP_SERVICE'],false,'uid');
    customers.AddFilterEvent(ext_Grid.getDescriptionStoreId(),'uid');

    pb_Grid.SetUseDependencyAsRefLinkFilter(['TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY<VOIP_SERVICE'],false,'uid');
    customers.AddFilterEvent(pb_Grid.getDescriptionStoreId(),'uid');

    Result:=TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(customers,subsec.Implementor_HC as TFRE_DB_CONTENT_DESC);
  end else begin
    ext_Grid.Filters.RemoveFilter('service');
    pb_Grid.Filters.RemoveFilter('service');
    if coll.ItemCount=1 then begin
      voip_service:=coll.First;
      ext_Grid.Filters.AddAutoDependencyFilter('service',['TFOS_DB_CITYCOM_VOIP_EXTENSION<VOIP_SERVICE'],[voip_service.UID]);
      pb_Grid.Filters.AddAutoDependencyFilter('service',['TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY<VOIP_SERVICE'],[voip_service.UID]);
      ses.GetSessionModuleData(ClassName).Field('selectedVoIP').AsString:=voip_service.UID_String;
    end else begin
      ext_Grid.Filters.AddAutoDependencyFilter('service',['TFOS_DB_CITYCOM_VOIP_EXTENSION<VOIP_SERVICE'],[CFRE_DB_NullGUID]);
      pb_Grid.Filters.AddAutoDependencyFilter('service',['TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY<VOIP_SERVICE'],[CFRE_DB_NullGUID]);
      ses.GetSessionModuleData(ClassName).DeleteField('selectedVoIP');
    end;
    Result:=subsec;
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_ContentHardware(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll: IFRE_DB_DERIVED_COLLECTION;
  res : TFRE_DB_VIEW_LIST_DESC;
begin
  coll:=ses.FetchDerivedCollection('VOIP_HARDWARE_GRID');

  res:=coll.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    res.AddButton.Describe(CWSF(@WEB_AddHW),'',FetchModuleTextShort(ses,'tb_add_hardware'),FetchModuleTextHint(ses,'tb_add_hardware'));
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    res.AddButton.Describe(CWSF(@WEB_HWDelete),'',FetchModuleTextShort(ses,'tb_delete_hardware'),FetchModuleTextHint(ses,'tb_delete_hardware'),fdgbd_single);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    res.AddButton.Describe(CWSF(@WEB_ModifyHW),'',FetchModuleTextShort(ses,'tb_modify_hardware'),FetchModuleTextHint(ses,'tb_modify_hardware'),fdgbd_single);
  end;

  Result:=res;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_ServiceContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  service : IFRE_DB_Object;
  scheme  : IFRE_DB_SchemeObject;
  editable: Boolean;
  form    : TFRE_DB_FORM_PANEL_DESC;
  sf      : TFRE_DB_SERVER_FUNC_DESC;
  res     : TFRE_DB_CONTENT_DESC;
  coll    : IFRE_DB_DERIVED_COLLECTION;
begin
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedVoIP') and (ses.GetSessionModuleData(ClassName).Field('selectedVoIP').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedVoIP').AsStringItem[0]),service));

    if not (conn.sys.CheckClassRight4DomainId(sr_FETCH,TFOS_DB_CITYCOM_VOIP_SERVICE,service.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_SERVICE,service.DomainID);
    if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_SERVICE,scheme) then
      raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_SERVICE]);

    form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,editable);
    if conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_SERVICE,service.DomainID) then begin
      form.AddSchemeFormGroup(scheme.GetInputGroup('main_admin'),ses);
    end else begin
      form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
    end;
    form.FillWithObjectValues(service,ses);

    if editable then begin
      sf:=CWSF(@WEB_UpdateService);
      sf.AddParam.Describe('serviceId',service.UID_String);
      form.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
    end;
    res:=form;
  end else begin
    coll:=ses.FetchDerivedCollection('VOIP_SERVICES_GRID');
    if coll.ItemCount=0 then begin
      res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_service_details_no_service'));
    end else begin
      res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_service_details_select_one'));
    end;
  end;
  res.contentId:='VOIP_SERVICE_DETAILS';
  Result:=res;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_AddService(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme : IFRE_DB_SchemeObject;
  res    : TFRE_DB_FORM_DIALOG_DESC;
  store  : TFRE_DB_STORE_DESC;
  obj    : IFRE_DB_Object;
  sf     : TFRE_DB_SERVER_FUNC_DESC;
begin
  if not conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_SERVICE,scheme) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_SERVICE]);

  sf:=CWSF(@WEB_CreateService);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'voip_create_diag_cap'),600,true,true,false);
  if input.FieldExists('zoneId') then begin
    sf.AddParam.Describe('zoneId',input.Field('zoneId').AsString);
  end else begin
    res.AddChooser.Describe(FetchModuleTextShort(ses,'customer_chooser_label'),'customer',ses.FetchDerivedCollection('VOIP_CUSTOMER_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true);
  end;
  res.AddSchemeFormGroup(scheme.GetInputGroup('main_add'),ses);

  res.SetElementValue('exchange_line','0');
  res.SetElementValue('business','true');

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_CreateService(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  voipService : TFOS_DB_CITYCOM_VOIP_SERVICE;
  coll        : IFRE_DB_COLLECTION;
  idx         : String;
  customer    : IFRE_DB_Object;
  sdomain     : TFRE_DB_GUID;
  zone        : TFRE_DB_ZONE;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_SERVICE,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_SERVICE]);

  if input.FieldPathExists('data.customer') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.FieldPath('data.customer').AsString),customer));
    if not customer.FieldExists('servicedomain') then
      raise EFRE_DB_Exception.Create(edb_ERROR,'The given customer has no service domain set!');

    input.Field('data').AsObject.DeleteField('customer');
    sdomain:=customer.Field('servicedomain').AsObjectLink;
  end else begin
    if input.FieldExists('zoneId') then begin
      CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));
      sdomain:=zone.DomainID;
    end else begin
      raise EFRE_DB_Exception.Create(edb_ERROR,'No domain Id given for new VoIP Service');
    end;
  end;

  if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_SERVICE,sdomain) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);

  voipService:=TFOS_DB_CITYCOM_VOIP_SERVICE.CreateForDB;
  voipService.Field('international_prefix').AsInt16:=CFOS_VOIP_INT_PREFIX;
  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,voipService,true,conn);
  voipService.ObjectName:='+'+ voipService.Field('international_prefix').AsString + voipService.Field('national_prefix').AsString + voipService.Field('number').AsString;
  idx:=TFOS_DB_CITYCOM_VOIP_SERVICE.ClassName+'_'+voipService.Field('international_prefix').AsString + voipService.Field('national_prefix').AsString + voipService.Field('number').AsString;
  voipService.SetDomainID(sdomain);
  voipService.Field('uniquephysicalid').AsString:=idx;
  if input.FieldExists('zoneId') then begin  //FIXXME
    voipService.Field('serviceParent').AsObjectLink:=zone.UID;
  end;

  if coll.ExistsIndexed(idx) then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'voip_create_error_exists_cap'),FetchModuleTextShort(ses,'voip_create_error_exists_msg'),fdbmt_error);
    exit;
  end;

  CheckDbResult(coll.Store(voipService));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_UpdateService(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  service     : IFRE_DB_Object;
  schemeObject: IFRE_DB_SchemeObject;
begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('serviceId').AsString),service));

  if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_SERVICE,service.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_SERVICE,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_SERVICE]);

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,service,false,conn);
  CheckDbResult(conn.Update(service));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_ServiceSC(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  add_pb_disabled : Boolean;
  service         : IFRE_DB_Object;
  wasExtAdmin     : Boolean;
  isExtAdmin      :Boolean;
begin
  CheckClassVisibility4MyDomain(ses);

  if ses.GetSessionModuleData(ClassName).FieldExists('selectedVoIP') and (ses.GetSessionModuleData(ClassName).Field('selectedVoIP').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').AsStringItem[0]),service));
    wasExtAdmin:=conn.SYS.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXTENSION,service.DomainID);
  end else begin
    wasExtAdmin:=false;
  end;

  add_pb_disabled:=true;
  isExtAdmin:=false;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedVoIP').AsStringArr:=input.Field('selected').AsStringArr;
    if input.Field('selected').ValueCount=1 then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').AsStringItem[0]),service));
      add_pb_disabled:= not conn.SYS.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,service.DomainID);
      isExtAdmin:=conn.SYS.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXTENSION,service.DomainID);
    end;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedVoIP');
  end;

  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_pb_entry',add_pb_disabled));

  if ses.isUpdatableContentVisible('VOIP_EXTENSIONS_CONTENT') and (wasExtAdmin<>isExtAdmin) then begin
    ses.SendServerClientRequest(fExtensionsMod.WEB_Content(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC);
  end else begin
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_extension',not isExtAdmin));
  end;

  if ses.isUpdatableContentVisible('VOIP_SERVICE_DETAILS') then begin
    Result:=WEB_ServiceContent(input,ses,app,conn);
  end else begin
    Result:=GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_AddHW(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=_AddModifyHW(input,ses,app,conn,false);
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_ModifyHW(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  Result:=_AddModifyHW(input,ses,app,conn,true);
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_StoreHW(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject : IFRE_DB_SchemeObject;
  hwObj        : TFOS_DB_CITYCOM_VOIP_HARDWARE;
  isNew        : Boolean;
  hwColl       : IFRE_DB_COLLECTION;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_HARDWARE,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_HARDWARE]);

  if input.FieldExists('hwId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('hwId').AsString),TFOS_DB_CITYCOM_VOIP_HARDWARE,hwObj));
    isNew:=false;
  end else begin
    hwColl:=conn.GetCollection(CFOS_DB_VOIP_HARDWARE_COLLECTION);
    hwObj:=TFOS_DB_CITYCOM_VOIP_HARDWARE.CreateForDB;
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,hwObj,isNew,conn);

  if isNew then begin
    CheckDbResult(hwColl.Store(hwObj));
  end else begin
    CheckDbResult(conn.Update(hwObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_HWDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg    : String;
  hw         : IFRE_DB_Object;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_HWDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'hardware_delete_diag_cap');

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),hw));
  msg:=StringReplace(FetchModuleTextShort(ses,'hardware_delete_diag_msg'),'%hardware_str%',hw.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_HWDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i       : NativeInt;
begin
  if not conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Delete(FREDB_H2G(input.Field('selected').AsStringArr[i])));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_CITYCOM_VOIP_SERVICE_MOD.WEB_HWMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res : TFRE_DB_MENU_DESC;
  func: TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if conn.sys.CheckClassRight4MyDomain(sr_DELETE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    func:=CWSF(@WEB_HWDelete);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_hardware'),'',func);
  end;
  if conn.sys.CheckClassRight4MyDomain(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_HARDWARE) then begin
    func:=CWSF(@WEB_ModifyHW);
    func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_hardware'),'',func);
  end;
  Result:=res;
end;

{ TFOS_DB_CITYCOM_VOIP_SERVICE }

class procedure TFOS_DB_CITYCOM_VOIP_SERVICE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group      : IFRE_DB_InputGroupSchemeDefinition;
  schemeField: IFRE_DB_FieldSchemeDefinition;
  ext_field: IFRE_DB_FieldSchemeDefinition;
  rd_field: IFRE_DB_FieldSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);

  scheme.SetParentSchemeByName(TFRE_DB_SUBSERVICE.ClassName);
  scheme.AddSchemeField('international_prefix',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('national_prefix',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('number',fdbft_String).SetupFieldDef(true);
  ext_field:=scheme.AddSchemeField('standard_extension',fdbft_Int32).SetupFieldDef(true);
  rd_field:=scheme.AddSchemeField('standard_redirection',fdbft_String).SetupFieldDef(true);

  ext_field.addDepField('standard_redirection');
  rd_field.addDepField('standard_extension');

  scheme.AddSchemeField('standard_extension_night',fdbft_Int32);
  schemeField:=scheme.AddSchemeField('business',fdbft_Boolean);
  scheme.AddSchemeField('exchange_line',fdbft_Int16).SetupFieldDef(true);
  schemeField.addDepField('exchange_line',false);

  group:=scheme.ReplaceInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('national_prefix',GetTranslateableTextKey('scheme_national_prefix'),true);
  group.AddInput('number',GetTranslateableTextKey('scheme_number'),true);
  group.AddInput('standard_extension',GetTranslateableTextKey('scheme_standard_extension'));
  group.AddInput('standard_redirection',GetTranslateableTextKey('scheme_standard_redirection'));
  group.AddInput('standard_extension_night',GetTranslateableTextKey('scheme_standard_extension_night'));
  group.AddInput('exchange_line',GetTranslateableTextKey('scheme_exchange_line'),true);

  group:=scheme.AddInputGroup('main_admin').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('national_prefix',GetTranslateableTextKey('scheme_national_prefix'));
  group.AddInput('number',GetTranslateableTextKey('scheme_number'));
  group.AddInput('standard_extension',GetTranslateableTextKey('scheme_standard_extension'));
  group.AddInput('standard_extension_night',GetTranslateableTextKey('scheme_standard_extension_night'));
  group.AddInput('business',GetTranslateableTextKey('scheme_business'));
  group.AddInput('exchange_line',GetTranslateableTextKey('scheme_exchange_line'));

  group:=scheme.AddInputGroup('main_add').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('national_prefix',GetTranslateableTextKey('scheme_national_prefix'));
  group.AddInput('number',GetTranslateableTextKey('scheme_number'));
  group.AddInput('standard_extension',GetTranslateableTextKey('scheme_standard_extension'));
  group.AddInput('standard_extension_night',GetTranslateableTextKey('scheme_standard_extension_night'));
  group.AddInput('business',GetTranslateableTextKey('scheme_business'));
  group.AddInput('exchange_line',GetTranslateableTextKey('scheme_exchange_line'));
end;

class procedure TFOS_DB_CITYCOM_VOIP_SERVICE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';

  if (currentVersionId='') then begin
    currentVersionId := '0.9';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'scheme_national_prefix','National Prefix');
    StoreTranslateableText(conn,'scheme_number','Number');
    StoreTranslateableText(conn,'scheme_standard_extension','Standard Extension');
    StoreTranslateableText(conn,'scheme_standard_extension_night','Standard Extension Night');
    StoreTranslateableText(conn,'scheme_business','Business Customer');
    StoreTranslateableText(conn,'scheme_exchange_line','Exchange line');

    StoreTranslateableText(conn,'caption','VoIP');
  end;
end;

class procedure TFOS_DB_CITYCOM_VOIP_SERVICE.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
var
  role: IFRE_DB_ROLE;
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);
  if (currentVersionId='') then begin
    currentVersionId:='0.9';

    role := CreateClassRole('administer','Administer VoIP Service','Allowed to administer the VoIP Service');
    role.AddRight(GetRight4Domain(GetClassRightName('administer'),domainUID));
    CheckDbResult(conn.StoreRole(role,domainUID),'Error creating '+ClassName+'.administer role');
  end;
end;

class function TFOS_DB_CITYCOM_VOIP_SERVICE.GetCaption(const conn: IFRE_DB_CONNECTION): String;
begin
  Result:=GetTranslateableTextShort(conn,'caption');
end;

{ TFOS_DB_CITYCOM_VOIP_EXTENSION }

class procedure TFOS_DB_CITYCOM_VOIP_EXTENSION.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group      : IFRE_DB_InputGroupSchemeDefinition;
  enum       : IFRE_DB_Enum;
  schemeField: IFRE_DB_FieldSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);

  GFRE_DBI.RegisterSysClientFieldValidator(GFRE_DBI.NewClientFieldValidator('voip_int_number').Setup('^[+][0-9]+$',
                                           GFRE_DBI.CreateText('$voip_int_number','International Number'),
                                           GetTranslateableTextKey('validator_voip_int_number'),
                                           '0-9+'));

  GFRE_DBI.RegisterSysClientFieldValidator(GFRE_DBI.NewClientFieldValidator('voip_email').Setup('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+$',
                                           GFRE_DBI.CreateText('$voip_email','Email'),
                                           GetTranslateableTextKey('validator_voip_email'),
                                           'a-zA-Z0-9._%+-@'));

  enum:=GFRE_DBI.NewEnum('voip_extension_type').Setup(GFRE_DBI.CreateText('$voip_extension_type','Extension Type'));
  enum.addEntry('T',GetTranslateableTextKey('voip_ext_t'));
  enum.addEntry('G',GetTranslateableTextKey('voip_ext_g'));
  enum.addEntry('V',GetTranslateableTextKey('voip_ext_v'));
  enum.addEntry('P',GetTranslateableTextKey('voip_ext_p'));
  enum.addEntry('R',GetTranslateableTextKey('voip_ext_r'));
  enum.addEntry('F',GetTranslateableTextKey('voip_ext_f'));
  GFRE_DBI.RegisterSysEnum(enum);

  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('voip_service',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('number',fdbft_Int32).SetupFieldDef(true);
  //telephone
  scheme.AddSchemeField('telephone',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('expansions',fdbft_ObjLink).SetupFieldDef(false,true);
  scheme.AddSchemeField('password',fdbft_String).required:=true;
  scheme.AddSchemeField('provisioning',fdbft_Boolean);
  scheme.AddSchemeField('recording',fdbft_Boolean);
  scheme.AddSchemeField('ip',fdbft_String).SetupFieldDef(true,false,'','ip');
  scheme.AddSchemeField('mac',fdbft_String).SetupFieldDef(true,false,'','mac');
  //virtual extension
  scheme.AddSchemeField('real_number',fdbft_String).SetupFieldDef(true,false,'','voip_int_number');
  //playfile & record
  scheme.AddSchemeField('filename',fdbft_String).SetupFieldDef(true);
  //playfile
  scheme.AddSchemeField('playfile',fdbft_Stream);
  //fax to mail
  scheme.AddSchemeField('email',fdbft_String).SetupFieldDef(true,false,'','voip_email');

  schemeField:=scheme.AddSchemeField('type',fdbft_String).SetupFieldDef(true,false,'voip_extension_type');
  //telephone
  schemeField.addEnumDepField('telephone','T',fdv_visible);
  schemeField.addEnumDepField('password','T',fdv_visible);
  schemeField.addEnumDepField('provisioning','T',fdv_visible);
  schemeField.addEnumDepField('recording','T',fdv_visible);
  schemeField.addEnumDepField('ip','T',fdv_visible);
  schemeField.addEnumDepField('mac','T',fdv_visible);
  //virtual extension
  schemeField.addEnumDepField('real_number','V',fdv_visible);
  //playfile & record
  schemeField.addEnumDepField('filename','P',fdv_visible);
  schemeField.addEnumDepField('filename','R',fdv_visible);
  //playfile
  schemeField.addEnumDepField('playfile','P',fdv_visible);
  //virtual extension
  schemeField.addEnumDepField('email','F',fdv_visible);

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('number',GetTranslateableTextKey('scheme_number'),true);
  group.AddInput('objname',GetTranslateableTextKey('scheme_name'));
  group.AddInput('type',GetTranslateableTextKey('scheme_type'),true);

  group:=scheme.AddInputGroup('main_admin').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('number',GetTranslateableTextKey('scheme_number'));
  group.AddInput('objname',GetTranslateableTextKey('scheme_name'));
  group.AddInput('type',GetTranslateableTextKey('scheme_type'));
  group.AddInput('telephone',GetTranslateableTextKey('scheme_telephone'),false,false,'',CFOS_DB_VOIP_TELEPHONE_DCOLL,true);
  group.AddInput('password',GetTranslateableTextKey('scheme_password'));
  group.AddInput('provisioning',GetTranslateableTextKey('scheme_provisioning'));
  group.AddInput('recording',GetTranslateableTextKey('scheme_recording'));
  group.AddInput('ip',GetTranslateableTextKey('scheme_ip'));
  group.AddInput('mac',GetTranslateableTextKey('scheme_mac'));
  group.AddInput('real_number',GetTranslateableTextKey('scheme_real_number'));
  group.AddInput('filename',GetTranslateableTextKey('scheme_filename'));
  group.AddInput('playfile',GetTranslateableTextKey('scheme_playfile'));
  group.AddInput('email',GetTranslateableTextKey('scheme_email'));
end;

class procedure TFOS_DB_CITYCOM_VOIP_EXTENSION.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';

  if (currentVersionId='') then begin
    currentVersionId := '0.9';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'voip_ext_t','Telephone');
    StoreTranslateableText(conn,'voip_ext_g','Group Call');
    StoreTranslateableText(conn,'voip_ext_v','Virtual Extension');
    StoreTranslateableText(conn,'voip_ext_p','Playfile');
    StoreTranslateableText(conn,'voip_ext_r','Record');
    StoreTranslateableText(conn,'voip_ext_f','Fax to Mail');

    StoreTranslateableText(conn,'scheme_name','Name');
    StoreTranslateableText(conn,'scheme_number','Number');
    StoreTranslateableText(conn,'scheme_type','Type');
    StoreTranslateableText(conn,'scheme_telephone','Telephone');
    StoreTranslateableText(conn,'scheme_password','Password');
    StoreTranslateableText(conn,'scheme_provisioning','Provisioning');
    StoreTranslateableText(conn,'scheme_recording','Recording');
    StoreTranslateableText(conn,'scheme_ip','IP');
    StoreTranslateableText(conn,'scheme_mac','Mac');
    StoreTranslateableText(conn,'scheme_real_number','To number');
    StoreTranslateableText(conn,'scheme_filename','Filename');
    StoreTranslateableText(conn,'scheme_playfile','Filename');
    StoreTranslateableText(conn,'scheme_email','Email');

    StoreTranslateableText(conn,'validator_voip_int_number','e.g.: +431234567890');
    StoreTranslateableText(conn,'validator_voip_email','john@doe.com');
  end;
end;

class procedure TFOS_DB_CITYCOM_VOIP_EXTENSION.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
var
  role: IFRE_DB_ROLE;
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);
  if (currentVersionId='') then begin
    currentVersionId:='0.9';

    role := CreateClassRole('administer','Administer Extension','Allowed to administer extensions');
    role.AddRight(GetRight4Domain(GetClassRightName('administer'),domainUID));
    CheckDbResult(conn.StoreRole(role,domainUID),'Error creating '+ClassName+'.administer role');
  end;
end;

function TFOS_DB_CITYCOM_VOIP_EXTENSION.WEB_SaveOperation(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i: Integer;
begin
  if (input.FieldPathExists('data.number') and (input.FieldPath('data.number').AsInt16<>Field('number').AsInt16)) and not conn.sys.CheckClassRight4DomainId('administer',ClassType,DomainID) then
    raise EFRE_DB_Exception.Create('Access denied');

  if input.FieldPathExists('data.expansions') and not conn.sys.CheckClassRight4DomainId('administer',ClassType,DomainID) then begin
    if input.FieldPath('data.expansions').ValueCount<>Field('expansions').ValueCount then
      raise EFRE_DB_Exception.Create('Access denied');

    for i := 0 to Field('expansions').ValueCount - 1 do begin
      if input.FieldPath('data.expansions').AsStringItem[i]<>FREDB_G2H(Field('expansions').AsObjectLinkItem[i]) then
        raise EFRE_DB_Exception.Create('Access denied');
    end;
  end;

  Result:=inherited WEB_SaveOperation(input, ses, app, conn);
end;

{ TFOS_CITYCOM_VOIP_EXTENSIONS_MOD }

class procedure TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('voip_extensions_description')
end;

class procedure TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';
  if currentVersionId='' then begin
    currentVersionId := '0.9';

    CreateModuleText(conn,'voip_extensions_description','Extensions','Extensions','Extensions');

    CreateModuleText(conn,'grid_ext_name','Name');
    CreateModuleText(conn,'grid_ext_number','Number');
    CreateModuleText(conn,'grid_ext_type','Type');
    CreateModuleText(conn,'grid_ext_provisioning','Prov.');
    CreateModuleText(conn,'grid_ext_recording','Rec.');

    CreateModuleText(conn,'grid_ext_ip_mac_pass','Telephone: %hwname_str%, IP: %ip_str%, Mac: %mac_str%, Password: %pass_str%');
    CreateModuleText(conn,'grid_ext_real_number','Number: %number_str%');
    CreateModuleText(conn,'grid_ext_filename','Filename: %filename_str%');
    CreateModuleText(conn,'grid_ext_email','EMail: %email_str%');

    CreateModuleText(conn,'tb_create_extension','Add');
    CreateModuleText(conn,'tb_delete_extension','Delete');
    CreateModuleText(conn,'tb_modify_extension','Modify');
    CreateModuleText(conn,'tb_extension_keys','Keys');
    CreateModuleText(conn,'tb_extension_expansions','Expansions');

    CreateModuleText(conn,'cm_delete_extension','Delete');
    CreateModuleText(conn,'cm_modify_extension','Modify');
    CreateModuleText(conn,'cm_extension_keys','Keys');
    CreateModuleText(conn,'cm_extension_expansions','Expansions');

    CreateModuleText(conn,'extension_create_diag_cap','Add Extension');
    CreateModuleText(conn,'extension_modify_diag_cap','Modify Extension');

    CreateModuleText(conn,'extension_delete_diag_cap','Delete Extension');
    CreateModuleText(conn,'extension_delete_diag_msg','Delete Extension "%extension_str%"');
    CreateModuleText(conn,'extension_delete_single_select','Exactly one object has to be selected for deletion.');

    CreateModuleText(conn,'extension_keys_diag_cap','Keys');
    CreateModuleText(conn,'extension_keys_diag_action','Action');
    CreateModuleText(conn,'extension_keys_diag_value','Value');
    CreateModuleText(conn,'extension_keys_diag_descr','Description');
    CreateModuleText(conn,'extension_keys_diag_key_input','Key %key_str%');

    CreateModuleText(conn,'manage_expansions_cap','Manage Expansions');

    CreateModuleText(conn,'grid_used_expansions_cap','Used Expansions');
    CreateModuleText(conn,'grid_available_expansions_cap','Available Expansions');
    CreateModuleText(conn,'grid_exp_in_name','Name');
    CreateModuleText(conn,'grid_exp_in_count','Count');
    CreateModuleText(conn,'grid_exp_out_name','Name');

    CreateModuleText(conn,'tb_add_exp','Add');
    CreateModuleText(conn,'tb_remove_exp','Remove');
    CreateModuleText(conn,'tb_configure_exp','Count');

    CreateModuleText(conn,'cm_add_exp','Add');
    CreateModuleText(conn,'cm_remove_exp','Remove');
    CreateModuleText(conn,'cm_configure_exp','Count');

    CreateModuleText(conn,'configure_expansion_count_diag_cap','Configure Expansion Count');
  end;
end;

class procedure TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
var
  coll: IFRE_DB_COLLECTION;
begin
  if currentVersionId='' then begin
    currentVersionId := '0.9';
    coll := conn.CreateCollection(CFOS_DB_VOIP_EXTENSIONS_COLLECTION);
    coll := conn.CreateCollection(CFOS_DB_VOIP_HARDWARE_COLLECTION);
    coll := conn.CreateCollection(CFOS_DB_VOIP_EXT_EXP_REL_COLLECTION);
  end;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD._addModifyExtension(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  diagCap     : TFRE_DB_String;
  extensionDBO: IFRE_DB_Object;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  number_elem : TFRE_DB_INPUT_NUMBER_DESC;
  service     : IFRE_DB_Object;
  sdomainId   : TFRE_DB_GUID;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_EXTENSION,scheme) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_EXTENSION]);

  sf:=CWSF(@WEB_StoreExtension);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),extensionDBO));

    sdomainId:=extensionDBO.DomainID;
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,sdomainId) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('extensionId',input.Field('selected').AsString);
    diagCap:=FetchModuleTextShort(ses,'extension_modify_diag_cap');
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').AsStringItem[0]),service));

    sdomainId:=service.DomainID;
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXTENSION,sdomainId) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('serviceId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'extension_create_diag_cap');
  end;
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600,true,true,isModify);

  if conn.SYS.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,sdomainId) then begin
    res.AddSchemeFormGroup(scheme.GetInputGroup('main_admin'),ses);
  end else begin
    res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  end;

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    res.FillWithObjectValues(extensionDBO,ses);
  end else begin
    res.SetElementValue('provisioning','true');
  end;
  number_elem:=res.GetFormElement('number').Implementor_HC as TFRE_DB_INPUT_NUMBER_DESC;
  number_elem.setMinMax(0,999);

  Result:=res;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD._sendCPEDHCPData(const extension_uid: TFRE_DB_GUID; const ses: IFRE_DB_UserSession; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var  inp,opd    : IFRE_DB_Object;
     coll       : IFRE_DB_COLLECTION;
     device     : IFRE_DB_Object;
     dhcp       : TFRE_DB_CPE_DHCP_SERVICE;
     newdhcp    : TFRE_DB_CPE_DHCP_SERVICE;
     found      : boolean;

   procedure GotAnswer(const ses: IFRE_DB_UserSession; const new_input: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const ocid: Qword; const opaquedata: IFRE_DB_Object);
   var
     res     : TFRE_DB_MESSAGE_DESC;
     i       : NativeInt;
     cnt     : NativeInt;
     newnew  : IFRE_DB_Object;

   begin
     case status of
       cdcs_OK:
         begin
           res:=TFRE_DB_MESSAGE_DESC.create.Describe('DHCP','SETUP OK',fdbmt_info);
         end;
       cdcs_TIMEOUT:
         begin
           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COMMUNICATION TIMEOUT SET DHCP',fdbmt_error); { FIXXME }
         end;
       cdcs_ERROR:
         begin
           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT SET DHCP ['+new_input.Field('ERROR').AsString+']',fdbmt_error); { FIXXME }
         end;
     end;
     ses.SendServerClientAnswer(res,ocid);
     cnt := 0;
   end;

   procedure _dhcpIterator (const obj:IFRE_DB_Object);
   var subnet    : TFRE_DB_DHCP_Subnet;
       newsubnet : TFRE_DB_DHCP_Subnet;
       i         : integer;
       extcoll   : IFRE_DB_COLLECTION;

     procedure _ExtensionIterator(const obj:IFRE_DB_Object);
     var dhcpfix : TFRE_DB_DHCP_Fixed;
     begin
       writeln(obj.Field('mac').AsString+' '+obj.Field('ip').asstring);
       dhcpfix  := TFRE_DB_DHCP_Fixed.CreateForDB;
       dhcpfix.ObjectName:='tel'+inttostr(i);
       dhcpfix.Field('ip').AsString      := obj.Field('ip').asstring;
       dhcpfix.Field('mac').AsString     := obj.Field('mac').asstring;
       inc(i);
       newsubnet.Field(dhcpfix.UID.AsHexString).AsObject:=dhcpfix;
     end;

   begin
     i := 0;
     if obj.IsA(TFRE_DB_DHCP_Subnet,subnet) then
       begin
         newsubnet := TFRE_DB_DHCP_Subnet.CreateForDB;
         newsubnet.SetAllSimpleObjectFieldsFromObject(subnet);
         newdhcp.Field(newsubnet.UID_String).AsObject:=newsubnet;
         extColl:=conn.GetCollection(CFOS_DB_VOIP_EXTENSIONS_COLLECTION);
         extColl.ForAll(@_ExtensionIterator);
       end;
   end;

begin
  coll:=conn.GetCollection(CFRE_DB_ASSET_COLLECTION);
  if coll.GetIndexedObj(lowercase(trim(cFRE_CMDLINE_DEBUG)),device,'mac') then      //FIXME, DETERMINE CPE MAC FOR EXTENSION
    begin
//        writeln('ASSETT',device.DumpToString());
      if device.Field('config').AsObject.Field('dhcp').AsObject.IsA(TFRE_DB_CPE_DHCP_SERVICE,dhcp) then
        begin
          newdhcp := TFRE_DB_CPE_DHCP_SERVICE.CreateForDB;
          newdhcp.SetAllSimpleObjectFieldsFromObject(dhcp);
          dhcp.ForAllObjects(@_dhcpIterator);
          device.Field('config').AsObject.Field('dhcp').AsObject:=newdhcp;
          writeln('CPE DUMP',device.Field('config').AsObject.Field('dhcp').AsObject.DumpToString());
          inp := GFRE_DBI.NewObject;
          inp.Field('DHCP').AsObject := device.Field('config').AsObject.Field('dhcp').AsObject.CloneToNewObject;
          CheckDbResult(conn.Update(device));
          if ses.InvokeRemoteRequestMachineMac(lowercase(trim(cFRE_CMDLINE_DEBUG)),'TFRE_CPE_FEED_CLIENT','UPDATEDHCP',inp,@GotAnswer,nil)=edb_OK then
            begin
              Result := GFRE_DB_SUPPRESS_SYNC_ANSWER;
              exit;
            end
          else
            begin
              Result := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT CONFIGURE DHCP',fdbmt_error); { FIXXME }
              inp.Finalize;
            end
        end
      else
        raise EFRE_DB_Exception.Create('NO DHCP SERVICE IN DEVICE');
    end
  else
    raise EFRE_DB_Exception.Create('CPE DEVICE NOT IN DATABASE');
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD._sendVOIPEntryData(const cmd_mode: TFRE_VOIP_CMD_MODE; const extNumber: TFRE_DB_String; const extension, serviceObj, telephone: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var  inp        : IFRE_DB_Object;
     machineid  : TFRE_DB_GUID;
     cmd        : string;

   procedure GotAnswer(const ses: IFRE_DB_UserSession; const new_input: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const ocid: Qword; const opaquedata: IFRE_DB_Object);
   var
     res     : TFRE_DB_MESSAGE_DESC;
     i       : NativeInt;
     cnt     : NativeInt;
     newnew  : IFRE_DB_Object;

   begin
     case status of
       cdcs_OK:
         begin
           res:=TFRE_DB_MESSAGE_DESC.create.Describe('VOIP','SETUP OK',fdbmt_info);
         end;
       cdcs_TIMEOUT:
         begin
           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COMMUNICATION TIMEOUT SET VOIP',fdbmt_error); { FIXXME }
         end;
       cdcs_ERROR:
         begin
           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT SET VOIP ['+new_input.Field('ERROR').AsString+']',fdbmt_error); { FIXXME }
         end;
     end;
     ses.SendServerClientAnswer(res,ocid);
     cnt := 0;
   end;

 begin
   inp := GFRE_DBI.NewObject;
   case cmd_mode of
     voipInsert:begin
       cmd := 'INSERTVOIPENTRY';
       inp.field('extension').AsObject  := extension.CloneToNewObject;
       inp.Field('serviceObj').AsObject := serviceObj.CloneToNewObject;
       inp.Field('telephone').AsObject  := telephone.CloneToNewObject;
     end;
     voipUpdate:begin
       cmd := 'UPDATEVOIPENTRY';
       inp.Field('extNumber').asstring  := extnumber;
       inp.field('extension').AsObject  := extension.CloneToNewObject;
       inp.Field('serviceObj').AsObject := serviceObj.CloneToNewObject;
       inp.Field('telephone').AsObject  := telephone.CloneToNewObject;
     end;
     voipDelete:begin
       cmd := 'DELETEVOIPENTRY';
       inp.Field('extNumber').asstring  := extnumber;
       inp.field('extension').AsObject  := extension.CloneToNewObject;
       inp.Field('serviceObj').AsObject := serviceObj.CloneToNewObject;
     end;
   else
     raise EFRE_DB_Exception.Create('INVALID VOIP CMD MODE');
   end;
//   machineid := TFRE_DB_SERVICE.GetMachineUIDForService(conn,serviceObj.UID);
//    if ses.InvokeRemoteRequestMachine(machineid,'TFRE_BOX_FEED_CLIENT',cmd,inp,@GotAnswer,nil)=edb_OK then
   if ses.InvokeRemoteRequestMachineMac('00:25:90:82:bf:ae', 'TFRE_BOX_FEED_CLIENT',cmd,inp,@GotAnswer,nil)=edb_OK then
     begin
       Result := GFRE_DB_SUPPRESS_SYNC_ANSWER;
       exit;
     end
   else
     begin
       Result := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT CONFIGURE VOIP',fdbmt_error); { FIXXME }
       inp.Finalize;
     end;
 end;

procedure TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  grid     : IFRE_DB_DERIVED_COLLECTION;
  enum     : IFRE_DB_Enum;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_ext_name'),dt_string,true,true,false,2);
      AddOneToOnescheme('number','',FetchModuleTextShort(session,'grid_ext_number'),dt_number,true,true,false,1);
      AddFulltextFilterOnTransformed(['objname','number']);
    end;

    grid := session.NewDerivedCollection('VOIP_EXTENSIONS_GRID');
    with grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_EXTENSIONS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_ExtMenu),nil,CWSF(@WEB_ExtSC));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.GetSystemEnum('voip_extension_type',enum);

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_ext_name'),dt_string,true,true,false,4);
      AddOneToOnescheme('number','',FetchModuleTextShort(session,'grid_ext_number'),dt_number,true,true,false,2);
      AddOneToOnescheme('type','',FetchModuleTextShort(session,'grid_ext_type'),dt_string,true,true,true,2,'','','',enum.getCaptions(conn));
      AddOneToOnescheme('provisioning','',FetchModuleTextShort(session,'grid_ext_provisioning'),dt_boolean,true,false,false,1);
      AddOneToOnescheme('recording','',FetchModuleTextShort(session,'grid_ext_recording'),dt_boolean,true,false,false,1);
      AddOneToOnescheme('description','','',dt_description);
      AddMatchingReferencedField('telephone>TFOS_DB_CITYCOM_VOIP_HARDWARE','objname','hwname','',false);
      AddOneToOnescheme('ip','','',dt_string,false);
      AddOneToOnescheme('mac','','',dt_string,false);
      AddOneToOnescheme('password','','',dt_string,false);
      AddOneToOnescheme('real_number','','',dt_string,false);
      AddOneToOnescheme('filename','','',dt_string,false);
      AddOneToOnescheme('email','','',dt_string,false);
      AddFulltextFilterOnTransformed(['objname','number']);
      SetFinalRightTransformFunction(@CalculateDescription,[FetchModuleTextShort(session,'grid_ext_ip_mac_pass'),FetchModuleTextShort(session,'grid_ext_real_number'),FetchModuleTextShort(session,'grid_ext_filename'),FetchModuleTextShort(session,'grid_ext_email')]);
    end;

    grid := session.NewDerivedCollection('VOIP_EXTENSIONS_ADMIN_GRID');
    with grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_EXTENSIONS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_ExtMenu),nil,CWSF(@WEB_ExtSC));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField('EXPANSION>TFOS_DB_CITYCOM_VOIP_HARDWARE','objname','objname',FetchModuleTextShort(session,'grid_exp_in_name'),true,dt_string,true);
      AddOneToOnescheme('count','',FetchModuleTextShort(session,'grid_exp_in_count'),dt_string,true,true);
      AddFulltextFilterOnTransformed(['objname']);
    end;

    grid := session.NewDerivedCollection('VOIP_EXTENSION_EXP_IN_GRID');
    with grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_EXT_EXP_REL_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],FetchModuleTextShort(session,'grid_used_expansions_cap'),CWSF(@WEB_ExpInMenu),nil,nil,nil,CWSF(@WEB_ConfigureExpCount));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_exp_out_name'),dt_string,true,true);
      AddOneToOnescheme('type','','',dt_string,false);
      AddFulltextFilterOnTransformed(['objname']);
    end;

    grid := session.NewDerivedCollection('VOIP_EXTENSION_EXP_OUT_GRID');
    with grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_HARDWARE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],FetchModuleTextShort(session,'grid_available_expansions_cap'),CWSF(@WEB_ExpOutMenu),nil,nil,nil,CWSF(@WEB_RemoveExp));
      SetDefaultOrderField('objname',true);
      Filters.AddStringFieldFilter('TYPE_FILTER','type','EXP',dbft_EXACT);
    end;

  end;
end;

procedure TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.CalculateDescription(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object;const langres: array of TFRE_DB_String);
var
  descr: String;
begin
  if transformed_object.field('ip').AsString<>'' then begin
    descr:=StringReplace(langres[0],'%ip_str%',transformed_object.Field('ip').AsString,[rfReplaceAll]);
    descr:=StringReplace(descr,'%mac_str%',transformed_object.Field('mac').AsString,[rfReplaceAll]);
    descr:=StringReplace(descr,'%pass_str%',transformed_object.Field('password').AsString,[rfReplaceAll]);
    descr:=StringReplace(descr,'%hwname_str%',transformed_object.Field('hwname').AsString,[rfReplaceAll]);
    transformed_object.Field('description').AsString:=descr;;
  end else begin
    if transformed_object.field('real_number').AsString<>'' then begin
      transformed_object.Field('description').AsString:=StringReplace(langres[1],'%number_str%',transformed_object.Field('real_number').AsString,[rfReplaceAll]);
    end else begin
      if transformed_object.field('filename').AsString<>'' then begin
        transformed_object.Field('description').AsString:=StringReplace(langres[2],'%filename_str%',transformed_object.Field('filename').AsString,[rfReplaceAll]);
      end else begin
        if transformed_object.field('email').AsString<>'' then begin
          transformed_object.Field('description').AsString:=StringReplace(langres[3],'%email_str%',transformed_object.Field('email').AsString,[rfReplaceAll]);
        end;
      end;
    end;
  end;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc_ext  : IFRE_DB_DERIVED_COLLECTION;
  ext_grid: TFRE_DB_VIEW_LIST_DESC;
  admin   : Boolean;
  service : IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);


  admin:=ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).FieldExists('selectedVoIP') and (ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').ValueCount=1);
  if admin then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').AsStringItem[0]),service));
    admin:=admin and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXTENSION,service.DomainID);
  end;

  if admin then begin
    dc_ext:=ses.FetchDerivedCollection('VOIP_EXTENSIONS_ADMIN_GRID');
  end else begin
    dc_ext:=ses.FetchDerivedCollection('VOIP_EXTENSIONS_GRID');
  end;

  ext_grid:=dc_ext.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXTENSION) then begin
    ext_grid.AddButton.DescribeManualType('add_extension',CWSF(@WEB_AddExtension),'',FetchModuleTextShort(ses,'tb_create_extension'),FetchModuleTextHint(ses,'tb_create_extension'),not admin);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXTENSION) then begin
    ext_grid.AddButton.DescribeManualType('del_extension',CWSF(@WEB_ExtensionDelete),'',FetchModuleTextShort(ses,'tb_delete_extension'),FetchModuleTextHint(ses,'tb_delete_extension'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION) then begin
    ext_grid.AddButton.DescribeManualType('mod_extension',CWSF(@WEB_ModifyExtension),'',FetchModuleTextShort(ses,'tb_modify_extension'),FetchModuleTextHint(ses,'tb_modify_extension'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION) then begin
    ext_grid.AddButton.DescribeManualType('extension_keys',CWSF(@WEB_ExtensionKeys),'',FetchModuleTextShort(ses,'tb_extension_keys'),FetchModuleTextHint(ses,'tb_extension_keys'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION) then begin
    ext_grid.AddButton.DescribeManualType('extension_expansions',CWSF(@WEB_MangeExpansions),'',FetchModuleTextShort(ses,'tb_extension_expansions'),FetchModuleTextHint(ses,'tb_extension_expansions'),true);
  end;

  ext_grid.contentId:='VOIP_EXTENSIONS_CONTENT';
  Result:=ext_grid;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_AddExtension(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_addModifyExtension(input,ses,app,conn,false);
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExtensionDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg    : String;
  extension  : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),extension));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXTENSION,extension.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_ExtensionDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'extension_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'extension_delete_diag_msg'),'%extension_str%',extension.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExtensionDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i         : NativeInt;
  extension : IFRE_DB_Object;
  serviceObj: IFRE_DB_Object;

  //procedure _DumpData(const extension,serviceObj: IFRE_DB_Object);
  //
  //  function getKNDR(const extension,serviceObj: IFRE_DB_Object):TFRE_DB_String;
  //  begin
  //    Result:='0'+serviceObj.Field('national_prefix').AsString + serviceObj.Field('number').AsString;
  //  end;
  //
  //  function getUSER(const extension,serviceObj: IFRE_DB_Object):TFRE_DB_String;
  //  begin
  //    Result:=getKNDR(extension,serviceObj) + extension.Field('number').AsString;
  //  end;
  //
  //begin
  //  writeln('KNDR: ' + getKNDR(extension,serviceObj));
  //  writeln('USER: ' + getUSER(extension,serviceObj));
  //end;

  begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),extension));
      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXTENSION,extension.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Fetch(extension.Field('voip_service').AsObjectLink,serviceObj));

//      _DumpData(extension,serviceObj);
      _sendVOIPEntryData(voipDelete,'',extension,serviceObj,nil,ses,conn);
      CheckDbResult(conn.Delete(extension.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ModifyExtension(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_addModifyExtension(input,ses,app,conn,true);
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_StoreExtension(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject : IFRE_DB_SchemeObject;
  extensionObj : TFOS_DB_CITYCOM_VOIP_EXTENSION;
  isNew        : Boolean;
  extColl      : IFRE_DB_COLLECTION;
  service      : IFRE_DB_Object;
  telephone    : IFRE_DB_Object;
  extNumber    : TFRE_DB_String;
  extension_uid: TFRE_DB_GUID;


begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_EXTENSION,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_EXTENSION]);

  if input.FieldExists('extensionId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('extensionId').AsString),TFOS_DB_CITYCOM_VOIP_EXTENSION,extensionObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,extensionObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    CheckDbResult(conn.Fetch(FREDB_H2G(extensionObj.Field('voip_service').AsString),service));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('serviceId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXTENSION,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    extColl:=conn.GetCollection(CFOS_DB_VOIP_EXTENSIONS_COLLECTION);
    extensionObj:=TFOS_DB_CITYCOM_VOIP_EXTENSION.CreateForDB;
    extensionObj.SetDomainID(service.DomainID);
    isNew:=true;
  end;

  extNumber:=extensionObj.Field('number').AsString;
  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,extensionObj,isNew,conn);
  CheckDbResult(conn.Fetch(extensionObj.Field('telephone').AsObjectLink,telephone));

//  _DumpData(extNumber,extensionObj,service,telephone);
  if isNew then begin
    extensionObj.Field('voip_service').AsObjectLink:=service.UID;
    _sendVOIPEntryData(voipInsert,'',extensionObj,service,telephone,ses,conn);
    extension_uid := extensionObj.UID;
    CheckDbResult(extColl.Store(extensionObj.CloneToNewObject()));
    _sendCPEDHCPData(extension_uid,ses,conn);
  end else begin
    _sendVOIPEntryData(voipUpdate,extNumber,extensionObj,service,telephone,ses,conn);
    extension_uid := extensionObj.UID;
    CheckDbResult(conn.Update(extensionObj));
    _sendCPEDHCPData(extension_uid,ses,conn);
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExtensionKeys(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res      : TFRE_DB_FORM_DIALOG_DESC;
  extDBO   : IFRE_DB_Object;
  telephone: IFRE_DB_Object;
  group    : TFRE_DB_INPUT_GROUP_DESC;
  i,j,e    : Integer;
  block    : TFRE_DB_INPUT_BLOCK_DESC;
  expDBO   : IFRE_DB_Object;
  sf       : TFRE_DB_SERVER_FUNC_DESC;
  relDBO   : IFRE_DB_Object;
  enum     : IFRE_DB_Enum;
  store    : TFRE_DB_STORE_DESC;
  enumVals : IFRE_DB_ObjectArray;

  procedure _addDescrBlock();
  begin
    block:=group.AddBlock.Describe();
    block.AddDescription.Describe('','');
    block.AddDescription.Describe('',FetchModuleTextShort(ses,'extension_keys_diag_action'));
    block.AddDescription.Describe('',FetchModuleTextShort(ses,'extension_keys_diag_value'));
    block.AddDescription.Describe('',FetchModuleTextShort(ses,'extension_keys_diag_descr'));
  end;

  procedure _addInputBlocks(const preFix: String; const count: Integer);
  var
    i                   : Integer;
    idxStr              : String;
    ids                 : TFOSStringArray;
    field_path          : String;
    avalue,vvalue,dvalue: String;
  begin
    GFRE_BT.SeperateString(preFix,'_',ids);
    field_path:='KEYS';
    for i := 0 to High(ids) do begin
      field_path:=field_path + '.' + ids[i];
    end;
    for i := 0 to count - 1 do begin
      idxStr:=IntToStr(i);
      if extDBO.FieldPathExists(field_path + '.' + idxStr + '.action') then begin
        avalue:=extDBO.FieldPath(field_path + '.' + idxStr + '.action').AsString;
      end else begin
        avalue:='';
      end;
      if extDBO.FieldPathExists(field_path + '.' + idxStr + '.value') then begin
        vvalue:=extDBO.FieldPath(field_path + '.' + idxStr + '.value').AsString;
      end else begin
        vvalue:='';
      end;
      if extDBO.FieldPathExists(field_path + '.' + idxStr + '.descr') then begin
        dvalue:=extDBO.FieldPath(field_path + '.' + idxStr + '.descr').AsString;
      end else begin
        dvalue:='';
      end;
      block:=group.AddBlock.Describe();
      block.AddDescription.Describe('',StringReplace(FetchModuleTextShort(ses,'extension_keys_diag_key_input'),'%key_str%',IntToStr(i+1),[rfReplaceAll]));
      block.AddChooser.Describe('',preFix + '_' + idxStr + '_action',store,dh_chooser_combo,true,false,false,false,avalue);
      block.AddInput.Describe('',prefix + '_' + idxStr + '_value',false,false,false,false,vvalue);
      block.AddInput.Describe('',prefix + '_' + idxStr + '_descr',false,false,false,false,dvalue);
    end;
  end;

begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),extDBO));

  if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,extDBO.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  CheckDbResult(conn.Fetch(extDBO.Field('telephone').AsObjectLink,telephone));

  GFRE_DBI.GetSystemEnum('voip_key_action',enum);
  store:=TFRE_DB_STORE_DESC.create.Describe();
  enumVals:=enum.getEntries;
  for i := 0 to Length(enumVals) - 1 do begin
    store.AddEntry.Describe(conn.FetchTranslateableTextShort(enumVals[i].Field('c').AsString),enumVals[i].Field('v').AsString);
  end;

  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'extension_keys_diag_cap'),600);
  group:=res.AddGroup.Describe(telephone.Field('objname').AsString,true);
  _addDescrBlock();
  _addInputBlocks('TEL',telephone.Field('keys').AsInt16);
  e:=0;
  for i := 0 to extDBO.Field('expansions').ValueCount - 1 do begin
    CheckDbResult(conn.Fetch(extDBO.Field('expansions').AsObjectLinkItem[i],relDBO));
    CheckDbResult(conn.Fetch(relDBO.Field('expansion').AsObjectLink,expDBO));
    for j := 0 to relDBO.Field('count').AsInt16 - 1 do begin
      group:=res.AddGroup.Describe(expDBO.Field('objname').AsString,true);
      _addDescrBlock();
      _addInputBlocks('EXP_' + IntToStr(e),expDBO.Field('keys').AsInt16);
      e:=e+1;
    end;
  end;

  sf:=CWSF(@WEB_StoreExtensionKeys);
  sf.AddParam.Describe('extId',extDBO.UID_String);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  Result:=res;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_StoreExtensionKeys(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  extDBO: IFRE_DB_Object;

  procedure handleField(const field: IFRE_DB_Field);
  var
    ids       : TFOSStringArray;
    i         : Integer;
    field_path: String;
  begin
    GFRE_BT.SeperateString(Field.FieldName,'_',ids);
    field_path:='KEYS';
    for i := 0 to High(ids) do begin
      field_path:=field_path + '.' + ids[i];
    end;
    extDBO.FieldPathCreate(field_path).AsString:=field.AsString
  end;

begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('extId').AsString),extDBO));

  if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,extDBO.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  input.Field('data').AsObject.ForAllFields(@handleField,false,true);
  CheckDbResult(conn.Update(extDBO));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_MangeExpansions(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  extDBO            : IFRE_DB_Object;
  used_exp          : IFRE_DB_DERIVED_COLLECTION;
  used_exp_grid     : TFRE_DB_VIEW_LIST_DESC;
  available_exp     : IFRE_DB_DERIVED_COLLECTION;
  available_exp_grid: TFRE_DB_VIEW_LIST_DESC;
  expansions        : TFRE_DB_LAYOUT_DESC;
  sf                : TFRE_DB_SERVER_FUNC_DESC;
begin
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),extDBO));

  if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,extDBO.DomainID) and conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,extDBO.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  ses.GetSessionModuleData(ClassName).Field('selectedExtension').AsGUID:=extDBO.UID;

  used_exp:=ses.FetchDerivedCollection('VOIP_EXTENSION_EXP_IN_GRID');
  used_exp_grid:=used_exp.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  available_exp:=ses.FetchDerivedCollection('VOIP_EXTENSION_EXP_OUT_GRID');
  available_exp_grid:=available_exp.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  available_exp_grid.setDropGrid(used_exp_grid);
  used_exp_grid.setDropGrid(available_exp_grid);

  available_exp_grid.AddButton.Describe(CWSF(@WEB_ConfigureExpCount),'',FetchModuleTextShort(ses,'tb_add_exp'),FetchModuleTextHint(ses,'tb_add_exp'),fdgbd_single);

  used_exp_grid.AddButton.Describe(CWSF(@WEB_RemoveExp),'',FetchModuleTextShort(ses,'tb_remove_exp'),FetchModuleTextHint(ses,'tb_remove_exp'),fdgbd_single);
  sf:=CWSF(@WEB_ConfigureExpCount);
  sf.AddParam.Describe('isModify','true');
  used_exp_grid.AddButton.Describe(sf,'',FetchModuleTextShort(ses,'tb_configure_exp'),FetchModuleTextHint(ses,'tb_configure_exp'),fdgbd_single);

  used_exp.Filters.RemoveFilter('USEDEXP');
  used_exp.Filters.AddAutoDependencyFilter('USEDEXP',['EXPANSIONS>TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL'],[extDBO.UID]);
  available_exp.Filters.RemoveFilter('USEDEXP');
  available_exp.Filters.AddAutoDependencyFilter('USEDEXP',['EXPANSIONS>TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL','EXPANSION>TFOS_DB_CITYCOM_VOIP_HARDWARE'],[extDBO.UID],false);

  expansions:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,used_exp_grid,nil,nil,available_exp_grid,true,1,1,1,1,1);

  Result:=TFRE_DB_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'manage_expansions_cap'),expansions,60);
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExtMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res    : TFRE_DB_MENU_DESC;
  func   : TFRE_DB_SERVER_FUNC_DESC;
  dbo    : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
      func:=CWSF(@WEB_ExtensionDelete);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_extension'),'',func);
    end;
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
      func:=CWSF(@WEB_ModifyExtension);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_extension'),'',func);
      if dbo.Field('type').AsString='T' then begin
        func:=CWSF(@WEB_ExtensionKeys);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_extension_keys'),'',func);
        if conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
          func:=CWSF(@WEB_MangeExpansions);
          func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
          res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_extension_expansions'),'',func);
        end;
      end;
    end;
  end;
  Result:=res;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExtSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  del_disabled : Boolean;
  mod_disabled : Boolean;
  keys_disabled: Boolean;
  dbo          : IFRE_DB_Object;
  exp_disabled : Boolean;
begin
  CheckClassVisibility4MyDomain(ses);

  del_disabled:=true;
  mod_disabled:=true;
  keys_disabled:=true;
  exp_disabled:=true;

  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
      del_disabled:=false;
    end;
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
      mod_disabled:=false;
      if dbo.Field('type').AsString='T' then begin
        keys_disabled:=false;
        if conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
          exp_disabled:=false;
        end;
      end;
    end;
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('del_extension',del_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('mod_extension',mod_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('extension_keys',keys_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('extension_expansions',exp_disabled));

  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ConfigureExpCount(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  isModify: Boolean;
  relObj  : IFRE_DB_Object;
  extObj  : IFRE_DB_Object;
  scheme  : IFRE_DB_SchemeObject;
  sf      : TFRE_DB_SERVER_FUNC_DESC;
  res     : TFRE_DB_FORM_DIALOG_DESC;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,scheme) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL]);

  isModify:=input.FieldExists('isModify') and input.Field('isModify').AsBoolean;
  sf:=CWSF(@WEB_StoreExpCount);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'configure_expansion_count_diag_cap'),600,true,true,isModify);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),relObj));
    if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,relObj.DomainID) or conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,relObj.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('relId',relObj.UID_String);
    res.FillWithObjectValues(relObj,ses);
  end else begin
    CheckDbResult(conn.Fetch(ses.GetSessionModuleData(ClassName).Field('selectedExtension').AsGUID,extObj));
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,extObj.DomainID) or conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,extObj.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    res.SetElementValue('count','1');
    sf.AddParam.Describe('extId',extObj.UID_String);
    sf.AddParam.Describe('expId',input.Field('selected').AsString);
  end;

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_StoreExpCount(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject : IFRE_DB_SchemeObject;
  relObj       : TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL;
  isNew        : Boolean;
  relColl      : IFRE_DB_COLLECTION;
  extObj       : TFOS_DB_CITYCOM_VOIP_EXTENSION;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL]);

  if input.FieldExists('relId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('relId').AsString),TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,relObj));
    if not (conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,relObj.DomainID) or conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,relObj.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('extId').AsString),TFOS_DB_CITYCOM_VOIP_EXTENSION,extObj));
    if not (conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,extObj.DomainID) or conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,extObj.DomainID)) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    relColl:=conn.GetCollection(CFOS_DB_VOIP_EXT_EXP_REL_COLLECTION);
    relObj:=TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL.CreateForDB;
    relObj.SetDomainID(extObj.DomainID);
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,relObj,isNew,conn);

  if isNew then begin
    relObj.Field('expansion').AsObjectLink:=FREDB_H2G(input.Field('expId').AsString);
    CheckDbResult(relColl.Store(relObj.CloneToNewObject()));
    extObj.Field('expansions').AddObjectLink(relObj.UID);
    CheckDbResult(conn.Update(extObj));
  end else begin
    CheckDbResult(conn.Update(relObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_RemoveExp(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  relObj : TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL;
  refs   : TFRE_DB_GUIDArray;
  extObj : IFRE_DB_Object;
  i      : Integer;
begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,relObj));
  if not (conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,relObj.DomainID) or conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,relObj.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  refs:=conn.GetReferences(relObj.UID,false,'TFOS_DB_CITYCOM_VOIP_EXTENSION','expansions');

  for i := 0 to High(refs) do begin
    CheckDbResult(conn.Fetch(refs[i],extObj));
    extObj.Field('expansions').RemoveObjectLinkByUID(relObj.UID);
    CheckDbResult(conn.Update(extObj));
  end;

  CheckDbResult(conn.Delete(relObj.UID));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExpInMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res    : TFRE_DB_MENU_DESC;
  func   : TFRE_DB_SERVER_FUNC_DESC;
  dbo    : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
      if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,dbo.DomainID) then begin
        func:=CWSF(@WEB_RemoveExp);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_remove_exp'),'',func);
      end;
      if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,dbo.DomainID) then begin
        func:=CWSF(@WEB_ConfigureExpCount);
        func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
        func.AddParam.Describe('isModify','true');
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_configure_exp'),'',func);
      end;
    end;
  end;
  Result:=res;
end;

function TFOS_CITYCOM_VOIP_EXTENSIONS_MOD.WEB_ExpOutMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res    : TFRE_DB_MENU_DESC;
  func   : TFRE_DB_SERVER_FUNC_DESC;
  dbo    : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_EXT_EXP_REL,dbo.DomainID) and conn.sys.CheckClassRight4DomainId('administer',TFOS_DB_CITYCOM_VOIP_EXTENSION,dbo.DomainID) then begin
      func:=CWSF(@WEB_ConfigureExpCount);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_add_exp'),'',func);
    end;
  end;
  Result:=res;
end;

{ TFOS_CITYCOM_VOIP_PHONEBOOK_MOD }

class procedure TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('voip_phonebook_description')
end;

class procedure TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9.1';
  if currentVersionId='' then begin
    currentVersionId := '0.9';

    CreateModuleText(conn,'voip_phonebook_description','Phonebook','Phonebook','Phonebook');

    CreateModuleText(conn,'grid_pb_lastname','Last Name');
    CreateModuleText(conn,'grid_pb_firstname','First Name');
    CreateModuleText(conn,'grid_pb_landline','Landline');
    CreateModuleText(conn,'grid_pb_mobile','Mobile');
    CreateModuleText(conn,'grid_pb_internal','Internal');

    CreateModuleText(conn,'tb_create_entry','Add');
    CreateModuleText(conn,'tb_delete_entry','Delete');
    CreateModuleText(conn,'tb_modify_entry','Modify');

    CreateModuleText(conn,'entry_create_diag_cap','Add Entry');
    CreateModuleText(conn,'entry_modify_diag_cap','Modify Entry');

    CreateModuleText(conn,'entry_delete_diag_cap','Delete Entry');
    CreateModuleText(conn,'entry_delete_diag_msg','Delete Entry "%entry_str%"');
    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
  end;
  if currentVersionId='0.9' then begin
    currentVersionId := '0.9.1';

    CreateModuleText(conn,'cm_delete_entry','Delete');
    CreateModuleText(conn,'cm_modify_entry','Modify');
  end;

end;

class procedure TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.InstallUserDBObjects4Domain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.9';

  end;
end;

class procedure TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.InstallUserDBObjects4SysDomain(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TFRE_DB_GUID);
var
  coll: IFRE_DB_COLLECTION;
begin
  inherited InstallUserDBObjects4SysDomain(conn, currentVersionId, domainUID);
  if currentVersionId='' then begin
    currentVersionId := '0.9';
    coll := conn.CreateCollection(CFOS_DB_VOIP_PHONEBOOK_COLLECTION);
  end;
  InstallUserDBObjects4Domain(conn,currentVersionId,domainUID);
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD._addModifyEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_UserSession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const isModify: Boolean): IFRE_DB_Object;
var
  scheme  : IFRE_DB_SchemeObject;
  sf      : TFRE_DB_SERVER_FUNC_DESC;
  diagCap : TFRE_DB_String;
  entryDBO: IFRE_DB_Object;
  res     : TFRE_DB_FORM_DIALOG_DESC;
  service : IFRE_DB_Object;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,scheme) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY]);

  sf:=CWSF(@WEB_StoreEntry);
  if isModify then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),entryDBO));

    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,entryDBO.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('entryId',input.Field('selected').AsString);
    diagCap:=FetchModuleTextShort(ses,'entry_modify_diag_cap');
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').AsStringItem[0]),service));

    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    sf.AddParam.Describe('serviceId',service.UID_String);
    diagCap:=FetchModuleTextShort(ses,'entry_create_diag_cap');
  end;
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(diagCap,600,true,true,isModify);
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

  if isModify then begin
    res.FillWithObjectValues(entryDBO,ses);
  end;

  Result:=res;
end;

procedure TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  pb_grid  : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('lastname','',FetchModuleTextShort(session,'grid_pb_lastname'),dt_string,true,true);
      AddOneToOnescheme('firstname','',FetchModuleTextShort(session,'grid_pb_firstname'),dt_string,true,true);
      AddOneToOnescheme('landline','',FetchModuleTextShort(session,'grid_pb_landline'),dt_string);
      AddOneToOnescheme('mobile','',FetchModuleTextShort(session,'grid_pb_mobile'),dt_string);
      AddOneToOnescheme('internal','',FetchModuleTextShort(session,'grid_pb_internal'),dt_boolean,true,true,true);
      AddFulltextFilterOnTransformed(['lastname','firstname','landline','mobile']);
    end;

    pb_grid := session.NewDerivedCollection('VOIP_PHONEBOOK_GRID');
    with pb_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_VOIP_PHONEBOOK_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',CWSF(@WEB_PBMenu),nil,CWSF(@WEB_PBSC));
      SetDefaultOrderField('lastname',true);
    end;
 end;
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc_pb  : IFRE_DB_DERIVED_COLLECTION;
  pb_grid: TFRE_DB_VIEW_LIST_DESC;
  enabled: Boolean;
  service: IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  dc_pb:=ses.FetchDerivedCollection('VOIP_PHONEBOOK_GRID');
  pb_grid:=dc_pb.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY) then begin
    enabled:=ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).FieldExists('selectedVoIP') and (ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').ValueCount=1);
    if enabled then begin
      CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(TFOS_CITYCOM_VOIP_SERVICE_MOD.ClassName).Field('selectedVoIP').AsStringItem[0]),service));
      enabled:=enabled and conn.SYS.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,service.DomainID);
    end;
    pb_grid.AddButton.DescribeManualType('add_pb_entry',CWSF(@WEB_AddEntry),'',FetchModuleTextShort(ses,'tb_create_entry'),FetchModuleTextHint(ses,'tb_create_entry'),not enabled);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY) then begin
    pb_grid.AddButton.DescribeManualType('del_pb_entry',CWSF(@WEB_EntryDelete),'',FetchModuleTextShort(ses,'tb_delete_entry'),FetchModuleTextHint(ses,'tb_delete_entry'),true);
  end;
  if conn.sys.CheckClassRight4AnyDomain(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY) then begin
    pb_grid.AddButton.DescribeManualType('mod_pb_entry',CWSF(@WEB_ModifyEntry),'',FetchModuleTextShort(ses,'tb_modify_entry'),FetchModuleTextHint(ses,'tb_modify_entry'),true);
  end;

  Result:=pb_grid;
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_AddEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_addModifyEntry(input,ses,app,conn,false);
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_EntryDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf         : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg    : String;
  entry      : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),entry));

  if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,entry.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_EntryDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'entry_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'entry_delete_diag_msg'),'%entry_str%',entry.Field('lastname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_EntryDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i       : NativeInt;
  pb_entry: IFRE_DB_Object;
begin
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),pb_entry));
      if not conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,pb_entry.DomainID) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

      CheckDbResult(conn.Delete(pb_entry.UID));
    end;
    result := GFRE_DB_NIL_DESC;
  end else begin
    result := GFRE_DB_NIL_DESC;
  end;
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_ModifyEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_addModifyEntry(input,ses,app,conn,true);
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_StoreEntry(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject : IFRE_DB_SchemeObject;
  entryObj     : TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY;
  isNew        : Boolean;
  pbColl       : IFRE_DB_COLLECTION;
  service      : IFRE_DB_Object;
begin
  if not GFRE_DBI.GetSystemScheme(TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY]);

  if input.FieldExists('entryId') then begin
    CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('entryId').AsString),TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,entryObj));
    if not conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,entryObj.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    isNew:=false;
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('serviceId').AsString),service));
    if not conn.sys.CheckClassRight4DomainId(sr_STORE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,service.DomainID) then
      raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

    pbColl:=conn.GetCollection(CFOS_DB_VOIP_PHONEBOOK_COLLECTION);
    entryObj:=TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY.CreateForDB;
    entryObj.SetDomainID(service.DomainID);
    isNew:=true;
  end;

  schemeObject.SetObjectFieldsWithScheme(input.Field('data').AsObject,entryObj,isNew,conn);

  if isNew then begin
    entryObj.Field('voip_service').AsObjectLink:=service.UID;
    CheckDbResult(pbColl.Store(entryObj));
  end else begin
    CheckDbResult(conn.Update(entryObj));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_PBMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res    : TFRE_DB_MENU_DESC;
  func   : TFRE_DB_SERVER_FUNC_DESC;
  dbo    : IFRE_DB_Object;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  if input.Field('selected').ValueCount=1 then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,dbo.DomainID) then begin
      func:=CWSF(@WEB_EntryDelete);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete_entry'),'',func);
    end;
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,dbo.DomainID) then begin
      func:=CWSF(@WEB_ModifyEntry);
      func.AddParam.Describe('selected',input.Field('selected').AsStringArr);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_modify_entry'),'',func);
    end;
  end;
  Result:=res;
end;

function TFOS_CITYCOM_VOIP_PHONEBOOK_MOD.WEB_PBSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dbo         : IFRE_DB_Object;
  del_disabled: Boolean;
  mod_disabled: Boolean;
begin
  CheckClassVisibility4MyDomain(ses);

  del_disabled:=true;
  mod_disabled:=true;

  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
    if conn.sys.CheckClassRight4DomainId(sr_DELETE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,dbo.DomainID) then begin
      del_disabled:=false;
    end;
    if conn.sys.CheckClassRight4DomainId(sr_UPDATE,TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY,dbo.DomainID) then begin
      mod_disabled:=false;
    end;
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('del_pb_entry',del_disabled));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('mod_pb_entry',mod_disabled));

  Result:=GFRE_DB_NIL_DESC;
end;

{ TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY }

class procedure TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
var
  group : IFRE_DB_InputGroupSchemeDefinition;
begin
  inherited RegisterSystemScheme(scheme);

  GFRE_DBI.RegisterSysClientFieldValidator(GFRE_DBI.NewClientFieldValidator('voip_pb_number').Setup('^[0-9\*#p+]+$',
                                           GFRE_DBI.CreateText('$voip_pb_number','Phonebook Number'),
                                           GetTranslateableTextKey('validator_pb_number'),
                                           '0-9\*#p+'));

  scheme.SetParentSchemeByName('TFRE_DB_OBJECTEX');
  scheme.AddSchemeField('voip_service',fdbft_ObjLink).required:=true;
  scheme.AddSchemeField('lastname',fdbft_String).SetupFieldDef(true);
  scheme.AddSchemeField('firstname',fdbft_String);
  scheme.AddSchemeField('landline',fdbft_String).SetupFieldDef(false,false,'','voip_pb_number');
  scheme.AddSchemeField('mobile',fdbft_String).SetupFieldDef(false,false,'','voip_pb_number');
  scheme.AddSchemeField('internal',fdbft_Boolean);

  group:=scheme.AddInputGroup('main').Setup(GetTranslateableTextKey('scheme_main_group'));
  group.AddInput('lastname',GetTranslateableTextKey('scheme_lastname'));
  group.AddInput('firstname',GetTranslateableTextKey('scheme_firstname'));
  group.AddInput('landline',GetTranslateableTextKey('scheme_landline'));
  group.AddInput('mobile',GetTranslateableTextKey('scheme_mobile'));
  group.AddInput('internal',GetTranslateableTextKey('scheme_internal'));
end;

class procedure TFOS_DB_CITYCOM_VOIP_PHONEBOOK_ENTRY.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';

  if (currentVersionId='') then begin
    currentVersionId := '0.9';

    StoreTranslateableText(conn,'scheme_main_group','General Information');

    StoreTranslateableText(conn,'scheme_lastname','Last Name');
    StoreTranslateableText(conn,'scheme_firstname','First Name');
    StoreTranslateableText(conn,'scheme_landline','Landline Nummer');
    StoreTranslateableText(conn,'scheme_mobile','Mobile Nummer');
    StoreTranslateableText(conn,'scheme_internal','Internal');

    StoreTranslateableText(conn,'validator_pb_number','0-9, +, *, # and p are allowed');
  end;
end;



end.

