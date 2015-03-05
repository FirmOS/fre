unit fos_firmbox_common;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH

  Licence conditions
(§LIC_END)
}

{$codepage UTF8}
{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,
  FRE_DB_INTERFACE,
  fos_firmbox_adminapp;

implementation

procedure FIRMBOX_MetaRegister;
begin
  fos_firmbox_adminapp.Register_DB_Extensions;
end;

procedure FIRMBOX_MetaInitializeDatabase(const dbname: string; const user, pass: string);
begin
end;

procedure FIRMBOX_MetaRemove(const dbname: string; const user, pass: string);
begin
end;

procedure FIRMBOX_MetaGenerateTestdata(const dbname: string; const user, pass: string);
begin
end;


initialization

GFRE_DBI_REG_EXTMGR.RegisterNewExtension('FIRMBOX',@FIRMBOX_MetaRegister,@FIRMBOX_MetaInitializeDatabase,@FIRMBOX_MetaRemove,@FIRMBOX_MetaGenerateTestdata);

end.


