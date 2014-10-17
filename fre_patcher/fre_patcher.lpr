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
{$codepage utf-8}
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
    const realcust:string = '0081000359,0081000752,0081000516,0081000196,81000146,0081000661,0081000737,0081000752,0081000339,0081000695,0081000609,0081000681,0081000723,81000064,SC-PRO,SC-DEMO';
          realdom :string = 'ANKUENDER,BINDER,CITYCOM,CORTI,GRAZETTA,RUBIKON,ZOESCHER,BINDER,DMS,DIAGONALE,EGRAZ,HILFSWERK,PEAN,JOANNEUM,PRO-COMPETENCE,DEMO';
    var
    realdoma   :TFRE_DB_StringArray;
    realdomida :TFRE_DB_GUIDArray;
    realcusta  :TFRE_DB_StringArray;
    procedure  GenerateSearchDomains      (const generate:boolean);
    function   CheckFindDebitorNumber     (const debnr : string ; out domainname : TFRE_DB_String ; out domainuid:TFRE_DB_GUID):boolean;
    function   CheckFindDomainID          (const domainname : TFRE_DB_String):TFRE_DB_GUID;


    procedure   PatchCity1;
    procedure   PatchCityAddons                         (domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='x');
    procedure   PatchCityObjs                           (domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='x');
    procedure   PatchDeleteVersions                     ;
    procedure   PatchVersions;
    {$IFDEF FREMYSQL}
    procedure   ImportCitycomAccounts                   (domainname:string='citycom' ; domainuser:string='ckoch@citycom' ; domainpass:string='x');
    {$ENDIF}
    procedure   GenerateAutomaticWFSteps                ;
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

procedure TFRE_Testserver.GenerateSearchDomains(const generate: boolean);
var conn         : IFRE_DB_CONNECTION;
    i            : NativeInt;
begin
  FREDB_SeperateString(realcust,',',realcusta);
  FREDB_SeperateString(realdom,',',realdoma);
  if Length(realcusta)<>Length(realdoma) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'doms must be customers COUNT');
  begin
    conn := GFRE_DBI.NewConnection;
    CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
    SetLength(realdomida,Length(realdoma));
    for i:=0 to high(realdoma) do
      begin
        if not conn.SYS.DomainExists(realdoma[i]) then
          begin
            if generate then
              begin
                 writeln('>> ADDING DOMAIN ',realdoma[i]);
                 CheckDbResult(conn.AddDomain(realdoma[i],'',''));
                 writeln('>> ADDING DOMAIN ',realdoma[i],' DONE');
              end
            else
              begin
                writeln('NOT ALL DOMAINS IN DB -> abort');
                raise EFRE_DB_Exception.Create(edb_ERROR,'FAILED');
              end;
          end;
        realdomida[i] := conn.SYS.DomainID(realdoma[i]);
      end;
    conn.Finalize;
  end;
end;

function TFRE_Testserver.CheckFindDebitorNumber(const debnr: string; out domainname: TFRE_DB_String; out domainuid: TFRE_DB_GUID): boolean;
var i:NativeInt;
begin
  result := false;
  if debnr='' then
    exit;
  for i:=0 to high(realcusta) do
    begin
      if realcusta[i]=debnr then
        begin { found SAP debitnum}
          domainname := realdoma[i];
          domainuid  := realdomida[i];
          exit(true);
        end;
    end;
end;

function TFRE_Testserver.CheckFindDomainID(const domainname: TFRE_DB_String): TFRE_DB_GUID;
var i:NativeInt;
begin
  for i:=0 to high(realdoma) do
    begin
      if realdoma[i]=domainname then
        begin
          result  := realdomida[i];
          exit;
        end;
    end;
  raise EFRE_DB_Exception.Create(edb_ERROR,'non existent domain '+domainname);
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

procedure TFRE_Testserver.PatchCityObjs(domainname:string='citycom' ; domainuser:string='ckoch@citycom'; domainpass:string='x');
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

  var suid       :TFRE_DB_GUID;
      refs       :TFRE_DB_ObjectReferences;
      ccdebnr    :string;

  var my_domname : TFRE_DB_String;
      my_domuid  : TFRE_DB_GUID;
