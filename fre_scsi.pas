unit fre_scsi;

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
{$codepage UTF8}
{$modeswitch nestedprocvars}

interface

uses
  Classes, SysUtils,FRE_DB_INTERFACE, FRE_DB_COMMON, FRE_PROCESS, FOS_BASIS_TOOLS,
  FOS_TOOL_INTERFACES,fre_zfs,fre_system;


// ./sas2ircu 0 DISPLAY

//Device is a Hard disk
//  Enclosure #                             : 2
//  Slot #                                  : 0
//  SAS Address                             : 5003048-0-01ab-cc6c
//  State                                   : Ready (RDY)
//  Size (in MB)/(in sectors)               : 122104/250069679
//  Manufacturer                            : ATA
//  Model Number                            : Samsung SSD 840
//  Firmware Revision                       : 4B0Q
//  Serial No                               : S12PNEAD204359F
//  GUID                                    : 50025385501cb30c
//  Protocol                                : SATA
//  Drive Type                              : SATA_SSD
//
//Device is a Enclosure services device
//  Enclosure #                             : 2
//  Slot #                                  : 0
//  SAS Address                             : 5003048-0-01ab-cc7d
//  State                                   : Standby (SBY)
//  Manufacturer                            : LSI CORP
//  Model Number                            : SAS2X28
//  Firmware Revision                       : 0717
//  Serial No                               : x36557230
//  GUID                                    : N/A
//  Protocol                                : SAS
//  Device Type                             : Enclosure services device
//
//Device is a Hard disk
//  Enclosure #                             : 2
//  Slot #                                  : 1
//  SAS Address                             : 5003048-0-01ab-cc6d
//  State                                   : Ready (RDY)
//  Size (in MB)/(in sectors)               : 244198/500118191
//  Manufacturer                            : ATA
//  Model Number                            : Samsung SSD 840
//  Firmware Revision                       : 4B0Q
//  Serial No                               : S12RNEACC94641Y
//  GUID                                    : 500253855015d44d
//  Protocol                                : SATA
//  Drive Type                              : SATA_SSD
//
//Device is a Hard disk
//  Enclosure #                             : 2
//  Slot #                                  : 4
//  SAS Address                             : 5000c50-0-562c-2495
//  State                                   : Ready (RDY)
//  Size (in MB)/(in sectors)               : 953869/1953525167
//  Manufacturer                            : SEAGATE
//  Model Number                            : ST1000NM0001
//  Firmware Revision                       : 0002
//  Serial No                               : Z1N3RMMG
//  GUID                                    : 5000c500562c2497
//  Protocol                                : SAS
//  Drive Type                              : SAS_HDD

//fmtopo -V
//hc://:product-id=LSI-CORP-SAS2X28:server-id=:chassis-id=5003048001abcc7f:serial=Z1N3RMMG0000C3310LYW:part=SEAGATE-ST1000NM0001:revision=0002/ses-enclosure=0/bay=4/disk=0
//  group: protocol                       version: 1   stability: Private/Private
//    resource          fmri      hc://:product-id=LSI-CORP-SAS2X28:server-id=:chassis-id=5003048001abcc7f:serial=Z1N3RMMG0000C3310LYW:part=SEAGATE-ST1000NM0001:revision=0002/ses-enclosure=0/bay=4/disk=0
//    label             string    Slot 05
//    FRU               fmri      hc://:product-id=LSI-CORP-SAS2X28:server-id=:chassis-id=5003048001abcc7f:serial=Z1N3RMMG0000C3310LYW:part=SEAGATE-ST1000NM0001:revision=0002/ses-enclosure=0/bay=4/disk=0
//    ASRU              fmri      dev:///:devid=id1,sd@n5000c500562c2497//scsi_vhci/disk@g5000c500562c2497
//  group: authority                      version: 1   stability: Private/Private
//    product-id        string    LSI-CORP-SAS2X28
//    chassis-id        string    5003048001abcc7f
//    server-id         string
//  group: storage                        version: 1   stability: Private/Private
//    logical-disk      string    c0t5000C500562C2497d0
//    manufacturer      string    SEAGATE
//    model             string    ST1000NM0001
//    serial-number     string    Z1N3RMMG0000C3310LYW
//    firmware-revision string    0002
//    capacity-in-bytes string    1000204886016
//    target-port-l0ids string[]  [ "w5000c500562c2495" "w5000c500562c2496" ]
//  group: io                             version: 1   stability: Private/Private
//    devfs-path        string    /scsi_vhci/disk@g5000c500562c2497
//    devid             string    id1,sd@n5000c500562c2497
//    phys-path         string[]  [ "/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f/disk@w5000c500562c2495,0" "/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0/disk@w5000c500562c2496,0" ]
//
//

// cfgadm -alv
//c2                             connected    configured   unknown
//unavailable  scsi-sas     n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi
//c2::es/ses0                    connected    configured   unknown    LSI CORP SAS2X28
//unavailable  ESI          n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::es/ses0
//c2::w50025385501cb30c,0        connected    configured   unknown    Client Device: /dev/dsk/c0t50025385501CB30Cd0s0(sd12)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w50025385501cb30c,0
//c2::w5000c500562a02e1,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A02E3d0s0(sd1)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a02e1,0
//c2::w5000c500562a02e9,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A02EBd0s0(sd10)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a02e9,0
//c2::w5000c500562a15f9,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A15FBd0s0(sd7)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a15f9,0
//c2::w5000c500562a015d,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A015Fd0s0(sd13)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a015d,0
//c2::w5000c500562a0235,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A0237d0s0(sd4)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a0235,0
//c2::w5000c500562a0299,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A029Bd0s0(sd8)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a0299,0
//c2::w5000c500562a0329,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A032Bd0s0(sd11)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a0329,0
//c2::w5000c500562a0641,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A0643d0s0(sd3)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562a0641,0
//c2::w5000c500562c1b09,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C1B0Bd0s0(sd9)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562c1b09,0
//c2::w5000c500562c17d1,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C17D3d0s0(sd2)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562c17d1,0
//c2::w5000c500562c1825,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C1827d0s0(sd5)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562c1825,0
//c2::w5000c500562c2495,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C2497d0s0(sd6)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w5000c500562c2495,0
//c2::w500253855015d44d,0        connected    configured   unknown    Client Device: /dev/dsk/c0t500253855015D44Dd0s0(sd14)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f:scsi::w500253855015d44d,0
//c3                             connected    configured   unknown
//unavailable  scsi-sas     n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi
//c3::es/ses1                    connected    configured   unknown    LSI CORP SAS2X28
//unavailable  ESI          n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::es/ses1
//c3::w5000c500562a02e2,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A02E3d0s0(sd1)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a02e2,0
//c3::w5000c500562a02ea,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A02EBd0s0(sd10)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a02ea,0
//c3::w5000c500562a015e,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A015Fd0s0(sd13)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a015e,0
//c3::w5000c500562a15fa,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A15FBd0s0(sd7)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a15fa,0
//c3::w5000c500562a029a,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A029Bd0s0(sd8)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a029a,0
//c3::w5000c500562a032a,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A032Bd0s0(sd11)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a032a,0
//c3::w5000c500562a0236,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A0237d0s0(sd4)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a0236,0
//c3::w5000c500562a0642,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562A0643d0s0(sd3)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562a0642,0
//c3::w5000c500562c1b0a,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C1B0Bd0s0(sd9)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562c1b0a,0
//c3::w5000c500562c17d2,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C17D3d0s0(sd2)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562c17d2,0
//c3::w5000c500562c1826,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C1827d0s0(sd5)
//unavailable  disk-path    n        /devices/pci@0,0/pci8086,3c0a@3,2/pci1000,3020@0/iport@f0:scsi::w5000c500562c1826,0
//c3::w5000c500562c2496,0        connected    configured   unknown    Client Device: /dev/dsk/c0t5000C500562C2497d0s0(sd6)
//

