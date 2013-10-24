unit fre_base_server;

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
{$modeswitch nestedprocvars}

//TODO : EVENT - QUEUE DISPATCHING INTERINKTIMER ??? BAD DESIGN

interface

uses  classes, sysutils,fre_aps_interface,fos_fcom_interfaces,fos_fcom_types,fos_tool_interfaces,
      fre_http_srvhandler,fre_db_interface,fre_system,fos_interlocked,
      fre_db_core,fre_webssocket_baseserver,fre_db_common,
      fre_http_tools,fos_redblacktree_gen,fre_sys_base_cs,
      fre_wapp_dojo;

var cAdminUser:string='admin'+'@'+CFRE_DB_SYS_DOMAIN_NAME;
    cAdminPass:string='admin';
    cVersion  :string='0.1 alpha';

procedure RegisterLogin;

type
  { TFRE_BASE_SERVER }

  TFRE_DB_LOG_TYPE=(log_Warning,log_Error,log_INFO);

  TFRE_UserSession_Tree         = specialize TGFOS_RBTree<string,TFRE_DB_UserSession>;

  TFRE_BASE_SERVER=class(TObject,IFRE_APS_PROCESS,IFRE_HTTP_BASESERVER)
  private
    FOpenDatabaseList  : OFRE_DB_ConnectionArr;
    FUserSessionsTree  : TFRE_UserSession_Tree;  //TODO-> make array
    FDispatcher        : TFRE_HTTP_URL_DISPATCHER;
    FSessionTreeLock   : IFOS_LOCK;

    cont               : boolean;
    flistener_es       : IFRE_APS_SOCKET_EVENTSOURCE;
    flistener_es_ws    : IFRE_APS_SOCKET_EVENTSOURCE;

    FIL_ListenSock     : IFRE_APS_SOCKET_EVENTSOURCE;
    FIL_ListenSockSSL  : IFRE_APS_SOCKET_EVENTSOURCE;
    Foutput            : String;
    FLoginApp          : TFRE_DB_APPLICATION;
    FSystemConnection  : TFRE_DB_SYSTEM_CONNECTION;

    FWFE_Scheduler     : IFRE_APS_TIMER;
    FWFE_InTimer       : NativeInt;

    FDefaultSession           : TFRE_DB_UserSession;

    FHull_HTML,FHull_CT       : String;
    FTerminating              : boolean;

    procedure      _CloseAll                                 ;
    procedure      _SetupHttpBaseServer                      ;
    procedure      WFE_DispatchTimerEvent                    (const ES: IFRE_APS_EVENTSOURCE; const TID: integer; const Data: Pointer; const cp: integer);
    procedure      NewConnection                             (const session_id:string);
    procedure      ConnectionDropped                         (const session_id:string);
    procedure      BindInitialSession                        (const back_channel: IFRE_DB_COMMAND_REQUEST_ANSWER_SC ; out   session : TFRE_DB_UserSession;const old_session_id:string;const interactive_session:boolean);
    function       GetImpersonatedDatabaseConnection         (const dbname,username,pass:TFRE_DB_String ; out dbs:IFRE_DB_CONNECTION):TFRE_DB_Errortype;
    function       GetDBWithServerRights                     (const dbname:TFRE_DB_String ; out dbs:IFRE_DB_CONNECTION):TFRE_DB_Errortype;
    function       RestoreDefaultConnection                  (out  username : TFRE_DB_String ; out conn : IFRE_DB_CONNECTION):TFRE_DB_Errortype;
    function       GetImpersonatedDatabaseConnectionSession  (const dbname,username,pass,default_app : string;const default_uid_path : TFRE_DB_GUIDArray ; out dbs:TFRE_DB_UserSession):TFRE_DB_Errortype;
    function       ExistsUserSessionForUser                  (const username:string;out other_session:TFRE_DB_UserSession):boolean;
    function       ExistsUserSessionForKey                   (const key     :string;out other_session:TFRE_DB_UserSession):boolean;
    function       CheckUserNamePW                           (username,pass:TFRE_DB_String) : TFRE_DB_Errortype;
    function       FetchPublisherRAC                         (const rcall,rmeth:TFRE_DB_NameType;out rac:IFRE_DB_COMMAND_REQUEST_ANSWER_SC ; out right:TFRE_DB_String):boolean;
    function       FetchSessionById                          (const sesid : TFRE_DB_String ; var ses :IFRE_DB_UserSession):boolean;
  public
    DefaultDatabase              : String;
    TransFormFunc                : TFRE_DB_TRANSFORM_FUNCTION;

    HTTPWS_Listener              : IFRE_APSC_LISTENER;
    FLEX_Listener                : IFRE_APSC_LISTENER;

    constructor create           (const defaultdbname : string);
    destructor Destroy           ; override;
    procedure  Setup             ;
    procedure  Terminate         ;
    procedure  ReInit            ;
    procedure  Interrupt         ;
    function   GetName           : String;

    procedure Finalize              ;
    function  FetchFileCached       (file_path:String;var data:TFRE_DB_RawByteString):boolean;
    procedure FetchHullHTML         (var lContent:TFRE_DB_RawByteString;var lContentType:string);
    procedure DispatchHTTPRequest   (const connection_object:TObject;const uri:string ; const method: TFRE_HTTP_PARSER_REQUEST_METHOD);

    procedure APSC_NewListener      (const LISTENER : IFRE_APSC_LISTENER ; const state : TAPSC_ListenerState);
    procedure APSC_NewChannel       (const channel  : IFRE_APSC_CHANNEL  ; const state : TAPSC_ChannelState);
  end;


