
unit libdladm;
interface

{
  Automatically converted by H2Pas 1.0.0 from libdladm.h
  The following command line parameters were used:
    libdladm.h
}

  Type
  Pchar  = ^char;
  Pdladm_arg_list_t  = ^dladm_arg_list_t;
  Pdladm_handle_t  = ^dladm_handle_t;
  Pdladm_usage_t  = ^dladm_usage_t;
  Pmac_priority_level_t  = ^mac_priority_level_t;
  Pmac_propval_range_t  = ^mac_propval_range_t;
  Puint32_t  = ^uint32_t;
  Puint64_t  = ^uint64_t;
  Puint_t  = ^uint_t;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  {
   * CDDL HEADER START
   *
   * The contents of this file are subject to the terms of the
   * Common Development and Distribution License (the "License").
   * You may not use this file except in compliance with the License.
   *
   * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
   * or http://www.opensolaris.org/os/licensing.
   * See the License for the specific language governing permissions
   * and limitations under the License.
   *
   * When distributing Covered Code, include this CDDL HEADER in each
   * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
   * If applicable, add the following below this CDDL HEADER, with the
   * fields enclosed by brackets "[]" replaced with your own identifying
   * information: Portions Copyright [yyyy] [name of copyright owner]
   *
   * CDDL HEADER END
    }
  {
   * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
   * Copyright (c) 2011, Joyent, Inc. All rights reserved.
    }
{$ifndef _LIBDLADM_H}
{$define _LIBDLADM_H}  
{$include <sys/dls_mgmt.h>}
{$include <sys/dld.h>}
{$include <sys/dlpi.h>}
{$include <libnvpair.h>}
  {
   * This file includes structures, macros and common routines shared by all
   * data-link administration, and routines which do not directly administrate
   * links. For example, dladm_status2str().
    }
{ C++ extern C conditionnal removed }

  const
    LINKID_STR_WIDTH = 10;    
    DLADM_STRSIZE = 256;    
  {
   * option flags taken by the libdladm functions
   *
   *  - DLADM_OPT_ACTIVE:
   *    The function requests to bringup some configuration that only take
   *    effect on active system (not persistent).
   *
   *  - DLADM_OPT_PERSIST:
   *    The function requests to persist some configuration.
   *
   *  - DLADM_OPT_CREATE:
   *    Today, only used by dladm_set_secobj() - requests to create a secobj.
   *
   *  - DLADM_OPT_FORCE:
   *    The function requests to execute a specific operation forcefully.
   *
   *  - DLADM_OPT_PREFIX:
   *    The function requests to generate a link name using the specified prefix.
   *
   *  - DLADM_OPT_VLAN:
   *    Signifies VLAN creation code path
   *
   *  - DLADM_OPT_NOREFRESH:
   *    Do not refresh the daemon after setting parameter (used by STP mcheck).
   *
   *  - DLADM_OPT_BOOT:
   *    Bypass check functions during boot (used by pool property since pools
   *    can come up after link properties are set)
   *
   *  - DLADM_OPT_TRANSIENT:
   *    Indicates that the link assigned to a zone is transient and will be
   *    removed when the zone shuts down.
    }
    DLADM_OPT_ACTIVE = $00000001;    
    DLADM_OPT_PERSIST = $00000002;    
    DLADM_OPT_CREATE = $00000004;    
    DLADM_OPT_FORCE = $00000008;    
    DLADM_OPT_PREFIX = $00000010;    
    DLADM_OPT_ANCHOR = $00000020;    
    DLADM_OPT_VLAN = $00000040;    
    DLADM_OPT_NOREFRESH = $00000080;    
    DLADM_OPT_BOOT = $00000100;    
    DLADM_OPT_TRANSIENT = $00000200;    
    DLADM_WALK_TERMINATE = 0;    
    DLADM_WALK_CONTINUE = -(1);    
    DLADM_MAX_ARG_CNT = 32;    
    DLADM_MAX_ARG_VALS = 64;    

  type
    dladm_status_t = (DLADM_STATUS_OK := 0,DLADM_STATUS_BADARG,
      DLADM_STATUS_FAILED,DLADM_STATUS_TOOSMALL,
      DLADM_STATUS_NOTSUP,DLADM_STATUS_NOTFOUND,
      DLADM_STATUS_BADVAL,DLADM_STATUS_NOMEM,
      DLADM_STATUS_EXIST,DLADM_STATUS_LINKINVAL,
      DLADM_STATUS_PROPRDONLY,DLADM_STATUS_BADVALCNT,
      DLADM_STATUS_DBNOTFOUND,DLADM_STATUS_DENIED,
      DLADM_STATUS_IOERR,DLADM_STATUS_TEMPONLY,
      DLADM_STATUS_TIMEDOUT,DLADM_STATUS_ISCONN,
      DLADM_STATUS_NOTCONN,DLADM_STATUS_REPOSITORYINVAL,
      DLADM_STATUS_MACADDRINVAL,DLADM_STATUS_KEYINVAL,
      DLADM_STATUS_INVALIDMACADDRLEN,DLADM_STATUS_INVALIDMACADDRTYPE,
      DLADM_STATUS_LINKBUSY,DLADM_STATUS_VIDINVAL,
      DLADM_STATUS_NONOTIF,DLADM_STATUS_TRYAGAIN,
      DLADM_STATUS_IPTUNTYPE,DLADM_STATUS_IPTUNTYPEREQD,
      DLADM_STATUS_BADIPTUNLADDR,DLADM_STATUS_BADIPTUNRADDR,
      DLADM_STATUS_ADDRINUSE,DLADM_STATUS_BADTIMEVAL,
      DLADM_STATUS_INVALIDMACADDR,DLADM_STATUS_INVALIDMACADDRNIC,
      DLADM_STATUS_INVALIDMACADDRINUSE,DLADM_STATUS_MACFACTORYSLOTINVALID,
      DLADM_STATUS_MACFACTORYSLOTUSED,DLADM_STATUS_MACFACTORYSLOTALLUSED,
      DLADM_STATUS_MACFACTORYNOTSUP,DLADM_STATUS_INVALIDMACPREFIX,
      DLADM_STATUS_INVALIDMACPREFIXLEN,DLADM_STATUS_BADCPUID,
      DLADM_STATUS_CPUERR,DLADM_STATUS_CPUNOTONLINE,
      DLADM_STATUS_BADRANGE,DLADM_STATUS_TOOMANYELEMENTS,
      DLADM_STATUS_DB_NOTFOUND,DLADM_STATUS_DB_PARSE_ERR,
      DLADM_STATUS_PROP_PARSE_ERR,DLADM_STATUS_ATTR_PARSE_ERR,
      DLADM_STATUS_FLOW_DB_ERR,DLADM_STATUS_FLOW_DB_OPEN_ERR,
      DLADM_STATUS_FLOW_DB_PARSE_ERR,DLADM_STATUS_FLOWPROP_DB_PARSE_ERR,
      DLADM_STATUS_FLOW_ADD_ERR,DLADM_STATUS_FLOW_WALK_ERR,
      DLADM_STATUS_FLOW_IDENTICAL,DLADM_STATUS_FLOW_INCOMPATIBLE,
      DLADM_STATUS_FLOW_EXISTS,DLADM_STATUS_PERSIST_FLOW_EXISTS,
      DLADM_STATUS_INVALID_IP,DLADM_STATUS_INVALID_PREFIXLEN,
      DLADM_STATUS_INVALID_PROTOCOL,DLADM_STATUS_INVALID_PORT,
      DLADM_STATUS_INVALID_DSF,DLADM_STATUS_INVALID_DSFMASK,
      DLADM_STATUS_INVALID_MACMARGIN,DLADM_STATUS_NOTDEFINED,
      DLADM_STATUS_BADPROP,DLADM_STATUS_MINMAXBW,
      DLADM_STATUS_NO_HWRINGS,DLADM_STATUS_PERMONLY,
      DLADM_STATUS_OPTMISSING,DLADM_STATUS_POOLCPU,
      DLADM_STATUS_INVALID_PORT_INSTANCE,DLADM_STATUS_PORT_IS_DOWN,
      DLADM_STATUS_PKEY_NOT_PRESENT,DLADM_STATUS_PARTITION_EXISTS,
      DLADM_STATUS_INVALID_PKEY,DLADM_STATUS_NO_IB_HW_RESOURCE,
      DLADM_STATUS_INVALID_PKEY_TBL_SIZE,DLADM_STATUS_PORT_NOPROTO,
      DLADM_STATUS_INVALID_MTU);

    dladm_datatype_t = (DLADM_TYPE_STR,DLADM_TYPE_BOOLEAN,DLADM_TYPE_UINT64
      );

    dladm_conf_t = record
        ds_readonly : boolean_t;
        ds_u : record
            case longint of
              0 : ( dsu_confid : longint );
              1 : ( dsu_nvl : ^nvlist_t );
            end;
      end;

  const
    ds_confid = ds_u.dsu_confid;    
    ds_nvl = ds_u.dsu_nvl;    
    DLADM_INVALID_CONF = 0;    
  { opaque dladm handle to libdladm functions  }

  type
    dladm_handle = record
        {undefined structure}
      end;


    dladm_handle_t = ^dladm_handle;
  { open/close handle  }

  function dladm_open(_para1:Pdladm_handle_t):dladm_status_t;cdecl;

  procedure dladm_close(_para1:dladm_handle_t);cdecl;

  {
   * retrieve the dld file descriptor from handle, only libdladm and
   * dlmgmtd are given access to the door file descriptor.
    }
  function dladm_dld_fd(_para1:dladm_handle_t):longint;cdecl;

