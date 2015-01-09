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
  //fre_hal_disk_enclosure_pool_mangement,
  fre_zfs,
  //fre_scsi,
  fre_hal_schemes;
  //fre_diff_transport;

type

  { TFOS_INFRASTRUCTURE_MOD }

  TFOS_INFRASTRUCTURE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function        _canAddDS                           (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddMachine                      (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddPool                         (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddPDataset                     (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canAddZone                         (const conn: IFRE_DB_CONNECTION): Boolean;
  protected
    procedure       SetupAppModuleStructure             ; override;
  public
    procedure       CalculateIcon                       (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
    procedure       CalcMachineChooserLabel             (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    procedure       CalcPoolChooserLabel                (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    procedure       CalcDatasetChooserLabel             (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Add                             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
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

function TFOS_INFRASTRUCTURE_MOD._canAddDS(const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DATACENTER);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddMachine(const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_MACHINE);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddPool(const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_POOL);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddPDataset(const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_DATASET_PARENT);
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._canAddZone(const conn: IFRE_DB_CONNECTION): Boolean;
var
  res: Boolean;
begin
  res:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZONE);
  Result:=res;
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
    CreateModuleText(conn,'add_infrastructure_zone_template','Template');

    CreateModuleText(conn,'add_infrastructure_parent_machine_value','%machine_str% (%datacenter_str%)');
    CreateModuleText(conn,'add_infrastructure_parent_pool_value','%pool_str% (%datacenter_str%: %machine_str%)');
    CreateModuleText(conn,'add_infrastructure_parent_dataset_value','%dataset_str% (%datacenter_str%: %machine_str% - %pool_str%)');
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
    end;
    dc := session.NewDerivedCollection('TEMPLATE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_TEMPLATE_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'',TFRE_DB_StringArray.create('objname'));
      SetDefaultOrderField('objname',true);
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

  grid.AddButton.Describe(CWSF(@WEB_Add),'',FetchModuleTextShort(ses,'tb_add'));

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
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_diag_cap'),600);

  store:=TFRE_DB_STORE_DESC.create.Describe('id');
  chooser:=res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_type'),'type',store,dh_chooser_combo,true,true,true);

  if _canAddDS(conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_datacenter'),'DC');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_DATACENTER',scheme);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'dc',true,true);
    chooser.addDependentInputGroup(group,'DC');
  end;
  if _canAddMachine(conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_machine'),'M');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_MACHINE',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_datacenter'),'m.dc',ses.FetchDerivedCollection('DC_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'m',true,true);
    chooser.addDependentInputGroup(group,'M');
    chooser.addDependentInput('m.dc','M',fdv_visible);
  end;
  if _canAddPool(conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_pool'),'P');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZFS_POOL',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_machine'),'p.machine',ses.FetchDerivedCollection('MACHINE_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'p',true,true);
    chooser.addDependentInputGroup(group,'P');
    chooser.addDependentInput('p.machine','P',fdv_visible);
  end;
  if _canAddPDataset(conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_dataset'),'DS');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZFS_DATASET_PARENT',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_pool'),'ds.pool',ses.FetchDerivedCollection('POOL_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'ds',true,true);
    chooser.addDependentInputGroup(group,'DS');
    chooser.addDependentInput('ds.pool','DS',fdv_visible);
  end;
  if _canAddZone(conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_zone'),'Z');
    GFRE_DBI.GetSystemSchemeByName('TFRE_DB_ZONE',scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_dataset'),'z.ds',ses.FetchDerivedCollection('DATASET_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'z',true,true);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_zone_template'),'z.template',ses.FetchDerivedCollection('TEMPLATE_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    chooser.addDependentInputGroup(group,'Z');
    chooser.addDependentInput('z.template','Z',fdv_visible);
    chooser.addDependentInput('z.ds','Z',fdv_visible);
  end;

  Result:=res;
end;

end.

