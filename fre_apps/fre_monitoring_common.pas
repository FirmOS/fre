unit fre_monitoring_common;
{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON
  ;

type

  { TFRE_COMMON_WF_MOD }

  TFRE_COMMON_WF_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    procedure       SetupAppModuleStructure   ; override;
  public
    procedure       getHRState                (const ut : IFRE_DB_USER_RIGHT_TOKEN ; const transformed_object : IFRE_DB_Object ; const session_data : IFRE_DB_Object; const langres: array of TFRE_DB_String);
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object; override;
    function        WEB_GridMenu              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridSC                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_FinishWFStep          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_WFDelete              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_WFDeleteConfirmed     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_COMMON_JOBS_MOD }

  TFRE_COMMON_JOBS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
  protected
    procedure       SetupAppModuleStructure   ; override;
  public
    class procedure RegisterSystemScheme      (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content               (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object; override;
  end;

procedure Register_DB_Extensions;

implementation

{ TFRE_COMMON_JOBS_MOD }

procedure TFRE_COMMON_JOBS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('jobs_description')
end;

class procedure TFRE_COMMON_JOBS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

class procedure TFRE_COMMON_JOBS_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9';
  if currentVersionId='' then begin
    currentVersionId:='0.9';
    CreateModuleText(conn,'gc_job_caption','Caption');
    //CreateModuleText(conn,'gc_job_id','Id');
    //CreateModuleText(conn,'gc_job_state','State');
  end;
end;

procedure TFRE_COMMON_JOBS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  transform : IFRE_DB_SIMPLE_TRANSFORM;
  dc        : IFRE_DB_DERIVED_COLLECTION;
  conn      : IFRE_DB_CONNECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    conn:=session.GetDBConnection;
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('jobkey','',FetchModuleTextShort(session,'gc_job_caption'));
      AddOneToOnescheme('jobstate','',FetchModuleTextShort(session,'gc_job_state'));
      AddCollectorscheme('%s',TFRE_DB_NameTypeArray.Create('R.PROGRESS'),'PROGESS',FetchModuleTextShort(session,'gc_job_progress'));
    end;
    dc := session.NewDerivedCollection('JOBSMOD_JOBS_GRID');
    with dc do begin
      SetDeriveParent(conn.GetJobsCollection);
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'');
      //SetDefaultOrderField('step_id',true);
    end;
  end;
end;

function TFRE_COMMON_JOBS_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  Result:=ses.FetchDerivedCollection('JOBSMOD_JOBS_GRID').GetDisplayDescription;
end;

{ TFRE_COMMON_WF_MOD }

class procedure TFRE_COMMON_WF_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_COMMON_WF_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('workflows_description')
end;

procedure TFRE_COMMON_WF_MOD.getHRState(const ut: IFRE_DB_USER_RIGHT_TOKEN; const transformed_object: IFRE_DB_Object; const session_data: IFRE_DB_Object; const langres: array of TFRE_DB_String);
var fld : IFRE_DB_Field;
begin
  if transformed_object.FieldOnlyExisting('state',fld) then
    transformed_object.Field('stateHR').AsString:=langres[fld.AsInt16-1];
end;

class procedure TFRE_COMMON_WF_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.9.1';
  if currentVersionId='' then begin
    currentVersionId:='0.9';
    CreateModuleText(conn,'gc_wf_caption','Caption');
    CreateModuleText(conn,'gc_wf_id','Id');
    CreateModuleText(conn,'gc_wf_state','State');

  end;
  if currentVersionId='0.9' then begin
    currentVersionId:='0.9.1';
    CreateModuleText(conn,'gc_wf_group','Assigned group');

    CreateModuleText(conn,'wf_state_waiting','Waiting');
    CreateModuleText(conn,'wf_state_child_in_progress','Child in progress');
    CreateModuleText(conn,'wf_state_in_progress','In progress');
    CreateModuleText(conn,'wf_state_done','Done');
    CreateModuleText(conn,'wf_state_faild','Failed');

    CreateModuleText(conn,'tb_wf_step_finish','Finish step');
    CreateModuleText(conn,'cm_wf_step_finish','Finish step');

    CreateModuleText(conn,'wf_delete_diag_cap','Delete Workflow');
    CreateModuleText(conn,'wf_delete_diag_msg','Delete Workflow "%wf_str%"');
    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');
    CreateModuleText(conn,'tb_wf_delete','Delete WF');
    CreateModuleText(conn,'cm_wf_delete','Delete');
  end;
end;

procedure TFRE_COMMON_WF_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  transform : IFRE_DB_SIMPLE_TRANSFORM;
  dc        : IFRE_DB_DERIVED_COLLECTION;
  conn      : IFRE_DB_CONNECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    conn:=session.GetDBConnection;
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMultiToOnescheme(TFRE_DB_NameTypeArray.create('caption','step_caption'),'caption',FetchModuleTextShort(session,'gc_wf_caption'),dt_string,true,true);
      AddMatchingReferencedField(['<wf','customer>'],'objname','customer','',true,dt_description);
      AddOneToOnescheme('state','state','',dt_string,false);
      AddOneToOnescheme('stateHR','stateHR',FetchModuleTextShort(session,'gc_wf_state'));
      AddMatchingReferencedField('DESIGNATED_GROUP>TFRE_DB_GROUP','displayname','group',FetchModuleTextShort(session,'gc_wf_group'));
      AddOneToOnescheme('step_id','step_id',FetchModuleTextShort(session,'gc_wf_id'));
      SetFinalRightTransformFunction(@getHRState,[FetchModuleTextShort(session,'wf_state_waiting'),FetchModuleTextShort(session,'wf_state_child_in_progress'),FetchModuleTextShort(session,'wf_state_in_progress'),FetchModuleTextShort(session,'wf_state_done'),FetchModuleTextShort(session,'wf_state_faild')]);
    end;
    dc := session.NewDerivedCollection('WFMOD_WF_GRID');
    with dc do begin
      SetDeriveParent(conn.AdmGetWorkFlowCollection);
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_GridSC));
      SetParentToChildLinkField('<STEP_PARENT');
      SetDefaultOrderField('step_id',true);
    end;
  end;
