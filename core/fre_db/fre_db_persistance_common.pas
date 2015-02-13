unit fre_db_persistance_common;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2013, FirmOS Business Solutions GmbH
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

// VOLATILE Objects are not in WAL (or Cluster) (node local)

{-$DEFINE DEBUG_STORELOCK} // Debug Storelock on Commit
{-$DEFINE DEBUG_SUBOBJECTS_STORED} // Debug Storelock on Commit
{-$DEFINE DEBUG_CONSOLE_DUMP_TRANS} // Debuglog the in transaction final updated object
{$DEFINE DEBUG_OFFENDERS}

interface

uses
  Classes,contnrs,SysUtils,FRE_SYSTEM,FRE_DB_COMMON,FRE_DB_INTERFACE,FRE_DB_CORE,FOS_ARRAYGEN,FOS_GENERIC_SORT,FOS_TOOL_INTERFACES,FOS_AlignedArray,FOS_REDBLACKTREE_GEN,
  fos_art_tree,fos_sparelistgen;

type

  TFRE_DB_Persistance_Collection=class;

  { TFRE_DB_IndexValueStore }

  TFRE_DB_IndexValueStore=class
  private
    FOBJArray  : TFRE_DB_GUIDArray;
    procedure  InternalCheck;
  public
    function    Exists           (const guid   : TFRE_DB_GUID) : boolean;
    function    Add              (const objuid : TFRE_DB_GUID) : boolean;
    procedure   StreamToThis     (const stream:TStream);
    procedure   LoadFromThis     (const stream:TStream ; const coll: TFRE_DB_PERSISTANCE_COLLECTION);
    function    ObjectCount      : NativeInt;
    procedure   AppendObjectUIDS (var uids: TFRE_DB_GUIDArray; const ascending: boolean; var down_counter, up_counter: NativeInt; const max_count: Nativeint);
    function    RemoveUID        (const guid : TFRE_DB_GUID) : boolean;
    constructor create           ;
    destructor  Destroy          ;override;
  end;

  { TFRE_DB_MM_Index }

  TFRE_DB_MM_IndexClass = class of TFRE_DB_MM_Index;

  TFRE_DB_MM_Index=class
  private
    type
      tvaltype = (val_NULL,val_ZERO,val_VAL,val_NEG);
  protected
    FIndex           : TFRE_ART_TREE;
    FIndexName       : TFRE_DB_NameType;
    FUniqueName      : TFRE_DB_NameType;
    FFieldname       : TFRE_DB_NameType;
    FUniqueFieldname : TFRE_DB_NameType;
    FFieldType       : TFRE_DB_FIELDTYPE;
    FUnique          : Boolean;
    FAllowNull       : Boolean;
    FUniqueNullVals  : Boolean;
    FIsADomainIndex  : Boolean;                      { the index key gets prefixed with a domain uid, thus is per domaind id unique }
    FCollection      : TFRE_DB_PERSISTANCE_COLLECTION_BASE;

    procedure      _InternalCheckAdd                 (const key: PByte ; const keylen : Nativeint ; const isNullVal,isUpdate : Boolean ; const obj_uid : TFRE_DB_GUID);
    procedure      _InternalCheckDel                 (const key: PByte ; const keylen : Nativeint ; const isNullVal          : Boolean ; const obj_uid : TFRE_DB_GUID);
    procedure      _InternalAddGuidToValstore        (const key: PByte ; const keylen: Nativeint; const isNullVal: boolean; const uid: TFRE_DB_GUID);
    procedure      _InternalRemoveGuidFromValstore   (const key: PByte ; const keylen: Nativeint; const isNullVal: boolean; const uid: TFRE_DB_GUID);


    function        GetStringRepresentationOfTransientKey (const isnullvalue:boolean ; const key: PByte ; const keylen: Nativeint ): String;

    function        FetchIndexedValsTransformedKey    (var obj  : TFRE_DB_GUIDArray ; const key: PByte ; const keylen : Nativeint):boolean;
    procedure       ForAllIndexedValsTransformedKeys  (var uids : TFRE_DB_GUIDArray ; const mikey,makey : PByte ; const milen,malen : NativeInt ; const ascending: boolean ; const max_count : NativeInt=-1 ; skipfirst : NativeInt=0);

    procedure       TransformToBinaryComparable       (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint); virtual; abstract;
    procedure       TransformToBinaryComparableDomain (const domid_field: TFRE_DB_FIELD; const fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint);
    class procedure TransformToBinaryComparable       (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint ; const is_casesensitive : boolean ; const invert_key : boolean = false); virtual; abstract;
    function        CompareTransformedKeys            (const key1,key2: PByte ; const keylen1,keylen2 : Nativeint) : boolean;
    procedure       StreamHeader                      (const stream: TStream);virtual;
    procedure       StreamToThis                      (const stream: TStream);virtual;
    procedure       StreamIndex                       (const stream: TStream);virtual;
    function        GetIndexDefinitionObject          : IFRE_DB_Object ;virtual ;
    function        GetIndexDefinition                : TFRE_DB_INDEX_DEF; virtual;
    procedure       LoadIndex                         (const stream: TStream ; const coll : TFRE_DB_PERSISTANCE_COLLECTION);virtual;
    class function  CreateFromStream                  (const stream: TStream ; const coll : TFRE_DB_PERSISTANCE_COLLECTION):TFRE_DB_MM_Index;
    class function  CreateFromDef                     (const def   : TFRE_DB_INDEX_DEF ; const coll : TFRE_DB_PERSISTANCE_COLLECTION):TFRE_DB_MM_Index;
    class procedure InitializeNullKey                 ; virtual ; abstract;
    function       _IndexIsFullUniqe                 : Boolean;
    function       _GetIndexStringSpec               : String;
  public
    class function   GetIndexClassForFieldtype       (const fieldtype: TFRE_DB_FIELDTYPE ; var idxclass: TFRE_DB_MM_IndexClass): TFRE_DB_Errortype;
    class procedure  GetKeyLenForFieldtype           (const fieldtype: TFRE_DB_FIELDTYPE ; var FixedKeyLen : NativeInt);inline;
    constructor Create                               (const idx_name,fieldname: TFRE_DB_NameType ; const fieldtype : TFRE_DB_FIELDTYPE ; const unique : boolean ; const collection : TFRE_DB_PERSISTANCE_COLLECTION_BASE;const allow_null : boolean;const unique_null:boolean ; const domain_idx : boolean);
    destructor  Destroy                              ; override;
    function    Indexname                            : TFRE_DB_NameType;
    function    Uniquename                           : PFRE_DB_NameType;
    procedure   FieldTypeIndexCompatCheck            (fld:TFRE_DB_FIELD); virtual; abstract;
    function    NullvalueExists                      (var vals : TFRE_DB_IndexValueStore):boolean; virtual ; abstract;
    function    NullvalueExistsForObject             (const obj             : TFRE_DB_Object):boolean;
    procedure   IndexAddCheck                        (const obj             : TFRE_DB_Object; const check_only : boolean); virtual; // Object is added
    procedure   IndexUpdCheck                        (const new_obj,old_obj : TFRE_DB_Object; const check_only : boolean); virtual; // Object gets changed
    procedure   IndexDelCheck                        (const obj,new_obj     : TFRE_DB_Object; const check_only : boolean); virtual; // Object gets deleted
    function    SupportsDataType                     (const typ : TFRE_DB_FIELDTYPE):boolean; virtual ; abstract;
    function    SupportsIndexType                    (const ix_type : TFRE_DB_INDEX_TYPE):boolean;
    function    SupportsStringQuery                  : boolean; virtual ; abstract;
    function    SupportsSignedQuery                  : boolean; virtual ; abstract;
    function    SupportsUnsignedQuery                : boolean; virtual ; abstract;
    function    SupportsRealQuery                    : boolean; virtual ; abstract;
    function    IsUnique                             : Boolean;
    function    IsDomainIndex                        : boolean;
    procedure   AppendAllIndexedUids                 (var guids : TFRE_DB_GUIDArray ; const ascending: boolean ; const max_count: NativeInt; skipfirst: NativeInt);
    procedure   AppendAllIndexedUidsDomain           (var guids : TFRE_DB_GUIDArray ; const ascending: boolean ; const max_count: NativeInt; skipfirst: NativeInt ; const domid_field: TFRE_DB_FIELD);
    function    IndexTypeTxt                         : String;
    function    IndexedCount                         (const unique_values : boolean): NativeInt;
    function    IndexIsFullyUnique                   : Boolean;
    procedure   FullClearIndex                       ;
    procedure   FullReindex                          ;
  end;


  { TFRE_DB_UnsignedIndex }

  TFRE_DB_UnsignedIndex=class(TFRE_DB_MM_Index)
  private
    class var
     nullkey         :  Array [0..16] of Byte; // Nullkey is short in every domain
     nullkeylen      : NativeInt;
  protected
    class procedure   InitializeNullKey           ; override;
  public
    procedure         TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint); override;
    class procedure   TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint ; const is_cassensitive : boolean ; const invert_key : boolean = false); override;
    procedure         SetBinaryComparableKey      (const keyvalue:qword ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean);
    class procedure   SetBinaryComparableKey      (const keyvalue:qword ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean ; const FieldType : TFRE_DB_FIELDTYPE; const invert_key : boolean = false);
    constructor       CreateStreamed              (const stream : TStream ; const idx_name, fieldname: TFRE_DB_NameType ; const fieldtype : TFRE_DB_FIELDTYPE ; const unique : boolean ; const collection : TFRE_DB_PERSISTANCE_COLLECTION;const allow_null:boolean;const unique_null:boolean; const domain_idx : boolean);
    procedure         FieldTypeIndexCompatCheck   (fld:TFRE_DB_FIELD ); override;
    function          NullvalueExists             (var vals: TFRE_DB_IndexValueStore): boolean; override;
    function          SupportsDataType            (const typ: TFRE_DB_FIELDTYPE): boolean; override;
    procedure         ForAllIndexedUnsignedRange  (const min, max: QWord; var guids :  TFRE_DB_GUIDArray ; const ascending: boolean ; const min_is_null : boolean = false ; const max_is_max : boolean = false ; const max_count : NativeInt=-1 ; skipfirst : NativeInt=0);
    function          SupportsSignedQuery         : boolean; override;
    function          SupportsUnsignedQuery       : boolean; override;
    function          SupportsStringQuery         : boolean; override;
    function          SupportsRealQuery           : boolean; override;
  end;

  { TFRE_DB_SignedIndex }

  TFRE_DB_SignedIndex=class(TFRE_DB_MM_Index)
  private
    class var
     nullkey         :  Array [0..16] of Byte; // Nullkey is short in every domain
     nullkeylen      : NativeInt;
  protected
    class procedure   InitializeNullKey           ; override;
  public
    procedure         TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint); override;
    class procedure   TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint ; const is_casesensitive : boolean ; const invert_key : boolean = false); override;
    procedure         SetBinaryComparableKey      (const keyvalue:int64 ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean);
    class procedure   SetBinaryComparableKey      (const keyvalue:int64 ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean ; const FieldType : TFRE_DB_FIELDTYPE ; const invert_key : boolean = false);
    constructor       CreateStreamed              (const stream: TStream; const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION; const allow_null: boolean; const unique_null: boolean; const domain_idx : boolean);
    procedure         FieldTypeIndexCompatCheck   (fld:TFRE_DB_FIELD ); override;
    function          NullvalueExists             (var vals: TFRE_DB_IndexValueStore): boolean; override;
    function          SupportsDataType            (const typ: TFRE_DB_FIELDTYPE): boolean; override;
    function          SupportsSignedQuery         : boolean; override;
    function          SupportsUnsignedQuery       : boolean; override;
    function          SupportsStringQuery         : boolean; override;
    function          SupportsRealQuery           : boolean; override;
    procedure         ForAllIndexedSignedRange    (const min, max: int64; var guids :  TFRE_DB_GUIDArray ; const ascending: boolean ; const min_is_null : boolean = false ; const max_is_max : boolean = false ; const max_count : NativeInt=-1 ; skipfirst : NativeInt=0);
  end;

  { TFRE_DB_RealIndex }

  TFRE_DB_RealIndex=class(TFRE_DB_MM_Index) { currently implemented via int64 * 10000 conversion (bad) -> TODO real floating point binary compare}
  private
    class var
     nullkey         :  Array [0..16] of Byte; // Nullkey is short in every domain
     nullkeylen      : NativeInt;
  protected
    class procedure   InitializeNullKey           ; override;
  public
    procedure         TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint); override;
    class procedure   TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint ; const is_casesensitive : boolean ; const invert_key : boolean = false); override;
    procedure         SetBinaryComparableKey      (const keyvalue:Double ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean);
    class procedure   SetBinaryComparableKey      (const keyvalue:Double ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean ; const FieldType : TFRE_DB_FIELDTYPE ; const invert_key : boolean = false);
    constructor       CreateStreamed              (const stream: TStream; const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION; const allow_null: boolean; const unique_null: boolean ; const domain_idx : boolean);
    procedure         FieldTypeIndexCompatCheck   (fld:TFRE_DB_FIELD ); override;
    function          NullvalueExists             (var vals: TFRE_DB_IndexValueStore): boolean; override;
    function          SupportsDataType            (const typ: TFRE_DB_FIELDTYPE): boolean; override;
    function          SupportsSignedQuery         : boolean; override;
    function          SupportsUnsignedQuery       : boolean; override;
    function          SupportsStringQuery         : boolean; override;
    function          SupportsRealQuery           : boolean; override;
    procedure         ForAllIndexedRealRange      (const min, max: Double; var guids :  TFRE_DB_GUIDArray ; const ascending: boolean ; const min_is_null : boolean = false ; const max_is_max : boolean = false ; const max_count : NativeInt=-1 ; skipfirst : NativeInt=0);
  end;

  { TFRE_DB_TextIndex }

  TFRE_DB_TextIndex=class(TFRE_DB_MM_Index) //TODO Unicode Key Conversion
  private
    FCaseInsensitive : Boolean;
  class var
    nullkey         : Array [0..16] of Byte; // Nullkey is short in every domain
    nullkeylen      : NativeInt;
  protected
    procedure         SetBinaryComparableKey      (const keyvalue : TFRE_DB_String ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean);
    class procedure   SetBinaryComparableKey      (const keyvalue : TFRE_DB_String ; const key_target : PByte ; var key_len : NativeInt ; const is_null : boolean ; const case_insensitive : boolean ; const invert_key : boolean = false);
    procedure         StreamHeader                (const stream: TStream);override;
    function          GetIndexDefinitionObject    : IFRE_DB_Object;override;
    function          GetIndexDefinition          : TFRE_DB_INDEX_DEF; override;
    class procedure   InitializeNullKey           ; override;
  public
    constructor       Create                      (const idx_name,fieldname: TFRE_DB_NameType ; const fieldtype : TFRE_DB_FIELDTYPE ; const unique, case_insensitive : boolean ; const collection : TFRE_DB_PERSISTANCE_COLLECTION_BASE;const allow_null : boolean;const unique_null:boolean; const domain_idx : boolean);
    constructor       CreateStreamed              (const stream : TStream ; const idx_name, fieldname: TFRE_DB_NameType ; const fieldtype : TFRE_DB_FIELDTYPE ; const unique : boolean ; const collection : TFRE_DB_PERSISTANCE_COLLECTION;const allow_null : boolean;const unique_null:boolean; const domain_idx : boolean);
    procedure         FieldTypeIndexCompatCheck   (fld:TFRE_DB_FIELD ); override;
    function          NullvalueExists             (var vals: TFRE_DB_IndexValueStore): boolean; override;
    procedure         TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint); override;
    class procedure   TransformToBinaryComparable (fld:TFRE_DB_FIELD ; const key: PByte ; var keylen : Nativeint ; const is_casesensitive :boolean ; const invert_key : boolean = false); override;
    function          SupportsDataType            (const typ: TFRE_DB_FIELDTYPE): boolean; override;
    function          SupportsSignedQuery         : boolean; override;
    function          SupportsUnsignedQuery       : boolean; override;
    function          SupportsStringQuery         : boolean; override;
    function          SupportsRealQuery           : boolean; override;
    function          ForAllIndexedTextRange      (const min, max: TFRE_DB_String; var guids :  TFRE_DB_GUIDArray ; const ascending: boolean ; const min_is_null : boolean = false ; const max_is_max : boolean = false ; const max_count : NativeInt=-1 ; skipfirst : NativeInt=0  ; const only_count_unique_vals : boolean = false):boolean;
    function          ForAllIndexPrefixString     (const prefix  : TFRE_DB_String; var guids :  TFRE_DB_GUIDArray ; const index_name : TFRE_DB_NameType ; const ascending: boolean = true ; const max_count : NativeInt=0 ; skipfirst : NativeInt=0):boolean;
  end;

  { TFRE_DB_Persistance_Collection }
  TFRE_DB_Master_Data = class;

  TFRE_DB_Persistance_Collection=class(TFRE_DB_PERSISTANCE_COLLECTION_BASE)
  private
    FName         : TFRE_DB_NameType;
    FUpperName    : TFRE_DB_NameType;
    FMasterLink   : TFRE_DB_Master_Data;
    FVolatile     : Boolean;
    FGuidObjStore : TFRE_ART_TREE;
    FIndexStore   : array of TFRE_DB_MM_INDEX;

    function      IsVolatile         : boolean; override;

    procedure     AddIndex         (const idx : TFRE_DB_MM_Index);

    procedure     IndexAddCheck    (const obj              : TFRE_DB_Object;const check_only : boolean);
    procedure     IndexUpdCheck    (const new_obj, old_obj : TFRE_DB_Object;const check_only : boolean);
    procedure     IndexDelCheck    (const del_obj          : TFRE_DB_Object;const check_only : boolean);

    procedure     StoreInThisColl     (const new_iobj        : IFRE_DB_Object ; const checkphase : boolean);
    procedure     UpdateInThisColl    (const new_ifld,old_ifld : IFRE_DB_FIELD  ; const old_iobj,new_iobj : IFRE_DB_Object ; const update_typ : TFRE_DB_ObjCompareEventType ; const in_child_obj : boolean ; const checkphase : boolean);


    procedure     DeleteFromThisColl         (const del_iobj: IFRE_DB_Object ; const checkphase : boolean);

    function      DefineIndexOnFieldReal     (const checkonly : boolean ; const FieldName  : TFRE_DB_NameType ; const FieldType    : TFRE_DB_FIELDTYPE ; const unique : boolean ; const ignore_content_case: boolean ; const index_name : TFRE_DB_NameType ; const allow_null_value : boolean; const unique_null_values: boolean ; const domain_index : boolean ; var prelim_index : TFRE_DB_MM_Index): TFRE_DB_Errortype;
    function      DropIndexReal              (const checkonly : boolean ; const index_name : TFRE_DB_NameType ; const user_context : PFRE_DB_GUID) : TFRE_DB_Errortype;

    function      _GetIndexedObjUids         (const query_value: TFRE_DB_String ; out arr: TFRE_DB_GUIDArray; const index_name: TFRE_DB_NameType; const check_is_unique: boolean ; const is_null : boolean): boolean;

    function      GetPersLayer                   : IFRE_DB_PERSISTANCE_LAYER; override;
    procedure     GetAllIndexedUidsEncodedField  (const qry_val: IFRE_DB_Object; const index_name: TFRE_DB_NameType ; var uids : TFRE_DB_GUIDArray ; const check_is_unique : boolean);
    procedure     GetAllIndexedUidsEncFieldRange (const min,max: IFRE_DB_Object; const index_name: TFRE_DB_NameType ; var uids : TFRE_DB_GUIDArray ; const ascending : boolean ; const max_count,skipfirst : NativeInt ; const min_val_is_a_prefix : boolean);

  public
    function      CloneOutObject               (const inobj:TFRE_DB_Object):TFRE_DB_Object;
    function      CloneOutArray                (const objarr : TFRE_DB_GUIDArray):TFRE_DB_ObjectArray;
    function      CloneOutArrayOI              (const objarr : TFRE_DB_GUIDArray):IFRE_DB_ObjectArray;
    function      CloneOutArrayII              (const objarr : IFRE_DB_ObjectArray):IFRE_DB_ObjectArray;

    function      GetIndexedObjInternal        (const query_value : TFRE_DB_String   ; out   obj       : IFRE_DB_Object      ; const index_name : TFRE_DB_NameType='def' ; const val_is_null : boolean = false):boolean; // for the string fieldtype, dont clone

    function      GetIndexedValueCountRC       (const qry_val: IFRE_DB_Object; const index_name: TFRE_DB_NameType ; const user_context: PFRE_DB_GUID): NativeInt;
    function      GetIndexedUidsRC             (const qry_val: IFRE_DB_Object; out uids_out    : TFRE_DB_GUIDArray    ;  const index_must_be_fullyunique : boolean ; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
    function      GetIndexedObjsClonedRC       (const qry_val: IFRE_DB_Object; out objs        : IFRE_DB_ObjectArray  ;  const index_must_be_fullyunique : boolean ; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;

    function      GetIndexedValuecountRCRange  (const min,max: IFRE_DB_Object; const ascending : boolean ; const max_count,skipfirst : NativeInt                                    ; const min_val_is_a_prefix : boolean ; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
    function      GetIndexedUidsRCRange        (const min,max: IFRE_DB_Object; const ascending : boolean ; const max_count,skipfirst : NativeInt ; out uids_out : TFRE_DB_GUIDArray ; const min_val_is_a_prefix : boolean ; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
    function      GetIndexedObjsClonedRCRange  (const min,max: IFRE_DB_Object; const ascending : boolean ; const max_count,skipfirst : NativeInt ; out objs : IFRE_DB_ObjectArray   ; const min_val_is_a_prefix : boolean ; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
    function      GetFirstLastIdxCnt           (const idx: Nativeint ; out obj: IFRE_DB_Object ; const user_context: PFRE_DB_GUID):NativeInt;
    procedure     GetAllUIDsRC                 (var uids : TFRE_DB_GUIDArray   ; const user_context: PFRE_DB_GUID);
    procedure     GetAllObjectsRCInt           (var objs : IFRE_DB_ObjectArray ; const user_context: PFRE_DB_GUID);
    procedure     GetAllObjectsRC              (var objs : IFRE_DB_ObjectArray ; const user_context: PFRE_DB_GUID);

    function      IndexExists                  (const idx_name : TFRE_DB_NameType):NativeInt;
    function      GetIndexDefinition           (const idx_name : TFRE_DB_NameType ; const user_context: PFRE_DB_GUID):TFRE_DB_INDEX_DEF;
    function      IndexNames                   : TFRE_DB_NameTypeArray;

    {< Do all streaming changes for this section }
    procedure     StreamToThis           (const stream : TStream);
    procedure     StreamIndexToThis      (const ix_name : TFRE_DB_NameType ; const stream : TStream);
    function      GetIndexDefObject      : IFRE_DB_Object;
    procedure     CreateIndexDefsFromObj (const obj     : IFRE_DB_Object);
    procedure     LoadFromThis           (const stream  : TStream);
    function      BackupToObject         : IFRE_DB_Object;
    procedure     RestoreFromObject      (const obj:IFRE_DB_Object);
    { Do all streaming changes for this section >}

    function    CollectionName     (const unique:boolean=false):TFRE_DB_NameType; override ;

//    function    GetPersLayerIntf   : IFRE_DB_PERSISTANCE_COLLECTION_4_PERISTANCE_LAYER; override;
    function    UniqueName         : PFRE_DB_NameType;
    constructor Create             (const coll_name: TFRE_DB_NameType ; Volatile: Boolean; const masterdata : TFRE_DB_Master_Data);
    destructor  Destroy            ; override;
    function    Count              : int64; override;
    function    Exists             (const ouid: TFRE_DB_GUID): boolean;

    procedure   Clear              ; // Clear Store but dont free

    procedure   GetAllUIDS         (var uids : TFRE_DB_GUIDArray);
    procedure   GetAllObjects      (var objs : IFRE_DB_ObjectArray);
    procedure   GetAllObjectsInt   (var objs : IFRE_DB_ObjectArray);

    function    Remove             (const ouid    : TFRE_DB_GUID):TFRE_DB_Errortype;

    function    FetchO             (const uid:TFRE_DB_GUID ; var obj : TFRE_DB_Object) : boolean;
    function    Fetch              (const uid:TFRE_DB_GUID ; var iobj : IFRE_DB_Object) : boolean;

    function    FetchIntFromColl      (const uid:TFRE_DB_GUID ; out obj : IFRE_DB_Object):boolean;
    function    FetchIntFromCollO     (const uid:TFRE_DB_GUID ; out obj : TFRE_DB_Object ; const no_store_lock_check : boolean=false):boolean;
    function    FetchIntFromCollArrOI (const objarr : TFRE_DB_GUIDArray):IFRE_DB_ObjectArray;
    function    FetchIntFromCollAll   : IFRE_DB_ObjectArray;
    procedure   ForAllInternalI       (const iter : IFRE_DB_Obj_Iterator);
    procedure   ForAllInternal        (const iter : TFRE_DB_Obj_Iterator);
    procedure   ForAllInternalBreak   (const iter: TFRE_DB_ObjectIteratorBrk; var halt: boolean; const descending: boolean);
    procedure   CheckFieldChangeAgainstIndex (const oldfield,newfield : TFRE_DB_FIELD ; const change_type : TFRE_DB_ObjCompareEventType ; const check : boolean ; old_obj,new_obj : TFRE_DB_Object);
  end;

  { TFRE_DB_CollectionTree }

  { TFRE_DB_CollectionManageTree }

  TFRE_DB_PersColl_Iterator = procedure (const coll:TFRE_DB_PERSISTANCE_COLLECTION) is nested;


  TFRE_DB_CollectionManageTree = class
  private
    FCollTree : TFRE_ART_TREE;
    dummy     : PtrUInt;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    NewCollection     (const coll_name : TFRE_DB_NameType ; out Collection:TFRE_DB_PERSISTANCE_COLLECTION ; const volatile_in_memory:boolean ; const masterdata : TFRE_DB_Master_Data) : TFRE_DB_Errortype;
    function    DeleteCollection  (const coll_name : TFRE_DB_NameType):TFRE_DB_Errortype;
    function    GetCollection     (const coll_name : TFRE_DB_NameType ; out Collection:TFRE_DB_PERSISTANCE_COLLECTION) : boolean;
    function    GetCollectionInt  (const coll_name : TFRE_DB_NameType ; out Collection:TFRE_DB_PERSISTANCE_COLLECTION) : boolean;
    procedure   ForAllCollections (const iter : TFRE_DB_PersColl_Iterator);
    function    GetCollectionCount   : Integer;
  end;

  RFRE_DB_GUID_RefLink_InOut_Key = packed record
    GUID            : Array [0..15] of Byte;
    RefTyp          : Byte; // 17 Bytes // Outlink = $99 // Inlink= $AA
    ToFromGuid      : Array [0..15] of Byte;  // 25 Bytes // Outlink = $99 // Inlink= $AA
    SchemeSepField  : Array [0..129] of Byte; // VARIABLE LENGTH(!) // TODO THINK ABOUT filter prefix scan (schemeclass) "SCHEME|FIELD"
    KeyLength       : Byte; // Length (not part of key)
  end;
  PFRE_DB_GUID_RefLink_In_Key = ^RFRE_DB_GUID_RefLink_InOut_Key;

  type
    TFRE_DB_TransactionalUpdateList = class;

  var
    G_DB_TX_Number      : Qword;
    G_UserTokens        : TFPHashList;
    G_AllNonsysMasters  : Array of TFRE_DB_Master_Data;
    G_SysMaster         : TFRE_DB_Master_Data;
    G_Transaction       : TFRE_DB_TransactionalUpdateList;
    G_SysScheme         : TFRE_DB_Object;


  function     G_FetchNewTransactionID : QWord;
  procedure    G_UpdateUserToken   (const user_uid : TFRE_DB_GUID ; const uti : TFRE_DB_USER_RIGHT_TOKEN);
  function     G_GetUserToken      (const user_uid : PFRE_DB_GUID ; out   uti : TFRE_DB_USER_RIGHT_TOKEN ; const raise_ex : boolean):boolean;

  type
  { TFRE_DB_Master_Data }

  TFRE_DB_Master_Data=class(TObject)
  private
    FMyMastername              : String;
    FIsSysMaster               : Boolean;
    FMasterPersistentObjStore  : TFRE_ART_TREE;
    FMasterVolatileObjStore    : TFRE_ART_TREE;
    FMasterRefLinks            : TFRE_ART_TREE;
    FMasterCollectionStore     : TFRE_DB_CollectionManageTree;
    FLayer                     : IFRE_DB_PERSISTANCE_LAYER;

    function     GetOutBoundRefLinks        (const from_obj : TFRE_DB_GUID): TFRE_DB_ObjectReferences;
    function     GetInboundRefLinks         (const to_obj   : TFRE_DB_GUID): TFRE_DB_ObjectReferences;

    procedure    __RemoveInboundReflink     (const from_uid,to_uid : TFRE_DB_GUID ; const scheme_link_key : TFRE_DB_NameTypeRL ; const notifif : IFRE_DB_DBChangedNotification ; const tsid : TFRE_DB_TransStepId);
    procedure    __RemoveOutboundReflink    (const from_uid,to_uid : TFRE_DB_GUID ; const scheme_link_key : TFRE_DB_NameTypeRL ; const notifif : IFRE_DB_DBChangedNotification ; const tsid : TFRE_DB_TransStepId);
    procedure    __RemoveRefLink            (const from_uid,to_uid:TFRE_DB_GUID;const upper_from_schemename,upper_fieldname,upper_to_schemename : TFRE_DB_NameType ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);

    procedure    __SetupOutboundLinkKey     (const from_uid,to_uid: TFRE_DB_GUID ; const scheme_link_key : TFRE_DB_NameTypeRL ; var refoutkey : RFRE_DB_GUID_RefLink_InOut_Key); //inline;
    procedure    __SetupInboundLinkKey      (const from_uid,to_uid: TFRE_DB_GUID ; const scheme_link_key : TFRE_DB_NameTypeRL ; var refinkey  : RFRE_DB_GUID_RefLink_InOut_Key); //inline;
    procedure    __SetupInitialRefLink      (const from_key : TFRE_DB_Object ; FromFieldToSchemename,LinkFromSchemenameField: TFRE_DB_NameTypeRL ; const references_to : TFRE_DB_GUID ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);
    procedure    _SetupInitialRefLinks      (const from_key : TFRE_DB_Object ; const references_to_list : TFRE_DB_ObjectReferences ; const schemelink_arr : TFRE_DB_NameTypeRLArray ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);
    procedure    _RemoveAllRefLinks         (const from_key : TFRE_DB_Object ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);
    function     __RefLinkOutboundExists    (const from_uid: TFRE_DB_GUID;const  fieldname: TFRE_DB_NameType; to_object: TFRE_DB_GUID; const scheme_link: TFRE_DB_NameTypeRL):boolean;
    function     __RefLinkInboundExists     (const from_uid: TFRE_DB_GUID;const  fieldname: TFRE_DB_NameType; to_object: TFRE_DB_GUID; const scheme_link: TFRE_DB_NameTypeRL):boolean;
    procedure    __CheckReferenceLink       (const obj: TFRE_DB_Object; fieldname: TFRE_DB_NameType; link: TFRE_DB_GUID ; var scheme_link : TFRE_DB_NameTypeRL;const allow_existing_links : boolean=false);
    procedure    _ChangeRefLink             (const from_obj: TFRE_DB_Object; const upper_schemename: TFRE_DB_NameType; const upper_fieldname: TFRE_DB_NameType; const old_links, new_links: TFRE_DB_GUIDArray ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);

    // Check full referential integrity, check if to objects exist
    procedure    _CheckRefIntegrityForObject                              (const obj:TFRE_DB_Object ; var ref_array : TFRE_DB_ObjectReferences ; var schemelink_arr : TFRE_DB_NameTypeRLArray);
    procedure    _CheckExistingReferencelinksAndRemoveMissingFromObject   (const obj:TFRE_DB_Object); { auto repair function, use with care }

    class function  _CheckFetchRightUID      (const uid : TFRE_DB_GUID ; const ut : TFRE_DB_USER_RIGHT_TOKEN) : boolean;
    class procedure _TransactionalLockObject (const uid : TFRE_DB_GUID );

  public

    procedure    InternalClearSchemecacheLink;
    function     CloneOutObject         (const inobj:TFRE_DB_Object):TFRE_DB_Object;

    function     MyLayer                : IFRE_DB_PERSISTANCE_LAYER;
    function     GetPersistantRootObjectCount (const UppercaseSchemesFilter: TFRE_DB_StringArray=nil): Integer;

    function     InternalStoreObjectFromStable (const obj : TFRE_DB_Object) : TFRE_DB_Errortype;
    function     InternalRebuildRefindex                                    : TFRE_DB_Errortype;
    function     InternalCheckRestoredBackup                                : TFRE_DB_Errortype;
    procedure    InternalStoreLock                                          ;
    procedure    InternalCheckStoreLocked                                   ;
    procedure    InternalCheckSubobjectsStored                              ;

    procedure    FDB_CleanUpMasterData                                    ;

    constructor Create                  (const master_name: string; const Layer: IFRE_DB_PERSISTANCE_LAYER);
    destructor  Destroy                 ; override;


    function    GetReferencesRC         (const obj_uid: TFRE_DB_GUID; const from: boolean; const scheme_prefix_filter: TFRE_DB_NameType; const field_exact_filter: TFRE_DB_NameType; const user_context: PFRE_DB_GUID ; const concat_call: boolean=false): TFRE_DB_GUIDArray;
    function    GetReferencesRCRecurse  (const obj_uid: TFRE_DB_GUID; const from: boolean; const scheme_prefix_filter: TFRE_DB_NameType; const field_exact_filter: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): TFRE_DB_GUIDArray;
    function    GetReferencesCountRC    (const obj_uid:TFRE_DB_GUID;const from:boolean ; const scheme_prefix_filter : TFRE_DB_NameType ='' ; const field_exact_filter : TFRE_DB_NameType='' ; const user_context: PFRE_DB_GUID=nil ; const concat_call: boolean=false): NativeInt;
    function    GetReferencesDetailedRC (const obj_uid:TFRE_DB_GUID;const from:boolean ; const scheme_prefix_filter : TFRE_DB_NameType ='' ; const field_exact_filter : TFRE_DB_NameType='' ; const user_context: PFRE_DB_GUID=nil ; const concat_call: boolean=false): TFRE_DB_ObjectReferences;
    procedure   ExpandReferencesRC      (const user_context: PFRE_DB_GUID; const ObjectList: TFRE_DB_GUIDArray; const ref_constraints: TFRE_DB_NameTypeRLArray; out expanded_refs: TFRE_DB_GUIDArray);
    function    ExpandReferencesCountRC (const user_context: PFRE_DB_GUID; const ObjectList: TFRE_DB_GUIDArray; const ref_constraints: TFRE_DB_NameTypeRLArray): NativeInt;
    procedure   FetchExpandReferencesRC (const user_context: PFRE_DB_GUID; const ObjectList: TFRE_DB_GUIDArray; const ref_constraints: TFRE_DB_NameTypeRLArray; out expanded_refs: IFRE_DB_ObjectArray);
    function    BulkFetchRC             (const user_context: PFRE_DB_GUID; const obj_uids: TFRE_DB_GUIDArray; out objects: IFRE_DB_ObjectArray):TFRE_DB_Errortype;
    function    FetchObjectRC           (const user_context: PFRE_DB_GUID; const obj_uid : TFRE_DB_GUID ; out obj : TFRE_DB_Object ; const internal_obj : boolean) : boolean;

    function    ExistsObject            (const obj_uid : TFRE_DB_GUID ) : Boolean;
    function    FetchObject             (const obj_uid : TFRE_DB_GUID ; out obj : TFRE_DB_Object ; const internal_obj : boolean) : boolean;
    procedure   StoreObjectSingle       (const obj     : TFRE_DB_Object; const check_only: boolean; const notifif: IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);
    procedure   StoreObjectWithSubjs    (const obj     : TFRE_DB_Object; const check_only: boolean; const notifif: IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);
    procedure   DeleteObjectSingle      (const obj_uid : TFRE_DB_GUID ; const check_only : boolean ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId);  { frees root objects }
    procedure   DeleteObjectWithSubobjs (const del_obj : TFRE_DB_Object ; const check_only : boolean ; const notifif : IFRE_DB_DBChangedNotification; const tsid : TFRE_DB_TransStepId;const must_be_child:boolean=false);
    procedure   ForAllObjectsInternal   (const pers,volatile:boolean ; const iter:TFRE_DB_ObjectIteratorBrk); // No Clone
    function    MasterColls             : TFRE_DB_CollectionManageTree;
  end;

  { TFRE_DB_ChangeStep }

  TFRE_DB_ChangeStep=class
  protected
    FLayer         : IFRE_DB_PERSISTANCE_LAYER;
    FNotifIF       : IFRE_DB_DBChangedNotification;
    Fmaster        : TFRE_DB_Master_Data;
    FTransList     : TFRE_DB_TransactionalUpdateList;
    FStepID        : NativeInt;
    FUserContext   : PFRE_DB_GUID;
    FUserToken     : TFRE_DB_USER_RIGHT_TOKEN;
    procedure      InternalWriteObject         (const m : TMemoryStream;const obj : TFRE_DB_Object);
    procedure      InternalReadObject          (const m : TStream ; var obj : TFRE_DB_Object);
  protected
    procedure      CheckWriteThroughIndexDrop  (Coll     : TFRE_DB_PERSISTANCE_COLLECTION_BASE ; const index : TFRE_DB_NameType);
    procedure      CheckWriteThroughColl       (Coll     : TFRE_DB_PERSISTANCE_COLLECTION_BASE);
    procedure      CheckWriteThroughDeleteColl (Collname : TFRE_DB_NameType);
    procedure      CheckWriteThroughObj        (obj      : IFRE_DB_Object);
    procedure      CheckWriteThroughDeleteObj  (obj      : IFRE_DB_Object);
    function       _GetCollection              (const coll_name : TFRE_DB_NameType ; out Collection:TFRE_DB_PERSISTANCE_COLLECTION) : Boolean;
  public
    constructor    Create                      (const layer : IFRE_DB_PERSISTANCE_LAYER ; const masterdata : TFRE_DB_Master_Data ; const user_context : PFRE_DB_GUID);
    procedure      CheckExistenceAndPreconds   ; virtual;                                   { CHECK Only:  Preconditions satisfied ? -> fetch usertoken if needed }
    procedure      ChangeInCollectionCheckOrDo (const check : boolean); virtual ; abstract; { Do all collection related checks or stores (+collection indices) }
    procedure      MasterStore                 (const check : boolean); virtual ; abstract; { Do all objectc related checks or stores, (+reflink index) }
    procedure      SetStepID                   (const id:NativeInt);
    function       GetTransActionStepID        : TFRE_DB_TransStepId;
    function       Master                      : TFRE_DB_Master_Data;
  end;

  { TFRE_DB_NewCollectionStep }

  TFRE_DB_NewCollectionStep=class(TFRE_DB_ChangeStep)
  private
    FCollname       : TFRE_DB_NameType;
    FVolatile       : Boolean;
    FNewCollection  : TFRE_DB_PERSISTANCE_COLLECTION;
  public
    constructor Create                       (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;const coll_name: TFRE_DB_NameType;const volatile_in_memory: boolean ; const user_context : PFRE_DB_GUID);
    procedure   CheckExistenceAndPreconds    ; override;
    procedure   ChangeInCollectionCheckOrDo  (const check: boolean); override;
    procedure   MasterStore                  (const check: boolean); override;
    function    GetNewCollection             : TFRE_DB_PERSISTANCE_COLLECTION_BASE;
  end;

  { TFRE_DB_DefineIndexOnFieldStep }

  TFRE_DB_DefineIndexOnFieldStep=class(TFRE_DB_ChangeStep)
  private
    FCollname         : TFRE_DB_NameType;
    FVolatile         : Boolean;
    FCollection       : TFRE_DB_PERSISTANCE_COLLECTION;
    FindexName        : TFRE_DB_NameType;
    FPreliminaryIndex : TFRE_DB_MM_Index;
    Fcoll_name        : TFRE_DB_NameType;
    FFieldName        : TFRE_DB_NameType;
    FFieldType        : TFRE_DB_FIELDTYPE;
    FUnique           : boolean;
    FIgnoreCC         : boolean;
    Fallownull        : boolean;
    FUniqueNull       : boolean;
    FDomainIndex      : boolean;
  public
    constructor Create                       (const layer  : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;const coll_name: TFRE_DB_NameType ; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean; const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean ; const is_a_domain_index: boolean ; const user_context : PFRE_DB_GUID);
    procedure   CheckExistenceAndPreconds    ; override;
    procedure   ChangeInCollectionCheckOrDo  (const check: boolean); override;
    procedure   MasterStore                  (const check: boolean); override;
  end;


  { TFRE_DB_DropIndexStep }

  TFRE_DB_DropIndexStep=class(TFRE_DB_ChangeStep)
  private
    FCollname       : TFRE_DB_NameType;
    FIndexName      : TFRE_DB_NameType;
    FCollection     : TFRE_DB_PERSISTANCE_COLLECTION;
    FVolatile       : boolean;
  public
    constructor Create                       (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;const coll_name,index_name: TFRE_DB_NameType;const user_context : PFRE_DB_GUID);
    procedure   CheckExistenceAndPreconds    ; override;
    procedure   ChangeInCollectionCheckOrDo  (const check: boolean); override;
    procedure   MasterStore                  (const check: boolean); override;
  end;


  { TFRE_DB_DeleteCollectionStep }

  TFRE_DB_DeleteCollectionStep=class(TFRE_DB_ChangeStep)
  private
    FCollname       : TFRE_DB_NameType;
    FPersColl       : TFRE_DB_PERSISTANCE_COLLECTION;
    FVolatile       : boolean;
  public
    constructor Create                       (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;const coll_name: TFRE_DB_NameType ; const user_context : PFRE_DB_GUID);
    procedure   CheckExistenceAndPreconds    ; override;
    procedure   ChangeInCollectionCheckOrDo  (const check: boolean); override;
    procedure   MasterStore                  (const check: boolean); override;
  end;


  { TFRE_DB_InsertStep }

  TFRE_DB_InsertStep=class(TFRE_DB_ChangeStep)
  private
    FInsertList               : TFRE_DB_ObjectArray;
    FColl                     : TFRE_DB_PERSISTANCE_COLLECTION;
    FCollName                 : TFRE_DB_NameType;
    FThisIsAnAddToAnotherColl : Boolean;
  public
    constructor Create                       (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;new_obj : TFRE_DB_Object ; const insert_in_coll : TFRE_DB_NameType ; const user_context : PFRE_DB_GUID);  { ? is_store is used to differentiate the store from the update case}
    procedure   CheckExistenceAndPreconds    ; override;
    procedure   ChangeInCollectionCheckOrDo  (const check : boolean); override;
    procedure   MasterStore                  (const check : boolean); override;
  end;


  { TFRE_DB_DeleteObjectStep }
  TFRE_DB_DeleteObjectStep=class(TFRE_DB_ChangeStep)
  protected
    FDeleteObjectUid         : TFRE_DB_GUID;
    FDeleteList              : TFRE_DB_ObjectArray;
    CollName                 : TFRE_DB_NameType;
    FWouldNeedMasterDelete   : Boolean;
    FDelFromCollectionsNames : TFRE_DB_NameTypeArray;
    FDelFromCollections      : TFRE_DB_PERSISTANCE_COLLECTION_ARRAY;
  public
    constructor Create                        (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;const del_obj_uid : TFRE_DB_GUID ; const from_coll : TFRE_DB_NameType ; const user_context : PFRE_DB_GUID); // all collections or a single collection
    procedure   CheckExistenceAndPreconds     ; override;
    procedure   ChangeInCollectionCheckOrDo   (const check : boolean); override;
    procedure   MasterStore                   (const check : boolean); override;
  end;


  TFRE_DB_UpdateStep=class;
  { TFRE_DB_UpdateStep }

  RFRE_DB_UpdateSubStep=record
    updtyp       : TFRE_DB_ObjCompareEventType;
    newfield     : TFRE_DB_FIELD;
    oldfield     : TFRE_DB_FIELD;
    up_obj       : TFRE_DB_Object;
    in_child_obj : Boolean;
    in_del_list  : boolean;
  end;

  TFRE_DB_UpdateStep=class(TFRE_DB_ChangeStep)
  protected
    FSublist    : Array of RFRE_DB_UpdateSubStep;
    FCnt        : NativeInt;
    FDiffUpdate : TFRE_DB_Object;
    upobj       : TFRE_DB_Object;             // "new" object
    to_upd_obj  : TFRE_DB_Object;             // "old" object (Fields of object will be updated by newobjects fields)
    FCollName   : TFRE_DB_NameType;

    procedure   InternallApplyChanges         (const check: boolean);
  public
    procedure   AddSubStep                    (const uptyp: TFRE_DB_ObjCompareEventType; const new, old: TFRE_DB_FIELD; const is_a_child_field: boolean;const update_obj: TFRE_DB_Object ; const is_in_delete_list:boolean=false); { update_obj = to_update_obj or child}
    constructor Create                        (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;  obj : TFRE_DB_Object ; const update_in_coll : TFRE_DB_NameType ; const user_context : PFRE_DB_GUID);
    constructor CreateFromDiffTransport       (const layer : IFRE_DB_PERSISTANCE_LAYER;const masterdata : TFRE_DB_Master_Data;  diff_update_obj : TFRE_DB_Object ; const update_in_coll : TFRE_DB_NameType ; const user_context : PFRE_DB_GUID);
    procedure   CheckExistenceAndPreconds     ; override;
    procedure   ChangeInCollectionCheckOrDo   (const check : boolean); override;
    procedure   MasterStore                   (const check : boolean); override;
  end;

  OFRE_SL_TFRE_DB_ChangeStep  = specialize OFOS_SpareList<TFRE_DB_ChangeStep>;

  { TFRE_DB_TransactionalUpdateList }

  PFRE_DB_ChangeStep = ^TFRE_DB_ChangeStep;

  TFRE_DB_TransactionalUpdateList = class(TObject)
  private
    FChangeList  : OFRE_SL_TFRE_DB_ChangeStep; // The sparse List has to be ordered (!) / deletetions and reinsertions must not happen
    FTransId     : TFRE_DB_NameType;
    FTransNumber : QWord;
    FLastStepId  : TFRE_DB_TransStepId;
    FLockDir     : TFRE_DB_Object;
    procedure    ProcessCheck            ;
  public
    constructor  Create                  (const TransID : TFRE_DB_NameType ; const master_data : TFRE_DB_Master_Data ; const notify_if : IFRE_DB_DBChangedNotification);
    function     AddChangeStep           (const step:TFRE_DB_ChangeStep):NativeInt;
    procedure    Record_And_UnlockObject (const obj : TFRE_DB_Object);
    procedure    Record_A_NewObject      (const obj : TFRE_DB_Object);
    procedure    Forget_UnlockedObject   (const obj : TFRE_DB_Object);
    procedure    Lock_Unlocked_Objects   ;

    function     GetTransActionId        : TFRE_DB_NameType;
    function     GetTransLastStepTransId : TFRE_DB_TransStepId;

    function     Commit                  :boolean;
    procedure    Rollback                ;
    destructor   Destroy                 ;override;
  end;

  { TFRE_DB_DBChangedNotificationBase }

  TFRE_DB_DBChangedNotificationBase = class(TObject,IFRE_DB_DBChangedNotification)
  protected
    FLayerDB : Shortstring;
  public
    constructor Create                (const conn_db : TFRE_DB_NameType);
    destructor  Destroy               ;override;
    procedure  StartNotificationBlock (const key : TFRE_DB_TransStepId); virtual;
    procedure  FinishNotificationBlock(out block : IFRE_DB_Object); virtual;
    procedure  SendNotificationBlock  (const block : IFRE_DB_Object); virtual;
    procedure  CollectionCreated      (const coll_name: TFRE_DB_NameType; const in_memory_only : boolean ; const tsid : TFRE_DB_TransStepId) ; virtual ;
    procedure  CollectionDeleted      (const coll_name: TFRE_DB_NameType; const tsid : TFRE_DB_TransStepId) ; virtual ;
    procedure  IndexDefinedOnField    (const coll_name: TFRE_DB_NameType  ; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean;
                                       const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean;
                                       const tsid : TFRE_DB_TransStepId);virtual;
    procedure  IndexDroppedOnField    (const coll_name: TFRE_DB_NameType  ; const index_name: TFRE_DB_NameType; const tsid : TFRE_DB_TransStepId);virtual;
    procedure  ObjectStored           (const coll_name: TFRE_DB_NameType ; const obj : IFRE_DB_Object; const tsid : TFRE_DB_TransStepId) ; virtual;
    procedure  ObjectDeleted          (const coll_names: TFRE_DB_NameTypeArray ; const obj : IFRE_DB_Object; const tsid : TFRE_DB_TransStepId)  ; virtual;
    procedure  ObjectRemoved          (const coll_names: TFRE_DB_NameTypeArray ; const obj : IFRE_DB_Object ; const is_a_full_delete : boolean ; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  ObjectUpdated          (const obj : IFRE_DB_Object ; const colls:TFRE_DB_StringArray; const tsid : TFRE_DB_TransStepId);virtual;    { FULL STATE }
    procedure  DifferentiallUpdStarts (const obj       : IFRE_DB_Object; const tsid : TFRE_DB_TransStepId); virtual;            { DIFFERENTIAL STATE}
    procedure  DifferentiallUpdEnds   (const obj_uid   : TFRE_DB_GUID; const tsid : TFRE_DB_TransStepId); virtual;             { DIFFERENTIAL STATE}
    procedure  FieldDelete            (const old_field : IFRE_DB_Field; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  FieldAdd               (const new_field : IFRE_DB_Field; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  FieldChange            (const old_field,new_field : IFRE_DB_Field; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  SetupOutboundRefLink   (const from_obj : TFRE_DB_GUID           ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  SetupInboundRefLink    (const from_obj : IFRE_DB_Object  ; const to_obj: TFRE_DB_GUID          ; const key_description : TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  InboundReflinkDropped  (const from_obj : IFRE_DB_Object  ; const to_obj: TFRE_DB_GUID          ; const key_description : TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId); virtual;
    procedure  OutboundReflinkDropped (const from_obj : TFRE_DB_GUID           ; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId); virtual ;
    procedure  FinalizeNotif          ;
  end;

  { TFRE_DB_DBChangedNotificationProxy }

  { All objects reported by the Notification Subsystem must be freed, and must not have side effects on persistance data, thus copy in embedded case}

  TFRE_DB_DBChangedNotificationProxy=class(TFRE_DB_DBChangedNotificationBase,IFRE_DB_DBChangedNotification)
  private
    FRealIF          : IFRE_DB_DBChangedNotificationBlock;
    FBlockList       : IFRE_DB_Object;
    FBlocksendMethod : IFRE_DB_InvokeProcedure;
  protected
    procedure   CheckBlockStarted      ;
    procedure   CheckBlockNotStarted   ;
    procedure   AddNotificationEntry   (const entry:IFRE_DB_Object);
    procedure   AssertCheckTransactionID (const obj : IFRE_DB_Object ; const transid : TFRE_DB_TransStepId);
  public
    constructor Create                 (const real_interface : IFRE_DB_DBChangedNotificationBlock ; const db_name : TFRE_DB_NameType ; const BlocksendMethod : IFRE_DB_InvokeProcedure=nil);
    destructor  Destroy                ;override;
    procedure   StartNotificationBlock (const key      : TFRE_DB_TransStepId); override;
    procedure   FinishNotificationBlock(out   block    : IFRE_DB_Object); override;
    procedure   SendNotificationBlock  (const block    : IFRE_DB_Object);override;
    procedure   CollectionCreated      (const coll_name: TFRE_DB_NameType; const in_memory_only : boolean ; const tsid : TFRE_DB_TransStepId) ; override;
    procedure   CollectionDeleted      (const coll_name: TFRE_DB_NameType; const tsid : TFRE_DB_TransStepId) ; override ;
    procedure   IndexDefinedOnField    (const coll_name: TFRE_DB_NameType  ; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean;
                                        const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean;
                                        const tsid : TFRE_DB_TransStepId);override;
    procedure   IndexDroppedOnField    (const coll_name: TFRE_DB_NameType  ; const index_name: TFRE_DB_NameType; const tsid : TFRE_DB_TransStepId);override;
    procedure   ObjectStored           (const coll_name: TFRE_DB_NameType ; const obj : IFRE_DB_Object; const tsid : TFRE_DB_TransStepId) ; override;
    procedure   ObjectDeleted          (const coll_names: TFRE_DB_NameTypeArray ; const obj : IFRE_DB_Object; const tsid : TFRE_DB_TransStepId)  ; override;
    procedure   ObjectRemoved          (const coll_names: TFRE_DB_NameTypeArray ; const obj : IFRE_DB_Object; const is_a_full_delete : boolean ; const tsid : TFRE_DB_TransStepId); override;
    procedure   ObjectUpdated          (const obj : IFRE_DB_Object ; const colls:TFRE_DB_StringArray; const tsid : TFRE_DB_TransStepId);override;
    procedure   DifferentiallUpdStarts (const obj       : IFRE_DB_Object; const tsid : TFRE_DB_TransStepId); override;
    procedure   DifferentiallUpdEnds   (const obj_uid   : TFRE_DB_GUID; const tsid : TFRE_DB_TransStepId); override;
    procedure   FieldDelete            (const old_field : IFRE_DB_Field; const tsid : TFRE_DB_TransStepId); override;
    procedure   FieldAdd               (const new_field : IFRE_DB_Field; const tsid : TFRE_DB_TransStepId); override;
    procedure   FieldChange            (const old_field,new_field : IFRE_DB_Field; const tsid : TFRE_DB_TransStepId); override;
    procedure   SetupOutboundRefLink   (const from_obj : TFRE_DB_GUID          ; const to_obj: IFRE_DB_Object ; const key_description : TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId);override;
    procedure   SetupInboundRefLink    (const from_obj : IFRE_DB_Object ; const to_obj: TFRE_DB_GUID   ; const key_description : TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId); override;
    procedure   InboundReflinkDropped  (const from_obj : IFRE_DB_Object ; const to_obj: TFRE_DB_GUID   ; const key_description : TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId); override;
    procedure   OutboundReflinkDropped (const from_obj : TFRE_DB_GUID          ; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid : TFRE_DB_TransStepId);override;
  end;

implementation

function G_FetchNewTransactionID : QWord;
begin
  inc(G_DB_TX_Number);
  result := G_DB_TX_Number;
end;

procedure G_UpdateUserToken(const user_uid: TFRE_DB_GUID; const uti: TFRE_DB_USER_RIGHT_TOKEN);
var suti  : TFRE_DB_USER_RIGHT_TOKEN;
    idx   : Integer;
    hname : ShortString;
    uidh  : ShortString;
begin
  hname := FREDB_G2SB(user_uid);
  uidh := FREDB_G2H(user_uid)+' / '+uti.GetFullUserLogin;
  assert(user_uid=uti.GetUserUIDP^,'internal fault uids dont match');
  idx :=G_UserTokens.FindIndexOf(hname);
  if idx>=0 then
    begin
      suti := TFRE_DB_USER_RIGHT_TOKEN(G_UserTokens.Items[idx]);
      G_UserTokens.Delete(idx);
      suti.Free;
    end;
  G_UserTokens.add(hname,uti);
end;

function G_GetUserToken(const user_uid: PFRE_DB_GUID; out uti: TFRE_DB_USER_RIGHT_TOKEN; const raise_ex: boolean): boolean;
var idx   : Integer;
    hname : ShortString;
    uidh  : ShortString;
begin
  if not assigned(user_uid) then
    begin
      uti := nil;
      exit;
    end;
  uidh := FREDB_G2H(user_uid^);
  hname := FREDB_G2SB(user_uid^);
  idx :=G_UserTokens.FindIndexOf(hname);
  if idx>=0 then
    begin
      uti := TFRE_DB_USER_RIGHT_TOKEN(G_UserTokens.Items[idx]);
    end
  else
    uti := nil;
  if raise_ex and (not assigned(uti)) then
    begin
      raise EFRE_DB_PL_Exception.Create(edb_ERROR,'the specified user [%s] does not exist',[FREDB_G2H(user_uid^)]);
    end;
end;

{ TFRE_DB_DropIndexStep }

constructor TFRE_DB_DropIndexStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; const coll_name, index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID);
begin
  Inherited Create(layer,masterdata,user_context);
  FCollname   := coll_name;
  FIndexName  := index_name;
end;

procedure TFRE_DB_DropIndexStep.CheckExistenceAndPreconds;
begin
  if not Master.MasterColls.GetCollection(FCollname,FCollection) then
    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'collection [%s] does not exists!',[FCollname]);
end;

procedure TFRE_DB_DropIndexStep.ChangeInCollectionCheckOrDo(const check: boolean);
var res : TFRE_DB_Errortype;
begin
  res := FCollection.DropIndexReal(check,FIndexName,FUserContext);
  if res<>edb_OK then
    raise EFRE_DB_PL_Exception.Create(res,'collection [%s], index [%s] drop failed!',[FCollname,FindexName]);
end;

procedure TFRE_DB_DropIndexStep.MasterStore(const check: boolean);
begin
  if not check then
    begin
      if assigned(FNotifIF) then
        FNotifIF.IndexDroppedOnField(FCollname,FIndexName,GetTransActionStepID);
      CheckWriteThroughIndexDrop(FCollection,FIndexName);
    end;
end;

{ TFRE_DB_RealIndex }

class procedure TFRE_DB_RealIndex.InitializeNullKey;
begin
  SetBinaryComparableKey(0,@nullkey,nullkeylen,true,fdbft_Int16); { fieldtype is irrelevant for the null key }
end;

procedure TFRE_DB_RealIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint);
begin
  TransformToBinaryComparable(fld,key,keylen,false);
end;

class procedure TFRE_DB_RealIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint; const is_casesensitive: boolean; const invert_key: boolean);
var is_null_value : Boolean;
begin
  is_null_value := not assigned(fld);
  if not is_null_value then
    SetBinaryComparableKey(fld.AsReal64,key,keylen,is_null_value,fld.FieldType,invert_key)
  else
    SetBinaryComparableKey(0,key,keylen,is_null_value,fdbft_NotFound,invert_key);
end;

procedure TFRE_DB_RealIndex.SetBinaryComparableKey(const keyvalue: Double; const key_target: PByte; var key_len: NativeInt; const is_null: boolean);
begin
  SetBinaryComparableKey(keyvalue,key_target,key_len,is_null,FFieldType);
end;

class procedure TFRE_DB_RealIndex.SetBinaryComparableKey(const keyvalue: Double; const key_target: PByte; var key_len: NativeInt; const is_null: boolean; const FieldType: TFRE_DB_FIELDTYPE; const invert_key: boolean);
var FFixedKeylen  : NativeInt;
    i             : NativeInt;
    keyvalue_fake : int64;
begin
  if not is_null then
    begin
      keyvalue_fake := round(keyvalue*10000);
      GetKeyLenForFieldtype(FieldType,FFixedKeylen);
      key_len       := FFixedKeylen+1;
      case FFixedKeylen of
         8: PInt64(@key_target[1])^    := SwapEndian(keyvalue_fake);
        else
          raise EFRE_DB_PL_Exception.Create(edb_UNSUPPORTED,'unsupported fixed length in index transform to binary comparable');
      end;
      key_target[1] := key_target[1] xor 128;
      key_target[0] := 1; // 0 , val , -val are ordered after NULL values which are prefixed by '0' not by '1'
      if invert_key then
        for i := 1 to key_len do
          key_target[i] := not key_target[i];
    end
  else
    begin
      key_len:=1;
      if not invert_key then
        key_target[0]:=0
      else
        key_target[0]:=2;
    end;
end;

constructor TFRE_DB_RealIndex.CreateStreamed(const stream: TStream; const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION; const allow_null: boolean; const unique_null: boolean; const domain_idx : boolean);
begin
  Create(idx_name,fieldname,fieldtype,unique,collection,allow_null,unique_null,domain_idx);
  LoadIndex(stream,collection);
end;

procedure TFRE_DB_RealIndex.FieldTypeIndexCompatCheck(fld: TFRE_DB_FIELD);
begin
  if not SupportsDataType(fld.FieldType) then
    raise EFRE_DB_PL_Exception.Create(edb_ILLEGALCONVERSION,'the real index can only be used to index a real32/real64 number field, not a [%s] field.',[fld.FieldTypeAsString])
end;

function TFRE_DB_RealIndex.NullvalueExists(var vals: TFRE_DB_IndexValueStore): boolean;
var dummy  : NativeUint;
begin
  result := FIndex.ExistsBinaryKey(@nullkey,nullkeylen,dummy);
  if result then
    vals := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore
  else
    vals := nil;
end;

function TFRE_DB_RealIndex.SupportsDataType(const typ: TFRE_DB_FIELDTYPE): boolean;
begin
  case typ of
    fdbft_Real32,
    fdbft_Real64: result := true;
    else result := false;
  end;
end;

function TFRE_DB_RealIndex.SupportsSignedQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_RealIndex.SupportsUnsignedQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_RealIndex.SupportsStringQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_RealIndex.SupportsRealQuery: boolean;
begin
  result := true;
end;

procedure TFRE_DB_RealIndex.ForAllIndexedRealRange(const min, max: Double; var guids: TFRE_DB_GUIDArray; const ascending: boolean; const min_is_null: boolean; const max_is_max: boolean; const max_count: NativeInt; skipfirst: NativeInt);
var lokey,hikey       : Array [0..8] of Byte;
    lokeylen,hikeylen : NativeInt;
    lokeyp,hikeyp     : PByte;

   procedure IteratorBreak(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var down_counter,up_counter : NativeInt; const abscntr : NativeInt);
   begin
     (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
   end;

begin
  if not min_is_null then
    begin
      SetBinaryComparableKey(min,@lokey,lokeylen,min_is_null);
      lokeyp := lokey;
    end
  else
    lokeyp := nil;
  if not max_is_max then
    begin
      SetBinaryComparableKey(max,@hikey,hikeylen,max_is_max);
      hikeyp := hikey;
    end
  else
    hikeyp := nil;
  FIndex.RangeScan(lokeyp,hikeyp,lokeylen,hikeylen,@IteratorBreak,max_count,skipfirst,ascending)
end;

{ TFRE_DB_DefineIndexOnFieldStep }

constructor TFRE_DB_DefineIndexOnFieldStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; const coll_name: TFRE_DB_NameType; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean; const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean; const is_a_domain_index: boolean; const user_context: PFRE_DB_GUID);
begin
  Inherited Create(layer,masterdata,user_context);
  FCollname    := coll_name;
  FFieldName   := FieldName;
  FFieldType   := FieldType;
  FUnique      := unique;
  FIgnoreCC    := ignore_content_case;
  FindexName   := index_name;
  Fallownull   := allow_null_value;
  FUniqueNull  := unique_null_values;
  FDomainIndex := is_a_domain_index;
end;

procedure TFRE_DB_DefineIndexOnFieldStep.CheckExistenceAndPreconds;
begin
  if not Master.MasterColls.GetCollection(FCollname,FCollection) then
    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'collection [%s] does not exists!',[FCollname]);
end;

procedure TFRE_DB_DefineIndexOnFieldStep.ChangeInCollectionCheckOrDo(const check: boolean);
var res : TFRE_DB_Errortype;
begin
  res := FCollection.DefineIndexOnFieldReal(check,FFieldName,FFieldType,FUnique,FIgnoreCC,FindexName,Fallownull,FUniqueNull,FDomainIndex,FPreliminaryIndex);
  if res<>edb_OK then
    raise EFRE_DB_PL_Exception.Create(res,'collection [%s], index [%s] creation failed! [%s]',[FCollname,FindexName,res.Msg]);
end;

procedure TFRE_DB_DefineIndexOnFieldStep.MasterStore(const check: boolean);
begin
  if not check then
    begin
      if assigned(FNotifIF) then
        FNotifIF.IndexDefinedOnField(FCollname,FFieldName,FFieldType,FUnique,FIgnoreCC,FindexName,Fallownull,FUniqueNull,GetTransActionStepID);
      CheckWriteThroughColl(FCollection);
    end;
end;


{ TFRE_DB_DBChangedNotificationProxy }

procedure TFRE_DB_DBChangedNotificationProxy.CheckBlockStarted;
begin
  if not assigned(FBlockList) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'BLOCK LIST NOT STARTED');
end;

procedure TFRE_DB_DBChangedNotificationProxy.CheckBlockNotStarted;
begin
  if assigned(FBlockList) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'BLOCK LIST ALREADY STARTED');
end;

procedure TFRE_DB_DBChangedNotificationProxy.AddNotificationEntry(const entry: IFRE_DB_Object);
begin
  FBlockList.Field('N').AddObject(entry);
end;

procedure TFRE_DB_DBChangedNotificationProxy.AssertCheckTransactionID(const obj: IFRE_DB_Object; const transid: TFRE_DB_TransStepId);
var ttag : TFRE_DB_TransStepId;
begin
  ttag := obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString;
  if ttag <>transid then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'NOTPROXY : transaction id mismatch OBJ=[%s] NOTIFY=[%s]',[ttag,transid]);
end;

constructor TFRE_DB_DBChangedNotificationProxy.Create(const real_interface: IFRE_DB_DBChangedNotificationBlock; const db_name: TFRE_DB_NameType; const BlocksendMethod: IFRE_DB_InvokeProcedure);
begin
  FRealIF          := real_interface;
  FLayerDB         := db_name;
  FBlocksendMethod := BlocksendMethod;
end;

destructor TFRE_DB_DBChangedNotificationProxy.Destroy;
begin
  inherited Destroy;
end;

procedure TFRE_DB_DBChangedNotificationProxy.StartNotificationBlock(const key: TFRE_DB_TransStepId);
begin
  try
    Inherited; { log }
    CheckBlockNotStarted;
    FBlockList := GFRE_DBI.NewObject;
    FBlockList.Field('KEY').AsString := key;
    FBlockList.Field('L').AsString   := FLayerDB;
  except
    on e:Exception do
    begin
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'proxy notification error: StartNotificationBlock '+e.Message);
    end;
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.FinishNotificationBlock(out block: IFRE_DB_Object);
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    block      := FBlockList;
    FBlockList := nil;
  except
    on e:Exception do
    begin
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'proxy notification error: FinishNotificationBlock '+e.Message);
    end;
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.SendNotificationBlock(const block: IFRE_DB_Object);
var s:string;
begin
  try
    Inherited; { log }
    if assigned(FRealIF) then
      FRealIF.SendNotificationBlock(block)
    else
    if assigned(FBlocksendMethod) then
      FBlocksendMethod(block)
    else
      block.Finalize;
  except
    on e:Exception do
    begin
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'proxy notification error: SendNotificationBlock '+e.Message);
    end;
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.CollectionCreated(const coll_name: TFRE_DB_NameType; const in_memory_only: boolean; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'CC';
    newe.Field('CC').AsString   := coll_name;
    newe.Field('CV').AsBoolean  := in_memory_only;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: CollectionCreated '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.CollectionDeleted(const coll_name: TFRE_DB_NameType; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
   Inherited; { log }
   CheckBlockStarted;
   newe := GFRE_DBI.NewObject;
   newe.Field('C').AsString    := 'CD';
   newe.Field('CC').AsString   := coll_name;
   newe.Field('TSID').AsString := tsid;
   AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: CollectionDeleted '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.IndexDefinedOnField(const coll_name: TFRE_DB_NameType; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean; const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
   Inherited; { log }
   CheckBlockStarted;
   newe := GFRE_DBI.NewObject;
   newe.Field('C').AsString    := 'IC';
   newe.Field('CC').AsString   := coll_name;
   newe.Field('IN').AsString   := index_name;
   newe.Field('FN').AsString   := FieldName;
   newe.Field('FT').AsString   := CFRE_DB_FIELDTYPE_SHORT[FieldType];
   newe.Field('UI').AsBoolean  := unique;
   newe.Field('AN').AsBoolean  := allow_null_value;
   newe.Field('UN').AsBoolean  := unique_null_values;
   newe.Field('IC').AsBoolean  := ignore_content_case;
   newe.Field('TSID').AsString := tsid;
   AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: IndexDefinedOnField '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.IndexDroppedOnField(const coll_name: TFRE_DB_NameType; const index_name: TFRE_DB_NameType; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
     Inherited; { log }
     CheckBlockStarted;
     newe := GFRE_DBI.NewObject;
     newe.Field('C').AsString   := 'ID';
     newe.Field('CC').AsString  := coll_name;
     newe.Field('IN').AsString  := index_name;
     newe.Field('TSID').AsString := tsid;
     AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: IndexDroppedOnField '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.ObjectStored(const coll_name: TFRE_DB_NameType; const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'OS';
    newe.Field('CC').AsString   := coll_name;
    newe.Field('OBJ').AsObject  := obj.CloneToNewObject;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: ObjectStored '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.ObjectDeleted(const coll_names: TFRE_DB_NameTypeArray; const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'OD';
    newe.Field('CC').AsStringArr := FREDB_NametypeArray2StringArray(coll_names);
    newe.Field('OBJ').AsObject  := obj; //Is already cloned .CloneToNewObject;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: ObjectDeleted '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.ObjectRemoved(const coll_names: TFRE_DB_NameTypeArray; const obj: IFRE_DB_Object; const is_a_full_delete: boolean; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString     := 'OR';
    newe.Field('CC').AsStringArr := FREDB_NametypeArray2StringArray(coll_names);
    newe.Field('FD').AsBoolean   := is_a_full_delete;
    newe.Field('OBJ').AsObject   := obj.CloneToNewObject;
    newe.Field('TSID').AsString  := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: ObjectRemoved '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.ObjectUpdated(const obj: IFRE_DB_Object; const colls: TFRE_DB_StringArray; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'OU';
    newe.Field('CC').AsStringArr:= colls;
    newe.Field('OBJ').AsObject  := obj.CloneToNewObject;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
    AssertCheckTransactionID(obj,tsid);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: ObjectUpdated '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.DifferentiallUpdStarts(const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'DUS';
    newe.Field('O').AsObject    := obj;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: DiffUpstart '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.DifferentiallUpdEnds(const obj_uid: TFRE_DB_GUID; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'DUE';
    newe.Field('O').AsGUID      := obj_uid;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: DiffUpEnds '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.FieldDelete(const old_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'FD';
    newe.Field('FLD').AsObject  := old_field.CloneToNewStreamableObj;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: FieldDelete '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.FieldAdd(const new_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'FA';
    newe.Field('FLD').AsObject  := new_field.CloneToNewStreamableObj;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: FieldAdd '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.FieldChange(const old_field, new_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'FC';
    newe.Field('FLDO').AsObject := old_field.CloneToNewStreamableObj;
    newe.Field('FLDN').AsObject := new_field.CloneToNewStreamableObj;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: FieldChange '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.SetupOutboundRefLink(const from_obj: TFRE_DB_GUID; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'SOL';
    newe.Field('FO').AsGUID     := from_obj;
    newe.Field('TO').AsObject   := to_obj.CloneToNewObject;
    newe.Field('KD').AsString   := key_description;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: SetupOutboundRefLink '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.SetupInboundRefLink(const from_obj: IFRE_DB_Object; const to_obj: TFRE_DB_GUID; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'SIL';
    newe.Field('FO').AsObject   := from_obj.CloneToNewObject;
    newe.Field('TO').AsGUID     := to_obj;
    newe.Field('KD').AsString   := key_description;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: SetupInboundRefLink '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.InboundReflinkDropped(const from_obj: IFRE_DB_Object; const to_obj: TFRE_DB_GUID; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'DIL';
    newe.Field('FO').AsObject   := from_obj.CloneToNewObject;
    newe.Field('TO').AsGUID     := to_obj;
    newe.Field('KD').AsString   := key_description;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: InboundReflinkDropped '+e.Message);
  end;
end;

procedure TFRE_DB_DBChangedNotificationProxy.OutboundReflinkDropped(const from_obj: TFRE_DB_GUID; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
var newe : IFRE_DB_Object;
begin
  try
    Inherited; { log }
    CheckBlockStarted;
    newe := GFRE_DBI.NewObject;
    newe.Field('C').AsString    := 'DOL';
    newe.Field('FO').AsGUID     := from_obj;
    newe.Field('TO').AsObject   := to_obj.CloneToNewObject;
    newe.Field('KD').AsString   := key_description;
    newe.Field('TSID').AsString := tsid;
    AddNotificationEntry(newe);
  except on
    e:Exception do
      GFRE_DBI.LogError(dblc_PERSISTANCE_NOTIFY,'notification error: OutboundReflinkDropped '+e.Message);
  end;
end;

{ TFRE_DB_DBChangedNotificationBase }

constructor TFRE_DB_DBChangedNotificationBase.Create(const conn_db: TFRE_DB_NameType);
begin
  FLayerDB := conn_db;
end;

destructor TFRE_DB_DBChangedNotificationBase.Destroy;
begin
  inherited Destroy;
end;

procedure TFRE_DB_DBChangedNotificationBase.StartNotificationBlock(const key: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s]> NOTIFICATION BLOCK START [%s] ',[FLayerDB,key]));
end;

procedure TFRE_DB_DBChangedNotificationBase.FinishNotificationBlock(out block: IFRE_DB_Object);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s]> NOTIFICATION BLOCK FINISH',[FLayerDB]));
  block := nil;
end;

procedure TFRE_DB_DBChangedNotificationBase.SendNotificationBlock(const block: IFRE_DB_Object);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s]> NOTIFICATION BLOCK SEND',[FLayerDB]));
end;

