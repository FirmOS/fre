program fre_patcher;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2009, FirmOS Business Solutions GmbH
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

      * Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the documentation
        and/or other materials provided with the distribution.
      * Neither the name of the <FirmOS Business Solutions GmbH> nor the names
        of its contributors may be used to endorse or promote products derived
        from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
(§LIC_END)
}

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$LIBRARYPATH ../../lib}

{$DEFINE FREMYSQL}

uses
//  cmem,
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  classes,contnrs,fre_db_interface,fre_system,fre_db_core,
  FRE_DBTEST,
  fos_firmbox_common,
  fos_artemes_common,
  fos_citycom_common,
  fre_certificate_common,
  fos_artemes_testapp,
  fos_monitoring_app,
  fos_captiveportal_app,
  fre_basecli_app,
  fre_certificate_app,
  fre_hal_schemes,
  fre_zfs,
  fos_firmbox_vmapp,
  fos_firmbox_vm_machines_mod,
  fos_citycom_adc_common,
  sysutils,
  fos_citycom_base,
  {$IFDEF FREMYSQL}
  fre_mysql_ll,
  sqldb,
  {$ENDIF}
  fre_dbbusiness,
  fre_dbbase
  ;

{ mysql client on osx : brew install mysql-connector-c}


type
  { TFRE_Testserver }
  TFRE_Testserver = class(TFRE_CLISRV_APP)
  private
    procedure   PatchCity1;
    procedure   PatchCityAddons                         (domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='pepe');
    procedure   PatchCityObjs                           (domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='pepe');
    procedure   PatchDeleteVersions                     ;
    procedure   PatchVersions;
    {$IFDEF FREMYSQL}
    procedure   ImportCitycomAccounts                   (domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='pepe');
    {$ENDIF}
    procedure   GenerateAutomaticWFSteps                ;
    procedure   GenerateTestDataForProCompetence        ;
    procedure   MoveDomainCollecions                    ;
    procedure   GenerateDeviceData                      ;
    procedure   GenerateDataCenterData                  ;
    procedure   AddAFeederUser                          (const feederusername:string ; const feederpass:string ; const feederclass :string);
    procedure   AddAuser                                (const userstringencoding : string);

  protected
    procedure   AddCommandLineOptions                   ; override;
    function    PreStartupTerminatingCommands: boolean  ; override; { cmd's that should be executed without db(ple), they terminate}
    function    AfterStartupTerminatingCommands:boolean ; override; { cmd's that should be executed with db core init, they terminate}
    function    AfterInitDBTerminatingCommands:boolean  ; override; { cmd's that should be executed with full db init, they terminate}
    procedure   ParseSetSystemFlags                     ; override; { Setting of global flags before startup go here }
    procedure   Patch                                   (const option:string);
  end;

  { TFRE_Testserver }
var
  Application: TFRE_Testserver;

procedure TFRE_Testserver.AddCommandLineOptions;
begin
  inherited;
  AddHelpOutLine('Extended:');
  AddCheckOption('*','patch:'     ,'                | --patch=<val>                     : manual patch');
  AddCheckOption('*','adduser:'     ,'              | --adduser=username,password,class : quick add a user (feederuser) ');
end;

function TFRE_Testserver.PreStartupTerminatingCommands: boolean;
begin
  Result:=inherited PreStartupTerminatingCommands;
  //if HasOption('option') then
  //  begin
  //    result := true; { should terminate }
  //  end;
end;

function TFRE_Testserver.AfterStartupTerminatingCommands: boolean;
begin
  Result:=inherited AfterStartupTerminatingCommands;
  //if HasOption('option') then
  //  begin
  //    result := true; { should terminate }
  //  end;
end;

function TFRE_Testserver.AfterInitDBTerminatingCommands: boolean;
begin
  Result:=inherited AfterInitDBTerminatingCommands;
  if HasOption('patch') then
    begin
      Patch(GetOptionValue('patch'));
      GFRE_DB_PS_LAYER.SyncSnapshot;
      result := true; { should terminate }
    end
  else
  if HasOption('adduser') then
    begin
      AddAUser(GetOptionValue('adduser'));
      GFRE_DB_PS_LAYER.SyncSnapshot;
      result := true; { should terminate }
    end
  else
    begin
      writeln('use --patch command');
    end;
  result:=true;
end;

procedure TFRE_Testserver.ParseSetSystemFlags;
begin
  inherited ParseSetSystemFlags;
end;

procedure TFRE_Testserver.Patch(const option: string);
var conn : IFRE_DB_CONNECTION;
    cnt  : NativeInt;

    procedure ObjectPatch(const obj: IFRE_DB_Object; var halt:boolean ; const current,max : NativeInt);
    begin
      inc(cnt);
      writeln(cnt,' ',obj.UID_String,' ',obj.SchemeClass);
    end;

begin
  _CheckDBNameSupplied;
  _CheckAdminUserSupplied;
  _CheckAdminPassSupplied;
  case option of
    'city1'        : PatchCity1;
    'cityaddons'   : PatchCityAddons;
    'cityobjs'     : PatchCityObjs;
    'resetversions': PatchVersions;
    {$IFDEF FREMYSQL}
    'importacc'    : ImportCitycomAccounts;
    {$ENDIF}
    'genauto'      : GenerateAutomaticWFSteps;
    'procompetence': GenerateTestDataForProCompetence;
    'movedc'       : MoveDomainCollecions;
    'devicedata'   : GenerateDeviceData;
    'gendatacenter': GenerateDatacenterData;
  end;
end;

procedure TFRE_Testserver.PatchDeleteVersions;
var conn : IFRE_DB_SYS_CONNECTION;
begin
   conn := GFRE_DBI.NewSysOnlyConnection;
   writeln('EXISTING VERSIONS:');
   writeln('------');
   CheckDbResult(conn.Connect(cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
   writeln(conn.GetClassesVersionDirectory.DumpToString());
   CheckDbResult(conn.DelClassesVersionDirectory);
   conn.Finalize;
   writeln('------');
   writeln('FRESH VERSIONS:');
   conn := GFRE_DBI.NewSysOnlyConnection;
   CheckDbResult(conn.Connect(cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
   writeln(conn.GetClassesVersionDirectory.DumpToString());
   conn.Finalize;
end;

procedure TFRE_Testserver.PatchCity1;
var conn : IFRE_DB_CONNECTION;
    cnt  : NativeInt;
    coll : IFRE_DB_COLLECTION;

    procedure ObjectPatch(const obj:IFRE_DB_Object; var halt:boolean ; const current,max : NativeInt);
    begin
      writeln('Processing ',current,'/',max,' ',obj.SchemeClass);
      if obj.SchemeClass='TFOS_DB_CITYCOM_PROD_MOD_VARIATION_PRICE' then { don't use IsA() (schemes not registered) }
        begin
          coll.Store(obj);
        end
      else begin
        if obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_MODULE_RELATION' then { don't use IsA() (schemes not registered) }
          begin
            obj.Field('override_price').AsBoolean:=true;
            conn.Update(obj);
          end;
        end;
    end;

begin
   conn := GFRE_DB.NewConnection;
   GDBPS_SKIP_STARTUP_CHECKS := true; { skip inkonsitency checks, to enable consistency restoration  }
   CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
   coll := conn.GetCollection(CFOS_DB_PROD_MOD_VARIATION_PRICES_COLLECTION);
   writeln('PATCHING BASE DB ',FDBName);
   writeln('----');
   conn.ForAllDatabaseObjectsDo(@ObjectPatch);
   writeln('DONE');
end;

procedure TFRE_Testserver.PatchCityAddons(domainname:string; domainuser:string; domainpass:string);
var conn     : IFRE_DB_CONNECTION;
    cnt      : NativeInt;
    coll_p   : IFRE_DB_COLLECTION;
    coll_pv  : IFRE_DB_COLLECTION;
    coll_rel : IFRE_DB_COLLECTION;

    procedure AddonsPatch(const obj:IFRE_DB_Object);
    var
      addons : fre_db_interface.TFRE_DB_ObjLinkArray;
      rel_obj: TFOS_DB_CITYCOM_PRODUCT_ADDON_RELATION;
      i      : Integer;
      r_guid : TFRE_DB_GUID;
    begin
      addons:=obj.Field('addons').AsObjectLinkArray;
      obj.DeleteField('addons');
      for i := 0 to High(addons) do begin
        rel_obj:=TFOS_DB_CITYCOM_PRODUCT_ADDON_RELATION.CreateForDB;
        rel_obj.module:=addons[i];
        r_guid:=rel_obj.UID;
        CheckDbResult(coll_rel.Store(rel_obj));
        obj.Field('addons').AddObjectLink(r_guid);
      end;
      CheckDbResult(conn.Update(obj));
    end;

    procedure ObjectPatch(const obj:IFRE_DB_Object; var halt:boolean ; const current,max : NativeInt);
    var
      refs : TFRE_DB_GUIDArray;
      i    : Integer;
      group: IFRE_DB_GROUP;
    begin
      //writeln('Processing ',current,'/',max,' ',obj.SchemeClass);
      if obj.SchemeClass='TFRE_DB_TEXT' then { don't use IsA() (schemes not registered) }
        begin
          writeln('Delete ',obj.Field('t_key').AsString);
          CheckDbResult(conn.sys.DeleteTranslateableText(obj.Field('t_key').AsString));
        end;
      if obj.SchemeClass='TFRE_DB_GROUP' then { don't use IsA() (schemes not registered) }
        begin
          writeln('Delete ',obj.Field('objname').AsString);
          refs:=conn.GetReferences(obj.UID,false);
          if Length(refs)>0 then begin
            for i := 0 to High(refs) do begin
              CheckDbResult(conn.sys.RemoveUserGroupsById(refs[i],TFRE_DB_GUIDArray.create(obj.UID)));
            end;
          end;
          CheckDbResult(conn.sys.DeleteGroupById(obj.UID));
        end;
      if obj.SchemeClass='TFRE_DB_ROLE' then { don't use IsA() (schemes not registered) }
        begin
          writeln('Delete ',obj.Field('objname').AsString);
          refs:=conn.GetReferences(obj.UID,false);
          if Length(refs)>0 then begin
            for i := 0 to High(refs) do begin
              CheckDbResult(conn.SYS.FetchGroupById(refs[i],group));
              CheckDbResult(conn.sys.RemoveRolesFromGroupById(group.GetName,group.DomainID,TFRE_DB_GUIDArray.create(obj.UID),false));
            end;
          end;
          CheckDbResult(conn.sys.DeleteRole(obj.Field('objname').AsString,obj.DomainID));
        end;
    end;


begin
   conn := GFRE_DB.NewConnection;
   CheckDbResult(conn.Connect(FDBName,domainuser,domainpass));
   coll_p    := conn.GetCollection(CFOS_DB_PRODUCTS_COLLECTION);
   coll_pv   := conn.GetCollection(CFOS_DB_PRODUCT_VARIATIONS_COLLECTION);
   writeln('PATCHING BASE DB ',FDBName);
   coll_rel  := conn.GetCollection(CFOS_DB_PRODUCT_ADDON_RELATIONS_COLLECTION);
   coll_p.ForAll(@AddonsPatch);
   coll_rel  := conn.GetCollection(CFOS_DB_PRODUCTVARIATION_ADDON_RELATIONS_COLLECTION);
   coll_pv.ForAll(@AddonsPatch);
end;

procedure TFRE_Testserver.PatchCityObjs(domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='pepe');
var
  conn: IFRE_DB_CONNECTION;

    procedure ObjectPatch(const obj:IFRE_DB_Object; var halt:boolean ; const current,max : NativeInt);
    var
      refs      : TFRE_DB_GUIDArray;
      i         : Integer;
      dbo       : IFRE_DB_Object;
      moduleColl: IFRE_DB_COLLECTION;
      addonColl : IFRE_DB_COLLECTION;
      refObj    : IFRE_DB_Object;
    begin
      //writeln('Processing ',current,'/',max,' ',obj.SchemeClass);
      if (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_MODULE') then begin
        obj.Field('type').AsString:='SERVICE';
        CheckDbResult(conn.Update(obj));
      end else begin
        if (obj.SchemeClass='TFOS_DB_CITYCOM_PROD_MOD_VARIATION_PRICE') or
           (obj.SchemeClass='TFOS_DB_CITYCOM_PROD_MOD_VARIATION_COST_PRICE') or
           (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_PRICE') or
           (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_ADDON_RELATION') or
           (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_MODULE_RELATION') then begin{ don't use IsA() (schemes not registered) }
          refs:=conn.GetReferences(obj.UID,false);
          if Length(refs)=0 then begin
            writeln('NOT OK 0 ' + obj.SchemeClass);
            CheckDbResult(conn.Delete(obj.UID));
          end;
          //if Length(refs)=1 then begin
          //  writeln('OK 1 ' + obj.SchemeClass);
          //end;
          if Length(refs)>1 then begin
            writeln('NOT OK >1 ' + IntToStr(Length(refs)) + ' ' + obj.SchemeClass);
            if (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_ADDON_RELATION') or
               (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_MODULE_RELATION') then begin
              for i := 0 to High(refs)-1 do begin
                CheckDbResult(conn.Fetch(refs[i],dbo));
                writeln(IntToStr(i) + ' ' + dbo.Field('name').AsString + ' ' + dbo.SchemeClass + ' ' + FREDB_G2H(dbo.UID));

                if dbo.SchemeClass='TFOS_DB_CITYCOM_PRODUCT' then begin
                  moduleColl:=conn.GetCollection(CFOS_DB_PRODUCT_MODULE_RELATIONS_COLLECTION);
                  addonColl:=conn.GetCollection(CFOS_DB_PRODUCT_ADDON_RELATIONS_COLLECTION);
                end else begin
                  moduleColl:=conn.GetCollection(CFOS_DB_PRODUCTVARIATION_MODULE_RELATIONS_COLLECTION);
                  addonColl:=conn.GetCollection(CFOS_DB_PRODUCTVARIATION_ADDON_RELATIONS_COLLECTION);
                end;

                if (obj.SchemeClass='TFOS_DB_CITYCOM_PRODUCT_MODULE_RELATION') then begin
                  dbo.Field('modules').RemoveObjectLinkByUID(obj.UID);
                  refObj:=obj.CloneToNewObject(true);
                  dbo.Field('modules').AddObjectLink(refObj.UID);
                  CheckDbResult(moduleColl.Store(refObj));
                  CheckDbResult(conn.Update(dbo));
                end else begin
                  dbo.Field('addons').RemoveObjectLinkByUID(obj.UID);
                  refObj:=obj.CloneToNewObject(true);
                  dbo.Field('addons').AddObjectLink(refObj.UID);
                  CheckDbResult(addonColl.Store(refObj));
                  CheckDbResult(conn.Update(dbo));
                end;
              end;
            end;
          end;
        end;
      end;
    end;

begin
  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,domainuser,domainpass));
  writeln('PATCHING BASE DB ',FDBName);
  writeln('----');
  conn.ForAllDatabaseObjectsDo(@ObjectPatch);
  writeln('DONE');
end;

procedure TFRE_Testserver.PatchVersions;
var
  conn: IFRE_DB_CONNECTION;

    procedure ObjectPatch(const obj:IFRE_DB_Object; var halt:boolean ; const current,max : NativeInt);
    var
      refs : TFRE_DB_GUIDArray;
      i    : Integer;
      group: IFRE_DB_GROUP;
    begin
      //writeln('Processing ',current,'/',max,' ',obj.SchemeClass);
      if obj.SchemeClass='TFRE_DB_TEXT' then { don't use IsA() (schemes not registered) }
        begin
          writeln('Delete ',obj.Field('t_key').AsString);
          CheckDbResult(conn.sys.DeleteTranslateableText(obj.Field('t_key').AsString));
        end;
      if obj.SchemeClass='TFRE_DB_GROUP' then { don't use IsA() (schemes not registered) }
        begin
          writeln('Delete ',obj.Field('objname').AsString);
          refs:=conn.GetReferences(obj.UID,false);
          if Length(refs)>0 then begin
            for i := 0 to High(refs) do begin
              CheckDbResult(conn.sys.RemoveUserGroupsById(refs[i],TFRE_DB_GUIDArray.create(obj.UID)));
            end;
          end;
          CheckDbResult(conn.sys.DeleteGroupById(obj.UID));
        end;
      if obj.SchemeClass='TFRE_DB_ROLE' then { don't use IsA() (schemes not registered) }
        begin
          writeln('Delete ',obj.Field('objname').AsString);
          refs:=conn.GetReferences(obj.UID,false);
          if Length(refs)>0 then begin
            for i := 0 to High(refs) do begin
              CheckDbResult(conn.SYS.FetchGroupById(refs[i],group));
              CheckDbResult(conn.sys.RemoveRolesFromGroupById(group.GetName,group.DomainID,TFRE_DB_GUIDArray.create(obj.UID),false));
            end;
          end;
          CheckDbResult(conn.sys.DeleteRole(obj.Field('objname').AsString,obj.DomainID));
        end;
    end;

begin
  conn := GFRE_DBI.NewConnection;
  GDBPS_SKIP_STARTUP_CHECKS := true; { skip inkonsitency checks, to enable consistency restoration  }
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));

  writeln('PATCHING SYSTEM');
  writeln('----');
  conn.sys.ForAllDatabaseObjectsDo(@ObjectPatch);
  PatchDeleteVersions;
  writeln('DONE');
end;

{$IFDEF FREMYSQL}
procedure TFRE_Testserver.ImportCitycomAccounts(domainname: string; domainuser: string; domainpass: string);
var
  C            : TSQLConnection;
  T            : TSQLTransaction;
  Q            : TSQLQuery;
  i            : NativeInt;
  importfields : TFRE_DB_StringArray;
  importnames  : TFRE_DB_StringArray;
  importtypes  : TFRE_DB_FIELDTYPE_Array;
  cc_cust      : TFOS_DB_CITYCOM_CUSTOMER;
  conn         : IFRE_DB_CONNECTION;
  coll         : IFRE_DB_COLLECTION;
  res          : TFRE_DB_Errortype;
  cname        : string;
  cnt: Integer;

  procedure AddField(const crm_name,import_name : string;const ft : TFRE_DB_FIELDTYPE);
  begin
    SetLength(importfields,Length(importfields)+1);
    SetLength(importnames,Length(importnames)+1);
    SetLength(importtypes,Length(importtypes)+1);
    importfields[high(importfields)] := crm_name;
    importnames[high(importnames)]   := import_name;
    importtypes[high(importtypes)]   := ft;
  end;

  procedure Import;
  begin
    cc_cust.FieldPathCreate(importnames[i]).AsString:=q.FieldByName(importfields[i]).AsString
  end;
begin
  conn := GFRE_DBI.NewConnection;
  CheckDbResult(conn.Connect(FDBName,domainuser,domainpass));
  if not conn.CollectionExists(CFOS_DB_CUSTOMERS_COLLECTION) then
    conn.CreateCollection(CFOS_DB_CUSTOMERS_COLLECTION);
  coll := conn.GetCollection(CFOS_DB_CUSTOMERS_COLLECTION);

  C:=TFOSMySqlConn.Create(Nil);
  try
//    C.UserName:='root';
     C.UserName:='firmos';
    C.Password:='kmuRZ2013$';
    //c.HostName:='crm';
//    c.HostName:='10.1.0.124';
    c.HostName:='crm.citycom-austria.com';
    C.DatabaseName:='crm_citycom';
    T:=TSQLTransaction.Create(C);
    T.Database:=C;
    C.Connected:=True;
    Q:=TSQLQuery.Create(C);
    Q.Database:=C;
    Q.Transaction:=T;
    q.sql.Text := 'SET CHARACTER SET `utf8`';
    q.ExecSQL;
    q.sql.Text := 'SET NAMES `utf8`';
    q.ExecSQL;
    Q.SQL.Text:='SELECT accounts.*,accounts_cstm.* FROM `accounts_cstm` RIGHT OUTER JOIN `accounts` ON (`accounts_cstm`.`id_c` = `accounts`.`id`)';
    Q.Open;

    AddField('id','cc_crm_id',fdbft_String);
    AddField('name','objname',fdbft_String);
    AddField('billing_address_street','mainaddress.street',fdbft_String);
    AddField('billing_address_city','mainaddress.city',fdbft_String);
    AddField('billing_address_postalcode','mainaddress.zip',fdbft_String);
    AddField('billing_address_country','mainaddress.country',fdbft_String);
    AddField('website','http.url',fdbft_String);
    AddField('debitorennummer_c','cc_debitorennummer_c',fdbft_String);
    cnt:=0;
    While not Q.EOF do
      begin
        //if cnt=50 then break;
        cc_cust := TFOS_DB_CITYCOM_CUSTOMER.CreateForDB;
        for i:=0 to high(importfields) do
          begin
            write(q.FieldByName(importfields[i]).AsString,' ');
            Import;
          end;
        //WriteLn;
        //writeln(cc_cust.DumpToString);
        cname := cc_cust.Field('cc_crm_id').AsString+' - '+cc_cust.ObjectName;
        if cc_cust.Field('cc_debitorennummer_c').AsString<>'' then begin
          cnt:=cnt+1;
          res := coll.Store(cc_cust);
          writeln(cname,' : ',CFRE_DB_Errortype[res]);
        end;
        Q.Next
      end;
    Q.Close;
  finally
    C.Free;
  end;

end;
{$ENDIF}


procedure TFRE_Testserver.GenerateAutomaticWFSteps;
var conn   : TFRE_DB_CONNECTION;
    action : TFRE_DB_WORKFLOW_ACTION;
    coll   : IFRE_DB_COLLECTION;
    res    : TFRE_DB_Errortype;

    procedure _AddStep(const key,desc : string);
    begin
      action := TFRE_DB_WORKFLOW_ACTION.CreateForDB;
      action.Field('key').AsString     := key;
      action.Field('action_desc').AsString    := desc;
      action.Field('is_auto').AsBoolean:= true;
      res := coll.Store(action);
      writeln('Adding Automatic Action',key,' : ',CFRE_DB_Errortype[res]);
    end;

begin
  //conn := GFRE_DB.NewConnection;
  //CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
  //writeln('REMOVE WorkflowSchemes ', conn.SYSC.DeleteCollection('SysWorkflowScheme'));
  //writeln('REMOVE WorkflowAutoMeths ', conn.SYSC.DeleteCollection('SysWorkflowMethods'));
  //conn.Free;
  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
  coll := conn.SYSC.Collection('SysWorkflowScheme');
  try
   writeln('DEF INDEX ',coll.DefineIndexOnField('error_idx',fdbft_String,true,true).Code);
  except
  end;
  conn.Free;

  //conn := GFRE_DB.NewConnection;
  //CheckDbResult(conn.Connect(FDBName,'ckoch@citycom','pepe'));
  //coll  := conn.AdmGetWorkFlowMethCollection;
  //_AddStep('GETDOMAIN','Register a domain via interface');
  //_AddStep('SENDMAIL','Send a status Mail ');
  //_AddStep('PROVSTORAGE','Provision Storage');
  //_AddStep('UPDATECRMCUST','Update CRM Customer');
end;

procedure TFRE_Testserver.GenerateTestDataForProCompetence;
var vm   : TFRE_DB_VMACHINE;
    coll : IFRE_DB_COLLECTION;
    conn : TFRE_DB_CONNECTION;
begin
  FRE_DBBASE.Register_DB_Extensions;
  fos_citycom_base.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;

  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));

  if not conn.CollectionExists(CFRE_DB_VM_COLLECTION) then
    begin
     coll:=conn.CreateCollection(CFRE_DB_VM_COLLECTION);
     coll.DefineIndexOnField('key',fdbft_String,true,true);
    end
  else
    coll:=conn.GetCollection(CFRE_DB_VM_COLLECTION);

  vm:=TFRE_DB_VMACHINE.CreateForDB;
  vm.Field('objname').AsString:='qemuwin1';
  vm.key:='qemuwin1';
  vm.vncHost:='172.24.1.1';
  vm.vncPort:=5900;
  vm.state:='RUNNING';
  vm.mtype:='KVM';

  CheckDbResult(coll.Store(vm));

  vm:=TFRE_DB_VMACHINE.CreateForDB;
  vm.Field('objname').AsString:='qemulin1';

  vm.key:='qemulin1';
  vm.state:='RUNNING';
  vm.mtype:='KVM';
  vm.vncHost:='172.24.1.1';
  vm.vncPort:=5901;

  CheckDbResult(coll.Store(vm));

  conn.Free;

end;

procedure TFRE_Testserver.MoveDomainCollecions;
var coll : IFRE_DB_COLLECTION;
    conn : TFRE_DB_CONNECTION;

    function isDomainCollection(const collName: TFRE_DB_NameType): Boolean;
    var domuid : TFRE_DB_GUID;
    begin
      if Length(collName)<=32 then { this solution is (c) by HellySoft }
        exit(false);
      try
        domuid := FREDB_H2G(copy(collName,1,32));
        exit(true);
      except
        exit(false);
      end;
    end;


    procedure IterateColls(const coll : TFRE_DB_COLLECTION);
    var is_a_dc  : boolean;
        dc_name  : TFRE_DB_NameType;
         c_name  : TFRE_DB_NameType;
        nt       : TFRE_DB_INDEX_DEF_ARRAY;
        i        : NativeInt;
        domid    : TFRE_DB_GUID;
        new_coll : IFRE_DB_COLLECTION;
        new_objs : IFRE_DB_ObjectArray;
        dc_objs  :  IFRE_DB_ObjectArray;

        procedure CheckObjects(const iob : IFRE_DB_Object);
        begin
          if iob.DomainID<>domid then
            begin
              writeln('>>> WARNING : OBJ ',iob.UID_String,' HAS A DIFFERENT DOMAINID ',FREDB_G2H(iob.DomainID),'  THEN THE DOMAINCOLLECTION ',FREDB_G2H(domid));
            end
          else
            ; //writeln('  > OBJECT ',iob.UID_String,' OK');
          //if dc_name='dns_records' then
          //  begin
          //    writeln('>>------------------OBJ DUMP ');
          //    writeln(iob.DumpToString);
          //    writeln('<<------------------OBJ DUMP ');
          //  end;
        end;

        procedure CopyObjects(const iob : IFRE_DB_Object);
        begin
          if iob.DomainID<>domid then
            begin
              writeln('>>> WARNING : OBJ ',iob.UID_String,' HAS A DIFFERENT DOMAINID ',FREDB_G2H(iob.DomainID),'  THEN THE DOMAINCOLLECTION ',FREDB_G2H(domid));
            end
          else
            ; //writeln('  > OBJECT ',iob.UID_String,' OK');
        end;

        procedure CopyMissing;
        var i,j : NativeInt;
            fnd : boolean;
            desc:string;
        begin
          for i:=0 to high(dc_objs) do
            begin
              fnd := false;
              for j := 0 to high(new_objs) do
                if new_objs[j].UID=dc_objs[i].UID then
                  begin
                    fnd := true;
                    break;
                  end;
              if not fnd then
                begin
                  //writeln('  |> Store object ',dc_objs[i].GetDescriptionID,' in ',new_coll.CollectionName());
                  desc := dc_objs[i].GetDescriptionID+' in '+new_coll.CollectionName();
                  try
                    CheckDbResult(new_coll.Store(dc_objs[i]));
                  except
                    on e:Exception do
                      begin
                        writeln('  X|> Store object ',desc);
                        writeln(e.Message);
                      end;
                  end;
                end;
            end;
        end;

    begin
      is_a_dc := IsDomainCollection(coll.CollectionName());
      //writeln('COLL ', coll.CollectionName,' ',is_a_dc);
      if is_a_dc then
        begin
          dc_name := coll.CollectionName();
          dc_name := Copy(dc_name,33,maxint); //get DomainCollName

          nt      := coll.GetAllIndexDefinitions;
          domid   := FREDB_H2G(copy(coll.CollectionName(),1,32));
          writeln('DOMAIN COLL ', coll.CollectionName,' -> ',dc_name,' Indexes:',Length(nt),' ObjectCount : ',coll.ItemCount);
          for i:=0 to high(nt) do
            begin
              //writeln('  INDEX : ',nt[i].IndexDescriptionShort);
              //CheckDbResult(coll.DropIndex(nt[i].IndexName));
            end;
          coll.ForAllI(@CheckObjects);
          if not conn.CollectionExists(dc_name) then
            begin
              writeln('Creating non - DC Collection : ',dc_name);
              new_coll := conn.CreateCollection(dc_name);
              for i:=0 to high(nt) do
                begin
                   writeln('Defining Index on ',dc_name,' ',nt[i].IndexDescriptionShort);
                   CheckDbResult(new_coll.DefineIndexOnField(nt[i]));
                end;
            end
          else
            begin
              new_coll := conn.GetCollection(dc_name);
            end;
          new_coll.GetAllObjs(new_objs);
          GFRE_DB_PS_LAYER.DEBUG_InternalFunction(1);
          coll.GetAllObjs(dc_objs);
          GFRE_DB_PS_LAYER.DEBUG_InternalFunction(1);
          CopyMissing;
          GFRE_DB_PS_LAYER.DEBUG_InternalFunction(1);
          coll.ClearCollection;
          GFRE_DB_PS_LAYER.DEBUG_InternalFunction(1);
          c_name := coll.CollectionName();
          if conn.CollectionExists(c_name) then
            begin
              writeln('>> DELETE DOMAIN COLLECTION ',c_name);
              CheckDbResult(conn.DeleteCollection(c_name));
              writeln('<< DELETE DOMAIN COLLECTION ',c_name);
            end;
        end;
    end;


    procedure IterateCollsNoDc(const coll : TFRE_DB_COLLECTION);
    var is_a_dc  : boolean;
        nt       : TFRE_DB_INDEX_DEF_ARRAY;
        i        : NativeInt;

    begin
      is_a_dc := IsDomainCollection(coll.CollectionName());
      if is_a_dc then
        begin
        end
      else
        begin
          nt      := coll.GetAllIndexDefinitions;
          writeln('NORMAL COLL ', coll.CollectionName,' Indexes:',Length(nt),' ObjectCount : ',coll.ItemCount);
        end;
    end;

begin
  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
  conn.ForAllColls(@IterateColls);
  conn.ForAllColls(@IterateCollsNoDc);
  conn.Free;
end;

procedure TFRE_Testserver.GenerateDeviceData;
var cpe  : TFRE_DB_CRYPTOCPE;
    coll : IFRE_DB_COLLECTION;
    conn : TFRE_DB_CONNECTION;
    cfg  : IFRE_DB_Object;
    network :TFRE_DB_CPE_NETWORK_SERVICE;
    vpn     :TFRE_DB_CPE_OPENVPN_SERVICE;
    dhcp    :TFRE_DB_CPE_DHCP_SERVICE;
    vf      :TFRE_DB_CPE_VIRTUAL_FILESERVER;
    dl      :TFRE_DB_DATALINK_PHYS;
    tnl     :TFRE_DB_DATALINK_IPTUN;
    ip4     :TFRE_DB_IPV4_HOSTNET;
    ip6     :TFRE_DB_IPV6_HOSTNET;
    halo    :IFRE_DB_Object;
    caobj   :IFRE_DB_Object;
    crtobj  :IFRE_DB_Object;
    crt     :IFRE_DB_Object;
    dhcpsub :TFRE_DB_DHCP_Subnet;
    dhcpfix :TFRE_DB_DHCP_Fixed;

begin
  FRE_DBBASE.Register_DB_Extensions;
  fos_citycom_base.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;

  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));

  if not conn.CollectionExists(CFRE_DB_ASSET_COLLECTION) then
    begin
     coll:=conn.CreateCollection(CFRE_DB_ASSET_COLLECTION);
     coll.DefineIndexOnField('provisioningmac',fdbft_String,true,false,'mac',true,false);
    end
  else
    coll:=conn.GetCollection(CFRE_DB_ASSET_COLLECTION);

  cpe:=TFRE_DB_CRYPTOCPE.CreateForDB;
  cpe.ObjectName:='ccpe2 FirmOS';
  cpe.provisioningmac:='00:03:2d:1d:2d:7d';
  cfg:=GFRE_DBI.NewObject;
  cpe.Field('config').AsObject:=cfg;
  network := TFRE_DB_CPE_NETWORK_SERVICE.CreateForDB;
  cfg.Field('network').AsObject:=network;

  dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
  dl.ObjectName:='eth0';
  network.Field(dl.ObjectName).AsObject:=dl;
  ip4:= TFRE_DB_IPV4_HOSTNET.CreateForDB;
  ip4.Field('ip_net').AsString:='10.55.0.65/27';
  dl.Field(ip4.UID.AsHexString).AsObject:=ip4;

  dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
  dl.ObjectName:='eth1';
  network.Field(dl.ObjectName).AsObject:=dl;
  ip4:= TFRE_DB_IPV4_HOSTNET.CreateForDB;
  ip4.Field('ip_net').AsString:='192.168.1.100/24';
  dl.Field(ip4.UID.AsHexString).AsObject:=ip4;

  dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
  dl.ObjectName:='eth2';
  network.Field(dl.ObjectName).AsObject:=dl;
  ip6:= TFRE_DB_IPV6_HOSTNET.CreateForDB;
  ip6.Field('slaac').AsBoolean:=true;
  dl.Field(ip6.UID.AsHexString).AsObject:=ip6;

  dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
  dl.ObjectName:='eth3';
  network.Field(dl.ObjectName).AsObject:=dl;
  ip4:= TFRE_DB_IPV4_HOSTNET.CreateForDB;
  ip4.Field('dhcp').AsBoolean:=true;
  dl.Field(ip4.UID.AsHexString).AsObject:=ip4;

  tnl := TFRE_DB_DATALINK_IPTUN.CreateForDB;
  tnl.ObjectName:='tunnel6';
  tnl.Field('mode').AsString:='ip6ip6';
  tnl.Field('remote_ip_net_ipv6').AsString:='fdd7:f47b:4605:0705:0001:0000:0001:1';
  tnl.Field('local_ip_net_ipv6').AsString:='fdd7:f47b:4605:0705:0001:0000:0002:1';
  tnl.Field('device').AsString:='eth3';
  ip6:= TFRE_DB_IPV6_HOSTNET.CreateForDB;
  ip6.Field('slaac').AsBoolean:=false;
  ip6.Field('ip_net').AsString:='fdd7:f47b:4605:0705:0002:0000:0002:1/80';
  tnl.Field(ip6.UID.AsHexString).AsObject:=ip6;
  network.Field(tnl.ObjectName).AsObject:=tnl;

  tnl := TFRE_DB_DATALINK_IPTUN.CreateForDB;
  tnl.ObjectName:='tunnel4';
  tnl.Field('mode').AsString:='sit';
  tnl.Field('remote_ip_net_ipv4').AsString:='10.1.0.88';
  tnl.Field('local_ip_net_ipv4').AsString:='10.1.0.169';
  tnl.Field('device').AsString:='eth2';
  ip6:= TFRE_DB_IPV6_HOSTNET.CreateForDB;
  ip6.Field('slaac').AsBoolean:=false;
  ip6.Field('ip_net').AsString:='fdd7:f47b:4605:0705:0002:0000:0002:1/80';
  tnl.Field(ip6.UID.AsHexString).AsObject:=ip6;
  network.Field(tnl.ObjectName).AsObject:=tnl;


  halo   := GFRE_DBI.CreateFromFile('/opt/local/fre/hal/ca_backup_voip.cfg');
  writeln(halo.DumpToString());
  caobj  := halo.Field('ca').AsObject;
//  writeln(caobj.Field('VPNVOIP').AsObject.Field('crt_stream').AsStream);
  crtobj := halo.Field('crt').AsObject;
  vpn     := TFRE_DB_CPE_OPENVPN_SERVICE.CreateForDB;
  vpn.ObjectName:='voip';
  vpn.Field('server').AsBoolean:=false;
  vpn.Field('device').AsString:='tun0';
  vpn.Field('protocol').AsString:='tcp';
  vpn.Field('remote').AddString('109.73.158.186 1194');
  vpn.Field('remote').AddString('fdd7:f47b:4605:705::1 1194');
  vpn.Field('ca').asstream.LoadFromStream(caobj.Field('VPNVOIP').AsObject.Field('crt_stream').AsStream);
  crtobj.FetchObjWithStringFieldValue('objname','ccpe2',crt,TFRE_DB_CERTIFICATE.ClassName);
  vpn.Field('crt').asstream.LoadFromStream(crt.Field('crt_stream').AsStream);
  vpn.Field('key').asstream.LoadFromStream(crt.Field('key_stream').AsStream);
  cfg.Field(vpn.UID.AsHexString).AsObject:=vpn;
//  writeln(vpn.Field('crt').AsStream.AsRawByteString);
//  writeln(vpn.Field('key').AsStream.AsRawByteString);

  halo   := GFRE_DBI.CreateFromFile('/opt/local/fre/hal/ca_backup_kmub.cfg');
//  writeln(halo.DumpToString());
  caobj  := halo.Field('ca').AsObject;
  crtobj := halo.Field('crt').AsObject;
  vpn     := TFRE_DB_CPE_OPENVPN_SERVICE.CreateForDB;
  vpn.ObjectName:='kmu';
  vpn.Field('server').AsBoolean:=false;
  vpn.Field('device').AsString:='tap0';
  vpn.Field('protocol').AsString:='tcp';
  vpn.Field('remote').AddString('109.73.158.186 1196');
  vpn.Field('remote').AddString('fdd7:f47b:4605:705::1 1196');
  vpn.Field('ca').asstream.LoadFromStream(caobj.Field('VPNKMUB').AsObject.Field('crt_stream').AsStream);
  crtobj.FetchObjWithStringFieldValue('objname','ccpe1',crt,TFRE_DB_CERTIFICATE.ClassName);
  vpn.Field('crt').asstream.LoadFromStream(crt.Field('crt_stream').AsStream);
  vpn.Field('key').asstream.LoadFromStream(crt.Field('key_stream').AsStream);
  cfg.Field(vpn.UID.AsHexString).AsObject:=vpn;



  dhcp     := TFRE_DB_CPE_DHCP_SERVICE.CreateForDB;
  dhcpsub  := TFRE_DB_DHCP_Subnet.CreateForDB;
  dhcpsub.Field('subnet').AsString:='10.55.0.64/27';
  dhcpsub.Field('range_start').AsString:='10.55.0.40';
  dhcpsub.Field('range_end').AsString:='10.55.0.62';
  dhcpsub.Field('router').AsString:='10.55.0.65';
  dhcpsub.Field('dns').AsString:='8.8.8.8';
  dhcpsub.Field('option_tftp66').asstring:='192.168.82.3';

  dhcpfix  := TFRE_DB_DHCP_Fixed.CreateForDB;
  dhcpfix.ObjectName:='yealinka';
  dhcpfix.Field('ip').AsString      := '10.55.0.34';
  dhcpfix.Field('mac').AsString     := '00:15:65:32:9e:12';
  dhcpsub.Field(dhcpfix.UID.AsHexString).AsObject:=dhcpfix;
  dhcpfix  := TFRE_DB_DHCP_Fixed.CreateForDB;
  dhcpfix.ObjectName:='yealinkb';
  dhcpfix.Field('ip').AsString      := '10.55.0.35';
  dhcpfix.Field('mac').AsString     := '00:15:65:20:d2:af';
  dhcpsub.Field(dhcpfix.UID.AsHexString).AsObject:=dhcpfix;
  dhcpfix  := TFRE_DB_DHCP_Fixed.CreateForDB;
  dhcpfix.ObjectName:='yealinkc';
  dhcpfix.Field('ip').AsString      := '10.55.0.36';
  dhcpfix.Field('mac').AsString     := '00:15:65:20:d4:91';
  dhcpsub.Field(dhcpfix.UID.AsHexString).AsObject:=dhcpfix;
  dhcpfix  := TFRE_DB_DHCP_Fixed.CreateForDB;
  dhcpfix.ObjectName:='ataa';
  dhcpfix.Field('ip').AsString      := '10.55.0.37';
  dhcpfix.Field('mac').AsString     := 'ac:f2:c5:34:ac:6c';
  dhcpsub.Field(dhcpfix.UID.AsHexString).AsObject:=dhcpfix;
  dhcp.Field(dhcpsub.UID.AsHexString).AsObject:=dhcpsub;
  cfg.Field('dhcp').AsObject:=dhcp;

  vf       := TFRE_DB_CPE_VIRTUAL_FILESERVER.CreateForDB;
  cfg.Field('fileserver').AsObject:=vf;
  writeln('SWL:'+cfg.DumpToString());

  cfg.SaveToFile('/opt/local/fre/hal/cpe.cfg');

  CheckDbResult(coll.Store(cpe));



  cpe:=TFRE_DB_CRYPTOCPE.CreateForDB;
  cpe.ObjectName:='ccpe1 WienEnergie';
  cpe.provisioningmac:='00:03:2d:28:07:6b';
  CheckDbResult(coll.Store(cpe));

  cpe:=TFRE_DB_CRYPTOCPE.CreateForDB;
  cpe.ObjectName:='ccpe3 Citycom';
  cpe.provisioningmac:='00:03:2d:1d:2d:79';
  CheckDbResult(coll.Store(cpe));

  conn.Free;
end;

procedure TFRE_Testserver.AddAFeederUser(const feederusername: string; const feederpass: string; const feederclass: string);
var conn : IFRE_DB_CONNECTION;
begin
  conn := GFRE_DB.NewConnection;
  try
    CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
    CheckDbResult(conn.sys.AddUser(feederusername,conn.GetSysDomainUID,feederpass,'','',nil,'',true,'','',feederclass));
  finally
    conn.Finalize;
  end;
end;

procedure TFRE_Testserver.AddAuser(const userstringencoding: string);
var param : TFRE_DB_StringArray;
begin
  FREDB_SeperateString(userstringencoding,',',param);
  if Length(param)<>3 then
    begin
      writeln('syntax error, must have 3 parameters');
      exit;
    end;
  AddAFeederUser(param[0],param[1],param[2]);
end;

procedure TFRE_Testserver.GenerateDataCenterData;
var coll,dccoll    : IFRE_DB_COLLECTION;
    hcoll          : IFRE_DB_COLLECTION;
    tcoll          : IFRE_DB_COLLECTION;
    conn           : TFRE_DB_CONNECTION;
    cc_cust        : TFOS_DB_CITYCOM_CUSTOMER;
    tmpl           : TFRE_DB_FBZ_TEMPLATE;
    dc_id          : TFRE_DB_GUID;
    host_id        : TFRE_DB_GUID;
    template_id    : TFRE_DB_GUID;
    zcoll          : IFRE_DB_COLLECTION;
    pcoll          : IFRE_DB_COLLECTION;
    pool_id        : TFRE_DB_GUID;
    dscoll         : IFRE_DB_COLLECTION;
    ds_id          : TFRE_DB_GUID;
    zone_id        : TFRE_DB_GUID;
    lcoll          : IFRE_DB_COLLECTION;
    link_id        : TFRE_DB_GUID;
    ipcoll         : IFRE_DB_COLLECTION;
    oce0_id        : TFRE_DB_GUID;
    ixgbe_id       : TFRE_DB_GUID;
    e0_id,e1_id    : TFRE_DB_GUID;
    ipmp_nfs       : TFRE_DB_GUID;
    ipmp_drs       : TFRE_DB_GUID;
    g_domain_id    : TFRE_DB_GUID;
    rcoll          : IFRE_DB_COLLECTION;

    function       CreateDC(const name:string):TFRE_DB_GUID;
    var
      dc             : TFRE_DB_DATACENTER;
    begin
      dc           := TFRE_DB_DATACENTER.CreateForDB;
      dc.ObjectName:=name;
      dc.SetDomainID(g_domain_id);
      result       := dc.UID;
      CheckDBResult(dccoll.Store(dc));
      writeln('Created Datacenter:',name);
    end;

    function       CreateHost(const name:string; const dc_id:TFRE_DB_GUID):TFRE_DB_GUID;
    var
      host             : TFRE_DB_MACHINE;
    begin
      host             := TFRE_DB_MACHINE.CreateForDB;
      host.ObjectName  := name;
      host.Field('datacenterid').AddObjectLink(dc_id);
      host.Field('mosparentIds').AddObjectLink(dc_id);
      host.Field('serviceParent').AsObjectLink:=dc_id;
      host.SetDomainID(g_domain_id);
      result           := host.UID;
      CheckDBResult(hcoll.Store(host));
      writeln('Created Host:',name);
    end;

    function       CreatePool(const name:string; const host_id:TFRE_DB_GUID):TFRE_DB_GUID;
    var
      pool             : TFRE_DB_ZFS_POOL;
    begin
      pool             := TFRE_DB_ZFS_POOL.CreateForDB;
      pool.ObjectName  := name;
      pool.MachineID   := host_id;
      pool.Field('mosparentIds').AddObjectLink(host_id);
      pool.Field('serviceParent').AsObjectLink:=host_id;
      pool.SetDomainID(g_domain_id);
      result           := pool.UID;
      CheckDBResult(pcoll.Store(pool));
      writeln('Created Pool:',name);
    end;

    function       CreateDataset(const name:string; const pool_id:TFRE_DB_GUID):TFRE_DB_GUID;
    var
      ds               : TFRE_DB_ZFS_DATASET;
    begin
      ds             := TFRE_DB_ZFS_DATASET.CreateForDB;
      ds.ObjectName  := name;
      ds.Field('poolid').AsObjectLink := pool_id;
      ds.Field('serviceParent').AsObjectLink:=pool_id;
      ds.SetDomainID(g_domain_id);
      result           := ds.UID;
//      writeln('DATASET:',ds.DumpToString());
      CheckDBResult(dscoll.Store(ds));
      writeln('Created DataSet:',name);
    end;


    function       CreateZone(const name:string; const serviceparent_id:TFRE_DB_GUID; const host_id:TFRE_DB_GUID; const template_id:TFRE_DB_GUID):TFRE_DB_GUID;
    var
      zone             : TFRE_DB_ZONE;
    begin
      zone             := TFRE_DB_ZONE.CreateForDB;
      zone.ObjectName  := name;
      if template_id<>CFRE_DB_NullGUID then
        zone.Field('templateid').AsObjectLink:=template_id;
      zone.Field('hostid').AsObjectLink:=host_id;
      zone.Field('serviceParent').AsObjectLink:=serviceparent_id;
      zone.SetDomainID(g_domain_id);
      result           := zone.UID;
 //     writeln('ZONE:',zone.DumpToString());
      CheckDBResult(zcoll.Store(zone));
      writeln('Created Zone:',name);
    end;

    function AddDatalink(const clname:string; const name: string; const zoneid:TFRE_DB_GUID; const datalinkparentid:TFRE_DB_GUID; const show_virtual:boolean; const show_global:boolean; const mtu:integer;const vlan:integer;const ipmpparent:TFRE_DB_GUID; const description:TFRE_DB_String=''): TFRE_DB_GUID;
    var
      datalink    : IFRE_DB_Object;
    begin
      datalink := GFRE_DBI.NewObjectSchemeByName(clname);
      datalink.Field('objname').asstring := name;
      if datalinkparentid<>CFRE_DB_NullGUID then
        begin
          datalink.Field('parentid').AsObjectLink := datalinkparentid;
          datalink.Field('serviceParent').AsObjectLink:=datalinkparentid;
        end
      else
        begin
          datalink.Field('serviceParent').AsObjectLink:=zone_id;
        end;
      if ipmpparent<>CFRE_DB_NullGUID then
        begin
         datalink.Field('serviceParent').AddObjectLink(ipmpparent);
         datalink.Field('ipmpparentid').AsObjectLink:=ipmpparent;
        end;

      datalink.Field('zoneid').AsObjectLink := zone_id;
      if mtu<>0 then
        begin
          datalink.Field('mtu').AsUInt16            := mtu;
        end;
      if vlan<>0 then
        begin
          datalink.Field('vlan').AsUInt16 := vlan;
        end;
      if description<>''  then
        begin
          (datalink.Implementor_HC as TFRE_DB_DATALINK).Description:=GFRE_DBI.CreateText('$'+name,description);
        end;

      datalink.SetDomainID(g_domain_id);
      result := datalink.UID;
//      writeln('DATALINK:',datalink.DumpToString());
      CheckDbResult(lCOLL.Store(datalink),'Add Datalink');
      writeln('Created Datalink:',name);
    end;

    function AddIPV4( const ip_mask:string;const parent_id:TFRE_DB_GUID): TFRE_DB_GUID;
    var
      ip    : TFRE_DB_IPV4_HOSTNET;
    begin
      ip               := TFRE_DB_IPV4_HOSTNET.CreateForDB;
      if ip_mask<>'' then
        begin
          ip.SetIPCIDR(ip_mask);
          ip.Field('dhcp').asboolean:=false;
        end
      else
        ip.Field('dhcp').asboolean:=true;

      ip.Field('parentid').AsObjectLink:=parent_id;
      ip.Field('serviceParent').AsObjectLink:=parent_id;
      ip.SetDomainID(g_domain_id);
      result           := ip.UID;
//      writeln('IPV4',ip.DumpToString());
      CheckDBResult(ipcoll.Store(ip));
      writeln('Created ipv4:',ip_mask);
    end;

    function AddIPV6( const ip_mask:string;const parent_id:TFRE_DB_GUID): TFRE_DB_GUID;
    var
      ip    : TFRE_DB_IPV6_HOSTNET;
    begin
      ip               := TFRE_DB_IPV6_HOSTNET.CreateForDB;
      if ip_mask<>'' then
        begin
          ip.SetIPCIDR(ip_mask);
          ip.Field('slaac').asboolean:=false;
        end
      else
        ip.Field('slaac').asboolean:=true;

      ip.Field('parentid').AsObjectLink:=parent_id;
      ip.Field('serviceParent').AsObjectLink:=parent_id;
      ip.SetDomainID(g_domain_id);
      result           := ip.UID;
//      writeln('IPV6',ip.DumpToString());
      CheckDBResult(ipcoll.Store(ip));
      writeln('Created ipv6:',ip_mask);
    end;

    function AddRoutingIPV4( const ip_mask:string; const gw:string; const zone_id:TFRE_DB_GUID;const description:string=''): TFRE_DB_GUID;
    var
      r    : TFRE_DB_IPV4_NETROUTE;
    begin
      r               := TFRE_DB_IPV4_NETROUTE.CreateForDB;
      r.SetIPCIDR(ip_mask);
      r.SetGatewayIP(gw);
      r.Field('zoneid').AsObjectLink:=zone_id;
      r.Field('serviceParent').AsObjectLink:=zone_id;
      if description<>''  then
        begin
          r.Description:=GFRE_DBI.CreateText('$route',description);
        end;
      r.SetDomainID(g_domain_id);
      result           := r.UID;
//      writeln('ROUTING IPV4',r.DumpToString());
      CheckDBResult(rcoll.Store(r));
      writeln('Created Route ipv4:',ip_mask,' ',gw);
    end;

begin
  FRE_DBBASE.Register_DB_Extensions;
  fos_citycom_base.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;

  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));

  g_domain_id:=conn.GetSysDomainUID;

  if not conn.CollectionExists(CFRE_DB_DATACENTER_COLLECTION) then
    begin
     dccoll:=conn.CreateCollection(CFRE_DB_DATACENTER_COLLECTION);
     dccoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    dccoll:=conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_HOST_COLLECTION) then
    begin
     hcoll:=conn.CreateCollection(CFRE_DB_HOST_COLLECTION);
     hcoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    hcoll:=conn.GetCollection(CFRE_DB_HOST_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_TEMPLATE_COLLECTION) then
    begin
     tcoll:=conn.CreateCollection(CFRE_DB_TEMPLATE_COLLECTION);
     tcoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    tcoll:=conn.GetCollection(CFRE_DB_TEMPLATE_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_ZFS_POOL_COLLECTION) then
    begin
     pcoll:=conn.CreateCollection(CFRE_DB_ZFS_POOL_COLLECTION);
//     pcoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    pcoll:=conn.GetCollection(  CFRE_DB_ZFS_POOL_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_ZFS_DATASET_COLLECTION) then
    begin
     dscoll:=conn.CreateCollection(CFRE_DB_ZFS_DATASET_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    dscoll:=conn.GetCollection(  CFRE_DB_ZFS_DATASET_COLLECTION);

  if not conn.CollectionExists(CFOS_DB_ZONES_COLLECTION) then
    begin
     zcoll:=conn.CreateCollection(CFOS_DB_ZONES_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    zcoll:=conn.GetCollection(CFOS_DB_ZONES_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_DATALINK_COLLECTION) then
    begin
     lcoll:=conn.CreateCollection(CFRE_DB_DATALINK_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    lcoll:=conn.GetCollection(CFRE_DB_DATALINK_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_IP_COLLECTION) then
    begin
     ipcoll:=conn.CreateCollection(CFRE_DB_IP_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    ipcoll:=conn.GetCollection(CFRE_DB_IP_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_ROUTING_COLLECTION) then
    begin
     rcoll:=conn.CreateCollection(CFRE_DB_ROUTING_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    rcoll:=conn.GetCollection(CFRE_DB_ROUTING_COLLECTION);


  tmpl := TFRE_DB_FBZ_TEMPLATE.CreateForDB;
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VMACHINE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_SSH_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VIRTUAL_FILESERVER.Classname);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DNS.Classname);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DHCP.Classname);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_NETWORK_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_IMAP_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_MTA_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_POSTGRES_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_MYSQL_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_HTTP_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VOIP_SERVICE.ClassName);
  template_id := tmpl.UID;
  CheckDBResult(tcoll.Store(tmpl));

  g_domain_id:=conn.GetSysDomainUID;

  dc_id    := CreateDC('RZ Nord');
  host_id  := CreateHost('ANord01',dc_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.250.102/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.240.105/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.103/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.106/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.107/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.108/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_1',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.203/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.109/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  ixgbe_id := link_id;
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);

  pool_id  := CreatePool('anord01disk',host_id);
  ds_id    := CreateDataset('anord01disk/anord01ds',pool_id);

  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('boot1',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,true,false,0,1699,CFRE_DB_NullGUID,'Crypto CPE');
  AddIPV6('fdd7:f47b:4605:0705::20/64',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,true,false,0,1598,CFRE_DB_NullGUID,'Internet');
  AddIPV4('109.73.158.185/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('dbnord',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,ixgbe_id,true,false,0,0,CFRE_DB_NullGUID,'Mgmt LAN');
  AddIPV4('10.54.3.230/24',link_id);
  AddRoutingIPV4('default','10.54.3.252',zone_id,'Default Route');

  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('guitest',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,true,false,0,1598,CFRE_DB_NullGUID,'Internet');
  AddIPV4('109.73.158.188/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('ns1',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,true,false,0,1699,CFRE_DB_NullGUID,'Crypto CPE');
  AddIPV6('fdd7:f47b:4605:0705::11/64',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,true,false,0,1598,CFRE_DB_NullGUID,'Internet');
  AddIPV4('109.73.158.187/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  g_domain_id:=conn.GetSysDomainUID;   //GRAZETTA
  zone_id  := CreateZone('grazetta',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,true,false,0,363,CFRE_DB_NullGUID,'Lan');
  AddIPV4('192.168.50.5/24',link_id);

  g_domain_id:=conn.GetSysDomainUID;   //PRO-COMPETENCE
  zone_id  := CreateZone('kmurz_a',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,true,false,0,1699,CFRE_DB_NullGUID,'Crypto CPE');
  AddIPV6('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,true,false,0,1598,CFRE_DB_NullGUID,'Internet');
  AddIPV4('109.73.158.184/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'mgmt0',zone_id,ixgbe_id,true,false,0,0,CFRE_DB_NullGUID,'Mgmt LAN');
  AddIPV4('172.24.1.1/16',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,true,false,0,1591,CFRE_DB_NullGUID,'LAN');
  AddIPV4('192.168.2.1/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm0',zone_id,oce0_id,true,false,0,1591,CFRE_DB_NullGUID,'VM 0');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm1',zone_id,oce0_id,true,false,0,1591,CFRE_DB_NullGUID,'VM 1');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'znfs0',zone_id,oce0_id,true,false,0,2000,CFRE_DB_NullGUID,'Global NFS');
  AddIPV4('172.22.1.1/16',link_id);

  g_domain_id:=conn.GetSysDomainUID;   //ZOESCHER
  zone_id  := CreateZone('zoescher',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,true,false,0,1745,CFRE_DB_NullGUID,'Lan');
  AddIPV4('192.168.0.144/24',link_id);

  g_domain_id:=conn.GetSysDomainUID;   //DEMO
  zone_id  := CreateZone('demo',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,true,false,0,1699,CFRE_DB_NullGUID,'Crypto CPE');
  AddIPV6('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,true,false,0,1588,CFRE_DB_NullGUID,'Internet');
  AddIPV4('91.143.108.194/27',link_id);
  AddRoutingIPV4('default','91.143.108.193',zone_id,'Default Route');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'mgmt0',zone_id,ixgbe_id,true,false,0,0,CFRE_DB_NullGUID,'Mgmt LAN');
  AddIPV4('172.24.1.2/16',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,true,false,0,1589,CFRE_DB_NullGUID,'LAN');
  AddIPV4('192.168.3.1/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm0',zone_id,oce0_id,true,false,0,1589,CFRE_DB_NullGUID,'VM 0');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm1',zone_id,oce0_id,true,false,0,1589,CFRE_DB_NullGUID,'VM 1');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'znfs0',zone_id,oce0_id,true,false,0,2000,CFRE_DB_NullGUID,'Global NFS');
  AddIPV4('172.22.1.2/16',link_id);

  g_domain_id:=conn.GetSysDomainUID;
  ds_id    := CreateDataset('anord01disk/nas01ds',pool_id);

  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('rsync0',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicrsync0',zone_id,oce0_id,true,false,0,1598,CFRE_DB_NullGUID,'Internet');
  AddIPV4('109.73.158.190/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');
  g_domain_id:=conn.GetSysDomainUID;   //CORTI
  zone_id  := CreateZone('corti',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,true,false,0,1758,CFRE_DB_NullGUID,'Lan');
  AddIPV4('192.168.0.18/24',link_id);

  g_domain_id:=conn.GetSysDomainUID;
  host_id  := CreateHost('SNord01',dc_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);


  host_id  := CreateHost('FSNord01',dc_id);
  pool_id  := CreatePool('nordp',host_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.250.100/25',ipmp_nfs);
  AddIPV4('10.54.250.200/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.240.100/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.101/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.101/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_1',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.107/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.102/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_2',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.201/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.103/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_1',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.207/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.104/24',link_id);

  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);



  dc_id := CreateDC('RZ Sued');
  host_id  := CreateHost('ASued01',dc_id);
  ds_id    := CreateDataset('asued01disk/asued01ds',pool_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.250.112/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.240.115/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,CFRE_DB_NullGUID,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.113/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,CFRE_DB_NullGUID,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.116/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,CFRE_DB_NullGUID,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.117/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,CFRE_DB_NullGUID,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.118/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_1',zone_id,CFRE_DB_NullGUID,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.213/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,CFRE_DB_NullGUID,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.119/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);


  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('ns2',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,true,false,0,1699,CFRE_DB_NullGUID,'Crypto CPE');
  AddIPV6('fdd7:f47b:4605:0705::12/64',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,true,false,0,1598,CFRE_DB_NullGUID,'Internet');
  AddIPV4('109.73.158.189/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');
  g_domain_id:=conn.GetSysDomainUID;   //CITYCOM
  zone_id  := CreateZone('test',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,true,false,0,1758,CFRE_DB_NullGUID);
  ds_id    := CreateDataset('asued01disk/nas02ds',pool_id);

  g_domain_id:=conn.GetSysDomainUID;
  host_id  := CreateHost('SSued01',dc_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);


  host_id  := CreateHost('FSSued01',dc_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  pool_id  := CreatePool('suedp',host_id);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.250.110/25',ipmp_nfs);
  AddIPV4('10.54.250.210/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.240.110/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.111/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.111/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_1',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.117/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.112/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_2',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.211/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.113/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_1',zone_id,link_id,false,true,0,1595,ipmp_nfs);
  AddIPV4('10.54.250.217/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.114/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('',link_id);


  dc_id := CreateDC('RZ DRS');
  host_id  := CreateHost('DRS',dc_id);
  pool_id  := CreatePool('drsdisk',host_id);
  pool_id  := CreatePool('rpool',host_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.240.198/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.199/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.200/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.201/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,false,true,9000,0,CFRE_DB_NullGUID);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,false,true,0,1594,ipmp_drs);
  AddIPV4('10.54.240.202/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('10.54.3.198/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddRoutingIPV4('default','10.54.3.252',zone_id,'Default Route');

  dc_id := CreateDC('RZ Test');
  host_id  := CreateHost('Fosdev',dc_id);
  zone_id  := CreateZone('global',host_id,host_id,CFRE_DB_NullGUID);
  pool_id  := CreatePool('syspool',host_id);
  ds_id    := CreateDataset('syspool',pool_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'e1000g0',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('10.1.0.84/24',link_id);
  AddIPV4('172.22.0.99/24',link_id);
  AddIPV6('fdd7:f47b:4605:705:3:0:1:1/80',link_id);
  e0_id    := link_id;
  AddRoutingIPV4('default','10.1.0.1',zone_id,'Default Route');

  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'e1000g1',zone_id,CFRE_DB_NullGUID,false,true,1500,0,CFRE_DB_NullGUID);
  AddIPV4('172.22.0.99/24',link_id);
  e1_id    := link_id;

  g_domain_id:=conn.GetSysDomainUID;   //DEMO
  zone_id  := CreateZone('demo',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,e1_id,true,false,0,1699,CFRE_DB_NullGUID,'Crypto CPE');
  AddIPV6('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,e0_id,true,false,0,1588,CFRE_DB_NullGUID,'Internet');
  AddIPV4('91.143.108.194/27',link_id);
  AddRoutingIPV4('default','91.143.108.193',zone_id,'Default Route');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'mgmt0',zone_id,e0_id,true,false,0,0,CFRE_DB_NullGUID,'Mgmt Lan');
  AddIPV4('172.24.1.2/16',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,e0_id,true,false,0,1589,CFRE_DB_NullGUID,'Lan');
  AddIPV4('192.168.3.1/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm0',zone_id,e1_id,true,false,0,1589,CFRE_DB_NullGUID,'VM 0');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm1',zone_id,e1_id,true,false,0,1589,CFRE_DB_NullGUID,'VM 1');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'znfs0',zone_id,e0_id,true,false,0,2000,CFRE_DB_NullGUID,'Global NFS');
  AddIPV4('172.22.1.2/16',link_id);


  conn.Free;
end;

begin
  cFRE_PS_LAYER_USE_EMBEDDED := true; { always patch local ? }
  Application:=TFRE_Testserver.Create(nil);
  Application.Title:='FirmOS Generic #Patcher';
  Application.DefaultExtensions := 'TEST';
  Application.Run;
  Application.Free;
end.

