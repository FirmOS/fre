program fpmake_packages;

{$Mode objfpc}
{$H+}
{$inline on}

 uses fpmkunit,classes,sysutils,fos_buildtools;

 Var
   P   : TPackage;

 begin
   with Installer(TFOSInstaller) do begin
    P := AddPackage('FOS_MONSYS');
    with p do begin
       OSes      := cFOS_BUILD_OSes;
       Directory := cFOS_BUILD_PREFIX;
       Dependencies.Add('FRE_CORE');
       Dependencies.Add('FRE_DB');
       Dependencies.Add('FRE_INTF');
       Dependencies.Add('FRE_BLKCOM');
       Dependencies.Add('fcl-process');
       Dependencies.Add('FRE_HAL');
       Dependencies.Add('FRE_APPS');
       Dependencies.Add('FOS_FIRMBOX');
       with Targets do begin
        AddUnit('fos_mos_common.pas');
        AddUnit('fos_mos_monitoring_mod.pas');
        AddUnit('fos_mos_monitoringapp.pas');
        AddUnit('fos_mos_networkapp.pas');
        AddUnit('webapp/fos_monitoring_app.pas');
       end;
    end;
    Run;
   end;
 end.