implementation

uses FRE_DB_LOGIN;
{ TFRE_BASE_SERVER }



procedure TFRE_BASE_SERVER._CloseAll;

  procedure StoreSessionData(const session:TFRE_DB_UserSession);
  begin
    GFRE_DBI.LogDebug(dblc_SERVER,'SERVER : FINALIZING SESSION : [%s] USER[%s]',[session.GetSessionID,session.GetUsername]);
    session.Free;
  end;

  function CloseAll(const dbc : TFRE_DB_CONNECTION):boolean;
  begin
    result := false;
    GFRE_DBI.LogDebug(dblc_SERVER,'FINALIZING DATBASE DBC [%s]',[dbc.ConnectedName]);
    dbc.Free;
  end;

begin
  GFRE_DBI.LogDebug(dblc_SERVER,'ENTER CLOSING SEQUENCE');
  FTerminating := true;
  FSessionTreeLock.Acquire;
  try
    FUserSessionsTree.ForAllItems(@StoreSessionData);
  finally
    FSessionTreeLock.Release;
  end;
  GFRE_DBI.LogDebug(dblc_SERVER,'DATABASE COUNT [%d]',[FOpenDatabaseList.Count]);
  FOpenDatabaseList.ForAllBrk(@CloseAll);
  FSystemConnection.Free;
  FSystemConnection:=nil;
  GFRE_DBI.LogDebug(dblc_SERVER,'SERVER SHUTDOWN DONE');
  writeln('Syncdb');
  GFRE_DB_DEFAULT_PS_LAYER.SyncSnapshot(true);
  writeln('Syncdb-done');
end;

procedure TFRE_BASE_SERVER._SetupHttpBaseServer;
var dummy:TFRE_WEBSOCKET_SERVERHANDLER_FIRMOS_VNC_PROXY;
begin
  FDispatcher  := TFRE_HTTP_URL_DISPATCHER.Create;
  FREDB_LoadMimetypes('');
//  FDispatcher.RegisterVirtualProvider('','rest/fre/',@dummy.FREDB_Provider);
  FDispatcher.RegisterDefaultProvider('',@dummy.Default_Provider);
  GFRE_tF.Get_Lock(G_SerializeLock);
end;

destructor TFRE_BASE_SERVER.Destroy;

  //procedure _CleanQ;
  //var sendback:TFRE_DB_SEND_BACK_DELAYED_ENCAPSULATION;
  //begin
  //  repeat
  //    sendback := TFRE_DB_SEND_BACK_DELAYED_ENCAPSULATION(FInterLinkQ.Pop);
  //  until sendback=nil;
  //end;

begin
  //if assigned(FInterLinkQ) then begin
  //  _CleanQ;
  //  FInterLinkQ := nil;
  //end;
  inherited Destroy;
