unit fos_firmbox_common;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_SYSRIGHT_CONSTANTS,
  FRE_DB_INTERFACE,
  FRE_DBBASE,
  FRE_DBBUSINESS,
  fos_firmbox_userapp,
  fos_firmbox_fileserver,
  fos_firmbox_infrastructureapp,
  fos_firmbox_servicesapp,
  fos_firmbox_storageapp,
  fos_firmbox_vmapp,
  fos_firmbox_storeapp,
  fos_firmbox_applianceapp,
  fos_firmbox_vm_machines_mod,
  fre_hal_schemes,
  FRE_ZFS,
  fre_testcase,
  fre_system,
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
procedure InitDB(const dbname: string; const user, pass: string);

implementation

procedure InitializeCorebox(const dbname: string; const user, pass: string);
var conn : IFRE_DB_SYS_CONNECTION;
    res  : TFRE_DB_Errortype;
    adminug : TFRE_DB_StringArray;
    userug  : TFRE_DB_StringArray;
    guestug : TFRE_DB_StringArray;

    procedure _AddUserGroupToArray(const usergroup: string; var a: TFRE_DB_StringArray);
    begin
     setlength(a,length(a)+1);
     a[high(a)] := usergroup;
    end;

    procedure CreateAppUserGroups(const appname : string;const domain: TFRE_DB_NameType);
    begin
      _AddUserGroupToArray(Get_Groupname_App_Group_Subgroup(appname,'ADMIN'+'@'+domain),adminug);
      _AddUserGroupToArray(Get_Groupname_App_Group_Subgroup(appname,'USER'+'@'+domain),userug);
      _AddUserGroupToArray(Get_Groupname_App_Group_Subgroup(appname,'GUEST'+'@'+domain),guestug);
    end;

    procedure _addUsertoGroupsforDomain(const obj: IFRE_DB_Object);
    var domain  : TFRE_DB_NameType;

        procedure _addUsertoGroup(const user: string; const groupa: TFRE_DB_StringArray);
        var i     : NativeInt;
            login : string;
        begin
          login  := user+'@'+domain;
          if conn.UserExists(login) then begin
            CheckDbResult(conn.ModifyUserGroups(login,groupa,true),'cannot set usergroups '+login);
          end;
        end;

    begin
      domain := obj.Field('objname').asstring;

      setLength(adminug,0);
      setLength(userug,0);
      setLength(guestug,0);

      CreateAppUserGroups('corebox_appliance',domain);
      CreateAppUserGroups('corebox_user',domain);
      //CreateAppUserGroups('corebox_infrastructure');
      //CreateAppUserGroups('corebox_services');
      CreateAppUserGroups('corebox_storage',domain);
      CreateAppUserGroups('corebox_vm',domain);
      //CreateAppUserGroups('monsys');
      //CreateAppUserGroups('corebox_store');

      writeln(GFRE_DBI.StringArray2String(adminug));
      writeln(GFRE_DBI.StringArray2String(userug));

      if domain=cSYS_DOMAIN then begin
        _addUsertoGroup('admin1',adminug);
        _addUsertoGroup('admin2',adminug);
        _addUsertoGroup('feeder',adminug);

        _addUsertoGroup('user1',userug);
        _addUsertoGroup('user2',userug);

        setLength(adminug,0);
        CreateAppUserGroups('corebox_vm',domain);
        _addUsertoGroup('demo1',userug);
        _addUsertoGroup('demo2',userug);

        setLength(guestug,0);
        CreateAppUserGroups('corebox_vm',domain);
        _addUsertoGroup('guest',guestug);
      end else begin
        _addUsertoGroup('myadmin',adminug);
        _addUsertoGroup('admin',adminug);
        _addUsertoGroup('user1',userug);
        _addUsertoGroup('user2',userug);
      end;
    end;

