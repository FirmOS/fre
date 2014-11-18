program fossvc;

{$mode objfpc}{$H+}

{$LIBRARYPATH ../../lib}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, fosillu_libzonecfg,fre_process,
  FRE_SYSTEM,FOS_DEFAULT_IMPLEMENTATION,FOS_TOOL_INTERFACES,FOS_FCOM_TYPES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,
  FRE_DB_CORE,fre_dbbase, FRE_DB_EMBEDDED_IMPL, FRE_CONFIGURATION,fre_hal_schemes, fre_zfs, fosillu_libscf
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
  //ErrorMsg      : String;
  //i             : NativeInt;
  //state         : NativeInt;
  //cmd           : NativeInt;
  //pre           : boolean;
  //tmpvnic       : string;
  //zone_name     : string;
  //zone_dbo_file : string;
  //zone_dbo      : IFRE_DB_Object;
  //zone_path     : string;
  //zone          : TFRE_DB_ZONE;

  g_handle      : Pscf_handle_t;
  version       : DWord;
  imp_scope     : Pscf_scope_t;
  imp_service   : Pscf_service_t;
  imp_pg        : Pscf_propertygroup_t;
  imp_instance  : Pscf_instance_t;
  current_tx    : Pscf_transaction_t;

  err           : Integer;
  msg           : string;
  service_name  : string;

  procedure  CreateAndStartTransaction(const pg: Pscf_propertygroup_t; out newtx : Pscf_transaction_t);
  begin
    writeln('create transaction');
    newtx := scf_transaction_create(g_handle);
    if newtx=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create transaction:'+' '+msg);
      end;

    writeln('start transaction');
    err := scf_transaction_start(newtx,pg);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not start transaction:'+inttostr(err)+' '+msg);
      end;
  end;

  procedure  CommitAndFinalizeTransaction (const tx: Pscf_transaction_t);
  begin
    writeln('commit transaction');
    err := scf_transaction_commit(tx);
    if err<0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not commit transaction:'+inttostr(err)+' '+msg);
      end;

    scf_transaction_destroy_children(tx);
    scf_transaction_destroy(tx);
  end;

  procedure  AddPropertyToPG(const pg: Pscf_propertygroup_t; const tx: Pscf_transaction_t; const property_name: string; const property_value : string; const tp:scf_type_t);
  var
    entry         : Pscf_transaction_entry_t;
    value         : Pscf_value_t;
  begin
    writeln('Adding Property ',property_name,' ',property_value);


    writeln('create entry');
    entry := scf_entry_create(g_handle);
    if entry=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create entry:'+' '+msg);
      end;

    err := scf_transaction_property_new(tx,entry,PChar(property_name),tp);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not set transaction property new:'+inttostr(err)+' '+msg);
      end;

    writeln('create value');
    value := scf_value_create(g_handle);
    if value=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create value:'+inttostr(err)+' '+msg);
      end;

    writeln('value set from string');
    err := scf_value_set_from_string(value,tp,PChar(property_value));
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not set value from string:'+inttostr(err)+' '+msg);
      end;

    writeln('add value ');
    err := scf_entry_add_value(entry,value);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not add value:'+inttostr(err)+' '+msg);
      end;
  end;

  procedure  AddPropertyToPGBoolean(const pg: Pscf_propertygroup_t; const tx: Pscf_transaction_t; const property_name: string; const property_value : boolean);
  var
    entry         : Pscf_transaction_entry_t;
    value         : Pscf_value_t;
    boolean_value : Uint8;
  begin


    writeln('Adding Property ',property_name,' ',property_value);
    if property_value then
      boolean_value:=1
    else
      boolean_value:=0;

    writeln('create entry');
    entry := scf_entry_create(g_handle);
    if entry=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create entry:'+' '+msg);
      end;

    err := scf_transaction_property_new(tx,entry,PChar(property_name),SCF_TYPE_BOOLEAN);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not set transaction property new:'+inttostr(err)+' '+msg);
      end;

    writeln('create value');
    value := scf_value_create(g_handle);
    if value=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create value:'+inttostr(err)+' '+msg);
      end;

    writeln('value set from boolean');
    scf_value_set_boolean(value,boolean_value);

    writeln('add value ');
    err := scf_entry_add_value(entry,value);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not add value:'+inttostr(err)+' '+msg);
      end;
  end;

  procedure  AddPropertyToPGCount(const pg: Pscf_propertygroup_t; const tx: Pscf_transaction_t; const property_name: string; const property_value : UInt64);
  var
    entry         : Pscf_transaction_entry_t;
    value         : Pscf_value_t;
  begin


    writeln('Adding Property ',property_name,' ',property_value);

    writeln('create entry');
    entry := scf_entry_create(g_handle);
    if entry=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create entry:'+' '+msg);
      end;

    err := scf_transaction_property_new(tx,entry,PChar(property_name),SCF_TYPE_COUNT);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not set transaction property new:'+inttostr(err)+' '+msg);
      end;

    writeln('create value');
    value := scf_value_create(g_handle);
    if value=nil then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not create value:'+inttostr(err)+' '+msg);
      end;

    writeln('value set count ');
    scf_value_set_count(value,property_value);

    writeln('add value ');
    err := scf_entry_add_value(entry,value);
    if err<>0 then
      begin
        msg := StrPas(scf_strerror(scf_error));
        raise Exception.Create('could not add value:'+inttostr(err)+' '+msg);
      end;
  end;