begin
  GenerateSearchDomains(true);
  conn := GFRE_DBI.NewConnection;
  CheckDbResult(conn.Connect(FDBName,domainuser,domainpass));
  if not conn.CollectionExists(CFOS_DB_CUSTOMERS_COLLECTION) then
    conn.CreateCollection(CFOS_DB_CUSTOMERS_COLLECTION);
  coll := conn.GetCollection(CFOS_DB_CUSTOMERS_COLLECTION);

  //suid.SetFromHexString('cddcf489d6ceffcf9290e9a4fe0b0e2d');
  //refs := conn.GetReferencesDetailed(suid,false);

  writeln('Deleting Customers');
  coll.ClearCollection;
  writeln('Deleting Customers Done');

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
    writeln('TRY CONNECT DB');
    C.Connected:=True;
    writeln('CONNECTED DB');
    Q:=TSQLQuery.Create(C);
    Q.Database:=C;
    Q.Transaction:=T;
    q.sql.Text := 'SET CHARACTER SET `utf8`';
    q.ExecSQL;
    q.sql.Text := 'SET NAMES `utf8`';
    q.ExecSQL;
    Q.SQL.Text:='SELECT accounts.*,accounts_cstm.* FROM `accounts_cstm` RIGHT OUTER JOIN `accounts` ON (`accounts_cstm`.`id_c` = `accounts`.`id`)';
    writeln('OPEN QRY');
    Q.Open;
    writeln('OPEN QRY DONE');

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
            //write(q.FieldByName(importfields[i]).AsString,' ');
            Import;
          end;
        //WriteLn;
        //writeln(cc_cust.DumpToString);
        cname := cc_cust.Field('cc_crm_id').AsString+' - '+cc_cust.ObjectName;
        ccdebnr :=trim(cc_cust.Field('cc_debitorennummer_c').AsString);

        if CheckFindDebitorNumber(ccdebnr,my_domname,my_domuid) then begin
          cnt:=cnt+1;
          cc_cust.Field('servicedomain').AsObjectLink := my_domuid;
          res := coll.Store(cc_cust);
          writeln('>> ',ccdebnr,' - ',cname,' : ',my_domname,' ->',my_domuid.AsHexString,'   DB STORE -> ',CFRE_DB_Errortype[res]);
        end;
        //writeln(cname,' : ',CFRE_DB_Errortype[res]);
        Q.Next
      end;
    Q.Close;
  finally
    C.Free;
  end;

  cname:='';

  ccdebnr:='SC-DEMO';
  if CheckFindDebitorNumber(ccdebnr,my_domname,my_domuid) then
    begin
      cc_cust := TFOS_DB_CITYCOM_CUSTOMER.CreateForDB;
      cc_cust.ObjectName:='Demo Customer';
      cc_cust.FieldPathCreate('mainaddress.street').AsString:='Musterstraße 1';
      cc_cust.FieldPathCreate('mainaddress.city').AsString:='Musterstadt';
      cc_cust.FieldPathCreate('mainaddress.zip').AsString:='1234';
      cc_cust.FieldPathCreate('mainaddress.country').AsString:='Österreich';
      cc_cust.FieldPathCreate('http.url').AsString:='demo.styriacloud.net';
      cc_cust.Field('servicedomain').AsObjectLink := my_domuid;
      cc_cust.Field('cc_debitorennummer_c').AsString:=ccdebnr;
      res := coll.Store(cc_cust);
      writeln('>> ',ccdebnr,' - ',cname,' : ',my_domname,' ->',my_domuid.AsHexString,'   DB STORE -> ',CFRE_DB_Errortype[res]);
    end;

  ccdebnr:='SC-PRO';
  if CheckFindDebitorNumber(ccdebnr,my_domname,my_domuid) then
    begin
      cc_cust := TFOS_DB_CITYCOM_CUSTOMER.CreateForDB;
      cc_cust.ObjectName:='Pro Competence';
      cc_cust.FieldPathCreate('mainaddress.street').AsString:='Musterstraße 2';
      cc_cust.FieldPathCreate('mainaddress.city').AsString:='Musterstadt';
      cc_cust.FieldPathCreate('mainaddress.zip').AsString:='1234';
      cc_cust.FieldPathCreate('mainaddress.country').AsString:='Österreich';
      cc_cust.FieldPathCreate('http.url').AsString:='www.pro-competence.at';
      cc_cust.Field('servicedomain').AsObjectLink := my_domuid;
      cc_cust.Field('cc_debitorennummer_c').AsString:=ccdebnr;
      res := coll.Store(cc_cust);
      writeln('>> ',ccdebnr,' - ',cname,' : ',my_domname,' ->',my_domuid.AsHexString,'   DB STORE -> ',CFRE_DB_Errortype[res]);
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


    procedure CreateProvisioning(const mac, description, lan : string; const voip_subnetznr, zone_nr:integer; const kmuca_file, voipca_file, voip_crt:string; const tel_mac_array:TFRE_DB_StringArray; const nfsshare:string; const ecryptfs_fnek_sig,ecryptfs_sig,ecryptfs_key: string);
    var
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
      s       :string;
      b_ip    :integer;
      i       :integer;
      r       :TFRE_DB_IPV6_NETROUTE;
      shareobj: TFRE_DB_VIRTUAL_FILESHARE;
    begin
      cpe:=TFRE_DB_CRYPTOCPE.CreateForDB;
      cpe.ObjectName:=description;
      cpe.provisioningmac:=mac;
      cfg:=GFRE_DBI.NewObject;
      cpe.Field('config').AsObject:=cfg;
      network := TFRE_DB_CPE_NETWORK_SERVICE.CreateForDB;
      cfg.Field('network').AsObject:=network;
      network.Field('ipv4_forward').asboolean:=true;

      dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
      dl.ObjectName:='eth0';
      network.Field(dl.ObjectName).AsObject:=dl;
      ip4:= TFRE_DB_IPV4_HOSTNET.CreateForDB;

      b_ip := (voip_subnetznr-1)*32;
      s:= '10.55.0.'+inttostr(b_ip+1)+'/27';

      ip4.SetIPCIDR(s);
      dl.Field(ip4.UID.AsHexString).AsObject:=ip4;

      dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
      dl.ObjectName:='eth1';
      network.Field(dl.ObjectName).AsObject:=dl;
      ip4:= TFRE_DB_IPV4_HOSTNET.CreateForDB;
      ip4.SetIPCIDR(lan);
      dl.Field(ip4.UID.AsHexString).AsObject:=ip4;

      dl:= TFRE_DB_DATALINK_PHYS.CreateForDB;
      dl.ObjectName:='eth2';
      network.Field(dl.ObjectName).AsObject:=dl;
      ip6:= TFRE_DB_IPV6_HOSTNET.CreateForDB;
      ip6.SetIPCIDR('fdd7:f47b:4605:0705:0002:0000:0000:'+inttostr(zone_nr)+'/64');
      ip6.Field('slaac').AsBoolean:=false;
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
      tnl.Field('remote_ip_net_ipv6').AsString:='fdd7:f47b:4605:0705:0001:0000:0000:'+inttostr(zone_nr);
      tnl.Field('local_ip_net_ipv6').AsString:='fdd7:f47b:4605:0705:0002:0000:0000:'+inttostr(zone_nr);
      tnl.Field('device').AsString:='eth3';
      ip6:= TFRE_DB_IPV6_HOSTNET.CreateForDB;
      ip6.Field('slaac').AsBoolean:=false;
      ip6.SetIPCIDR('fdd7:f47b:4605:02c4:0002:0000:0000:'+inttostr(zone_nr)+'/64');

      tnl.Field(ip6.UID.AsHexString).AsObject:=ip6;
      network.Field(tnl.ObjectName).AsObject:=tnl;

      r := TFRE_DB_IPV6_NETROUTE.CreateForDB;
      r.SetIPCIDR('fdd7:f47b:4605:1b0d::/64');
      r.SetGatewayIP('fdd7:f47b:4605:02c4:0001:0000:0000:'+inttostr(zone_nr));
      network.Field(r.UID_String).AsObject:=r;

      //tnl := TFRE_DB_DATALINK_IPTUN.CreateForDB;
      //tnl.ObjectName:='tunnel4';
      //tnl.Field('mode').AsString:='sit';
      //tnl.Field('remote_ip_net_ipv4').AsString:='10.1.0.88';
      //tnl.Field('local_ip_net_ipv4').AsString:='10.1.0.169';
      //tnl.Field('device').AsString:='eth2';
      //ip6:= TFRE_DB_IPV6_HOSTNET.CreateForDB;
      //ip6.Field('slaac').AsBoolean:=false;
      //ip6.Field('ip_net').AsString:='fdd7:f47b:4605:0705:0002:0000:0002:1/80';
      //tnl.Field(ip6.UID.AsHexString).AsObject:=ip6;
      //network.Field(tnl.ObjectName).AsObject:=tnl;


      halo   := GFRE_DBI.CreateFromFile(voipca_file);