end;

procedure TFRE_BASE_SERVER.Setup;

     procedure _ConnectAllDatabases;
     var i       : Integer;
         dblist  : IFOS_STRINGS;
         ndbc    : TFRE_DB_CONNECTION;
         dbname  : string;
         res     : TFRE_DB_Errortype;
         log_txt : string;
         app     : TFRE_DB_APPLICATION;
     begin
       dblist := GFRE_DB_DEFAULT_PS_LAYER.DatabaseList;
       GFRE_DB.LogInfo(dblc_SERVER,'START SERVING DATABASES [%s]',[dblist.Commatext]);
       FSystemConnection := GFRE_DB.NewDirectSysConnection;
       res := FSystemConnection.Connect(cAdminUser,cAdminPass);  // direct admin connect
       if res<>edb_OK then begin
         FSystemConnection.Free;
         FSystemConnection := nil;
         GFRE_DB.LogError(dblc_SERVER,'SERVING SYSTEM DATABASE failed due to [%s]',[CFRE_DB_Errortype[res]]);
         GFRE_BT.CriticalAbort('CANNOT SERVE SYSTEM DB [%s]',[CFRE_DB_Errortype[res]]);
       end;

       if not GFRE_DB.GetAppInstanceByClass(TFRE_DB_LOGIN,app) then
         GFRE_BT.CriticalAbort('cannot fetch login app');
       FLoginApp := app as TFRE_DB_LOGIN;
       if not assigned(FLoginApp) then begin
         GFRE_BT.CriticalAbort('could not preload login app / not found');
       end;
       GFRE_DB.LogInfo(dblc_SERVER,'>LOGIN APP DONE',[]);
       for i := 0 to dblist.Count-1 do begin
         dbname := Uppercase(dblist[i]);
         if dbname='SYSTEM' then begin
           ;
         end else begin
           //InfoLog(5,'CONNECTING [%s]',[dbname]);
           ndbc := GFRE_DB.NewConnection(true);
           res  := ndbc.Connect(dbname,cAdminUser,cAdminPass,FSystemConnection); // direct admin connect
           if res<>edb_OK then begin
             GFRE_DB.LogError(dblc_EXCEPTION,'SERVING DATABASE [%s] failed due to [%s]',[dbname,CFRE_DB_Errortype[res]]);
           end else begin
             //InfoLog(5,'CONNECTED [%s]',[dbname]);
             FOpenDatabaseList.Add2Array(ndbc);
           end;
         end;
       end;
       res := GetImpersonatedDatabaseConnectionSession(DefaultDatabase,'GUEST'+'@'+CFRE_DB_SYS_DOMAIN_NAME,'','TFRE_DB_LOGIN',GFRE_DB.ConstructGuidArray([FLoginApp.UID]),FDefaultSession);
       CheckDbResult(res,'COULD NOT CONNECT DEFAULT DB / APP / WITH GUEST ACCESS');
     end;

     procedure _ServerInitializeApps;
     var apps : IFRE_DB_APPLICATION_ARRAY;
            i : Integer;
          dbs : IFRE_DB_CONNECTION;
     begin
       GFRE_DBI.FetchApplications(apps);
       for i:=0 to high(apps) do begin
         if apps[i].AppClassName<>'TFRE_DB_LOGIN' then begin
           if GetDBWithServerRights(DefaultDatabase,dbs)=edb_OK then begin // May be an array with db per app
             (apps[i].Implementor_HC as TFRE_DB_APPLICATION).ServerInitialize(dbs);
           end else begin
             GFRE_BT.CriticalAbort('CANNOT SERVERINITIALIZE APPLICATION [APP:%s DB: %s]',[apps[i].AppClassName,DefaultDatabase]);
           end;
         end;
       end;
     end;

     function MyGetPW:string;
     begin
       result := '0000';
     end;

     procedure InitHullHTML;
     var res_main : TFRE_DB_MAIN_DESC;
     begin
