unit fre_db_core_transdata;

{
(§LIC)
  (c) Autor,Copyright Dipl.Ing.- Helmut Hartl
      FirmOS Business Solutions GmbH
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2012, FirmOS Business Solutions GmbH
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

      * Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the documentation
        and/or other materials provided with the distribution.
      * Neither the name of the <FirmOS Business Solutions GmbH> nor the names
        of its contributors may be used to endorse or promote products derived
        from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
(§LIC_END)
}


{$mode objfpc}{$H+}
{$modeswitch nestedprocvars}
{$modeswitch advancedrecords}

interface

uses
     Classes,contnrs, SysUtils,fre_db_interface,fre_db_core,fos_art_tree,fos_tool_interfaces,fos_arraygen,fre_db_common,fre_db_persistance_common,fos_strutils,fre_aps_interface,math,fos_sparelistgen,fre_system;
var
    cFRE_INT_TUNE_TDM_COMPUTE_WORKERS : NativeUInt =  1;
    cFRE_INT_TUNE_SYSFILTEXTENSION_SZ : NativeUint =  128;
    cFRE_INT_TUNE_FILTER_PURGE_TO     : NativeUint =  0; // 5*1000; // 0 DONT PURGE
    cFRE_INT_RANGE_LIST_TUNE          : NativeInt  =  24; { default increment of list extension }

    cFRE_DBG_DISABLE_TRANS_ORDER_STORE : boolean   = false;


{
  TDM - Transformed Data Manager
  Notify Strategy
  1) Apply Changes from Notification Block (Transaction ID), mark QRYs with TID
  2) On Block End Check all Qry's for TID mark -> run compare querys
}

{
  TDM THE DATA Hierarchy
  ----------------------
  Level 0) TCDM                                   The whole Manager
  Level 1) (BTD) TFRE_DB_TRANFORMED_DATA          Transformed Data unorderd, stored in a hash list (uid,object)
  Level 2) (TOD) TFRE_DB_TRANSFORMED_ORDERED_DATA Ordering Upon the Data References to , ART Tree
  Level 3) (FCD) TFRE_DB_FilterContainer          Filtering upon the Ordered Data
  Level 4) (SRM) TFRE_DB_SESSION_DC_RANGE_MGR     Create/Drop Ranges, Manage the minimum set of needed ranges upon the filtered data
}

