unit fre_hal_disk;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2013, FirmOS Business Solutions GmbH
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

      * Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the documentation
        and/or other materials provided with the distribution.
      * Neither the name of the <FirmOS Business Solutions GmbH> nor the names
        of its contributors may be used to endorse or promote products derived
        from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
(§LIC_END)
}

{$mode objfpc}{$H+}
{$codepage UTF8}
{$modeswitch nestedprocvars}
{$interfaces corba}

interface

uses
  Classes, SysUtils,FRE_DB_INTERFACE, FRE_DB_COMMON, FRE_PROCESS, FOS_BASIS_TOOLS,
  FOS_TOOL_INTERFACES,FRE_ZFS,fre_scsi,fre_base_parser,FRE_SYSTEM;


type

  { TFRE_HAL_DISK }

  TFRE_HAL_DISK = class (TFRE_DB_Base)
  private

    data_lock                          : IFOS_LOCK;
    Fdata                              : IFRE_DB_Object;

  public
    constructor Create                 ; override;
    destructor  Destroy                ; override;

//    procedure InitializeDiskandEnclosureInformation (const remoteuser:string='';const remotehost:string='';const remotekey:string='');
    procedure InitializePoolInformation             (const remoteuser:string='';const remotehost:string='';const remotekey:string='');

    procedure ReceivedDBO                           (const dbo:IFRE_DB_Object);
    procedure UpdateDiskAndEnclosure                (const dbo:IFRE_DB_Object);
    procedure UpdateIostat                          (const dbo:IFRE_DB_Object);
    procedure UpdateZpoolStatus                     (const dbo:IFRE_DB_Object);
    procedure UpdateZpoolIostat                     (const dbo:IFRE_DB_Object);

    procedure CheckDifferences                      (const old_fdata:IFRE_DB_Object);

    function  IsDataAvailable                       :boolean;

    function  GetData                               : IFRE_DB_Object;

