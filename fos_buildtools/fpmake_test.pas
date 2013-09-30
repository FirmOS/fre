program fpmake_test;

{$Mode objfpc}
{$H+}
{$inline on}

 uses fpmkunit,classes,sysutils,fos_buildtools;

 Var
   P   : TPackage;
   T   : TTarget;

 begin
   With Installer(TFOSInstaller) do begin
     Defaults.BinInstallDir  := GetCurrentDir+'/../../bin';
     P := AddPackage('FIRMOSDEVTESTSERVER');
     with p do begin
       OSes := cFOS_BUILD_OSes;
       FOS_OS_SPEC_OPTIONS(Options);
       with Dependencies do begin
         Add('FRE_CORE');
         Add('FRE_INTF');
         Add('FRE_FCOM');
         Add('FRE_APS');
         Add('FRE_DB');
         Add('FRE_APPS');
         Add('FRE_BLKCOM');
         Add('FRE_SYNAPSE');
         Add('FRE_HAL');
         Add('FOS_FIRMBOX');
         Add('FOS_ARTEMES');
         Add('FOS_MONSYS');
         Add('FOS_CAPTIVEPORTAL');
       end;
       Directory:=cFOS_BUILD_PREFIX+'fre_test_server/';
       InstallProgramSuffix := FOSBuild.FOS_Suffix;
       with targets do begin
         AddProgram('fre_testserver.lpr').ExtraEnvironment.Values['FOS_PRODUCT_NAME'] := 'FIRMOSDEV TestServer';
         AddProgram('fre_testdatafeed.lpr').ExtraEnvironment.Values['FOS_PRODUCT_NAME'] := 'FIRMOSDEV TestFeeder';
       end;
     end;
     Run;
   end;
 end.
