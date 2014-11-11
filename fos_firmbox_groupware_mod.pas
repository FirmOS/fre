unit fos_firmbox_groupware_mod;

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
  FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DB_COMMON;

type

  { TFOS_FIRMBOX_GROUPWARE_MOD }

  TFOS_FIRMBOX_GROUPWARE_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    procedure       SetupAppModuleStructure             ; override;
  public
    class procedure RegisterSystemScheme                (const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       MySessionInitializeModule           (const session : TFRE_DB_UserSession);override;
    class procedure InstallDBObjects                    (const conn:IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallUserDBObjects                (const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType); override;
  published
    function        WEB_Content                         (const input:IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object; override;
  end;

procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_GROUPWARE_MOD);

  //GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_FIRMBOX_GROUPWARE_MOD }

class procedure TFOS_FIRMBOX_GROUPWARE_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFOS_FIRMBOX_GROUPWARE_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('groupware_description')
end;

class procedure TFOS_FIRMBOX_GROUPWARE_MOD.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; var currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='0.1';
  if currentVersionId='' then begin
    currentVersionId := '0.1';

    //TFOS_FIRMBOX_GROUPWARE_MOD;
    CreateModuleText(conn,'groupware_description','Groupware','Groupware','Groupware');

  end;
end;

class procedure TFOS_FIRMBOX_GROUPWARE_MOD.InstallUserDBObjects(const conn: IFRE_DB_CONNECTION; currentVersionId: TFRE_DB_NameType);
begin
  if currentVersionId='' then begin
    currentVersionId := '0.1';

  end;
end;

procedure TFOS_FIRMBOX_GROUPWARE_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitializeModule(session);
  if session.IsInteractiveSession then begin

  end;
end;

function TFOS_FIRMBOX_GROUPWARE_MOD.WEB_Content(const input: IFRE_DB_Object; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
begin
  CheckClassVisibility4MyDomain(ses);

  Result:=TFRE_DB_HORDE_DESC.create.Describe('horde.firmos.at');
end;

end.

