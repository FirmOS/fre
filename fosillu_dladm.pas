unit fosillu_dladm;

{$mode objfpc}{$H+}
{$codepage utf-8}
{$modeswitch advancedrecords }

interface

uses
  Classes, SysUtils,fre_db_interface,
  fos_illumos_defs,
  fosillu_libscf,
  fosillu_nvpair,
  fosillu_libdladm,
  fosillu_libdlaggr,
  ctypes, fosillu_sysnet_common;

var GILLU_DLADM : dladm_handle_t;

const
    MAXPORT = 256;


function  create_etherstub  (const linkname : string ; out error : string):boolean;
function  delete_etherstub  (const linkname : string ; out error : string):boolean;

function  create_simnet     (const linkname : string ; out error : string):boolean;
function  delete_simnet     (const linkname : string ; out error : string):boolean;
function  connect_simnet    (const linkname : string ; const peer_linkname : string; out error : string):boolean;

function  create_bridge     (const bridgename: string; const links : TFRE_DB_StringArray; out error : string):boolean;
function  add_to_bridge     (const bridgename: string; const links : TFRE_DB_StringArray; out error : string):boolean;
function  remove_from_bridge(const bridgename: string; const links : TFRE_DB_StringArray; out error : string):boolean;
function  delete_bridge     (const bridgename: string; out error : string):boolean;

//aggregation name without numeric key, key is set in field
function  create_aggr       (const aggrname  : string; const key: int32; const links : TFRE_DB_StringArray; const aggr_policy: string; const aggr_timer: string; const aggr_lacp_mode:string; const force:boolean; out error : string): boolean;
function  add_to_aggr       (const aggrname  : string; const links : TFRE_DB_StringArray; const force : boolean; out error : string):boolean;
function  remove_from_aggr  (const aggrname  : string; const links : TFRE_DB_StringArray; out error : string):boolean;
function  delete_aggr       (const aggrname  : string; out error : string):boolean;
function  modify_aggr       (const aggrname  : string; const aggr_policy: string; const aggr_timer: string; const aggr_lacp_mode:string; out error : string): boolean;

function  create_vnic       (const vnic, for_linkname: string ; var macaddr: TFOS_MAC_ADDR; out error: String ; const for_zone:string='' ; const vid : cint = 0 ;const vrid : vrid_t = VRRP_VRID_NONE ; linkprops:string=''): boolean;
function  delete_vnic       (const linkname : string ; out error : string;const zonename:string=''):boolean;
function  rename_vnic       (const from_linkname,to_linkname : string ; out error:string ; for_zone : string=''):boolean;
function  vnic_set_linkprop (const linkname: string; out error: string; prop,val: string; const zonename: string): boolean;
function  get_linkprops     (const linkname : string ; out error:string ; for_zone : string=''):boolean;
function  get_datalink_dbo  : IFRE_DB_Object;

implementation

function aggr_policy_from_string(const aggr_policy:string):uint32_t;
begin
  case aggr_policy of
   'L2': result := AGGR_POLICY_L2;
   'L3': result := AGGR_POLICY_L3;
   'L4': result := AGGR_POLICY_L4;
  else
    raise EFRE_DB_Exception.Create('AGGREGATION: invalid policy '+aggr_policy);
  end;
end;

function aggr_timer_from_string(const aggr_timer:string):aggr_lacp_timer_t;
begin
  case aggr_timer of
   'short': result := AGGR_LACP_TIMER_SHORT;
   'long' : result := AGGR_LACP_TIMER_LONG;
  else
    raise EFRE_DB_Exception.Create('AGGREGATION: invalid lacp timer '+aggr_timer);
  end;
end;

function aggr_lacp_mode_from_string(const aggr_lacp_mode:string):aggr_lacp_mode_t;
begin
  case aggr_lacp_mode of
   'off':     result := AGGR_LACP_OFF;
   'active':  result := AGGR_LACP_ACTIVE;
   'passive': result := AGGR_LACP_PASSIVE;
  else
    raise EFRE_DB_Exception.Create('AGGREGATION: invalid aggr lacp mode '+aggr_lacp_mode);
  end;
end;

function i_vnic_set_linkprop(const link : datalink_id_t ; prop,val: string ; out error:string):boolean;
var status : dladm_status_t;
    vall   : Pchar;
begin
  vall := Pchar(val);
  status := dladm_set_linkprop(GILLU_DLADM,link,pchar(prop),@vall,1,DLADM_OPT_ACTIVE);
  result := status=DLADM_STATUS_OK;
  if not result then
    begin
      error := 'SETLINKPROP: ['+prop+'='+val+'] failed ['+CDLADM_STATUS_CODES[status]+']';
    end;
end;

function vnic_set_linkprop(const linkname: string; out error: string; prop,val: string; const zonename: string): boolean;
begin
  abort;
end;