type

  TFRE_DB_DC_ORDER = record
    order_field      : TFRE_DB_NameType;
    ascending        : boolean;
    case_insensitive : boolean;
  end;

  TFRE_DB_DC_ORDER_LIST            = array of TFRE_DB_DC_ORDER;
  TFRE_DB_SESSION_DC_RANGE_MGR     = class;
  TFRE_DB_FILTER_CONTAINER         = class;
  TFRE_DB_TRANFORMED_DATA          = class;
  TFRE_DB_TRANSFORMED_ORDERED_DATA = class;

  TFRE_DB_DC_ORDER_ITERATOR                 = procedure(const order   : TFRE_DB_DC_ORDER) is nested;
  TFRE_DB_TRANFORMED_DATA_ITERATOR          = procedure(const transd  : TFRE_DB_TRANFORMED_DATA) is nested;
  TFRE_DB_TRANSFORMED_ORDERED_DATA_ITERATOR = procedure(const ordered : TFRE_DB_TRANSFORMED_ORDERED_DATA) is nested;
  TFRE_DB_FILTER_CONTAINER_ITERATOR         = procedure(const filter  : TFRE_DB_FILTER_CONTAINER) is nested;
  TFRE_DB_FILTER_ITERATOR                   = procedure(const filter  : TFRE_DB_FILTER_BASE) is nested;
  TFRE_DB_RANGE_MGR_ITERATOR                = procedure(const range   : TFRE_DB_SESSION_DC_RANGE_MGR) is nested;
  TFRE_DB_TRANSFORM_UTIL_DATA_ITERATOR      = procedure(const tud     : TFRE_DB_TRANSFORM_UTIL_DATA) is nested;


  { TFRE_DB_DC_ORDER_DEFINITION }

  TFRE_DB_DC_ORDER_DEFINITION = class(TFRE_DB_DC_ORDER_DEFINITION_BASE) { defines a globally stored ordered and transformed set of dbo's}
  private
    FOrderList          : array of TFRE_DB_DC_ORDER;
    FKey                : TFRE_DB_TRANS_COLL_DATA_KEY;
    function    IsSealed : Boolean;
  public
    procedure   MustNotBeSealed;
    procedure   MustBeSealed;
    procedure   SetDataKeyColl    (const parent_collectionname,derivedcollname : TFRE_DB_NameType);
    procedure   ClearOrders       ; override;
    procedure   AddOrderDef       (const orderfield_name : TFRE_DB_NameType ; const asc : boolean ; const case_insens : boolean); override;
    procedure   Seal              ;
    procedure   ForAllOrders      (const orderiterator : TFRE_DB_DC_ORDER_ITERATOR);
    procedure   AssignFrom        (const orderdef : TFRE_DB_DC_ORDER_DEFINITION_BASE); override;
    procedure   SetupBinaryKey    (const tud : TFRE_DB_TRANSFORM_UTIL_DATA ; const Key : PByteArray ; var max_key_len : NativeInt ; const tag_object : boolean); { setup a binary key according to this order }
    function    OrderCount        : NativeInt; override;
    function    Orderdatakey      : TFRE_DB_CACHE_DATA_KEY; { get orderdatakey upon basedata }
    function    BasedataKey       : TFRE_DB_CACHE_DATA_KEY; { get needed basedatakey }
    function    CacheDataKey      : TFRE_DB_TRANS_COLL_DATA_KEY;
    function    HasOrders         : boolean;override;
  end;

  { TFRE_DB_FILTER_STRING }

  TFRE_DB_FILTER_STRING=class(TFRE_DB_FILTER_BASE)
  protected
    FValues     : TFRE_DB_StringArray;
    FFilterType : TFRE_DB_STR_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType;override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64):boolean; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_String ; const stringfiltertype : TFRE_DB_STR_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean);
  end;

  { TFRE_DB_FILTER_SIGNED }

  TFRE_DB_FILTER_SIGNED=class(TFRE_DB_FILTER_BASE)
  protected
    FValues       : TFRE_DB_Int64Array;
    FFilterType   : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType;override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of Int64 ; const numfiltertype : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean);
  end;


  { TFRE_DB_FILTER_UNSIGNED }

  TFRE_DB_FILTER_UNSIGNED=class(TFRE_DB_FILTER_BASE)
  protected
    FValues     : TFRE_DB_UInt64Array;
    FFilterType : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType; override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of UInt64 ; const numfiltertype : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean);
  end;

  { TFRE_DB_FILTER_CURRENCY }

  TFRE_DB_FILTER_CURRENCY=class(TFRE_DB_FILTER_BASE)
  protected
    FValues       : TFRE_DB_CurrencyArray;
    FFilterType   : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType;override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of Currency ; const numfiltertype : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean);
  end;

  { TFRE_DB_FILTER_DATETIME }

  TFRE_DB_FILTER_DATETIME=class(TFRE_DB_FILTER_BASE)
  protected
    FValues       : TFRE_DB_DateTimeArray;
    FFilterType   : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType;override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_DateTime64 ; const numfiltertype : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean);
  end;

  { TFRE_DB_FILTER_REAL64 }

  TFRE_DB_FILTER_REAL64=class(TFRE_DB_FILTER_BASE)
  protected
    FValues       : TFRE_DB_Real64Array;
    FFilterType   : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType;override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of Double ; const numfiltertype : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean);
  end;


  { TFRE_DB_FILTER_BOOLEAN }

  TFRE_DB_FILTER_BOOLEAN=class(TFRE_DB_FILTER_BASE)
  protected
    FValue      : Boolean;
    FFilterType : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone           : TFRE_DB_FILTER_BASE;override;
    function  CheckFilterMiss (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    function  GetDefinitionKey: TFRE_DB_NameType; override;
    procedure InitFilter      (const fieldname : TFRE_DB_NameType ; const value: boolean ; const include_null_values : boolean);
  end;

  { TFRE_DB_FILTER_UID }

  TFRE_DB_FILTER_UID=class(TFRE_DB_FILTER_BASE)
  protected
    FValues        : TFRE_DB_GUIDArray;
    FFilterType    : TFRE_DB_NUM_FILTERTYPE;
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    function  GetDefinitionKey : TFRE_DB_NameType; override;
    procedure InitFilter       (const fieldname : TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_GUID ; const numfiltertype : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean ; const include_null_values : boolean; const only_root_nodes: Boolean);
  end;

  { TFRE_DB_FILTER_SCHEME }

  TFRE_DB_FILTER_SCHEME=class(TFRE_DB_FILTER_BASE)
  protected
    FValues     : Array of TFRE_DB_NameType;
  public
    function  Clone            : TFRE_DB_FILTER_BASE ; override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    function  GetDefinitionKey : TFRE_DB_NameType; override;
    procedure InitFilter       (filtervalues : Array of TFRE_DB_String ; const negate:boolean);
  end;

  { TFRE_DB_FILTER_RIGHT }

  TFRE_DB_FILTER_RIGHT=class(TFRE_DB_FILTER_BASE)
  private
    type
      TFRE_DB_FILTER_RIGHT_FILTER_MODE=(fm_ObjectRightFilter,fm_ReferedRightFilter,fm_ObjectRightFilterGeneric,fm_ReferedRightFilterGeneric);
  protected
    FRight            : TFRE_DB_STANDARD_RIGHT_SET;
    FMode             : TFRE_DB_FILTER_RIGHT_FILTER_MODE;
    FUserTokenClone   : IFRE_DB_USER_RIGHT_TOKEN;
    FSchemeclass      : TFRE_DB_Nametype;
    FDomIDField       : TFRE_DB_Nametype;
    FObjUidField      : TFRE_DB_NameType;
    FSchemeClassField : TFRE_DB_NameType;
    FRightSet         : TFRE_DB_StringArray;
    FIgnoreField      : TFRE_DB_NameType;   { specify a fieldname }
    FIgnoreValue      : TFRE_DB_NameType;   { and a value that ignore field contains, the filter should NOT Filter values that are to be ignored (ignorefield.asstring=value)}
  public
    function  Clone                    : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey         : TFRE_DB_NameType; override;
    function  CheckFilterMiss          (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter               (stdrightset  : TFRE_DB_STANDARD_RIGHT_SET ; const usertoken : IFRE_DB_USER_RIGHT_TOKEN ; const negate:boolean ; const ignoreFieldname , ignoreFieldValue : TFRE_DB_String);
    procedure InitFilterRefered        (domainidfield,objuidfield,schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType ; stdrightset  : TFRE_DB_STANDARD_RIGHT_SET ; const usertoken : IFRE_DB_USER_RIGHT_TOKEN ; const negate:boolean; const ignoreFieldname , ignoreFieldValue : TFRE_DB_String);
    procedure InitFilterGenRights      (const stdrightset  : array of TFRE_DB_String ; const usertoken : IFRE_DB_USER_RIGHT_TOKEN ; const negate:boolean; const ignoreFieldname , ignoreFieldValue : TFRE_DB_String);
    procedure InitFilterGenRightsRefrd (const domainidfield,objuidfield,schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType ; stdrightset  : array of TFRE_DB_String ; const usertoken : IFRE_DB_USER_RIGHT_TOKEN ; const negate:boolean; const ignoreFieldname , ignoreFieldValue : TFRE_DB_String);
  end;

  { TFRE_DB_FILTER_PARENT }

  TFRE_DB_FILTER_PARENT=class(TFRE_DB_FILTER_BASE)
  protected
    FAllowedParent : TFRE_DB_String; { Parentpathstring GrandParent/Parent/Childuidstr }
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType; override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override;
    procedure InitFilter       (const allowed_parent_path: TFRE_DB_String);
  end;

  { TFRE_DB_FILTER_CHILD }

  TFRE_DB_FILTER_CHILD=class(TFRE_DB_FILTER_BASE)
  protected
  public
    function  Clone            : TFRE_DB_FILTER_BASE;override;
    function  GetDefinitionKey : TFRE_DB_NameType; override;
    function  CheckFilterMiss  (const ud  : TFRE_DB_TRANSFORM_UTIL_DATA_BASE ; var flt_errors : Int64): boolean; override; { definition OK ? (miss) }
    procedure InitFilter       ;
  end;



  { TFRE_DB_DC_FILTER_DEFINITION }

  TFRE_DB_DC_FILTER_DEFINITION = class(TFRE_DB_DC_FILTER_DEFINITION_BASE)
  private
    FFilterKey                    : TFRE_DB_TRANS_COLL_FILTER_KEY; { summed unique filter key }
    FKeyList                      : TFPHashObjectList;
    FFilterHit                    : boolean;
    FFilterErr                    : int64;
    FFiltDefDBname                : TFRE_DB_NameType;
    FIsa_CP_ChildFilterContainer  : Boolean; { Child Parent (Tree) Dataset -> CHILDDATA  }
    FIsa_CP_ParentFilterContainer : Boolean; { Child Parent (Tree) Dataset -> PARENTDATA }
    FPPA                          : TFRE_DB_String;
    FTransientTraceCB             : TFRE_DB_FILTER_ITERATOR;

    function   IsSealed      : Boolean;
    procedure  _ForAllAdd    (obj:TObject ; arg:Pointer);
    procedure  _ForAllKey    (obj:TObject ; arg:Pointer);
    procedure  _ForAllFilter (obj:TObject ; arg:Pointer);
  public
    constructor Create                          (const filter_dbname : TFRE_DB_NameType);
    destructor  Destroy                         ;override;
    procedure   AddFilters                      (const source : TFRE_DB_DC_FILTER_DEFINITION_BASE; const clone : boolean=true); { add filters,take ownership }
    procedure   AddFilter                       (const source : TFRE_DB_FILTER_BASE; const clone : boolean=false);              { add filter,take ownership }
    procedure   AddStringFieldFilter            (const key,fieldname:TFRE_DB_NameType ; filtervalue  : TFRE_DB_String              ; const stringfiltertype : TFRE_DB_STR_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddSignedFieldFilter            (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of Int64              ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddUnsignedFieldFilter          (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of Uint64             ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddCurrencyFieldFilter          (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of Currency           ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddReal64FieldFilter            (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of Double             ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddDatetimeFieldFilter          (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_DateTime64 ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddBooleanFieldFilter           (const key,fieldname:TFRE_DB_NameType ; filtervalue  : boolean                                                                       ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddUIDFieldFilter               (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_GUID       ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddRootNodeFilter               (const key,fieldname:TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_GUID       ; const numfiltertype    : TFRE_DB_NUM_FILTERTYPE ; const negate:boolean=true  ; const include_null_values : boolean=false);override;
    procedure   AddSchemeObjectFilter           (const key:          TFRE_DB_NameType ; filtervalues : Array of TFRE_DB_String                                                       ; const negate:boolean=true );override;
    procedure   AddStdRightObjectFilter         (const key:          TFRE_DB_NameType ; stdrightset  : TFRE_DB_STANDARD_RIGHT_SET  ; const usertoken : IFRE_DB_USER_RIGHT_TOKEN      ; const negate:boolean=true ; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');override;
    procedure   AddStdClassRightFilter          (const key:          TFRE_DB_NameType ; domainidfield, objuidfield, schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType; stdrightset: TFRE_DB_STANDARD_RIGHT_SET; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean=true; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String=''); override;
    procedure   AddObjectRightFilter            (const key:          TFRE_DB_NameType ; rightset  : Array of TFRE_DB_String  ; const usertoken : IFRE_DB_USER_RIGHT_TOKEN      ; const negate:boolean=true ; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');override;
    procedure   AddClassRightFilter             (const key:          TFRE_DB_NameType ; domainidfield, objuidfield, schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType; rightset: Array of TFRE_DB_String; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean=true; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');override;
    procedure   AddChildFilter                  (const key:          TFRE_DB_NameType); override ;                                                 { Filters Childs out => Only Root nodes PP must be empty, internal (!) do not USE }
    procedure   AddParentFilter                 (const key: TFRE_DB_NameType; const allowed_parent_path: TFRE_DB_String); override; { Child Query Filter, filter all Nodes which have not the corresponding PP, internal (!), do not USE }

    function    RemoveFilter                    (const key:          TFRE_DB_NameType):boolean;override;
    function    FilterExists                    (const key:          TFRE_DB_NameType):boolean;override;
    procedure   RemoveAllFilters                ;override;
    procedure   RemoveAllFiltersPrefix          (const key_prefix:   TFRE_DB_NameType);override;

    procedure   MustNotBeSealed                 ;
    procedure   MustBeSealed                    ;
    procedure   Seal                            ;
    function    GetFilterKey                    : TFRE_DB_TRANS_COLL_FILTER_KEY;
    function    DoesObjectPassFilters           (const tud : TFRE_DB_TRANSFORM_UTIL_DATA; const tracecb : TFRE_DB_FILTER_ITERATOR) : boolean;
    function    FilterDBName                    : TFRE_DB_NameType;
    property    IsAChildDataFilterDefinition    : Boolean read FIsa_CP_ChildFilterContainer;
    property    IsARootDataFilterDefinition     : Boolean read FIsa_CP_ParentFilterContainer;
    property    ParentPath                      : TFRE_DB_String read FPPA;
  end;

  TFRE_DB_QUERY            = class;


  { TFRE_DB_SESSION_DC_RANGE }

  TFRE_DB_SESSION_DC_RANGE=class
    FStartIndex             : NativeInt;                                    { of range, not of qry(!) }
    FEndIndex               : NativeInt;
    FResultDBOs             : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;              { remember all objs of this range, need to update that list by notify updates,
                                                                                  need to hold that list to check against changes in filterchanges             }
    FResultDBOsCompare      : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;              { due to a filter update rerun the query - store in compare array, compare, send updates, switch the arrays }
    FMgr                    : TFRE_DB_SESSION_DC_RANGE_MGR;

    function     RangeFilled                          : boolean;
    procedure    FillRange                            (const compare_fill : boolean=false);
    function     GetAbsoluteIndexedObj                (const abs_idx : NativeInt):IFRE_DB_Object;
    function     AbsIdxFrom                           (const range_idx : NativeInt):NativeInt;
    function     CheckUidIsInRange                    (const search_uid : TFRE_DB_GUID):boolean;
    procedure    ClearRange                           ;

    function     GetCorrespondingParentPath           : TFRE_DB_String;
    function     IsAChildResultset                    : Boolean;
    function     IsARootResultset                     : Boolean;
  public
    constructor  Create                               (const mgr : TFRE_DB_SESSION_DC_RANGE_MGR ; const start_idx,end_idx : NativeInt);
    destructor   Destroy                              ; override;
    procedure    ExtendRangeToEnd                     (const end_idx   : NativeInt ; const dont_fill : boolean);
    procedure    ExtendRangeToStart                   (const start_idx : NativeInt ; const dont_fill : boolean);
    procedure    CropRangeFromStartTo                 (const crop_idx  : NativeInt ; const dont_crop : boolean);
    procedure    CropRangeFromEndTo                   (const crop_idx  : NativeInt ; const dont_crop : boolean);
    procedure    RangeExecuteQry                      (const qry_start_ix,chunk_start, chunk_end : NativeInt ; var dbos : IFRE_DB_ObjectArray);
    procedure    RangeProcessFilterChangeBasedUpdates (const sessionid: TFRE_DB_SESSION_ID; const storeid: TFRE_DB_NameType; const orderkey: TFRE_DB_NameType ; const AbsCount : NativeInt ; var calcedabs : NativeInt);
    property     StartIndex                           : NativeInt read FStartIndex;
    property     EndIndex                             : NativeInt read FEndIndex;
  end;

  { TFRE_DB_SESSION_DC_RANGE_MGR }
  TFRE_DB_SESSION_DC_RANGE_QRY_STATUS = (rq_Bad,rq_OK,rq_NO_DATA);

  TFRE_DB_SESSION_DC_RANGE_MGR=class { a session and a distinct dc hase one rangemanager, which stores all range requests, there should be the minimum amount of ranges to satisfy queries }
  private
    FRMGTransTag            : TFRE_DB_TransStepId;
    FLastQryMaximalIndex    : NativeInt; { get's set on FindRangeSatisfyingQuery, used to drop ranges on CompareRangesRun }
  type TWorkRangeR= record
           Rid : NativeInt;
           Six : NativeInt;
           Eix : NativeInt;
           rr  : TFRE_DB_SESSION_DC_RANGE;
         end;
       TWorkRangeIter  = procedure(const r: TFRE_DB_SESSION_DC_RANGE) is nested;
       TRangeIterBrk   = procedure(const r:TFRE_DB_SESSION_DC_RANGE ; var halt:boolean) is nested;
  var
    FRMK             : TFRE_DB_SESSION_DC_RANGE_MGR_KEY;
    FRanges          : TFRE_ART_TREE;
    FRMFiltercont    : TFRE_DB_FILTER_CONTAINER;
    FRMOrdering      : TFRE_DB_TRANSFORMED_ORDERED_DATA;

    procedure   InternalRangeCheck                  (testranges : Array of NativeInt ; const range_iter : TWorkRangeIter);
    procedure   Bailout                             (msg:string ; params : Array of Const);
    procedure   DumpRanges                          ;
    function    DumpRangesCompressd                 : String;
    function    GetMaxIndex                         : NativeInt;
    function    ForAllRanges                        (const riter : TRangeIterBrk):boolean;
    procedure   TagRangeMgrIfObjectIsInResultRanges (const search_uid: TFRE_DB_GUID; const transid: TFRE_DB_TransStepId);

  protected
    function     GetCorrespondingParentPath      : TFRE_DB_String;
    function     IsAChildResultset               : Boolean;
    function     IsARootResultset                : Boolean;
    procedure    ClearRanges                     ;
  public
    constructor Create                           (const key : TFRE_DB_SESSION_DC_RANGE_MGR_KEY);
    destructor  Destroy                          ; override;
    function    FindRange4QueryAndUpdateQuerySpec(const sessionid: TFRE_DB_SESSION_ID; out range: TFRE_DB_SESSION_DC_RANGE; var startidx, endidx, potentialcnt: NativeInt): boolean;
    function    FindRangeSatisfyingQuery         (start_idx,end_idx : NativeInt ; out range:TFRE_DB_SESSION_DC_RANGE ; const dont_fill : boolean):TFRE_DB_SESSION_DC_RANGE_QRY_STATUS; { Find or define a new range upon data, process range minimization }
    function    DropRange                        (start_idx,end_idx : NativeInt ; const dont_crop : boolean ; const riter : TWorkRangeIter=nil):TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;
    procedure   TagForUpInsDelRLC                (const TransID: TFRE_DB_TransStepId); { maybe need to count i,u,d to handle range extension better}
    procedure   HandleTagged                     ;
    procedure   ProcessChildObjCountChange       (const obj: IFRE_DB_Object);
    procedure   ProcessFilterChangeBasedUpdates  ;
    function    GetLastRange                     : TFRE_DB_SESSION_DC_RANGE;
    function    GetStoreID                       : TFRE_DB_NameType;
    function    GetSessionID                     : TFRE_DB_SESSION_ID;

    procedure   CheckQuerySpecAndClearIfNeeded   (const qryid : TFRE_DB_SESSION_DC_RANGE_MGR_KEY);
    procedure   AssignOrdering                   (const od : TFRE_DB_TRANSFORMED_ORDERED_DATA);
    procedure   AssignFiltering                  (const fc : TFRE_DB_FILTER_CONTAINER);
    function    RangemanagerKeyString            : TFRE_DB_CACHE_DATA_KEY;
    property    RangeManagerOrdering             : TFRE_DB_TRANSFORMED_ORDERED_DATA read FRMOrdering;
    property    RangeManagerFiltering            : TFRE_DB_FILTER_CONTAINER read FRMFiltercont;
  end;

  { TFRE_DB_QUERY }

  TFRE_DB_QUERY=class(TFRE_DB_QUERY_BASE,IFRE_APSC_WORKABLE) { Query a Range }
  private
    type
      TFRE_DB_COMPUTE_QUERYSTATE = (cs_Initiated,cs_FetchData,cs_NeedTransform,cs_NeedOrder,cs_NeedFilterFilling,cs_RangeProcessing,cs_DeliverRange,cs_NoDataAvailable);
    function  GetFilterDefinition: TFRE_DB_DC_FILTER_DEFINITION;
    function  GetOrderDefinition: TFRE_DB_DC_ORDER_DEFINITION;
  protected
    { References }
    FRm                       : TFRE_DB_SESSION_DC_RANGE_MGR;     { the assigned range manager for the query  }
    FTransdata                : TFRE_DB_TRANFORMED_DATA;          { the transformed data matching that query  }
    FOrdered                  : TFRE_DB_TRANSFORMED_ORDERED_DATA; { assigned transformed and ordered data     }
    FFiltered                 : TFRE_DB_FILTER_CONTAINER;         { the filtercontainer of the ordering       }
    FSessionRange             : TFRE_DB_SESSION_DC_RANGE;         { the range of this query                   }
    FTransformobject          : IFRE_DB_SIMPLE_TRANSFORM;         { the transformation object of the query dc }

    { Managed }
    FClonedRangeDBOS          : IFRE_DB_ObjectArray;
    FQryDBName                : TFRE_DB_NameType;                 { used for reeval filters, etc          }
    FQueryId                  : TFRE_DB_SESSION_DC_RANGE_MGR_KEY; { ID of this specific Query             }
    FQueryDescr               : string;
    FParentChildLinkFldSpec   : TFRE_DB_NameTypeRL;               { rl spec of the parent child relation                }
    FParentChildScheme        : TFRE_DB_NameType;                 { the same as single fields                           }
    FParentChildField         : TFRE_DB_NameType;                 {                                                     }
    FParentLinksChild         : Boolean ;                         {                                                     }
    FParentChildSkipschemes   : TFRE_DB_NameTypeArray;            { skip this schemes in a parent child query           }
    FParentChildFilterClasses : TFRE_DB_NameTypeArray;            { completly ignore these classes in reflinking        }
    FParentChildStopOnLeaves  : TFRE_DB_NameTypeArray;            { stop on this leave classes and dont recurse further }

    FQueryFilters             : TFRE_DB_DC_FILTER_DEFINITION;     { managed here, cleanup here}
    FOrderDef                 : TFRE_DB_DC_ORDER_DEFINITION;      { linked to order definition of base ordered data, dont cleanup here}
    FDependencyIds            : TFRE_DB_StringArray;              { dependency id's of this querys DC, in same order as }
    FDepRefConstraints        : TFRE_DB_NameTypeRLArrayArray;     { this reference link constraints, there must be an extra }
    FDependcyFilterUids       : Array of TFRE_DB_GUIDArray;       { this is a special filter type, the GUID array may, at some later time, be extended to support other field types }
    FIsChildQuery             : Boolean;                          { this is a request for childs }
    FUserKey                  : TFRE_DB_String;                   { Login@Domain | GUID ?}

    FStartIdx                 : NativeInt;                        { }
    FEndIndex                 : NativeInt;                        { }
    FPotentialCount           : NativeInt;                        { }

    FQueryStartTime           : NativeInt;
    FQueryEndTime             : NativeInt;

    FReqID                    : Qword;                            { request that generated that query }
    FOnlyOneUID               : TFRE_DB_GUID;
    FUidPointQry              : Boolean;
    FAsyncResultCtx           : IFRE_APSC_CHANNEL_GROUP;
    FCompute                  : IFRE_APSC_CHANNEL_GROUP;
    FMyComputeState           : TFRE_DB_COMPUTE_QUERYSTATE;
    FMyWorkerCount            : NativeInt;

    Fbasekey                  : TFRE_DB_CACHE_DATA_KEY; { during work }
    FQSt,FQEt                 : NativeInt;
    Fst,Fet                   : NativeInt;
    Frcnt                     : NativeInt;
    FSyncEvent                : IFOS_E;
    FError                    : boolean;
    FErrorString              : TFRE_DB_String;

     function                GetReflinkSpec        (const upper_refid : TFRE_DB_NameType):TFRE_DB_NameTypeRLArray;
     function                GetReflinkStartValues (const upper_refid : TFRE_DB_NameType):TFRE_DB_GUIDArray; { start values for the RL expansion }
     procedure               SwapCompareQueryQry   ;
  public
     procedure   CaptureStartTime                  ; override;
     function    CaptureEndTime                    : NativeInt;  override;

     constructor Create                            (const qry_dbname : TFRE_DB_NameType);
     destructor  Destroy                           ; override;
     function    GetQueryID                        : TFRE_DB_SESSION_DC_RANGE_MGR_KEY; override;
     function    HasOrderDefinition                : boolean;
     property    Orderdef                          : TFRE_DB_DC_ORDER_DEFINITION  read GetOrderDefinition;
     property    Filterdef                         : TFRE_DB_DC_FILTER_DEFINITION read GetFilterDefinition;
     property    QryDBName                         : TFRE_DB_NameType read FQryDBName;

     function    GetReqID                          : Qword; override;
     function    GetTransfrom                      : IFRE_DB_SIMPLE_TRANSFORM; override;
     function    GetResultData                     : IFRE_DB_ObjectArray; override;
     function    GetTotalCount                     : NativeInt; override;


     procedure   SetupWorkingContextAndStart       (const Compute: IFRE_APSC_CHANNEL_GROUP; const transform: IFRE_DB_SIMPLE_TRANSFORM; const return_cg: IFRE_APSC_CHANNEL_GROUP; const ReqID: Qword ; const sync_event : IFOS_E);
     procedure   SetupWorkerCount_WIF              (const wc : NativeInt);
     function    GetAsyncDoneContext_WIF           : IFRE_APSC_CHANNEL_MANAGER;
     function    GetAsyncDoneChannelGroup_WIF      : IFRE_APSC_CHANNEL_GROUP;
     function    StartGetMaximumChunk_WIF          : NativeInt;
     procedure   ParallelWorkIt_WIF                (const startchunk,endchunk : Nativeint ; const wid : NativeInt);
     procedure   WorkNextCyle_WIF                  (var continue : boolean); { set to true to get a recall                                      }
     procedure   WorkDone_WIF                      ;
     procedure   ErrorOccurred_WIF                 (const ec : NativeInt ; const em : string);
  end;

  { TFRE_DB_TRANSDATA_CHANGE_NOTIFIER }

  TFRE_DB_TRANSDATA_CHANGE_NOTIFIER=class(IFRE_DB_TRANSDATA_CHANGE_NOTIFIER)
  private
     FSessionUpdateList : TFPHashObjectList;  { gets freed in the session or on failed ctx switch to session }
     FKey               : TFRE_DB_TransStepId;
     function    GetSessionUPO                (const sessionid: TFRE_DB_NameType): TFRE_DB_SESSION_UPO;
  public
     property    TransKey                     : TFRE_DB_TransStepId read FKey;
     constructor Create                       (const key: TFRE_DB_TransStepId);
     procedure   AddDirectSessionUpdateEntry  (const update_dbo : IFRE_DB_Object); { add a dbo update for sessions dbo's (forms) }
     procedure   AddGridInplaceUpdate         (const sessionid: TFRE_DB_NameType; const store_id,store_id_dc: TFRE_DB_String; const upo   : IFRE_DB_Object ; const oldpos,newpos,abscount : NativeInt); { inplace update entry for the store }
     procedure   AddGridInsertUpdate          (const sessionid: TFRE_DB_NameType; const store_id,store_id_dc: TFRE_DB_String; const upo   : IFRE_DB_Object ; const position,abscount : NativeInt);
     procedure   AddGridRemoveUpdate          (const sessionid: TFRE_DB_NameType; const store_id,store_id_dc: TFRE_DB_String; const del_id: TFRE_DB_String ; const position,abscount : NativeInt);
     procedure   NotifyAll;
  end;

  { TFRE_DB_TRANFORMED_DATA }
  TFRE_DB_SKIP_ENC=class
    parent_uid   : TFRE_DB_GUID;
    skipped_uid  : TFRE_DB_GUIDArray;
    skippd_class : ShortString;
  end;

  { TFRE_DB_TRANSFORM_BACKLINK }

  TFRE_DB_TRANSFORM_BACKLINK=class
  private
    FBLList : TFPObjectList;
    ToUid   : TFRE_DB_GUID;
  public
    procedure   AddBackLink         (const util : TFRE_DB_TRANSFORM_UTIL_DATA);
    procedure   RemoveBacklink      (const util : TFRE_DB_TRANSFORM_UTIL_DATA);
    function    BacklinkCount       : NativeInt;
    function    GetDependendObjects : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
    constructor Create              ;
    destructor  Destroy             ; override;
  end;

  TFRE_DB_TRANFORMED_DATA=class
  private
    type
      TDC_TransMode = (trans_Insert,trans_Update,trans_SingleInsert);
    var
      FTDDBName             : TFRE_DB_NameType;
      FKey                  : TFRE_DB_TRANS_COLL_DATA_KEY;   { CN/DCN/CHILD RL SPEC }
      FTransformedData      : TFPHashObjectList;
      FTransformBacklinks   : TFPHashObjectList;
      FSkipSkipped          : TFPHashObjectList;
      FSkipParent           : TFPHashObjectList;
      FTransdatalock        : IFOS_LOCK;
      FOrderings            : TFPObjectList;
      FTDCreationTime       : TFRE_DB_DateTime64;
      FChildDataIsLazy      : Boolean; { the child data is lazy : UNSUPPORTED }
      FRecordCount          : Nativeint;
      FParallelCount        : Nativeint;

      FObjectFetchArray     : IFRE_DB_ObjectArray;
      { >--- Check valid settings }
      FParentCollectionName               : TFRE_DB_NameType;
      FDCHasParentChildRefRelationDefined : boolean;
      FIsChildQuery                       : boolean;
      FParentLinksChild                   : boolean;
      FParentChildLinkFldSpec             : TFRE_DB_NameTypeRL;
      FParentChildScheme                  : TFRE_DB_NameType;
      FParentChildField                   : TFRE_DB_NameType;
      FParentChildSkipSchemes,
      FParentChildFilterClasses,
      FParentChildStopOnLeaves            : TFRE_DB_NameTypeArray;
      FTransform                          : TFRE_DB_TRANSFORMOBJECT;
      { <--- Check valid settings }
      FConnection                         : TFRE_DB_CONNECTION;
      FSystemConnection                   : TFRE_DB_SYSTEM_CONNECTION;
      FParentCollection                   : TFRE_DB_COLLECTION;
      FIsInSysstemDB                      : boolean;


    //FDC                   : IFRE_DB_DERIVED_COLLECTION;
    function    IncludesChildData             : Boolean; { the query is a tree query, thus the transformations may include childs                         }
    function    HasReflinksInTransform        : Boolean; { the query has reflinks in the transform, so on RL change the Transform has to be revaluated ...}
    function    IsReflinkSpecRelevant         (const rlspec : TFRE_DB_NameTypeRL):boolean;

    procedure   _AssertCheckTransid           (const obj : IFRE_DB_Object ; const transkey : TFRE_DB_TransStepId);

    procedure   TransformSingleUpdate         (const util : TFRE_DB_TRANSFORM_UTIL_DATA ; const in_object: IFRE_DB_Object ; const upd_idx: NativeInt; const parentpath_full: TFRE_DB_StringArray; const transkey: TFRE_DB_TransStepId);
    procedure   TransformSingleInsert         (const util: TFRE_DB_TRANSFORM_UTIL_DATA; const in_object: IFRE_DB_Object; const rl_ins: boolean ; const parent_tr_obj: TFRE_DB_TRANSFORM_UTIL_DATA; const transkey: TFRE_DB_TransStepId);
    procedure   TransformFetchAll             ;
    procedure   TransformAllParallel          (const startchunk, endchunk: Nativeint; const wid: nativeint);
    procedure   MyTransForm                   (const start_idx, endindx: NativeInt; const lazy_child_expand: boolean; const mode: TDC_TransMode; const update_idx: NativeInt; const rl_ins: boolean; const parentpaths: TFRE_DB_StringArray;
                                               const in_parent_tr_obj: TFRE_DB_TRANSFORM_UTIL_DATA; const transkey: TFRE_DB_TransStepId; const wid: nativeint; const single_in_object: IFRE_DB_Object; util: TFRE_DB_TRANSFORM_UTIL_DATA);

  public
    function    TransformedCount              : NativeInt;
    procedure   Cleanup                       ;

    function    FindParentIndex               (paruid : TFRE_DB_GUID ; out rootinsert : boolean) : Nativeint;

    procedure   UpdateObjectByNotify          (const obj : IFRE_DB_Object ; const transkey : TFRE_DB_TransStepId);                                                                                             { notify step 1 }
    procedure   InsertObjectByNotify          (const coll_name : TFRE_DB_NameType ; const obj : IFRE_DB_Object ; const rl_ins : boolean ; const parent : TFRE_DB_GUID ; const transkey : TFRE_DB_TransStepId); { notify step 1 }
    procedure   RemoveObjectByNotify          (const coll_name : TFRE_DB_NameType ; const obj : IFRE_DB_Object ; const rl_rem : boolean ; const parent : TFRE_DB_GUID ; const transkey : TFRE_DB_TransStepId); { notify step 1 }

    { The reflink operations are ordered to occur before the update,insert,delete operations (remove should not do a reflink change(!) }
    procedure   SetupOutboundRefLink          (const from_obj : IFRE_DB_Object ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const transkey : TFRE_DB_TransStepId);          { notify step 1 }
    procedure   SetupInboundRefLink           (const from_obj : IFRE_DB_Object ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const transkey : TFRE_DB_TransStepId);          { notify step 1 }
    procedure   InboundReflinkDropped         (const from_obj : IFRE_DB_Object ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const transkey : TFRE_DB_TransStepId);          { notify step 1 }
    procedure   OutboundReflinkDropped        (const from_obj : IFRE_DB_Object ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const transkey : TFRE_DB_TransStepId);          { notify step 1 }


    function    ExistsObjDirect               (const uid:TFRE_DB_GUID):NativeInt;
    procedure   SetTransformedObject          (const utildata : TFRE_DB_TRANSFORM_UTIL_DATA); { inital fill, from initial transform }
    procedure   SetTransObjectSingleInsert    (const utildata : TFRE_DB_TRANSFORM_UTIL_DATA); { single fill from notify }

    procedure   SetSkippedParentChildScheme   (const parent_uid,child_uid : TFRE_DB_GUID ; const child_class : ShortString);


    procedure   HandleUpdateTransformedObject (const utildata: TFRE_DB_TRANSFORM_UTIL_DATA; const upd_idx: NativeInt);                                               { notify update, step 2 }
    procedure   HandleInsertTransformedObject (const utildata: TFRE_DB_TRANSFORM_UTIL_DATA; const parent_tud: TFRE_DB_TRANSFORM_UTIL_DATA); { notify update, step 2 }
    procedure   HandleDeleteTransformedObject (const del_idx: NativeInt     ; const parent_tud : TFRE_DB_TRANSFORM_UTIL_DATA ; transtag : TFRE_DB_TransStepId);               { notify update, step 2 }
    procedure   InsertReferenceBackLinks      (const utildata: TFRE_DB_TRANSFORM_UTIL_DATA);
    procedure   RemoveReferenceBacklinks      (const utildata: TFRE_DB_TRANSFORM_UTIL_DATA);
    function    CheckReferenceBackLink        (const searchuid: TFRE_DB_GUID; out dependend_transformed: TFRE_DB_TRANSFORM_UTIL_DATA_ARR): boolean;

    constructor Create                        (const qry: TFRE_DB_QUERY ; const transform : IFRE_DB_TRANSFORMOBJECT ; const data_parallelism : nativeint);
    destructor  Destroy                       ; override;
    procedure   ForAllObjs                    (const forall : TFRE_DB_Obj_Iterator);
    procedure   ForAllTransformed             (const forall : TFRE_DB_TRANSFORM_UTIL_DATA_ITERATOR);

    procedure   AddOrdering                   (const ordering : TFRE_DB_TRANSFORMED_ORDERED_DATA);
    procedure   RemoveOrdering                (const ordering : TFRE_DB_TRANSFORMED_ORDERED_DATA);
    function    GetTransFormKey               : TFRE_DB_TRANS_COLL_DATA_KEY;
    procedure   CheckIntegrity                ;
  end;

  { TFRE_DB_ORDER_CONTAINER }
  OFRE_SL_TFRE_DB_TRANSFORM_UTIL_DATA = specialize OFOS_SpareList<TFRE_DB_TRANSFORM_UTIL_DATA>;


  TFRE_DB_ORDER_CONTAINER=class
  private
    FOBJArray : OFRE_SL_TFRE_DB_TRANSFORM_UTIL_DATA;
  public
    function    AddObject     (const tud : TFRE_DB_TRANSFORM_UTIL_DATA):boolean;
    function    Exists        (const tud : TFRE_DB_TRANSFORM_UTIL_DATA):boolean;
    procedure   ReplaceObject (const old_tud,new_tud : TFRE_DB_TRANSFORM_UTIL_DATA);
    function    RemoveObject  (const old_tud : TFRE_DB_TRANSFORM_UTIL_DATA):boolean; { true if this was the last value in the container }
    procedure   ForAllInOC    (const iter : TFRE_DB_TRANSFORM_UTIL_DATA_ITERATOR);
    constructor Create        ;
  end;

  { TFRE_DB_FILTER_CONTAINER }

  TFRE_DB_FILTER_CONTAINER=class
  private

  var
    FOBJArray        : Array of TFRE_DB_TRANSFORM_UTIL_DATA;
    FCnt             : NativeUint;
    FFilled          : Boolean;
    FFCCreationTime  : TFRE_DB_DateTime64;
    FFilters         : TFRE_DB_DC_FILTER_DEFINITION;
    FFullKey         : TFRE_DB_TRANS_COLL_DATA_KEY;
    FArtRangeMgrs    : TFRE_ART_TREE;   { all sessions upon that filter }
    FOrdered         : TFRE_DB_TRANSFORMED_ORDERED_DATA;

    procedure        SetFilled(AValue: boolean);
    procedure        ClearDataInFilter;
    function         UnconditionalRemoveOldObject (const td: TFRE_DB_TRANSFORMED_ORDERED_DATA ; const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA ; const ignore_non_existing: boolean ; const transtag: TFRE_DB_TransStepId):NativeInt;
    function         UnconditionalInsertNewObject (const td: TFRE_DB_TRANSFORMED_ORDERED_DATA ; const new_tud: TFRE_DB_TRANSFORM_UTIL_DATA):NativeInt;
    function         OrderKey                 : TFRE_DB_NameType;
  public
    procedure        FillFilter                    (const startchunk, endchunk: Nativeint; const wid: NativeInt);

    procedure   TagQueries4UpInsDel                 (const TransActionTag: TFRE_DB_TransStepId);

    procedure   AddSessionRangemanager              (const rm: TFRE_DB_SESSION_DC_RANGE_MGR);
    procedure   RemoveSessionRangemanager           (const rm: TFRE_DB_SESSION_DC_RANGE_MGR);
    procedure   ForAllSessionRangemgrs              (const rm_iter : TFRE_DB_RANGE_MGR_ITERATOR);
    procedure   ClearAllRangesOfFilter              ;

    function    GetDataCount                  : NativeInt;
    //function    CalcRangeMgrKey               (const sessionid : TFRE_DB_SESSION_ID):TFRE_DB_SESSION_DC_RANGE_MGR_KEY;
    property    IsFilled                      : boolean read FFilled write SetFilled;
    procedure   CheckFilteredAdd              (const tud : TFRE_DB_TRANSFORM_UTIL_DATA);
    procedure   Notify_CheckFilteredUpdate    (const td  : TFRE_DB_TRANSFORMED_ORDERED_DATA ; const old_tud,new_tud : TFRE_DB_TRANSFORM_UTIL_DATA ; const order_changed : boolean ; const transtag: TFRE_DB_TransStepId);
    function    Notify_CheckFilteredDelete    (const td  : TFRE_DB_TRANSFORMED_ORDERED_DATA ; const old_tud         : TFRE_DB_TRANSFORM_UTIL_DATA ; const transtag: TFRE_DB_TransStepId ; const is_update_order_change :boolean) : NativeInt;
    function    Notify_CheckFilteredInsert    (const td  : TFRE_DB_TRANSFORMED_ORDERED_DATA ; const new_tud         : TFRE_DB_TRANSFORM_UTIL_DATA ; const transtag: TFRE_DB_TransStepId ; const is_update_order_change :boolean) : NativeInt;
    procedure   Notify_CheckChildCountChange  (const transid : TFRE_DB_TransStepId ; const parent : TFRE_DB_TRANSFORM_UTIL_DATA);
    function    DoesObjectPassFilterContainer (const tud : TFRE_DB_TRANSFORM_UTIL_DATA ; const tracecb : TFRE_DB_FILTER_ITERATOR=nil):boolean;
    procedure   AdjustLength                  ;
    constructor Create                        (const full_key : TFRE_DB_TRANS_COLL_DATA_KEY ; const qry_filters : TFRE_DB_DC_FILTER_DEFINITION ; const ordered : TFRE_DB_TRANSFORMED_ORDERED_DATA);
    destructor  Destroy                       ; override;
    function    GetCacheDataKey               : TFRE_DB_TRANS_COLL_DATA_KEY;
    function    FilterDataKey                 : TFRE_DB_CACHE_DATA_KEY;
    procedure   Checkintegrity                ;
    function    FetchDirectInFilter           (const uid:TFRE_DB_GUID ; out dbo : IFRE_DB_Object):boolean;
    property    IsAChildDataFilterDefinition  : Boolean read FFilters.FIsa_CP_ChildFilterContainer;
    property    IsARootDataFilterDefinition   : Boolean read FFilters.FIsa_CP_ParentFilterContainer;
    property    ParentPath                    : TFRE_DB_String read FFilters.FPPA;
    function    GetTransFormUtilData          (const idx : NativeInt) : TFRE_DB_TRANSFORM_UTIL_DATA;
  end;


  { TFRE_DB_TRANSFORMED_ORDERED_DATA }

  TFRE_DB_TRANSFORMED_ORDERED_DATA=class
  protected
    FOrderDef          : TFRE_DB_DC_ORDER_DEFINITION;
    FBaseTransData     : TFRE_DB_TRANFORMED_DATA;
    FArtTreeKeyToObj   : TFRE_ART_TREE; { store the Pointer to the Transformed Data Entry}
    FArtTreeFilterKey  : TFRE_ART_TREE; { store a filtering based on the order }
    FTOCreationTime    : TFRE_DB_DateTime64;

    procedure          InsertIntoTree                (const tud : TFRE_DB_TRANSFORM_UTIL_DATA);

    procedure          ForAllFilters                 (const filter_iter : TFRE_DB_FILTER_CONTAINER_ITERATOR);

    procedure          Notify_ChildCountChange       (const transtag: TFRE_DB_TransStepId ; const parent_obj : TFRE_DB_TRANSFORM_UTIL_DATA);

    procedure          Notify_UpdateIntoTree         (const old_tud,new_tud : TFRE_DB_TRANSFORM_UTIL_DATA ; const transtag: TFRE_DB_TransStepId);
    procedure          Notify_InsertIntoTree         (const new_tud : TFRE_DB_TRANSFORM_UTIL_DATA ; const transtag: TFRE_DB_TransStepId);
    procedure          Notify_InsertIntoTree         (const key: PByte; const keylen: NativeInt; const new_tud: TFRE_DB_TRANSFORM_UTIL_DATA ; const transtag: TFRE_DB_TransStepId ; const propagate_up : boolean = true);
    procedure          Notify_DeleteFromTree         (const old_tud : TFRE_DB_TRANSFORM_UTIL_DATA ; transtag : TFRE_DB_TransStepId);
    procedure          Notify_DeleteFromTree         (const key: PByte; const keylen: NativeInt; const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA ; const transtag: TFRE_DB_TransStepId ; const propagate_up : boolean = true);

    function           GetFilterContainer         (const key   : TFRE_DB_TRANS_COLL_FILTER_KEY ; out filtercontainer: TFRE_DB_FILTER_CONTAINER):boolean;
    function           GetOrCreateFiltercontainer (const filter: TFRE_DB_DC_FILTER_DEFINITION; out filtercontainer: TFRE_DB_FILTER_CONTAINER):boolean;
    procedure          FillFilterContainer        (const filtercontainer: TFRE_DB_FILTER_CONTAINER ; const startchunk, endchunk: Nativeint; const wid: NativeInt);
  public
    constructor  Create                  (const orderdef : TFRE_DB_DC_ORDER_DEFINITION ; base_trans_data : TFRE_DB_TRANFORMED_DATA);
    destructor   Destroy                 ; override;
    procedure    OrderTheData            (const startchunk, endchunk: Nativeint; const wid: NativeInt);
    function     GetOrderedDatakey       : TFRE_DB_CACHE_DATA_KEY;
    function     GetCacheDataKey         : TFRE_DB_TRANS_COLL_DATA_KEY;
    function     GetFiltersCount         : NativeInt;
    function     GetFilledFiltersCount   : NativeInt;
    procedure    DebugCheckintegrity     ;
  end;

  { TFRE_DB_TRANSDATA_MANAGER }

  TFRE_DB_TRANSDATA_MANAGER=class(TFRE_DB_TRANSDATA_MANAGER_BASE,IFRE_DB_DBChangedNotification)
  private
  type
    TFRE_TDM_DROPQ_PARAMS=class
      qry_id         : TFRE_DB_CACHE_DATA_KEY;
      whole_session  : boolean;
      start_idx      : NativeInt;
      end_idx        : NativeInt;
    end;

  var
    FParallelCnt   : NativeInt;
    FTransCompute  : IFRE_APSC_CHANNEL_GROUP;
    FTransList     : TFPHashList;                          { List of base transformed data}
    FOrders        : TFPHashList;                          { List of orderings of base transforms}
    FCurrentNotify : TFRE_DB_TRANSDATA_CHANGE_NOTIFIER;    { gather list of notifications for a notification block (transaction) }
    FCurrentNLayer : TFRE_DB_NameType;
    FStatTimer     : IFRE_APSC_TIMER;
    FArtRangeMgrs  : TFRE_ART_TREE;                        { one(!) RM per session/dc combination }


    procedure   AddBaseTransformedData       (const base_data : TFRE_DB_TRANFORMED_DATA);
    procedure   _ForAllOrders                (obj:Pointer ; arg:Pointer);
    procedure   _ForAllTransforms            (obj:Pointer ; arg:Pointer);

    procedure   ForAllOrders                 (const order_iter  : TFRE_DB_TRANSFORMED_ORDERED_DATA_ITERATOR);
    procedure   ForAllTransformed            (const trans_iter  : TFRE_DB_TRANFORMED_DATA_ITERATOR);
    procedure   ForAllQueryRangeMgrs         (const rm_iter     : TFRE_DB_RANGE_MGR_ITERATOR);
    procedure   ForAllQueryRangeMgrsSession  (const rm_iter     : TFRE_DB_RANGE_MGR_ITERATOR;const sessionprefix : TFRE_DB_SESSION_ID);
    procedure   ForAllFilterContainers       (const filter_iter : TFRE_DB_FILTER_CONTAINER_ITERATOR);

    procedure   TL_StatsTimer;
    procedure   AssertCheckTransactionID                    (const obj : IFRE_DB_Object ; const transid : TFRE_DB_TransStepId);

    //procedure   CheckChildCountChangesAndTag                (const parent_obj : IFRE_DB_Object);
    {NOFIF BLOCK INTERFACE}
    procedure  StartNotificationBlock (const key : TFRE_DB_TransStepId);
    procedure  FinishNotificationBlock(out block : IFRE_DB_Object);
    procedure  SendNotificationBlock  (const block : IFRE_DB_Object);
    procedure  CollectionCreated      (const coll_name: TFRE_DB_NameType  ; const in_memory_only : boolean ; const tsid : TFRE_DB_TransStepId);
    procedure  CollectionDeleted      (const coll_name: TFRE_DB_NameType  ; const tsid : TFRE_DB_TransStepId) ;
    procedure  IndexDefinedOnField    (const coll_name: TFRE_DB_NameType  ; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean;
                                       const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean;
                                       const unique_null_values: boolean ; const tsid : TFRE_DB_TransStepId);
    procedure  IndexDroppedOnField    (const coll_name: TFRE_DB_NameType  ; const index_name: TFRE_DB_NameType ; const tsid : TFRE_DB_TransStepId);
    procedure  ObjectStored           (const coll_name: TFRE_DB_NameType  ; const obj : IFRE_DB_Object ; const tsid : TFRE_DB_TransStepId); { FULL STATE }
    procedure  ObjectDeleted          (const coll_names: TFRE_DB_NameTypeArray ; const obj : IFRE_DB_Object ; const tsid : TFRE_DB_TransStepId);                                      { FULL STATE }
    procedure  ObjectRemoved          (const coll_names: TFRE_DB_NameTypeArray ; const obj : IFRE_DB_Object ; const is_a_full_delete : boolean ; const tsid : TFRE_DB_TransStepId);  { FULL STATE }
    procedure  ObjectUpdated          (const obj : IFRE_DB_Object ; const colls:TFRE_DB_StringArray ; const tsid : TFRE_DB_TransStepId);    { FULL STATE }
    procedure  DifferentiallUpdStarts (const obj_uid   : IFRE_DB_Object ; const tsid : TFRE_DB_TransStepId);            { DIFFERENTIAL STATE}
    procedure  FieldDelete            (const old_field : IFRE_DB_Field  ; const tsid : TFRE_DB_TransStepId);            { DIFFERENTIAL STATE}
    procedure  FieldAdd               (const new_field : IFRE_DB_Field  ; const tsid : TFRE_DB_TransStepId);            { DIFFERENTIAL STATE}
    procedure  FieldChange            (const old_field,new_field : IFRE_DB_Field ; const tsid : TFRE_DB_TransStepId);   { DIFFERENTIAL STATE}
    procedure  DifferentiallUpdEnds   (const obj_uid   : TFRE_DB_GUID ; const tsid : TFRE_DB_TransStepId);              { DIFFERENTIAL STATE}
    procedure  SetupOutboundRefLink   (const from_obj : IFRE_DB_Object   ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const tsid : TFRE_DB_TransStepId);
    procedure  SetupInboundRefLink    (const from_obj : IFRE_DB_Object   ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const tsid : TFRE_DB_TransStepId);
    procedure  InboundReflinkDropped  (const from_obj : IFRE_DB_Object   ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const tsid : TFRE_DB_TransStepId);
    procedure  OutboundReflinkDropped (const from_obj : IFRE_DB_Object   ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL ; const tsid : TFRE_DB_TransStepId);
    procedure  FinalizeNotif          ;
    {NOFIF BLOCK INTERFACE - END}
    function   DBC                    (const dblname : TFRE_DB_NameType) : IFRE_DB_CONNECTION;
    //procedure  ChildObjCountChange    (const parent_obj : IFRE_DB_Object); { the child object count has changed, send an update on queries with P-C relation, where this object is in }

    function    GetTransformedOrderedData    (const qry : TFRE_DB_QUERY_BASE ; var cd   : TFRE_DB_TRANSFORMED_ORDERED_DATA):boolean;
    function    CreateTransformedOrdered     (const generating_qry : TFRE_DB_QUERY):TFRE_DB_TRANSFORMED_ORDERED_DATA;
    function    GetBaseTransformedData       (base_key: TFRE_DB_CACHE_DATA_KEY; out base_data: TFRE_DB_TRANFORMED_DATA): boolean;


    constructor Create        ;
    destructor  Destroy       ; override;

    function    GetNewOrderDefinition               : TFRE_DB_DC_ORDER_DEFINITION_BASE; override ;
    function    GetNewFilterDefinition              (const filter_db_name : TFRE_DB_NameType)  : TFRE_DB_DC_FILTER_DEFINITION_BASE ; override;
    {
     Generate the query spec from the JSON Webinput object
     dependency_reference_ids : this are the dependency keys that be considered to use from the JSON (usually one, input dependency)
     collection_transform_key : unique specifier of the DATA TRANSFORMATION defined by this collection, ORDERS derive from them
    }
    function    GenerateQueryFromQryDef              (const qry_def : TFRE_DB_QUERY_DEF):TFRE_DB_QUERY_BASE; override;

    { --- Notify gathering }
    procedure   CN_AddDirectSessionUpdateEntry       (const update_dbo : IFRE_DB_Object); { add a dbo update for sessions dbo's (forms) }
    procedure   CN_AddGridInplaceUpdate              (const sessionid : TFRE_DB_NameType ; const store_id,store_id_dc : TFRE_DB_String ; const upo   : IFRE_DB_Object ; const oldpos,newpos,abscount : NativeInt);
    procedure   CN_AddGridInplaceDelete              (const sessionid : TFRE_DB_NameType ; const store_id,store_id_dc : TFRE_DB_String ; const del_id: TFRE_DB_String ; const position,abscount : NativeInt);
    procedure   CN_AddGridInsertUpdate               (const sessionid : TFRE_DB_NameType ; const store_id,store_id_dc : TFRE_DB_String ; const upo   : IFRE_DB_Object ; const position,abscount : NativeInt);

    procedure   UpdateLiveStatistics                 (const stats : IFRE_DB_Object);
    function    GetSessionRangeManager               (const qryid_rmkey: TFRE_DB_CACHE_DATA_KEY; out rm: TFRE_DB_SESSION_DC_RANGE_MGR; const is_Queryid: boolean): boolean;
    function    CreateSessionRangeManager            (const qryid : TFRE_DB_SESSION_DC_RANGE_MGR_KEY): TFRE_DB_SESSION_DC_RANGE_MGR;
    procedure   s_StatTimer                          (const timer        : IFRE_APSC_TIMER ; const flag1,flag2 : boolean);
    procedure   s_DropAllQueryRanges                 (const p     : TFRE_TDM_DROPQ_PARAMS);
    procedure   s_DropQryRange                       (const p     : TFRE_TDM_DROPQ_PARAMS);
    procedure   s_InboundNotificationBlock           (const block : IFRE_DB_Object);
  public
    function    ParallelWorkers                      : NativeInt;

    procedure   cs_DropAllQueryRanges                (const qry_id: TFRE_DB_CACHE_DATA_KEY;const whole_session : boolean); override; { is a seesion id only, if all ranges from that session should be deleted }
    procedure   cs_RemoveQueryRange                  (const qry_id: TFRE_DB_CACHE_DATA_KEY; const start_idx, end_idx: NativeInt); override;
    procedure   cs_InvokeQry                         (const qry   : TFRE_DB_QUERY_BASE; const transform: IFRE_DB_SIMPLE_TRANSFORM; const return_cg: IFRE_APSC_CHANNEL_GROUP;const ReqID:Qword ; const sync_event : IFOS_E); override;
    procedure   cs_InboundNotificationBlock          (const dbname: TFRE_DB_NameType ; const block : IFRE_DB_Object);override;
  end;


procedure  InitTransfromManager;
procedure  FinalizeTransformManager;
procedure  RangeManager_TestSuite;

implementation

function G_TCDM : TFRE_DB_TRANSDATA_MANAGER;
begin
  result := GFRE_DB_TCDM as TFRE_DB_TRANSDATA_MANAGER;
end;

procedure InitTransfromManager;
begin
  if not assigned(GFRE_DB_TCDM) then
    GFRE_DB_TCDM := TFRE_DB_TRANSDATA_MANAGER.Create;
end;

procedure FinalizeTransformManager;
begin
  if assigned(GFRE_DB_TCDM) then
    begin
      GFRE_DB_TCDM.Free;
      GFRE_DB_TCDM:=nil;
    end;
end;

procedure FREDB_DumpArray(const object_array : IFRE_DB_ObjectArray ; const start, cnt : NativeInt ; const fn : string);
var i : NativeInt;
begin
  for i := 0 to high(object_array) do
    begin
      writeln(i,' :: ',object_array[i].field(fn).AsString,' -- ',object_array[i].UID_String);
    end;
end;

//function  FREDB_BinaryFindIndexInSorted(const search_key : TFRE_DB_ByteArray ; const order_Key : TFRE_DB_NameType ; var before : NativeInt ; const object_array : IFRE_DB_ObjectArray ; var exists : boolean ; const exact_uid : PFRE_DB_Guid=nil ; const ignore_non_existing : boolean=false):NativeInt;
//var midx,leftx,rightx : NativeInt;
//    mkey              : TFRE_DB_ByteArray;
//    res               : NativeInt;
//
//    function Compare(key1,key2 : TFRE_DB_ByteArray):NativeInt;
//    var k1l,k2l,km,i : NativeInt;
//        v1,v2        : byte;
//    begin
//      k1l := Length(key1);
//      k2l := Length(key2);
//      km  := max(k1l,k2l)-1;
//      for i :=0 to km do
//       begin
//         if i<k1l then
//           v1 := key1[i]
//         else
//           v1 := 0;
//         if i<k2l then
//           v2 := key2[i]
//         else
//           v2 := 0;
//         result := v1 - v2;
//         if result<>0 then
//           break;
//       end;
//    end;
//
//    function FindExactKey : NativeInt;
//    begin
//      result := -1;
//      {first go to beginning }
//      if object_array[midx].UID=exact_uid^ then { quick bailout }
//        exit(midx);
//      repeat
//        if (midx=0) then
//          break;          { go back until the key changes }
//        mkey := object_array[midx-1].Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(order_Key).AsByteArr;
//        if Compare(search_key,mkey)=0 then
//          dec(midx)
//        else
//          break;
//      until false;
//      repeat
//        if midx>high(object_array) then { now go up and find the uid }
//          break;
//        if object_array[midx].UID=exact_uid^ then { quick bailout }
//          exit(midx);
//        if Compare(search_key,mkey)=0 then
//          inc(midx)
//        else
//          begin
//            result := midx;
//            break;
//          end;
//      until false;
//      if not ignore_non_existing then
//        raise EFRE_DB_Exception.Create(edb_NOT_FOUND,'the exact uid was not found in the array')
//      else
//        begin
//          exists := false;
//          result := midx;
//        end;
//    end;
//
//    function FindLastKey : NativeInt;
//    begin
//      result := -1;
//      repeat { go back }
//        if (midx=high(object_array)) then
//          break;
//        mkey := object_array[midx+1].Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(order_Key).AsByteArr;
//        if Compare(search_key,mkey)=0 then
//          inc(midx)
//        else
//          break;
//      until false;
//      result := midx;
//    end;
//
//
//begin
//  leftx  := 0;
//  before := 0;
//  midx   := 0;
//  res    := 0;
//  rightx := high(object_array);
//  exists := false;
//  while  leftx<=rightx do
//    begin
//       midx := leftx + ((rightx - leftx) div 2);
//       mkey := object_array[midx].Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(order_Key).AsByteArr;
//       if Length(mkey)=0 then
//         raise EFRE_DB_Exception.Create(edb_ERROR,'invalid order key len 0');
//       res := Compare(mkey,search_key);
//       if res=0 then
//         begin
//           exists := true;
//           result := midx;
//           if assigned(exact_uid) then
//             result := FindExactKey
//           else
//             result := FindLastKey;
//           exit;
//         end;
//       if res>0 then
//         rightx := midx-1
//       else
//         leftx  := midx+1;
//    end;
//  exists := false;
//  before := res;  { 1 = before}
//  result := midx;
//end;

function  FREDB_BinaryFindIndexInSortedUDA(const search_key : TFRE_DB_ByteArray ; const order_Key : TFRE_DB_NameType ; var before : NativeInt ; const object_array : TFRE_DB_TRANSFORM_UTIL_DATA_ARR ; var exists : boolean ; const exact_uid : PFRE_DB_Guid=nil ; const ignore_non_existing : boolean=false):NativeInt;
var midx,leftx,rightx : NativeInt;
    mkey              : TFRE_DB_ByteArray;
    res               : NativeInt;

    function Compare(key1,key2 : TFRE_DB_ByteArray):NativeInt;
    var k1l,k2l,km,i : NativeInt;
        v1,v2        : byte;
    begin
      k1l := Length(key1);
      k2l := Length(key2);
      km  := max(k1l,k2l)-1;
      for i :=0 to km do
       begin
         if i<k1l then
           v1 := key1[i]
         else
           v1 := 0;
         if i<k2l then
           v2 := key2[i]
         else
           v2 := 0;
         result := v1 - v2;
         if result<>0 then
           break;
       end;
    end;

    function FindExactKey : NativeInt;
    begin
      result := -1;
      {first go to beginning }
      if object_array[midx].GetObject.UID=exact_uid^ then { quick bailout }
        exit(midx);
      repeat
        if (midx=0) then
          break;          { go back until the key changes }
        //mkey := object_array[midx-1].GetObject.Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(order_Key).AsByteArr;
        mkey := object_array[midx-1].GetOrderKey(order_Key);
        if Compare(search_key,mkey)=0 then
          dec(midx)
        else
          break;
      until false;
      repeat
        if midx>high(object_array) then { now go up and find the uid }
          break;
        if object_array[midx].GetObject.UID=exact_uid^ then { quick bailout }
          exit(midx);
        if Compare(search_key,mkey)=0 then
          inc(midx)
        else
          begin
            result := midx;
            break;
          end;
      until false;
      if not ignore_non_existing then
        raise EFRE_DB_Exception.Create(edb_NOT_FOUND,'the exact uid was not found in the array')
      else
        begin
          exists := false;
          result := midx;
        end;
    end;

    function FindLastKey : NativeInt;
    begin
      result := -1;
      repeat { go back }
        if (midx=high(object_array)) then
          break;
        //mkey := object_array[midx+1].GetObject.Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(order_Key).AsByteArr;
        mkey := object_array[midx+1].GetOrderKey(order_Key);
        if Compare(search_key,mkey)=0 then
          inc(midx)
        else
          break;
      until false;
      result := midx;
    end;


begin
  leftx  := 0;
  before := 0;
  midx   := 0;
  res    := 0;
  rightx := high(object_array);
  exists := false;
  while  leftx<=rightx do
    begin
       midx := leftx + ((rightx - leftx) div 2);
       //mkey := object_array[midx].GetObject.Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(order_Key).AsByteArr;
       mkey := object_array[midx].GetOrderKey(order_Key);
       if Length(mkey)=0 then
         raise EFRE_DB_Exception.Create(edb_ERROR,'invalid order key len 0');
       res := Compare(mkey,search_key);
       if res=0 then
         begin
           exists := true;
           result := midx;
           if assigned(exact_uid) then
             result := FindExactKey
           else
             result := FindLastKey;
           exit;
         end;
       if res>0 then
         rightx := midx-1
       else
         leftx  := midx+1;
    end;
  exists := false;
  before := res;  { 1 = before}
  result := midx;
end;

function FREDB_RemoveIdxFomObjectArrayUDA(const arr: TFRE_DB_TRANSFORM_UTIL_DATA_ARR; const idx: NativeInt): TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
var cnt,i   : NativeInt;
begin
  if (idx<0) or (idx>High(arr)) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'FREDB_RemoveIdxFomObjectArrayUDA idx not in bounds failed -> [%d<=%d<=%d]', [0,idx,high(arr)]);
  SetLength(result,Length(arr)-1);
  cnt := 0;
  for i:=0 to idx-1 do
    begin
      result[cnt] := arr[i];
      inc(cnt)
    end;
  for i:=idx+1 to high(arr) do
    begin
      result[cnt] := arr[i];
      inc(cnt);
    end;
end;

function FREDB_InsertAtIdxToObjectArrayUDA(const arr: TFRE_DB_TRANSFORM_UTIL_DATA_ARR; var at_idx: NativeInt; const new_obj: TFRE_DB_TRANSFORM_UTIL_DATA ; const before : boolean): TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
var cnt,i,myat   : NativeInt;
begin
  SetLength(result,Length(arr)+1);
  if (at_idx<0) or (at_idx>High(Result)) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'FREDB_InsertAtIdxToObjectArrayUDA idx not in bounds failed -> [%d<=%d<=%d]', [0,at_idx,high(arr)]);
  cnt  := 0;
  myat := at_idx;
  if length(arr)=0 then
    begin
      result[0] := new_obj;
      exit;
    end;
  for i:=0 to high(arr) do
    begin
      if i<>myat then
        begin
          result[cnt] := arr[i];
          inc(cnt);
        end
      else
        begin
          if before then
            begin
              result[cnt] := new_obj;
              at_idx := cnt;
              inc(cnt);
              result[cnt] := arr[i];
              inc(cnt);
            end
          else
            begin
              result[cnt] := arr[i];
              inc(cnt);
              result[cnt] := new_obj;
              at_idx := cnt;
              inc(cnt);
            end;
        end;
    end;
end;




{ TFRE_DB_TRANSFORM_BACKLINK }

procedure TFRE_DB_TRANSFORM_BACKLINK.AddBackLink(const util: TFRE_DB_TRANSFORM_UTIL_DATA);
begin
  if FBLList.IndexOf(util)>-1 then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'invalid double add to refbacklink');
  FBLList.Add(util);
  writeln('ADDING REFERENCE BACKLINK ',ToUid.AsHexString,' <- ',util.GetObject.SchemeClass,' ',util.GetObject.UID_String,' ',FBLList.Count);
end;

procedure TFRE_DB_TRANSFORM_BACKLINK.RemoveBacklink(const util: TFRE_DB_TRANSFORM_UTIL_DATA);
var idx : NativeInt;
begin
  idx := FBLList.IndexOf(util);
  if idx = -1 then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'invalid, idx not found in refbacklink');
  writeln('REMOVING REFERENCE BACKLINK ',ToUid.AsHexString,' <- ',util.GetObject.SchemeClass,' ',util.GetObject.UID_String,' ',FBLList.Count);
  FBLList.Delete(idx);
end;

function TFRE_DB_TRANSFORM_BACKLINK.BacklinkCount: NativeInt;
begin
  result := FBLList.Count;
end;

function TFRE_DB_TRANSFORM_BACKLINK.GetDependendObjects: TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
var
    i: NativeInt;
begin
  SetLength(result,BacklinkCount);
  for i := 0 to FBLList.Count-1 do
   result[i] := FBLList[i] as TFRE_DB_TRANSFORM_UTIL_DATA;
end;

constructor TFRE_DB_TRANSFORM_BACKLINK.Create;
begin
  Inherited;
  FBLList := TFPObjectList.Create;
end;

destructor TFRE_DB_TRANSFORM_BACKLINK.Destroy;
begin
  if assigned(FBLList) then
    FBLList.Free;
  inherited Destroy;
end;

{ TFRE_DB_SESSION_DC_RANGE_MGR_KEY }

{ TFRE_DB_SESSION_DC_RANGE }

function TFRE_DB_SESSION_DC_RANGE.RangeFilled: boolean;
begin
  result := Length(FResultDBOs)<>0;
end;

procedure TFRE_DB_SESSION_DC_RANGE.FillRange(const compare_fill: boolean);
var
    i,j       : NativeInt;
begin
  if not compare_fill then
    begin
      if Length(FResultDBOs)=0 then
        begin
          SetLength(FResultDBOs,FEndIndex-FStartIndex+1);
          j         := 0;
          for i := FStartIndex to FEndIndex do
           begin
             FResultDBOs[j] := FMgr.RangeManagerFiltering.GetTransFormUtilData(i).CloneMySelf;
             inc(j)
           end;
        end
      else
        raise EFRE_DB_Exception.Create(edb_ERROR,'range is filled, double fill not allowed');
    end
  else
    begin
      if Length(FResultDBOsCompare)=0 then
        begin
          SetLength(FResultDBOsCompare,FEndIndex-FStartIndex+1);
          j         := 0;
          for i := FStartIndex to FEndIndex do
            begin
              FResultDBOsCompare[j] := FMgr.RangeManagerFiltering.GetTransFormUtilData(i).CloneMySelf;
              inc(j)
            end;
          SetLength(FResultDBOsCompare,j);
        end
      else
        raise EFRE_DB_Exception.Create(edb_ERROR,'compare range is filled, double fill not allowed');
    end;
end;

function TFRE_DB_SESSION_DC_RANGE.GetAbsoluteIndexedObj(const abs_idx: NativeInt): IFRE_DB_Object;
begin
  if (abs_idx>FEndIndex) or (abs_idx<FStartIndex) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'invalid absolute index [%d] request for range [%d..%d]',[abs_idx,FStartIndex,FEndIndex]);
  if FResultDBOs=nil then
    raise EFRE_DB_Exception.Create(edb_ERROR,'range not filled with data');
  result := FResultDBOs[abs_idx-FStartIndex].GetObj;
end;

function TFRE_DB_SESSION_DC_RANGE.AbsIdxFrom(const range_idx: NativeInt): NativeInt;
begin
  result := FStartIndex+range_idx;
end;

function TFRE_DB_SESSION_DC_RANGE.CheckUidIsInRange(const search_uid: TFRE_DB_GUID): boolean;
var i : NativeInt;
begin
  result := false;
  for i:=0 to high(FResultDBOs) do
    begin
      if FResultDBOs[i].GetObject.UID=search_uid then
        begin
          GFRE_DBI.LogDebug(dblc_DBTDM,'TAG/QRY UPDATE OBJECT DUE TO CHILD OBJECT COUNT CHANGE IN RMGR [%s], UID [%s]',[FMgr.RangemanagerKeyString,search_uid.AsHexString]);
          exit(true);
        end;
    end;
end;

procedure TFRE_DB_SESSION_DC_RANGE.ClearRange;
var i : NativeInt;
begin
  for i:=0 to high(FResultDBOs) do
    begin
      FResultDBOs[i].Free;
    end;
  SetLength(FResultDBOs,0);
end;

function TFRE_DB_SESSION_DC_RANGE.GetCorrespondingParentPath: TFRE_DB_String;
begin
  result := FMgr.GetCorrespondingParentPath;
end;

function TFRE_DB_SESSION_DC_RANGE.IsAChildResultset: Boolean;
begin
  result := FMgr.IsAChildResultSet;
end;

function TFRE_DB_SESSION_DC_RANGE.IsARootResultset: Boolean;
begin
  result := FMgr.IsARootResultset;
end;

constructor TFRE_DB_SESSION_DC_RANGE.Create(const mgr: TFRE_DB_SESSION_DC_RANGE_MGR; const start_idx, end_idx: NativeInt);
begin
  FMgr        := mgr;
  FStartIndex := start_idx;
  FEndIndex   := end_idx;
end;

destructor TFRE_DB_SESSION_DC_RANGE.Destroy;
begin
  ClearRange;
  inherited Destroy;
end;

procedure TFRE_DB_SESSION_DC_RANGE.ExtendRangeToEnd(const end_idx: NativeInt; const dont_fill: boolean);
var old_end   : NativeInt;
       i,j    : NativeInt;
       newlen : NativeInt;
       oldlen : NativeInt;
       {
         1: Range : 5..10  Index (0..5) old_end=10
         2: Extend to -> end_idx = 20, FEndindex = 20
            newlen = 16 oldlen = 6
            j = 10-5+1 = 6

       }
begin
  old_end   := FEndIndex;
  FEndIndex := end_idx;
  newlen    := FEndIndex-FStartIndex+1;
  oldlen    := old_end-FStartIndex+1;

  if newlen<=oldlen then
    raise EFRE_DB_Exception.Create(edb_ERROR,'extend to end failed, newlen<=oldlen [%d <= %d]',[newlen,oldlen]);

  if dont_fill then { used in the compare case, setup the indices but dont touch the array }
    exit;

  if Length(FResultDBOs)=0 then
    begin
      FillRange();
    end
  else
    begin
      SetLength(FResultDBOs,newlen);
      //FOBJArray := FMgr.RangeManagerFiltering.FOBJArray;
      j     := (old_end-FStartIndex+1);
      for i := (old_end+1) to FEndIndex do
       begin
         FResultDBOs[j] := FMgr.RangeManagerFiltering.GetTransFormUtilData(i).CloneMySelf;
         inc(j);
       end;
    end;
end;

procedure TFRE_DB_SESSION_DC_RANGE.ExtendRangeToStart(const start_idx: NativeInt; const dont_fill: boolean); //self
var FNewResult  : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
    newlen      : NativeInt;
    old_start   : NativeInt;
    i,j         : NativeInt;

begin
  old_start   := FStartIndex;
  FStartIndex := start_idx;

  if dont_fill then { used in the compare case, setup the indices but dont touch the array }
    exit;

  if Length(FResultDBOs)=0 then
    begin
      FillRange();
    end
  else
    begin
      newlen    := FEndIndex-start_idx+1;
      SetLength(FNewResult,newlen);
      j := 0;
      for i:=FStartIndex to old_start-1 do
        begin
          FNewResult[j] := FMgr.RangeManagerFiltering.GetTransFormUtilData(i).CloneMySelf;
          inc(j);
        end;
      for i := old_start to FEndIndex do
        begin
          FNewResult[j] := FResultDBOs[i-old_start];
          inc(j);
        end;
      FResultDBOs := FNewResult;
    end;
end;

procedure TFRE_DB_SESSION_DC_RANGE.CropRangeFromStartTo(const crop_idx: NativeInt; const dont_crop: boolean);  //self
var FNewResult  : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
    newlen      : NativeInt;
    old_start   : NativeInt;
    crop_base   : NativeInt;
    i,j         : NativeInt;
    FOBJArray   : IFRE_DB_ObjectArray;
begin
  if crop_idx<=FStartIndex then
    raise EFRE_DB_Exception.create(edb_ERROR,'crop range from start invalid crop_idx [crop_idx = %d, old_end = %d]',[crop_idx,FStartIndex]);

  newlen    := FEndIndex-crop_idx+1;
  old_start := FStartIndex;
  //SetLength(FNewResult,newlen);
  FStartIndex := crop_idx;

  if dont_crop then { used in the compare case, setup the indices but dont touch the array }
    exit;


  crop_base   := crop_idx - old_start;
  FNewResult  := Copy(FResultDBOs,crop_base,newlen);

  for i := 0 to crop_base-1 do
    FResultDBOs[i].Free;

  FResultDBOs := FNewResult;
end;

procedure TFRE_DB_SESSION_DC_RANGE.CropRangeFromEndTo(const crop_idx: NativeInt; const dont_crop: boolean);
var i,old_end,newlen : NativeInt;
begin
  old_end    := FEndIndex;
  FEndIndex  := crop_idx;
  if old_end<=FEndIndex then
    raise EFRE_DB_Exception.create(edb_ERROR,'crop range from end invalid crop_idx [crop_idx = %d, old_end = %d]',[crop_idx,old_end]);
  if dont_crop then { used in the compare case, setup the indices but dont touch the array }
    exit;
  if Length(FResultDBOs)=0 then
    begin
      FillRange();
    end
  else
    begin
      for i := old_end downto FEndIndex+1 do
        begin
          FResultDBOs[i-FStartIndex].Free;
          FResultDBOs[i-FStartIndex]:=nil;
        end;
      newlen := FEndIndex-FStartIndex+1;
      SetLength(FResultDBOs,newlen);
    end;
end;

procedure TFRE_DB_SESSION_DC_RANGE.RangeExecuteQry(const qry_start_ix, chunk_start, chunk_end: NativeInt; var dbos: IFRE_DB_ObjectArray);
var i : NativeInt;
begin
  if Length(FResultDBOs)=0 then
    GFRE_BT.CriticalAbort('range empty not filled in parallel deliver result/clone (!)');
  for i:= chunk_start to chunk_end do  //qry_start_ix to qry_end_ix do { qry start - end (not range !) }
    begin
      dbos[i] := GetAbsoluteIndexedObj(i+qry_start_ix).CloneToNewObject;
    end;
end;

procedure TFRE_DB_SESSION_DC_RANGE.RangeProcessFilterChangeBasedUpdates(const sessionid: TFRE_DB_SESSION_ID; const storeid: TFRE_DB_NameType; const orderkey: TFRE_DB_NameType; const AbsCount: NativeInt; var calcedabs: NativeInt);
var myupo     : IFRE_DB_Object;
    i         : Integer;
    j         : Integer;
    exists    : Boolean;
    ppstoreid : TFRE_DB_String;
    pp        : TFRE_DB_String;
    IsaChild  : Boolean;
    Inserted  : NativeInt;
    Deleted   : NativeInt;
    Updated   : NativeInt;

  function ObjectIsModified(const o1,o2 : TFRE_DB_TRANSFORM_UTIL_DATA):boolean;
  var otag,
      ntag        : TFRE_DB_TransStepId;
  begin
    otag   := o1.GetObject.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
    ntag   := o2.GetObject.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
    result := ntag<>otag; { object has a new transaction tag, thus was modified }
  end;

  procedure AddToList(var l : TFRE_DB_TRANSFORM_UTIL_DATA_ARR ; const tud : TFRE_DB_TRANSFORM_UTIL_DATA ; var cnt : NativeInt);
  begin
    if cnt=Length(l) then
      SetLength(l,length(l)+cFRE_INT_RANGE_LIST_TUNE);
    l[cnt] := tud;
    inc(cnt);
  end;

  procedure CompressArray(var ina : TFRE_DB_TRANSFORM_UTIL_DATA_ARR);
  var newa  : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
      i,cnt : NativeInt;
  begin
    SetLength(newa,Length(ina));
    cnt :=0;
    for i:=0 to high(ina) do
      if ina[i]<>nil then
        begin
          newa[cnt]:=ina[i];
          inc(cnt);
        end;
    SetLength(newa,cnt);
    ina := newa;
  end;


  procedure DoDelete(const idx : NativeInt);
  begin
    dec(calcedabs); { one is deleted, thus decrement the absolute cnt }
    inc(Deleted);
    if IsaChild then
        ppstoreid := storeid+'@'+pp
    else
      ppstoreid := storeid;
    G_TCDM.CN_AddGridInplaceDelete(sessionid,ppstoreid,storeid,FResultDBOs[i].GetObject.UID_String,AbsIdxFrom(i),calcedabs); { send delete for no more  existing object }
    FResultDBOs[idx].Free;
    FResultDBOs[idx]:= nil; { hole }
  end;

  procedure InsertIntoOldResults(var ia_idx : NativeInt ; tud : TFRE_DB_TRANSFORM_UTIL_DATA ; const before:boolean);
  begin
    FREDB_InsertAtIdxToObjectArrayUDA(FResultDBOs,ia_idx,tud.CloneMySelf,before); { clone it it gets freed }
    inc(calcedabs);
    inc(Inserted);
    if IsaChild  then
      ppstoreid := storeid+'@'+pp
    else
      ppstoreid := storeid;
    G_TCDM.CN_AddGridInsertUpdate(sessionid,ppstoreid,storeid,tud.GetObj,AbsIdxFrom(ia_idx),calcedabs);
  end;

  procedure SendUpdate(const old_idx,new_idx : NativeInt; const obj : IFRE_DB_Object);
  begin
    inc(Updated);
    if IsaChild  then
      ppstoreid := storeid+'@'+pp
    else
      ppstoreid := storeid;
    G_TCDM.CN_AddGridInplaceUpdate(sessionid,ppstoreid,storeid,obj,old_idx,new_idx,calcedabs);
  end;


  function FREDB_GuidInUDA(const check: TFRE_DB_GUID; const arr: TFRE_DB_TRANSFORM_UTIL_DATA_ARR): NativeInt;
  var  i: NativeInt;
  begin
    result := -1;
    for i:=0 to High(arr) do
      if check=arr[i].GetObject.UID then
        exit(i);
  end;


  var UpdateList    : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
      UpdCount      : NativeInt=0;
      hiold,hinew   : NativeInt;
      new_key       : TFRE_DB_ByteArray;
      ia_idx,before : NativeInt;
      in_idx        : NativeInt;


  { FResultDBOS         = State on Client }
  { FResultDBOSCompare  = State to be     } //self

begin
  IsaChild := IsAChildResultset;
  PP       := GetCorrespondingParentPath;
  Inserted := 0;
  Deleted  := 0;
  Updated  := 0;
  try
     FillRange(true); { Fill Compare Range according to adjusted endindex }
     try
      { Phase One : Delete all that are missing in the new resultset }
       calcedabs  := AbsCount;  { old count }
      //if Length(FResultDBOs)<>calcedabs then { HOLDS ONLY in small ranges }
      //  raise EFRE_DB_Exception.Create(edb_ERROR,'calced something wrong A');
       hiold      := high(FResultDBOs);
       hinew      := High(FResultDBOsCompare);
       for i := hiold downto 0 do { Do for every Object that was in the Result set of the query, do it in reverse so that the position index does not change on deletes }
         begin
           exists := false;  { todo replace with binary search }
           for j := hinew downto 0  do { Check if the object still exists in the old result set }
             begin
               if FResultDBOsCompare[j].GetObject.uid = FResultDBOs[i].GetObject.UID then { Object is found, maybe Update }
                 begin
                   exists := true;
                   if ObjectIsModified(FResultDBOsCompare[j],FResultDBOs[i]) then { Object is modified => Update}
                     begin
                       AddToList(UpdateList,FResultDBOsCompare[j],UpdCount);      { remember to update the object from the new set }
                     end;
                   break; { found }
                 end;
             end;
           if not exists then { delete the object unconditionally }
             begin
               DoDelete(i);
             end;
         end;
       SetLength(UpdateList,UpdCount);
       CompressArray(FResultDBOs);
       //if Length(FResultDBOs)<>calcedabs then
       //  raise EFRE_DB_Exception.Create(edb_ERROR,'calced something wrong B');

       { Phase Two : Insert all new entries into old resultset, to get the insert point }
       for i := 0 to hinew do { Do for every Object that was in the new result set of the query }
         begin
           if FREDB_GuidInUDA(FResultDBOsCompare[i].GetObject.UID,UpdateList)<>-1 then { is not an update, skip}
             continue;
           exists   := false;
           new_key  := FResultDBOsCompare[i].GetOrderKey(orderkey);     //FResultDBOsCompare[i].Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(OrderKey).AsByteArr;
           if Length(new_key)=0 then
               raise EFRE_DB_Exception.Create(edb_ERROR,'total order key / binary key not found in insert / ProcessFilterchangeBAsedUpdates');
           ia_idx := FREDB_BinaryFindIndexInSortedUDA(new_key,OrderKey,before,FResultDBOs,exists,FResultDBOsCompare[i].GetObject.PUID,true); { search new in old, binary, get key }
           if not exists then
             begin
               InsertIntoOldResults(ia_idx,FResultDBOsCompare[i],before>0);
             end;
         end;

       { Phase Three : From the updatelist, update in new array }

        //if calcedabs<>Length(FResultDBOsCompare) then
        // raise EFRE_DB_Exception.Create(edb_ERROR,'calced something wrong C / Result must have same len as expected ');

       //if (Length(FResultDBOs)+Inserted)<>Length(FResultDBOsCompare) then
       //  raise EFRE_DB_Exception.Create(edb_ERROR,'calced something wrong D / old result + insertde must be new result count');

       for i:=0 to high(UpdateList) do
         begin
           in_idx := FREDB_GuidInUDA(UpdateList[i].GetObject.UID,FResultDBOsCompare);
           ia_idx := FREDB_GuidInUDA(UpdateList[i].GetObject.UID,FResultDBOs);
           if in_idx<0 then
             raise EFRE_DB_Exception.Create(edb_ERROR,'cannot find update uid [%s] in new array',[UpdateList[i].GetObject.UID.AsHexString]);
           if ia_idx<0 then
             raise EFRE_DB_Exception.Create(edb_ERROR,'cannot find update uid [%s] in old array',[UpdateList[i].GetObject.UID.AsHexString]);
           SendUpdate(ia_idx,in_idx,FResultDBOsCompare[in_idx].GetObject.CloneToNewObject);
         end;
     finally
       ClearRange;
       FResultDBOs := FResultDBOsCompare;
       FResultDBOsCompare:=nil;
     end;
     //if (FEndIndex-FStartIndex+1)<>Length(FResultDBOs) then
     //    raise EFRE_DB_Exception.Create(edb_ERROR,'calced something wrong E - Start End Indices wrong');
  except
   on e:exception do
     begin
       writeln('-------------------------------------');
       writeln('>>>>> RANGEMGR FILTER UPDATE FAILURE (CACHED DATA MAY BE ROTTEN)');
       writeln('SPEC ',FMgr.FRMFiltercont.GetCacheDataKey.GetFullKeyString,' CHILD = ',IsaChild,' PP=',GetCorrespondingParentPath);
       writeln(e.Message);
       writeln('-------------------------------------');
     end;
  end;
end;

{ TFRE_DB_SESSION_DC_RANGE_MGR }

procedure TFRE_DB_SESSION_DC_RANGE_MGR.InternalRangeCheck(testranges: array of NativeInt; const range_iter: TWorkRangeIter);
type
  TRange=record
    s,e : NativeInt;
  end;
var lr,ltr : NativeInt;
    tArray : Array of TRange;
    i,j    : NativeInt;

    procedure Scan(var dummy : PtrUInt);
    var r : TFRE_DB_SESSION_DC_RANGE;
    begin
      r := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(dummy));
      if (tArray[i].s<>r.FStartIndex) or (tArray[i].e<>r.FEndIndex) then
        Bailout('range mismatch at index [%d] differences : [start: %d<> %d / end %d <> %d]',[i,tArray[i].s,r.FStartIndex,tArray[i].e,r.FEndIndex]);
      range_iter(r);
      inc(i);
    end;

begin
  if Length(testranges) mod 2 <>0 then
    Bailout('testrange spec failed',[]);
  SetLength(TArray,Length(testranges) div 2);
  i:=0;
  j:=0;
  while i <= high(testranges) do
    begin
      tArray[j].s := testranges[i];
      tArray[j].e := testranges[i+1];
      inc(i,2);
      inc(j,1);
    end;
  lr  := FRanges.GetValueCount;
  ltr := Length(TArray);
  if lr <> ltr then
    Bailout('Unexpected Ranges Have: %d <>  Want %d',[lr,ltr]);
  i := 0;
  FRanges.LinearScan(@Scan);
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.Bailout(msg: string; params: array of const);
var txt : string;
begin
  txt := Format(msg,params);
  writeln(txt);
  DumpRanges;
  halt;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.DumpRanges;
var i : NativeInt;

  procedure DumpRange(var dummy : PtrUInt);
  var r : TFRE_DB_SESSION_DC_RANGE;
  begin
    r := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(dummy));
    writeln(format(' > RANGE %3d [%5d .. %5d]',[i,r.FStartIndex,r.FEndIndex]));
    inc(i);
  end;

begin
  i:=0;
  FRanges.LinearScan(@DumpRange);
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.DumpRangesCompressd: String;
var i : NativeInt;

  procedure DumpRange(var dummy : PtrUInt);
  var r : TFRE_DB_SESSION_DC_RANGE;
  begin
    r := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(dummy));
    result := result +format('[%d..%d]',[r.FStartIndex,r.FEndIndex]);
  end;

begin
  result := '';
  FRanges.LinearScan(@DumpRange);
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.GetMaxIndex: NativeInt;
begin
  if not assigned(FRMFiltercont) then
    exit(0)
  else
    result := FRMFiltercont.GetDataCount-1;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.ForAllRanges(const riter: TRangeIterBrk): boolean;
var halt : boolean;

   procedure Iterate(var value : NativeUint ; var break : boolean);
   var r : TFRE_DB_SESSION_DC_RANGE;
   begin
     r := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(value));
     riter(r,break);
   end;

begin
  halt   := false;
  result := FRanges.LinearScanBreak(@Iterate,halt);
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.TagRangeMgrIfObjectIsInResultRanges(const search_uid: TFRE_DB_GUID ; const transid : TFRE_DB_TransStepId);
var i : NativeInt;

    procedure MySearch(const r : TFRE_DB_SESSION_DC_RANGE ; var halt:boolean);
    begin
      halt := r.CheckUidIsInRange(search_uid);
      if halt then
        TagForUpInsDelRLC(transid);
    end;

begin { TODO: UseHashlists for RangeScans (?) }
  ForAllRanges(@MySearch);
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.GetCorrespondingParentPath: TFRE_DB_String;
begin
  result := FRMFiltercont.ParentPath;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.IsAChildResultset: Boolean;
begin
  result := FRMFiltercont.IsAChildDataFilterDefinition;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.IsARootResultset: Boolean;
begin
  result := FRMFiltercont.IsARootDataFilterDefinition;
end;



constructor TFRE_DB_SESSION_DC_RANGE_MGR.Create(const key: TFRE_DB_SESSION_DC_RANGE_MGR_KEY);
begin
  FRMK                 := key;
  FRanges              := TFRE_ART_TREE.Create;
  FLastQryMaximalIndex := -1; { never set indicator }
end;

destructor TFRE_DB_SESSION_DC_RANGE_MGR.Destroy;
begin
  ClearRanges;
  FRanges.Free;
  inherited Destroy;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.AssignOrdering(const od: TFRE_DB_TRANSFORMED_ORDERED_DATA);
begin
  if assigned(FRMFiltercont) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'rm - want assigned ordering but filtering already assigned');
  if assigned(FRMOrdering) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'rm - ordering double assign');
  FRMOrdering := od;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.AssignFiltering(const fc: TFRE_DB_FILTER_CONTAINER);
begin
  if not assigned(FRMOrdering) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'rm want filter assign, but no ordering');
  if Assigned(FRMFiltercont) then
    raise EFRE_DB_Exception.create(edb_INTERNAL,'rm - fc double assign');
  fc.AddSessionRangemanager(self);
  FRMFiltercont := fc;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.ClearRanges;

  procedure FreeRanges(var dummy : PtrUInt);
  begin
    TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(dummy)).Free;
  end;

begin
  FRanges.LinearScan(@FreeRanges);
  FRanges.Clear;
  if assigned(FRMFiltercont) then
    FRMFiltercont.RemoveSessionRangemanager(self);
  FRMFiltercont:=nil;
  FRMOrdering:=nil;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.FindRange4QueryAndUpdateQuerySpec(const sessionid: TFRE_DB_SESSION_ID; out range: TFRE_DB_SESSION_DC_RANGE; var startidx, endidx, potentialcnt: NativeInt): boolean;
begin
  result    := FindRangeSatisfyingQuery(startidx,endidx,range,false)=rq_OK;
  if result then
    begin
      if endidx > range.FEndIndex then { crop down end index if it is too high}
        endidx := range.FEndIndex;
      potentialcnt := GetMaxIndex+1;
    end;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.FindRangeSatisfyingQuery(start_idx, end_idx: NativeInt; out range: TFRE_DB_SESSION_DC_RANGE; const dont_fill: boolean): TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;
var i                 : NativeInt;
    FStartInRangeID   : TWorkRangeR;
    FEndInRangeID     : TWorkRangeR;
    FStartAdjRangeID  : TWorkRangeR;
    FEndAdjRangeID    : TWorkRangeR;
    FStartExtendingID : TWorkRangeR;
    FEndExtendingID   : TWorkRangeR;
    FRangeAfterReqIx  : TWorkRangeR;
    maxi              : NativeInt;
    newrange          : TFRE_DB_SESSION_DC_RANGE;
    halt              : Boolean;

    procedure CheckPartialRanges;
    var  i     : NativeInt;

        procedure ClearValues(var wr:TWorkRangeR);inline;
        begin
          wr.Rid := -1; wr.Six := -1 ; wr.Eix := -1; wr.rr := nil;
        end;

        procedure Scan(var dummy : PtrUInt ; var halt : boolean);
        var r : TFRE_DB_SESSION_DC_RANGE;

            procedure SetValues(var wr:TWorkRangeR);inline;
            begin
              wr.rid := r.FStartIndex; wr.Six := r.FStartIndex; wr.Eix := r.FEndIndex; wr.rr := r;
            end;

        begin
          r := TFRE_DB_SESSION_DC_RANGE(dummy);
          if (FStartInRangeID.Rid=-1) and ((r.FStartIndex <= start_idx) and (r.FEndIndex>= start_idx)) then  { found a range satisfying start_idx }
            SetValues(FStartInRangeID);
          if (FStartAdjRangeID.Rid=-1) and (r.FEndIndex+1=start_idx) then                                    { found a range which is immediatly (adjecent) before the requested range }
            SetValues(FStartAdjRangeID);
          if (FEndInRangeID.Rid=-1) and ((r.FStartIndex <= end_idx) and (r.FEndIndex>= end_idx)) then        { found a range satisfying end_idx }
            SetValues(FEndInRangeID);
          if (FEndAdjRangeID.rid=-1) and (r.FStartIndex-1=end_idx) then                                      { found a range which is immediatly (adjecent) after the requested range  }
            SetValues(FEndAdjRangeID);
          if r.FStartIndex>end_idx then
            begin
              SetValues(FRangeAfterReqIx);
              halt := true;
              exit;
            end;
          inc(i);
        end;

    begin
      i:=0;
      ClearValues(FStartInRangeID);
      ClearValues(FEndInRangeID);
      ClearValues(FStartAdjRangeID);
      ClearValues(FEndAdjRangeID);
      ClearValues(FEndInRangeID);
      ClearValues(FRangeAfterReqIx);
      halt := false;
      FRanges.LinearScanBreak(@Scan,halt);
    end;

    procedure ExtendStartingRangeToEnd(const r : TFRE_DB_SESSION_DC_RANGE ; const end_idx : NativeInt);
    begin
      r.ExtendRangeToEnd(end_idx,dont_fill);
    end;

    function ExtendRangeToRange(const sr,er : TFRE_DB_SESSION_DC_RANGE):TFRE_DB_SESSION_DC_RANGE;
    var i      : NativeInt;
        ranges : Array of TFRE_DB_SESSION_DC_RANGE;
        rr     : TFRE_DB_SESSION_DC_RANGE;
        dummy  : PtrUInt;

      procedure RangeScan(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var dcounter,upcounter : NativeInt ; const abscntr : NativeInt);
      var r : TFRE_DB_SESSION_DC_RANGE;
      begin
        r         := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(value));
        ranges[i] := r;
        inc(i);
      end;

    begin
      i := 0;
      if sr=er then
        raise EFRE_DB_Exception.Create(edb_ERROR,'using ExtendRangeToRange for a same range request');
      GFRE_DBI.LogDebug(dblc_DBTDMRM,'WARNING REQUEST FETCHING ALREADY FETCHED DATA [%d..%d] Ranges ( %s )',[start_idx,end_idx,DumpRangesCompressd]);
      write(Format('WARNING REQUEST FETCHING ALREADY FETCHED DATA [%d..%d] Ranges ( %s ) ',[start_idx,end_idx,DumpRangesCompressd]));
      SetLength(ranges,FRanges.GetValueCount);
      FRanges.RangeScanUint64Key(sr.FStartIndex,er.FStartIndex,@RangeScan);
      SetLength(ranges,i);
      if Length(ranges)<2 then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'a bridging range to range extend should have at least 2 ranges not [%d]',[Length(ranges)]);
      for i:=high(ranges) downto 1 do { remove all bridging ranges except the first one ...}
       begin
         rr := ranges[i];
         if not FRanges.RemoveUInt64Key(rr.FStartIndex,dummy) then
           raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range remove bridging range not found [%d..%d] ',[rr.FStartIndex,rr.FEndIndex ]);
         rr.Free;
       end;
      rr := ranges[0];
      rr.ExtendRangeToEnd(er.FEndIndex,dont_fill);
      result := rr;
    end;

    procedure ExtendEndingRangeToStart(const r : TFRE_DB_SESSION_DC_RANGE ; const start_idx : NativeInt);
    var dummy : PtrUInt;
    begin
      if not FRanges.RemoveUInt64Key(r.FStartIndex,dummy) then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent extendending to start [%d] ',[r.FStartIndex]);
      if dummy<>PtrUInt(r) then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id pointer compare failure');
      r.ExtendRangeToStart(start_idx,dont_fill);
      if not FRanges.InsertUInt64Key(r.FStartIndex,FREDB_ObjectToPtrUInt(r)) then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range exists [%d %d]',[r.FStartIndex,r.FEndIndex]);
    end;

begin
  range := nil;
  maxi := GetMaxIndex;
  if start_idx<0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'range query startindx [%d] is < 0',[start_idx]);
  if end_idx<0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'range query endindx [%d] is < 0',[end_idx]);
  GFRE_DBI.LogDebug(dblc_DBTDMRM,'FIND RANGE SATISFYING QUERY [%d .. %d]',[start_idx,end_idx]);
  GFRE_DBI.LogDebug(dblc_DBTDMRM,'in Ranges : [%s] ',[DumpRangesCompressd]);
  if start_idx>end_idx then
    raise EFRE_DB_Exception.Create(edb_ERROR,'range query startindx [%d] is higher then endindex [%d]',[start_idx,end_idx]);
  if (start_idx>maxi) then
    begin
      GFRE_DBI.LogDebug(dblc_DBTDMRM,'no data availlable');
      exit(rq_NO_DATA);    { there is definitly no data available }
    end;
  FLastQryMaximalIndex := maxi;
  if end_idx > maxi then
    end_idx := maxi;
  CheckPartialRanges;
  if (FStartInRangeID.Rid=FEndInRangeID.Rid) and (FStartInRangeID.Rid<>-1) then { found an existing range, covering the requested range }
    begin
      range := FStartInRangeID.rr;
    end
  else
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid=-1) and (FStartAdjRangeID.Rid=-1) and (FEndAdjRangeID.Rid=-1) then { no range, and no direct extension satisfies the range request }
    begin
       newrange := TFRE_DB_SESSION_DC_RANGE.Create(self,start_idx,end_idx);
       if not FRanges.InsertUInt64Key(newrange.FStartIndex,FREDB_ObjectToPtrUInt(newrange)) then
         raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range exists [%d %d]',[newrange.FStartIndex,newrange.FEndIndex]);
       range := newrange;
       if not dont_fill then
         range.FillRange;
    end
  else
  if (FStartInRangeID.Rid>-1) and (FEndInRangeID.Rid=-1) and (halt=true) and (FRangeAfterReqIx.Rid>-1) and (FEndAdjRangeID.Rid=-1) then { found a start range to extend and a range after with a gap in between }
    begin
      ExtendStartingRangeToEnd(FStartInRangeID.rr,end_idx);
      range := FStartInRangeID.rr;
    end
  else
  if (FStartInRangeID.Rid>-1) and (FEndInRangeID.Rid=-1) and (halt=false) and (FEndAdjRangeID.Rid=-1) then { found a start range to extend and no range behind }
    begin
      ExtendStartingRangeToEnd(FStartInRangeID.rr,end_idx);
      range := FStartInRangeID.rr;
    end
  else
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid>-1) and (FStartAdjRangeID.Rid=-1) then
    begin
      GFRE_DBI.LogDebug(dblc_DBTDMRM,'WARNING REQUEST ALREADY FETCHED DATA IN ENDRANGE REQUEST [%d..%d] Matching Range [%d..%d]',[start_idx,end_idx,FEndInRangeID.Six,FEndInRangeID.Eix]);
      write(Format('WARNING REQUEST ALREADY FETCHED DATA IN ENDRANGE REQUEST [%d..%d] Matching Range [%d..%d]',[start_idx,end_idx,FEndInRangeID.Six,FEndInRangeID.Eix]));
      ExtendEndingRangeToStart(FEndInRangeID.rr,start_idx);
      range := FEndInRangeID.rr;
    end
  else
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid=-1) and (FStartAdjRangeID.Rid=-1) and (FEndAdjRangeID.Rid>-1) then { found a range after a gap, that is extending the requested range }
    begin
      ExtendEndingRangeToStart(FEndAdjRangeID.rr,start_idx);
      range := FEndAdjRangeID.rr;
    end
  else
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid=-1) and (FStartAdjRangeID.Rid>-1) and (FEndAdjRangeID.Rid=-1) then { found a range that is extending the requested range to the front, and a gap behind }
    begin
      ExtendStartingRangeToEnd(FStartAdjRangeID.rr,end_idx);
      range := FStartAdjRangeID.rr;
    end
  else
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid=-1) and (FStartAdjRangeID.Rid>-1) and (FEndAdjRangeID.Rid>-1) then { found a range that is bridging two ranges, both adjecent }
    begin
      range := ExtendRangeToRange(FStartAdjRangeID.rr,FEndAdjRangeID.rr);
    end
  else
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid>-1) and (FStartAdjRangeID.Rid>-1) and (FEndAdjRangeID.Rid=-1) then { found a range that is bridging two ranges, start adjecent }
    begin
      range := ExtendRangeToRange(FStartAdjRangeID.rr,FEndInRangeID.rr);
    end
  else
  if (FStartInRangeID.Rid>-1) and (FEndInRangeID.Rid=-1) and (FStartAdjRangeID.Rid=-1) and (FEndAdjRangeID.Rid>-1) then { found a range that is bridging two ranges, end adjecent }
    begin
      range := ExtendRangeToRange(FStartInRangeID.rr,FEndAdjRangeID.rr);
    end
  else
  if (FStartInRangeID.Rid>-1) and (FEndInRangeID.Rid>-1) and (FStartAdjRangeID.Rid=-1) and (FEndAdjRangeID.Rid=-1) then { found a range that is bridging two ranges }
    begin
      range := ExtendRangeToRange(FStartInRangeID.rr,FEndInRangeID.rr);
    end
  else
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected case FindRangeSatisfyingQuery Want: [%d..%d] in [%s] {SIR %d EIR %d SAR %d EAR %d RAR %d %s} ',[start_idx,end_idx,DumpRangesCompressd,FStartInRangeID.Rid,FEndInRangeID.Rid,FStartAdjRangeID.rid,FEndAdjRangeID.rid,FRangeAfterReqIx.Rid,BoolToStr(halt,'HALT','NOT HALT')]);
  result := rq_OK;
  GFRE_DBI.LogDebug(dblc_DBTDMRM,'Found range / New Ranges : %s ',[DumpRangesCompressd]);
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.DropRange(start_idx, end_idx: NativeInt; const dont_crop: boolean; const riter: TWorkRangeIter): TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;
var i                 : NativeInt;
    FStartInRangeID   : TWorkRangeR;
    FEndInRangeID     : TWorkRangeR;
    newrange          : TFRE_DB_SESSION_DC_RANGE;
    halt              : Boolean;

    procedure CheckPartialRanges;
        procedure ClearValues(var wr:TWorkRangeR);inline;
        begin
          wr.Rid := -1; wr.Six := -1 ; wr.Eix := -1; wr.rr := nil;
        end;

        procedure Scan(var dummy : PtrUInt ; var halt : boolean);
        var r : TFRE_DB_SESSION_DC_RANGE;

            procedure SetValues(var wr:TWorkRangeR);inline;
            begin
              wr.rid := r.FStartIndex; wr.Six := r.FStartIndex; wr.Eix := r.FEndIndex; wr.rr := r;
            end;

        begin
          r := TFRE_DB_SESSION_DC_RANGE(dummy);
          if (FStartInRangeID.Rid=-1) and (start_idx <= r.FEndIndex) then    { found the minimal range the delete must start }
            SetValues(FStartInRangeID);
          if (FEndInRangeID.Rid=-1) and (end_idx <= r.FEndIndex) then        { found the last  range satisfying end_idx   }
            SetValues(FEndInRangeID);
        end;

    begin
      i:=0;
      ClearValues(FStartInRangeID);
      ClearValues(FEndInRangeID);
      halt := false;
      FRanges.LinearScanBreak(@Scan,halt);
    end;

    procedure DoOneRangeSplitOrRangeCutoff(const range : TFRE_DB_SESSION_DC_RANGE);
    var dummy    : PtrUInt;
        newrange : TFRE_DB_SESSION_DC_RANGE;
    begin
      if (start_idx=range.FStartIndex) and (end_idx=range.FEndIndex) then
        begin
           if not FRanges.RemoveUInt64Key(range.FStartIndex,dummy) then
             raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent drop full range [%d] ',[range.FStartIndex]);
           try
             if assigned(riter) then
               riter(range);
           finally
             range.Free;
           end;
        end
      else
      if (start_idx=range.FStartIndex) and (end_idx<range.FEndIndex) then { front cut off }
        begin
           if not FRanges.RemoveUInt64Key(range.FStartIndex,dummy) then
             raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent front cutoff range [%d] ',[range.FStartIndex]);
           range.CropRangeFromStartTo(end_idx+1,dont_crop);
           if not FRanges.InsertUInt64Key(range.FStartIndex,FREDB_ObjectToPtrUInt(range)) then { insert range with new start index }
             raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id insert fail front cut off range [%d] ',[range.FStartIndex]);
        end
      else
      if (start_idx>range.FStartIndex) and (end_idx=range.FEndIndex) then { tail cut off }
        begin
          range.CropRangeFromEndTo(start_idx-1,dont_crop);
        end
      else
      if (start_idx>range.FStartIndex) and (end_idx<range.FEndIndex) then { range split - cut off end, inser new end }
        begin
          newrange := TFRE_DB_SESSION_DC_RANGE.Create(self,end_idx+1,range.FEndIndex);
          newrange.FillRange();
          range.CropRangeFromEndTo(start_idx-1,dont_crop);
          if not FRanges.InsertUInt64Key(newrange.FStartIndex,FREDB_ObjectToPtrUInt(newrange)) then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr range split exists [%d %d]',[newrange.FStartIndex,newrange.FEndIndex]);
        end
      else
      if (start_idx<range.FStartIndex) and (end_idx=range.FEndIndex) then { full range cut start too early, warning }
        begin
          GFRE_DBI.LogDebug(dblc_DBTDMRM,'WARNING DROP RANGE REQUEST FOR NON FULLY RANGED DATA / FULL DROP [%d..%d] Matching Range [%d..%d]',[start_idx,end_idx,range.FStartIndex,range.FEndIndex]);
          write(Format('WARNING DROP RANGE REQUEST FOR NON FULLY RANGED DATA / FULL DROP [%d..%d] Matching Range [%d..%d]',[start_idx,end_idx,range.FStartIndex,range.FEndIndex]));
          if not FRanges.RemoveUInt64Key(range.FStartIndex,dummy) then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent drop full range /warning [%d] ',[range.FStartIndex]);
          try
            if assigned(riter) then
              riter(range);
          finally
            range.Free;
          end;
        end
      else
      if (start_idx<range.FStartIndex) and (end_idx<range.FEndIndex) then { partial range cut, warning }
        begin
          GFRE_DBI.LogDebug(dblc_DBTDMRM,'WARNING DROP RANGE REQUEST FOR NON FULLY RANGED DATA / PARTIAL DROP  [%d..%d] Matching Range [%d..%d]',[start_idx,end_idx,range.FStartIndex,range.FEndIndex]);
          write(Format('WARNING DROP RANGE REQUEST FOR NON FULLY RANGED DATA / PARTIAL DROP [%d..%d] Matching Range [%d..%d]',[start_idx,end_idx,range.FStartIndex,range.FEndIndex]));
          if not FRanges.RemoveUInt64Key(range.FStartIndex,dummy) then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent front cutoff/partial range [%d] ',[range.FStartIndex]);
          range.CropRangeFromStartTo(end_idx+1,dont_crop);
          if not FRanges.InsertUInt64Key(range.FStartIndex,FREDB_ObjectToPtrUInt(range)) then { insert range with new start index }
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id insert fail front cut off range/partial [%d] ',[range.FStartIndex]);
        end
      else
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected case DoOneRangeSplitOrRangeCutoff cut [%d..%d] range [%d..%d]',[start_idx,end_idx,range.FStartIndex,range.FEndIndex]);
    end;

    procedure DoRangeToRangeDrop(const sr,er : TFRE_DB_SESSION_DC_RANGE);
    var i      : NativeInt;
        ranges : Array of TFRE_DB_SESSION_DC_RANGE;
        rr     : TFRE_DB_SESSION_DC_RANGE;
        dummy  : PtrUInt;

      procedure RangeScan(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var dcounter,upcounter : NativeInt ; const abscntr : NativeInt);
      var r : TFRE_DB_SESSION_DC_RANGE;
      begin
        r         := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(value));
        ranges[i] := r;
        inc(i);
      end;

    begin
      i := 0;
      GFRE_DBI.LogDebug(dblc_DBTDMRM,'WARNING DROP REQUEST FOR NON FULLY RANGED DATA [%d..%d] Ranges ( %s )',[start_idx,end_idx,DumpRangesCompressd]);
      write(Format('WARNING DROP REQUEST FOR NON FULLY RANGED DATA [%d..%d] Ranges ( %s )',[start_idx,end_idx,DumpRangesCompressd]));

      if sr=nil then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'handle DoRangeToRangeDrop, sr not found');
      if er=nil then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'handle DoRangeToRangeDrop, er not found');

      SetLength(ranges,FRanges.GetValueCount);
      FRanges.RangeScanUint64Key(sr.FStartIndex,er.FStartIndex,@RangeScan);
      SetLength(ranges,i);
      if Length(ranges)<2 then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'a bridging range to range extend should have at least 2 ranges not [%d]',[Length(ranges)]);
      for i:=1 to high(ranges)-1 do { remove all bridging ranges except the firsta and last one ...}
       begin
         if not FRanges.RemoveUInt64Key(ranges[i].FStartIndex,dummy) then
           raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent droprange2range range [%d] ',[ranges[i].FStartIndex]);
         try
           if assigned(riter) then
             riter(ranges[i]);
         finally
           ranges[i].Free;
         end;
       end;

      rr := Ranges[0];
      if start_idx <= rr.FStartIndex then
        begin
          if not FRanges.RemoveUInt64Key(rr.FStartIndex,dummy) then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent droprange2range range [%d] ',[rr.FStartIndex]);
          rr.free;
        end
      else
      if start_idx > rr.FStartIndex  then
        begin
          rr.CropRangeFromEndTo(start_idx-1,dont_crop);
        end;

      rr := Ranges[high(ranges)];
      if (rr.FEndIndex<=end_idx) then
        begin
          if not FRanges.RemoveUInt64Key(rr.FStartIndex,dummy) then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent droprange2range range [%d] ',[rr.FStartIndex]);
          try
            if assigned(riter) then
              riter(rr);
          finally
            rr.free;
          end;
        end
      else
      if (rr.FEndIndex>end_idx) and (rr.FStartIndex<=end_idx) then
        begin
          if not FRanges.RemoveUInt64Key(rr.FStartIndex,dummy) then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id nonexistent droprange2range range [%d] ',[rr.FStartIndex]);
          rr.CropRangeFromStartTo(end_idx+1,dont_crop);
          if not FRanges.InsertUInt64Key(rr.FStartIndex,FREDB_ObjectToPtrUInt(rr)) then { insert range with new start index }
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal rangemgr fault/range id insert fail front cut off range [%d] ',[rr.FStartIndex]);
        end
    end;

    procedure SetLast(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
    var r : TFRE_DB_SESSION_DC_RANGE;
    begin
       r := TFRE_DB_SESSION_DC_RANGE(value);
       FEndInRangeID.rr  := r;
       FEndInRangeID.Rid := r.FStartIndex;
       FEndInRangeID.Six := r.FStartIndex;
       FEndInRangeID.Eix := r.FEndIndex;
       end_idx           := FEndInRangeID.Eix;
    end;

begin
  //GFRE_DBI.LogDebug(dblc_DBTDMRM,'ENTRY DELETE WARNING / DROP RANGE / TEST LOGGER');
  halt := false;
  CheckPartialRanges;
  FLastQryMaximalIndex := GetMaxIndex;
  if (FStartInRangeID.Rid=-1) and (FEndInRangeID.Rid=-1) then
    exit(rq_NO_DATA);
  if (FStartInRangeID.Rid>-1) and (FEndInRangeID.Rid=-1) then
    begin
      FRanges.LastKeyVal(@SetLast);
    end;
  if FStartInRangeID.Rid=FEndInRangeID.Rid then { One Range Split }
      DoOneRangeSplitOrRangeCutoff(FStartInRangeID.rr)
  else
      DoRangeToRangeDrop(FStartInRangeID.rr,FEndInRangeID.rr);
end;


procedure TFRE_DB_SESSION_DC_RANGE_MGR.TagForUpInsDelRLC(const TransID: TFRE_DB_TransStepId);
begin
  if not (pos('/',TransID)>0)  then
    raise EFRE_DB_Exception.Create(edb_ERROR,'must provide full tag');
  GFRE_DBI.LogDebug(dblc_DBTDM,'       >QRY MATCH UP/INS/DEL/CHILDCOUNTCHANGE TAG IN RMG [%s]',[RangemanagerKeyString]); //self
  FRMGTransTag := TransID;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.HandleTagged;
begin
  if FRMGTransTag<>'' then
    try
      GFRE_DBI.LogDebug(dblc_DBTDM,'  > PROCESSING TAGGED RMG [%S] TRANSID [%s]',[RangemanagerKeyString,FRMGTransTag]);
      ProcessFilterChangeBasedUpdates;
      GFRE_DBI.LogDebug(dblc_DBTDM,'  < PROCESSING TAGGED RMG [%S] TRANSID [%s] DONE',[RangemanagerKeyString,FRMGTransTag]);
    finally
      FRMGTransTag := '';
    end;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.ProcessChildObjCountChange(const obj: IFRE_DB_Object);
begin
  TagRangeMgrIfObjectIsInResultRanges(obj.UID,obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString);
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.ProcessFilterChangeBasedUpdates;
var newlastidx : NativeInt;
    calcedlast : NativeInt;
    lastrange  : TFRE_DB_SESSION_DC_RANGE;
    lastlast   : NativeInt;

  procedure DoRunRanges(const r : TFRE_DB_SESSION_DC_RANGE ; var halt:boolean);
  begin
    r.RangeProcessFilterChangeBasedUpdates(GetSessionID,GetStoreID,FRMFiltercont.OrderKey,lastlast,calcedlast);
  end;

  procedure DoCompare;
  begin
    ForAllRanges(@DoRunRanges);
  end;

  procedure DropRangeDataCallback(const r : TFRE_DB_SESSION_DC_RANGE);
  begin
    r.RangeProcessFilterChangeBasedUpdates(GetSessionID,GetStoreID,FRMFiltercont.OrderKey,lastlast,calcedlast);
  end;

begin
  //DoCompare; { first do the compare, then check for range changes } //self
  //if FRMGRKey.DataKey.DC_Name<>'PRODUCT_MODULESIN_GRID'
  //  then exit;
  newlastidx := FRMFiltercont.GetDataCount-1;
  lastlast   := FLastQryMaximalIndex;
  lastrange  := GetLastRange;
  if assigned(lastrange) then
    begin
      if newlastidx>lastlast then
        begin
          if lastrange.EndIndex=lastlast then  { check if the last range "touches" the "old" END then extend last range }
            FindRangeSatisfyingQuery(lastrange.StartIndex,newlastidx,lastrange,true); { only if the lastidx was in the endrange and only extend to the end ... FStartidx must remain correct(!), FLastQryMax gets adjusted}
        end
      else
      if newlastidx<lastlast then  { reduce qry / drop range }
        DropRange(newlastidx+1,lastlast,true,@DropRangeDataCallback); { newlastidx should stay in range :-),  need to update (=delete) all dropped ranges -> client, FLastQryMax gets adjusted }
      DoCompare;
    end
  else
    begin { no lastrange found, so open up a new range with default entrys (26) }
      case FindRangeSatisfyingQuery(0,25,lastrange,true) of
        rq_Bad: ;
        rq_OK:
          begin
            DoCompare;
          end;
        rq_NO_DATA: ;
      end;
    end;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.GetLastRange: TFRE_DB_SESSION_DC_RANGE;

    procedure SetLast(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
    begin
      result := TFRE_DB_SESSION_DC_RANGE(FREDB_PtrUIntToObject(value));
    end;

begin
  result := nil;
  FRanges.LastKeyVal(@SetLast);
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.RangemanagerKeyString: TFRE_DB_CACHE_DATA_KEY;
begin
  result := FRMK.GetRmKeyAsString;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.GetStoreID: TFRE_DB_NameType;
begin
  result := FRMK.DataKey.DC_Name;
end;

function TFRE_DB_SESSION_DC_RANGE_MGR.GetSessionID: TFRE_DB_SESSION_ID;
begin
  result := FRMK.SessionID;
end;

procedure TFRE_DB_SESSION_DC_RANGE_MGR.CheckQuerySpecAndClearIfNeeded(const qryid: TFRE_DB_SESSION_DC_RANGE_MGR_KEY);
var s1,s2 : TFRE_DB_CACHE_DATA_KEY;
begin
  s1 := qryid.GetFullKeyString;
  s2 := self.FRMK.GetFullKeyString;
  if s1<>s2 then { The keys differ -> clean all ranges, remove filter binding }
    begin
      ClearRanges;
      FRMK := qryid;
    end;
end;

{ TFRE_DB_TRANSDATA_CHANGE_NOTIFIER }

function TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.GetSessionUPO(const sessionid : TFRE_DB_NameType): TFRE_DB_SESSION_UPO;
begin
  result := FSessionUpdateList.Find(sessionid) as TFRE_DB_SESSION_UPO;
  if not assigned(result) then
    begin
      result := TFRE_DB_SESSION_UPO.Create(sessionid);
      FSessionUpdateList.Add(sessionid,result);
    end;
end;

constructor TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.Create(const key: TFRE_DB_TransStepId);
begin
  FSessionUpdateList := TFPHashObjectList.Create(true);
  FKey               := key;
end;

procedure TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.AddDirectSessionUpdateEntry(const update_dbo: IFRE_DB_Object);
var halt : boolean;
  //procedure AllSessions
begin
  halt := false;
  { todo session should register update dbo's here ...}
  //GFRE_DBI.NetServ.ForAllSessionsLocked(@AllSessions,halt);
end;

procedure TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.AddGridInplaceUpdate(const sessionid: TFRE_DB_NameType; const store_id, store_id_dc: TFRE_DB_String; const upo: IFRE_DB_Object; const oldpos, newpos, abscount: NativeInt);
begin
  GetSessionUPO(sessionid).AddStoreUpdate(store_id,store_id_dc,upo,oldpos,newpos,abscount);
end;

procedure TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.AddGridInsertUpdate(const sessionid: TFRE_DB_NameType; const store_id, store_id_dc: TFRE_DB_String; const upo: IFRE_DB_Object; const position, abscount: NativeInt);
begin
  GetSessionUPO(sessionid).AddStoreInsert(store_id,store_id_dc,upo,position,abscount);
end;

procedure TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.AddGridRemoveUpdate(const sessionid: TFRE_DB_NameType; const store_id, store_id_dc: TFRE_DB_String; const del_id: TFRE_DB_String; const position, abscount: NativeInt);
begin
  GetSessionUPO(sessionid).AddStoreDelete(store_id,store_id_dc,del_id,position,abscount);
end;

procedure TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.NotifyAll;
var i    : NativeInt;
    supo : TFRE_DB_SESSION_UPO;
begin
  for i  := 0 to FSessionUpdateList.Count-1 do
   begin
     supo := FSessionUpdateList.Items[i] as TFRE_DB_SESSION_UPO;
     supo.cs_SendUpdatesToSession;
   end;
end;

{ TFRE_DB_FILTER_CHILD }

function TFRE_DB_FILTER_CHILD.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_CHILD;
begin
  fClone                := TFRE_DB_FILTER_CHILD.Create(FKey);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_CHILD.GetDefinitionKey: TFRE_DB_NameType;
begin
  result := 'CF';
end;

function TFRE_DB_FILTER_CHILD.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
begin
  result := TFRE_DB_TRANSFORM_UTIL_DATA(ud).ObjectIsInParentPath(''); //  { is root (no parent) in array ?}
end;

procedure TFRE_DB_FILTER_CHILD.InitFilter;
begin

end;

{ TFRE_DB_FILTER_PARENT }

function TFRE_DB_FILTER_PARENT.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_PARENT;
begin
  fClone                := TFRE_DB_FILTER_PARENT.Create(FKey);
  fClone.FAllowedParent := FAllowedParent;
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;


function TFRE_DB_FILTER_PARENT.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : NativeInt;
begin
  hsh := GFRE_BT.HashFast32(@FAllowedParent[1],length(FAllowedParent),0);
  result := 'PF:'+ GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_PARENT.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
begin
  //result := FREDB_PP_ObjectInParentPath(obj,FAllowedParent);
  result := TFRE_DB_TRANSFORM_UTIL_DATA(ud).ObjectIsInParentPath(FAllowedParent);
end;

procedure TFRE_DB_FILTER_PARENT.InitFilter(const allowed_parent_path: TFRE_DB_String);
begin
  //FAllowedParent := FREDB_G2H(allowed_parent_path[0]); { currently only the immediate parent is used (client restriction) }
  FAllowedParent := allowed_parent_path;
end;

{ TFRE_DB_FILTER_REAL64 }

function TFRE_DB_FILTER_REAL64.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_REAL64;
begin
  fClone                := TFRE_DB_FILTER_REAL64.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_REAL64.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i],SizeOf(QWord),hsh);
  result := 'R:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_REAL64.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var multivalfield : boolean;
    fieldval      : Double;
    fieldisnull   : boolean;
    fielmismatch  : boolean;
    error_fld     : boolean;
    fld           : IFRE_DB_Field;

  procedure DoInBounds;
  var lbnd,ubnd : Double;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not((fieldval>lbnd) and (fieldval<ubnd));
  end;

  procedure DoWithBounds;
  var lbnd,ubnd : Double;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not((fieldval>=lbnd) and (fieldval<=ubnd));
  end;

  procedure AllValues;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure OneValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure NoValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

