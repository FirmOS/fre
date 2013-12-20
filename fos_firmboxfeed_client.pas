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
    FVM_FeedAppClass      : TFRE_DB_String;
    FVM_FeedAppUid        : TGuid;
    FSTORAGE_FeedAppClass : TFRE_DB_String;
    FSTORAGE_FeedAppUid   : TGuid;
    FAPPL_FeedAppClass    : TFRE_DB_String;
    FAPPL_FeedAppUid      : TGuid;
    vmc                   : IFOS_VM_HOST_CONTROL; // Todo Move MVStats to Statscontroller
    statscontroller       : IFOS_STATS_CONTROL;
    disk_hal              : TFRE_HAL_DISK;

    disks_sent            : boolean;

  private

  public
    procedure  MySessionEstablished    (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  MySessionDisconnected   (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  QueryUserPass           (out user, pass: string); override;
    procedure  MyInitialize            ; override;
    procedure  MyFinalize              ; override;
    procedure  MyConnectionTimer       ; override;
    procedure  GenerateFeedDataTimer   (const TIM : IFRE_APSC_TIMER ; const flag1,flag2 : boolean); // Timout & CMD Arrived & Answer Arrived
    procedure  SubfeederEvent          (const id:string; const dbo:IFRE_DB_Object);override;
  published
    procedure  REM_REQUESTDISKDATA     (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
  end;


implementation




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
    FStorage_Feeding   := True;
    disks_sent         := false;
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
  disks_sent      := false;
  inherited;
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
  statscontroller.StartCPUParser(true);
  statscontroller.StartRAMParser(true);
  statscontroller.StartNetworkParser(true);
  statscontroller.StartCacheParser(true);
  statscontroller.StartZFSParser(true);


  disk_hal   := TFRE_HAL_DISK.Create;
  disks_sent := false;
//  disk_hal.InitializeDiskandEnclosureInformation(cFRE_REMOTE_USER,cFRE_REMOTE_HOST,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));
//  disk_hal.InitializePoolInformation(cFRE_REMOTE_USER,cFRE_REMOTE_HOST,SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/user/id_rsa'));

  if cFRE_SUBFEEDER_IP='' then
    AddSubFeederEventViaUX('disksub')
  else
    AddSubFeederEventViaTCP(cFRE_SUBFEEDER_IP,'44101','disksub');

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
  //if FAPP_Feeding then
  //  begin
  //    try
  //      vmo := GFRE_DBI.NewObject;
  //      vmo.Field('LIVE STATUS FEED').AsString:='LSF_0.0.1';
  //      vmo.Field('TIMESTAMP').AsDateTimeUTC := GFRE_DT.Now_UTC;
  //      vmo.Field('CPU').AsObject := statscontroller.Get_CPU_Data;
  //      vmo.Field('VMSTAT').AsObject := statscontroller.Get_Ram_Data;
  //      vmo.Field('NET').AsObject := statscontroller.Get_Network_Data;
  //      vmo.Field('CACHE').AsObject := statscontroller.Get_CacheData;
  //      SendServerCommand(FAPPL_FeedAppClass,'RAW_DATA_FEED',TFRE_DB_GUIDArray.Create(FAPPL_FeedAppUid),vmo);
  //      //writeln('LIVEUPDATE SENT! ' , GFRE_DT.Now_UTC);
  //    except on e:exception do begin
  //      writeln('FEED EXCEPTION : ',e.Message);
  //    end;end;
  //  end;
  //if FDISK_Feeding then
  //  begin
  //    try
  //      vmo := GFRE_DBI.NewObject;
  //      vmo.Field('ZPOOLIO').AsObject := statscontroller.Get_ZpoolIostat_Data;
  //      SendServerCommand(FSTORAGE_FeedAppClass,'RAW_DISK_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),vmo);
  //      //writeln('DISK LIVEUPDATE SENT!');
  //    except on e:exception do begin
  //      writeln('SEND DISK FEED EXCEPTION : ',e.Message);
  //    end;end;
  //  end;
  //if FVM_Feeding then
  //  begin
  //    try
  //      SendServerCommand(FVM_FeedAppClass,'VM_FEED_UPDATE',TFRE_DB_GUIDArray.Create(FVM_FeedAppUid),vmc.Get_VM_Data);
  //      writeln('VM LIVEUPDATE SENT!');
  //    except on e:exception do begin
  //      writeln('VM LIVEUPDATE FEED EXCEPTION : ',e.Message);
  //    end;end;
  //  end;
  //
  if FStorage_Feeding then
    begin
 //     writeln('disks_sent',disks_sent);
      if (disk_hal.IsDataAvailable) and (not disks_sent) then
        begin
          SendServerCommand(FSTORAGE_FeedAppClass,'DISK_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),disk_hal.GetData);
          disks_sent:=true;
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

procedure TFRE_BOX_FEED_CLIENT.SubfeederEvent(const id: string; const dbo: IFRE_DB_Object);
begin
  disk_hal.ReceivedDBO(dbo);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_REQUESTDISKDATA(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var   reply_Data  : IFRE_DB_Object;
begin
  disks_sent:=false;
  writeln('SWL: REQUESTING DISK DATA');
  reply_data := GFRE_DBI.NewObject;
  AnswerSyncCommand(command_id,reply_data);
end;

end.

