
unit fosillu_scr;
interface

{
  Automatically converted by H2Pas 1.0.0 from libdllink_stripd.h
  The following command line parameters were used:
    -DcCpv
    -o
    fosillu_scr.pp
    libdllink_stripd.h
}

  const
    External_library=''; {Setup as you need}

  Type
  Pboolean_t  = ^boolean_t;
  Pchar  = ^char;
  Pdatalink_class_t  = ^datalink_class_t;
  Pdatalink_id_t  = ^datalink_id_t;
  Pdladm_arg_list_t  = ^dladm_arg_list_t;
  Pdladm_attr_t  = ^dladm_attr_t;
  Pdladm_conf_t  = ^dladm_conf_t;
  Pdladm_hwgrp_attr_t  = ^dladm_hwgrp_attr_t;
  Pdladm_macaddr_attr_t  = ^dladm_macaddr_attr_t;
  Pdladm_phys_attr_t  = ^dladm_phys_attr_t;
  Pdladm_secobj_class_t  = ^dladm_secobj_class_t;
  Pdladm_walkcb_t  = ^dladm_walkcb_t;
  Psize_t  = ^size_t;
  Puint32_t  = ^uint32_t;
  Puint8_t  = ^uint8_t;
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
   * Copyright (c) 2011, Joyent Inc. All rights reserved.
    }
{$ifndef _LIBDLLINK_H}
{$define _LIBDLLINK_H}  
  {
   * This file includes structures, macros and routines used by general
   * link administration (i.e. not limited to one specific type of link).
    }
{$include <stdio.h>}
{$include <sys/types.h>}
{$include <sys/param.h>}
{$include <sys/mac.h>}
{$include <sys/dld.h>}
{$include <libdladm.h>}
{ C++ extern C conditionnal removed }


{ C++ end of extern C conditionnal removed }
{$endif}
  { _LIBDLLINK_H  }

implementation


end.
