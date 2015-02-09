unit fos_firmboxfeed_client;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2013, FirmOS Business Solutions GmbH
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
{$codepage UTF8}
{$modeswitch nestedprocvars}



interface

uses
  Classes, SysUtils,fre_base_client,FOS_TOOL_INTERFACES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,FOS_VM_CONTROL_INTERFACE,
  fre_system,fos_stats_control_interface, fre_hal_disk_enclosure_pool_mangement,fre_dbbase,fre_zfs,fre_scsi,fre_hal_schemes,fre_dbbusiness,
  fre_diff_transport,fre_process,fre_mysql_ll,sqldb
  {$IFDEF SOLARIS}
  ,fosillu_hal_zonectrl,fosillu_hal_dbo_common,fosillu_libzonecfg,fosillu_hal_svcctrl
  {$ENDIF}
  ;


type


  { TFRE_BOX_FEED_CLIENT }

  TFRE_BOX_FEED_CLIENT=class(TFRE_BASE_CLIENT)
  private
    FEED_Timer            : IFRE_APSC_TIMER;
    FVM_Feeding           : Boolean;
    FDISK_Feeding         : Boolean;
    FAPP_Feeding          : Boolean;
    FStorage_Feeding      : Boolean;
    FVM_FeedAppClass      : TFRE_DB_String;
    FVM_FeedAppUid        : TFRE_DB_Guid;
    FADCAdmin_FeedAppClass: TFRE_DB_String;
    FADCAdmin_FeedAppUid  : TFRE_DB_Guid;
    FAPPL_FeedAppClass    : TFRE_DB_String;
    FAPPL_FeedAppUid      : TFRE_DB_Guid;
    vmc                   : IFOS_VM_HOST_CONTROL; // Todo Move MVStats to Statscontroller
    statscontroller       : IFOS_STATS_CONTROL;
    disk_hal              : TFRE_HAL_DISK_ENCLOSURE_POOL_MANAGEMENT;
    mysqlconnection       : TSQLConnection;
    mysqltransaction      : TSQLTransaction;
    servicedata_lock      : IFOS_LOCK;
    servicedata           : IFRE_DB_Object;
    live_all              : IFRE_DB_Object;
    liveupdate_lock       : IFOS_LOCK;
    service_coll_assign   : IFRE_DB_Object;


  private
    procedure  CCB_RequestDiskEncPoolData  (const DATA : IFRE_DB_Object ; const status:TFRE_DB_COMMAND_STATUS ; const error_txt:string);
    procedure  CCB_RequestServiceStructure (const DATA : IFRE_DB_Object ; const status:TFRE_DB_COMMAND_STATUS ; const error_txt:string);
    procedure  CCB_SendStructureUpdate     (const DATA : IFRE_DB_Object ; const status:TFRE_DB_COMMAND_STATUS ; const error_txt:string);
    function   _VoipEntryCmd               (const cmd     : string; const input : IFRE_DB_Object) : IFRE_DB_Object;
    procedure  _MatchLinkStats             (const data : IFRE_DB_Object);
    procedure  UpdateandSendZoneData;
    procedure  TestzoneEnum;
    procedure  TestSvcZone;
  public
    procedure  MySessionEstablished    (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  MySessionDisconnected   (const chanman : IFRE_APSC_CHANNEL_MANAGER); override;
    procedure  QueryUserPass           (out user, pass: string); override;
    procedure  MyInitialize            ; override;
    procedure  MyRegisterClasses       ; override;
    procedure  MyFinalize              ; override;
    procedure  MyConnectionTimer       ; override;
    procedure  GenerateFeedDataTimer   (const TIM : IFRE_APSC_TIMER ; const flag1,flag2 : boolean); // Timout & CMD Arrived & Answer Arrived
    procedure  SubfeederEvent          (const id:string; const dbo:IFRE_DB_Object);override;
  published
    procedure  REM_BROWSEPATH          (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_UPDATEBANDWIDTH     (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_UPDATEDSQUOTA       (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_UPDATEVOIPENTRY     (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_DELETEVOIPENTRY     (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_INSERTVOIPENTRY     (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_STARTVM             (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_STOPVM              (const command_id : Qword ; const input : IFRE_DB_Object ; const cmd_type : TFRE_DB_COMMANDTYPE);
    procedure  REM_REQUESTDISKDATA     (const command_id : Qword ; const input: IFRE_DB_Object  ; const cmd_type : TFRE_DB_COMMANDTYPE);

  end;


implementation



procedure TFRE_BOX_FEED_CLIENT.CCB_RequestDiskEncPoolData(const DATA: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const error_txt: string);
begin
  GFRE_DBI.LogNotice(dblc_FLEXCOM,'CCB_RequestDiskEncPoolData '+ inttostr(Ord(status)));
  case status of
    cdcs_OK: begin
      disk_hal.ServerDiskEncPoolDataAnswer(data);
      FStorage_Feeding   := True;
    end;
    cdcs_TIMEOUT: ;
    cdcs_ERROR: begin
       GFRE_BT.CriticalAbort('Request DiskEncPoolData Error - Server Returned Error: '+error_txt);
    end;
  end;
end;

procedure TFRE_BOX_FEED_CLIENT.CCB_RequestServiceStructure(const DATA: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS; const error_txt: string);
begin
  GFRE_DBI.LogNotice(dblc_FLEXCOM,'CCB_RequestServiceStructure '+ inttostr(Ord(status)));
  case status of
    cdcs_OK: begin
//      writeln('SWL SERVICE DATA STRUCTURE', data.DumpToString);
      servicedata_lock.Acquire;
      try
        servicedata := data.CloneToNewObject();
      finally
        servicedata_lock.Release;
      end;
    end;
    cdcs_TIMEOUT: ;
    cdcs_ERROR: begin
       GFRE_BT.CriticalAbort('RequestServiceStructure Error - Server Returned Error: '+error_txt);
    end;
  end;
end;

procedure TFRE_BOX_FEED_CLIENT.CCB_SendStructureUpdate(const DATA: IFRE_DB_Object; const status: TFRE_DB_COMMAND_STATUS;const error_txt: string);
var machineUIDS:TFRE_DB_GUIDArray;
begin
  if status<>cdcs_OK then
    begin
      writeln('CCB STRUCTURE UPDATE STATUS',data.DumpToString(),' STATUS:',status,' ERROR:',error_txt);
      machineUIDS:=GetMyMachineUIDs;
      SendServerCommand('TFRE_DB_MACHINE','REQUEST_SERVICE_STRUCTURE',TFRE_DB_GUIDArray.Create(machineUIDS[0]),nil,@CCB_RequestServiceStructure);
    end;
end;

function TFRE_BOX_FEED_CLIENT._VoipEntryCmd(const cmd: string; const input: IFRE_DB_Object): IFRE_DB_Object;
var
    q         : TSQLQuery;
    extension : IFRE_DB_Object;
    serviceObj: IFRE_DB_Object;
    telephone : IFRE_DB_Object;

    function getKNDR(const extension,serviceObj: IFRE_DB_Object):TFRE_DB_String;
    begin
      Result:='0'+serviceObj.Field('national_prefix').AsString + serviceObj.Field('number').AsString;
    end;

    function getUSER(const extension,serviceObj: IFRE_DB_Object):TFRE_DB_String;
    begin
      Result:=getKNDR(extension,serviceObj) + extension.Field('number').AsString;
    end;

    function _refreshdb(const q:TSQLQuery;const kndr:string):integer;
    var p           : TFRE_Process;
        outstring   : string;
        errorstring : string;
    begin
      q.sql.text:='INSERT INTO `transfer` (`asterisk`, `kunde`, `cmd`, `param`, stamp) VALUES '+
                  '(19, :kdnr, ''UPDATE-DIALPLAN'', :kdnr, now()),'+
                  '(19, :kdnr, ''UPDATE-EXTENSIONS'', :kdnr, now()),'+
                  '(19, :kdnr, ''UPDATE-PHONES'', :kdnr, now()),'+
                  '(19, :kdnr, ''EXTENSIONS-RELOAD'',:kdnr, now()),'+
                  '(19, :kdnr, ''SIP-RELOAD'', :kdnr, now()),'+
                  '(1001,:kdnr, ''UPDATE-DHCP'', :kdnr, now()),'+
                  '(1001,:kdnr, ''DHCP-RELOAD'', :kdnr, now());';
      q.ParamByName('kdnr').AsString  := kndr;
      q.ExecSQL;
      p := TFRE_Process.Create(nil);
      try
        result :=p.ExecutePiped('nc',TFRE_DB_StringArray.Create('192.168.82.3','29000'),'UPDATE',outstring,errorstring);
      finally
        p.free;
      end;
      p := TFRE_Process.Create(nil);
      try
        result :=p.ExecutePiped('nc',TFRE_DB_StringArray.Create('192.168.82.2','29000'),'UPDATE',outstring,errorstring);
      finally
        p.free;
      end;
    end;

begin
  result := GFRE_DBI.NewObject;
  extension := input.Field('extension').AsObject;
  serviceObj:= input.Field('serviceObj').AsObject;
  if (cmd='UPDATEVOIPENTRY') or (cmd='INSERTVOIPENTRY') then
    telephone := input.Field('telephone').asObject;

    //procedure _DumpData(const extNumber:TFRE_DB_String; const extension,serviceObj,telephone: IFRE_DB_Object);
    //
    //
    //begin
    //  writeln('KNDR: ' + getKNDR(extension,serviceObj));
    //  writeln('USER: ' + getUSER(extension,serviceObj));
    //  if extNumber<>'' then begin
    //    writeln('USER OLD:' + getKNDR(extension,serviceObj) + extNumber);
    //  end else begin
    //    writeln('USER OLD: new Extension');
    //  end;
    //  writeln('PWD: ' + extension.Field('password').AsString);
    //  writeln('TEL: ' + telephone.Field('sqlId').AsString);
    //  if extension.Field('provisioning').AsBoolean then begin
    //    writeln('AUTOPROV_PROFIL: 1');
    //  end else begin
    //    writeln('AUTOPROV_PROFIL: 0');
    //  end;
    //  writeln('NSTREIN: ' + extension.Field('number').AsString);
    //  writeln('NSTRAUS: ' + extension.Field('number').AsString);
    //  writeln('CLIDNAME: ' + extension.Field('objname').AsString);
    //  writeln('DEFAULTIP: ' + extension.Field('ip').AsString);
    //  writeln('MAC: ' + extension.Field('mac').AsString);
    //  if extension.Field('recording').AsBoolean then begin
    //    writeln('DARFAUZEICHNEN: J');
    //  end else begin
    //    writeln('DARFAUZEICHNEN: N');
    //  end;
    //end;

  Q:=TSQLQuery.Create(mysqlconnection);
  try
    try
      Q.Database:=mysqlconnection;
      Q.Transaction:=mysqltransaction;
      if (cmd='UPDATEVOIPENTRY') or (cmd='INSERTVOIPENTRY') then
        begin
          if (cmd='UPDATEVOIPENTRY') then
            begin
              q.SQL.text :='update nebenstellen set kdnr=:kdnr,user=:user,pwd=:pwd,geraet=:geraet,autoprov_profil=:autoprov_profil,nstrein=:nstrein, nstraus=:nstraus, zurclid=:zurclid, amtsruf=:amtsruf,ausland=:ausland,'+
                           'sperrklassen=:sperrklassen, clidname=:clidname,rufgruppe=:rufgruppe,laeutzeit=:laeutzeit,`laeutzeit-nacht`=:laeutzeitnacht,`laeutzeit-intern`=:laeutzeitintern,name=:name,defaultip=:defaultip,mac=:mac,'+
                           'darfaufzeichnen=:darfaufzeichnen,vmpin=:vmpin,`vm-standardtext`=:vmstandardtext, email=:email where user=:old_user';
              q.Prepare;
              q.ParamByName('old_user').AsString:= getKNDR(extension,serviceObj) + input.Field('extnumber').asstring;
            end
          else
            begin
              q.SQL.text :='INSERT INTO `nebenstellen` (`kdnr`, `user`, `pwd`, `geraet`, `autoprov_profil`, `nstrein`, `nstraus`, `zurclid`, `amtsruf`, `ausland`, `sperrklassen`, `clidname`, `rufgruppe`, `laeutzeit`, `laeutzeit-nacht`,'+
                           '`laeutzeit-intern`, `name`, `defaultip`, `mac`, `darfaufzeichnen`, `vmpin`, `vm-standardtext`, `email`) VALUES ('+
                           ':kdnr, :user, :pwd, :geraet, :autoprov_profil, :nstrein, :nstraus, :zurclid, :amtsruf, :ausland, :sperrklassen, :clidname, :rufgruppe, :laeutzeit, :laeutzeitnacht,'+
                           ':laeutzeitintern, :name, :defaultip, :mac, :darfaufzeichnen, :vmpin, :vmstandardtext, :email);';
              q.Prepare;
            end;
          q.ParamByName('kdnr').AsString  := getKNDR(extension,serviceObj);
          q.ParamByName('user').AsString  := getUser(extension,serviceObj);
          q.ParamByName('pwd').AsString    := extension.Field('password').AsString;
          if telephone.Field('sqlID').AsString = '' then
            begin
              q.ParamByName('autoprov_profil').AsString := '4';
              q.ParamByName('geraet').AsString    := '10';
            end
          else
            begin
              q.ParamByName('autoprov_profil').AsString := '5';
              q.ParamByName('geraet').AsString    := telephone.Field('sqlID').AsString;
            end;

          q.ParamByName('nstrein').AsString   := extension.Field('number').AsString;
          q.ParamByName('nstraus').AsString   := extension.Field('number').AsString;
          q.ParamByName('zurclid').AsString   := '1';
          q.ParamByName('amtsruf').AsString   := '1';
          q.ParamByName('ausland').AsString   := '1';
          q.ParamByName('sperrklassen').AsString   := '';
          q.ParamByName('clidname').AsString   := extension.Field('objname').AsString;
          q.ParamByName('rufgruppe').AsString   := '1';
          q.ParamByName('laeutzeit').AsString   := '30';
          q.ParamByName('laeutzeitnacht').AsString   := '15';
          q.ParamByName('laeutzeitintern').AsString   := '30';
          q.ParamByName('name').AsString   := '';
          q.ParamByName('defaultip').AsString   := extension.Field('ip').AsString;
          q.ParamByName('mac').AsString   := extension.Field('mac').AsString;
          if extension.Field('recording').AsBoolean then begin
            q.ParamByName('darfaufzeichnen').AsString   := 'J';
          end else begin
            q.ParamByName('darfaufzeichnen').AsString   := 'N';
          end;
          q.ParamByName('vmpin').AsString   := '1234';
          q.ParamByName('vmstandardtext').AsString   := 'J';
          q.ParamByName('email').AsString   := 'dummy@spamdump.com';
          q.ExecSQL;
          writeln('QRY DONE');
          result.Field('resultcode').AsInt32 :=_refreshdb(q,getKNDR(extension,serviceObj));
          writeln('TRANSFER QRY DONE');
        end;
      if (cmd='DELETEVOIPENTRY')  then
        begin
          q.SQL.text :='DELETE FROM `nebenstellen`  where `kdnr`=:kdnr and `user`=:user;';
          q.Prepare;
          q.ParamByName('kdnr').AsString  := getKNDR(extension,serviceObj);
          q.ParamByName('user').AsString  := getUser(extension,serviceObj);
          q.ExecSQL;
          writeln('DELETE QRY DONE');
          result.Field('resultcode').AsInt32 :=_refreshdb(q,getKNDR(extension,serviceObj));
          writeln('TRANSFER QRY DONE');
        end;
    except on e:Exception do
      begin
        result.Field('EXCEPTION').asstring:=E.Message;
      end;
    end;
  finally
    q.free;
  end;
end;

procedure TFRE_BOX_FEED_CLIENT._MatchLinkStats(const data: IFRE_DB_Object);
var i     : integer;
    iobj  : IFRE_DB_Object;
    dobj  : IFRE_DB_Object;
    zone  : IFRE_DB_Object;
    iname : string;

    procedure _zoneIterator(const obj: IFRE_DB_Object);
//    procedure _zoneIterator(const obj: IFRE_DB_Object; var halt:boolean);

      //procedure CalcDifferences;
      //begin
      //  if zone.Field('objname').asstring)='demo' then   //DEBUG CODE
      //    begin
      //
      //    end;
      //end;

    begin
//      halt := false;
//      writeln('SWL ',obj.Field('objname').asstring);
      if obj.Field('objname').asstring=iname then
        begin
//          halt := true;
//          if obj.FieldExists('oldstat') then
//            CalcDifferences;
          writeln('SWL SENDSTAT FOR DATALINK ',obj.UID_String,' ',dobj.DumpToString());  //TODO SENDSTAT
          obj.Field('oldstat').asobject := dobj.CloneToNewObject;
        end;
    end;

begin
  servicedata_lock.Acquire;
  try
    writeln('SWL MACHINE LINK STATS');
    for i:=0 to data.Field('DATA').ValueCount-1 do
      begin
        iobj := data.Field('DATA').AsObjectItem[i];
        dobj := iobj.Field('DATA').asobject;
        iname := iobj.Field('name').asstring;
        if (Pos('z',iname)=1)  and (Pos('_',iname)>0) then
          iname := Copy(iname,Pos('_',iname)+1,maxint);
        writeln('SWL INTERFACE NAME',iname,' ',dobj.Field('zonename').asstring);
        if servicedata.FetchObjWithStringFieldValue('OBJNAME',dobj.Field('zonename').asstring,zone,TFRE_DB_ZONE.ClassName) then
          begin
            writeln('SWL ZONE FOUND', zone.Field('objname').asstring);
//            if zone.Field('objname').asstring='demo' then
//              writeln('SWL ZONE',zone.DumpToString());
            zone.ForAllObjects(@_zoneIterator);
          end;
      end;
  finally
    servicedata_lock.Release;
  end;
end;

procedure TFRE_BOX_FEED_CLIENT.UpdateandSendZoneData;
var ndata          : IFRE_DB_Object;
    zdata          : IFRE_DB_Object;
    zoneguid       : TFRE_DB_GUID;
    transport_list : IFRE_DB_Object;

    procedure UpdateZones(const obj:IFRE_DB_Object);
    var structzone: TFRE_DB_ZONE;
        sobj      : IFRE_DB_Object;
        zname     : string;
        zplugin   : TFRE_DB_ZONESTATUS_PLUGIN;
    begin
      zname := obj.Field('zname').asstring;
      if zname='global' then
        begin
          //FIXXME handle global
          exit;
        end
      else
        begin
          try
            zoneguid.SetFromHexString(zname);
            if ndata.FetchObjByUID(zoneguid,sobj)=false then
              raise Exception.Create('ZONE '+zname+' NOT IN SERVICE STRUCTURE');
          except
            writeln('SKIP UNDEFINED ZONE ',zname);
            exit;
          end;
        end;
      if sobj.IsA(TFRE_DB_ZONE,structzone) then
        begin
          Writeln('SWL ZONE FOUND '+structzone.UID_String);
          // update zonestatus plugin
          if not structzone.HasPlugin(TFRE_DB_ZONESTATUS_PLUGIN,zplugin) then
            begin
              zplugin := TFRE_DB_ZONESTATUS_PLUGIN.Create;
              structzone.AttachPlugin(zplugin);
            end;
          zplugin.SetZoneID(obj.Field('zid').AsInt64);
          zplugin.SetZoneState(obj.Field('zstate').asstring,obj.Field('zstate_num').AsUInt32);
          // error, valid, brand
          structzone.Field('error').AsString  := obj.Field('error').asstring;
          structzone.Field('valid').AsBoolean := obj.Field('valid').asboolean;
          structzone.Field('zbrand').AsString := obj.Field('zbrand').asstring;
          structzone.Field('zuuid').AsString  := obj.Field('zuuid').asstring;
//          writeln('SWL ZONE UPDATED ',structzone.DumpToString);
        end
      else
        raise Exception.Create('UID '+zoneguid.AsHexString+' IS NOT A ZONE IN THE SERVICE STRUCTURE');
    end;

    procedure ResetZoneState(const obj:IFRE_DB_Object;var haltit:boolean);
    var structzone: TFRE_DB_ZONE;
        zplugin   : TFRE_DB_ZONESTATUS_PLUGIN;
    begin
      haltit :=false;
      if obj.isa(TFRE_DB_GLOBAL_ZONE) then
        exit;
      if obj.IsA(TFRE_DB_ZONE,structzone) then
        begin
          writeln('SWL RESET ZONESTATE',structzone.UID_String);
          if not structzone.HasPlugin(TFRE_DB_ZONESTATUS_PLUGIN,zplugin) then
            begin
              zplugin := TFRE_DB_ZONESTATUS_PLUGIN.Create;
              structzone.AttachPlugin(zplugin);
            end;
          zplugin.SetZoneID(-1);
          zplugin.SetZoneState('planned',-1);
        end;
    end;

begin
{$IFDEF SOLARIS}
  servicedata_lock.Acquire;
  try

    transport_list := GFRE_DBI.NewObject;
    ndata          := servicedata.CloneToNewObject;


    zdata := fre_list_all_zones;

    ndata.ForAllObjectsBreakHierarchic(@ResetZoneState);

    zdata.ForAllObjects(@UpdateZones);

    FREDIFF_GenerateRelationalDiffContainersandAddToBulkObject(ndata,servicedata,service_coll_assign,transport_list,true);


    if FREDIFF_ChangesGenerated(transport_list) then
      begin
        writeln('SWL ZONE TRANSPORT',transport_list.DumpToString);
        //writeln('SWL SDATA',servicedata.DumpToString());
        //writeln('SWL NDATA',ndata.DumpToString());
        SendServerCommand(FADCAdmin_FeedAppClass,'DATA_FEED',TFRE_DB_GUIDArray.Create(FADCAdmin_FeedAppUid),transport_list,@CCB_SendStructureUpdate);
      end
    else
      transport_list.Finalize;

    servicedata.Finalize;
    servicedata:=ndata;
  finally
    servicedata_lock.Release;
  end;
{$ENDIF}
end;

procedure TFRE_BOX_FEED_CLIENT.TestzoneEnum;
var obj   : IFRE_DB_Object;
begin
  {$IFDEF SOLARIS}
  obj := fre_list_all_zones;
  writeln('SWL ZONE LIST',obj.DumpToString);
  {$ENDIF}

  abort;
end;

procedure TFRE_BOX_FEED_CLIENT.TestSvcZone;
begin
  {$IFDEF SOLARIS}
  fre_enable_or_disable_service('fos/fos_vm_bc82f561c6bbda065fb4216850f29e3f',true,'15a56c904a7f00248929bfdb576a45c9');
  {$ENDIF}
  abort;
end;

procedure TFRE_BOX_FEED_CLIENT.MySessionEstablished(const chanman: IFRE_APSC_CHANNEL_MANAGER);
var i           : integer;
    machineUIDS : TFRE_DB_GUIDArray;
    dummydata   : IFRE_DB_Object;
begin
  inherited;

  if Get_AppClassAndUid('TFRE_FIRMBOX_APPLIANCE_APP',FAPPL_FeedAppClass,FAPPL_FeedAppUid) then begin
//    FAPP_Feeding := True;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_APPLIANCE_APP APP NOT FOUND!');
  end;
  if Get_AppClassAndUid('TFRE_FIRMBOX_VM_APP',FVM_FeedAppClass,FVM_FeedAppUid) then begin
//    FVM_Feeding   := True;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_VM_APP APP NOT FOUND!');
  end;

  if Get_AppClassAndUid('TFOS_CITYCOM_ADC_ADMIN_APP',FADCAdmin_FeedAppClass,FADCAdmin_FeedAppUid) then begin
    disk_hal.ResetToUnInitialized;
    machineUIDS := GetMyMachineUIDs;
    for i:=0 to high(machineUIDS) do begin
      GFRE_DBI.LogNotice(dblc_FLEXCOM,'SENDING REQUEST FOR MACHINE REQUEST_DISK_ENC_POOL_DATA '+FREDB_G2H(machineUIDS[i]));
      SendServerCommand('TFRE_DB_MACHINE','REQUEST_DISK_ENC_POOL_DATA',TFRE_DB_GUIDArray.Create(machineUIDS[i]),nil,@CCB_RequestDiskEncPoolData);
      SendServerCommand('TFRE_DB_MACHINE','REQUEST_SERVICE_STRUCTURE',TFRE_DB_GUIDArray.Create(machineUIDS[i]),nil,@CCB_RequestServiceStructure);
    end;
  end else begin
    GFRE_DBI.LogError(dblc_FLEXCOM,'FEEDING NOT POSSIBLE, TFRE_FIRMBOX_STORAGE_APP APP NOT FOUND!');
  end;


  FEED_Timer := chanman.AddChannelManagerTimer('FEED_'+chanman.GetID,30000,@GenerateFeedDataTimer,true); // Beside the "normal 1 sec" Timer a 5 sec timer in the channel context
  writeln('Generated Feedtimer ',FEED_Timer.cs_GetID);
end;

procedure TFRE_BOX_FEED_CLIENT.MySessionDisconnected(const chanman: IFRE_APSC_CHANNEL_MANAGER);
begin
  writeln('FINALIZING FEED FROM CM_'+chanman.GetID);
  FEED_Timer.cs_Finalize;
  FVM_Feeding   := false;
  FDISK_Feeding := false;
  FAPP_Feeding  := false;
  FStorage_Feeding:= false;
  inherited;
end;

procedure TFRE_BOX_FEED_CLIENT.QueryUserPass(out user, pass: string);
begin
  user := cFRE_Feed_User;
  pass := cFRE_Feed_Pass;
end;

procedure TFRE_BOX_FEED_CLIENT.MyInitialize;
var q : TSQLQuery;
begin
//  FEED_Timer      := GFRE_S.AddPeriodicTimer (1000,@GenerateFeedDataTimer);
//  FEED_Timer30    := GFRE_S.AddPeriodicTimer (30000,@GenerateFeedDataTimer30);
  //vmc             := Get_VM_Host_Control     (cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  //vmc.VM_EnableVMMonitor                     (true);

  //statscontroller := Get_Stats_Control       (cFRE_REMOTE_USER,cFRE_REMOTE_HOST);
  //statscontroller.StartCPUParser(true);
  //statscontroller.StartRAMParser(true);
  //statscontroller.StartNetworkParser(true);
  //statscontroller.StartCacheParser(true);
  //statscontroller.StartZFSParser(true);

  AddJobTransportCollectionAssignment(TFRE_DB_ZONE.ClassName,'');    // skip zones in transfer


  {$IFDEF SOLARIS}
  InitIllumosLibraryHandles;
  {$ENDIF}

//  TestzoneEnum;
//  TestSvcZone;

  GFRE_TF.Get_Lock(liveupdate_lock);
  live_all := GFRE_DBI.NewObject;
  GFRE_TF.Get_Lock(servicedata_lock);
  servicedata:=GFRE_DBI.NewObject;

  service_coll_assign:=GFRE_DBI.NewObject;
  service_coll_assign.Field(TFRE_DB_ZONE.ClassName).asstring:=CFOS_DB_ZONES_COLLECTION;

  disk_hal   := TFRE_HAL_DISK_ENCLOSURE_POOL_MANAGEMENT.Create;

  if cFRE_SUBFEEDER_IP='' then
    AddSubFeederEventViaUX('disksub')
  else
    AddSubFeederEventViaTCP(cFRE_SUBFEEDER_IP,'44101','disksub');

  //mysqlconnection:=TFOSMySqlConn.Create(nil);
  //mysqlconnection.UserName:='firmos';
  //mysqlconnection.Password:='kmuRZ2013$';
  //mysqlconnection.DatabaseName:='asterisk';
  //mysqlconnection.HostName:='192.168.82.3';
  //mysqltransaction:=TSQLTransaction.Create(mysqlconnection);
  //mysqltransaction.Database:=mysqlconnection;
  //writeln('TRY CONNECT DB');
  //mysqlconnection.Connected:=True;
  //writeln('CONNECTED DB');
  //Q:=TSQLQuery.Create(mysqlconnection);
  //try
  //  Q.Database:=mysqlconnection;
  //  Q.Transaction:=mysqltransaction;
  //  q.sql.Text := 'SET CHARACTER SET `utf8`';
  //  q.ExecSQL;
  //  q.sql.Text := 'SET NAMES `utf8`';
  //  q.ExecSQL;
  //  writeln('OPEN QRY DONE');
  //finally
  //  q.free;
  //end;

end;

procedure TFRE_BOX_FEED_CLIENT.MyRegisterClasses;
begin
  fre_dbbase.Register_DB_Extensions;
  fre_dbbusiness.Register_DB_Extensions;
  fre_ZFS.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fre_scsi.Register_DB_Extensions;

  RegisterSupportedRifClass(TFRE_DB_ZONECREATION_JOB);
  RegisterSupportedRifClass(TFRE_DB_ZONEDESTROY_JOB);
  RegisterSupportedRifClass(TFRE_DB_ZONE);
  RegisterSupportedRifClass(TFRE_DB_SERVICE);
  RegisterSupportedRifClass(TFRE_DB_VMACHINE);
  RegisterSupportedRifClass(TFRE_DB_FIREWALL_SERVICE);
end;

procedure TFRE_BOX_FEED_CLIENT.MyFinalize;
begin
  writeln('FEED CLIENT FINALIZE');
//  FEED_Timer.FinalizeIt;
//  FEED_Timer30.FinalizeIt;
  //vmc.Finalize ;

  service_coll_assign.Finalize;

  liveupdate_lock.Finalize;
  servicedata_lock.Finalize;
  servicedata.Finalize;

  disk_hal.Free;
  statscontroller.Finalize;

end;


var g_disc_delay : integer=0;

procedure TFRE_BOX_FEED_CLIENT.MyConnectionTimer;
var vmo         : IFRE_DB_Object;
    lio         : IFRE_DB_Object;
    update_data : IFRE_DB_Object;
begin
  inherited;
  //if FAPP_Feeding then
  //  begin
  //    try
  //      vmo := GFRE_DBI.NewObject;
  //      vmo.Field('LIVE STATUS FEED').AsString:='LSF_0.0.1';
  //      vmo.Field('TIMESTAMP').AsDateTimeUTC := GFRE_DT.Now_UTC;
  //      vmo.Field('CPU').AsObject := statscontroller.Get_CPU_Data;
  //      vmo.Field('VMSTAT').AsObject := statscontroller.Get_Ram_Data;
  //      vmo.Field('NET').AsObject := statscontroller.Get_Network_Data;
  //      vmo.Field('CACHE').AsObject := statscontroller.Get_CacheData;
  //      SendServerCommand(FAPPL_FeedAppClass,'RAW_DATA_FEED',TFRE_DB_GUIDArray.Create(FAPPL_FeedAppUid),vmo);
  //      //writeln('LIVEUPDATE SENT! ' , GFRE_DT.Now_UTC);
  //    except on e:exception do begin
  //      writeln('FEED EXCEPTION : ',e.Message);
  //    end;end;
  //  end;
  //if FDISK_Feeding then
  //  begin
  //    try
  //      vmo := GFRE_DBI.NewObject;
  //      vmo.Field('ZPOOLIO').AsObject := statscontroller.Get_ZpoolIostat_Data;
  //      SendServerCommand(FSTORAGE_FeedAppClass,'RAW_DISK_FEED',TFRE_DB_GUIDArray.Create(FSTORAGE_FeedAppUid),vmo);
  //      //writeln('DISK LIVEUPDATE SENT!');
  //    except on e:exception do begin
  //      writeln('SEND DISK FEED EXCEPTION : ',e.Message);
  //    end;end;
  //  end;
  //if FVM_Feeding then
  //  begin
  //    try
  //      SendServerCommand(FVM_FeedAppClass,'VM_FEED_UPDATE',TFRE_DB_GUIDArray.Create(FVM_FeedAppUid),vmc.Get_VM_Data);
  //      writeln('VM LIVEUPDATE SENT!');
  //    except on e:exception do begin
  //      writeln('VM LIVEUPDATE FEED EXCEPTION : ',e.Message);
  //    end;end;
  //  end;
  //
  if FStorage_Feeding then
    begin
      update_data:=disk_hal.GetUpdateDataAndTakeStatusSnaphot(cFRE_MACHINE_NAME);
      if  FREDIFF_ChangesGenerated(update_data) then
        begin
          SendServerCommand(FADCAdmin_FeedAppClass,'DATA_FEED',TFRE_DB_GUIDArray.Create(FADCAdmin_FeedAppUid),update_data,nil);
          writeln('DISK DATA_FEED SEND');
        end
      else
        update_data.Finalize;

      UpdateandSendZoneData;

      liveupdate_lock.Acquire;
      try
        lio:=live_all.CloneToNewObject;
      finally
        liveupdate_lock.Release;
      end;
      SendServerCommand('FIRMOS','UPDATELIVE',nil,lio);
    end;
end;

procedure TFRE_BOX_FEED_CLIENT.GenerateFeedDataTimer(const TIM: IFRE_APSC_TIMER; const flag1, flag2: boolean);
var vmo : IFRE_DB_Object;
begin
  if FAPP_Feeding then
    begin
      try
        vmo := GFRE_DBI.NewObject;
        vmo.Field('LIVE STATUS FEED 30').AsString:='LSF30_0.0.1';
        vmo.Field('ZFS').AsObject := statscontroller.Get_ZFS_Data_Once;
        SendServerCommand(FAPPL_FeedAppClass,'RAW_DATA_FEED30',TFRE_DB_GUIDArray.Create(FAPPL_FeedAppUid),vmo);
        //writeln('LIVEUPDATE (30) SENT! ' , GFRE_DT.Now_UTC);
      except on e:exception do begin
        writeln('FEED EXCEPTION : ',e.Message);
      end;end;
    end;
end;

procedure TFRE_BOX_FEED_CLIENT.SubfeederEvent(const id: string; const dbo: IFRE_DB_Object);
var subfeedmodule :string;

    procedure SendLiveStatCallback(const all_status_data: IFRE_DB_Object);
    begin
      liveupdate_lock.Acquire;
      try
        live_all.Field(all_status_data.Field('statuid').asGUID.AsHexString).AsObject:=all_status_data;
//        writeln('SWL SETTING LIVEDATA',live_all.DumpToString());
      finally
        liveupdate_lock.Release;
      end;
    end;


begin
  //var live,liveall : IFRE_DB_Object;
  //    disk_hal.ReceivedDBO(dbo);
  //    live    := GFRE_DBI.NewObject;
  //    liveall := GFRE_DBI.NewObject;
  //    live.Field('zpool_desc').AsString := 'SCRUBBING '+inttostr(random(100));
  //    liveall.Field('a35864a4d66063a6474f39ce5f27e9f9').AsObject:=live;
  //    SendServerCommand('FIRMOS','UPDATELIVE',nil,liveall);


  writeln('SUBFEEDER EVENT ID : ',id);
//  writeln(dbo.DumpToString());
  writeln('-----------------------------------------------------------------------------------------------------');
  subfeedmodule := dbo.Field('SUBFEED').asstring;
  if subfeedmodule = 'LINKSTAT' then
    begin
//      _MatchLinkStats(dbo);
//      writeln(dbo.DumpToString());
    end
  else
    disk_hal.ReceivedDBO(dbo,@SendLiveStatCallback);
end;


procedure TFRE_BOX_FEED_CLIENT.REM_BROWSEPATH(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var reply_data : IFRE_DB_Object;
    level      : string;

    function ListDirLevel(const basepath: string): IFRE_DB_Object;
    var Info  : TSearchRec;
        entry : TFRE_DB_FS_ENTRY;
        count : NativeInt;
    begin
      result := GFRE_DBI.NewObject;
      count  := 0;
      If FindFirst (basepath+'*',faAnyFile and faDirectory,Info)=0 then
        Repeat
          With Info do
            begin
              if (name='.') or (name='..') then
                Continue;
              entry := TFRE_DB_FS_ENTRY.CreateForDB;
              entry.SetProperties(name,(Attr and faDirectory) <> faDirectory,Size,mode,Time);
              result.Field(inttostr(count)).AsObject := entry;
              inc(count);
            end;
        Until FindNext(info)<>0;
      FindClose(Info);
    end;

begin
  level      := input.Field('level').AsString;
  {$IFDEF DARWIN }
  level :=  StringReplace(level,'/anord01disk/anord01ds/domains/demo/demo/zonedata/vfiler/development','/',[]);
  {$ENDIF}
  writeln('::: BROWSE - LEVEL ',level);
  reply_data := ListDirLevel(level);
  input.Finalize;
  AnswerSyncCommand(command_id,reply_data);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_UPDATEBANDWIDTH(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData  : IFRE_DB_Object;
    cmd        : string;
    errcode    : Integer;
begin
  writeln('CALLED REM_UPDATEBANDWIDTH');
  writeln(input.DumpToString());
  cmd := 'ssh -i /opt/local/fre/id_rsa_bw root@10.54.3.100 /root/setbandwidth '+input.FieldPath('BW').AsString;
  //writeln(cmd);
  errcode := FRE_ProcessCMD(cmd);
  writeln('resultcode ',errcode);
  input.Finalize;
  replyData := GFRE_DBI.NewObject;
  replyData.Field('resultcode').AsInt32 := errcode;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_UPDATEDSQUOTA(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData  : IFRE_DB_Object;
    cmd        : string;
    errcode    : Integer;

begin
  writeln('CALLED REM_UPDATEDSQUOTA');
  //writeln(input.DumpToString());

  cmd := 'zfs set quota='+input.FieldPath('SHARE.QUOTA_MB').AsString+'m '+input.FieldPath('SHARE.DATASET').AsString;
  //writeln(cmd);
  errcode := FRE_ProcessCMD(cmd);
  writeln('resultcode ',errcode);
  input.Finalize;
  replyData := GFRE_DBI.NewObject;
  replyData.Field('resultcode').AsInt32 := errcode;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_UPDATEVOIPENTRY(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData : IFRE_DB_Object;
begin
  writeln('CALLED REM_UPDATEVOIPENTRY');
  writeln(input.DumpToString());

  replyData := _VoipEntryCmd('UPDATEVOIPENTRY',input);

  input.Finalize;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_DELETEVOIPENTRY(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData : IFRE_DB_Object;
begin
  writeln('CALLED REM_DELETEVOIPENTRY');
  writeln(input.DumpToString());

  replyData := _VoipEntryCmd('DELETEVOIPENTRY',input);

  input.Finalize;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_INSERTVOIPENTRY(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData : IFRE_DB_Object;
begin
  writeln('CALLED REM_INSERTVOIPENTRY');
  writeln(input.DumpToString());

  replyData := _VoipEntryCmd('INSERTVOIPENTRY',input);

  input.Finalize;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_STARTVM(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData : IFRE_DB_Object;
begin
  writeln('CALLED REM_STARTVM');
  writeln(input.DumpToString());
  input.Finalize;
  replyData := GFRE_DBI.NewObject;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_STOPVM(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var replyData : IFRE_DB_Object;
begin
  writeln('CALLED REM_STOPVM');
  writeln(input.DumpToString());
  input.Finalize;
  replyData := GFRE_DBI.NewObject;
  AnswerSyncCommand(command_id,replyData);
end;

procedure TFRE_BOX_FEED_CLIENT.REM_REQUESTDISKDATA(const command_id: Qword; const input: IFRE_DB_Object; const cmd_type: TFRE_DB_COMMANDTYPE);
var   reply_Data  : IFRE_DB_Object;
begin
//  writeln('SWL: REQUESTING DISK DATA');
  reply_data := GFRE_DBI.NewObject;
  AnswerSyncCommand(command_id,reply_data);
end;

end.

