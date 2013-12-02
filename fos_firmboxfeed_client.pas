unit fos_firmboxfeed_client;

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

interface

uses
  Classes, SysUtils,fre_base_client,FOS_TOOL_INTERFACES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,FOS_VM_CONTROL_INTERFACE,
  fre_system,fos_stats_control_interface, fre_hal_disk,fre_dbbase,fre_zfs,fre_scsi;


type


  { TFRE_BOX_FEED_CLIENT }

  TFRE_BOX_FEED_CLIENT=class(TFRE_BASE_CLIENT)
  private
    FEED_Timer            : IFRE_APSC_TIMER;
    FVM_Feeding           : Boolean;
    FDISK_Feeding         : Boolean;
    FAPP_Feeding          : Boolean;
    FStorage_Feeding      : Boolean;
    FDiskInfo_Send        : Boolean;
    FPool_Send            : Boolean;
    FVM_FeedAppClass      : TFRE_DB_String;
    FVM_FeedAppUid        : TGuid;
    FSTORAGE_FeedAppClass : TFRE_DB_String;
    FSTORAGE_FeedAppUid   : TGuid;
    FAPPL_FeedAppClass    : TFRE_DB_String;
    FAPPL_FeedAppUid      : TGuid;
    vmc                   : IFOS_VM_HOST_CONTROL; // Todo Move MVStats to Statscontroller
    statscontroller       : IFOS_STATS_CONTROL;
    disk_hal              : TFRE_HAL_DISK;

    disk_information      : IFRE_DB_Object;
    pool_information      : IFRE_DB_Object;
    disks_sent            : boolean;
    pools_sent            : boolean;

  private
    procedure               _QuereInitialDiskInformation;
    procedure               _QuereInitialPoolInformation;


  public
    procedure  MySessionEstablished    (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  MySessionDisconnected   (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  QueryUserPass           (out user, pass: string); override;
    procedure  MyInitialize            ; override;
    procedure  MyFinalize              ; override;
    procedure  MyConnectionTimer       ; override;
    procedure  GenerateFeedDataTimer   (const TIM : IFRE_APSC_TIMER ; const flag1,flag2 : boolean); // Timout & CMD Arrived & Answer Arrived
  end;


implementation


procedure TFRE_BOX_FEED_CLIENT._QuereInitialDiskInformation;
var
    disks    : IFRE_DB_Object;

begin
  // send disk data once
  disks := disk_hal.GetDiskInformation(cFRE_REMOTE_USER,cFRE_REMOTE_HOST,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'),false);
  if disks.Field('resultcode').AsInt32<>0 then
    GFRE_DBI.LogError(dblc_APPLICATION,'COULD NOT GET DISK INFORMATION %d %s',[disks.Field('resultcode').AsInt32,disks.Field('error').AsString])
  else
    disk_information := disks;

end;

procedure TFRE_BOX_FEED_CLIENT._QuereInitialPoolInformation;
var
    pools    : IFRE_DB_Object;
    pool     : IFRE_DB_Object;
    i        : NativeInt;
    poolname : TFRE_DB_String;
    pool_res : IFRE_DB_Object;

begin
  pool_res   := GFRE_DBI.NewObject;

  // send all pool data once
  pools := disk_hal.GetPools(cFRE_REMOTE_USER,cFRE_REMOTE_HOST,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
  if pools.Field('resultcode').AsInt32<>0 then
    GFRE_DBI.LogError(dblc_APPLICATION,'COULD NOT GET POOL CONFIGURATION %d %s',[pools.Field('resultcode').AsInt32,pools.Field('error').AsString])
  else
    begin
      for i := 0 to pools.Field('data').ValueCount-1 do
        begin
          poolname := pools.Field('data').AsObjectItem[i].Field('name').asstring;
          pool     := disk_hal.GetPoolConfiguration(poolname,cFRE_REMOTE_USER,cFRE_REMOTE_HOST,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
          (pool.Field('data').asobject.Implementor_HC as TFRE_DB_ZFS_POOL).setZFSGuid(pools.Field('data').AsObjectItem[i].Field('zpool_guid').asstring);
          pool_res.Field('data').AddObject(pool.Field('data').asobject);
        end;
      pool_information := pool_res;
    end;

end;

procedure TFRE_BOX_FEED_CLIENT.MySessionEstablished(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  inherited;

  if Get_AppClassAndUid('TFRE_FIRMBOX_APPLIANCE_APP',FSTORAGE_FeedAppClass,FSTORAGE_FeedAppUid) then begin
//    FDISK_Feeding := True;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_APPLIANCE_APP APP NOT FOUND!');
  end;
  if Get_AppClassAndUid('TFRE_FIRMBOX_APPLIANCE_APP',FAPPL_FeedAppClass,FAPPL_FeedAppUid) then begin
//    FAPP_Feeding := True;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_APPLIANCE_APP APP NOT FOUND!');
  end;
  if Get_AppClassAndUid('TFRE_FIRMBOX_VM_APP',FVM_FeedAppClass,FVM_FeedAppUid) then begin
//    FVM_Feeding   := True;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_VM_APP APP NOT FOUND!');
  end;

  if Get_AppClassAndUid('TFRE_FIRMBOX_STORAGE_APP',FStorage_FeedAppClass,FSTORAGE_FeedAppUid) then begin
    // FStorage_Feeding   := True;
    disks_sent         := false;
    pools_sent         := false;

    // direct query debug mode
    _QuereInitialDiskInformation;
    _QuereInitialPoolInformation;

    SendServerCommand(FSTORAGE_FeedAppClass,'DISK_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),disk_information);
    disk_information := nil;

    SendServerCommand(FSTORAGE_FeedAppClass,'POOL_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),pool_information);
    pool_information := nil;

  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_STORAGE_APP APP NOT FOUND!');
  end;


  FEED_Timer := chanman.AddTimer(30000); // Beside the "normal 1 sec" Timer a 5 sec timer in the channel context
  FEED_Timer.TIM_SetID('FEED_'+inttostr(chanman.GetID));
  writeln('Generated Feedtimer 30 ',FEED_Timer.TIM_GetID);
  FEED_Timer.TIM_SetCallback(@GenerateFeedDataTimer);
  FEED_Timer.TIM_Start;


end;

procedure TFRE_BOX_FEED_CLIENT.MySessionDisconnected(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  FEED_Timer.Finalize;
  FVM_Feeding   := false;
  FDISK_Feeding := false;
  FAPP_Feeding  := false;
  FStorage_Feeding:= false;
  pools_sent      := false;
  disks_sent      := false;
end;

procedure TFRE_BOX_FEED_CLIENT.QueryUserPass(out user, pass: string);
begin
  user := cFRE_Feed_User;
  pass := cFRE_Feed_Pass;
end;

procedure TFRE_BOX_FEED_CLIENT.MyInitialize;
begin
//  FEED_Timer      := GFRE_S.AddPeriodicTimer (1000,@GenerateFeedDataTimer);
//  FEED_Timer30    := GFRE_S.AddPeriodicTimer (30000,@GenerateFeedDataTimer30);
  //vmc             := Get_VM_Host_Control     (cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  //vmc.VM_EnableVMMonitor                     (true);

  fre_dbbase.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;

  statscontroller := Get_Stats_Control       (cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  statscontroller.StartDiskPersistentMonitorParser(true);
  statscontroller.StartCPUParser(true);
  statscontroller.StartRAMParser(true);
  statscontroller.StartNetworkParser(true);
  statscontroller.StartCacheParser(true);
  statscontroller.StartZFSParser(true);
  statscontroller.StartZpoolIostatParser(true);

  disk_hal   := TFRE_HAL_DISK.Create;
  disks_sent := false;

  _QuereInitialDiskInformation;
  _QuereInitialPoolInformation;

end;

procedure TFRE_BOX_FEED_CLIENT.MyFinalize;
begin
  writeln('FEED CLIENT FINALIZE');
//  FEED_Timer.FinalizeIt;
//  FEED_Timer30.FinalizeIt;
  //vmc.Finalize ;

  disk_hal.Free;
  statscontroller.Finalize;

end;


var g_disc_delay : integer=0;

procedure TFRE_BOX_FEED_CLIENT.MyConnectionTimer;
var vmo : IFRE_DB_Object;
begin
  writeln('CONN TIMER');
  if FAPP_Feeding then
    begin
      try
        vmo := GFRE_DBI.NewObject;
        vmo.Field('LIVE STATUS FEED').AsString:='LSF_0.0.1';
        vmo.Field('TIMESTAMP').AsDateTimeUTC := GFRE_DT.Now_UTC;
        vmo.Field('CPU').AsObject := statscontroller.Get_CPU_Data;
        vmo.Field('VMSTAT').AsObject := statscontroller.Get_Ram_Data;
        vmo.Field('NET').AsObject := statscontroller.Get_Network_Data;
        vmo.Field('CACHE').AsObject := statscontroller.Get_CacheData;
        vmo.Field('DISK').AsObject := statscontroller.Get_Disk_Data;
        SendServerCommand(FAPPL_FeedAppClass,'RAW_DATA_FEED',TFRE_DB_GUIDArray.Create(FAPPL_FeedAppUid),vmo);
        //writeln('LIVEUPDATE SENT! ' , GFRE_DT.Now_UTC);
      except on e:exception do begin
        writeln('FEED EXCEPTION : ',e.Message);
      end;end;
    end;
  if FDISK_Feeding then
    begin
      try
        vmo := GFRE_DBI.NewObject;
        vmo.Field('DISK').AsObject := statscontroller.Get_Disk_Data;
        vmo.Field('ZPOOLIO').AsObject := statscontroller.Get_ZpoolIostat_Data;
        SendServerCommand(FSTORAGE_FeedAppClass,'RAW_DISK_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),vmo);
        //writeln('DISK LIVEUPDATE SENT!');
      except on e:exception do begin
        writeln('SEND DISK FEED EXCEPTION : ',e.Message);
      end;end;
    end;
  if FVM_Feeding then
    begin
      try
        SendServerCommand(FVM_FeedAppClass,'VM_FEED_UPDATE',TFRE_DB_GUIDArray.Create(FVM_FeedAppUid),vmc.Get_VM_Data);
        writeln('VM LIVEUPDATE SENT!');
      except on e:exception do begin
        writeln('VM LIVEUPDATE FEED EXCEPTION : ',e.Message);
      end;end;
    end;

  if FStorage_Feeding then
    begin
 //     writeln('disks_sent',disks_sent);
 //     writeln('pools_sent',pools_sent);
      if (Assigned(disk_information)) and (not disks_sent) then
        begin
          SendServerCommand(FSTORAGE_FeedAppClass,'DISK_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),disk_information.CloneToNewObject);
          disks_sent:=true;
        end;
      if (Assigned(pool_information)) and (disks_sent) and (not pools_sent) then
        begin
          SendServerCommand(FSTORAGE_FeedAppClass,'POOL_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),pool_information.CloneToNewObject);
          pools_sent:=true;
        end;
    end;
end;

procedure TFRE_BOX_FEED_CLIENT.GenerateFeedDataTimer(const TIM: IFRE_APSC_TIMER; const flag1, flag2: boolean);
var vmo : IFRE_DB_Object;
begin
  if FAPP_Feeding then
    begin
      try
        vmo := GFRE_DBI.NewObject;
        vmo.Field('LIVE STATUS FEED 30').AsString:='LSF30_0.0.1';
        vmo.Field('ZFS').AsObject := statscontroller.Get_ZFS_Data_Once;
        SendServerCommand(FAPPL_FeedAppClass,'RAW_DATA_FEED30',TFRE_DB_GUIDArray.Create(FAPPL_FeedAppUid),vmo);
        //writeln('LIVEUPDATE (30) SENT! ' , GFRE_DT.Now_UTC);
      except on e:exception do begin
        writeln('FEED EXCEPTION : ',e.Message);
      end;end;
    end;
end;

end.

