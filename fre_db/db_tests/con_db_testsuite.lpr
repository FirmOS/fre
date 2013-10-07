program con_db_testsuite;

{$mode objfpc}
{$H+}
{$codepage utf8}
{$LIBRARYPATH ../../fre_external/fre_ext_libs}


uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  cmem,
  FRE_SYSTEM,FRE_CONFIGURATION,math,
  FRE_DB_PERSISTANCE_FS_SIMPLE,
  consoletestrunner,
  FOS_DEFAULT_IMPLEMENTATION,
  FRE_DB_CORE,FRE_DB_INTERFACE,FRE_dbbase,
  FOS_TOOL_INTERFACES,
  sysutils,
  fre_db_testsuite;

var App: TTestRunner;

begin
  Initialize_Read_FRE_CFG_Parameter;
  GFRE_DB_DEFAULT_PS_LAYER := Get_PersistanceLayer_PS_Simple(cFRE_SERVER_DEFAULT_DIR+DirectorySeparator+'db');


  Init4Server;
  Register_DB_Extensions;
  RegisterTestCodeClasses;

  TEST_GUID_1 := StringToGUID('{00000000-0000-0000-0000-000000000001}');
  TEST_GUID_2 := StringToGUID('{00000000-0000-0000-0000-000000000002}');
  TEST_GUID_3 := StringToGUID('{00000000-0000-0000-0000-000000000003}');
  GFRE_DB.LocalZone        := 'Europe/Vienna';

  App := TTestRunner.Create(nil);
  App.Initialize;
  App.Title := 'FirmOS FRE Database Testsuite';
  App.Run;
  App.Free;
end.

