program fossvc;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$codepage utf-8}

{$LIBRARYPATH ../../lib}
{$LINKLIB libdladm}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, fosillu_libzonecfg,fre_process,
  FRE_SYSTEM,FOS_DEFAULT_IMPLEMENTATION,FOS_TOOL_INTERFACES,FOS_FCOM_TYPES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,
  FRE_DB_CORE,fre_dbbase, FRE_DB_EMBEDDED_IMPL, FRE_CONFIGURATION,fre_hal_schemes, fre_zfs, fosillu_libscf,fos_firmbox_svcctrl,
  fos_citycom_voip_mod, fosillu_ipadm
  { you can add units after this };

type

  { TFRE_fossvc }

  TFRE_fossvc = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   WriteHelp; virtual;
  end;

{ TFRE_fos_brand }

procedure TFRE_fossvc.DoRun;
var
  ErrorMsg      : String;
  zone_dbo_file : string;
  zone_dbo      : IFRE_DB_Object;
  //zone          : TFRE_DB_ZONE;
  svclist       : IFRE_DB_Object;
  foundobj      : IFRE_DB_Object;
  uid_string    : string;
  uid           : TFRE_DB_GUID;

  svc           : TFRE_DB_SERVICE;

  procedure EnableService(const obj: IFRE_DB_Object);
  var ip : TFRE_DB_IP_HOSTNET;
      dl : TFRE_DB_DATALINK;
  begin
    writeln('SWL: ENABLE');
    if obj.IsA(TFRE_DB_IP_HOSTNET,ip) then
      begin
        if ip.Parent.IsA(TFRE_DB_DATALINK,dl) then
          ip.Field('datalinkname').asstring := dl.ObjectName;
        ip.Field('datalinkname').asstring :='e1000g0';  //DEBUG
        ip.RIF_StartService;
      end;
  end;

  procedure DisableService(const obj: IFRE_DB_Object);
  var ip : TFRE_DB_IP_HOSTNET;
      dl : TFRE_DB_DATALINK;
  begin
    writeln('SWL: DISABLE');
    if obj.IsA(TFRE_DB_IP_HOSTNET,ip) then
      begin
        if ip.Parent.IsA(TFRE_DB_DATALINK,dl) then
          ip.Field('datalinkname').asstring := dl.ObjectName;
        ip.Field('datalinkname').asstring :='e1000g0';  //DEBUG
        ip.RIF_StopService;
      end;
  end;

  procedure RestartService(const obj: IFRE_DB_Object);
  begin
    writeln('SWL: RESTART');
  end;

  procedure TryToChangeServiceState(const obj: IFRE_DB_Object);
  begin
     if HasOption('*','enable') then
      EnableService(obj)
    else
      if HasOption('*','disable') then
        DisableService(obj)
      else
        if HasOption('*','restart') then
          RestartService(obj)
        else
          raise Exception.Create('no enable,disable,restart option choosen!');
  end;

  procedure CheckServices(const obj: IFRE_DB_Object);
  var dl     : TFRE_DB_DATALINK;
      resdbo : IFRE_DB_Object;
      svc    : TFRE_DB_SERVICE;
  begin
    if obj.IsA(TFRE_DB_DATALINK,dl) then
      begin
        writeln('SWL: NOW DATALINK ',dl.ObjectName,' ',obj.UID.AsHexString);
        resdbo := dl.RIF_CreateOrUpdateServices;
        writeln(resdbo.DumpToString());
      end
    else
      if obj.IsA(TFRE_DB_SERVICE,svc) then
        begin
          writeln('SWL: NOW SERVICE ',obj.UID.AsHexString,' ', svc.getFMRI);
          if svclist.FetchObjWithStringFieldValue('fmri',svc.getFMRI,foundobj,'') then
            begin
              writeln('SWL: SERVICE ALREADY CREATED');
              svclist.DeleteField(foundobj.UID.AsHexString);
            end
          else
            begin
              resdbo := svc.RIF_CreateOrUpdateService;
              writeln(resdbo.DumpToString());
            end;
        end;
  end;

  procedure _DeleteService(const obj:IFRE_DB_Object);
  var fmri        : string;
  begin
    fmri := obj.Field('fmri').asstring;
    obj.Field('svc_name').asstring:=Copy(fmri,6,maxint);
    writeln('SWL: REMOVE SERVICE ',fmri);
    fre_destroy_service(obj);
  end;

  procedure _LoadZoneDbo;
  begin
    zone_dbo_file := '/zonedbo/zone.dbo';
    zone_dbo  := GFRE_DBI.CreateFromFile(zone_dbo_file);
  end;

