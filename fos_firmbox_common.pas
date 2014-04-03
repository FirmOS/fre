unit fos_firmbox_common;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DBBASE,
  FRE_DBBUSINESS,
  fre_accesscontrol_common,
  fos_firmbox_storageapp,
  fos_firmbox_servicesapp,
  fos_firmbox_vmapp,
  fos_firmbox_applianceapp,
  fos_firmbox_vm_machines_mod,
  fre_hal_schemes,
  fre_hal_update,
  FRE_ZFS,
  fre_scsi,
  fre_testcase,
  fre_system,
  fre_hal_disk_enclosure_pool_mangement,
  fos_vm_control_interface
;

//* USER - GRUPPE - ROLLE
//--
//Action Points -> User's in DB anlegen -> Grids, Layout (ROLLEN NACHZIEHN)
//
//--
//INFRA -> COMPUTER/GERÄTEVERWALTUNG | AP'S L2 (LANCOM | UBNT)  | NETZWERK | INFRASTRUKTUR | SWITCH PORTSECURITY | ASSETS | VPN
//--
//SERVICES APP -> FILESERVER | FILEBROWSER/BACKUP | MAILSERVER | WEBSERVER | DBSERVER ? POSTGRES | MYSQL ?
//--
//STORAGE -> POOL(DISKÜBERSICHT) | PLATZAUFTEILUNG | MONITORING
//--
//SYSTEM MONITORING STATUS -> MON
//--
//VIRTUALISIERUNG -> VM's - MACHINEN - VIRTUELLES NETZWERK - MONITORING
//--
//STORE(SALES) -> APP ( Funktionsmodule / Speicherplatz Kaufen / VM RAM / Virtuelle CPU's / BACKUPSPACE )
//

implementation


