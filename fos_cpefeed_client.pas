unit fos_cpefeed_client;

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
{$modeswitch nestedprocvars}
{$codepage utf-8}

interface

uses
  Classes, SysUtils,fre_base_client,FOS_TOOL_INTERFACES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,FOS_VM_CONTROL_INTERFACE,
  fre_system,fre_dbbase,fre_dbbusiness, fre_hal_schemes,fre_process,fre_db_core,
  fre_diff_transport;


type


  { TFRE_CPE_FEED_CLIENT }

  TFRE_CPE_FEED_CLIENT=class(TFRE_BASE_CLIENT)
  private
    hal_cfg    :IFRE_DB_Object;
    procedure  ConfigureCPE;
  public
    procedure  MySessionEstablished    (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  MySessionDisconnected   (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  QueryUserPass           (out user, pass: string); override;
    procedure  MyRegisterClasses       ; override;
    procedure  MyInitialize            ; override;
    procedure  MyFinalize              ; override;
    procedure  MyConnectionTimer       ; override;
    procedure  GenerateFeedDataTimer   (const TIM : IFRE_APSC_TIMER ; const flag1,flag2 : boolean); // Timout & CMD Arrived & Answer Arrived
    procedure  SubfeederEvent          (const id:string; const dbo:IFRE_DB_Object);override;
  published
  end;


implementation



procedure TFRE_CPE_FEED_CLIENT.ConfigureCPE;

 procedure _NetworkIterator(const service:IFRE_DB_Object);
 var network              :TFRE_DB_CPE_NETWORK_SERVICE;
 begin
   if service.IsA(TFRE_DB_CPE_NETWORK_SERVICE,network) then
   begin
     network.ConfigureHAL;
   end;
  end;

 procedure _VPNIterator(const service:IFRE_DB_Object);
 var openvpn              :TFRE_DB_CPE_OPENVPN_SERVICE;
 begin
   if service.IsA(TFRE_DB_CPE_OPENVPN_SERVICE,openvpn) then
   begin
     openvpn.ConfigureHAL;
   end;
  end;

 procedure _DHCPIterator(const service:IFRE_DB_Object);
 var dhcp                 :TFRE_DB_CPE_DHCP_SERVICE;
 begin
   if service.IsA(TFRE_DB_CPE_DHCP_SERVICE,dhcp) then
   begin
     dhcp.ConfigureHAL;
   end;
  end;


begin
  hal_cfg.ForAllObjects(@_NetworkIterator);
  hal_cfg.ForAllObjects(@_VPNIterator);
  hal_cfg.ForAllObjects(@_DHCPIterator);
end;

procedure TFRE_CPE_FEED_CLIENT.MySessionEstablished(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  inherited;
end;

procedure TFRE_CPE_FEED_CLIENT.MySessionDisconnected(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  inherited;
end;

procedure TFRE_CPE_FEED_CLIENT.QueryUserPass(out user, pass: string);
begin
  user := cFRE_Feed_User;
  pass := cFRE_Feed_Pass;
end;

procedure TFRE_CPE_FEED_CLIENT.MyRegisterClasses;
begin
  fre_dbbase.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_diff_transport.Register_DB_Extensions;
end;

procedure TFRE_CPE_FEED_CLIENT.MyInitialize;
begin

  hal_cfg:=GFRE_DBI.CreateFromFile(cFRE_HAL_CFG_DIR+DirectorySeparator+'cpe.cfg');

  //writeln('SWL:',hal_cfg.DumpToString());
  ConfigureCPE;
end;

procedure TFRE_CPE_FEED_CLIENT.MyFinalize;
begin
  writeln('FEED CLIENT FINALIZE');

end;


procedure TFRE_CPE_FEED_CLIENT.MyConnectionTimer;
begin
end;

procedure TFRE_CPE_FEED_CLIENT.GenerateFeedDataTimer(const TIM: IFRE_APSC_TIMER; const flag1, flag2: boolean);
begin
end;

procedure TFRE_CPE_FEED_CLIENT.SubfeederEvent(const id: string; const dbo: IFRE_DB_Object);
begin
end;


end.