procedure TFRE_DB_DBChangedNotificationBase.CollectionCreated(const coll_name: TFRE_DB_NameType; const in_memory_only: boolean; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> COLLECTION CREATED : [%s (%s)] ',[FLayerDB,tsid,coll_name,BoolToStr(in_memory_only,'Volatile','Persistent')]));
end;

procedure TFRE_DB_DBChangedNotificationBase.CollectionDeleted(const coll_name: TFRE_DB_NameType; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> COLLECTION DELETED : [%s]',[FLayerDB,tsid,coll_name]));
end;

procedure TFRE_DB_DBChangedNotificationBase.IndexDefinedOnField(const coll_name: TFRE_DB_NameType; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean; const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> INDEX [%s] ON COLLECTION CREATED : [%s] (%s)',[FLayerDB,tsid,index_name,coll_name,FieldName+'/'+CFRE_DB_FIELDTYPE[FieldType]]));
end;

procedure TFRE_DB_DBChangedNotificationBase.IndexDroppedOnField(const coll_name: TFRE_DB_NameType; const index_name: TFRE_DB_NameType; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> INDEX [%s] ON COLLECTION DROPPED : [%s]',[FLayerDB,tsid,index_name,coll_name]));
end;

procedure TFRE_DB_DBChangedNotificationBase.ObjectStored(const coll_name: TFRE_DB_NameType; const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> OBJECT STORE IN [%s] -> %s',[FLayerDB,tsid,coll_name,obj.GetDescriptionID]));
end;

procedure TFRE_DB_DBChangedNotificationBase.ObjectDeleted(const coll_names: TFRE_DB_NameTypeArray; const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> OBJECT FINAL DELETE FROM [%s] -> %s',[FLayerDB,tsid,FREDB_CombineString(FREDB_NametypeArray2StringArray(coll_names),','),obj.GetDescriptionID]));
end;

procedure TFRE_DB_DBChangedNotificationBase.ObjectRemoved(const coll_names: TFRE_DB_NameTypeArray; const obj: IFRE_DB_Object; const is_a_full_delete: boolean; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> OBJECT REMOVED FROM [%s] -> %s (%s)',[FLayerDB,tsid,FREDB_CombineString(FREDB_NametypeArray2StringArray(coll_names),','),obj.GetDescriptionID,BoolToStr(is_a_full_delete,'FULL DELETE','COLLECTION REMOVE')]));
end;

procedure TFRE_DB_DBChangedNotificationBase.ObjectUpdated(const obj: IFRE_DB_Object; const colls: TFRE_DB_StringArray; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> OBJECT UPDATED -> %s in [%s]',[FLayerDB,tsid,obj.GetDescriptionID,FREDB_CombineString(colls,',')]));
end;

procedure TFRE_DB_DBChangedNotificationBase.DifferentiallUpdStarts(const obj: IFRE_DB_Object; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> DIFFERENTIAL UPDATE START -> %s',[FLayerDB,tsid,obj.GetDescriptionID]));
end;

procedure TFRE_DB_DBChangedNotificationBase.DifferentiallUpdEnds(const obj_uid: TFRE_DB_GUID; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> DIFFERENTIAL UPDATE END [UID: %s]',[FLayerDB,tsid,FREDB_G2H(obj_uid)]));
end;

procedure TFRE_DB_DBChangedNotificationBase.FieldDelete(const old_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> FIELD [%s/(%s)] DELETED FROM OBJECT -> %s',[FLayerDB,tsid,old_field.FieldName,old_field.FieldTypeAsString,old_field.ParentObject.GetDescriptionID]));
end;

procedure TFRE_DB_DBChangedNotificationBase.FieldAdd(const new_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> FIELD [%s/(%s)] ADDED TO OBJECT -> %s',[FLayerDB,tsid,new_field.FieldName,new_field.FieldTypeAsString,new_field.ParentObject.GetDescriptionID]));
end;

procedure TFRE_DB_DBChangedNotificationBase.FieldChange(const old_field, new_field: IFRE_DB_Field; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> FIELD [%s/(%s)] CHANGED IN OBJECT -> %s',[FLayerDB,tsid,new_field.FieldName,new_field.FieldTypeAsString,new_field.ParentObject.GetDescriptionID]));
end;

procedure TFRE_DB_DBChangedNotificationBase.SetupOutboundRefLink(const from_obj: TFRE_DB_GUID; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
begin
    GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> NEW OUTBOUND REFLINK  [%s] -> [%s] (%s)',[FLayerDB,tsid,FREDB_G2H(from_obj),to_obj.UID_String,key_description]));
end;

procedure TFRE_DB_DBChangedNotificationBase.SetupInboundRefLink(const from_obj: IFRE_DB_Object; const to_obj: TFRE_DB_GUID; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
begin
    GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> NEW INBOUND REFLINK  [%s] -> [%s] (%s)',[FLayerDB,tsid,from_obj.UID_String,FREDB_G2H(to_obj),key_description]));
end;

procedure TFRE_DB_DBChangedNotificationBase.InboundReflinkDropped(const from_obj: IFRE_DB_Object; const to_obj: TFRE_DB_GUID; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
begin
    GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> DROPPED INBOUND REFLINK  [%s] -> [%s] (%s)',[FLayerDB,tsid,from_obj.UID_String,FREDB_G2H(to_obj),key_description]));
end;

procedure TFRE_DB_DBChangedNotificationBase.OutboundReflinkDropped(const from_obj: TFRE_DB_GUID; const to_obj: IFRE_DB_Object; const key_description: TFRE_DB_NameTypeRL; const tsid: TFRE_DB_TransStepId);
begin
  GFRE_DBI.LogInfo(dblc_PERSISTANCE_NOTIFY,Format('[%s/%s]> DROPPED OUTBOUND REFLINK  [%s] -> [%s] (%s)',[FLayerDB,tsid,FREDB_G2H(from_obj),to_obj.UID_String,key_description]));
end;

procedure TFRE_DB_DBChangedNotificationBase.FinalizeNotif;
begin
  Free;
end;

{ TFRE_DB_DeleteCollectionStep }

constructor TFRE_DB_DeleteCollectionStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; const coll_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID);
begin
  inherited create(layer,masterdata,user_context);
  FCollname      := coll_name;
end;

procedure TFRE_DB_DeleteCollectionStep.CheckExistenceAndPreconds;
begin
  if not Master.MasterColls.GetCollection(FCollname,FPersColl) then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'collection [%s] does not exists!',[FCollname]);
  if FPersColl.Count<>0 then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'collection [%s] is not empty (%d) - only empty collections may be deleted!',[FCollname,FPersColl.Count]);
  FVolatile := FPersColl.IsVolatile;
end;

procedure TFRE_DB_DeleteCollectionStep.ChangeInCollectionCheckOrDo(const check: boolean);
begin

end;

procedure TFRE_DB_DeleteCollectionStep.MasterStore(const check: boolean);
var res:TFRE_DB_Errortype;
begin
  if not check then
    begin
      res := Master.MasterColls.DeleteCollection(FCollname);
      if res<>edb_OK  then
        raise EFRE_DB_PL_Exception.Create(res,'failed to delete new collection [%s] in transaction step',[FCollname]);
      if assigned(FNotifIF) then
        FNotifIF.CollectionDeleted(FCollname,GetTransActionStepID);
      if not FVolatile then
        CheckWriteThroughDeleteColl(FCollname);
    end;
end;


{ TFRE_DB_DeleteObjectStep }

constructor TFRE_DB_DeleteObjectStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; const del_obj_uid: TFRE_DB_GUID; const from_coll: TFRE_DB_NameType ; const user_context: PFRE_DB_GUID);
begin
  inherited Create(layer,masterdata,user_context);
  CollName  := from_coll;
  if CollName='' then
    FWouldNeedMasterDelete := true
  else
    FWouldNeedMasterDelete := false;
  FDeleteObjectUid         := del_obj_uid;
end;

procedure TFRE_DB_DeleteObjectStep.CheckExistenceAndPreconds;
var del_obj : TFRE_DB_Object;
begin
  inherited CheckExistenceAndPreconds;

  if not FMaster.FetchObject(FDeleteObjectUid,del_obj,true) then
      raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'an object should be deleted but was not found [%s]',[FREDB_G2H(FDeleteObjectUid)]);

  if (CollName<>'') then
    if del_obj.__InternalCollectionExistsName(CollName)=-1 then
      raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the request to delete object [%s] from collection [%s] could not be completed, the object is not stored in the requested collection',[del_obj.UID_String,CollName]);
  if assigned(FUserToken) and (FUserToken.CheckStdRightSetUIDAndClass(del_obj.UID,del_obj.DomainID,del_obj.SchemeClass,[sr_DELETE])<>edb_OK) then
      raise EFRE_DB_Exception.Create(edb_ACCESS,'no right to delete object [%s]',[FREDB_G2H(FDeleteObjectUid)]);

  if not del_obj.IsObjectRoot then
    raise EFRE_DB_Exception.Create(edb_ERROR,'a delete of a subobject is only allowed via an update of an root object');


  G_Transaction.Record_And_UnlockObject(del_obj);
  FDeleteList := del_obj.GetFullHierarchicObjectList(true);
  if FDeleteList[0].IsObjectRoot=false then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected/non objectroot delete');
end;


procedure TFRE_DB_DeleteObjectStep.ChangeInCollectionCheckOrDo(const check: boolean);
var arr : TFRE_DB_PERSISTANCE_COLLECTION_ARRAY;
      i : NativeInt;
     idx: NativeInt;
begin
  if check
     and (CollName<>'') then
       begin
         if FDeleteList[0].__InternalCollectionExistsName(CollName)=-1 then
           raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the request to delete object [%s] from collection [%s] could not be completed, the object is not stored in the requested collection',[FDeleteList[0].UID_String,CollName]);
       end;
  arr := FDeleteList[0].__InternalGetCollectionList;
  if CollName='' then
    begin { Delete from all }
      SetLength(FDelFromCollections,Length(arr));
      SetLength(FDelFromCollectionsNames,Length(arr));
      for i := 0 to high(arr) do
        begin
          FDelFromCollections[i]      := arr[i];
          FDelFromCollectionsNames[i] := arr[i].CollectionName(false);
          (arr[i] as TFRE_DB_Persistance_Collection).DeleteFromThisColl(FDeleteList[0],check);
          if not check then
            begin
              FDeleteList[0].Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString:=GetTransActionStepID;
              CheckWriteThroughColl(arr[i]);
            end;
        end;
      if not check then
        if assigned(FNotifIF) then
          FNotifIF.ObjectRemoved(FDelFromCollectionsNames,FDeleteList[0],true,GetTransActionStepID);
    end
  else
    begin { Delete from specific collection}
      idx := FDeleteList[0].__InternalCollectionExistsName(CollName); // Delete from this collection self.FDelObj;
      assert(idx<>-1);
      (arr[idx] as TFRE_DB_Persistance_Collection).DeleteFromThisColl(FDeleteList[0],check);
      if check
         and (Length(FDeleteList[0].__InternalGetCollectionList)=1) then
           FWouldNeedMasterDelete:=true;
      SetLength(FDelFromCollections,1);
      SetLength(FDelFromCollectionsNames,1);
      FDelFromCollections[0]      := arr[idx];
      FDelFromCollectionsNames[0] := arr[idx].CollectionName(false);
      if not check then
        begin
          FDeleteList[0].Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString:=GetTransActionStepID;
          if assigned(FNotifIF) then
            FNotifIF.ObjectRemoved(FDelFromCollectionsNames, FDeleteList[0],FWouldNeedMasterDelete,GetTransActionStepID);
          CheckWriteThroughColl(arr[idx]);
        end;
    end;
end;

procedure TFRE_DB_DeleteObjectStep.MasterStore(const check: boolean);
var notify_delob : IFRE_DB_Object;
               i : NativeInt;
begin
  if check
     and FWouldNeedMasterDelete then { this is the check phase, the internalcount is >1}
       begin
         master.DeleteObjectWithSubobjs(FDeleteList[0],check,FNotifIF,GetTransActionStepID);
       end
  else
    begin
      if length(FDeleteList[0].__InternalGetCollectionList)=0 then { this is the real phase}
        begin
          G_Transaction.Forget_UnlockedObject(FDeleteList[0]); { do not unlock it, later it ceases to be }
          if assigned(FNotifIF) then
            begin
              notify_delob := FDeleteList[0].CloneToNewObject;
              notify_delob.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString:=GetTransActionStepID;
            end;
          CheckWriteThroughDeleteObj(FDeleteList[0]); { the changes must only be recorded persistent when the object is finally deleted, the internal collection assosciation is not stored persistent }
          if FDeleteList[0].IsSystemDB then
            G_SysMaster.DeleteObjectWithSubobjs(FDeleteList[0],check,FNotifIF,GetTransActionStepID)
          else
            master.DeleteObjectWithSubobjs(FDeleteList[0],check,FNotifIF,GetTransActionStepID);
          if assigned(FNotifIF) then
            FNotifIF.ObjectDeleted(FDelFromCollectionsNames,notify_delob,GetTransActionStepID); { Notify after delete }
        end;
      for i:=0 to high(FDelFromCollections) do
        CheckWriteThroughColl(FDelFromCollections[i]);
    end;
end;

{ TFRE_DB_NewCollectionStep }


constructor TFRE_DB_NewCollectionStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; const coll_name: TFRE_DB_NameType; const volatile_in_memory: boolean; const user_context: PFRE_DB_GUID);
begin
  inherited Create(layer,masterdata,user_context);
  FCollname      := coll_name;
  FVolatile      := volatile_in_memory;
end;

procedure TFRE_DB_NewCollectionStep.CheckExistenceAndPreconds;
var coll : TFRE_DB_PERSISTANCE_COLLECTION;
begin
  if Master.MasterColls.GetCollection(FCollname,coll) then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'collection [%s] already exists!',[FCollname]);
end;

procedure TFRE_DB_NewCollectionStep.ChangeInCollectionCheckOrDo(const check: boolean);
begin

end;

procedure TFRE_DB_NewCollectionStep.MasterStore(const check: boolean);
var res:TFRE_DB_Errortype;
begin
  if not check then
    begin
      res := Master.MasterColls.NewCollection(FCollname,FNewCollection,FVolatile,Master);
      if res<>edb_OK  then
        raise EFRE_DB_PL_Exception.Create(res,'failed to create new collectiion in step [%s] ',[FCollname]);
      if assigned(FNotifIF) then
        FNotifIF.CollectionCreated(FCollname,FVolatile,GetTransActionStepID);
      CheckWriteThroughColl(FNewCollection);
    end;
end;

function TFRE_DB_NewCollectionStep.GetNewCollection: TFRE_DB_PERSISTANCE_COLLECTION_BASE;
begin
  result := FNewCollection;
end;

{ TFRE_DB_SignedIndex }

class procedure TFRE_DB_SignedIndex.InitializeNullKey;
begin
  SetBinaryComparableKey(0,@nullkey,nullkeylen,true,fdbft_Int16); { fieldtype is irrelevant for the null key }
end;

procedure TFRE_DB_SignedIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint);
begin
  TransformToBinaryComparable(fld,key,keylen,false);
end;

class procedure TFRE_DB_SignedIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint; const is_casesensitive: boolean; const invert_key: boolean);
var is_null_value : Boolean;
begin
  is_null_value := not assigned(fld);
  if not is_null_value then
    SetBinaryComparableKey(fld.AsInt64,key,keylen,is_null_value,fld.FieldType,invert_key)
  else
    SetBinaryComparableKey(0,key,keylen,true,fdbft_NotFound,invert_key);
end;

procedure TFRE_DB_SignedIndex.SetBinaryComparableKey(const keyvalue: int64; const key_target: PByte; var key_len: NativeInt; const is_null: boolean);
begin
  SetBinaryComparableKey(keyvalue,key_target,key_len,is_null,FFieldType);
end;

class procedure TFRE_DB_SignedIndex.SetBinaryComparableKey(const keyvalue: int64; const key_target: PByte; var key_len: NativeInt; const is_null: boolean; const FieldType: TFRE_DB_FIELDTYPE; const invert_key: boolean);
var FFixedKeylen : NativeInt;
    i            : NativeInt;
begin
  if not is_null then
    begin
      GetKeyLenForFieldtype(FieldType,FFixedKeylen);
      key_len := FFixedKeylen+1;
      case FFixedKeylen of
         2: PSmallInt(@key_target[1])^ := SwapEndian(SmallInt(keyvalue));
         4: PInteger(@key_target[1])^  := SwapEndian(Integer(keyvalue));
         8: PInt64(@key_target[1])^    := SwapEndian(keyvalue);
        else
          raise EFRE_DB_PL_Exception.Create(edb_UNSUPPORTED,'unsupported fixed length in index transform to binary comparable');
      end;
      key_target[1] := key_target[1] xor 128;
      key_target[0] := 1; // 0 , val , -val are ordered after NULL values which are prefixed by '0' not by '1'
      if invert_key then
        for i := 1 to key_len do
          key_target[i] := not key_target[i];
    end
  else
    begin
      key_len:=1;
      if not invert_key then
        key_target[0]:=0
      else
        key_target[0]:=2;
    end;
end;

constructor TFRE_DB_SignedIndex.CreateStreamed(const stream: TStream; const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION; const allow_null: boolean; const unique_null: boolean; const domain_idx: boolean);
begin
  Create(idx_name,fieldname,fieldtype,unique,collection,allow_null,unique_null,domain_idx);
  LoadIndex(stream,collection);
end;

procedure TFRE_DB_SignedIndex.FieldTypeIndexCompatCheck(fld: TFRE_DB_FIELD);
begin
  if not SupportsDataType(fld.FieldType) then
    raise EFRE_DB_PL_Exception.Create(edb_ILLEGALCONVERSION,'the signed index can only be used to index a signed number field, not a [%s] field.',[fld.FieldTypeAsString])
end;

function TFRE_DB_SignedIndex.NullvalueExists(var vals: TFRE_DB_IndexValueStore): boolean;
var dummy  : NativeUint;
begin
  result := FIndex.ExistsBinaryKey(@nullkey,nullkeylen,dummy);
  if result then
    vals := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore
  else
    vals := nil;
end;

function TFRE_DB_SignedIndex.SupportsDataType(const typ: TFRE_DB_FIELDTYPE): boolean;
begin
  case typ of
    fdbft_Int16,
    fdbft_Int32,
    fdbft_Int64,
    fdbft_DateTimeUTC,
    fdbft_Currency: result := true;
    else result := false;
  end;
end;

function TFRE_DB_SignedIndex.SupportsSignedQuery: boolean;
begin
  result := true;
end;

function TFRE_DB_SignedIndex.SupportsUnsignedQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_SignedIndex.SupportsStringQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_SignedIndex.SupportsRealQuery: boolean;
begin
  result := false;
end;

procedure TFRE_DB_SignedIndex.ForAllIndexedSignedRange(const min, max: int64; var guids: TFRE_DB_GUIDArray; const ascending: boolean; const min_is_null: boolean; const max_is_max: boolean; const max_count: NativeInt; skipfirst: NativeInt);
var lokey,hikey       : Array [0..8] of Byte;
    lokeylen,hikeylen : NativeInt;
    lokeyp,hikeyp     : PByte;

   procedure IteratorBreak(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var down_counter,up_counter : NativeInt; const abscntr : NativeInt);
   begin
     (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
   end;

begin
  if not min_is_null then
    begin
      SetBinaryComparableKey(min,@lokey,lokeylen,min_is_null);
      lokeyp := lokey;
    end
  else
    lokeyp := nil;
  if not max_is_max then
    begin
      SetBinaryComparableKey(max,@hikey,hikeylen,max_is_max);
      hikeyp := hikey;
    end
  else
    hikeyp := nil;
  FIndex.RangeScan(lokeyp,hikeyp,lokeylen,hikeylen,@IteratorBreak,max_count,skipfirst,ascending)
end;

{ TFRE_DB_UnsignedIndex }

class procedure TFRE_DB_UnsignedIndex.InitializeNullKey;
begin
  SetBinaryComparableKey(0,@nullkey,nullkeylen,true,fdbft_UInt16); { exact fieldtype is irrelevant for null key}
end;

procedure TFRE_DB_UnsignedIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint);
begin
  TransformToBinaryComparable(fld,key,keylen,false);
end;

class procedure TFRE_DB_UnsignedIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint; const is_cassensitive: boolean; const invert_key: boolean);
var guid          : TFRE_DB_GUID;
    is_null_value : boolean;
    isguid        : boolean;
    i             : NativeInt;

begin
  is_null_value := not assigned(fld);
  isguid        := false;

  if (not is_null_value)
     and (fld.FieldType=fdbft_GUID) then
       begin
         guid   := fld.AsGUID;
         isguid := true;
       end
  else
  if (not is_null_value)
     and (fld.FieldType=fdbft_ObjLink) then
       begin
         guid   := fld.AsObjectLink;
         isguid := true;
       end;

  if isguid then
    begin
      if not is_null_value then
        begin
          move(guid,key[1],sizeof(TFRE_DB_GUID));
          keylen:=17;
          key[0]:=1;
          if invert_key then
            for i:=1 to sizeof(TFRE_DB_GUID) do
              key[i] := not key[i];
        end
      else
        begin
          keylen := 2;
          if not invert_key then
            key[0] := 0
          else
            key[0] := 2;
        end
    end
  else
    begin
      if not is_null_value then
        SetBinaryComparableKey(fld.AsUInt64,key,keylen,is_null_value,fld.FieldType,invert_key)
      else
        SetBinaryComparableKey(0,key,keylen,is_null_value,fdbft_NotFound,invert_key);
    end;
end;

procedure TFRE_DB_UnsignedIndex.SetBinaryComparableKey(const keyvalue: qword; const key_target: PByte; var key_len: NativeInt; const is_null: boolean);
begin
  SetBinaryComparableKey(keyvalue,key_target,key_len,is_null,FFieldType);
end;

class procedure TFRE_DB_UnsignedIndex.SetBinaryComparableKey(const keyvalue: qword; const key_target: PByte; var key_len: NativeInt; const is_null: boolean; const FieldType: TFRE_DB_FIELDTYPE; const invert_key: boolean);
var FixedKeyLen : NativeInt;
    i           : NativeInt;
begin
  if not is_null then
    begin
      GetKeyLenForFieldtype(FieldType,FixedKeyLen);
      key_len := FixedKeylen+1;
      case FixedKeylen of
          1: PByte(@key_target[1])^     := Byte(keyvalue);
          2: PWord(@key_target[1])^     := SwapEndian(Word(keyvalue));
          4: PCardinal(@key_target[1])^ := SwapEndian(Cardinal(keyvalue));
          8: PQWord(@key_target[1])^    := SwapEndian(keyvalue);
        else
          raise EFRE_DB_PL_Exception.Create(edb_UNSUPPORTED,'unsupported fixed length in index transform to binary comparable');
      end;
      key_target[0] := 1; // 0 , val are ordered after NULL values which are prefixed by '0' not by '1'
      if invert_key then
        for i := 1 to key_len do
          key_target[i] := not key_target[i];
    end
  else
    begin
      key_len := 1 ; // FixedKeylen; {}
      if not invert_key then
        key_target[0] := 0 // first value
      else
        key_target[0] := 2 // last value
    end;
end;

constructor TFRE_DB_UnsignedIndex.CreateStreamed(const stream: TStream; const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION; const allow_null: boolean; const unique_null: boolean; const domain_idx: boolean);
begin
  Create(idx_name,fieldname,fieldtype,unique,collection,allow_null,unique_null,domain_idx);
  LoadIndex(stream,collection);
end;

procedure TFRE_DB_UnsignedIndex.FieldTypeIndexCompatCheck(fld: TFRE_DB_FIELD);
begin
  if not SupportsDataType(fld.FieldType) then
    raise EFRE_DB_PL_Exception.Create(edb_ILLEGALCONVERSION,'the unsigned index can only be used to index a unsigned number field, not a [%s] field.',[fld.FieldTypeAsString])
end;

function TFRE_DB_UnsignedIndex.NullvalueExists(var vals: TFRE_DB_IndexValueStore): boolean;
var dummy  : NativeUint;
begin
  result := FIndex.ExistsBinaryKey(@nullkey,nullkeylen,dummy);
  if result then
    vals := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore
  else
    vals := nil;
end;

function TFRE_DB_UnsignedIndex.SupportsDataType(const typ: TFRE_DB_FIELDTYPE): boolean;
begin
  case typ of
    fdbft_Byte,
    fdbft_UInt16,
    fdbft_UInt32,
    fdbft_UInt64,
    fdbft_Boolean,
    fdbft_GUID,
    fdbft_ObjLink,
    fdbft_DateTimeUTC: result := true;
    else result := false;
  end;
end;

function TFRE_DB_UnsignedIndex.SupportsSignedQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_UnsignedIndex.SupportsUnsignedQuery: boolean;
begin
  result := true;
end;

function TFRE_DB_UnsignedIndex.SupportsStringQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_UnsignedIndex.SupportsRealQuery: boolean;
begin
  result := false;
end;

procedure TFRE_DB_UnsignedIndex.ForAllIndexedUnsignedRange(const min, max: QWord; var guids: TFRE_DB_GUIDArray; const ascending: boolean; const min_is_null: boolean; const max_is_max: boolean; const max_count: NativeInt; skipfirst: NativeInt);
var lokey,hikey       : Array [0..8] of Byte;
    lokeylen,hikeylen : NativeInt;
    lokeyp,hikeyp     : PByte;

   procedure IteratorBreak(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var down_counter,up_counter : nativeint ; const abscntr : NativeInt);
   begin
     (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
   end;

begin
  if (FFieldType = fdbft_GUID) or
     (FFieldType = fdbft_ObjLink) then
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'no range queries on an uid or objectlink index are allowed');
  if not min_is_null then
    begin
      SetBinaryComparableKey(min,@lokey,lokeylen,min_is_null);
      lokeyp := lokey;
    end
  else
    lokeyp := nil;
  if not max_is_max then
    begin
      SetBinaryComparableKey(max,@hikey,hikeylen,max_is_max);
      hikeyp := hikey;
    end
  else
    hikeyp := nil;
  FIndex.RangeScan(lokeyp,hikeyp,lokeylen,hikeylen,@IteratorBreak,max_count,skipfirst,ascending)
end;

{ TFRE_DB_ChangeStep }

procedure TFRE_DB_ChangeStep.InternalWriteObject(const m: TMemoryStream; const obj: TFRE_DB_Object);
var nsize: NativeInt;
begin
   nsize := obj.NeededSize;
   m.WriteAnsiString(IntToStr(nsize));
   if (m.Size-m.Position)<(nsize) then
       m.SetSize(m.Size + nsize + 4096);
   obj.CopyToMemory(m.Memory+m.Position);
   m.Position:=m.Position+nsize;
end;

procedure TFRE_DB_ChangeStep.InternalReadObject(const m: TStream; var obj: TFRE_DB_Object);
var nsize    : NativeInt;
      mem    : Pointer;
      s      : string;
      stackm : Array [1..4096] of Byte;

begin
   s := m.ReadAnsiString;
   nsize  := FREDB_String2NativeInt(s);
   if nsize>4096 then
     Getmem(mem,nsize)
   else
     mem := @stackm[1];
   try
     m.ReadBuffer(mem^,nsize);
     obj := TFRE_DB_Object.CreateFromMemory(mem);
   finally
     if nsize>4096 then
       Freemem(mem);
   end;
end;

procedure TFRE_DB_ChangeStep.CheckWriteThroughIndexDrop(Coll: TFRE_DB_PERSISTANCE_COLLECTION_BASE; const index: TFRE_DB_NameType);
begin
  CheckWriteThroughColl(coll);
end;

procedure TFRE_DB_ChangeStep.CheckWriteThroughColl(Coll: TFRE_DB_PERSISTANCE_COLLECTION_BASE);
var layer : IFRE_DB_PERSISTANCE_LAYER;
begin
  if coll.IsVolatile then
    exit;
  try
   layer := FLayer;
   if GDBPS_TRANS_WRITE_THROUGH then
     begin
       layer := coll.GetPersLayer;
       layer.WT_StoreCollectionPersistent(coll);
       GFRE_DBI.LogDebug(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH STORE COLLECTION (%s)',[Layer.GetConnectedDB,coll.CollectionName()]));
     end;
  except
    on e:Exception do
      begin
        GFRE_DBI.LogEmergency(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH ERROR STORE COLLECTION (%s) (%s)',[Layer.GetConnectedDB,coll.CollectionName(),e.Message]));
      end;
  end;
end;

procedure TFRE_DB_ChangeStep.CheckWriteThroughDeleteColl(Collname: TFRE_DB_NameType);
begin
  try
   if GDBPS_TRANS_WRITE_THROUGH then
     begin
       FLayer.WT_DeleteCollectionPersistent(Collname);
       GFRE_DBI.LogDebug(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH DELETE COLLECTION (%s)',[FLayer.GetConnectedDB,Collname]));
     end;
  except
    on e:Exception do
      begin
        GFRE_DBI.LogEmergency(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH ERROR DELETE COLLECTION (%s) (%s)',[FLayer.GetConnectedDB,Collname,e.Message]));
      end;
  end;
end;

procedure TFRE_DB_ChangeStep.CheckWriteThroughObj(obj: IFRE_DB_Object);
var layer : IFRE_DB_PERSISTANCE_LAYER;
    cdb   : String;
begin
  try
    if GDBPS_TRANS_WRITE_THROUGH then
      begin
        layer := FLayer;
        if (obj.Implementor as TFRE_DB_Object).IsSystemDB then
          begin
            layer := G_SysMaster.MyLayer;
            layer.WT_StoreObjectPersistent(obj);
          end
        else
          FLayer.WT_StoreObjectPersistent(obj);
        cdb := Layer.GetConnectedDB;
        GFRE_DBI.LogDebug(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH OBJECT (%s)',[cdb,obj.GetDescriptionID]));
      end;
  except
    on e:Exception do
      begin
        GFRE_DBI.LogEmergency(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH ERROR OBJECT (%s) (%s)',[Layer.GetConnectedDB,obj.GetDescriptionID,e.Message]));
      end;
  end;
end;

procedure TFRE_DB_ChangeStep.CheckWriteThroughDeleteObj(obj: IFRE_DB_Object);
var layer : IFRE_DB_PERSISTANCE_LAYER;
    cdb   : TFRE_DB_NameType;
begin
  try
   if GDBPS_TRANS_WRITE_THROUGH then
     begin
       layer := FLayer;
       if (obj.Implementor as TFRE_DB_Object).IsVolatile then
         exit;
       if (obj.Implementor as TFRE_DB_Object).IsSystemDB then
         begin
           layer := G_SysMaster.MyLayer;
           Layer.WT_DeleteObjectPersistent(obj);
         end
       else
         Layer.WT_DeleteObjectPersistent(obj);
       cdb := Layer.GetConnectedDB;
       GFRE_DBI.LogDebug(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH DELETE OBJECT (%s)',[cdb,obj.GetDescriptionID]));
     end;
  except
    on e:Exception do
      begin
        GFRE_DBI.LogEmergency(dblc_PERSISTANCE,Format('[%s]> WRITE THROUGH ERROR DELETE OBJECT (%s) (%s)',[FLayer.GetConnectedDB,obj.GetDescriptionID,e.Message]));
      end;
  end;
end;

function TFRE_DB_ChangeStep._GetCollection(const coll_name: TFRE_DB_NameType; out Collection: TFRE_DB_PERSISTANCE_COLLECTION): Boolean;
begin
  result := FMaster.MasterColls.GetCollection(coll_name,Collection);
end;

constructor TFRE_DB_ChangeStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data ; const user_context : PFRE_DB_GUID);
begin
  FLayer       := layer;
  Fmaster      := masterdata;
  FNotifIF     := Flayer.GetNotificationRecordIF;
  FUserContext := user_context;
end;


procedure TFRE_DB_ChangeStep.CheckExistenceAndPreconds;
begin
  if assigned(FUserContext) then
    G_GetUserToken(FUserContext,FUserToken,true);
end;

procedure TFRE_DB_ChangeStep.SetStepID(const id: NativeInt);
begin
  FStepID:=id;
end;

function TFRE_DB_ChangeStep.GetTransActionStepID: TFRE_DB_TransStepId;
begin
  result := FTransList.GetTransActionId+'/'+inttostr(FStepID);
end;

function TFRE_DB_ChangeStep.Master: TFRE_DB_Master_Data;
begin
  result := Fmaster;
end;

{ TFRE_DB_UpdateStep }

constructor TFRE_DB_UpdateStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; obj: TFRE_DB_Object; const update_in_coll: TFRE_DB_NameType; const user_context: PFRE_DB_GUID);
begin
  inherited Create(layer,masterdata,user_context);
  SetLength(FSublist,25);
  upobj     := obj;
  FCollName := update_in_coll;
end;

constructor TFRE_DB_UpdateStep.CreateFromDiffTransport(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; diff_update_obj: TFRE_DB_Object; const update_in_coll: TFRE_DB_NameType; const user_context: PFRE_DB_GUID);
begin
  inherited Create(layer,masterdata,user_context);
  SetLength(FSublist,25);
  upobj       := nil;
  FCollName   := update_in_coll;
  FDiffUpdate := diff_update_obj;
end;

procedure TFRE_DB_UpdateStep.CheckExistenceAndPreconds;
var P : TFRE_DB_GUIDArray;

   procedure GenUpdate(const is_child_update : boolean ; const up_obj : IFRE_DB_Object ; const update_type :TFRE_DB_ObjCompareEventType  ;const new_ifield, old_ifield: IFRE_DB_Field);
   var child                    : TFRE_DB_Object;
       new_object               : TFRE_DB_Object;
       old_fld,
       new_fld                  : TFRE_DB_FIELD;
       s                        : string;

   begin
     if assigned(old_ifield) then
       begin
         old_fld := old_ifield.Implementor as TFRE_DB_FIELD;
         s:=old_fld.FieldName;
       end
     else
       old_fld := nil;
     if assigned(new_ifield) then
       begin
         new_fld := new_ifield.Implementor as TFRE_DB_FIELD;
         s:=new_fld.FieldName;
       end
     else
       new_fld := nil;
     case update_type of
       cev_FieldDeleted:
           addsubstep(cev_FieldDeleted,nil,old_fld,is_child_update,up_obj.Implementor as TFRE_DB_Object);
       cev_FieldAdded:
           addsubstep(cev_FieldAdded,new_fld,nil,is_child_update,up_obj.Implementor as TFRE_DB_Object);
       cev_FieldChanged :
         if (new_fld.FieldType=fdbft_Object) and (new_fld.AsObject.UID=old_fld.AsObject.UID) then
           begin
             s:='HERE';
             exit; { ignore updates on object fields with same uid, handled in this object }
           end
         else
           addsubstep(cev_FieldChanged,new_fld,old_fld,is_child_update,up_obj.Implementor as TFRE_DB_Object);
     end;
   end;


   procedure GenerateTheChangeListFromDiffObject;
   var deleted_fields,
       updated_fields,
       inserted_fields : TFRE_DB_StringArray;
       child_update    : boolean;
       i               : NativeInt;
       to_update_obj   : TFRE_DB_Object;
       new_obj         : TFRE_DB_Object; { child or root (!) }
       oldfield        : TFRE_DB_FIELD;
       newfield        : TFRE_DB_FIELD;
       difffield       : TFRE_DB_FIELD;
       fieldname       : TFRE_DB_NameType;
       iff             : TFRE_DB_NameType;
       ichld           : TFRE_DB_Object;
       inchld          : TFRE_DB_Object;
       f_in_delete     : boolean;

   begin
     deleted_fields  := FDiffUpdate.Field('D_FN').AsStringArr;
     updated_fields  := FDiffUpdate.Field('U_FN').AsStringArr;
     inserted_fields := FDiffUpdate.Field('I_FN').AsStringArr;
     child_update    := Length(P)>1;
     if not child_update then
       begin
         to_update_obj := to_upd_obj; { "old" root }
         new_obj       := upobj;      { "new" root }
       end
     else
       begin
         new_obj     := upobj; { "new" child }   { search original old child, and create intermediate new childs }
         ichld       := to_upd_obj;
         for i:=1 to high(p) do
           begin
             //writeln(i,'-- ICHILD ',ichld.UID_String,' search ',p[i].AsHexString);
             if not ichld.FetchObjByUIDNonHierarchic(p[i],iff,ichld) then
               begin
                 //writeln('---FULLSTOP--- at index ',i);
                 //writeln(to_upd_obj.DumpToString());
                 //writeln('---- ',p[i].AsHexString,' ----------');
                 //writeln(ichld.DumpToString());
                 //writeln('--------------');
                 raise EFRE_DB_Exception.Create(edb_ERROR,'diffupdate, find field, path not existent');
               end;
             to_update_obj := ichld;
             inchld        := TFRE_DB_Object.Create;
             inchld.Field('UID').AsGUID := p[i];
             new_obj.Field(iff).AsObject := inchld;
             new_obj                     := inchld;
           end;
       end;

     for i := 0 to high(deleted_fields) do
       begin
         fieldname := deleted_fields[i];
         if not to_update_obj.FieldOnlyExisting(fieldname,oldfield) then
           raise EFRE_DB_Exception.Create(edb_ERROR,'diffupdate deletefield / field not found [%s] in [%s]',[fieldname,to_update_obj.UID_String]);
         AddSubStep(cev_FieldDeleted,nil,oldfield,child_update,to_update_obj);
       end;
     for i := 0 to high(inserted_fields) do
       begin
         fieldname := inserted_fields[i];
         f_in_delete:=false;
         if  to_update_obj.FieldOnlyExisting(fieldname,oldfield) then
           begin
             if not FREDB_StringInArray(fieldname,deleted_fields) then
               raise EFRE_DB_Exception.Create(edb_ERROR,'diffupdate insertfield / field already existing field found [%s], and it is not in the actual delete list(!)',[fieldname]);
             f_in_delete := true;
           end;
         if not FDiffUpdate.FieldOnlyExisting('I_F_'+inttostr(i),difffield) then
           raise EFRE_DB_Exception.Create(edb_ERROR,'diffupdate difffield encoding insert [%s] / field not found [%s]',['I_F_'+inttostr(i),fieldname]);
         newfield  := new_obj.Field(fieldname);
         newfield.CloneFromField(difffield);
         AddSubStep(cev_FieldAdded,newfield,nil,child_update,to_update_obj,f_in_delete);
       end;
     for i := 0 to high(updated_fields) do
       begin
         fieldname := updated_fields[i];
         if not to_update_obj.FieldOnlyExisting(fieldname,oldfield) then
           raise EFRE_DB_Exception.Create(edb_ERROR,'diffupdate updatefield / field not found [%s]',[fieldname]);
         if not FDiffUpdate.FieldOnlyExisting('U_F_'+inttostr(i),difffield) then
           raise EFRE_DB_Exception.Create(edb_ERROR,'diffupdate difffield encoding update [%s] / field not found [%s]',['U_F_'+inttostr(i),fieldname]);
         newfield  := new_obj.Field(fieldname);
         newfield.CloneFromField(difffield);
         if newfield.FieldType<>oldfield.FieldType then
           raise EFRE_DB_Exception.Create(edb_ERROR,'diff bulkupdate, fieldupdate, fiedtypes differ [%s]<>[%s]',[newfield.FieldTypeAsString,oldfield.FieldTypeAsString]);
         if newfield.CompareToFieldShallow(oldfield) then
           raise EFRE_DB_Exception.Create(edb_ERROR,'diff bulkupdate, fieldupdate, rejecting update, fieldvalues are the same for field [%s]/[%s] in [%s]',[newfield.FieldName,newfield.FieldTypeAsString,to_update_obj.UID_String]);
         AddSubStep(cev_FieldChanged,newfield,oldfield,child_update,to_update_obj);
       end;

   end;

begin
  inherited CheckExistenceAndPreconds;
  if not assigned(FDiffUpdate) then
    begin { Standard Update }
      FCnt          := 0;
      if upobj.DomainID=CFRE_DB_NullGUID then
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'persistance failure, an object without a domainid cannot be stored');
      upobj._InternalGuidNullCheck;

      if not upobj.IsObjectRoot then
        raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the object [%s] is a child object, only root objects updates are allowed',[upobj.UID_String]);

      if not FMaster.FetchObject(upobj.UID,to_upd_obj,true) then
        raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'an object should be updated but was not found [%s]',[upobj.UID_String]);
      if length(to_upd_obj.__InternalGetCollectionList)=0 then
        begin
          writeln('BAD INTERNAL ::: OFFENDING OBJECT ', to_upd_obj.DumpToString());
          if not GDBPS_SKIP_STARTUP_CHECKS then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'fetched to update ubj must have internal collections(!)');
        end;
      if FCollName<>'' then
        if to_upd_obj.__InternalCollectionExistsName(FCollName)=-1 then
          raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'update, a collectionname was given for updaterequest, but the dbo is not in that collection');

      G_Transaction.Record_And_UnlockObject(to_upd_obj);
      TFRE_DB_Object.GenerateAnObjChangeList(upobj,to_upd_obj,nil,nil,@GenUpdate);
    end
  else
    begin { Differential Update }
      upobj := TFRE_DB_Object.Create; { create an dummy embedding updated object containing the "diff" fields }
      P := FDiffUpdate.Field('P').AsGUIDArr;
      upobj.Field('UID').AsGUID := P[0];
      try
        if not FMaster.FetchObject(upobj.UID,to_upd_obj,true) then
          raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'an object should be updated but was not found [%s]',[upobj.UID_String]);
        upobj.SetDomainID(to_upd_obj.DomainID);
        if upobj.DomainID=CFRE_DB_NullGUID then
          raise EFRE_DB_PL_Exception.Create(edb_ERROR,'persistance failure, an object without a domainid cannot be stored');

        if length(to_upd_obj.__InternalGetCollectionList)=0 then
          begin
            writeln('BAD INTERNAL ::: OFFENDING OBJECT ', to_upd_obj.DumpToString());
            if not GDBPS_SKIP_STARTUP_CHECKS then
              raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'fetched to update ubj must have internal collections(!)');
          end;
        if FCollName<>'' then
          if to_upd_obj.__InternalCollectionExistsName(FCollName)=-1 then
            raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'update, a collectionname was given for updaterequest, but the dbo is not in that collection');
        G_Transaction.Record_And_UnlockObject(to_upd_obj);
        GenerateTheChangeListFromDiffObject;

      except
        writeln('------------');
        writeln(FDiffUpdate.DumpToString());
        writeln('-----------------');
      end;
    end;
end;

procedure TFRE_DB_UpdateStep.AddSubStep(const uptyp: TFRE_DB_ObjCompareEventType; const new, old: TFRE_DB_FIELD; const is_a_child_field: boolean; const update_obj: TFRE_DB_Object; const is_in_delete_list: boolean);
begin
  if FCnt>=Length(FSublist) then
   SetLength(FSublist,Length(FSublist)+25);
  with FSublist[fcnt] do
    begin
      updtyp       := uptyp;
      newfield     := new;
      oldfield     := old;
      up_obj       := update_obj;
      in_child_obj := is_a_child_field;
      in_del_list  := is_in_delete_list;
    end;
  inc(fcnt);
end;

procedure TFRE_DB_UpdateStep.InternallApplyChanges(const check: boolean);
var i,j         : NativeInt;
    collarray   : TFRE_DB_PERSISTANCE_COLLECTION_ARRAY;
    inmemobject : TFRE_DB_Object;

    procedure _DeletedField;
    begin
      with FSublist[i] do
        begin
          if not check then
            if assigned(FNotifIF) then
              FNotifIF.FieldDelete(oldfield,GetTransActionStepID); { Notify before delete }
          case oldfield.FieldType of
            fdbft_Object:
              begin
                if check then
                  begin
                    master.DeleteObjectWithSubobjs(oldfield.AsObject,true,FNotifIF,GetTransActionStepID,true);
                  end
                else
                  begin
                    master.DeleteObjectWithSubobjs(oldfield.AsObject,false,FNotifIF,GetTransActionStepID,true);
                    inmemobject.DeleteField(oldfield.FieldName);
                  end;
              end;
            fdbft_ObjLink:
              begin
                if check then
                  begin
                    if in_child_obj then { new links are nil }
                      raise EFRE_DB_Exception.Create(edb_INTERNAL,'UPDATE/DELETEFIELD a child object must not have reflinks/unexpected case');
                  end
                else
                  begin
                    master._ChangeRefLink(inmemobject,uppercase(inmemobject.SchemeClass),uppercase(oldfield.FieldName),oldfield.AsObjectLinkArray,nil,FNotifIF,GetTransActionStepID);
                    inmemobject.Field(oldfield.FieldName).Clear;
                  end;
              end;
            else begin
              if not check then
                inmemobject.DeleteField(oldfield.FieldName);
            end; // ok
          end;
        end;
    end;

    procedure _AddedField;
    var sc,fn : TFRE_DB_NameType;
        j     : nativeint;

        procedure SubObjectInsert;
        var FInsertList : TFRE_DB_ObjectArray;
            k           : NativeInt;
        begin

          if check then // debug
            begin
              if not FSublist[i].in_del_list then { skip store checks for to be in teh same step deleted objects }
                master.StoreObjectWithSubjs(FSublist[i].newfield.AsObject,check,FNotifIF,GetTransActionStepID);
            end
          else
            begin { for real }
              inmemobject.Field(FSublist[i].newfield.FieldName).AsObject := FSublist[i].newfield.AsObject.CloneToNewObject(); { subobject insert}
              master.StoreObjectWithSubjs(inmemobject.Field(FSublist[i].newfield.FieldName).AsObject,check,FNotifIF,GetTransActionStepID);
            end;
        end;

    begin
      assert(assigned(inmemobject),'internal, logic');
      with FSublist[i] do
        begin
          if not check then
            if assigned(FNotifIF) then
              FNotifIF.FieldAdd(newfield,GetTransActionStepID)
          else
            if (inmemobject.FieldExists(newfield.FieldName) and (not in_del_list)) then
              raise EFRE_DB_Exception.Create(edb_ERROR,'updatestep add field [%s] to object [%s], but the field already exists, and it is not in a delete that happens before',[newfield.FieldName,inmemobject.UID_String]);
          case newfield.FieldType of
            fdbft_NotFound,fdbft_GUID,fdbft_Byte,fdbft_Int16,fdbft_UInt16,fdbft_Int32,fdbft_UInt32,fdbft_Int64,fdbft_UInt64,
            fdbft_Real32,fdbft_Real64,fdbft_Currency,fdbft_String,fdbft_Boolean,fdbft_DateTimeUTC,fdbft_Stream :
              begin
                if check then
                  exit;
                inmemobject.Field(newfield.fieldName).CloneFromField(newfield);
              end;
            fdbft_Object:
              begin
                SubObjectInsert;
              end;
            fdbft_ObjLink:
              if check then
                begin
                  if not FREDB_CheckGuidsUnique(newfield.AsObjectLinkArray) then
                    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'objectlink array field is not unique Field[%s] Object[%s]',[newfield.FieldName,newfield.ParentObject.UID_String]);
                  for j:=0 to high(newfield.AsObjectLinkArray) do
                    master.__CheckReferenceLink(inmemobject,newfield.FieldName,newfield.AsObjectLinkArray[j],sc);
                end
              else
                begin
                  fn := uppercase(inmemobject.SchemeClass)+'<'+ uppercase(newfield.FieldName);
                  inmemobject.Field(newfield.FieldName).AsObjectLinkArray:=newfield.AsObjectLinkArray;
                  for j:=0 to high(newfield.AsObjectLinkArray) do
                    begin
                      master.__CheckReferenceLink(inmemobject,newfield.FieldName,newfield.AsObjectLinkArray[j],sc);
                      master.__SetupInitialRefLink(inmemobject,sc,fn,newfield.AsObjectLinkArray[j],FNotifIF,GetTransActionStepID);
                    end;
                end;
          end;
      end;
    end;

    procedure _ChangedField;
    var sc,fn    : TFRE_DB_NameType;
        j        : nativeint;
        oldlinks : TFRE_DB_GUIDArray;
        existobj : TFRE_DB_Object;
    begin
      with FSublist[i] do
        begin
          assert(up_obj.ObjectRoot = to_upd_obj,'internal, logic');
          if (not check) then
            begin
              if assigned(FNotifIF) then
                FNotifIF.FieldChange(oldfield, newfield,GetTransActionStepID);
            end;
          case newfield.FieldType of
            fdbft_NotFound,fdbft_GUID,fdbft_Byte,fdbft_Int16,fdbft_UInt16,fdbft_Int32,fdbft_UInt32,fdbft_Int64,fdbft_UInt64,
            fdbft_Real32,fdbft_Real64,fdbft_Currency,fdbft_String,fdbft_Boolean,fdbft_DateTimeUTC,fdbft_Stream :
              begin
                if check then
                  exit;
                inmemobject.Field(newfield.FieldName).CloneFromField(newfield);
              end;
            fdbft_Object:
              begin
                if oldfield.AsObject.UID = newfield.AsObject.UID then
                  raise EFRE_DB_Exception.Create(edb_ERROR,'it is not allowed to do a subobject filedupdate with the same uid (same) object in field [%s] of obj [%s] with new objuid [%s]',[newfield.FieldName,inmemobject.UID_String,newfield.AsObject.UID_String]);
                { Free old object, masterfree(old uid=1), store new object, masterstore new object(uid = 1)   }
                if check then
                  begin
                    if FMaster.FetchObject(newfield.AsObject.UID,existobj,true) then
                      begin
                        if existobj.IsObjectRoot then
                          raise EFRE_DB_Exception.Create(edb_ERROR,'the subobject [%s] that is to be inserted in field [%s] of object [%s], is already stored as root object',[newfield.AsObject.UID_String,newfield.FieldName,to_upd_obj.UID_String])
                        else
                          raise EFRE_DB_Exception.Create(edb_ERROR,'the subobject [%s] that is to be inserted in field [%s] of object [%s], is already stored as field [%s] in object [%s]',[newfield.AsObject.UID_String,newfield.FieldName,to_upd_obj.UID_String,existobj.ParentField.FieldName,to_upd_obj.UID_String])
                      end;
                  end
                else
                  begin
                    master.DeleteObjectWithSubobjs(oldfield.AsObject,false,FNotifIF,GetTransActionStepID,true);
                    inmemobject.DeleteField(oldfield.FieldName);

                    inmemobject.Field(newfield.FieldName).AsObject := newfield.AsObject.CloneToNewObject(); { subobject insert}
                    master.StoreObjectWithSubjs(inmemobject.Field(newfield.FieldName).AsObject,check,FNotifIF,GetTransActionStepID);
                  end;
              end;
            fdbft_ObjLink:
              if check then
                begin
                  if not FREDB_CheckGuidsUnique(newfield.AsObjectLinkArray) then
                    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'objectlink array field is not unique Field[%s] Object[%s]',[newfield.FieldName,newfield.ParentObject.UID_String]);
                  for j:=0 to high(newfield.AsObjectLinkArray) do
                    master.__CheckReferenceLink(inmemobject,newfield.FieldName,newfield.AsObjectLinkArray[j],sc,true);
                end
              else
                begin
                  oldlinks := oldfield.AsObjectLinkArray;
                  inmemobject.Field(newfield.FieldName).AsObjectLinkArray:=newfield.AsObjectLinkArray;
                  master._ChangeRefLink(inmemobject,uppercase(inmemobject.SchemeClass),uppercase(newfield.FieldName),oldlinks,newfield.AsObjectLinkArray,FNotifIF,GetTransActionStepID);
                end;
          end;
        end;
    end;

    procedure CheckWriteThrough;
    var arr : TFRE_DB_PERSISTANCE_COLLECTION_ARRAY;
          i : NativeInt;
    begin
      CheckWriteThroughObj(to_upd_obj);
      arr := to_upd_obj.__InternalGetCollectionList;
      for i:=0 to high(arr) do
        CheckWriteThroughColl(arr[i]);
    end;

    var diffupdo : TFRE_DB_Object;

begin
  if not check then
    begin
      to_upd_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString := GetTransActionStepID;
      diffupdo := to_upd_obj.CloneToNewObject; { TODO: replace with a more efficient solution, new object (streaming/weak ...)}
      diffupdo.ClearAllFields;
      diffupdo.Field('uid').AsGUID      := to_upd_obj.UID;
      diffupdo.Field('domainid').AsGUID := to_upd_obj.DomainID;
      if assigned(FNotifIF) then
        FNotifIF.DifferentiallUpdStarts(diffupdo,GetTransActionStepID);
    end;

  for i:=0 to FCnt-1 do
    begin
      with FSublist[i] do
        begin
          //writeln(i,' >> ',updtyp,' ',check,' ',in_del_list);
          inmemobject := up_obj; { a object in to_upd_obj, or = to_upd_obj }
          case updtyp of
            cev_FieldDeleted: _DeletedField;
            cev_FieldAdded:   _AddedField;
            cev_FieldChanged: _ChangedField;
          end;
        end;
    end;
  if not check then
    if assigned(FNotifIF) then
      FNotifIF.DifferentiallUpdEnds(to_upd_obj.UID,GetTransActionStepID); { Notifications will be transmitted on block level -> no special handling here, block get deleted on error }
  if not check then
    begin
      to_upd_obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString := GetTransActionStepID;
      if assigned(FNotifIF) then
        FNotifIF.ObjectUpdated(to_upd_obj,to_upd_obj.__InternalGetCollectionListUSL,GetTransActionStepID);
      {$IFDEF DEBUG_CONSOLE_DUMP_TRANS}
        writeln('---UPDATESTEP DUMP --- FINAL');
        writeln(to_upd_obj.ObjectRoot.DumpToString());
        writeln('---UPDATESTEP DUMP --- DONE');
      {$ENDIF}
      CheckWriteThrough;
    end;
end;

procedure TFRE_DB_UpdateStep.ChangeInCollectionCheckOrDo(const check: boolean);
var i,j       : NativeInt;
    collarray : TFRE_DB_PERSISTANCE_COLLECTION_ARRAY;
begin
  for i:=0 to FCnt-1 do
    with FSublist[i] do
      begin
        collarray := to_upd_obj.__InternalGetCollectionList;
        for j := 0 to high(collarray) do
          (collarray[j] as TFRE_DB_Persistance_Collection).UpdateInThisColl(newfield,oldfield,to_upd_obj,upobj,updtyp,in_child_obj,check); { need to check indices, if appropriate }
      end
end;

//Check what has to be done at master level, (reflinks)
procedure TFRE_DB_UpdateStep.MasterStore(const check: boolean);
begin
  if to_upd_obj.IsObjectRoot then
    if length(to_upd_obj.__InternalGetCollectionList)=0 then
      raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'must have internal collections to store into');
  InternallApplyChanges(check);
end;

{ TFRE_DB_TransactionalUpdateList }

function     ChangeStepNull        (const cs : PFRE_DB_ChangeStep):boolean;
begin
  result := not assigned(cs^);
end;

function     ChangeStepSame        (const cs1,cs2 : PFRE_DB_ChangeStep):boolean;
begin
  result := cs1^=cs2^;
end;

constructor TFRE_DB_TransactionalUpdateList.Create(const TransID: TFRE_DB_NameType; const master_data: TFRE_DB_Master_Data; const notify_if: IFRE_DB_DBChangedNotification);
begin
  FChangeList.InitSparseList(nil,@ChangeStepNull,@ChangeStepSame,10);
  FTransNumber := G_FetchNewTransactionID;
  FTransId     := IntToStr(G_DB_TX_Number)+'#'+TransID;
  FLockDir     := TFRE_DB_Object.Create;
end;

function TFRE_DB_TransactionalUpdateList.AddChangeStep(const step: TFRE_DB_ChangeStep): NativeInt;
begin
  step.FTransList := self;
  result          := FChangeList.Add(step);
  step.SetStepID(result);
  FLastStepId := step.GetTransActionStepID;
end;

procedure TFRE_DB_TransactionalUpdateList.Record_And_UnlockObject(const obj: TFRE_DB_Object);
begin
  obj.Assert_CheckStoreLocked;
  obj.Set_Store_Locked(false);
  FLockDir.Field(obj.UID_String).AsBoolean:=true;
end;

procedure TFRE_DB_TransactionalUpdateList.Record_A_NewObject(const obj: TFRE_DB_Object);
begin
  FLockDir.Field(obj.UID_String).AsBoolean:=true;
end;

procedure TFRE_DB_TransactionalUpdateList.Forget_UnlockedObject(const obj: TFRE_DB_Object);
begin
  FLockDir.DeleteField(obj.UID_String);
end;

procedure TFRE_DB_TransactionalUpdateList.Lock_Unlocked_Objects;

  procedure Lockit(const f:TFRE_DB_FIELD);
  var uid : TFRE_DB_GUID;
      fn  : TFRE_DB_NameType;
  begin
    if f.FieldType=fdbft_Boolean then
      begin
        fn  := f.FieldName;
        uid := FREDB_H2G(fn);
        try
          TFRE_DB_Master_Data._TransactionalLockObject(uid);
        except
          on e:exception do
            begin
              GFRE_DBI.LogError(dblc_PERSISTANCE,'LockUnockedObjects(Transaction) Failure : '+e.Message);
              raise;
            end;
        end;
      end;
  end;

begin
  try
    try
      FLockDir.ForAllFields(@Lockit);
    finally
      FLockDir.ClearAllFields;
    end;
  except
    on e: exception do
      begin
        writeln('INTERNAL FAULT>> Lock_Unlocked_Objects '+e.Message);
      end;
  end;
end;


function     ObjecTFRE_DB_GUIDCompare     (const o1,o2 : PFRE_DB_Object):boolean;
begin
  result := FREDB_Guids_Same(o1^.UID,o2^.UID);
end;

function     DBObjIsNull           (const obj   : PFRE_DB_Object) : Boolean;
begin
  result := not assigned(obj^);
end;

function TFRE_DB_TransactionalUpdateList.GetTransActionId: TFRE_DB_NameType;
begin
  result := FTransId;
end;

function TFRE_DB_TransactionalUpdateList.GetTransLastStepTransId: TFRE_DB_TransStepId;
begin
  result := FLastStepId;
end;

procedure TFRE_DB_TransactionalUpdateList.ProcessCheck;
var failure : boolean;

  procedure CheckForExistence(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  begin
    with step do
      CheckExistenceAndPreconds;
  end;

  procedure StoreInCollectionCheck(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  begin
    with step do
      ChangeInCollectionCheckOrDo(true);
  end;

  procedure MasterStoreCheck(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  begin
    with step do
      MasterStore(true);
  end;

begin
  failure   := false;
  FChangeList.ForAllBreak(@CheckForExistence);
  FChangeList.ForAllBreak(@StoreInCollectionCheck);
  FChangeList.ForAllBreak(@MasterStoreCheck);
end;

function TFRE_DB_TransactionalUpdateList.Commit: boolean;
var changes          : boolean;
    l_notifs         : TList;
    ftransid_w_layer : IFRE_DB_PERSISTANCE_LAYER;

  procedure StoreInCollection(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  begin
    step.ChangeInCollectionCheckOrDo(false);
    if step is TFRE_DB_InsertStep then
      halt_flag:=true;
  end;

  //Store objects and sub objects
  procedure MasterStore(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  begin
    if not assigned(ftransid_w_layer) then
      ftransid_w_layer := step.FLayer; { just get one layer to write the last transaction id on success }
    step.MasterStore(false);
  end;

  procedure GatherNotifs(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  var ni : IFRE_DB_DBChangedNotification;
  begin
    ni := step.FNotifIF;
    if assigned(ni) then
      if l_notifs.IndexOf(ni)=-1 then
        l_notifs.Add(ni);
  end;

  procedure StartNotifBlocks;
  var i : NativeInt;
  begin
    for i := 0 to l_notifs.Count-1 do
      with IFRE_DB_DBChangedNotification(l_notifs.Items[i]) do
        StartNotificationBlock(FTransId);
  end;

  procedure SendNotifBlocks;
  var i     : NativeInt;
      block : IFRE_DB_Object;
  begin
    for i := 0 to l_notifs.Count-1 do
      with IFRE_DB_DBChangedNotification(l_notifs.Items[i]) do
        begin
          FinishNotificationBlock(block);
          if assigned(block) then
            SendNotificationBlock(block);
        end;
  end;


begin
  ftransid_w_layer := nil;
  try
    { Perform all necessary prechecks before changing the Database }
    ProcessCheck;

    changes := FChangeList.Count>0;
    { Apply the changes, and record the Notifications }
    if changes then
      begin
        try
          if changes then
            begin
              try
                l_notifs := TList.Create;
                FChangeList.ForAllBreak(@GatherNotifs);
                StartNotifBlocks;
                FChangeList.ForAllBreak(@StoreInCollection);
                FChangeList.ForAllBreak(@MasterStore);
                ftransid_w_layer.WT_TransactionID(FTransNumber);
                SendNotifBlocks;
              except on e:exception do
                begin
                  GFRE_DBI.LogEmergency(dblc_PERSISTANCE,'-TRANSACTION FAILURE (NOT IN CHECK PHASE) [%s]'+e.Message);
                  GFRE_BT.CriticalAbort('-TRANSACTION FAILURE (NOT IN CHECK PHASE) [%s]'+e.Message);
                end;
              end;
            end
          else
           changes:=changes;
        finally
          l_notifs.free;
        end;
      end;
    result := changes;
  finally
    Lock_Unlocked_Objects;
  end;
  {$IFDEF DEBUG_STORELOCK}
   GFRE_DB_PS_LAYER.DEBUG_InternalFunction(1); { Full Storelocking Check }
  {$ENDIF}
  {$IFDEF DEBUG_SUBOBJECTS_STORED}
   GFRE_DB_PS_LAYER.DEBUG_InternalFunction(2); { Full Subobject Storage Check }
  {$ENDIF}
end;

procedure TFRE_DB_TransactionalUpdateList.Rollback;
begin
  abort;
end;

destructor TFRE_DB_TransactionalUpdateList.Destroy;
  procedure CleanUp(var step:TFRE_DB_ChangeStep;const idx:NativeInt ; var halt_flag:boolean);
  begin
    step.Free;
  end;
begin
  FChangeList.ForAllBreak(@Cleanup);
  FLockDir.Free;
end;

{ TFRE_DB_InsertStep }

constructor TFRE_DB_InsertStep.Create(const layer: IFRE_DB_PERSISTANCE_LAYER; const masterdata: TFRE_DB_Master_Data; new_obj: TFRE_DB_Object; const insert_in_coll: TFRE_DB_NameType; const user_context: PFRE_DB_GUID);
var cn:string;
begin
  inherited Create(layer,masterdata,user_context);
  FCollName   := insert_in_coll;
  FInsertList := new_obj.GetFullHierarchicObjectList(true);
end;

procedure TFRE_DB_InsertStep.CheckExistenceAndPreconds;
var existing_object : TFRE_DB_Object;
    i               : NativeInt;
    Foldobject      : TFRE_DB_Object;
begin
  try
    if FCollName='' then
      raise EFRE_DB_PL_Exception.Create(edb_INVALID_PARAMS,'a collectionname must be provided on store request');
    if not _GetCollection(FCollName,FColl) then
      raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'store step, the specified collection [%s] was not found',[FCollName]);
    if FInsertList[0].IsObjectRoot=false then
      raise EFRE_DB_Exception.Create(edb_INTERNAL,'initial store of non root objects is not allowed');

    if FInsertList[0].DomainID=CFRE_DB_NullGUID then
      raise EFRE_DB_PL_Exception.Create(edb_ERROR,'store, persistance failure, an object without a domainid cannot be stored');

    FInsertList[0]._InternalGuidNullCheck;

    if Fcoll.IsVolatile then
      FInsertList[0].Set_Volatile;

    for i:=0 to high(FInsertList) do
      begin
        if master.FetchObject(FInsertList[i].UID,existing_object,true) then
          begin
            if existing_object.IsObjectRoot then
              begin
                if i<>0 then
                  raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected case %d should be 0, and not an objectroot',[i]);
                G_Transaction.Record_And_UnlockObject(existing_object);
                FCollName:=FCollName;
                if existing_object.__InternalCollectionExistsName(FCollName)<>-1 then
                  raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'the to be stored rootobject [%s] does already exist in master data as subobject or rootobject, and in the specified collection [%s]',[FInsertList[i].UID_String,FCollName]);
                if not TFRE_DB_Object.CompareObjectsEqual(FInsertList[i],existing_object) then
                  raise EFRE_DB_PL_Exception.Create(edb_MISMATCH,'the to be stored rootobject [%s] does already exist in master data as subobject or rootobject, it is requested to store in the new collection [%s], but the insert object is not exactly the same as the existing object',[FInsertList[i].UID_String,FCollName]);
                FThisIsAnAddToAnotherColl := true;
                Foldobject := FInsertList[0];
                SetLength(FInsertList,1);
                FInsertList[0] := existing_object;
                try
                 Foldobject.free;
                except
                  on e:exception do
                    begin
                      GFRE_DBI.LogError(dblc_PERSISTANCE,'unexpected exception InsertStep/Checkexistience multiple collection store [%s]',[e.Message]);
                    end;
                end;
                break; { stop insert object processing }
              end
            else
              begin
                raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'for the to be stored rootobject [%s] a subobject [%s] does already exist in master data as subobject or rootobject, the specified collection is [%s]',[FInsertList[0].UID_String,FInsertList[i].UID_String,FCollName]);
              end;
          end;
      end;
  {$IFDEF DEBUG_OFFENDERS}
  except
    writeln('>INSERT---OFFENDING OBJECT---');
    writeln(FInsertList[0].DumpToString(2));
    writeln('<INSERT---OFFENDING OBJECT---');
    raise
  end;
  {$ENDIF}
end;

procedure TFRE_DB_InsertStep.ChangeInCollectionCheckOrDo(const check: boolean);
begin
  try
    (FColl as TFRE_DB_Persistance_Collection).StoreInThisColl(FInsertList[0],check);
  except
    on e:Exception do
      begin
        writeln('INSERT STEP <',GetTransActionStepID,'> FAILURE ('+e.Message+')'); { TODO -> In transaction and Step ID}
        writeln('Offending Object');
        writeln('-------------------');
        writeln(FInsertList[0].DumpToString(2));
        writeln('-------------------');
        raise;
      end;
  end;
end;

procedure TFRE_DB_InsertStep.MasterStore(const check: boolean);
var i : NativeInt;
begin
  assert((check=true) or (length(FInsertList[0].__InternalGetCollectionList)>0));
  if check then
    G_Transaction.Record_A_NewObject(FInsertList[0]);
  if not FThisIsAnAddToAnotherColl then
    begin
      master.StoreObjectWithSubjs(FInsertList[0],check,FNotifIF,GetTransActionStepID);
    end;
  if not check then
    begin
      FInsertList[0].Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString := GetTransActionStepID;
      if assigned(FNotifIF) then
         FNotifIF.ObjectStored(FColl.CollectionName, FInsertList[0],GetTransActionStepID);
      CheckWriteThroughObj(FInsertList[0]);
      CheckWriteThroughColl(FColl);
    end;
end;

{ TFRE_DB_IndexValueStore }

procedure TFRE_DB_IndexValueStore.InternalCheck;
var i:NativeInt;
begin
  //try
  //  for i:=0 to high(FOBJArray) do
  //    FOBJArray[i].Assert_CheckStoreLocked;
  //except on e:Exception do
  // begin
  //  writeln('E ',e.Message);
  //  writeln('LEN ARRAY ',Length(FOBJArray));
  //  for i:=0 to high(FOBJArray) do
  //    begin
  //      writeln('--',i,' ',FOBJArray[i].InternalUniqueDebugKey);
  //      writeln(FOBJArray[i].DumpToString());
  //      writeln('--');
  //    end;
  //  raise;
  // end;
  //end;
end;


function TFRE_DB_IndexValueStore.Exists(const guid: TFRE_DB_GUID): boolean;
var i : NativeInt;
begin
  for i := 0 to High(FOBJArray) do
    if FREDB_Guids_Compare(FOBJArray[i],guid)=0 then
      exit(true);
  result := false;
end;

function TFRE_DB_IndexValueStore.Add(const objuid: TFRE_DB_GUID): boolean;
begin
  if Exists(objuid) then
    exit(false);
  SetLength(FOBJArray,Length(FOBJArray)+1);
  FOBJArray[high(FOBJArray)] := objuid;
  result := true;
end;

procedure TFRE_DB_IndexValueStore.StreamToThis(const stream: TStream);
var i : NativeInt;
begin
  stream.WriteQWord(Length(FOBJArray));
  for i:=0 to high(FOBJArray) do
    stream.WriteBuffer(FOBJArray[i],SizeOf(TFRE_DB_GUID));
end;

procedure TFRE_DB_IndexValueStore.LoadFromThis(const stream: TStream; const coll: TFRE_DB_PERSISTANCE_COLLECTION);
var i,cnt : NativeInt;
    uid   : TFRE_DB_GUID;
    obj   : IFRE_DB_Object;
begin
  cnt := stream.ReadQWord;
  SetLength(FOBJArray,cnt);
  for i:=0 to high(FOBJArray) do
    begin
      stream.ReadBuffer(uid,SizeOf(TFRE_DB_GUID));
      FOBJArray[i] := uid;
      if not coll.FetchIntFromColl(uid,obj) then //
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'STREAM LOAD INDEX ERROR CANT FIND [%s] IN COLLECTION',[FREDB_G2H(uid)]);
    end;
end;

function TFRE_DB_IndexValueStore.ObjectCount: NativeInt;
begin
  result := Length(FOBJArray);
end;

procedure TFRE_DB_IndexValueStore.AppendObjectUIDS(var uids: TFRE_DB_GUIDArray; const ascending: boolean; var down_counter, up_counter: NativeInt ; const max_count : Nativeint);
var i,pos : NativeInt;
begin
  pos := Length(uids);
  SetLength(uids,Length(uids)+ObjectCount);
  if ascending then
    for i := 0 to high(FOBJArray) do
      begin
        if down_counter>0 then
          dec(down_counter)
        else
          begin
            uids[pos] := FOBJArray[i];
            inc(pos);
            inc(up_counter);
            if (max_count>0) and
               (up_counter>=max_count) then
                 break;
          end;
      end
  else
    for i := high(FOBJArray) downto 0 do
      begin
        if down_counter>0 then
          dec(down_counter)
        else
          begin
            uids[pos] := FOBJArray[i];
            inc(pos);
            inc(up_counter);
            if (max_count>0) and
               (up_counter>=max_count) then
                 break;
          end;
      end;
  if pos<>Length(uids) then
    SetLength(uids,pos);
end;

function TFRE_DB_IndexValueStore.RemoveUID(const guid: TFRE_DB_GUID): boolean;
var i        : NativeInt;
    newarray : TFRE_DB_GUIDArray;
    cnt      : NativeInt;
begin
  SetLength(newarray,high(FOBJArray));
  cnt    := 0;
  result := false;
  for i := 0 to High(FOBJArray) do
    if FOBJArray[i]<>guid then
      begin
        newarray[cnt] := FOBJArray[i];
        inc(cnt);
      end
    else
      result := true;
  FOBJArray := newarray;
end;

constructor TFRE_DB_IndexValueStore.create;
begin
  inherited;
end;

destructor TFRE_DB_IndexValueStore.Destroy;
begin
  inherited Destroy;
end;

{ TFRE_DB_Master_Data }


function TFRE_DB_Master_Data.GetOutBoundRefLinks(const from_obj: TFRE_DB_GUID): TFRE_DB_ObjectReferences;
var key : RFRE_DB_GUID_RefLink_InOut_Key;
    cnt : NativeInt;

   procedure Iterate(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var halt : boolean);
   var namelen : NativeInt;
       name    : TFRE_DB_NameType;
   begin
     if cnt=Length(result) then
       SetLength(result,Length(result)+10);
     assert(value=$BAD0BEEF);
     namelen := KeyLen-33;
     Assert(namelen>0);
     SetLength(name,namelen);
     move(PFRE_DB_GUID_RefLink_In_Key(key)^.SchemeSepField,name[1],namelen); // copy name
     result[cnt].fieldname  := GFRE_BT.SepLeft(name,'>');
     result[cnt].schemename := GFRE_BT.SepRight(name,'>');
     move(PFRE_DB_GUID_RefLink_In_Key(key)^.ToFromGuid,result[cnt].linked_uid,16); // copy guid
     inc(cnt);
   end;

begin
  cnt := 0;
  move(from_obj,key.GUID,16);
  key.RefTyp:=$99;
  FMasterRefLinks.PrefixScan(@key,17,@Iterate);
  SetLength(result,cnt);
end;

function TFRE_DB_Master_Data.GetInboundRefLinks(const to_obj: TFRE_DB_GUID): TFRE_DB_ObjectReferences;
var key : RFRE_DB_GUID_RefLink_InOut_Key;
    cnt : NativeInt;

   procedure Iterate(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var halt : boolean);
   var namelen : NativeInt;
       name    : TFRE_DB_NameType;
   begin
     if cnt=Length(result) then
       SetLength(result,Length(result)+10);
     assert(value=$BEEF0BAD);
     namelen := KeyLen-33;
     Assert(namelen>0);
     SetLength(name,namelen);
     move(PFRE_DB_GUID_RefLink_In_Key(key)^.SchemeSepField,name[1],namelen); // copy name
     result[cnt].fieldname  := GFRE_BT.SepRight(name,'<');
     result[cnt].schemename := GFRE_BT.SepLeft(name,'<');
     move(PFRE_DB_GUID_RefLink_In_Key(key)^.ToFromGuid,result[cnt].linked_uid,16); // copy guid
     inc(cnt);
   end;

begin
  cnt := 0;
  move(to_obj,key.GUID,16);
  key.RefTyp:=$AA;
  FMasterRefLinks.PrefixScan(@key,17,@Iterate);
  SetLength(result,cnt);
end;

procedure TFRE_DB_Master_Data.__RemoveInboundReflink(const from_uid, to_uid: TFRE_DB_GUID; const scheme_link_key: TFRE_DB_NameTypeRL; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var
  refinkey   : RFRE_DB_GUID_RefLink_InOut_Key;
  exists     : boolean;
  value      : PtrUInt;
  from_obj   : TFRE_DB_Object;
  lock_state : boolean;

begin
  __SetupInboundLinkKey(from_uid,to_uid,scheme_link_key,refinkey);
  exists := FMasterRefLinks.RemoveBinaryKey(@refinkey,refinkey.KeyLength,value);
  if not exists then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'internal inbound reflink structure bad, inbound link not found for outbound from,to,schemelink [%s, %s, %s]',[FREDB_G2H(from_uid),FREDB_G2H(to_uid),scheme_link_key]);
  if value<>$BEEF0BAD then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'internal inbound reflink structure bad, value invalid [%d]',[value]);

  if not FetchObject(from_uid,from_obj,true) then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'remove inbound reflink not found %s',[FREDB_G2H(to_uid)]);

  if assigned(notifif) then
    begin
      from_obj.Set_Store_LockedUnLockedIf(false,lock_state); { Locking is ok here, to reduce cloning }
      try
        notifif.InboundReflinkDropped(from_obj,to_uid,scheme_link_key,tsid);
      finally
        from_obj.Set_Store_LockedUnLockedIf(true,lock_state);
      end;
    end;
end;

procedure TFRE_DB_Master_Data.__RemoveOutboundReflink(const from_uid, to_uid: TFRE_DB_GUID; const scheme_link_key: TFRE_DB_NameTypeRL; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var
  refoutkey  : RFRE_DB_GUID_RefLink_InOut_Key;
  exists     : boolean;
  value      : PtrUInt;
  to_obj     : TFRE_DB_Object;
  lock_state : boolean;
begin
  __SetupOutboundLinkKey(from_uid,to_uid,scheme_link_key,refoutkey);
  exists := FMasterRefLinks.RemoveBinaryKey(@refoutkey,refoutkey.KeyLength,value);
  if not exists then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'internal outbound reflink structure bad, inbound link not found for outbound from,to,schemelink [%s, %s, %s]',[FREDB_G2H(from_uid),FREDB_G2H(to_uid),scheme_link_key]);
  if value<>$BAD0BEEF then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'internal outbound reflink structure bad, value invalid [%d]',[value]);
  if not FetchObject(to_uid,to_obj,true) then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'remove outbound reflink not found %s',[FREDB_G2H(to_uid)]);
  if assigned(notifif) then
    begin
      to_obj.Set_Store_LockedUnLockedIf(false,lock_state);
      try
        notifif.OutboundReflinkDropped(from_uid,to_obj,scheme_link_key,tsid); { Locking is ok here, to reduce cloning }
      finally
        to_obj.Set_Store_LockedUnLockedIf(true,lock_state);
      end;
    end;