procedure FIRMBOX_MetaGenerateTestData(const dbname: string; const user, pass: string);
var conn     : IFRE_DB_Connection;
    coll     : IFRE_DB_Collection;
    scoll    : IFRE_DB_Collection;
    acoll    : IFRE_DB_Collection;
    hcoll    : IFRE_DB_Collection;
    bcoll    : IFRE_DB_Collection;
    tcoll    : IFRE_DB_Collection;
    vm_disks : IFRE_DB_COLLECTION;
    vm_isos  : IFRE_DB_COLLECTION;
    cob      : IFRE_DB_Object;
    group    : IFRE_DB_Object;
    share    : IFRE_DB_Object;
    share_id : TGUID;
    fs       : TGUID;
    fsname   : string;
    ncoll    : IFRE_DB_Collection;
    mcoll    : IFRE_DB_Collection;
    link_parent : TGUID;
    vm_parent   : TGUID;
    mguid: TGuid;
    dguid: TGuid;
    zguid: TGuid;
    zobj: TFRE_DB_ZONE;
    sobj: TFRE_DB_SERVICE;
    mobj: TFRE_DB_MACHINE;
    dobj: TFRE_DB_SERVICE_DOMAIN;

  function AddDatalink(const clname:string; const name: string; const parentid:TGUID; const show_virtual:boolean; const show_global:boolean; const icon:string; const ip:string; const desc:string='';const vlan:integer=0): TGUID;
  var
    datalink    : IFRE_DB_Object;
  begin
    datalink := GFRE_DBI.NewObjectSchemeByName(clname);
    datalink.Field('objname').asstring := name;
    if parentid<>GUID_NULL then begin
      datalink.Field('parentid').AsObjectLink := parentid;
    end;
    datalink.Field('showvirtual').AsBoolean   := show_virtual;
    datalink.Field('showglobal').AsBoolean    := show_global;
    datalink.Field('ip_net').Asstring         := ip;
    datalink.Field('mtu').AsUInt16            := 1500;
    datalink.Field('icon').AsString:='images_apps/firmbox_appliance/datalink_'+lowercase(icon)+'.png';
    datalink.Field('desc').AsObject := GFRE_DBI.NewObjectSchemeByName('TFRE_DB_TEXT');
    datalink.Field('desc').AsObject.Field('txt').asString := desc;
    if vlan<>0 then begin
      datalink.Field('vlan').AsUInt16 := vlan;
    end;
    result := datalink.UID;
    CheckDbResult(nCOLL.Store(datalink),'Add Datalink');
  end;

  procedure _AddVShare(const sharename:string; const cifs,afp,webdav,ftp:boolean; const qu :integer;const domain:string);
  var role      : IFRE_DB_ROLE;
      right     : IFRE_DB_RIGHT;
      snap      : IFRE_DB_Object;
      rightname : string;
      i         : NativeInt;
  begin
    share :=  GFRE_DBI.NewObjectScheme(TFRE_DB_VIRTUAL_FILESHARE);
    share.Field('fileserver').AsObjectLink := fs;
    share.Field('fileservername').AsString := fsname;
    share.Field('pool').AsString := 'zones';
    share.Field('objname').AsString := sharename;
    share.Field('cifs').AsBoolean   := cifs;
    share.Field('webdav').AsBoolean := webdav;
    share.Field('afp').AsBoolean    := afp;
    share.Field('ftp').AsBoolean     := ftp;
    share.Field('quota_mb').AsUInt32 := qu;
    share.Field('logbias').AsString := 'latency';
    share.Field('compression').AsString := 'on';
    share.Field('aclinheritance').Asstring := 'restricted';
    share.Field('aclmode').Asstring := 'discard';
    share.Field('canmount').Asstring := 'on';
    share.Field('copies').Asstring := '1';
    share.Field('sync').Asstring := 'standard';
    share_id   := share.UID;
    CheckDbResult(SCOLL.Store(share),'Add Share');

    //rightname := FREDB_Get_Rightname_UID('FSWRITE',share_id);
    //CheckDbResult(CONN.NewRole(rightname,'Write Access to share '+sharename+' on NAS '+fsname,'Write Access to share '+sharename+' on NAS '+fsname,role),'Adding Write role');
    //right := GFRE_DBI.NewRight(rightname);
    //role.AddRight(right);
    //CheckDbResult(CONN.StoreRole('firmbox_storage',domain,role),'Saving Role');
    //
    //rightname := FREDB_Get_Rightname_UID('FSREAD',share_id);
    //CheckDbResult(CONN.NewRole(rightname,'Read Access to share '+sharename+' on NAS '+fsname,'Read Access to share '+sharename+' on NAS '+fsname,role),'Adding Read role');
    //right := GFRE_DBI.NewRight(rightname);
    //role.AddRight(right);
    //CheckDbResult(CONN.StoreRole('firmbox_storage',domain,role),'Saving Role');

    for i:=1 to 10 do begin
      snap :=  GFRE_DBI.NewObjectScheme(TFRE_DB_ZFS_SNAPSHOT);
      snap.Field('parentid').AsObjectLink := share_id;
      snap.Field('objname').asString      := 'zones/vfiler/'+GFRE_BT.GUID_2_HexString(fs)+'/'+GFRE_BT.GUID_2_HexString(share_id)+'@AUTO-'+inttostr(i);
      snap.Field('creation').AsDateTimeUTC:= GFRE_DT.Now_UTC-(86400*1000*(10-i));
      snap.Field('used_mb').AsUInt32      := trunc(1.2*(random(10)+1));
      snap.Field('refer_mb').AsUInt32     := trunc(9.3*((random(3)+1)*i));
      CheckDbResult(BCOLL.Store(snap),'Add Snapshot');
    end;
  end;

  procedure _AddNShare(const sharename:string; const qu :integer);
  var share_id  : TGUID;
      access    : IFRE_DB_Object;
      snap      : IFRE_DB_Object;
      i         : NativeInt;
  begin
    share :=  GFRE_DBI.NewObjectScheme(TFRE_DB_NFS_FILESHARE);
    share.Field('fileserver').AsObjectLink := fs;
    share.Field('fileservername').AsString := fsname;
    share.Field('objname').AsString := sharename;
    share.Field('pool').AsString := 'zones';
    share.Field('refer_mb').AsUInt32 := 0;//qu div 10;
    share.Field('used_mb').AsUInt32 := 0;//qu div 2;
    share.Field('quota_mb').AsUInt32 := qu;
    share.Field('logbias').AsString := 'latency';
    share.Field('auth').AsString    := 'sys';
    share.Field('compression').AsString := 'on';
    share.Field('aclinheritance').Asstring := 'restricted';
    share.Field('aclmode').Asstring := 'discard';
    share.Field('canmount').Asstring := 'on';
    share.Field('copies').Asstring := '1';
    share.Field('sync').Asstring := 'standard';
    share_id                        := share.UID;
    CheckDbResult(SCOLL.Store(share),'Add Share');

    access :=  GFRE_DBI.NewObjectScheme(TFRE_DB_NFS_ACCESS);
    access.Field('fileshare').AsObjectLink := share_id;
    access.Field('accesstype').AsString    := 'RO';
    access.Field('subnet').Asstring        := '192.168.0.0/24';
    CheckDbResult(ACOLL.Store(access),'Add Access');

    access :=  GFRE_DBI.NewObjectScheme(TFRE_DB_NFS_ACCESS);
    access.Field('fileshare').AsObjectLink := share_id;
    access.Field('accesstype').AsString    := 'RW';
    access.Field('subnet').Asstring        := '10.0.0.0/24';
    CheckDbResult(ACOLL.Store(access),'Add Access');

    for i:=1 to 10 do begin
      snap :=  GFRE_DBI.NewObjectScheme(TFRE_DB_ZFS_SNAPSHOT);
      snap.Field('parentid').AsObjectLink := share_id;
      snap.Field('objname').asString      := 'zones/nfs/'+GFRE_BT.GUID_2_HexString(share_id)+'@AUTO-'+inttostr(i);
      snap.Field('creation').AsDateTimeUTC:= GFRE_DT.Now_UTC-(86400*1000*(10-i));
      snap.Field('used_mb').AsUInt32      := trunc(3.2*(random(10)+1));
      snap.Field('refer_mb').AsUInt32     := trunc(12.3*((random(3)+1)*i));
      CheckDbResult(BCOLL.Store(snap),'Add Snapshot');
    end;

  end;

  procedure _AddLUN(const guid:string; const sz :integer);
  var share_id  : TGUID;
      view      : IFRE_DB_Object;
      snap      : IFRE_DB_Object;
      i         : NativeInt;
  begin
    share :=  GFRE_DBI.NewObjectScheme(TFRE_DB_LUN);
    share.Field('fileserver').AsObjectLink := fs;
    share.Field('fileservername').AsString := fsname;
    share.Field('objname').AsString := guid;
    share.Field('pool').AsString := 'zones';
    share.Field('size_mb').AsUInt32 := sz;
    share.Field('logbias').AsString := 'latency';
    share.Field('compression').AsString := 'on';
    share.Field('primarycache').AsString := 'all';
    share.Field('secondarycache').AsString := 'all';
    share.Field('copies').Asstring := '1';
    share.Field('sync').Asstring := 'standard';
    share_id                        := share.UID;
    CheckDbResult(SCOLL.Store(share),'Add LUN');

    view :=  GFRE_DBI.NewObjectScheme(TFRE_DB_LUN_VIEW);
    view.Field('fileshare').AsObjectLink := share_id;
    view.Field('initiatorgroup').AsString    := 'vmhosts';
    view.Field('targetgroup').AsString       := 'firmbox_iscsi_target';
    CheckDbResult(ACOLL.Store(view),'Add View');

    view :=  GFRE_DBI.NewObjectScheme(TFRE_DB_LUN_VIEW);
    view.Field('fileshare').AsObjectLink := share_id;
    view.Field('initiatorgroup').AsString    := 'firmbox_initator';
    view.Field('targetgroup').AsString       := 'firmbox_iscsi_target';
    CheckDbResult(ACOLL.Store(view),'Add View');

    for i:=1 to 10 do begin
      snap :=  GFRE_DBI.NewObjectScheme(TFRE_DB_ZFS_SNAPSHOT);
      snap.Field('parentid').AsObjectLink := share_id;
      snap.Field('objname').asString      := 'zones/lun/'+GFRE_BT.GUID_2_HexString(share_id)+'@AUTO-'+inttostr(i);
      snap.Field('creation').AsDateTimeUTC:= GFRE_DT.Now_UTC-(86400*1000*(10-i));
      snap.Field('used_mb').AsUInt32      := trunc(4.12*(random(10)+1));
      snap.Field('refer_mb').AsUInt32     := sz;
      CheckDbResult(BCOLL.Store(snap),'Add Snapshot');
    end;
  end;

  procedure InitVirtualMachines;
  var coll    : IFRE_DB_COLLECTION;
      vmc     : IFOS_VM_HOST_CONTROL;
      vmo     : IFRE_DB_Object;
      root    : IFRE_DB_Object;

    procedure AddVMAdditions(const obj:IFRE_DB_Object);
    var domain   : IFRE_DB_DOMAIN;
        i        : NativeInt;
        snap     : IFRE_DB_Object;
        sz       : UInt32;

        //procedure _AddRolesForDomain(const domainname:string);
        //var
        //    role     : IFRE_DB_ROLE;
        //    right    : IFRE_DB_RIGHT;
        //    rolename : string;
        //begin
        //  rolename := FREDB_Get_Rightname_UID('VMLIST',obj.UID);
        //  CheckDbResult(CONN.NewRole(rolename,'List Virtual Machine '+obj.Field('objname').asstring,'List Virtual Machine '+obj.Field('objname').asstring,role),'Adding List role');
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMLIST',obj.UID)); role.AddRight(right);
        //  CheckDbResult(CONN.StoreRole('firmbox_vm',domainname,role),'Saving Role');
        //
        //  rolename := FREDB_Get_Rightname_UID('VMUSE',obj.UID);
        //  CheckDbResult(CONN.NewRole(rolename,'Use Virtual Machine '+obj.Field('objname').asstring,'Use Virtual Machine '+obj.Field('objname').asstring,role),'Adding Use role');
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMLIST',obj.UID)); role.AddRight(right);
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMVIEWCONSOLE',obj.UID)); role.AddRight(right);
        //  CheckDbResult(CONN.StoreRole('firmbox_vm',domainname,role),'Saving Role');
        //
        //  conn.AddGroupRoles(Get_Groupname_App_Group_Subgroup('firmbox_vm','USER'+'@'+domainname),GFRE_DBI.ConstructStringArray([rolename+'@'+domainname]));
        //
        //  rolename := FREDB_Get_Rightname_UID('VMADMIN',obj.UID);
        //  CheckDbResult(CONN.NewRole(rolename,'Admin Virtual Machine '+obj.Field('objname').asstring,'Admin Virtual Machine '+obj.Field('objname').asstring,role),'Adding Admin role');
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMLIST',obj.UID)); role.AddRight(right);
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMVIEWCONSOLE',obj.UID)); role.AddRight(right);
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMUSECONSOLE',obj.UID)); role.AddRight(right);
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMSTART',obj.UID)); role.AddRight(right);
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMSTOP',obj.UID)); role.AddRight(right);
        //  right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMCONFIGURE',obj.UID)); role.AddRight(right);
        //  CheckDbResult(CONN.StoreRole('firmbox_vm',domainname,role),'Saving Role');
        //
        //  conn.AddGroupRoles(Get_Groupname_App_Group_Subgroup('firmbox_vm','ADMIN'+'@'+domainname),GFRE_DBI.ConstructStringArray([rolename+'@'+domainname]));
        //end;

    begin
      //if conn.FetchDomainById(obj.Field('domainid').AsGUID,domain)<>edb_OK then
      //  raise EFRE_DB_Exception.Create('Domain '+obj.Field('domainid').asstring+' not found for machine '+obj.Field('objname').asstring);
      //
      //_AddRolesForDomain(domain.Domainname(false));
      //if (domain.Domainname(true)<>CFRE_DB_SYS_DOMAIN_NAME) then
      //  _AddRolesForDomain(CFRE_DB_SYS_DOMAIN_NAME);

      sz :=  20*(random(10)+1);

      for i:=1 to 3 do begin
        snap :=  GFRE_DBI.NewObjectScheme(TFRE_DB_ZFS_SNAPSHOT);
        snap.Field('parentid').AsObjectLink := obj.uid;
        if obj.SchemeClass=TFRE_DB_ZONE.ClassName then
          begin
            snap.Field('objname').asString      := 'zones/'+obj.Field('mkey').asstring+'@AUTO-'+inttostr(i);
          end
        else
          begin
            snap.Field('objname').asString      := 'zones/'+obj.Field('mkey').asstring+'-disk0@AUTO-'+inttostr(i);
          end;
        snap.Field('creation').AsDateTimeUTC:= GFRE_DT.Now_UTC-(86400*1000*(3-i));
        snap.Field('used_mb').AsUInt32      := trunc(3.33*(random(10)+1));
        snap.Field('refer_mb').AsUInt32     := sz;
        CheckDbResult(BCOLL.Store(snap),'Add Snapshot');
      end;
