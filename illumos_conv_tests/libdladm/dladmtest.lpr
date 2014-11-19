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

var res         : dladm_status_t;
    err         : string;
    rb          : boolean;
    m           : TFOS_MAC_ADDR;
    paramst     : string;
    i           : integer;
    linkname    : string;
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
        writeln('get linkprops',get_linkprops('hugovn1',err),' ',err);
    end
  else
    writeln('DLADM OPEN FAILED ',res);
end.

