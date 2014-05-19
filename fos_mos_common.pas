unit fos_mos_common;

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
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DBBASE,
  fre_accesscontrol_common,
  fre_monitoring,fos_mos_monitoringapp, fos_mos_networkapp,
  fre_zfs,fre_scsi,fre_hal_disk_enclosure_pool_mangement,fre_hal_schemes,fre_diff_transport,fre_hal_mos,
  fre_system;

implementation

procedure MOS_MetaRegister;
begin
  FRE_DBBASE.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  fre_monitoring.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_hal_mos.Register_DB_Extensions;
  fre_diff_transport.Register_DB_Extensions;
  fos_mos_monitoringapp.Register_DB_Extensions;
  fos_mos_networkapp.Register_DB_Extensions;
  fre_accesscontrol_common.Register_DB_Extensions;
end;

procedure MOS_MetaInitializeDatabase(const dbname: string; const user, pass: string);
begin
end;

procedure MOS_MetaRemove(const dbname: string; const user, pass: string);
begin
end;

procedure MOS_Metatestdata(const dbname: string; const user, pass: string);
var
  conn                : IFRE_DB_CONNECTION;
  coll                : IFRE_DB_COLLECTION;
  addons              : IFRE_DB_Object;
  uguid1,uguid2       : TFRE_DB_GUID;
  mguid               : TFRE_DB_GUID;
  guid                : TFRE_DB_GUID;
  domuid_for_testdata : TFRE_DB_GUID;
  variationId         : TGuid;
  vcoll               : IFRE_DB_COLLECTION;
  mcoll               : IFRE_DB_COLLECTION;
  mosuid              : TGuid;
  moslocuid           : TGuid;
  mosmachinesueduid   : TGuid;
  mosmachinenorduid   : TGuid;
  pool                : TFRE_DB_ZFS_POOL;
  ds                  : TFRE_DB_ZFS_DATASTORAGE;
  mosObjRZ            : TFRE_DB_VIRTUALMOSOBJECT;
  mosObjRack          : TFRE_DB_VIRTUALMOSOBJECT;
  mosObjMachine       : TFRE_DB_MACHINE;
  mosObjLoc           : TFRE_DB_VIRTUALMOSOBJECT;
  domainId            : TGuid;
  userObj             : IFRE_DB_USER;
  groups              : TFRE_DB_GUIDArray;
  groupObj            : IFRE_DB_GROUP;


  procedure InitTestUser;
  var login     : TFRE_DB_String;
      res       : TFRE_DB_Errortype;
      passwd    : TFRE_DB_String;
      domainUID : TGuid;
      userObj   : IFRE_DB_USER;
      groupObj  : IFRE_DB_GROUP;
  begin

      login  :='monitorfeeder';
      passwd :='x';

      domainUID:=conn.SYS.DomainID(CFRE_DB_SYS_DOMAIN_NAME);

      if conn.sys.UserExists(login,domainUID) then
        CheckDbResult(conn.sys.DeleteUser(login,domainUID),'cannot delete user '+login);
      CheckDbResult(conn.sys.AddUser(login,domainUID,passwd,'Feeder','Feeder'),'cannot add user '+login);

      CheckDbResult(conn.sys.FetchUser(login,domainUID,userObj),'could not fetch user');
      CheckDbResult(conn.sys.FetchGroup('MONITORFEEDER',domainUID,groupObj),'could not fetch user');

      CheckDbResult(conn.sys.ModifyUserGroupsById(userObj.UID,TFRE_DB_GUIDArray.create(groupObj.UID),true),'cannot set user groups '+login);
  end;

