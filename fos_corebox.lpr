program fos_corebox;
{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2009, FirmOS Business Solutions GmbH
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
{$LIBRARYPATH ./../fre_external/fre_ext_libs}

uses
  cmem,cthreads,

  FRE_SYSTEM,FOS_DEFAULT_IMPLEMENTATION,FOS_TOOL_INTERFACES,FOS_FCOM_TYPES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,
  FRE_DB_CORE,

  FRE_APS_IMPL_LE, FOS_FCOM_DEFAULT, FRE_DB_EMBEDDED_IMPL,
  FRE_CONFIGURATION,FRE_BASE_SERVER,FRE_DBMONITORING,FRE_ZFS,

  FRE_DBBASE,FRE_DBBUSINESS,FRE_DBCLOUDCONTROL,
  FOS_DBCOREBOX_FILESERVER,
  FOS_DBCOREBOX_USERAPP,
  FOS_DBCOREBOX_INFRASTRUCTUREAPP,
  FOS_DBCOREBOX_SERVICESAPP,
  FOS_DBCOREBOX_STORAGEAPP,
  FOS_DBCOREBOX_VMAPP,
  FOS_DBCOREBOX_STOREAPP,
  FOS_DBCOREBOX_COMMON,
  fos_dbcorebox_vm_machines_mod
  ;

var
  switch : string;

begin
  writeln;
  writeln('FirmOS Corebox Server '+cFRE_SERVER_VERSION);
  writeln(cFRE_SERVER_COPYRIGHT);
  writeln;
  Init4Server;
  Initialize_Read_FRE_CFG_Parameter;
  FRE_DB_Startup_Initialize;
  writeln('STARTUP @LOCAL TIME :',GFRE_DT.ToStrFOS(GFRE_DT.UTCToLocalTime(GFRE_DT.Now_UTC,GFRE_DBI.LocalZone)),'  UTC TIME :',GFRE_DT.ToStrFOS(GFRE_DT.Now_UTC));
  if CMD_CheckParam('NOINT') then G_NO_INTERRUPT_FLAG := true;



  // Base Registrations
  FRE_DBBASE.Register_DB_Extensions;
  // Cloudcontrol
  FRE_DBBUSINESS.Register_DB_Extensions;
  // Test
  FOS_DBCOREBOX_USERAPP.Register_DB_Extensions;
  FOS_DBCOREBOX_INFRASTRUCTUREAPP.Register_DB_Extensions;
  FRE_DBMONITORING.Register_DB_Extensions;
  FOS_DBCOREBOX_FILESERVER.Register_DB_Extensions;
  FOS_DBCOREBOX_SERVICESAPP.Register_DB_Extensions;
  FOS_DBCOREBOX_STORAGEAPP.Register_DB_Extensions;
  FOS_DBCOREBOX_VMAPP.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;
  //FOS_DBCOREBOX_STOREAPP.Register_DB_Extensions;



//  FRE_DBTEST.Register_DB_Extensions;
//  fre_testcase.Register_DB_Extensions;
//  FRE_DBMONITORING.Register_DB_Extensions;
//  FRE_DBCLOUDCONTROL.Register_DB_Extensions;
//  FRE_HAL_TRANSPORT.Register_DB_Extensions;
  // LearningLounge
//  FRE_DB_LEARNINGLOUNGE.Register_DB_Extensions;

  cVM_HostUser   := 'root';
  cVMHostMachine := '10.1.0.102';

  FRE_BASE_SERVER.RegisterLogin;
  FRE_DB_Startup_Initialization_Complete;
  FRE_DB_Enter_Servermode;

  switch := lowercase(ParamStr(1));
  case switch of
    'initdb' : begin
      FOS_DBCOREBOX_COMMON.InitDB;
    end;
   else begin
     SetupAPS;
     GFRE_S.Start(TFRE_BASE_SERVER.Create);
     GFRE_S.Run;
     TearDownAPS;
     Shutdown_Done;
   end;
 end;
end.