end;

procedure TFRE_DB_Master_Data.__RemoveRefLink(const from_uid, to_uid: TFRE_DB_GUID; const upper_from_schemename, upper_fieldname, upper_to_schemename: TFRE_DB_NameType; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var
   scheme_link_key    : TFRE_DB_NameTypeRL;
begin
  scheme_link_key := upper_from_schemename+'<'+upper_fieldname;
  __RemoveInboundRefLink(from_uid,to_uid,scheme_link_key,notifif,tsid);
  scheme_link_key := upper_fieldname+'>'+upper_to_schemename;
  __RemoveOutboundReflink(from_uid,to_uid,scheme_link_key,notifif,tsid);
end;

procedure TFRE_DB_Master_Data.__SetupOutboundLinkKey(const from_uid, to_uid: TFRE_DB_GUID; const scheme_link_key: TFRE_DB_NameTypeRL; var refoutkey: RFRE_DB_GUID_RefLink_InOut_Key);
begin
  move(from_uid,refoutkey.GUID,16);
  refoutkey.RefTyp := $99;
  move(to_uid,refoutkey.ToFromGuid,16);
  move(scheme_link_key[1],refoutkey.SchemeSepField,Length(scheme_link_key));
  refoutkey.KeyLength := 33+Length(scheme_link_key);
end;

procedure TFRE_DB_Master_Data.__SetupInboundLinkKey(const from_uid, to_uid: TFRE_DB_GUID; const scheme_link_key: TFRE_DB_NameTypeRL; var refinkey: RFRE_DB_GUID_RefLink_InOut_Key);
begin
  move(to_uid,refinkey.GUID,16);
  refinkey.RefTyp := $AA;
  move(from_uid,refinkey.ToFromGuid,16);
  move(scheme_link_key[1],refinkey.SchemeSepField,length(scheme_link_key));
  refinkey.KeyLength := 33+Length(scheme_link_key);
end;

function TFRE_DB_Master_Data.__RefLinkOutboundExists(const from_uid: TFRE_DB_GUID; const fieldname: TFRE_DB_NameType; to_object: TFRE_DB_GUID; const scheme_link: TFRE_DB_NameTypeRL): boolean;
var refoutkey : RFRE_DB_GUID_RefLink_InOut_Key;
    value     : PtrUInt;
begin
  __SetupOutboundLinkKey(from_uid,to_object,scheme_link,refoutkey);
  result := FMasterRefLinks.ExistsBinaryKey(@refoutkey,refoutkey.KeyLength,value);
  if result and
     (value<>$BAD0BEEF) then
       raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'internal outbound reflink structure bad, value invalid [%d]',[value]);
