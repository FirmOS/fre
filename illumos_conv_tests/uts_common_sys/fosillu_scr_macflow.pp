unit fosillu_scr_macflow;
interface

{
  Automatically converted by H2Pas 1.0.0 from mac_flow_stripd.h
  The following command line parameters were used:
    -DcCpv
    -o
    fosillu_scr_macflow.pp
    mac_flow_stripd.h
}

  const
    External_library=''; {Setup as you need}

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
   * Copyright 2010 Sun Microsystems, Inc.  All rights reserved.
   * Use is subject to license terms.
   * Copyright 2013 Joyent, Inc.  All rights reserved.
    }
{$ifndef	_MAC_FLOW_H}
{$define _MAC_FLOW_H}  
  {
   * Main structure describing a flow of packets, for classification use
    }
{ C++ extern C conditionnal removed }
{$include <sys/types.h>}
{$include <netinet/in.h>		/* for IPPROTO_* constants */}
{$include <sys/ethernet.h>}


implementation


end.
