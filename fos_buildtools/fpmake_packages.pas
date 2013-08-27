program fpmake_packages;

{$Mode objfpc}
{$H+}
{$inline on}

 uses fpmkunit,classes,sysutils,fos_buildtools;

 Var
   P   : TPackage;

 begin
   with Installer(TFOSInstaller) do begin
    P := AddPackage('FOS_FIRMBOX');
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
       with Targets do begin
        AddUnit('fos_firmbox_common.pas');
        AddUnit('fos_firmbox_applianceapp.pas');
        AddUnit('fos_firmbox_fileserver.pas');
        AddUnit('fos_firmbox_infrastructureapp.pas');
        AddUnit('fos_firmbox_servicesapp.pas');
        AddUnit('fos_firmbox_storageapp.pas');
        AddUnit('fos_firmbox_storeapp.pas');
        AddUnit('fos_firmbox_vm_machines_mod.pas');
        AddUnit('fos_firmbox_vmapp.pas');
        AddUnit('fos_firmboxfeed_client.pas');
       end;
    end;
    Run;
   end;
 end.