end;

function TFRE_DB_Master_Data.__RefLinkInboundExists(const from_uid: TFRE_DB_GUID; const fieldname: TFRE_DB_NameType; to_object: TFRE_DB_GUID; const scheme_link: TFRE_DB_NameTypeRL): boolean;
var refinkey : RFRE_DB_GUID_RefLink_InOut_Key;
    value    : PtrUInt;
begin
  __SetupInboundLinkKey(from_uid,to_object,scheme_link,refinkey);
  result := FMasterRefLinks.ExistsBinaryKey(@refinkey,refinkey.KeyLength,value);
  if result
     and (value<>$BEEF0BAD) then
       raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'internal inbound reflink structure bad, value invalid [%d]',[value]);
end;

procedure TFRE_DB_Master_Data.__CheckReferenceLink(const obj: TFRE_DB_Object; fieldname: TFRE_DB_NameType; link: TFRE_DB_GUID; var scheme_link: TFRE_DB_NameTypeRL;const allow_existing_links : boolean);
var j       : NativeInt;
    ref_obj : TFRE_DB_Object;

begin
  //writeln('TODO _ PARALLEL CHECK OF REFLINK INDEX TREE');
  if not FetchObject(link,ref_obj,true) then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'referential link check: link from obj(%s:%s) to obj(%s) : the to object does not exist!',[obj.GetDescriptionID,fieldname,FREDB_G2H(link)]);
  if obj.IsVolatile or obj.IsSystem then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'referential link check: link from obj(%s:%s) to obj(%s) : the linking object is volatile or system!',[obj.GetDescriptionID,fieldname,FREDB_G2H(link)]);
  scheme_link := uppercase(fieldname+'>'+ref_obj.SchemeClass);
  if (not allow_existing_links) and
     __RefLinkOutboundExists(obj.UID,fieldname,link,scheme_link) then
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'outbound reflink already existing from  from obj(%s:%s) to obj(%s:%s)',[obj.UID_String,fieldname,FREDB_G2H(link),ref_obj.SchemeClass]);
  if (not allow_existing_links) and
     __RefLinkInboundExists(obj.UID,fieldname,link,uppercase(obj.SchemeClass+'<'+fieldname)) then
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'outbound reflink already existing from  from obj(%s:%s) to obj(%s:%s)',[obj.UID_String,fieldname,FREDB_G2H(link),ref_obj.SchemeClass]);
end;

