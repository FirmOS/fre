unit fos_firmbox_accesscontrol;

//PREPARATION FOR A DERIVED USAGE OF THE COMMON ACCESS CONTROL IN THE FIRMBOX APP
//
// UNFINISHED (ONLY A TEST PROTOTYPE BY NOW)

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,fre_accesscontrol_common,FOS_TOOL_INTERFACES,
  FRE_DB_INTERFACE,
  FRE_DBBASE,
  FRE_DB_COMMON;

type

  { TFOS_FIRMBOX_USER_APP }

  TFOS_FIRMBOX_USER_APP=class(TFRE_COMMON_ACCESSCONTROL_APP)
  protected
      procedure       SetupApplicationStructure     ; override;
  end;

  TFOS_FIRMBOX_ROLE_MOD=class(TFRE_COMMON_ROLE_MOD)
  end;

  TFOS_FIRMBOX_GROUP_MOD=class(TFRE_COMMON_GROUP_MOD)
  end;

  TFOS_FIRMBOX_USER_MOD=class(TFRE_COMMON_USER_MOD)
  end;

  TFOS_FIRMBOX_DOMAIN_MOD=class(TFRE_COMMON_DOMAIN_MOD)
  end;


procedure Register_DB_Extensions;

implementation

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_DOMAIN_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_USER_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_GROUP_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_ROLE_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFOS_FIRMBOX_USER_APP);
  GFRE_DBI.Initialize_Extension_Objects;
end;

{ TFOS_FIRMBOX_USER_APP }

procedure TFOS_FIRMBOX_USER_APP.SetupApplicationStructure;
begin
  InitAppDesc('$description');
  AddApplicationModule(TFOS_FIRMBOX_DOMAIN_MOD.create);
  AddApplicationModule(TFOS_FIRMBOX_USER_MOD.create);
  AddApplicationModule(TFOS_FIRMBOX_GROUP_MOD.create);
  AddApplicationModule(TFOS_FIRMBOX_ROLE_MOD.create);
end;

end.