//      if obj.field('mtype').asstring='OS' then begin
//        writeln(obj.DumpToString());
//      end;
    end;

  begin

    vmc := Get_VM_Host_Control(cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
    try
      vmc.VM_ListMachines(vmo);
    finally
      vmc.Finalize;
    end;
    VM_UpdateCollection(conn,coll,vmo,TFRE_DB_VMACHINE.ClassName,TFRE_DB_ZONE.ClassName);

    // add root

    root :=  GFRE_DBI.NewObjectScheme(TFRE_DB_ZONE);
    root.Field('objname').asstring    :='Global Root Zone';
    root.Field('MKey').AsString       :='ROOT';
    root.Field('MType').AsString      :='OS';
    root.Field('MState').AsString     := 'running';
    root.Field('MStateIcon').AsString := 'images_apps/hal/vm_running.png';
    root.Field('domainid').asGUID     := conn.sys.DomainId(CFRE_DB_SYS_DOMAIN_NAME);
    root.Field('shell').AsString      := 'http://10.1.0.146:4200/global/';
    coll.Store(root);

    // add roles
    coll.ForAll(@AddVMAdditions);
  end;

  procedure InitTestUser;
  var login     : TFRE_DB_String;
      res       : TFRE_DB_Errortype;
      userdbo   : IFRE_DB_USER;
      passwd    : TFRE_DB_String;
  begin

      login  :='firmfeeder@'+CFRE_DB_SYS_DOMAIN_NAME;
      passwd :='x';

      if conn.sys.UserExists(login) then
        CheckDbResult(conn.sys.DeleteUser(login),'cannot delete user '+login);
      CheckDbResult(conn.sys.AddUser(login,passwd,'Feeder','Feeder'),'cannot add user '+login);

      CheckDbResult(conn.sys.ModifyUserGroups(login,TFRE_DB_StringArray.create('VMFEEDER'+'@'+CFRE_DB_SYS_DOMAIN_NAME,'APPLIANCEFEEDER'+'@'+CFRE_DB_SYS_DOMAIN_NAME,'STORAGEFEEDER'+'@'+CFRE_DB_SYS_DOMAIN_NAME),true),'cannot set user groups '+login);
      CheckDbResult(conn.sys.fetchuser(login,userdbo),'could not fetch user');

      login  :='firmviewer@'+CFRE_DB_SYS_DOMAIN_NAME;
      passwd :='x';

      if conn.sys.UserExists(login) then
        CheckDbResult(conn.sys.DeleteUser(login),'cannot delete user '+login);
      CheckDbResult(conn.sys.AddUser(login,passwd,'Firmviewer','Firmviewer'),'cannot add user '+login);

      CheckDbResult(conn.sys.ModifyUserGroups(login,TFRE_DB_StringArray.Create('VMVIEWER'+'@'+CFRE_DB_SYS_DOMAIN_NAME),true),'cannot set user groups '+login);
      CheckDbResult(conn.sys.fetchuser(login,userdbo),'could not fetch user');

  end;

begin
 CONN := GFRE_DBI.NewConnection;
 CONN.Connect(dbname,'admin@'+CFRE_DB_SYS_DOMAIN_NAME,'admin');

 InitTestUser;


 COLL := CONN.GetCollection('service');
 SCOLL:= CONN.GetCollection('fileshare');
 ACOLL:= CONN.GetCollection('fileshare_access');
 BCOLL:= CONN.GetCollection('snapshot');

 // InitVirtualMachines;

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_VIRTUAL_FILESERVER);
// cob.Field('machineid').AsObjectLink:=wlan_machine_uid;
 cob.Field('pool').asstring:='zones';
 fsname := 'Engineering';
 cob.Field('objname').asstring:= fsname;
 cob.Field('domainid').asguid := conn.sys.DomainId('SYSTEM');
 cob.Field('domain').asstring := 'FIRMOS';
 cob.Field('ip').asstring:='10.1.0.148/24';
 fs := COB.UID;
 CheckDbResult(COLL.Store(cob),'Add Fileserver');

 _AddVShare('Source',true,false,true,true,1024,'FIRMOS');
 _AddVShare('Development',true,true,true,true,2000,'FIRMOS');
 _AddVShare('Testing',false,false,true,false,1024,'FIRMOS');

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_VIRTUAL_FILESERVER);
// cob.Field('machineid').AsObjectLink:=wlan_machine_uid;
 cob.Field('pool').asstring:='zones';
 fsname := 'Business';
 cob.Field('objname').asstring:= fsname;
 cob.Field('domainid').asguid := conn.sys.DomainId('SYSTEM');
 cob.Field('domain').asstring := 'DEMO';
 cob.Field('ip').asstring:='10.1.0.147/24';
 fs := COB.UID;
 CheckDbResult(COLL.Store(cob),'Add Fileserver');


 _AddVShare('Accounting',true,false,true,false,4096,'DEMO');
 _AddVShare('Marketing',false,true,true,true,5012,'DEMO');
 _AddVShare('Management',false,false,false,true,2048,'DEMO');


 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_GLOBAL_FILESERVER);