begin
  CONN := GFRE_DBI.NewSysOnlyConnection;
  try
    res  := CONN.Connect('admin@'+cSYS_DOMAIN,'admin');
    if res<>edb_OK then gfre_bt.CriticalAbort('cannot connect system : %s',[CFRE_DB_Errortype[res]]);
      conn.InstallAppDefaults('corebox_appliance');
      conn.InstallAppDefaults('corebox_user');
      conn.InstallAppDefaults('corebox_storage');
      conn.InstallAppDefaults('corebox_vm');
      //conn.InstallAppDefaults('corebox_infrastructure');
      //conn.InstallAppDefaults('corebox_services');
      //conn.InstallAppDefaults('monsys');
      //conn.InstallAppDefaults('corebox_store');

      conn.ForAllDomains(@_addUsertoGroupsforDomain);
  finally
    conn.Finalize;
  end;
 end;

procedure GenerateTestData(const dbname: string; const user, pass: string);
var conn     : IFRE_DB_Connection;
    coll     : IFRE_DB_Collection;
    scoll    : IFRE_DB_Collection;
    acoll    : IFRE_DB_Collection;
    hcoll    : IFRE_DB_Collection;
    bcoll    : IFRE_DB_Collection;
    tcoll    : IFRE_DB_Collection;
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

  function AddDatalink(const clname:string; const name: string; const parentid:TGUID; const show_virtual:boolean; const show_global:boolean; const icon:string; const ip:string; const desc:string='';const vlan:integer=0): TGUID;
  var
    datalink    : IFRE_DB_Object;
  begin
    datalink := CONN.NewObject(clname);
    datalink.Field('objname').asstring := name;
    if parentid<>GUID_NULL then begin
      datalink.Field('parentid').AsObjectLink := parentid;
    end;
    datalink.Field('showvirtual').AsBoolean   := show_virtual;
    datalink.Field('showglobal').AsBoolean    := show_global;
    datalink.Field('ip_net').Asstring         := ip;
    datalink.Field('mtu').AsUInt16            := 1500;
    datalink.Field('icon').AsString:='images_apps/corebox_appliance/datalink_'+lowercase(icon)+'.png';
    datalink.Field('desc').AsObject := CONN.NewObject('TFRE_DB_TEXT');
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
    share := CONN.NewObject(TFRE_DB_VIRTUAL_FILESHARE.ClassName);
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

    rightname := FREDB_Get_Rightname_UID('FSWRITE',share_id);
    CheckDbResult(CONN.NewRole(rightname,'Write Access to share '+sharename+' on NAS '+fsname,'Write Access to share '+sharename+' on NAS '+fsname,role),'Adding Write role');
    right := GFRE_DBI.NewRight(rightname,'','');
    role.AddRight(right);
    CheckDbResult(CONN.StoreRole('corebox_storage',domain,role),'Saving Role');

    rightname := FREDB_Get_Rightname_UID('FSREAD',share_id);
    CheckDbResult(CONN.NewRole(rightname,'Read Access to share '+sharename+' on NAS '+fsname,'Read Access to share '+sharename+' on NAS '+fsname,role),'Adding Read role');
    right := GFRE_DBI.NewRight(rightname,'','');
    role.AddRight(right);
    CheckDbResult(CONN.StoreRole('corebox_storage',domain,role),'Saving Role');

    for i:=1 to 10 do begin
      snap := CONN.NewObject(TFRE_DB_ZFS_SNAPSHOT.ClassName);
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
    share := CONN.NewObject(TFRE_DB_NFS_FILESHARE.ClassName);
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

    access := CONN.NewObject(TFRE_DB_NFS_ACCESS.ClassName);
    access.Field('fileshare').AsObjectLink := share_id;
    access.Field('accesstype').AsString    := 'ro';
    access.Field('subnet').Asstring        := '192.168.0.0/24';
    CheckDbResult(ACOLL.Store(access),'Add Access');

    access := CONN.NewObject(TFRE_DB_NFS_ACCESS.ClassName);
    access.Field('fileshare').AsObjectLink := share_id;
    access.Field('accesstype').AsString    := 'rw';
    access.Field('subnet').Asstring        := '10.0.0.0/24';
    CheckDbResult(ACOLL.Store(access),'Add Access');

    for i:=1 to 10 do begin
      snap := CONN.NewObject(TFRE_DB_ZFS_SNAPSHOT.ClassName);
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
    share := CONN.NewObject(TFRE_DB_LUN.ClassName);
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

    view := CONN.NewObject(TFRE_DB_LUN_VIEW.ClassName);
    view.Field('fileshare').AsObjectLink := share_id;
    view.Field('initiatorgroup').AsString    := 'vmhosts';
    view.Field('targetgroup').AsString       := 'firmbox_iscsi_target';
    CheckDbResult(ACOLL.Store(view),'Add View');

    view := CONN.NewObject(TFRE_DB_LUN_VIEW.ClassName);
    view.Field('fileshare').AsObjectLink := share_id;
    view.Field('initiatorgroup').AsString    := 'firmbox_initator';
    view.Field('targetgroup').AsString       := 'firmbox_iscsi_target';
    CheckDbResult(ACOLL.Store(view),'Add View');

    for i:=1 to 10 do begin
      snap := CONN.NewObject(TFRE_DB_ZFS_SNAPSHOT.ClassName);
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

        procedure _AddRolesForDomain(const domainname:string);
        var
            role     : IFRE_DB_ROLE;
            right    : IFRE_DB_RIGHT;
            rolename : string;
        begin
          rolename := FREDB_Get_Rightname_UID('VMLIST',obj.UID);
          CheckDbResult(CONN.NewRole(rolename,'List Virtual Machine '+obj.Field('objname').asstring,'List Virtual Machine '+obj.Field('objname').asstring,role),'Adding List role');
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMLIST',obj.UID),'',''); role.AddRight(right);
          CheckDbResult(CONN.StoreRole('corebox_vm',domainname,role),'Saving Role');

          rolename := FREDB_Get_Rightname_UID('VMUSE',obj.UID);
          CheckDbResult(CONN.NewRole(rolename,'Use Virtual Machine '+obj.Field('objname').asstring,'Use Virtual Machine '+obj.Field('objname').asstring,role),'Adding Use role');
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMLIST',obj.UID),'',''); role.AddRight(right);
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMVIEWCONSOLE',obj.UID),'',''); role.AddRight(right);
          CheckDbResult(CONN.StoreRole('corebox_vm',domainname,role),'Saving Role');

          conn.AddGroupRoles(Get_Groupname_App_Group_Subgroup('corebox_vm','USER'+'@'+domainname),GFRE_DBI.ConstructStringArray([rolename+'@'+domainname]));

          rolename := FREDB_Get_Rightname_UID('VMADMIN',obj.UID);
          CheckDbResult(CONN.NewRole(rolename,'Admin Virtual Machine '+obj.Field('objname').asstring,'Admin Virtual Machine '+obj.Field('objname').asstring,role),'Adding Admin role');
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMLIST',obj.UID),'',''); role.AddRight(right);
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMVIEWCONSOLE',obj.UID),'',''); role.AddRight(right);
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMUSECONSOLE',obj.UID),'',''); role.AddRight(right);
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMSTART',obj.UID),'',''); role.AddRight(right);
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMSTOP',obj.UID),'',''); role.AddRight(right);
          right := GFRE_DBI.NewRight(FREDB_Get_Rightname_UID('VMCONFIGURE',obj.UID),'',''); role.AddRight(right);
          CheckDbResult(CONN.StoreRole('corebox_vm',domainname,role),'Saving Role');

          conn.AddGroupRoles(Get_Groupname_App_Group_Subgroup('corebox_vm','ADMIN'+'@'+domainname),GFRE_DBI.ConstructStringArray([rolename+'@'+domainname]));
        end;

    begin
      if conn.FetchDomainById(obj.Field('domainid').AsGUID,domain)<>edb_OK then
        raise EFRE_DB_Exception.Create('Domain '+obj.Field('domainid').asstring+' not found for machine '+obj.Field('objname').asstring);

      _AddRolesForDomain(domain.GetName);
      if (domain.GetName<>cSYS_DOMAIN) then
        _AddRolesForDomain(cSYS_DOMAIN);

      sz :=  20*(random(10)+1);

      for i:=1 to 3 do begin
        snap := CONN.NewObject(TFRE_DB_ZFS_SNAPSHOT.ClassName);
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

    coll := conn.Collection('virtualmachine');
    coll.DefineIndexOnField('Mkey',fdbft_String,true,true);

    VM_UpdateCollection(conn,coll,vmo,TFRE_DB_VMACHINE.ClassName,TFRE_DB_ZONE.ClassName);

    // add root

    root := conn.NewObject(TFRE_DB_ZONE.ClassName);
    root.Field('objname').asstring    :='Global Root Zone';
    root.Field('MKey').AsString       :='ROOT';
    root.Field('MType').AsString      :='OS';
    root.Field('MState').AsString     := 'running';
    root.Field('MStateIcon').AsString := 'images_apps/corebox_vm_machines/vm_running.png';
    root.Field('domainid').asGUID     := conn.DomainId(cSYS_DOMAIN);
    root.Field('shell').AsString      := 'http://10.1.0.146:4200/global/';
    coll.Store(root);

    // add roles
    writeln ('Machines in Collection:',coll.Count);
    coll.ForAll(@AddVMAdditions);
  end;

