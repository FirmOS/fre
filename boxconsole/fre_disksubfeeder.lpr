program fre_disksubfeeder;

{
(§LIC)
  (c) Autor,Copyright
      Dipl.Ing.- Helmut Hartl, Dipl.Ing.- Franz Schober, Dipl.Ing.- Christian Koch
      FirmOS Business Solutions GmbH
      www.openfirmos.org
      New Style BSD Licence (OSI)

  Copyright (c) 2001-2009, FirmOS Business Solutions GmbH
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
{$LIBRARYPATH ../../lib}
{$LINKLIB umem}

uses
  //cmem,
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils,
  fre_libevent_core,
  fre_system,
  fre_fcom_ssl,
  fre_aps_comm_impl,
  fre_disksubfeed_client,
  fre_basedbo_server,
  fre_basesubfeed_app;


{$I fos_version_helper.inc}


type
  { TFRE_Testserver }

  { TFRE_DISKSUB_FEED }

  TFRE_DISKSUB_FEED = class(TFRE_BASESUBDATA_FEED)
    procedure TestMethod; override;
    procedure WriteVersion; override;
  end;

  { TFRE_Testserver }
var
  Application : TFRE_DISKSUB_FEED;

{ TFRE_TESTDATA_FEED }

procedure TFRE_DISKSUB_FEED.TestMethod;
begin
  writeln('PUNCHING AN UNFREED STRINGLIST INTO THE MEM FOR HEAPTRACE CHECK');
  TStringList.Create;
end;

procedure TFRE_DISKSUB_FEED.WriteVersion;
begin
  writeln(GFOS_VHELP_GET_VERSION_STRING);
end;

  {
    DEBUG Leaks using libumem
    LD_PRELOAD=libumem.so
    UMEM_DEBUG=default,verbose
    mdb ./fre_disksubfeeder -o follow_fork_mode=parent
    ::sybp _exit
    ::findleaks
  }

{ TTestThread }

begin
  cAPSC_JACK_TIMEOUT := 5*60000;
  Application:=TFRE_DISKSUB_FEED.Create(nil,TFRE_DISKSUB_FEED_SERVER.Create);
  Application.Run;
  Application.Free;
end.