// cob.Field('machineid').AsObjectLink:=wlan_machine_uid;
 fs := COB.UID;
 CheckDbResult(COLL.Store(cob),'Add Fileserver');

 fsname := 'GlobalNFS';

 _AddNShare('home',20240);
 _AddNShare('rdp',40960);
 _AddNShare('backup',30360);

 fsname := 'SAN';

 _AddLun('600144F090832B3B000051DEAE750001',10240);
 _AddLun('600144F090832B3B000051DEAE780002',102400);

 ncoll := Conn.GetCollection('datalink');


 link_parent:=AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'igb0',GUID_NULL,true,true,'phys','10.1.0.232/24','admin');
 AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnic1',link_parent,false,true,'vnic','192.198.0.1/24','inactive');
 AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnic2',link_parent,false,true,'vnic','172.17.0.1/24','inactive');
 vm_parent :=link_parent;
 link_parent:=AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'igb1',GUID_NULL,true,true,'phys','','inactive');
 link_parent:=AddDatalink(TFRE_DB_DATALINK_AGGR.ClassName,'aggr0',GUID_NULL,true,true,'aggr','192.168.1.1/24','inactive');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',link_parent,false,true,'phys','inactive');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',link_parent,false,true,'phys','inactive');
// AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnic3',link_parent,true,false,'vnic');
// AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnic4',link_parent,true,false,'vnic');
 link_parent:=AddDatalink(TFRE_DB_DATALINK_STUB.ClassName,'stub0',GUID_NULL,true,false,'stub','','Virtual Switch');
 AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'net1',link_parent,true,false,'vnic','','Virtual FW inactive',1001);
 AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'net1',link_parent,true,false,'vnic','','Virtual FW inactive',1001);

 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','10.1.0.142/24','VM ubuntu1');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','10.1.0.143/24','VM ubuntu2');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','10.1.0.144/24','VM win1');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','10.1.0.145/24','VM win2');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','10.1.0.146/24','VM freebsd');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','10.1.0.147/24','Zone vnas1');
 AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'net0',vm_parent,true,false,'vnic','192.168.2.1/24','Zone vnas2');


 hcoll := Conn.GetCollection('hba');

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_FC_PORT);
 cob.Field('objname').asstring:='10000090fa0ef24a';
 cob.Field('targetmode').AsBoolean:=false;
 cob.Field('portnr').AsUInt16:=1;
 cob.Field('manufacturer').asstring:='Emulex';
 cob.Field('model').asstring:='LPe12002-M8';
 cob.Field('firmware').asstring:='2.00a4 (U3D2.00A4)';
 cob.Field('biosversion').asstring:='Boot:5.12a5';
 cob.Field('serial').asstring:='FC23941874';
 cob.Field('driver').asstring:='emlxs';
 cob.Field('driverversion').asstring:='2.60k (2011.03.24.16.45)';
 cob.Field('porttype').asstring:='L-port';
 cob.Field('state').asstring:='offline';
 cob.Field('supportedspeeds').asstring:='2Gb 4Gb 8Gb';
 cob.Field('currentspeed').asstring:='not established';
 cob.Field('nodewwn').asstring:='20000090fa0ef24a';
 CheckDbResult(hCOLL.Store(cob),'Add FC Port');

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_FC_PORT);
 cob.Field('objname').asstring:='10000090fa0ef24b';
 cob.Field('targetmode').AsBoolean:=true;
 cob.Field('portnr').AsUInt16:=2;
 cob.Field('manufacturer').asstring:='Emulex';
 cob.Field('model').asstring:='LPe12002-M8';
 cob.Field('firmware').asstring:='2.00a4 (U3D2.00A4)';
 cob.Field('biosversion').asstring:='Boot:5.12a5';
 cob.Field('serial').asstring:='FC23941874';
 cob.Field('driver').asstring:='emlxs';
 cob.Field('driverversion').asstring:='2.60k (2011.03.24.16.45)';
 cob.Field('porttype').asstring:='L-port';
 cob.Field('state').asstring:='offline';
 cob.Field('supportedspeeds').asstring:='2Gb 4Gb 8Gb';
 cob.Field('currentspeed').asstring:='not established';
 cob.Field('nodewwn').asstring:='20000090fa0ef24b';
 CheckDbResult(hCOLL.Store(cob),'Add FC Port');

 mcoll := Conn.GetCollection('setting');
 COB   := GFRE_DBI.NewObjectScheme(TFRE_DB_MACHINE_SETTING_POWER);
 cob.Field('objname').asstring:='Power State';
 cob.Field('poweroperation').asstring:='nothing';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_MACHINE_SETTING_HOSTNAME);
 cob.Field('objname').asstring:='Hostname';
 cob.Field('hostname').asstring:='firmbox';
 cob.Field('domainname').asstring:='firmos.at';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_MACHINE_SETTING_TIME);
 cob.Field('objname').asstring:='Time';
 cob.Field('region').asstring:='Europe';
 cob.Field('timezone').asstring:='Europe/Vienna';
 cob.Field('ntpserver').asstring:='pool.ntp.org';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');

 COB  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_MACHINE_SETTING_MAIL);
 cob.Field('objname').asstring:='Mail';
 cob.Field('smtpserver').asstring:='localhost';
 cob.Field('mailfrom').asstring:='firmbox@firmos.at';
 cob.Field('mailto').asstring:='office@firmos.at';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');


 vm_disks := conn.GetCollection('VM_DISKS');

 cob := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_DISK);
 cob.Field('diskid').AsString:='d1';
 cob.Field('name').AsString:='d1 name';
 CheckDbResult(vm_disks.Store(cob),'Store VM disk');

 cob := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_DISK);
 cob.Field('diskid').AsString:='d2';
 cob.Field('name').AsString:='d2 name';
 CheckDbResult(vm_disks.Store(cob),'Store VM disk');

 vm_isos := conn.GetCollection('VM_ISOS');

 cob := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_ISO);
 cob.Field('isoid').AsString:='i1';
 cob.Field('name').AsString:='iso1 name';
 CheckDbResult(vm_isos.Store(cob),'Store VM iso');

 cob := GFRE_DBI.NewObjectScheme(TFRE_FIRMBOX_VM_ISO);
 cob.Field('isoid').AsString:='i2';
 cob.Field('name').AsString:='iso2 name';
 CheckDbResult(vm_isos.Store(cob),'Store VM iso');

  //SERVICES

  coll:=conn.GetCollection(CFRE_DB_MACHINE_COLLECTION);
  mobj:=TFRE_DB_MACHINE.CreateForDB;
  mobj.Name:='Firmbox 1';
  mguid:=mobj.UID;
  CheckDbResult(coll.Store(mobj));

  mobj:=TFRE_DB_MACHINE.CreateForDB;
  mobj.Name:='Firmbox 2';
  CheckDbResult(coll.Store(mobj));

  coll:=conn.GetCollection(CFOS_DB_SERVICE_DOMAINS_COLLECTION);

  dobj:=TFRE_DB_SERVICE_DOMAIN.CreateForDB;
  dobj.Name:='Domain1';
  dobj.Field('serviceParent').AsObjectLink:=mguid;
  dguid:=dobj.UID;
  CheckDbResult(coll.Store(dobj));

  dobj:=TFRE_DB_SERVICE_DOMAIN.CreateForDB;
  dobj.Name:='Domain2';
  dobj.Field('serviceParent').AsObjectLink:=mguid;
  CheckDbResult(coll.Store(dobj));

  coll:=conn.GetCollection(CFOS_DB_ZONES_COLLECTION);

  zobj:=TFRE_DB_ZONE.CreateForDB;
  zobj.Name:='Zone1';
  zobj.Field('serviceParent').AsObjectLink:=dguid;
  zguid:=zobj.UID;
  CheckDbResult(coll.Store(zobj));

  coll:=conn.GetCollection(CFOS_DB_MANAGED_SERVICES_COLLECTION);

  sobj:=TFRE_DB_SERVICE.CreateForDB;
  sobj.Name:='VM1';
  sobj.Field('serviceParent').AsObjectLink:=zguid;
  CheckDbResult(coll.Store(sobj));

  sobj:=TFRE_DB_SERVICE.CreateForDB;
  sobj.Name:='VM2';
  sobj.Field('serviceParent').AsObjectLink:=zguid;
  CheckDbResult(coll.Store(sobj));

  sobj:=TFRE_DB_SERVICE.CreateForDB;
  sobj.Name:='DNS';
  sobj.Field('serviceParent').AsObjectLink:=zguid;
  CheckDbResult(coll.Store(sobj));

  zobj:=TFRE_DB_ZONE.CreateForDB;
  zobj.Name:='Zone2';
  zobj.Field('serviceParent').AsObjectLink:=dguid;
  CheckDbResult(coll.Store(zobj));

 CONN.Finalize;
