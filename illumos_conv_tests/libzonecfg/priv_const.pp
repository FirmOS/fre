
unit priv_const;
interface

uses
  ctypes;

{
  Automatically converted by H2Pas 1.0.0 from priv_const.h
  The following command line parameters were used:
    -D
    -c
    -C
    -p
    priv_const.h
}

const
  External_library=''; {Setup as you need}

{ Pointers to basic pascal types, inserted by h2pas conversion program.}
Type
  PLongint  = ^Longint;
  PSmallInt = ^SmallInt;
  PByte     = ^Byte;
  PWord     = ^Word;
  PDWord    = ^DWord;
  PDouble   = ^Double;

Type
Ppriv_impl_info  = ^priv_impl_info;
Ppriv_info_names  = ^priv_info_names;
Ppriv_set  = ^priv_set;
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
 * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
 * Copyright 2013, Joyent, Inc. All rights reserved.
 *
 * Privilege constant definitions; these constants are subject to
 * change, including renumbering, without notice and should not be
 * used in any code.  Privilege names must be used instead.
 * Privileges and privilege sets must not be stored in binary
 * form; privileges and privileges sets must be converted to
 * textual representation before being committed to persistent store.
 *
 * THIS FILE WAS GENERATED; DO NOT EDIT
  }
{$ifndef _SYS_PRIV_CONST_H}
{$define _SYS_PRIV_CONST_H}
{$include <sys/types.h>}
{ C++ extern C conditionnal removed }
{$if defined(_KERNEL) || defined(_KMEMUSER)}

const
  PRIV_NSET = 4;  
  PRIV_SETSIZE = 3;  
{$endif}
{$ifdef _KERNEL}
{$define __PRIV_CONST_IMPL}
(* Const before type ignored *)
  var
    priv_names : ^pcchar;cvar;external;
(* Const before type ignored *)
    priv_setnames : ^pcchar;cvar;external;
    nprivs : cint;cvar;external;
    privbytes : cint;cvar;external;
    maxprivbytes : cint;cvar;external;
    privinfosize : size_t;cvar;external;
    priv_str : pcchar;cvar;external;
    priv_basic : Ppriv_set;cvar;external;
    priv_info : Ppriv_impl_info;cvar;external;
    priv_ninfo : Ppriv_info_names;cvar;external;
{ Privileges  }