//       res_main  := TFRE_DB_MAIN_DESC.create.Describe(cFRE_WEB_STYLE,'https://tracker.firmos.at/s/en_UK-wu9k4g-1988229788/6097/12/1.4.0-m2/_/download/batch/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector-embededjs/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector-embededjs.js?collectorId=5e38a693');
       res_main  := TFRE_DB_MAIN_DESC.create.Describe(cFRE_WEB_STYLE);
       TransFormFunc(FDefaultSession,fct_SyncReply,res_main,FHull_HTML,FHull_CT,false,fdbtt_get2html);
     end;

begin
  TransFormFunc     := @FRE_WAPP_DOJO.TransformInvocation;
  FOpenDatabaseList.init;

  GFRE_DB.LogNotice(dblc_SERVER,'FirmOS System Base Server Node Startup Vesion (%s)',[cVersion]);

  FUserSessionsTree  := TFRE_UserSession_Tree.Create(@Default_RB_String_Compare);
  GFRE_TF.Get_Lock(FSessionTreeLock);

  //ssldir := SetDirSeparators(cFRE_SERVER_DEFAULT_DIR+'/ssl/server_files/');
  //GFRE_DB.LogInfo(dblc_SERVER,'HTTP (MAINTENANCE/SERVICE) SERVER SSL LISTENING ON (%s) ',[flistener_es.GetSocket.Get_AI.SocketAsString]);
  //me:=GFRE_S.AddSocketListener_SSL('*',44443,fil_IPV4,fsp_TCP,shandler,true,flistener_es,fssl_TLSv1,ssldir+cFRE_SSL_CERT_FILE,ssldir+cFRE_SSL_PRIVATE_KEY_FILE,ssldir+cFRE_SSL_ROOT_CA_FILE,@MyGetPW,false,false,false,'DEFAULT');
  //if me<>ese_OK then begin
  //  GFRE_BT.CriticalAbort('Cant create listening socket <%s>',[CFOS_FCOM_MULTIERROR[me]]);
  //  exit;
  //end;
  //GFRE_DB.LogInfo(dblc_SERVER,'HTTP (MAINTENANCE/SERVICE) SERVER LISTENING ON (%s) ',[flistener_es.GetSocket.Get_AI.SocketAsString]);

  //flex_handler.ListenerError      := @ListenerErrorFC;
  //flex_handler.ServerHandler      := @ServerHandlerFC;
  //flex_handler.InitServerSock     := @InitServerSockFC;
  //flex_handler.TearDownServerSock := @TearDownServerSockFC;

  //me:=GFRE_S.AddSocketListener('*',44001,fil_IPV4,fsp_TCP,flex_handler,true,FIL_ListenSock);
  //if me<>ese_OK then begin
  //  GFRE_BT.CriticalAbort('EVENT SERVER Cant create listening socket <%s>',[CFOS_FCOM_MULTIERROR[me]]);
  //end;
  //GFRE_DB.LogInfo(dblc_SERVER,'NODE INTERLINK (SERVER) LISTENING ON (%s) ',[FIL_ListenSock.GetSocket.Get_AI.SocketAsString]);
  //me:=GFRE_S.AddSocketListener_SSL('*',44002,fil_IPV4,fsp_TCP,flex_handler,true,FIL_ListenSockSSL,fssl_TLSv1,ssldir+cFRE_SSL_CERT_FILE,ssldir+cFRE_SSL_PRIVATE_KEY_FILE,ssldir+cFRE_SSL_ROOT_CA_FILE,@MyGetPW,false,false,false,'DEFAULT');
  //if me<>ese_OK then begin
  //  GFRE_BT.CriticalAbort('EVENT SERVER Cant create listening socket <%s>',[CFOS_FCOM_MULTIERROR[me]]);
  //end;
  //GFRE_DB.LogInfo(dblc_SERVER,'NODE INTERLINK (SERVER/SSL) LISTENING ON (%s) ',[FIL_ListenSockSSL.GetSocket.Get_AI.SocketAsString]);

  //FInterLinkEvent := GFRE_S.AddPeriodicSignalTimer(1,@InterLinkDispatchTimer,nil,dm_OneWorker);
  //FWFE_Scheduler  := GFRE_S.AddPeriodicTimer(1000,@WFE_DispatchTimerEvent,nil,dm_OneWorker);

  _SetupHttpBaseServer;
  _ConnectAllDatabases;
  _ServerinitializeApps;

  InitHullHTML;

  GFRE_SC.AddListener_TCP ('*','44000','HTTP/WS');
  GFRE_SC.SetNewListenerCB(@APSC_NewListener);
  GFRE_SC.SetNewChannelCB(@APSC_NewChannel);

  GFRE_SC.AddListener_TCP ('*','44001','FLEX');
  GFRE_SC.SetNewListenerCB(@APSC_NewListener);
  GFRE_SC.SetNewChannelCB(@APSC_NewChannel);


  writeln('SERVER INITIALIZED, running');
