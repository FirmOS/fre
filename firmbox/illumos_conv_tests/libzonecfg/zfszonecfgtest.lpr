program zfszonecfgtest;

{$mode objfpc}{$H+}

uses
  cthreads, unixtype, fosillu_libscf, fosillu_nvpair, fosillu_libzfs, fosillu_zfs, Classes, fos_illumos_defs,fosillu_mnttab,fosillu_libzonecfg,
  ctypes, sysutils, strutils, fosillu_priv,
  fos_firmbox_zonectrl,fos_default_implementation, fosillu_hal_dbo_common,fosillu_hal_dbo_zfs_dataset;

var zone_id : zoneid_t;
    flags   : cint;
    res     : cint;

begin
  writeln('FOS ZONECFG Test');
  zone_id := getzoneid;
  flags   := 0;
  res     := zone_getattr(zone_id,ZONE_ATTR_FLAGS,@flags,sizeof(flags));
  writeln('GETUID ',getuid,' GETEUID ',geteuid,' GETGID ',getgid,' ',' GETEGID ',getegid);
  writeln('AR=',res,' ZONEID ',zone_id,' ',(fos_getzonenamebyid(zone_id)),' ',BoolToStr(((flags and 8)>0),'exclusive ip zone','shared ip zone'));

  //sanity_check('86f9c62a7bed960f34b49ad54ec1df22',CMD_BOOT,true,true,true);

  InitIllumosLibraryHandles;
//  list_zones;
  zfs_list_all;

end.