const
  PRIV_CONTRACT_EVENT = 0;  
  PRIV_CONTRACT_IDENTITY = 1;  
  PRIV_CONTRACT_OBSERVER = 2;  
  PRIV_CPC_CPU = 3;  
  PRIV_DTRACE_KERNEL = 4;  
  PRIV_DTRACE_PROC = 5;  
  PRIV_DTRACE_USER = 6;  
  PRIV_FILE_CHOWN = 7;  
  PRIV_FILE_CHOWN_SELF = 8;  
  PRIV_FILE_DAC_EXECUTE = 9;  
  PRIV_FILE_DAC_READ = 10;  
  PRIV_FILE_DAC_SEARCH = 11;  
  PRIV_FILE_DAC_WRITE = 12;  
  PRIV_FILE_DOWNGRADE_SL = 13;  
  PRIV_FILE_FLAG_SET = 14;  
  PRIV_FILE_LINK_ANY = 15;  
  PRIV_FILE_OWNER = 16;  
  PRIV_FILE_READ = 17;  
  PRIV_FILE_SETID = 18;  
  PRIV_FILE_UPGRADE_SL = 19;  
  PRIV_FILE_WRITE = 20;  
  PRIV_GRAPHICS_ACCESS = 21;  
  PRIV_GRAPHICS_MAP = 22;  
  PRIV_IPC_DAC_READ = 23;  
  PRIV_IPC_DAC_WRITE = 24;  
  PRIV_IPC_OWNER = 25;  
  PRIV_NET_ACCESS = 26;  
  PRIV_NET_BINDMLP = 27;  
  PRIV_NET_ICMPACCESS = 28;  
  PRIV_NET_MAC_AWARE = 29;  
  PRIV_NET_MAC_IMPLICIT = 30;  
  PRIV_NET_OBSERVABILITY = 31;  
  PRIV_NET_PRIVADDR = 32;  
  PRIV_NET_RAWACCESS = 33;  
  PRIV_PROC_AUDIT = 34;  
  PRIV_PROC_CHROOT = 35;  
  PRIV_PROC_CLOCK_HIGHRES = 36;  
  PRIV_PROC_EXEC = 37;  
  PRIV_PROC_FORK = 38;  
  PRIV_PROC_INFO = 39;  
  PRIV_PROC_LOCK_MEMORY = 40;  
  PRIV_PROC_OWNER = 41;  
  PRIV_PROC_PRIOUP = 42;  
  PRIV_PROC_PRIOCNTL = 43;  
  PRIV_PROC_SESSION = 44;  
  PRIV_PROC_SETID = 45;  
  PRIV_PROC_TASKID = 46;  
  PRIV_PROC_ZONE = 47;  
  PRIV_SYS_ACCT = 48;  
  PRIV_SYS_ADMIN = 49;  
  PRIV_SYS_AUDIT = 50;  
  PRIV_SYS_CONFIG = 51;  
  PRIV_SYS_DEVICES = 52;  
  PRIV_SYS_IPC_CONFIG = 53;  
  PRIV_SYS_LINKDIR = 54;  
  PRIV_SYS_MOUNT = 55;  
  PRIV_SYS_IPTUN_CONFIG = 56;  
  PRIV_SYS_DL_CONFIG = 57;  
  PRIV_SYS_IP_CONFIG = 58;  
  PRIV_SYS_NET_CONFIG = 59;  
  PRIV_SYS_NFS = 60;  
  PRIV_SYS_PPP_CONFIG = 61;  
  PRIV_SYS_RES_BIND = 62;  
  PRIV_SYS_RES_CONFIG = 63;  
  PRIV_SYS_RESOURCE = 64;  
  PRIV_SYS_SMB = 65;  
  PRIV_SYS_SUSER_COMPAT = 66;  
  PRIV_SYS_TIME = 67;  
  PRIV_SYS_TRANS_LABEL = 68;  
  PRIV_VIRT_MANAGE = 69;  
  PRIV_WIN_COLORMAP = 70;  
  PRIV_WIN_CONFIG = 71;  
  PRIV_WIN_DAC_READ = 72;  
  PRIV_WIN_DAC_WRITE = 73;  
  PRIV_WIN_DEVICES = 74;  
  PRIV_WIN_DGA = 75;  
  PRIV_WIN_DOWNGRADE_SL = 76;  
  PRIV_WIN_FONTPATH = 77;  
  PRIV_WIN_MAC_READ = 78;  
  PRIV_WIN_MAC_WRITE = 79;  
  PRIV_WIN_SELECTION = 80;  
  PRIV_WIN_UPGRADE_SL = 81;  
  PRIV_XVM_CONTROL = 82;  
{ Privilege sets  }
  PRIV_EFFECTIVE = 0;  
  PRIV_INHERITABLE = 1;  
  PRIV_PERMITTED = 2;  
  PRIV_LIMIT = 3;  
  MAX_PRIVILEGE = 96;  
{#define	PRIV_UNSAFE_ASSERT(set)\ }
{		PRIV_ASSERT((set), PRIV_PROC_AUDIT);\ }
{		PRIV_ASSERT((set), PRIV_PROC_SETID);\ }
{		PRIV_ASSERT((set), PRIV_SYS_RESOURCE) }
{#define	PRIV_BASIC_ASSERT(set)\ }
{		PRIV_ASSERT((set), PRIV_FILE_LINK_ANY);\ }
{		PRIV_ASSERT((set), PRIV_FILE_READ);\ }
{		PRIV_ASSERT((set), PRIV_FILE_WRITE);\ }
{		PRIV_ASSERT((set), PRIV_NET_ACCESS);\ }
{		PRIV_ASSERT((set), PRIV_PROC_EXEC);\ }
{		PRIV_ASSERT((set), PRIV_PROC_FORK);\ }
{		PRIV_ASSERT((set), PRIV_PROC_INFO);\ }
{		PRIV_ASSERT((set), PRIV_PROC_SESSION) }
{$endif}
{ _KERNEL  }
{ C++ end of extern C conditionnal removed }
{$endif}
{ _SYS_PRIV_CONST_H  }

implementation


end.