begin
  InitMinimal(false);
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fos_citycom_voip_mod.Register_DB_Extensions;

  ErrorMsg:=CheckOptions('cslt',['createsvc','services','list','test','ip:','routing:','enable','disable','restart']);
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('l','list') then
    begin
      svclist := fre_get_servicelist(GetOptionValue('l','list'));
      writeln(svclist.DumpToString);
      Terminate;
      exit;
    end;

  if HasOption('c','createsvc') then begin
    svc := TFRE_DB_SERVICE.Create;
    svc.SetSvcNameandType('fos/foscfg','FirmOS Configuration Service','transient','core,signal');
    svc.SetSvcEnvironment('/opt/local/fre','root','root','LANG=C');
    svc.SetSvcStart('/opt/local/fre/bin/fossvc --services',60);
    svc.SetSvcStop (':kill',60);
    svc.AddSvcDependency('datalink-management','svc:/network/datalink-management','require_all','none');
    svc.AddSvcDependency('ip-management','svc:/network/ip-interface-management','require_all','none');
    svc.AddSvcDependency('loopback','svc:/network/loopback','require_all','none');
    fre_create_service(svc);

    svc := TFRE_DB_SERVICE.Create;
    svc.SetSvcNameandType('fos/fosip','FirmOS IP Setup Ready','transient','core,signal');
    svc.SetSvcStart(':true',3);
    svc.SetSvcStop (':true',3);
    svc.AddSvcDependency('foscfg','svc:/fos/foscfg','require_all','none');
    svc.AddSvcDependent ('fosip','svc:/milestone/network','require_all','none');
    fre_create_service(svc);

    Terminate;
    Exit;
  end;

  if HasOption('s','services') then
    begin
      _LoadZoneDBo;

      svclist := fre_get_servicelist('fos_');
      try
        zone_dbo.ForAllObjects(@CheckServices);
        svclist.ForAllObjects(@_DeleteService);
      finally
        svclist.Finalize;
      end;

      Terminate;
      Exit;
    end;

  if HasOption('*','ip') then
    begin
      _LoadZoneDBO;
      uid_string := GetOptionValue('*','ip');
      if uid_string='' then
        raise Exception.Create('No UID for ip option set!');
      uid.SetFromHexString(uid_string);

      if not zone_dbo.FetchObjByUID(uid,foundobj) then
        raise Exception.Create('UID not found for this zone!');

      TryToChangeServiceState(foundobj);

      Terminate;
      Exit;
    end;

  if HasOption('*','routing') then
    begin
      _LoadZoneDBO;
      uid_string := GetOptionValue('*','routing');
      if uid_string='' then
        raise Exception.Create('No UID for routing option set!');
      uid.SetFromHexString(uid_string);

      if not zone_dbo.FetchObjByUID(uid,foundobj) then
        raise Exception.Create('UID not found for this zone!');

      TryToChangeServiceState(foundobj);

      Terminate;
      Exit;
    end;


  if HasOption('t','test') then
    begin
      svc := TFRE_DB_SERVICE.Create;
      svc.SetSvcNameandType('fos/test','Exim Mailservice (MTA)','child','core,signal');
      svc.SetSvcEnvironment('/','mail','mail','LANG=C');
      svc.SetSvcStart('/opt/local/sbin/exim -C /opt/local/etc/exim/configure -bdf',60);
      svc.SetSvcStop (':kill',60);
//      svc.AddSvcDependency('network','svc:/milestone/network:default','require_all','error');
//      svc.AddSvcDependency('filesystem','svc:/system/filesystem/local','require_all','error');
      svc.AddSvcDependent ('fostest','svc:/milestone/network','optional_all','none');
      fre_create_service(svc);
      Terminate;
      Exit;
//  readln;
//  fre_destroy_service(svc);
    end;


  // stop program loop
  Terminate;
end;

constructor TFRE_fossvc.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TFRE_fossvc.Destroy;
begin
  inherited Destroy;
end;

procedure TFRE_fossvc.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TFRE_fossvc;
begin
  Application:=TFRE_fossvc.Create(nil);
  Application.Run;
  Application.Free;
end.