begin
  error_fld := false;
  if TFRE_DB_TRANSFORM_UTIL_DATA(ud).GetObj.FieldOnlyExisting(FFieldname,fld) then
    begin
      multivalfield := fld.ValueCount>1;
      try
        fieldval      := fld.AsReal64;
        case FFilterType of
          dbnf_EXACT:                result := not(fieldval= FValues[0]);
          dbnf_LESSER:               result := not(fieldval< FValues[0]);
          dbnf_LESSER_EQ:            result := not(fieldval<=FValues[0]);
          dbnf_GREATER:              result := not(fieldval> FValues[0]);
          dbnf_GREATER_EQ:           result := not(fieldval>=FValues[0]);
          dbnf_IN_RANGE_EX_BOUNDS:   DoInBounds;
          dbnf_IN_RANGE_WITH_BOUNDS: DoWithBounds;
          dbnf_AllValuesFromFilter:  AllValues;
          dbnf_OneValueFromFilter:   OneValue;
          dbnf_NoValueInFilter:      NoValue;
        end;
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := FAllowNull;
  result := (result xor FNegate) or error_fld; { invert result, or filter error results }
end;

procedure TFRE_DB_FILTER_REAL64.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of Double; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFilterType := numfiltertype;
  FNegate     := negate;
  FAllowNull  := include_null_values;
  case numfiltertype of
    dbnf_EXACT,
    dbnf_LESSER,
    dbnf_LESSER_EQ,
    dbnf_GREATER,
    dbnf_GREATER_EQ:
      if Length(filtervalues)<>1 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the real64 filter with numfiltertype %s, needs exactly one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_IN_RANGE_EX_BOUNDS,
    dbnf_IN_RANGE_WITH_BOUNDS:
      if Length(filtervalues)<>2 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the real64 filter with numfiltertype %s, needs exactly two bounding values',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_AllValuesFromFilter,
    dbnf_NoValueInFilter,
    dbnf_OneValueFromFilter:
      if Length(filtervalues)=0 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the real64 filter with numfiltertype %s, needs at least one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
  end;
