
unit fosillu_libdlflow;
interface

{
  Automatically converted by H2Pas 1.0.0 from libdlflow.h
  The following command line parameters were used:
    -DcCpv
    -o
    fosillu_libdlflow.pp
    libdlflow.h
}

  const
    External_library=''; {Setup as you need}

  Type
  Pchar  = ^char;
  Pdladm_arg_list_t  = ^dladm_arg_list_t;
  Pdladm_flow_attr_t  = ^dladm_flow_attr_t;
  Pdld_flowinfo_t  = ^dld_flowinfo_t;
  Pin6_addr_t  = ^in6_addr_t;
  Plongint  = ^longint;
  Puchar_t  = ^uchar_t;
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
   * Copyright 2009 Sun Microsystems, Inc.  All rights reserved.
   * Use is subject to license terms.
    }
{$ifndef _LIBDLFLOW_H}
{$define _LIBDLFLOW_H}  
  {
   * This file includes strcutures, macros and routines used by general
   * flow administration
    }
{$include <sys/types.h>}
{$include <netinet/in.h>}
{$include <sys/mac_flow.h>}
{$include <sys/dld.h>}
{$include <sys/param.h>}
{$include <sys/mac.h>}
{$include <libdladm.h>}
{$include <libdladm_impl.h>}
{ C++ extern C conditionnal removed }

  type
    dladm_flow_attr = record
        fa_linkid : datalink_id_t;
        fa_flowname : array[0..(MAXFLOWNAMELEN)-1] of char;
        fa_flow_desc : flow_desc_t;
        fa_resource_props : mac_resource_props_t;
        fa_mask : uint64_t;
        fa_nattr : longint;
      end;
    dladm_flow_attr_t = dladm_flow_attr;
(* Const before type ignored *)

  function dladm_flow_add(_para1:dladm_handle_t; _para2:datalink_id_t; _para3:Pdladm_arg_list_t; _para4:Pdladm_arg_list_t; _para5:Pchar; 
             _para6:boolean_t; _para7:Pchar):dladm_status_t;cdecl;external External_library name 'dladm_flow_add';

(* Const before type ignored *)
  function dladm_flow_remove(_para1:dladm_handle_t; _para2:Pchar; _para3:boolean_t; _para4:Pchar):dladm_status_t;cdecl;external External_library name 'dladm_flow_remove';

  function dladm_flow_init(_para1:dladm_handle_t):dladm_status_t;cdecl;external External_library name 'dladm_flow_init';

  function dladm_flow_parse_db(_para1:Pchar; _para2:Pdld_flowinfo_t):dladm_status_t;cdecl;external External_library name 'dladm_flow_parse_db';

  function dladm_walk_flow(_para1:function (_para1:dladm_handle_t; _para2:Pdladm_flow_attr_t; _para3:pointer):longint; _para2:dladm_handle_t; _para3:datalink_id_t; _para4:pointer; _para5:boolean_t):dladm_status_t;cdecl;external External_library name 'dlad

(* Const before type ignored *)
  function dladm_flow_info(_para1:dladm_handle_t; _para2:Pchar; _para3:Pdladm_flow_attr_t):dladm_status_t;cdecl;external External_library name 'dladm_flow_info';

(* Const before type ignored *)
(* Const before type ignored *)
  function dladm_set_flowprop(_para1:dladm_handle_t; _para2:Pchar; _para3:Pchar; _para4:PPchar; _para5:uint_t; 
             _para6:uint_t; _para7:PPchar):dladm_status_t;cdecl;external External_library name 'dladm_set_flowprop';

(* Const before type ignored *)
(* Const before type ignored *)
  function dladm_get_flowprop(_para1:dladm_handle_t; _para2:Pchar; _para3:uint32_t; _para4:Pchar; _para5:PPchar; 
             _para6:Puint_t):dladm_status_t;cdecl;external External_library name 'dladm_get_flowprop';

(* Const before type ignored *)
(* Const before type ignored *)
  function dladm_walk_flowprop(_para1:function (_para1:pointer; _para2:Pchar):longint; _para2:Pchar; _para3:pointer):dladm_status_t;cdecl;external External_library name 'dladm_walk_flowprop';

  procedure dladm_flow_attr_mask(_para1:uint64_t; _para2:Pdladm_flow_attr_t);cdecl;external External_library name 'dladm_flow_attr_mask';

  function dladm_flow_attr_check(_para1:Pdladm_arg_list_t):dladm_status_t;cdecl;external External_library name 'dladm_flow_attr_check';

  function dladm_prefixlen2mask(_para1:longint; _para2:longint; _para3:Puchar_t):dladm_status_t;cdecl;external External_library name 'dladm_prefixlen2mask';

  function dladm_mask2prefixlen(_para1:Pin6_addr_t; _para2:longint; _para3:Plongint):dladm_status_t;cdecl;external External_library name 'dladm_mask2prefixlen';

  function dladm_proto2str(_para1:uint8_t):^char;cdecl;external External_library name 'dladm_proto2str';

(* Const before type ignored *)
  function dladm_str2proto(_para1:Pchar):uint8_t;cdecl;external External_library name 'dladm_str2proto';

  procedure dladm_flow_attr_ip2str(_para1:Pdladm_flow_attr_t; _para2:Pchar; _para3:size_t);cdecl;external External_library name 'dladm_flow_attr_ip2str';

  procedure dladm_flow_attr_proto2str(_para1:Pdladm_flow_attr_t; _para2:Pchar; _para3:size_t);cdecl;external External_library name 'dladm_flow_attr_proto2str';

  procedure dladm_flow_attr_port2str(_para1:Pdladm_flow_attr_t; _para2:Pchar; _para3:size_t);cdecl;external External_library name 'dladm_flow_attr_port2str';

  procedure dladm_flow_attr_dsfield2str(_para1:Pdladm_flow_attr_t; _para2:Pchar; _para3:size_t);cdecl;external External_library name 'dladm_flow_attr_dsfield2str';

{ C++ end of extern C conditionnal removed }
{$endif}
  { _LIBDLFLOW_H  }

implementation


end.
