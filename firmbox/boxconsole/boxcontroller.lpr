program boxcontroller;

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


uses
  //cmem,
  cthreads,
  Classes, SysUtils, CustApp,
  FRE_SYSTEM,
  FOS_DEFAULT_IMPLEMENTATION,
  //FRE_DB_INTERFACE,
  //FRE_DB_CORE,
  //FRE_DB_EMBEDDED_IMPL,
  //FRE_CONFIGURATION,
  fos_fbcontroller_feedclient,
  fos_firmbox_svcctrl,
  fre_basefeed_app;


{$I fos_version_helper.inc}


  // Domain 1 'c90575128043469fcdef1908878fca7b'
  // Domain 2 '789957815850feb6b7dc9965ad47bf67'
  // Zone 1d1 '86f9c62a7bed960f34b49ad54ec1df22'
  // Zone 2d1 'fca7f31695298e3de211961300f4437e'
  // Zone 1d2 '96f9c62a7bed960f34b49ad54ec1df23'
  // Zone 2d2 'eca7f31695298e3de211961300f4437f'


type

  { TFRE_BOXCONTROLLER_FEED }

  TFRE_BOXCONTROLLER_FEED = class(TFRE_BASEDATA_FEED)
  private
  public
    procedure            MyRunMethod; override;
    procedure            WriteVersion; override;
  end;

procedure TFRE_BOXCONTROLLER_FEED.MyRunMethod;
begin
  inherited MyRunMethod;
end;

procedure TFRE_BOXCONTROLLER_FEED.WriteVersion;
begin
  writeln(GFOS_VHELP_GET_VERSION_STRING);
end;

var
  Application : TFRE_BOXCONTROLLER_FEED;

begin
  writeln('BOXCONTROLLER TEST');
  Application:=TFRE_BOXCONTROLLER_FEED.Create(nil,TFRE_BOXCONTROLLER_FEED_CLIENT.Create);
  Application.Run;
  Application.Free;
end.

