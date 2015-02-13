unit fosillu_libdlaggr;

interface

uses ctypes,unixtype,fos_illumos_defs,fosillu_nvpair,fosillu_sysnet_common,fosillu_libdladm;

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
   * Copyright (c) 2014, FirmOS All rights reserved.
    }
  {
   * This file includes structures, macros and common routines shared by all
   * data-link administration, and routines which do not directly administrate
   * links. For example, dladm_status2str().
    }

  {$IFDEF FPC}
  {$PACKRECORDS C}
  {$ENDIF}
  {$LINKLIB libdladm}

  const
    External_library=''; {Setup as you need}

  Type
    Paggr_lacp_mode_t  = ^aggr_lacp_mode_t;
    Paggr_lacp_timer_t  = ^aggr_lacp_timer_t;
    Pboolean_t  = ^boolean_t;
    Pbyte  = ^byte;
    Pchar  = ^char;
    Pdatalink_id_t  = ^datalink_id_t;
    Pdladm_aggr_grp_attr_t  = ^dladm_aggr_grp_attr_t;
    Pdladm_aggr_port_attr_db_t  = ^dladm_aggr_port_attr_db_t;
    Puchar_t  = ^uchar_t;
    Puint32_t  = ^uint32_t;


    dladm_aggr_port_attr_db = record
        lp_linkid : datalink_id_t;
      end;
    dladm_aggr_port_attr_db_t = dladm_aggr_port_attr_db;

    dladm_aggr_port_attr = record
        lp_linkid : datalink_id_t;
        lp_mac : array[0..(ETHERADDRL)-1] of uchar_t;
        lp_state : aggr_port_state_t;
        lp_lacp_state : aggr_lacp_state_t;
      end;
    dladm_aggr_port_attr_t = dladm_aggr_port_attr;

    dladm_aggr_grp_attr = record
        lg_linkid : datalink_id_t;
        lg_key : uint32_t;
        lg_nports : uint32_t;
        lg_ports : ^dladm_aggr_port_attr_t;
        lg_policy : uint32_t;
        lg_mac : array[0..(ETHERADDRL)-1] of uchar_t;
        lg_mac_fixed : boolean_t;
        lg_force : boolean_t;
        lg_lacp_mode : aggr_lacp_mode_t;
        lg_lacp_timer : aggr_lacp_timer_t;
      end;
    dladm_aggr_grp_attr_t = dladm_aggr_grp_attr;

  const
    DLADM_AGGR_MODIFY_POLICY = $01;
    DLADM_AGGR_MODIFY_MAC = $02;
    DLADM_AGGR_MODIFY_LACP_MODE = $04;
    DLADM_AGGR_MODIFY_LACP_TIMER = $08;

(* Const before type ignored *)
(* Const before type ignored *)

  function dladm_aggr_create(_para1:dladm_handle_t; _para2:Pchar; _para3:uint16_t; _para4:uint32_t; _para5:Pdladm_aggr_port_attr_db_t; 
             _para6:uint32_t; _para7:boolean_t; _para8:Puchar_t; _para9:aggr_lacp_mode_t; _para10:aggr_lacp_timer_t; 
             _para11:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_create';

  function dladm_aggr_delete(_para1:dladm_handle_t; _para2:datalink_id_t; _para3:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_delete';

  function dladm_aggr_add(_para1:dladm_handle_t; _para2:datalink_id_t; _para3:uint32_t; _para4:Pdladm_aggr_port_attr_db_t; _para5:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_add';

  function dladm_aggr_remove(_para1:dladm_handle_t; _para2:datalink_id_t; _para3:uint32_t; _para4:Pdladm_aggr_port_attr_db_t; _para5:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_remove';

(* Const before type ignored *)
  function dladm_aggr_modify(_para1:dladm_handle_t; _para2:datalink_id_t; _para3:uint32_t; _para4:uint32_t; _para5:boolean_t; 
             _para6:Puchar_t; _para7:aggr_lacp_mode_t; _para8:aggr_lacp_timer_t; _para9:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_modify';

  function dladm_aggr_up(_para1:dladm_handle_t; _para2:datalink_id_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_up';

  function dladm_aggr_info(_para1:dladm_handle_t; _para2:datalink_id_t; _para3:Pdladm_aggr_grp_attr_t; _para4:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_aggr_info';

(* Const before type ignored *)
  function dladm_aggr_str2policy(_para1:Pchar; _para2:Puint32_t):boolean_t;cdecl;external External_library name 'dladm_aggr_str2policy';

  function dladm_aggr_policy2str(_para1:uint32_t; _para2:Pchar):pchar;cdecl;external External_library name 'dladm_aggr_policy2str';

(* Const before type ignored *)
  function dladm_aggr_str2macaddr(_para1:Pchar; _para2:Pboolean_t; _para3:Puchar_t):boolean_t;cdecl;external External_library name 'dladm_aggr_str2macaddr';

(* Const before type ignored *)
(* Const before type ignored *)
  function dladm_aggr_macaddr2str(_para1:Pbyte; _para2:Pchar):pchar;cdecl;external External_library name 'dladm_aggr_macaddr2str';

(* Const before type ignored *)
  function dladm_aggr_str2lacpmode(_para1:Pchar; _para2:Paggr_lacp_mode_t):boolean_t;cdecl;external External_library name 'dladm_aggr_str2lacpmode';

(* Const before type ignored *)
  function dladm_aggr_lacpmode2str(_para1:aggr_lacp_mode_t; _para2:Pchar):pchar;cdecl;external External_library name 'dladm_aggr_lacpmode2str';

(* Const before type ignored *)
  function dladm_aggr_str2lacptimer(_para1:Pchar; _para2:Paggr_lacp_timer_t):boolean_t;cdecl;external External_library name 'dladm_aggr_str2lacptimer';

(* Const before type ignored *)
  function dladm_aggr_lacptimer2str(_para1:aggr_lacp_timer_t; _para2:Pchar):pchar;cdecl;external External_library name 'dladm_aggr_lacptimer2str';

(* Const before type ignored *)
  function dladm_aggr_portstate2str(_para1:aggr_port_state_t; _para2:Pchar):pchar;cdecl;external External_library name 'dladm_aggr_portstate2str';

  function dladm_key2linkid(_para1:dladm_handle_t; _para2:uint16_t; _para3:Pdatalink_id_t; _para4:uint32_t):dladm_status_t;cdecl;external External_library name 'dladm_key2linkid';


implementation


end.