end;

{ TFRE_DB_FILTER_DATETIME }

function TFRE_DB_FILTER_DATETIME.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_DATETIME;
begin
  fClone                := TFRE_DB_FILTER_DATETIME.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_DATETIME.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i],SizeOf(QWord),hsh);
  result := 'D:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_DATETIME.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var multivalfield : boolean;
    fieldval      : TFRE_DB_DateTime64;
    fieldisnull   : boolean;
    fielmismatch  : boolean;
    error_fld     : boolean;
    fld           : IFRE_DB_Field;

  procedure DoInBounds;
  var lbnd,ubnd : TFRE_DB_DateTime64;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not((fieldval>lbnd) and (fieldval<ubnd));
  end;

  procedure DoWithBounds;
  var lbnd,ubnd : TFRE_DB_DateTime64;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not((fieldval>=lbnd) and (fieldval<=ubnd));
  end;

  procedure AllValues;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure OneValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure NoValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;


begin
  error_fld := false;
  if ud.GetObj.FieldOnlyExisting(FFieldname,fld) then
    begin
      multivalfield := fld.ValueCount>1;
      try
        fieldval      := fld.AsDateTimeUTC;
        case FFilterType of
          dbnf_EXACT:                result := not(fieldval= FValues[0]);
          dbnf_LESSER:               result := not(fieldval< FValues[0]);
          dbnf_LESSER_EQ:            result := not(fieldval<=FValues[0]);
          dbnf_GREATER:              result := not(fieldval> FValues[0]);
          dbnf_GREATER_EQ:           result := not(fieldval>=FValues[0]);
          dbnf_IN_RANGE_EX_BOUNDS:   DoInBounds;
          dbnf_IN_RANGE_WITH_BOUNDS: DoWithBounds;
          dbnf_AllValuesFromFilter:  AllValues;
          dbnf_OneValueFromFilter:   OneValue;
          dbnf_NoValueInFilter:      NoValue;
        end;
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := FAllowNull;
  result := (result xor FNegate) or error_fld; { invert result, or filter error results }
end;

procedure TFRE_DB_FILTER_DATETIME.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of TFRE_DB_DateTime64; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFilterType := numfiltertype;
  FNegate     := negate;
  FAllowNull  := include_null_values;
  case numfiltertype of
    dbnf_EXACT,
    dbnf_LESSER,
    dbnf_LESSER_EQ,
    dbnf_GREATER,
    dbnf_GREATER_EQ:
      if Length(filtervalues)<>1 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the datetime filter with numfiltertype %s, needs exactly one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_IN_RANGE_EX_BOUNDS,
    dbnf_IN_RANGE_WITH_BOUNDS:
      if Length(filtervalues)<>2 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the datetime filter with numfiltertype %s, needs exactly two bounding values',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_AllValuesFromFilter,
    dbnf_NoValueInFilter,
    dbnf_OneValueFromFilter:
      if Length(filtervalues)=0 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the datetime filter with numfiltertype %s, needs at least one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
  end;
end;

{ TFRE_DB_FILTER_CURRENCY }

function TFRE_DB_FILTER_CURRENCY.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_CURRENCY;
begin
  fClone                := TFRE_DB_FILTER_CURRENCY.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_CURRENCY.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i],SizeOf(QWord),hsh);
  result := 'C:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_CURRENCY.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var multivalfield : boolean;
    fieldval      : Currency;
    fieldisnull   : boolean;
    fielmismatch  : boolean;
    error_fld     : boolean;
    fld           : IFRE_DB_Field;

  procedure DoInBounds;
  var lbnd,ubnd : Currency;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not((fieldval>lbnd) and (fieldval<ubnd));
  end;

  procedure DoWithBounds;
  var lbnd,ubnd : Currency;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not((fieldval>=lbnd) and (fieldval<=ubnd));
  end;

  procedure AllValues;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure OneValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure NoValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

begin
  error_fld := false;
  if ud.GetObj.FieldOnlyExisting(FFieldname,fld) then
    begin
      multivalfield := fld.ValueCount>1;
      try
        fieldval      := fld.AsCurrency;
        case FFilterType of
          dbnf_EXACT:                result := not(fieldval= FValues[0]);
          dbnf_LESSER:               result := not(fieldval< FValues[0]);
          dbnf_LESSER_EQ:            result := not(fieldval<=FValues[0]);
          dbnf_GREATER:              result := not(fieldval> FValues[0]);
          dbnf_GREATER_EQ:           result := not(fieldval>=FValues[0]);
          dbnf_IN_RANGE_EX_BOUNDS:   DoInBounds;
          dbnf_IN_RANGE_WITH_BOUNDS: DoWithBounds;
          dbnf_AllValuesFromFilter:  AllValues;
          dbnf_OneValueFromFilter:   OneValue;
          dbnf_NoValueInFilter:      NoValue;
      end;
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := FAllowNull;
  result := (result xor FNegate) or error_fld; { invert result, or filter error results }
end;

procedure TFRE_DB_FILTER_CURRENCY.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of Currency ; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFilterType := numfiltertype;
  FNegate     := negate;
  FAllowNull  := include_null_values;
  case numfiltertype of
    dbnf_EXACT,
    dbnf_LESSER,
    dbnf_LESSER_EQ,
    dbnf_GREATER,
    dbnf_GREATER_EQ:
      if Length(filtervalues)<>1 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the currency filter with numfiltertype %s, needs exactly one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_IN_RANGE_EX_BOUNDS,
    dbnf_IN_RANGE_WITH_BOUNDS:
      if Length(filtervalues)<>2 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the currency filter with numfiltertype %s, needs exactly two bounding values',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_AllValuesFromFilter,
    dbnf_NoValueInFilter,
    dbnf_OneValueFromFilter:
      if Length(filtervalues)=0 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the currency filter with numfiltertype %s, needs at least one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
  end;
end;

{ TFRE_DB_FILTER_RIGHT }

function TFRE_DB_FILTER_RIGHT.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_RIGHT;
begin
  fClone                   := TFRE_DB_FILTER_RIGHT.Create(FKey);
  fClone.FRight            := FRight;
  fClone.FNegate           := FNegate;
  fClone.FUserTokenClone   := FUserTokenClone;
  fClone.FDomIDField       := FDomIDField;
  fClone.FSchemeclass      := FSchemeClass;
  fClone.FMode             := FMode;
  fClone.FSchemeClassField := FSchemeClassField;
  fClone.FObjUidField      := FObjUidField;
  fClone.FDomIDField       := FDomIDField;
  fClone.FRightSet         := copy(FRightSet);
  fClone.FIgnoreField      := FIgnoreField;
  fClone.FIgnoreValue      := FIgnoreValue;
  fClone.FOnlyRootNodes    := FOnlyRootNodes;
  result                   := fClone;
end;

function TFRE_DB_FILTER_RIGHT.GetDefinitionKey: TFRE_DB_NameType;
var hsh : cardinal;
      i : NativeInt;
begin
  result :='';
  if sr_STORE in FRight then
    result:=result+'S';
  if sr_UPDATE in FRight then
    result:=result+'U';
  if sr_FETCH in FRight then
    result:=result+'F';
  if sr_DELETE in FRight then
    result:=result+'D';
  if FNegate then
    result:=result+'1'
  else
    result:=result+'0';
  result := result+inttostr(ord(FMode))+':'+FSchemeclass+'-'+FDomIDField+'-'+FObjUidField+'-'+FSchemeClassField+':'+FUserTokenClone.GetUniqueTokenKey+'.'+FIgnoreField+'.'+FIgnoreValue;
  hsh := GFRE_BT.HashFast32(@result[1],length(result),0);
  for i:= 0 to high(FRightSet) do
    hsh := GFRE_BT.HashFast32(@FRightSet[i][1],Length(FRightSet[i]),hsh);
  result := 'Z:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_RIGHT.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var cn     : ShortString;
    fld    : IFRE_DB_Field;
    ivalue : TFRE_DB_String;

    function ReferedDomainCheck(const std : boolean):boolean;
    var domid  : TFRE_DB_GUID;
        objuid : TFRE_DB_GUID;
    begin
      try
        if (FDomIDField<>'') and ud.GetObj.FieldOnlyExisting(FDomIDField,fld) then
          domid :=  fld.AsGUID
        else
          domid := CFRE_DB_NullGUID; { skip domain right tests to false (no right)}
        if (FObjUidField<>'') and ud.GetObj.FieldOnlyExisting(FObjUidField,fld) then
          objuid := fld.AsGUID
        else
          objuid := CFRE_DB_NullGUID; { skip object right tests to false (no right)}
        if (FSchemeClassField<>'') then
          FSchemeclass := uppercase(ud.GetObj.Field(FSchemeClassField).AsString);
        if std then
          result := FUserTokenClone.CheckStdRightSetUIDAndClass(objuid,domid,FSchemeclass,FRight)<>edb_OK { use negative (!) check in filters }
        else
          result := FUserTokenClone.CheckGenRightSetUIDAndClass(objuid,domid,FSchemeclass,FRightSet)<>edb_OK; { use negative (!) check in filters }
      except
        inc(flt_errors);
        result := true;
      end;
    end;

    function ObjectRightcheck:boolean;
    begin
      cn := ud.PreTransformedScheme;
      result := FUserTokenClone.CheckStdRightSetUIDAndClass(ud.GetObj.UID,ud.GetObj.DomainID,cn,FRight)<>edb_OK;
    end;

    function ObjectRightcheckGeneric:boolean;
    begin
      cn := ud.PreTransformedScheme;
      result := FUserTokenClone.CheckGenRightSetUIDAndClass(ud.GetObj.UID,ud.GetObj.DomainID,cn,FRightSet)<>edb_OK;
    end;


begin
  if (FIgnoreValue<>'') and ud.GetObj.FieldOnlyExisting(FIgnoreField,fld) then
    begin
      try
        if FIgnoreValue=fld.AsString then
          exit(true); { do not respect negate }
      except
        inc(flt_errors);
        result := true; { get's negated }
      end;
    end;
  case FMode of
    fm_ObjectRightFilter:
      result := ObjectRightcheck;
    fm_ReferedRightFilter:
      result := ReferedDomainCheck(true);
    fm_ObjectRightFilterGeneric:
      result := ObjectRightcheckGeneric;
    fm_ReferedRightFilterGeneric:
      result := ReferedDomainCheck(false);
  end;
  result := (result xor FNegate); { invert result }
end;

procedure TFRE_DB_FILTER_RIGHT.InitFilter(stdrightset: TFRE_DB_STANDARD_RIGHT_SET; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreFieldname, ignoreFieldValue: TFRE_DB_String);
begin
  if stdrightset=[] then
    raise EFRE_DB_Exception.Create(edb_ERROR,'at least one right must be specified for the filter');
  if not assigned(usertoken) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'a usertoken must be specified for the filter');
  FRight          := stdrightset;
  FUserTokenClone := usertoken;
  FNegate         := negate;
  FMode           := fm_ObjectRightFilter;
  FIgnoreField    := ignoreFieldname;
  FIgnoreValue    := ignoreFieldValue;
end;

procedure TFRE_DB_FILTER_RIGHT.InitFilterRefered(domainidfield, objuidfield, schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType; stdrightset: TFRE_DB_STANDARD_RIGHT_SET; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreFieldname, ignoreFieldValue: TFRE_DB_String);
begin
  if stdrightset=[] then
    raise EFRE_DB_Exception.Create(edb_ERROR,'at least one right must be specified for the filter');
  if not assigned(usertoken) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'a usertoken must be specified for the filter');
  FRight            := stdrightset;
  FUserTokenClone   := usertoken;
  FNegate           := negate;
  FMode             := fm_ReferedRightFilter;
  FSchemeclass      := schemeclass;
  FDomIDField       := domainidfield;
  FObjUidField      := objuidfield;
  FSchemeClassField := schemeclassfield;
  FIgnoreField      := ignoreFieldname;
  FIgnoreValue      := ignoreFieldValue;
end;

procedure TFRE_DB_FILTER_RIGHT.InitFilterGenRights(const stdrightset: array of TFRE_DB_String; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreFieldname, ignoreFieldValue: TFRE_DB_String);
var i : NativeInt;
begin
  if Length(stdrightset)=0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'at least one right must be specified for the filter');
  SetLength(FRightSet,Length(stdrightset));
  for i := 0 to high(stdrightset) do
    FRightSet[i] := stdrightset[i];
  if not assigned(usertoken) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'a usertoken must be specified for the filter');
  FRight          := [];
  FUserTokenClone := usertoken;
  FNegate         := negate;
  FMode           := fm_ObjectRightFilterGeneric;
  FIgnoreField    := ignoreFieldname;
  FIgnoreValue    := ignoreFieldValue;
end;

procedure TFRE_DB_FILTER_RIGHT.InitFilterGenRightsRefrd(const domainidfield, objuidfield, schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType; stdrightset: array of TFRE_DB_String; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreFieldname, ignoreFieldValue: TFRE_DB_String);
var i : NativeInt;
begin
  if Length(stdrightset)=0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'at least one right must be specified for the filter');
  SetLength(FRightSet,Length(stdrightset));
  for i := 0 to high(stdrightset) do
    FRightSet[i] := stdrightset[i];
  if not assigned(usertoken) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'a usertoken must be specified for the filter');
  FRight            := [];
  FUserTokenClone   := usertoken;
  FNegate           := negate;
  FMode             := fm_ReferedRightFilterGeneric;
  FSchemeclass      := schemeclass;
  FDomIDField       := domainidfield;
  FObjUidField      := objuidfield;
  FSchemeClassField := schemeclassfield;
  FIgnoreField      := ignoreFieldname;
  FIgnoreValue      := ignoreFieldValue;
end;


{ TFRE_DB_FILTER_SCHEME }

function TFRE_DB_FILTER_SCHEME.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_SCHEME;
begin
  fClone                := TFRE_DB_FILTER_SCHEME.Create(FKey);
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := False;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_SCHEME.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var
  cn: ShortString;
  i : NativeInt;
begin
  cn := ud.PreTransformedScheme;
  result := true;
  for i:= 0 to high(FValues) do begin //self
    if cn=FValues[i] then begin
      Result:=false;
      break;
    end;
  end;
  result := (result xor FNegate); { invert result }
end;

function TFRE_DB_FILTER_SCHEME.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(nil,0,0);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i][1],Length(FValues[i]),hsh);
  result := 'X:'+GFRE_BT.Mem2HexStr(@hsh,4)+BoolToStr(FNegate,'1','0');
end;

procedure TFRE_DB_FILTER_SCHEME.InitFilter(filtervalues: array of TFRE_DB_String; const negate: boolean);
var i:integer;
begin
  if Length(filtervalues)=0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'at least one scheme must be specified for the filter');
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := UpperCase(filtervalues[i]);
  FNegate     := negate;
end;

{ TFRE_DB_FILTER_UID }

function TFRE_DB_FILTER_UID.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_UID;
begin
  fClone                := TFRE_DB_FILTER_UID.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_UID.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var fieldvals      : TFRE_DB_GUIDArray;
     fld           : IFRE_DB_Field;
     error_fld     : boolean;
     i,j           : NativeInt;
     notcontained  : Boolean;
begin
  error_fld := false;
  if ud.GetObj.FieldOnlyExisting(FFieldname,fld) then
    begin
      try
        if fld.AsString='' then begin
          fieldvals     := TFRE_DB_GUIDArray.create;
        end else begin
          fieldvals     := fld.AsGUIDArr;
        end;
        case FFilterType of
          dbnf_EXACT:               { all fieldvalues and filtervalues must be the same in the same order }
            begin
              result := false;
              if Length(fieldvals) <> Length(FValues) then
                begin
                  result:=true;
                end
              else
                for i:=0 to high(FValues) do
                  if not FREDB_Guids_Same(fieldvals[i],FValues[i]) then
                    begin
                      result:=true;
                      break;
                    end;
            end;
          dbnf_OneValueFromFilter:
            begin
              result := true; {negate=false, result=false => display=false // negate=true, result=false => display=true}
              for i:=0 to high(fieldvals) do
               for j:=0 to high(FValues) do
                 if FREDB_Guids_Same(fieldvals[i],FValues[j]) then
                   begin
                     result := false;
                     break;
                   end;
            end;
          dbnf_NoValueInFilter:
            begin
                result := false;
                 for j:=0 to high(FValues) do
                  for i:=0 to high(fieldvals) do
                   if FREDB_Guids_Same(fieldvals[i],FValues[j]) then
                     begin
                       result := true;
                       break;
                     end;
            end;
          dbnf_AllValuesFromFilter: { all fieldvalues must be in filter}
            begin
              result := false;
              if Length(fieldvals) <> Length(FValues) then
                begin
                  result:=true;
                end
              else
                for j:=0 to high(FValues) do begin
                 notcontained:=true;
                 for i:=0 to high(fieldvals) do
                  if FREDB_Guids_Same(fieldvals[i],FValues[j]) then
                    begin
                      notcontained:=false;
                      break;
                    end;
                  if notcontained then begin
                    result:=true;
                    break;
                  end;
                end;
            end;
        end;
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := FAllowNull;
  result := (result xor fnegate) or error_fld; { invert result, or filter error results }
end;

function TFRE_DB_FILTER_UID.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(nil,0,0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i],SizeOf(TFRE_DB_GUID),hsh);
  result := 'G:'+ GFRE_BT.Mem2HexStr(@hsh,4);
end;

procedure TFRE_DB_FILTER_UID.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of TFRE_DB_GUID; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean; const only_root_nodes:Boolean);
var i:integer;
begin
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFieldname    := fieldname;
  FFilterType   := numfiltertype;
  FNegate       := negate;
  FAllowNull    := include_null_values;
  FOnlyRootNodes:= only_root_nodes;
  case numfiltertype of
    dbnf_EXACT:
      if Length(filtervalues)<>1 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the uid filter with numfiltertype %s, needs exactly one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_AllValuesFromFilter,
    dbnf_OneValueFromFilter: ; { empty array is allowed }
    dbnf_NoValueInFilter: ; { empty array is allowed }
    dbnf_LESSER,
    dbnf_LESSER_EQ,
    dbnf_GREATER,
    dbnf_GREATER_EQ,
    dbnf_IN_RANGE_EX_BOUNDS,
    dbnf_IN_RANGE_WITH_BOUNDS:
        raise EFRE_DB_Exception.Create(edb_ERROR,'the uid filter does not support numfiltertype %s',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
  end;
end;

{ TFRE_DB_FILTER_BOOLEAN }

function TFRE_DB_FILTER_BOOLEAN.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_BOOLEAN;
begin
  fClone                := TFRE_DB_FILTER_BOOLEAN.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValue         := FValue;
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_BOOLEAN.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var fieldval       : boolean;
     fld           : IFRE_DB_Field;
     multivalfield : boolean;
     error_fld     : boolean;
begin
  error_fld := false;
  if ud.GetObj.FieldOnlyExisting(FFieldname,fld) then
    begin
      multivalfield := fld.ValueCount>1;
      try
        fieldval      := fld.AsBoolean;
        result        := not(fieldval=FValue);
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := not FAllowNull;
  result := (result xor FNegate) or error_fld; { invert result, or filter error results }
end;

function TFRE_DB_FILTER_BOOLEAN.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[8];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FValue,'1','0')+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  result := 'B:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

procedure TFRE_DB_FILTER_BOOLEAN.InitFilter(const fieldname: TFRE_DB_NameType; const value: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  FValue      := value;
  FNegate     := false;
  FAllowNull  := include_null_values;
end;

{ TFRE_DB_FILTER_UNSIGNED }

function TFRE_DB_FILTER_UNSIGNED.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_UNSIGNED;
begin
  fClone                 := TFRE_DB_FILTER_UNSIGNED.Create(FKey);
  fClone.FFieldname      := FFieldname;
  fClone.FNegate         := FNegate;
  fClone.FAllowNull      := FAllowNull;
  fClone.FFilterType     := FFilterType;
  fClone.FValues         := Copy(FValues);
  fClone.FOnlyRootNodes  := FOnlyRootNodes;
  result                 := fClone;
end;

function TFRE_DB_FILTER_UNSIGNED.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i],SizeOf(QWord),hsh);
  result := 'U:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_UNSIGNED.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
begin
  result := false;
  inc(flt_errors); // Unsigned Filter not implemented
end;

procedure TFRE_DB_FILTER_UNSIGNED.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of UInt64; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFilterType := numfiltertype;
  FNegate     := negate;
  FAllowNull  := include_null_values;
  case numfiltertype of
    dbnf_EXACT,
    dbnf_LESSER,
    dbnf_LESSER_EQ,
    dbnf_GREATER,
    dbnf_GREATER_EQ:
      if Length(filtervalues)<>1 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the unsigned filter with numfiltertype %s, needs exactly one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_IN_RANGE_EX_BOUNDS,
    dbnf_IN_RANGE_WITH_BOUNDS:
      if Length(filtervalues)<>2 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the unsigned filter with numfiltertype %s, needs exactly two bounding values',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_AllValuesFromFilter,
    dbnf_NoValueInFilter,
    dbnf_OneValueFromFilter:
      if Length(filtervalues)=0 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the unsigned filter with numfiltertype %s, needs at least one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
  end;
end;

{ TFRE_DB_FILTER_SIGNED }

function TFRE_DB_FILTER_SIGNED.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_SIGNED;
begin
  fClone                := TFRE_DB_FILTER_SIGNED.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_SIGNED.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[6];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_NUM_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i],SizeOf(int64),hsh);
  result := 'S:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_SIGNED.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var multivalfield : boolean;
    fieldval      : int64;
    fieldisnull   : boolean;
    fielmismatch  : boolean;
    error_fld     : boolean;
    fld           : IFRE_DB_Field;

  procedure DoInBounds;
  var lbnd,ubnd : int64;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not ((fieldval>lbnd) and (fieldval<ubnd));
  end;

  procedure DoWithBounds;
  var lbnd,ubnd : int64;
  begin
    lbnd   := FValues[0];
    ubnd   := FValues[1];
    result := not ((fieldval>=lbnd) and (fieldval<=ubnd));
  end;

  procedure AllValues;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure NoValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

  procedure OneValue;
  begin
    error_fld:=true;
    inc(flt_errors); { not implemented }
  end;

begin
  error_fld := false;
  if ud.GetObj.FieldOnlyExisting(FFieldname,fld) then
    begin
      multivalfield := fld.ValueCount>1;
      try
        fieldval      := fld.AsInt64;
        case FFilterType of
          dbnf_EXACT:                result := not (fieldval= FValues[0]);
          dbnf_LESSER:               result := not (fieldval< FValues[0]);
          dbnf_LESSER_EQ:            result := not (fieldval<=FValues[0]);
          dbnf_GREATER:              result := not (fieldval> FValues[0]);
          dbnf_GREATER_EQ:           result := not (fieldval>=FValues[0]);
          dbnf_IN_RANGE_EX_BOUNDS:   DoInBounds;
          dbnf_IN_RANGE_WITH_BOUNDS: DoWithBounds;
          dbnf_AllValuesFromFilter:  AllValues;
          dbnf_OneValueFromFilter:   OneValue;
          dbnf_NoValueInFilter:      NoValue;
        end;
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := FAllowNull;
  result := (result xor FNegate) or error_fld; { invert result, or filter error results }
end;

procedure TFRE_DB_FILTER_SIGNED.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of Int64; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFilterType := numfiltertype;
  FNegate     := negate;
  FAllowNull  := include_null_values;
  case numfiltertype of
    dbnf_EXACT,
    dbnf_LESSER,
    dbnf_LESSER_EQ,
    dbnf_GREATER,
    dbnf_GREATER_EQ:
      if Length(filtervalues)<>1 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the signed filter with numfiltertype %s, needs exactly one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_IN_RANGE_EX_BOUNDS,
    dbnf_IN_RANGE_WITH_BOUNDS:
      if Length(filtervalues)<>2 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the signed filter with numfiltertype %s, needs exactly two bounding values',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
    dbnf_AllValuesFromFilter,
    dbnf_NoValueInFilter,
    dbnf_OneValueFromFilter:
      if Length(filtervalues)=0 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'the signed filter with numfiltertype %s, needs at least one value',[CFRE_DB_NUM_FILTERTYPE[numfiltertype]]);
  end;