function get_linkprops(const linkname: string; out error: string; for_zone: string): boolean;
begin
  abort;
end;

//function

function Walk_MacAddrCB (_dldbo:pointer; _pmacaddr:Pdladm_macaddr_attr_t):boolean_t; cdecl;
var macaddr_attr : dladm_macaddr_attr_t;
    dldbo        : IFRE_DB_Object;
    macdbo       : IFRE_DB_Object;
    macaddr      : TFOS_MAC_ADDR;
begin
  macaddr_attr:=_pmacaddr^;

  dldbo  := IFRE_DB_Object(_dldbo);
  macdbo := GFRE_DBI.NewObject;
  dldbo.Field(inttostr(macaddr_attr.ma_slot)).asobject:=macdbo;

  writeln('SWL WALKMAC');
  macdbo.Field('slot').asuint16  := macaddr_attr.ma_slot;
  macdbo.Field('flags').asuint16 := macaddr_attr.ma_flags;
  macdbo.Field('addrlen').asuint16 := macaddr_attr.ma_addrlen;

  if macaddr_attr.ma_addrlen<>6 then
    raise EFRE_DB_Exception.Create('UNSUPPORTED MAC ADDR LEN '+inttostr(macaddr_attr.ma_addrlen));

  Move(macaddr_attr.ma_addr,macaddr,macaddr_attr.ma_addrlen);

  macdbo.Field('macaddr').asstring       := macaddr.GetAsString;
  macdbo.Field('client_name').asstring   := StrPas(macaddr_attr.ma_client_name);
  macdbo.Field('client_linkid').asuint32 := macaddr_attr.ma_client_linkid;
  result := B_TRUE;
end;

function ShowLinkCB (_dladm_handle:dladm_handle_t; _dl_id:datalink_id_t; _dbo:pointer):longint; cdecl;
var dbo    : IFRE_DB_Object;
    status : dladm_status_t;
    dlclass: datalink_class_t;
    flags  : UInt32_t;
    media  : Uint32_t;
    link   : Array[0..MAXLINKNAMELEN-1] of char;
    error  : string;
    dldbo  : IFRE_DB_Object;
    dbocl  : string;
    res    : NativeInt;
begin
  dbo := IFRE_DB_Object(_dbo);


//  dbo.Field('linkid').asuint32:=_dl_id;
  writeln('SWL SHOWLINK CB DATALINK');

  status := dladm_datalink_id2info(_dladm_handle,_dl_id,@flags,@dlclass,@media,@link,MAXLINKNAMELEN);
  if status <>DLADM_STATUS_OK then
    begin
      error := 'DATALINK ID 2 INFO FAILED: ['+inttostr(_dl_id)+'] failed ['+CDLADM_STATUS_CODES[status]+']';
      raise EFRE_DB_Exception.Create(error);
    end;

  case dlclass of
   DATALINK_CLASS_PHYS: dbocl := 'TFRE_DB_DATALINK_PHYS';
   DATALINK_CLASS_AGGR: dbocl := 'TFRE_DB_DATALINK_AGGR';
   DATALINK_CLASS_VNIC: dbocl := 'TFRE_DB_DATALINK_VNIC';
   DATALINK_CLASS_ETHERSTUB: dbocl := 'TFRE_DB_DATALINK_STUB';
   DATALINK_CLASS_SIMNET: dbocl := 'TFRE_DB_DATALINK_SIMNET';
   DATALINK_CLASS_BRIDGE: dbocl := 'TFRE_DB_DATALINK_BRIDGE';
   DATALINK_CLASS_IPTUN:  dbocl := 'TFRE_DB_DATALINK_IPTUN';
  else
    raise EFRE_DB_Exception.Create('UNSUPPORTED CLASS '+inttostr(uint32(dlclass)));
  end;


  dldbo := GFRE_DBI.NewObjectSchemeByName(dbocl);
  dbo.Field(inttostr(_dl_id)).AsObject:= dldbo;

  dldbo.Field('datalink_id').asUint32    :=_dl_id;
  dldbo.Field('objname').asstring        := link;
  dldbo.Field('datalink_class').asuint16 := Uint16(dlclass);
  dldbo.Field('media').asuint32          := media;

  res := dladm_walk_macaddr(_dladm_handle,_dl_id,dldbo,@Walk_MacAddrCB);
  if res <>0 then
    begin
      error := 'DATALINK WALK MACADDR FAILED: ['+inttostr(_dl_id)+'] failed ';
      writeln('SWL :',error);
//      raise EFRE_DB_Exception.Create(error);
    end;
  result := DLADM_WALK_CONTINUE;
end;

function get_datalink_dbo: IFRE_DB_Object;
var status : dladm_status_t;
    cb     : dladm_walk_datalinkid_cb_t;
    state  : Pointer;
    flags  : UInt32_t;
    error  : string;
    dlclass: datalink_class_t;

