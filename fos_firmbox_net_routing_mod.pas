unit fos_firmbox_net_routing_mod;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils, FRE_SYSTEM,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON,
  fre_hal_schemes,fre_dbbusiness;

type

{ TFRE_FIRMBOX_NET_ROUTING_MOD }

  TFRE_FIRMBOX_NET_ROUTING_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects           (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects       (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
    procedure       SetupAppModuleStructure    ; override;
  public
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_IFSC                   (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentIF              (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_SliderChanged          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_NET_ROUTING_MOD);
end;

{ TFRE_FIRMBOX_NET_ROUTING_MOD }

class procedure TFRE_FIRMBOX_NET_ROUTING_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('net_routing_description')
end;

class procedure TFRE_FIRMBOX_NET_ROUTING_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'net_routing_description','Networks','Networks','Networks');

    CreateModuleText(conn,'grid_interfaces_cap','Interfaces');
    CreateModuleText(conn,'grid_interface','Interface');
    CreateModuleText(conn,'grid_customer','Customer');
    CreateModuleText(conn,'grid_customer_default_value','Global - Not Assigned');

    CreateModuleText(conn,'bandwidth_group','Internet Bandwidth [MBit]');
    CreateModuleText(conn,'info_if_details_select_one','Please select an Interface object to get detailed information about it.');
  end;
end;

class procedure TFRE_FIRMBOX_NET_ROUTING_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  inherited InstallUserDBObjects(conn, currentVersionId);
end;

procedure TFRE_FIRMBOX_NET_ROUTING_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  if_grid  : IFRE_DB_DERIVED_COLLECTION;
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_customer'),true,dt_string,true,true,1,'',FetchModuleTextShort(session,'grid_customer_default_value'),nil,false,'domainid');
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_interface'));
      //AddFulltextFilterOnTransformed(['objname','number']);
    end;

    if_grid := session.NewDerivedCollection('INTERFACES_GRID');
    with if_grid do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],FetchModuleTextShort(session,'grid_interfaces_cap'),nil,'',nil,nil,CWSF(@WEB_IFSC));
      Filters.AddSchemeObjectFilter('service',TFRE_DB_DATALINK.getAllDataLinkClasses);
      Orders.AddOrderDef('customer',true,false);
      //Orders.AddOrderDef('objname',true,false);
    end;
  end;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res       : TFRE_DB_LAYOUT_DESC;
  if_grid   : TFRE_DB_CONTENT_DESC;
  content   : TFRE_DB_CONTENT_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  ses.GetSessionModuleData(ClassName).DeleteField('selectedIF');

  if_grid:=ses.FetchDerivedCollection('INTERFACES_GRID').GetDisplayDescription;
  res:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(if_grid,WEB_ContentIF(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC,nil,nil,nil,true,1,2);
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_IFSC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  if input.FieldExists('selected') and (input.Field('selected').ValueCount>0)  then begin
    ses.GetSessionModuleData(ClassName).Field('selectedIF').AsStringArr:=input.Field('selected').AsStringArr;
  end else begin
    ses.GetSessionModuleData(ClassName).DeleteField('selectedIF');
  end;

  Result:=WEB_ContentIF(input,ses,app,conn);
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_ContentIF(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_CONTENT_DESC;
  ifObj : IFRE_DB_Object;
  form  : TFRE_DB_FORM_PANEL_DESC;
  scheme: IFRE_DB_SchemeObject;
  slider: TFRE_DB_FORM_PANEL_DESC;
  group : TFRE_DB_INPUT_GROUP_DESC;
begin
  if ses.GetSessionModuleData(ClassName).FieldExists('selectedIF') and (ses.GetSessionModuleData(ClassName).Field('selectedIF').ValueCount=1) then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(ses.GetSessionModuleData(ClassName).Field('selectedIF').AsStringItem[0]),ifObj));

    //editable:=conn.sys.CheckClassRight4DomainId(sr_UPDATE,ifObj.Implementor_HC.ClassType,ifObj.DomainID);

    if not GFRE_DBI.GetSystemScheme(ifObj.Implementor_HC.ClassType,scheme) then
      raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[ifObj.Implementor_HC.ClassType]);

    form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,false);
    form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
    form.FillWithObjectValues(ifObj,ses);

    if (ifObj.Field('type').AsString='internet') then begin
      slider:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,true,CWSF(@WEB_SliderChanged),500);
      slider.contentId:='slider_form';
      group:=slider.AddGroup.Describe(FetchModuleTextShort(ses,'bandwidth_group'));
      group.AddNumber.DescribeSlider('','slider',10,100,true,'20',0,10);

      res:=TFRE_DB_LAYOUT_DESC.create.Describe().SetAutoSizedLayout(nil,form,nil,slider);
    end else begin
      res:=form;
    end;
  end else begin
    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_if_details_select_one'));
  end;

  res.contentId:='IF_DETAILS';
  Result:=res;
end;

function TFRE_FIRMBOX_NET_ROUTING_MOD.WEB_SliderChanged(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var machineid : TFRE_DB_GUID;
    inp,opd    : IFRE_DB_Object;

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
           res:=TFRE_DB_MESSAGE_DESC.create.Describe('BW','SETUP OK',fdbmt_info);
         end;
       cdcs_TIMEOUT:
         begin
           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COMMUNICATION TIMEOUT SET BW',fdbmt_error); { FIXXME }
         end;
       cdcs_ERROR:
         begin
           Res := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT SET BW ['+new_input.Field('ERROR').AsString+']',fdbmt_error); { FIXXME }
         end;
     end;
     ses.SendServerClientAnswer(res,ocid);
     cnt := 0;
   end;


begin
  writeln('SWL: SLIDER CHANGED', input.DumpToString);
  inp := GFRE_DBI.NewObject;
  inp.Field('BW').Asstring :=input.field('SLIDER').asstring;
  if ses.InvokeRemoteRequestMachineMac('00:25:90:82:bf:ae','TFRE_BOX_FEED_CLIENT','UPDATEBANDWIDTH',inp,@GotAnswer,nil)=edb_OK then  //FIXXME
    begin
      Result := GFRE_DB_SUPPRESS_SYNC_ANSWER;
      exit;
    end
  else
    begin
      Result := TFRE_DB_MESSAGE_DESC.create.Describe('ERROR','COULD NOT SET BANDWIDTH',fdbmt_error); { FIXXME }
      inp.Finalize;
    end
end;

end.