(* Const before type ignored *)

  type
    dladm_arg_info = record
        ai_name : ^char;
        ai_val : array[0..(DLADM_MAX_ARG_VALS)-1] of ^char;
        ai_count : uint_t;
      end;
    dladm_arg_info_t = dladm_arg_info;

    dladm_arg_list = record
        al_info : array[0..(DLADM_MAX_ARG_CNT)-1] of dladm_arg_info_t;
        al_count : uint_t;
        al_buf : ^char;
      end;
    dladm_arg_list_t = dladm_arg_list;

    dladm_logtype_t = (DLADM_LOGTYPE_LINK := 1,DLADM_LOGTYPE_FLOW
      );

    dladm_usage = record
        du_name : array[0..(MAXLINKNAMELEN)-1] of char;
        du_duration : uint64_t;
        du_stime : uint64_t;
        du_etime : uint64_t;
        du_ipackets : uint64_t;
        du_rbytes : uint64_t;
        du_opackets : uint64_t;
        du_obytes : uint64_t;
        du_bandwidth : uint64_t;
        du_last : boolean_t;
      end;
    dladm_usage_t = dladm_usage;
(* Const before type ignored *)

  function dladm_status2str(_para1:dladm_status_t; _para2:Pchar):^char;cdecl;

(* Const before type ignored *)
  function dladm_set_rootdir(_para1:Pchar):dladm_status_t;cdecl;

