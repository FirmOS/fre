unit fos_infrastucture_mod;

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
  FRE_DB_COMMON,fre_system,
  fre_dbbusiness,
  //fre_hal_disk_enclosure_pool_mangement,
  fre_zfs,
  //fre_scsi,
  fre_hal_schemes;
  //fre_diff_transport;

type

  { TFOS_INFRASTRUCTURE_MOD }

  TFOS_INFRASTRUCTURE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _canAddDC                           (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddMachine                      (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddPool                         (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddPDataset                     (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddZone                         (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;

    function        _storeDC                            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storeMachine                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storePool                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storeDataset                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storeZone                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  protected
    procedure       SetupAppModuleStructure             ; override;
  public
    procedure       CalculateIcon                       (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
    procedure       CalcMachineChooserLabel             (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    procedure       CalcPoolChooserLabel                (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    procedure       CalcDatasetChooserLabel             (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Add                             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Store                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;


implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  //fre_scsi.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFOS_INFRASTRUCTURE_MOD);
end;

{ TFOS_INFRASTRUCTURE_MOD }

class procedure TFOS_INFRASTRUCTURE_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

function TFOS_INFRASTRUCTURE_MOD._canAddDC(const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DATACENTER);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddMachine(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_MACHINE) and (ses.FetchDerivedCollection('DC_CHOOSER').ItemCount>0);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddPool(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_POOL) and (ses.FetchDerivedCollection('MACHINE_CHOOSER').ItemCount>0);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddPDataset(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_DATASET_PARENT) and (ses.FetchDerivedCollection('POOL_CHOOSER').ItemCount>0);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddZone(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZONE) and (ses.FetchDerivedCollection('DATASET_CHOOSER').ItemCount>0) and (ses.FetchDerivedCollection('TEMPLATE_CHOOSER').ItemCount>0);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._storeDC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  coll        : IFRE_DB_COLLECTION;
  dc          : TFRE_DB_DATACENTER;
begin
  if not _canAddDC(conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION);
  if coll.ExistsIndexed(input.Field('objname').AsString) then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_error_exists_cap'),FetchModuleTextShort(ses,'add_infrastructure_error_exists_message_dc'),fdbmt_error);
    exit;
  end;

  if not GFRE_DBI.GetSystemScheme(TFRE_DB_DATACENTER,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_DATACENTER]);

  dc:=TFRE_DB_DATACENTER.CreateForDB;
  schemeObject.SetObjectFieldsWithScheme(input,dc,true,conn);

  CheckDbResult(coll.Store(dc));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD._storeMachine(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  coll        : IFRE_DB_COLLECTION;
  machine     : TFRE_DB_MACHINE;
  dcId        : TFRE_DB_GUID;
  zone        : TFRE_DB_ZONE;
  zcoll       : IFRE_DB_COLLECTION;
  tcoll       : IFRE_DB_COLLECTION;
  gtemplate   : IFRE_DB_Object;
  halt        : Boolean;

  procedure _getGlobalTemplate(const obj : IFRE_DB_Object ; var halt : boolean);
  begin
    if (obj.Implementor_HC as TFRE_DB_FBZ_TEMPLATE).global then begin
      gtemplate:=obj;
      halt:=true;
    end;
  end;

begin
  if not _canAddMachine(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(cFRE_DB_MACHINE_COLLECTION);
  if coll.ExistsIndexed(input.Field('objname').AsString) then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_error_exists_cap'),FetchModuleTextShort(ses,'add_infrastructure_error_exists_message_machine'),fdbmt_error);
    exit;
  end;

  if not GFRE_DBI.GetSystemScheme(TFRE_DB_MACHINE,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_MACHINE]);

  tcoll:=conn.GetCollection(CFRE_DB_TEMPLATE_COLLECTION);
  gtemplate:=nil;
  halt:=false;
  tcoll.ForAllBreak(@_getGlobalTemplate,halt);
  if not Assigned(gtemplate) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'No template found for global zone');

  machine:=TFRE_DB_MACHINE.CreateForDB;
  dcId:=FREDB_H2G(input.Field('dc').AsString);
  input.DeleteField('dc');

  machine.Field('datacenterid').AsObjectLink:=dcId;
  machine.Field('mosparentIds').AsObjectLink:=dcId;
  machine.Field('serviceParent').AsObjectLink:=dcId;

  schemeObject.SetObjectFieldsWithScheme(input,machine,true,conn);

  CheckDbResult(coll.Store(machine.CloneToNewObject()));

  //create global zone
  zcoll:=conn.GetCollection(CFOS_DB_ZONES_COLLECTION);

  zone:=TFRE_DB_ZONE.CreateForDB;
  zone.ObjectName:='global';
  zone.Field('templateid').AsObjectLink:=gtemplate.UID;
  zone.Field('hostid').AsObjectLink:=machine.UID;
  zone.Field('serviceParent').AsObjectLink:=machine.UID;

  CheckDBResult(zcoll.Store(zone));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD._storePool(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  mId         : TFRE_DB_GUID;
  coll        : IFRE_DB_COLLECTION;
  pool        : TFRE_DB_ZFS_POOL;
  ds          : TFRE_DB_ZFS_DATASET_FILE;
  dcoll       : IFRE_DB_COLLECTION;
  idx         : String;
begin
  if not _canAddPool(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  dcoll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);

  idx:=input.Field('objname').AsString + '@' + input.Field('machine').AsString;

  if coll.ExistsIndexed(idx,false,'upid') then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_error_exists_cap'),FetchModuleTextShort(ses,'add_infrastructure_error_exists_message_pool'),fdbmt_error);
    exit;
  end;

  if not GFRE_DBI.GetSystemScheme(TFRE_DB_ZFS_POOL,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_ZFS_POOL]);

  pool:=TFRE_DB_ZFS_POOL.CreateForDB;
  mId:=FREDB_H2G(input.Field('machine').AsString);
  input.DeleteField('machine');

  pool.MachineID:=mId;
  pool.Field('mosparentIds').AsObjectLink:=mId;
  pool.Field('serviceParent').AsObjectLink:=mId;
  pool.Field('uniquephysicalid').AsString:=idx;
  schemeObject.SetObjectFieldsWithScheme(input,pool,true,conn);

  CheckDBResult(coll.Store(pool.CloneToNewObject()));

  //create root dataset

  ds:=TFRE_DB_ZFS_DATASET_FILE.CreateForDB;
  ds.ObjectName:=pool.ObjectName;
  ds.Field('poolid').AsObjectLink:=pool.UID;
  ds.Field('dataset').asstring:='/'+pool.ObjectName;
  ds.Field('serviceParent').AsObjectLink:=pool.UID;
  ds.Field('uniquephysicalid').AsString:=ds.Field('dataset').AsString + '@' + pool.UID_String;

  CheckDBResult(dcoll.Store(ds));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD._storeDataset(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  coll        : IFRE_DB_COLLECTION;
  idx         : String;
  schemeObject: IFRE_DB_SchemeObject;
  pool        : TFRE_DB_ZFS_POOL;
  ds          : TFRE_DB_ZFS_DATASET_FILE;
  rootDS         : IFRE_DB_Object;
begin
  if not _canAddPDataset(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);

  if not GFRE_DBI.GetSystemScheme(TFRE_DB_ZFS_DATASET_PARENT,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_ZFS_DATASET_PARENT]);

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('pool').AsString),TFRE_DB_ZFS_POOL,pool));
  input.DeleteField('pool');

  if not coll.GetIndexedObj('/'+pool.ObjectName + '@' + pool.UID_String,rootDS,'upid') then
    raise EFRE_DB_Exception.Create(edb_ERROR,'Root dataset not found.');

  ds:=TFRE_DB_ZFS_DATASET_PARENT.CreateForDB;
  ds.Field('poolid').AsObjectLink:=pool.UID;
  schemeObject.SetObjectFieldsWithScheme(input,ds,true,conn);
  ds.Field('dataset').AsString:='/'+pool.ObjectName+'/'+ds.ObjectName;
  idx:=ds.Field('dataset').AsString + '@' + pool.UID_String;

  if coll.ExistsIndexed(idx,false,'upid') then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_error_exists_cap'),FetchModuleTextShort(ses,'add_infrastructure_error_exists_message_dataset'),fdbmt_error);
    exit;
  end;
  ds.Field('serviceParent').AsObjectLink:=rootDS.UID;
  ds.Field('uniquephysicalid').AsString:=idx;

  CheckDBResult(coll.Store(ds));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD._storeZone(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not _canAddZone(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));


  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

procedure TFOS_INFRASTRUCTURE_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('infrastructure_description')
end;

procedure TFOS_INFRASTRUCTURE_MOD.CalcMachineChooserLabel(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
var
  str: String;
begin
  str:=StringReplace(langres[0],'%datacenter_str%',transformed_object.Field('dc').AsString,[rfReplaceAll]);
  str:=StringReplace(str,'%machine_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
  transformed_object.Field('label').AsString:=str;
end;

procedure TFOS_INFRASTRUCTURE_MOD.CalcPoolChooserLabel(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
var
  str: String;
begin
  str:=StringReplace(langres[0],'%datacenter_str%',transformed_object.Field('dc').AsString,[rfReplaceAll]);
  str:=StringReplace(str,'%machine_str%',transformed_object.Field('machine').AsString,[rfReplaceAll]);
  str:=StringReplace(str,'%pool_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
  transformed_object.Field('label').AsString:=str;
end;

procedure TFOS_INFRASTRUCTURE_MOD.CalcDatasetChooserLabel(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
var
  str: String;
begin
  str:=StringReplace(langres[0],'%datacenter_str%',transformed_object.Field('dc').AsString,[rfReplaceAll]);
  str:=StringReplace(str,'%machine_str%',transformed_object.Field('machine').AsString,[rfReplaceAll]);
  str:=StringReplace(str,'%pool_str%',transformed_object.Field('pool').AsString,[rfReplaceAll]);
  str:=StringReplace(str,'%dataset_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
  transformed_object.Field('label').AsString:=str;
end;

class procedure TFOS_INFRASTRUCTURE_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';

    CreateModuleText(conn,'infrastructure_description','Infrastructure','Infrastructure','Infrastructure');

    CreateModuleText(conn,'grid_name','Name');

    CreateModuleText(conn,'tb_add','Add','','Add infrastructure');

    CreateModuleText(conn,'add_infrastructure_diag_cap','Add infrastructure');
    CreateModuleText(conn,'add_infrastructure_type','Type');
    CreateModuleText(conn,'add_infrastructure_type_datacenter','Datacenter');
    CreateModuleText(conn,'add_infrastructure_type_machine','Machine');
    CreateModuleText(conn,'add_infrastructure_type_pool','Pool');
    CreateModuleText(conn,'add_infrastructure_type_dataset','Dataset');
    CreateModuleText(conn,'add_infrastructure_type_zone','Zone');

    CreateModuleText(conn,'add_infrastructure_parent_datacenter','Datacenter');
    CreateModuleText(conn,'add_infrastructure_parent_machine','Machine');
    CreateModuleText(conn,'add_infrastructure_parent_pool','Pool');
    CreateModuleText(conn,'add_infrastructure_parent_dataset','Dataset');
    CreateModuleText(conn,'add_infrastructure_customer','Customer');
    CreateModuleText(conn,'add_infrastructure_zone_template','Template');

    CreateModuleText(conn,'add_infrastructure_parent_machine_value','%machine_str% (%datacenter_str%)');
    CreateModuleText(conn,'add_infrastructure_parent_pool_value','%pool_str% (%datacenter_str%: %machine_str%)');
    CreateModuleText(conn,'add_infrastructure_parent_dataset_value','%dataset_str% (%datacenter_str%: %machine_str% - %pool_str%)');

    CreateModuleText(conn,'add_infrastructure_error_exists_cap','Error');
    CreateModuleText(conn,'add_infrastructure_error_exists_message_dc','A datacenter with the given name already exists. Please choose another name.');
    CreateModuleText(conn,'add_infrastructure_error_exists_message_machine','A machine with the given name already exists. Please choose another name.');
    CreateModuleText(conn,'add_infrastructure_error_exists_message_pool','A pool with the given name already exists on the chosen machine. Please choose another name.');
    CreateModuleText(conn,'add_infrastructure_error_exists_message_dataset','A dataset with the given name already exists on the chosen pool. Please choose another name.');
  end;
end;

class procedure TFOS_INFRASTRUCTURE_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateDiskDataCollections(conn);
  if currentVersionId='' then begin
    currentVersionId := '1.0';
  end;
end;

procedure TFOS_INFRASTRUCTURE_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app       : TFRE_DB_APPLICATION;
  conn      : IFRE_DB_CONNECTION;
  transform : IFRE_DB_SIMPLE_TRANSFORM;
  dc        : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  app  := GetEmbeddingApp;
  conn := session.GetDBConnection;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_name'),dt_string,true,false,false,1,'icon');
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      AddOneToOnescheme('icon','','',dt_string,false);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
    end;
    dc := session.NewDerivedCollection('INFRASTRUCTURE_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',nil,'');//,CWSF(@WEB_GridMenu),nil,CWSF(@WEB_GridSC));
      SetParentToChildLinkField ('<SERVICEPARENT');
      Filters.AddSchemeObjectFilter('schemes',[TFRE_DB_DATACENTER.ClassName,TFRE_DB_MACHINE.ClassName,TFRE_DB_ZFS_POOL.ClassName,TFRE_DB_ZONE.ClassName]);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('servicedomain','','',dt_string,false);
    end;
    dc := session.NewDerivedCollection('ZONE_CUSTOMER_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_CUSTOMERS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','servicedomain','','','TFRE_DB_ZONE',[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('global','','',dt_boolean,False,false,false,1,'','','false');
      AddOneToOnescheme('deprecated','','',dt_boolean,False,false,false,1,'','','false');
    end;
    dc := session.NewDerivedCollection('TEMPLATE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_TEMPLATE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
      Filters.AddBooleanFieldFilter('global','global',true,false);
      Filters.AddBooleanFieldFilter('deprecated','deprecated',true,false);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
    end;
    dc := session.NewDerivedCollection('DC_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddMatchingReferencedField(['SERVICEPARENT>TFRE_DB_DATACENTER'],'objname','dc');
      AddOneToOnescheme('label','label');
      SetFinalRightTransformFunction(@CalcMachineChooserLabel,[FetchModuleTextShort(session,'add_infrastructure_parent_machine_value')]);
    end;
    dc := session.NewDerivedCollection('MACHINE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(cFRE_DB_MACHINE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddMatchingReferencedField(['SERVICEPARENT>TFRE_DB_MACHINE','SERVICEPARENT>TFRE_DB_DATACENTER'],'objname','dc');
      AddMatchingReferencedField(['SERVICEPARENT>TFRE_DB_MACHINE'],'objname','machine');
      AddOneToOnescheme('label','label');
      SetFinalRightTransformFunction(@CalcPoolChooserLabel,[FetchModuleTextShort(session,'add_infrastructure_parent_pool_value')]);
    end;
    dc := session.NewDerivedCollection('POOL_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddMatchingReferencedField(['SERVICEPARENT>TFRE_DB_ZFS_DATASET','SERVICEPARENT>TFRE_DB_ZFS_POOL','SERVICEPARENT>TFRE_DB_MACHINE','SERVICEPARENT>TFRE_DB_DATACENTER'],'objname','dc');
      AddMatchingReferencedField(['SERVICEPARENT>TFRE_DB_ZFS_DATASET','SERVICEPARENT>TFRE_DB_ZFS_POOL','SERVICEPARENT>TFRE_DB_MACHINE'],'objname','machine');
      AddMatchingReferencedField(['SERVICEPARENT>TFRE_DB_ZFS_DATASET','SERVICEPARENT>TFRE_DB_ZFS_POOL'],'objname','pool');
      AddOneToOnescheme('label','label');
      SetFinalRightTransformFunction(@CalcDatasetChooserLabel,[FetchModuleTextShort(session,'add_infrastructure_parent_dataset_value')]);
    end;
    dc := session.NewDerivedCollection('DATASET_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('scheme',[TFRE_DB_ZFS_DATASET_PARENT.ClassName]);
    end;
  end;
end;

procedure TFOS_INFRASTRUCTURE_MOD.CalculateIcon(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
begin
  transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/classicons/'+LowerCase(transformed_object.Field('sc').AsString)+'.svg');
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc     : IFRE_DB_DERIVED_COLLECTION;
  grid   : TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc:=ses.FetchDerivedCollection('INFRASTRUCTURE_GRID');
  grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if _canAddDC(conn) or _canAddMachine(ses,conn) or _canAddPDataset(ses,conn) or _canAddPool(ses,conn) or _canAddZone(ses,conn) then begin
    grid.AddButton.Describe(CWSF(@WEB_Add),'',FetchModuleTextShort(ses,'tb_add'));
  end;

  Result:=grid;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_Add(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res    : TFRE_DB_FORM_DIALOG_DESC;
  store  : TFRE_DB_STORE_DESC;
  scheme : IFRE_DB_SchemeObject;
  chooser: TFRE_DB_INPUT_CHOOSER_DESC;
  group  : TFRE_DB_INPUT_GROUP_DESC;
begin
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_diag_cap'),600,true,true,false);

  store:=TFRE_DB_STORE_DESC.create.Describe('id');
  chooser:=res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_type'),'type',store,dh_chooser_combo,true,true,true);

  if _canAddDC(conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_datacenter'),'DC');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_DATACENTER',scheme);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'dc',true,true);
    chooser.addDependentInputGroup(group,'DC');
  end;
  if _canAddMachine(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_machine'),'M');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_MACHINE',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_datacenter'),'m.dc',ses.FetchDerivedCollection('DC_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'m',true,true);
    chooser.addDependentInputGroup(group,'M');
    chooser.addDependentInput('m.dc','M',fdv_visible);
  end;
  if _canAddPool(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_pool'),'P');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZFS_POOL',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_machine'),'p.machine',ses.FetchDerivedCollection('MACHINE_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'p',true,true);
    chooser.addDependentInputGroup(group,'P');
    chooser.addDependentInput('p.machine','P',fdv_visible);
  end;
  if _canAddPDataset(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_dataset'),'DS');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZFS_DATASET_PARENT',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_pool'),'ds.pool',ses.FetchDerivedCollection('POOL_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'ds',true,true);
    chooser.addDependentInputGroup(group,'DS');
    chooser.addDependentInput('ds.pool','DS',fdv_visible);
  end;
  if _canAddZone(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_zone'),'Z');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZONE',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_customer'),'z.customer',ses.FetchDerivedCollection('ZONE_CUSTOMER_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true,false,true);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_dataset'),'z.ds',ses.FetchDerivedCollection('DATASET_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'z',true,true);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_zone_template'),'z.template',ses.FetchDerivedCollection('TEMPLATE_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    chooser.addDependentInputGroup(group,'Z');
    chooser.addDependentInput('z.customer','Z',fdv_visible);
    chooser.addDependentInput('z.template','Z',fdv_visible);
    chooser.addDependentInput('z.ds','Z',fdv_visible);
  end;
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),CWSF(@WEB_Store),fdbbt_submit);

  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_Store(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  if not input.FieldPathExists('data.type') then raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required parameter "type"');
  case input.FieldPath('data.type').AsString of
    'DC': begin
            if not input.FieldPathExists('data.dc') then raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required data');
            Result:=_storeDC(input.FieldPath('data.dc').AsObject,ses,app,conn);
          end;
    'M' : begin
            if not input.FieldPathExists('data.m') then raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required data');
            Result:=_storeMachine(input.FieldPath('data.m').AsObject,ses,app,conn);
          end;
    'P' : begin
            if not input.FieldPathExists('data.p') then raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required data');
            Result:=_storePool(input.FieldPath('data.p').AsObject,ses,app,conn);
          end;
    'DS': begin
            if not input.FieldPathExists('data.ds') then raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required data');
            Result:=_storeDataset(input.FieldPath('data.ds').AsObject,ses,app,conn);
          end;
    'Z' : begin
            if not input.FieldPathExists('data.z') then raise EFRE_DB_Exception.Create(edb_ERROR,'Missing required data');
            Result:=_storeZone(input.FieldPath('data.z').AsObject,ses,app,conn);
          end;
    else begin
      raise EFRE_DB_Exception.Create(edb_ERROR,'Unknown infrastructure type');
    end;
  end;
end;

end.

