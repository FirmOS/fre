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
  fre_hal_schemes,
  fos_citycom_voip_mod,
  fos_firmbox_pool_mod;
  //fre_diff_transport;

type

  { TFOS_INFRASTRUCTURE_MOD }

  TFOS_INFRASTRUCTURE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  private
    fStoragePoolsMod                                    : TFOS_FIRMBOX_POOL_MOD;
    fVoIPMod                                            : TFOS_CITYCOM_VOIP_SERVICE_MOD;
    function        _canAddDC                           (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeleteDC                        (const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeleteDC                        (const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
    function        _canAddMachine                      (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeleteMachine                   (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeleteMachine                   (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
    function        _canAddPool                         (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeletePool                      (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeletePool                      (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
    function        _canAddPDataset                     (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeletePDataset                  (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeletePDataset                  (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
    function        _canAddZone                         (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeleteZone                      (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
    function        _canDeleteZone                      (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;

    function        _canDelete                          (const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const id: String): Boolean;

    function        _fillDSObj                          (const dsObj: TFRE_DB_ZFS_DATASET;const poolId: TFRE_DB_GUID; const parentPath: String; const serviceParent: TFRE_DB_GUID; const coll: IFRE_DB_COLLECTION=nil):Boolean;
    function        _storeDC                            (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storeMachine                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storePool                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storeDataset                       (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _storeZone                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        _deleteDC                           (const dbo:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _deleteMachine                      (const dbo:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _deletePool                         (const dbo:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _deleteDataset                      (const dbo:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _deleteZone                         (const dbo:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):Boolean;
    function        _getDetails                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):TFRE_DB_CONTENT_DESC;
    function        _getZoneDetails                     (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):TFRE_DB_CONTENT_DESC;
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
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;override;
    function        WEB_Add                             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Store                           (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridMenu                        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_GridSC                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_Delete                          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_DeleteConfirmed                 (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;

    function        WEB_ZoneContentConfiguration        (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_ZoneContentServices             (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreZoneConfiguration          (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_AddService                      (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_StoreService                    (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;


implementation

procedure Register_DB_Extensions;
begin
  fre_hal_schemes.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  //fre_scsi.Register_DB_Extensions;
  fos_firmbox_pool_mod.Register_DB_Extensions;

  GFRE_DBI.RegisterObjectClassEx(TFOS_INFRASTRUCTURE_MOD);
end;

{ TFOS_INFRASTRUCTURE_MOD }

class procedure TFOS_INFRASTRUCTURE_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

function TFOS_INFRASTRUCTURE_MOD._canAddDC(const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_DATACENTER);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeleteDC(const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_DATACENTER);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeleteDC(const conn: IFRE_DB_CONNECTION;const dId: TFRE_DB_GUID): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_DATACENTER,dId);
end;

function TFOS_INFRASTRUCTURE_MOD._canAddMachine(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_MACHINE) and conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZONE) and (ses.FetchDerivedCollection('DC_CHOOSER').ItemCount>0);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeleteMachine(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_MACHINE) and conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZONE);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeleteMachine(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_MACHINE,dId) and conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_ZONE,dId);
end;

function TFOS_INFRASTRUCTURE_MOD._canAddPool(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_POOL) and conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_DATASET_FILE) and (ses.FetchDerivedCollection('MACHINE_CHOOSER').ItemCount>0);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeletePool(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_POOL) and conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_DATASET_FILE);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeletePool(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_ZFS_POOL,dId) and conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_ZFS_DATASET_FILE,dId);
end;

function TFOS_INFRASTRUCTURE_MOD._canAddPDataset(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_DATASET_PARENT) and (ses.FetchDerivedCollection('POOL_CHOOSER').ItemCount>0);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeletePDataset(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_DATASET_PARENT);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeletePDataset(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION;const dId: TFRE_DB_GUID): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_ZFS_DATASET_PARENT,dId);
end;

function TFOS_INFRASTRUCTURE_MOD._canAddZone(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZONE) and conn.sys.CheckClassRight4AnyDomain(sr_STORE,TFRE_DB_ZFS_DATASET_FILE) and (ses.FetchDerivedCollection('DATASET_CHOOSER').ItemCount>0) and (ses.FetchDerivedCollection('TEMPLATE_CHOOSER').ItemCount>0);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeleteZone(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZONE) and conn.sys.CheckClassRight4AnyDomain(sr_DELETE,TFRE_DB_ZFS_DATASET_FILE);
end;

function TFOS_INFRASTRUCTURE_MOD._canDeleteZone(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const dId: TFRE_DB_GUID): Boolean;
begin
  Result:=conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_ZONE,dId) and conn.sys.CheckClassRight4DomainId(sr_DELETE,TFRE_DB_ZFS_DATASET_FILE,dId);
end;

function TFOS_INFRASTRUCTURE_MOD._canDelete(const ses: IFRE_DB_Usersession; const conn: IFRE_DB_CONNECTION; const id: String): Boolean;
var
  dbo   : IFRE_DB_Object;
  rcount: NativeInt;
  hcObj : TObject;
  dcoll : IFRE_DB_COLLECTION;
  dsObj : IFRE_DB_Object;
  pObj  : IFRE_DB_Object;
begin
  Result:=false;
  CheckDbResult(conn.Fetch(FREDB_H2G(id),dbo));

  hcObj:=dbo.Implementor_HC;

  if hcObj is TFRE_DB_DATACENTER then begin
    if _canDeleteDC(conn,dbo.DomainID) then begin
      rcount:=conn.GetReferencesCount(dbo.UID,false);
      if rcount=0 then begin
        Result:=true;
      end;
    end;
  end else
  if hcObj is TFRE_DB_MACHINE then begin
    if _canDeleteDC(conn,dbo.DomainID) then begin
      rcount:=conn.GetReferencesCount(dbo.UID,false,TFRE_DB_ZFS_POOL.ClassName,'seviceParent');
      if rcount=0 then begin
        Result:=true;
      end;
    end;
  end else
  if hcObj is TFRE_DB_ZFS_POOL then begin
    if _canDeletePool(ses,conn,dbo.DomainID) then begin
      if (hcObj as TFRE_DB_ZFS_POOL).getIsNew then begin
        dcoll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);
        dcoll.GetIndexedObjText('/'+dbo.Field('objname').AsString + '@' + dbo.UID_String,dsObj,false,'upid');
        rcount:=conn.GetReferencesCount(dsObj.UID,false);
        if rcount=0 then begin
          Result:=true;
        end;
      end;
    end;
  end else
  if hcObj is TFRE_DB_ZFS_DATASET_PARENT then begin
    if _canDeletePDataset(ses,conn,dbo.DomainID) then begin
      rcount:=conn.GetReferencesCount(dbo.UID,false);
      if rcount=0 then begin
        Result:=true;
      end;
    end;
  end else
  if hcObj is TFRE_DB_ZONE then begin
    CheckDbResult(conn.Fetch(dbo.Field('serviceParent').AsObjectLink,pObj));
    if not (pObj.Implementor_HC is TFRE_DB_MACHINE) then begin //global zone
      if _canDeleteZone(ses,conn,dbo.DomainID) then begin
        Result:=true;
      end;
    end;
  end;
end;

function TFOS_INFRASTRUCTURE_MOD._fillDSObj(const dsObj: TFRE_DB_ZFS_DATASET; const poolId: TFRE_DB_GUID; const parentPath: String; const serviceParent: TFRE_DB_GUID; const coll: IFRE_DB_COLLECTION): Boolean;
var
  idx: String;
begin
  dsObj.Field('poolid').AsObjectLink:=poolId;
  dsObj.Field('dataset').AsString:=parentPath + '/' + dsObj.ObjectName;
  idx:=dsObj.Field('dataset').AsString + '@' + FREDB_G2H(poolId);

  if Assigned(coll) then begin
    if coll.ExistsIndexedText(idx,false,'upid')<>0 then begin
      Result:=false;
      exit;
    end;
  end;
  dsObj.Field('serviceParent').AsObjectLink:=serviceParent;
  dsObj.Field('uniquephysicalid').AsString:=idx;
  Result:=true;
end;

function TFOS_INFRASTRUCTURE_MOD._storeDC(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  coll        : IFRE_DB_COLLECTION;
  dc          : TFRE_DB_DATACENTER;
begin
  if not _canAddDC(conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION);
  if coll.ExistsIndexedText(input.Field('objname').AsString)<>0 then begin
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
  var
    tObj: TFRE_DB_FBZ_TEMPLATE;
  begin
    tObj:=(obj.Implementor_HC as TFRE_DB_FBZ_TEMPLATE);
    if tObj.global and not tObj.deprecated then begin
      gtemplate:=obj;
      halt:=true;
    end;
  end;

begin
  if not _canAddMachine(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetMachinesCollection;
  if coll.ExistsIndexedText(input.Field('objname').AsString)<>0 then begin
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
  zone.Field('uniquephysicalid').AsString:=zone.ObjectName+'@'+machine.UID_String;

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
  dstore      : TFRE_DB_ZFS_DATASTORAGE;
  vcoll       : IFRE_DB_COLLECTION;
begin
  if not _canAddPool(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);
  dcoll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);

  idx:=input.Field('objname').AsString + '@' + input.Field('machine').AsString;

  if coll.ExistsIndexedText(idx,false,'upid')<>0 then begin
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

  pool.setIsNew();
  dstore:=pool.createDatastorage;
  dstore.SetName(pool.GetName);
  dstore.setIsNew;
  vcoll:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);

  CheckDBResult(coll.Store(pool.CloneToNewObject()));
  CheckDbResult(vcoll.Store(dstore));

  //create root dataset

  ds:=TFRE_DB_ZFS_DATASET_FILE.CreateForDB;
  ds.ObjectName:=pool.ObjectName;
  _fillDSObj(ds,pool.UID,'',pool.UID);
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
  rootDS      : IFRE_DB_Object;
begin
  if not _canAddPDataset(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);

  if not GFRE_DBI.GetSystemScheme(TFRE_DB_ZFS_DATASET_PARENT,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_ZFS_DATASET_PARENT]);

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('pool').AsString),TFRE_DB_ZFS_POOL,pool));
  input.DeleteField('pool');

  if coll.GetIndexedObjText('/'+pool.ObjectName + '@' + pool.UID_String,rootDS,false,'upid')=0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'Root dataset not found.');

  ds:=TFRE_DB_ZFS_DATASET_PARENT.CreateForDB;
  schemeObject.SetObjectFieldsWithScheme(input,ds,true,conn);
  if not _fillDSObj(ds,pool.UID,rootDS.Field('dataset').AsString,rootDS.UID,coll) then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_error_exists_cap'),FetchModuleTextShort(ses,'add_infrastructure_error_exists_message_dataset'),fdbmt_error);
    exit;
  end;
  CheckDBResult(coll.Store(ds));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD._storeZone(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  schemeObject: IFRE_DB_SchemeObject;
  coll        : IFRE_DB_COLLECTION;
  ds          : TFRE_DB_ZFS_DATASET_PARENT;
  customer    : IFRE_DB_Object;
  sdomain     : TFRE_DB_GUID;
  zone        : TFRE_DB_ZONE;
  pool        : TFRE_DB_ZFS_POOL;
  dcoll       : IFRE_DB_COLLECTION;
  domainsDS   : TFRE_DB_ZFS_DATASET_FILE;
  sdomainDS   : TFRE_DB_ZFS_DATASET_FILE;
  dbo         : IFRE_DB_Object;
  idx         : String;
  zoneDS      : TFRE_DB_ZFS_DATASET_FILE;
begin
  if not _canAddZone(ses,conn) then raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  coll:=conn.GetCollection(CFOS_DB_ZONES_COLLECTION);
  dcoll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);

  if not GFRE_DBI.GetSystemScheme(TFRE_DB_ZONE,schemeObject) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'the scheme [%s] is unknown!',[TFRE_DB_ZONE]);

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('ds').AsString),TFRE_DB_ZFS_DATASET_PARENT,ds));
  input.DeleteField('ds');

  zone:=TFRE_DB_ZONE.CreateForDB;
  if input.FieldExists('customer') then begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('customer').AsString),customer));
    if not customer.FieldExists('servicedomain') then
      raise EFRE_DB_Exception.Create(edb_ERROR,'The given customer has no service domain set!');

    input.DeleteField('customer');
    sdomain:=customer.Field('servicedomain').AsObjectLink;
  end else begin
    if input.FieldExists('domainId') then begin
      sdomain:=FREDB_H2G(input.Field('domainId').AsString);
    end else begin
      raise EFRE_DB_Exception.Create(edb_ERROR,'No domain id given for the new zone!');
    end;
  end;
  zone.SetDomainID(sdomain);
  schemeObject.SetObjectFieldsWithScheme(input,zone,true,conn);

  CheckDbResult(conn.FetchAs(ds.Field('poolid').AsObjectLink,TFRE_DB_ZFS_POOL,pool));
  zone.Field('hostid').AsObjectLink:=pool.Field('serviceParent').AsObjectLink;

  if dcoll.GetIndexedObjText(ds.Field('dataset').AsString + '/domains@' + pool.UID_String,dbo,false,'upid')=0 then begin //domains DS
    domainsDS:=TFRE_DB_ZFS_DATASET_FILE.CreateForDB;
    domainsDS.ObjectName:='domains';
    _fillDSObj(domainsDS,pool.UID,ds.Field('dataset').AsString,ds.UID);
    CheckDBResult(dcoll.Store(domainsDS.CloneToNewObject()));
  end else begin
    domainsDS:=dbo.Implementor_HC as TFRE_DB_ZFS_DATASET_FILE;
  end;

  if dcoll.GetIndexedObjText(domainsDS.Field('dataset').AsString + '/' + FREDB_G2H(sdomain)+'@' + pool.UID_String,dbo,false,'upid')=0 then begin //service domain DS
    sdomainDS:=TFRE_DB_ZFS_DATASET_FILE.CreateForDB;
    sdomainDS.ObjectName:=FREDB_G2H(sdomain);
    _fillDSObj(sdomainDS,pool.UID,domainsDS.Field('dataset').AsString,domainsDS.UID);
    CheckDBResult(dcoll.Store(sdomainDS.CloneToNewObject()));
  end else begin
    sdomainDS:=dbo.Implementor_HC as TFRE_DB_ZFS_DATASET_FILE;
  end;

  idx:=zone.ObjectName + '@' + FREDB_G2H(sdomain);

  if coll.ExistsIndexedText(idx,false,'upid')<>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'add_infrastructure_error_exists_cap'),FetchModuleTextShort(ses,'add_infrastructure_error_exists_message_zone'),fdbmt_error);
    exit;
  end;
  zone.Field('uniquephysicalid').AsString:=idx;

  zoneDS:=TFRE_DB_ZFS_DATASET_FILE.CreateForDB;
  zoneDS.ObjectName:=zone.ObjectName;
  _fillDSObj(zoneDS,pool.UID,sdomainDS.Field('dataset').AsString,sdomainDS.UID);
  CheckDBResult(dcoll.Store(zoneDS.CloneToNewObject()));

  zone.Field('serviceParent').AsObjectLink:=zoneDS.UID;

  CheckDBResult(coll.Store(zone));

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.Create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD._deleteDC(const dbo: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  CheckDbResult(conn.Delete(dbo.UID));
end;

function TFOS_INFRASTRUCTURE_MOD._deleteMachine(const dbo: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): Boolean;
var
  zcoll: IFRE_DB_COLLECTION;
  zObj : IFRE_DB_Object;
begin
  Result:=true;
  //delete global zone
  zcoll:=conn.GetCollection(CFOS_DB_ZONES_COLLECTION);
  zcoll.GetIndexedObjText('global@' + dbo.UID_String,zObj,false,'upid');
  CheckDbResult(conn.Delete(zObj.UID));
  //delete machine
  CheckDbResult(conn.Delete(dbo.UID));
end;

function TFOS_INFRASTRUCTURE_MOD._deletePool(const dbo: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): Boolean;
var
  dcoll   : IFRE_DB_COLLECTION;
  dObj    : IFRE_DB_Object;
  tmpInput: IFRE_DB_Object;
begin
  Result:=true;
  //delete root dataset
  dcoll:=conn.GetCollection(CFRE_DB_ZFS_DATASET_COLLECTION);
  dcoll.GetIndexedObjText('/' + dbo.Field('objname').AsString + '@' + dbo.UID_String,dObj,false,'upid');
  CheckDbResult(conn.Delete(dObj.UID));
  //delete pool
  fStoragePoolsMod.removeNew(TFRE_DB_StringArray.create(dbo.UID_String),ses,conn);
end;

function TFOS_INFRASTRUCTURE_MOD._deleteDataset(const dbo: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): Boolean;
begin
  Result:=true;
  CheckDbResult(conn.Delete(dbo.UID));
end;

function TFOS_INFRASTRUCTURE_MOD._deleteZone(const dbo: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): Boolean;
var
  dsObj          : IFRE_DB_Object;
  domainObj      : IFRE_DB_Object;
  domainsObj     : IFRE_DB_Object;
  refCount       : NativeInt;
  refCountDomains: NativeInt;
begin
  Result:=true;
  //delete zone
  CheckDbResult(conn.Fetch(dbo.Field('serviceParent').AsObjectLink,dsObj));
  CheckDbResult(conn.Delete(dbo.UID));
  //delete zone dataset
  CheckDbResult(conn.Fetch(dsObj.Field('serviceParent').AsObjectLink,domainObj));
  CheckDbResult(conn.Delete(dsObj.UID));
  //delete domain if empty
  refCount:=conn.GetReferencesCount(domainObj.UID,false,TFRE_DB_ZFS_DATASET_FILE.ClassName,'serviceParent');
  if refCount=0 then begin;
    CheckDbResult(conn.Fetch(domainObj.Field('serviceParent').AsObjectLink,domainsObj));
    CheckDbResult(conn.Delete(domainObj.UID));
    //delete domains if empty
    refCountDomains:=conn.GetReferencesCount(domainsObj.UID,false,TFRE_DB_ZFS_DATASET_FILE.ClassName,'serviceParent');
    if refCountDomains=0 then begin
      CheckDbResult(conn.Delete(domainsObj.UID));
    end;
  end;
end;

function TFOS_INFRASTRUCTURE_MOD._getDetails(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): TFRE_DB_CONTENT_DESC;
var
  res   : TFRE_DB_CONTENT_DESC;
  dbo   : IFRE_DB_Object;
  scheme: IFRE_DB_SchemeObject;
  form  : TFRE_DB_FORM_PANEL_DESC;
  hcObj: TObject;
begin
  if not input.FieldExists('selected') or (input.Field('selected').ValueCount<>1) then begin
    res:=TFRE_DB_HTML_DESC.create.Describe(FetchModuleTextShort(ses,'info_details_select_one'));
  end else begin
    CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsString),dbo));

    hcObj:=dbo.Implementor_HC;
    if hcObj is TFRE_DB_ZFS_POOL then begin
      res:=fStoragePoolsMod.WEB_Content(input,ses,app,conn).Implementor_HC as TFRE_DB_CONTENT_DESC;
    end else
    if hcObj is TFRE_DB_ZONE then begin
      res:=_getZoneDetails(input,ses,app,conn);
    end else begin
      form:=TFRE_DB_FORM_PANEL_DESC.create.Describe('',true,false);
      GFRE_DBI.GetSystemSchemeByName(dbo.Implementor_HC.ClassName,scheme);
      form.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);
      form.FillWithObjectValues(dbo,ses);

      res:=form;
    end;
  end;
  res.contentId:='infrastructureDetails';
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD._getZoneDetails(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): TFRE_DB_CONTENT_DESC;
var
  res: TFRE_DB_SUBSECTIONS_DESC;
  sf : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_SUBSECTIONS_DESC.create.Describe();
  sf:=CWSF(@WEB_ZoneContentServices);
  sf.AddParam.Describe('selected',input.Field('selected').AsString);
  res.AddSection.Describe(sf,FetchModuleTextShort(ses,'zone_services_tab'),1);
  sf:=CWSF(@WEB_ZoneContentConfiguration);
  sf.AddParam.Describe('selected',input.Field('selected').AsString);
  res.AddSection.Describe(sf,FetchModuleTextShort(ses,'zone_config_tab'),2);
  Result:=res;