//mpathadm show lu /dev/rdsk/c0t5000C500562A02E3d0s2
//Logical Unit:  /dev/rdsk/c0t5000C500562A02E3d0s2
//        mpath-support:  libmpscsi_vhci.so
//        Vendor:  SEAGATE
//        Product:  ST1000NM0001
//        Revision:  0002
//        Name Type:  unknown type
//        Name:  5000c500562a02e3
//        Asymmetric:  no
//        Current Load Balance:  none
//        Logical Unit Group ID:  NA
//        Auto Failback:  on
//        Auto Probing:  NA
//
//        Paths:
//                Initiator Port Name:  w500605b0055961c0
//                Target Port Name:  w5000c500562a02e1
//                Override Path:  NA
//                Path State:  OK
//                Disabled:  no
//
//                Initiator Port Name:  w500605b0055961c0
//                Target Port Name:  w5000c500562a02e2
//                Override Path:  NA
//                Path State:  OK
//                Disabled:  no
//
//        Target Ports:
//                Name:  w5000c500562a02e1
//                Relative ID:  0
//
//                Name:  w5000c500562a02e2
//                Relative ID:  0

var

   cSG3Inq : string = '/opt/local/sg3utils/bin/sg_inq';
   cSG3Ses : string = '/opt/local/sg3utils/bin/sg_ses';
   cSG3cap : string = '/opt/local/sg3utils/bin/sg_readcap';
   cMpathListLu : string = 'mpathadm';