begin
 writeln('SWL GET DATALINK');
 cb     := @ShowLinkCB;
 state  := nil;
 flags  := DLADM_OPT_ACTIVE;

 result := GFRE_DBI.NewObject;
 state  := result;
 dlclass := datalink_class_t(uint32(DATALINK_CLASS_PHYS)+uint32(DATALINK_CLASS_VNIC)+uint32(DATALINK_CLASS_SIMNET)+uint32(DATALINK_CLASS_AGGR)+uint32(DATALINK_CLASS_BRIDGE)+uint32(DATALINK_CLASS_ETHERSTUB));
 status := dladm_walk_datalink_id(cb,GILLU_DLADM,state,dlclass,DATALINK_ANY_MEDIATYPE,flags);
 if status <>DLADM_STATUS_OK then
   begin
     error := 'DATALINK WALK FAILED: ['+CDLADM_STATUS_CODES[status]+']';
     raise EFRE_DB_Exception.Create(error);
   end;

   writeln('SWL DBO',result.DumpToString);
end;



function create_etherstub(const linkname: string; out error: string): boolean;
var flags    : UInt32_t;
    status   : dladm_status_t;
    lname    : Pchar;
    mac_addr : array [0..ETHERADDRLEN-1] of Uchar_t;
begin
  lname  := PChar(linkname);
  if (Length(linkname)>MAXLINKNAMELEN) or (dladm_valid_linkname(lname)<>B_TRUE) then
    begin
      error := 'CREATEETHERSTUB: invalid linkname ['+linkname+']';
      exit(false);
    end;

  flags  := DLADM_OPT_ANCHOR or DLADM_OPT_ACTIVE; { non persistent per default }

  status := dladm_vnic_create(GILLU_DLADM,lname,DATALINK_INVALID_LINKID,VNIC_MAC_ADDR_TYPE_AUTO,@mac_addr,ETHERADDRLEN,nil,0,0,VRRP_VRID_NONE,AF_UNSPEC,nil,nil,flags);

  result := status = DLADM_STATUS_OK;
  if not result then
    begin
      error := 'CREATEETHERSTUB: ['+linkname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
end;

function check_etherstub_vnic(const name:PChar ; const link_id : datalink_id_t;const  check_for_etherstub : Boolean ; const flags:UInt32_t ; out error:string):boolean;
var is_etherstub : boolean;
    attr         : dladm_vnic_attr_t;
begin
  if dladm_vnic_info(GILLU_DLADM,link_id,@attr,flags)<>DLADM_STATUS_OK then
    exit(true); { delete is ok, info not availlable }
  is_etherstub := (attr.va_link_id = DATALINK_INVALID_LINKID);
  if check_for_etherstub <> is_etherstub then
    if check_for_etherstub then
      begin
        error := name+' is not an etherstub';
        exit(false);
      end
    else
     begin
       error := name+' is not a vnic';
       exit(false);
     end;
  result := true;
end;

function i_delete_vnic(const linkname : string ; out error:string ; const for_vnic:boolean ; const zonename:pchar):boolean;
var flags    : UInt32_t;
    status   : dladm_status_t;
    lname    : Pchar;
    mac_addr : array [0..ETHERADDRLEN-1] of Uchar_t;
    linkid   : datalink_id_t;