end;

{ TFRE_DB_FILTER_STRING }

function TFRE_DB_FILTER_STRING.Clone: TFRE_DB_FILTER_BASE;
var fClone : TFRE_DB_FILTER_STRING;
begin
  fClone                := TFRE_DB_FILTER_STRING.Create(FKey);
  fClone.FFieldname     := FFieldname;
  fClone.FNegate        := FNegate;
  fClone.FAllowNull     := FAllowNull;
  fClone.FFilterType    := FFilterType;
  fClone.FValues        := Copy(FValues);
  fClone.FOnlyRootNodes := FOnlyRootNodes;
  result                := fClone;
end;

function TFRE_DB_FILTER_STRING.GetDefinitionKey: TFRE_DB_NameType;
var  hsh : cardinal;
     i   : Integer;
     scr : String[4];
begin
  hsh := GFRE_BT.HashFast32(@FFieldname[1],Length(FFieldname),0);
  scr := CFRE_DB_STR_FILTERTYPE[FFilterType]+BoolToStr(FNegate,'1','0')+BoolToStr(FAllowNull,'1','0');
  hsh := GFRE_BT.HashFast32(@scr[1],Length(scr),hsh);
  for i:= 0 to high(FValues) do
    hsh := GFRE_BT.HashFast32(@FValues[i][1],Length(FValues[i]),hsh);
  result := 'T:'+GFRE_BT.Mem2HexStr(@hsh,4);
end;

function TFRE_DB_FILTER_STRING.CheckFilterMiss(const ud: TFRE_DB_TRANSFORM_UTIL_DATA_BASE; var flt_errors: Int64): boolean;
var fieldval       : TFRE_DB_String;
     fld           : IFRE_DB_Field;
     multivalfield : boolean;
     error_fld     : boolean;
     filterVal     : TFRE_DB_String;
     i             : Integer;
begin
  error_fld := false;
  filterVal := FValues[0];

  if ud.GetObj.FieldOnlyExisting(FFieldname,fld) then  // self.FFieldname;
    begin
      multivalfield := fld.ValueCount>1;
      try
        fieldval      := fld.AsString;
        case FFilterType of
          dbft_EXACT:      result := not (((length(fieldval)=0) or FOS_AnsiContainsText(fieldval,filterVal)) and (length(fieldval)=length(filterVal)));
          dbft_PART:       result := not FOS_AnsiContainsText(fieldval,filterVal);
          dbft_STARTPART:  result := not FOS_AnsiStartsText  (filterVal,fieldval);
          dbft_ENDPART:    result := not FOS_AnsiEndsText    (filterVal,fieldval);
          dbft_EXACTVALUEINARRAY:
            begin
              Result:=true;
              for i := 0 to fld.ValueCount - 1 do begin
                fieldval      := fld.AsStringItem[i];
                if (((length(fieldval)=0) or FOS_AnsiContainsText(fieldval,filterVal)) and (length(fieldval)=length(filterVal))) then begin
                  Result:=false;
                  break;
                end;
              end;
            end;
        end;
      except { invalid conversion }
        error_fld := true;
        inc(flt_errors);
      end;
    end
  else { fld is null }
    result := FAllowNull;
  result := (result xor FNegate) or error_fld; { invert result, or filter error results }
end;

procedure TFRE_DB_FILTER_STRING.InitFilter(const fieldname: TFRE_DB_NameType; filtervalues: array of TFRE_DB_String; const stringfiltertype: TFRE_DB_STR_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var i:integer;
begin
  FFieldname  := fieldname;
  SetLength(FValues,length(filtervalues));
  for i:=0 to high(filtervalues) do
    FValues[i] := filtervalues[i];
  FFilterType := stringfiltertype;
  FNegate     := negate;
  FAllowNull  := include_null_values;
end;

{ TFRE_DB_FILTER_CONTAINER }

procedure TFRE_DB_FILTER_CONTAINER.SetFilled(AValue: boolean);
begin
  FFilled:=AValue;
end;

procedure TFRE_DB_FILTER_CONTAINER.ClearDataInFilter;
begin
  GFRE_DBI.LogInfo(dblc_DBTDM,'>CLEARING DATA IN FILTERING FOR FILTERKEY [%s]',[FilterDataKey]);
  SetLength(FOBJArray,0); { only references ...}
  FCnt    := 0;
  FFilled := false;
end;

function TFRE_DB_FILTER_CONTAINER.UnconditionalRemoveOldObject(const td: TFRE_DB_TRANSFORMED_ORDERED_DATA; const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const ignore_non_existing: boolean; const transtag: TFRE_DB_TransStepId): NativeInt;
var old_idx   : NativeInt;
    before    : NativeInt;
    old_key   : TFRE_DB_ByteArray;
    exists    : boolean;
    //old_obj   : TFRE_DB_Object;
begin
  old_idx:=-1;
  if IsFilled then
    begin
      //old_obj  := old_tud.GetObject;
      //old_key  := old_obj.Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(OrderKey).AsByteArr;
      old_key  := old_tud.GetOrderKey(OrderKey);
      old_idx  := FREDB_BinaryFindIndexInSortedUDA(old_key,OrderKey,before,FOBJArray,exists,old_tud.GetObject.PUID,true);
      result   := old_idx;
      if exists then
        begin
          FOBJArray := FREDB_RemoveIdxFomObjectArrayUDA(FOBJArray,old_idx);
          dec(FCnt);
          AdjustLength;
          TagQueries4UpInsDel(transtag);
        end
      else
        if ignore_non_existing=false then
          raise EFRE_DB_Exception.Create(edb_ERROR,'notify filtered delete / not found');
    end
end;

function TFRE_DB_FILTER_CONTAINER.UnconditionalInsertNewObject(const td: TFRE_DB_TRANSFORMED_ORDERED_DATA; const new_tud: TFRE_DB_TRANSFORM_UTIL_DATA): NativeInt;
var ia_idx   : NativeInt;
    before   : NativeInt;
    exists   : boolean;
    i        : NativeInt;
    new_key  : TFRE_DB_ByteArray;
begin
  if IsFilled then
    begin
      new_key  := new_tud.GetOrderKey(OrderKey);
      if Length(new_key)=0 then
        raise EFRE_DB_Exception.Create(edb_ERROR,'total order key / binary key not found in insert');
      ia_idx := FREDB_BinaryFindIndexInSortedUDA(new_key,OrderKey,before,FOBJArray,exists); { exists means here that there is one KEY (not uid) existing !}
      FOBJArray := FREDB_InsertAtIdxToObjectArrayUDA(FOBJArray,ia_idx,new_tud,before>0); { ia_idx gets adjusted }
      result := ia_idx;
      inc(FCnt);
      AdjustLength;
      TagQueries4UpInsDel(new_tud.GetObject.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString);
    end;
end;

function TFRE_DB_FILTER_CONTAINER.OrderKey: TFRE_DB_NameType;
begin
  result := FFullKey.orderkey;
end;

procedure TFRE_DB_FILTER_CONTAINER.FillFilter(const startchunk, endchunk: Nativeint; const wid: NativeInt);
begin
  FOrdered.FillFilterContainer(self,startchunk,endchunk,wid);
end;


procedure TFRE_DB_FILTER_CONTAINER.TagQueries4UpInsDel(const TransActionTag: TFRE_DB_TransStepId);

  procedure Iter(const rm : TFRE_DB_SESSION_DC_RANGE_MGR);
  begin
    rm.TagForUpInsDelRLC(TransActionTag);
  end;

begin
  ForAllSessionRangemgrs(@iter);
end;

procedure TFRE_DB_FILTER_CONTAINER.AddSessionRangemanager(const rm: TFRE_DB_SESSION_DC_RANGE_MGR);
var mkey_s  : Shortstring;
begin
  mkey_s  := rm.RangemanagerKeyString;
  if not FArtRangeMgrs.InsertStringKey(mkey_s,FREDB_ObjectToPtrUInt(rm)) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'range mgr tree add failed/existing');
end;

procedure TFRE_DB_FILTER_CONTAINER.RemoveSessionRangemanager(const rm: TFRE_DB_SESSION_DC_RANGE_MGR);
var dummy : PtrUInt;
begin
  if rm.RangeManagerFiltering<>self then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'invalid filter rm removal');
  if not FArtRangeMgrs.RemoveStringKey(rm.RangemanagerKeyString,dummy) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'cannot remove session rmg for [%s] not found',[rm.RangemanagerKeyString]);
  if FArtRangeMgrs.GetValueCount=0 then
    begin
      GFRE_DBI.LogInfo(dblc_DBTDM,'>REMOVED LAST SESSION RM [%s] FROM FILTER [%s] -> CLEARING FILTER',[FilterDataKey,rm.RangemanagerKeyString]);
      ClearDataInFilter;
    end;
end;

procedure TFRE_DB_FILTER_CONTAINER.ForAllSessionRangemgrs(const rm_iter: TFRE_DB_RANGE_MGR_ITERATOR);

  procedure Scan(var value : PtrUInt);
  begin
    rm_iter(FREDB_PtrUIntToObject(value) as TFRE_DB_SESSION_DC_RANGE_MGR);
  end;

begin
  FArtRangeMgrs.LinearScan(@Scan);
end;

procedure TFRE_DB_FILTER_CONTAINER.ClearAllRangesOfFilter;

  procedure Iter(const rm : TFRE_DB_SESSION_DC_RANGE_MGR);
  begin
    rm.ClearRanges();
  end;

begin
  ForAllSessionRangemgrs(@Iter);
end;

function TFRE_DB_FILTER_CONTAINER.GetDataCount: NativeInt;
begin
  result := Length(FOBJArray);
end;

function TFRE_DB_FILTER_CONTAINER.DoesObjectPassFilterContainer(const tud: TFRE_DB_TRANSFORM_UTIL_DATA; const tracecb: TFRE_DB_FILTER_ITERATOR): boolean;
begin
  result := FFilters.DoesObjectPassFilters(tud,tracecb);
end;


procedure TFRE_DB_FILTER_CONTAINER.CheckFilteredAdd(const tud: TFRE_DB_TRANSFORM_UTIL_DATA);
begin
  if FCnt=Length(FOBJArray) then
    SetLength(FOBJArray,Length(FOBJArray)+cFRE_INT_TUNE_SYSFILTEXTENSION_SZ);
  if DoesObjectPassFilterContainer(tud) then
    begin
      FOBJArray[FCnt] := tud;
      inc(FCnt);
    end;
end;

procedure TFRE_DB_FILTER_CONTAINER.Notify_CheckFilteredUpdate(const td: TFRE_DB_TRANSFORMED_ORDERED_DATA; const old_tud, new_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const order_changed: boolean; const transtag: TFRE_DB_TransStepId);
var old_idx   : NativeInt;
    new_idx   : NativeInt;
    before    : NativeInt;
    exists    : boolean;
    i         : NativeInt;
    fm        : ShortString;
    //old_obj,
    //new_obj   : TFRE_DB_Object;

    procedure FilterTraceCB(const f:TFRE_DB_FILTER_BASE);
    begin
      fm := f.ClassName;
    end;

begin
  if not IsFilled then
    exit;
  fm := '';
  //old_obj := old_tud.GetObject;
  //new_obj := new_tud.GetObject;
  if DoesObjectPassFilterContainer(new_tud,@FilterTraceCB) then   //self
    begin { Update object does pass the filters}
      if order_changed then { order has potentially changed, key has changed / len value / but order may not have been changed in filtering }
        begin
          old_idx := Notify_CheckFilteredDelete(td,old_tud,transtag,true);
          new_idx := Notify_CheckFilteredInsert(td,new_tud,transtag,true);
          //Checkintegrity;
        end
      else
        begin
          GFRE_DBI.LogDebug(dblc_DBTDM,'     >FILTER MATCH UPDATE OBJECT ORDER NOT CHANGED [%s] IN FILTER [%s]',[old_tud.GetObject.UID_String,GetCacheDataKey.GetFullKeyString]);
          old_idx := FREDB_BinaryFindIndexInSortedUDA(old_tud.GetOrderKey(orderKey),orderkey,before,FOBJArray,exists,old_tud.GetObject.PUID,true);
          if exists=false then
            begin
              { the object passes the filter but is not in the filter, add it }
              UnconditionalInsertNewObject(td,new_tud); { this may be caused by a retransformation now going through the filter (!) }
            end
          else
            begin
              FOBJArray[old_idx] := new_tud;
              TagQueries4UpInsDel(transtag);  { in place update }
            end;
        end;
    end
  else
    begin { Update object does not pass the filters anymore -> remove it}
      GFRE_DBI.LogDebug(dblc_DBTDM,'     >FILTER REJECT UPDATE OBJECT [%s] IN FILTER [%s] DETAIL {%s}',[old_tud.GetObject.UID_String,GetCacheDataKey.GetFullKeyString,fm]);
      old_idx := UnconditionalRemoveOldObject(td,old_tud,true,transtag); { ignore non existing objects ...}
      //Checkintegrity;
    end;
end;

function TFRE_DB_FILTER_CONTAINER.Notify_CheckFilteredDelete(const td: TFRE_DB_TRANSFORMED_ORDERED_DATA; const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const transtag: TFRE_DB_TransStepId; const is_update_order_change: boolean): NativeInt;
var     tag : string[30];
    old_obj : TFRE_DB_Object;
begin
  if not IsFilled then
    exit;
  result := -1;
  old_obj := old_tud.GetObject;
  if is_update_order_change then
    tag := '* ORDERCHANGE *'
  else
    tag := '';
  if DoesObjectPassFilterContainer(old_tud) then
    begin { old object is potentially in the client query present }
      GFRE_DBI.LogDebug(dblc_DBTDM,'     >FILTER MATCH DELETE OBJECT [%s] IN ORDER/FILTER [%s] %s',[old_obj.UID_String,GetCacheDataKey.GetFullKeyString,tag]);
      result := UnconditionalRemoveOldObject(td,old_tud,false,transtag);
    end
  else
    begin
      GFRE_DBI.LogDebug(dblc_DBTDM,'     >FILTER REJECT DELETE OBJECT [%s] IN ORDER/FILTER [%s] %s',[old_obj.UID_String,GetCacheDataKey.GetFullKeyString,tag]);
    end;
end;


function TFRE_DB_FILTER_CONTAINER.Notify_CheckFilteredInsert(const td: TFRE_DB_TRANSFORMED_ORDERED_DATA; const new_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const transtag: TFRE_DB_TransStepId; const is_update_order_change: boolean): NativeInt;
var tag     : string[30];
    new_obj : TFRE_DB_Object;
begin
  if not IsFilled then
    exit;
  if is_update_order_change then // self
    tag := '* ORDERCHANGE *'
  else
    tag := '';
  result := -1;
  new_obj := new_tud.GetObject;
  if DoesObjectPassFilterContainer(new_tud) then
    begin { old object is potentially in the client query present }
      GFRE_DBI.LogDebug(dblc_DBTDM,'     >FILTER MATCH INSERT OBJECT [%s] IN ORDER/FILTER [%s] %s',[new_obj.UID_String,GetCacheDataKey.GetFullKeyString,tag]);
      result := UnconditionalInsertNewObject(td,new_tud);
    end
  else
    begin
      GFRE_DBI.LogDebug(dblc_DBTDM,'     >FILTER REJECT INSERT OBJECT [%s] IN ORDER/FILTER [%s] %s',[new_obj.UID_String,GetCacheDataKey.GetFullKeyString,tag]);
    end;
end;

procedure TFRE_DB_FILTER_CONTAINER.Notify_CheckChildCountChange(const transid: TFRE_DB_TransStepId; const parent: TFRE_DB_TRANSFORM_UTIL_DATA);
begin
  if DoesObjectPassFilterContainer(parent) then
    TagQueries4UpInsDel(transid);
end;

procedure TFRE_DB_FILTER_CONTAINER.AdjustLength;
begin
  SetLength(FOBJArray,FCnt);
end;

constructor TFRE_DB_FILTER_CONTAINER.Create(const full_key: TFRE_DB_TRANS_COLL_DATA_KEY; const qry_filters: TFRE_DB_DC_FILTER_DEFINITION; const ordered: TFRE_DB_TRANSFORMED_ORDERED_DATA);
begin
  inherited Create;
  FCnt            := 0;
  FFCCreationTime := GFRE_DT.Now_UTC;
  //FChildQueryCont := is_child_qry;
  FFilters        := TFRE_DB_DC_FILTER_DEFINITION.Create(qry_filters.FFiltDefDBname);
  FFilters.AddFilters(qry_filters);
  FFilters.Seal;
  FFullKey           := full_key;
  FFullKey.filterkey := FFilters.GetFilterKey;
  FFullKey.Seal;
  FArtRangeMgrs  := TFRE_ART_TREE.Create;
  FOrdered       := ordered;
end;

destructor TFRE_DB_FILTER_CONTAINER.Destroy;
begin
  FArtRangeMgrs.Free;   { TODO: clean queries }
  FFilters.Free;
  inherited Destroy;
end;

function TFRE_DB_FILTER_CONTAINER.GetCacheDataKey: TFRE_DB_TRANS_COLL_DATA_KEY;
begin
  result := FFullKey;
end;

function TFRE_DB_FILTER_CONTAINER.FilterDataKey: TFRE_DB_CACHE_DATA_KEY;
begin
  result := GetCacheDataKey.GetFullKeyString;
end;

procedure TFRE_DB_FILTER_CONTAINER.Checkintegrity;
var  i   : NativeInt;
     obj : IFRE_DB_Object;
begin
  try
    //for i := 0 to high(FOBJArray) do
    //  begin
    //    obj := FOBJArray[i].CloneToNewObject();
    //    obj.Finalize;
    //    obj := FOBJArray[i].CloneToNewObject();
    //    obj.Finalize;
    //    obj := FOBJArray[i].CloneToNewObject();
    //    obj.Finalize;
    //  end;
    abort;
  except
    on E:Exception do
      begin
        writeln('--- FILTER INTEGRITY CHECK FAILED ',e.Message,' ',OrderKey,' ',FFilters.GetFilterKey);
      end;
  end;
end;

function TFRE_DB_FILTER_CONTAINER.FetchDirectInFilter(const uid: TFRE_DB_GUID; out dbo: IFRE_DB_Object): boolean;
var i:NativeInt;
begin
  result := false; { TODO: use order }
  for i:=0 to high(FOBJArray) do
    if uid=FOBJArray[i].GetObject.UID then
      begin
        dbo := FOBJArray[i].GetObject;
        exit(true);
      end;
end;

function TFRE_DB_FILTER_CONTAINER.GetTransFormUtilData(const idx: NativeInt): TFRE_DB_TRANSFORM_UTIL_DATA;
begin
  result := FOBJArray[idx];
end;


{ TFRE_DB_DC_FILTER_DEFINITION }

function TFRE_DB_DC_FILTER_DEFINITION.IsSealed: Boolean;
begin
  result := FFilterKey<>'';
end;

procedure TFRE_DB_DC_FILTER_DEFINITION._ForAllAdd(obj: TObject; arg: Pointer);
var clone  : boolean;
begin
  clone := NativeUint(arg)=1;
  AddFilter(obj as TFRE_DB_FILTER_BASE,clone);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION._ForAllKey(obj: TObject; arg: Pointer);
begin
  TStringList(arg).Add((obj as TFRE_DB_FILTER_BASE).GetDefinitionKey);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION._ForAllFilter(obj: TObject; arg: Pointer);
var tob : TFRE_DB_TRANSFORM_UTIL_DATA;
    flt : TFRE_DB_FILTER_BASE;
begin
  if FFilterHit=true then
    exit;
  tob         := TFRE_DB_TRANSFORM_UTIL_DATA(arg);
  flt         := obj as TFRE_DB_FILTER_BASE;
  if (flt.IsARootNodeOnlyFilter and ( (FIsa_CP_ChildFilterContainer) or  (not tob.ObjectIsInParentPath('')))) then
    exit;
  FFilterHit := not flt.CheckFilterMiss(tob,FFilterErr);
  if (FFilterHit) and Assigned(FTransientTraceCB) then
    begin
      FTransientTraceCB(flt);
    end;
end;

constructor TFRE_DB_DC_FILTER_DEFINITION.Create(const filter_dbname: TFRE_DB_NameType);
begin
  FKeyList       := TFPHashObjectList.Create(true);
  FFiltDefDBname := filter_dbname;
  if FFiltDefDBname='' then
    raise EFRE_DB_Exception.Create(edb_ERROR,'dbname not set in create filter def');
end;

destructor TFRE_DB_DC_FILTER_DEFINITION.Destroy;
begin
  FKeyList.Free;
  inherited Destroy;
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddFilters(const source: TFRE_DB_DC_FILTER_DEFINITION_BASE; const clone: boolean);
var src : TFRE_DB_DC_FILTER_DEFINITION;
begin
  if not assigned(source) then    //self
    exit;
  src := source as TFRE_DB_DC_FILTER_DEFINITION;
  if clone then
    src.FKeyList.ForEachCall(@_ForAllAdd,Pointer(1))
  else
    src.FKeyList.ForEachCall(@_ForAllAdd,Pointer(0));
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddFilter(const source: TFRE_DB_FILTER_BASE; const clone: boolean);
var filt : TFRE_DB_FILTER_BASE;
    key  : TFRE_DB_NameType;
begin
  key := source.GetKeyName;
  if FKeyList.FindIndexOf(key)<>-1 then
    begin
      try
        if not clone then
          source.Free;
      except
        WriteLn('>>>>>>>>>>> UNEXPECTED FILTER CLONE BUG');
      end;
      raise EFRE_DB_Exception.Create(edb_ERROR,'FILTER WITH KEY ALREADY EXISTS IN THIS DEFINITION [%s]',[key]);
    end;
  if clone then
    filt := source.Clone
  else
    filt := source;
  FKeyList.Add(source.GetKeyName,filt);
  if filt is TFRE_DB_FILTER_PARENT then
    begin
      FIsa_CP_ChildFilterContainer := true;
      FPPA := TFRE_DB_FILTER_PARENT(filt).FAllowedParent;
    end
  else
  if filt is TFRE_DB_FILTER_CHILD then { Filters childs = is a parent ds }
    begin
      FIsa_CP_ParentFilterContainer := true;
      FPPA := '';
    end;
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddStringFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalue: TFRE_DB_String; const stringfiltertype: TFRE_DB_STR_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_STRING;
begin
  filt := TFRE_DB_FILTER_STRING.Create(key);
  filt.InitFilter(fieldname,filtervalue,stringfiltertype,negate,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddSignedFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of Int64; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_SIGNED;
begin
  filt := TFRE_DB_FILTER_SIGNED.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddUnsignedFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of Uint64; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_UNSIGNED;
begin
  filt := TFRE_DB_FILTER_UNSIGNED.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddCurrencyFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of Currency; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_CURRENCY;
begin
  filt := TFRE_DB_FILTER_CURRENCY.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddReal64FieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of Double; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_REAL64;
begin
  filt := TFRE_DB_FILTER_REAL64.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddDatetimeFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of TFRE_DB_DateTime64; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_DATETIME;
begin
  filt := TFRE_DB_FILTER_DATETIME.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddBooleanFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalue: boolean; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_BOOLEAN;
begin
  filt := TFRE_DB_FILTER_BOOLEAN.Create(key);
  if negate then
    filtervalue := not filtervalue;
  filt.InitFilter(fieldname,filtervalue,include_null_values);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddUIDFieldFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of TFRE_DB_GUID; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_UID;
begin
  filt := TFRE_DB_FILTER_UID.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values,false);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddRootNodeFilter(const key, fieldname: TFRE_DB_NameType; filtervalues: array of TFRE_DB_GUID; const numfiltertype: TFRE_DB_NUM_FILTERTYPE; const negate: boolean; const include_null_values: boolean);
var filt : TFRE_DB_FILTER_UID;
begin
  filt := TFRE_DB_FILTER_UID.Create(key);
  filt.InitFilter(fieldname,filtervalues,numfiltertype,negate,include_null_values,true);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddSchemeObjectFilter(const key: TFRE_DB_NameType; filtervalues: array of TFRE_DB_String; const negate: boolean);
