unit fos_monitorfeed_client;

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
  fre_system,fos_stats_control_interface, fre_hal_disk_enclosure_pool_mangement,fre_dbbase,fre_zfs,fre_scsi,fre_hal_schemes,fre_monitoring,fre_hal_mos,
  fre_diff_transport;


type


  { TFRE_MONITOR_FEED_CLIENT }

  TFRE_MONITOR_FEED_CLIENT=class(TFRE_BASE_CLIENT)
  private
    FEED_Timer            : IFRE_APSC_TIMER;
    FMonitor_Feeding      : Boolean;
    FMonitor_FeedAppClass : TFRE_DB_String;
    FMonitor_FeedAppUid   : TGuid;
    disk_hal              : TFRE_HAL_DISK;
    mos_hal               : TFRE_HAL_MOS;
  private

  public
    procedure  MySessionEstablished    (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  MySessionDisconnected   (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  QueryUserPass           (out user, pass: string); override;
    procedure  MyInitialize            ; override;
    procedure  MyFinalize              ; override;
    procedure  MyConnectionTimer       ; override;
    procedure  SubfeederEvent          (const id:string; const dbo:IFRE_DB_Object);override;
    procedure  GenerateFeedDataTimer   (const TIM : IFRE_APSC_TIMER ; const flag1,flag2 : boolean); // Timout & CMD Arrived & Answer Arrived

  published
  end;


implementation




procedure TFRE_MONITOR_FEED_CLIENT.MySessionEstablished(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  inherited;

  if Get_AppClassAndUid('TFOS_CITYCOM_MONITORING_APP',FMonitor_FeedAppClass,FMonitor_FeedAppUid) then begin
    FMonitor_Feeding   := True;
    disk_hal.ClearSnapshotAndUpdates;
    mos_hal.ClearSnapshotAndUpdates;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFOS_CITYCOM_MONITORING_APP APP NOT FOUND!');
  end;

  FEED_Timer := chanman.AddTimer(10000);
  FEED_Timer.TIM_SetID('FEED_'+inttostr(chanman.GetID));
  writeln('Generated Feedtimer 10 ',FEED_Timer.TIM_GetID);
  FEED_Timer.TIM_SetCallback(@GenerateFeedDataTimer);
  FEED_Timer.TIM_Start;
end;

procedure TFRE_MONITOR_FEED_CLIENT.MySessionDisconnected(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  FEED_Timer.Finalize;
  FMonitor_Feeding:= false;
  inherited;
end;

procedure TFRE_MONITOR_FEED_CLIENT.QueryUserPass(out user, pass: string);
begin
  user := cFRE_Feed_User;
  pass := cFRE_Feed_Pass;
end;

procedure TFRE_MONITOR_FEED_CLIENT.MyInitialize;
begin
  fre_dbbase.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;
  fre_monitoring.Register_DB_Extensions;
  fre_diff_transport.Register_DB_Extensions;
  fre_hal_mos.Register_DB_Extensions;

  disk_hal   := TFRE_HAL_DISK.Create;
  mos_hal    := TFRE_HAL_MOS.Create;

  mos_hal.LoadConfiguration;
  mos_hal.StartSNMPRequests;

  if cFRE_SUBFEEDER_IP='' then
    AddSubFeederEventViaUX('disksub')
  else
    AddSubFeederEventViaTCP(cFRE_SUBFEEDER_IP,'44101','disksub');

end;

procedure TFRE_MONITOR_FEED_CLIENT.MyFinalize;
begin
  disk_hal.Free;
  mos_hal.Free;
end;


var g_disc_delay : integer=0;

procedure TFRE_MONITOR_FEED_CLIENT.MyConnectionTimer;
var vmo : IFRE_DB_Object;
begin
  if FMonitor_Feeding then
    begin
      SendServerCommand(FMonitor_FeedAppClass,'DISK_DATA_FEED',TFRE_DB_GUIDArray.Create(FMonitor_FeedAppUid),disk_hal.GetUpdateDataAndTakeSnaphot);
      disk_hal.ClearSnapshotAndUpdates; //force always full state

      SendServerCommand(FMonitor_FeedAppClass,'MOS_DATA_FEED',TFRE_DB_GUIDArray.Create(FMonitor_FeedAppUid),mos_hal.GetUpdateDataAndTakeSnaphot);
//      mos_hal.ClearSnapshotAndUpdates; //force always full state

    end;
end;

procedure TFRE_MONITOR_FEED_CLIENT.SubfeederEvent(const id: string; const dbo: IFRE_DB_Object);
begin
  disk_hal.ReceivedDBO(dbo);
end;

procedure TFRE_MONITOR_FEED_CLIENT.GenerateFeedDataTimer(const TIM: IFRE_APSC_TIMER; const flag1, flag2: boolean);
begin
  mos_hal.StartSNMPRequests;
end;

end.