// Setup the "to_list" for KEY-UID,Field,(Subkeys)
// For every in the "to_list" referenced object set an inbound link, from KEY-UID

procedure TFRE_DB_Master_Data.__SetupInitialRefLink(const from_key: TFRE_DB_Object; FromFieldToSchemename, LinkFromSchemenameField: TFRE_DB_NameTypeRL; const references_to: TFRE_DB_GUID; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var refoutkey     : RFRE_DB_GUID_RefLink_InOut_Key;
    refinkey      : RFRE_DB_GUID_RefLink_InOut_Key;
    ref_obj       : TFRE_DB_Object;
    fieldname     : TFRE_DB_NameType;
    schemename    : TFRE_DB_NameType;
    was_locked    : boolean;

begin
  assert(pos('>',FromFieldToSchemename)>0,'internal reflink failure 1');
  FREDB_SplitRefLinkDescription(FromFieldToSchemename,fieldname,schemename);

  if not FetchObject(references_to,ref_obj,true) then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'referential link check: link from obj(%s:%s) to obj(%s) : the to object does not exist!',[from_key.GetDescriptionID,FromFieldToSchemename,FREDB_G2H(references_to)]);
  if not ref_obj.IsObjectRoot then
    begin
      writeln('SSSLL :::');
      writeln(ref_obj.DumpToString());
      halt;
    end;
  FromFieldToSchemename   := uppercase(fieldname+'>'+ref_obj.SchemeClass);
  LinkFromSchemenameField := uppercase(from_key.SchemeClass+'<'+fieldname);

  __SetupOutboundLinkKey(from_key.UID,references_to,FromFieldToSchemename,refoutkey);
  if not FMasterRefLinks.InsertBinaryKey(@refoutkey,refoutkey.KeyLength,$BAD0BEEF) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'although prechecked the reflink fromkey exists. :-(');

  assert(pos('<',LinkFromSchemenameField)>0,'internal reflink failure 2');
  __SetupInboundLinkKey(from_key.UID,references_to,LinkFromSchemenameField,refinkey);
  if not FMasterRefLinks.InsertBinaryKey(@refinkey,refinkey.KeyLength,$BEEF0BAD) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'although prechecked the reflink tokey exists. :-(');

  { Notify after link setup }
  if assigned(notifif) then
    begin
      ref_obj.Set_Store_LockedUnLockedIf(false,was_locked); { Locking is ok here, to reduce cloning }
      try
        notifif.SetupOutboundRefLink(from_key.UID,ref_obj,FromFieldToSchemename,tsid);
      finally
        ref_obj.Set_Store_LockedUnLockedIf(true,was_locked);
      end;
      notifif.SetupInboundRefLink(from_key,references_to,LinkFromSchemenameField,tsid);
    end;
end;

procedure TFRE_DB_Master_Data._ChangeRefLink(const from_obj: TFRE_DB_Object; const upper_schemename: TFRE_DB_NameType; const upper_fieldname: TFRE_DB_NameType; const old_links, new_links: TFRE_DB_GUIDArray; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var
    inserted_list     : TFRE_DB_GUIDArray;
    removed_list      : TFRE_DB_GUIDArray;
    i,idx             : NativeInt;
    dbg               : Nativeint;
    outlist           : TFRE_DB_ObjectReferences;
    object_references : TFRE_DB_ObjectReferences;
    to_scheme_name    : TFRE_DB_NameType;
    schemelink        : TFRE_DB_NameTypeRL;

    function FREDB_GetToUidSchemeclassfromReferences(const from_obr : TFRE_DB_ObjectReferences; const upper_from_fieldname : TFRE_DB_NameType; const to_uid:TFRE_DB_GUID; var tolink_schemename:TFRE_DB_NameType) : boolean;
    var i:integer;
    begin
      result:=false;
      for i:=0 to high(object_references) do
        begin
          if (from_obr[i].fieldname=upper_fieldname)
             and (from_obr[i].linked_uid=to_uid) then
               begin
                 tolink_schemename := from_obr[i].schemename;
                 exit(true);
               end;
        end;
    end;

begin
  dbg := Length(old_links);
  dbg := Length(new_links);
  SetLength(inserted_list,Length(new_links));
  SetLength(removed_list,Length(old_links));

  idx := 0;
  for i:=0 to high(old_links) do
    if FREDB_GuidInArray(old_links[i],new_links)=-1 then
      begin
        removed_list[idx] := old_links[i];
        inc(idx);
      end;
  SetLength(removed_list,idx);

  idx := 0;
  for i:=0 to high(new_links) do
    if FREDB_GuidInArray(new_links[i],old_links)=-1 then
      begin
        inserted_list[idx] := new_links[i];
        inc(idx);
      end;
  SetLength(inserted_list,idx);

  object_references := GetOutBoundRefLinks(from_obj.UID);

  for i:= 0 to high(removed_list) do
    begin
      FREDB_GetToUidSchemeclassfromReferences(object_references,upper_fieldname,removed_list[i],to_scheme_name);
      __RemoveRefLink(from_obj.UID,removed_list[i],upper_schemename,upper_fieldname,to_scheme_name,notifif,tsid);
    end;

  for i:= 0 to high(inserted_list) do
    begin
      __CheckReferenceLink(from_obj,upper_fieldname,inserted_list[i],schemelink,false);
      __SetupInitialRefLink(from_obj,schemelink,upper_schemename+'<'+upper_fieldname,inserted_list[i],notifif,tsid);
    end;
end;

procedure TFRE_DB_Master_Data._SetupInitialRefLinks(const from_key: TFRE_DB_Object; const references_to_list: TFRE_DB_ObjectReferences; const schemelink_arr: TFRE_DB_NameTypeRLArray; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var
  i: NativeInt;
begin
  assert(Length(references_to_list)=Length(schemelink_arr),'internal error');
  for i:=0 to high(references_to_list) do
    __SetupInitialRefLink(from_key,schemelink_arr[i],uppercase(from_key.SchemeClass+'<'+references_to_list[i].fieldname),references_to_list[i].linked_uid,notifif,tsid);
end;

procedure TFRE_DB_Master_Data._RemoveAllRefLinks(const from_key: TFRE_DB_Object; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var object_references  : TFRE_DB_ObjectReferences;
    refoutkey          : RFRE_DB_GUID_RefLink_InOut_Key;
    refinkey           : RFRE_DB_GUID_RefLink_InOut_Key;
    i                  : NativeInt;
    from_uid,to_object : TFRE_DB_GUID;
    sc_from            : TFRE_DB_NameType;
    scheme_link_key    : TFRE_DB_NameTypeRL;

  //begin
  //  scheme_link_key := sc_from+'<'+object_references[i].fieldname;
  //  __RemoveInboundRefLink(from_uid,object_references[i].linked_uid,scheme_link_key);
  //  scheme_link_key := object_references[i].fieldname+'>'+object_references[i].schemename;
  //  __RemoveOutboundReflink(from_uid,object_references[i].linked_uid,scheme_link_key);
  //end;


begin
  from_uid := from_key.UID;
  sc_from  := uppercase(from_key.SchemeClass);
  object_references := GetOutBoundRefLinks(from_key.UID);
  for i:=0 to high(object_references) do
    __RemoveRefLink(from_uid,object_references[i].linked_uid,sc_from,object_references[i].fieldname,object_references[i].schemename,notifif,tsid);
end;

procedure TFRE_DB_Master_Data._CheckRefIntegrityForObject(const obj: TFRE_DB_Object; var ref_array: TFRE_DB_ObjectReferences; var schemelink_arr: TFRE_DB_NameTypeRLArray);
var  i : NativeInt;
begin
  ref_array := obj.ReferencesFromData;
  SetLength(schemelink_arr,Length(ref_array));
  for i:=0 to high(ref_array) do
    __CheckReferenceLink(obj,ref_array[i].fieldname,ref_array[i].linked_uid,schemelink_arr[i]);
end;

procedure TFRE_DB_Master_Data._CheckExistingReferencelinksAndRemoveMissingFromObject(const obj: TFRE_DB_Object);
var  i              : NativeInt;
     ref_array      : TFRE_DB_ObjectReferences;
     schemelink_arr : TFRE_DB_NameTypeRLArray;
     rls            : TFRE_DB_GUIDArray;
begin
  ref_array := obj.ReferencesFromData;
  SetLength(schemelink_arr,Length(ref_array));
  for i:=0 to high(ref_array) do
    begin
      try
        __CheckReferenceLink(obj,ref_array[i].fieldname,ref_array[i].linked_uid,schemelink_arr[i]);
      except
        on e:exception do
          begin
            writeln('>RECOVERY EXCEPTION : ',e.Message);
            writeln(format('> TRY REMOVING REF LINK : [%s.%s -> %s (%s)]',[obj.GetDescriptionID,ref_array[i].fieldname,FREDB_G2H(ref_array[i].linked_uid),schemelink_arr[i]]));
            obj.Field(ref_array[i].fieldname).RemoveObjectLinkByUID(ref_array[i].linked_uid);
            writeln('REMOVED -> RECURSE');
            _CheckExistingReferencelinksAndRemoveMissingFromObject(obj);
          end;
      end;
    end;
end;

function TFRE_DB_Master_Data.MyLayer: IFRE_DB_PERSISTANCE_LAYER;
begin
  result := FLayer;
end;

function TFRE_DB_Master_Data.GetPersistantRootObjectCount(const UppercaseSchemesFilter: TFRE_DB_StringArray): Integer;
var brk:integer;
    procedure Scan(const obj : TFRE_DB_Object ; var break : boolean);
    begin
      if obj.IsObjectRoot then
        begin
          if (length(UppercaseSchemesFilter)=0)
             or (FREDB_StringInArray(uppercase(obj.SchemeClass),UpperCaseSchemesFilter)) then
              inc(result);
        end;
    end;
begin
  result := 0;
  ForAllObjectsInternal(true,false,@scan);
end;

function TFRE_DB_Master_Data.InternalStoreObjectFromStable(const obj: TFRE_DB_Object): TFRE_DB_Errortype;
var
   key    : TFRE_DB_GUID;
   dummy  : PtrUInt;
   halt   : boolean=false;

   procedure Store(const obj:TFRE_DB_Object; var halt:boolean);
   begin
     dummy := FREDB_ObjectToPtrUInt(obj);
     key   := obj.UID;
     //writeln('RELOAD STORE : ',obj.UID_String,' ',obj.IsObjectRoot);
     if not FMasterPersistentObjStore.InsertBinaryKeyOrFetch(@key,sizeof(TFRE_DB_GUID),dummy) then
       result := edb_EXISTS;
     if result<>edb_OK then
       halt := true
   end;

begin
  Result := edb_OK;
  obj.ForAllObjectsBreakHierarchic(@Store,halt);
end;

function TFRE_DB_Master_Data.InternalRebuildRefindex: TFRE_DB_Errortype;

  procedure BuildRef(const obj:TFRE_DB_Object ; var break : boolean);
  var references_to_list : TFRE_DB_ObjectReferences;
      scheme_links        : TFRE_DB_NameTypeRLArray;
      setup_repair        : boolean;
  begin
    try
      setup_repair := false;
      _CheckRefIntegrityForObject(obj,references_to_list,scheme_links); // Todo Check inbound From Links (unique?)
    except
      on e:exception do
        begin
          if GDBPS_SKIP_STARTUP_CHECKS then
            begin
              setup_repair := true;
            end
          else
            raise;
        end;
    end;
    if setup_repair then
      begin
         _CheckExistingReferencelinksAndRemoveMissingFromObject(obj);
        _CheckRefIntegrityForObject(obj,references_to_list,scheme_links); // Todo Check inbound From Links (unique?)
        FLayer.WT_StoreObjectPersistent(obj);
        writeln('WROTE THROUGH PATCHED OBJECT : ');
        writeln(obj.DumpToString(2));
      end;
    if Length(references_to_list)>0 then
      _SetupInitialRefLinks(obj,references_to_list,scheme_links,nil,'BOOT');
  end;

begin
  ForAllObjectsInternal(true,false,@BuildRef);
  result := edb_OK;
end;

function TFRE_DB_Master_Data.InternalCheckRestoredBackup: TFRE_DB_Errortype;
var cnt : NativeInt;

  procedure CheckObjectInCollection(const obj:TFRE_DB_Object ; var break : boolean);
  var obrefs : TFRE_DB_ObjectReferences;
      i      : NativeInt;
  begin
    if obj.IsObjectRoot then
      begin
        obj.Set_Store_Locked(False);
        try
          if length(obj.__InternalGetCollectionList)=0 then
          begin
            inc(cnt);
            writeln('INTERNAL FAILURE ('+FLayer.GetConnectedDB+'):::DB VERIFY - OFFENDING OBJECT (not stored in an collection ?)');
            writeln(obj.DumpToString(2));
            writeln('--Looking for references');
            obrefs := GetReferencesDetailedRC(obj.UID,false);
            for i:=0 to high(obrefs) do
              begin
                writeln('Is referenced by : ',obrefs[i].schemename,'(',FREDB_G2H(obrefs[i].linked_uid),').',obrefs[i].fieldname);
              end;
          end;
        finally
          obj.Set_Store_Locked(True);
        end;
     end;
  end;

begin
  cnt := 0;
  ForAllObjectsInternal(true,false,@CheckObjectInCollection);
  if cnt>0 then
    begin
      writeln('FAILURES : ',cnt);
      exit(edb_INTERNAL);
    end;
  result := edb_OK;
end;

procedure TFRE_DB_Master_Data.InternalStoreLock;

  procedure StoreLock(const obj:TFRE_DB_Object ; var break : boolean);
  begin
    if obj.IsObjectRoot then
      obj.Set_Store_Locked(true);
  end;

begin
  ForAllObjectsInternal(true,false,@Storelock);
end;

procedure TFRE_DB_Master_Data.InternalCheckStoreLocked;

  procedure StoreLock(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
  var obj : TFRE_DB_Object;
  begin
    obj := FREDB_PtrUIntToObject(value) as TFRE_DB_Object;
    if obj.IsObjectRoot then
      obj.Assert_CheckStoreLocked;
  end;

begin
  FMasterPersistentObjStore.LinearScanKeyVals(@StoreLock);
end;

procedure TFRE_DB_Master_Data.InternalCheckSubobjectsStored;

  procedure CheckStored(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
  var obj : TFRE_DB_Object;
      fso : TFRE_DB_Object;
      oa  : TFRE_DB_ObjectArray;
       i  : NativeInt;
  begin
    obj := FREDB_PtrUIntToObject(value) as TFRE_DB_Object;
    if obj.IsObjectRoot then
      begin
        oa := obj.GetFullHierarchicObjectList(false);
        for i := 0 to high(oa) do
          begin
            if not FetchObject(oa[i].UID,fso,true) then
              begin
                raise EFRE_DB_Exception.Create(edb_INTERNAL,'internal subobject validation failed - ');
              end;
          end;
      end;
  end;

begin
  FMasterPersistentObjStore.LinearScanKeyVals(@CheckStored);
end;

procedure TFRE_DB_Master_Data.FDB_CleanUpMasterData;

  procedure CleanReflinks(var refl : NativeUint);
  begin
    if (refl<>$BEEF0BAD) and
       (refl<>$BAD0BEEF) then
         raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'tree node inconsistency/bad value');
  end;

  procedure CleanObj(var ob : NativeUint);
  var obj : TFRE_DB_Object;
  begin
    if ob=0 then
      exit;
    obj := TFRE_DB_Object(FREDB_PtrUIntToObject(ob));
    if obj.IsObjectRoot then
      begin
        obj.Set_Store_Locked(False);
        obj.Free;
      end;
  end;

  procedure CleanAllChilds(var ob : NativeUint);
  var obj : TFRE_DB_Object;
  begin
    obj := TFRE_DB_Object(FREDB_PtrUIntToObject(ob));
    if not obj.IsObjectRoot then
     ob:=0;
  end;


begin
  FMasterPersistentObjStore.LinearScan(@CleanAllChilds);
  FMasterPersistentObjStore.LinearScan(@CleanObj);
  FMasterPersistentObjStore.Clear;
  FMasterVolatileObjStore.LinearScan(@CleanAllChilds);
  FMasterVolatileObjStore.LinearScan(@CleanObj);
  FMasterVolatileObjStore.Clear;
  FMasterRefLinks.LinearScan(@CleanReflinks);
  FMasterRefLinks.Clear;
  FMasterCollectionStore.Clear;
end;

constructor TFRE_DB_Master_Data.Create(const master_name: string ; const Layer : IFRE_DB_PERSISTANCE_LAYER);
begin
  FMasterPersistentObjStore := TFRE_ART_TREE.Create;
  FMasterVolatileObjStore   := TFRE_ART_TREE.Create;
  FMasterRefLinks           := TFRE_ART_TREE.Create;
  FMasterCollectionStore    := TFRE_DB_CollectionManageTree.Create;
  FMyMastername             := master_name;
  FLayer                    := Layer;
  if (uppercase(master_name)='SYSTEM') then
    FIsSysMaster:=true;
  if FMyMastername='' then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'BAD NO NAME');
end;

destructor TFRE_DB_Master_Data.Destroy;
begin
  FDB_CleanUpMasterData;
  FMasterPersistentObjStore.Free;
  FMasterVolatileObjStore.Free;
  FMasterRefLinks.Free;
  FMasterCollectionStore.Free;
  inherited Destroy;
end;

class function TFRE_DB_Master_Data._CheckFetchRightUID(const uid: TFRE_DB_GUID; const ut: TFRE_DB_USER_RIGHT_TOKEN): boolean;
var obj : TFRE_DB_Object;
    i   : NativeInt;
begin
  if not G_SysMaster.FetchObject(uid,obj,true) then
    for i := 0 to high(G_AllNonsysMasters) do
      if G_AllNonsysMasters[i].FetchObject(uid,obj,true) then
        break;
  if not Assigned(obj) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not internal fetch object for checkright [%s]',[FREDB_G2H(uid)]);
  if not assigned(ut) then
    exit(true);
  result := ut.CheckStdRightsetInternalObj(obj,[sr_FETCH])=edb_OK;
end;

class procedure TFRE_DB_Master_Data._TransactionalLockObject(const uid: TFRE_DB_GUID);
var obj : TFRE_DB_Object;
    i   : NativeInt;
begin
  if not G_SysMaster.FetchObject(uid,obj,true) then
    for i := 0 to high(G_AllNonsysMasters) do
      if G_AllNonsysMasters[i].FetchObject(uid,obj,true) then
        break;
  if not Assigned(obj) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not internal fetch object for TransactionLockObject [%s]',[FREDB_G2H(uid)]);
  obj.Assert_CheckStoreUnLocked;
  obj.Set_Store_Locked(true);
end;

procedure TFRE_DB_Master_Data.InternalClearSchemecacheLink;

  procedure ClearSchemeLink(const obj:TFRE_DB_Object; var halt:boolean);
  begin
    obj.ClearSchemecachelink;
  end;

begin
  if self=nil then { unconnected db case }
    exit;
  ForAllObjectsInternal(true,true,@ClearSchemeLink);
end;

function TFRE_DB_Master_Data.CloneOutObject(const inobj: TFRE_DB_Object): TFRE_DB_Object;
begin
  inobj.Assert_CheckStoreLocked;
  inobj.Set_Store_Locked(false);
  try
   if Length(inobj.__InternalGetCollectionList)<1 then
     raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'logic failure, object has no assignment to internal collections');
   result := inobj.CloneToNewObject;
   if result = inobj then
     abort;
  finally
    inobj.Set_Store_Locked(true);
  end;
end;


function TFRE_DB_Master_Data.GetReferencesRC(const obj_uid: TFRE_DB_GUID; const from: boolean; const scheme_prefix_filter: TFRE_DB_NameType; const field_exact_filter: TFRE_DB_NameType; const user_context: PFRE_DB_GUID ; const concat_call : boolean): TFRE_DB_GUIDArray;
var obr     : TFRE_DB_ObjectReferences;
    obrc    : TFRE_DB_ObjectReferences;
    i,j,cnt : NativeInt;
    add     : boolean;
    spf     : TFRE_DB_NameType;
    fef     : TFRE_DB_NameType;
    sysrefs : TFRE_DB_GUIDArray;
    uti     : TFRE_DB_USER_RIGHT_TOKEN;
begin
  G_GetUserToken(user_context,uti,true);
  if from then
    obr := GetOutBoundRefLinks(obj_uid)
  else
    begin
      obr := GetInboundRefLinks(obj_uid);
      if FIsSysMaster and (not concat_call) then { there possibly exist non system reflinks to the system db, gather them too, if this is a SYSTEM ONLY call (concat=false) }
        begin
          for j := 0 to high(G_AllNonsysMasters) do
            begin
              obrc := G_AllNonsysMasters[j].GetInboundRefLinks(obj_uid);
              if Length(obrc)>0 then
                FREDB_ConcatReferenceArrays(obr,obrc);
            end;
        end;
    end;
  SetLength(result,length(obr));

  spf := uppercase(scheme_prefix_filter);
  fef := uppercase(field_exact_filter);

  cnt := 0;

  for i:=0 to high(obr) do
    if ((spf='') or  (pos(spf,obr[i].schemename)=1)) and ((fef='') or (fef=obr[i].fieldname)) then
      if _CheckFetchRightUID(obr[i].linked_uid,uti) then
        begin
          result[cnt] := obr[i].linked_uid;
          inc(cnt);
        end;

  SetLength(result,cnt);
  if not FIsSysMaster then { gather the system db references too}
    begin
      sysrefs := G_SysMaster.GetReferencesRC(obj_uid,from,scheme_prefix_filter,field_exact_filter,user_context,true);
      FREDB_ConcatGUIDArrays(result,sysrefs);
    end;
end;

function TFRE_DB_Master_Data.GetReferencesRCRecurse(const obj_uid: TFRE_DB_GUID; const from: boolean; const scheme_prefix_filter: TFRE_DB_NameType; const field_exact_filter: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): TFRE_DB_GUIDArray;
var uti    : TFRE_DB_USER_RIGHT_TOKEN;
    spf    : TFRE_DB_NameType;
    fef    : TFRE_DB_NameType;
    cnt    : NativeInt;
    concat : TFRE_DB_GUIDArray;

    function GetReferencesRCRecurseInt(const obj_uid: TFRE_DB_GUID):NativeInt;
    var i   : NativeInt;
       refs : TFRE_DB_ObjectReferences;
       cr   : boolean;
    begin
      result := 0;
      refs   := GetReferencesDetailedRC(obj_uid,from,'',field_exact_filter,user_context); { disable scheme filter }
      for i:=0 to High(refs) do
        begin
          cr := _CheckFetchRightUID(refs[i].linked_uid,uti);
          if cr then
            inc(result); { there are accessible parents }
          if pos(spf,refs[i].schemename)=1 then { end schemename is ok }
            begin
              if cr then { rights are ok }
                begin
                  if cnt=Length(concat) then
                    SetLength(concat,Length(concat)+25);
                  concat[cnt] := refs[i].linked_uid; { add link }
                  inc(cnt);
                end
            end
          else { wrong scheme }
            begin
              if (GetReferencesRCRecurseInt(refs[i].linked_uid)=0) and (spf='') then { no parents, and search til end }
                begin
                  if cnt=Length(concat) then
                    SetLength(concat,Length(concat)+25);
                  concat[cnt] := refs[i].linked_uid; { add link }
                  inc(cnt);
                end;
            end;
        end;
    end;

begin
  G_GetUserToken(user_context,uti,true);
  spf := uppercase(scheme_prefix_filter);
  fef := uppercase(field_exact_filter);
  cnt := 0;
  SetLength(concat,0);
  GetReferencesRCRecurseInt(obj_uid);
  SetLength(concat,cnt);
  result := concat;
end;

function TFRE_DB_Master_Data.GetReferencesCountRC(const obj_uid: TFRE_DB_GUID; const from: boolean; const scheme_prefix_filter: TFRE_DB_NameType; const field_exact_filter: TFRE_DB_NameType; const user_context: PFRE_DB_GUID; const concat_call: boolean): NativeInt;
var obr    : TFRE_DB_ObjectReferences;
    obrc   : TFRE_DB_ObjectReferences;
    i,j    : NativeInt;
    spf    : TFRE_DB_NameType;
    fef    : TFRE_DB_NameType;
    syscnt : NativeInt;
    uti    : TFRE_DB_USER_RIGHT_TOKEN;
begin
  G_GetUserToken(user_context,uti,true);
  if from then
    obr := GetOutBoundRefLinks(obj_uid)
  else
    begin
      obr := GetInboundRefLinks(obj_uid);
      if FIsSysMaster and (not concat_call) then { there possibly exist non system reflinks to the system db, gather them too, if this is a SYSTEM ONLY call (concat=false) }
        begin
          for j := 0 to high(G_AllNonsysMasters) do
            begin
              obrc := G_AllNonsysMasters[j].GetInboundRefLinks(obj_uid);
              if Length(obrc)>0 then
                FREDB_ConcatReferenceArrays(obr,obrc);
            end;
        end;
    end;

  spf := uppercase(scheme_prefix_filter);
  fef := uppercase(field_exact_filter);

  result := 0;
  for i:=0 to high(obr) do
    if ((spf='') or  (pos(spf,obr[i].schemename)=1)) and ((fef='') or (fef=obr[i].fieldname)) then
      if _CheckFetchRightUID(obr[i].linked_uid,uti) then
        begin
          inc(result);
        end;
  if not FIsSysMaster then { gather the system db references too}
    begin
      syscnt := G_SysMaster.GetReferencesCountRC(obj_uid,from,scheme_prefix_filter,field_exact_filter,user_context,true);
      inc(result,syscnt);
    end;
end;

function TFRE_DB_Master_Data.GetReferencesDetailedRC(const obj_uid: TFRE_DB_GUID; const from: boolean; const scheme_prefix_filter: TFRE_DB_NameType; const field_exact_filter: TFRE_DB_NameType; const user_context: PFRE_DB_GUID; const concat_call: boolean): TFRE_DB_ObjectReferences;
var obr     : TFRE_DB_ObjectReferences;
    obrc    : TFRE_DB_ObjectReferences;
    i,j,cnt : NativeInt;
    add     : boolean;
    spf     : TFRE_DB_NameType;
    fef     : TFRE_DB_NameType;
    sysobrs : TFRE_DB_ObjectReferences;
    uti     : TFRE_DB_USER_RIGHT_TOKEN;
begin
  G_GetUserToken(user_context,uti,true);
  if from then
    obr := GetOutBoundRefLinks(obj_uid)
  else
    begin
      obr := GetInboundRefLinks(obj_uid);
      if FIsSysMaster and (not concat_call) then { there possibly exist non system reflinks to the system db, gather them too, if this is a SYSTEM ONLY call (concat=false) }
        begin
          for j := 0 to high(G_AllNonsysMasters) do
            begin
              obrc := G_AllNonsysMasters[j].GetInboundRefLinks(obj_uid);
              if Length(obrc)>0 then
                FREDB_ConcatReferenceArrays(obr,obrc);
            end;
        end;
    end;
  SetLength(result,length(obr));

  spf := uppercase(scheme_prefix_filter);
  fef := uppercase(field_exact_filter);

  cnt := 0;
  for i:=0 to high(obr) do
    if ((spf='') or  (pos(spf,obr[i].schemename)=1)) and ((fef='') or (fef=obr[i].fieldname)) then
      if _CheckFetchRightUID(obr[i].linked_uid,uti) then
        begin
          result[cnt] := obr[i];
          inc(cnt);
        end;

  SetLength(result,cnt);
  if not FIsSysMaster then { gather the system db references too}
    begin
      sysobrs := G_SysMaster.GetReferencesDetailedRC(obj_uid,from,scheme_prefix_filter,field_exact_filter,user_context,true);
      FREDB_ConcatReferenceArrays(result,sysobrs);
    end;
end;

procedure TFRE_DB_Master_Data.ExpandReferencesRC(const user_context: PFRE_DB_GUID; const ObjectList: TFRE_DB_GUIDArray; const ref_constraints: TFRE_DB_NameTypeRLArray; out expanded_refs: TFRE_DB_GUIDArray);
var i        : NativeInt;
    count    : NativeInt;

  procedure FetchChained(uid:TFRE_DB_GUID ; field_chain : TFRE_DB_NameTypeRLArray ; depth : NativeInt);
  var obrefs   : TFRE_DB_GUIDArray;
      i        : NativeInt;
      scheme   : TFRE_DB_NameType;
      field    : TFRE_DB_NameType;
      outbound : Boolean;
      recurse  : boolean;
  begin
    if depth<length(field_chain) then
      begin
        outbound := FREDB_SplitRefLinkDescriptionEx(field_chain[depth],field,scheme,recurse);
        if not recurse then
          obrefs   := GetReferencesRC(uid,outbound,scheme,field,user_context,false)
        else
          obrefs   := GetReferencesRCRecurse(uid,outbound,scheme,field,user_context);

        for i := 0 to  high(obrefs) do
          begin
            FetchChained(obrefs[i],field_chain,depth+1);
          end;
      end
    else
      begin
        if Length(expanded_refs) = count then
          SetLength(expanded_refs,Length(expanded_refs)+256);
        if FREDB_GuidInArray(uid,expanded_refs)=-1 then
          begin
            expanded_refs[count] := uid;
            inc(count);
          end;
      end;
  end;
begin
  SetLength(expanded_refs,0);
  count := 0;
  for i := 0 to High(ObjectList) do
    FetchChained(ObjectList[i],ref_constraints,0);
  SetLength(expanded_refs,count);
end;

function TFRE_DB_Master_Data.ExpandReferencesCountRC(const user_context: PFRE_DB_GUID; const ObjectList: TFRE_DB_GUIDArray; const ref_constraints: TFRE_DB_NameTypeRLArray): NativeInt;
var expanded_refs: TFRE_DB_GUIDArray;
begin
  ExpandReferencesRC(user_context,ObjectList,ref_constraints,expanded_refs);
  result := Length(expanded_refs);
end;

procedure TFRE_DB_Master_Data.FetchExpandReferencesRC(const user_context: PFRE_DB_GUID; const ObjectList: TFRE_DB_GUIDArray; const ref_constraints: TFRE_DB_NameTypeRLArray; out expanded_refs: IFRE_DB_ObjectArray);
var expanded_ref: TFRE_DB_GUIDArray;
begin
  ExpandReferencesRC(user_context,ObjectList,ref_constraints,expanded_ref);
  BulkFetchRC(nil,expanded_ref,expanded_refs);
end;

function TFRE_DB_Master_Data.BulkFetchRC(const user_context: PFRE_DB_GUID; const obj_uids: TFRE_DB_GUIDArray; out objects: IFRE_DB_ObjectArray): TFRE_DB_Errortype;
var dboa  : TFRE_DB_ObjectArray;
    i     : NativeInt;
    all   : Boolean;
begin
  SetLength(dboa,length(obj_uids));
  all := true;
  for i := 0 to high(dboa) do
     if not FetchObjectRC(user_context,obj_uids[i],dboa[i],true) then
       begin
         all := false;
         break;
       end;
  if all then
    begin
      SetLength(objects,Length(dboa));
      for i := 0 to high(objects) do
        objects[i] := CloneOutObject(dboa[i]);
      exit(edb_OK);
    end;
  result := edb_NOT_FOUND;
end;

function TFRE_DB_Master_Data.FetchObjectRC(const user_context: PFRE_DB_GUID; const obj_uid: TFRE_DB_GUID; out obj: TFRE_DB_Object; const internal_obj: boolean): boolean;
var
    uti     : TFRE_DB_USER_RIGHT_TOKEN;
begin
  G_GetUserToken(user_context,uti,true);
  result := FetchObject(obj_uid,obj,true);
  if result then
    begin
      if not assigned(user_context) then
        exit(true);
      result := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH])=edb_OK;
      if result=false then
        begin
          obj := nil;
        end
      else
        begin
          if internal_obj=false then { only cloneout if needed }
            obj := CloneOutObject(obj);
        end;
    end;
