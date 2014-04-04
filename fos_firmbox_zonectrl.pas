unit fos_firmbox_zonectrl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,unix,ctypes,unixtype,fos_illumos_defs,fosillu_priv,fosillu_libzonecfg,fosillu_priv_names,
  fos_tool_interfaces,fosillu_libzfs;

const
  CMD_HELP      =   0;
  CMD_BOOT      =   1;
  CMD_HALT      =   2;
  CMD_READY     =   3;
  CMD_SHUTDOWN  =   4;
  CMD_REBOOT    =   5;
  CMD_LIST      =   6;
  CMD_VERIFY    =   7;
  CMD_INSTALL   =   8;
  CMD_UNINSTALL =   9;
  CMD_MOUNT     =  10;
  CMD_UNMOUNT   =  11;
  CMD_CLONE     =  12;
  CMD_MOVE      =  13;
  CMD_DETACH    =  14;
  CMD_ATTACH    =  15;
  CMD_MARK      =  16;
  CMD_APPLY     =  17;
  CMD_SYSBOOT   =  18;
  CMD_MIN       =  CMD_HELP;
  CMD_MAX       =  CMD_SYSBOOT;

type
  zone_entry_t=record
    valid      : boolean;
    error      : string;
    zid        : zoneid_t;
    zname      : string;
    zstate     : string;
    zstate_num : zone_state_t;
    zbrand     : string;
    zroot      : string;
    zuuid      : string;
    ziptype    : zone_iptype_t;
  end;

  PZone_entry_t = ^zone_entry_t;

var zents  : array of zone_entry_t;
    nzents : uint_t;

procedure sanity_check(zone : string; cmd_num : integer; running, unsafe_when_running, force : boolean);

procedure list_zones;

implementation

procedure lookup_zone_info(const zone_name:string; zid : zoneid_t ; var zent : zone_entry_t);
var uuid   : uuid_t;
    scratch: string;
    flags  : cint;
    handle : zone_dochandle_t;
begin
 uuid := Default(uuid_t);
 zent.zname  := zone_name;
 zent.zbrand := '?';
 zent.zroot  := '?';
 zent.zstate := '?';
 zent.valid  := true;
 zent.zid    := zid;
 try
   if zonecfg_get_uuid(Pchar(zone_name),uuid)=0 then
     begin
       zent.zuuid := GFRE_BT.GUID_2_HexString(uuid);
     end;
    SetLength(scratch,MAXPATHLEN);
    if zone_get_zonepath(Pchar(zone_name),@scratch[1],Length(scratch))<>0 then
      raise Exception.create('cannot get zonepath');
 //   zent.zroot:=copy(pchar(scratch),1,maxint);
    zent.zroot := pchar(scratch);

    if ((zone_get_state(pchar(zone_name), @zent.zstate_num)) <> Z_OK) then
      raise Exception.create('cannot get zonestate');
    zent.zstate := zone_state_str(zent.zstate_num);

    SetLength(scratch,256);
    if zone_get_brand(pchar(zone_name),@scratch[1],length(scratch))<>0 then
      raise Exception.create('cannot get zonebrand');
    zent.zbrand := copy(pchar(scratch),1,maxint);
    if (zent.zid=ZONE_ID_UNDEFINED) and (zent.zstate_num=ZONE_STATE_RUNNING) then
       zent.zid := getzoneidbyname(Pchar(zone_name));
    if zent.zid=GLOBAL_ZONEID then
      begin
        zent.ziptype:=ZS_SHARED;
        exit;
      end;

    if (zent.zstate_num=ZONE_STATE_RUNNING) and (zent.zid<>ZONE_ID_UNDEFINED) then
      begin
         if zone_getattr(zent.zid,ZONE_ATTR_FLAGS,@flags,sizeof(flags))<=0 then
           raise Exception.create('cannot get zone attr');
         if (flags and ZF_NET_EXCL)=ZF_NET_EXCL then
           zent.ziptype:=ZS_EXCLUSIVE
         else
           zent.ziptype:=ZS_SHARED;
        exit;
      end;
      handle := zonecfg_init_handle();
      if handle = Nil then
        raise Exception.create('could not init handle');

      if zonecfg_get_handle(pchar(zone_name), handle)<>0 then
        begin
          zonecfg_fini_handle(handle);
          raise Exception.create('could not get handle');
        end;

      if zonecfg_get_iptype(handle,@zent.ziptype)<>0 then
        begin
          zonecfg_fini_handle(handle);
          raise Exception.create('could not get iptype');
        end;
      zonecfg_fini_handle(handle);
  except
    on e:exception do
      begin
        zent.valid:=false;
        zent.error:=e.Message;
      end;
  end;
