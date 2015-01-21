unit fos_firmbox_common;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DBBASE,
  FRE_DBBUSINESS,
  fre_accesscontrol_common,
  fos_firmbox_storageapp,
  fos_firmbox_servicesapp,
  fos_firmbox_vmapp,
  fos_firmbox_applianceapp,
  fos_firmbox_vm_machines_mod,
  fre_hal_schemes,
  fre_diff_transport,
  FRE_ZFS,
  fre_scsi,
  fre_testcase,
  fre_system,
  fre_hal_disk_enclosure_pool_mangement,
  fos_vm_control_interface
;

//* USER - GRUPPE - ROLLE
//--
//Action Points -> User's in DB anlegen -> Grids, Layout (ROLLEN NACHZIEHN)
//
//--
//INFRA -> COMPUTER/GERÄTEVERWALTUNG | AP'S L2 (LANCOM | UBNT)  | NETZWERK | INFRASTRUKTUR | SWITCH PORTSECURITY | ASSETS | VPN
//--
//SERVICES APP -> FILESERVER | FILEBROWSER/BACKUP | MAILSERVER | WEBSERVER | DBSERVER ? POSTGRES | MYSQL ?
//--
//STORAGE -> POOL(DISKÜBERSICHT) | PLATZAUFTEILUNG | MONITORING
//--
//SYSTEM MONITORING STATUS -> MON
//--
//VIRTUALISIERUNG -> VM's - MACHINEN - VIRTUELLES NETZWERK - MONITORING
//--
//STORE(SALES) -> APP ( Funktionsmodule / Speicherplatz Kaufen / VM RAM / Virtuelle CPU's / BACKUPSPACE )
//

implementation


procedure FIRMBOX_MetaGenerateTestData(const dbname: string; const user, pass: string);
begin
end;

procedure FIRMBOX_MetaRegister;
begin
  // Base Registrations
  FRE_DBBASE.Register_DB_Extensions;
  FRE_DBBUSINESS.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;
  fos_firmbox_applianceapp.Register_DB_Extensions;
  fre_accesscontrol_common.Register_DB_Extensions;
  fre_testcase.Register_DB_Extensions;
  fos_firmbox_storageapp.Register_DB_Extensions;
  fos_firmbox_servicesapp.Register_DB_Extensions;
  fos_firmbox_vmapp.Register_DB_Extensions;
  //GFRE_DBI.Initialize_Extension_Objects;
end;

procedure FIRMBOX_MetaInitializeDatabase(const dbname: string; const user, pass: string);
begin
end;

procedure FIRMBOX_MetaRemove(const dbname: string; const user, pass: string);
begin
end;

initialization

 GFRE_DBI_REG_EXTMGR.RegisterNewExtension('FIRMBOX',@FIRMBOX_MetaRegister,@FIRMBOX_MetaInitializeDatabase,@FIRMBOX_MetaRemove,@FIRMBOX_MetaGenerateTestdata);


end.