var filt : TFRE_DB_FILTER_SCHEME;
begin
  filt := TFRE_DB_FILTER_SCHEME.Create(key);
  filt.InitFilter(filtervalues,negate);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddStdRightObjectFilter(const key: TFRE_DB_NameType; stdrightset: TFRE_DB_STANDARD_RIGHT_SET; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');
var filt : TFRE_DB_FILTER_RIGHT;
begin
  filt := TFRE_DB_FILTER_RIGHT.Create(key);
  filt.InitFilter(stdrightset,usertoken,negate,ignoreField,ignoreValue);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddStdClassRightFilter(const key: TFRE_DB_NameType; domainidfield,objuidfield,schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType; stdrightset: TFRE_DB_STANDARD_RIGHT_SET; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');
var filt : TFRE_DB_FILTER_RIGHT;
begin
  filt := TFRE_DB_FILTER_RIGHT.Create(key);
  filt.InitFilterRefered(domainidfield,objuidfield,schemeclassfield,schemeclass,stdrightset,usertoken,negate,ignoreField,ignoreValue);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddObjectRightFilter(const key: TFRE_DB_NameType; rightset: array of TFRE_DB_String; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');
var filt : TFRE_DB_FILTER_RIGHT;
begin
  filt := TFRE_DB_FILTER_RIGHT.Create(key);
  filt.InitFilterGenRights(rightset,usertoken,negate,ignoreField,ignoreValue);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddClassRightFilter(const key: TFRE_DB_NameType; domainidfield, objuidfield, schemeclassfield: TFRE_DB_NameType; schemeclass: TFRE_DB_NameType; rightset: array of TFRE_DB_String; const usertoken: IFRE_DB_USER_RIGHT_TOKEN; const negate: boolean; const ignoreField:TFRE_DB_NameType=''; const ignoreValue:TFRE_DB_String='');
var filt : TFRE_DB_FILTER_RIGHT;
begin
  filt := TFRE_DB_FILTER_RIGHT.Create(key);
  filt.InitFilterGenRightsRefrd(domainidfield,objuidfield,schemeclassfield,schemeclass,rightset,usertoken,negate,ignoreField,ignoreValue);
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddChildFilter(const key: TFRE_DB_NameType);
var filt : TFRE_DB_FILTER_CHILD;
begin
  if FIsa_CP_ParentFilterContainer or FIsa_CP_ChildFilterContainer then
    raise EFRE_DB_Exception.Create(edb_ERROR,'this is already a child or parendata filter definition, cannot add a childfilter (!)');
  SetLength(FPPA,0);
  FIsa_CP_ChildFilterContainer := true;
  filt := TFRE_DB_FILTER_CHILD.Create(key);
  filt.InitFilter;
  AddFilter(filt,false);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.AddParentFilter(const key: TFRE_DB_NameType; const allowed_parent_path: TFRE_DB_String);
var filt : TFRE_DB_FILTER_PARENT;
begin
  if FIsa_CP_ParentFilterContainer or FIsa_CP_ChildFilterContainer then
    raise EFRE_DB_Exception.Create(edb_ERROR,'this is already a child or parendata filter definition, cannot add a parentfilter (!)');
  FIsa_CP_ParentFilterContainer := true;
  FPPA := allowed_parent_path;
  filt := TFRE_DB_FILTER_PARENT.Create(key);
  filt.InitFilter(allowed_parent_path);
  AddFilter(filt,false);
end;

function TFRE_DB_DC_FILTER_DEFINITION.RemoveFilter(const key: TFRE_DB_NameType): boolean;
var idx : Integer;
begin
  idx    := FKeyList.FindIndexOf(key);
  result := idx<>-1;
  if result then
    FKeyList.Delete(idx);
end;

function TFRE_DB_DC_FILTER_DEFINITION.FilterExists(const key: TFRE_DB_NameType): boolean;
var idx : Integer;
begin
  idx    := FKeyList.FindIndexOf(key);
  result := idx<>-1;
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.RemoveAllFilters;
begin
  FKeyList.Clear;
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.RemoveAllFiltersPrefix(const key_prefix: TFRE_DB_NameType);
var idx : NativeInt;

    function findprefix:boolean;
    var i    : NativeInt;
        filt : TFRE_DB_FILTER_BASE;
        key  : TFRE_DB_NameType;
    begin
      for i:= 0 to FKeyList.Count-1 do
        begin
          filt := FKeyList.Items[i] as TFRE_DB_FILTER_BASE;
          key  := filt.GetKeyName;
          if pos(key_prefix,key)=1 then
            begin
              idx:=i;
              exit(true);
            end;
        end;
      idx:=-1;
      result := false;
    end;

begin
  while findprefix do
    FKeyList.Delete(idx);
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.MustNotBeSealed;
begin
 if IsSealed then
   raise EFRE_DB_Exception.Create(edb_ERROR,'filter definition is already sealed');
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.MustBeSealed;
begin
 if not IsSealed then
   raise EFRE_DB_Exception.Create(edb_ERROR,'filter definition is not done');
end;

procedure TFRE_DB_DC_FILTER_DEFINITION.Seal;
var sl : TStringList;
begin
  MustNotBeSealed;
  FFilterKey:='';
  sl := TStringList.Create;
  try
    FKeyList.ForEachCall(@_ForAllKey,sl);
    sl.Sort;
    FFilterKey := sl.CommaText;
    FFilterKey := GFRE_BT.HashFast32_Hex(FFilterKey);
  finally
    sl.free;
  end;
end;

function TFRE_DB_DC_FILTER_DEFINITION.GetFilterKey: TFRE_DB_TRANS_COLL_FILTER_KEY;
begin
  MustBeSealed;
  result := FFilterKey;
end;

function TFRE_DB_DC_FILTER_DEFINITION.DoesObjectPassFilters(const tud: TFRE_DB_TRANSFORM_UTIL_DATA; const tracecb: TFRE_DB_FILTER_ITERATOR): boolean;
begin
  FFilterHit := false;
  FFilterErr  := 0;
  FTransientTraceCB := tracecb;
  try
    FKeyList.ForEachCall(@_ForAllFilter,tud);
  finally
    FTransientTraceCB:=nil;
  end;
  result := not FFilterHit;
end;

function TFRE_DB_DC_FILTER_DEFINITION.FilterDBName: TFRE_DB_NameType;
begin
  result := FFiltDefDBname;
end;

{ TFRE_DB_DC_ORDER_DEFINITION }

function TFRE_DB_DC_ORDER_DEFINITION.IsSealed: Boolean;
begin
  result := FKey.IsSealed;
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.MustNotBeSealed;
begin
  if IsSealed then
    raise EFRE_DB_Exception.Create(edb_ERROR,'order definition is already sealed');
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.MustBeSealed;
begin
  if not IsSealed then
    raise EFRE_DB_Exception.Create(edb_ERROR,'order definition is not done');
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.SetDataKeyColl(const parent_collectionname, derivedcollname: TFRE_DB_NameType);
begin
  FKey.Collname  := parent_collectionname;
  FKey.DC_Name   := derivedcollname;
  //FKey.RL_Spec   := ParentChildspec;
  //if FKey.RL_Spec='' then
  //  FKey.RL_Spec := '#'
  //else
  //  FKey.RL_Spec := GFRE_BT.HashFast32_Hex(ParentChildspec);
end;


procedure TFRE_DB_DC_ORDER_DEFINITION.ForAllOrders(const orderiterator: TFRE_DB_DC_ORDER_ITERATOR);
var order : TFRE_DB_DC_ORDER;
begin
  for order in FOrderList do
    orderiterator(order);
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.AssignFrom(const orderdef: TFRE_DB_DC_ORDER_DEFINITION_BASE);

  procedure Copy(const order:TFRE_DB_DC_ORDER);
  begin
    with order do
      AddOrderDef(order_field,ascending,case_insensitive);
  end;

begin
  ClearOrders;
  (orderdef as TFRE_DB_DC_ORDER_DEFINITION).ForAllOrders(@Copy);
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.SetupBinaryKey(const tud: TFRE_DB_TRANSFORM_UTIL_DATA; const Key: PByteArray; var max_key_len: NativeInt; const tag_object: boolean);
var
    KeyLen : NativeInt;
    obj    : TFRE_DB_Object;

  procedure  Iter(const order : TFRE_DB_DC_ORDER);
  var fld    : IFRE_DB_Field;
      idx    : TFRE_DB_MM_IndexClass;
  begin
    if obj.FieldOnlyExistingI(order.order_field,fld) then
      begin
        if TFRE_DB_MM_Index.GetIndexClassForFieldtype(fld.FieldType,idx)=edb_UNSUPPORTED then
          begin
            TFRE_DB_TextIndex.TransformToBinaryComparable(nil,key[max_key_len],KeyLen,false,not order.ascending); { fallback transform the nil/unknown/unsupported fieldtype to a text null value }
          end
        else
          if idx=TFRE_DB_UnsignedIndex then
            TFRE_DB_UnsignedIndex.TransformToBinaryComparable(fld.Implementor as TFRE_DB_FIELD,Key[max_key_len],keylen,false,not order.ascending)
          else
          if idx=TFRE_DB_SignedIndex then
            TFRE_DB_SignedIndex.TransformToBinaryComparable(fld.Implementor as TFRE_DB_FIELD,Key[max_key_len],keylen,false,not order.ascending)
          else
          if idx=TFRE_DB_TextIndex then
            TFRE_DB_TextIndex.TransformToBinaryComparable(fld.Implementor as TFRE_DB_FIELD,Key[max_key_len],keylen,order.case_insensitive,not order.ascending)
          else
          if idx=TFRE_DB_RealIndex then
            TFRE_DB_RealIndex.TransformToBinaryComparable(fld.Implementor as TFRE_DB_FIELD,Key[max_key_len],keylen,false,not order.ascending)
          else
            raise EFRE_DB_Exception.Create(edb_INTERNAL,' unknonw idx typed must be reported as unsupported ! idx='+idx.classname);
      end
    else
      begin
        TFRE_DB_TextIndex.TransformToBinaryComparable(nil,@key[max_key_len],KeyLen,false); { fallback transform the nil/unknown/unsupported fieldtype to a text null value }
      end;
    max_key_len := max_key_len+KeyLen;
  end;

  procedure TagObject;
  var byte_arr : TFRE_DB_ByteArray;
  begin
    FREDB_BinaryKey2ByteArray(key[0],max_key_len,byte_arr);
    //obj.Field(cFRE_DB_SYS_T_OBJ_TOTAL_ORDER).AsObject.Field(FKey.orderkey).AsByteArr := byte_arr;
    tud.SetOrderkey(FKey.orderkey,byte_arr);
  end;

begin
  MustBeSealed;
  max_key_len := 0;
  obj         := tud.GetObject;
  ForAllOrders(@iter);
  if tag_object then
    TagObject;
end;

function TFRE_DB_DC_ORDER_DEFINITION.OrderCount: NativeInt;
begin
  result := Length(FOrderList);
end;

function TFRE_DB_DC_ORDER_DEFINITION.Orderdatakey: TFRE_DB_CACHE_DATA_KEY;
begin
  result := FKey.GetOrderKeyPart;
end;

function TFRE_DB_DC_ORDER_DEFINITION.BasedataKey: TFRE_DB_CACHE_DATA_KEY;
begin
  result := FKey.GetBaseDataKey;
end;

function TFRE_DB_DC_ORDER_DEFINITION.CacheDataKey: TFRE_DB_TRANS_COLL_DATA_KEY;
begin
  result := FKey;
end;

function TFRE_DB_DC_ORDER_DEFINITION.HasOrders: boolean;
begin
  result := Length(FOrderList)>0;
end;


procedure TFRE_DB_DC_ORDER_DEFINITION.ClearOrders;
begin
  SetLength(FOrderList,0);
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.AddOrderDef(const orderfield_name: TFRE_DB_NameType; const asc: boolean; const case_insens: boolean);
begin
  MustNotBeSealed;
  SetLength(FOrderList,Length(FOrderList)+1);
  with FOrderList[high(FOrderList)] do
    begin
      ascending        := asc;
      order_field      := orderfield_name;
      case_insensitive := case_insens;
    end;
end;

procedure TFRE_DB_DC_ORDER_DEFINITION.Seal;
var key : string;
    i   : NativeInt;
begin
  MustNotBeSealed;
  if Length(FOrderList)=0 then
    raise EFRE_DB_Exception.Create(edb_ERROR,'a orderdefinition must at least contain one order!');
  key := '';
  for i := 0 to high(FOrderList) do
    with FOrderList[i] do
      key  := key +order_field+BoolToStr(ascending,'A','D');
  FKey.OrderKey := GFRE_BT.HashFast32_Hex(key);
  FKey.Seal;
end;

{ TFRE_DB_ORDER_CONTAINER }

function TFRE_DB_ORDER_CONTAINER.AddObject(const tud: TFRE_DB_TRANSFORM_UTIL_DATA): boolean;
var idx : NativeInt;
begin
  idx    := FOBJArray.Add(tud);
  result := idx=-1;
end;

function TFRE_DB_ORDER_CONTAINER.Exists(const tud: TFRE_DB_TRANSFORM_UTIL_DATA): boolean;
begin
  result := FOBJArray.Exists(tud)<>-1;
end;

procedure TFRE_DB_ORDER_CONTAINER.ReplaceObject(const old_tud, new_tud: TFRE_DB_TRANSFORM_UTIL_DATA);
var idx : NativeInt;
begin
  idx := FOBJArray.Exists(old_tud);
  if idx=-1 then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'ordercontainer/replace old object not found');
  FOBJArray.Element[idx] := new_tud;
end;

function TFRE_DB_ORDER_CONTAINER.RemoveObject(const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA): boolean;
var idx : NativeInt;
begin
  if not FOBJArray.Delete(old_tud) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'logic / remove from ordercontainer / value not found');
  result := FOBJArray.Count=0;
end;

procedure TFRE_DB_ORDER_CONTAINER.ForAllInOC(const iter: TFRE_DB_TRANSFORM_UTIL_DATA_ITERATOR);

  procedure MyIter(var tud : TFRE_DB_TRANSFORM_UTIL_DATA);
  begin
    iter(tud);
  end;

begin
  FOBJArray.ForAll(@myiter);
end;

constructor TFRE_DB_ORDER_CONTAINER.Create;
begin
  inherited Create;
  FOBJArray.InitSparseListPtrCmp;
end;

{ TFRE_DB_QUERY }

function TFRE_DB_QUERY.GetFilterDefinition: TFRE_DB_DC_FILTER_DEFINITION;
begin
  result := FQueryFilters;
end;

function TFRE_DB_QUERY.GetOrderDefinition: TFRE_DB_DC_ORDER_DEFINITION;
begin
  result := FOrderDef;
end;

function TFRE_DB_QUERY.GetReflinkSpec(const upper_refid: TFRE_DB_NameType): TFRE_DB_NameTypeRLArray;
var i:integer;
begin
  for i:=0 to high(FDependencyIds) do
    if FDependencyIds[i]=upper_refid then
      exit(FDepRefConstraints[i]);
  raise EFRE_DB_Exception.Create(edb_ERROR,'cannot find a reflink spec for reference id '+upper_refid);
end;

function TFRE_DB_QUERY.GetReflinkStartValues(const upper_refid: TFRE_DB_NameType): TFRE_DB_GUIDArray;
var i:integer;
begin
  for i:=0 to high(FDependencyIds) do
    if FDependencyIds[i]=upper_refid then
      exit(FDependcyFilterUids[i]);
  raise EFRE_DB_Exception.Create(edb_ERROR,'cannot find the filter values for reference id '+upper_refid);
end;

procedure TFRE_DB_QUERY.SwapCompareQueryQry;
var i : NativeInt;
begin
  //for i := 0 to High(FResultDBOs) do
  // begin
  //   FResultDBOs[i].Finalize;
  // end;
  //FResultDBOs             := copy(FResultDBOsCompare);
  //FQueryCurrIdx           := FQueryCurrIdxCmp;
  //FQueryDeliveredCount    := FQueryDeliveredCountCmp;
  //FQueryPotentialCount    := FQueryPotentialCountCmp;
  //SetLength(FResultDBOsCompare,0);
end;

procedure TFRE_DB_QUERY.CaptureStartTime;
begin
  FQueryStartTime := GFRE_BT.Get_Ticks_ms;
end;

function TFRE_DB_QUERY.CaptureEndTime: NativeInt;
begin
  FQueryEndTime := GFRE_BT.Get_Ticks_ms;
  result        := FQueryEndTime - FQueryStartTime;
end;

constructor TFRE_DB_QUERY.Create(const qry_dbname: TFRE_DB_NameType);
begin
  FQryDBname     := qry_dbname;
  FOrderDef      := TFRE_DB_DC_ORDER_DEFINITION.Create;
  FQueryFilters  := TFRE_DB_DC_FILTER_DEFINITION.Create(qry_dbname);
end;

destructor TFRE_DB_QUERY.Destroy;
begin
  FQueryFilters.free;
  {FOrderDef.Free; dont free orderdef it's used in the orders TODO: CHECK}
  GFRE_DBI.LogDebug(dblc_DBTDM,'  <> FINALIZE QRY [%s]',[GetQueryID.GetFullKeyString]);
  inherited Destroy;
end;

function TFRE_DB_QUERY.GetQueryID: TFRE_DB_SESSION_DC_RANGE_MGR_KEY;
begin
  result := FQueryId;
end;

//function TFRE_DB_QUERY.GetQueryID: TFRE_DB_NameType;
//begin
//  result := FQueryId;
//end;


function TFRE_DB_QUERY.HasOrderDefinition: boolean;
begin
  result := assigned(FOrderDef);
end;


function TFRE_DB_QUERY.GetReqID: Qword;
begin
  result := FReqID;
end;

function TFRE_DB_QUERY.GetTransfrom: IFRE_DB_SIMPLE_TRANSFORM;
begin
  result := FTransformobject;
end;

function TFRE_DB_QUERY.GetResultData: IFRE_DB_ObjectArray;
begin
  result := FClonedRangeDBOS;
end;

function TFRE_DB_QUERY.GetTotalCount: NativeInt;
begin
  result := FPotentialCount;
end;

procedure TFRE_DB_QUERY.SetupWorkingContextAndStart(const Compute: IFRE_APSC_CHANNEL_GROUP; const transform: IFRE_DB_SIMPLE_TRANSFORM; const return_cg: IFRE_APSC_CHANNEL_GROUP; const ReqID: Qword; const sync_event: IFOS_E);
begin
  FCompute         := Compute;
  FAsyncResultCtx  := return_cg;
  FMyComputeState  := cs_Initiated;
  FTransformobject := transform;
  FReqID           := ReqID;
  FSyncEvent       := sync_event;
  FCompute.DoAsyncWork(self);
end;

procedure TFRE_DB_QUERY.SetupWorkerCount_WIF(const wc: NativeInt);
begin
  FMyWorkerCount := wc;
end;

function TFRE_DB_QUERY.GetAsyncDoneContext_WIF: IFRE_APSC_CHANNEL_MANAGER;
begin
  result := nil;
end;

function TFRE_DB_QUERY.GetAsyncDoneChannelGroup_WIF: IFRE_APSC_CHANNEL_GROUP;
begin
  Result := FAsyncResultCtx;
end;

function TFRE_DB_QUERY.StartGetMaximumChunk_WIF: NativeInt;
var is_filled : boolean;

   procedure SetupFiltering;
   begin
     result := 1;
     fst    := GFRE_BT.Get_Ticks_ms;
     GFRE_DBI.LogDebug(dblc_DBTDM,'> FILTER FILLING DATA FOR [%s]',[FFiltered.FilterDataKey]);
   end;

   procedure SetupOrdering;
   begin
     result   := 1; // do serial / Ftransdata.TransformedCount;
     fst    := GFRE_BT.Get_Ticks_ms;
     GFRE_DBI.LogDebug(dblc_DBTDM,'> ORDERING  DATA FOR [%s]',[FOrderDef.Orderdatakey]);
     FOrdered :=G_TCDM.CreateTransformedOrdered(self);
     FRm.AssignOrdering(FOrdered);
   end;

   procedure SetupRangeProcessing;
   var onedbo : IFRE_DB_Object;
   begin
     case FStartIdx of
       -1:
         begin { deliver potential count, don't create a range }
           FPotentialCount := FFiltered.GetDataCount;
           FMyComputeState := cs_DeliverRange;
           result          := -1;
           exit;
         end;
       -2:
         begin { first }
           FStartIdx := 0;
           FEndIndex := 0;
         end;
       -3:     { last  }
         begin
           FStartIdx := FFiltered.GetDataCount-1;
           FEndIndex := FFiltered.GetDataCount-1;
         end;
       -4:
         begin { only one uid }
           if not FFiltered.IsFilled then
             FFiltered.FillFilter(0,0,-1);
           if FFiltered.FetchDirectInFilter(FOnlyOneUID,onedbo) then
             begin
               SetLength(FClonedRangeDBOS,1);
               FClonedRangeDBOS[0] := onedbo.CloneToNewObject;
               FMyComputeState := cs_DeliverRange;
               result          := -1;
               exit;
             end
           else
             begin
               SetLength(FClonedRangeDBOS,0);
               FMyComputeState := cs_NoDataAvailable;
               result          := -1;
               exit;
             end;
         end;
     end;
     if not FRm.FindRange4QueryAndUpdateQuerySpec(FQueryId.SessionID,FSessionRange,FStartIdx,FEndIndex,FPotentialCount) then { creates a session range manager, and a range if needed }
       begin
         FMyComputeState := cs_NoDataAvailable;
         result          := -1;
         exit;
       end;
     if FSessionRange.FMgr.RangemanagerKeyString<>FQueryId.GetRmKeyAsString then
       GFRE_BT.CriticalAbort('rangemgr key failure (!)');
     if not FSessionRange.RangeFilled then
       begin
         FSessionRange.FillRange();
       end;
     result          := FEndIndex-FStartIdx+1;
     SetLength(FClonedRangeDBOS,result); { prepare result array }
     FMyComputeState := cs_DeliverRange;
   end;

   procedure CreateEmptyData;
   begin
     if not cFRE_DBG_DISABLE_TRANS_ORDER_STORE then
       G_TCDM.AddBaseTransformedData(Ftransdata); { need to add the transformed data, even if zero to allow updates for it }
     FOrdered :=G_TCDM.CreateTransformedOrdered(self);
     FOrdered.OrderTheData(0,0,-1);
     FRm.AssignOrdering(FOrdered);
     FOrdered.GetOrCreateFiltercontainer(Filterdef,FFiltered);
     FRm.AssignFiltering(FFiltered);
     FOrdered.FillFilterContainer(FFiltered,0,0,-1);
     if FStartIdx>=0 then { only create a range if this isn't a "special" query (ItemCount,LAst,First) ... }
       begin
         FRm.FindRange4QueryAndUpdateQuerySpec(FQueryId.SessionID,FSessionRange,FStartIdx,FEndIndex,FPotentialCount); { creates a session range manager, and no range (no data) }
       end;
     FMyComputeState := cs_NoDataAvailable;
   end;

   procedure CheckSetupFiltering;
   begin
     if not assigned(FRm.RangeManagerFiltering) then
       begin
         FOrdered.GetOrCreateFiltercontainer(Filterdef,FFiltered);
         FRM.AssignFiltering(FFiltered);
       end
     else
       begin
         FFiltered := FRm.RangeManagerFiltering;
       end;
     if FFiltered.IsFilled then
       begin
         FMyComputeState := cs_RangeProcessing;
         SetupRangeProcessing;
       end
     else
       begin
         FMyComputeState := cs_NeedFilterFilling;
         SetupFiltering;
       end;
   end;

begin
  result := 0; { invalid }
  case FMyComputeState of
    cs_Initiated:
      begin
        if  G_TCDM.GetSessionRangeManager(FQueryId.GetRmKeyAsString,FRm,false) then
          begin
            FRm.CheckQuerySpecAndClearIfNeeded(FQueryId); { drop filter/order association if not matching, remove rm from filter ... }
          end
        else
          begin
            frm := G_TCDM.CreateSessionRangeManager(FQueryId);
          end;
        if not assigned(FRm.RangeManagerOrdering) then
          begin
            Fbasekey := Orderdef.BasedataKey;
            if not G_TCDM.GetBaseTransformedData(Fbasekey,Ftransdata) then { 1st search for Transformeddata }
              begin
                GFRE_DBI.LogDebug(dblc_DBTDM,'>BASE TRANSFORMING DATA FOR [%s] FETCHING',[fbasekey]);
                Fst := GFRE_BT.Get_Ticks_ms;
                result          := 1;
                FMyComputeState := cs_FetchData;
              end
            else
              begin      { Transforming was found is ordering known (?) }
                if G_TCDM.GetTransformedOrderedData(self,FOrdered) then
                  begin
                    FRm.AssignOrdering(FOrdered);
                    CheckSetupFiltering;
                  end
                else
                  begin
                    FMyComputeState := cs_NeedOrder;
                    SetupOrdering;
                  end;
              end;
          end
        else
          begin  { Ordered is here, check for filter}
             result := 1;
             FOrdered := FRm.RangeManagerOrdering;
             CheckSetupFiltering;
          end;
      end;
    cs_NeedTransform:
      begin
        result := Ftransdata.FRecordCount;
        if result=0 then
          begin
            CreateEmptyData;
            result := -1;
            exit;
          end
        else
        begin
          fst    := GFRE_BT.Get_Ticks_ms;
          GFRE_DBI.LogDebug(dblc_DBTDM,'>BASE TRANSFORMING DATA FOR [%s]',[Fbasekey]);
        end;
      end;
    cs_NeedOrder:
       SetupOrdering;
    cs_NeedFilterFilling:
       SetupFiltering;
    cs_RangeProcessing:
       SetupRangeProcessing;
    else
      GFRE_BT.CriticalAbort(classname+' workable interface failed invalid state/GetMaximumChunk');
  end;
end;

procedure TFRE_DB_QUERY.ParallelWorkIt_WIF(const startchunk, endchunk: Nativeint; const wid: NativeInt);

  procedure LocalFetchTransfromdata;
  begin
     Ftransdata := TFRE_DB_TRANFORMED_DATA.Create(self,FTransformobject,FCompute.GetChannelManagerCount);  { the transform data is identified by the basekey }
     Ftransdata.TransformFetchAll;
     Fet        := GFRE_BT.Get_Ticks_ms;
     GFRE_DBI.LogInfo(dblc_DBTDM,'<BASE TRANSFORMING DATA FOR [%s] FETCHING DONE - %d records in %d ms',[Fbasekey,Ftransdata.FRecordCount,fet-fst]);
  end;

  procedure TransformData;
  begin
    Ftransdata.TransformAllParallel(startchunk,endchunk,wid);
  end;

  procedure OrderTheData;
  begin
    FOrdered.OrderTheData(startchunk,endchunk,wid);
  end;

  procedure FilterTheData; { get filtercontainer for this query }
  begin
    FOrdered.FillFilterContainer(FFiltered,startchunk,endchunk,wid);
  end;

  procedure DeliverRange;
  begin
    FSessionRange.RangeExecuteQry(FStartIdx,startchunk,endchunk,FClonedRangeDBOS);
  end;


  procedure FillRange;
  begin
    abort;
  end;

begin
  case FMyComputeState of
    cs_FetchData:
         LocalFetchTransfromdata;
    cs_NeedTransform:
         TransformData;
    cs_NeedOrder:
         OrderTheData;
    cs_NeedFilterFilling:
         FilterTheData;
    cs_DeliverRange:
         Deliverrange;
    else
      GFRE_BT.CriticalAbort(classname+' workable interface failed invalid state/WorkIt');
  end;
end;

procedure TFRE_DB_QUERY.WorkNextCyle_WIF(var continue: boolean);
begin
  case FMyComputeState of
    cs_FetchData:
      begin
        FMyComputeState := cs_NeedTransform; { data fetched, now transform }
        continue        := true;
      end;
    cs_NeedTransform:
      begin
        G_TCDM.AddBaseTransformedData(Ftransdata);
        fet        := GFRE_BT.Get_Ticks_ms;
        fst        := fet-fst;
        GFRE_DBI.LogInfo(dblc_DBTDM,'<BASE TRANSFORMING DATA FOR [%s] DONE (Parallel : %d) - Transformed %d records in %d ms',[Fbasekey,G_TCDM.ParallelWorkers,Ftransdata.TransformedCount,fst]);
        FMyComputeState := cs_NeedOrder;
        continue        := true;
      end;
    cs_NeedOrder:
      begin
        fet        := GFRE_BT.Get_Ticks_ms;
        fst        := fet-fst;
        GFRE_DBI.LogInfo(dblc_DBTDM,'<ORDERING DATA FOR [%s] DONE (Parallel : %d) - Ordered  %d records in %d ms',[FOrderDef.Orderdatakey,G_TCDM.ParallelWorkers,Ftransdata.TransformedCount,fst]);
        FOrdered.GetOrCreateFiltercontainer(Filterdef,FFiltered);
        FRm.AssignFiltering(FFiltered);
        if FFiltered.IsFilled then
          FMyComputeState := cs_RangeProcessing
        else
          FMyComputeState := cs_NeedFilterFilling;
        continue := true;
      end;
    cs_DeliverRange:
      begin
        continue := false;
      end;
    cs_NeedFilterFilling:
      begin
        Fet := GFRE_BT.Get_Ticks_ms;
        GFRE_DBI.LogInfo(dblc_DBTDM,'<NEW FILTERING FILLING FOR FILTERKEY[%s] DONE in %d ms / Potential (%d)',[FFiltered.FilterDataKey,fet-fst,FFiltered.FCnt]);
        FMyComputeState := cs_RangeProcessing;
        continue := true;
      end
    else
      GFRE_BT.CriticalAbort(classname+' workable interface failed invalid state/WorkDone');
  end;
end;


procedure TFRE_DB_QUERY.WorkDone_WIF;
var ses : TFRE_DB_UserSession;
begin { In context of Netserver Channel Group }
  if assigned(FSyncEvent) then
    begin
      FSyncEvent.SetEventWithData(self);
    end
  else
    begin
      if GFRE_DBI.NetServ.FetchSessionByIdLocked(FQueryId.SessionID,ses) then
        try
          if not ses.DispatchCoroutine(TFRE_APSC_CoRoutine(@Ses.COR_AnswerGridData),self) then
            Free;
        finally
          ses.UnlockSession;
        end;
    end;
end;

procedure TFRE_DB_QUERY.ErrorOccurred_WIF(const ec: NativeInt; const em: string);
begin
  FError        := true;
  FErrorString  := em;
end;




{ TFRE_DB_TRANFORMED_DATA }

procedure TFRE_DB_TRANFORMED_DATA.TransformSingleUpdate(const util: TFRE_DB_TRANSFORM_UTIL_DATA; const in_object: IFRE_DB_Object; const upd_idx: NativeInt; const parentpath_full: TFRE_DB_StringArray; const transkey: TFRE_DB_TransStepId);
begin
  MyTransForm(-1,-1,false,trans_Update,upd_idx,false,parentpath_full,nil,transkey,-1,in_object,util);
end;

procedure TFRE_DB_TRANFORMED_DATA.TransformSingleInsert(const util: TFRE_DB_TRANSFORM_UTIL_DATA; const in_object: IFRE_DB_Object; const rl_ins: boolean; const parent_tr_obj: TFRE_DB_TRANSFORM_UTIL_DATA; const transkey: TFRE_DB_TransStepId);
begin
  if assigned(parent_tr_obj) then
    MyTransForm(-1,-1,false,trans_SingleInsert,-1,rl_ins,parent_tr_obj.GetExtendedParentPath,parent_tr_obj,transkey,-1,in_object,util)
  else
    MyTransForm(-1,-1,false,trans_SingleInsert,-1,rl_ins,[''],nil,transkey,-1,in_object,util)
end;

procedure TFRE_DB_TRANFORMED_DATA.TransformFetchAll;
begin
  CleanUp;   { retransform ? }
  FConnection         :=  G_TCDM.DBC(FTDDBName).Implementor_HC as TFRE_DB_CONNECTION;
  FSystemConnection   := FConnection.SYS.Implementor as TFRE_DB_SYSTEM_CONNECTION;
  if FSystemConnection.CollectionExists(nil,FParentCollectionName) then
    begin
      FParentCollection := FSystemConnection.GetCollection(nil,FParentCollectionName).Implementor as TFRE_DB_COLLECTION;
      FIsInSysstemDB    := true;
    end
  else
    FParentCollection   := FConnection.GetCollection(FParentCollectionName).Implementor as TFRE_DB_COLLECTION;

  FParentCollection.GetAllObjsNoRC(FObjectFetchArray);
  FRecordCount          := Length(FObjectFetchArray);
end;

procedure TFRE_DB_TRANFORMED_DATA.TransformAllParallel(const startchunk, endchunk: Nativeint ; const wid : nativeint);
begin
  MyTransForm(startchunk,endchunk,false,trans_Insert,-1,false,[''],nil,'-',wid,nil,nil);
end;


procedure TFRE_DB_TRANFORMED_DATA.MyTransForm(const start_idx, endindx: NativeInt; const lazy_child_expand: boolean; const mode: TDC_TransMode; const update_idx: NativeInt; const rl_ins: boolean; const parentpaths: TFRE_DB_StringArray;
                                              const in_parent_tr_obj: TFRE_DB_TRANSFORM_UTIL_DATA; const transkey: TFRE_DB_TransStepId; const wid: nativeint; const single_in_object: IFRE_DB_Object; util: TFRE_DB_TRANSFORM_UTIL_DATA);
var
  in_object     : IFRE_DB_Object;
  tr_obj        : TFRE_DB_Object;
  rec_cnt       : NativeInt;
  len_chld      : NativeInt;
  //utildata      : TFRE_DB_TRANSFORM_UTIL_DATA;

    procedure SetInternalFields(const tro,ino:IFRE_DB_Object);
    var oldtag,newtag : TFRE_DB_String;
    begin
      oldtag := tro.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
      newtag := ino.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
      tro.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString := newtag;
    end;

    procedure SetSpecialFields(const tro,ino:IFRE_DB_Object);
    var fld : IFRE_DB_FIELD;
    begin
      tro.Field('_menufunc_').AsString      := 'Menu';
      tro.Field('_contentfunc_').AsString   := 'Content';
      //tro.Field('children').AsString        := 'UNCHECKED';
      //if ino.FieldOnlyExisting('icon',fld) then // icon in source
      //  tro.Field('icon').AsString:= FREDB_getThemedResource(fld.AsString); // icon in transformed
    end;

    {FParentChildStopOnLeaves, FParentChildFilterClasses, FParentChildSkipClasses}
    procedure TransFormChildsForUid(const parent_tr_obj : IFRE_DB_Object ; const parentpath : string ; const depth : NativeInt ; const in_uid : TFRE_DB_GUID);
    var j           : NativeInt;
        refd_uids   : TFRE_DB_GUIDArray;
        refd_objs   : IFRE_DB_ObjectArray;
        len_chld    : NativeInt;
        in_chld_obj : IFRE_DB_Object;
        in_ch_class : ShortString;
        stop        : boolean;
        utilc       : TFRE_DB_TRANSFORM_UTIL_DATA;
    begin
     refd_uids     := FConnection.GetReferencesNoRightCheck(in_uid,FParentLinksChild,FParentChildScheme,FParentChildField);
     len_chld := 0;
     if length(refd_uids)>0 then
       begin
         CheckDbResult(FConnection.BulkFetchNoRightCheck(refd_uids,refd_objs),'transform childs');
         for j:=0 to high(refd_objs) do
           begin
             in_chld_obj  := refd_objs[j];
             in_ch_class  := in_chld_obj.Implementor_HC.ClassName;
             try
               stop := FREDB_StringInNametypeArray(in_ch_class,FParentChildStopOnLeaves);
               if FREDB_StringInNametypeArray(in_ch_class,FParentChildFilterClasses) then
                 begin
                  continue; { skip the object as a whole}
                 end;
               if FREDB_StringInNametypeArray(in_ch_class,FParentChildSkipSchemes) then
                 begin
                   SetSkippedParentChildScheme(in_uid,in_chld_obj.UID,in_ch_class);
                   TransFormChildsForUid(parent_tr_obj,parentpath,depth+1,refd_uids[j]); { this is the initial fill case, next step transfrom children recursive, but they are now root nodes }
                 end
               else
                 begin
                   inc(rec_cnt);
                   inc(len_chld);
                   utilc     := TFRE_DB_TRANSFORM_UTIL_DATA.Create;
                   tr_obj    := FTransform.TransformInOut(FConnection,in_chld_obj,utilc);
                   utilc.UtilSetTransformedObject(tr_obj);
                   SetInternalFields(tr_obj,in_chld_obj);
                   SetSpecialFields(tr_obj,in_chld_obj);
                   utilc.AddParentPath(parentpath);
                   FTransdatalock.Acquire;
                   try
                     SetTransformedObject(utilc); // tr_obj;
                   finally
                     FTransdatalock.Release;
                   end;
                   if not stop then
                     TransFormChildsForUid(tr_obj,FREDB_PP_ExtendParentPath(refd_uids[j],parentpath),depth+1,refd_uids[j]); { recurse }
                 end;
             finally
               refd_objs[j].Finalize;
             end;
           end;
         SetLength(refd_objs,0);
       end;
     if assigned(parent_tr_obj) then { not assigned = skipped root }
       begin
         parent_tr_obj.Field(cFRE_DB_CLN_CHILD_CNT).AsInt32 := len_chld;
         if len_chld>0 then
           parent_tr_obj.Field(cFRE_DB_CLN_CHILD_FLD).AsString := cFRE_DB_CLN_CHILD_FLG;
       end;
    end;

    var rc           : NativeInt;
        i            : NativeInt;
        ino_up_class : ShortString;

begin
  rec_cnt := 0;
  case mode of
    trans_Insert:
      begin
        try
          for i := start_idx to endindx do
            begin
              in_object    := FObjectFetchArray[i];
              util         := TFRE_DB_TRANSFORM_UTIL_DATA.Create;
              ino_up_class := uppercase(in_object.Implementor_HC.ClassName);
              if IncludesChildData then
                begin
                  if FREDB_StringInNametypeArray(ino_up_class,FParentChildFilterClasses) then //self
                    begin
                      { skip the object as a whole}
                    end
                  else
                    begin
                      rc := FConnection.GetReferencesCountNoRightCheck(in_object.UID,not FParentLinksChild,FParentChildScheme,FParentChildField);
                      if rc=0 then { ROOT NODE}
                        begin
                          if FREDB_StringInNametypeArray(ino_up_class,FParentChildSkipSchemes) then
                            begin
                              SetSkippedParentChildScheme(CFRE_DB_NullGUID,in_object.UID,ino_up_class);
                              TransFormChildsForUid(nil,'',0,in_object.UID); { this is the initial fill case, next step transfrom children recursive, but they are now root nodes }
                            end
                          else
                            begin
                              tr_obj := FTransform.TransformInOut(FConnection,in_object,util);
                              util.UtilSetTransformedObject(tr_obj);
                              inc(rec_cnt);
                              FTransdatalock.Acquire;
                              try
                                SetTransformedObject(util); // tr_obj
                              finally
                                FTransdatalock.Release;
                              end;
                              util.AddParentPath('');//  FREDB_PP_AddParentPathToObj(tr_obj,''); { this is a root node }
                              SetInternalFields(tr_obj,in_object);
                              SetSpecialFields(tr_obj,in_object);
                              TransFormChildsForUid(tr_obj,tr_obj.UID_String,0,tr_obj.UID); { this is the initial fill case, next step transfrom children recursive }
                            end;
                         end;
                    end;
                end
              else
                begin
                   tr_obj := FTransform.TransformInOut(FConnection,in_object,util);
                   util.UtilSetTransformedObject(tr_obj);
                   inc(rec_cnt);
                   FTransdatalock.Acquire;
                   try
                     SetTransformedObject(util); // tr_obj
                   finally
                     FTransdatalock.Release;
                   end;
                   util.AddParentPath(''); //FREDB_PP_AddParentPathToObj(tr_obj,''); { this is a root node }
                   SetInternalFields(tr_obj,in_object);
                end;
            end; { for }
        finally
          for i := start_idx to endindx do
            begin
              in_object := FObjectFetchArray[i];
              in_object.Finalize;
              FObjectFetchArray[i]:=nil;
            end;
        end;
      end;
    trans_SingleInsert:
      begin
        ino_up_class := uppercase(single_in_object.Implementor_HC.ClassName);
        util   := TFRE_DB_TRANSFORM_UTIL_DATA.Create;
        tr_obj := FTransform.TransformInOut(FConnection,single_in_object,util);
        util.UtilSetTransformedObject(tr_obj);
        util.SetParentPaths(parentpaths);
        SetSpecialFields(tr_obj,single_in_object);
        SetInternalFields(tr_obj,single_in_object);
        HandleInsertTransformedObject(util,in_parent_tr_obj);
      end;
    trans_Update:
      begin
        util         := TFRE_DB_TRANSFORM_UTIL_DATA.Create;
        ino_up_class := uppercase(single_in_object.Implementor_HC.ClassName);
        tr_obj       := FTransform.TransformInOut(FConnection,single_in_object,util);
        util.UtilSetTransformedObject(tr_obj);
        SetSpecialFields(tr_obj,single_in_object);
        util.SetParentPaths(parentpaths);
        SetInternalFields(tr_obj,single_in_object);
        if IncludesChildData then
          begin
            len_chld := FConnection.GetReferencesCountNoRightCheck(single_in_object.UID,FParentLinksChild,FParentChildScheme,FParentChildField);
            tr_obj.Field(cFRE_DB_CLN_CHILD_CNT).AsInt32 := len_chld;
            if len_chld>0 then
              tr_obj.Field(cFRE_DB_CLN_CHILD_FLD).AsString := cFRE_DB_CLN_CHILD_FLG;
          end;
        HandleUpdateTransformedObject(util,update_idx);
        { do not handle child updates now, they will get handled on field update event of the parent }
      end;
  end;
end;

function TFRE_DB_TRANFORMED_DATA.TransformedCount: NativeInt;
begin
  result := FTransformedData.Count;
end;

function TFRE_DB_TRANFORMED_DATA.IncludesChildData: Boolean;
begin
  result := FDCHasParentChildRefRelationDefined;
end;

function TFRE_DB_TRANFORMED_DATA.HasReflinksInTransform: Boolean;
begin
  result := FTransform.HasReflinksInTransform;
end;

function TFRE_DB_TRANFORMED_DATA.IsReflinkSpecRelevant(const rlspec: TFRE_DB_NameTypeRL): boolean;
begin
  result := FTransform.IsReflinkSpecRelevant(rlspec);
end;

procedure TFRE_DB_TRANFORMED_DATA._AssertCheckTransid(const obj: IFRE_DB_Object; const transkey: TFRE_DB_TransStepId);
var otid : TFRE_DB_TransStepId;
begin
  otid := obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
  if otid<>transkey then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'Modification Transid not matching : [%s <> %s]',[otid,transkey]);
end;

procedure TFRE_DB_TRANFORMED_DATA.Cleanup;
begin
  FTransformedData.Clear;
end;

function TFRE_DB_TRANFORMED_DATA.FindParentIndex(paruid: TFRE_DB_GUID; out rootinsert: boolean): Nativeint;
var us    : ShortString;
    skip  : TFRE_DB_SKIP_ENC;
begin
  rootinsert := false;
  repeat
    result := ExistsObjDirect(paruid);
    if result<0 then { not found }
      begin
        us   := FREDB_G2SB(paruid);
        skip := FSkipSkipped.Find(us) as TFRE_DB_SKIP_ENC;
        if assigned(skip) then
          begin
            paruid := skip.parent_uid;
            if paruid=CFRE_DB_NullGUID then
              begin
                rootinsert:=true;
                exit(0);
              end;
            continue;
          end;
        break;
      end
    else
      begin
        exit;
      end;
  until false;
  result := -1;
end;

procedure TFRE_DB_TRANFORMED_DATA.UpdateObjectByNotify(const obj: IFRE_DB_Object ; const transkey: TFRE_DB_TransStepId);
var idx  : NativeInt;
    tupo : TFRE_DB_Object;
    ppfa : TFRE_DB_StringArray;
    root : boolean;
    util : TFRE_DB_TRANSFORM_UTIL_DATA;
    dta  : TFRE_DB_TRANSFORM_UTIL_DATA_ARR;
    i    : NativeInt;
    od: TFRE_DB_TRANSFORMED_ORDERED_DATA;

    procedure ReTransformUpdate(const dta : TFRE_DB_TRANSFORM_UTIL_DATA_ARR ; const transkey: TFRE_DB_TransStepId);
    var
      i: NativeInt;
    begin
      for i:=0 to high(dta) do
       begin
         UpdateObjectByNotify(dta[i].GetObject,transkey);
       end;
    end;

begin
  _AssertCheckTransid(obj,transkey);
  idx  := FindParentIndex(obj.UID,root); { Check if the Object Exists in the current Transformed Data}  //self
  ppfa := nil;
  if idx>=0 then
    begin
      util  := FTransformedData.Items[idx] as TFRE_DB_TRANSFORM_UTIL_DATA;
      tupo  := util.GetObject;
      ppfa  := util.GetParentPaths;
      GFRE_DBI.LogDebug(dblc_DBTDM,'   >NOTIFY UPDATE OBJECT [%s] AGAINST TRANSDATA [%s] PARENTPATH [%s]',[obj.GetDescriptionID,FKey.GetBaseDataKey,FREDB_CombineString(ppfa,',')]);
      TransformSingleUpdate(util,obj,idx,ppfa,transkey);
    end
  else
    begin
      GFRE_DBI.LogDebug(dblc_DBTDM,'   >NOTIFY SKIP UPDATE OBJECT [%s] AGAINST TRANSDATA [%s] PARENTPATH [%s] OBJECT NOT FOUND',[obj.GetDescriptionID,FKey.GetBaseDataKey,FREDB_CombineString(ppfa,',')]);
      { not needed - dont clone }
    end;
  if HasReflinksInTransform and { }
      true then
        begin
          G_DEBUG_COUNTER:=1;
          //if CheckReferenceBackLink(obj.UID,dta) then
          //  ReTransformUpdate(dta,transkey);
        end;
end;

procedure TFRE_DB_TRANFORMED_DATA.InsertObjectByNotify(const coll_name: TFRE_DB_NameType; const obj: IFRE_DB_Object; const rl_ins: boolean; const parent: TFRE_DB_GUID; const transkey: TFRE_DB_TransStepId);
var idx   : NativeInt;
    rooti : boolean;
    pud   : TFRE_DB_TRANSFORM_UTIL_DATA;

begin
  _AssertCheckTransid(obj,transkey);
  if rl_ins or (uppercase(coll_name) =  FKey.Collname) then
    begin
      if rl_ins then { Reflink update (tree), fetch parent,  set parentpath} //self
        begin
          idx := FindParentIndex(parent,rooti);
          if idx>=0 then
            begin
              if rooti then
                begin
                  GFRE_DBI.LogDebug(dblc_DBTDM,' >NOTIFY INSERT OBJECT [%s] AGAINST TRANSDATA [%s] COLL [%s] IS A REFLINK UPDATE (SKIPCLASSES/ROOT)',[obj.GetDescriptionID,FKey.GetBaseDataKey,coll_name]);
                  TransformSingleInsert(nil,obj.CloneToNewObject(),true,nil,transkey);
                end
              else
                begin
                  GFRE_DBI.LogDebug(dblc_DBTDM,' >NOTIFY INSERT OBJECT [%s] AGAINST TRANSDATA [%s] COLL [%s] IS A REFLINK UPDATE',[obj.GetDescriptionID,FKey.GetBaseDataKey,coll_name]);
                  pud := FTransformedData.Items[idx] as TFRE_DB_TRANSFORM_UTIL_DATA;
                  TransformSingleInsert(nil,obj.CloneToNewObject(),true,pud,transkey); { Frees the object }
                end;
            end
          else
            GFRE_DBI.LogDebug(dblc_DBTDM,' >SKIP NOT FOUND / NOTIFY INSERT OBJECT [%s] AGAINST TRANSDATA [%s] COLL [%s] IS A REFLINK UPDATE',[obj.GetDescriptionID,FKey.GetBaseDataKey,coll_name]);
        end
      else
        begin { root insert }
          //GFRE_DBI.LogDebug(dblc_DBTDM,' >NOTIFY INSERT OBJECT [%s] AGAINST TRANSDATA [%s] COLL [%s] IS A COLLECTION UPDATE',[obj.GetDescriptionID,FKey.key,coll_name]);
          idx := FindParentIndex(obj.UID,rooti);
          if idx>=0 then
            begin
              if IncludesChildData then
                GFRE_DBI.LogDebug(dblc_DBTDM,' >SKIP EXISTING NOTIFY INSERT OBJECT [%s] AGAINST TRANSDATA [%s] COLL [%s]',[obj.GetDescriptionID,FKey.GetBaseDataKey,coll_name])
                 { the object got highly probably updated by an rl insert, via reflinks, so skip double transform}
              else
                raise EFRE_DB_Exception.Create(edb_ERROR,'td updateobjectbynotify failed - already found, but not a parent child relation')
            end
          else
            begin
              GFRE_DBI.LogDebug(dblc_DBTDM,' >NOTIFY INSERT OBJECT [%s] AGAINST TRANSDATA [%s] COLL [%s] IS A COLLECTION UPDATE',[obj.GetDescriptionID,FKey.GetBaseDataKey,coll_name]);
              TransformSingleInsert(nil,obj.CloneToNewObject(),false,nil,transkey); { Frees the object }
            end;
        end;
    end
  else
    begin { skip,  dont clone }
      {
        not needed, this is no direct collection update
        RL Updates are processed with the RL Events
      }
    end;
end;


procedure TFRE_DB_TRANFORMED_DATA.RemoveObjectByNotify(const coll_name: TFRE_DB_NameType; const obj: IFRE_DB_Object; const rl_rem: boolean; const parent: TFRE_DB_GUID; const transkey: TFRE_DB_TransStepId);
var idx,pidx : NativeInt;
    root     : Boolean;
    util     : TFRE_DB_TRANSFORM_UTIL_DATA;
begin
  if rl_rem or (uppercase(coll_name) =  FKey.Collname) then
    begin
      idx := FindParentIndex(obj.UID,root);
      if idx>=0 then
        begin
          if rl_rem then
            begin
              pidx := FindParentIndex(parent,root);
              util := FTransformedData.Items[pidx] as TFRE_DB_TRANSFORM_UTIL_DATA;
            end
          else
            begin
              util := nil;
            end;
          HandleDeleteTransformedObject(idx,util,transkey)
        end
      else
        begin
          if IncludesChildData then
            { the object got highly probably removed by an rl drop, via reflinks, so skip double delete try }
          else
            raise EFRE_DB_Exception.Create(edb_NOT_FOUND,'td removeobjectbynotify failed - not found / but not a childquery data');
        end;
    end;
end;


procedure TFRE_DB_TRANFORMED_DATA.SetupOutboundRefLink(const from_obj: IFRE_DB_Object ; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const transkey: TFRE_DB_TransStepId);
var idx : NativeInt;
begin
  if IncludesChildData and
     FREDB_CompareReflinkSpecs(FParentChildLinkFldSpec,key_description) then
       begin
         idx := ExistsObjDirect(to_obj.UID);
         if idx>=0 then
         //  raise EFRE_DB_Exception.Create(edb_EXISTS,'td setupoutbound rl - exists')
         else
           InsertObjectByNotify('',to_obj,true,from_obj.UID,transkey)
       end;
  if HasReflinksInTransform and { Reflinks that are dirctly in the transform and in the transformed result set }
      true then
        begin
          if IsReflinkSpecRelevant(key_description) then
            begin
              writeln('OUTBOUND ADD  MATCH ',self.FKey.GetBaseDataKey,' ',to_obj.DumpToString());
              G_DEBUG_COUNTER:=1;
            end;
          { TODO - handle that right }
        end;
end;

procedure TFRE_DB_TRANFORMED_DATA.SetupInboundRefLink(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const transkey: TFRE_DB_TransStepId);
var idx : NativeInt;
begin
  if IncludesChildData and
     FREDB_CompareReflinkSpecs(FParentChildLinkFldSpec,key_description) then  //self
       begin
         idx := ExistsObjDirect(from_obj.UID);
         if idx>=0 then
           //raise EFRE_DB_Exception.Create(edb_EXISTS,'td setupinbound rl - exists')
         else
           InsertObjectByNotify('',from_obj,true,to_obj.UID,transkey)
       end;
  if HasReflinksInTransform and IsReflinkSpecRelevant(key_description) then
    UpdateObjectByNotify(to_obj,to_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString); { the object pointed to by the link is not updated by the link itself (!), todo -> HINT only filterchange if TRANSID of NEW and STORED SAME }
end;

procedure TFRE_DB_TRANFORMED_DATA.InboundReflinkDropped(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const transkey: TFRE_DB_TransStepId);
var idx : NativeInt;
begin
  if IncludesChildData and
     FREDB_CompareReflinkSpecs(FParentChildLinkFldSpec,key_description) then // self
       begin
         idx := ExistsObjDirect(from_obj.UID);
         if idx<0 then
           begin
             //raise EFRE_DB_Exception.Create(edb_NOT_FOUND,'td inboundrldropped - not found')
           end
         else
           RemoveObjectByNotify('',from_obj,true,to_obj.UID,transkey)
       end;
  if HasReflinksInTransform and IsReflinkSpecRelevant(key_description) then
    UpdateObjectByNotify(to_obj,to_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString); { the object pointed to by the link is not updated by the link itself (!), todo -> HINT only filterchange if TRANSID of NEW and STORED SAME }
end;

procedure TFRE_DB_TRANFORMED_DATA.OutboundReflinkDropped(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const transkey: TFRE_DB_TransStepId);
var idx : NativeInt;
begin
  if IncludesChildData and
     FREDB_CompareReflinkSpecs(FParentChildLinkFldSpec,key_description) then
       begin
         idx := ExistsObjDirect(to_obj.UID);
         if idx<0 then
         //  raise EFRE_DB_Exception.Create(edb_EXISTS,'td outboundrldropped - not found')
         else
           RemoveObjectByNotify('',to_obj,true,from_obj.uid,transkey)
       end;
  if HasReflinksInTransform and
      true then
        begin
          if IsReflinkSpecRelevant(key_description) then
            begin
              writeln('OUTBOUND DROP  MATCH ',self.FKey.GetBaseDataKey,' ',to_obj.DumpToString());
              G_DEBUG_COUNTER:=1;
            end;
        end;
end;

function TFRE_DB_TRANFORMED_DATA.ExistsObjDirect(const uid: TFRE_DB_GUID): NativeInt;
var us : ShortString;
begin
  us := FREDB_G2SB(UID);
  result := FTransformedData.FindIndexOf(us);
end;


procedure TFRE_DB_TRANFORMED_DATA.SetTransformedObject(const utildata: TFRE_DB_TRANSFORM_UTIL_DATA);
var us     : ShortString;
    ob     : TFRE_DB_Object;
    i      : NativeInt;
    ppa    : TFRE_DB_StringArray;
    utilo  : TFRE_DB_TRANSFORM_UTIL_DATA;
    trob   : IFRE_DB_Object;
begin
  trob  := utildata.GetObject;
  us    := FREDB_G2SB(trob.UID);
  utilo := FTransformedData.Find(us) as TFRE_DB_TRANSFORM_UTIL_DATA;
  if assigned(utilo) then
    begin
      ob    := utilo.GetObject;
      if ob.UID=trob.UID then
        begin
          ppa := utilo.GetParentPaths;
          if length(ppa)<>1 then
            raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected double add / there should be exactly one parentpath');
          utilo.AddParentPath(ppa[0]);
        end
      else
        raise EFRE_DB_Exception.Create(edb_ERROR,'hash collision / double add / transformed data');
    end
  else
    begin
      FTransformedData.Add(us,utildata);
      //InsertReferenceBackLinks(utildata);
    end;
end;

procedure TFRE_DB_TRANFORMED_DATA.SetSkippedParentChildScheme(const parent_uid, child_uid: TFRE_DB_GUID; const child_class: ShortString);
var us   : ShortString;
    ob   : TObject;
    i    : NativeInt;
    ppa  : TFRE_DB_StringArray;
    skip : TFRE_DB_SKIP_ENC;
    ud   : TFRE_DB_TRANSFORM_UTIL_DATA;

    procedure AddSkippedUid(const s : TFRE_DB_SKIP_ENC);
    begin
      SetLength(s.skipped_uid,Length(s.skipped_uid)+1);
      s.skipped_uid[high(s.skipped_uid)] := child_uid;
    end;

begin
    skip := TFRE_DB_SKIP_ENC.Create;
    skip.parent_uid   := parent_uid;
    skip.skippd_class := child_class;
    AddSkippedUid(skip);

    us := FREDB_G2SB(parent_uid);
    ob := FSkipParent.Find(us) as TObject;
    if assigned(ob) then
      begin
        AddSkippedUid(ob as TFRE_DB_SKIP_ENC);
      end
    else
      FSkipParent.Add(us,skip);

    us := FREDB_G2SB(child_uid);
    ud := FTransformedData.Find(us) as TFRE_DB_TRANSFORM_UTIL_DATA;
    //ob := ud.GetObject;
    if assigned(ud) then
      raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected double add / skipclass (A) [%s][%s][%s]',[parent_uid.AsHexString,child_uid.AsHexString,child_class])
    else
      FSkipSkipped.Add(us,skip);
end;

procedure TFRE_DB_TRANFORMED_DATA.SetTransObjectSingleInsert(const utildata: TFRE_DB_TRANSFORM_UTIL_DATA);
begin
  SetTransformedObject(utildata); { currently no need to diversificate }
end;

procedure TFRE_DB_TRANFORMED_DATA.HandleUpdateTransformedObject(const utildata: TFRE_DB_TRANSFORM_UTIL_DATA; const upd_idx: NativeInt);
var old_o   : TFRE_DB_Object;
    i       : NativeInt;
    od      : TFRE_DB_TRANSFORMED_ORDERED_DATA;
    transid : TFRE_DB_TransStepId;
    utilo   : TFRE_DB_TRANSFORM_UTIL_DATA;
    tr_obj  : IFRE_DB_Object;

begin
  tr_obj := utildata.GetObject;
  GFRE_DBI.LogDebug(dblc_DBTDM,'   TRANSFORMED OBJECT UPDATE [%s] AGAINST ALL ORDERINGS FOR BASEDATA [%s]',[tr_obj.UID_String,FKey.GetBaseDataKey]);
  utilo  := FTransformeddata.Items[upd_idx] as TFRE_DB_TRANSFORM_UTIL_DATA;
  old_o  := utilo.GetObject;
  tr_obj := utildata.GetObject;
  try
    FTransformedData.Delete(upd_idx);      { all orderings now point to the dangling removed object}
    SetTransformedObject(utildata);       { new object in hashlist }
    transid := tr_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
    for i := 0 to FOrderings.Count-1 do
      begin
        od := FOrderings.Items[i] as TFRE_DB_TRANSFORMED_ORDERED_DATA;
        GFRE_DBI.LogDebug(dblc_DBTDM,'   >MATCH UPDATE OBJECT [%s] IN ORDERING [%s]',[tr_obj.UID_String,od.FOrderDef.Orderdatakey]);
        od.Notify_UpdateIntoTree(utilo,utildata,transid); { propagate update up}
      end;
  finally
    //RemoveReferenceBacklinks(utilo); { diasbled ATM }
  end;
end;

procedure TFRE_DB_TRANFORMED_DATA.HandleInsertTransformedObject(const utildata: TFRE_DB_TRANSFORM_UTIL_DATA; const parent_tud: TFRE_DB_TRANSFORM_UTIL_DATA);
var  i       : NativeInt;
    od       : TFRE_DB_TRANSFORMED_ORDERED_DATA;
    transid  : TFRE_DB_TransStepId;
    childchg : boolean;
    tr_obj   : IFRE_DB_Object;

  function CheckParentObjectChildcountChange:boolean;
  var pcc           : NativeInt;
      pflag         : string;
      tid2          : TFRE_DB_TransStepId;
      parent_object : TFRE_DB_Object;
  begin
    result := false;
    if assigned(parent_tud) then
      begin
        parent_object := parent_tud.GetObject;
        pflag := parent_object.Field(cFRE_DB_CLN_CHILD_FLD).AsString;
        if pflag='' then
          pcc := 0
        else
          pcc := parent_object.Field(cFRE_DB_CLN_CHILD_CNT).AsInt32;
        parent_object.Field(cFRE_DB_CLN_CHILD_FLD).AsString     := cFRE_DB_CLN_CHILD_FLG;
        parent_object.Field(cFRE_DB_CLN_CHILD_CNT).AsInt32      := pcc+1;
        tid2 := tr_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
        parent_object.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString := tid2; { TAG Changed / Fake TAG (Childcount/not in db) }
        result := true;
      end;
  end;

begin
  tr_obj  := utildata.GetObject;
  GFRE_DBI.LogDebug(dblc_DBTDM,'   TRANSFORMED OBJECT INSERT [%s] AGAINST ALL ORDERINGS FOR BASEDATA [%s]',[tr_obj.UID_String,FKey.GetBaseDataKey]);
  SetTransObjectSingleInsert(utildata); { new object in hashlist }
  transid := tr_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
  childchg := CheckParentObjectChildcountChange;
  for i := 0 to FOrderings.Count-1 do
    begin
      od := FOrderings.Items[i] as TFRE_DB_TRANSFORMED_ORDERED_DATA;
      GFRE_DBI.LogDebug(dblc_DBTDM,'   >MATCH INSERT OBJECT [%s] IN ORDERING [%s]',[tr_obj.UID_String,od.FOrderDef.Orderdatakey]);
      od.Notify_InsertIntoTree(utildata,transid); { propagate new object up}
      if childchg then
        od.Notify_ChildCountChange(transid,parent_tud);
    end;
end;

procedure TFRE_DB_TRANFORMED_DATA.HandleDeleteTransformedObject(const del_idx: NativeInt; const parent_tud: TFRE_DB_TRANSFORM_UTIL_DATA; transtag: TFRE_DB_TransStepId);
var del_o    : TFRE_DB_Object;
    i        : NativeInt;
    childchg : boolean;
    util     : TFRE_DB_TRANSFORM_UTIL_DATA;
    parent_object : TFRE_DB_Object;

  function CheckParentObjectChildcountChange:boolean;
  var pcc        : NativeInt;
      //pflag      : string;
  begin
   result := false;
   if assigned(parent_tud) then
     begin
       parent_object := parent_tud.GetObject;
       pcc   := parent_object.Field(cFRE_DB_CLN_CHILD_CNT).AsInt32;
       //pflag := parent_object.Field(cFRE_DB_CLN_CHILD_FLD).AsString;
       if pcc=0 then
         raise EFRE_DB_Exception.Create(edb_ERROR,'unexpected CheckParentObjectChildCountChange '+inttostr(pcc));
       if pcc>1 then
         parent_object.Field(cFRE_DB_CLN_CHILD_FLD).AsString := cFRE_DB_CLN_CHILD_FLG
       else
         parent_object.DeleteField(cFRE_DB_CLN_CHILD_FLD);
       parent_object.Field(cFRE_DB_CLN_CHILD_CNT).AsInt32      := pcc-1;
       parent_object.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString := transtag;
       result := true;
     end;
  end;

begin
  util  := FTransformeddata.Items[del_idx] as TFRE_DB_TRANSFORM_UTIL_DATA;
  del_o := util.GetObject;
  GFRE_DBI.LogDebug(dblc_DBTDM,'   TRANSFORMED OBJECT DELETE [%s] AGAINST ALL ORDERINGS FOR BASEDATA [%s]',[del_o.UID_String,FKey.GetBaseDataKey]);
  try
    childchg := CheckParentObjectChildcountChange;
    FTransformedData.Delete(del_idx);   { all orderings now point to the dangling removed object}
    for i := 0 to FOrderings.Count-1 do
     begin
       (FOrderings.Items[i] as TFRE_DB_TRANSFORMED_ORDERED_DATA).Notify_DeleteFromTree(util,transtag); { propagate old object up}
       if childchg then
         (FOrderings.Items[i] as TFRE_DB_TRANSFORMED_ORDERED_DATA).Notify_ChildCountChange(transtag,parent_tud);
     end;
  finally
    //RemoveReferenceBacklinks(util);
  end;
end;

procedure TFRE_DB_TRANFORMED_DATA.InsertReferenceBackLinks(const utildata: TFRE_DB_TRANSFORM_UTIL_DATA);
var us     : ShortString;
    rlb    : TFRE_DB_TRANSFORM_BACKLINK;
    i      : NativeInt;
    exrefs : TFRE_DB_GUIDArray;
begin
  exrefs := utildata.GetExpandedReferences;
  for i:=0 to high(exrefs) do
    begin
      us := exrefs[i].AsBinaryString;
      rlb := FTransformBacklinks.Find(us) as TFRE_DB_TRANSFORM_BACKLINK;
      if not assigned(rlb) then
        begin
          rlb := TFRE_DB_TRANSFORM_BACKLINK.Create;
          rlb.ToUid := exrefs[i];
          FTransformBacklinks.Add(us,rlb);
        end;
      rlb.AddBackLink(utildata);
    end;
end;

procedure TFRE_DB_TRANFORMED_DATA.RemoveReferenceBacklinks(const utildata: TFRE_DB_TRANSFORM_UTIL_DATA);
var us     : ShortString;
    rlb    : TFRE_DB_TRANSFORM_BACKLINK;
    i      : NativeInt;
    idx    : NativeInt;
    exrefs : TFRE_DB_GUIDArray;
begin
  exrefs := utildata.GetExpandedReferences;
  for i := 0 to high(exrefs) do
    begin
      us  := exrefs[i].AsBinaryString;
      idx := FTransformBacklinks.FindIndexOf(us);
      rlb := FTransformBacklinks.Items[idx] as TFRE_DB_TRANSFORM_BACKLINK;
      if not assigned(rlb) then
        raise EFRE_DB_Exception.Create(edb_ERROR,'unexcpected, could not find backlink');
      rlb.RemoveBacklink(utildata);
      if rlb.BacklinkCount=0 then
        FTransformBacklinks.Delete(idx);
    end;
end;

function TFRE_DB_TRANFORMED_DATA.CheckReferenceBackLink(const searchuid : TFRE_DB_GUID ; out dependend_transformed: TFRE_DB_TRANSFORM_UTIL_DATA_ARR): boolean;
var us     : ShortString;
    rlb    : TFRE_DB_TRANSFORM_BACKLINK;
begin
  us     := searchuid.AsBinaryString;
  rlb    := FTransformBacklinks.Find(us) as TFRE_DB_TRANSFORM_BACKLINK;
  result := assigned(rlb);
  if result then
    dependend_transformed := rlb.GetDependendObjects;
end;

function TFRE_DB_TRANFORMED_DATA.GetTransFormKey: TFRE_DB_TRANS_COLL_DATA_KEY;
begin
  result := FKey;
end;

procedure TFRE_DB_TRANFORMED_DATA.CheckIntegrity;

  procedure CheckInt(const ino : TFRE_DB_Object);
  var obj : IFRE_DB_Object;
  begin
   try
    obj := ino.CloneToNewObject();
    obj.Finalize;
    obj := ino.CloneToNewObject();
    obj.Finalize;
    obj := ino.CloneToNewObject();
    obj.Finalize;
   except
     on e : exception do
      begin
        writeln('TD Integrity Check Failed ',e.Message,' ',FKey.GetBaseDataKey);
        halt;
      end;
   end;
  end;

begin
  ForAllObjs(@CheckInt);
end;

//procedure TFRE_DB_TRANFORMED_DATA.TransformAll(var rcnt: NativeInt);
//begin
//  TransformAllTo(G_TCDM.DBC(FTDDBName),self,FChildDataIsLazy,rcnt);
//end;


constructor TFRE_DB_TRANFORMED_DATA.Create(const qry: TFRE_DB_QUERY; const transform: IFRE_DB_TRANSFORMOBJECT; const data_parallelism: nativeint);
begin
  FKey                                := qry.Orderdef.CacheDataKey;
  Fkey.orderkey                       := '';                        { this is unordered, the orderkey comes from the frist query generating the data }

  FChildDataIsLazy                    := False;

  FParentCollectionName               := qry.Orderdef.CacheDataKey.Collname;
  FIsChildQuery                       := qry.FIsChildQuery;
  FParentLinksChild                   := qry.FParentLinksChild;
  FParentChildScheme                  := qry.FParentChildScheme;
  FParentChildField                   := qry.FParentChildField;
  FParentChildSkipSchemes             := qry.FParentChildSkipschemes;
  FParentChildFilterClasses           := qry.FParentChildFilterClasses;
  FParentChildLinkFldSpec             := qry.FParentChildLinkFldSpec;
  FParentChildStopOnLeaves            := qry.FParentChildStopOnLeaves;
  FDCHasParentChildRefRelationDefined := FParentChildLinkFldSpec<>'';

  FTransform                          := transform.Implementor as TFRE_DB_TRANSFORMOBJECT;
  FTDCreationTime                     := GFRE_DT.Now_UTC;
  FTransformedData                    := TFPHashObjectList.Create(false);
  FSkipSkipped                        := TFPHashObjectList.Create(false);
  FTransformBacklinks                 := TFPHashObjectList.Create(True);
  FSkipParent                         := TFPHashObjectList.Create(true);
  FOrderings                          := TFPObjectList.Create(false);
  FTDDBName                           := qry.QryDBName;
  FParallelCount                      := data_parallelism;
  GFRE_TF.Get_Lock(FTransdatalock);
end;

destructor TFRE_DB_TRANFORMED_DATA.Destroy;
begin
  FOrderings.Clear;
  FTransdatalock.Finalize;
  FTransformBacklinks.Free;
  inherited Destroy;
end;

procedure TFRE_DB_TRANFORMED_DATA.ForAllObjs(const forall: TFRE_DB_Obj_Iterator);
var i  : NativeInt;
    ud : TFRE_DB_TRANSFORM_UTIL_DATA;
begin
  for i:=0 to FTransformedData.Count-1 do
   begin
     ud := FTransformedData.Items[i] as TFRE_DB_TRANSFORM_UTIL_DATA;
     forall(ud.GetObject);
   end;
end;

procedure TFRE_DB_TRANFORMED_DATA.ForAllTransformed(const forall: TFRE_DB_TRANSFORM_UTIL_DATA_ITERATOR);
var i  : NativeInt;
    ud : TFRE_DB_TRANSFORM_UTIL_DATA;
begin
  for i:=0 to FTransformedData.Count-1 do
   begin
     ud := FTransformedData.Items[i] as TFRE_DB_TRANSFORM_UTIL_DATA;
     forall(ud);
   end;
end;

procedure TFRE_DB_TRANFORMED_DATA.AddOrdering(const ordering: TFRE_DB_TRANSFORMED_ORDERED_DATA);
begin
  if FOrderings.IndexOf(ordering)<>-1 then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'double add ordering');
  FOrderings.Add(ordering);
end;

procedure TFRE_DB_TRANFORMED_DATA.RemoveOrdering(const ordering: TFRE_DB_TRANSFORMED_ORDERED_DATA);
var idx : NativeInt;
begin
  idx := FOrderings.IndexOf(ordering);
  if idx=-1 then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'ordering not found on remove');
  FOrderings.Delete(idx);
end;

{ TFRE_DB_TRANSDATA_MANAGER }

function TFRE_DB_TRANSDATA_MANAGER.GetNewOrderDefinition: TFRE_DB_DC_ORDER_DEFINITION_BASE;
begin
  result := TFRE_DB_DC_ORDER_DEFINITION.Create;
end;

function TFRE_DB_TRANSDATA_MANAGER.GetNewFilterDefinition(const filter_db_name: TFRE_DB_NameType): TFRE_DB_DC_FILTER_DEFINITION_BASE;
begin
  result := TFRE_DB_DC_FILTER_DEFINITION.Create(filter_db_name);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ForAllQueryRangeMgrs(const rm_iter: TFRE_DB_RANGE_MGR_ITERATOR);

  procedure Scan(var dummy : PtrUInt);
  var r : TFRE_DB_SESSION_DC_RANGE_MGR;
  begin
    r := TFRE_DB_SESSION_DC_RANGE_MGR(FREDB_PtrUIntToObject(dummy));
    rm_iter(r);
  end;

begin
   FArtRangeMgrs.LinearScan(@Scan);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ForAllQueryRangeMgrsSession(const rm_iter: TFRE_DB_RANGE_MGR_ITERATOR; const sessionprefix: TFRE_DB_SESSION_ID);

  procedure Scan(var value : PtrUInt ; const Key : PByte ; const KeyLen : PtrUInt ; var break : boolean);
  var r : TFRE_DB_SESSION_DC_RANGE_MGR;
  begin
    r := TFRE_DB_SESSION_DC_RANGE_MGR(FREDB_PtrUIntToObject(value));
    rm_iter(r);
  end;

begin
   FArtRangeMgrs.PrefixStringScan(sessionprefix,@Scan);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ForAllFilterContainers(const filter_iter: TFRE_DB_FILTER_CONTAINER_ITERATOR);

  procedure OrderIter(const order : TFRE_DB_TRANSFORMED_ORDERED_DATA);
  begin
    order.ForAllFilters(filter_iter);
  end;

begin
  ForAllOrders(@OrderIter);
end;

function TFRE_DB_TRANSDATA_MANAGER.GetBaseTransformedData(base_key: TFRE_DB_CACHE_DATA_KEY; out base_data: TFRE_DB_TRANFORMED_DATA): boolean;
begin
  base_data := nil;
  base_key  := UpperCase(base_key);
  base_data :=  TObject(FTransList.Find(base_key)) as TFRE_DB_TRANFORMED_DATA;
  result    := assigned(base_data);
  GFRE_DBI.LogDebug(dblc_DBTDM,'BASE TRANSFORMED DATA FOR [%s] %s',[base_key,BoolToStr(result,'FOUND','NOT FOUND')]);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.AddBaseTransformedData(const base_data: TFRE_DB_TRANFORMED_DATA);
var key : TFRE_DB_CACHE_DATA_KEY;
begin
  key := base_data.FKey.GetBaseDataKey;
  if FTransList.FindIndexOf(key)<>-1 then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'tdm - double add basedata');
  FTransList.Add(key,base_data);