end;

function TFRE_DB_Master_Data.ExistsObject(const obj_uid: TFRE_DB_GUID): Boolean;
var dummy : NativeUint;
begin
  if FMasterVolatileObjStore.ExistsBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummy) then
    exit(true);
  if FMasterPersistentObjStore.ExistsBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummy) then
    exit(true);
  exit(false);
end;

function TFRE_DB_Master_Data.FetchObject(const obj_uid: TFRE_DB_GUID; out obj: TFRE_DB_Object; const internal_obj: boolean): boolean;
var dummy : NativeUint;
    clobj : TFRE_DB_Object;
begin
  obj := nil;
  result := FMasterVolatileObjStore.ExistsBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummy);
  if result then
    begin
      obj := FREDB_PtrUIntToObject(dummy) as TFRE_DB_Object;
    end
  else
    begin
     result := FMasterPersistentObjStore.ExistsBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummy);
     if result then
       obj := FREDB_PtrUIntToObject(dummy) as TFRE_DB_Object;
    end;
  if result and FIsSysMaster then
    obj.Set_SystemDB; { set internal flag that this object comes from the sys layer ( update/wt) }
  if result and
     not internal_obj then
       begin
         if not obj.IsObjectRoot then
           raise EFRE_DB_PL_Exception.Create(edb_ERROR,'the object [%s] is a subobject,a "root" of the fetch of the subobject is not allowed',[FREDB_G2H(obj_uid)]);
         obj.Assert_CheckStoreLocked;
         obj.Set_Store_Locked(false);
         try
           clobj := obj.CloneToNewObject;
         finally
           obj.Set_Store_Locked(true);
         end;
         obj := clobj;
       end;
   if not result then { not found here, search in system master data, but not the other way round }
     if not FIsSysMaster then
       result := G_SysMaster.FetchObject(obj_uid,obj,internal_obj);
end;

procedure TFRE_DB_Master_Data.StoreObjectSingle(const obj: TFRE_DB_Object; const check_only: boolean; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var references_to_list : TFRE_DB_ObjectReferences;
    key                : TFRE_DB_GUID;
    dummy              : PtrUInt;
    scheme_links       : TFRE_DB_NameTypeRLArray;
begin
  key := obj.UID;
  _CheckRefIntegrityForObject(obj,references_to_list,scheme_links); // Todo Check inbound From Links (unique?)
  if (obj.IsVolatile
     or obj.IsSystem
     or (not obj.IsObjectRoot))
     and (Length(references_to_list)>0) then
       raise EFRE_DB_PL_Exception.Create(edb_INVALID_PARAMS,'a volatile,system or child object is not allowed to reference other objects');
  if obj.ObjectRoot.IsVolatile then {!! essential}
    begin
      if check_only then
        begin
          if FMasterVolatileObjStore.ExistsBinaryKey(@key,SizeOf(TFRE_DB_GUID),dummy) then
            begin
              if obj.IsObjectRoot then
                begin
                  raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'cannot store volatile rootobject, an object [%s] is already stored as root or subobject',[obj.UID_String]);
                end
              else
                begin
                  raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'cannot store volatile subobject, an object [%s] is already stored as root or subobject',[obj.UID_String]);
                end;
            end;
        end
      else
        begin
          if not FMasterVolatileObjStore.InsertBinaryKey(@key,SizeOf(TFRE_DB_GUID),FREDB_ObjectToPtrUInt(obj)) then
            raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'cannot store volatile object')
        end;
    end
  else
    begin { Not Volatile }
      dummy := FREDB_ObjectToPtrUInt(obj);
      if check_only then
        begin
          if FMasterPersistentObjStore.ExistsBinaryKey(@key,SizeOf(TFRE_DB_GUID),dummy) then
            begin
              if obj.IsObjectRoot then
                begin
                  raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'cannot store persistent rootobject, an object [%s] is already stored as root or subobject',[obj.UID_String]);
                end
              else
                begin
                  raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'cannot store persistent subobject, an object [%s] is already stored as root or subobject',[obj.UID_String]);
                end;
            end;
        end
      else
        begin { non check - do it }
          if tsid='' then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'transation id not set on store OBJ(%s)',[obj.UID_String]);
          obj.Field(cFRE_DB_SYS_T_LMO_TRANSID).AsString:=tsid;
          if not FMasterPersistentObjStore.InsertBinaryKeyOrFetch(@key,sizeof(TFRE_DB_GUID),dummy) then
            raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'cannot store persistent object [%s]',[obj.InternalUniqueDebugKey]);
          if Length(references_to_list)>0 then
            _SetupInitialRefLinks(obj,references_to_list,scheme_links,notifif,tsid);
        end;
    end;
end;

procedure TFRE_DB_Master_Data.StoreObjectWithSubjs(const obj: TFRE_DB_Object; const check_only: boolean; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var lInsertList : TFRE_DB_ObjectArray;
    i           : NativeInt;
begin
  lInsertList := obj.GetFullHierarchicObjectList(true);
  for i:=0 to high(lInsertList) do
    StoreObjectSingle(lInsertList[i],check_only,notifif,tsid);
end;

procedure TFRE_DB_Master_Data.DeleteObjectSingle(const obj_uid: TFRE_DB_GUID; const check_only: boolean; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId);
var dummyv  : PtrUInt;
    dummyp  : PtrUInt;
    obj     : TFRE_DB_Object;
    ex_vol  : boolean;
    ex_pers : boolean;
    isroot  : boolean;
    cn      : shortstring;
begin
  if check_only then
    begin
      if GetReferencesCountRC(obj_uid,false) > 0 then
        raise EFRE_DB_PL_Exception.Create(edb_OBJECT_REFERENCED,'DELETE OF OBJECT [%s] FAILED, OBJECT IS REFERENCED',[FREDB_G2H(obj_uid)]);
      exit;
    end;

  ex_vol  := FMasterVolatileObjStore.ExistsBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummyv);
  ex_pers := FMasterPersistentObjStore.ExistsBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummyp);
  if (ex_vol=false) and
     (ex_pers=false) then
       raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'DELETE OF OBJECT [%s] FAILED, OBJECT NOT FOUND',[FREDB_G2H(obj_uid)]);
  if ex_vol then
    begin
      obj := FREDB_PtrUIntToObject(dummyv) as TFRE_DB_Object;
      if not FMasterVolatileObjStore.RemoveBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummyv) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'cannot remove existing');
      if obj.IsObjectRoot then
        obj.Free
      else
        obj:=obj;
    end;
  if ex_pers then
    begin
      try
        obj := FREDB_PtrUIntToObject(dummyp) as TFRE_DB_Object;
      except
        cn := TObject(dummyp).ClassName;
      end;
      _RemoveAllRefLinks(obj,notifif,tsid);
      if not FMasterPersistentObjStore.RemoveBinaryKey(@obj_uid,SizeOf(TFRE_DB_GUID),dummyp) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'cannot remove existing');
      if obj.IsObjectRoot then
        obj.Free
      else
        obj:=obj;
    end;
end;

procedure TFRE_DB_Master_Data.DeleteObjectWithSubobjs(const del_obj: TFRE_DB_Object; const check_only: boolean; const notifif: IFRE_DB_DBChangedNotification; const tsid: TFRE_DB_TransStepId; const must_be_child: boolean);
var lDelList : TFRE_DB_ObjectArray;
    k,h      : NativeInt;
begin
  lDelList := del_obj.GetFullHierarchicObjectList(true); { the list is build recursive top down, only free the root object, but remove the childs too !}
  if must_be_child and lDelList[0].IsObjectRoot then
    raise EFRE_DB_Exception.Create(edb_INTERNAL,'unexpected root object in DeleteObjectWithSubobjs');
  h := high(lDelList);
  for k := h downto 0 do
    DeleteObjectSingle(lDelList[k].UID,check_only,notifif,tsid);
end;

procedure TFRE_DB_Master_Data.ForAllObjectsInternal(const pers, volatile: boolean; const iter: TFRE_DB_ObjectIteratorBrk);
var break : boolean;

  procedure ObjCallBack(var val:NativeUint;var break : boolean);
  begin
    iter(FREDB_PtrUIntToObject(val) as TFRE_DB_Object,break);
  end;

begin
  break := false; //self
  if pers then
    FMasterPersistentObjStore.LinearScanBreak(@ObjCallback,break);
  if volatile then
    FMasterVolatileObjStore.LinearScanBreak(@ObjCallback,break);
end;

function TFRE_DB_Master_Data.MasterColls: TFRE_DB_CollectionManageTree;
begin
  result := FMasterCollectionStore;
end;

{ TFRE_DB_TextIndex }

procedure TFRE_DB_TextIndex.SetBinaryComparableKey(const keyvalue: TFRE_DB_String; const key_target: PByte; var key_len: NativeInt; const is_null: boolean);
begin
  SetBinaryComparableKey(keyvalue,key_target,key_len,is_null,FCaseInsensitive);
end;

class procedure TFRE_DB_TextIndex.SetBinaryComparableKey(const keyvalue: TFRE_DB_String; const key_target: PByte; var key_len: NativeInt; const is_null: boolean ;  const case_insensitive: boolean; const invert_key: boolean);
var str           : TFRE_DB_String;
    regular_value : boolean;
    i             : NativeInt;
begin
  regular_value := true;
  if case_insensitive then
    str := UpperCase(keyvalue)
  else
    str := keyvalue;
  str := #1+str;
  if is_null then
    begin
      regular_value:=false;
      if not invert_key then
        str := #0#0
      else
        str := #2#1; // inverted null=max value
    end
  else
    begin
      if str=#1 then // "" (empty) String
        begin
          regular_value := false;
          if not invert_key then
            str := #0#1
          else
            str := #2#0; // 1 before inverted null value
        end;
    end;
  key_len := Length(str);
  if invert_key and regular_value then
    begin
      for i:= 2 to Length(str) do
        byte(str[i]) := not byte(str[i]);
    end;
  Move(str[1],key_target^,key_len);
end;

procedure TFRE_DB_TextIndex.StreamHeader(const stream: TStream);
begin
  inherited StreamHeader(stream);
  if FCaseInsensitive then
    stream.WriteByte(1)
  else
    stream.WriteByte(0);
end;

function TFRE_DB_TextIndex.GetIndexDefinitionObject: IFRE_DB_Object;
begin
  Result:=inherited GetIndexDefinitionObject;
  result.Field('IXT_CSENS').AsBoolean := FCaseInsensitive;
end;

function TFRE_DB_TextIndex.GetIndexDefinition: TFRE_DB_INDEX_DEF;
begin
  Result:=inherited GetIndexDefinition;
  result.IgnoreCase := FCaseInsensitive;
end;

class procedure TFRE_DB_TextIndex.InitializeNullKey;
begin
  SetBinaryComparableKey('',@nullkey,nullkeylen,true,true);
end;


constructor TFRE_DB_TextIndex.Create(const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique, case_insensitive: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION_BASE; const allow_null: boolean; const unique_null: boolean; const domain_idx: boolean);
begin
  inherited Create(idx_name,fieldname,fieldtype,unique,collection,allow_null,unique_null,domain_idx);
  FCaseInsensitive := case_insensitive;
end;

constructor TFRE_DB_TextIndex.CreateStreamed(const stream: TStream; const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION; const allow_null: boolean; const unique_null: boolean; const domain_idx: boolean);
var ci : Boolean;
begin
  ci := stream.ReadByte=1;
  Create(idx_name,fieldname,fieldtype,unique,ci,collection,allow_null,unique_null,domain_idx);
  LoadIndex(stream,collection);
end;


procedure TFRE_DB_TextIndex.FieldTypeIndexCompatCheck(fld: TFRE_DB_FIELD);
begin
  if fld.FieldType<>fdbft_String then
    raise EFRE_DB_PL_Exception.Create(edb_ILLEGALCONVERSION,'the text index can only be used to index a string field, not a [%s] field. Maybe use a calculated field with results a string field',[fld.FieldTypeAsString])
end;

function TFRE_DB_TextIndex.NullvalueExists(var vals: TFRE_DB_IndexValueStore): boolean;
var dummy  : NativeUint;
begin
  result := FIndex.ExistsBinaryKey(@nullkey,nullkeylen,dummy);
  if result then
    vals := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore
  else
    vals := nil;
end;

procedure TFRE_DB_TextIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint);
begin
  TransformToBinaryComparable(fld,key,keylen,FCaseInsensitive);
end;

class procedure TFRE_DB_TextIndex.TransformToBinaryComparable(fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint; const is_casesensitive: boolean; const invert_key: boolean);
var is_null_value : Boolean;
begin
  is_null_value := not assigned(fld);
  if not is_null_value then
    SetBinaryComparableKey(fld.AsString,key,keylen,is_null_value,is_casesensitive,invert_key)
  else
    SetBinaryComparableKey('',key,keylen,is_null_value,is_casesensitive,invert_key);
end;

function TFRE_DB_TextIndex.SupportsDataType(const typ: TFRE_DB_FIELDTYPE): boolean;
begin
  if typ=fdbft_String then
    exit(true)
  else
    exit(false)
end;

function TFRE_DB_TextIndex.SupportsSignedQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_TextIndex.SupportsUnsignedQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_TextIndex.SupportsStringQuery: boolean;
begin
  result := true;
end;

function TFRE_DB_TextIndex.SupportsRealQuery: boolean;
begin
  result := false;
end;

function TFRE_DB_TextIndex.ForAllIndexedTextRange(const min, max: TFRE_DB_String; var guids: TFRE_DB_GUIDArray; const ascending: boolean; const min_is_null: boolean; const max_is_max: boolean; const max_count: NativeInt; skipfirst: NativeInt; const only_count_unique_vals: boolean): boolean;
var lokey,hikey       : Array [0..8] of Byte;
    lokeylen,hikeylen : NativeInt;
    lokeyp,hikeyp     : PByte;

   procedure IteratorBreak(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var down_counter,up_counter : nativeint ; const abscntr : NativeInt);
   begin
     (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
   end;

begin
  if not min_is_null then
    begin
      SetBinaryComparableKey(min,@lokey,lokeylen,min_is_null);
      lokeyp := lokey;
    end
  else
    lokeyp := nil;
  if not max_is_max then
    begin
      SetBinaryComparableKey(max,@hikey,hikeylen,max_is_max);
      hikeyp := hikey;
    end
  else
    hikeyp := nil;
  result := FIndex.RangeScan(lokeyp,hikeyp,lokeylen,hikeylen,@IteratorBreak,max_count,skipfirst,ascending)
end;

function TFRE_DB_TextIndex.ForAllIndexPrefixString(const prefix: TFRE_DB_String; var guids: TFRE_DB_GUIDArray; const index_name: TFRE_DB_NameType; const ascending: boolean; const max_count: NativeInt; skipfirst: NativeInt): boolean;
var
    transkey : Array [0..CFREA_maxKeyLen] of Byte;
    keylen   : NativeInt;

   procedure IteratorBreak(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean);
   var up_counter,down_counter,abscntr : NAtiveint;
   begin
     up_counter := 0 ; down_counter := 0 ;abscntr := 0;
     (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
   end;

begin
  if (max_count<>0) or
     (skipfirst<>0) then
       E_FOS_Implement;
  SetBinaryComparableKey(prefix,@transkey,keylen,false);
  result := FIndex.PrefixScan(@transkey,keylen,@IteratorBreak);
end;


{ TFRE_DB_MM_Index }

constructor TFRE_DB_MM_Index.Create(const idx_name, fieldname: TFRE_DB_NameType; const fieldtype: TFRE_DB_FIELDTYPE; const unique: boolean; const collection: TFRE_DB_PERSISTANCE_COLLECTION_BASE; const allow_null: boolean; const unique_null: boolean; const domain_idx: boolean);
begin
  FIndex           := TFRE_ART_TREE.Create;
  FIndexName       := idx_name;
  FUniqueName      := UpperCase(FIndexName);
  FUnique          := unique;
  FFieldname       := fieldname;
  FUniqueFieldname := uppercase(fieldname);
  FFieldType       := fieldtype;
  FUnique          := unique;
  FCollection      := collection;
  FAllowNull       := allow_null;
  FUniqueNullVals  := unique_null;
  FIsADomainIndex  := domain_idx;
  //GetKeyLenForFieldtype(fieldtype,FFixedKeylen);
  InitializeNullKey;
end;

destructor TFRE_DB_MM_Index.Destroy;
begin
  FullClearIndex;
  FIndex.Free;
end;

function TFRE_DB_MM_Index.Indexname: TFRE_DB_NameType;
begin
  result := FIndexName;
end;

function TFRE_DB_MM_Index.Uniquename: PFRE_DB_NameType;
begin
  result := @FUniqueName;
end;

function TFRE_DB_MM_Index.NullvalueExistsForObject(const obj: TFRE_DB_Object): boolean;
var values : TFRE_DB_IndexValueStore;
begin
  if NullvalueExists(values) then
    result := values.Exists(obj.UID)
  else
    result :=false;
end;

procedure TFRE_DB_MM_Index.IndexAddCheck(const obj: TFRE_DB_Object; const check_only: boolean);
var
    fld       : TFRE_DB_FIELD;
    isNullVal : boolean;
    key       : Array [0..CFREA_maxKeyLen] of Byte;
    keylen    : NativeInt;

begin
  isNullVal := not obj.FieldOnlyExisting(FFieldname,fld);

  if isNullVal
    and (not FAllowNull) then
      raise EFRE_DB_PL_Exception.Create(edb_UNSUPPORTED,'for the index [%s] the usage of null values (=unset fields) is not allowed',[_GetIndexStringSpec]);

  if not isNullVal then
    FieldTypeIndexCompatCheck(fld);

  if FIsADomainIndex then
    TransformToBinaryComparableDomain(obj.Field('DomainID'),fld,@key,keylen)
  else
    TransformtoBinaryComparable(fld,@key,keylen);

  if check_only then
    _InternalCheckAdd(@key,keylen,isNullVal,false,obj.uid)
  else
    _InternalAddGuidToValstore(@key,keylen,isNullVal,obj.UID);
end;

procedure TFRE_DB_MM_Index.IndexUpdCheck(const new_obj, old_obj: TFRE_DB_Object; const check_only: boolean);
var
    oldfld,newfld  : TFRE_DB_FIELD;
    obj_uid        : TFRE_DB_GUID;
    dummy          : NativeUint;
    values         : TFRE_DB_IndexValueStore;
    isNullValue    : boolean;
    OldIsNullValue : boolean;
    key            : Array [0..CFREA_maxKeyLen] of Byte;
    keylen         : NativeInt;
    ukey           : Array [0..CFREA_maxKeyLen] of Byte;
    ukeylen        : NativeInt;

begin
  assert(assigned(new_obj));
  assert(assigned(old_obj));
  assert(new_obj.UID=old_obj.UID);
  obj_uid := new_obj.UID;
  OldIsNullValue := not old_obj.FieldOnlyExisting(FFieldname,oldfld);

  if FIsADomainIndex then
    TransformToBinaryComparableDomain(old_obj.Field('DomainID'),oldfld,key,keylen)
  else
    TransformtoBinaryComparable(oldfld,key,keylen);

  isNullValue    := not new_obj.FieldOnlyExisting(FFieldname,newfld);

  if not isNullValue then
    FieldTypeIndexCompatCheck(newfld);

  if FIsADomainIndex then
    TransformToBinaryComparableDomain(new_obj.Field('DomainID'),newfld,ukey,ukeylen)
  else
    TransformtoBinaryComparable(newfld,ukey,ukeylen);

  if CompareTransformedKeys(key,ukey,keylen,ukeylen) then { This should not happen, as the change compare has to happen earlier }
    begin
      // The change would not update the index / the key value is the same, which is only possible on Case insensitive indexes where the fieldvalue changed, but not the indexed value
      if (self is TFRE_DB_TextIndex)
         and ((self as TFRE_DB_TextIndex).FCaseInsensitive=true) then
           exit;
      raise EFRE_DB_PL_Exception.Create(edb_ERROR,'cant update the index for object [%s] / for the unique index [%s] the values would be the same ([%s]->[%s])',[new_obj.UID_String,_GetIndexStringSpec,FFieldname,GetStringRepresentationOfTransientKey(OldIsNullValue,key,keylen),GetStringRepresentationOfTransientKey(isNullValue,ukey,ukeylen)]);
    end;
  //writeln('INDEX CHANGE ',_GetIndexStringSpec,' REMOVE VAL ',oldfld.AsString,' ',new_obj.UID_String);
  //writeln('INDEX CHANGE ',_GetIndexStringSpec,' ADD VAL '   ,newfld.AsString,' ',new_obj.UID_String);
  if check_only then
    begin
      _InternalCheckAdd(@ukey,ukeylen,isNullValue,true,obj_uid)
    end
  else
    begin
      // Update - (1) Remove old object index value from index
      //          (2) Add new object/field value to index
      _InternalRemoveGuidFromValstore(@key,keylen,isNullValue,obj_uid);
      _InternalAddGuidToValstore(@ukey,ukeylen,isNullValue,obj_uid);
    end;
end;

procedure TFRE_DB_MM_Index.IndexDelCheck(const obj, new_obj: TFRE_DB_Object; const check_only: boolean);
var oldfld         : TFRE_DB_FIELD;
    obj_uid        : TFRE_DB_GUID;
    OldIsNullValue : boolean;
    key            : Array [0..CFREA_maxKeyLen] of Byte;
    keylen         : NativeInt;

begin
  obj_uid        := obj.UID;
  OldIsNullValue := not obj.FieldOnlyExisting(FFieldname,oldfld);

  if FIsADomainIndex then
    TransformToBinaryComparableDomain(obj.Field('DomainID'),oldfld,@key,keylen)
  else
    TransformtoBinaryComparable(oldfld,@key,keylen);
  if check_only then
    _InternalCheckDel(@key,keylen,OldIsNullValue,obj_uid)
  else
    _InternalRemoveGuidFromValstore(@key,keylen,OldIsNullValue,obj_uid); // Remove old object index value from index
  if FAllowNull
    and assigned(new_obj) then  // if the new_obj is not assigned this is a full delete, not a field delete(!)
      IndexAddCheck(new_obj,check_only); // Need to Transform Null Value
end;

function TFRE_DB_MM_Index.SupportsIndexType(const ix_type: TFRE_DB_INDEX_TYPE): boolean;
begin
  case ix_type of
    fdbit_Unsupported: raise EFRE_DB_PL_Exception.Create(edb_MISMATCH,'an unsupported index type is unsupported by definition, so dont query for support');
    fdbit_Unsigned: result := SupportsUnsignedQuery;
    fdbit_Signed:   result := SupportsSignedQuery;
    fdbit_Real:     result := SupportsRealQuery;
    fdbit_Text:     result := SupportsStringQuery;
  end;
end;

function TFRE_DB_MM_Index.IsUnique: Boolean;
begin
  result := FUnique;
end;

function TFRE_DB_MM_Index.IsDomainIndex: boolean;
begin
  result := FIsADomainIndex;
end;


procedure TFRE_DB_MM_Index.AppendAllIndexedUids(var guids: TFRE_DB_GUIDArray; const ascending: boolean; const max_count: NativeInt; skipfirst: NativeInt);
var halt : boolean;
    down_counter,up_counter,abscntr : NativeInt;

  procedure NodeProc(var value : NativeUint ; var break:boolean);
  begin
    (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
    if (max_count>0) and
       (up_counter>=max_count) then
         break:=true;
  end;

begin
  down_counter := skipfirst;
  up_counter   := 0;
  abscntr      := max_count;
  if ascending then
    FIndex.LinearScanBreak(@NodeProc,halt)
  else
    FIndex.LinearScanBreak(@NodeProc,halt,true);
end;

procedure TFRE_DB_MM_Index.AppendAllIndexedUidsDomain(var guids: TFRE_DB_GUIDArray; const ascending: boolean; const max_count: NativeInt; skipfirst: NativeInt; const domid_field: TFRE_DB_FIELD);
var halt : boolean;
    down_counter,up_counter,abscntr : NativeInt;
    keylen   : NativeInt;
    transkey : Array [0..CFREA_maxKeyLen] of Byte;

  procedure NodeProc(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean);
  begin
    (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(guids,ascending,down_counter,up_counter,abscntr);
    if (max_count>0) and
       (up_counter>=max_count) then
         break:=true;
  end;

begin
  down_counter := skipfirst;
  up_counter   := 0;
  abscntr      := max_count;

  TFRE_DB_UnsignedIndex.TransformtoBinaryComparable(domid_field,@transkey[0],keylen,false,false); { domainid as prefix }
  if ascending then
    FIndex.PrefixScan(transkey,keylen,@NodeProc)
  else
    FIndex.PrefixScanReverse(transkey,keylen,@NodeProc);
end;

function TFRE_DB_MM_Index.IndexTypeTxt: String;
begin
  result := CFRE_DB_INDEX_TYPE[FREDB_GetIndexTypeForFieldType(FFieldType)];
end;

function TFRE_DB_MM_Index.IndexedCount(const unique_values: boolean): NativeInt;

   procedure CountValuesIndex(var dummy : NativeUint);
   begin
     result := result + TFRE_DB_IndexValueStore(FREDB_PtrUIntToObject(dummy)).ObjectCount;
   end;

begin
  if unique_values then
    result := FIndex.GetValueCount
  else
    begin
      if (FUniqueNullVals=false)
         or (FUnique=false) then
           begin
             result := 0;
             FIndex.LinearScan(@CountValuesIndex); //TODO: Replace with Bookkeeping variant
           end
      else
        result := FIndex.GetValueCount;
    end;
end;

function TFRE_DB_MM_Index.IndexIsFullyUnique: Boolean;
begin
  result := _IndexIsFullUniqe;
end;

procedure TFRE_DB_MM_Index.FullClearIndex;

  procedure ClearIndex(var dummy : NativeUint);
  begin
    TFRE_DB_IndexValueStore(FREDB_PtrUIntToObject(dummy)).free;
  end;

begin
  FIndex.LinearScan(@ClearIndex);
end;

procedure TFRE_DB_MM_Index.FullReindex;

  procedure Add(const obj : TFRE_DB_Object);
  begin
    obj.Set_Store_Locked(false);
    try
      IndexAddCheck(obj,false);
    finally
      obj.Set_Store_Locked(true);
    end;
  end;

begin
  FullClearIndex;
  (FCollection as TFRE_DB_Persistance_Collection).ForAllInternal(@Add);
end;

procedure TFRE_DB_MM_Index._InternalCheckAdd(const key: PByte; const keylen: Nativeint; const isNullVal, isUpdate: Boolean; const obj_uid: TFRE_DB_GUID);
var dummy  : NativeUint;
    values : TFRE_DB_IndexValueStore;
begin
  if isNullVal and
     not FAllowNull then
       raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'trying to add a null value for the index [%s/%s/%s], which is not allowing null values value=[ %s]',[FCollection.CollectionName(false),FIndexName,FFieldname,GetStringRepresentationOfTransientKey(isNullVal,key,keylen)]);
  if FIndex.ExistsBinaryKey(key,keylen,dummy) then // if not existing then
    begin
      values := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore;
      if isNullVal then
        begin
          if FUniqueNullVals then
            raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'for the null-unique index [%s] the null key value already exists [ %s]',[_GetIndexStringSpec,GetStringRepresentationOfTransientKey(isNullVal,key,keylen)])
          else
            begin
              if values.Exists(obj_uid) then
                raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'for the non null-unique index [%s] the value(=obj) already exists',[_GetIndexStringSpec])
            end;
        end
      else
        begin
          if FUnique then
            raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'for the unique index [%s] the key already exists [ %s]',[_GetIndexStringSpec,GetStringRepresentationOfTransientKey(isNullVal,key,keylen)])
          else
            begin
              if values.Exists(obj_uid) then
                raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'for the non unique index [%s] the value [ %s] already exists',[_GetIndexStringSpec,GetStringRepresentationOfTransientKey(isNullVal,key,keylen)])
            end;
        end
    end
