unit fos_firmbox_svcctrl;

{$mode objfpc}{$H+}

interface
  {$DEFINE FIRMOS_HAL}
uses
  Classes, SysUtils,fre_db_interface
  {$IFDEF FIRMOS_HAL}
  ,libscf, nvpair, libzfs, zfs, fos_illumos_defs,fosillu_libzonecfg
  {$ENDIF}
  ;
type

  {
   Should be plugged into a feed client to expose svc functions
   Should hold all (zones) svcs related functionality and the composed status object

   DIRECT WEB USE : NO
   HAL USE        : YES (HAL Class)
   MWS USE        : YES (decomposed view) through baseclass
  }

  TFOS_BOXSVC_CONTROLLER=class(TFRE_DB_ObjectEx)
  private

  public

  end;

{$IFDEF FIRMOS_HAL}
  TFOS_BOXSVC_CONTROLLER_HAL=class(TFRE_DB_ObjectEx)
  private
   //Domänen(name/uid?)/Zonen/Services/Instancen
  public

  end;

var GBOXSVC : TFOS_BOXSVC_CONTROLLER;

procedure CreateBoxSvcController;
{$ENDIF}

implementation

{$IFDEF FIRMOS_HAL}
procedure CreateBoxSvcController;
begin
  if not assigned(GBOXSVC) then
    GBOXSVC := TFOS_BOXSVC_CONTROLLER.create;
end;
{$ENDIF}

end.