end;

procedure TFRE_DB_TRANSDATA_MANAGER._ForAllOrders(obj: Pointer; arg: Pointer);
begin
  TFRE_DB_TRANSFORMED_ORDERED_DATA_ITERATOR(arg^)((TObject(obj) as TFRE_DB_TRANSFORMED_ORDERED_DATA));
end;

procedure TFRE_DB_TRANSDATA_MANAGER._ForAllTransforms(obj: Pointer; arg: Pointer);
begin
  TFRE_DB_TRANFORMED_DATA_ITERATOR(arg^)((TObject(obj) as TFRE_DB_TRANFORMED_DATA));
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ForAllOrders(const order_iter: TFRE_DB_TRANSFORMED_ORDERED_DATA_ITERATOR);
begin
  FOrders.ForEachCall(@_ForAllOrders,@order_iter);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ForAllTransformed(const trans_iter: TFRE_DB_TRANFORMED_DATA_ITERATOR);
begin
  FTransList.ForEachCall(@_ForAllTransforms,@trans_iter);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.TL_StatsTimer;
var cnt  : NativeInt;
    fcnt : NativeInt;

  procedure CountFilters(const order : TFRE_DB_TRANSFORMED_ORDERED_DATA);
  begin
    cnt  := cnt  + order.GetFiltersCount;
    fcnt := fcnt + order.GetFilledFiltersCount;
  end;

  procedure Debug_Checkup(const order : TFRE_DB_TRANSFORMED_ORDERED_DATA);
  begin
    order.DebugCheckintegrity;
  end;

begin
  cnt  := 0;
  fcnt := 0;
  //FOrders.Clear;
  // FOrders.ForAll(@CountFilters); BAD LOCKING
  //FOrders.ForAll(@Debug_Checkup);
  //GFRE_DB.LogDebug(dblc_DBTDM,'> TM STATS Queries (%d) Transforms (%d) Orders (%d) Filters/FilledFilters (%d/%d)',[FArtQueryStore.GetValueCount,FTransList.Count,FOrders.Count,cnt,fcnt]);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.AssertCheckTransactionID(const obj: IFRE_DB_Object; const transid: TFRE_DB_TransStepId);
var ttag : TFRE_DB_TransStepId;
begin
  ttag := obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
  if ttag <>transid then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'transaction id mismatch OBJ=[%s] NOTIFY=[%s]',[ttag,transid]);
end;

//procedure TFRE_DB_TRANSDATA_MANAGER.CheckChildCountChangesAndTag(const parent_obj: IFRE_DB_Object);
//
//  procedure CheckUpdates(const rmg : TFRE_DB_SESSION_DC_RANGE_MGR);
//  begin
//    rmg.ProcessChildObjCountChange(parent_obj);
//  end;
//
//begin
//  ForAllQueryRangeMgrs(@CheckUpdates);
//end;

procedure TFRE_DB_TRANSDATA_MANAGER.StartNotificationBlock(const key: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogDebug(dblc_DBTDM,'->>> NOTIFY : START INBOUND NOTIFICATION BLOCK  [%s]',[Key]);
  if assigned(FCurrentNotify) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'logic/a notify block is currently assigned');
  FCurrentNotify := TFRE_DB_TRANSDATA_CHANGE_NOTIFIER.Create(key);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.FinishNotificationBlock(out block: IFRE_DB_Object);

  procedure HandleTaggedQueries(const rmg : TFRE_DB_SESSION_DC_RANGE_MGR);
  begin
     rmg.HandleTagged;
  end;


begin
  if not assigned(FCurrentNotify) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'logic/no notify block is currently assigned');

  GFRE_DBI.LogDebug(dblc_DBTDM,'-> NOTIFY : START QRY TAG SCAN TID [%s]',[FCurrentNotify.TransKey]);
  ForAllQueryRangeMgrs(@HandleTaggedQueries);
  GFRE_DBI.LogDebug(dblc_DBTDM,'<- NOTIFY : END QRY TAG SCAN [%s]',[FCurrentNotify.TransKey]);

  FCurrentNotify.NotifyAll;
  FreeAndNil(FCurrentNotify);
  GFRE_DBI.LogDebug(dblc_DBTDM,'<<<-DONE NOTIFY : END INBOUND NOTIFICATION BLOCK ---');

end;

