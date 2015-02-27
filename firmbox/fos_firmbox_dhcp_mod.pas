unit fos_firmbox_dhcp_mod;

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

{ TFRE_FIRMBOX_DHCP_MOD }

  TFRE_FIRMBOX_DHCP_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure    ; override;
  public
    class procedure RegisterSystemScheme       (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects           (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    procedure       MySessionInitializeModule  (const session : TFRE_DB_UserSession);override;
    function        canAddDHCP                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
  published
    function        WEB_Content                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_ContentGeneral         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentTemplates       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ContentHosts           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_AddDHCP                (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_CreateDHCP             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  GFRE_DBI.RegisterObjectClassEx(TFRE_FIRMBOX_DHCP_MOD);
end;

{ TFRE_FIRMBOX_DHCP_MOD }

class procedure TFRE_FIRMBOX_DHCP_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_FIRMBOX_DHCP_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('dhcp_description')
end;

class procedure TFRE_FIRMBOX_DHCP_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    CreateModuleText(conn,'dhcp_description','DHCP','DHCP','DHCP');

    CreateModuleText(conn,'general_tab','General');
    CreateModuleText(conn,'hosts_tab','Ranges/Hosts');
    CreateModuleText(conn,'templates_tab','Templates');

    CreateModuleText(conn,'service_grid_objname','Name');
    CreateModuleText(conn,'service_grid_zone','Zone');

    CreateModuleText(conn,'tb_create_dhcp','Add');

    CreateModuleText(conn,'dhcp_new_caption','New DHCP Server');

    CreateModuleText(conn,'zone_chooser_label','Zone');
    CreateModuleText(conn,'zone_chooser_value','%zone_str% (%customer_str%)');
    CreateModuleText(conn,'zone_chooser_value_no_customer','%zone_str%');
  end;
end;

procedure TFRE_FIRMBOX_DHCP_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var
  app      : TFRE_DB_APPLICATION;
  conn     : IFRE_DB_CONNECTION;
  transform: IFRE_DB_SIMPLE_TRANSFORM;
  dc       : IFRE_DB_DERIVED_COLLECTION;

  procedure _setCaption(const input,transformed_object : IFRE_DB_Object;const langres: TFRE_DB_StringArray);
  var
    str: String;
  begin
    if transformed_object.Field('customer').AsString<>'' then begin
      str:=StringReplace(langres[0],'%zone_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
      str:=StringReplace(str,'%customer_str%',transformed_object.Field('customer').AsString,[rfReplaceAll]);
    end else begin
      str:=StringReplace(langres[1],'%zone_str%',transformed_object.Field('objname').AsString,[rfReplaceAll]);
    end;
    transformed_object.Field('label').AsString:=str;
  end;

begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin
    app  := GetEmbeddingApp;
    conn := session.GetDBConnection;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname');
      AddOneToOnescheme('label');
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_string,true,true,1,'','',nil,false,'domainid');
      AddMatchingReferencedField(['TEMPLATEID>TFRE_DB_FBZ_TEMPLATE'],'serviceclasses');
      AddMatchingReferencedField(['TFRE_DB_DHCP<SERVICEPARENT'],'uid','dhcp','',false,dt_string,false,false,1,'','OK');
      AddOneToOnescheme('disabledSCs');
      SetSimpleFuncTransformNested(@_setCaption,[FetchModuleTextShort(session,'zone_chooser_value'),FetchModuleTextShort(session,'zone_chooser_value_no_customer')]);
    end;

    dc := session.NewDerivedCollection('DHCP_ZONE_CHOOSER');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_ZONES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Chooser,[],'');
      SetDefaultOrderField('objname',true);
      Filters.AddStdClassRightFilter('rights','domainid','','',TFRE_DB_DHCP.ClassName,[sr_STORE],session.GetDBConnection.SYS.GetCurrentUserTokenClone);
      Filters.AddStringFieldFilter('serviceclasses','serviceclasses',TFRE_DB_DHCP.ClassName,dbft_EXACTVALUEINARRAY);
      Filters.AddStringFieldFilter('disabledSCs','disabledSCs',TFRE_DB_DHCP.ClassName,dbft_EXACTVALUEINARRAY,false,true);
      Filters.AddStringFieldFilter('used','dhcp','OK',dbft_EXACT);
    end;

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'service_grid_objname'));
      AddMatchingReferencedFieldArray(['SERVICEPARENT>TFRE_DB_ZONE'],'objname','zone',FetchModuleTextShort(session,'service_grid_zone'));
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer','',true,dt_description,false,false,1,'','',nil,false,'domainid');
    end;

    dc := session.NewDerivedCollection('DHCP_SERVICES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox],'',nil,nil);//,CWSF(@WEB_ServiceSC));
      //SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('service',[TFRE_DB_DHCP.ClassName]);
    end;

  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.canAddDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION; const zone: TFRE_DB_ZONE): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_STORE,TFRE_DB_DHCP,zone.DomainID);
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  subs        : TFRE_DB_SUBSECTIONS_DESC;
  dc          : IFRE_DB_DERIVED_COLLECTION;
  servicesDC  : IFRE_DB_DERIVED_COLLECTION;
  layout      : TFRE_DB_LAYOUT_DESC;
  servicesGrid: TFRE_DB_VIEW_LIST_DESC;
  service     : IFRE_DB_Object;