end;


function fetch_zents():boolean;
var zids         : array of zoneid_t;
    nzents_saved : uint_t;
    i,retv       : cint;
    zentp        : PZone_entry_t;
    name         : string;
    label again;
begin
  result := false;
  if (nzents > 0) then
    exit(true);
 if zone_list(nil, nzents)<>0 then
   raise EXception.create('failed to get zoneid list');

again:
  if (nzents =0) then
    exit(true);

  SetLength(zids,nzents);
  nzents_saved := nzents;

  if (zone_list(@zids[0], nzents) <> 0) then
    raise Exception.Create('failed to get zonelist');


 if (nzents <> nzents_saved) then
   goto again;

 SetLength(zents,nzents);

 for i:=0 to high(zents) do
   begin
     name := fos_getzonenamebyid(zids[i]);
     if name='' then
       begin
         zents[i].valid := false;
         continue;
       end;
     lookup_zone_info(name,zids[i],zents[i]);
   end;
end;

procedure lookup_running_zone(const str:string;var result:zone_entry_t);
var i : integer;
begin
  result := default(zone_entry_t);
  if not fetch_zents then
    exit;
  for i := 0 to high(zents) do
    begin
      if str=zents[i].zname then
        begin
          result :=zents[i];
          break;
        end;
    end;
end;

procedure sanity_check(zone : string; cmd_num : integer; running, unsafe_when_running, force : boolean);
var
  zent             : zone_entry_t;
  privset          : Ppriv_set_t ;
  state, min_state : zone_state_t ;
  kernzone         : string[ZONENAME_MAX];
  fp               : FILE;