end;


procedure TFRE_BASE_SERVER.Terminate;
begin
  GFRE_DB.LogNotice(dblc_SERVER,'TERMINATE SIGNAL RECEIVED',[]);
  _CloseAll;
  GFRE_S.Quit;
end;

procedure TFRE_BASE_SERVER.ReInit;
begin
  GFRE_DB_DEFAULT_PS_LAYER.SyncSnapshot(false);
end;

procedure TFRE_BASE_SERVER.Interrupt;
begin
  if G_NO_INTERRUPT_FLAG THEN exit;
  writeln('INTERRUPT');
  _CloseAll;
  GFRE_S.Quit;
end;

function TFRE_BASE_SERVER.GetName: String;
begin
  result := 'FRE-Server';
end;

procedure TFRE_BASE_SERVER.Finalize;
begin
  free;
end;

function TFRE_BASE_SERVER.FetchFileCached(file_path: String; var data: TFRE_DB_RawByteString): boolean;
var fn : String;
    fh : THandle;
    fs : int64;
    fs2: int64;
begin
  fn := cFRE_SERVER_WWW_ROOT_DIR+DirectorySeparator+file_path;
  if FileExists(fn) then begin
    fh := FileOpen(fn,fmOpenRead+fmShareDenyNone);
    fs := FileSeek(fh,0,fsFromEnd);
    SetLength(data,fs);
    FileSeek(fh,0,fsFromBeginning);
    fs2 := FileRead(fh,data[1],fs);
    if fs2<>fs then abort;
    FileClose(fh);
    result := true;
  end else begin
    result := false;
  end;
end;

procedure TFRE_BASE_SERVER.FetchHullHTML(var lContent: TFRE_DB_RawByteString; var lContentType: string);
begin
  lContent     := FHull_HTML;
  lContentType := FHull_CT;
end;

procedure TFRE_BASE_SERVER.DispatchHTTPRequest(const connection_object: TObject; const uri: string; const method: TFRE_HTTP_PARSER_REQUEST_METHOD);
begin
  FDispatcher.DispatchRequest(connection_object,uri,method);
end;

procedure TFRE_BASE_SERVER.APSC_NewListener(const LISTENER: IFRE_APSC_LISTENER; const state: TAPSC_ListenerState);
var lid : String;
begin
  lid :=listener.GetID;
  if lid='HTTP/WS' then
    begin
      if state =als_EVENT_NEW_LISTENER then
        begin
          if LISTENER.GetState=als_STOPPED then
            begin
              HTTPWS_Listener := listener;
              HTTPWS_Listener.Start;
            end
          else
            GFRE_BT.CriticalAbort('CANNOT ACTIVATE HTTP/WS SERVER : '+LISTENER.GetErrorString);
        end;
    end
  else
  if lid='FLEX' then
    begin
      if state =als_EVENT_NEW_LISTENER then
        begin
          if LISTENER.GetState=als_STOPPED then
            begin
              FLEX_Listener := listener;
              FLEX_Listener.Start;
            end
          else
            GFRE_BT.CriticalAbort('CANNOT ACTIVATE FLEX SERVER : '+LISTENER.GetErrorString);
        end;
    end
  else
    GFRE_BT.CriticalAbort('unknown listener ?');
end;