begin
  CheckClassVisibility4AnyDomain(ses);

  //frg:=ses.FetchDerivedCollection('FIREWALL_RULES_GRID');
  //frg.Filters.RemoveFilter('service');
  //fng:=ses.FetchDerivedCollection('FIREWALL_NAT_GRID');
  //fng.Filters.RemoveFilter('service');
  //fpg:=ses.FetchDerivedCollection('FIREWALL_POOLS_GRID');
  //fpg.Filters.RemoveFilter('service');
  //ses.GetSessionModuleData(ClassName).DeleteField('selectedFirewall');

  subs:=TFRE_DB_SUBSECTIONS_DESC.Create.Describe();
  subs.AddSection.Describe(CWSF(@WEB_ContentGeneral),FetchModuleTextShort(ses,'general_tab'),1);
  subs.AddSection.Describe(CWSF(@WEB_ContentHosts),FetchModuleTextShort(ses,'hosts_tab'),2);
  subs.AddSection.Describe(CWSF(@WEB_ContentTemplates),FetchModuleTextShort(ses,'templates_tab'),3);
  servicesDC:=ses.FetchDerivedCollection('DHCP_SERVICES_GRID');
  if (Length(conn.sys.GetDomainsForClassRight(sr_FETCH,TFRE_DB_DHCP))>1) or //multidomain
     conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP) or           //can add service
     (servicesDC.ItemCount>1) then begin                                    //has more than one service
    layout:=TFRE_DB_LAYOUT_DESC.create.Describe();
    servicesGrid:=servicesDC.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
    if conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DHCP) then begin
      servicesGrid.AddButton.Describe(CWSF(@WEB_AddDHCP),'',FetchModuleTextShort(ses,'tb_create_dhcp'));
    end;
    layout.SetLayout(servicesGrid,subs);
    Result:=layout;
  end else begin
    if servicesDC.ItemCount=1 then begin //set service filters
      service:=servicesDC.First;
      //ses.GetSessionModuleData(ClassName).Field('selectedFirewall').AsGUID:=service.UID;
      //frg.Filters.AddUIDFieldFilter('service','fw_uid',[service.UID],dbnf_OneValueFromFilter);
      //fng.Filters.AddUIDFieldFilter('service','fw_uid',[service.UID],dbnf_OneValueFromFilter);
      //fpg.Filters.AddUIDFieldFilter('service','fw_uid',[service.UID],dbnf_OneValueFromFilter);
    end else begin
      //frg.Filters.AddUIDFieldFilter('service','fw_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
      //fng.Filters.AddUIDFieldFilter('service','fw_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
      //fpg.Filters.AddUIDFieldFilter('service','fw_uid',[CFRE_DB_NullGUID],dbnf_OneValueFromFilter);
    end;
    Result:=subs;
  end;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ContentGeneral(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('GENERAL');
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ContentTemplates(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('TEMPLATES');
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_ContentHosts(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  Result:=TFRE_DB_HTML_DESC.create.Describe('HOSTS');
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_AddDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_FORM_DIALOG_DESC;
  sf    : TFRE_DB_SERVER_FUNC_DESC;
  zoneId: TFRE_DB_String;
  zone  : TFRE_DB_ZONE;
  scheme: IFRE_DB_SchemeObject;
begin
  CheckClassVisibility4MyDomain(ses);

  GetSystemScheme(TFRE_DB_DHCP,scheme);
  res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(FetchModuleTextShort(ses,'dhcp_new_caption'),600,true,true,false);

  sf:=CWSF(@WEB_CreateDHCP);

  if input.FieldPathExists('data.zone') then begin
    zoneId:=input.FieldPath('data.zone').AsString;
  end else begin
    if input.FieldExists('zoneId') then begin
      zoneId:=input.Field('zoneId').AsString;
      sf.AddParam.Describe('zoneId',zoneId);

      CheckDbResult(conn.FetchAs(FREDB_H2G(zoneId),TFRE_DB_ZONE,zone));
      if not canAddDHCP(input,ses,app,conn,zone) then
        raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));
    end else begin
      res.AddChooser.Describe(FetchModuleTextShort(ses,'zone_chooser_label'),'zone',ses.FetchDerivedCollection('DHCP_ZONE_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true);
    end;
  end;
  res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'',true,true);
  res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  Result:=res;
end;

function TFRE_FIRMBOX_DHCP_MOD.WEB_CreateDHCP(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zoneId  : TFRE_DB_String;
  zone    : TFRE_DB_ZONE;
  scheme  : IFRE_DB_SchemeObject;
  dhcp    : TFRE_DB_DHCP;
begin
  if input.FieldPathExists('data.zone') then begin
    zoneId:=input.FieldPath('data.zone').AsString;
    input.Field('data').AsObject.DeleteField('zone');
  end else begin
    if input.FieldExists('zoneId') then begin
      zoneId:=input.Field('zoneId').AsString;
    end else begin
      raise EFRE_DB_Exception.Create('Missing parameter: data.zone or zoneId');
    end;
  end;

  CheckDbResult(conn.FetchAs(FREDB_H2G(zoneId),TFRE_DB_ZONE,zone));
  if not canAddDHCP(input,ses,app,conn,zone) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  GetSystemScheme(TFRE_DB_DHCP,scheme);
  dhcp:=TFRE_DB_DHCP.CreateForDB;
  dhcp.SetDomainID(zone.DomainID);
  dhcp.Field('serviceParent').AsObjectLink:=zone.UID;
  dhcp.Field('uniquephysicalid').AsString:=TFRE_DB_DHCP.ClassName + '@' + zone.UID_String;
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,dhcp,true,conn);

  CheckDbResult(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION).Store(dhcp));
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

end.

