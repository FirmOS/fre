program fre_testdatafeed;

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

// ./fre_testdatafeed -U root -H 10.220.251.10 -u feeder@system -p a1234
// ./fre_testdatafeed -U root -H 10.1.0.116 -u feeder@system -p a1234

// -u mfeeder@system -p mighty
// lazarus+debugger: => ./fre_testdatafeed -U root -H 10.220.251.10

uses
  cmem,
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,
  FRE_SYSTEM,FOS_DEFAULT_IMPLEMENTATION,FOS_TOOL_INTERFACES,FOS_FCOM_TYPES,FRE_APS_INTERFACE,FRE_DB_INTERFACE,
  FRE_DB_CORE,

  FRE_DB_EMBEDDED_IMPL,
  FRE_CONFIGURATION,FRE_BASE_SERVER,
  fre_base_client, fos_firmboxfeed_client,fre_basefeed_app;


{$I fos_version_helper.inc}


type


  TFRE_FIRMBOX_FEED = class(TFRE_BASEDATA_FEED)
  end;


var
  Application : TFRE_FIRMBOX_FEED;


begin
  Application:=TFRE_FIRMBOX_FEED.Create(nil,TFRE_BOX_FEED_CLIENT.Create);
  Application.Run;
  Application.Free;
end.
