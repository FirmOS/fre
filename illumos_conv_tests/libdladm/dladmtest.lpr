program dladmtest;

{$mode objfpc}{$H+}
{$codepage utf-8}

uses
  cthreads, unixtype,Classes,fre_db_interface,fos_default_implementation,
  fos_illumos_defs,
  fosillu_libscf,
  fosillu_nvpair,
  fosillu_libzfs, fosillu_zfs,
  fosillu_mnttab,fosillu_libzonecfg,
  fosillu_libdladm,
  ctypes, sysutils, strutils, fosillu_sysnet_common, fosillu_dladm;

{$LINKLIB libdladm}


var res,status  : dladm_status_t;
    err         : string;
    rb          : boolean;
    m           : TFOS_MAC_ADDR;
    paramst     : string;
    i           : integer;
    linkname    : string;
    bridgename  : string;
    aggrname    : string;

begin
  paramst := ParamStr(1);
  res := dladm_open(@GILLU_DLADM);

  if res=DLADM_STATUS_OK then
    begin
      linkname:='hugo0';
      linkname:='e1000g0';
      if paramst='ce' then
        WriteLn('CREATE ETHERSTUB ',create_etherstub('hugo0',err),' ',err)
      else
      if paramst='de' then
        WriteLn('DELETE ETHERSTUB ',delete_etherstub('hugo0',err),' ',err)
      else
      if paramst='cv' then
        begin
          m.SetFromString('02:22:33:44:55:65');
          writeln('CREATE VNIC ',m.GetAsString,' ',create_vnic('hugovn1',linkname,m,err),' ',err);
        end;
      if paramst='dv' then
        writeln('DELETE VNIC ',delete_vnic('hugovn1',err),' ',err)
      else
      if paramst='cvz' then
        begin
          m.SetFromString('02:22:33:44:55:67');
          writeln('CREATE VNIC ZONED ',m.GetAsString,' ',create_vnic('hugovn1',linkname,m,err,'demo',1492),' ',err);
        end
      else
      if paramst='dvz' then
        writeln('DELETE VNIC ZONED ',delete_vnic('hugovn1',err,'demo'),' ',err)
      else
      if paramst='glp' then
        writeln('get linkprops',get_linkprops('hugovn1',err),' ',err)
      else
      if paramst='addbridge' then
        begin
          bridgename := ParamStr(2);
          linkname   := Paramstr(3);
          writeln('add to bridge',add_to_bridge(bridgename,TFRE_DB_StringArray.Create(linkname),err),' ',err)
        end
      else
      if paramst='removebridge' then
        begin
          bridgename := ParamStr(2);
          linkname   := Paramstr(3);
          writeln('remove from bridge',remove_from_bridge(bridgename,TFRE_DB_StringArray.Create(linkname),err),' ',err)
        end
      else
      if paramst='createbridge' then
        begin
         bridgename := PAramstr(2);
         writeln('create bridge',create_bridge(bridgename,TFRE_DB_StringArray.Create,err),' ',err);
        end
      else
      if paramst='deletebridge' then
        begin
         bridgename := PAramstr(2);
         writeln('delete bridge',delete_bridge(bridgename,err),' ',err);
        end
      else
      if paramst='createsim' then
        begin
         linkname := PAramstr(2);
         writeln('create sim',create_simnet(linkname,err),' ',err);
        end
      else
      if paramst='deletesim' then
        begin
         linkname := PAramstr(2);
         writeln('delete sim',delete_simnet(linkname,err),' ',err);
        end
      else
      if paramst='createaggr' then
        begin
         aggrname := PAramstr(2);
         linkname := PAramstr(3);
         writeln('create aggr',create_aggr(aggrname,1,TFRE_DB_StringArray.Create(linkname),'L2','short','active',false,err),' ',err);
        end
      else
      if paramst='deleteeaggr' then
        begin
         aggrname := PAramstr(2);
         writeln('delete aggr',delete_aggr(aggrname,err),' ',err);
        end
      else
      if paramst='addaggr' then
        begin
         aggrname := PAramstr(2);
         linkname := PAramstr(3);
         writeln('add aggr',add_to_aggr(aggrname,TFRE_DB_StringArray.Create(linkname),false,err),' ',err);
        end
      else
      if paramst='removeaggr' then
        begin
         aggrname := PAramstr(2);
         linkname := PAramstr(3);
         writeln('remove aggr',remove_from_aggr(aggrname,TFRE_DB_StringArray.Create(linkname),err),' ',err);
        end
      else
      if paramst='modifyaggr' then
        begin
         aggrname := PAramstr(2);
         writeln('modify aggr',modify_aggr(aggrname,'L2','long','off',err),' ',err);
        end
      else
      if paramst='connectsim' then
        begin
         aggrname := PAramstr(2);
         linkname := PAramstr(3);
         writeln('connect sim',connect_simnet(aggrname,linkname,err),' ',err);
        end
      else
        writeln('SCHEI* PARAMETER');
    end
  else
    writeln('DLADM OPEN FAILED ',res);
end.