begin
 CONN := GFRE_DBI.NewConnection;
 CONN.Connect(dbname,'admin@'+cSYS_DOMAIN,'admin');

 COLL := CONN.Collection('service');
 SCOLL:= CONN.Collection('fileshare');
 ACOLL:= CONN.Collection('fileshare_access');
 BCOLL:= CONN.Collection('snapshot');
 TCOLL:= CONN.Collection('note');
 tcoll.DefineIndexOnField('link',fdbft_String,true,true);

 InitVirtualMachines;

 COB  := CONN.NewObject(TFRE_DB_VIRTUAL_FILESERVER.ClassName);
// cob.Field('machineid').AsObjectLink:=wlan_machine_uid;
// COb.Field('servicegroup').AsObjectLink:=si;
 cob.Field('pool').asstring:='zones';
 fsname := 'Engineering';
 cob.Field('objname').asstring:= fsname;
 cob.Field('domainid').asguid := conn.DomainId('firmos');
 cob.Field('domain').asstring := 'FIRMOS';
 cob.Field('ip').asstring:='10.1.0.148/24';
 fs := COB.UID;
 CheckDbResult(COLL.Store(cob),'Add Fileserver');

 _AddVShare('Source',true,false,true,true,1024,'FIRMOS');
 _AddVShare('Development',true,true,true,true,2000,'FIRMOS');
 _AddVShare('Testing',false,false,true,false,1024,'FIRMOS');

 COB  := CONN.NewObject(TFRE_DB_VIRTUAL_FILESERVER.ClassName);