end;

function TFRE_COMMON_WF_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res: TFRE_DB_VIEW_LIST_DESC;
begin
  CheckClassVisibility4AnyDomain(ses);

  res:=ses.FetchDerivedCollection('WFMOD_WF_GRID').GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  if conn.SYS.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_WORKFLOW_STEP) and conn.SYS.CheckClassRight4AnyDomain(sr_UPDATE,TFRE_DB_WORKFLOW) then begin
    res.AddButton.DescribeManualType('finish_wfs',CWSF(@WEB_FinishWFStep),'',FetchModuleTextShort(ses,'tb_wf_step_finish'),'',true);
  end;
  if conn.SYS.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_WORKFLOW_STEP) and conn.SYS.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_WORKFLOW) then begin
    res.AddButton.DescribeManualType('delete_wf',CWSF(@WEB_WFDelete),'',FetchModuleTextShort(ses,'tb_wf_delete'),'',true);
  end;

  Result:=res;
end;

function TFRE_COMMON_WF_MOD.WEB_GridSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  disableF  : Boolean;
  dbo       : IFRE_DB_Object;
  wfStep    : TFRE_DB_WORKFLOW_STEP;
  disableDel: Boolean;
begin
  disableF:=true;
  disableDel:=true;
  if input.FieldExists('selected') and (input.Field('selected').ValueCount=1) then begin
    conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo);
    if dbo.Implementor_HC is TFRE_DB_WORKFLOW_STEP then begin
      wfStep:=dbo.Implementor_HC as TFRE_DB_WORKFLOW_STEP;
      if wfStep.getState=3 then begin
        disableF:=false;
      end;
    end;
    if conn.SYS.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_WORKFLOW_STEP,dbo.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_WORKFLOW,dbo.DomainID) then begin
      if dbo.Implementor_HC is TFRE_DB_WORKFLOW then begin
        disableDel:=false;
      end;
    end;
  end;
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('delete_wf',disableDel));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('finish_wfs',disableF));
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_COMMON_WF_MOD.WEB_GridMenu(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_MENU_DESC;
  dbo   : IFRE_DB_Object;
  wfStep: TFRE_DB_WORKFLOW_STEP;
  sf    : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;
  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));
  if conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_WORKFLOW_STEP,dbo.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_WORKFLOW,dbo.DomainID) then begin
    if dbo.Implementor_HC is TFRE_DB_WORKFLOW_STEP then begin
      wfStep:=dbo.Implementor_HC as TFRE_DB_WORKFLOW_STEP;
      if wfStep.getState=3 then begin
        sf:=CWSF(@WEB_FinishWFStep);
        sf.AddParam.Describe('selected',input.Field('selected').AsString);
        res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_wf_step_finish'),'',sf);
      end;
    end;
  end;
  if conn.SYS.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_WORKFLOW_STEP,dbo.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_WORKFLOW,dbo.DomainID) then begin
    if dbo.Implementor_HC is TFRE_DB_WORKFLOW then begin
      sf:=CWSF(@WEB_WFDelete);
      sf.AddParam.Describe('selected',input.Field('selected').AsString);
      res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_wf_delete'),'',sf);
    end;
  end;
  Result:=res;
end;

function TFRE_COMMON_WF_MOD.WEB_FinishWFStep(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  wfStep: TFRE_DB_WORKFLOW_STEP;
begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_WORKFLOW_STEP,wfStep));
  if not (conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_WORKFLOW_STEP,wfStep.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_WORKFLOW,wfStep.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  wfStep.setState(conn,4);
  Result:=GFRE_DB_NIL_DESC;
end;

function TFRE_COMMON_WF_MOD.WEB_WFDelete(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf      : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg : String;
  wf      : IFRE_DB_Object;
begin
  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),wf));

  if not (conn.SYS.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_WORKFLOW_STEP,wf.DomainID) and conn.SYS.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_WORKFLOW,wf.DomainID)) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  sf:=CWSF(@WEB_WFDeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'wf_delete_diag_cap');

  msg:=StringReplace(FetchModuleTextShort(ses,'wf_delete_diag_msg'),'%wf_str%',wf.Field('caption').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFRE_COMMON_WF_MOD.WEB_WFDeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  wf: IFRE_DB_Object;
  i : Integer;

  procedure _handleChildSteps(const parent: IFRE_DB_Object);
  var
    refs    : TFRE_DB_GUIDArray;
    i       : Integer;
    childObj: IFRE_DB_Object;
  begin
    refs:=conn.GetReferences(parent.UID,false,'','step_parent');
    for i := 0 to High(refs) do begin
      CheckDbResult(conn.Fetch(refs[i],childObj));
      _handleChildSteps(childObj);
      CheckDbResult(conn.Delete(refs[i]));
    end;
  end;

begin
  Result:=GFRE_DB_NIL_DESC;
  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),wf));
      _handleChildSteps(wf);
      CheckDbResult(conn.Delete(wf.UID));
    end;
  end;
end;

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_COMMON_WF_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_COMMON_JOBS_MOD);
end;

end.
