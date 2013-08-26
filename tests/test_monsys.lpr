program test_monsys;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  consoletestrunner, fre_configuration,
  FOS_TOOL_INTERFACES, FRE_DB_EMBEDDED_IMPL,
  FOS_DEFAULT_IMPLEMENTATION, FRE_DB_INTERFACE, FRE_SYSTEM,
  Classes, FRE_PROCESS, fre_tester_testsuite, fre_testcase,
  FRE_DBBUSINESS, FRE_DBBASE, FRE_DBMONITORING,
  FRE_ZFS, FRE_OPENVPN,FRE_DB_CORE,fre_alert, fre_diskshelf;

var App: TTestRunner;

begin
//  InitMinimal(true);
  Init4Server;
  Initialize_Read_FRE_CFG_Parameter;

  FRE_DBBASE.Register_DB_Extensions;
  FRE_DBBUSINESS.Register_DB_Extensions;
  FRE_DBMONITORING.Register_DB_Extensions;
  fre_testcase.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;

  FRE_DB_Startup_Initialization_Complete;
  GFRE_DBI.LocalZone := 'Europe/Vienna';

  App := TTestRunner.Create(nil);
  App.Initialize;
  App.Title := 'FirmOS FRE Monsys Testsuite';
  App.Run;
  App.Free;
end.

