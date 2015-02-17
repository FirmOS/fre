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
  FRE_DB_CORE,fre_dbbase, FRE_CONFIGURATION,fre_hal_schemes, fre_zfs, fosillu_libscf,fos_firmbox_svcctrl,
  fos_citycom_voip_mod, fosillu_ipadm, fosillu_hal_svcctrl,fosillu_hal_dbo_common,fre_dbbusiness
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
  svc_name      : string;
  svc           : TFRE_DB_SERVICE;

  function StartService(const obj: IFRE_DB_Object):boolean;
  var ip     : TFRE_DB_IP_HOSTNET;
      ip4    : TFRE_DB_IPV4_HOSTNET;
      dl     : TFRE_DB_DATALINK;
      resdbo : IFRE_DB_Object;

  begin
    result := false;
    writeln('SWL: START');
    if obj.IsA(TFRE_DB_IP_HOSTNET,ip) then
      begin
        if ip.Parent.IsA(TFRE_DB_DATALINK,dl) then
          ip.Field('datalinkname').asstring := dl.ObjectName;
//        ip.Field('datalinkname').asstring :='e1000g0';  //DEBUG
//        if obj.isA(TFRE_DB_IPV4_HOSTNET,ip4) then       //DEBUG
//          ip.Field('dhcp').asboolean := true;           //DEBUG
        resdbo := ip.StartService;
        result := resdbo.Field('started').asboolean;
      end;
  end;

  function StopService(const obj: IFRE_DB_Object):boolean;
  var ip     : TFRE_DB_IP_HOSTNET;
      dl     : TFRE_DB_DATALINK;
      resdbo : IFRE_DB_Object;
  begin
    result :=false;
    writeln('SWL: STOP');
    if obj.IsA(TFRE_DB_IP_HOSTNET,ip) then
      begin
        if ip.Parent.IsA(TFRE_DB_DATALINK,dl) then
          ip.Field('datalinkname').asstring := dl.ObjectName;
        //ip.Field('datalinkname').asstring :='e1000g0';  //DEBUG
        resdbo := ip.StopService;
        result := resdbo.Field('stopped').asboolean;
      end;
  end;

  function RestartService(const obj: IFRE_DB_Object):boolean;
  begin
    result :=false;
    writeln('SWL: RESTART NOT IMPLEMENTED YET');
  end;

  function TryToChangeServiceState(const obj: IFRE_DB_Object):boolean;
  begin
    if HasOption('*','start') then
      result := StartService(obj)
    else
      if HasOption('*','stop') then
        result := StopService(obj)
      else
        if HasOption('*','restart') then
          result := RestartService(obj)
        else
          raise Exception.Create('no enable,disable,restart option choosen!');
  end;

  procedure CheckServices(const obj: IFRE_DB_Object);
  var dl     : TFRE_DB_DATALINK;
      resdbo : IFRE_DB_Object;
      svc    : TFRE_DB_SERVICE;

    procedure _RemoveIPHostnetService(const fld:IFRE_DB_Field);
    var fmri     : string;
        foundobj : IFRE_DB_Object;
    begin
      if fld.FieldType=fdbft_String then
        begin
          fmri := fld.AsString;
          if svclist.FetchObjWithStringFieldValue('fmri',fmri,foundobj,'') then
            begin
              writeln('SWL: IP SERVICE CREATED/EXISTING');
              svclist.DeleteField(foundobj.UID.AsHexString);
            end;
        end;
    end;

  begin
    if obj.IsA(TFRE_DB_DATALINK,dl) then
      begin
        writeln('SWL: NOW DATALINK ',dl.ObjectName,' ',obj.UID.AsHexString);
        resdbo := dl.RIF_CreateOrUpdateServices;
        resdbo.ForAllFields(@_RemoveIPHostnetService,true);
//        writeln(resdbo.DumpToString());
      end
    else
      begin
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
                writeln('SWL CREATE OR UPDATE SERVICE ',svc.getFMRI);
                resdbo := svc.RIF_CreateOrUpdateService;
              //  writeln(resdbo.DumpToString());
              end;
          end;
      end;
  end;

  procedure _DeleteService(const obj:IFRE_DB_Object);
  var fmri        : string;
      svc_name    : string;
  begin
    fmri     := obj.Field('fmri').asstring;
    svc_name := Copy(fmri,6,maxint);
    writeln('SWL: REMOVE DEPENDENCY ',fmri);
    try
      if Pos('fos_ip_',svc_name)>0 then
        fre_remove_dependency('fos/fosip',StringReplace(svc_name,'/','',[rfReplaceAll]));
      if Pos('fos_routing',svc_name)>0 then
        fre_remove_dependency('milestone/network',StringReplace(svc_name,'/','',[rfReplaceAll]));
    except on E:Exception do
      begin
        writeln('SWL: DEPENDENCY FOR '+svc_name+' DOES NOT EXIST');
      end;
    end;
    obj.Field('svc_name').asstring:=svc_name;
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
  fre_dbbase.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fos_citycom_voip_mod.Register_DB_Extensions;
  GFRE_DB.Initialize_Extension_ObjectsBuild;

  ErrorMsg:=CheckOptions('cslt',['createsvc','services','list','test','ip:','routing:','start','stop','restart','enable:','disable:','refresh:']);
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  InitIllumosLibraryHandles;

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

      fre_refresh_service('fos/fosip');
      fre_refresh_service('milestone/network');

      Terminate;
      halt(0);
    end;

  if HasOption('*','ip') or HasOption('*','routing') then
    begin
      _LoadZoneDBO;
      if HasOption('*','ip') then
        uid_string := GetOptionValue('*','ip')
      else
        uid_string := GetOptionValue('*','routing');

      if uid_string='' then
        raise Exception.Create('No UID for ip option set!');
      uid.SetFromHexString(uid_string);

      if not zone_dbo.FetchObjByUID(uid,foundobj) then
        raise Exception.Create('UID not found for this zone!');

      if TryToChangeServiceState(foundobj) then
        begin
          Terminate;
          halt(0);
        end
      else
        begin
          Terminate;
          halt(1);
        end;
    end;

  if HasOption('t','test') then
    begin
      fre_remove_dependency('fos/fosip',StringReplace('fos/fosip_cpe0_6761c387e535e2f221106b9776cff2d1','/','',[rfReplaceAll]));
      Terminate;
      Exit;

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

  if HasOption('*','enable') then
    begin
      svc_name := GetOptionValue('*','enable');
      fre_enable_or_disable_service(svc_name,true);
      Terminate;
      Exit;
    end;

  if HasOption('*','disable') then
    begin
      svc_name := GetOptionValue('*','disable');
      fre_enable_or_disable_service(svc_name,false);
      Terminate;
      Exit;
    end;

  if HasOption('*','refresh') then
    begin
      svc_name := GetOptionValue('*','refresh');
      fre_refresh_service(svc_name);
      Terminate;
      Exit;
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

