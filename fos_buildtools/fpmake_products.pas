program fpmake_products;

{$Mode objfpc}
{$H+}
{$inline on}

 uses fpmkunit,classes,sysutils,fos_buildtools;

 Var
   P   : TPackage;

begin
  With Installer(TFOSInstaller) do begin
    Defaults.BinInstallDir  := GetCurrentDir+'/../../bin';
    P := AddPackage('FOS_FIRMBOX');
    with p do begin
      OSes := cFOS_BUILD_OSes;
      FOS_OS_SPEC_OPTIONS(Options);
      with Dependencies do begin
        Add('FRE_INTF');
        Add('FRE_CORE');
        Add('FRE_DB');
        Add('FRE_HAL');
        Add('FRE_APPS');
        Add('fcl-xml');
        Add('fcl-fpcunit');
        Add('FOS_FIRMBOX');
      end;
      Directory:=cFOS_BUILD_PREFIX+'firmbox/';
      InstallProgramSuffix := FOSBuild.FOS_Suffix;
      with targets do begin
        AddProgram('firmbox.lpr');
      end;
    end;
    P := AddPackage('FOS_BOXCONSOLE');
    with p do begin
      OSes := cFOS_BUILD_OSes;
      FOS_OS_SPEC_OPTIONS(Options);
      with Dependencies do begin
        Add('FRE_INTF');
        Add('FRE_CORE');
        Add('FRE_DB');
        Add('FRE_HAL');
        Add('FRE_APPS');
        Add('fcl-xml');
        Add('fcl-fpcunit');
        Add('FOS_FIRMBOX');
      end;
      Directory:=cFOS_BUILD_PREFIX+'boxconsole/';
      Options.Add('-Fi../../core/fos_include');
      InstallProgramSuffix := FOSBuild.FOS_Suffix;
      with targets do begin
        AddProgram('boxconsole.lpr');
        AddProgram('fre_disksubfeeder.lpr');
      end;
    end;
    P := AddPackage('FOS_FIRMBOX_TOOLS');
    with p do begin
      OSes := cFOS_BUILD_OSes;
      FOS_OS_SPEC_OPTIONS(Options);
      with Dependencies do begin
        Add('FRE_INTF');
        Add('FRE_CORE');
        Add('FRE_DB');
        Add('FRE_HAL');
        Add('FRE_APPS');
        Add('fcl-xml');
        Add('fcl-fpcunit');
      end;
      Directory:=cFOS_BUILD_PREFIX+'tools/';
      Options.Add('-Fi../../core/fos_include');
      InstallProgramSuffix := FOSBuild.FOS_Suffix;
      with targets do begin
        AddProgram('fre_illumos_sdparameter.lpr');
        AddProgram('fre_safejob.lpr');
        AddProgram('foscmd.lpr');
      end;
    end;
    Run;
  end;
end.