(* Const before type ignored *)
  function dladm_class2str(_para1:datalink_class_t; _para2:Pchar):^char;cdecl;

(* Const before type ignored *)
  function dladm_media2str(_para1:uint32_t; _para2:Pchar):^char;cdecl;

(* Const before type ignored *)
  function dladm_str2media(_para1:Pchar):uint32_t;cdecl;

(* Const before type ignored *)
  function dladm_valid_linkname(_para1:Pchar):boolean_t;cdecl;

  function dladm_str2interval(_para1:Pchar; _para2:Puint32_t):boolean_t;cdecl;

  function dladm_str2bw(_para1:Pchar; _para2:Puint64_t):dladm_status_t;cdecl;

(* Const before type ignored *)
  function dladm_bw2str(_para1:int64_t; _para2:Pchar):^char;cdecl;

  function dladm_str2pri(_para1:Pchar; _para2:Pmac_priority_level_t):dladm_status_t;cdecl;

(* Const before type ignored *)
  function dladm_pri2str(_para1:mac_priority_level_t; _para2:Pchar):^char;cdecl;

  function dladm_str2protect(_para1:Pchar; _para2:Puint32_t):dladm_status_t;cdecl;

(* Const before type ignored *)
  function dladm_protect2str(_para1:uint32_t; _para2:Pchar):^char;cdecl;

  function dladm_str2ipv4addr(_para1:Pchar; _para2:pointer):dladm_status_t;cdecl;

