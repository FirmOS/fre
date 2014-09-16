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
  AddCheckOption('*','patch:'     ,'                | --patch <val>                     : manual patch');
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
   coll := conn.GetDomainCollection(CFOS_DB_PROD_MOD_VARIATION_PRICES_COLLECTION,'CITYCOM');
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
      r_guid : TGuid;
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
   coll_p    := conn.GetDomainCollection(CFOS_DB_PRODUCTS_COLLECTION,domainname);
   coll_pv   := conn.GetDomainCollection(CFOS_DB_PRODUCT_VARIATIONS_COLLECTION,domainname);
   writeln('PATCHING BASE DB ',FDBName);
   coll_rel  := conn.GetDomainCollection(CFOS_DB_PRODUCT_ADDON_RELATIONS_COLLECTION,domainname);
   coll_p.ForAll(@AddonsPatch);
   coll_rel  := conn.GetDomainCollection(CFOS_DB_PRODUCTVARIATION_ADDON_RELATIONS_COLLECTION,domainname);
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
                  moduleColl:=conn.GetDomainCollection(CFOS_DB_PRODUCT_MODULE_RELATIONS_COLLECTION,'citycom');
                  addonColl:=conn.GetDomainCollection(CFOS_DB_PRODUCT_ADDON_RELATIONS_COLLECTION,'citycom');
                end else begin
                  moduleColl:=conn.GetDomainCollection(CFOS_DB_PRODUCTVARIATION_MODULE_RELATIONS_COLLECTION,'citycom');
                  addonColl:=conn.GetDomainCollection(CFOS_DB_PRODUCTVARIATION_ADDON_RELATIONS_COLLECTION,'citycom');
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
  if not conn.DomainCollectionExists(CFOS_DB_CUSTOMERS_COLLECTION,domainname) then
    conn.CreateDomainCollection(CFOS_DB_CUSTOMERS_COLLECTION,false,domainname);
  coll := conn.GetDomainCollection(CFOS_DB_CUSTOMERS_COLLECTION,domainname);

  C:=TFOSMySqlConn.Create(Nil);
  try
    C.UserName:='root';
    C.Password:='kmuRZ2013$';
    //c.HostName:='crm';
    c.HostName:='10.1.0.124';
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
      is_a_dc := coll.IsADomainCollection;
      //writeln('COLL ', coll.CollectionName,' ',is_a_dc);
      if is_a_dc then
        begin
          dc_name := coll.DomainCollName();
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
      is_a_dc := coll.IsADomainCollection;
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


begin
  cFRE_PS_LAYER_USE_EMBEDDED := true; { always patch local ? }
  Application:=TFRE_Testserver.Create(nil);
  Application.Title:='FirmOS Generic #Patcher';
  Application.DefaultExtensions := 'TEST';
  Application.Run;
  Application.Free;
end.

