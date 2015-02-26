unit fos_mos_monitoring_mod;

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
  fre_monitoring;

type

  { TFOS_CITYCOM_MOS_BASE_MOD }

  TFOS_CITYCOM_MOS_BASE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    function  _getMOSObjContent (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function  _getMOSObjMenu    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_CITYCOM_MOS_LOGICAL_MOD }

  TFOS_CITYCOM_MOS_LOGICAL_MOD = class (TFOS_CITYCOM_MOS_BASE_MOD)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);override;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridMenu                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridSC                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFOS_CITYCOM_MOS_PHYSICAL_MOD }

  TFOS_CITYCOM_MOS_PHYSICAL_MOD = class (TFOS_CITYCOM_MOS_BASE_MOD)
  protected
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure             ; override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);override;
  public
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    procedure       CalculateIcon                       (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object;const langres: array of TFRE_DB_String);
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentGrid                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentGraph                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_MObjSC                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;


implementation

procedure Register_DB_Extensions;
begin
  fre_monitoring.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_MOS_LOGICAL_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_CITYCOM_MOS_PHYSICAL_MOD);

  //GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_CITYCOM_MOS_BASE_MOD }

function TFOS_CITYCOM_MOS_BASE_MOD._getMOSObjContent(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_CONTENT_DESC;
  mosObj: IFRE_DB_Object;
  scheme: IFRE_DB_SchemeObject;
  ig    : IFRE_DB_InputGroupSchemeDefinition;
  form  : TFRE_DB_FORM_PANEL_DESC;
begin
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),mosObj));
    writeln('SWL: MOSOBJ',mosobj.DumpToString());
    if mosObj.MethodExists('MOSContent') then begin
      res:=mosObj.Invoke('MOSContent',input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC;
    end else begin
      try
        if GFRE_DBI.GetSystemScheme(mosObj.Implementor_HC.ClassType,scheme) then begin
          ig:=scheme.GetInputGroup('main');
          form:=TFRE_DB_FORM_PANEL_DESC.create.Describe(FetchModuleTextShort(ses,'info_content_main'),true,false);
          form.AddSchemeFormGroup(ig,ses);
          form.FillWithObjectValues(mosObj,ses);
          res:=form;
        end else begin
          res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_content_no_details'));
        end;
      except
        on E:Exception do begin
          res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_content_no_details'));
        end;
      end;
    end;
  end else begin
    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_content_select_one'));
  end;
  res.contentId:='MOS_OBJ_CONTENT';
  Result:=res;
end;

function TFOS_CITYCOM_MOS_BASE_MOD._getMOSObjMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  mosObj: IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1)  then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),mosObj));
    if mosObj.MethodExists('MOSMenu') then begin
      Result:=mosObj.Invoke('MOSMenu',input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC;
    end else begin
      Result:=GFRE_DB_NIL_DESC;
    end;
  end;
end;

{ TFOS_CITYCOM_MOS_PHYSICAL_MOD }

class procedure TFOS_CITYCOM_MOS_PHYSICAL_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_CITYCOM_MOS_PHYSICAL_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('physical_description')
end;

class procedure TFOS_CITYCOM_MOS_PHYSICAL_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';

    CreateModuleText(conn,'physical_description','Physical','Physical','Physical');

    CreateModuleText(conn,'section_grid_cap','Detail');
    CreateModuleText(conn,'section_graph_cap','Graph');
    CreateModuleText(conn,'error_monitoring_struct_file','Error on reading the monitoring structure file. Please place a valid structure.svg file into the binary directoy.');
    CreateModuleText(conn,'grid_name','Name');
    CreateModuleText(conn,'grid_status','Status');
    CreateModuleText(conn,'info_content_select_one','Please select one object to get detailed information about it.');
    CreateModuleText(conn,'info_content_no_details','There are no details available for the selected object.');
    CreateModuleText(conn,'info_content_main','Main Information');
  end;
end;

class procedure TFOS_CITYCOM_MOS_PHYSICAL_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateServicesCollections(conn);
end;

procedure TFOS_CITYCOM_MOS_PHYSICAL_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_name'),dt_string,true,false,false,true,1,'icon');
      AddPluginField(TFRE_DB_ZONESTATUS_PLUGIN,'ZSTATE','',FetchModuleTextShort(session,'grid_status'));
      //AddOneToOnescheme('status','',FetchModuleTextShort(session,'grid_status'));
      //AddStatisticToOnescheme('status','',FetchModuleTextShort(session,'grid_status'));
      AddOneToOnescheme('icon','','',dt_string,false);
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
      //SetStatisticTransformationFunction(@StatisticFields); { set fields }
    end;
    dc := session.NewDerivedCollection('MONITORING_PHYSICAL_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',nil,nil,CWSF(@WEB_MObjSC));
      SetParentToChildLinkField ('<SERVICEPARENT',[TFRE_DB_ZFS_DATASET_FILE.ClassName]);
    end;
  end;
end;

procedure TFOS_CITYCOM_MOS_PHYSICAL_MOD.CalculateIcon(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
begin
  transformed_object.Field('icon').AsString:=FREDB_getThemedResource('images_apps/classicons/'+LowerCase(transformed_object.Field('sc').AsString)+'.svg');
end;

function TFOS_CITYCOM_MOS_PHYSICAL_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_SUBSECTIONS_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedObj');

  res:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  res.AddSection.Describe(CWSF(@WEB_ContentGrid),FetchModuleTextShort(ses,'section_grid_cap'),1);
  res.AddSection.Describe(CWSF(@WEB_ContentGraph),FetchModuleTextShort(ses,'section_graph_cap'),2);
  Result:=res;
end;

function TFOS_CITYCOM_MOS_PHYSICAL_MOD.WEB_ContentGrid(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc  : IFRE_DB_DERIVED_COLLECTION;
  grid: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc:=ses.FetchDerivedCollection('MONITORING_PHYSICAL_GRID');
  grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  Result:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,grid,_getMOSObjContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,true,-1,1,1);
end;

function TFOS_CITYCOM_MOS_PHYSICAL_MOD.WEB_ContentGraph(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  try
    Result:=TFRE_DB_SVG_DESC.create.Describe(GFRE_BT.StringFromFile('structure.svg'),'monitoring_structure');
  except
    on E:Exception do begin
      Result:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'error_monitoring_struct_file'));
    end;
  end;
end;

function TFOS_CITYCOM_MOS_PHYSICAL_MOD.WEB_MObjSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dbo: IFRE_DB_Object;
begin
  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedObj').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedObj');
  end;

  Result:=_getMOSObjContent(input,ses,app,conn);