type

  TFRE_DB_UNDEFINED_BLOCKDEVICE = class(TFRE_DB_ZFS_BLOCKDEVICE)   // devices from iostat without /dev/rdsk/*s2 entry
  end;


  { TFRE_DB_PHYS_DISK }

  TFRE_DB_PHYS_DISK=class(TFRE_DB_ZFS_BLOCKDEVICE)
  private
    function GetBlockSize: Uint16;
    function GetEnclosureUID: TGUID;
    function GetEnclosureNr: Uint16;
    function Getfw_revision: string;
    function Getmanufacturer: string;
    function Getmodel_number: string;
    function GetOperationalPathCount: Uint16;
    function GetParentInEnclosureUID: TGUID;
    function GetSlotNr: Uint16;
    function GetTotalPathCount: Uint16;
    function GetWWN: string;
    function Getserial_number: string;
    function GetSize_Sectors: UInt32;
    procedure SetBlockSize(AValue: Uint16);
    procedure SetEnclosureNr(AValue: Uint16);
    procedure SetEnclosureUID(AValue: TGUID);
    procedure Setfw_revision(AValue: string);
    procedure Setmanufacturer(AValue: string);
    procedure Setmodel_number(AValue: string);
    procedure SetOperationalPathCount(AValue: Uint16);
    procedure SetParentInEnclosureUID(AValue: TGUID);
    procedure SetSlotNr(AValue: Uint16);
    procedure SetTotalPathCount(AValue: Uint16);
    procedure SetWWN(AValue: string);
    procedure Setserial_number(AValue: string);
    procedure SetSize_Sectors(AValue: UInt32);
  protected
    class procedure RegisterSystemScheme        (const scheme : IFRE_DB_SCHEMEOBJECT); override;
    procedure _getLayoutCaption                 (const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
    procedure _getLayoutSubCaption              (const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
    procedure _getLayoutIcon                    (const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
    procedure _getSizeMB                        (const calcfieldsetter : IFRE_DB_CALCFIELD_SETTER); virtual;
    procedure _getCaption                       (const calcfieldsetter : IFRE_DB_CALCFIELD_SETTER); override;
  public
    function GetTargetPorts: TFRE_DB_StringArray;
    property WWN                                 : string read GetWWN write SetWWN;
    property Manufacturer                        : string read Getmanufacturer write Setmanufacturer;
    property Model_number                        : string read Getmodel_number write Setmodel_number;
    property Fw_revision                         : string read Getfw_revision write Setfw_revision;
    property Serial_number                       : string read Getserial_number write Setserial_number;
    property Size_Sectors                        : UInt32 read GetSize_Sectors write SetSize_Sectors;
    property ParentInEnclosureUID                : TGUID read GetParentInEnclosureUID write SetParentInEnclosureUID;
    property SlotNr                              : Uint16 read GetSlotNr write SetSlotNr;
    property EnclosureNr                         : Uint16 read GetEnclosureNr write SetEnclosureNr;
    property EnclosureUID                        : TGUID  read GetEnclosureUID write SetEnclosureUID;
    property BlockSize                           : Uint16 read GetBlockSize write SetBlockSize;
    property TotalPathCount                      : Uint16 read GetTotalPathCount write SetTotalPathCount;
    property OperationalPathCount                : Uint16 read GetOperationalPathCount write SetOperationalPathCount;
  end;

  { TFRE_DB_SATA_DISK }

  TFRE_DB_SATA_DISK=class(TFRE_DB_PHYS_DISK)
  public
    procedure SetTargetPort                     (const targetport_1:string);
  end;

  { TFRE_DB_SAS_DISK }

  TFRE_DB_SAS_DISK=class(TFRE_DB_PHYS_DISK)
  public
    procedure SetTargetPorts                    (const targetport_1:string; const targetport_2:string);
  end;

  { TFRE_DB_SAS_EXPANDER }

  TFRE_DB_SAS_EXPANDER=class(TFRE_DB_ObjectEx)
  private
    function  Getfw_revision: string;
    function  Getmanufacturer: string;
    function  Getmodel_number: string;
    function  GetDeviceIdentifier: TFRE_DB_String;
    function  GetParentInEnclosureUID: TGUID;
    procedure Setfw_revision(AValue: string);
    procedure Setmanufacturer(AValue: string);
    procedure Setmodel_number(AValue: string);
    procedure SetDeviceIdentifier(AValue: TFRE_DB_String);
    procedure SetParentInEnclosureUID(AValue: TGUID);
  public
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  public
    property  Model_number         : string read Getmodel_number write Setmodel_number;
    property  Manufacturer         : string read Getmanufacturer write Setmanufacturer;
    property  Fw_revision          : string read Getfw_revision write Setfw_revision;
    property  DeviceIdentifier     : TFRE_DB_String read getDeviceIdentifier write setDeviceIdentifier;
    property  ParentInEnclosureUID : TGUID read GetParentInEnclosureUID write SetParentInEnclosureUID;
  end;

  { TFRE_DB_DRIVESLOT }

  TFRE_DB_DRIVESLOT=class(TFRE_DB_ObjectEx)
  private
    function  GetDeviceIdentifier: TFRE_DB_String;
    function  GetEnclosureNr: Uint16;
    function  GetPortType: string;
    function  GetSlotNr    : UInt16;
    function  GetParentInEnclosureUID: TGUID;
    procedure setDeviceIdentifier(AValue: TFRE_DB_String);
    procedure SetEnclosureNr(AValue: Uint16);
    procedure SetParentInEnclosureUID(AValue: TGUID);
    procedure SetPortType(AValue: string);
    procedure SetSlotNr   (AValue: UInt16);
  public
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
  public
    procedure SetAttachedTo  (const port_nr:Byte; const AValue: string);
    procedure SetTargetPort  (const port_nr:Byte; const AValue: string);
    function  GetTargetPort  (const port_nr:Byte) : TFRE_DB_String;
    property  SlotNr: Uint16 read GetSlotNr write SetSlotNr;
    property  PortType             : string read GetPortType write SetPortType;
    property  DeviceIdentifier     : TFRE_DB_String read getDeviceIdentifier write setDeviceIdentifier;
    property  ParentInEnclosureUID : TGUID read GetParentInEnclosureUID write SetParentInEnclosureUID;
    property  EnclosureNr          : Uint16 read GetEnclosureNr write SetEnclosureNr;
  end;


  { TFRE_DB_ENCLOSURE }

  TFRE_DB_ENCLOSURE=class(TFRE_DB_ObjectEx)
  private
    function  getDeviceIdentifier               : TFRE_DB_String;
    function  GetDriveSlots                     : UInt16;
    function  GetEnclosureNr                    : Uint16;
    procedure setDeviceIdentifier               (AValue: TFRE_DB_String);
    procedure SetDriveSlots                     (AValue: UInt16);
    procedure SetEnclosureNr                    (AValue: Uint16);
  public
    class procedure InstallDBObjects            (const conn:IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType); override;
    class procedure RegisterSystemScheme        (const scheme : IFRE_DB_SCHEMEOBJECT); override;
  public
    procedure AddExpanderEmbedded               (const expander: TFRE_DB_SAS_Expander; const devicename: string='');
    procedure _getChildrenString                (const calcfieldsetter : IFRE_DB_CALCFIELD_SETTER);
    procedure _getLayoutCaption                 (const calcfieldsetter : IFRE_DB_CALCFIELD_SETTER);
    procedure _getLayoutSubcaption              (const calcfieldsetter : IFRE_DB_CALCFIELD_SETTER);
    procedure _getLayoutIcon                    (const calcfieldsetter : IFRE_DB_CALCFIELD_SETTER);
    function  GetDriveSlotEmbedded              (const slotnr:UInt16; out driveslot: TFRE_DB_DRIVESLOT):boolean;
    procedure AddDriveSlotEmbedded              (const slotnr:UInt16; const driveslot: TFRE_DB_DRIVESLOT);

    property  DeviceIdentifier : TFRE_DB_String read getDeviceIdentifier write setDeviceIdentifier;
    property  DriveSlots       : UInt16 read GetDriveSlots write SetDriveSlots;
    property  EnclosureNr      : Uint16 read GetEnclosureNr write SetEnclosureNr;
  end;

  { TFRE_DB_SCSI }

  TFRE_DB_SCSI = class (TFRE_DB_Multiprocess)
  private
    function        _SG3GetPage                        (const cmd:string;  out output:string;out error:string; const params : TFRE_DB_StringArray=nil):integer;
    function        _FileExistsLocalorRemote           (const filename:string) : boolean;

    function        getrdskDevices                     (const iostat_devices: IFRE_DB_Object): IFRE_DB_Object;
    function        getexpanderDevices                 : IFRE_DB_Object;
    function        SG3DiskInquiry                     (const devicepath : TFRE_DB_String; out disk: IFRE_DB_Object) : integer;
    function        SG3SESInquiry                      (const devicepath : TFRE_DB_String; var scsi_structure: IFRE_DB_Object) : integer;
  protected
    class procedure RegisterSystemScheme               (const scheme : IFRE_DB_SCHEMEOBJECT); override;
  public
    function        GetSG3DiskandEnclosureInformation  (const iostat_devices: IFRE_DB_Object; out error: string; out scsi_structure:IFRE_DB_Object) : integer;
    function        GetMpathAdmLUInformation           (out error: string; out mpathinfo:IFRE_DB_Object) : integer;

  end;

procedure Register_DB_Extensions;


implementation

{ TFRE_DB_SATA_DISK }

procedure TFRE_DB_SATA_DISK.SetTargetPort(const targetport_1: string);
begin
  Field('target_port').AsString:=targetport_1;
end;

{ TFRE_DB_ENCLOSURE }

function TFRE_DB_ENCLOSURE.getDeviceIdentifier: TFRE_DB_String;
begin
  result := Field('deviceIdentifier').AsString;
end;

function TFRE_DB_ENCLOSURE.GetDriveSlots: UInt16;
begin
  result := field('drive_slots').AsUInt16;
end;

function TFRE_DB_ENCLOSURE.GetEnclosureNr: Uint16;
begin
  Result:=Field('enclosurenr').AsUInt16;
end;

procedure TFRE_DB_ENCLOSURE.setDeviceIdentifier(AValue: TFRE_DB_String);
begin
  Field('deviceIdentifier').AsString := AValue;
end;

procedure TFRE_DB_ENCLOSURE.SetDriveSlots(AValue: UInt16);
begin
  field('drive_slots').AsUInt16 := avalue;
end;

procedure TFRE_DB_ENCLOSURE.SetEnclosureNr(AValue: Uint16);
begin
  Field('enclosurenr').AsUInt16 := AValue;
end;

class procedure TFRE_DB_ENCLOSURE.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;

class procedure TFRE_DB_ENCLOSURE.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddCalcSchemeField('children',fdbft_String,@_getChildrenString);
  scheme.AddCalcSchemeField('caption_layout',fdbft_String,@_getLayoutCaption);
  scheme.AddCalcSchemeField('subcaption_layout',fdbft_String,@_getLayoutSubcaption);
  scheme.AddCalcSchemeField('icon_layout',fdbft_String,@_getLayoutIcon);
end;

procedure TFRE_DB_ENCLOSURE._getChildrenString(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  calcfieldsetter.SetAsString('UNCHECKED');
end;

procedure TFRE_DB_ENCLOSURE._getLayoutCaption(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  calcfieldsetter.SetAsString('Enclosure '+inttostr(EnclosureNr)+' '+Field('subcaption_layout').asstring);
end;

procedure TFRE_DB_ENCLOSURE._getLayoutSubcaption(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  calcfieldsetter.SetAsString('ID:'+DeviceIdentifier+' Slots:'+inttostr(DriveSlots));
end;

procedure TFRE_DB_ENCLOSURE._getLayoutIcon(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  calcfieldsetter.SetAsString(FREDB_getThemedResource('images_apps/firmbox_storage/'+ClassName+'.png'));
end;

procedure TFRE_DB_ENCLOSURE.AddExpanderEmbedded(const expander: TFRE_DB_SAS_Expander;const devicename:string);
begin
  if devicename<>'' then
    expander.DeviceIdentifier:=DeviceIdentifier+'_'+devicename;
  if not FieldExists('expanders') then
    Field('expanders').AsObject:= GFRE_DBI.NewObject;
  Field('expanders').asObject.Field(expander.DeviceIdentifier).AsObject:=expander;
end;

function TFRE_DB_ENCLOSURE.GetDriveSlotEmbedded(const slotnr: UInt16; out driveslot: TFRE_DB_DRIVESLOT): boolean;
begin
  if not FieldExists('slots') then
    begin
      driveslot:=nil;
      exit(false);
    end;
  result:=Field('slots').asObject.FieldExists('slot'+inttostr(slotnr));
  if result then
    driveslot := Field('slots').AsObject.Field('slot'+inttostr(slotnr)).AsObject.Implementor_HC as TFRE_DB_DRIVESLOT
  else
    driveslot := nil;
end;

procedure TFRE_DB_ENCLOSURE.AddDriveSlotEmbedded(const slotnr: UInt16; const driveslot: TFRE_DB_DRIVESLOT);
begin
  driveslot.DeviceIdentifier:=DeviceIdentifier+'_slot'+inttostr(slotnr);
  if not FieldExists('slots') then
    Field('slots').AsObject:= GFRE_DBI.NewObject;
  driveslot.SlotNr       := slotnr;
  driveslot.EnclosureNr  := EnclosureNr;
  Field('slots').AsObject.Field('slot'+inttostr(slotnr)).AsObject:=driveslot;
end;

function TFRE_DB_SCSI._SG3GetPage(const cmd: string; out output: string; out error: string; const params: TFRE_DB_StringArray): integer;
var   proc        : TFRE_DB_Process;
begin
  ClearProcess;
  proc := TFRE_DB_Process.create;
  proc.SetupInput(cmd,params);
  AddProcess(proc);
  ExecuteMulti;
  output := proc.OutputToString;
  error  := proc.ErrorToString;
  result := proc.Field('exitstatus').AsInt32;
  ClearProcess;
end;

function TFRE_DB_SCSI._FileExistsLocalorRemote(const filename: string): boolean;
var   proc        : TFRE_DB_Process;
begin
  if FieldExists('remotehost') then
    begin
      ClearProcess;
      proc := TFRE_DB_Process.create;
      proc.SetupInput('test',TFRE_DB_StringArray.Create ('-e',filename));
      AddProcess(proc);
      ExecuteMulti;
      result := proc.Field('exitstatus').AsInt32=0;
   end
  else
    result := FileExists(filename);
end;


function TFRE_DB_SCSI.getrdskDevices(const iostat_devices: IFRE_DB_Object): IFRE_DB_Object;

  procedure _getDevices(const obj:IFRE_DB_Object);
  begin
    result.Field('device').AddString('/dev/rdsk/'+obj.Field('iodevicename').asstring+'s2');
  end;

begin
  result := GFRE_DBI.NewObject;
  iostat_devices.ForAllObjects(@_getdevices);
end;

function TFRE_DB_SCSI.getexpanderDevices: IFRE_DB_Object;
var sl : TStringList;
    i  : NativeInt;
    proc  : TFRE_DB_Process;
begin
//  if FieldExists('remotehost') then
//    begin
      result := GFRE_DBI.NewObject;
      ClearProcess;
      proc := TFRE_DB_Process.create;
      try
        proc.SetupInput('find',TFRE_DB_StringArray.Create ('/dev/es'));
        AddProcess(proc);
        ExecuteMulti;
        sl := TStringList.Create;
        try
          sl.Text:=TFRE_DB_Process (proc.Implementor_HC).OutputToString;
          for i:= 1 to sl.count-1 do
            begin
              result.Field('device').AddString(sl[i]);
            end;
        finally
          sl.Free;
        end;
      finally
        ClearProcess;
      end;
//    end
//  else
//    abort; //Implement local Find for devices
end;

function TFRE_DB_SCSI.SG3DiskInquiry(const devicepath: TFRE_DB_String; out disk: IFRE_DB_Object): integer;

type
  TFRE_DB_SCSI_DEVICEIDENTIFICATION_PARSE = (di_none,di_address_loc,di_target);
var
  sl          : TStringList;
  i           : NativeInt;
  s           : string;
  porti       : NativeInt;
  ports       : Array[1..2] of string;
  di_parse    : TFRE_DB_SCSI_DEVICEIDENTIFICATION_PARSE;
  devicename  : string;
  res         : integer;
  outstring   : string;
  errstring   : string;
  undefineddisk : TFRE_DB_UNDEFINED_BLOCKDEVICE;
  blocks_s    : string;
  blocksize_s : string;
  vendor      : string;
  model_number: string;
  fw_revision : string;
  serialnr    : string;
  devicetype  : string;

begin
//  writeln(devicepath);
  devicename := Copy(devicepath,11,length(devicepath));
  devicename := Copy(devicename,1,length(devicename)-2);
//  writeln(devicename);

  GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3DiskInquiry [%s]',[devicepath]);
  if not _FileExistsLocalorRemote(devicepath) then                      // devices from iostat without /dev/rdsk/*s2 entry
    begin
      GFRE_DBI.LogInfo(dblc_APPLICATION,'SG3DiskInquiry Undefined Blockdevice [%s]',[devicepath]);
      undefineddisk  := TFRE_DB_UNDEFINED_BLOCKDEVICE.CreateForDB;
      undefineddisk.DeviceName       := devicename;
      undefineddisk.DeviceIdentifier := devicename;
      disk := undefineddisk;
      exit(0);
    end;

  GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3GetPage: <default> [%s]',[devicepath]);

  res := _SG3GetPage(cSG3Inq,outstring,errstring,TFRE_DB_StringArray.Create (devicepath));
  if res=0 then
    begin
      sl := TStringList.Create;
      try
        sl.Text := outstring;
        for i:=0 to sl.count-1 do
         begin
           s:= sl[i];
           if Pos('Vendor identification',s)>0 then
             vendor       := trim(GFRE_BT.SepRight(s,':'));
           if Pos('Product identification',s)>0 then
             model_number := trim(GFRE_BT.SepRight(s,':'));
           if Pos('Product revision level',s)>0 then
             fw_revision  := trim(GFRE_BT.SepRight(s,':'));
           if Pos('Unit serial number',s)>0 then
             serialnr     := trim(GFRE_BT.SepRight(s,':'));
           if Pos('Peripheral device type',s)>0 then
             devicetype   := trim(GFRE_BT.SepRight(s,':'));
         end;
      finally
        sl.Free;
      end;
    end
  else
    begin
      disk   := nil;
      GFRE_DBI.LogError(dblc_APPLICATION,'SG3 Inquire for %s failed with resultcode %d, %s',[devicepath,res,errstring]);
      exit(res);
    end;

   if devicetype<>'disk' then
     begin
       GFRE_DBI.LogInfo(dblc_APPLICATION,'SG3DiskInquiry Type of device [%s] is not disk [%s]',[devicetype,devicepath]);
       undefineddisk  := TFRE_DB_UNDEFINED_BLOCKDEVICE.CreateForDB;
       undefineddisk.DeviceName       := devicename;
       undefineddisk.DeviceIdentifier := devicename;
       disk := undefineddisk;
       exit(0);
     end;

  if vendor='ATA' then
    begin
      GFRE_DBI.LogDebug(dblc_APPLICATION,'Vendor of device is %s [%s]',[vendor, devicepath]);
      disk  := GFRE_DBI.NewObjectScheme(TFRE_DB_SATA_DISK)
    end
  else
    begin
      GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3GetPage: 0x88 [%s]',[devicepath]);
      res := _SG3GetPage(cSG3Inq,outstring,errstring,TFRE_DB_StringArray.Create ('-p','0x88',devicepath));
      if res=0 then //SAS DISK
        begin
          disk  := GFRE_DBI.NewObjectScheme(TFRE_DB_SAS_DISK);
          porti := 0;
          sl := TStringList.Create;
          try
            sl.Text := outstring;
            for i:=0 to sl.count-1 do
             begin
               s:= sl[i];
               if Pos('Relative port=1',s)>0 then
                 porti := 1;
               if Pos('Relative port=2',s)>0 then
                 porti := 2;
               if Pos('Vendor Specific Identifier:',s)>0 then
                 begin
                   if porti>0 then
                     begin
                       s := sl[i+1];
                       ports[porti] := GFRE_BT.SepLeft(GFRE_BT.SepRight(s,'['),']');
                       porti :=0;
                     end;
                 end;
             end;
          finally
            sl.Free;
          end;
          (disk.Implementor_HC as TFRE_DB_SAS_DISK).SetTargetPorts(ports[1],ports[2]);
        end
      else
        begin
          disk   := nil;
          GFRE_DBI.LogError(dblc_APPLICATION,'SG3 Inquire for %s failed with resultcode %d, %s',[devicepath,res,errstring]);
          exit(res);
        end;
    end;

  (disk.Implementor_HC as TFRE_DB_PHYS_DISK).Setmanufacturer(vendor);
  (disk.Implementor_HC as TFRE_DB_PHYS_DISK).Setmodel_number(model_number);
  (disk.Implementor_HC as TFRE_DB_PHYS_DISK).Setfw_revision(fw_revision);
  (disk.Implementor_HC as TFRE_DB_PHYS_DISK).Setserial_number(serialnr);

  // get wwn
  GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3GetPage: di [%s]',[devicepath]);
  res := _SG3GetPage(cSG3Inq,outstring,errstring,TFRE_DB_StringArray.Create ('-p','di',devicepath));
  if res=0 then
    begin
      di_parse:=di_none;
      sl := TStringList.Create;
      try
        sl.Text := outstring;
        for i:=0 to sl.count-1 do
         begin
           s:= sl[i];
           if Pos('associated with the addressed logical unit',s)>0 then
             di_parse:=di_address_loc;
           if Pos('associated with the target port',s)>0 then
             di_parse:=di_target;
           if Pos('Vendor Specific Identifier:',s)>0 then
             begin
               case di_parse of
                 di_address_loc:
                   begin
                     s := sl[i+1];
                     (disk.Implementor_HC as TFRE_DB_PHYS_DISK).SetWWN(GFRE_BT.SepLeft(GFRE_BT.SepRight(s,'['),']'));
                   end;
                 di_target:
                   begin
                     if (disk.Implementor_HC is TFRE_DB_SATA_DISK) then
                       begin
                         s := sl[i+1];
                         (disk.Implementor_HC as TFRE_DB_SATA_DISK).SetTargetPort(GFRE_BT.SepLeft(GFRE_BT.SepRight(s,'['),']'));
                       end;
                   end;
               end;  //ignore others
               di_parse:=di_none;
             end;
         end;
      finally
        sl.Free;
      end;
    end
  else
    GFRE_DBI.LogError(dblc_APPLICATION,'SG3 Inquire for %s failed with resultcode %d, %s',[devicepath,res,errstring]);



  (disk.Implementor_HC as TFRE_DB_PHYS_DISK).DeviceName := devicename;

  if (disk.Implementor_HC as TFRE_DB_PHYS_DISK).DeviceIdentifier='' then          // no WWN
    (disk.Implementor_HC as TFRE_DB_PHYS_DISK).DeviceIdentifier:=devicename;

  GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3GetPage: cap [%s]',[devicepath]);

  res := _SG3GetPage(cSG3cap,outstring,errstring,TFRE_DB_StringArray.Create ('-l','-b',devicepath));
  if res=0 then
    begin
      s:=outstring;
      blocks_s    := trim(GFRE_BT.SepLeft(s,' '));
      blocksize_s := trim(GFRE_BT.SepRight(s,' '));
      (disk.Implementor_HC as TFRE_DB_PHYS_DISK).SetSize_Sectors(StrToInt(blocks_s));
      (disk.Implementor_HC as TFRE_DB_PHYS_DISK).SetBlockSize(StrToInt(blocksize_s));
    end
  else
    begin
      if Assigned(disk) then
        disk.Finalize;
      disk   := nil;
      GFRE_DBI.LogError(dblc_APPLICATION,'SG3 Readcap for %s failed with resultcode %d, %s',[devicepath,res,errstring]);
      exit(res);
    end;

  exit(0);
end;

function TFRE_DB_SCSI.SG3SESInquiry(const devicepath: TFRE_DB_String; var scsi_structure: IFRE_DB_Object): integer;
var
  sl             : TStringList;
  i              : NativeInt;
  s              : string;
  res            : integer;
  outstring      : string;
  errstring      : string;
  expander       : TFRE_DB_SAS_EXPANDER;
  enclosure      : TFRE_DB_ENCLOSURE;
  enclosure_id   : string;

  function _getOrCreateEnclosure(const enclosure_id:string):TFRE_DB_ENCLOSURE;
  var enclosures : IFRE_DB_Object;
      encnr      : UInt16;
  begin
    result     := nil;
    enclosures := scsi_structure.Field('enclosures').AsObject;
    if enclosures.FieldExists(enclosure_id) then
      exit(enclosures.Field(enclosure_id).AsObject.Implementor_HC as TFRE_DB_ENCLOSURE)
    else
      begin
        result := TFRE_DB_ENCLOSURE.Create;
        result.DeviceIdentifier:= enclosure_id;
        result.EnclosureNr     := enclosures.FieldCount(true)-2;
//        writeln('ENCLOSURE NR:',result.EnclosureNr);
        enclosures.Field(enclosure_id).AsObject:=result;
      end;
  end;

  procedure _AnalyzeDriveSlotInformation(const proc:TFRE_DB_Process);
  var i            : NativeInt;
      outstring    : string;
      errstring    : string;
      driveslot    : TFRE_DB_DRIVESLOT;
      port_nr      : integer;
      slotnr       : integer;
  begin
    outstring   := proc.OutputToString;
    errstring   := proc.ErrorToString;
    slotnr      := proc.Field('slotnr').AsUInt16;
    res         := proc.Field('exitstatus').AsInt32;
    if res=0 then
      begin
        if enclosure.GetDriveSlotEmbedded(slotnr,driveslot) then
          port_nr  := 2
        else
          begin
            driveslot        := TFRE_DB_DRIVESLOT.Create;
            enclosure.AddDriveSlotEmbedded(slotnr,driveslot);
            port_nr := 1;
          end;

        sl := TStringList.Create;
        try
          sl.Text := outstring;
          for i:=1 to sl.count-1 do
           begin
             s:= sl[i];
             if Pos('target port for',s)>0 then
                 driveslot.PortType:=trim(GFRE_BT.SepRight(s,':'));
             if Pos('attached SAS address',s)>0 then
               begin
                 driveslot.SetAttachedTo(port_nr,trim(GFRE_BT.SepRight(s,':')));
                 s:=sl[i+1];
                 driveslot.SetTargetPort(port_nr,trim(GFRE_BT.SepRight(s,':')));
               end;
           end;
//          writeln(driveslot.DumpToString());
        finally
          sl.Free;
        end;
      end
    else
      begin
        GFRE_DBI.LogError(dblc_APPLICATION,'SG3 Ses for %s, Slot %d failed with resultcode %d, %s',[devicepath,slotnr,res,errstring]);
        exit;
      end;
  end;

  procedure _GetDriveSlotInformation(const slotnr:NativeInt);
  var
    proc         : TFRE_DB_Process;
  begin
    GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3Ses: -I 0 [%d] -p aes [%s]',[slotnr,devicepath]);

    proc := TFRE_DB_Process.create;
    proc.SetupInput(cSG3Ses,TFRE_DB_StringArray.Create ('-I','0,'+inttostr(slotnr),'-p','aes',devicepath));
    proc.Field('slotnr').AsUInt16:=slotnr;
//    writeln('SWL:slot ',slotnr,' ',devicepath);
    AddProcess(proc);
  end;


begin

  // determine sas/sata, get target ports
//  writeln('SWL:',devicepath);
  GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3GetPage: cf [%s]',[devicepath]);

  res := _SG3GetPage(cSG3Ses,outstring,errstring,TFRE_DB_StringArray.Create ('-p','cf',devicepath));
  if res=0 then
    begin
      sl := TStringList.Create;
      try
        sl.Text := outstring;
        expander := TFRE_DB_SAS_EXPANDER.create;
        for i:=1 to sl.count-1 do
         begin
           s:= sl[i];
           if Pos('enclosure logical identifier',s)>0 then
             begin
               enclosure_id := trim(GFRE_BT.SepRight(s,':'));
               enclosure:=_getOrCreateEnclosure(enclosure_id);
               enclosure.AddExpanderEmbedded(expander,Copy(devicepath,Pos('ses',devicepath),maxint));
             end;
           if Pos('enclosure vendor',s)>0 then
             begin
               s := GFRE_BT.SepRight(s,':');
               expander.Manufacturer:=trim(GFRE_BT.SepLeft(s,'product'));
               s := GFRE_BT.SepRight(s,':');
               expander.Model_number:=trim(GFRE_BT.SepLeft(s,'rev'));
               s := GFRE_BT.SepRight(s,':');
               expander.Fw_revision:=trim(s);
             end;
           if Pos('Array device slot',s)>0 then
             begin
               s:= sl[i+1];
               enclosure.DriveSlots:=strtoint(trim(GFRE_BT.SepRight(s,':')));
             end;
         end;
      finally
        sl.Free;
      end;
    end
  else
    begin
      GFRE_DBI.LogError(dblc_APPLICATION,'SG3 Ses for %s failed with resultcode %d, %s',[devicepath,res,errstring]);
      exit;
    end;
//  writeln('SWL:ENCLO',enclosure.DumpToString());
  if assigned(enclosure) then
    begin
      for i:=0 to enclosure.DriveSlots-1 do
        begin
          ClearProcess;
          _GetDriveSlotInformation(i);
          ExecuteMulti;
          _AnalyzeDriveSlotInformation(GetProcess(0));
          ClearProcess;
        end;
    end;
end;

class procedure TFRE_DB_SCSI.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
end;


function TFRE_DB_SCSI.GetSG3DiskandEnclosureInformation(const iostat_devices: IFRE_DB_Object; out error: string; out scsi_structure: IFRE_DB_Object): integer;
var devices : IFRE_DB_Object;
    disk    : IFRE_DB_Object;
    i       : NativeInt;
begin
//  writeln('IOStat Devices:',iostat_devices.DumpToString());
  try
    cSG3Inq := cFRE_ToolsPath+'/sg3utils/bin/sg_inq';
    cSG3Ses := cFRE_ToolsPath+'/sg3utils/bin/sg_ses';
    cSG3cap := cFRE_ToolsPath+'/sg3utils/bin/sg_readcap';

  //  writeln('SG3INQ Program:',csg3inq);

    scsi_structure   := GFRE_DBI.NewObject;
    scsi_structure.Field('enclosures').asObject := GFRE_DBI.NewObject;
    scsi_structure.Field('disks').asObject      := GFRE_DBI.NewObject;
    devices := getexpanderDevices;
  //  writeln('ES :',devices.DumpToString());
    try
      for i := 0 to devices.Field('device').ValueCount-1 do
        begin
          SG3SESInquiry(devices.Field('device').AsStringItem[i],scsi_structure);
        end;
    finally
      devices.Finalize;
    end;
    devices := getrdskDevices(iostat_devices);
    try
      for i := 0 to devices.Field('device').ValueCount-1 do
        begin
          if SG3DiskInquiry(devices.Field('device').AsStringItem[i],disk)=0 then
            scsi_structure.Field('disks').asObject.Field(disk.Field('DEVICEIDENTIFIER').asstring).asobject:=disk;
        end;
    finally
      devices.Finalize;
    end;
  finally
    iostat_devices.Finalize;
  end;
  GFRE_DBI.LogDebug(dblc_APPLICATION,'SG3DiskandEnclosureInformation Done');
end;

function TFRE_DB_SCSI.GetMpathAdmLUInformation(out error: string; out mpathinfo: IFRE_DB_Object): integer;
var   proc        : TFRE_DB_Process;
      sl          : TStringList;
      s           : string;
      device      : string;
      i           : NativeInt;
      p           : NativeInt;
      tpathcount  : NativeInt;
      opathcount  : NativeInt;
      devobj      : IFRE_DB_Object;
begin
  ClearProcess;
  proc := TFRE_DB_Process.create;
  proc.SetupInput(cMpathListLu,TFRE_DB_StringArray.Create ('list','lu'));
  AddProcess(proc);
  ExecuteMulti;

  error  := proc.ErrorToString;
  result := proc.Field('exitstatus').AsInt32;
  mpathinfo := GFRE_DBI.NewObject;
  if result=0 then
    begin
      sl:=TStringList.Create;
      try
        sl.Text := proc.OutputToString;
        for i:=0 to sl.count-1 do
          begin
            s := sl[i];
            p := Pos('/dev/rdsk/',s);
            if p>0 then
              begin
                device := Copy(s,p+10,length(s));
                device := Copy(device,1,length(device)-2);
//                writeln('SWL: DEVICE:',device);
                if (i+1<sl.count) then
                  tpathcount:= strtoint(trim(GFRE_BT.SepRight(sl[i+1],':')))
                else
                  tpathcount:= 0;
                if (i+2<sl.count) then
                  opathcount:= strtoint(trim(GFRE_BT.SepRight(sl[i+2],':')))
                else
                  opathcount:= 0;
                devobj:=GFRE_DBI.NewObject;
                devobj.Field('device').asstring     := device;
                devobj.Field('tpathcount').AsUInt16 := tpathcount;
                devobj.Field('opathcount').AsUInt16 := opathcount;
                mpathinfo.Field(device).AsObject    := devobj;
              end;
          end;
      finally
        sl.Free;
      end;
  end;
end;

{ TFRE_DB_PHYS_DISK }

function TFRE_DB_PHYS_DISK.GetBlockSize: Uint16;
begin
  Result:=Field('blocksize').AsUint16;
end;

function TFRE_DB_PHYS_DISK.GetEnclosureUID: TGUID;
begin
  Result:=Field('enclosure_uid').AsObjectLink;
end;

function TFRE_DB_PHYS_DISK.GetEnclosureNr: Uint16;
begin
  Result:=Field('enclosurenr').AsUInt16;
end;

function TFRE_DB_PHYS_DISK.Getfw_revision: string;
begin
  result:=field('fw_revision').asstring;
end;

function TFRE_DB_PHYS_DISK.Getmanufacturer: string;
begin
  result:=field('manufacturer').asstring;
end;

function TFRE_DB_PHYS_DISK.Getmodel_number: string;
begin
  result:=field('model_number').asstring;
end;

function TFRE_DB_PHYS_DISK.GetOperationalPathCount: Uint16;
begin
  if FieldExists('operationalpathcount') then
    Result:=Field('operationalpathcount').AsUInt16
  else
    Result:=0;
end;

function TFRE_DB_PHYS_DISK.GetParentInEnclosureUID: TGUID;
begin
  Result:=Field('parent_in_enclosure_uid').AsObjectLink;
end;

function TFRE_DB_PHYS_DISK.GetSlotNr: Uint16;
begin
  if FieldExists('slotnr') then begin
    Result:=Field('slotnr').AsUInt16;
  end else begin
    Result:=0;
  end;
end;

function TFRE_DB_PHYS_DISK.GetTotalPathCount: Uint16;
begin
  if FieldExists('totalpathcount') then
    Result:=Field('totalpathcount').AsUInt16
  else
    Result:=0;
end;

function TFRE_DB_PHYS_DISK.GetWWN: string;
begin
  result:=getDeviceIdentifier;
end;

function TFRE_DB_PHYS_DISK.Getserial_number: string;
begin
  result:=field('serial_number').asstring;
end;

function TFRE_DB_PHYS_DISK.GetSize_Sectors: UInt32;
begin
  result := field('size_sectors').AsUInt32;
end;

procedure TFRE_DB_PHYS_DISK.SetBlockSize(AValue: Uint16);
begin
  Field('blocksize').AsUInt16:=AValue;
end;

procedure TFRE_DB_PHYS_DISK.SetEnclosureNr(AValue: Uint16);
begin
  Field('enclosurenr').AsUInt16:=AValue;
end;

procedure TFRE_DB_PHYS_DISK.SetEnclosureUID(AValue: TGUID);
begin
   Field('enclosure_uid').AsObjectLink:=AValue;
end;


procedure TFRE_DB_PHYS_DISK.Setfw_revision(AValue: string);
begin
  field('fw_revision').asstring := avalue;
end;

procedure TFRE_DB_PHYS_DISK.Setmanufacturer(AValue: string);
begin
  field('manufacturer').asstring := avalue;
end;

procedure TFRE_DB_PHYS_DISK.Setmodel_number(AValue: string);
begin
  field('model_number').asstring := avalue;
end;

procedure TFRE_DB_PHYS_DISK.SetOperationalPathCount(AValue: Uint16);
begin
  Field('operationalpathcount').AsUInt16:=AValue;
end;

procedure TFRE_DB_PHYS_DISK.SetParentInEnclosureUID(AValue: TGUID);
begin
  Field('parent_in_enclosure_uid').AsObjectLink:=Avalue;
end;

procedure TFRE_DB_PHYS_DISK.SetSlotNr(AValue: Uint16);
begin
  Field('slotnr').AsUInt16 := AValue;
end;

procedure TFRE_DB_PHYS_DISK.SetTotalPathCount(AValue: Uint16);
begin
  Field('totalpathcount').AsUInt16:=AValue;
end;


procedure TFRE_DB_PHYS_DISK.SetWWN(AValue: string);
begin
  setDeviceIdentifier(AValue);
end;

procedure TFRE_DB_PHYS_DISK.Setserial_number(AValue: string);
begin
  field('serial_number').asstring := avalue;
end;

procedure TFRE_DB_PHYS_DISK.SetSize_Sectors(AValue: UInt32);
begin
  field('size_sectors').AsUInt32 := AValue;
end;

procedure TFRE_DB_PHYS_DISK._getSizeMB(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  if FieldExists('blocksize') and FieldExists('size_sectors') then
    calcfieldsetter.SetAsUInt32(Uint64(Field('blocksize').AsUInt16*Field('size_sectors').AsUInt32) div 1000000)
  else
    calcfieldsetter.SetAsUInt32(0);
end;

procedure TFRE_DB_PHYS_DISK._getCaption(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
   calcfieldsetter.SetAsString('(' + IntToStr(SlotNr) + ')'+' '+WWN);
end;

class procedure TFRE_DB_PHYS_DISK.RegisterSystemScheme(const scheme: IFRE_DB_SCHEMEOBJECT);
begin
  inherited RegisterSystemScheme(scheme);
  scheme.AddCalcSchemeField('size_mb',fdbft_UInt32,@_getSizeMb);
  scheme.AddCalcSchemeField('caption_layout',fdbft_String,@_getLayoutCaption);
  scheme.AddCalcSchemeField('subcaption_layout',fdbft_String,@_getLayoutSubcaption);
  scheme.AddCalcSchemeField('icon_layout',fdbft_String,@_getLayoutIcon);
end;

procedure TFRE_DB_PHYS_DISK._getLayoutCaption(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  calcfieldsetter.SetAsString('(' + IntToStr(SlotNr) + ')'+inttostr(Field('size_mb').AsUint32)+' '+Field('subcaption_layout').asstring);
end;

procedure TFRE_DB_PHYS_DISK._getLayoutSubCaption(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  calcfieldsetter.SetAsString(Manufacturer+' '+Model_number+' '+Serial_number+' '+WWN+' ('+inttostr(OperationalPathCount)+'/'+inttostr(TotalPathCount)+')');
end;

procedure TFRE_DB_PHYS_DISK._getLayoutIcon(const calcfieldsetter: IFRE_DB_CALCFIELD_SETTER);
begin
  if getIsNew then begin
    calcfieldsetter.SetAsString(FREDB_getThemedResource('images_apps/firmbox_storage/'+ClassName+'_new.png'));
  end else begin
    if IsUnassigned then begin
      calcfieldsetter.SetAsString(FREDB_getThemedResource('images_apps/firmbox_storage/'+ClassName+'_unassigned.png'));
    end else begin
      calcfieldsetter.SetAsString(FREDB_getThemedResource('images_apps/firmbox_storage/'+ClassName+'.png'));
    end;
  end;
end;

function TFRE_DB_PHYS_DISK.GetTargetPorts: TFRE_DB_StringArray;
begin
  if fieldExists('target_port') then
    result := field('target_port').AsStringArr
  else
    result := TFRE_DB_StringArray.Create;
end;


{ TFRE_DB_SAS_DISK }

procedure TFRE_DB_SAS_DISK.SetTargetPorts(const targetport_1: string; const targetport_2: string);
begin
  Field('target_port').AsString:=targetport_1;
  Field('target_port').AddString(targetport_2);
end;

{ TFRE_DB_DRIVESLOT }

function TFRE_DB_DRIVESLOT.getDeviceIdentifier: TFRE_DB_String;
begin
  result := Field('deviceIdentifier').AsString;
end;

function TFRE_DB_DRIVESLOT.GetEnclosureNr: Uint16;
begin
  Result:=Field('enclosurenr').AsUInt16;
end;

function TFRE_DB_DRIVESLOT.GetPortType: string;
begin
  result:=Field('porttype').asstring;
end;

function TFRE_DB_DRIVESLOT.GetSlotNr: UInt16;
begin
  result := Field('slotnr').AsUInt16;
end;

function TFRE_DB_DRIVESLOT.GetParentInEnclosureUID: TGUID;
begin
  Result:=Field('parent_in_enclosure_uid').AsObjectLink;
end;

procedure TFRE_DB_DRIVESLOT.setDeviceIdentifier(AValue: TFRE_DB_String);
begin
  Field('deviceIdentifier').AsString:=AValue;
end;

procedure TFRE_DB_DRIVESLOT.SetEnclosureNr(AValue: Uint16);
begin
  Field('enclosurenr').AsUInt16:=AValue;
end;

procedure TFRE_DB_DRIVESLOT.SetParentInEnclosureUID(AValue: TGUID);
begin
  Field('parent_in_enclosure_uid').AsObjectLink:=AValue;
end;

procedure TFRE_DB_DRIVESLOT.SetPortType(AValue: string);
begin
  Field('porttype').asstring:=Avalue;
end;

procedure TFRE_DB_DRIVESLOT.SetSlotNr(AValue: UInt16);
begin
  Field('slotnr').AsUInt16:=Avalue;
end;

class procedure TFRE_DB_DRIVESLOT.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;

procedure TFRE_DB_DRIVESLOT.SetAttachedTo(const port_nr: Byte; const AValue: string);
begin
  Field('attached_to_'+inttostr(port_nr)).AsString := AValue;
end;

procedure TFRE_DB_DRIVESLOT.SetTargetPort(const port_nr: Byte; const AValue: string);
begin
  Field('targetport_'+inttostr(port_nr)).AsString := AValue;
end;

function TFRE_DB_DRIVESLOT.GetTargetPort(const port_nr: Byte): TFRE_DB_String;
begin
  result := Field('targetport_'+inttostr(port_nr)).AsString;
end;

{ TFRE_DB_SAS_EXPANDER }

function TFRE_DB_SAS_EXPANDER.Getfw_revision: string;
begin
  result:=field('fw_revision').asstring;
end;

function TFRE_DB_SAS_EXPANDER.Getmanufacturer: string;
begin
  result:=field('manufacturer').asstring;
end;

function TFRE_DB_SAS_EXPANDER.Getmodel_number: string;
begin
  result:=field('model_number').asstring;
end;

function TFRE_DB_SAS_EXPANDER.GetDeviceIdentifier: TFRE_DB_String;
begin
  result:=Field('deviceIdentifier').AsString;
end;

function TFRE_DB_SAS_EXPANDER.GetParentInEnclosureUID: TGUID;
begin
  Result:=Field('parent_in_enclosure_uid').AsObjectLink;
end;


procedure TFRE_DB_SAS_EXPANDER.Setfw_revision(AValue: string);
begin
  field('fw_revision').asstring := avalue;
end;

procedure TFRE_DB_SAS_EXPANDER.Setmanufacturer(AValue: string);
begin
  field('manufacturer').asstring := avalue;
end;

procedure TFRE_DB_SAS_EXPANDER.Setmodel_number(AValue: string);
begin
  field('model_number').asstring := avalue;
end;

procedure TFRE_DB_SAS_EXPANDER.SetDeviceIdentifier(AValue: TFRE_DB_String);
begin
  Field('deviceIdentifier').AsString:=AValue;
end;

procedure TFRE_DB_SAS_EXPANDER.SetParentInEnclosureUID(AValue: TGUID);
begin
  Field('parent_in_enclosure_uid').AsObjectLink:=AValue;
end;

class procedure TFRE_DB_SAS_EXPANDER.InstallDBObjects(const conn: IFRE_DB_SYS_CONNECTION; currentVersionId: TFRE_DB_NameType; var newVersionId: TFRE_DB_NameType);
begin
  newVersionId:='1.0';
end;

procedure Register_DB_Extensions;
begin
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_UNDEFINED_BLOCKDEVICE);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_PHYS_DISK);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_SAS_DISK);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_SATA_DISK);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_SAS_EXPANDER);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_DRIVESLOT);
  GFRE_DBI.RegisterObjectClassEx(TFRE_DB_ENCLOSURE);
  GFRE_DBI.Initialize_Extension_Objects;
end;


end.

