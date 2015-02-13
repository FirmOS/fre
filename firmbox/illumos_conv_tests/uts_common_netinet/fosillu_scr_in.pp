
unit fosillu_scr_in;
interface

{
  Automatically converted by H2Pas 1.0.0 from in_stripd.h
  The following command line parameters were used:
    -DcCpv
    -o
    fosillu_scr_in.pp
    in_stripd.h
}


implementation

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_CLASSA(i : longint) : longint;
  begin
    IN_CLASSA:=(i(@($80000000)))=0;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_CLASSB(i : longint) : longint;
  begin
    IN_CLASSB:=(i(@($c0000000)))=$80000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_CLASSC(i : longint) : longint;
  begin
    IN_CLASSC:=(i(@($e0000000)))=$c0000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_CLASSD(i : longint) : longint;
  begin
    IN_CLASSD:=(i(@($f0000000)))=$e0000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_CLASSE(i : longint) : longint;
  begin
    IN_CLASSE:=(i(@($f0000000)))=$f0000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_MULTICAST(i : longint) : longint;
  begin
    IN_MULTICAST:=IN_CLASSD(i);
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_EXPERIMENTAL(i : longint) : longint;
  begin
    IN_EXPERIMENTAL:=(i(@($e0000000)))=$e0000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_BADCLASS(i : longint) : longint;
  begin
    IN_BADCLASS:=(i(@($f0000000)))=$f0000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN_LINKLOCAL(i : longint) : longint;
  begin
    IN_LINKLOCAL:=(i(@(IN_AUTOCONF_MASK)))=IN_AUTOCONF_NET;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_UNSPECIFIED(addr : longint) : longint;
  begin
    IN6_IS_ADDR_UNSPECIFIED:=((((addr^.(_S6_un.(_S6_u32[3])))=0) and (@((addr^.(_S6_un.(_S6_u32[2])))=0))) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_LOOPBACK(addr : longint) : longint;
  begin
    IN6_IS_ADDR_LOOPBACK:=((((addr^.(_S6_un.(_S6_u32[3])))=$00000001) and (@((addr^.(_S6_un.(_S6_u32[2])))=0))) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_LOOPBACK(addr : longint) : longint;
  begin
    IN6_IS_ADDR_LOOPBACK:=((((addr^.(_S6_un.(_S6_u32[3])))=$01000000) and (@((addr^.(_S6_un.(_S6_u32[2])))=0))) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MULTICAST(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MULTICAST:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff000000)=$ff000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MULTICAST(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MULTICAST:=((addr^.(_S6_un.(_S6_u32[0]))) and $000000ff)=$000000ff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_LINKLOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_LINKLOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ffc00000)=$fe800000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_LINKLOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_LINKLOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $0000c0ff)=$000080fe;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_SITELOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_SITELOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ffc00000)=$fec00000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_SITELOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_SITELOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $0000c0ff)=$0000c0fe;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_V4MAPPED(addr : longint) : longint;
  begin
    IN6_IS_ADDR_V4MAPPED:=(((addr^.(_S6_un.(_S6_u32[2])))=$0000ffff) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_V4MAPPED(addr : longint) : longint;
  begin
    IN6_IS_ADDR_V4MAPPED:=(((addr^.(_S6_un.(_S6_u32[2])))=$ffff0000) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_V4MAPPED_ANY(addr : longint) : longint;
  begin
    IN6_IS_ADDR_V4MAPPED_ANY:=((((addr^.(_S6_un.(_S6_u32[3])))=0) and (@((addr^.(_S6_un.(_S6_u32[2])))=$0000ffff))) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_V4MAPPED_ANY(addr : longint) : longint;
  begin
    IN6_IS_ADDR_V4MAPPED_ANY:=((((addr^.(_S6_un.(_S6_u32[3])))=0) and (@((addr^.(_S6_un.(_S6_u32[2])))=$ffff0000))) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_V4COMPAT(addr : longint) : longint;
  begin
    IN6_IS_ADDR_V4COMPAT:=(((((addr^.(_S6_un.(_S6_u32[2])))=0) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0))) and (@( not ((addr^.(_S6_un.(_S6_u32[3])))=0)))) and (@( not ((addr^.(_S6_un.(_S6_u32[3])))=$00000001)));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_V4COMPAT(addr : longint) : longint;
  begin
    IN6_IS_ADDR_V4COMPAT:=(((((addr^.(_S6_un.(_S6_u32[2])))=0) and (@((addr^.(_S6_un.(_S6_u32[1])))=0))) and (@((addr^.(_S6_un.(_S6_u32[0])))=0))) and (@( not ((addr^.(_S6_un.(_S6_u32[3])))=0)))) and (@( not ((addr^.(_S6_un.(_S6_u32[3])))=$01000000)));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_RESERVED(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_RESERVED:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff0f0000)=$ff000000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_RESERVED(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_RESERVED:=((addr^.(_S6_un.(_S6_u32[0]))) and $00000fff)=$000000ff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_NODELOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_NODELOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff0f0000)=$ff010000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_NODELOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_NODELOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $00000fff)=$000001ff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_LINKLOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_LINKLOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff0f0000)=$ff020000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_LINKLOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_LINKLOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $00000fff)=$000002ff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_SITELOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_SITELOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff0f0000)=$ff050000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_SITELOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_SITELOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $00000fff)=$000005ff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_ORGLOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_ORGLOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff0f0000)=$ff080000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_ORGLOCAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_ORGLOCAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $00000fff)=$000008ff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_GLOBAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_GLOBAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $ff0f0000)=$ff0e0000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_GLOBAL(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_GLOBAL:=((addr^.(_S6_un.(_S6_u32[0]))) and $00000fff)=$00000eff;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_SOLICITEDNODE(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_SOLICITEDNODE:=((((addr^.(_S6_un.(_S6_u32[0])))=$ff020000) and (@((addr^.(_S6_un.(_S6_u32[1])))=$00000000))) and (@((addr^.(_S6_un.(_S6_u32[2])))=$00000001))) and (@(((addr^.(_S6_un.(_S6_u32[3]))) and $ff000000)=$ff000000));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_MC_SOLICITEDNODE(addr : longint) : longint;
  begin
    IN6_IS_ADDR_MC_SOLICITEDNODE:=((((addr^.(_S6_un.(_S6_u32[0])))=$000002ff) and (@((addr^.(_S6_un.(_S6_u32[1])))=$00000000))) and (@((addr^.(_S6_un.(_S6_u32[2])))=$01000000))) and (@(((addr^.(_S6_un.(_S6_u32[3]))) and $000000ff)=$000000ff));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_6TO4(addr : longint) : longint;
  begin
    IN6_IS_ADDR_6TO4:=((addr^.(_S6_un.(_S6_u32[0]))) and $ffff0000)=$20020000;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_IS_ADDR_6TO4(addr : longint) : longint;
  begin
    IN6_IS_ADDR_6TO4:=((addr^.(_S6_un.(_S6_u32[0]))) and $0000ffff)=$00000220;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_ARE_6TO4_PREFIX_EQUAL(addr1,addr2 : longint) : longint;
  begin
    IN6_ARE_6TO4_PREFIX_EQUAL:=(((addr1^.(_S6_un.(_S6_u32[0])))=(addr2^.(_S6_un.(_S6_u32[0])))) and (@((addr1^.(_S6_un.(_S6_u8[4])))=(addr2^.(_S6_un.(_S6_u8[4])))))) and (@((addr1^.(_S6_un.(_S6_u8[5])))=(addr2^.(_S6_un.(_S6_u8[5])))));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_V4MAPPED_TO_INADDR(v6,v4 : longint) : longint;
  begin
    IN6_V4MAPPED_TO_INADDR:=(v4^.s_addr):=(v6^.(_S6_un.(_S6_u32[3])));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_V4MAPPED_TO_IPADDR(v6,v4 : longint) : longint;
  begin
    IN6_V4MAPPED_TO_IPADDR:=v4:=(v6^.(_S6_un.(_S6_u32[3])));
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_ARE_ADDR_EQUAL(addr1,addr2 : longint) : longint;
  begin
    IN6_ARE_ADDR_EQUAL:=((((addr1^.(_S6_un.(_S6_u32[3])))=(addr2^.(_S6_un.(_S6_u32[3])))) and (@((addr1^.(_S6_un.(_S6_u32[2])))=(addr2^.(_S6_un.(_S6_u32[2])))))) and (@((addr1^.(_S6_un.(_S6_u32[1])))=(addr2^.(_S6_un.(_S6_u32[1])))))) and (@((addr1^.(_S6_u
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_MASK_FROM_PREFIX(qoctet,prefix : longint) : longint;
  var
     if_local1, if_local2 : longint;
  (* result types are not known *)
  begin
    if (qoctet*32)>=prefix then
      if_local1:=$00000000
    else
      if_local1:=$FFFFFFFF shl (((qoctet(+(1)))*32)-prefix);
    if ((qoctet(+(1)))*32)<prefix then
      if_local2:=$FFFFFFFF
    else
      if_local2:=if_local1;
    IN6_MASK_FROM_PREFIX:=if_local2;
  end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function IN6_ARE_PREFIXEDADDR_EQUAL(addr1,addr2,prefix : longint) : longint;
  begin
    IN6_ARE_PREFIXEDADDR_EQUAL:=(((((ntohl(addr1^.(_S6_un.(_S6_u32[0])))) and (IN6_MASK_FROM_PREFIX(0,prefix)))=((ntohl(addr2^.(_S6_un.(_S6_u32[0])))) and (IN6_MASK_FROM_PREFIX(0,prefix)))) and (@(((ntohl(addr1^.(_S6_un.(_S6_u32[1])))) and (IN6_MASK_FROM_
  end;


end.
