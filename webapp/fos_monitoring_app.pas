unit fos_monitoring_app;

{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$codepage utf-8}

interface

uses
  Classes, SysUtils,FOS_TOOL_INTERFACES,
  Process,

  FRE_HAL_UTILS,
  FRE_DB_COMMON,
  FRE_DBBUSINESS,
  FRE_DB_INTERFACE,
  FRE_SYSTEM,
  fre_zfs,
  fre_alert,
  fre_process,
  fre_testcase,
  fre_hal_schemes,
  fre_do_safejob;

const

  cremoteuser               = 'root';
  cremotehost               = '10.1.0.116';
  cremotehosttester         = '10.1.0.138';
  cwinrmurl                 = 'https://10.4.0.234:5986/wsman';
  cwinrmuser                = 'winrmi';
  cwinrmpassword            = 'mgo54rb5A';



type

  //Monitoroverview
  //Servicegroup (z.b. Kunde)
  //Service ( z.B. Internetaccess), Betroffene Kunden, (Notiz : welche Abhängigkeiten der Services untereinander)
  //Machine/Device ( z.b. Gateway)
  //Testcase (z.B. Internettest lokales Gateway, Provider-Gateway, mehrere Hosts im Netz)

  EFOS_MONITORING_Exception=class(Exception);


  { TFRE_DB_Monitoring }

  TFRE_DB_Monitoring=class(TFRE_DB_ObjectEx)   // singleton
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
  published
    function        WEB_FullStatusUpdate   (const input:IFRE_DB_OBject ; const ses: IFRE_DB_Usersession ; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
    function        WEB_PartialStatusUpdate(const input:IFRE_DB_OBject ; const ses: IFRE_DB_Usersession ; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION):IFRE_DB_Object;
  end;

  { TFRE_DB_MONSYS_MOD }

  TFRE_DB_MONSYS_MOD = class (TFRE_DB_APPLICATION_MODULE)
  protected
    class procedure RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT); override;
    procedure       SetupAppModuleStructure; override;
  private
  published
    procedure MySessionInitializeModule (const session : TFRE_DB_UserSession);override;
    function  IMI_Content               (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_Update                (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_ClearFailure          (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_CheckActuality        (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_TestcaseStatus_Details(const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_TestcaseStatus_Report (const input:IFRE_DB_Object):IFRE_DB_Object;
    function  IMI_TestcaseStatus_Troubleshooting(const input:IFRE_DB_Object):IFRE_DB_Object;
  end;

  { TFRE_DB_MONSYS }

  TFRE_DB_MONSYS = class (TFRE_DB_APPLICATION)
  private
    procedure       SetupApplicationStructure ; override;
    procedure       _UpdateSitemap            (const session: TFRE_DB_UserSession);

  protected
    procedure       MySessionInitialize       (const session:TFRE_DB_UserSession);override;
    procedure       MySessionPromotion        (const session: TFRE_DB_UserSession); override;
    function        ShowInApplicationChooser  (const session:IFRE_DB_UserSession): Boolean;override;
  public
    class procedure RegisterSystemScheme      (const scheme:IFRE_DB_SCHEMEOBJECT); override;
    class procedure InstallDBObjects          (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure InstallDBObjects4Domain   (const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID); override;
  end;

  TFRE_AlertHTMLJob = class (TFRE_DB_Testcase)
  protected
    procedure       InternalSetup               ; override;
    class procedure RegisterSystemScheme        (const scheme : IFRE_DB_SCHEMEOBJECT); override;
  public
    procedure       ExecuteTest                 ; override;
  end;

  { TFRE_DB_SCP_JOB }

  TFRE_DB_SCP_JOB=class(TFRE_DB_ObjectEx)
  protected
    procedure  InternalSetup ; override;
  published
    function   IMI_Do_the_Job       (const input:IFRE_DB_Object):IFRE_DB_Object;
  end;


procedure Register_DB_Extensions;
procedure DummyDoJobs;
function  GetActualMonitoring : IFRE_DB_Object;
procedure UpdateMonitoring(const conn: IFRE_DB_CONNECTION);

implementation

procedure InitializeMonitoring;
begin
end;

procedure CreateMonitoringDB(const dbname: string; const user, pass: string);
 type
      tmadress = (tmFOSLab,tmKSMServ,tmFOSServ,tmFOSMB,tmcc);
 var
      mon          : IFRE_DB_Object;
      mon_id       : TGUID;
      mon_key      : string;
      sg           : IFRE_DB_Object;
      sg_id        : TGUID;
      service      : IFRE_DB_Object;
      service_id   : TGUID;
      machine      : IFRE_DB_Object;
      machine_id   : TGUID;
      tester       : TFRE_DB_Tester;
      coll_mon     : IFRE_DB_COLLECTION;
      coll_sg      : IFRE_DB_COLLECTION;
      coll_service : IFRE_DB_COLLECTION;
      coll_machine : IFRE_DB_COLLECTION;
      coll_testcase       : IFRE_DB_COLLECTION;
      coll_testcasestatus : IFRE_DB_COLLECTION;
      jobdbo       : IFRE_DB_Object;
      cronl        : TStringList;
      conn         : IFRE_DB_CONNECTION;

      function GetRemoteKeyFilename: string;
      begin
       result := SetDirSeparators(cFRE_GLOBAL_DIRECTORY+'/ssl/user/id_rsa');         // must be authorized for remoteuser on remotehost
      end;

      function GetBackupKeyFilename: string;
      begin
        result := SetDirSeparators(cFRE_GLOBAL_DIRECTORY+'/ssl/user/zfsbackup_rsa');
      end;



      procedure AddServiceGroup(const name :string);
      begin
        sg                                  :=  GFRE_DBI.NewObjectScheme(TFRE_DB_SERVICEGROUP);
        sg.Field('objname').AsString        := name;
        // sg.Field('CUSTOMERID').AsObjectLink := customerid;
        sg_id                               := sg.UID;
        sg.Field('monitoring').AsObjectLink := mon_id;
        CheckDbResult(coll_sg.Store(sg),'Add ServiceGroup');
      end;

      procedure AddService(const name :string);
      begin
        service                                     :=  GFRE_DBI.NewObjectScheme(TFRE_DB_SERVICE);
        service.Field('objname').AsString           := name;
        service_id                                  := service.UID;
        service.Field('servicegroup').AsObjectLink  := sg_id;
        CheckDbResult(coll_service.Store(service),'Add Service');
      end;

      procedure Troubleshooting(const obj:IFRE_DB_Object; const tshoot:string);
      begin
        obj.Field('troubleshooting').asstring := tshoot;
      end;

      procedure AddTestCaseStatus(const tc_id: TGUID;const periodic:TFRE_TestPeriodic);
       var
         tcs      : IFRE_DB_Object;
       begin
         tcs      :=TFRE_DB_TESTCASESTATUS.CreateForDB;
         tcs.Field('periodic_ord').AsInt16  := Ord(periodic);
         tcs.Field('testcase').AsObjectLink        :=  tc_id;
         TFRE_DB_TestcaseStatus(tcs.Implementor_HC).IMI_ClearStatus(nil);
         writeln(tcs.DumpToString);
         CheckDbResult(coll_testcasestatus.Store(tcs),'Add Testcasestatus');
       end;

      procedure StoreAndAddToMachine(obj:IFRE_DB_Object);
      var
        id       : TGUID;
        tc       : TFRE_DB_Testcase;
        periodic : TFRE_TestPeriodic;
      begin
        id       := obj.UID;
        obj.Field('machine').AsObjectLink     := machine_id;
        tc       := TFRE_DB_Testcase(obj.Implementor_HC);
        periodic := tc.GetPeriodic;
        writeln(obj.DumpToString);
        CheckDbResult(coll_testcase.Store(obj),'Add Testcase');
        AddTestCaseStatus(id,periodic);
      end;

      procedure AddVMPingTestCase(const vmhost: string; const vmarray: TFRE_DB_StringArray;const rtt:integer);
      var
        job      : TFRE_DB_MultiPingTestcase;
        i        : integer;

      begin
        job    :=TFRE_DB_MultiPingTestcase.CreateForDB;
        job.SetJobkeyDescription(mon_key+'_'+uppercase(vmhost),'Host '+vmhost);
        job.SetInformation(vmhost);
        job.SetRTTTimeout_ms(rtt);
        job.SetPingCount(10);
        Troubleshooting(job,'Check Status of Machines');
        for i := low(vmarray) to high(vmarray) do begin
          writeln('I:',i);
          job.AddPingTest(vmarray[i],vmarray[i]);
        end;
   //     writeln(job.DumpToString());
        StoreAndAddToMachine(job);
      end;

      procedure AddMachine(const name :string; const ip:string;const where:tmadress;const vmid:string='';const noping:boolean=false);
      var rtt:integer;

         procedure AddAddress;
         var c_dbo : IFRE_DB_Object;
             a_dbo : IFRE_DB_Object;
         begin
           c_dbo := TFRE_DB_COUNTRY.CreateForDB;
           c_dbo.Field('objname').AsString:='Österreich';
           c_dbo.Field('tld').AsString:='at';
           a_dbo := TFRE_DB_ADDRESS.CreateForDB;
           if where in [tmFOSLab,tmFOSServ,tmKSMServ] then begin
            a_dbo.Field('street').asstring:='Obstweg';
            a_dbo.Field('nr').asstring:='4';
            a_dbo.Field('city').asstring:='Neu-Pirka';
            a_dbo.Field('zip').asstring:='8073';
            if where = tmFOSLab then begin
              a_dbo.Field('co').asstring:='Labor 1.Stock';
            end else begin
              a_dbo.Field('co').asstring:='Serverraum Parterre';
            end;
            rtt := 1000;
           end else if where=tmFOSMB then begin
             a_dbo.Field('street').asstring:='Marburgerkai';
             a_dbo.Field('nr').asstring:='1';
             a_dbo.Field('city').asstring:='Graz';
             a_dbo.Field('zip').asstring:='8010';
             rtt := 1000;
            end else begin
             a_dbo.Field('street').asstring:='Steirergasse';
             a_dbo.Field('nr').asstring:='111';
             a_dbo.Field('city').asstring:='Graz';
             a_dbo.Field('zip').asstring:='8010';
             rtt := 1000;
            end;
           a_dbo.Field('country').AsObject:=c_dbo;
           machine.Field('address').AsObject:=a_dbo;
           if vmid<>'' then begin
             machine.Field('vmid').AsString:=vmid;
           end;
         end;

      begin
        machine                                := TFRE_DB_MACHINE.CreateForDB;
        machine.Field('objname').AsString      := name;
        machine.Field('ip').AsString           := ip;
        AddAddress;
        machine_id                             := machine.UID;
        machine.Field('service').AsObjectLink  := service_id;
        writeln(machine.DumpToString);
        CheckDbResult(coll_machine.Store(machine),'Add Machine');

        if noping=false then begin
          AddVMPingTestCase(StringReplace(name+'_PING','.','_',[rfReplaceAll]),TFRE_DB_StringArray.Create(ip),rtt);
        end;
      end;




      procedure _create_jobdbo(const obj:IFRE_DB_Object);
      var jobkey : string;
      begin
        jobkey := obj.Field('objname').asstring;
        if Pos(mon_key,jobkey)=1 then begin
        //  writeln(obj.DumpToString);
          jobdbo.Field(jobkey).asobject := obj;
        end;
      end;

      procedure _create_cronjobs(const obj:IFRE_DB_Object);
      var jobkey  : string;
          line    : string;
          periodic: string;
      begin
        jobkey := obj.Field('objname').asstring;
        if Pos(mon_key,jobkey)=1 then begin
         case TFRE_DB_Testcase(obj.Implementor_HC).GetPeriodic of
           everyDay :   periodic :='0 0 * * * ';
           everyHour:   periodic :='15 * * * *';
           everyMinute: periodic :='* * * * * ';
         end;
         line := periodic+'      fre_safejob '+jobkey;
         cronl.Add(line);
        end;
      end;

      procedure CreateAlert;
      var alert: TFRE_Alert;

           procedure _create_alerts(const obj:IFRE_DB_Object);
           var jobkey : string;
           begin
             jobkey := obj.Field('objname').asstring;
 //            if Pos('CITYACCESS_AP_',jobkey)>0 then begin
               alert.AddAlertKeys(TFRE_DB_StringArray.Create(jobkey));
 //            end;
           end;

      begin
        alert := TFRE_Alert.Create;
        try
          alert.ClearStatus;
          alert.ClearConfig;
          alert.SetSMTPHost('mail.firmos.at','25','mailer','45mfj345l2094pc1');
          alert.SetMailFrom('alert@firmos.at');
          alert.SetMailSubject('Alert from FirmOS Monitoring System Controller');
          alert.AddAlertingEMailCommon(TFRE_DB_StringArray.Create('franz.schober@firmos.at','noc@firmos.at'));
          alert.AddAlertTypeCommon(alty_Mail);
          alert.SetAlertModeCommon(almo_ChangeTimeout);
          alert.SetChangeTimeoutCommon(300);
          coll_testcase.ForAll(@_create_alerts);
          alert.SaveAlertConfig;
        finally
          alert.free;
        end;

      end;

      procedure AddTestCase(const name : string);
      var
        obj    : TFRE_DB_Testcase;
      begin
        obj   :=TFRE_DB_Testcase.CreateForDB;
        obj.SetJobkeyDescription('DUMMY'+'_'+name,'Description TODO:'+name);
        Troubleshooting(obj,'fix it :-) '+name);
        StoreAndAddToMachine(obj);
      end;

      procedure AddZpoolStatusTestCase(const server: string; const jobkey: string; const desc: string);
      var
        z      : TFRE_DB_ZFSJob;
      begin
        z   :=TFRE_DB_ZFSJob.CreateForDB;
        z.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        z.SetRemoteSSH(cremoteuser, server, Getremotekeyfilename);
        z.SetPeriodic(everyHour);
        z.SetPoolStatus('zones',7,14);
        Troubleshooting(z,'Check Disks ! ');
        StoreAndAddToMachine(z);
      end;

      procedure AddZFSSpaceTestCase(const server: string; const jobkey: string; const desc: string);
      var
        z      : TFRE_DB_ZFSJob;
      begin
        z   := TFRE_DB_ZFSJob.CreateForDB;
        z.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        z.SetRemoteSSH(cremoteuser, server, Getremotekeyfilename);
        z.SetDatasetspace('zones',80,95);
        Troubleshooting(z,'Delete data or remove snapshots in your dataset !');
        StoreAndAddToMachine(z);
      end;

      procedure AddDiskSpaceTestCase(const server: string; const jobkey: string; const desc: string; const mountpoint:string);
      var
        z      : TFRE_DB_DiskspaceTestcase;
      begin
        z     :=TFRE_DB_DiskspaceTestcase.CreateForDB;
        z.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        z.SetRemoteSSH(cremoteuser, server, Getremotekeyfilename);
        z.SetMountpoint(mountpoint,80,95);
        Troubleshooting(z,'Delete data or extend the device !');
        StoreAndAddToMachine(z);
      end;

      procedure AddHTTPTestCase(const url: string; const jobkey: string; const desc: string; const header:string; const responsematch:string);
      var
        z      : TFRE_DB_HTTPTestcase;
      begin
        z     :=TFRE_DB_HTTPTestcase.CreateForDB;
        z.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
//             z.SetRemoteSSH(cremoteuser, server, Getremotekeyfilename);
        z.SetURL(url,header,responsematch);
        z.SetPeriodic(everyHour);
        Troubleshooting(z,'Delete data or extend the device !');
        StoreAndAddToMachine(z);
      end;

      procedure AddCPUTestCase(const server: string; const jobkey: string; const desc: string; const warning_load:integer; const error_load:integer);
      var
        t      : TFRE_DB_CPULoadTestcase;
      begin
        t     :=TFRE_DB_CPULoadTestcase.CreateForDB;
        t.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        t.SetRemoteSSH(cremoteuser, server, Getremotekeyfilename);
        t.SetLimits(warning_load,error_load);
        t.SetPeriodic(everyHour);
        Troubleshooting(t,'Check for slow processes or hangs !');
        StoreAndAddToMachine(t);
      end;


      procedure AddProcessTestCase(const server: string;const jobkey:string;const desc:string;const processname:TFRE_DB_StringArray;const error_count:TFRE_DB_UInt32Array);
      var
        p      : TFRE_DB_ProcessTestcase;
        i      : integer;
      begin
        p     :=TFRE_DB_ProcessTestcase.CreateForDB;
        p.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        p.SetRemoteSSH(cremoteuser, server, Getremotekeyfilename);
        for i := 0 to high(processname) do begin
          p.AddProcessTest(processname[i],1,error_count[i],processname[i]);
        end;
        Troubleshooting(p,'Restart failing Processes !');
        StoreAndAddToMachine(p);
      end;

      procedure AddSSHZFSReplication(const jobkey: string; const desc : string; const sourcehost: string; const desthost:string; const sourceds:string; const destds: string;const checkperiod_sec: integer;const snapshotkey:string='AUTO');
       var
         zf     : TFRE_DB_ZFSJob;
       begin
         zf    :=TFRE_DB_ZFSJob.CreateForDB;
         zf.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
         zf.SetRemoteSSH(cremoteuser, sourcehost, Getremotekeyfilename);
         zf.SetSSHReplicate(sourceds,destds,snapshotkey,desthost,'zfsback',GetbackupKeyFileName,'/zones/firmos/zfsback/.ssh/id_rsa');
         zf.SetPeriodic(everyDay);
         Troubleshooting(zf,'Check Replication ! ');
         StoreAndAddToMachine(zf);

         zf    :=TFRE_DB_ZFSJob.CreateForDB;
         zf.SetJobkeyDescription(mon_key+'_'+jobkey+'_CHECK',desc);
         zf.SetRemoteSSH(cremoteuser, desthost, Getremotekeyfilename);
         zf.SetSnapshotCheck(destds,'AUTO',checkperiod_sec*2,checkperiod_sec*4);
         zf.SetPeriodic(everyHour);
         Troubleshooting(zf,'Check Snapshot ! ');
         StoreAndAddToMachine(zf);
      end;

      procedure AddTCPZFSReplication(const jobkey: string; const desc : string; const desthost:string; const sourceds:string; const destds: string;const checkperiod_sec: integer;const snapshotkey:string='AUTO');
       var
         zf     : TFRE_DB_ZFSJob;
       begin
         zf    :=TFRE_DB_ZFSJob.CreateForDB;
         zf.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
         zf.SetTCPReplicate(sourceds,destds,snapshotkey,desthost,CFRE_FOSCMD_PORT);
         zf.SetPeriodic(everyDay);
         Troubleshooting(zf,'Check Replication ! ');
         StoreAndAddToMachine(zf);

         //zf    :=TFRE_DB_ZFSJob.CreateForDB;
         //zf.SetJobkeyDescription(mon_key+'_'+jobkey+'_CHECK',desc);
         //zf.SetRemoteSSH(cremoteuser, desthost, Getremotekeyfilename);
         //zf.SetSnapshotCheck(destds,'AUTO',checkperiod_sec*2,checkperiod_sec*4);
         //zf.SetPeriodic(everyHour);
         //Troubleshooting(zf,'Check Snapshot ! ');
         //StoreAndAddToMachine(zf);
      end;

      procedure AddZFSSnapshot(const jobkey: string; const desc : string; const sourcehost: string; const sourceds:string; const checkperiod_sec: integer;const snapshotkey:string='AUTO');
       var
         zf     : TFRE_DB_ZFSJob;
       begin
         zf    :=TFRE_DB_ZFSJob.CreateForDB;
         zf.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
         zf.SetRemoteSSH(cremoteuser, sourcehost, Getremotekeyfilename);
         zf.SetSnapshot(sourceds,snapshotkey);
         zf.SetPeriodic(everyDay);
         Troubleshooting(zf,'Check Do Snapshot! ');
         StoreAndAddToMachine(zf);

         zf    :=TFRE_DB_ZFSJob.CreateForDB;
         zf.SetJobkeyDescription(mon_key+'_'+jobkey+'_CHECK',desc);
         zf.SetRemoteSSH(cremoteuser, sourcehost, Getremotekeyfilename);
         zf.SetSnapshotCheck(sourceds,'AUTO',checkperiod_sec*2,checkperiod_sec*4);
         zf.SetPeriodic(everyHour);
         Troubleshooting(zf,'Check Snapshot ! ');
         StoreAndAddToMachine(zf);
      end;


      procedure AddInternetTestCase(const office:boolean);
      var
        job    : TFRE_DB_InternetTestcase;
      begin
        job    :=TFRE_DB_InternetTestcase.CreateForDB;
        job.SetRemoteSSH(cremoteuser, cremotehost, Getremotekeyfilename);
        if office then begin
          job.SetJobkeyDescription(mon_key+'_'+'INTERNETTESTCASE','Internetverbindung FirmOS Office');
          job.PrepareTest('91.114.28.42','91.114.28.41',TFRE_DB_StringArray.Create ('10.1.0.1'));
        end else begin
         job.SetJobkeyDescription(mon_key+'_'+'INTERNETTESTCASE_HOUSING','Internetverbindung FirmOS Housing');
         job.PrepareTest('10.220.251.1','80.120.208.113',TFRE_DB_StringArray.Create ('8.8.8.8'));
        end;
        job.SetPeriodic(everyHour);
        Troubleshooting(job,'Restart Modem !');
        StoreAndAddToMachine(job);
      end;


      procedure AddWinRMTestCase(const server: string; const jobkey: string; const desc: string);
      var
        wm     : TFRE_DB_WinRMTestcase;
        wmt    : TFRE_DB_WinRMTarget;
      begin
        wm    :=TFRE_DB_WinRMTestcase.CreateForDB;
        wm.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        wm.SetRemoteSSH(cremoteuser, cremotehosttester, Getremotekeyfilename);
        wmt      := wm.AddWinRMTarget(cwinrmurl, cwinrmuser, cwinrmpassword);
        wmt.AddTestDiskSpace('E422D5D9',40,90);
        wmt.AddTestServiceRunning('MSExchangeServiceHost');
        wmt.AddTestServiceRunning('DHCPServer');
        wmt.SetTestCPUUsage(90);
        Troubleshooting(wm,'Check KSM Server ! ');
        StoreAndAddToMachine(wm);
      end;

      procedure AddMailCheck(const name : string);
      var
        sm     : TFRE_DB_MailSendTestcase;
        cm     : TFRE_DB_MailCheckTestcase;
      begin
        sm       := TFRE_DB_MailSendTestcase.CreateForDB;
        sm.SetJobkeyDescription(mon_key+'_'+name,'Senden von Mails über den KSM Exchange Server');
        sm.SetRemoteSSH(cremoteuser, cremotehosttester, GetRemoteKeyFilename);
        sm.AddMailserver('10.4.0.234',cwinrmuser,cwinrmpassword,'tester@ksm.at','monsys@monsys.firmos.at');
        StoreAndAddToMachine(sm);

        cm       := TFRE_DB_MailCheckTestcase.CreateForDB;
        cm.SetJobkeyDescription(mon_key+'_'+name+'_CHECK','Empfangen von über den KSM Exchange Server gesendenten Mails');
        cm.Field('MAX_ALLOWED_TIME').AsInt32 := 60;
        cm.SetRemoteSSH(cremoteuser, cremotehosttester, Getremotekeyfilename);
        cm.SetMailserver('10.4.0.234',mon_key+'_'+name,300,600);
        StoreAndAddToMachine(cm);
       end;

      procedure AddSMBTestCase(const server: string; const jobkey: string; const desc: string; const user : string; const pass: string; const fileshare : string; const mountpoint : string);
      var
        smb    : TFRE_DB_SMBTestcase;
      begin
        smb   :=TFRE_DB_SMBTestcase.CreateForDB;
        smb.SetJobkeyDescription(mon_key+'_'+jobkey,desc);
        smb.SetRemoteSSH(cremoteuser, cremotehosttester, Getremotekeyfilename);
        smb.SetFileshare(server,user,pass,fileshare,mountpoint);
        Troubleshooting(smb,'Check Fileservice ! ');
        StoreAndAddToMachine(smb);
      end;

      procedure AddSBFWZones;
      var
        job      : TFRE_DB_MultiPingTestcase;
        i        : integer;

        procedure AddZone(const ip:string; const detail:string);
        begin
          writeln('ZONE:',detail,' ',ip);
          job.AddPingTest(ip,detail);
        end;

      begin
        job    :=TFRE_DB_MultiPingTestcase.CreateForDB;
        job.SetJobkeyDescription(mon_key+'_'+'SBFW_ZONES_PING','Small Business Firewall');
        job.SetInformation('Small Business Firewall');
        job.SetRTTTimeout_ms(100);
        job.SetPingCount(5);
        Troubleshooting(job,'Check SBFW System');
        AddZone('109.73.149.69','Droneberger');
        AddZone('109.73.149.70','TestCustomer');
        AddZone('109.73.149.71','Huber');
        AddZone('109.73.149.72','tribeka_leonhard');
        AddZone('109.73.149.73','tribeka_technikerstrasse');
        AddZone('109.73.149.74','tribeka_grieskai');
        AddZone('109.73.149.75','tribeka_muchargasse');
        StoreAndAddToMachine(job);
      end;

      procedure AddCityaccessAPTestCase;
      var
        collsite   : IFRE_DB_COLLECTION;

        procedure _addCheck;
        var
          check    : TFRE_AlertHTMLJob;
        begin
         check :=TFRE_AlertHTMLJob.CreateForDB;
         check.SetJobkeyDescription(mon_key+'_'+'ALERT_HTML_REPORT','HTML_REPORT');
         StoreAndAddToMachine(check);
        end;


        procedure _site_endpoints(const site:IFRE_DB_Object);
        var
          aps      : TFRE_DB_GUIDArray;
          ap       : IFRE_DB_Object;
          obj      : IFRE_DB_Object;
          job      : TFRE_DB_MultiPingTestcase;
          i        : integer;

        begin
          writeln ('SITE:',site.Field('objname').asstring);
          //Fixme
          //aps   := site.ReferencedByList(TFRE_DB_AP_Lancom.Classname);
          abort;
          if length(aps)>0 then begin
            writeln('AP:',length(aps));
            job    :=TFRE_DB_MultiPingTestcase.CreateForDB;
            job.SetJobkeyDescription(mon_key+'_'+'CITYACCESS_AP_'+site.Field('sitekey').asstring,'Cityaccess Accesspoints '+site.Field('objname').asstring);
 //           job.SetRemoteSSH(cremoteuser, cremotehost, Getremotekeyfilename);
            job.SetInformation(site.Field('objname').asstring);
            job.SetRTTTimeout_ms(50);
            job.SetPingCount(5);
            Troubleshooting(job,'Check Connections and Backbone Routing/VLAN');

            for i := low(aps) to high(aps) do begin
              CONN.Fetch(aps[i],ap);
              writeln('I:',i);
              job.AddPingTest(ap.Field('external_ip').asstring,ap.Field('mountingdetail').asstring);
            end;
            StoreAndAddToMachine(job);
          end;


        end;

      begin
        collsite   := CONN.GetCollection('site');
        collsite.ForAll(@_site_endpoints);

//             _addCheck;

      end;


begin

  CONN := GFRE_DBI.NewConnection;
  CONN.Connect(dbname,'admin@system','admin');

  jobdbo       := GFRE_DBI.NewObject;

  coll_mon            := CONN.CreateCollection('monitoring');
  coll_sg             := CONN.CreateCollection('servicegroup');
  coll_service        := CONN.CreateCollection('service');
  coll_machine        := CONN.CreateCollection('machine');
  coll_testcasestatus := CONN.CreateCollection('testcasestatus');

  coll_testcase := conn.CreateCollection('testcase',true);
  if not coll_testcase.IndexExists('def') then
    coll_testcase.DefineIndexOnField('objname',fdbft_String,true,true);

  mon_key                               := 'MONFOS';

  mon                                := TFRE_DB_Monitoring.CreateForDB;
  mon.Field('objname').AsString      := mon_key;
  mon_id                             := mon.UID;
  CheckDbResult(coll_mon.Store(mon),'Add Monitoring');



    // Precondition: Hierarchie ist immer gleich, gleiche Levels

   // AddTester('Tester1','10.1.0.138');
  ///    AddSCPJob;

  AddServiceGroup('Citycom');         // Firmos Office/Internet/Gateway/INTERNETTESTCASE            STATUS            STATUSDETAILS
    AddService('nordpool');
      AddMachine('snord01','10.54.3.1',tmFOSServ);
      AddTCPZFSReplication('ZFS_REPL_NORDPOOL_01','Replication RZ nordp','10.54.240.198','nordp',
                        'drsdisk/drssnapshots/s01_nordp',86400);
      AddTCPZFSReplication('ZFS_REPL_NORDDISK_TEST','Replication RZ norddisk test','10.54.240.198','norddisk/test',
                        'drsdisk/drssnapshots/norddisktest',86400);
    AddService('nordpool');
      AddMachine('ssued01','10.54.3.2',tmFOSServ);
      AddTCPZFSReplication('ZFS_REPL_SUEDPOOL_01','Replication RZ suedp','10.54.240.198','suedp',
                        'drsdisk/drssnapshots/s01_suedp',86400);

  AddServiceGroup('FirmOS Office');         // Firmos Office/Internet/Gateway/INTERNETTESTCASE            STATUS            STATUSDETAILS
      AddService('Internet');
        AddMachine('Gateway','91.114.28.42',tmFOSServ);
        AddInternetTestcase(true);
        AddProcessTestCase('10.1.0.1','OFFICE_GW_PROCESS','Processes on FirmOS Office Gateway',TFRE_DB_StringArray.Create('openvpn','named','dhcpd'),TFRE_DB_UInt32Array.Create(4,1,1));
        AddMachine('kamera','10.1.0.69',tmFosLab,'');
      AddService('Storage');
        AddMachine('FirmOSStorage','10.1.0.116',tmFOSLab);
          AddCPUTestCase('10.1.0.116','CPU_FOSDATA','CPU Load FirmOS Office Storage',5,10);
          AddZpoolStatusTestCase('10.1.0.116','ZPOOL_FOS_FOSDATA','Zones FirmOS Office Storage');
          AddZFSSpaceTestCase('10.1.0.116','ZFS_SPACE_FOSDATA','Zones FirmOS Office Storage Space');
          AddSSHZFSReplication('ZFS_REPL_FOSDATA','Replication FirmOS Fosdata','10.1.0.116','smartstore.firmos.at','zones/568ac8fd-d282-4848-a5b7-c5df2ae6f3f8',
                            'zones/backup/firmos/568ac8fd-d282-4848-a5b7-c5df2ae6f3f8',86400);
          AddSSHZFSReplication('ZFS_REPL_FOSDATA_DOK','Replication FirmOS Fosdata Dokumente','10.1.0.116','smartstore.firmos.at','zones/FirmOS_Data/FirmOS_Dokumente',
                            'zones/backup/firmos/FirmOSData/FirmOS_Dokumente',86400);
          AddSSHZFSReplication('ZFS_REPL_FOSDATA_LIB','Replication FirmOS Fosdata Library','10.1.0.116','smartstore.firmos.at','zones/FirmOS_Data/FirmOS_Library',
                            'zones/backup/firmos/FirmOSData/FirmOS_Library',86400);
        AddMachine('fosdata','10.1.0.132',tmFOSLab,'568ac8fd-d282-4848-a5b7-c5df2ae6f3f8');
          AddProcessTestCase('10.1.0.132','OFFICE_FOSDATA_PROCESS','Processes on Office Fosdata',TFRE_DB_StringArray.Create('smbd','afpd','netatalk'),TFRE_DB_UInt32Array.Create(1,1,1));
        AddMachine('win2008dc','10.1.0.110',tmFosLab,'24d6d43c-24f2-4087-9e37-692c79f1ce91');
        AddMachine('win2008vsphere','10.1.0.111',tmFosLab,'e59ea635-7400-42bc-925b-d9ee9168ccf3');
        AddMachine('nexenta','10.1.0.112',tmFosLab,'cdb518dc-b40c-47e6-a492-4ae359f9049d');
        AddMachine('testzone','10.1.0.113',tmFosLab,'128581ed-52d6-4777-8533-de05261ef23b');
        AddMachine('smartosbuild','10.1.0.114',tmFosLab,'1d53d0eb-cdde-4a99-a32e-4a3bbe7d519b');
        AddMachine('windev','10.1.0.115',tmFosLab,'1a1bc352-0a92-4aad-8aa9-edb293e54ea0');
        AddMachine('old_build','10.1.0.117',tmFosLab,'bd2a5ef3-a11c-459e-8d26-460939758fed');
        AddMachine('wintest','10.1.0.118',tmFosLab,'d8aea6ea-94b7-4aab-b2c7-16b69c9ea156');
      AddService('Lab');
    AddServiceGroup('KSM');
      AddService('Office');
        AddMachine('SBS Server','10.4.0.234',tmKSMServ);
          AddWinRMTestCase('10.4.0.234','WINRM_KSM_SBS','SBS Server KSM WinRM');
          AddTestCase('Services Exchange + POP3 Connector');
          AddSMBTestCase('10.4.0.234','KSM_SBS_FILESHARE','SBS Server KSM Fileshare KSM_Buero', cwinrmuser, cwinrmpassword, 'KSM_BUERO', '/usr/local/testsmb');
          AddMailCheck('MAILKSM');
        AddMachine('Linux','10.4.0.3',tmKSMServ);
          AddDiskSpaceTestCase('10.4.0.3','KSM_LINUX_SPACE','Diskspace on KSM Linux','/');
          AddProcessTestCase('10.4.0.3','KSM_LINUX_PROCESS','Processes on KSM Linux',TFRE_DB_StringArray.Create('fbguard','fbserver','Dispatcher'),TFRE_DB_UInt32Array.Create(1,1,1));
      AddService('Storage');
        AddMachine('KSMStorage','10.1.0.129',tmKSMServ);
          AddZpoolStatusTestCase('10.1.0.129','ZPOOL_KSM_ZONES','Diskpool KSM Storage');
          AddZFSSpaceTestCase('10.1.0.129','ZFS_SPACE_KSM_ZONES','Zones FirmOS Office Storage Space');
          AddCPUTestCase('10.1.0.129','CPU_KSM','CPU Load KSM Storage',5,10);
          AddSSHZFSReplication('ZFS_REPL_KSMLINUX','Replication KSM Faktura','10.1.0.129','smartstore.firmos.at','zones/2cd2e934-f21e-4fea-b46e-f3098f4e3be3',
                            'zones/backup/ksm/2cd2e934-f21e-4fea-b46e-f3098f4e3be3',86400);
          AddSSHZFSReplication('ZFS_REPL_KSMLINUX_DISK','Replication KSM Faktura Disk0','10.1.0.129','smartstore.firmos.at','zones/2cd2e934-f21e-4fea-b46e-f3098f4e3be3-disk0',
                            'zones/backup/ksm/2cd2e934-f21e-4fea-b46e-f3098f4e3be3-disk0',86400);
          AddSSHZFSReplication('ZFS_REPL_KSMSBS','Replication KSM SBS','10.1.0.129','smartstore.firmos.at','zones/a560f5a3-35ae-4552-9f25-be1308c9db65',
                            'zones/backup/ksm/a560f5a3-35ae-4552-9f25-be1308c9db65',86400);
          AddSSHZFSReplication('ZFS_REPL_KSMSBS_DISK','Replication KSM SBS Disk0','10.1.0.129','smartstore.firmos.at','zones/a560f5a3-35ae-4552-9f25-be1308c9db65-disk0',
                            'zones/backup/ksm/a560f5a3-35ae-4552-9f25-be1308c9db65-disk0',86400);
    AddServiceGroup('FirmOS Marburgerkai');
      AddService('Backoffice');
        AddMachine('Firewall','80.120.208.114',tmFOSMB);
          AddInternetTestcase(false);
//             AddMachine('Belkin KVM','80.120.208.115',tmFOSMB);
        AddMachine('DRAC_FIREWALL','80.120.208.116',tmFOSMB);
        AddMachine('HP_SWITCH','80.123.225.54',tmFOSMB,'',true);
        AddMachine('BACKOFFICE','10.220.252.101',tmFOSMB);
          AddTestCase('FirmOSMail');
        AddMachine('FIP','10.220.252.21',tmFOSMB);
          AddProcessTestCase('10.220.252.21','FIP2_PROCESS','Processes on FIP2',TFRE_DB_StringArray.Create('postgres','mysqld','Dispatcher','fbguard','fbserver'),TFRE_DB_UInt32Array.Create(1,1,1,1,1));
          AddDiskSpaceTestCase('10.220.252.21','FIP2_DISKSPACE','Diskspace on FIP2 /','/');
      AddService('SmartOSStorage');
          AddMachine('SmartOS','10.220.251.10',tmFOSMB,'',true);
          AddCPUTestCase('10.220.251.10','CPU_SMARTSTORAGE','CPU Load SmartStorage',10,15);
          AddZpoolStatusTestCase('10.220.251.10','ZPOOL_FOS_SMARTSTORAGE','Diskpool FirmOS SmartStorage');
          AddZFSSpaceTestCase('10.220.251.10','ZFS_SPACE_SMARTSTORAGE','Zones FirmOS SmartStorage');
          AddZFSSnapshot('ZFS_SNAPSHOT_SMARTSTORAGE','Snapshot Smartstorage','smartstore.firmos.at','zones',86400,'FULLSNAP');

          AddMachine('firmgit.firmos.at','10.220.252.120',tmFOSMB,'7b161e9f-36a4-4abf-925d-45c1b09ca1dc');
          AddHTTPTestCase('http://fosbuild.firmos.at','HTTP_FOSBUILD','FirmOS Building System (Jenkins)','','Jenkins');
          AddMachine('ns1int.firmos.at','10.220.252.11',tmFOSMB);
          AddMachine('ns2int.firmos.at','10.220.252.12',tmFOSMB);
          AddMachine('fpclin32.firmos.at','10.220.252.31',tmFOSMB);
          AddMachine('fpclin64.firmos.at','10.220.252.32',tmFOSMB);
          AddMachine('fpcwinxp32.firmos.at','10.220.252.42',tmFOSMB);
          AddMachine('fpcvista64.firmos.at','10.220.252.41',tmFOSMB);
          AddMachine('freelove832.firmos.at','10.220.252.51',tmFOSMB);
          AddMachine('freelove864.firmos.at','10.220.252.52',tmFOSMB);
          AddMachine('openbsd32.firmos.at','10.220.252.53',tmFOSMB);
          AddMachine('openbsd64.firmos.at','10.220.252.54',tmFOSMB);
          AddMachine('openindiana.firmos.at','10.220.252.55',tmFOSMB);
          AddMachine('freelove932.firmos.at','10.220.252.56',tmFOSMB);
          AddMachine('freelove964.firmos.at','10.220.252.57',tmFOSMB);
          AddMachine('netbsd32.firmos.at','10.220.252.58',tmFOSMB);
          AddMachine('netbsd64.firmos.at','10.220.252.59',tmFOSMB);
          AddMachine('fpcopensolaris.firmos.at','10.220.252.61',tmFOSMB);
          AddMachine('fpcwin764.firmos.at','10.220.252.63',tmFOSMB);
          AddMachine('fpcwin2008r2.firmos.at','10.220.252.64',tmFOSMB);
          AddMachine('fpcJenkins.firmos.at','10.220.252.66',tmFOSMB);
//             AddMachine('openindiana2.firmos.at','10.220.252.67',tmFOSMB);
          AddMachine('oraclesolaris.firmos.at','10.220.252.68',tmFOSMB);
          AddMachine('fpcamiga.firmos.at','10.220.252.69',tmFOSMB);
          AddMachine('fpcreactos.firmos.at','10.220.252.70',tmFOSMB,'',true);
          AddMachine('lazarusteam32.firmos.at','10.220.252.80',tmFOSMB);
          AddHTTPTestCase('http://10.220.252.81','HTTP_LAZARUS','Lazarus Forum','','forumtitle');
          AddMachine('newlazarusteam.firmos.at','10.220.252.82',tmFOSMB);
          AddMachine('fpcfed32.firmos.at','10.220.252.91',tmFOSMB);
          AddMachine('fpcfed64.firmos.at','10.220.252.92',tmFOSMB);
          AddMachine('fpcqemu.firmos.at','10.220.252.95',tmFOSMB,'',true);
          AddMachine('fpchaiku32.firmos.at','10.220.252.97',tmFOSMB,'',true);
          AddMachine('freepascaldos.firmos.at','10.220.252.98',tmFOSMB,'',true);
          AddMachine('fpcfreedos11.firmos.at','10.220.252.99',tmFOSMB,'',true);
          AddMachine('firmbsd82leg.firmos.at','10.220.252.121',tmFOSMB,'06dec646-802f-4d99-8eb3-4b50db030224');
          AddMachine('firmbsd90.firmos.at','10.220.252.122' ,tmFOSMB,'c7e81ecb-107e-424e-9de3-bb4ed2e7e8c7');
          AddMachine('firmbsd9032.firmos.at','10.220.252.123' ,tmFOSMB,'d8402ea1-02ba-44a2-b0d5-c467b28a618a');  //id
          AddMachine('firmdebian64.firmos.at','10.220.252.124',tmFOSMB,'5c8727f9-89b7-4e47-aa1e-5da46ba8aecf');
          AddMachine('firmdebian32.firmos.at','10.220.252.125',tmFOSMB,'7a6999cf-bd18-49c8-8eaf-1590b26e86c8');
          AddMachine('monsysprod','10.220.252.130',tmFOSMB,'1160215a-c3f8-4aac-b932-46db11a5b398');
          AddMachine('openwrt_ubnt_build','10.220.252.132',tmFOSMB,'1e0fc382-9a1d-4fd4-9101-70714b7e6124',true);
 //       AddMachine('ddwrt','10.220.252.133',tmFOSMB,'6c0117b4-c452-4b56-adf0-6824e5694a7c');
 //       AddMachine('evercity','10.220.252.134',tmFOSMB,'92c2014b-e636-4d64-ba02-5bdf168b33e4');
 //       AddMachine('smos_package_build','10.220.252.135',tmFOSMB,'15843d0e-d5c0-4e19-bd4d-6fd6f7cfd657');
          AddMachine('win7dev','10.220.252.136',tmFOSMB,'79387d0d-4a59-4bae-b29d-55474744733a');
          AddMachine('ebay_sniper','10.220.252.140',tmFOSMB,'183934d6-8475-44a7-a6df-e93ea4b1320f',true);
          AddMachine('meeting','10.220.252.142',tmFOSMB,'4d242470-2994-4536-8fea-3b80fe52b944');
 //       AddMachine('openerp_debian64','10.220.252.143',tmFOSMB,'05c88c76-65aa-470d-918d-2d260b2dfbd8');
          AddMachine('nagios','10.220.252.144',tmFOSMB,'9aa85aa6-091d-43f4-8cd4-c75c01dfd856',true);
 //       AddMachine('testubuntu2','10.220.252.145',tmFOSMB,'2bceffb3-5b9d-4851-8ecc-3f82a8684da8');
          AddMachine('firmosweb','10.220.252.146',tmFOSMB,'13bad66b-dcbc-4eb1-9779-9b0465fc4159',true);
          AddMachine('firmosdrupal','10.220.252.147',tmFOSMB,'ad49d4be-156f-4e5a-b108-35339228f196');
          AddHTTPTestCase('http://10.220.252.147','HTTP_FIRMOS','FirmOS Homepage','Host: www.firmos.at','FirmOS Business Solutions');
          AddHTTPTestCase('http://10.220.252.147','HTTP_KSM','KSM Homepage','Host: www.ksm.at','KSM');
          AddMachine('herrengasse','10.220.252.148',tmFOSMB,'563f9e83-71f8-422a-9d69-06a97c9c9193');
          AddMachine('franzdata','10.220.252.149',tmFOSMB,'5c1eae31-67bc-4f19-a148-9ede039d7ad8');

          AddMachine('webext','10.220.252.150',tmFOSMB,'');


     AddService('Artemes');
          AddMachine('Artemes','10.220.249.10',tmFOSMB,'',true);
          AddZpoolStatusTestCase('10.220.249.10','ZPOOL_ARTEMES','Diskpool Artemes');
          AddZFSSpaceTestCase('10.220.249.10','ZFS_SPACE_ARTEMES','Zones Artemes');
          AddSSHZFSReplication('ZFS_REPL_ARTEMES','Replication Artemes Complete','10.220.249.10','smartstore.firmos.at','zones',
                            'zones/backup/artemes/complete',86400,'COMPLETE');
 AddServiceGroup('Citycom');
      AddService('Cityaccess');
        AddMachine('WlanController','109.73.148.178',tmCC);
           AddDiskSpaceTestCase('172.17.0.1','WLANC_SPACE_USR','Diskspace on WLANC /usr','/usr');
           AddDiskSpaceTestCase('172.17.0.1','WLANC_SPACE_VAR','Diskspace on WLANC /var','/var');
           AddTestCase('Cityaccess CPU Load');
           AddProcessTestCase('172.17.0.1','WLANC_PROCESS','Processes on WLAN Controller',TFRE_DB_StringArray.Create('squid','httpd','dhcpd','named','postgres','cron'),TFRE_DB_UInt32Array.Create(1,1,1,1,1,1));
           AddCityaccessAPTestCase;
      AddService('Small Business Firewall');
        AddMachine('SBFW','109.73.149.68',tmCC);
           AddZFSSpaceTestCase('109.73.149.68','ZFS_SPACE_SBFW','Zones SBFW Space');
           AddCPUTestCase('109.73.149.68','CPU_SBFW','CPU Load SBFW',4,8);
           AddSBFWZones;

   coll_testcase.ForAll(@_create_jobdbo);

   cronl := TStringList.Create;
   try
     coll_testcase.ForAll(@_create_cronjobs);
     cronl.SaveToFile(cFRE_HAL_CFG_DIR+'cronjobs');
   finally
     cronl.Free;
   end;

   CreateAlert;

   jobdbo.SaveToFile(cFRE_HAL_CFG_DIR+'jobs.dbo');
   writeln(jobdbo.DumpToString);
   //abort;
 end;


procedure TFRE_DB_SCP_JOB.InternalSetup;
begin
  inherited InternalSetup;
  FNamedObject.ObjectName := 'SCPMONITORING';
  Field('MAX_ALLOWED_TIME').AsInt32 := 10;
end;


function TFRE_DB_SCP_JOB.IMI_Do_the_Job(const input: IFRE_DB_Object): IFRE_DB_Object;
var proc          : TFRE_Process;
    outs,errors   : string;
    res           : integer;
    statussummary : string;
    status        : string;

    function      DeleteJobs : boolean;
    var
      istrings      : IFOS_STRINGS;
      i             : integer;
    begin
      result        :=  true;
      istrings      :=  GFRE_TF.Get_FOS_Strings;
      GFRE_BT.List_Files(cFRE_JOB_RESULT_DIR,istrings,1,true);        // List All Files
//      writeln (istrings.Commatext);
      for i:= 0 to istrings.Count-1 do begin
        if DeleteFile(istrings.Items[i])=false then begin
          Field('FAILEDTODELETE').AddString(istrings.Items[i]);
          result :=false;
        end;
      end;
    end;

begin
  Field('starttime').AsDateTimeUTC:=GFRE_DT.Now_UTC;
  proc := TFRE_Process.Create(nil);
  try
    res := proc.ExecutePiped('scp',TFRE_DB_StringArray.Create('-r','-i'+cFRE_HAL_CFG_DIR+cFRE_MONITORING_KEY_FILE,cFRE_JOB_RESULT_DIR,cFRE_MONITORING_USER+'@'+cFRE_MONITORING_HOST+':'+cFRE_MONITORING_DEST_DIR),'',outs,errors);
    if res=0 then begin
      if DeleteJobs then begin
        statussummary                   := Format ('SCP TO [%s] SUCCESSFUL',[cFRE_MONITORING_HOST]);
        status                          := 'OK';
      end else begin
        statussummary                   := Format ('SCP TO [%s] SUCCESSFUL, DELETE OF FILES FAILED',[cFRE_MONITORING_HOST]);
        status                          := 'WARNING';
      end;
    end else begin
      statussummary                   := Format ('SCP FAILED RESULTCODE:[%d] OUTPUT:[%s] ERROR:[%s]',[res,outs,errors]);
      status                          := 'FAILURE';
    end;
    Field('status').AsString        := status;
    Field('statussummary').AsString := statussummary;
  finally
    proc.Free;
  end;
  Field('endtime').AsDateTimeUTC:=GFRE_DT.Now_UTC;
end;


procedure TFRE_AlertHTMLJob.InternalSetup;
begin
  inherited InternalSetup;
  Field('MAX_ALLOWED_TIME').AsInt32 := 55;
end;

class procedure TFRE_AlertHTMLJob.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;


procedure TFRE_AlertHTMLJob.ExecuteTest;
var actmon  : IFRE_DB_Object;
    html    : TStringList;
    alert   : TFRE_Alert;

  procedure Htmljobs (const fld :IFRE_DB_Field);
  var jobresult : IFRE_DB_Object;
      ihosts    : integer;
      host      : IFRE_DB_Object;
      bgcolor   : string;
  begin
    if (fld.FieldType=fdbft_Object) then begin
//      if Pos('CITYACCESS',fld.FieldName)=0 then exit;
      jobresult := fld.AsObject;
      if (jobresult.Field('information').asstring<>'') and (jobresult.FieldExists('hosts')) then begin
        html.add('<h2>'+jobresult.Field('information').asstring+'</h2>');
        html.Add('<table border="1" cellpadding="1" cellspacing="1" style="width: 100%;">');
        html.Add('<col width="100"><col width="100"><col width="100"><col width="100"><col width="100">');
        html.Add('<tbody>');
        for ihosts := 0 to jobresult.Field('hosts').Valuecount-1 do begin
          host     := jobresult.Field('hosts').AsObjectItem[ihosts];
          case host.Field('status').asstring of
            'OK'       : bgcolor := ' bgcolor="White"';
            'WARNING'  : bgcolor := ' bgcolor="Orange"';
            'FAILURE'  : bgcolor := ' bgcolor="Red"';
            else
              bgcolor := '';
          end;
          html.Add('<tr'+bgcolor+'>');
          html.Add('<td>'+host.Field('host').asstring+'</td>');
          html.Add('<td>'+host.Field('information').asstring+'</td>');
          html.Add('<td>'+jobresult.Field('starttime').asstring+'</td>');
          html.Add('<td>'+host.Field('status').asstring+'</td>');
          html.Add('<td>'+host.Field('statussummary').asstring+'</td>');
          html.Add('<td>'+host.Field('detailsummary').asstring+'</td>');
          html.Add('</tr>');
        end;
        html.Add('</tbody>');
        html.Add('</table>');
      end else begin
        html.add('<h2>'+fld.FieldName+'</h2>');
        html.Add('<table border="1" cellpadding="1" cellspacing="1" style="width: 100%;">');
        html.Add('<col width="100"><col width="100"><col width="100"><col width="100"><col width="100">');
        html.Add('<tbody>');
        case jobresult.Field('status').asstring of
          'OK'       : bgcolor := ' bgcolor="White"';
          'WARNING'  : bgcolor := ' bgcolor="Orange"';
          'FAILURE'  : bgcolor := ' bgcolor="Red"';
          else
            bgcolor := '';
        end;
        html.Add('<tr'+bgcolor+'>');
        html.Add('<td>'+jobresult.Field('starttime').asstring+'</td>');
        html.Add('<td>'+jobresult.Field('status').asstring+'</td>');
        html.Add('<td>'+jobresult.Field('statussummary').asstring+'</td>');
        html.Add('</tr>');
        html.Add('</tbody>');
        html.Add('</table>');
      end;
    end;
  end;

begin
  try
    actmon   := GetActualMonitoring;
    alert    := TFRE_Alert.Create;
    try
      alert.CheckAlerting(actmon);
      alert.SendAlerts;
    finally
      alert.Free;
    end;
//    writeln(actmon.DumpToString());
    html     := TStringList.Create;
    try
      html.Add('<html>');
      html.Add('<body>');
      actmon.ForAllFields(@htmljobs);
      html.Add('</body>');
      html.Add('</html>');
      html.SaveToFile(cFRE_HAL_CFG_DIR+'monitor.html');
    finally
      html.Free;
    end;
    SetStatus(StatusOK,'AlertHTML Done');
  except on E: Exception do begin
    SetStatus(StatusFailure,'Exception:'+E.Message);
  end; end;
end;

{ TFRE_DB_MONSYS_MOD }

class procedure TFRE_DB_MONSYS_MOD.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION_MODULE');
end;

procedure TFRE_DB_MONSYS_MOD.SetupAppModuleStructure;
begin
  inherited SetupAppModuleStructure;
  InitModuleDesc('$monitoring_description');
end;


procedure TFRE_DB_MONSYS_MOD.MySessionInitializeModule(const session: TFRE_DB_UserSession);
var dc_monitoring : IFRE_DB_DERIVED_COLLECTION;
    tr_Monitoring : IFRE_DB_SIMPLE_TRANSFORM;
    conn          : IFRE_DB_CONNECTION;

begin
  inherited;
  if session.IsInteractiveSession then begin
    conn:=session.GetDBConnection;
    GFRE_DBI.NewObjectIntf(IFRE_DB_SIMPLE_TRANSFORM,tr_Monitoring);
    with tr_Monitoring do begin
      AddOneToOnescheme('status_icon','','Status',dt_icon);
      AddMatchingReferencedField('testcase','displayname','displayname','Testfunktion');
      AddOneToOnescheme('statusupdatetime','','Statusupdate',dt_date);
      AddOneToOnescheme('statussummary','','Statusinformation');
      AddMatchingReferencedField (['testcase','machine'],'objname','machine','Gerät');
      AddMatchingReferencedField (['testcase','machine'],'ip','ip','IP-Adresse');
      AddMatchingReferencedField (['testcase','machine'],'displayaddress','address','Aufstellungsort'); // -> TODO Fix to vali reflink specifier syntax
  //    AddMatchingReferencedField('status_uid','status_icon','','Icon',dt_icon);
  //    AddMatchingReferencedField('status_uid','provisioned_time','','ProvTime',dt_date);
  //    AddMatchingReferencedField('status_uid','online_time','','Last Online',dt_date);
    end;

    dc_monitoring := session.NewDerivedCollection('main_monsys');
    with dc_monitoring do begin
      SetDeriveParent(conn.GetCollection('testcasestatus'));
      SetDeriveTransformation(tr_Monitoring);
      SetDisplayType(cdt_Listview,[cdgf_ShowSearchbox,cdgf_ColumnDragable,cdgf_ColumnHideable,cdgf_ColumnResizeable],'Monitoring',nil,'',nil,nil,TFRE_DB_SERVER_FUNC_DESC.create.Describe(self,'TestcaseStatus_Details'));
    end;
  end;
end;

function TFRE_DB_MONSYS_MOD.IMI_Content(const input: IFRE_DB_Object): IFRE_DB_Object;
var  dc_monitoring : IFRE_DB_DERIVED_COLLECTION;
     lvd_Monitoring   : TFRE_DB_VIEW_LIST_DESC;
begin
  dc_monitoring := GetSession(input).FetchDerivedCollection('main_monsys');
  lvd_Monitoring := dc_monitoring.GetDisplayDescription as TFRE_DB_VIEW_LIST_DESC;
  lvd_Monitoring.AddButton.Describe(TFRE_DB_SERVER_FUNC_DESC.create.Describe(Self,'Update'),'images_apps/monitoring/update.png','Update');
  lvd_Monitoring.AddButton.Describe(TFRE_DB_SERVER_FUNC_DESC.create.Describe(Self,'CheckActuality'),'images_apps/monitoring/update.png','Check Actuality');
  lvd_Monitoring.AddButton.Describe(TFRE_DB_SERVER_FUNC_DESC.create.Describe(Self,'ClearFailure'),'images_apps/monitoring/clear.png','Clear Failure');
  result := TFRE_DB_LAYOUT_DESC.create.Describe.SetLayout(lvd_Monitoring,nil,nil,nil,nil,true,1);
end;

function TFRE_DB_MONSYS_MOD.IMI_Update(const input: IFRE_DB_Object): IFRE_DB_Object;
begin
  UpdateMonitoring(GetDBConnection(input));
  result := GFRE_DB_NIL_DESC;
end;


function TFRE_DB_MONSYS_MOD.IMI_CheckActuality(const input: IFRE_DB_Object): IFRE_DB_Object;
var col       : IFRE_DB_COLLECTION;
    obj       : IFRE_DB_Object;

  procedure _checkactual(const obj:IFRE_DB_Object);
  begin
    if not obj.IsA(TFRE_DB_TestcaseStatus.ClassName) then begin
      writeln('FETCHED OBJ ',obj.UID_String,' IS BAD!');
    end else begin
      TFRE_DB_TestcaseStatus(obj.Implementor_HC).IMI_CheckActuality(input);
      GetDBConnection(input).Update(obj);
    end;
  end;

begin
  writeln('check actuality');
  col       := GetDBConnection(input).GetCollection('testcasestatus');
  col.ForAll(@_checkactual);
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DB_MONSYS_MOD.IMI_ClearFailure(const input: IFRE_DB_Object): IFRE_DB_Object;
var col       : IFRE_DB_COLLECTION;
    upd_guids : TFRE_DB_GUIDArray;
    i         : integer;
    obj       : IFRE_DB_Object;
begin
  col       := GetDBConnection(input).GetCollection('testcasestatus');
  upd_guids :=  GFRE_DBI.StringArray2GuidArray(input.Field('SELECTED').AsStringArr);
  for i:=0 to high(upd_guids) do begin
    if col.Fetch(upd_guids[i],obj) then begin
      if not obj.IsA(TFRE_DB_TestcaseStatus.ClassName) then begin
        writeln('FETCHED OBJ ',obj.UID_String,' IS BAD!');
      end else begin
        TFRE_DB_TestcaseStatus(obj.Implementor_HC).IMI_ClearStatus(input);
        GetDBConnection(input).Update(obj);
      end;
    end else begin
      writeln('Could not fetch : '+GFRE_BT.GUID_2_HexString(upd_guids[i]));
    end;
  end;
  result := GFRE_DB_NIL_DESC;
end;

function TFRE_DB_MONSYS_MOD.IMI_TestcaseStatus_Details(const input: IFRE_DB_Object): IFRE_DB_Object;
var   sub     : TFRE_DB_SUBSECTIONS_DESC;
      sf      : TFRE_DB_SERVER_FUNC_DESC;
      dc      : IFRE_DB_DERIVED_COLLECTION;
begin
  if input.FieldExists('SELECTED') then begin
//    writeln(GFRE_BT.GUID_2_HexString(input.Field('SELECTED').AsGUID));
    sub := TFRE_DB_SUBSECTIONS_DESC.Create.Describe(sec_dt_tab);
    sf := TFRE_DB_SERVER_FUNC_DESC.Create.Describe(Self,'TestcaseStatus_Report');
    sf.AddParam.Describe('guid',GFRE_BT.GUID_2_HexString(input.Field('SELECTED').asguid));
    sub.AddSection.Describe(sf,'Details',1);
    sf := TFRE_DB_SERVER_FUNC_DESC.Create.Describe(Self,'TestcaseStatus_Troubleshooting');
    sf.AddParam.Describe('guid',GFRE_BT.GUID_2_HexString(input.Field('SELECTED').asguid));
    sub.AddSection.Describe(sf,'Troubleshooting',2);
    result := sub;
  end;
end;

function TFRE_DB_MONSYS_MOD.IMI_TestcaseStatus_Report(const input: IFRE_DB_Object): IFRE_DB_Object;
var obj : IFRE_DB_Object;
    s   : string;
begin
//  writeln(input.DumpToString);
  GetDBConnection(input).Fetch(GFRE_BT.HexString_2_GUID(input.Field('guid').AsString),obj);
  if assigned(obj) then begin
    s      := obj.Field('actual_result').AsObject.DumpToString;
    s      := FREDB_String2EscapedJSString('<pre style="font-size: 10px">'+s+'</pre>');
    result := TFRE_DB_HTML_DESC.create.Describe(s);
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('NO RESULT');
  end;
end;

function TFRE_DB_MONSYS_MOD.IMI_TestcaseStatus_Troubleshooting(const input: IFRE_DB_Object): IFRE_DB_Object;
var obj : IFRE_DB_Object;
    s   : string;
begin
//  writeln('trouble');
  GetDBConnection(input).Fetch(GFRE_BT.HexString_2_GUID(input.Field('guid').AsString),obj);
  if Assigned(obj) then begin
    GetDBConnection(input).Fetch(obj.Field('testcase').AsGUID,obj);
    if Assigned(obj) then begin
      s      :=obj.Field('troubleshooting').Asstring;
      s      := '<code>'+StringReplace(s,LineEnding,'<br />',[rfReplaceAll])+'</code>';
      result := TFRE_DB_HTML_DESC.create.Describe(s);
    end;
  end else begin
    result := TFRE_DB_HTML_DESC.create.Describe('NO INFORMATION');
  end;
end;


{ TFRE_DB_MONSYS }

procedure TFRE_DB_MONSYS.SetupApplicationStructure;
begin
  InitAppDesc('$description');
  AddApplicationModule(TFRE_DB_MONSYS_MOD.create);
end;


procedure TFRE_DB_MONSYS._UpdateSitemap(const session: TFRE_DB_UserSession);
var
  SiteMapData  : IFRE_DB_Object;
  conn         : IFRE_DB_CONNECTION;
begin
  conn:=session.GetDBConnection;
  SiteMapData  := GFRE_DBI.NewObject;
  FREDB_SiteMap_AddRadialEntry(SiteMapData,'Monitoring','Monitoring','images_apps/monitoring/monitor_white.svg','',0,conn.sys.CheckClassRight4MyDomain(sr_FETCH,TFRE_DB_MONSYS));
  FREDB_SiteMap_RadialAutoposition(SiteMapData);
  session.GetSessionAppData(Classname).Field('SITEMAP').AsObject := SiteMapData;
end;

procedure TFRE_DB_MONSYS.MySessionInitialize(const session: TFRE_DB_UserSession);
begin
  inherited MySessionInitialize(session);
  if session.IsInteractiveSession then begin
    _UpdateSitemap(session);
  end;
end;

procedure TFRE_DB_MONSYS.MySessionPromotion(const session: TFRE_DB_UserSession);
begin
  inherited MySessionPromotion(session);
  if session.IsInteractiveSession then
    _UpdateSitemap(session);
end;

function TFRE_DB_MONSYS.ShowInApplicationChooser(const session: IFRE_DB_UserSession): Boolean;
begin
  Result := true;
end;

class procedure TFRE_DB_MONSYS.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName('TFRE_DB_APPLICATION');
  scheme.AddSchemeFieldSubscheme('monsysmod'      , 'TFRE_DB_MONSYS_MOD');
end;

class procedure TFRE_DB_MONSYS.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  inherited;

  newVersionId:='1.0';

  if (currentVersionId='') then
    begin
      CreateAppText(conn,'$caption','Monitoring','Monitoring','Monitoring');
      CreateAppText(conn,'$monitoring_description','Monitoring','Monitoring','Monitoring');

      currentVersionId:='1.0';
    end;
  if (currentVersionId='1.0') then
    begin
    //next update code
    end;
end;

class procedure TFRE_DB_MONSYS.InstallDBObjects4Domain(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; domainUID: TGUID);
begin
  inherited InstallDBObjects4Domain(conn, currentVersionId, domainUID);
end;

{ TFRE_DB_Monitoring }

class procedure TFRE_DB_Monitoring.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.SetParentSchemeByName  ('TFRE_DB_OBJECTEX');
end;

function TFRE_DB_Monitoring.WEB_FullStatusUpdate(const input: IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;

  procedure _dopartialupdate(const fld : IFRE_DB_Field);
  begin
//    writeln(fld.FieldName);
    if (fld.FieldType = fdbft_Object) then begin
      fld.AsObject.Field('jobkey').AsString := fld.FieldName;
      WEB_PartialStatusUpdate(fld.AsObject,ses,app,conn);
    end;
  end;

begin
  input.ForAllFields(@_dopartialupdate);
end;

function TFRE_DB_Monitoring.WEB_PartialStatusUpdate(const input: IFRE_DB_OBject; const ses: IFRE_DB_Usersession; const app: IFRE_DB_APPLICATION; const conn: IFRE_DB_CONNECTION): IFRE_DB_Object;
var jobkey              : string;
    coll_testcase       : IFRE_DB_COLLECTION;
    testcase_dbo        : IFRE_DB_Object;
    testcase_status_ids : TFRE_DB_GUIDArray;
    testcase_status_dbo : IFRE_DB_Object;
    itcs                : integer;
begin
  jobkey        := input.Field('jobkey').AsString;
  coll_testcase := conn.GetCollection('testcase');
  if coll_testcase.GetIndexedObj(jobkey,testcase_dbo) then begin

  //  testcase_status_ids := testcase_dbo.ReferencedByList('TFRE_DB_TestcaseStatus'); DEPRECATED
    testcase_status_ids := conn.GetReferences(testcase_dbo.UID,false,'TFRE_DB_TestcaseStatus');
    for itcs := low(testcase_status_ids) to high(testcase_status_ids) do begin
      conn.Fetch(testcase_status_ids[itcs],testcase_status_dbo);
      if testcase_status_dbo.Field('actual').AsBoolean = true then begin
       //TFRE_DB_TestcaseStatus(testcase_status_dbo.Implementor_HC).WEB_UpdateActualStatus(input,ses,app,conn); NOT SO CUTE
        testcase_status_dbo.Invoke('WEB_UpdateActualStatus',input,ses,app,conn);
      end;
    end;
  end else begin
    raise EFOS_MONITORING_Exception.Create('TESTCASE WITH JOBKEY DOES NOT EXIST :'+jobkey);  // TODO LOG
  end;
end;


procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_Monitoring);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MONSYS_MOD);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_MONSYS);
  GFRE_DBI.RegisterObjectClassEx(TFRE_AlertHTMLJob);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_SCP_JOB);
  GFRE_DBI.Initialize_Extension_Objects;
end;

procedure DummyDoJobs;
begin
  //DO_SaveJob('MONFOS_INTERNETTESTCASE',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZPOOL_FOS_LIVEPOOL',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_MAILKSM',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_MAILKSM_CHECK',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_WINRM_KSM_SBS',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZPOOL_KSM_LIVEPOOL',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZFS_REPL_KSMLINUX',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_ZFS_REPL_KSMLINUXCHECK',cFRE_HAL_CFG_DIR+'jobs.dbo');
  //DO_SaveJob('MONFOS_KSM_SBS_FILESHARE',cFRE_HAL_CFG_DIR+'jobs.dbo');
  DO_SaveJob('MONFOS_CITYACCESS_AP_CITYBEACH',cFRE_HAL_CFG_DIR+'jobs.dbo');
  DO_SaveJob('MONFOS_CITYACCESS_AP_JOANNEUM',cFRE_HAL_CFG_DIR+'jobs.dbo');
end;

function GetActualMonitoring : IFRE_DB_Object;
var
  istrings      : IFOS_STRINGS;
  i             : integer;
  job           : IFRE_DB_Object;
  nowt          : int64;
  newname       : string;
  dir           : string;

begin
  result        := GFRE_DBI.NewObject;
  istrings      :=  GFRE_TF.Get_FOS_Strings;


  GFRE_BT.List_Files(cFRE_JOB_RESULT_DIR,istrings,1,true);        // List All Files
  if istrings.Count>0 then begin
    nowt         := GFRE_DT.Now_UTC;
    dir          := cFRE_JOB_ARCHIVE_DIR+DirectorySeparator+inttostr(nowt);
    ForceDirectories(dir);
  end;

  for i:= 0 to istrings.Count-1 do begin
    job := GFRE_DBI.CreateFromFile(istrings[i]);
    result.Field(job.Field('objname').asstring).asobject := job.Field('R').asobject;
    newname := StringReplace(istrings[i],cFRE_JOB_RESULT_DIR,dir,[]);
    if RenameFile(istrings[i],newname)=false then begin
      raise EFOS_MONITORING_Exception.Create('CANT RENAME JOB '+istrings[i]+' '+newname);;
    end;
  end;

end;

procedure UpdateMonitoring(const conn: IFRE_DB_CONNECTION);
var
  actmon        : IFRE_DB_Object;
  coll_mon      : IFRE_DB_COLLECTION;
  mon           : IFRE_DB_Object;
  hlt           : boolean;


  procedure _getmon(const obj:IFRE_DB_Object ; var halt : boolean);
  begin
    mon   := obj;
  end;

begin
  actmon        :=  GetActualMonitoring;

  coll_mon  := CONN.GetCollection('monitoring');
//  writeln ('COUNT:',coll_mon.Count);
  hlt := true; // get first
  coll_mon.ForAllBreak(@_getmon,hlt);
//  writeln(mon.DumpToString);

  abort;
  //FIXME ? Dangling global Method ?
  //TFRE_DB_Monitoring(mon.Implementor_HC).WEB_FullStatusUpdate(actmon);
end;

procedure MONSYS_MetaRegister;
begin
  FRE_DBBUSINESS.Register_DB_Extensions;
  fre_testcase.Register_DB_Extensions;
  fre_hal_schemes.Register_DB_Extensions;
  fos_monitoring_app.Register_DB_Extensions;
  FRE_ZFS.Register_DB_Extensions;
end;

procedure MONSYS_MetaInitializeDatabase(const dbname: string; const user, pass: string);
begin
  writeln('METAINIT MONSYS');
  InitializeMonitoring;
  CreateMonitoringDB(dbname,user,pass);
end;

procedure MONSYS_MetaRemove(const dbname: string; const user, pass: string);
var conn  : IFRE_DB_SYS_CONNECTION;
    res   : TFRE_DB_Errortype;
begin
  CONN := GFRE_DBI.NewSysOnlyConnection;
  try
    res  := CONN.Connect('admin@system','admin');
    if res<>edb_OK then gfre_bt.CriticalAbort('cannot connect system : %s',[CFRE_DB_Errortype[res]]);
  finally
    conn.Finalize;
  end;
end;

initialization
  GFRE_DBI_REG_EXTMGR.RegisterNewExtension('MONSYS',@MONSYS_MetaRegister,@MONSYS_MetaInitializeDatabase,@MONSYS_MetaRemove);

end.