end;

procedure TFRE_DB_MM_Index._InternalCheckDel(const key: PByte; const keylen: Nativeint; const isNullVal: Boolean; const obj_uid: TFRE_DB_GUID);
var dummy        : NativeUint;
    values       : TFRE_DB_IndexValueStore;
    nullvalExist : Boolean;
begin
  if not FAllowNull
     and isNullVal then
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'delete check failed idx [%s] does not allow null values.',[_GetIndexStringSpec]);

  nullvalExist := NullvalueExists(values);
  if FUniqueNullVals
     and isNullVal
     and nullvalExist then
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'delete check failed idx [%s] does allow only one unique null value, and a null value already exist',[_GetIndexStringSpec]);

  if FIndex.ExistsBinaryKey(key,keylen,dummy) then // if not existing then
    begin
      values := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore;
      if not values.Exists(obj_uid) then
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'delete check failed idx [%s] value does not exist [ %s]',[_GetIndexStringSpec,GetStringRepresentationOfTransientKey(isNullVal,key,keylen)])
    end
  else
    raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'for the unique index [%s] the key to delete does not exists [ %s]',[_GetIndexStringSpec,GetStringRepresentationOfTransientKey(isNullVal,key,keylen)])
end;

procedure TFRE_DB_MM_Index._InternalAddGuidToValstore(const key: PByte; const keylen: Nativeint ; const isNullVal : boolean ; const uid: TFRE_DB_GUID);
var
    dummy : NativeUint;
   values : TFRE_DB_IndexValueStore;
begin
  values   := TFRE_DB_IndexValueStore.Create;
  dummy    := FREDB_ObjectToPtrUInt(values);
  if FIndex.InsertBinaryKeyOrFetch(key,keylen,dummy) then
   begin //new
      if not FIndex.ExistsBinaryKey(key,keylen,dummy) then
        begin
          FIndex.InsertBinaryKey(key,keylen,dummy); // debug line
          GFRE_BT.CriticalAbort('inserted key but not finding it, failure in tree structure!');
        end;
      if not values.Add(uid) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'unexpected internal index unique/empty/add failure');
    end
  else
    begin // exists
      values.free;
      values := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore;
      if isNullVal then
        begin
          if FUniqueNullVals then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'unexpected internal null-unique index add/exists failure')
          else
            if not values.Add(UID) then
              raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'unexpected internal index non null-unique add failure');
        end
      else
        begin
          if FUnique then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'unexpected internal unique index add/exists failure')
          else
            if not values.Add(UID) then
              raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'unexpected internal index non unique add failure');
        end;
    end;
end;

procedure TFRE_DB_MM_Index._InternalRemoveGuidFromValstore(const key: PByte; const keylen: Nativeint; const isNullVal: boolean; const uid: TFRE_DB_GUID);
var
    dummy : NativeUint;
   values : TFRE_DB_IndexValueStore;
begin
  if not FIndex.ExistsBinaryKey(key,keylen,dummy) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'index/field [%s] update, cannot find old value?',[_GetIndexStringSpec]);
  values := FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore;
  if not values.RemoveUID(uid) then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'index/field [%s] update, cannot find old obj uid [%s] value in indexvaluestore?',[_GetIndexStringSpec,FREDB_G2H(uid)]);
  if values.ObjectCount=0 then
    begin
      if not FIndex.RemoveBinaryKey(key,keylen,dummy) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'index/field [%s] update, cannot remove the index node entry for old obj uid [%s] in indextree?',[_GetIndexStringSpec,FREDB_G2H(uid)]);
      values.free;
    end;
end;

function TFRE_DB_MM_Index.GetStringRepresentationOfTransientKey(const isnullvalue: boolean; const key: PByte; const keylen: Nativeint): String;
begin
  if isnullvalue then
    exit('(NULL)')
  else
    result := GFRE_BT.Dump_Binary(@key[0],keylen,true,false)
end;

function TFRE_DB_MM_Index.FetchIndexedValsTransformedKey(var obj: TFRE_DB_GUIDArray; const key: PByte; const keylen: Nativeint): boolean;
var dummy : NativeUint;
    down_counter,up_counter,abscntr : NativeInt;
begin
  SetLength(obj,0);
  down_counter:=0; up_counter:=0; abscntr:=0;
  result := FIndex.ExistsBinaryKey(key,keylen,dummy);
  if result then
    (FREDB_PtrUIntToObject(dummy) as TFRE_DB_IndexValueStore).AppendObjectUIDS(obj,true,down_counter,up_counter,abscntr)
end;

procedure TFRE_DB_MM_Index.ForAllIndexedValsTransformedKeys(var uids: TFRE_DB_GUIDArray; const mikey, makey: PByte; const milen, malen: NativeInt; const ascending: boolean; const max_count: NativeInt; skipfirst: NativeInt);

   procedure IteratorBreak(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint ; var break : boolean ; var down_counter,up_counter : NativeInt; const abscntr : NativeInt);
   begin
     (FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore).AppendObjectUIDS(uids,ascending,down_counter,up_counter,abscntr);
   end;

begin
  SetLength(uids,0);
  FIndex.RangeScan(mikey,makey,milen,malen,@IteratorBreak,max_count,skipfirst,ascending)
end;

procedure TFRE_DB_MM_Index.TransformToBinaryComparableDomain(const domid_field: TFRE_DB_FIELD; const fld: TFRE_DB_FIELD; const key: PByte; var keylen: Nativeint);
var dkeylen : NativeInt;
begin
  TFRE_DB_UnsignedIndex.TransformtoBinaryComparable(domid_field,key,dkeylen,false,false); { prefix with domainid }
  TransformtoBinaryComparable(fld,key+dkeylen,keylen);
  keylen := keylen+dkeylen;
end;

function TFRE_DB_MM_Index.CompareTransformedKeys(const key1, key2: PByte; const keylen1, keylen2: Nativeint): boolean;
begin
  if keylen1=keylen2 then
    if CompareMemRange(@key1[0],@key2[0],keylen1)=0 then
      exit(true);
  exit(false);
end;

procedure TFRE_DB_MM_Index.StreamHeader(const stream: TStream);
begin
  stream.WriteAnsiString('FOSIDX1');
  stream.WriteAnsiString(ClassName);
  stream.WriteAnsiString(FIndexName);
  stream.WriteAnsiString(FFieldname);
  stream.WriteAnsiString(CFRE_DB_FIELDTYPE_SHORT[FFieldType]);
  if FUnique then
    stream.WriteByte(1)
  else
    stream.WriteByte(0);
  if FAllowNull then
    stream.WriteByte(1)
  else
    stream.WriteByte(0);
  if FUniqueNullVals then
    stream.WriteByte(1)
  else
    stream.WriteByte(0);
  if FIsADomainIndex then
    stream.WriteByte(1)
  else
    stream.WriteByte(0);
end;

procedure TFRE_DB_MM_Index.StreamToThis(const stream: TStream);
begin
  StreamHeader(stream);
  StreamIndex(stream);
end;

procedure TFRE_DB_MM_Index.StreamIndex(const stream: TStream);
var i:NativeInt;

  procedure StreamKeyVal(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
  var ixs : TFRE_DB_IndexValueStore;
  begin
    stream.WriteQWord(KeyLen);
    stream.WriteBuffer(Key^,KeyLen);
    ixs := FREDB_PtrUIntToObject(value) as TFRE_DB_IndexValueStore;
    ixs.StreamToThis(stream);
  end;

begin
  i := FIndex.GetValueCount;
  stream.WriteQWord(i);
  FIndex.LinearScanKeyVals(@StreamKeyVal);
end;

function TFRE_DB_MM_Index.GetIndexDefinitionObject: IFRE_DB_Object;
begin
  result := GFRE_DBI.NewObject;
  result.Field('IX_CLASS').AsString  := ClassName;
  result.Field('IX_NAM').AsString    := FIndexName;
  result.Field('IX_FN').AsString     := FFieldname;
  result.Field('IX_FT').AsString     := CFRE_DB_FIELDTYPE_SHORT[FFieldType];
  result.Field('IX_UNQ').AsBoolean   := FUnique;
  result.Field('IX_UNQN').AsBoolean  := FUniqueNullVals;
  result.Field('IX_ANULL').AsBoolean := FAllowNull;
  result.Field('IX_DOM').AsBoolean   := FIsADomainIndex;
end;

function TFRE_DB_MM_Index.GetIndexDefinition: TFRE_DB_INDEX_DEF;
begin
  with result do
    begin
      IndexClass    := ClassName;
      IndexName     := FIndexName;
      FieldName     := FFieldname;
      FieldType     := FFieldType;
      Unique        := FUnique;
      AllowNulls    := FAllowNull;
      UniqueNull    := FUniqueNullVals;
      IgnoreCase    := false;
      DomainIndex   := FIsADomainIndex;
    end;
end;

procedure TFRE_DB_MM_Index.LoadIndex(const stream: TStream ; const coll: TFRE_DB_PERSISTANCE_COLLECTION);
var i,cnt      : NativeInt;
    keylen     : NativeUint;
    key        : RawByteString;
    ixs        : TFRE_DB_IndexValueStore;

begin
  cnt := stream.ReadQWord;
  for i := 1 to cnt do
    begin
      keylen := stream.ReadQWord;
      SetLength(key,keylen);
      stream.ReadBuffer(Key[1],keylen);
      ixs := TFRE_DB_IndexValueStore.Create;
      ixs.LoadFromThis(stream,coll);
      if not FIndex.InsertBinaryKey(@key[1],keylen,FREDB_ObjectToPtrUInt(ixs)) then
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'stream load : index add failure [%s]',[key]);
    end;
end;

class function TFRE_DB_MM_Index.CreateFromStream(const stream: TStream; const coll: TFRE_DB_PERSISTANCE_COLLECTION): TFRE_DB_MM_Index;
var vers           : String;
    cn,idxn,fieldn : String;
    ft             : TFRE_DB_FIELDTYPE;
    unique         : boolean;
    allownull      : boolean;
    uniquenull     : boolean;
    domindex       : boolean;

begin
  vers      := stream.ReadAnsiString;
  if vers='FOSIDX1' then
    begin
      cn         := stream.ReadAnsiString;
      idxn       := stream.ReadAnsiString;
      fieldn     := stream.ReadAnsiString;
      ft         := FREDB_FieldtypeShortString2Fieldtype(stream.ReadAnsiString);
      unique     := stream.ReadByte=1;
      allownull  := stream.ReadByte=1;
      uniquenull := stream.ReadByte=1;
      domindex   := stream.ReadByte=1;
    end
  else
    begin
      cn         := vers;
      idxn       := stream.ReadAnsiString;
      fieldn     := stream.ReadAnsiString;
      ft         := FREDB_FieldtypeShortString2Fieldtype(stream.ReadAnsiString);
      unique     := stream.ReadByte=1;
      allownull  := stream.ReadByte=1;
      uniquenull := stream.ReadByte=1;
      domindex   := false;
    end;
  case cn of
    'TFRE_DB_TextIndex'     : result := TFRE_DB_TextIndex.CreateStreamed    (stream,idxn,fieldn,ft,unique,coll,allownull,uniquenull,domindex);
    'TFRE_DB_RealIndex'     : result := TFRE_DB_RealIndex.CreateStreamed    (stream,idxn,fieldn,ft,unique,coll,allownull,uniquenull,domindex);
    'TFRE_DB_SignedIndex'   : result := TFRE_DB_SignedIndex.CreateStreamed  (stream,idxn,fieldn,ft,unique,coll,allownull,uniquenull,domindex);
    'TFRE_DB_UnsignedIndex' : result := TFRE_DB_UnsignedIndex.CreateStreamed(stream,idxn,fieldn,ft,unique,coll,allownull,uniquenull,domindex);
    else
      raise EFRE_DB_PL_Exception.Create(edb_ERROR,'Unsupported streaming index class [%s]',[cn]);
  end;
end;

class function TFRE_DB_MM_Index.CreateFromDef(const def: TFRE_DB_INDEX_DEF; const coll: TFRE_DB_PERSISTANCE_COLLECTION): TFRE_DB_MM_Index;
begin
  with def do
    case IndexClass of
      'TFRE_DB_TextIndex'     : result := TFRE_DB_TextIndex.Create    (IndexName,FieldName,FieldType,Unique,IgnoreCase,coll,AllowNulls,UniqueNull,DomainIndex);
      'TFRE_DB_RealIndex'     : result := TFRE_DB_RealIndex.Create    (IndexName,FieldName,FieldType,Unique           ,coll,AllowNulls,UniqueNull,DomainIndex);
      'TFRE_DB_SignedIndex'   : result := TFRE_DB_SignedIndex.Create  (IndexName,FieldName,FieldType,Unique           ,coll,AllowNulls,UniqueNull,DomainIndex);
      'TFRE_DB_UnsignedIndex' : result := TFRE_DB_UnsignedIndex.Create(IndexName,FieldName,FieldType,Unique           ,coll,AllowNulls,UniqueNull,DomainIndex);
      else
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'Unsupported streaming index class [%s]',[IndexClass]);
    end;
end;

function TFRE_DB_MM_Index._IndexIsFullUniqe: Boolean;
begin
  result := (FUnique=true) and ((FUniqueNullVals=true) or (FAllowNull=false));
end;

function TFRE_DB_MM_Index._GetIndexStringSpec: String;
begin
  result := FCollection.CollectionName(false)+'#'+FIndexName+'('+FFieldname+')';
end;

class function TFRE_DB_MM_Index.GetIndexClassForFieldtype(const fieldtype: TFRE_DB_FIELDTYPE; var idxclass: TFRE_DB_MM_IndexClass): TFRE_DB_Errortype;
begin
  result := edb_OK;
  case FieldType of
    fdbft_GUID,
    fdbft_ObjLink,
    fdbft_Boolean,
    fdbft_Byte,
    fdbft_UInt16,
    fdbft_UInt32,
    fdbft_UInt64 :     idxclass     := TFRE_DB_UnsignedIndex;
    fdbft_Int16,    // invert Sign bit by xor (1 shl (bits-1)), then swap endian
    fdbft_Int32,
    fdbft_Int64,
    fdbft_Currency, // = int64*10000;
    fdbft_DateTimeUTC: idxclass     := TFRE_DB_SignedIndex;
    fdbft_Real32,
    fdbft_Real64:      idxclass     := TFRE_DB_RealIndex;

    fdbft_String:      idxclass     := TFRE_DB_TextIndex;
    //fdbft_Stream: ;
    //fdbft_Object: ;
    else
      exit(edb_UNSUPPORTED);
  end;
end;

class procedure TFRE_DB_MM_Index.GetKeyLenForFieldtype(const fieldtype: TFRE_DB_FIELDTYPE; var FixedKeyLen: NativeInt);
begin
  case fieldtype of
    fdbft_GUID,
    fdbft_ObjLink:      FixedKeylen := 16;
    fdbft_Byte:         FixedKeylen := 1;
    fdbft_Int16:        FixedKeylen := 2;
    fdbft_UInt16:       FixedKeylen := 2;
    fdbft_Int32:        FixedKeylen := 4;
    fdbft_UInt32:       FixedKeylen := 4;
    fdbft_Int64:        FixedKeylen := 8;
    fdbft_UInt64:       FixedKeylen := 8;
    fdbft_Real32:       FixedKeylen := 8;
    fdbft_Real64:       FixedKeylen := 8;
    fdbft_Currency:     FixedKeylen := 8;
    fdbft_String:       FixedKeylen := 8;
    fdbft_Boolean:      FixedKeylen := 1;
    fdbft_DateTimeUTC:  FixedKeylen := 8;
    else
      FixedKeyLen := -1;
  end;
end;

{ TFRE_DB_CollectionTree }

constructor TFRE_DB_CollectionManageTree.Create;
begin
  FCollTree := TFRE_ART_TREE.Create;
end;

destructor TFRE_DB_CollectionManageTree.Destroy;
begin
  FCollTree.Clear;
  FCollTree.Free;
  inherited Destroy;
end;

procedure TFRE_DB_CollectionManageTree.Clear;

  procedure ClearTree(var dummy : NativeUint);
  begin
    TFRE_DB_Persistance_Collection(FREDB_PtrUIntToObject(dummy)).Free;
  end;

begin
  FCollTree.LinearScan(@ClearTree);
  FCollTree.Clear;
end;

function TFRE_DB_CollectionManageTree.NewCollection(const coll_name: TFRE_DB_NameType; out Collection: TFRE_DB_PERSISTANCE_COLLECTION; const volatile_in_memory: boolean; const masterdata: TFRE_DB_Master_Data): TFRE_DB_Errortype;
var coll     : TFRE_DB_Persistance_Collection;
    safename : TFRE_DB_NameType;
begin
  safename := UpperCase(coll_name);
  if FCollTree.ExistsBinaryKey(@safename[1],Length(safename),dummy) then
    begin
      Collection := TFRE_DB_Persistance_Collection(dummy);
      result     := edb_EXISTS;
    end
  else
    begin
      coll := TFRE_DB_Persistance_Collection.Create(coll_name,volatile_in_memory,masterdata);
      if FCollTree.InsertBinaryKey(@coll.UniqueName^[1],length(coll.UniqueName^),FREDB_ObjectToPtrUInt(coll)) then
        begin
          Collection := coll;
          exit(edb_OK);
        end
      else
        begin
          coll.Free;
          exit(edb_INTERNAL);
        end;
    end;
end;

function TFRE_DB_CollectionManageTree.DeleteCollection(const coll_name: TFRE_DB_NameType): TFRE_DB_Errortype;
var coll     : TFRE_DB_Persistance_Collection;
    safename : TFRE_DB_NameType;
    colli    : TFRE_DB_PERSISTANCE_COLLECTION_BASE;
begin
  safename := UpperCase(coll_name);
  if FCollTree.RemoveBinaryKey(@safename[1],Length(safename),dummy) then
    begin
      Coll := TFRE_DB_Persistance_Collection(dummy);
      result     := edb_OK;
      Coll.Free;
    end
  else
    begin
      result := edb_NOT_FOUND;
    end;
end;

function TFRE_DB_CollectionManageTree.GetCollection(const coll_name: TFRE_DB_NameType; out Collection: TFRE_DB_PERSISTANCE_COLLECTION): boolean;
begin
  result := GetCollectionInt(coll_name,TFRE_DB_PERSISTANCE_COLLECTION(Collection));
end;

function TFRE_DB_CollectionManageTree.GetCollectionInt(const coll_name: TFRE_DB_NameType; out Collection: TFRE_DB_PERSISTANCE_COLLECTION): boolean;
var safename : TFRE_DB_NameType;
begin
  safename:=uppercase(coll_name);
  if FCollTree.ExistsBinaryKey(@safename[1],length(safename),dummy) then
    begin
      Collection := TFRE_DB_Persistance_Collection(dummy);
      result     := true;
    end
  else
    begin
      Collection := nil;
      Result := false;
    end;
end;

procedure TFRE_DB_CollectionManageTree.ForAllCollections(const iter: TFRE_DB_PersColl_Iterator);
var brk : boolean;
  procedure IterateColls(var dummy:NativeUInt ; var brk : boolean);
  var coll : TFRE_DB_Persistance_Collection;
  begin
    coll := FREDB_PtrUIntToObject(dummy) as TFRE_DB_Persistance_Collection;
    if coll.IsVolatile then
      abort;
    iter(coll)
  end;
begin
  brk := false;
  FCollTree.LinearScanBreak(@IterateColls,brk);
end;

function TFRE_DB_CollectionManageTree.GetCollectionCount: Integer;
begin
  result := FCollTree.GetValueCount;
end;

{ TFRE_DB_Persistance_Collection }

function TFRE_DB_Persistance_Collection.IsVolatile: boolean;
begin
  result := FVolatile;
end;

function TFRE_DB_Persistance_Collection.IndexExists(const idx_name: TFRE_DB_NameType): NativeInt;
var
  i           : NativeInt;
  FUniqueName : TFRE_DB_NameType;
begin
  result := -1;
  FUniqueName := UpperCase(idx_name);
  for i := 0 to high(FIndexStore) do
    if FIndexStore[i].Uniquename^=FUniqueName then
      exit(i);
end;

function TFRE_DB_Persistance_Collection.GetIndexDefinition(const idx_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): TFRE_DB_INDEX_DEF;
var i : NativeInt;
begin
  i := IndexExists(idx_name);
  if i=-1 then
    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the requested index [%s] does not exist on collection [%s]',[idx_name,FName]);
  result := FIndexStore[i].GetIndexDefinition;
end;

function TFRE_DB_Persistance_Collection.IndexNames: TFRE_DB_NameTypeArray;
var  i : Integer;
begin
  SetLength(result,Length(FIndexStore));
  for i := 0 to high(FIndexStore) do
    result[i] := FIndexStore[i].Indexname;
end;

procedure TFRE_DB_Persistance_Collection.AddIndex(const idx: TFRE_DB_MM_Index);
var high : NativeInt;
begin
  high := Length(FIndexStore);
  SetLength(FIndexStore,high+1);
  FIndexStore[high] := idx;
end;

procedure TFRE_DB_Persistance_Collection.IndexAddCheck(const obj: TFRE_DB_Object; const check_only: boolean);
var i : NativeInt;
begin
  for i:= 0 to high(FIndexStore) do
    FIndexStore[i].IndexAddCheck(obj,check_only);
end;

procedure TFRE_DB_Persistance_Collection.IndexUpdCheck(const new_obj, old_obj: TFRE_DB_Object; const check_only: boolean);
var i : NativeInt;
begin
  for i:= 0 to high(FIndexStore) do
    FIndexStore[i].IndexUpdCheck(new_obj, old_obj,check_only);
end;

procedure TFRE_DB_Persistance_Collection.IndexDelCheck(const del_obj: TFRE_DB_Object; const check_only: boolean);
var i : NativeInt;
begin
  for i:= 0 to high(FIndexStore) do
    FIndexStore[i].IndexDelCheck(del_obj,nil,check_only);
end;

constructor TFRE_DB_Persistance_Collection.Create(const coll_name: TFRE_DB_NameType; Volatile: Boolean; const masterdata: TFRE_DB_Master_Data);
begin
  FGuidObjStore := TFRE_ART_TREE.Create;
  FName         := coll_name;
  FVolatile     := Volatile;
  FMasterLink   := masterdata;
  FUpperName    := UpperCase(FName);
end;

destructor TFRE_DB_Persistance_Collection.Destroy;
var
  i: NativeInt;
begin
  for i := 0 to high(FIndexStore) do
    FIndexStore[i].Free;
  Clear;
  FGuidObjStore.Free;
  inherited Destroy;
end;

function TFRE_DB_Persistance_Collection.Count: int64;
begin
  result := FGuidObjStore.GetValueCount;
end;

function TFRE_DB_Persistance_Collection.Exists(const ouid: TFRE_DB_GUID): boolean;
var  dummy : PtrUInt;
begin
  result := FGuidObjStore.ExistsBinaryKey(@ouid,SizeOf(ouid),dummy);
end;

function TFRE_DB_Persistance_Collection.Remove(const ouid: TFRE_DB_GUID): TFRE_DB_Errortype;
begin
  abort;
  //FLayer.DeleteObject(ouid,CollectionName(true));
  //exit(edb_OK);
end;

function TFRE_DB_Persistance_Collection.FetchO(const uid: TFRE_DB_GUID; var obj: TFRE_DB_Object): boolean;
var  dummy : PtrUInt;
begin
  result := FGuidObjStore.ExistsBinaryKey(@uid,SizeOf(TFRE_DB_GUID),dummy);
  if result then
    obj := CloneOutObject(FREDB_PtrUIntToObject(dummy) as TFRE_DB_Object)
  else
    obj := nil;
end;

procedure TFRE_DB_Persistance_Collection.Clear;
begin
  FGuidObjStore.Clear;
end;

procedure TFRE_DB_Persistance_Collection.GetAllUIDS(var uids: TFRE_DB_GUIDArray);
var cnt,maxc : NativeInt;

  procedure ForAll(var val:PtrUInt);
  var newobj : TFRE_DB_Object;
  begin
    newobj    := FREDB_PtrUIntToObject(val) as TFRE_DB_Object;
    uids[cnt] := newobj.UID;
    inc(cnt);
    assert(cnt<=maxc);
  end;

begin
  cnt  := 0;
  maxc := FGuidObjStore.GetValueCount;
  SetLength(uids,maxc);
  FGuidObjStore.LinearScan(@ForAll);
end;

procedure TFRE_DB_Persistance_Collection.GetAllObjects(var objs: IFRE_DB_ObjectArray);
var cnt,maxc : NativeInt;

  procedure ForAll(var val:PtrUInt);
  var newobj : TFRE_DB_Object;
  begin
    newobj    := FREDB_PtrUIntToObject(val) as TFRE_DB_Object;
    objs[cnt] := CloneOutObject(newobj);
    inc(cnt);
    assert(cnt<=maxc);
  end;

begin
  cnt  := 0;
  maxc := FGuidObjStore.GetValueCount;
  SetLength(objs,maxc);
  FGuidObjStore.LinearScan(@ForAll);
end;

procedure TFRE_DB_Persistance_Collection.GetAllObjectsInt(var objs: IFRE_DB_ObjectArray);
var cnt,maxc : NativeInt;

  procedure ForAll(var val:PtrUInt);
  var newobj : TFRE_DB_Object;
  begin
    newobj    := FREDB_PtrUIntToObject(val) as TFRE_DB_Object;
    objs[cnt] := newobj;
    inc(cnt);
    assert(cnt<=maxc);
  end;

begin
  cnt  := 0;
  maxc := FGuidObjStore.GetValueCount;
  SetLength(objs,maxc);
  FGuidObjStore.LinearScan(@ForAll);
end;

// An object is allowed only once in a collection, but can be stored in multiple collections
// An object is always at least in one collection, dangling objects (without beeing in a collection) are errors
// All subobjects are stored and fetchable in the "Master" store too
// Subobjects can only be parented once (can only be part of one object), thus need to be unique

procedure TFRE_DB_Persistance_Collection.StoreInThisColl(const new_iobj: IFRE_DB_Object; const checkphase: boolean);
var new_obj : TFRE_DB_Object;
      dummy : PtrUInt;
begin
  // Check existance in this collection
  new_obj := new_iobj.Implementor as TFRE_DB_Object;
  if checkphase then
    begin
      if FGuidObjStore.ExistsBinaryKey(new_obj.UIDP,SizeOf(TFRE_DB_GUID),dummy) then
        raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'object [%s] already exists on store in collection [%s]',[new_obj.UID_String,FName]);
      IndexAddCheck(new_obj,true);
    end
  else
    begin
        IndexAddCheck(new_obj,false);
        if not FGuidObjStore.InsertBinaryKey(new_obj.UIDP,SizeOf(TFRE_DB_GUID),FREDB_ObjectToPtrUInt(new_obj)) then
          raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'store of object [%s] in collection [%s] failed -> already exists on store after exist check ?',[new_obj.UID_String,FName]);
        new_obj.__InternalCollectionAdd(self); // Add The Colection Reference to a directly stored master or child object
        assert(length(new_obj.__InternalGetCollectionList)>0);
    end;
end;

procedure TFRE_DB_Persistance_Collection.UpdateInThisColl(const new_ifld, old_ifld: IFRE_DB_FIELD; const old_iobj, new_iobj: IFRE_DB_Object; const update_typ: TFRE_DB_ObjCompareEventType; const in_child_obj: boolean; const checkphase: boolean);
var old_fld,new_fld : TFRE_DB_FIELD;
    old_obj,new_obj : TFRE_DB_Object;
begin
  if Assigned(old_iobj) then
    old_obj := old_iobj.Implementor as TFRE_DB_Object
  else
    old_obj := nil;
  if assigned(new_iobj) then
    new_obj := new_iobj.Implementor as TFRE_DB_Object
  else
    new_obj := nil;
  if assigned(old_ifld) then
    old_fld := old_ifld.Implementor as TFRE_DB_FIELD
  else
    old_fld := nil;
  if assigned(new_ifld) then
    new_fld := new_ifld.Implementor as TFRE_DB_FIELD
  else
    new_fld := nil;
  if not in_child_obj then
    CheckFieldChangeAgainstIndex(old_fld,new_fld,update_typ,checkphase,old_obj,new_obj)
  else
   { indices must not be defined on child objects}
end;

procedure TFRE_DB_Persistance_Collection.DeleteFromThisColl(const del_iobj: IFRE_DB_Object; const checkphase: boolean);
var    cnt   : NativeInt;
     del_obj : TFRE_DB_Object;
       dummy : PtrUInt;
begin
  del_obj := del_iobj.Implementor as TFRE_DB_Object;
  if checkphase then
    begin
      if not FGuidObjStore.ExistsBinaryKey(del_obj.UIDP,SizeOf(TFRE_DB_GUID),dummy) then
        raise EFRE_DB_PL_Exception.Create(edb_EXISTS,'object [%s] does not exist on delete in collection [%s]',[del_obj.UID_String,FName]);
      IndexDelCheck(del_obj,true);
    end
  else
    begin
      IndexDelCheck(del_obj,false);
      if not FGuidObjStore.RemoveBinaryKey(del_obj.UIDP,SizeOf(TFRE_DB_GUID),dummy) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'delete of object [%s] in collection [%s] failed -> does not exists on delete after exist check ?',[del_obj.UID_String,FName]);
      cnt := del_obj.__InternalCollectionRemove(self); // Add The Colection Reference to a directly stored master or child object
      if cnt=0 then
        begin
          // Object will be finally removed on FMasterdata Step
        end;
    end;
end;

function TFRE_DB_Persistance_Collection.CloneOutObject(const inobj: TFRE_DB_Object): TFRE_DB_Object;
begin
  result := FMasterLink.CloneOutObject(inobj);
end;

function TFRE_DB_Persistance_Collection.CloneOutArray(const objarr: TFRE_DB_GUIDArray): TFRE_DB_ObjectArray;
var i:NativeInt;
begin
  SetLength(result,length(objarr));
  for i:=0 to high(objarr) do
    if not FetchO(objarr[i],result[i]) then
      raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'cloneout failed uid not found [%s]',[FREDB_G2H(objarr[i])]);
end;

function TFRE_DB_Persistance_Collection.CloneOutArrayOI(const objarr: TFRE_DB_GUIDArray): IFRE_DB_ObjectArray;
var i:NativeInt;
begin
  SetLength(result,length(objarr));
  for i:=0 to high(objarr) do
    if not Fetch(objarr[i],result[i]) then
      raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'cloneout failed uid not found [%s]',[FREDB_G2H(objarr[i])]);
end;

function TFRE_DB_Persistance_Collection.CloneOutArrayII(const objarr: IFRE_DB_ObjectArray): IFRE_DB_ObjectArray;
var i : NativeInt;
begin
  SetLength(result,Length(objarr));
  for i:=0 to high(objarr) do
    result[i] := CloneOutObject(objarr[i].Implementor as TFRE_DB_Object);
end;

function TFRE_DB_Persistance_Collection.FetchIntFromCollArrOI(const objarr: TFRE_DB_GUIDArray): IFRE_DB_ObjectArray;
var i:NativeInt;
begin
  SetLength(result,length(objarr));
  for i:=0 to high(objarr) do
    if not FetchIntFromColl(objarr[i],result[i]) then
      raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'fetchinternalarr failed uid not found [%s]',[FREDB_G2H(objarr[i])]);
end;

function TFRE_DB_Persistance_Collection.FetchIntFromCollAll: IFRE_DB_ObjectArray;
var uids : TFRE_DB_GUIDArray;
begin
  GetAllUIDS(uids);
  result := FetchIntFromCollArrOI(uids)
end;

procedure TFRE_DB_Persistance_Collection.ForAllInternalI(const iter: IFRE_DB_Obj_Iterator);
  procedure ForAll(var val:PtrUInt);
  var newobj : TFRE_DB_Object;
  begin
    newobj    := FREDB_PtrUIntToObject(val) as TFRE_DB_Object;
    iter(newobj);
  end;
begin
  FGuidObjStore.LinearScan(@ForAll);
end;

procedure TFRE_DB_Persistance_Collection.ForAllInternal(const iter: TFRE_DB_Obj_Iterator);
  procedure ForAll(var val:PtrUInt);
  var newobj : TFRE_DB_Object;
  begin
    newobj    := FREDB_PtrUIntToObject(val) as TFRE_DB_Object;
    iter(newobj);
  end;
begin
  FGuidObjStore.LinearScan(@ForAll);
end;

procedure TFRE_DB_Persistance_Collection.ForAllInternalBreak(const iter: TFRE_DB_ObjectIteratorBrk;var halt : boolean ; const descending : boolean);

  procedure ForAll(var val : NativeUint ; var break : boolean);
  var newobj : TFRE_DB_Object;
  begin
    newobj    := FREDB_PtrUIntToObject(val) as TFRE_DB_Object;
    iter(newobj,break);
  end;

begin
  FGuidObjStore.LinearScanBreak(@ForAll,halt,descending);