procedure TFRE_DB_TRANSDATA_MANAGER.SendNotificationBlock(const block: IFRE_DB_Object);
begin
  abort;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.CollectionCreated(const coll_name: TFRE_DB_NameType; const in_memory_only: boolean; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.CollectionDeleted(const coll_name: TFRE_DB_NameType; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.IndexDefinedOnField(const coll_name: TFRE_DB_NameType; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean; const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.IndexDroppedOnField(const coll_name: TFRE_DB_NameType; const index_name: TFRE_DB_NameType; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ObjectStored(const coll_name: TFRE_DB_NameType; const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  begin
    tcd.InsertObjectByNotify(coll_name,obj.CloneToNewObject(),false,CFRE_DB_NullGUID,tsid);
  end;

begin
  AssertCheckTransactionID(obj,tsid);
  if coll_name='' then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'collname not set on ObjectStored Notification');
    GFRE_DBI.LogDebug(dblc_DBTDM,'-> NOTIFY : START OBJECT STORED [%s] in Collection [%s]',[obj.GetDescriptionID,coll_name]);
    ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
    GFRE_DBI.LogDebug(dblc_DBTDM,'<- NOTIFY : END  OBJECT STORED [%s] in Collection [%s]',[obj.GetDescriptionID,coll_name]);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ObjectDeleted(const coll_names: TFRE_DB_NameTypeArray; const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
var logcolls : string;
  { if an object is finally deleted the reflinks from the objects are removed (if possible) }

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  var i : NativeInt;
  begin
    for i:=0 to high(coll_names) do
      tcd.RemoveObjectByNotify(coll_names[i],obj,false,CFRE_DB_NullGUID,tsid);
  end;

  procedure LogEntry;
  begin
    logcolls := FREDB_CombineString(FREDB_NametypeArray2StringArray(coll_names),',');
    GFRE_DBI.LogDebug(dblc_DBTDM,'-> NOTIFY : START OBJECT DELETED [%s] in Collections [%s]',[obj.GetDescriptionID,logcolls]);
  end;

  procedure LogLeave;
  begin
    GFRE_DBI.LogDebug(dblc_DBTDM,'<- NOTIFY : END   OBJECT DELETED [%s] in Collections [%s]',[obj.GetDescriptionID,logcolls]);
  end;

begin
  AssertCheckTransactionID(obj,tsid);
  GFRE_DBI.LogDebugIf(dblc_DBTDM,@LogEntry);
  ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
  GFRE_DBI.LogDebugIf(dblc_DBTDM,@LogLeave);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ObjectUpdated(const obj: IFRE_DB_Object; const colls: TFRE_DB_StringArray; const tsid: TFRE_DB_TransStepId);

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  begin
    tcd.UpdateObjectByNotify(obj,tsid);
  end;

begin
  AssertCheckTransactionID(obj,tsid);
  GFRE_DBI.LogDebug(dblc_DBTDM,'-> NOTIFY : START OBJECT UPDATED [%s] in Collections [%s]',[obj.GetDescriptionID,FREDB_CombineString(colls,',')]);
  FCurrentNotify.AddDirectSessionUpdateEntry(obj.CloneToNewObject);
  ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
  GFRE_DBI.LogDebug(dblc_DBTDM,'<- NOTIFY : END   OBJECT UPDATED [%s] in Collections [%s]',[obj.GetDescriptionID,FREDB_CombineString(colls,',')]);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.DifferentiallUpdStarts(const obj_uid: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.FieldDelete(const old_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.FieldAdd(const new_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.FieldChange(const old_field, new_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.DifferentiallUpdEnds(const obj_uid: TFRE_DB_GUID; const tsid: TFRE_DB_TransStepId);
begin
end;

procedure TFRE_DB_TRANSDATA_MANAGER.ObjectRemoved(const coll_names: TFRE_DB_NameTypeArray; const obj: IFRE_DB_Object; const is_a_full_delete: boolean; const tsid: TFRE_DB_TransStepId);
begin
  { if an object is only removed from a collection the reflinks from the objects stay the same }
  if not is_a_full_delete then
    begin
      GFRE_DBI.LogDebug(dblc_DBTDM,'--->>>>>>>>> COLLECTION ONLY REMOVE NOT HANDLED BY NOTIFY ? / TEST IT // NOTIFY : START OBJECT REMOVED [%s] in Collection [%s]',[obj.GetDescriptionID,FREDB_CombineString(FREDB_NametypeArray2StringArray(coll_names),',')]);
    end;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.SetupOutboundRefLink(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  begin
    tcd.SetupOutboundReflink(from_obj.CloneToNewObject,to_obj.CloneToNewObject,key_description,tsid); { must do all tagging inside (reflinks) relevant }
  end;

begin
  ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
end;

procedure TFRE_DB_TRANSDATA_MANAGER.SetupInboundRefLink(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  begin
    tcd.SetupInboundRefLink(from_obj.CloneToNewObject,to_obj.CloneToNewObject,key_description,tsid);
  end;

begin
  ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
end;

procedure TFRE_DB_TRANSDATA_MANAGER.InboundReflinkDropped(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  begin
    tcd.InboundReflinkDropped(from_obj.CloneToNewObject,to_obj.CloneToNewObject,key_description,tsid);
  end;

begin
  ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
end;

procedure TFRE_DB_TRANSDATA_MANAGER.OutboundReflinkDropped(const from_obj: IFRE_DB_Object; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);

  procedure CheckIfNeeded(const tcd : TFRE_DB_TRANFORMED_DATA);
  begin
    tcd.OutboundReflinkDropped(from_obj.CloneToNewObject,to_obj.CloneToNewObject,key_description,tsid);
  end;

begin
  ForAllTransformed(@CheckIfNeeded); { search all base transforms for needed updates ... }
end;

//procedure TFRE_DB_TRANSDATA_MANAGER.ChildObjCountChange(const parent_obj: IFRE_DB_Object);
//begin
//  CheckChildCountChangesAndTag(parent_obj);
//end;

procedure TFRE_DB_TRANSDATA_MANAGER.FinalizeNotif;
begin

end;

function TFRE_DB_TRANSDATA_MANAGER.DBC(const dblname: TFRE_DB_NameType): IFRE_DB_CONNECTION;
begin
  CheckDbResult(GFRE_DB.NetServer.GetDBWithServerRights(dblname,result),'TCDM - could not fetch admin dbc '+dblname);
end;

constructor TFRE_DB_TRANSDATA_MANAGER.Create;
begin
  FOrders        := TFPHashList.Create;
  FTransList     := TFPHashList.Create;
  FArtRangeMgrs  := TFRE_ART_TREE.Create;
  FParallelCnt   := cFRE_INT_TUNE_TDM_COMPUTE_WORKERS;
  GFRE_SC.CreateNewChannelGroup('CT',FTransCompute,cFRE_INT_TUNE_TDM_COMPUTE_WORKERS);
  FStatTimer     := FTransCompute.AddChannelGroupTimer('TDMSTAT',1000,@s_StatTimer,true);
end;

destructor TFRE_DB_TRANSDATA_MANAGER.Destroy;
begin
  FArtRangeMgrs.Free;
  Forders.Free; { TODO : Free Transformations, Free Orders}
  FTransList.Free;
  inherited Destroy;
end;

function TFRE_DB_TRANSDATA_MANAGER.GetTransformedOrderedData(const qry: TFRE_DB_QUERY_BASE; var cd: TFRE_DB_TRANSFORMED_ORDERED_DATA): boolean;
var fkd : TFRE_DB_CACHE_DATA_KEY;
begin
  fkd    := lowercase(TFRE_DB_QUERY(qry).Orderdef.Orderdatakey);
  cd     := TObject(FOrders.Find(fkd)) as TFRE_DB_TRANSFORMED_ORDERED_DATA;
  result := assigned(cd);
  GFRE_DBI.LogDebug(dblc_DBTDM,'>GET ORDERING FOR TRANSFORMED DATA FOR [%s] %s',[fkd,BoolToStr(result,'FOUND','NOT FOUND')]);
end;


function TFRE_DB_TRANSDATA_MANAGER.CreateTransformedOrdered(const generating_qry: TFRE_DB_QUERY): TFRE_DB_TRANSFORMED_ORDERED_DATA;
begin
   result := TFRE_DB_TRANSFORMED_ORDERED_DATA.Create(generating_qry.FOrderDef,generating_qry.Ftransdata);     { generate the ordered, transformed data (next layer) }
   if not cFRE_DBG_DISABLE_TRANS_ORDER_STORE then
     begin
       if FOrders.FindIndexOf(lowercase(result.FOrderDef.Orderdatakey))<>-1 then
         raise EFRE_DB_Exception.Create(edb_INTERNAL,'tdm - double add order');
       FOrders.Add(lowercase(result.FOrderDef.Orderdatakey),result);
     end;
end;

function TFRE_DB_TRANSDATA_MANAGER.GenerateQueryFromQryDef(const qry_def: TFRE_DB_QUERY_DEF): TFRE_DB_QUERY_BASE;
var qry : TFRE_DB_QUERY;

   procedure ProcessDependencies;
   var i : NativeInt;
   begin
     if qry.FIsChildQuery then { do not process dependencies for child queries ( check with client ) }
       exit;
     SetLength(qry.FDependencyIds,Length(qry_def.DependencyRefIds));
     for i:=0 to high(qry.FDependencyIds) do
      qry.FDependencyIds[i] := uppercase(qry_def.DependencyRefIds[i]);
     qry.FDepRefConstraints  := qry_def.DepRefConstraints;
     qry.FDependcyFilterUids := qry_def.DepFilterUids;
   end;

   procedure ProcessOrderDefinition;
   begin
     qry.Orderdef.AssignFrom(qry_def.OrderDefRef);
     qry.Orderdef.SetDataKeyColl(qry_def.ParentName,qry_def.DerivedCollName);
     qry.OrderDef.Seal;
   end;

   procedure ProcessCheckChildQuery;
   begin
     with qry do begin
       FParentChildLinkFldSpec   := qry_def.ParentChildSpec;          { comes from dc }
       FParentChildScheme        := qry_def.ParentChildScheme;
       FParentChildField         := qry_def.ParentChildField;
       FParentLinksChild         := qry_def.ParentLinksChild;
       FParentChildSkipschemes   := qry_def.ParentChildSkipSchemes;   { comes from dc }
       FParentChildFilterClasses := qry_def.ParentChildFilterClasses;
       FParentChildStopOnLeaves  := qry_def.ParentChildStopOnLeaves;
       if qry_def.ParentPath<>'' then
         begin { this is a child query }
           Filterdef.AddParentFilter('*SPCF*',qry_def.ParentPath); { add a parent field filter }
           FIsChildQuery := true;
         end
       else
         begin
           Filterdef.AddChildFilter('*SPCF*'); { add a child filter }
           FIsChildQuery := false;
         end;
     end;
   end;

   procedure ProcessRange;
   begin
     with qry do
       begin
         FStartIdx        := qry_def.StartIdx;
         FEndIndex        := qry_def.EndIndex;
         //FToDeliverCount  := qry_def.ToDeliverCount;
       end;
   end;

   procedure ProcessCheckFulltextFilter;
   begin
     if qry_def.FullTextFilter<>'' then
       begin
         qry.Filterdef.AddStringFieldFilter('*FTX*','FTX_SEARCH',qry_def.FullTextFilter,dbft_PART);
       end
     else
       begin
         qry.Filterdef.RemoveFilter('*FTX*');
       end;
   end;

   procedure Processfilters;
   begin
     qry.Filterdef.AddStdRightObjectFilter('*SRF*',[sr_FETCH],qry_def.UserTokenRef.CloneToNewUserToken);
     qry.Filterdef.AddFilters(qry_def.FilterDefStaticRef,true);
     qry.Filterdef.AddFilters(qry_def.FilterDefDynamicRef,true);
     qry.Filterdef.AddFilters(qry_def.FilterDefDependencyRef,true);
     qry.Filterdef.Seal;
   end;

   procedure SetQueryID;
   begin
     qry.FQueryId.Setup4QryId(qry_def.SessionID,qry.FOrderDef.CacheDataKey,qry.Filterdef.GetFilterKey,qry_def.ParentPath);
     qry.FQueryDescr    := Format('QRY(%s)',[qry.FQueryId.GetFullKeyString]);
   end;

begin
  qry             := TFRE_DB_QUERY.Create(qry_def.DBName);
  qry.FOnlyOneUID := qry_def.OnlyOneUID;
  if qry.FOnlyOneUID<>CFRE_DB_NullGUID then
    qry.FUidPointQry:=true;
  ProcessCheckChildQuery;
  ProcessDependencies;
  ProcessOrderDefinition;
  ProcessRange;
  ProcessCheckFulltextFilter;
  ProcessFilters;
  SetQueryID;
  Result := qry;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.CN_AddDirectSessionUpdateEntry(const update_dbo: IFRE_DB_Object);
begin
  if not assigned(FCurrentNotify) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'internal/current notify gatherer not assigned / direct session update entry');
  GFRE_DBI.LogDebug(dblc_DBTDM,'         >CN_DIRECT SESSION UPDATE');
  GFRE_DBI.LogDebug(dblc_DBTDM,'           >%s',[update_dbo.DumpToString(15)]);
  FCurrentNotify.AddDirectSessionUpdateEntry(update_dbo);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.CN_AddGridInplaceUpdate(const sessionid: TFRE_DB_NameType; const store_id, store_id_dc: TFRE_DB_String; const upo: IFRE_DB_Object; const oldpos, newpos, abscount: NativeInt);
begin
  if not assigned(FCurrentNotify) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'internal/current notify gatherer not assigned / grid inplace update');
  GFRE_DBI.LogDebug(dblc_DBTDM,'         >CN_INPLACE UPDATE SES[%s]  STORE[%s] POS/ABS[%d->%d/%d]',[sessionid,store_id,oldpos,newpos,abscount]);
  GFRE_DBI.LogDebug(dblc_DBTDM,'           >%s',[upo.DumpToString(15)]);
  FCurrentNotify.AddGridInplaceUpdate(sessionid,store_id,store_id_dc,upo,oldpos,newpos,abscount);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.CN_AddGridInplaceDelete(const sessionid: TFRE_DB_NameType; const store_id, store_id_dc: TFRE_DB_String; const del_id: TFRE_DB_String; const position, abscount: NativeInt);
begin
  if not assigned(FCurrentNotify) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'internal/current notify gatherer not assigned / grid delete');
  GFRE_DBI.LogDebug(dblc_DBTDM,'         >CN_DELETE UPDATE SES[%s]  STORE[%s] DEL ID [%s] POS/ABS[%d/%d]',[sessionid,store_id,del_id,position,abscount]);
  FCurrentNotify.AddGridRemoveUpdate(sessionid,store_id,store_id_dc,del_id,position,abscount);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.CN_AddGridInsertUpdate(const sessionid: TFRE_DB_NameType; const store_id, store_id_dc: TFRE_DB_String; const upo: IFRE_DB_Object; const position, abscount: NativeInt);
begin
  if not assigned(FCurrentNotify) then
    raise EFRE_DB_Exception.Create(edb_ERROR,'internal/current notify gatherer not assigned / grid insert update');
  GFRE_DBI.LogDebug(dblc_DBTDM,'         >CN_INSERT UPDATE SES[%s]  STORE[%s] POS/ABS[%d/%d]',[sessionid,store_id,position,abscount]);
  GFRE_DBI.LogDebug(dblc_DBTDM,'           >%s',[upo.DumpToString(15)]);
  FCurrentNotify.AddGridInsertUpdate(sessionid,store_id,store_id_dc,upo,position,abscount);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.UpdateLiveStatistics(const stats: IFRE_DB_Object);
var stat_entry : IFRE_DB_Object;

  procedure SearchStatQuery(const mgr : TFRE_DB_SESSION_DC_RANGE_MGR);
  var storeid : TFRE_DB_NameType;
      ct      : TFRE_DB_UPDATE_STORE_DESC;
      entry   : IFRE_DB_Object;
      change  : IFRE_DB_Object;
      i       : Integer;

      function FinalTransFormUPO:boolean;
      var ses : TFRE_DB_UserSession;
      begin
        result := false;
        abort; // how ?
        //if not GFRE_DBI.NetServ.FetchSessionByIdLocked(mgr.FSessionID,ses) then
        //  begin
        //    GFRE_DBI.LogWarning(dblc_DBTDM,'> SESSION [%s] NOT FOUND ON UPDATE/INSERT mgR(?)',[mgr.FSessionID]);
        //    exit;
        //  end
        //else
        //  begin
        //    try
        //      change := entry.CloneToNewObject;
        //      mgr.FBaseData.FBaseTransData.FDC.FinalRightTransform(ses,change);
        //      result := true;
        //    finally
        //      ses.UnlockSession;
        //    end;
        //  end;
      end;

      var statmethod : TMethod;
          statmfld   : IFRE_DB_Field;

      type
        tstatclassm = procedure(const transformed_output : IFRE_DB_Object ; const stat_data : IFRE_DB_Object ; const statfieldname : TFRE_DB_Nametype) of object;

  begin
    storeid := mgr.GetStoreID;
    //if mgr.FBaseData.FBaseTransData.FDC.HasStatTransforms then
    //  begin
    //    for i:=0 to high(mgr.FResultDBOs) do
    //      if mgr.FResultDBOs[i].UID=stat_entry.Field('statuid').AsGUID then
    //          begin
    //            if mgr.FResultDBOs[i].FieldOnlyExisting(cFRE_DB_SYS_STAT_METHODPOINTER,statmfld) then
    //              begin
    //                //writeln('>>>>>>>>>>>>>>>>>>>>> FOUND A STATUSUPDATE ENTRY UID  ---');
    //                //writeln(mgr.FResultDBOs[i].DumpToString());
    //                //writeln('--------- CORRESPONDING STATISTIC OBJECT ');
    //                //writeln(stat_entry.DumpToString());
    //                //writeln('---------------------');
    //                statmethod.Code := Pointer(statmfld.AsUint64);
    //                entry := mgr.FResultDBOs[i];
    //                if FinalTransFormUPO then
    //                  begin
    //                    tstatclassm(statmethod)(change,stat_entry,'status'); { after final right transform, do finally the stat transform }
    //                    ct := TFRE_DB_UPDATE_STORE_DESC.create.Describe(storeid);
    //                    ct.addUpdatedEntry(change,mgr.GetQueryID_ClientPart);
    //                    GFRE_DBI.NetServ.SendDelegatedContentToClient(mgr.FSessionID,ct);
    //                  end;
    //              end
    //            else
    //              begin
    //                writeln('>>>>>>>>>>>>>>>>>>>>> FOUND A STATUSUPDATE ENTRY UID BUT NO STATISTIC METHOD ---');
    //                writeln(mgr.FResultDBOs[i].DumpToString());
    //                writeln('--------- CORRESPONDING STATISTIC OBJECT ');
    //                writeln(stat_entry.DumpToString());
    //                writeln('---------------------');
    //              end;
    //          end;
    //  end;
  end;

  procedure MyStatsUpdate(const stat_obj:IFRE_DB_Object);
  begin
    stat_entry := stat_obj; { make it available through stack frame }
    //writeln('>>>  SEARCH FOR STATUS OBJECT : ');
    //writeln(stat_entry.DumpToString());
    //writeln('-----------------------');
    //FIXME
    //ForAllQueryRangeMgrs(@SearchStatQuery);
  end;

begin
  stats.ForAllObjects(@MyStatsUpdate);
end;

function TFRE_DB_TRANSDATA_MANAGER.GetSessionRangeManager(const qryid_rmkey: TFRE_DB_CACHE_DATA_KEY; out rm: TFRE_DB_SESSION_DC_RANGE_MGR ; const is_Queryid:boolean): boolean;
var key   : TFRE_DB_SESSION_DC_RANGE_MGR_KEY;
    rmk   : TFRE_DB_CACHE_DATA_KEY;
    dummy : PtrUInt;

begin
  result := false;
  if is_Queryid then
    begin
      key.SetupFromQryID(qryid_rmkey);
      rmk := key.GetRmKeyAsString;
    end
  else
    rmk := qryid_rmkey;
  if FArtRangeMgrs.ExistsStringKey(rmk,dummy) then
    begin
      result := true;
      rm     := TFRE_DB_SESSION_DC_RANGE_MGR(FREDB_PtrUIntToObject(dummy));
    end
  else
    begin
      result := false;
      rm     := nil;
    end;
end;

function TFRE_DB_TRANSDATA_MANAGER.CreateSessionRangeManager(const qryid: TFRE_DB_SESSION_DC_RANGE_MGR_KEY): TFRE_DB_SESSION_DC_RANGE_MGR;
var mkey_s : TFRE_DB_CACHE_DATA_KEY;
begin
  mkey_s := qryid.GetRmKeyAsString;
  result := TFRE_DB_SESSION_DC_RANGE_MGR.Create(qryid);
  if not FArtRangeMgrs.InsertStringKey(mkey_s,FREDB_ObjectToPtrUInt(result)) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'range mgr tree insert failed');
end;

procedure TFRE_DB_TRANSDATA_MANAGER.s_StatTimer(const timer: IFRE_APSC_TIMER; const flag1, flag2: boolean);
begin
  TL_StatsTimer;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.s_DropAllQueryRanges(const p: TFRE_TDM_DROPQ_PARAMS);
var rm  : TFRE_DB_SESSION_DC_RANGE_MGR;
    st  : ShortString;
    sid : TFRE_DB_SESSION_ID;

    procedure ClearRanges(const rm : TFRE_DB_SESSION_DC_RANGE_MGR);
    begin
      rm.ClearRanges;
    end;

begin
  try
   if p.whole_session then
     begin
       sid := p.qry_id;
       ForAllQueryRangeMgrsSession(@ClearRanges,sid);
       exit;
     end;
   if GetSessionRangeManager(p.qry_id,rm,true) then
     begin
       rm.ClearRanges;
     end
   else
     begin
       GFRE_DBI.LogInfo(dblc_DBTDM,'>CANNOT DROP QRY ALL RANGES FOR [%s] | NOT FOUND',[p.qry_id]);
     end;
  finally
    p.Free;
  end;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.s_DropQryRange(const p : TFRE_TDM_DROPQ_PARAMS);
var rm  : TFRE_DB_SESSION_DC_RANGE_MGR;
    st  : ShortString;
    sid : TFRE_DB_SESSION_ID;
    cd  : TFRE_DB_TRANSFORMED_ORDERED_DATA;
    fc  : TFRE_DB_FILTER_CONTAINER;

begin
  if GetSessionRangeManager(p.qry_id,rm,true) then
    begin
      case rm.DropRange(p.start_idx,p.end_idx,false) of
        rq_Bad:     st := 'BAD';
        rq_OK:      st := 'OK';
        rq_NO_DATA: st := 'NO DATA';
      end;
      GFRE_DBI.LogInfo(dblc_DBTDM,'>DROP QRY RANGE FOR [%s] STATUS [%s] RANGES [%s]',[p.qry_id,st,rm.DumpRangesCompressd]);
    end
  else
    begin
      GFRE_DBI.LogInfo(dblc_DBTDM,'>DROP QRY RANGE FOR [%s] STATUS [RANGEMANAGER NOT FOUND]',[p.qry_id]);
    end;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.s_InboundNotificationBlock(const block: IFRE_DB_Object);
var dummy : IFRE_DB_Object;
begin
  if GDBPS_DISABLE_NOTIFY then
    exit;
  self.StartNotificationBlock(Block.Field('KEY').AsString);
  try
    FREDB_ApplyNotificationBlockToNotifIF(block,self,FCurrentNLayer);
  finally
    self.FinishNotificationBlock(dummy);
  end;
end;

function TFRE_DB_TRANSDATA_MANAGER.ParallelWorkers: NativeInt;
begin
  result := FParallelCnt;
end;

procedure TFRE_DB_TRANSDATA_MANAGER.cs_DropAllQueryRanges(const qry_id: TFRE_DB_CACHE_DATA_KEY; const whole_session: boolean);
var p   : TFRE_TDM_DROPQ_PARAMS;
begin
  p := TFRE_TDM_DROPQ_PARAMS.Create;
  p.qry_id         := qry_id;
  p.whole_session  := whole_session;
  FTransCompute.DoAsyncWorkSimpleMethod(TFRE_APSC_CoRoutine(@s_DropAllQueryRanges),p);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.cs_RemoveQueryRange(const qry_id: TFRE_DB_CACHE_DATA_KEY; const start_idx, end_idx: NativeInt);
var p : TFRE_TDM_DROPQ_PARAMS;
begin
  p := TFRE_TDM_DROPQ_PARAMS.Create;
  p.qry_id         := qry_id;
  p.start_idx      := start_idx;
  p.end_idx        := end_idx;
  FTransCompute.DoAsyncWorkSimpleMethod(TFRE_APSC_CoRoutine(@s_DropQryRange),p);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.cs_InvokeQry(const qry: TFRE_DB_QUERY_BASE; const transform: IFRE_DB_SIMPLE_TRANSFORM; const return_cg: IFRE_APSC_CHANNEL_GROUP; const ReqID: Qword; const sync_event: IFOS_E);
var lqry : TFRE_DB_QUERY;
begin
  lqry := qry as TFRE_DB_QUERY;
  lqry.CaptureStartTime;
  lqry.SetupWorkingContextAndStart(FTransCompute,transform,return_cg,ReqID,sync_event);
end;

procedure TFRE_DB_TRANSDATA_MANAGER.cs_InboundNotificationBlock(const dbname: TFRE_DB_NameType; const block: IFRE_DB_Object);
begin
  FTransCompute.DoAsyncWorkSimpleMethod(TFRE_APSC_CoRoutine(@s_InboundNotificationBlock),block);
end;


procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.InsertIntoTree(const tud: TFRE_DB_TRANSFORM_UTIL_DATA);
var
    Key        : Array [0..512] of Byte;
    k_len      : NativeInt;
    oc         : TFRE_DB_ORDER_CONTAINER;
    dummy      : PPtrUInt;
    byte_arr   : TFRE_DB_ByteArray;
    insert_obj : TFRE_DB_Object;
begin
  insert_obj := tud.GetObject;
  FOrderDef.SetupBinaryKey(tud,@key,k_len,True);

  dummy := nil;
  if FArtTreeKeyToObj.InsertBinaryKeyorFetchR(key,k_len,dummy) then
    begin
      oc := TFRE_DB_ORDER_CONTAINER.Create;
      dummy^ := FREDB_ObjectToPtrUInt(oc);
    end
  else
    oc := FREDB_PtrUIntToObject(dummy^) as TFRE_DB_ORDER_CONTAINER;
  oc.AddObject(tud);
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.ForAllFilters(const filter_iter: TFRE_DB_FILTER_CONTAINER_ITERATOR);

  procedure Iter(var dummy : PtrUInt);
  begin
    filter_iter(FREDB_PtrUIntToObject(dummy) as TFRE_DB_FILTER_CONTAINER);
  end;

begin
  FArtTreeFilterKey.LinearScan(@Iter);
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.Notify_ChildCountChange(const transtag: TFRE_DB_TransStepId; const parent_obj: TFRE_DB_TRANSFORM_UTIL_DATA);

  procedure filterccchg(const f : TFRE_DB_FILTER_CONTAINER);
  begin
     f.Notify_CheckChildCountChange(transtag,parent_obj);
  end;

begin
  ForAllFilters(@filterccchg);
end;


procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.Notify_InsertIntoTree(const new_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const transtag: TFRE_DB_TransStepId);
var
   keynew       : Array [0..512] of Byte;
   keynewlen    : NativeInt;
begin
  FOrderDef.SetupBinaryKey(new_tud,@Keynew[0],keynewlen,true);
  Notify_InsertIntoTree(@keynew[0],keynewlen,new_tud,transtag);
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.Notify_InsertIntoTree(const key: PByte; const keylen: NativeInt; const new_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const transtag: TFRE_DB_TransStepId; const propagate_up: boolean);
var
    oc       : TFRE_DB_ORDER_CONTAINER;
    dummy    : PPtrUInt;
    byte_arr,
    byte_arr2: TFRE_DB_ByteArray;

  procedure CheckAllOpenFiltersInsert(var dummy : PtrUInt); //self.FBaseTransData
  var filtercont : TFRE_DB_FILTER_CONTAINER;
  begin
    filtercont := FREDB_PtrUIntToObject(dummy) as TFRE_DB_FILTER_CONTAINER;
    filtercont.Notify_CheckFilteredInsert(self,new_tud,transtag,false);
  end;

begin
  dummy := nil;
  if FArtTreeKeyToObj.InsertBinaryKeyorFetchR(key,keylen,dummy) then
    begin
      oc := TFRE_DB_ORDER_CONTAINER.Create;
      dummy^ := FREDB_ObjectToPtrUInt(oc);
    end
  else
    oc := FREDB_PtrUIntToObject(dummy^) as TFRE_DB_ORDER_CONTAINER;
  if oc.Exists(new_tud) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'Notify Inset KEY Failed');
  oc.AddObject(new_tud);
  if propagate_up then
    begin
      FArtTreeFilterKey.LinearScan(@CheckAllOpenFiltersInsert);
    end;
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.Notify_DeleteFromTree(const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA; transtag: TFRE_DB_TransStepId);
var
   keyold       : Array [0..512] of Byte;
   keyoldlen    : NativeInt;
begin
  FOrderDef.SetupBinaryKey(old_tud,@KeyOld[0],keyoldlen,false);
  Notify_DeleteFromTree(@keyold,keyoldlen,old_tud,transtag,true);
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.Notify_DeleteFromTree(const key: PByte; const keylen: NativeInt; const old_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const transtag: TFRE_DB_TransStepId; const propagate_up: boolean);
var valueptr     : PtrUInt;
    oc           : TFRE_DB_ORDER_CONTAINER;

  procedure CheckAllOpenFiltersRemoveOrderChanged(var dummy : PtrUInt);
  var filtercont : TFRE_DB_FILTER_CONTAINER;
  begin
    filtercont := FREDB_PtrUIntToObject(dummy) as TFRE_DB_FILTER_CONTAINER;
    filtercont.Notify_CheckFilteredDelete(self,old_tud,transtag,false);
  end;

begin
  if not FArtTreeKeyToObj.ExistsBinaryKey(key,keylen,valueptr) then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'notify tree update internal / value not found');
  oc := FREDB_PtrUIntToObject(valueptr) as TFRE_DB_ORDER_CONTAINER;
  if oc.RemoveObject(old_tud) then { true = remove the (empty) ordercontaienr now }
    begin
      FArtTreeKeyToObj.RemoveBinaryKey(key,keylen,valueptr);
      assert(TFRE_DB_ORDER_CONTAINER(valueptr)=oc,'internal/logic remove failed');
      oc.free;
    end;
  if propagate_up then
    begin
      FArtTreeFilterKey.LinearScan(@CheckAllOpenFiltersRemoveOrderChanged);
    end;
end;

function TFRE_DB_TRANSFORMED_ORDERED_DATA.GetFilterContainer(const key: TFRE_DB_TRANS_COLL_FILTER_KEY; out filtercontainer: TFRE_DB_FILTER_CONTAINER): boolean;
var dummy : PtrUInt;
begin
  result := FArtTreeFilterKey.ExistsStringKey(key,dummy);
  if result then
    filtercontainer := FREDB_PtrUIntToObject(dummy) as TFRE_DB_FILTER_CONTAINER;
end;

function TFRE_DB_TRANSFORMED_ORDERED_DATA.GetOrCreateFiltercontainer(const filter: TFRE_DB_DC_FILTER_DEFINITION; out filtercontainer: TFRE_DB_FILTER_CONTAINER): boolean;
var filtkey    : TFRE_DB_TRANS_COLL_FILTER_KEY;
    dummy      : PNativeUint;
begin
  filtkey         := filter.GetFilterKey;
  dummy           := nil;
  filtercontainer := nil;
  if FArtTreeFilterKey.InsertStringKeyOrFetchR(filtkey,dummy) then
    begin
      filtercontainer := TFRE_DB_FILTER_CONTAINER.Create(GetCacheDataKey,filter,self);
      dummy^          := FREDB_ObjectToPtrUInt(FilterContainer); { clone filters into filtercontainer spec, result the filtercontainer reference,
                                                                   but manage it in the art tree, of the transformed ordered data }
      result          := true;
    end
  else
    begin
      filtercontainer := FREDB_PtrUIntToObject(dummy^) as TFRE_DB_FILTER_CONTAINER;
      result          := false;
      GFRE_DBI.LogInfo(dblc_DBTDM,'>REUSING FILTERING FOR BASEDATA FOR FILTERKEY [%s] [%s]',[FilterContainer.FilterDataKey,BoolToStr(filtercontainer.IsFilled,'FILLED','NOT FILLED')]);
    end;
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.FillFilterContainer(const filtercontainer: TFRE_DB_FILTER_CONTAINER; const startchunk, endchunk: Nativeint; const wid: NativeInt);
var brk : boolean;

    procedure IteratorBreak(var dummy : PtrUInt ; var halt : boolean);
    var oc : TFRE_DB_ORDER_CONTAINER;

        procedure MyIter(const tud : TFRE_DB_TRANSFORM_UTIL_DATA);
        begin
          filtercontainer.CheckFilteredAdd(tud);
        end;

    begin
      oc := FREDB_PtrUIntToObject(dummy) as TFRE_DB_ORDER_CONTAINER;
      oc.ForAllInOC(@MyIter);
    end;

begin
  if not filtercontainer.IsFilled then
    begin
      brk := false;
      FArtTreeKeyToObj.LinearScanBreak(@IteratorBreak,brk,false);
      FilterContainer.IsFilled := true;
      FilterContainer.AdjustLength;
    end
  else
    raise EFRE_DB_Exception.Create(edb_ERROR,'filling a already filled filtercontainer [%s] is senseless ',[filtercontainer.FilterDataKey]);
end;


procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.Notify_UpdateIntoTree(const old_tud, new_tud: TFRE_DB_TRANSFORM_UTIL_DATA; const transtag: TFRE_DB_TransStepId);
var
   keyold,
   keynew       : Array [0..512] of Byte;
   keyoldlen,
   keynewlen    : NativeInt;
   orderchanged : boolean;
   valueptr     : PtrUInt;
   oc           : TFRE_DB_ORDER_CONTAINER;

   procedure CheckAllOpenFiltersNoOrderChanged(var dummy : PtrUInt);
   var filtercont : TFRE_DB_FILTER_CONTAINER;
   begin
     filtercont := FREDB_PtrUIntToObject(dummy) as TFRE_DB_FILTER_CONTAINER;
     filtercont.Notify_CheckFilteredUpdate(self,old_tud,new_tud,false,transtag);
   end;

   procedure CheckAllOpenFiltersOrderChanged(var dummy : PtrUInt);
   var filtercont : TFRE_DB_FILTER_CONTAINER;
   begin
     filtercont := FREDB_PtrUIntToObject(dummy) as TFRE_DB_FILTER_CONTAINER;
     filtercont.Notify_CheckFilteredUpdate(self,old_tud,new_tud,true,transtag);
   end;

begin
  FOrderDef.SetupBinaryKey(old_tud,@KeyOld[0],keyoldlen,false);
  FOrderDef.SetupBinaryKey(new_tud,@keynew[0],keynewlen,true);
  orderchanged := (keyoldlen <> keynewlen) or
                  (CompareByte(keynew[0],keyold[0],keyoldlen)<>0);
  if orderchanged then { Key has changed, thus order has possibly changed -> issue an remove, insert cycle ....}
    begin { todo - check if order realy changed, neighbors ?}
      GFRE_DBI.LogDebug(dblc_DBTDM,'    >POTENTIAL ORDER CHANGED / UPDATE OBJECT [%s] IN ORDERING [%s] DELETE/INSERT CYCLE IN OD',[new_tud.GetObject.UID_String,FOrderDef.Orderdatakey]);
      Notify_DeleteFromTree(@keyold[0],keyoldlen,old_tud,transtag,false);
      Notify_InsertIntoTree(@keynew[0],keynewlen,new_tud,transtag,false);
      FArtTreeFilterKey.LinearScan(@CheckAllOpenFiltersOrderChanged);
    end
  else
    begin
      if not FArtTreeKeyToObj.ExistsBinaryKey(keyold,keyoldlen,valueptr) then
        raise EFRE_DB_Exception.Create(edb_INTERNAL,'notify tree update internal / value not found');
      GFRE_DBI.LogDebug(dblc_DBTDM,'    >ORDER NOT CHANGED / UPDATE OBJECT [%s] IN ORDERING [%s]',[new_tud.GetObject.UID_String,FOrderDef.Orderdatakey]);
      oc := FREDB_PtrUIntToObject(valueptr) as TFRE_DB_ORDER_CONTAINER;
      oc.ReplaceObject(old_tud,new_tud);
      FArtTreeFilterKey.LinearScan(@CheckAllOpenFiltersNoOrderChanged);
    end;
end;


constructor TFRE_DB_TRANSFORMED_ORDERED_DATA.Create(const orderdef: TFRE_DB_DC_ORDER_DEFINITION; base_trans_data: TFRE_DB_TRANFORMED_DATA);
begin
  FOrderDef         := orderdef;
  FArtTreeKeyToObj  := TFRE_ART_TREE.Create;
  FArtTreeFilterKey := TFRE_ART_TREE.Create;
  FTOCreationTime   := GFRE_DT.Now_UTC;
  FBaseTransData    := base_trans_data;
  base_trans_data.AddOrdering(self);
end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.OrderTheData(const startchunk, endchunk: Nativeint; const wid: NativeInt);
var i       : NativeInt;

   procedure OrderArray(const tud : TFRE_DB_TRANSFORM_UTIL_DATA);
   begin
     InsertIntoTree(tud);
   end;


begin
  FArtTreeKeyToObj.Clear;
  FBaseTransData.ForAllTransformed(@OrderArray);
end;

function TFRE_DB_TRANSFORMED_ORDERED_DATA.GetOrderedDatakey: TFRE_DB_CACHE_DATA_KEY;
begin
  result := FOrderDef.Orderdatakey;
end;

function TFRE_DB_TRANSFORMED_ORDERED_DATA.GetCacheDataKey: TFRE_DB_TRANS_COLL_DATA_KEY;
begin
  result := FOrderDef.CacheDataKey;
end;

destructor TFRE_DB_TRANSFORMED_ORDERED_DATA.Destroy;
begin
  FArtTreeKeyToObj.Destroy;
  inherited Destroy;
end;


function TFRE_DB_TRANSFORMED_ORDERED_DATA.GetFiltersCount: NativeInt;
begin
  result := FArtTreeFilterKey.GetValueCount;
end;

function TFRE_DB_TRANSFORMED_ORDERED_DATA.GetFilledFiltersCount: NativeInt;

   procedure GetCount(var f : NativeUint);
   var filter : TFRE_DB_FILTER_CONTAINER;
   begin
     filter := FREDB_PtrUIntToObject(f) as TFRE_DB_FILTER_CONTAINER;
     if filter.IsFilled then
       inc(result);
   end;

 begin
   result := 0;
   FArtTreeFilterKey.LinearScan(@GetCount);
 end;

procedure TFRE_DB_TRANSFORMED_ORDERED_DATA.DebugCheckintegrity;

  procedure CheckIntegrity(var f : NativeUint);
  var filter : TFRE_DB_FILTER_CONTAINER;
  begin
    filter := FREDB_PtrUIntToObject(f) as TFRE_DB_FILTER_CONTAINER;
    filter.Checkintegrity;
  end;

begin
  FBaseTransData.CheckIntegrity;
  FArtTreeFilterKey.LinearScan(@CheckIntegrity);
end;

{ TFRE_DB_TRANSDATA_MANAGER }
procedure RangeManager_TestSuite;
var rm       : TFRE_DB_SESSION_DC_RANGE_MGR;
    fc       : TFRE_DB_FILTER_CONTAINER;
    fakekey  : TFRE_DB_TRANS_COLL_DATA_KEY;
    rmk      : TFRE_DB_SESSION_DC_RANGE_MGR_KEY;
    i        : NativeInt;
    ud       : TFRE_DB_TRANSFORM_UTIL_DATA;
    ob       : TFRE_DB_Object;

    procedure CheckRangeData(const rrr:TFRE_DB_SESSION_DC_RANGE);
    var i   : NativeInt;
        obj : IFRE_DB_Object;
        oix : NativeInt;
    begin
      write(' RRR Check (',rrr.FStartIndex,'..',rrr.FEndIndex,') ');
      for i := rrr.FStartIndex to rrr.FEndIndex do
       begin
         obj := rrr.GetAbsoluteIndexedObj(i);
         oix := obj.Field('IDX').AsInt64;
         if oix<>i then
           rm.Bailout('Fail : Range %d .. %d  Data failed idx= %d oix = %d ',[rrr.FStartIndex,rrr.FEndIndex,i,oix]);
       end;
    end;

    procedure QRCheck(const testid : Nativeint ; const s,e : NativeInt;const expected : TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;const ranges :  Array of NativeInt);
    var r   : TFRE_DB_SESSION_DC_RANGE;
        g   : TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;
        msg : String;


    begin
      write('Test ',testid,' : ');
      g := rm.FindRangeSatisfyingQuery(s,e,r,false);
      if g<>expected then
        begin
          WriteStr(msg,'Test ',testid,' failed Expexted:',expected,' got ',g);
          rm.Bailout(msg,[]);
        end;
      rm.InternalRangeCheck(ranges,@CheckRangeData);
      writeln('OK');
    end;

    procedure DRCheck(const testid : Nativeint ; const s,e : NativeInt;const expected : TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;const ranges :  Array of NativeInt);
    var r   : TFRE_DB_SESSION_DC_RANGE;
        g   : TFRE_DB_SESSION_DC_RANGE_QRY_STATUS;
        msg : String;
    begin
      write('Test ',testid,' : ');
      g := rm.DropRange(s,e,false);
      if g<>expected then
        begin
          WriteStr(msg,'Test ',testid,' failed Expexted:',expected,' got ',g);
          rm.Bailout(msg,[]);
        end;
      rm.InternalRangeCheck(ranges,@CheckRangeData);
      writeln('OK');
    end;


begin
  {
    Data is from 0 .. 100 (101)
    WARNING: Requests over the total count, no warning for first request, total count ->
    ---
    1)  Get Range 150-160 -> NO DATA
    2)  RQry : 0..9     -> |0..9  |
    3)  RQry : 20..29   -> |0..9  | |20..29|
    4)  RQry : 9..15    -> |0..15 | |20..29|
    5)  RQry : 19..22   -> |0..15 | |19..29| WARNING (Requesting already fetched Entries)
    6)  RQry : 18..18   -> |0..15 | |18..29|
    7)  RQry : 16..16   -> |0..16 | |18..29|
    8)  RQry : 17..17   -> |0..29 |
    9)  DelR : 10..19   -> |0..9  | |20..29|
    10) DelR : 0..3     -> |4..9  | |20..29|
    11) DelR : 0..4     -> |5..9  | |20..29|  WARNING (DelRange Data not in Range)
    12) RQry : 40..49   -> |5..9  | |20..29| |40..49|
    13) RQry : 60..69   -> |5..9  | |20..29| |40..49| |60..69|
    14) RQry : 10..59   -> |5..69 | WARNING (Requesting already fetched Entries)
    15) DelR : 10..19   -> |5..9  | |20..69|
    16) DelR : 30..39   -> |5..9  | |20..29| |40..69|
    17) DelR : 50..59   -> |5..9  | |20..29| |40..49| |60..69|
    18) DelR : 15..55   -> |5..9  | |60..69| WARNING (DelRange Data not in Range)
    19) RQry : 20..29   -> |5..9  | |20..29| |60..69|
    20) RQry : 40..49   -> |5..9  | |20..29| |40..49| |60..69|
    21) RQry : 6..61    -> |5..69 | WARNING (Requesting over known ranges)
    22) Clear
    23) 0..25
    24) 26..60
    25) 61..100
    26) DRange 0..40
    27) RQry : 30..120    -> |30..100 | WARNING (Requesting over known ranges)
    28) RQry : 30..120    -> |30..100 | WARNING (Requesting over known ranges)
    29) DRange 70.120 ->  |30..69 |
    30) DRange 20.40 ->   |41..69 |
    31) DRange 68.120 ->  |41..100|
    32) Clear

    TotalCount immer mitliefern

    MaxDataChange -> Events -> Range Clear

  }
  fakekey.Collname:='X';
  fc := TFRE_DB_FILTER_CONTAINER.Create(fakekey,nil,nil);
  SetLength(fc.FOBJArray,101);
  for i:=0 to high(fc.FOBJArray) do
   begin
     ud := TFRE_DB_TRANSFORM_UTIL_DATA.Create;
     ob := GFRE_DB.NewObject;
     ob.Field('IDX').AsInt64:=i;
     ud.UtilSetTransformedObject(ob);
     fc.FOBJArray[i] := ud;
   end;
  rmk.SessionID:='1';
  rm := TFRE_DB_SESSION_DC_RANGE_MGR.Create(rmk);
  rm.InternalRangeCheck([],nil);
  try
    QRCheck( 0,-1,0,rq_NO_DATA,[]);
  except
  end;
  try
    QRCheck( 0,0,-1,rq_NO_DATA,[]);
  except
  end;
  QRCheck( 1,150,160,rq_NO_DATA,[]);
  QRCheck( 2, 0, 9,rq_OK,[0,9]);
  QRCheck( 3,20,29,rq_OK,[0,9,20,29]);
  QRCheck( 4, 9,15,rq_OK,[0,15,20,29]);
  QRCheck( 5,19,22,rq_OK,[0,15,19,29]);
  QRCheck( 6,18,18,rq_OK,[0,15,18,29]);
  QRCheck( 7,16,16,rq_OK,[0,16,18,29]);
  QRCheck( 8,17,17,rq_OK,[0,29]);
  DRCheck( 9,10,19,rq_OK,[0,9,20,29]);
  DRCheck(10, 0, 3,rq_OK,[4,9,20,29]);
  DRCheck(11, 0, 4,rq_OK,[5,9,20,29]);
  QRCheck(12,40,49,rq_OK,[5,9,20,29,40,49]);
  QRCheck(13,60,69,rq_OK,[5,9,20,29,40,49,60,69]);
  QRCheck(14,10,59,rq_OK,[5,69]);
  DRCheck(15,10, 19,rq_OK,[5,9,20,69]);
  DRCheck(16,30, 39,rq_OK,[5,9,20,29,40,69]);
  DRCheck(17,50, 59,rq_OK,[5,9,20,29,40,49,60,69]);
  DRCheck(18,15, 55,rq_OK,[5,9,60,69]);
  QRCheck(19,20,29,rq_OK,[5,9,20,29,60,69]);
  QRCheck(20,40,49,rq_OK,[5,9,20,29,40,49,60,69]);
  QRCheck(21,6,61,rq_OK,[5,69]);
  rm.ClearRanges;
  QRCheck(23, 0, 25,rq_OK,[0,25]);
  QRCheck(24,26, 60,rq_OK,[0,60]);
  QRCheck(25,61,100,rq_OK,[0,100]);
  DRCheck(26, 0 ,40,rq_OK,[41,100]);
  QRCheck(27,30,120,rq_OK,[30,100]);
  QRCheck(28,30,120,rq_OK,[30,100]);
  DRCheck(29,70,120,rq_OK,[30,69]);
  DRCheck(30,20,40,rq_OK,[41,69]);
  QRCheck(31,68,120,rq_OK,[41,100]);
  rm.ClearRanges;
  QRCheck(33,10,20,rq_OK,[10,20]);
  QRCheck(34,40,50,rq_OK,[10,20,40,50]);
  QRCheck(35,70,80,rq_OK,[10,20,40,50,70,80]);
  QRCheck(36,21,75,rq_OK,[10,80]);
  rm.ClearRanges;
  QRCheck(33,10,20,rq_OK,[10,20]);
  QRCheck(34,40,50,rq_OK,[10,20,40,50]);
  QRCheck(35,70,80,rq_OK,[10,20,40,50,70,80]);
  QRCheck(36,15,69,rq_OK,[10,80]);

  rm.DumpRanges;
end;

end.