(* Const before type ignored *)
  function dladm_ipv4addr2str(_para1:pointer; _para2:Pchar):^char;cdecl;

  function dladm_str2ipv6addr(_para1:Pchar; _para2:pointer):dladm_status_t;cdecl;

(* Const before type ignored *)
  function dladm_ipv6addr2str(_para1:pointer; _para2:Pchar):^char;cdecl;

  function dladm_parse_flow_props(_para1:Pchar; _para2:PPdladm_arg_list_t; _para3:boolean_t):dladm_status_t;cdecl;

  function dladm_parse_link_props(_para1:Pchar; _para2:PPdladm_arg_list_t; _para3:boolean_t):dladm_status_t;cdecl;

  procedure dladm_free_props(_para1:Pdladm_arg_list_t);cdecl;

  function dladm_parse_flow_attrs(_para1:Pchar; _para2:PPdladm_arg_list_t; _para3:boolean_t):dladm_status_t;cdecl;

  procedure dladm_free_attrs(_para1:Pdladm_arg_list_t);cdecl;

  function dladm_start_usagelog(_para1:dladm_handle_t; _para2:dladm_logtype_t; _para3:uint_t):dladm_status_t;cdecl;

  function dladm_stop_usagelog(_para1:dladm_handle_t; _para2:dladm_logtype_t):dladm_status_t;cdecl;

  function dladm_walk_usage_res(_para1:function (_para1:Pdladm_usage_t; _para2:pointer):longint; _para2:longint; _para3:Pchar; _para4:Pchar; _para5:Pchar; 
             _para6:Pchar; _para7:pointer):dladm_status_t;cdecl;

  function dladm_walk_usage_time(_para1:function (_para1:Pdladm_usage_t; _para2:pointer):longint; _para2:longint; _para3:Pchar; _para4:Pchar; _para5:Pchar; 
             _para6:pointer):dladm_status_t;cdecl;

  function dladm_usage_summary(_para1:function (_para1:Pdladm_usage_t; _para2:pointer):longint; _para2:longint; _para3:Pchar; _para4:pointer):dladm_status_t;cdecl;

  function dladm_usage_dates(_para1:function (_para1:Pdladm_usage_t; _para2:pointer):longint; _para2:longint; _para3:Pchar; _para4:Pchar; _para5:pointer):dladm_status_t;cdecl;

  function dladm_zone_boot(_para1:dladm_handle_t; _para2:zoneid_t):dladm_status_t;cdecl;

  function dladm_zone_halt(_para1:dladm_handle_t; _para2:zoneid_t):dladm_status_t;cdecl;

  function dladm_strs2range(_para1:PPchar; _para2:uint_t; _para3:mac_propval_type_t; _para4:PPmac_propval_range_t):dladm_status_t;cdecl;

  function dladm_range2list(_para1:Pmac_propval_range_t; _para2:pointer; _para3:Puint_t):dladm_status_t;cdecl;

  function dladm_range2strs(_para1:Pmac_propval_range_t; _para2:PPchar):longint;cdecl;

  function dladm_list2range(_para1:pointer; _para2:uint_t; _para3:mac_propval_type_t; _para4:PPmac_propval_range_t):dladm_status_t;cdecl;

{ C++ end of extern C conditionnal removed }
{$endif}
  { _LIBDLADM_H  }

implementation


end.