//    function  FetchDiskAndEnclosureInformation      (const remoteuser:string='';const remotehost:string='';const remotekey:string=''): IFRE_DB_OBJECT;
    function  FetchPoolConfiguration                (const zfs_pool_name:string; const remoteuser:string='';const remotehost:string='';const remotekey:string=''): IFRE_DB_OBJECT;

    procedure UpdateDiskIoStatInformation           (const devicename:string; const iostat_information: TFRE_DB_IOSTAT);

    function  GetPools                  (const remoteuser:string='';const remotehost:string='';const remotekey:string=''): IFRE_DB_OBJECT;
    function  CreateDiskpool            (const input:IFRE_DB_Object; const remoteuser:string='';const remotehost:string='';const remotekey:string=''): IFRE_DB_OBJECT;

  published
    procedure REM_GetDiskInformation    (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure REM_GetPools              (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure REM_GetPoolConfiguration  (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure REM_CreateDiskpool        (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
  end;

implementation


{ TFRE_HAL_DISK }

constructor TFRE_HAL_DISK.Create;
var indbo:IFRE_DB_Object;
begin
  inherited;
  GFRE_TF.Get_Lock(data_lock);
  Fdata:=GFRE_DBI.NewObject;

  //indbo :=GFRE_DBI.CreateFromFile('DISKENC');
  //ReceivedDBO(indbo);
  //indbo :=GFRE_DBI.CreateFromFile('DISKENC');
  //ReceivedDBO(indbo);
end;

destructor TFRE_HAL_DISK.Destroy;
begin

  data_lock.Finalize;
  Fdata.Finalize;

  inherited Destroy;
end;

//procedure TFRE_HAL_DISK.InitializeDiskandEnclosureInformation(const remoteuser: string; const remotehost: string; const remotekey: string);
//var
//    disks    : IFRE_DB_Object;
//begin
//  disks := FetchDiskAndEnclosureInformation(remoteuser,remotehost,remotekey);
//  if disks.Field('resultcode').AsInt32<>0 then
//    begin
//      GFRE_DBI.LogError(dblc_APPLICATION,'COULD NOT GET DISK INFORMATION %d %s',[disks.Field('resultcode').AsInt32,disks.Field('error').AsString]);
//      disks.Finalize;
//    end
//  else
//    begin
//      data_lock.Acquire;
//      try
//        if Assigned(Fdata) then
//          Fdata.Finalize;
//        Fdata := disks.Field('data').AsObject.CloneToNewObject(false);
//        disks.Finalize;
//      finally
//        data_lock.Release;
//      end;
//    end;
//end;

procedure TFRE_HAL_DISK.InitializePoolInformation(const remoteuser: string; const remotehost: string; const remotekey: string);
var
    pools    : IFRE_DB_Object;
    pool     : IFRE_DB_Object;
    i        : NativeInt;
    poolname : TFRE_DB_String;

begin

  // send all pool data once
  pools := GetPools(remoteuser,remotehost,remotekey);
  if pools.Field('resultcode').AsInt32<>0 then
    begin
      GFRE_DBI.LogError(dblc_APPLICATION,'COULD NOT GET POOL CONFIGURATION %d %s',[pools.Field('resultcode').AsInt32,pools.Field('error').AsString]);
      pools.Finalize;
    end
  else
    begin
      for i := 0 to pools.Field('data').ValueCount-1 do
        begin
          poolname := pools.Field('data').AsObjectItem[i].Field('name').asstring;
          pool     := FetchPoolConfiguration(poolname,remoteuser,remotehost,remotekey);
          (pool.Field('data').asobject.Implementor_HC as TFRE_DB_ZFS_POOL).setZFSGuid(pools.Field('data').AsObjectItem[i].Field('zpool_guid').asstring);

          data_lock.Acquire;
          try
            if Fdata.FieldExists('pools')=false then
              Fdata.Field('pools').AddObject(GFRE_DBI.NewObject);
            Fdata.Field('pools').asobject.Field(poolname).asObject:=pool.Field('data').asobject;
          finally
            data_lock.Release;
          end;
        end;
    end;

end;

procedure TFRE_HAL_DISK.ReceivedDBO(const dbo: IFRE_DB_Object);
var subfeedmodule:string;
begin
//  writeln(dbo.DumpToString());
  subfeedmodule := dbo.Field('SUBFEED').asstring;
  if subfeedmodule='DISKENCLOSURE' then
    UpdateDiskAndEnclosure(dbo.Field('data').asobject)
  else
    if subfeedmodule='IOSTAT' then
      UpdateIostat(dbo.Field('data').asobject)
    else
      if subfeedmodule='ZPOOLSTATUS' then
        UpdateZpoolStatus(dbo.Field('data').asobject)
      else
        if subfeedmodule='ZPOOLIOSTAT' then
          UpdateZpoolIostat(dbo.Field('data').asobject)
        else
          writeln('UNHANDLED SUBFEEDMODULE ',subfeedmodule);

end;

procedure TFRE_HAL_DISK.UpdateDiskAndEnclosure(const dbo: IFRE_DB_Object);
var
  last_fdata:IFRE_DB_Object;

  procedure _UpdateDisks(const obj:IFRE_DB_Object);
  var feed_disk : TFRE_DB_ZFS_BLOCKDEVICE;
      old_obj   : IFRE_DB_OBject;
  begin
    feed_disk := obj.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE;
    if fdata.FetchObjWithStringFieldValue('DEVICEIDENTIFIER',feed_disk.DeviceIdentifier,old_obj,'') then
      begin
        old_obj.SetAllSimpleObjectFieldsFromObject(feed_disk);
      end
    else
      begin
        fdata.Field('disks').asObject.Field(feed_disk.Field('DEVICEIDENTIFIER').asstring).asobject:=feed_disk.CloneToNewObject;
      end;
  end;

  procedure _UpdateEnclosures(const obj:IFRE_DB_Object);
  var feed_enclosure : TFRE_DB_ENCLOSURE;
      old_enclosure  : IFRE_DB_OBject;

    procedure _UpdateSlots(const slotobj:IFRE_DB_Object);
    var feed_slot    : TFRE_DB_DRIVESLOT;
        old_slot     : IFRE_DB_Object;
    begin
      feed_slot      := slotobj.Implementor_HC as TFRE_DB_DRIVESLOT;
      if fdata.FetchObjWithStringFieldValue('DEVICEIDENTIFIER',feed_slot.DeviceIdentifier,old_slot,'') then
        begin
          old_slot.SetAllSimpleObjectFieldsFromObject(feed_slot);
        end
      else
        begin
          (old_enclosure.Implementor_HC as TFRE_DB_ENCLOSURE).AddDriveSlotEmbedded(feed_slot.SlotNr,(feed_slot.CloneToNewObject.Implementor_HC as TFRE_DB_DRIVESLOT));
        end;
    end;

    procedure _UpdateExpanders(const expanderobj:IFRE_DB_Object);
    var feed_expander    : TFRE_DB_SAS_EXPANDER;
        old_expander     : IFRE_DB_Object;
    begin
      feed_expander      := expanderobj.Implementor_HC as TFRE_DB_SAS_EXPANDER;
      if fdata.FetchObjWithStringFieldValue('DEVICEIDENTIFIER',feed_expander.DeviceIdentifier,old_expander,'') then
        begin
          old_expander.SetAllSimpleObjectFieldsFromObject(feed_expander);
        end
      else
        begin
          (old_enclosure.Implementor_HC as TFRE_DB_ENCLOSURE).AddExpanderEmbedded((feed_expander.CloneToNewObject.Implementor_HC as TFRE_DB_SAS_EXPANDER));
        end;
    end;

  begin
    feed_enclosure   := obj.Implementor_HC as TFRE_DB_ENCLOSURE;
    if fdata.FetchObjWithStringFieldValue('DEVICEIDENTIFIER',feed_enclosure.DeviceIdentifier,old_enclosure,'') then
      begin
        old_enclosure.SetAllSimpleObjectFieldsFromObject(feed_enclosure);
        feed_enclosure.Field('slots').AsObject.ForAllObjects(@_updateslots);
        feed_enclosure.Field('expanders').AsObject.ForAllObjects(@_updateexpanders);
      end
    else
      begin
        fdata.Field('enclosures').asObject.Field(feed_enclosure.Field('DEVICEIDENTIFIER').asstring).asobject:=feed_enclosure.CloneToNewObject;
      end;

  end;

begin
  data_lock.Acquire;
  try
    last_fdata := fdata.CloneToNewObject;


    if not Fdata.FieldExists('disks') then
      fdata.Field('disks').AsObject:=GFRE_DBI.NewObject;
    dbo.Field('disks').AsObject.ForAllObjects(@_updatedisks);

    if not Fdata.FieldExists('enclosures') then
      fdata.Field('enclosures').AsObject:=GFRE_DBI.NewObject;

    dbo.Field('enclosures').AsObject.ForAllObjects(@_updateenclosures);

//    writeln('FDATA:',fdata.DumpToString());
//    writeln('OLDFDATA:',last_fdata.DumpToString());

//    CheckDifferences(last_fdata);

    last_fdata.Finalize;
  finally
    data_lock.Release;
  end;
end;

procedure TFRE_HAL_DISK.UpdateIostat(const dbo: IFRE_DB_Object);

  procedure _UpdateIostat(const obj:IFRE_DB_Object);
  var feed_io   : TFRE_DB_IOSTAT;
      old_obj   : IFRE_DB_Object;
      disk_obj  : IFRE_DB_Object;
      new_io    : IFRE_DB_Object;
  begin
    feed_io     := obj.Implementor_HC as TFRE_DB_IOSTAT;
    if fdata.FetchObjWithStringFieldValue('IODEVICENAME',feed_io.Field('iodevicename').asstring,old_obj,'TFRE_DB_IOSTAT') then
      begin
        old_obj.SetAllSimpleObjectFieldsFromObject(feed_io);
      end
    else
      begin
        if fdata.FetchObjWithStringFieldValue('DEVICENAME',feed_io.Field('iodevicename').asstring,old_obj,'') then
          begin
            new_io := feed_io.CloneToNewObject;
            (old_obj.Implementor_HC as TFRE_DB_ZFS_OBJ).IoStat:=(new_io.Implementor_HC as TFRE_DB_IOSTAT);
          end
        else
          begin
            writeln('update iostat for unknown devicename:',feed_io.Field('iodevicename').asstring);
          end;
      end;
  end;

begin
  exit;
  data_lock.Acquire;
  try
//    writeln('IOSTAT',dbo.DumpToString());

    dbo.ForAllObjects(@_updateiostat);

  finally
    data_lock.Release;
  end;
end;

procedure TFRE_HAL_DISK.UpdateZpoolStatus(const dbo: IFRE_DB_Object);

  procedure _UpdatePools(const obj:IFRE_DB_Object);
  var feed_pool : TFRE_DB_ZFS_POOL;
      old_obj   : IFRE_DB_Object;


    procedure _UpdateHierarchic(const obj:IFRE_DB_Object; var halt:boolean);
    var zfs_guid : string;
        zfs_obj  : IFRE_DB_Object;
    begin
      halt :=false;
      zfs_guid :=obj.Field('zfs_guid').asstring;
      if zfs_guid<>'' then
        begin
          if fdata.FetchObjWithStringFieldValue('ZFS_GUID',zfs_guid,old_obj,'') then
            begin
//              writeln('found:',zfs_guid);
              old_obj.SetAllSimpleObjectFieldsFromObject(obj);
            end
          else
            writeln('could not find ',zfs_guid);
        end;
    end;

  begin
    feed_pool   := obj.Implementor_HC as TFRE_DB_ZFS_POOL;
    if fdata.FetchObjWithStringFieldValue('POOL',feed_pool.Field('pool').asstring,old_obj,'TFRE_DB_ZFS_POOL') then
      begin
        old_obj.SetAllSimpleObjectFieldsFromObject(feed_pool);
        feed_pool.ForAllObjectsBreakHierarchic(@_updateHierarchic);
      end
    else
      begin
        fdata.Field('pools').AsObject.Field(feed_pool.Field('pool').asstring).AsObject:=feed_pool.CloneToNewObject;
      end;
  end;


begin
  data_lock.Acquire;
  try

    if not Fdata.FieldExists('pools') then
      fdata.Field('pools').AsObject:=GFRE_DBI.NewObject;

//    writeln('ZPOOLSTATUS',dbo.DumpToString());

    dbo.ForAllObjects(@_updatepools);
//    writeln('FDATA',fdata.DumpToString());

  finally
    data_lock.Release;
  end;

end;

procedure TFRE_HAL_DISK.UpdateZpoolIostat(const dbo: IFRE_DB_Object);

  procedure _UpdatezpoolIostat(const obj:IFRE_DB_Object);
  var feed_zpool_io   : TFRE_DB_ZPOOL_IOSTAT;
      old_obj         : IFRE_DB_Object;
      new_io          : IFRE_DB_Object;
  begin
//    writeln('xxx1');
    feed_zpool_io     := obj.Implementor_HC as TFRE_DB_ZPOOL_IOSTAT;
//    writeln(feed_zpool_io.DumpToString());
//    writeln(feed_zpool_io.Field('zfs_guid').asstring);
    if fdata.FetchObjWithStringFieldValue('ZFS_GUID',feed_zpool_io.Field('ZFS_GUID').asstring,old_obj,'TFRE_DB_ZPOOL_IOSTAT') then
      begin
//        writeln('update zpool iostat direct');
        old_obj.SetAllSimpleObjectFieldsFromObject(feed_zpool_io);
      end
    else
      begin
        if fdata.FetchObjWithStringFieldValue('ZFS_GUID',feed_zpool_io.Field('ZFS_GUID').asstring,old_obj,'') then
          begin
//            writeln('new zpool iostat');
            new_io := feed_zpool_io.CloneToNewObject;
            (old_obj.Implementor_HC as TFRE_DB_ZFS_OBJ).ZPoolIostat:=(new_io.Implementor_HC as TFRE_DB_ZPOOL_IOSTAT);
          end
        else
          begin
            writeln('update zpool iostat for unknown zfs guid:',feed_zpool_io.Field('zfs_guid').asstring);
          end;
      end;
  end;

  procedure _UpdatePool(const zobj:IFRE_DB_Object);
  begin
    zobj.ForAllObjects(@_UpdatezpoolIostat);
  end;

begin
  data_lock.Acquire;
  try

    if not Fdata.FieldExists('pools') then
      fdata.Field('pools').AsObject:=GFRE_DBI.NewObject;

//    writeln('ZPOOLIOSTAT',dbo.DumpToString());

    dbo.ForAllObjects(@_UpdatePool);

//    writeln('FDATA',fdata.DumpToString());

  finally
    data_lock.Release;
  end;

end;

procedure TFRE_HAL_DISK.CheckDifferences(const old_fdata: IFRE_DB_Object);
var new_fdata:IFRE_DB_Object;

  procedure _Insert(const o : IFRE_DB_Object);
  begin
    writeln('INSERT STEP : ',o.UID_String,' ',o.SchemeClass,' ',BoolToStr(o.IsObjectRoot,' ROOT OBJECT ',' CHILD OBJECT '));
    writeln(o.DumpToString(2));
  end;

  procedure _Delete(const o : IFRE_DB_Object);
    function  _ParentFieldnameIfExists:String;
    begin
      if not o.IsObjectRoot then
        result := o.ParentField.FieldName
      else
        result := '';
    end;

  begin
    writeln('DELETE STEP : ',o.UID_String,' ',o.SchemeClass,BoolToStr(o.IsObjectRoot,' ROOT OBJECT ',' CHILD OBJECT '),_ParentFieldnameIfExists);
    writeln(o.DumpToString(2));
  end;

  procedure _Update(const is_child_update : boolean ; const update_obj : IFRE_DB_Object ; const update_type :TFRE_DB_ObjCompareEventType  ;const new_field, old_field: IFRE_DB_Field);
  var nfn,nft,ofn,oft,updt,ofv,nfv : TFRE_DB_NameType;
  begin
    if assigned(new_field) then
      begin
        nfn := new_field.FieldName;
        nft := new_field.FieldTypeAsString;
        if new_field.IsEmptyArray then
          nfv := '(empty array)'
        else
          nfv := new_field.AsString;
      end;
    if assigned(old_field) then
      begin
        ofn := old_field.FieldName;
        oft := old_field.FieldTypeAsString;
        if old_field.IsEmptyArray then
          ofv := '(empty array)'
        else
          ofv := old_field.AsString;
      end;
    case update_type of
      cev_FieldDeleted: updt := 'DELETE FIELD '+nfn+'('+nft+')';
      cev_FieldAdded:   updt := 'ADD FIELD '+nfn+'('+nft+')';
      cev_FieldChanged: updt := 'CHANGE FIELD : '+nfn+' FROM '+ofv+':'+oft+' TO '+nfv+':'+nft;
    end;
    writeln('UPDATE STEP : ',BoolToStr(is_child_update,' CHILD UPDATE ',' ROOT UPDATE '), update_obj.UID_String,' ',update_obj.SchemeClass,' '+updt);
  end;
begin
  new_fdata:=GetData;
  try
    GFRE_DBI.GenerateAnObjChangeList(old_fdata,new_fdata,@_Insert,@_Delete,@_Update);
  finally
    new_fdata.Finalize;
  end;
end;

function TFRE_HAL_DISK.IsDataAvailable: boolean;
begin
  result := Assigned(Fdata);
  if result then
    result := Fdata.FieldExists('enclosures');
  if result then
    result := Fdata.FieldExists('disks');
  if result then
    result := Fdata.FieldExists('pools');
end;

function TFRE_HAL_DISK.GetData: IFRE_DB_Object;
begin
  if IsDataAvailable then
    begin
      data_lock.Acquire;
      try
        result := Fdata.CloneToNewObject;
      finally
        data_lock.Release;
      end;
    end
  else
    result := nil;
end;


//function TFRE_HAL_DISK.FetchDiskAndEnclosureInformation(const remoteuser: string; const remotehost: string; const remotekey: string): IFRE_DB_OBJECT;
//var so    : TFRE_DB_SCSI;
//    obj   : IFRE_DB_Object;
//    error : string;
//    res   : integer;
//begin
//  so     := TFRE_DB_SCSI.create;
//  try
//    so.SetRemoteSSH(remoteuser, remotehost, remotekey);
//    res    := so.GetSG3DiskAndEnclosureInformation(error,obj);
////    res    := so.GetDiskInformation(error,obj);
//    result := GFRE_DBI.NewObject;
//    result.Field('resultcode').AsInt32 := res;
//    result.Field('error').asstring     := error;
//    result.Field('data').AsObject      := obj;
//  finally
//    so.Free;
//  end;
//end;

function TFRE_HAL_DISK.GetPools(const remoteuser: string; const remotehost: string; const remotekey: string): IFRE_DB_OBJECT;
var zo    : TFRE_DB_ZFS;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
begin
  zo     := TFRE_DB_ZFS.create;
  try
    zo.SetRemoteSSH(remoteuser, remotehost, remotekey);
    res    := zo.GetPools(error,obj);
    result := GFRE_DBI.NewObject;
    result.Field('resultcode').AsInt32 := res;
    result.Field('error').asstring     := error;
    result.Field('data').AsObject      := obj;
  finally
    zo.Free;
  end;
end;

function TFRE_HAL_DISK.FetchPoolConfiguration(const zfs_pool_name: string; const remoteuser: string; const remotehost: string; const remotekey: string): IFRE_DB_OBJECT;
var zo    : TFRE_DB_ZFS;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
begin
  zo     := TFRE_DB_ZFS.create;
  try
    zo.SetRemoteSSH(remoteuser, remotehost, remotekey);
    res    := zo.GetPoolStatus(zfs_pool_name,error,obj);
    result := GFRE_DBI.NewObject;
    result.Field('resultcode').AsInt32 := res;
    result.Field('error').asstring     := error;
    result.Field('data').AsObject      := obj;
  finally
    zo.Free;
  end;
end;

procedure TFRE_HAL_DISK.UpdateDiskIoStatInformation(const devicename: string; const iostat_information: TFRE_DB_IOSTAT);

  function _FindDiskbyDevicename (const fld:IFRE_DB_FIELD):boolean;
  var
    disk : TFRE_DB_ZFS_BLOCKDEVICE;
  begin
    result := false;
    if fld.FieldType=fdbft_Object then
      begin
        disk := (fld.AsObject.Implementor_HC as TFRE_DB_ZFS_BLOCKDEVICE);
        if disk.DeviceName=devicename then
          begin
            disk.IoStat:=iostat_information;
            result :=true;
          end;
      end;
  end;
begin
 data_lock.Acquire;
 try
   Fdata.Field('disks').AsObject.ForAllFieldsBreak(@_FindDiskbyDevicename);
 finally
   data_lock.Release;
 end;
end;

function TFRE_HAL_DISK.CreateDiskpool(const input: IFRE_DB_Object; const remoteuser: string; const remotehost: string; const remotekey: string): IFRE_DB_OBJECT;
var zo    : TFRE_DB_ZFS;
    obj   : IFRE_DB_Object;
    error : string;
    res   : integer;
begin
  zo     := TFRE_DB_ZFS.create;
  try
    zo.SetRemoteSSH(remoteuser, remotehost, remotekey);
    res    := zo.CreateDiskpool(input,error,obj);
    result := GFRE_DBI.NewObject;
    result.Field('resultcode').AsInt32 := res;
    result.Field('error').asstring     := error;
    result.Field('data').AsObject      := obj;
  finally
    zo.Free;
  end;
end;

procedure TFRE_HAL_DISK.REM_GetDiskInformation(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
begin
  // AnswerSyncCommand(command_id,GetDiskInformation(input.Field('remoteuser').asstring,input.Field('remotehost').asstring,input.Field('remotekey').asstring));
  input.Finalize;
end;

procedure TFRE_HAL_DISK.REM_GetPools(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
begin
  // AnswerSyncCommand(command_id,GetPools(input.Field('remoteuser').asstring,input.Field('remotehost').asstring,input.Field('remotekey').asstring));
  input.Finalize;
end;

procedure TFRE_HAL_DISK.REM_GetPoolConfiguration(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
begin
  // AnswerSyncCommand(command_id,GetPoolConfiguration(input.Field('poolname').asstring,input.Field('remoteuser').asstring,input.Field('remotehost').asstring,input.Field('remotekey').asstring));
  input.Finalize;
end;

procedure TFRE_HAL_DISK.REM_CreateDiskpool(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
begin
  // AnswerSyncCommand(command_id,CreateDiskpool(input,input.Field('remoteuser').asstring,input.Field('remotehost').asstring,input.Field('remotekey').asstring));
  input.Finalize;
end;

//function TFOS_STATS_CONTROL.Get_Disk_Data: IFRE_DB_Object;
//var
//  DISKAGGR: IFRE_DB_Object;
//
//  procedure _addDisk(const field: IFRE_DB_Field);
//    begin
//    if pos('C',field.FieldName)<>1 then exit; //fixxme - hack to check for disks
//    DISKAGGR.Field('rps').AsInt64:=DISKAGGR.Field('rps').AsInt64 + field.AsObject.Field('rps').AsInt64;
//    DISKAGGR.Field('wps').AsInt64:=DISKAGGR.Field('wps').AsInt64 + field.AsObject.Field('wps').AsInt64;
//  end;
//
//begin
//  result := FDiskMon.Get_Data_Object;
//  DISKAGGR:=GFRE_DBI.NewObject;
//  DISKAGGR.Field('rps').AsInt64:=0;
//  DISKAGGR.Field('wps').AsInt64:=0;
//  result.ForAllFields(@_addDisk);
//
//  result.Field('disk_aggr').AsObject := DISKAGGR;
//end;


end.