begin
  conn := GFRE_DBI.NewConnection;
  try
    conn.Connect(dbname,user,pass);

    InitTestUser; { ->> Move to init of MOS APP ! }

    //MONITORING

    domainId:=conn.sys.DomainID('test');
    CheckDbResult(conn.SYS.FetchUser('admin',domainId,userObj));
    groups:=TFRE_DB_GUIDArray.create;
    SetLength(groups,2);
    conn.SYS.FetchGroup('MOSADMINS',domainId,groupObj);
    groups[0]:=groupObj.UID;
    conn.SYS.FetchGroup('NETWORKADMINS',domainId,groupObj);
    groups[1]:=groupObj.UID;
    CheckDbResult(conn.SYS.ModifyUserGroupsById(userObj.UID,groups,true));

    CheckDbResult(conn.SYS.FetchUser('admin',domainId,userObj));
    groups:=TFRE_DB_GUIDArray.create;
    SetLength(groups,2);
    conn.SYS.FetchGroup('MOSMANAGERS',domainId,groupObj);
    groups[0]:=groupObj.UID;
    conn.SYS.FetchGroup('NETWORKMANAGERS',domainId,groupObj);
    groups[1]:=groupObj.UID;
    CheckDbResult(conn.SYS.ModifyUserGroupsById(userObj.UID,groups,true));

    CheckDbResult(conn.SYS.FetchUser('admin',domainId,userObj));
    groups:=TFRE_DB_GUIDArray.create;
    SetLength(groups,2);
    conn.SYS.FetchGroup('MOSVIEWERS',domainId,groupObj);
    groups[0]:=groupObj.UID;
    conn.SYS.FetchGroup('NETWORKVIEWERS',domainId,groupObj);
    groups[1]:=groupObj.UID;
    CheckDbResult(conn.SYS.ModifyUserGroupsById(userObj.UID,groups,true));

    coll:=conn.GetCollection(CFRE_DB_MOS_COLLECTION);

    mosObjLoc:=TFRE_DB_VIRTUALMOSOBJECT.CreateForDB;
    mosObjLoc.caption:='RZ Locations';
    mosObjLoc.SetDomainID(domuid_for_testdata);
    mosObjLoc.Field('status_mos').AsString:=CFRE_DB_MOS_STATUS[fdbstat_ok];
    moslocuid:=mosObjLoc.UID;
    CheckDbResult(coll.Store(mosObjLoc),'Add MOS Object');

    mosObjRZ:=TFRE_DB_VIRTUALMOSOBJECT.CreateForDB;
    mosObjRZ.caption:='RZ Süd';
    mosObjRZ.SetMOSKey('RZSUED');
    mosObjRZ.SetDomainID(domuid_for_testdata);
    mosObjRZ.Field('mosparentIds').AddObjectLink(moslocuid);
    mosObjRZ.Field('status_mos').AsString:=CFRE_DB_MOS_STATUS[fdbstat_warning];
    mosuid:=mosObjRZ.UID;
    CheckDbResult(coll.Store(mosObjRZ),'Add MOS Object');

    mosObjRack:=TFRE_DB_VIRTUALMOSOBJECT.CreateForDB;
    mosObjRack.caption:='Rack 1';
    mosObjRack.Field('mosparentIds').AddObjectLink(mosuid);
    mosObjRack.SetDomainID(domuid_for_testdata);
    mosObjRack.Field('status_mos').AsString:=CFRE_DB_MOS_STATUS[fdbstat_error];
    mosuid:=mosObjRack.UID;
    CheckDbResult(coll.Store(mosObjRack),'Add MOS Object');

    mcoll      := conn.GetCollection(CFRE_DB_MACHINE_COLLECTION);

    mosObjMachine:=TFRE_DB_MACHINE.CreateForDB;
//    mosObjMachine.caption:='SNord 1';
    mosObjMachine.ObjectName:='SSued01';
    mosObjMachine.Field('mosparentIds').AddObjectLink(mosuid);
    mosObjMachine.SetDomainID(domuid_for_testdata);
    mosmachinesueduid:=mosObjMachine.UID;
    CheckDbResult(mcoll.Store(mosObjMachine),'Add Machine Object');

    mosObjRZ:=TFRE_DB_VIRTUALMOSOBJECT.CreateForDB;
    mosObjRZ.caption:='RZ Nord';
    mosObjRZ.SetMOSKey('RZNORD');
    mosObjRZ.SetDomainID(domuid_for_testdata);
    mosObjRZ.Field('mosparentIds').AddObjectLink(moslocuid);
    mosuid:=mosObjRZ.UID;
    CheckDbResult(coll.Store(mosObjRZ),'Add MOS Object');

    mosObjRack:=TFRE_DB_VIRTUALMOSOBJECT.CreateForDB;
    mosObjRack.caption:='Rack 1 Nord';
    mosObjRack.Field('mosparentIds').AddObjectLink(mosuid);
    mosObjRack.SetDomainID(domuid_for_testdata);
    mosuid:=mosObjRack.UID;
    CheckDbResult(coll.Store(mosObjRack),'Add MOS Object');

    mosObjMachine:=TFRE_DB_MACHINE.CreateForDB;
//    mosObjMachine.caption:='SNord 1';
    mosObjMachine.ObjectName:='SNord01';
    mosObjMachine.Field('mosparentIds').AddObjectLink(mosuid);
    mosObjMachine.SetDomainID(domuid_for_testdata);
    mosmachinenorduid:=mosObjMachine.UID;
    CheckDbResult(mcoll.Store(mosObjMachine),'Add Machine Object');

    coll:=conn.GetCollection(CFRE_DB_ZFS_POOL_COLLECTION);

    pool:=TFRE_DB_ZFS_POOL.CreateForDB;
    pool.setname('pool');
    pool.SetDomainID(domuid_for_testdata);
    pool.Field('mosparentIds').AddObjectLink(mosmachinenorduid);
    pool.Field('mosparentIds').AddObjectLink(mosmachinesueduid);
    CheckDbResult(coll.Store(pool));

    coll:=conn.GetCollection(CFRE_DB_ZFS_VDEV_COLLECTION);
    ds:=pool.createDatastorage;
    ds.setname('pool');
    ds.SetDomainID(domuid_for_testdata);
    CheckDbResult(coll.Store(ds));

  finally
    conn.Finalize;
  end;
end;

initialization

GFRE_DBI_REG_EXTMGR.RegisterNewExtension('MOS',@MOS_MetaRegister,@MOS_MetaInitializeDatabase,@MOS_MetaRemove,@MOS_Metatestdata);


end.

