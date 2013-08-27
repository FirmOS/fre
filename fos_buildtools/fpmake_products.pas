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
    P := AddPackage('FOS_MONSYS');
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
        Add('FOS_MONSYS');
      end;
      Directory:=cFOS_BUILD_PREFIX+'webapp';
      InstallProgramSuffix := FOSBuild.FOS_Suffix;
      with targets do begin
        AddProgram('monsys.lpr');
      end;
    end;
    Run;
  end;
end.