// cob.Field('machineid').AsObjectLink:=wlan_machine_uid;
// COb.Field('servicegroup').AsObjectLink:=si;
 cob.Field('pool').asstring:='zones';
 fsname := 'Business';
 cob.Field('objname').asstring:= fsname;
 cob.Field('domainid').asguid := conn.DomainId('demo');
 cob.Field('domain').asstring := 'DEMO';
 cob.Field('ip').asstring:='10.1.0.147/24';
 fs := COB.UID;
 CheckDbResult(COLL.Store(cob),'Add Fileserver');


 _AddVShare('Accounting',true,false,true,false,4096,'DEMO');
 _AddVShare('Marketing',false,true,true,true,5012,'DEMO');
 _AddVShare('Management',false,false,false,true,2048,'DEMO');


 COB  := CONN.NewObject(TFRE_DB_GLOBAL_FILESERVER.ClassName);
// cob.Field('machineid').AsObjectLink:=wlan_machine_uid;
// COb.Field('servicegroup').AsObjectLink:=si;
 fs := COB.UID;
 CheckDbResult(COLL.Store(cob),'Add Fileserver');

 fsname := 'GlobalNFS';

 _AddNShare('home',20240);
 _AddNShare('rdp',40960);
 _AddNShare('backup',30360);

 fsname := 'SAN';

 _AddLun('600144F090832B3B000051DEAE750001',10240);
 _AddLun('600144F090832B3B000051DEAE780002',102400);

 ncoll := Conn.Collection('datalink');


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


 hcoll := Conn.Collection('hba');

 COB  := CONN.NewObject(TFRE_DB_FC_PORT.ClassName);
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

 COB  := CONN.NewObject(TFRE_DB_FC_PORT.ClassName);
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

 mcoll := Conn.Collection('setting');
 COB  := CONN.NewObject(TFRE_DB_MACHINE_SETTING_POWER.ClassName);
 cob.Field('objname').asstring:='Power State';
 cob.Field('poweroperation').asstring:='nothing';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');

 COB  := CONN.NewObject(TFRE_DB_MACHINE_SETTING_HOSTNAME.ClassName);
 cob.Field('objname').asstring:='Hostname';
 cob.Field('hostname').asstring:='firmbox';
 cob.Field('domainname').asstring:='firmos.at';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');

 COB  := CONN.NewObject(TFRE_DB_MACHINE_SETTING_TIME.ClassName);
 cob.Field('objname').asstring:='Time';
 cob.Field('region').asstring:='Europe';
 cob.Field('timezone').asstring:='Europe/Vienna';
 cob.Field('ntpserver').asstring:='pool.ntp.org';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');

 COB  := CONN.NewObject(TFRE_DB_MACHINE_SETTING_MAIL.ClassName);
 cob.Field('objname').asstring:='Mail';
 cob.Field('smtpserver').asstring:='localhost';
 cob.Field('mailfrom').asstring:='firmbox@firmos.at';
 cob.Field('mailto').asstring:='office@firmos.at';
 CheckDbResult(mCOLL.Store(cob),'Add Setting');



 CONN.Finalize;