end;

procedure TFOS_INFRASTRUCTURE_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  fStoragePoolsMod:=TFOS_FIRMBOX_POOL_MOD.create;
  AddApplicationModule(fStoragePoolsMod);
  fVoIPMod:=TFOS_CITYCOM_VOIP_SERVICE_MOD.create;
  AddApplicationModule(fVoIPMod);
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

    CreateModuleText(conn,'tb_add','Add');
    CreateModuleText(conn,'tb_delete','Delete');
    CreateModuleText(conn,'cm_delete','Delete');

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
    CreateModuleText(conn,'add_infrastructure_error_exists_message_zone','A zone with the given name already exists for the given domain. Please choose another name.');

    CreateModuleText(conn,'delete_diag_cap','Remove Infrastructure');
    CreateModuleText(conn,'delete_diag_msg','Remove infrastructure object "%object_str%"?');
    CreateModuleText(conn,'error_delete_single_select','Exactly one object has to be selected for deletion.');

    CreateModuleText(conn,'info_details_select_one','Please select an object to get detailed information about it.');

    CreateModuleText(conn,'zone_services_tab','Services');
    CreateModuleText(conn,'zone_config_tab','Configuration');
    CreateModuleText(conn,'zone_config_form_caption','Available Services');
    CreateModuleText(conn,'zone_config_save_error_cap','Error');
    CreateModuleText(conn,'zone_config_save_error_msg','Error saving zone configuration. Following service(s) are already in use and cannot be disabled: %services_str%');

    CreateModuleText(conn,'grid_service_name','Name');
    CreateModuleText(conn,'tb_add_service','Add');
    CreateModuleText(conn,'add_service_diag_cap','Add %service_str%');
    CreateModuleText(conn,'service_create_error_exists_cap','Error: Add service');
    CreateModuleText(conn,'service_create_error_exists_msg','A %service_str% service with the given name already exists!');
  end;