begin
 if getzoneid<>GLOBAL_ZONEID then
   raise Exception.Create('must be in global zone to use administrative functions');
 privset := nil;
 privset := priv_allocset;
 if not assigned(privset) then
   raise Exception.Create('could not allocate privset');
 if getppriv(PRIV_EFFECTIVE,privset)<>0 then
   raise Exception.Create('privset');
 if priv_isfullset(privset)=B_FALSE then
   raise Exception.Create('must be a privileged user');
 writeln('SANITY OK');
 priv_freeset(privset);

 if (zonecfg_in_alt_root=B_TRUE) then
   raise Exception.Create('zone in alternate root not supported');
 lookup_running_zone(zone,zent);
 if running and (not force) then
   begin
     if zent.valid=false then
       raise Exception.Create('zone not running');
   end
 else
   begin
     //if (unsafe_when_running && zent != NULL) {
     //        /* check whether the zone is ready or running */
     //        if ((err = zone_get_state(zent->zname,
     //            &zent->zstate_num)) != Z_OK) {
     //                errno = err;
     //                zperror2(zent->zname,
     //                    gettext("could not get state"));
     //                /* can't tell, so hedge */
     //                zent->zstate_str = "ready/running";
     //        } else {
     //                zent->zstate_str =
     //                    zone_state_str(zent->zstate_num);
     //        }
     //        zerror(gettext("%s operation is invalid for %s zones."),
     //            cmd_to_str(cmd_num), zent->zstate_str);
     //        return (Z_ERR);
     //}
     //if ((err = zone_get_state(zone, &state)) != Z_OK) {
     //        errno = err;
     //        zperror2(zone, gettext("could not get state"));
     //        return (Z_ERR);
     //}
     //switch (cmd_num) {
     //case CMD_UNINSTALL:
     //        if (state == ZONE_STATE_CONFIGURED) {
     //                zerror(gettext("is already in state '%s'."),
     //                    zone_state_str(ZONE_STATE_CONFIGURED));
     //                return (Z_ERR);
     //        }
     //        break;
     //case CMD_ATTACH:
     //        if (state == ZONE_STATE_INSTALLED) {
     //                zerror(gettext("is already %s."),
     //                    zone_state_str(ZONE_STATE_INSTALLED));
     //                return (Z_ERR);
     //        } else if (state == ZONE_STATE_INCOMPLETE && !force) {
     //                zerror(gettext("zone is %s; %s required."),
     //                    zone_state_str(ZONE_STATE_INCOMPLETE),
     //                    cmd_to_str(CMD_UNINSTALL));
     //                return (Z_ERR);
     //        }
     //        break;
     //case CMD_CLONE:
     //case CMD_INSTALL:
     //        if (state == ZONE_STATE_INSTALLED) {
     //                zerror(gettext("is already %s."),
     //                    zone_state_str(ZONE_STATE_INSTALLED));
     //                return (Z_ERR);
     //        } else if (state == ZONE_STATE_INCOMPLETE) {
     //                zerror(gettext("zone is %s; %s required."),
     //                    zone_state_str(ZONE_STATE_INCOMPLETE),
     //                    cmd_to_str(CMD_UNINSTALL));
     //                return (Z_ERR);
     //        }
     //        break;
     //case CMD_DETACH:
     //case CMD_MOVE:
     //case CMD_READY:
     //case CMD_BOOT:
     //case CMD_MOUNT:
     //case CMD_MARK:
     //        if ((cmd_num == CMD_BOOT || cmd_num == CMD_MOUNT) &&
     //            force)
     //                min_state = ZONE_STATE_INCOMPLETE;
     //        else if (cmd_num == CMD_MARK)
     //                min_state = ZONE_STATE_CONFIGURED;
     //        else
     //                min_state = ZONE_STATE_INSTALLED;
     //
     //        if (state < min_state) {
     //                zerror(gettext("must be %s before %s."),
     //                    zone_state_str(min_state),
     //                    cmd_to_str(cmd_num));
     //                return (Z_ERR);
     //        }
     //        break;
     //case CMD_VERIFY:
     //        if (state == ZONE_STATE_INCOMPLETE) {
     //                zerror(gettext("zone is %s; %s required."),
     //                    zone_state_str(ZONE_STATE_INCOMPLETE),
     //                    cmd_to_str(CMD_UNINSTALL));
     //                return (Z_ERR);
     //        }
     //        break;
     //case CMD_UNMOUNT:
     //        if (state != ZONE_STATE_MOUNTED) {
     //                zerror(gettext("must be %s before %s."),
     //                    zone_state_str(ZONE_STATE_MOUNTED),
     //                    cmd_to_str(cmd_num));
     //                return (Z_ERR);
     //        }
     //        break;
     //case CMD_SYSBOOT:
     //        if (state != ZONE_STATE_INSTALLED) {
     //                zerror(gettext("%s operation is invalid for %s "
     //                    "zones."), cmd_to_str(cmd_num),
     //                    zone_state_str(state));
     //                return (Z_ERR);
     //        }
     //        break;
     //}
   end;
end;

procedure list_zones;
var
    i      : Integer;
    cookie : PFILE;
    name   : string;
    cname  : PChar;
    zent   : zone_entry_t;

begin
 //fetch_zents;
 //for i := 0 to high(zents) do
 //  begin
 //    with zents[i] do
 //      writeln(valid,' ',error,' ',zid,' ',zname,' ',ziptype,' ',zroot,' ',zstate,' ',zstate_num,' ',zuuid,' ',zbrand);
 //  end;
   cookie := setzoneent;
   repeat
      cname := getzoneent(cookie);
      if not assigned(cname) then
        break;
      name  := string(cname);
      illu_Free(cname);
      lookup_zone_info(name,ZONE_ID_UNDEFINED,zent);
      with zent do
        writeln(valid,' ',error,' ',zid,' ',zname,' ',ziptype,' ',zroot,' ',zstate,' ',zstate_num,' ',zuuid,' ',zbrand);
   until false;
   endzoneent(cookie);
   //sleep(1000);
   //writeln;
   //writeln;
end;



end.