end;

{ TFOS_CITYCOM_MOS_LOGICAL_MOD }

class procedure TFOS_CITYCOM_MOS_LOGICAL_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_CITYCOM_MOS_LOGICAL_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('logical_description')
end;

class procedure TFOS_CITYCOM_MOS_LOGICAL_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
  if currentVersionId='' then begin
    currentVersionId := '1.0';

    CreateModuleText(conn,'logical_description','Logical','Logical','Logical');

    CreateModuleText(conn,'grid_name','Name');
    CreateModuleText(conn,'grid_status','Status');

    CreateModuleText(conn,'info_content_select_one','Please select one object to get detailed information about it.');
    CreateModuleText(conn,'info_content_no_details','There are no details available for the selected object.');
  end;
end;

class procedure TFOS_CITYCOM_MOS_LOGICAL_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateMonitoringCollections(conn);
end;

procedure TFOS_CITYCOM_MOS_LOGICAL_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
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
      AddOneToOnescheme('caption_mos','',FetchModuleTextShort(session,'grid_name'));
      AddOneToOnescheme('status','',FetchModuleTextShort(session,'grid_status'));
    end;
    dc := session.NewDerivedCollection('MONITORING_LOGICAL_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_MOS_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_GridSC));
      SetParentToChildLinkField ('<MOSPARENTIDS');
    end;
  end;
end;

function TFOS_CITYCOM_MOS_LOGICAL_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dc     : IFRE_DB_DERIVED_COLLECTION;
  grid   : TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc:=ses.FetchDerivedCollection('MONITORING_LOGICAL_GRID');
  grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  Result:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(nil,grid,_getMOSObjContent(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,true,-1,1,1);
end;

function TFOS_CITYCOM_MOS_LOGICAL_MOD.WEB_GridMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=_getMOSObjMenu(input,ses,app,conn);
end;

function TFOS_CITYCOM_MOS_LOGICAL_MOD.WEB_GridSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  Result:=_getMOSObjContent(input,ses,app,conn);
end;

end.

