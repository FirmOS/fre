unit FRE_DBMONITORING;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$codepage utf-8}

interface

uses
  Classes, SysUtils,FOS_TOOL_INTERFACES,
  Process,

  FRE_HAL_UTILS,
  FRE_DB_COMMON,
  FRE_DBBUSINESS,
  FRE_DB_INTERFACE,
  FRE_SYSTEM,
  FRE_DB_SYSRIGHT_CONSTANTS,
  fos_dbcorebox_machine,
  fre_zfs,
  fre_alert,
  fre_process,
  fre_testcase,
  fre_do_safejob;

type

  //Monitoroverview
  //Servicegroup (z.b. Kunde)
  //Service ( z.B. Internetaccess), Betroffene Kunden, (Notiz : welche Abhängigkeiten der Services untereinander)
  //Machine/Device ( z.b. Gateway)
  //Testcase (z.B. Internettest lokales Gateway, Provider-Gateway, mehrere Hosts im Netz)

  EFOS_MONITORING_Exception=class(Exception);


  { TFRE_DB_Monitoring }

  TFRE_DB_Monitoring=class(TFRE_DB_ObjectEx)   // singleton
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
  published
    function        IMI_FullStatusUpdate(const input: IFRE_DB_Object): IFRE_DB_Object;
    function        IMI_PartialStatusUpdate(const input: IFRE_DB_Object): IFRE_DB_Object;
  end;

  { TFRE_DB_MONSYS_MOD }

  TFRE_DB_MONSYS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure; override;
  private
  published
    procedure MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
    function  IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_Update                (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_ClearFailure          (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_CheckActuality        (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_TestcaseStatus_Details(const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_TestcaseStatus_Report (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_TestcaseStatus_Troubleshooting(const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DB_MONSYS }

  TFRE_DB_MONSYS = class (TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    function        InstallAppDefaults        (const conn : IFRE_DB_SYS_CONNECTION):TFRE_DB_Errortype; override;
    procedure       _UpdateSitemap            (const session: TFRE_DB_UserSession);

  protected
    procedure       MySessionInitialize       (const session:TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
    function        ShowInApplicationChooser  (const session:TFRE_DB_UserSession): Boolean;override;
    function        CFG_ApplicationUsesRights : boolean; override;
    function        _ActualVersion            : TFRE_DB_String; override;
  public
    class procedure RegisterSystemScheme (const scheme:IFRE_DB_SCHEMEOBJECT); override;
  published
  end;

  TFRE_AlertHTMLJob = class (TFRE_DB_Testcase)
  protected
    procedure       InternalSetup               ; override;
    class procedure RegisterSystemScheme        (const scheme : IFRE_DB_SCHEMEOBJECT); override;
  public
    procedure       ExecuteTest                 ; override;
  end;

  { TFRE_DB_SCP_JOB }

  TFRE_DB_SCP_JOB=class(TFRE_DB_ObjectEx)
  protected
    procedure  InternalSetup ; override;
  published
    function   IMI_Do_the_Job       (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;
procedure DummyDoJobs;
function  GetActualMonitoring : IFRE_DB_Object;
procedure UpdateMonitoring(const conn: IFRE_DB_CONNECTION);

implementation

procedure InitializeMonitoring;
var conn  : IFRE_DB_SYS_CONNECTION;
    res   : TFRE_DB_Errortype;
    i     : integer;
    login : string;
begin
  writeln('Start Generate Usergroups Monsys');
  CONN := GFRE_DBI.NewSysOnlyConnection;
  try
    res  := CONN.Connect('admin','admin');
    if res<>edb_OK then gfre_bt.CriticalAbort('cannot connect system : %s',[CFRE_DB_Errortype[res]]);

      conn.InstallAppDefaults('monsys');

      for i := 1 to 3 do begin
        login := 'admin'+inttostr(i);
        if conn.UserExists(login) then begin
          CheckDbResult(conn.ModifyUserGroups(login,GFRE_DBI.ConstructStringArray([Get_Groupname_App_Group_Subgroup('monsys','ADMIN'),Get_Groupname_App_Group_Subgroup('monsys','USER')]),true),'cannot set user groups '+login);
        end;
        login := 'user'+inttostr(i);
        if conn.UserExists(login) then begin
          CheckDbResult(conn.ModifyUserGroups(login,GFRE_DBI.ConstructStringArray([Get_Groupname_App_Group_Subgroup('monsys','USER')]),true),'cannot set user '+login);
        end;
      end;

      CheckDbResult(conn.ModifyUserGroups('guest',GFRE_DBI.ConstructStringArray([cSYSUG_DB_GUESTS,Get_Groupname_App_Group_Subgroup('monsys','GUEST')])),'cannot set usergroups guest');

  finally
    conn.Finalize;
  end;
end;


procedure TFRE_DB_SCP_JOB.InternalSetup;
begin
  inherited InternalSetup;
  FNamedObject.ObjectName := 'SCPMONITORING';
  Field('MAX_ALLOWED_TIME').AsInt32 := 10;
end;


function TFRE_DB_SCP_JOB.IMI_Do_the_Job(const input: IFRE_DB_Object): IFRE_DB_Object;
var proc          : TFRE_Process;
    outs,errors   : string;
    res           : integer;
    statussummary : string;
    status        : string;

    function      DeleteJobs : boolean;
    var
      istrings      : IFOS_STRINGS;
      i             : integer;
    begin
      result        :=  true;
      istrings      :=  GFRE_TF.Get_FOS_Strings;
      GFRE_BT.List_Files(cFRE_JOB_RESULT_DIR,istrings,1,true);        // List All Files
//      writeln (istrings.Commatext);
      for i:= 0 to istrings.Count-1 do begin
        if DeleteFile(istrings.Items[i])=false then begin
          Field('FAILEDTODELETE').AddString(istrings.Items[i]);
          result :=false;
        end;
      end;
    end;

begin
  Field('starttime').AsDateTimeUTC:=GFRE_DT.Now_UTC;
  proc := TFRE_Process.Create(nil);
  try
    res := proc.ExecutePiped('scp',TFRE_DB_StringArray.Create('-r','-i'+cFRE_HAL_CFG_DIR+cFRE_MONITORING_KEY_FILE,cFRE_JOB_RESULT_DIR,cFRE_MONITORING_USER+'@'+cFRE_MONITORING_HOST+':'+cFRE_MONITORING_DEST_DIR),'',outs,errors);
    if res=0 then begin
      if DeleteJobs then begin
        statussummary                   := Format ('SCP TO [%s] SUCCESSFUL',[cFRE_MONITORING_HOST]);
        status                          := 'OK';
      end else begin
        statussummary                   := Format ('SCP TO [%s] SUCCESSFUL, DELETE OF FILES FAILED',[cFRE_MONITORING_HOST]);
        status                          := 'WARNING';
      end;
    end else begin
      statussummary                   := Format ('SCP FAILED RESULTCODE:[%d] OUTPUT:[%s] ERROR:[%s]',[res,outs,errors]);
      status                          := 'FAILURE';
    end;
    Field('status').AsString        := status;
    Field('statussummary').AsString := statussummary;
  finally
    proc.Free;
  end;
  Field('endtime').AsDateTimeUTC:=GFRE_DT.Now_UTC;
end;


procedure TFRE_AlertHTMLJob.InternalSetup;
begin
  inherited InternalSetup;
  Field('MAX_ALLOWED_TIME').AsInt32 := 55;
end;

class procedure TFRE_AlertHTMLJob.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;


procedure TFRE_AlertHTMLJob.ExecuteTest;
var actmon  : IFRE_DB_Object;
    html    : TStringList;
    alert   : TFRE_Alert;

  procedure Htmljobs (const fld :IFRE_DB_Field);
  var jobresult : IFRE_DB_Object;
      ihosts    : integer;
      host      : IFRE_DB_Object;
      bgcolor   : string;
  begin
    if (fld.FieldType=fdbft_Object) then begin
//      if Pos('CITYACCESS',fld.FieldName)=0 then exit;
      jobresult := fld.AsObject;
      if (jobresult.Field('information').asstring<>'') and (jobresult.FieldExists('hosts')) then begin
        html.add('<h2>'+jobresult.Field('information').asstring+'</h2>');
        html.Add('<table border="1" cellpadding="1" cellspacing="1" style="width: 100%;">');
        html.Add('<col width="100"><col width="100"><col width="100"><col width="100"><col width="100">');
        html.Add('<tbody>');
        for ihosts := 0 to jobresult.Field('hosts').Valuecount-1 do begin
          host     := jobresult.Field('hosts').AsObjectItem[ihosts];
          case host.Field('status').asstring of
            'OK'       : bgcolor := ' bgcolor="White"';
            'WARNING'  : bgcolor := ' bgcolor="Orange"';
            'FAILURE'  : bgcolor := ' bgcolor="Red"';
            else
              bgcolor := '';
          end;
          html.Add('<tr'+bgcolor+'>');
          html.Add('<td>'+host.Field('host').asstring+'</td>');
          html.Add('<td>'+host.Field('information').asstring+'</td>');
          html.Add('<td>'+jobresult.Field('starttime').asstring+'</td>');
          html.Add('<td>'+host.Field('status').asstring+'</td>');
          html.Add('<td>'+host.Field('statussummary').asstring+'</td>');
          html.Add('<td>'+host.Field('detailsummary').asstring+'</td>');
          html.Add('</tr>');
        end;
        html.Add('</tbody>');
        html.Add('</table>');
      end else begin
        html.add('<h2>'+fld.FieldName+'</h2>');
        html.Add('<table border="1" cellpadding="1" cellspacing="1" style="width: 100%;">');
        html.Add('<col width="100"><col width="100"><col width="100"><col width="100"><col width="100">');
        html.Add('<tbody>');
        case jobresult.Field('status').asstring of
          'OK'       : bgcolor := ' bgcolor="White"';
          'WARNING'  : bgcolor := ' bgcolor="Orange"';
          'FAILURE'  : bgcolor := ' bgcolor="Red"';
          else
            bgcolor := '';
        end;
        html.Add('<tr'+bgcolor+'>');
        html.Add('<td>'+jobresult.Field('starttime').asstring+'</td>');
        html.Add('<td>'+jobresult.Field('status').asstring+'</td>');
        html.Add('<td>'+jobresult.Field('statussummary').asstring+'</td>');
        html.Add('</tr>');
        html.Add('</tbody>');
        html.Add('</table>');
      end;
    end;
  end;

begin
  try
    actmon   := GetActualMonitoring;
    alert    := TFRE_Alert.Create;
    try
      alert.CheckAlerting(actmon);
      alert.SendAlerts;
    finally
      alert.Free;
    end;
//    writeln(actmon.DumpToString());
    html     := TStringList.Create;
    try
      html.Add('<html>');
      html.Add('<body>');
      actmon.ForAllFields(@htmljobs);
      html.Add('</body>');
      html.Add('</html>');
      html.SaveToFile(cFRE_HAL_CFG_DIR+'monitor.html');
    finally
      html.Free;
    end;
    SetStatus(StatusOK,'AlertHTML Done');
  except on E: Exception do begin
    SetStatus(StatusFailure,'Exception:'+E.Message);
  end; end;
end;

{ TFRE_DB_MONSYS_MOD }

class procedure TFRE_DB_MONSYS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DB_MONSYS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('monsysmod','$monitoring_description');
end;


procedure TFRE_DB_MONSYS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var dc_monitoring : IFRE_DB_DERIVED_COLLECTION;
    tr_Monitoring    : IFRE_DB_SIMPLE_TRANSFORM;

begin
  inherited;
  if session.IsInteractiveSession then begin
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Monitoring);
    with tr_Monitoring do begin
      AddOneToOnescheme('status_icon','','Status',dt_icon);
      AddMatchingReferencedField('testcase','displayname','displayname','Testfunktion');
      AddOneToOnescheme('statusupdatetime','','Statusupdate',dt_date);
      AddOneToOnescheme('statussummary','','Statusinformation');
      AddMatchingReferencedField (TFRE_DB_StringArray.Create('testcase','machine'),'objname','machine','Gerät');
      AddMatchingReferencedField (TFRE_DB_StringArray.Create('testcase','machine'),'ip','ip','IP-Adresse');
      AddMatchingReferencedField (TFRE_DB_StringArray.Create('testcase','machine'),'displayaddress','address','Aufstellungsort');
  //    AddMatchingReferencedField('status_uid','status_icon','','Icon',dt_icon);
  //    AddMatchingReferencedField('status_uid','provisioned_time','','ProvTime',dt_date);
  //    AddMatchingReferencedField('status_uid','online_time','','Last Online',dt_date);
    end;

    dc_monitoring := session.NewDerivedCollection('main_monsys');
    with dc_monitoring do begin
      SetDeriveParent(session.GetDBConnection.Collection('testcasestatus'));
      SetDeriveTransformation(tr_Monitoring);
      SetDisplayType(cdt_Listview,[cdgf_Filter,cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'Monitoring',nil,'',nil,nil,TFRE_DB_SERVER_FUNC_DESC.create.Describe(self,'TestcaseStatus_Details'));
    end;
  end;
end;

function TFRE_DB_MONSYS_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
var  dc_monitoring : IFRE_DB_DERIVED_COLLECTION;
     lvd_Monitoring   : TFRE_DB_VIEW_LIST_DESC;
begin
  dc_monitoring := GetSession(input).FetchDerivedCollection('main_monsys');
  lvd_Monitoring := dc_monitoring.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  lvd_Monitoring.AddButton.Describe(TFRE_DB_SERVER_FUNC_DESC.create.Describe(Self,'Update'),'images_apps/monitoring/update.png','Update');
  lvd_Monitoring.AddButton.Describe(TFRE_DB_SERVER_FUNC_DESC.create.Describe(Self,'CheckActuality'),'images_apps/monitoring/update.png','Check Actuality');
  lvd_Monitoring.AddButton.Describe(TFRE_DB_SERVER_FUNC_DESC.create.Describe(Self,'ClearFailure'),'images_apps/monitoring/clear.png','Clear Failure');
  result := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(lvd_Monitoring,nil,nil,nil,nil,true,1);
end;

function TFRE_DB_MONSYS_MOD.IMI_Update(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  UpdateMonitoring(GetDBConnection(input));
  result := GFRE_DB_NIL_DESC;
end;


function TFRE_DB_MONSYS_MOD.IMI_CheckActuality(const input: IFRE_DB_Object): IFRE_DB_Object;
var col       : IFRE_DB_COLLECTION;
    obj       : IFRE_DB_Object;

  procedure _checkactual(const obj:IFRE_DB_Object);
  begin
    if not obj.IsA(TFRE_DB_TestcaseStatus.ClassName) then begin
      writeln('FETCHED OBJ ',obj.UID_String,' IS BAD!');
    end else begin
      TFRE_DB_TestcaseStatus(obj.Implementor_HC).IMI_CheckActuality(input);
      GetDBConnection(input).Update(obj);
    end;
  end;

begin
  writeln('check actuality');
  col       := GetDBConnection(input).Collection('testcasestatus');
  col.ForAll(@_checkactual);
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DB_MONSYS_MOD.IMI_ClearFailure(const input: IFRE_DB_Object): IFRE_DB_Object;
var col       : IFRE_DB_COLLECTION;
    upd_guids : TFRE_DB_GUIDArray;
    i         : integer;
    obj       : IFRE_DB_Object;
begin
  col       := GetDBConnection(input).Collection('testcasestatus');
  upd_guids :=  GFRE_DBI.StringArray2GuidArray(input.Field('SELECTED').AsStringArr);
  for i:=0 to high(upd_guids) do begin
    if col.Fetch(upd_guids[i],obj) then begin
      if not obj.IsA(TFRE_DB_TestcaseStatus.ClassName) then begin
        writeln('FETCHED OBJ ',obj.UID_String,' IS BAD!');
      end else begin
        TFRE_DB_TestcaseStatus(obj.Implementor_HC).IMI_ClearStatus(input);
        GetDBConnection(input).Update(obj);
      end;
    end else begin
      writeln('Could not fetch : '+GFRE_BT.GUID_2_HexString(upd_guids[i]));
    end;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DB_MONSYS_MOD.IMI_TestcaseStatus_Details(const input: IFRE_DB_Object): IFRE_DB_Object;
var   sub     : TFRE_DB_SUBSECTIONS_DESC;
      sf      : TFRE_DB_SERVER_FUNC_DESC;
      dc      : IFRE_DB_DERIVED_COLLECTION;
begin
  if input.FieldExists('SELECTED') then begin
//    writeln(GFRE_BT.GUID_2_HexString(input.Field('SELECTED').AsGUID));
    sub := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
    sf := TFRE_DB_SERVER_FUNC_DESC.Create.Describe(Self,'TestcaseStatus_Report');
    sf.AddParam.Describe('guid',GFRE_BT.GUID_2_HexString(input.Field('SELECTED').asguid));
    sub.AddSection.Describe(sf,'Details',1);
    sf := TFRE_DB_SERVER_FUNC_DESC.Create.Describe(Self,'TestcaseStatus_Troubleshooting');
    sf.AddParam.Describe('guid',GFRE_BT.GUID_2_HexString(input.Field('SELECTED').asguid));
    sub.AddSection.Describe(sf,'Troubleshooting',2);
    result := sub;
  end;
end;

function TFRE_DB_MONSYS_MOD.IMI_TestcaseStatus_Report(const input: IFRE_DB_Object): IFRE_DB_Object;
var obj : IFRE_DB_Object;
    s   : string;
begin
//  writeln(input.DumpToString);
  if GetDBConnection(input).Fetch(GFRE_BT.HexString_2_GUID(input.Field('guid').AsString),obj) then begin
    s      := obj.Field('actual_result').AsObject.DumpToString;
    s      := FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+s+'</pre>');
    result := TFRE_DB_HTML_DESC.create.Describe(s);
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('NO RESULT');
  end;
end;

function TFRE_DB_MONSYS_MOD.IMI_TestcaseStatus_Troubleshooting(const input: IFRE_DB_Object): IFRE_DB_Object;
var obj : IFRE_DB_Object;
    s   : string;
begin
//  writeln('trouble');
  if GetDBConnection(input).Fetch(GFRE_BT.HexString_2_GUID(input.Field('guid').AsString),obj) then begin
    if GetDBConnection(input).Fetch(obj.Field('testcase').AsGUID,obj) then begin
      s      :=obj.Field('troubleshooting').Asstring;
      s      := '<code>'+StringReplace(s,LineEnding,'<br />',[rfReplaceAll])+'</code>';
      result := TFRE_DB_HTML_DESC.create.Describe(s);
    end;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('NO INFORMATION');
  end;
end;


{ TFRE_DB_MONSYS }

procedure TFRE_DB_MONSYS.SetupApplicationStructure;
begin
  InitAppDesc('monsys','$description');
  AddApplicationModule(TFRE_DB_MONSYS_MOD.create);
end;

function TFRE_DB_MONSYS.InstallAppDefaults(const conn: IFRE_DB_SYS_CONNECTION): TFRE_DB_Errortype;
var admin_app_rg  : IFRE_DB_ROLE;
     user_app_rg  : IFRE_DB_ROLE;
     guest_app_rg : IFRE_DB_ROLE;
     old_version  : TFRE_DB_String;
begin

  case _CheckVersion(conn,old_version) of
   NotInstalled : begin
                     _SetAppdataVersion(conn,_ActualVersion);
                     admin_app_rg  := _CreateAppRole('ADMIN','MONSYS ADMIN','Monitoring System Administration Rights');
                     user_app_rg   := _CreateAppRole('USER','MONSYS USER','Monitoring System Default User Rights');
                     guest_app_rg  := _CreateAppRole('GUEST','MONSYS GUEST','Monitoring System Default User Rights');
                     _AddAppRight(admin_app_rg,'ADMIN','MONSYS Admin','Administration of Monitoring System');
                     _AddAppRight(user_app_rg ,'START','MONSYS Start','Startup of Monitoring System');
                     _AddAppRight(guest_app_rg ,'START','MONSYS Start','Startup of Monitoring System');

                     _AddAppRightModules(admin_app_rg,GFRE_DBI.ConstructStringArray(['monsysmod']));
                     conn.StoreRole(ObjectName,cSYS_DOMAIN,admin_app_rg);
                     conn.StoreRole(ObjectName,cSYS_DOMAIN,guest_app_rg);
                     conn.StoreRole(ObjectName,cSYS_DOMAIN,user_app_rg);

                     _AddSystemGroups(conn,cSYS_DOMAIN);

                     CreateAppText(conn,'$description','Monitoring','Monitoring','Monitoring');
                     CreateAppText(conn,'$monitoring_description','Monitoring','Monitoring','Monitoring');
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

procedure TFRE_DB_MONSYS._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Monitoring','Monitoring','images_apps/monitoring/monitor_white.svg','',0,CheckAppRightModule(conn,'monsysmod'));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(ObjectName).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_DB_MONSYS.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_DB_MONSYS.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  _UpdateSitemap(session);
end;

function TFRE_DB_MONSYS.ShowInApplicationChooser(const session: TFRE_DB_UserSession): Boolean;
begin
  Result := true;
end;

function TFRE_DB_MONSYS.CFG_ApplicationUsesRights: boolean;
begin
  Result:=true;
end;

function TFRE_DB_MONSYS._ActualVersion: TFRE_DB_String;
begin
  Result:='1.0';
end;

class procedure TFRE_DB_MONSYS.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
  scheme.AddSchemeFieldSubscheme('monsysmod'      , 'TFRE_DB_MONSYS_MOD');
end;

{ TFRE_DB_Monitoring }

class procedure TFRE_DB_Monitoring.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName  ('TFRE_DB_OBJECTEX');
end;

function TFRE_DB_Monitoring.IMI_FullStatusUpdate(const input: IFRE_DB_Object): IFRE_DB_Object;

  procedure _dopartialupdate(const fld : IFRE_DB_Field);
  begin
//    writeln(fld.FieldName);
    if (fld.FieldType = fdbft_Object) then begin
      fld.AsObject.Field('jobkey').AsString := fld.FieldName;
      IMI_PartialStatusUpdate(fld.AsObject);
    end;
  end;

begin
  input.ForAllFields(@_dopartialupdate);
end;

function TFRE_DB_Monitoring.IMI_PartialStatusUpdate(const input: IFRE_DB_Object): IFRE_DB_Object;
var jobkey              : string;
    coll_testcase       : IFRE_DB_COLLECTION;
    testcase_dbo        : IFRE_DB_Object;
    testcase_status_ids : TFRE_DB_GUIDArray;
    testcase_status_dbo : IFRE_DB_Object;
    itcs                : integer;
begin
  jobkey        := input.Field('jobkey').AsString;
  coll_testcase := GetDBConnection.Collection('testcase',true);
  if coll_testcase.GetIndexedObj(jobkey,testcase_dbo) then begin
    testcase_status_ids := testcase_dbo.ReferencedByList('TFRE_DB_TestcaseStatus');
    for itcs := low(testcase_status_ids) to high(testcase_status_ids) do begin
      GetDBConnection.Fetch(testcase_status_ids[itcs],testcase_status_dbo);
      if testcase_status_dbo.Field('actual').AsBoolean = true then begin
        TFRE_DB_TestcaseStatus(testcase_status_dbo.Implementor_HC).IMI_UpdateActualStatus(input);
      end;
    end;
  end else begin
    raise EFOS_MONITORING_Exception.Create('TESTCASE WITH JOBKEY DOES NOT EXIST :'+jobkey);  // TODO LOG
  end;
end;


procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_Monitoring);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MONSYS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MONSYS);
  GFRE_DBI.RegisterObjectClassEx(TFRE_AlertHTMLJob);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_SCP_JOB);
  GFRE_DBI.Initialize_Extension_Objects;
end;

procedure DummyDoJobs;
begin
  //DO_SaveJob('MONFOS_INTERNETTESTCASE',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZPOOL_FOS_LIVEPOOL',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_MAILKSM',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_MAILKSM_CHECK',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_WINRM_KSM_SBS',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZPOOL_KSM_LIVEPOOL',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZFS_REPL_KSMLINUX',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZFS_REPL_KSMLINUXCHECK',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_KSM_SBS_FILESHARE',cFRE_HAL_CFG_DIR+'jobs.dbo');
  DO_SaveJob('MONFOS_CITYACCESS_AP_CITYBEACH',cFRE_HAL_CFG_DIR+'jobs.dbo');
  DO_SaveJob('MONFOS_CITYACCESS_AP_JOANNEUM',cFRE_HAL_CFG_DIR+'jobs.dbo');
end;

function GetActualMonitoring : IFRE_DB_Object;
var
  istrings      : IFOS_STRINGS;
  i             : integer;
  job           : IFRE_DB_Object;
  nowt          : int64;
  newname       : string;
  dir           : string;

begin
  result        := GFRE_DBI.NewObject;
  istrings      :=  GFRE_TF.Get_FOS_Strings;


  GFRE_BT.List_Files(cFRE_JOB_RESULT_DIR,istrings,1,true);        // List All Files
  if istrings.Count>0 then begin
    nowt         := GFRE_DT.Now_UTC;
    dir          := cFRE_JOB_ARCHIVE_DIR+DirectorySeparator+inttostr(nowt);
    ForceDirectories(dir);
  end;

  for i:= 0 to istrings.Count-1 do begin
    job := GFRE_DBI.CreateFromFile(istrings[i]);
    result.Field(job.Field('objname').asstring).asobject := job.Field('R').asobject;
    newname := StringReplace(istrings[i],cFRE_JOB_RESULT_DIR,dir,[]);
    if RenameFile(istrings[i],newname)=false then begin
      raise EFOS_MONITORING_Exception.Create('CANT RENAME JOB '+istrings[i]+' '+newname);;
    end;
  end;

end;

procedure UpdateMonitoring(const conn: IFRE_DB_CONNECTION);
var
  actmon        : IFRE_DB_Object;
  coll_mon      : IFRE_DB_COLLECTION;
  mon           : IFRE_DB_Object;


  function _getmon(const obj:IFRE_DB_Object):boolean;
  begin
    mon    := obj;
    result := true;
  end;

begin
  actmon        :=  GetActualMonitoring;

  coll_mon  := CONN.Collection('monitoring');
//  writeln ('COUNT:',coll_mon.Count);
  coll_mon.ForAllBreak(@_getmon);
//  writeln(mon.DumpToString);

  TFRE_DB_Monitoring(mon.Implementor_HC).IMI_FullStatusUpdate(actmon);
end;

procedure MONSYS_MetaRegister;
begin
  FRE_DBBUSINESS.Register_DB_Extensions;
  fre_testcase.Register_DB_Extensions;
  fos_dbcorebox_machine.Register_DB_Extensions;
  FRE_DBMONITORING.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;
end;

procedure MONSYS_MetaInitializeDatabase(const dbname: string; const user, pass: string);
begin
  writeln('METAINIT MONSYS');
  InitializeMonitoring;
//  CreateDB(true);
end;

procedure MONSYS_MetaRemove(const dbname: string; const user, pass: string);
var conn  : IFRE_DB_SYS_CONNECTION;
    res   : TFRE_DB_Errortype;
begin
  CONN := GFRE_DBI.NewSysOnlyConnection;
  try
    res  := CONN.Connect('admin','admin');
    if res<>edb_OK then gfre_bt.CriticalAbort('cannot connect system : %s',[CFRE_DB_Errortype[res]]);
    conn.RemoveApp('monsys');
  finally
    conn.Finalize;
  end;
end;

initialization
  GFRE_DBI_REG_EXTMGR.RegisterNewExtension('MONSYS',@MONSYS_MetaRegister,@MONSYS_MetaInitializeDatabase,@MONSYS_MetaRemove);

end.