procedure TFRE_BASE_SERVER.APSC_NewChannel(const channel: IFRE_APSC_CHANNEL; const state: TAPSC_ChannelState);
var lid : String;

  procedure _Setup_New_HTTP_WS_Channel;
  var lServerHandler : TFRE_WEBSOCKET_SERVERHANDLER_FIRMOS_VNC_PROXY;
  begin
    lServerHandler := TFRE_WEBSOCKET_SERVERHANDLER_FIRMOS_VNC_PROXY.Create(channel,self);
    lServerHandler.OnBindInitialSession := @BindInitialSession;
    channel.SetVerboseDesc('HTTP ['+inttostr(channel.GetHandleKey)+']'+'('+channel.GetConnSocketAddr+')');
    channel.SetOnReadData(@lServerHandler.ReadChannelData);
    channel.SetOnDisconnnect(@lServerHandler.DisconnectChannel);
    channel.CH_Enable_Reading;
  end;

  procedure _Setup_New_Flex_Channel;
  var bc : TFRE_SERVED_BASE_CONNECTION;
      us : TFRE_DB_UserSession;
  begin
    bc                      :=TFRE_SERVED_BASE_CONNECTION.Create;
    bc.SetChannel(channel);
    bc.OnBindInitialSession := @BindInitialSession;
    channel.SetVerboseDesc('FLEX ['+inttostr(channel.GetHandleKey)+']'+'('+channel.GetConnSocketAddr+')');
    channel.SetOnReadData(@bc.ReadChannelData);
    channel.SetOnDisconnnect(@bc.DisconnectChannel);
    channel.CH_Enable_Reading;
  end;

begin
  lid := channel.GetListener.GetID;
  if lid ='HTTP/WS' then
    _Setup_New_HTTP_WS_Channel
  else
  if lid = 'FLEX' then
    _Setup_New_Flex_Channel
  else
    GFRE_BT.CriticalAbort('unexpected listener id in new channel?');
end;

procedure TFRE_BASE_SERVER.WFE_DispatchTimerEvent(const ES: IFRE_APS_EVENTSOURCE; const TID: integer; const Data: Pointer; const cp: integer);
var FSession_dispatch_array   : Array of TFRE_DB_UserSession;
    i                         : NativeInt;
    lSession                  : TFRE_DB_UserSession;
begin
  FSessionTreeLock.Acquire;
  try
    //if FUserSessionsTree.QueryTreeChange then begin
      FSession_dispatch_array := FUserSessionsTree.GetAllItemsAsArray;
    //end;
    for i := 0 to high(FSession_dispatch_array) do
      begin
        if FSession_dispatch_array[i].CheckUnboundSessionForPurge then
          begin
            if FUserSessionsTree.Delete(FSession_dispatch_array[i].GetSessionID,lSession) then
              begin
                writeln('FREEING USER SESSION ',lSession.GetSessionID,' user=',lSession.GetUsername,' from ',lSession.GetClientDetails);
                try
                  lSession.free;
                except on e:exception do
                  writeln('SESSION FREE FAILED : ',e.Message);
                end;
                FSession_dispatch_array[i]:=nil;
              end
            else
              begin
                writeln('--CRITICAL ?? - cannot delete unbound session ? ',FSession_dispatch_array[i].GetSessionID);
              end;
          end;
      end;
  finally
    FSessionTreeLock.Release;
  end;
end;

procedure TFRE_BASE_SERVER.NewConnection(const session_id: string);
begin
  writeln('NEW INTERLINK CONNECTION : ',session_id);
end;

procedure TFRE_BASE_SERVER.ConnectionDropped(const session_id: string);
begin
  writeln('DROPPED INTERLINK CONNECTION : ',session_id);
end;


function TFRE_BASE_SERVER.GetImpersonatedDatabaseConnectionSession(const dbname, username, pass,default_app: string;const default_uid_path : TFRE_DB_GUIDArray; out dbs: TFRE_DB_UserSession): TFRE_DB_Errortype;
var found : boolean;
    res   : TFRE_DB_Errortype;
    dbc   : IFRE_DB_CONNECTION;