end;

procedure TFRE_DB_Persistance_Collection.StreamToThis(const stream: TStream);
var i,cnt,vcnt : nativeint;

   procedure AllGuids(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
   var s:string[16];
   begin
     assert(KeyLen=16);
     SetLength(s,16);
     move(key^,s[1],16);
     stream.WriteAnsiString(s); // guid;
     inc(vcnt);
   end;

begin
  if FVolatile then
    abort;
  stream.Position:=0;
  stream.WriteAnsiString('FDBC');
  stream.WriteAnsiString(FName);
  stream.WriteAnsiString('*');
  cnt  := FGuidObjStore.GetValueCount;
  vcnt := 0;
  stream.WriteQWord(cnt);
  FGuidObjStore.LinearScanKeyVals(@AllGuids);
  assert(vcnt=cnt);
  //stream.WriteQWord(length(FIndexStore));
  //for i:=0 to high(FIndexStore) do
  //  FIndexStore[i].StreamToThis(stream);
  stream.WriteQWord(0); { index stream is not in the collection stream anymore }
end;

procedure TFRE_DB_Persistance_Collection.StreamIndexToThis(const ix_name: TFRE_DB_NameType; const stream: TStream);
var ix : NativeInt;
begin
  ix :=IndexExists(ix_name);
  if ix=-1 then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch index by name [%s]',[ix_name]);
  FIndexStore[ix].StreamToThis(stream);
end;

function TFRE_DB_Persistance_Collection.GetIndexDefObject: IFRE_DB_Object;
var obj : IFRE_DB_Object;
    i   : NativeInt;
begin
  obj := GFRE_DBI.NewObject;
  obj.Field('IndexNames').AsStringArr := FREDB_NametypeArray2StringArray(IndexNames);
  for i:=0 to high(FIndexStore) do
    obj.Field('ID_'+FIndexStore[i].Uniquename^).AsObject := FIndexStore[i].GetIndexDefinitionObject;
  result := obj;
end;

procedure TFRE_DB_Persistance_Collection.CreateIndexDefsFromObj(const obj: IFRE_DB_Object);
var ido    : IFRE_DB_Object;
    stream : TStream;
    loaded : boolean;
    ixdef  : TFRE_DB_INDEX_DEF_ARRAY;
    i      : NativeInt;

begin
  if Length(FIndexStore)<>0 then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'index definitions could only be created on an empty index store(!)');
  ixdef := FREDB_CreateIndexDefArrayFromObject(obj);
  SetLength(FIndexStore,Length(ixdef));
  for i:=0 to high(ixdef) do
    begin
      loaded := false;
      if GetPersLayer.FDB_TryGetIndexStream(CollectionName(false),ixdef[i].IndexName,stream) then
        begin
          try
            GFRE_DBI.LogDebug(dblc_PERSISTANCE,'>>LOAD STREAM FOR DEF [%s]',[ixdef[i].IndexDescription]);
            FIndexStore[i] := TFRE_DB_MM_Index.CreateFromStream(stream,self);
            loaded := true;
            stream.Free;
          except
            on e:Exception do
              begin
                 GFRE_DBI.LogError(dblc_PERSISTANCE,'FAILURE LOADING INDEX STREAM [%s/%s] (%s)',[CollectionName(false),ixdef[i].IndexName,e.Message]);
                 loaded := false;
              end;
          end;
        end;
      if not loaded then
        begin
          GFRE_DBI.LogError(dblc_PERSISTANCE,'COULD NOT LOAD INDEX STREAM FOR [%s/%s]',[CollectionName(false),ixdef[i].IndexName]);
          FIndexStore[i] := TFRE_DB_MM_Index.CreateFromDef(ixdef[i],self);
          GFRE_DBI.LogWarning(dblc_PERSISTANCE,'REINDEXING [%s] (%s)',[CollectionName(false),ixdef[i].IndexDescription]);
          FIndexStore[i].FullReindex;
          GFRE_DBI.LogWarning(dblc_PERSISTANCE,'REINDEXING [%s/%s] DONE',[CollectionName(false),ixdef[i].IndexName]);
        end;
    end;
end;

procedure TFRE_DB_Persistance_Collection.LoadFromThis(const stream: TStream);
var in_txt : String;
    cnt,i  : NativeInt;
    uid    : TFRE_DB_GUID;
    dbo    : TFRE_DB_Object;
begin
  in_txt := stream.ReadAnsiString;
  if in_txt<>'FDBC' then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'COLLECTION STREAM INVALID : signature bad');
  in_txt := stream.ReadAnsiString;
  if in_txt<>FName then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'COLLECTION STREAM INVALID NAME DIFFERS: [%s <> %s]',[in_txt,FName]);
  stream.ReadAnsiString; // deprecated collectionclassname

  cnt := stream.ReadQWord;
  //writeln('RELOADING COLLECTION ',in_txt,' / ',cnt);
  for i := 1 to cnt do
    begin
      in_txt := stream.ReadAnsiString; // guid;
      assert(Length(in_txt)=16);
      move(in_txt[1],uid,16);
      if not FMasterLink.FetchObject(uid,dbo,true) or
         not assigned(dbo) then
           raise EFRE_DB_PL_Exception.Create(edb_ERROR,'COLLECTION [%s] LOAD / FETCH FAILED [%s]',[CollectionName(false),FREDB_G2H(uid)]);
      if not FGuidObjStore.InsertBinaryKey(dbo.UIDP,SizeOf(TFRE_DB_GUID),FREDB_ObjectToPtrUInt(dbo)) then
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'COLLECTION [%s] LOAD / INSERT FAILED [%s] EXISTS',[CollectionName(false),FREDB_G2H(uid)]);
      dbo.__InternalCollectionAdd(self);
    end;
  cnt := stream.ReadQWord;
  SetLength(FIndexStore,cnt);
  for i := 0 to high(FIndexStore) do
    begin
      FIndexStore[i] := TFRE_DB_MM_Index.CreateFromStream(stream,self);
      writeln('>>> WARNING');
      writeln('>>>   LOADING OLD FORMAT / INPLACE INDEX STREAM >>',FIndexStore[i].Indexname,'<<');
      writeln('>>> WARNING');
    end;
end;

function TFRE_DB_Persistance_Collection.BackupToObject: IFRE_DB_Object;
var i,cnt,vcnt : nativeint;
    obj        : IFRE_DB_Object;
    arr        : TFRE_DB_GUIDArray;

   procedure AllGuids(var value : NativeUInt ; const Key : PByte ; const KeyLen : NativeUint);
   var pguid : PFRE_DB_GUID;
   begin
     assert(KeyLen=16);
     pguid := PFRE_DB_GUID(Key);
     arr[vcnt] := pguid^;
     inc(vcnt);
   end;

begin
  if FVolatile then
    abort;
  obj := GFRE_DBI.NewObject;
  obj.Field('CollectionName').AsString := FName;
  obj.Field('ClassName').AsString      := '*';
  cnt  := FGuidObjStore.GetValueCount;
  vcnt := 0;
  SetLength(arr,cnt);
  FGuidObjStore.LinearScanKeyVals(@AllGuids);
  assert(vcnt=cnt);
  obj.Field('ObjectUids').AsGUIDArr := arr;
  obj.Field('IndexCount').AsInt32   := length(FIndexStore);
  for i:=0 to high(FIndexStore) do
    FIndexStore[i].StreamToThis(obj.Field('Index_'+inttostr(i)).AsStream);
  obj.Field('Indexes').AsObject := GetIndexDefObject;
  result := obj;
end;

procedure TFRE_DB_Persistance_Collection.RestoreFromObject(const obj: IFRE_DB_Object);
var in_txt : String;
    cnt,i  : NativeInt;
    uid    : TFRE_DB_GUID;
    dbo    : TFRE_DB_Object;
    arr    : TFRE_DB_GUIDArray;
begin
  //FCClassname := obj.Field('ClassName').AsString;
  arr         :=  obj.Field('ObjectUids').AsGUIDArr;
  for i := 0 to high(arr) do
    begin
      uid := arr[i];
      if (not FMasterLink.FetchObject(uid,dbo,true)) or
         not assigned(dbo) then
           raise EFRE_DB_PL_Exception.Create(edb_ERROR,'COLLECTION LOAD / FETCH FAILED [%s]',[FREDB_G2H(uid)]);
      if not FGuidObjStore.InsertBinaryKey(dbo.UIDP,SizeOf(TFRE_DB_GUID),FREDB_ObjectToPtrUInt(dbo)) then
        raise EFRE_DB_PL_Exception.Create(edb_ERROR,'COLLECTION LOAD / INSERT FAILED [%s] EXISTS',[FREDB_G2H(uid)]);
      dbo.__InternalCollectionAdd(self);
    end;

  cnt := obj.Field('IndexCount').AsInt32;
  SetLength(FIndexStore,cnt);
  for i := 0 to high(FIndexStore) do
    FIndexStore[i] := TFRE_DB_MM_Index.CreateFromStream(obj.Field('Index_'+inttostr(i)).AsStream,self);
end;

function TFRE_DB_Persistance_Collection.CollectionName(const unique: boolean): TFRE_DB_NameType;
begin
  if unique then
    result := UniqueName^
  else
    result := FName;
end;

function TFRE_DB_Persistance_Collection.Fetch(const uid: TFRE_DB_GUID; var iobj: IFRE_DB_Object): boolean;
var dummy : PtrUInt;
begin
  result := FGuidObjStore.ExistsBinaryKey(@uid,SizeOf(TFRE_DB_GUID),dummy);
  if result then
    iobj := CloneOutObject(FREDB_PtrUIntToObject(dummy) as TFRE_DB_Object)
  else
    iobj := nil;
end;

function TFRE_DB_Persistance_Collection.DefineIndexOnFieldReal(const checkonly: boolean; const FieldName: TFRE_DB_NameType; const FieldType: TFRE_DB_FIELDTYPE; const unique: boolean; const ignore_content_case: boolean; const index_name: TFRE_DB_NameType; const allow_null_value: boolean; const unique_null_values: boolean; const domain_index: boolean; var prelim_index: TFRE_DB_MM_Index): TFRE_DB_Errortype;
begin
  result     := edb_OK;
  if IndexExists(index_name)>=0 then
    exit(edb_EXISTS);
  if checkonly then
    begin
      case FieldType of
        fdbft_GUID,
        fdbft_ObjLink,
        fdbft_Boolean,
        fdbft_Byte,
        fdbft_UInt16,
        fdbft_UInt32,
        fdbft_UInt64 :
            prelim_index := TFRE_DB_UnsignedIndex.Create(index_name,fieldname,fieldtype,unique,self,allow_null_value,unique_null_values,domain_index);
        fdbft_Int16,    // invert Sign bit by xor (1 shl (bits-1)), then swap endian
        fdbft_Int32,
        fdbft_Int64,
        fdbft_Currency, // = int64*10000;
        fdbft_DateTimeUTC:
            prelim_index := TFRE_DB_SignedIndex.Create(index_name,fieldname,fieldtype,unique,self,allow_null_value,unique_null_values,domain_index);
        fdbft_Real32,
        fdbft_Real64:
            prelim_index := TFRE_DB_RealIndex.Create(index_name,fieldname,fieldtype,unique,self,allow_null_value,unique_null_values,domain_index);
        fdbft_String:
            prelim_index := TFRE_DB_TextIndex.Create(index_name,FieldName,FieldType,unique,ignore_content_case,self,allow_null_value,unique_null_values,domain_index);
        else
          exit(edb_UNSUPPORTED);
      end;
      if Count>0 then
        begin
          try
           prelim_index.FullReindex;
          except
            on e:exception do
              begin
                 try
                   prelim_index.Free;
                 finally
                 end;
                 result.Code := edb_ERROR;
                 result.Msg  := 'Reindexing Failure : '+e.Message;
              end;
          end;
        end;
    end;
  if not checkonly then
    AddIndex(prelim_index);
end;

function TFRE_DB_Persistance_Collection.DropIndexReal(const checkonly: boolean; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): TFRE_DB_Errortype;
var idx   : NativeInt;
    i     : NativeInt;
    ix    : TFRE_DB_MM_Index;
    idxsn : Array of TFRE_DB_MM_Index;
begin
  if checkonly then
    begin
      idx := IndexExists(index_name);
      if idx=-1 then
        exit(edb_NOT_FOUND);
      exit(edb_OK);
    end
  else
   begin
     idx := IndexExists(index_name);
     if idx=-1 then
       exit(edb_NOT_FOUND);
     ix := FIndexStore[idx];
     try
       FIndexStore[idx]:=nil;
       ix.free;
     except
       on E:Exception do
         GFRE_DBI.LogError(dblc_PERSISTANCE,'unexpected exception freeing index data [%s] on collection [%s]',[index_name,CollectionName(false)]);
     end;
     SetLength(idxsn,Length(FIndexStore)-1);
     idx := 0;
     for i := 0 to high(FIndexStore) do
       begin
         if FIndexStore[i]<>nil then
           begin
             idxsn[idx] := FIndexStore[i];
             inc(idx)
           end;
       end;
     FIndexStore := idxsn;
     result := edb_OK;
   end;
end;


// Check if a field can be removed safely from an object stored in this collection, or if an index exists on that field
//TODO -> handle indexed field change
procedure TFRE_DB_Persistance_Collection.CheckFieldChangeAgainstIndex(const oldfield, newfield: TFRE_DB_FIELD; const change_type: TFRE_DB_ObjCompareEventType; const check: boolean; old_obj, new_obj: TFRE_DB_Object);
var i             : NativeInt;
    nullValExists : boolean;
    fieldname     : TFRE_DB_NameType;
    idummy        : TFRE_DB_Object;
begin
  if assigned(newfield) then
    begin
      fieldname := uppercase(newfield.FieldName);
    end;
  if assigned(oldfield) then
    begin
      fieldname := uppercase(oldfield.FieldName);
    end;
  for i := 0 to high(FIndexStore) do
    if FIndexStore[i].FUniqueFieldname=fieldname then
      begin
        case change_type of
          cev_FieldDeleted:
            begin
              FIndexStore[i].IndexDelCheck(old_obj,new_obj,check);
            end;
          cev_FieldAdded:
            begin
              nullValExists := FIndexStore[i].NullvalueExistsForObject(new_obj);
              if nullValExists then // We need to do an index update if a nullvalue for this object is already indexed
                begin
                  if not FetchIntFromCollO(new_obj.UID,idummy,true) then
                    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'FIELDCHANGE Internal an object should be updated but was not found [%s]',[new_obj.UID_String]);
                  old_obj := idummy.Implementor as TFRE_DB_Object;
                  FIndexStore[i].IndexUpdCheck(new_obj,old_obj,check);
                end
              else
                FIndexStore[i].IndexAddCheck(new_obj,check);
            end;
          cev_FieldChanged:
            begin
              FIndexStore[i].IndexUpdCheck(new_obj,old_obj,check);
            end;
        end;
      end;
end;

function TFRE_DB_Persistance_Collection.GetIndexedObjInternal(const query_value: TFRE_DB_String; out obj: IFRE_DB_Object; const index_name: TFRE_DB_NameType; const val_is_null: boolean): boolean;
var arr : TFRE_DB_GUIDArray;
begin
  result := _GetIndexedObjUids(query_value,arr,index_name,true,val_is_null);
  if not result then
    exit;
  if Length(arr)<>1 then
    raise EFRE_DB_PL_Exception.create(edb_INTERNAL,'a unique index internal store contains [%d] elements!',[length(arr)]);
  result := FetchIntFromColl(arr[0],obj);
  if not result then
    raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'logic failure, the index uid cannot be fetched as object');
end;

function TFRE_DB_Persistance_Collection._GetIndexedObjUids(const query_value: TFRE_DB_String; out arr: TFRE_DB_GUIDArray; const index_name: TFRE_DB_NameType; const check_is_unique: boolean; const is_null: boolean): boolean;
var idx     : NativeInt;
    index   : TFRE_DB_MM_Index;
    key     : Array [0..CFREA_maxKeyLen] of Byte;
    keylen  : NativeInt;

begin
  idx := IndexExists(index_name);
  if idx=-1 then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'the requested index named [%s] does not exist on collection [%s]',[index_name,FName]);
  index := FIndexStore[idx];
  if check_is_unique and
     not index.IsUnique then
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'the requested index named [%s] is not unique you must not use a point query',[index_name]);
  if not index.SupportsStringQuery then
    raise EFRE_DB_PL_Exception.Create(edb_ERROR,'the requested index named [%s] does not support a string query',[index_name]);

  (index as TFRE_DB_TextIndex).SetBinaryComparableKey(query_value,@key[0],keylen,is_null);
  result := index.FetchIndexedValsTransformedKey(arr,key,keylen);
end;


function TFRE_DB_Persistance_Collection.FetchIntFromColl(const uid: TFRE_DB_GUID; out obj: IFRE_DB_Object): boolean;
var objo : TFRE_DB_Object;
begin
  result := FetchIntFromCollO(uid,objo);
  if result then
    obj := objo
  else
    obj := nil;
end;

function TFRE_DB_Persistance_Collection.FetchIntFromCollO(const uid: TFRE_DB_GUID; out obj: TFRE_DB_Object; const no_store_lock_check: boolean): boolean;
var  dummy : PtrUInt;
begin
  result := FGuidObjStore.ExistsBinaryKey(@uid,SizeOf(TFRE_DB_GUID),dummy);
  if result then
    begin
      obj := FREDB_PtrUIntToObject(dummy) as TFRE_DB_Object;
      if not no_store_lock_check then
        obj.Assert_CheckStoreLocked;
      if Length(obj.__InternalGetCollectionList)<1 then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'logic failure, object has no assignment to internal collections');
    end
  else
    obj := nil;
end;

function TFRE_DB_Persistance_Collection.GetPersLayer: IFRE_DB_PERSISTANCE_LAYER;
begin
  result := FMasterLink.FLayer;
end;

procedure TFRE_DB_Persistance_Collection.GetAllIndexedUidsEncodedField(const qry_val: IFRE_DB_Object; const index_name: TFRE_DB_NameType; var uids: TFRE_DB_GUIDArray; const check_is_unique: boolean);
var   ix       : NativeInt;
      idx      : TFRE_DB_MM_Index;
      valf     : IFRE_DB_Field;
      domf     : IFRE_DB_Field;
      key      : Array [0..CFREA_maxKeyLen] of Byte;
      keylen   : NativeInt;
      ix_type  : TFRE_DB_INDEX_TYPE;

begin
  ix := IndexExists(index_name);
  if ix=-1 then
    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the index named[%s] does not exist',[index_name]);
  ix_type  := FREDB_GetIndexTypeFromObjectEncoding(qry_val);
  valf     := FREDB_GetIndexFldValFromObjectEncoding(qry_val);
  idx      := FIndexStore[ix];
  if not idx.SupportsIndexType(ix_type) then
    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the index named[%s] does not support the requested index type[%s], but index type[%s]',[index_name,CFRE_DB_INDEX_TYPE[ix_type],idx.IndexTypeTxt]);
  if check_is_unique and
     //not idx.IndexIsFullyUnique then { TODO -> Reindex System Collections, fix index definitions }
     not idx.IsUnique then { TODO -> Reindex System Collections, fix index definitions }
       raise EFRE_DB_PL_Exception.Create(edb_ERROR,'the requested index named [%s] is not unique you must not use a point query',[index_name]);
  if idx.IsDomainIndex then
    begin
      domf     := FREDB_GetDomainIDFldValFromObjectEncoding(qry_val);
      if assigned(valf) then
        idx.TransformToBinaryComparableDomain(domf.Implementor as TFRE_DB_FIELD,valf.Implementor as TFRE_DB_FIELD,@key,keylen)
      else
        idx.TransformToBinaryComparableDomain(domf.Implementor as TFRE_DB_FIELD,nil,@key,keylen);
    end
  else
    begin
      if assigned(valf) then
        idx.TransformToBinaryComparable(valf.Implementor as TFRE_DB_FIELD,@key,keylen)
      else
        idx.TransformToBinaryComparable(nil,@key,keylen);
    end;
  idx.FetchIndexedValsTransformedKey(uids,@key,keylen);
end;

procedure TFRE_DB_Persistance_Collection.GetAllIndexedUidsEncFieldRange(const min, max: IFRE_DB_Object; const index_name: TFRE_DB_NameType; var uids: TFRE_DB_GUIDArray; const ascending: boolean; const max_count, skipfirst: NativeInt; const min_val_is_a_prefix: boolean);
var   ix        : NativeInt;
      idx       : TFRE_DB_MM_Index;
      valf      : IFRE_DB_Field;
      keymin    : Array [0..CFREA_maxKeyLen] of Byte;
      keymax    : Array [0..CFREA_maxKeyLen] of Byte;
      keyminp   : PByte;
      keymaxp   : PByte;
      keylenmin : NativeInt;
      keylenmax : NativeInt;
      ix_type   : TFRE_DB_INDEX_TYPE;
      ix_t_mi   : TFRE_DB_INDEX_TYPE;
      ix_t_ma   : TFRE_DB_INDEX_TYPE;
      domf      : IFRE_DB_Field;

begin
  ix := IndexExists(index_name);
  if ix=-1 then
    raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the index named[%s] does not exist',[index_name]);
  idx      := FIndexStore[ix];
  if min_val_is_a_prefix then
    begin
      E_FOS_Implement;
    end;
  ix_t_mi    := FREDB_GetIndexTypeFromObjectEncoding(min);
  ix_t_ma    := FREDB_GetIndexTypeFromObjectEncoding(max);
  if (ix_t_mi=fdbit_SpecialValue) and (ix_t_ma=fdbit_SpecialValue) then
    begin { all indexed values }
      if idx.IsDomainIndex then
        begin
          domf := FREDB_GetDomainIDFldValFromObjectEncoding(min); {domain id must be encoded in minimum field }
          idx.AppendAllIndexedUidsDomain(uids,ascending,max_count,skipfirst,domf.Implementor as TFRE_DB_FIELD);
        end
      else
        idx.AppendAllIndexedUids(uids,ascending,max_count,skipfirst);
      exit;
    end
  else
  if (ix_t_mi=fdbit_SpecialValue) then
    begin
      if not idx.SupportsIndexType(ix_t_ma) then
        raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the index named[%s] does not support the requested index type[%s], but index type[%s]',[index_name,CFRE_DB_INDEX_TYPE[ix_t_ma],idx.IndexTypeTxt]);
      if idx.IsDomainIndex then
        begin
          E_FOS_Implement;
        end
      else
        begin
          valf    := FREDB_GetIndexFldValFromObjectEncoding(max);
          idx.TransformToBinaryComparable(valf.Implementor as TFRE_DB_FIELD,@keymax,keylenmax);
          keyminp := nil; { from minimum key range }
          keymaxp := @keymax[0];
        end;
    end
  else
  if (ix_t_ma=fdbit_SpecialValue) then
    begin
      if not idx.SupportsIndexType(ix_t_mi) then
        raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the index named[%s] does not support the requested index type[%s], but index type[%s]',[index_name,CFRE_DB_INDEX_TYPE[ix_t_mi],idx.IndexTypeTxt]);
      if idx.IsDomainIndex then
        begin
          E_FOS_Implement;
        end
      else
        begin
          valf    := FREDB_GetIndexFldValFromObjectEncoding(min);
          idx.TransformToBinaryComparable(valf.Implementor as TFRE_DB_FIELD,@keymin,keylenmin);
          keymaxp := nil; { to maximum key range }
          keyminp := @keymin[0];
        end;
    end
  else
    begin
      if ix_t_ma<>ix_t_mi then
        raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the requested index type[%s] for minvalue range scan is different than the  maxvalue  index type[%s]',[CFRE_DB_INDEX_TYPE[ix_t_mi],CFRE_DB_INDEX_TYPE[ix_t_ma]]);
      if not idx.SupportsIndexType(ix_t_ma) then
        raise EFRE_DB_PL_Exception.Create(edb_NOT_FOUND,'the index named[%s] does not support the requested index type[%s], but index type[%s]',[index_name,CFRE_DB_INDEX_TYPE[ix_t_ma],idx.IndexTypeTxt]);
      if idx.IsDomainIndex then
        begin
          E_FOS_Implement;
        end
      else
        begin
          valf    := FREDB_GetIndexFldValFromObjectEncoding(min);
          idx.TransformToBinaryComparable(valf.Implementor as TFRE_DB_FIELD,@keymin,keylenmin);
          keyminp := @keymin[0];
          valf    := FREDB_GetIndexFldValFromObjectEncoding(max);
          idx.TransformToBinaryComparable(valf.Implementor as TFRE_DB_FIELD,@keymax,keylenmax);
          keymaxp := @keymax[0];
        end;
    end;
  idx.ForAllIndexedValsTransformedKeys(uids,keyminp,keymaxp,keylenmin,keylenmax,ascending,max_count,skipfirst);
end;


function TFRE_DB_Persistance_Collection.GetIndexedValueCountRC(const qry_val: IFRE_DB_Object; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
var i    : NativeInt;
    uids : TFRE_DB_GUIDArray;
    uti  : TFRE_DB_USER_RIGHT_TOKEN;
    err  : TFRE_DB_Errortype;
    obj  : TFRE_DB_Object;
begin
  G_GetUserToken(user_context,uti,true);
  FREDB_SetUserDomIDFldValForObjectEncoding(qry_val,uti);
  GetAllIndexedUidsEncodedField(qry_val,index_name,uids,false);
  if not assigned(uti) then
    result := Length(uids)
  else
    begin
      result := 0;
      for i := 0 to high(uids) do
        begin
          if not FetchIntFromCollO(uids[i],obj) then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch collection object while evaluating index value count');
          err := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH]);
          if err=edb_OK then
            inc(Result);
        end;
    end;
end;


function TFRE_DB_Persistance_Collection.GetIndexedUidsRC(const qry_val: IFRE_DB_Object; out uids_out: TFRE_DB_GUIDArray; const index_must_be_fullyunique: boolean; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
var i        : NativeInt;
    uids     : TFRE_DB_GUIDArray;
    uti      : TFRE_DB_USER_RIGHT_TOKEN;
    err      : TFRE_DB_Errortype;
    obj      : TFRE_DB_Object;
begin
  G_GetUserToken(user_context,uti,true);
  FREDB_SetUserDomIDFldValForObjectEncoding(qry_val,uti);
  GetAllIndexedUidsEncodedField(qry_val,index_name,uids,index_must_be_fullyunique);
  if not assigned(uti) then
    begin
      uids_out := uids;
    end
  else
    begin
      result := 0;
      SetLength(uids_out,length(uids));
      for i := 0 to high(uids) do
        begin
          if not FetchIntFromCollO(uids[i],obj) then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch collection object while evaluating index value count');
          err := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH]);
          if err=edb_OK then
            begin
              uids_out[result] := uids[i];
              inc(Result);
            end;
        end;
      SetLength(uids_out,result);
    end;
  result := Length(uids_out);
end;

function TFRE_DB_Persistance_Collection.GetIndexedObjsClonedRC(const qry_val: IFRE_DB_Object; out objs: IFRE_DB_ObjectArray; const index_must_be_fullyunique: boolean; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
var i        : NativeInt;
    uids     : TFRE_DB_GUIDArray;
    uti      : TFRE_DB_USER_RIGHT_TOKEN;
    err      : TFRE_DB_Errortype;
    obj      : TFRE_DB_Object;

begin
  G_GetUserToken(user_context,uti,true);
  FREDB_SetUserDomIDFldValForObjectEncoding(qry_val,uti);
  GetAllIndexedUidsEncodedField(qry_val,index_name,uids,index_must_be_fullyunique);
  result := 0;
  SetLength(objs,length(uids));
  for i := 0 to high(uids) do
    begin
      if not FetchIntFromCollO(uids[i],obj) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch collection object while evaluating index value count');
      if assigned(uti) then
        err := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH])
      else
        err := edb_OK;
      if err=edb_OK then
        begin
          objs[result] := CloneOutObject(obj);
          inc(Result);
        end;
    end;
  SetLength(objs,result);
end;

function TFRE_DB_Persistance_Collection.GetIndexedValuecountRCRange(const min, max: IFRE_DB_Object; const ascending: boolean; const max_count, skipfirst: NativeInt; const min_val_is_a_prefix: boolean; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
var i     : NativeInt;
    uids  : TFRE_DB_GUIDArray;
    uti   : TFRE_DB_USER_RIGHT_TOKEN;
    err   : TFRE_DB_Errortype;
    obj   : TFRE_DB_Object;
begin
  G_GetUserToken(user_context,uti,true);
  FREDB_SetUserDomIDFldValForObjectEncoding(min,uti);
  GetAllIndexedUidsEncFieldRange(min,max,index_name,uids,ascending,max_count,skipfirst,min_val_is_a_prefix);
  if not assigned(uti) then
    result := Length(uids)
  else
    begin
      result := 0;
      for i := 0 to high(uids) do
        begin
          if not FetchIntFromCollO(uids[i],obj) then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch collection object while evaluating index value count');
          err := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH]);
          if err=edb_OK then
            inc(Result);
        end;
    end;
end;

function TFRE_DB_Persistance_Collection.GetIndexedUidsRCRange(const min, max: IFRE_DB_Object; const ascending: boolean; const max_count, skipfirst: NativeInt; out uids_out: TFRE_DB_GUIDArray; const min_val_is_a_prefix: boolean; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
var i        : NativeInt;
    uids     : TFRE_DB_GUIDArray;
    uti      : TFRE_DB_USER_RIGHT_TOKEN;
    err      : TFRE_DB_Errortype;
    obj      : TFRE_DB_Object;
begin
  G_GetUserToken(user_context,uti,true);
  FREDB_SetUserDomIDFldValForObjectEncoding(min,uti);
  GetAllIndexedUidsEncFieldRange(min,max,index_name,uids,ascending,max_count,skipfirst,min_val_is_a_prefix);
  if not assigned(uti) then
    begin
      uids_out := uids;
    end
  else
    begin
      result := 0;
      SetLength(uids_out,length(uids));
      for i := 0 to high(uids) do
        begin
          if not FetchIntFromCollO(uids[i],obj) then
            raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch collection object while evaluating index value count');
          err := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH]);
          if err=edb_OK then
            begin
              inc(Result);
              uids_out[result] := uids[i];
            end;
        end;
      SetLength(uids_out,result);
    end;
end;

function TFRE_DB_Persistance_Collection.GetIndexedObjsClonedRCRange(const min, max: IFRE_DB_Object; const ascending: boolean; const max_count, skipfirst: NativeInt; out objs: IFRE_DB_ObjectArray; const min_val_is_a_prefix: boolean; const index_name: TFRE_DB_NameType; const user_context: PFRE_DB_GUID): NativeInt;
var i        : NativeInt;
    uids     : TFRE_DB_GUIDArray;
    uti      : TFRE_DB_USER_RIGHT_TOKEN;
    err      : TFRE_DB_Errortype;
    obj      : TFRE_DB_Object;

begin
  G_GetUserToken(user_context,uti,true);
  FREDB_SetUserDomIDFldValForObjectEncoding(min,uti);
  GetAllIndexedUidsEncFieldRange(min,max,index_name,uids,ascending,max_count,skipfirst,min_val_is_a_prefix);
  result := 0;
  SetLength(objs,length(uids));
  for i := 0 to high(uids) do
    begin
      if not FetchIntFromCollO(uids[i],obj) then
        raise EFRE_DB_PL_Exception.Create(edb_INTERNAL,'could not fetch collection object while evaluating index value count');
      if assigned(uti) then
        err := uti.CheckStdRightsetInternalObj(obj,[sr_FETCH])
      else
        err := edb_OK;
      if err=edb_OK then
        begin
          obj.Set_Store_Locked(false);
          try
            objs[result] := obj.CloneToNewObject;
            inc(Result);
          finally
            obj.Set_Store_Locked(true);
          end;
        end;
    end;
  SetLength(objs,result);
end;

function TFRE_DB_Persistance_Collection.GetFirstLastIdxCnt(const idx: Nativeint; out obj: IFRE_DB_Object; const user_context: PFRE_DB_GUID): NativeInt;
var objs : IFRE_DB_ObjectArray;
    halt : boolean;

    procedure MyGet(const myobj:TFRE_DB_Object; var halt:boolean);
    begin
      obj := CloneOutObject(myobj);
    end;

begin
  result := 0;
  obj    := nil;
  case idx of
    -1 : { First}
        begin
          halt := true;
          ForAllInternalBreak(@MyGet,halt,false);
        end;
    -2 : { Last }
        begin
          halt := true;
          ForAllInternalBreak(@MyGet,halt,true);
        end;
    -3 : { Cnt}
        begin
          GetAllObjectsRCInt(objs,user_context);
          result := Length(objs);
        end;
    else
      begin
        if idx<0 then
          raise EFRE_DB_PL_Exception.Create(edb_ERROR,'you must use an positive index on getfirstlastidxcnt');
        GetAllObjectsRCInt(objs,user_context);
        result :=  Length(objs);
        if idx > high(objs) then
          raise EFRE_DB_PL_Exception.Create(edb_INDEXOUTOFBOUNDS,'you must use an index in the range of [%d - %d]',[0,high(objs)]);
        obj := CloneOutObject(objs[idx].Implementor as TFRE_DB_Object);
      end;
  end;
end;

procedure TFRE_DB_Persistance_Collection.GetAllUIDsRC(var uids: TFRE_DB_GUIDArray; const user_context: PFRE_DB_GUID);
var cnt : NativeInt;
    ut  : TFRE_DB_USER_RIGHT_TOKEN;

   procedure GatherWithRights(const obj : TFRE_DB_Object);
   begin
     if ut.CheckStdRightSetUIDAndClass(obj.UID,obj.DomainID,obj.SchemeClass,[sr_FETCH])=edb_OK then
       begin
         uids[cnt] := obj.UID;
         inc(cnt);
       end;
   end;

begin
  if not assigned(user_context) then
     GetAllUIDS(uids)
  else
    begin
      G_GetUserToken(user_context,ut,true);
      SetLength(uids,Count);
      cnt := 0;
      ForAllInternal(@GatherWithRights);
      SetLength(uids,cnt);
    end;
end;

procedure TFRE_DB_Persistance_Collection.GetAllObjectsRCInt(var objs: IFRE_DB_ObjectArray; const user_context: PFRE_DB_GUID);
var cnt : NativeInt;
    ut  : TFRE_DB_USER_RIGHT_TOKEN;

   procedure GatherWithRights(const obj : TFRE_DB_Object);
   begin
     if ut.CheckStdRightSetUIDAndClass(obj.UID,obj.DomainID,obj.SchemeClass,[sr_FETCH])=edb_OK then
       begin
         objs[cnt] := obj;
         inc(cnt);
       end;
   end;

begin
  if not assigned(user_context) then
     GetAllObjectsInt(objs)
  else
    begin
      G_GetUserToken(user_context,ut,true);
      SetLength(objs,Count);
      cnt := 0;
      ForAllInternal(@GatherWithRights);
      SetLength(objs,cnt);
    end;
end;

procedure TFRE_DB_Persistance_Collection.GetAllObjectsRC(var objs: IFRE_DB_ObjectArray; const user_context: PFRE_DB_GUID);
var iobjs : IFRE_DB_ObjectArray;
begin
  GetAllObjectsRCInt(iobjs,user_context);
  objs := CloneOutArrayII(iobjs);
end;


function TFRE_DB_Persistance_Collection.UniqueName: PFRE_DB_NameType;
begin
  UniqueName := @FUpperName;
end;


initialization

end.