end;

class procedure TFOS_INFRASTRUCTURE_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  CreateDiskDataCollections(conn);
  CreateServicesCollections(conn);
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
      AddMatchingReferencedField(['TFOS_DB_CITYCOM_CUSTOMER<SERVICEDOMAIN'],'objname','customer',FetchModuleTextShort(session,'grid_nameserver_customer'),true,dt_description,true,true,1,'','',nil,false,'domainid');
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      AddOneToOnescheme('icon','','',dt_string,false);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
    end;
    dc := session.NewDerivedCollection('INFRASTRUCTURE_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[cdgf_Children],'',nil,'',CWSF(@WEB_GridMenu),nil,CWSF(@WEB_GridSC));
      SetParentToChildLinkField ('<SERVICEPARENT',[TFRE_DB_ZFS_DATASET_FILE.ClassName]);
      Filters.AddSchemeObjectFilter('schemes',[TFRE_DB_DATACENTER.ClassName,TFRE_DB_MACHINE.ClassName,TFRE_DB_ZFS_POOL.ClassName,TFRE_DB_ZONE.ClassName,TFRE_DB_ZFS_DATASET_PARENT.ClassName,TFRE_DB_ZFS_DATASET_FILE.ClassName]);
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
      SetDeriveParent(conn.GetMachinesCollection);
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

    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,transform);
    with transform do begin
      AddOneToOnescheme('objname','',FetchModuleTextShort(session,'grid_service_name'),dt_string,true,false,false,1,'icon');
      AddOneToOnescheme('schemeclass','sc','',dt_string,false);
      AddOneToOnescheme('icon','','',dt_string,false);
      SetFinalRightTransformFunction(@CalculateIcon,[]);
    end;

    dc := session.NewDerivedCollection('ZONE_SERVICES_GRID');
    with dc do begin
      SetDeriveParent(conn.GetCollection(CFOS_DB_SERVICES_COLLECTION));
      SetDeriveTransformation(transform);
      SetDisplayType(cdt_Listview,[],'',nil,'',nil,nil);
      SetDefaultOrderField('objname',true);
      Filters.AddSchemeObjectFilter('schemes',TFRE_DB_DATALINK.getAllDataLinkClasses,false);
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
  layout : TFRE_DB_LAYOUT_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  dc:=ses.FetchDerivedCollection('INFRASTRUCTURE_GRID');
  grid:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  if _canAddDC(conn) or _canAddMachine(ses,conn) or _canAddPDataset(ses,conn) or _canAddPool(ses,conn) or _canAddZone(ses,conn) then begin
    grid.AddButton.Describe(CWSF(@WEB_Add),'',FetchModuleTextShort(ses,'tb_add'));
  end;
  if _canDeleteDC(conn) or _canDeleteMachine(ses,conn) or _canDeletePDataset(ses,conn) or _canDeletePool(ses,conn) or _canDeleteZone(ses,conn) then begin
    grid.AddButton.DescribeManualType('tb_delete',CWSF(@WEB_Delete),'',FetchModuleTextShort(ses,'tb_delete'),'',true);
  end;

  layout:=TFRE_DB_LAYOUT_DESC.create.Describe().SetLayout(grid,_getDetails(input,ses,app,conn));

  Result:=layout;
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
    GFRE_DBI.GetSystemSchemeByName(TFRE_DB_DATACENTER.ClassName,scheme);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'dc',true,true);
    chooser.addDependentInputGroup(group,'DC');
  end;
  if _canAddMachine(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_machine'),'M');
    GFRE_DBI.GetSystemSchemeByName(TFRE_DB_MACHINE.ClassName,scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_datacenter'),'m.dc',ses.FetchDerivedCollection('DC_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'m',true,true);
    chooser.addDependentInputGroup(group,'M');
    chooser.addDependentInput('m.dc','M',fdv_visible);
  end;
  if _canAddPool(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_pool'),'P');
    GFRE_DBI.GetSystemSchemeByName(TFRE_DB_ZFS_POOL.ClassName,scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_machine'),'p.machine',ses.FetchDerivedCollection('MACHINE_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'p',true,true);
    chooser.addDependentInputGroup(group,'P');
    chooser.addDependentInput('p.machine','P',fdv_visible);
  end;
  if _canAddPDataset(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_dataset'),'DS');
    GFRE_DBI.GetSystemSchemeByName(TFRE_DB_ZFS_DATASET_PARENT.ClassName,scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_pool'),'ds.pool',ses.FetchDerivedCollection('POOL_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'ds',true,true);
    chooser.addDependentInputGroup(group,'DS');
    chooser.addDependentInput('ds.pool','DS',fdv_visible);
  end;
  if _canAddZone(ses,conn) then begin
    store.AddEntry.Describe(FetchModuleTextShort(ses,'add_infrastructure_type_zone'),'Z');
    GFRE_DBI.GetSystemSchemeByName(TFRE_DB_ZONE.ClassName,scheme);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_customer'),'z.customer',ses.FetchDerivedCollection('ZONE_CUSTOMER_CHOOSER').GetStoreDescription.Implementor_HC as TFRE_DB_STORE_DESC,dh_chooser_combo,true,false,true);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_parent_dataset'),'z.ds',ses.FetchDerivedCollection('DATASET_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    group:=res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses,false,false,'z',true,true);
    res.AddChooser.Describe(FetchModuleTextShort(ses,'add_infrastructure_zone_template'),'z.templateid',ses.FetchDerivedCollection('TEMPLATE_CHOOSER').GetStoreDescription as TFRE_DB_STORE_DESC,dh_chooser_combo,true,true,true);
    chooser.addDependentInputGroup(group,'Z');
    chooser.addDependentInput('z.customer','Z',fdv_visible);
    chooser.addDependentInput('z.templateid','Z',fdv_visible);
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

function TFOS_INFRASTRUCTURE_MOD.WEB_GridMenu(const input: IFRE_DB_Object;const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION;const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  res   : TFRE_DB_MENU_DESC;
  sf    : TFRE_DB_SERVER_FUNC_DESC;
begin
  res:=TFRE_DB_MENU_DESC.create.Describe;

  if _canDelete(ses,conn,input.Field('selected').AsString) then begin
    sf:=CWSF(@WEB_Delete);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    res.AddEntry.Describe(FetchModuleTextShort(ses,'cm_delete'),'',sf);
  end;
  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_GridSC(const input: IFRE_DB_Object;const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  dDisabled: Boolean;
begin
  dDisabled:=not (input.FieldExists('selected') and _canDelete(ses,conn,input.Field('selected').AsString));
  ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('tb_delete',dDisabled));
  Result:=_getDetails(input,ses,app,conn);
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_Delete(const input: IFRE_DB_Object;const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION;const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  cap,msg     : String;
  dbo         : IFRE_DB_Object;
begin
  if not _canDelete(ses,conn,input.Field('selected').AsString) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.Field('selected').ValueCount<>1 then raise EFRE_DB_Exception.Create(FetchModuleTextShort(ses,'error_delete_single_select'));

  sf:=CWSF(@WEB_DeleteConfirmed);
  sf.AddParam.Describe('selected',input.Field('selected').AsStringArr);
  cap:=FetchModuleTextShort(ses,'delete_diag_cap');

  CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[0]),dbo));
  msg:=StringReplace(FetchModuleTextShort(ses,'delete_diag_msg'),'%object_str%',dbo.Field('objname').AsString,[rfReplaceAll]);
  Result:=TFRE_DB_MESSAGE_DESC.create.Describe(cap,msg,fdbmt_confirm,sf);
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_DeleteConfirmed(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  i    : NativeInt;
  dbo  : IFRE_DB_Object;
  hcObj: TObject;
begin
  if not _canDelete(ses,conn,input.Field('selected').AsString) then
     raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if input.field('confirmed').AsBoolean then begin
    for i:= 0 to input.Field('selected').ValueCount-1 do begin
      CheckDbResult(conn.Fetch(FREDB_H2G(input.Field('selected').AsStringArr[i]),dbo));
      hcObj:=dbo.Implementor_HC;
      if hcObj is TFRE_DB_DATACENTER then begin
        _deleteDC(dbo,ses,app,conn);
      end else
      if hcObj is TFRE_DB_MACHINE then begin
       _deleteMachine(dbo,ses,app,conn);
      end else
      if hcObj is TFRE_DB_ZFS_POOL then begin
        _deletePool(dbo,ses,app,conn);
      end else
      if hcObj is TFRE_DB_ZFS_DATASET_PARENT then begin
        _deleteDataset(dbo,ses,app,conn);
      end else
      if hcObj is TFRE_DB_ZONE then begin
        _deleteZone(dbo,ses,app,conn);
      end;
    end;
  end;
  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_ZoneContentConfiguration(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zone        : TFRE_DB_ZONE;
  template    : TFRE_DB_FBZ_TEMPLATE;
  res         : TFRE_DB_FORM_PANEL_DESC;
  i           : Integer;
  exClass     : TFRE_DB_ObjectClassEx;
  conf        : IFRE_DB_Object;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  defaultValue: Boolean;
  disabled    : Boolean;
  serviceClass: String;
begin
  CheckClassVisibility4MyDomain(ses);

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_ZONE,zone));
  res:=TFRE_DB_FORM_PANEL_DESC.create.Describe(FetchModuleTextShort(ses,'zone_config_form_caption'));
  res.contentId:='configureZone';

  CheckDbResult(conn.FetchAs(zone.Field('templateid').AsObjectLink,TFRE_DB_FBZ_TEMPLATE,template));

  for i := 0 to template.Field('serviceclasses').ValueCount -1 do begin
    serviceClass:=template.Field('serviceclasses').AsStringArr[i];
    exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
    conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
    if conf.Field('type').AsString='service' then begin
      defaultValue:=FREDB_StringInArrayIdx(serviceClass,zone.Field('disabledSCs').AsStringArr)=-1;
      if defaultValue then begin
        disabled:=false;
      end else begin
        disabled:=conn.GetReferencesCount(zone.UID,false,serviceClass,'serviceParent')>0;
      end;

      res.AddBool.Describe(conf.Field('caption').AsString,serviceClass,false,false,disabled,defaultValue);
    end;
  end;

  if conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_ZONE,zone.DomainID) then begin
    sf:=CWSF(@WEB_StoreZoneConfiguration);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);
  end;

  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_ZoneContentServices(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zone        : TFRE_DB_ZONE;
  res         : TFRE_DB_VIEW_LIST_DESC;
  dc          : IFRE_DB_DERIVED_COLLECTION;
  menu        : TFRE_DB_MENU_DESC;
  canAdd      : Boolean;
  template    : TFRE_DB_FBZ_TEMPLATE;
  i           : Integer;
  serviceClass: String;
  exClass     : TFRE_DB_ObjectClassEx;
  conf        : IFRE_DB_Object;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  submenu     : TFRE_DB_SUBMENU_DESC;
begin
  CheckClassVisibility4MyDomain(ses);

  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_ZONE,zone));

  dc:=ses.FetchDerivedCollection('ZONE_SERVICES_GRID');
  dc.Filters.RemoveFilter('zone');
  dc.Filters.AddAutoDependencyFilter('zone',['<SERVICEPARENT'],[zone.UID]);
  res:=dc.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;

  canAdd:=false;
  menu:=TFRE_DB_MENU_DESC.create.Describe;
  submenu:=menu.AddMenu.Describe(FetchModuleTextShort(ses,'tb_add_service'),'');

  CheckDbResult(conn.FetchAs(zone.Field('templateid').AsObjectLink,TFRE_DB_FBZ_TEMPLATE,template));

  for i := 0 to template.Field('serviceclasses').ValueCount -1 do begin
    serviceClass:=template.Field('serviceclasses').AsStringArr[i];
    exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
    if conn.SYS.CheckClassRight4DomainId(sr_STORE,serviceClass,zone.DomainID) then begin
      conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
      if conf.Field('type').AsString='service' then begin
        canAdd:=true;
        sf:=CWSF(@WEB_AddService);
        sf.AddParam.Describe('serviceClass',serviceClass);
        sf.AddParam.Describe('zoneId',zone.UID_String);
        submenu.AddEntry.Describe(conf.Field('caption').AsString,'',sf,conf.Field('OnlyOneServicePerZone').AsBoolean and (conn.GetReferencesCount(zone.UID,false,serviceClass,'serviceParent')>0),'add_'+serviceClass);
      end;
    end;
  end;

  if canAdd then begin
    res.SetMenu(menu);
  end;

  Result:=res;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_StoreZoneConfiguration(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zone         : TFRE_DB_ZONE;
  errorClasses : TFRE_DB_StringArray;
  sf           : TFRE_DB_SERVER_FUNC_DESC;
  servicesStr  : String;
  exClass      : TFRE_DB_ObjectClassEx;
  i            : Integer;
  conf         : IFRE_DB_Object;

  procedure _handleService(const field: IFRE_DB_Field);
  var
    idx     : NativeInt;
    refCount: NativeInt;
  begin
    idx:=FREDB_StringInArrayIdx(field.FieldName,zone.Field('disabledSCs').AsStringArr);
    if field.AsBoolean then begin
      if idx<>-1 then begin
        zone.Field('disabledSCs').RemoveString(idx);
      end;
    end else begin
      if idx=-1 then begin
        refCount:=conn.GetReferencesCount(zone.UID,false,field.FieldName,'serviceParent');
        if refCount>0 then begin
          SetLength(errorClasses,Length(errorClasses)+1);
          errorClasses[Length(errorClasses)-1]:=field.FieldName;
        end;
        zone.Field('disabledSCs').AddString(field.FieldName);
      end;
    end;
  end;

begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('selected').AsString),TFRE_DB_ZONE,zone));

  if not conn.SYS.CheckClassRight4DomainId(sr_UPDATE,TFRE_DB_ZONE,zone.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  SetLength(errorClasses,0);
  input.Field('data').AsObject.ForAllFields(@_handleService,true,true);

  if Length(errorClasses)=0 then begin
    CheckDbResult(conn.Update(zone));
    Result:=GFRE_DB_NIL_DESC;
  end else begin
    sf:=CWSF(@WEB_ZoneContentConfiguration);
    sf.AddParam.Describe('selected',input.Field('selected').AsString);
    servicesStr:='';
    for i := 0 to high(errorClasses) do begin
      exClass:=GFRE_DBI.GetObjectClassEx(errorClasses[i]);
      conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);

      if i>0 then servicesStr:=servicesStr + ', ';
      servicesStr:=servicesStr + conf.Field('caption').AsString;
    end;
    Result:=TFRE_DB_MESSAGE_DESC.create.Describe(FetchModuleTextShort(ses,'zone_config_save_error_cap'),StringReplace(FetchModuleTextShort(ses,'zone_config_save_error_msg'),'%services_str%',servicesStr,[rfReplaceAll]),fdbmt_error,sf);
  end;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_AddService(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  zone        : TFRE_DB_ZONE;
  scheme      : IFRE_DB_SchemeObject;
  res         : TFRE_DB_FORM_DIALOG_DESC;
  sf          : TFRE_DB_SERVER_FUNC_DESC;
  serviceClass: shortstring;
  exClass     : TFRE_DB_ObjectClassEx;
  conf        : IFRE_DB_Object;
begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));
  serviceClass:=input.Field('serviceClass').AsString;
  if not conn.SYS.CheckClassRight4DomainId(sr_STORE,serviceClass,zone.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  case serviceClass of
    'TFOS_DB_CITYCOM_VOIP_SERVICE' : begin
                                       Result:=fVoIPMod.WEB_AddService(input,ses,app,conn);
                                     end
    else begin
      exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
      conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
      res:=TFRE_DB_FORM_DIALOG_DESC.create.Describe(StringReplace(FetchModuleTextShort(ses,'add_service_diag_cap'),'%service_str%',conf.Field('caption').AsString,[rfReplaceAll]),600);
      GFRE_DBI.GetSystemSchemeByName(serviceClass,scheme);
      res.AddSchemeFormGroup(scheme.GetInputGroup('main'),ses);

      sf:=CWSF(@WEB_StoreService);
      sf.AddParam.Describe('zoneId',zone.UID_String);
      sf.AddParam.Describe('serviceClass',serviceClass);
      res.AddButton.Describe(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('button_save')),sf,fdbbt_submit);

      Result:=res;
    end;
  end;