begin
  result:= GetImpersonatedDatabaseConnection(dbname,username,pass,dbc);
  if result=edb_OK then begin
    dbs := TFRE_DB_UserSession.Create(username,'',default_app,default_uid_path,dbc);
    dbs.OnGetImpersonatedDBC    := @GetImpersonatedDatabaseConnection;
    dbs.OnRestoreDefaultDBC     := @RestoreDefaultConnection;
    dbs.OnExistsUserSession     := @ExistsUserSessionForUser;
    dbs.OnExistsUserSession4Key := @ExistsUserSessionForKey;
    dbs.OnCheckUserNamePW       := @CheckUserNamePW;
    dbs.OnFetchSessionById      := @FetchSessionById;
    dbs.OnFetchPublisherRAC     := @FetchPublisherRAC;
  end;
end;

function TFRE_BASE_SERVER.ExistsUserSessionForUser(const username: string; out other_session: TFRE_DB_UserSession): boolean;
var fsession : TFRE_DB_UserSession;

  function SearchUser(const session:TFRE_DB_UserSession):boolean;
  begin
    if uppercase(session.GetUsername)=uppercase(username) then
      begin
        fsession := session;
        result   := true;
      end
    else
      result := false;
  end;

begin
  result        := false;
  fsession      := nil;
  other_session := nil;
  FSessionTreeLock.Acquire;
  try
    FUserSessionsTree.ForAllItemsBrk(@SearchUser);
    if assigned(fsession) then begin
      other_session     := fsession;
      result            := true;
    end;
  finally
    FSessionTreeLock.Release;
  end;
end;

function TFRE_BASE_SERVER.ExistsUserSessionForKey(const key: string; out other_session: TFRE_DB_UserSession): boolean;
var fsession : TFRE_DB_UserSession;

  function SearchKey(const session:TFRE_DB_UserSession):boolean;
  begin
    if session.GetTakeOverKey=key then
      begin
        fsession := session;
        result   := true;
      end
    else
      result := false;
  end;

begin
  result        := false;
  fsession      := nil;
  other_session := nil;
  FSessionTreeLock.Acquire;
  try
    FUserSessionsTree.ForAllItemsBrk(@SearchKey);
    if assigned(fsession) then begin
      other_session     := fsession;
      result            := true;
    end;
  finally
    FSessionTreeLock.Release;
  end;
end;

function TFRE_BASE_SERVER.CheckUserNamePW(username, pass: TFRE_DB_String): TFRE_DB_Errortype;
begin
  result := FDefaultSession.GetDBConnection.CheckLogin(username,pass);
end;

function TFRE_BASE_SERVER.FetchPublisherRAC(const rcall, rmeth: TFRE_DB_NameType; out rac: IFRE_DB_COMMAND_REQUEST_ANSWER_SC ; out right:TFRE_DB_String): boolean;

  function SearchRAC(const session:TFRE_DB_UserSession):boolean;
  var arr : TFRE_DB_RemoteReqSpecArray;
      i   : NAtiveint;
  begin
    arr := session.GetPublishedRemoteMeths;
    for i:=0 to high(arr) do
      begin
        if (arr[i].classname=rcall)
           and (arr[i].methodname=rmeth) then
             begin
               right := arr[i].invokationright;
               rac := session.GetClientServerInterface;
               result := true;
               exit;
             end;
      end;
    result := false;
  end;

begin
  result   := false;
  rac      := nil;
  FSessionTreeLock.Acquire;
  try
    FUserSessionsTree.ForAllItemsBrk(@SearchRac);
    if assigned(rac) then begin
      result            := true;
    end;
  finally
    FSessionTreeLock.Release;
  end;
end;

function TFRE_BASE_SERVER.FetchSessionById(const sesid: TFRE_DB_String; var ses: IFRE_DB_UserSession): boolean;

  function SearchSession(const session:TFRE_DB_UserSession):boolean;
  var arr : TFRE_DB_RemoteReqSpecArray;
      i   : NAtiveint;
  begin
    if session.GetSessionID = sesid then
      begin
        result := true;
        ses := session;
      end
    else
      result := false;
  end;

begin
  result   := false;
  ses      := nil;
  FSessionTreeLock.Acquire;
  try
    FUserSessionsTree.ForAllItemsBrk(@SearchSession);
    if assigned(ses) then begin
      result            := true;
    end;
  finally
    FSessionTreeLock.Release;
  end;
end;

constructor TFRE_BASE_SERVER.create(const defaultdbname: string);
begin
  DefaultDatabase := defaultdbname;