//      writeln(halo.DumpToString());
      caobj  := halo.Field('ca').AsObject;
    //  writeln(caobj.Field('VPNVOIP').AsObject.Field('crt_stream').AsStream);
      crtobj := halo.Field('crt').AsObject;
      vpn     := TFRE_DB_CPE_OPENVPN_SERVICE.CreateForDB;
      vpn.ObjectName:='voip';
      vpn.Field('server').AsBoolean:=false;
      vpn.Field('device').AsString:='tun0';
      vpn.Field('protocol').AsString:='tcp';
      vpn.Field('remote').AddString('109.73.144.150 1194');
      vpn.Field('remote').AddString('fdd7:f47b:4605:705::1 1194');
      vpn.Field('ca').asstream.LoadFromStream(caobj.Field('VPNVOIP').AsObject.Field('crt_stream').AsStream);
      crtobj.FetchObjWithStringFieldValue('objname',voip_crt,crt,TFRE_DB_CERTIFICATE.ClassName);
      vpn.Field('crt').asstream.LoadFromStream(crt.Field('crt_stream').AsStream);
      vpn.Field('key').asstream.LoadFromStream(crt.Field('key_stream').AsStream);
      cfg.Field(vpn.UID.AsHexString).AsObject:=vpn;
    //  writeln(vpn.Field('crt').AsStream.AsRawByteString);
    //  writeln(vpn.Field('key').AsStream.AsRawByteString);

      halo   := GFRE_DBI.CreateFromFile(kmuca_file);
    //  writeln(halo.DumpToString());
      caobj  := halo.Field('ca').AsObject;
      crtobj := halo.Field('crt').AsObject;
      vpn     := TFRE_DB_CPE_OPENVPN_SERVICE.CreateForDB;
      vpn.ObjectName:='kmu';
      vpn.Field('server').AsBoolean:=false;
      vpn.Field('device').AsString:='tap0';
      vpn.Field('protocol').AsString:='tcp';
      vpn.Field('remote').AddString('109.73.144.150 1196');
      vpn.Field('remote').AddString('fdd7:f47b:4605:705::1 1196');
      vpn.Field('ca').asstream.LoadFromStream(caobj.Field('VPNKMUB').AsObject.Field('crt_stream').AsStream);
      crtobj.FetchObjWithStringFieldValue('objname','ccpe1',crt,TFRE_DB_CERTIFICATE.ClassName);
      vpn.Field('crt').asstream.LoadFromStream(crt.Field('crt_stream').AsStream);
      vpn.Field('key').asstream.LoadFromStream(crt.Field('key_stream').AsStream);
      cfg.Field(vpn.UID.AsHexString).AsObject:=vpn;



      dhcp     := TFRE_DB_CPE_DHCP_SERVICE.CreateForDB;
      dhcpsub  := TFRE_DB_DHCP_Subnet.CreateForDB;
      dhcpsub.Field('subnet').AsString:='10.55.0.'+inttostr(b_ip)+'/27';
      dhcpsub.Field('range_start').AsString:='10.55.0.'+inttostr(b_ip+10);
      dhcpsub.Field('range_end').AsString:='10.55.0.'+inttostr(b_ip+31);
      dhcpsub.Field('router').AsString:='10.55.0.'+inttostr(b_ip+1);
      dhcpsub.Field('dns').AsString:='172.23.1.1';
      dhcpsub.Field('option_tftp66').asstring:='192.168.82.3';

      for i:=0 to high(tel_mac_array) do
        begin
          dhcpfix  := TFRE_DB_DHCP_Fixed.CreateForDB;
          dhcpfix.ObjectName:='tel'+inttostr(i);
          dhcpfix.Field('ip').AsString      := '10.55.0.'+inttostr(b_ip+2+i);
          dhcpfix.Field('mac').AsString     := tel_mac_array[i];
          dhcpsub.Field(dhcpfix.UID.AsHexString).AsObject:=dhcpfix;
        end;

      dhcp.Field(dhcpsub.UID_String).AsObject:=dhcpsub;
      cfg.Field('dhcp').AsObject:=dhcp;

      vf       := TFRE_DB_CPE_VIRTUAL_FILESERVER.CreateForDB;
      vf.ObjectName:='knoxdata';
      vf.Field('nfsshare').asstring := nfsshare;
      vf.Field('ecryptfs_fnek_sig').asstring := ecryptfs_fnek_sig;
      vf.Field('ecryptfs_sig').asstring := ecryptfs_sig;
      vf.Field('ecryptfs_key').asstring := ecryptfs_key;
      vf.Field('cryptofile').asstring   := 'cryptofile';
      cfg.Field('fileserver').AsObject:=vf;


      shareObj:=TFRE_DB_VIRTUAL_FILESHARE.CreateForDB;
      shareObj.Field('dataset').asstring:='anord01disk/anord01ds/domains/demo/demo/zonedata/secfiler/securefiles';
      shareobj.ObjectName:='SecureFiles';
      vf.Field(shareobj.UID_String).asObject:=shareobj;

      writeln('SWL:'+cfg.DumpToString());
      cfg.SaveToFile('/opt/local/fre/hal/'+mac+'_cpe.cfg');

      CheckDbResult(coll.Store(cpe));
    end;

begin
  FRE_DBBASE.Register_DB_Extensions;
  fos_citycom_base.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;

  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
  GFRE_DB.Initialize_Extension_ObjectsBuild;

  if not conn.CollectionExists(CFRE_DB_ASSET_COLLECTION) then
    begin
     coll:=conn.CreateCollection(CFRE_DB_ASSET_COLLECTION);
     coll.DefineIndexOnField('provisioningmac',fdbft_String,true,false,'mac',true,false);
    end
  else
    coll:=conn.GetCollection(CFRE_DB_ASSET_COLLECTION);

  coll.ClearCollection;

  // WienEnergie