end;

procedure InitDB(const dbname: string; const user, pass: string);
begin
  InitializeCorebox(dbname,user,pass);
  GenerateTestData(dbname,user,pass);
end;

procedure FIRMBOX_MetaRegister;
begin
  // Base Registrations
  FRE_DBBASE.Register_DB_Extensions;
  FRE_DBBUSINESS.Register_DB_Extensions;
  fos_firmbox_applianceapp.Register_DB_Extensions;
  fos_firmbox_userapp.Register_DB_Extensions;
  fos_firmbox_infrastructureapp.Register_DB_Extensions;
  fre_testcase.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fos_firmbox_fileserver.Register_DB_Extensions;
  fos_firmbox_servicesapp.Register_DB_Extensions;
  fos_firmbox_storageapp.Register_DB_Extensions;
  fos_firmbox_vmapp.Register_DB_Extensions;
  fos_firmbox_storeapp.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;
end;

procedure FIRMBOX_MetaInitializeDatabase(const dbname: string; const user, pass: string);
begin
  fos_firmbox_common.InitDB(dbname,user,pass);
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
    conn.RemoveApp('corebox_appliance');
    conn.RemoveApp('corebox_user');
    conn.RemoveApp('corebox_infrastructure');
    conn.RemoveApp('corebox_services');
    conn.RemoveApp('corebox_storage');
    conn.RemoveApp('corebox_vm');
  finally
    conn.Finalize;
  end;
end;

initialization

 GFRE_DBI_REG_EXTMGR.RegisterNewExtension('FIRMBOX',@FIRMBOX_MetaRegister,@FIRMBOX_MetaInitializeDatabase,@FIRMBOX_MetaRemove);


end.