end;

procedure TFRE_BASE_SERVER.BindInitialSession(const back_channel: IFRE_DB_COMMAND_REQUEST_ANSWER_SC; out  session: TFRE_DB_UserSession; const old_session_id: string;  const interactive_session: boolean);
var ws         : TFRE_WEBSOCKET_SERVERHANDLER_FIRMOS_VNC_PROXY;
    SessionKey : String;
    found      : boolean;
    reuse_ses  : boolean;
begin
  found     := false;
  reuse_ses := (old_session_id<>'NEW') and (old_session_id<>'');
  if reuse_ses then begin
    FSessionTreeLock.Acquire;
    try
      if FUserSessionsTree.Find(old_session_id,session) then begin
        GFRE_DBI.LogDebug(dblc_SESSION,'REUSING SESSION [%s]',[old_session_id]);
        found:=true;
        session.SetSessionState(sta_REUSED);
        session.SetServerClientInterface(back_channel,interactive_session);
      end else begin
        GFRE_DBI.LogDebug(dblc_SESSION,'OLD REQUESTED SESSION NOT FOUND [%s]',[old_session_id]);
      end;
    finally
      FSessionTreeLock.Release;
    end;
  end;
  if not found then begin
    session                     := FDefaultSession.CloneSession(back_channel.GetInfoForSessionDesc); //  (sender as TFRE_WEBSOCKET_SERVERHANDLER_FIRMOS_VNC_PROXY).GetSocketDesc
    if reuse_ses then
      session.SetSessionState(sta_ReUseNotFound)
    else
      session.SetSessionState(sta_ActiveNew);
    FSessionTreeLock.Acquire;
    try
      FUserSessionsTree.Add(session.GetSessionID,session);
      session.SetServerClientInterface(back_channel,interactive_session);
    finally
      FSessionTreeLock.Release;
    end;
    GFRE_DBI.LogDebug(dblc_SESSION,'STARTING NEW SESSION [%s]',[session.GetSessionID]);
  end;
end;


function TFRE_BASE_SERVER.GetImpersonatedDatabaseConnection(const dbname, username, pass: TFRE_DB_String; out dbs: IFRE_DB_CONNECTION): TFRE_DB_Errortype;
var found : boolean;
    res   : TFRE_DB_Errortype;

  function FindDb(const dbconnection:TFRE_DB_CONNECTION):boolean;
  var l_dbc : TFRE_DB_CONNECTION;
  begin
    result := false;
    if uppercase(dbconnection.ConnectedName) = uppercase(dbname) then begin
      res    :=dbconnection.ImpersonateClone(username,pass,l_dbc);
      dbs    := l_dbc;
      result := true;
    end;
  end;

begin
  dbs    := nil;
  found  := FOpenDatabaseList.ForAllBrk(@FindDb);
  if found then begin
    result := res;
  end else begin
    result := edb_NOT_FOUND;
  end;
end;

function TFRE_BASE_SERVER.GetDBWithServerRights(const dbname: TFRE_DB_String; out dbs: IFRE_DB_CONNECTION): TFRE_DB_Errortype;
var found : boolean;
    res   : TFRE_DB_Errortype;

  function FindDb(const dbconnection:TFRE_DB_CONNECTION):boolean;
  begin
    result := false;
    if uppercase(dbconnection.ConnectedName) = uppercase(dbname) then begin
      dbs    := dbconnection;
      result := true;
    end;
  end;

begin
  dbs    := nil;
  found  := FOpenDatabaseList.ForAllBrk(@FindDb);
  if found then begin
    result := edb_OK;
  end else begin
    result := edb_NOT_FOUND;
  end;
end;

function TFRE_BASE_SERVER.RestoreDefaultConnection(out username: TFRE_DB_String; out conn: IFRE_DB_CONNECTION): TFRE_DB_Errortype;
begin
  conn     := FDefaultSession.GetDBConnection;
  username := FDefaultSession.GetUsername;
  result   := edb_OK;
end;

procedure RegisterLogin;
begin
  GFRE_DB.RegisterObjectClassEx(TFRE_DB_LOGIN);
  GFRE_DBI.Initialize_Extension_Objects;
end;


end.