//  CreateProvisioning('00:03:2d:28:07:6b','Wien Energie',);
  // Demo CC
  CreateProvisioning('00:03:2d:1d:2d:79','Demo Citycom','192.168.3.2/24',2,3,'/opt/local/fre/hal/ca_backup_kmub.cfg','/opt/local/fre/hal/ca_backup_voip.cfg','ccpe2',
                     TFRE_DB_StringArray.Create('00:15:65:32:9e:12','00:15:65:20:d2:af','00:15:65:20:d4:91','ac:f2:c5:34:ac:6c'),
                     '[fdd7:f47b:4605:1b0d:0:0:0:1]:/anord01disk/anord01ds/domains/demo/demo/zonedata/secfiler','b3cf9cb7d3270dcd','b3cf9cb7d3270dcd','enctest123');
  // Test FirmOS
  CreateProvisioning('00:03:2d:1d:2d:7d','Test FirmOS','192.168.3.2/24',3,3,'/opt/local/fre/hal/ca_backup_kmub.cfg','/opt/local/fre/hal/ca_backup_voip.cfg','ccpe3',
                      TFRE_DB_StringArray.Create('00:15:65:38:39:68','10:15:65:37:5e:3f'),
                      '[fdd7:f47b:4605:1b0d:0:0:0:1]:/syspool/domains/demo/demo/zonedata/secfiler','b3cf9cb7d3270dcd','b3cf9cb7d3270dcd','enctest123');


  conn.Free;
end;

procedure TFRE_Testserver.AddAFeederUser(const feederusername: string; const feederpass: string; const feederclass: string);
var conn : IFRE_DB_CONNECTION;
begin
  conn := GFRE_DB.NewConnection;
  try
    CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
    GFRE_DB.Initialize_Extension_ObjectsBuild;
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
    gz_template_id : TFRE_DB_GUID;
    zcoll          : IFRE_DB_COLLECTION;
    pcoll          : IFRE_DB_COLLECTION;
    pool_id        : TFRE_DB_GUID;
    dscoll         : IFRE_DB_COLLECTION;
    ds_id          : TFRE_DB_GUID;
    zone_id        : TFRE_DB_GUID;
    svc_coll       : IFRE_DB_COLLECTION;
    link_id        : TFRE_DB_GUID;
    ipcoll         : IFRE_DB_COLLECTION;
    oce0_id        : TFRE_DB_GUID;
    ixgbe_id       : TFRE_DB_GUID;
    e0_id,e1_id    : TFRE_DB_GUID;
    ipmp_nfs       : TFRE_DB_GUID;
    ipmp_drs       : TFRE_DB_GUID;
    g_domain_id    : TFRE_DB_GUID;
    rcoll          : IFRE_DB_COLLECTION;
    sharecoll      : IFRE_DB_COLLECTION;
    vf_id          : TFRE_DB_GUID;

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

    function       CreateHost(const name:string; const dc_id:TFRE_DB_GUID; const mac: TFRE_DB_String):TFRE_DB_GUID;
    var
      host             : TFRE_DB_MACHINE;
    begin
      host             := TFRE_DB_MACHINE.CreateForDB;
      host.ObjectName  := name;
      host.Field('provisioningmac').AsString:=mac;
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

    function AddDatalink(const clname:string; const name: string; const zoneid:TFRE_DB_GUID; const datalinkparentid:TFRE_DB_GUID; const mtu:integer;const vlan:integer;const ipmpparent:TFRE_DB_GUID; const uniquephysicalid:TFRE_DB_String;const networktype:TFRE_DB_String;const description:TFRE_DB_String=''): TFRE_DB_GUID;
    var
      datalink    : IFRE_DB_Object;
    begin
      datalink := GFRE_DBI.NewObjectSchemeByName(clname);
      datalink.Field('objname').asstring := name;
      datalink.Field('uniquephysicalid').asstring := uniquephysicalid;
      datalink.Field('type').asstring := networktype;

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
      CheckDbResult(svc_coll.Store(datalink),'Add Datalink');
      writeln('Created Datalink:',name);
    end;

    function AddIPV4( const ip_mask:string;const parent_id:TFRE_DB_GUID): TFRE_DB_GUID;
    var
      ip    : TFRE_DB_IPV4_HOSTNET;
    begin
      ip               := TFRE_DB_IPV4_HOSTNET.CreateForDB;
      if ip_mask<>'' then
        begin
          ip.ObjectName:=ip_mask;
          ip.SetIPCIDR(ip_mask);
          ip.Field('dhcp').asboolean:=false;
        end
      else begin
        ip.ObjectName:='DHCP';
        ip.Field('dhcp').asboolean:=true;
      end;

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
          ip.ObjectName:=ip_mask;
          ip.SetIPCIDR(ip_mask);
          ip.Field('slaac').asboolean:=false;
        end
      else begin
        ip.ObjectName:='SLAAC';
        ip.Field('slaac').asboolean:=true;
      end;

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
      r.ObjectName:=ip_mask;
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

    procedure RemoveObjLinks(const coll:IFRE_DB_COLLECTION);

      procedure _clearIterator(const obj:IFRE_DB_Object);

        procedure _fieldIterator(const fld:IFRE_DB_Field);
        begin
          if fld.FieldType=fdbft_ObjLink then
            begin
              writeln('deleting field :',fld.fieldname);
              obj.DeleteField(fld.FieldName);
            end;
        end;

      begin
        obj.ForAllFields(@_fieldIterator);
        CheckDbResult(coll.Update(obj));
      end;

    begin
      coll.ForAll(@_clearIterator);
    end;


   procedure CreateVM(const zone_id:TFRE_DB_GUID; const name:string; const mgmt_ip:string; const port:integer);
   var vm:TFRE_DB_VMACHINE;
   begin
     vm:=TFRE_DB_VMACHINE.CreateForDB;
     vm.SetDomainID(g_domain_id);
     vm.ObjectName:=name;
     vm.key:=name;
     vm.vncHost:=mgmt_ip;
     vm.vncPort:=port;
     vm.state:='RUNNING';
     vm.mtype:='KVM';
     vm.Field('serviceParent').AsObjectLink:=zone_id;
     vm.Field('zoneid').AsObjectLink:=zone_id;
     vm.Field('uniquephysicalid').asstring := zone_id.AsHexString+'_'+name;
     CheckDbResult(svc_coll.Store(vm));
   end;

   procedure CreateShare(const fileserver_id:TFRE_DB_GUID; const pool_id:TFRE_DB_GUID;const ds:string; const sharename:string;const quota,rquota:integer);
   var idx: string;
       shareobj: TFRE_DB_VIRTUAL_FILESHARE;
   begin
     shareColl:=conn.GetCollection(CFRE_DB_FILESHARE_COLLECTION);
     idx:='FS_'+ sharename + '@' + fileserver_id.AsHexString;
     shareObj:=TFRE_DB_VIRTUAL_FILESHARE.CreateForDB;
     shareObj.SetDomainID(g_domain_id);
     shareObj.Field('uniquephysicalid').AsString:=idx;
     shareObj.Field('dataset').asstring:=ds;
     shareObj.Field('poolid').AsObjectLink:=pool_id;
     shareObj.Field('fileserver').AsObjectLink:=fileserver_id;
     shareobj.ObjectName:=sharename;
     shareobj.Field('quota_mb').AsUInt32:=quota;
     shareobj.Field('referenced_mb').AsUInt32:=quota;
     writeln('VFS:',shareobj.DumpToString());
     CheckDbResult(shareColl.Store(shareObj));
   end;

   function CreateVFiler(const zone_id:TFRE_DB_GUID; const name:string):TFRE_DB_GUID;
   var vf  : TFRE_DB_VIRTUAL_FILESERVER;
       idx : string;
   begin
     vf:=TFRE_DB_VIRTUAL_FILESERVER.CreateForDB;
     vf.SetDomainID(g_domain_id);
     vf.ObjectName:=name;
     idx:='VFS_'+zone_id.AsHexString;
     vf.Field('uniquephysicalid').AsString:=idx;
     vf.Field('serviceParent').AsObjectLink:=zone_id;
     vf.Field('zoneid').AsObjectLink:=zone_id;
     result:= vf.UId;
     writeln('VF:',vf.DumpToString());
     CheckDbResult(svc_coll.Store(vf));
   end;

   function CreateCFiler(const zone_id:TFRE_DB_GUID; const name:string):TFRE_DB_GUID;
   var cf  : TFRE_DB_CRYPTO_FILESERVER;
       idx : string;
   begin
     cf:=TFRE_DB_CRYPTO_FILESERVER.CreateForDB;
     cf.SetDomainID(g_domain_id);
     cf.ObjectName:=name;
     idx:='CFS_'+zone_id.AsHexString;
     cf.Field('uniquephysicalid').AsString:=idx;
     cf.Field('serviceParent').AsObjectLink:=zone_id;
     cf.Field('zoneid').AsObjectLink:=zone_id;
     result:= cf.UId;
     writeln('CF:',cf.DumpToString());
     CheckDbResult(svc_coll.Store(cf));
   end;


