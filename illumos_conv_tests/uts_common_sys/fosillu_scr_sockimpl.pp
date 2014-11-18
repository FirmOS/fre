
unit fosillu_scr_sockimpl;
interface

{
  Automatically converted by H2Pas 1.0.0 from socket_impl.h
  The following command line parameters were used:
    -DcCpv
    -o
    fosillu_scr_sockimpl.pp
    socket_impl.h
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
   * Copyright 2009 Sun Microsystems, Inc.  All rights reserved.
   * Use is subject to license terms.
    }
  {	Copyright (c) 1983, 1984, 1985, 1986, 1987, 1988, 1989 AT&T	 }
  {	  All Rights Reserved	 }
  {
   * Portions of this source code were derived from Berkeley 4.3 BSD
   * under license from the Regents of the University of California.
    }

{ C++ end of extern C conditionnal removed }
{$endif}
  { _SYS_SOCKET_IMPL_H  }

implementation

  { was #define dname def_expr }
  function _SS_ALIGNSIZE : longint; { return type might be wrong }
    begin
      _SS_ALIGNSIZE:=sizeof(sockaddr_maxalign_t);
    end;

  { was #define dname def_expr }
  function _SS_PAD1SIZE : longint; { return type might be wrong }
    begin
      _SS_PAD1SIZE:=_SS_ALIGNSIZE-(sizeof(sa_family_t));
    end;

  { was #define dname def_expr }
  function _SS_PAD2SIZE : longint; { return type might be wrong }
    begin
      _SS_PAD2SIZE:=_SS_MAXSIZE-(((sizeof(sa_family_t))+_SS_PAD1SIZE)+_SS_ALIGNSIZE);
    end;


end.
