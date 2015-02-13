program zpconftest;

{$mode objfpc}{$H+}
{$LINKLIB libumem.so}

uses
  //cthreads,
  cmem,
  fosillu_nvpair,fosillu_libzfs,fosillu_zfs,Classes, fos_illumos_defs,ctypes,sysutils,strutils;

var
  zph : Plibzfs_handle_t;


  function FOSNVGET_U64(const elem:Pnvpair_t ; var val:UInt64):boolean;
  begin
    result := nvpair_value_uint64(elem,@val)=0;
  end;

  function FOSNVGET_BOOLEAN(const elem:Pnvpair_t; var val: boolean):boolean;
  begin
    result := true;
    val    := true; { there is no function, the existence of the value implies true }
  end;

  function FOSNVGET_U64ARR(const elem:Pnvpair_t ; var val:PPuint64_t ; var cnt : Uint64_t):boolean;
  begin
    result := nvpair_value_uint64_array(elem,@val,@cnt)=0;
  end;

  function FOSNVGET_STRING(const elem:Pnvpair_t ; var val:string):boolean;
  var s : Pchar;
  begin
    result := nvpair_value_string(elem,@s)=0;
    val    := s;
  end;

  function FOSNVGET_NVLIST(const elem:Pnvpair_t ; var nvlist : Pnvlist_t):boolean;
  begin
    result := nvpair_value_nvlist(elem,@nvlist)=0;
  end;

  function FOSNVGET_NVARR(const elem:Pnvpair_t ; var nvlistarr : PPnvlist_t ; var cnt : uint_t):boolean;
  begin
    result := nvpair_value_nvlist_array(elem,@nvlistarr,@cnt)=0;
  end;

  function FOSNVPAIR_NAME(const elem:Pnvpair_t):string;
  begin
    result := pchar(nvpair_name(elem));
  end;

{
 * Vdev statistics.  Note: all fields should be 64-bit because this
 * is passed between kernel and userland as an nvlist uint64 array.
  }
{ time since vdev load	 }
{ vdev state		 }
{ see vdev_aux_t	 }
{ space allocated	 }
{ total capacity	 }
{ deflated capacity	 }
{ replaceable dev size  }
{ expandable dev size  }
{ operation count	 }
{ bytes read/written	 }
{ read errors		 }
{ write errors		 }
{ checksum errors	 }
{ self-healed bytes	 }
{ removing?	 }
{ scan processed bytes	 }

 // vs_timestamp : hrtime_t;
 // vs_state : uint64_t;
 // vs_aux : uint64_t;
 // vs_alloc : uint64_t;
 // vs_space : uint64_t;
 // vs_dspace : uint64_t;
 // vs_rsize : uint64_t;
 // vs_esize : uint64_t;
 // vs_ops : array[0..ord(ZIO_TYPES)-1] of uint64_t;
 // vs_bytes : array[0..ord(ZIO_TYPES)-1] of uint64_t;
 // vs_read_errors : uint64_t;
 // vs_write_errors : uint64_t;
 // vs_checksum_errors : uint64_t;
 // vs_self_healed : uint64_t;
 // vs_scan_removing : uint64_t;
 // vs_scan_processed : uint64_t;

  procedure dump_zfs_state(const  elem : Pnvpair_t ; const indent : integer);
  var vs   : Pvdev_stat_t;
       c   : Uint64_t=0;
      uia  : PPuint64_t=nil;
      i    : integer;
      demo : string='';
  begin
    if FOSNVGET_U64ARR(elem,uia,c) then
      begin
        vs := Pvdev_stat_t(uia);
        WriteStr(demo,vdev_state(vs^.vs_state));
        WriteLn(StringOfChar(' ',indent),'--VDEV-STATS--');
        WriteLn(StringOfChar(' ',indent),'STATE           = ',vdev_state(vs^.vs_state),' :: ',demo);
        WriteLn(StringOfChar(' ',indent),'TIMESTAMP       = ',vs^.vs_timestamp);
        WriteLn(StringOfChar(' ',indent),'AUX             = ',vdev_aux(vs^.vs_aux));
        WriteLn(StringOfChar(' ',indent),'ALLOC           = ',(vs^.vs_alloc));
        WriteLn(StringOfChar(' ',indent),'SPACE           = ',(vs^.vs_space));
        WriteLn(StringOfChar(' ',indent),'DSPACE          = ',(vs^.vs_dspace));
        WriteLn(StringOfChar(' ',indent),'RSIZE           = ',(vs^.vs_rsize));
        WriteLn(StringOfChar(' ',indent),'ESIZE           = ',(vs^.vs_esize));
        WriteLn(StringOfChar(' ',indent),'DSPACE          = ',(vs^.vs_dspace));
        WriteLn(StringOfChar(' ',indent),'READ ERRORS     = ',(vs^.vs_read_errors));
        WriteLn(StringOfChar(' ',indent),'WRITE ERRORS    = ',(vs^.vs_write_errors));
        WriteLn(StringOfChar(' ',indent),'CHECKSUM ERRORS = ',(vs^.vs_checksum_errors));
        WriteLn(StringOfChar(' ',indent),'SCAN REMOVING   = ',(vs^.vs_scan_removing));
        WriteLn(StringOfChar(' ',indent),'SCAN PROCESSED  = ',(vs^.vs_scan_processed));
        for i:=0 to ord(ZIO_TYPES)-1 do
          begin
            WriteLn(StringOfChar(' ',indent+2),zio_type_t(i):15,' = ',vs^.vs_ops[i]:10,' / ',vs^.vs_bytes[i]);
          end;
      end;
  end;