begin
  GenerateSearchDomains(false);

  FRE_DBBASE.Register_DB_Extensions;
  fos_citycom_base.Register_DB_Extensions;
  fre_zfs.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;

  conn := GFRE_DB.NewConnection;
  CheckDbResult(conn.Connect(FDBName,cFRE_ADMIN_USER,cFRE_ADMIN_PASS));
  GFRE_DB.Initialize_Extension_ObjectsBuild;

  g_domain_id:=conn.GetSysDomainUID;

  if not conn.CollectionExists(CFRE_DB_DATACENTER_COLLECTION) then
    begin
     dccoll:=conn.CreateCollection(CFRE_DB_DATACENTER_COLLECTION);
     dccoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    dccoll:=conn.GetCollection(CFRE_DB_DATACENTER_COLLECTION);

  hcoll:=conn.GetCollection(cFRE_DB_MACHINE_COLLECTION);

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

  if not conn.CollectionExists(CFOS_DB_ZONES_COLLECTION) then { zones per domain }
    begin
     zcoll:=conn.CreateCollection(CFOS_DB_ZONES_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    zcoll:=conn.GetCollection(CFOS_DB_ZONES_COLLECTION);

  svc_coll:=conn.GetCollection(CFOS_DB_SERVICES_COLLECTION);  { services per domain }

  if not conn.CollectionExists(CFRE_DB_IP_COLLECTION) then    { ip per domain }
    begin
     ipcoll:=conn.CreateCollection(CFRE_DB_IP_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    ipcoll:=conn.GetCollection(CFRE_DB_IP_COLLECTION);
                                                                { ROUTING SERVICE anlegen }
  if not conn.CollectionExists(CFRE_DB_ROUTING_COLLECTION) then { routing per domain }
    begin
     rcoll:=conn.CreateCollection(CFRE_DB_ROUTING_COLLECTION);
//     dscoll.DefineIndexOnField('objname',fdbft_String,true);
    end
  else
    rcoll:=conn.GetCollection(CFRE_DB_ROUTING_COLLECTION);

  if not conn.CollectionExists(CFRE_DB_FILESHARE_COLLECTION) then begin
    sharecoll:=conn.CreateCollection(CFRE_DB_FILESHARE_COLLECTION);
  end else begin
    sharecoll:=conn.GetCollection(CFRE_DB_FILESHARE_COLLECTION);
  end;
  if not sharecoll.IndexExists('def') then begin
    sharecoll.DefineIndexOnField('objname',fdbft_String,true,true,'def',false);
  end;

  sharecoll.ClearCollection;
  rcoll.ClearCollection;
  ipcoll.ClearCollection;

  RemoveObjLinks(svc_coll);
  writeln('clear svcs');
  svc_coll.ClearCollection;
  writeln('cleared svc');
  zcoll.ClearCollection;
  dscoll.ClearCollection;
  pcoll.ClearCollection;
  tcoll.ClearCollection;
  if conn.CollectionExists('hosts') then
    begin
      hcoll:=conn.GetCollection('hosts');
      hcoll.ClearCollection;
    end;
  hcoll:=conn.GetCollection(cFRE_DB_MACHINE_COLLECTION);
  hcoll.ClearCollection;
  dccoll.ClearCollection;

  if hcoll.IndexExists('pmac') then
    begin
      CheckDbResult(hcoll.DropIndex('pmac'));
      CheckDbResult(hcoll.DefineIndexOnField('provisioningmac',fdbft_String,true,true,'pmac',false));
    end;

  tmpl := TFRE_DB_FBZ_TEMPLATE.CreateForDB;
  tmpl.ObjectName:='GLOBAL';
  tmpl.Field('serviceclasses').AddString(TFRE_DB_GLOBAL_FILESERVER.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_Routing.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_AGGR.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_IPMP.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_IPTUN.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_STUB.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_VNIC.ClassName);
  gz_template_id := tmpl.UID;
  CheckDBResult(tcoll.Store(tmpl));


  tmpl := TFRE_DB_FBZ_TEMPLATE.CreateForDB;
  tmpl.ObjectName:='FBZ_093';
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VMACHINE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_SSH_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VIRTUAL_FILESERVER.Classname);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DNS.Classname);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DHCP.Classname);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VPN.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_IMAP_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_MTA_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_POSTGRES_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_MYSQL_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_HTTP_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_VOIP_SERVICE.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_Routing.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_IPTUN.ClassName);
  tmpl.Field('serviceclasses').AddString(TFRE_DB_DATALINK_VNIC.ClassName);
  template_id := tmpl.UID;
  CheckDBResult(tcoll.Store(tmpl));

  g_domain_id:=conn.GetSysDomainUID;

  dc_id    := CreateDC('RZ Nord');
  host_id  := CreateHost('ANord01',dc_id,'00:25:90:82:bf:ae');
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'anord01_ipmp_nfs','mgmt');
  AddIPV4('10.54.250.102/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'anord01_ipmp_drs','mgmt');
  AddIPV4('10.54.240.105/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:37:79:4a','generic');
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:a0:36:08','mgmt');
  AddIPV4('10.54.250.103/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:7a:74:cd','mgmt');
  AddIPV4('10.54.240.106/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:37:79:4e','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:f9:51:fb','mgmt');
  AddIPV4('10.54.240.107/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:37:79:a2','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:7e:8f:d4','mgmt');
  AddIPV4('10.54.240.108/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:37:79:a6','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_1',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:ec:27:ce','mgmt');
  AddIPV4('10.54.250.203/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:d4:64:df','mgmt');
  AddIPV4('10.54.240.109/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:82:bf:ae','generic');
  ixgbe_id := link_id;
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:82:bf:af','generic');
  AddIPV4('',link_id);

  pool_id  := CreatePool('anord01disk',host_id);
  ds_id    := CreateDataset('anord01disk/anord01ds',pool_id);


  g_domain_id := CheckFindDomainID('CITYCOM');
  zone_id  := CreateZone('boot1',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,0,1699,CFRE_DB_NullGUID,'02:08:20:50:4c:9c','cpe','Crypto CPE');
  AddIPV6('fdd7:f47b:4605:0705::20/64',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,0,1598,CFRE_DB_NullGUID,'02:08:20:85:d9:ab','internet','Internet');
  AddIPV4('109.73.158.185/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  zone_id  := CreateZone('dbnord',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,ixgbe_id,0,0,CFRE_DB_NullGUID,'02:08:20:3a:62:ce','mgmt','Mgmt LAN');
  AddIPV4('10.54.3.230/24',link_id);
  AddRoutingIPV4('default','10.54.3.252',zone_id,'Default Route');

  zone_id  := CreateZone('guitest',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,0,1598,CFRE_DB_NullGUID,'02:08:20:e7:99:7d','internet','Internet');
  AddIPV4('109.73.158.188/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  zone_id  := CreateZone('ns1',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,0,1699,CFRE_DB_NullGUID,'02:08:20:15:83:8f','cpe','Crypto CPE');
  AddIPV6('fdd7:f47b:4605:0705::11/64',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,0,1598,CFRE_DB_NullGUID,'02:08:20:a9:32:69','internet','Internet');
  AddIPV4('109.73.158.187/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  g_domain_id := CheckFindDomainID('GRAZETTA');
  zone_id  := CreateZone('grazetta',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,0,363,CFRE_DB_NullGUID,'02:08:20:96:f2:03','lan','Lan');
  AddIPV4('192.168.50.5/24',link_id);

  g_domain_id := CheckFindDomainID('PRO-COMPETENCE');
  zone_id  := CreateZone('kmurz_a',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,0,1699,CFRE_DB_NullGUID,'02:08:20:84:b2:0d','cpe','Crypto CPE');
  AddIPV6('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,0,1598,CFRE_DB_NullGUID,'02:08:20:28:5d:11','internet','Internet');
  AddIPV4('109.73.158.184/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'mgmt0',zone_id,ixgbe_id,0,0,CFRE_DB_NullGUID,'02:08:20:6f:60:84','mgmt','Mgmt LAN');
  AddIPV4('172.24.1.1/16',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,0,1591,CFRE_DB_NullGUID,'02:08:20:86:21:dd','lan','LAN');
  AddIPV4('192.168.2.1/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm0',zone_id,oce0_id,0,1591,CFRE_DB_NullGUID,'02:08:20:44:dd:13','vm','VM 0');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm1',zone_id,oce0_id,0,1591,CFRE_DB_NullGUID,'02:08:20:e4:c9:7e','vm','VM 1');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'znfs0',zone_id,oce0_id,0,2000,CFRE_DB_NullGUID,'02:08:20:45:87:d1','mgmt','Global NFS');
  AddIPV4('172.22.1.1/16',link_id);
  CreateVM(zone_id,'qemuwin2','172.24.1.1',5900);
  CreateVM(zone_id,'qemulin1','172.24.1.1',5901);

  g_domain_id := CheckFindDomainID('ZOESCHER');
  zone_id  := CreateZone('zoescher',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,0,1745,CFRE_DB_NullGUID,'02:08:20:c4:58:31','lan','Lan');
  AddIPV4('192.168.0.144/24',link_id);

  g_domain_id := CheckFindDomainID('DEMO');
  zone_id  := CreateZone('demo',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,0,1699,CFRE_DB_NullGUID,'02:08:20:a:8:9c','cpe','Crypto CPE');
  AddIPV6('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,0,1588,CFRE_DB_NullGUID,'02:08:20:2f:3b:3c','internet','Internet');
  AddIPV4('91.143.108.194/27',link_id);
  AddRoutingIPV4('default','91.143.108.193',zone_id,'Default Route');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'mgmt0',zone_id,ixgbe_id,0,0,CFRE_DB_NullGUID,'02:08:20:16:70:91','mgmt','Mgmt LAN');
  AddIPV4('172.24.1.2/16',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,0,1589,CFRE_DB_NullGUID,'02:08:20:79:55:84','lan','LAN');
  AddIPV4('192.168.3.1/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm0',zone_id,oce0_id,0,1589,CFRE_DB_NullGUID,'02:08:20:dd:68:d3','vm','VM 0');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm1',zone_id,oce0_id,0,1589,CFRE_DB_NullGUID,'02:08:20:7d:3:42','vm','VM 1');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'znfs0',zone_id,oce0_id,0,2000,CFRE_DB_NullGUID,'02:08:20:23:54:62','Global NFS');
  AddIPV4('172.22.1.2/16',link_id);
  CreateVM(zone_id,'qemuwin2','172.24.1.2',5900);
  CreateVM(zone_id,'qemulin1','172.24.1.2',5901);
  vf_id:=CreateVFiler(zone_id,'Demo Virtual Fileserver');
  CreateShare(vf_id,pool_id,'anord01disk/anord01ds/domains/demo/demo/zonedata/vfiler/sales','Sales',10240,10240);
  CreateShare(vf_id,pool_id,'anord01disk/anord01ds/domains/demo/demo/zonedata/vfiler/development','Development',10240,10240);
  CreateShare(vf_id,pool_id,'anord01disk/anord01ds/domains/demo/demo/zonedata/vfiler/management','Management',10240,10240);
  vf_id:=CreateCFiler(zone_id,'Demo Crypto Fileserver');
  CreateShare(vf_id,pool_id,'anord01disk/anord01ds/domains/demo/demo/zonedata/secfiler/securefiles','SecureFiles',10240,10240);

  g_domain_id:=conn.GetSysDomainUID;
  ds_id    := CreateDataset('anord01disk/nas01ds',pool_id);

  g_domain_id := CheckFindDomainID('CITYCOM');
  zone_id  := CreateZone('rsync0',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicrsync0',zone_id,oce0_id,0,1598,CFRE_DB_NullGUID,'02:08:20:bc:85:c9','internet','Internet');
  AddIPV4('109.73.158.190/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');

  g_domain_id := CheckFindDomainID('CORTI');
  zone_id  := CreateZone('corti',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,0,1758,CFRE_DB_NullGUID,'02:08:20:4b:eb:3a','lan','Lan');
  AddIPV4('192.168.0.18/24',link_id);

  g_domain_id:=conn.GetSysDomainUID;
  host_id  := CreateHost('SNord01',dc_id,'00:25:90:82:c0:0c');
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:82:c0:0c','mgmt');
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:82:c0:0d','mgmt');
  AddIPV4('',link_id);

  host_id  := CreateHost('FSNord01',dc_id,'00:25:90:8a:c7:c0');
  pool_id  := CreatePool('nordp',host_id);
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'fsnord01_ipmp_nfs','mgmt');
  AddIPV4('10.54.250.100/25',ipmp_nfs);
  AddIPV4('10.54.250.200/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'fsnord01_ipmp_drs','mgmt');
  AddIPV4('10.54.240.100/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:47:6d:88','generic');
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:35:ba:d3','mgmt');
  AddIPV4('10.54.250.101/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:da:52:00','mgmt');
  AddIPV4('10.54.240.101/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:47:6d:8c','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_1',zone_id,link_id,0,1595,ipmp_nfs,'02:88:20:90:d9:15','mgmt');
  AddIPV4('10.54.250.107/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:1d:52:4d','mgmt');
  AddIPV4('10.54.240.102/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:47:6c:b0','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_2',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:a2:c7:11','mgmt');
  AddIPV4('10.54.250.201/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:86:12:9c','mgmt');
  AddIPV4('10.54.240.103/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'0:90:fa:47:6c:b4','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_3',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:c7:6a:fd','mgmt');
  AddIPV4('10.54.250.207/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:39:36:36','mgmt');
  AddIPV4('10.54.240.104/24',link_id);

  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:c7:c0','mgmt');
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:c7:c1','mgmt');
  AddIPV4('',link_id);



  dc_id := CreateDC('RZ Sued');
  host_id  := CreateHost('ASued01',dc_id,'00:25:90:8a:cb:e2');
  ds_id    := CreateDataset('asued01disk/asued01ds',pool_id);
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'asued01_ipmp_nfs','mgmt');
  AddIPV4('10.54.250.112/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'asued01_ipmp_drs','mgmt');
  AddIPV4('10.54.240.115/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:4c:11:64','generic');
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,CFRE_DB_NullGUID,0,1595,ipmp_nfs,'02:8:20:e5:26:67','mgmt');
  AddIPV4('10.54.250.113/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,CFRE_DB_NullGUID,0,1594,ipmp_drs,'02:08:20:2a:85:19','mgmt');
  AddIPV4('10.54.240.116/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:4c:11:68','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,CFRE_DB_NullGUID,0,1594,ipmp_drs,'02:08:20:c9:d3:5f','mgmt');
  AddIPV4('10.54.240.117/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:4c:f:f6','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,CFRE_DB_NullGUID,0,1594,ipmp_drs,'02:08:20:ff:99:35','mgmt');
  AddIPV4('10.54.240.118/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:4c:f:fa','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_1',zone_id,CFRE_DB_NullGUID,0,1595,ipmp_nfs,'02:08:20:3d:56:8','mgmt');
  AddIPV4('10.54.250.213/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,CFRE_DB_NullGUID,0,1594,ipmp_drs,'02:08:20:89:76:8e','mgmt');
  AddIPV4('10.54.240.119/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:cb:e2','mgmt');
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:cb:e3','mgmt');
  AddIPV4('',link_id);

  g_domain_id := CheckFindDomainID('CITYCOM');
  zone_id  := CreateZone('ns2',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,oce0_id,0,1699,CFRE_DB_NullGUID,'02:08:20:bf:8c:ae','cpe','Crypto CPE');
  AddIPV6('fdd7:f47b:4605:0705::12/64',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,oce0_id,0,1598,CFRE_DB_NullGUID,'02:08:20:16:a3:b3','internet','Internet');
  AddIPV4('109.73.158.189/28',link_id);
  AddRoutingIPV4('default','109.73.158.177',zone_id,'Default Route');
  zone_id  := CreateZone('test',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,oce0_id,0,1758,CFRE_DB_NullGUID,'02:08:20:c9:f3:6a','lan');
  ds_id    := CreateDataset('asued01disk/nas02ds',pool_id);

  g_domain_id:=conn.GetSysDomainUID;
  host_id  := CreateHost('SSued01',dc_id,'00:25:90:82:c0:04');
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:82:c0:04','mgmt');
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:82:c0:05','mgmt');
  AddIPV4('',link_id);


  host_id  := CreateHost('FSSued01',dc_id,'00:25:90:8a:c7:d8');
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  pool_id  := CreatePool('suedp',host_id);
  ipmp_nfs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'nfs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'fssued01_ipmp_nfs','mgmt');
  AddIPV4('10.54.250.110/25',ipmp_nfs);
  AddIPV4('10.54.250.210/25',ipmp_nfs);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'fssued01_ipmp_drs','mgmt');
  AddIPV4('10.54.240.110/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:4c:0e:f8','generic');
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_0',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:07:2b:4d','mgmt');
  AddIPV4('10.54.250.111/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:d4:df:88','mgmt');
  AddIPV4('10.54.240.111/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:4c:0e:fc','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_1',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:f9:33:a6','mgmt');
  AddIPV4('10.54.250.117/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:79:a7:79','mgmt');
  AddIPV4('10.54.240.112/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:47:6c:c8','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicnfs0_2',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:f0:43:f8','mgmt');
  AddIPV4('10.54.250.211/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:1d:4a:18','mgmt');
  AddIPV4('10.54.240.113/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:47:6c:cc','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'vnicnfs0_3',zone_id,link_id,0,1595,ipmp_nfs,'02:08:20:e0:93:1f','mgmt');
  AddIPV4('10.54.250.217/25',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:73:8d:b0','mgmt');
  AddIPV4('10.54.240.114/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:c7:d8','mgmt');
  AddIPV4('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:c7:d9','mgmt');
  AddIPV4('',link_id);


  dc_id := CreateDC('RZ DRS');
  host_id  := CreateHost('DRS',dc_id,'00:25:90:8a:c3:2e');
  pool_id  := CreatePool('drsdisk',host_id);
  pool_id  := CreatePool('rpool',host_id);
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  ipmp_drs := AddDatalink(TFRE_DB_DATALINK_IPMP.ClassName,'drs0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'drs_ipmp_drs','mgmt');
  AddIPV4('10.54.240.198/24',ipmp_drs);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce0',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:34:e2:7a','generic');
  oce0_id  := link_id;
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_0',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:7f:ff:0f','mgmt');
  AddIPV4('10.54.240.199/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce1',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:34:e2:7e','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_1',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:5a:12:aa','mgmt');
  AddIPV4('10.54.240.200/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce2',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:34:e2:e2','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_2',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:8e:fc:83','mgmt');
  AddIPV4('10.54.240.201/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'oce3',zone_id,CFRE_DB_NullGUID,9000,0,CFRE_DB_NullGUID,'00:90:fa:34:e2:e6','generic');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vnicdrs0_3',zone_id,link_id,0,1594,ipmp_drs,'02:08:20:21:06:ef','mgmt');
  AddIPV4('10.54.240.202/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:c3:2e','mgmt');
  AddIPV4('10.54.3.198/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'ixgbe1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:25:90:8a:c3:2f','mgmt');
  AddRoutingIPV4('default','10.54.3.252',zone_id,'Default Route');

  dc_id := CreateDC('RZ Test');
  host_id  := CreateHost('Fosdev',dc_id,'00:0c:29:71:65:fd');
  zone_id  := CreateZone('global',host_id,host_id,gz_template_id);
  pool_id  := CreatePool('syspool',host_id);
  ds_id    := CreateDataset('syspool',pool_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'e1000g0',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:0c:29:71:65:fd','generic');
  AddIPV4('10.1.0.84/24',link_id);
  AddIPV4('172.22.0.99/24',link_id);
  AddIPV6('fdd7:f47b:4605:705:3:0:1:1/80',link_id);
  e0_id    := link_id;
  AddRoutingIPV4('default','10.1.0.1',zone_id,'Default Route');

  link_id  := AddDatalink(TFRE_DB_DATALINK_PHYS.ClassName,'e1000g1',zone_id,CFRE_DB_NullGUID,1500,0,CFRE_DB_NullGUID,'00:0c:29:71:65:07','generic');
  AddIPV4('172.22.0.99/24',link_id);
  e1_id    := link_id;

  g_domain_id := CheckFindDomainID('DEMO');
  zone_id  := CreateZone('demo',ds_id,host_id,template_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'cpe0',zone_id,e1_id,0,1699,CFRE_DB_NullGUID,'02:08:20:a4:c6:7c','cpe','Crypto CPE');
  AddIPV6('',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'inet0',zone_id,e0_id,0,1588,CFRE_DB_NullGUID,'02:08:20:e7:40:51','internet','Internet');
  AddIPV4('91.143.108.194/27',link_id);
  AddRoutingIPV4('default','91.143.108.193',zone_id,'Default Route');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'mgmt0',zone_id,e0_id,0,0,CFRE_DB_NullGUID,'02:08:20:d3:59:df','mgmt','Mgmt Lan');
  AddIPV4('172.24.1.2/16',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'lan0',zone_id,e0_id,0,1589,CFRE_DB_NullGUID,'02:08:20:3a:4c:16','lan','Lan');
  AddIPV4('192.168.3.1/24',link_id);
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm0',zone_id,e1_id,0,1589,CFRE_DB_NullGUID,'02:08:20:52:58:69','vm','VM 0');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'vm1',zone_id,e1_id,0,1589,CFRE_DB_NullGUID,'02:08:20:2d:18:0a','vm','VM 1');
  link_id  := AddDatalink(TFRE_DB_DATALINK_VNIC.ClassName,'znfs0',zone_id,e0_id,0,2000,CFRE_DB_NullGUID,'02:08:20:a7:7b:de','mgmt','Global NFS');
  AddIPV4('172.22.1.2/16',link_id);
  vf_id:=CreateVFiler(zone_id,'Test Virtual Fileserver');
  CreateShare(vf_id,pool_id,'syspool/domains/demo/demo/zonedata/vfiler/sales','Sales',10240,10240);
  CreateShare(vf_id,pool_id,'syspool/domains/demo/demo/zonedata/vfiler/development','Development',10240,10240);
  CreateShare(vf_id,pool_id,'syspool/domains/demo/demo/zonedata/vfiler/management','Management',10240,10240);
  vf_id:=CreateCFiler(zone_id,'Test Crypto Fileserver');
  CreateShare(vf_id,pool_id,'syspool/domains/mydomain/newzone0/zonedata/secfiler/securefiles','SecureFiles',10240,10240);



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