end;

procedure FIRMBOX_MetaRegister;
begin
  // Base Registrations
  FRE_DBBASE.Register_DB_Extensions;
  FRE_DBBUSINESS.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_hal_update.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;
  fos_firmbox_applianceapp.Register_DB_Extensions;
  fre_accesscontrol_common.Register_DB_Extensions;
  fre_testcase.Register_DB_Extensions;
  fos_firmbox_storageapp.Register_DB_Extensions;
  fos_firmbox_servicesapp.Register_DB_Extensions;
  fos_firmbox_vmapp.Register_DB_Extensions;
  GFRE_DBI.Initialize_Extension_Objects;
end;

procedure FIRMBOX_MetaInitializeDatabase(const dbname: string; const user, pass: string);
var conn            : IFRE_DB_CONNECTION;
    collection      : IFRE_DB_COLLECTION;
    storeObj        : IFRE_DB_Object;
    vm_disks        : IFRE_DB_COLLECTION;
    vm_isos         : IFRE_DB_COLLECTION;
    vm_sc           : IFRE_DB_COLLECTION;
    vm_keyboards    : IFRE_DB_COLLECTION;
begin
  CONN := GFRE_DBI.NewConnection;
  CONN.Connect(dbname,'admin@'+CFRE_DB_SYS_DOMAIN_NAME,'admin');
  try
    collection  := conn.getCollection(CFRE_DB_VM_COLLECTION);
    if not collection.IndexExists('def') then
      collection.DefineIndexOnField('Mkey',fdbft_String,true,true);

    vm_disks := conn.CreateCollection('VM_DISKS');
    if not vm_disks.IndexExists('def') then
      vm_disks.DefineIndexOnField('diskid',fdbft_String,true,true);

    vm_isos := conn.CreateCollection('VM_ISOS');
    if not vm_isos.IndexExists('def') then
      vm_isos.DefineIndexOnField('isoid',fdbft_String,true,true);

    vm_sc := conn.CreateCollection('VM_SCS');
    if not vm_sc.IndexExists('def') then
      vm_sc.DefineIndexOnField('scid',fdbft_String,true,true);

    vm_keyboards := conn.CreateCollection('VM_KEYBOARDS');
    if not vm_keyboards.IndexExists('def') then
      vm_keyboards.DefineIndexOnField('keyboardid',fdbft_String,true,true);

    collection  := conn.CreateCollection('datalink');     //fixme
    collection  := conn.CreateCollection('setting');
    collection  := conn.CreateCollection('hba');
    collection  := conn.CreateCollection('snapshot');
    collection  := conn.CreateCollection('service');
    collection  := conn.CreateCollection('fileshare');
    collection  := conn.CreateCollection('fileshare_access');

   {
    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('keyboardid').AsString:='en-gb';
    storeObj.Field('name').AsString:='English (GB)';
    storeObj.Field('order').AsString:='1';
    CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('keyboardid').AsString:='en-us';
    storeObj.Field('name').AsString:='English (US)';
    storeObj.Field('order').AsString:='2';
    CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('keyboardid').AsString:='fr';
    storeObj.Field('name').AsString:='French';
    storeObj.Field('order').AsString:='3';
    CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('keyboardid').AsString:='de';
    storeObj.Field('name').AsString:='German';
    storeObj.Field('order').AsString:='4';
    CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('keyboardid').AsString:='it';
    storeObj.Field('name').AsString:='Italian';
    storeObj.Field('order').AsString:='5';
    CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('keyboardid').AsString:='es';
    storeObj.Field('name').AsString:='Spanish';
    storeObj.Field('order').AsString:='6';
    CheckDbResult(vm_keyboards.Store(storeObj),'Store keyboard layout');

    //FIXXME: move to correct location or read from qemu help
    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('scid').AsString:='ac97';
    storeObj.Field('name').AsString:='Intel 82801AA AC97 Audio';
    storeObj.Field('order').AsString:='1';
    CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('scid').AsString:='sb16';
    storeObj.Field('name').AsString:='Creative Sound Blaster 16';
    storeObj.Field('order').AsString:='2';
    CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('scid').AsString:='es1370';
    storeObj.Field('name').AsString:='ENSONIQ AudioPCI ES1370';
    storeObj.Field('order').AsString:='3';
    CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');

    storeObj:=GFRE_DBI.NewObject;
    storeObj.Field('scid').AsString:='hda';
    storeObj.Field('name').AsString:='Intel HD Audio';
    storeObj.Field('order').AsString:='4';
    CheckDbResult(vm_sc.Store(storeObj),'Store VM sound card');
    }
  finally
    conn.Finalize;
  end;
end;

procedure FIRMBOX_MetaRemove(const dbname: string; const user, pass: string);
var conn  : IFRE_DB_SYS_CONNECTION;
    res   : TFRE_DB_Errortype;
    i     : integer;
    login : string;
begin
  CONN := GFRE_DBI.NewSysOnlyConnection;
  try
    res  := CONN.Connect('admin','admin');
    if res<>edb_OK then gfre_bt.CriticalAbort('cannot connect system : %s',[CFRE_DB_Errortype[res]]);
  finally
    conn.Finalize;
  end;
end;

initialization

 GFRE_DBI_REG_EXTMGR.RegisterNewExtension('FIRMBOX',@FIRMBOX_MetaRegister,@FIRMBOX_MetaInitializeDatabase,@FIRMBOX_MetaRemove,@FIRMBOX_MetaGenerateTestdata);


end.