end;

function TFOS_INFRASTRUCTURE_MOD.WEB_StoreService(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var
  scheme      : IFRE_DB_SchemeObject;
  zone        : TFRE_DB_ZONE;
  dbo         : IFRE_DB_Object;
  coll        : IFRE_DB_COLLECTION;
  exClass     : TFRE_DB_ObjectClassEx;
  conf        : IFRE_DB_Object;
  serviceClass: TFRE_DB_String;
  idx         : String;
begin
  CheckDbResult(conn.FetchAs(FREDB_H2G(input.Field('zoneId').AsString),TFRE_DB_ZONE,zone));
  if not conn.SYS.CheckClassRight4DomainId(sr_STORE,input.Field('serviceClass').AsString,zone.DomainID) then
    raise EFRE_DB_Exception.Create(conn.FetchTranslateableTextShort(FREDB_GetGlobalTextKey('error_no_access')));

  if not input.FieldPathExists('data.objname') then
    raise EFRE_DB_Exception.Create('Missing input parameter objname!');

  serviceClass:=input.Field('serviceClass').AsString;
  exClass:=GFRE_DBI.GetObjectClassEx(serviceClass);
  conf:=exClass.Invoke_DBIMC_Method('GetConfig',input,ses,app,conn);
  idx:=serviceClass + '_' + input.FieldPath('data.objname').AsString + '@' + zone.UID_String;
  coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);
  if coll.ExistsIndexedText(idx)<>0 then begin
    Result:=TFRE_DB_MESSAGE_DESC.Create.Describe(FetchModuleTextShort(ses,'service_create_error_exists_cap'),StringReplace(FetchModuleTextShort(ses,'service_create_error_exists_msg'),'%service_str%',conf.Field('caption').AsString,[rfReplaceAll]),fdbmt_error);
    exit;
  end;

  GFRE_DBI.GetSystemSchemeByName(serviceClass,scheme);
  dbo:=GFRE_DBI.NewObjectSchemeByName(serviceClass);
  dbo.Field('serviceParent').AsObjectLink:=zone.UID;
  dbo.Field('uniquephysicalid').AsString:=idx;
  dbo.SetDomainID(zone.DomainID);
  scheme.SetObjectFieldsWithScheme(input.Field('data').AsObject,dbo,true,conn);

  CheckDbResult(coll.Store(dbo));

  if conf.Field('OnlyOneServicePerZone').AsBoolean then begin
    ses.SendServerClientRequest(TFRE_DB_UPDATE_UI_ELEMENT_DESC.create.DescribeStatus('add_'+serviceClass,true));
  end;

  Result:=TFRE_DB_CLOSE_DIALOG_DESC.create.Describe();
end;

end.