begin
  InitMinimal(false);
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;


  service_name  :='fos/exim';

  writeln('get handle');
  g_handle      := scf_handle_create(SCF_VERSION);
  if g_handle=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not get scf_handle:'+' '+msg);
    end;

  writeln('bind handle');
  err := scf_handle_bind(g_handle);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not bind scf_handle:'+inttostr(err)+' '+msg);
    end;

  writeln('create scope');
  imp_scope:=scf_scope_create(g_handle);
  if imp_scope=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create scope:'+' '+msg);
    end;

  writeln('create local scope');
  err := scf_handle_get_scope(g_handle,PChar(SCF_SCOPE_LOCAL),imp_scope);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not get local scope:'+inttostr(err)+' '+msg);
    end;

  writeln('create service');
  imp_service:=scf_service_create(g_handle);
  if imp_service=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create service:'+' '+msg);
    end;

  writeln('validate service name');
  err := scf_scope_get_service(imp_scope,PChar(service_name),imp_service);
  if err<>0 then
    begin
      if scf_error<>SCF_ERROR_NOT_FOUND then
        begin
          msg := StrPas(scf_strerror(scf_error));
          raise Exception.Create('could not validate servicename:'+inttostr(err)+' '+msg);
        end;
    end;

  writeln('add service');
  err := scf_scope_add_service(imp_scope,PChar(service_name),imp_service);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not add service:'+inttostr(err)+' '+msg);
    end;

  writeln('create propertygroup');
  imp_pg := scf_pg_create(g_handle);
  if imp_pg=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create property group:'+' '+msg);
    end;

  writeln('add propertygroup');
  err := scf_service_add_pg(imp_service,Pchar('startd'),Pchar(SCF_GROUP_FRAMEWORK),0,imp_pg);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not property group:'+inttostr(err)+' '+msg);
    end;

  CreateAndStartTransaction(imp_pg,current_tx);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_IGNORE,'core,signal',SCF_TYPE_ASTRING);
  CommitAndFinalizeTransaction(current_tx);


  writeln('create propertygroup dependency');
  imp_pg := scf_pg_create(g_handle);
  if imp_pg=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create property group:'+' '+msg);
    end;

  writeln('add propertygroup dependency');
  err := scf_service_add_pg(imp_service,Pchar('network'),Pchar(SCF_GROUP_DEPENDENCY),0,imp_pg);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not add property group:'+inttostr(err)+' '+msg);
    end;

  CreateAndStartTransaction(imp_pg,current_tx);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_GROUPING,'require_all',SCF_TYPE_ASTRING);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_RESTART_ON,'error',SCF_TYPE_ASTRING);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_TYPE_,'service',SCF_TYPE_ASTRING);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_ENTITIES,'svc:/milestone/network:default',SCF_TYPE_FMRI);
  CommitAndFinalizeTransaction(current_tx);

  writeln('create propertygroup general');
  imp_pg := scf_pg_create(g_handle);
  if imp_pg=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create property group:'+' '+msg);
    end;

  writeln('add propertygroup general');
  err := scf_service_add_pg(imp_service,Pchar(SCF_PG_GENERAL),Pchar(SCF_GROUP_FRAMEWORK),0,imp_pg);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not add property group:'+inttostr(err)+' '+msg);
    end;

  CreateAndStartTransaction(imp_pg,current_tx);
  AddPropertyToPGBoolean(imp_pg,current_tx,SCF_PROPERTY_SINGLE_INSTANCE,true);
  AddPropertyToPG(imp_pg,current_tx,'entity_stability','Evolving',SCF_TYPE_ASTRING);
  CommitAndFinalizeTransaction(current_tx);

  writeln('create propertygroup start');
  imp_pg := scf_pg_create(g_handle);
  if imp_pg=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create property group:'+' '+msg);
    end;

  writeln('add propertygroup start');
  err := scf_service_add_pg(imp_service,Pchar('start'),Pchar(SCF_GROUP_METHOD),0,imp_pg);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not add property group:'+inttostr(err)+' '+msg);
    end;

  CreateAndStartTransaction(imp_pg,current_tx);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_TYPE_,'method',SCF_TYPE_ASTRING);
  AddPropertyToPG(imp_pg,current_tx,SCF_PROPERTY_EXEC,'/opt/local/sbin/exim',SCF_TYPE_ASTRING);
  AddPropertyToPGCount(imp_pg,current_tx,SCF_PROPERTY_TIMEOUT,60);
  CommitAndFinalizeTransaction(current_tx);


  writeln('create instance');
  imp_instance := scf_instance_create(g_handle);
  if imp_instance=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create instance:'+' '+msg);
    end;

  writeln('add instance');
  err := scf_service_add_instance(imp_service,PChar('default'),imp_instance);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not add instance:'+inttostr(err)+' '+msg);
    end;

  writeln('create propertygroup general');
  imp_pg := scf_pg_create(g_handle);
  if imp_pg=nil then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not create property group:'+' '+msg);
    end;

  writeln('add propertygroup instance general');
  err := scf_instance_add_pg(imp_instance,Pchar(SCF_PG_GENERAL),Pchar(SCF_GROUP_FRAMEWORK),0,imp_pg);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not add property group:'+inttostr(err)+' '+msg);
    end;

  CreateAndStartTransaction(imp_pg,current_tx);
  AddPropertyToPGBoolean(imp_pg,current_tx,SCF_PROPERTY_ENABLED,false);
  CommitAndFinalizeTransaction(current_tx);


  readln;

  writeln('delete instance');
  err := scf_instance_delete(imp_instance);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not delete instance:'+inttostr(err)+' '+msg);
    end;


  writeln('delete service');
  err := scf_service_delete(imp_service);
  if err<>0 then
    begin
      msg := StrPas(scf_strerror(scf_error));
      raise Exception.Create('could not delete service:'+inttostr(err)+' '+msg);
    end;


  //for i:=0 to ParamCount do
  //begin
  //  write(inttostr(i)+'=['+ParamStr(i)+'] ');
  //end;
  //writeln;
  //


//  pre        := Pos('pre',ParamStr(1))>0;
//  state      := strtoint(ParamStr(4));
//  cmd        := strtoint(ParamStr(5));
//  zone_name  := ParamStr(2);
//  zone_path  := ParamStr(3);
//  zone_dbo_file := Copy(zone_path,1,Pos('/domains',zone_path)-1)+'/zones/'+zone_name+'/zone.dbo';
//  writeln('SWL: ',zone_dbo_file);
//  zone_dbo  := GFRE_DBI.CreateFromFile(zone_dbo_file);
////  0=[/usr/lib/brand/fbz/fosbrand] 1=[--post] 2=[15a56c904a7f00248929bfdb576a45c9] 3=[/syspool/domains/df842e6d890b0fb5bb3a1b8db0cc8dc6/15a56c904a7f00248929bfdb576a45c9] 4=[2] 5=[0]
//
//  if (state=ZONE_STATE_INSTALLED) and (pre=false) and (cmd=0) then
//    begin
//      zone := (zone_dbo.Implementor_HC as TFRE_DB_ZONE);
//      zone.BootingHookConfigure;
//    end;
//

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