{
	vdev_stat_t *vs;
	uint_t	c;

	VERIFY(nvpair_value_uint64_array(elem, (uint64_t **) &vs, &c) == 0);
	printf("%*sstate=%llu\n", indent, "", (u_longlong_t) vs->vs_state);
	printf("%*saux=%llu\n", indent, "", (u_longlong_t) vs->vs_aux);
	printf("%*s...\n", indent, "");
}

  procedure dump_nvlist(const list : Pnvlist_t ;  indent : cint);
  var elem      : Pnvpair_t  = nil;
      nvlist    : Pnvlist_t  = nil;
      nvlistarr : PPnvlist_t = nil;
      count     : uint_t=0;
      u64val    : UInt64=0;
      strval    : string='';
      boolval   : boolean=false;
      i         : integer;
      name      : string;
  begin
    repeat
      elem := nvlist_next_nvpair(list, elem);
      if not assigned(elem) then
                    exit;
      case nvpair_type(elem) of
        DATA_TYPE_STRING :
            if FOSNVGET_STRING(elem,strval) then
              writeln(StringOfChar(' ',indent),FOSNVPAIR_NAME(elem),'=',strval);
        DATA_TYPE_UINT64 :
            if FOSNVGET_U64(elem,u64val) then
              writeln(StringOfChar(' ',indent),FOSNVPAIR_NAME(elem),'=',u64val);
        DATA_TYPE_NVLIST :
            if FOSNVGET_NVLIST(elem,nvlist) then
              begin
                writeln(StringOfChar(' ',indent),FOSNVPAIR_NAME(elem));
                dump_nvlist(nvlist,indent+4);
              end;
        DATA_TYPE_NVLIST_ARRAY :
            begin
              if FOSNVGET_NVARR(elem,nvlistarr,count) then
                for i := 0 to count-1 do
                  begin
                    writeln(StringOfChar(' ',indent),FOSNVPAIR_NAME(elem),'[',count,']');
                    dump_nvlist(nvlistarr[i],indent+8);
                  end;
            end;
        DATA_TYPE_UINT64_ARRAY :
            begin
              name := FOSNVPAIR_NAME(elem);
              if name = 'vdev_stats' then
                dump_zfs_state(elem,indent+4)
              else
                writeln(StringOfChar(' ',indent),name,' <array of uint64_t>')
            end;
        DATA_TYPE_BOOLEAN:
            begin
              if FOSNVGET_BOOLEAN(elem,boolval) then
                writeln(StringOfChar(' ',indent),FOSNVPAIR_NAME(elem),'=',BoolToStr(boolval,'1','0'));
            end;
        else
          begin
            writeln('unhandled config type ',nvpair_type(elem),' for name=',FOSNVPAIR_NAME(elem));
          end;
      end;
    until false;
  end;

  procedure dump_config(const pooln : string);
  var zp : Pzpool_handle_t;
      zs : Pnvlist_t;
  begin
    writeln(pooln);
    zp := zpool_open(zph, Pchar(@pooln[1]));
    if not assigned(zp) then
      begin
        writeln('cannot open zpool ',pooln);
        exit;
      end;
    zs := zpool_get_config(zp, nil);
    dump_nvlist(zs, 4);
    if assigned(zp) then
      zpool_close(zp);
  end;

 type
   zfs_cb_data=record
     zproplist   : Pzprop_list_t;
     props_table : Array [0..ord(ZFS_NUM_PROPS)] of uint8_t;
   end;
   Pzfs_cb_data = ^zfs_cb_data;

 var funcp:zfs_iter_f;
     funcp2:zfs_iter_f;

  function dataset_cb_zvol(z_hdl:Pzfs_handle_t; data:pointer):cint;cdecl;
  begin
    writeln('ZFS TYPE FROM ZVOL ',zfs_get_type(z_hdl),' ',zfs_get_name(z_hdl));
    exit(0);
  end;

  function dataset_cb(z_hdl:Pzfs_handle_t; data:pointer):cint;cdecl;
  //var ztyp       : zfs_type_t;
  //    cbd        : Pzfs_cb_data;
  //    userprops  : Pnvlist_t;
  //    propval    : Pnvlist_t;
  //    propstr    : Pchar;
  //    source     : zprop_source_t;
  //    property_  : array [0..ZFS_MAXPROPLEN] of char;
  //    sourcename : array [0..ZFS_MAXNAMELEN] of char;
  //    src        : string;

      //procedure print_ds;
      //var pl : Pzprop_list_t;
      //begin
      //  userprops := zfs_get_user_props(z_hdl);
      //  pl := cbd^.zproplist;
      //  while(pl<>Nil) do
      //    begin
      //      if pl^.pl_prop <> ZPROP_INVAL then
      //        begin
      //          if zfs_prop_get(z_hdl,zfs_prop_t(pl^.pl_prop),@property_,sizeof(property_),@source,@sourcename,SizeOf(sourcename),B_TRUE)=0 then
      //            begin
      //              case source of
      //                ZPROP_SRC_NONE:      src := '-';
      //                ZPROP_SRC_DEFAULT:   src := 'D';
      //                ZPROP_SRC_TEMPORARY: src := 'TT';
      //                ZPROP_SRC_LOCAL:     src := 'L';
      //                ZPROP_SRC_INHERITED: src := 'I';
      //                ZPROP_SRC_RECEIVED:  src := 'R';
      //              end;
      //              writeln('  SYS:',zfs_prop_to_name(zfs_prop_t(pl^.pl_prop)),': ',pchar(property_),' SOURCE : ',src);//' ',pchar(sourcename));
      //            end;
      //        end
      //      else
      //      if ord(zfs_prop_userquota_(pchar(pl^.pl_user_prop)))<>0 then
      //        begin
      //           writeln('userquota!');
      //        end
      //      else
      //      if ord(zfs_prop_written_(pchar(pl^.pl_user_prop)))<>0 then
      //        begin
      //          writeln('written!');
      //        end
      //      else
      //        begin
      //          if nvlist_lookup_nvlist(userprops,Pcchar(pl^.pl_user_prop),@propval)<>0 then
      //            propstr:='-'
      //          else
      //            begin
      //              if nvlist_lookup_string(propval,PCChar(ZPROP_VALUE),@propstr)<>0 then
      //                propstr := 'lookup failure';
      //                writeln('  USR:',Pchar(pl^.pl_user_prop),': ''',propstr,'''');
      //            end;
      //        end;
      //      pl :=  pl^.pl_next;
      //    end;
      //end;

  begin
    //cbd := Pzfs_cb_data(data);
    //ztyp := zfs_get_type(z_hdl);
    writeln('ZFS TYPE ',zfs_get_type(z_hdl),' ',zfs_get_name(z_hdl));
    //if not assigned(cbd^.zproplist) then
    //  writeln('EXPAND PD ',integer(cbd^.zproplist),' ',zfs_expand_proplist(z_hdl,@cbd^.zproplist,B_TRUE,B_TRUE),' ',integer(cbd^.zproplist));
    //print_ds;

    if zfs_get_type(z_hdl) <> ZFS_TYPE_VOLUME then
      begin
        if zfs_get_type(z_hdl) = ZFS_TYPE_FILESYSTEM then
          zfs_iter_filesystems(z_hdl,funcp,data);
        if (zfs_get_type(z_hdl) and (ZFS_TYPE_SNAPSHOT or ZFS_TYPE_BOOKMARK)) = 0 then
          zfs_iter_snapshots(z_hdl,funcp,data);
      end
    else
      begin
        //if (zfs_get_type(z_hdl) and (ZFS_TYPE_SNAPSHOT or ZFS_TYPE_BOOKMARK)) = 0 then
         zfs_iter_snapshots(z_hdl,funcp2,data);
      end;
    //if (ztyp and (ZFS_TYPE_SNAPSHOT or ZFS_TYPE_BOOKMARK)) = 0 then
    //   zfs_iter_bookmarks(z_hdl,funcp,data);
    result := 0;
    zfs_close(z_hdl);
  end;

  const default:pchar='name';

  procedure list_datasets;
  var data_cb : zfs_cb_data;
  begin
    data_cb.zproplist:=Nil;
    zprop_get_list(zph,default,@data_cb.zproplist,ZFS_TYPE_DATASET);
    funcp := @dataset_cb;
    funcp2 := @dataset_cb_zvol;
    zfs_iter_root(zph,funcp,@data_cb);
    zprop_free_list(data_cb.zproplist);
  end;

  var startt,enddt : TDateTime;
      endless : boolean;
begin
  writeln('FOS ZPC Test, set FOS_ENDLESS<>'' to run endless');
  endless := GetEnvironmentVariable('FOS_ENDLESS')='';
  zph := nil;
  zph := libzfs_init();
  libzfs_print_on_error(zph,B_TRUE);
 // libzfs_mnttab_cache(zph,B_TRUE);
  libzfs_set_cachedprops(zph,B_TRUE);
  //if paramstr(1)='' then
  //  dump_config('syspool')
  //else
  //  dump_config(paramstr(1));
  repeat
    startt:=now;
    writeln('START RUN ');
    list_datasets;
    enddt:=now;
    writeln('END RUN ',(enddt-startt)*100000:5:4);
  until endless;
  libzfs_mnttab_cache(zph,B_FALSE);
  libzfs_fini(zph);
end.