begin
  lname  := PChar(linkname);
  flags  := DLADM_OPT_ACTIVE;
  status := dladm_zname2info(GILLU_DLADM,zonename,lname,@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'DELETEVNIC: ['+linkname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
  if not check_etherstub_vnic(lname,linkid,not for_vnic,DLADM_OPT_ACTIVE,error) then
    exit(false);

  if assigned(zonename) then
    begin { must set linkprop zone=global to force down then vnic, the vnic remains in the zone: sort of inconsistent}
      if not i_vnic_set_linkprop(linkid,'zone','global',error) then
        exit;
    end;
  status := dladm_vnic_delete(GILLU_DLADM,linkid,flags);
  if status<>DLADM_STATUS_OK then
    if for_vnic then
      begin
        error := 'vnic delete ['+linkname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
        exit(false);
      end
    else
      begin
        error := 'etherstub delete ['+linkname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
        exit(false);
      end;
  result:=true;
  error:='';
end;

function delete_etherstub(const linkname: string; out error: string): boolean;
begin
  result := i_delete_vnic(linkname,error,false,nil);
end;

function create_simnet(const linkname: string; out error: string): boolean;
var flags    : UInt32_t;
    status   : dladm_status_t;
    lname    : Pchar;
begin
  lname  := PChar(linkname);
  if (Length(linkname)>MAXLINKNAMELEN) or (dladm_valid_linkname(lname)<>B_TRUE) then
    begin
      error := 'CREATESIMNET: invalid linkname ['+linkname+']';
      exit(false);
    end;

  flags  := DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
  writeln('SWL FLAGS ',hexStr(Uint32(flags),4));

  status := dladm_simnet_create(GILLU_DLADM,lname,DL_ETHER,flags);

  result := status = DLADM_STATUS_OK;
  if not result then
    begin
      error := 'CREATESIMNET: ['+linkname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
end;

function delete_simnet(const linkname: string; out error: string): boolean;
var status   : dladm_status_t;
    lname    : Pchar;
    linkid   : datalink_id_t;
    flags    : UInt32_t  = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
begin
  lname  := PChar(linkname);
  if (Length(linkname)>MAXLINKNAMELEN) or (dladm_valid_linkname(lname)<>B_TRUE) then
    begin
      error := 'CREATESIMNET: invalid linkname ['+linkname+']';
      exit(false);
    end;

  status := dladm_name2info(GILLU_DLADM,pchar(linkname),@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'DELETESIMNET: link ['+lname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  status := dladm_simnet_delete(GILLU_DLADM,linkid,flags);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'DELETESIMNET: link ['+lname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  result := status = DLADM_STATUS_OK;
end;

function connect_simnet(const linkname: string; const peer_linkname: string; out error: string): boolean;
var status      : dladm_status_t;
    flags       : UInt32_t = DLADM_OPT_ACTIVE or DLADM_OPT_PERSIST;
    linkid      : datalink_id_t;
    peer_linkid : datalink_id_t;
begin
  status := dladm_name2info(GILLU_DLADM,pchar(linkname),@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'CONNECTSIMNET: link ['+linkname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  if peer_linkname='' then
    peer_linkid:=DATALINK_INVALID_LINKID
  else
    begin
      status := dladm_name2info(GILLU_DLADM,pchar(peer_linkname),@peer_linkid,nil,nil,nil);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'CONNECTSIMNET: peer link ['+peer_linkname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
    end;

  status := dladm_simnet_modify(GILLU_DLADM, linkid, peer_linkid, flags);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'CONNECTSIMNET: link ['+linkname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  result := true;
end;

type
  TFRE_BRIDGECMD= (brAdd,brModify,brCreate);


function create_add_modify_bridge (const bridgename: string; const func: TFRE_BRIDGECMD; const links : TFRE_DB_StringArray; out error:string):boolean;
var status            : dladm_status_t;
    flags             : UInt32_t = DLADM_OPT_ACTIVE or DLADM_OPT_PERSIST;
    cfg,cfg_old       : UID_STP_CFG_T;
    bridge            : PChar;
    brprot            : dladm_bridge_prot_t = DLADM_BRIDGE_PROT_UNKNOWN;
    brprot_old        : dladm_bridge_prot_t;
    n                 : NativeInt;
    nmax              : NativeInt;
    dlclass           : datalink_class_t;
    classfilter       : datalink_class_t;
    media             : UInt32_t;
    pointless         : Array[0..DLADM_STRSIZE-1] of char;
    linkids           : Array[0..MAXPORT-1] of datalink_id_t;

begin

  cfg.field_mask      := 0;
  cfg.bridge_priority := DEF_BR_PRIO;
  cfg.max_age         := DEF_BR_MAXAGE;
  cfg.hello_time      := DEF_BR_HELLOT;
  cfg.forward_delay   := DEF_BR_FWDELAY;
  cfg.force_version   := DEF_FORCE_VERS;

  writeln('CFG ',cfg.field_mask,' bridge_prio',cfg.bridge_priority,' maxage ',cfg.max_age,' hello ',cfg.hello_time,' fwdelay ',cfg.forward_delay,' fversion',cfg.force_version);

  bridge  := PChar(bridgename);

  if (Length(bridge)>MAXLINKNAMELEN) or (dladm_valid_bridgename(bridge)<>B_TRUE) then
    begin
      error := 'CREATEBRIDGE: invalid bridgename ['+bridgename+']';
      exit(false);
    end;

  dladm_bridge_get_properties(bridge,@cfg_old,@brprot_old);
  if brprot = DLADM_BRIDGE_PROT_UNKNOWN then
    brprot:= brprot_old;
  if (cfg.field_mask and BR_CFG_AGE)=0 then
    cfg.max_age:= cfg_old.max_age;
  if (cfg.field_mask and BR_CFG_HELLO)=0 then
    cfg.hello_time:= cfg_old.hello_time;
  if (cfg.field_mask and BR_CFG_DELAY)=0 then
    cfg.forward_delay:= cfg_old.forward_delay;

  writeln('CFG OLD',cfg_old.field_mask,' bridge_prio',cfg_old.bridge_priority,' maxage ',cfg_old.max_age,' hello ',cfg_old.hello_time,' fwdelay ',cfg_old.forward_delay,' fversion',cfg_old.force_version);
  writeln('CFG    ',cfg.field_mask,' bridge_prio',cfg.bridge_priority,' maxage ',cfg.max_age,' hello ',cfg.hello_time,' fwdelay ',cfg.forward_delay,' fversion',cfg.force_version);

  for n:=0 to high(links) do
    begin
      status := dladm_name2info(GILLU_DLADM,Pchar(links[n]),@linkids[n],nil,@dlclass,@media);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'BRIDGE: failed ['+bridgename+'] dlname ['+links[n]+' info ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
      classfilter := datalink_class_t(uint32(DATALINK_CLASS_PHYS)+uint32(DATALINK_CLASS_AGGR)+uint32(DATALINK_CLASS_ETHERSTUB)+uint32(DATALINK_CLASS_SIMNET));
//      writeln('SWL CLASSFILTER:',hexStr(uint32(classfilter),4));
      dladm_class2str(dlclass,@pointless);
      if (uint32(dlclass) and (not (uint32(classfilter))))>0 then
        begin
          error := 'BRIDGE: Link ['+links[n]+'] cannot be bridged, invalid class '+StrPas(pointless);
          exit(false);
        end;
      writeln('SWL CHECK ',n,' link ',links[n],' linkid '+inttostr(linkids[n]),' class ',Strpas(pointless));

      dladm_media2str(media,@pointless);
      if (not (media=DL_ETHER)) and (not (media=DL_100VG)) and (not (media=DL_ETH_CSMA)) and (not (media=DL_100BT)) then
        begin
          error := 'BRIDGE: Link ['+links[n]+'] cannot be bridged, invalid media '+StrPas(pointless);
          exit(false);
        end;
      writeln('SWL CHECK ',n,' link ',links[n],' media ',Strpas(pointless));
    end;

  if func=brCreate then
    flags := flags or DLADM_OPT_CREATE;

  writeln('SWL FLAGS',hexStr(flags,4));

  if not (func=brAdd) then
    begin
      writeln ('SWL BRIDGE CONFIGURE ',bridge);
      status := dladm_bridge_configure(GILLU_DLADM,bridge,@cfg,brprot,flags);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'CREATEBRIDGE: failed ['+bridgename+'] ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
    end;

  writeln('CFG    ',cfg.field_mask,' bridge_prio',cfg.bridge_priority,' maxage ',cfg.max_age,' hello ',cfg.hello_time,' fwdelay ',cfg.forward_delay,' fversion',cfg.force_version);

  nmax := -1;

  status := DLADM_STATUS_OK;

  for n:= 0 to high(links) do
    begin
      writeln('SWL SET LINK ID ',linkids[n],' NAME ',links[n], ' BRIDGE ', bridge);

      status := dladm_bridge_setlink(GILLU_DLADM,linkids[n],bridge);
      writeln('SWL STATUS SETLINK ',status);
      if status<>DLADM_STATUS_OK then
        begin
          writeln('BRIDGE: FAILED TO SET LINK [',linkids[n],'] ['+CDLADM_STATUS_CODES[status]+']');
          break
        end
      else
        nmax:=n;
    end;

  if nmax=high(links) then
    begin
      writeln('SWL ALL LINKS SET');
      if func=brCreate then
        begin
          status := dladm_bridge_enable(bridge);
          if status<>DLADM_STATUS_OK then
            begin
              error := 'CREATEBRIDGE: enable failed ['+bridgename+'] ['+CDLADM_STATUS_CODES[status]+']';
//              exit(false); CLEANUP
            end;
          exit(true);
        end
      else
        exit(true);
    end;
  //cleanup
  writeln('SWL CLEANUP BRIDGE ',nmax);

  for n:=0 to nmax do
    begin
      writeln('SWL UNSETTING LINK :',n);
      dladm_bridge_setlink(GILLU_DLADM,linkids[n],Pchar(''));
    end;

  if func=brCreate then
    begin
      writeln('SWL DELETE BRIDGE ',bridgename);
      dladm_bridge_delete(GILLU_DLADM,bridge,flags);
    end;

  if (nmax<high(links)) and (sizeof(links)>0) then
    error := 'Unable to add link '+links[nmax+1]+' to bridge '+bridgename
  else
    error := 'Unable to enable bridge '+bridgename;

  result := false;
end;

function create_bridge(const bridgename: string; const links: TFRE_DB_StringArray; out error: string): boolean;
begin
  result := create_add_modify_bridge(bridgename,brCreate,links,error);
end;

function add_to_bridge(const bridgename: string; const links: TFRE_DB_StringArray; out error: string): boolean;
begin
  result := create_add_modify_bridge(bridgename,brAdd,links,error);
end;

function remove_from_bridge(const bridgename: string; const links: TFRE_DB_StringArray; out error: string): boolean;
var
    status            : dladm_status_t;
    bridge            : PChar;
    n                 : NativeInt;
    linkids           : Array[0..MAXPORT-1] of datalink_id_t;
    old_bridge        : Array[0..MAXLINKNAMELEN-1] of char;
    removed_one       : boolean;
begin
  bridge := PChar (bridgename);
  result := false;

  for n:=0 to high(links) do
    begin
      status := dladm_name2info(GILLU_DLADM,Pchar(links[n]),@linkids[n],nil,nil,nil);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'BRIDGE: Remove failed from bridge ['+bridgename+'] link ['+links[n]+' info ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
      status := dladm_bridge_getlink(GILLU_DLADM,linkids[n],@old_bridge,sizeof(old_bridge));
      if ((not (status=DLADM_STATUS_OK)) and (not (status=DLADM_STATUS_NOTFOUND))) then
        begin
          error := 'BRIDGE: Cannot get bridge status on ['+bridgename+'] link ['+links[n]+' info ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
      if (status=DLADM_STATUS_NOTFOUND) or (strcomp(bridge,old_bridge)<>0) then
        begin
          error := 'Link '+links[n]+' is not on bridge '+bridge;
          exit(false);
        end;
    end;

  removed_one:=false;

  error := '';
  for n:=0 to high(links) do
    begin
      status := dladm_bridge_setlink(GILLU_DLADM,linkids[n],Pchar(''));
      if status = DLADM_STATUS_OK then
        removed_one := true
      else
        error := 'Can not remove link '+links[n]+' from bridge '+bridge;
    end;

  if removed_one=false then
    begin
      error := 'Unable to remove any links from bridge '+bridge;
      exit(false);
    end;

  result :=true;
end;

function delete_bridge(const bridgename: string; out error: string): boolean;
var status            : dladm_status_t;
    flags             : UInt32_t = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
    brname            : PChar;
begin

  brname  := PChar(bridgename);
  if (Length(brname)>MAXLINKNAMELEN) or (dladm_valid_bridgename(brname)<>B_TRUE) then
    begin
      error := 'DELETEBRIDGE: invalid bridgename ['+bridgename+']';
      exit(false);
    end;

  status := dladm_bridge_delete(GILLU_DLADM,brname,flags);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'DELETEBRIDGE: failed ['+bridgename+'] ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
  result:=true;
end;

function create_aggr(const aggrname: string; const key: int32; const links: TFRE_DB_StringArray; const aggr_policy: string; const aggr_timer: string; const aggr_lacp_mode: string; const force :boolean; out error: string): boolean;
label done;
var
    policy            : uint32_t;
    lacp_mode         : aggr_lacp_mode_t;
    lacp_timer        : aggr_lacp_timer_t;
    aname             : PChar;
    port              : Array[0..MAXPORT-1] of dladm_aggr_port_attr_db_t;
    n                 : NativeInt;
    status            : dladm_status_t;
    mac_addr          : Array[0..ETHERADDRL-1] of uint8_t;
    mac_addr_fixed    : boolean_t = B_FALSE;
    flags             : uint32_t = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
begin
  aname  := PChar(aggrname+inttostr(key));

  policy      := aggr_policy_from_string    (aggr_policy);
  lacp_timer  := aggr_timer_from_string     (aggr_timer);
  lacp_mode   := aggr_lacp_mode_from_string (aggr_lacp_mode);

  if (Length(aggrname)>MAXLINKNAMELEN) or (dladm_valid_linkname(aname)<>B_TRUE) then
    begin
      error := 'CREATEAGGREGATION: invalid aggregation name ['+aname+']';
      exit(false);
    end;

  if length(links)=0 then
    begin
      error := 'CREATEAGGREGATION: at least one linke must be provided for aggregation ['+aname+']';
      exit(false);
    end;

  if force=true then
    flags := flags + DLADM_OPT_FORCE;

  for n:=0 to high(links) do
    begin
      status := dladm_name2info(GILLU_DLADM,Pchar(links[n]),@port[n].lp_linkid,nil,nil,nil);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'CREATE AGGREGATION: Invalid Link name for ['+aname+'] link ['+links[n]+'] ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
    end;



  status := dladm_aggr_create(GILLU_DLADM,aname,key,length(links),port,policy,mac_addr_fixed,Puchar_t(mac_addr),lacp_mode,lacp_timer,flags);
  if (status<>DLADM_STATUS_OK) then
    goto done;

  //
  //  if (dladm_parse_link_props(propstr, &proplist, B_FALSE)
  //      != DLADM_STATUS_OK)
  //  	die("invalid aggregation property");
  //
  //  if (proplist == NULL)
  //  	return;
  //
  //  status = dladm_name2info(handle, name, &linkid, NULL, NULL, NULL);
  //  if (status != DLADM_STATUS_OK)
  //  	goto done;
  //
  //  for (i = 0; i < proplist->al_count; i++) {
  //  	dladm_arg_info_t	*aip = &proplist->al_info[i];
  //
  //  	pstatus = dladm_set_linkprop(handle, linkid, aip->ai_name,
  //  	    aip->ai_val, aip->ai_count, flags);
  //
  //  	if (pstatus != DLADM_STATUS_OK) {
  //  		die_dlerr(pstatus,
  //  		    "aggr creation succeeded but "
  //  		    "could not set property '%s'", aip->ai_name);
  //  	}
  //  }

done:

//  dladm_free_props(proplist);

  if (status<>DLADM_STATUS_OK) then
    if (status=DLADM_STATUS_NONOTIF) then
      begin
        error := 'CREATE AGGREGATION: not all links have link up/down detection; must use force ['+aname+']';
        exit(false);
      end
    else
      begin
        error := 'CREATE AGGREGATION: Create aggregation ['+aname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
        exit(false);
      end;
  result :=true;
end;

function add_to_aggr(const aggrname: string; const links: TFRE_DB_StringArray; const force : boolean; out error: string): boolean;
var
    aname             : PChar;
    port              : Array[0..MAXPORT-1] of dladm_aggr_port_attr_db_t;
    n                 : NativeInt;
    status            : dladm_status_t;
    flags             : uint32_t = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
    linkid            : datalink_id_t;

begin
  aname  := PChar(aggrname);

  if force=true then
    flags := flags + DLADM_OPT_FORCE;

  status := dladm_name2info(GILLU_DLADM,aname,@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'ADD TO AGGREGATION: not found ['+aname+'] ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  if length(links)=0 then
    begin
      error := 'ADDAGGREGATION: at least one linke must be provided for add aggregation ['+aname+']';
      exit(false);
    end;

  for n:=0 to high(links) do
    begin
      status := dladm_name2info(GILLU_DLADM,Pchar(links[n]),@port[n].lp_linkid,nil,nil,nil);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'ADD TO AGGREGATION: Invalid Link name for ['+aname+'] link ['+links[n]+'] ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
    end;

  status := dladm_aggr_add(GILLU_DLADM, linkid, length(links), port, flags);
  if (status<>DLADM_STATUS_OK) then
    if (status=DLADM_STATUS_NOTSUP) then
      begin
        error := 'ADD AGGREGATION: link capabilities dont match ['+aname+']';
        exit(false);
      end
    else
      if (status=DLADM_STATUS_NONOTIF) then
        begin
          error := 'ADD AGGREGATION: not all links have link up/down detection; must use force ['+aname+']';
          exit(false);
        end
      else
        begin
          error := 'ADD AGGREGATION: Add aggregation ['+aname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;

  result :=true;
end;

function remove_from_aggr(const aggrname: string; const links: TFRE_DB_StringArray; out error: string): boolean;
var
    aname             : PChar;
    status            : dladm_status_t;
    flags             : uint32_t = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
    linkid            : datalink_id_t;
    port              : Array[0..MAXPORT-1] of dladm_aggr_port_attr_db_t;
    n                 : NativeInt;

begin
  aname := PChar(aggrname);
  status := dladm_name2info(GILLU_DLADM,aname,@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'REMOVEAGGREGATION: not found ['+aname+'] ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  for n:=0 to high(links) do
    begin
      status := dladm_name2info(GILLU_DLADM,Pchar(links[n]),@port[n].lp_linkid,nil,nil,nil);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'REMOVE FROM AGGREGATION: Invalid Link name for ['+aname+'] link ['+links[n]+'] ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
    end;

  status := dladm_aggr_remove(GILLU_DLADM,linkid,length(links),port,flags);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'REMOVE FROM AGGREGATION: Remove aggregation ['+aname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
end;

function delete_aggr(const aggrname: string; out error: string): boolean;
var
    aname             : PChar;
    status            : dladm_status_t;
    flags             : uint32_t = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
    linkid            : datalink_id_t;
begin

  aname := PChar(aggrname);

  status := dladm_name2info(GILLU_DLADM,aname,@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'DELETEAGGREGATION: not found ['+aname+'] ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  status := dladm_aggr_delete(GILLU_DLADM, linkid, flags);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'DELETEAGGREGATION: failed ['+aname+'] ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  result := true;
end;

function modify_aggr(const aggrname: string; const aggr_policy: string; const aggr_timer: string; const aggr_lacp_mode: string; out error: string): boolean;
var
    policy            : uint32_t;
    lacp_mode         : aggr_lacp_mode_t;
    lacp_timer        : aggr_lacp_timer_t;
    aname             : PChar;
    status            : dladm_status_t;
    flags             : uint32_t = DLADM_OPT_ACTIVE + DLADM_OPT_PERSIST;
    modify_mask       :	uint8_t = 0;
    mac_addr          : Array[0..ETHERADDRL-1] of uint8_t;
    mac_addr_fixed    : boolean_t = B_FALSE;
    linkid            : datalink_id_t;

begin
  aname  := PChar(aggrname);

  policy      := aggr_policy_from_string    (aggr_policy);
  lacp_timer  := aggr_timer_from_string     (aggr_timer);
  lacp_mode   := aggr_lacp_mode_from_string (aggr_lacp_mode);

  modify_mask := DLADM_AGGR_MODIFY_POLICY + DLADM_AGGR_MODIFY_LACP_TIMER + DLADM_AGGR_MODIFY_LACP_MODE;

  status := dladm_name2info(GILLU_DLADM,aname,@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'MODIFYAGGREGATION: not found ['+aname+'] ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;

  status := dladm_aggr_modify(GILLU_DLADM, linkid, modify_mask, policy,mac_addr_fixed,Puchar_t(mac_addr),lacp_mode,lacp_timer,flags);
  if (status<>DLADM_STATUS_OK) then
    begin
      error := 'MODIFYAGGREGATION: Modify aggregation ['+aname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
  result :=true;
end;

function create_vnic(const vnic, for_linkname: string; var macaddr: TFOS_MAC_ADDR; out error: String ; const for_zone:string='' ; const vid : cint = 0 ;const vrid : vrid_t = VRRP_VRID_NONE ; linkprops:string=''): boolean;
var linkid,dev_linkid : datalink_id_t;
    flags             : UInt32_t  = DLADM_OPT_ACTIVE;
    status            : dladm_status_t;
    mac_addr_type     : vnic_mac_addr_type_t = VNIC_MAC_ADDR_TYPE_UNKNOWN;
    af                : cint = AF_UNSPEC;
    proplist          : Pdladm_arg_list_t=nil;
    mac_addr          : Puchar_t;
    mac_slot          : cint=-1;
    name              : pchar;
    vnicname          : string;
begin
  if Length(for_linkname)>MAXLINKNAMELEN then
    begin
      error := 'linkname ['+vnic+'/'+for_linkname+'] is too long';
      exit(false);
    end;
  if vid<>0 then
    if (vid>4094) or (vid<1) then
      begin
        error := 'invalid vlan id ['+inttostR(vid)+']';
        exit(false);
      end;
  status := dladm_name2info(GILLU_DLADM,pchar(for_linkname),@linkid,nil,nil,nil);
  if status<>DLADM_STATUS_OK then
    begin
      error := 'CREATEVNIC: link ['+vnic+'/'+for_linkname+'] invalid ['+CDLADM_STATUS_CODES[status]+']';
      exit(false);
    end;
  if pos('zone',linkprops)>0 then
    begin
      error := 'CREATEVNIC: dont specify zone prop in linkprops, use the for_zone string';
      exit(false);
    end;
  vnicname := vnic;
  if for_zone<>'' then
    begin
      flags := flags+DLADM_OPT_TRANSIENT;
      vnicname := 'xx'+FREDB_GetRandomChars(20,rpm_OnlyChars)+'0';
      if linkprops<>'' then
        linkprops:='zone='+trim(for_zone)+','+linkprops
      else
        linkprops:='zone='+trim(for_zone);
    end;
  if linkprops<>'' then
    begin
      status := dladm_parse_link_props(pchar(linkprops),@proplist,B_FALSE);
      if status<>DLADM_STATUS_OK then
        begin
          error := 'CREATEVNIC: ['+vnic+'/'+for_linkname+' : '+linkprops+'] properties invalid ['+CDLADM_STATUS_CODES[status]+']';
          exit(false);
        end;
    end;
  try
    name          := pchar(vnicname);
    mac_addr_type := VNIC_MAC_ADDR_TYPE_FIXED;
    mac_addr      := macaddr.GetPointer;
    writeln('VID=',vid,' ',vrid);
    status        := dladm_vnic_create(GILLU_DLADM,name,linkid,mac_addr_type,mac_addr,6,@mac_slot,0,vid,vrid,af,@dev_linkid,proplist,flags);
    result        := status=DLADM_STATUS_OK;
    if not result then
      begin
        error := 'CREATEVNIC: ['+vnic+'/'+for_linkname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
        exit(false);
      end
    else
      if for_zone<>'' then
        begin
          result := rename_vnic(vnicname,vnic,error,for_zone);
        end;
  finally
    if assigned(proplist) then
      dladm_free_props(proplist);
  end;
end;

function delete_vnic(const linkname: string; out error: string;const zonename:string): boolean;
var zname : pchar;
begin
  if zonename<>'' then
    zname:=pchar(zonename)
  else
    zname:=nil;
  result := i_delete_vnic(linkname,error,true,zname);
end;

function rename_vnic(const from_linkname, to_linkname: string; out error: string; for_zone: string): boolean;
var status : dladm_status_t;
begin
  status := dladm_rename_link(GILLU_DLADM,pchar(for_zone),pchar(from_linkname),pchar(to_linkname));
  result := status=DLADM_STATUS_OK;
  if not result then
    begin
      error := 'RENAMEVNIC: ['+for_zone+' '+from_linkname+'->'+to_linkname+'] failed ['+CDLADM_STATUS_CODES[status]+']';
    end;
end;



end.

