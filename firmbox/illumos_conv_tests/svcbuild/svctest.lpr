program svctest;

{$mode objfpc}{$H+}

uses
  cthreads, unixtype, fosillu_libscf, fosillu_nvpair, fosillu_libzfs, fosillu_zfs, Classes, fos_illumos_defs,fosillu_mnttab,fosillu_libzonecfg,
  ctypes, sysutils, strutils;

var h      : Pscf_handle_t;
    res    : integer;
    g_pg   : Pscf_propertygroup_t;
    g_prop : Pscf_property_t;
    g_val  : Pscf_value_t;

    {*
     * Convenience libscf wrapper functions.
     *

    *
     * Get the single value of the named property in the given property group,
     * which must have type ty, and put it in *vp.  If ty is SCF_TYPE_ASTRING, vp
     * is taken to be a char **, and sz is the size of the buffer.  sz is unused
     * otherwise.  Return 0 on success, -1 if the property doesn't exist, has the
     * wrong type, or doesn't have a single value.  If flags has EMPTY_OK, don't
     * complain if the property has no values (but return nonzero).  If flags has
     * MULTI_OK and the property has multiple values, succeed with E2BIG.
     *
     }

    function
    pg_get_single_val(pg : Pscf_propertygroup_t; const propname : string; ty : scf_type_t ;
        vp : pointer ;  sz : size_t ;  flags : uint_t):cint;
    begin
      if ty<>SCF_TYPE_ASTRING then
        abort;

      if scf_pg_get_property(pg, @propname[1], g_prop) = -1 then
       begin
         writeln('GET PROP ERROR : ',scf_error);
         abort;
       end;
      if (scf_property_is_type(g_prop, ty) <> SCF_SUCCESS) then
        begin
          writeln('type mismatch');
          abort;
        end;
      if (scf_property_get_value(g_prop, g_val) <> SCF_SUCCESS) then
        begin
          writeln('GET PROP VAL ERROR : ',scf_error);
          abort;
        end;
      result := scf_value_get_astring(g_val, vp, sz);
    end;
    {
    	char *buf, root[MAXPATHLEN];
    	size_t buf_sz;
    	int ret = -1, r;
    	boolean_t multi = B_FALSE;

    	assert((flags & ~(EMPTY_OK | MULTI_OK)) == 0);

    	if (scf_pg_get_property(pg, propname, g_prop) == -1) {
    		if (scf_error() != SCF_ERROR_NOT_FOUND)
    			scfdie();

    		goto out;
    	}

    	if (scf_property_is_type(g_prop, ty) != SCF_SUCCESS) {
    		if (scf_error() == SCF_ERROR_TYPE_MISMATCH)
    			goto misconfigured;
    		scfdie();
    	}

    	if (scf_property_get_value(g_prop, g_val) != SCF_SUCCESS) {
    		switch (scf_error()) {
    		case SCF_ERROR_NOT_FOUND:
    			if (flags & EMPTY_OK)
    				goto out;
    			goto misconfigured;

    		case SCF_ERROR_CONSTRAINT_VIOLATED:
    			if (flags & MULTI_OK) {
    				multi = B_TRUE;
    				break;
    			}
    			goto misconfigured;

    		case SCF_ERROR_PERMISSION_DENIED:
    		default:
    			scfdie();
    		}
    	}

    	switch (ty) {
    	case SCF_TYPE_ASTRING:
    		r = scf_value_get_astring(g_val, vp, sz) > 0 ? SCF_SUCCESS : -1;
    		break;

    	case SCF_TYPE_BOOLEAN:
    		r = scf_value_get_boolean(g_val, (uint8_t *)vp);
    		break;

    	case SCF_TYPE_COUNT:
    		r = scf_value_get_count(g_val, (uint64_t *)vp);
    		break;

    	case SCF_TYPE_INTEGER:
    		r = scf_value_get_integer(g_val, (int64_t *)vp);
    		break;

    	case SCF_TYPE_TIME: {
    		int64_t sec;
    		int32_t ns;
    		r = scf_value_get_time(g_val, &sec, &ns);
    		((struct timeval *)vp)->tv_sec = sec;
    		((struct timeval *)vp)->tv_usec = ns / 1000;
    		break;
    	}

    	case SCF_TYPE_USTRING:
    		r = scf_value_get_ustring(g_val, vp, sz) > 0 ? SCF_SUCCESS : -1;
    		break;

    	default:
    #ifndef NDEBUG
    		uu_warn("%s:%d: Unknown type %d.\n", __FILE__, __LINE__, ty);
    #endif
    		abort();
    	}
    	if (r != SCF_SUCCESS)
    		scfdie();

    	ret = multi ? E2BIG : 0;
    	goto out;

    misconfigured:
    	buf_sz = max_scf_fmri_length + 1;
    	buf = safe_malloc(buf_sz);
    	if (scf_property_to_fmri(g_prop, buf, buf_sz) == -1)
    		scfdie();

    	uu_warn(gettext("Property \"%s\" is misconfigured.\n"), buf);

    	free(buf);

    out:
    	if (ret != 0 || g_zonename == NULL ||
    	    (strcmp(propname, SCF_PROPERTY_LOGFILE) != 0 &&
    	    strcmp(propname, SCF_PROPERTY_ALT_LOGFILE) != 0))
    		return (ret);

    	/*
    	 * If we're here, we have a log file and we have specified a zone.
    	 * As a convenience, we're going to prepend the zone path to the
    	 * name of the log file.
    	 */
    	root[0] = '\0';
    	(void) zone_get_rootpath(g_zonename, root, sizeof (root));
    	(void) strlcat(root, vp, sizeof (root));
    	(void) snprintf(vp, sz, "%s", root);

    	return (ret);
    }



    {
     *
     * As pg_get_single_val(), except look the property group up in an
     * instance.  If "use_running" is set, and the running snapshot exists,
     * do a composed lookup there.  Otherwise, do an (optionally composed)
     * lookup on the current values.  Note that lookups using snapshots are
     * always composed.
     *
     }

    function inst_get_single_val(inst : Pscf_instance_t ; const pgname,propname : string;
        ty : scf_type_t ; vp : pointer ;  sz : size_t ; flags : uint_t ;
        use_running, composed : cint) : cint;
    var snap : Pscf_snapshot_t = nil;
        //rpg  : Pscf_propertygroup_t;
        //test : string;
    begin
     // rpg  := scf_pg_create(h);
      Result := scf_instance_get_pg_composed(inst, snap, @pgname[1], g_pg);
      if Result=-1 then
        begin
          writeln('scf composed : ',scf_error);
          abort;
        end;
      if assigned(snap) then
        scf_snapshot_destroy(snap);
      if Result=-1 then
        exit;
      if assigned(g_pg) then
        Result := pg_get_single_val(g_pg, propname, ty, vp, sz, flags);
    end;

    {
    	scf_snapshot_t *snap = NULL;
    	int r;

    	if (use_running)
    		snap = get_running_snapshot(inst);
    	if (composed || use_running)
    		r = scf_instance_get_pg_composed(inst, snap, pgname, g_pg);
    	else
    		r = scf_instance_get_pg(inst, pgname, g_pg);
    	if (snap)
    		scf_snapshot_destroy(snap);
    	if (r == -1)
    		return (-1);

    	r = pg_get_single_val(g_pg, propname, ty, vp, sz, flags);

    	return (r);
    }


    {
     * Get a string property from the restarter property group of the given
     * instance.  Return an empty string on normal problems.
    }
    procedure get_restarter_string_prop(inst : Pscf_instance_t ; const pname : string ; var value : string);
    var len : cint;
    begin
      SetLength(value,1024);
      len := inst_get_single_val(inst, SCF_PG_RESTARTER, pname ,SCF_TYPE_ASTRING, @value[1], length(value), 0, 0, 1);
      if (len <> 0) then
        SetLength(value,len)
      else
        value := '';
    end;

  function list_instance(dummy : pointer ; wip : Pscf_walkinfo_t):cint;cdecl;
  var fmri,state:string;
      scope     :string;
      len       : cint;
  begin
    if assigned(wip^.pg) then
      begin
        state := SCF_STATE_STRING_LEGACY;
      end
    else
      begin
        get_restarter_string_prop(wip^.inst,SCF_PROPERTY_STATE,state);
      end;
    scope := '';
    if assigned(wip^.scope) then
      begin
        setlength(scope,256);
        len := scf_scope_get_name(wip^.scope, @scope[1], Length(scope));
        SetLength(scope,len);
      end;
    fmri := PChar(wip^.fmri);
    writeln( fmri,' STATE = ',state,' ',scope);
    result := 0;
  end;

  procedure error_cb(param1 : PChar ; p2 : array of const);
  begin
    writeln('ERROR CALLBACK?');
  end;


 var fmri : string;
     err : scf_error_t;
     //wit  : scf_walkinfo_t;
begin
  writeln('FOS SVCS Test');
  h      := scf_handle_create(Pscf_version_t(1));
  res    := scf_handle_bind(h);
  g_pg   := scf_pg_create(h);
  g_prop := scf_property_create(h);
  g_val  := scf_value_create(h);

  err := scf_walk_fmri(h, 0, nil, SCF_WALK_MULTIPLE + SCF_WALK_LEGACY, @list_instance , nil, nil,@error_cb);
  //writeln('SCF Handle :',integer(h));
  //fmri := 'svc:/network/iscsi/target:default'+#0;
  //res := smf_enable_instance(@fmri[1],0);
//  writeln('Enable Test ',res);
  //res := scf_simple_walk_instances(SCF_STATE_ALL,pointer(4711),@simple_walk);
end.

