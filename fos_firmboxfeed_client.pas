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
  fre_system,fos_stats_control_interface, fre_hal_disk_enclosure_pool_mangement,fre_dbbase,fre_zfs,fre_scsi,fre_hal_schemes,fre_dbbusiness,
  fre_diff_transport;


type


  { TFRE_BOX_FEED_CLIENT }

  TFRE_BOX_FEED_CLIENT=class(TFRE_BASE_CLIENT)
  private
    FEED_Timer            : IFRE_APSC_TIMER;
    FVM_Feeding           : Boolean;
    FDISK_Feeding         : Boolean;
    FAPP_Feeding          : Boolean;
    FStorage_Feeding      : Boolean;
    FVM_FeedAppClass      : TFRE_DB_String;
    FVM_FeedAppUid        : TFRE_DB_Guid;
    FSTORAGE_FeedAppClass : TFRE_DB_String;
    FSTORAGE_FeedAppUid   : TFRE_DB_Guid;
    FAPPL_FeedAppClass    : TFRE_DB_String;
    FAPPL_FeedAppUid      : TFRE_DB_Guid;
    vmc                   : IFOS_VM_HOST_CONTROL; // Todo Move MVStats to Statscontroller
    statscontroller       : IFOS_STATS_CONTROL;
    disk_hal              : TFRE_HAL_DISK_ENCLOSURE_POOL_MANAGEMENT;

  private
    procedure  CCB_RequestDiskEncPoolData  (const DATA : IFRE_DB_Object ; const status:TFRE_DB_COMMAND_STATUS ; const error_txt:string);


  public
    procedure  MySessionEstablished    (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  MySessionDisconnected   (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  QueryUserPass           (out user, pass: string); override;
    procedure  MyInitialize            ; override;
    procedure  MyRegisterClasses       ; override;
    procedure  MyFinalize              ; override;
    procedure  MyConnectionTimer       ; override;
    procedure  GenerateFeedDataTimer   (const TIM : IFRE_APSC_TIMER ; const flag1,flag2 : boolean); // Timout & CMD Arrived & Answer Arrived
    procedure  SubfeederEvent          (const id:string; const dbo:IFRE_DB_Object);override;
  published
    procedure  REM_BROWSEPATH          (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_REQUESTDISKDATA     (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
  end;


implementation



procedure TFRE_BOX_FEED_CLIENT.CCB_RequestDiskEncPoolData(const DATA: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const error_txt: string);
begin
  GFRE_DBI.LogNotice(dblc_FLEXCOM,'CCB_RequestDiskEncPoolData '+ inttostr(Ord(status)));
  case status of
    cdcs_OK: begin
      disk_hal.ServerDiskEncPoolDataAnswer(data);
      FStorage_Feeding   := True;
    end;
    cdcs_TIMEOUT: ;
    cdcs_ERROR: begin
       GFRE_BT.CriticalAbort('Request DiskEncPoolData Error - Server Returned Error: '+error_txt);
    end;
  end;
end;

procedure TFRE_BOX_FEED_CLIENT.MySessionEstablished(const chanman: IFRE_APSC_CHANNEL_MANAGER);
var i           : integer;
    machineUIDS : TFRE_DB_GUIDArray;
    dummydata   : IFRE_DB_Object;
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
    disk_hal.ResetToUnInitialized;
    machineUIDS := GetMyMachineUIDs;
    for i:=0 to high(machineUIDS) do begin
      GFRE_DBI.LogNotice(dblc_FLEXCOM,'SENDING REQUEST FOR MACHINE REQUEST_DISK_ENC_POOL_DATA '+FREDB_G2H(machineUIDS[i]));
      SendServerCommand('TFRE_DB_MACHINE','REQUEST_DISK_ENC_POOL_DATA',TFRE_DB_GUIDArray.Create(machineUIDS[i]),nil,@CCB_RequestDiskEncPoolData);
    end;
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

  //statscontroller := Get_Stats_Control       (cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  //statscontroller.StartCPUParser(true);
  //statscontroller.StartRAMParser(true);
  //statscontroller.StartNetworkParser(true);
  //statscontroller.StartCacheParser(true);
  //statscontroller.StartZFSParser(true);


  disk_hal   := TFRE_HAL_DISK_ENCLOSURE_POOL_MANAGEMENT.Create;

  if cFRE_SUBFEEDER_IP='' then
    AddSubFeederEventViaUX('disksub')
  else
    AddSubFeederEventViaTCP(cFRE_SUBFEEDER_IP,'44101','disksub');

end;

procedure TFRE_BOX_FEED_CLIENT.MyRegisterClasses;
begin
  fre_dbbase.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_diff_transport.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;
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
      //disk_hal.GetUpdateDataAndTakeStatusSnaphot(cFRE_MACHINE_NAME);
//      SendServerCommand(FSTORAGE_FeedAppClass,'DISK_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),vmo);
       SendServerCommand(FSTORAGE_FeedAppClass,'DISK_DATA_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),disk_hal.GetUpdateDataAndTakeStatusSnaphot(cFRE_MACHINE_NAME),@CCB_RequestDiskEncPoolData);
//    disk_hal.ClearStatusSnapshotAndUpdates; //DEBUG force always full state
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
//  writeln('SUBFEEDER EVENT ID : ',id);
//  writeln(dbo.DumpToString());
  writeln('-----------------------------------------------------------------------------------------------------');
  disk_hal.ReceivedDBO(dbo);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_BROWSEPATH(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var reply_data : IFRE_DB_Object;
    level      : string;

    function ListDirLevel(const basepath: string): IFRE_DB_Object;
    var Info  : TSearchRec;
        entry : TFRE_DB_FS_ENTRY;
        count : NativeInt;
    begin
      result := GFRE_DBI.NewObject;
      count  := 0;
      If FindFirst (basepath+'*',faAnyFile and faDirectory,Info)=0 then
        Repeat
          With Info do
            begin
              if (name='.') or (name='..') then
                Continue;
              entry := TFRE_DB_FS_ENTRY.CreateForDB;
              entry.SetProperties(name,(Attr and faDirectory) <> faDirectory,Size,mode,Time);
              result.Field(inttostr(count)).AsObject := entry;
              inc(count);
            end;
        Until FindNext(info)<>0;
      FindClose(Info);
    end;

begin
  level      := input.Field('level').AsString;
  //level :=  StringReplace(level,'/anord01disk/anord01ds/domains/demo/demo/zonedata/vfiler/development','/',[]);
  writeln('::: BROWSE - LEVEL ',level);
  reply_data := ListDirLevel(level);
  input.Finalize;
  AnswerSyncCommand(command_id,reply_data);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_REQUESTDISKDATA(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var   reply_Data  : IFRE_DB_Object;
begin
//  writeln('SWL: REQUESTING DISK DATA');
  reply_data := GFRE_DBI.NewObject;
  AnswerSyncCommand(command_id,reply_data);
end;

end.

