program boxconsole;

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
// lazarus+debugger: => ./fre_testdatafeed -U root -H 10.220.251.10 -D

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
  fos_firmboxfeed_client,fre_basefeed_app,
  fos_ncurses_core;


//const
  //cFrameBorder=Blue*16+Blue;
  //cMenuBack=Cyan;
  //cMenuFrame=Cyan;

  //private
  //  cBannerHeader        : string;
  //  cBannerVersion       : string;
  //  cBannerCopyright     : string;
  //  cInfoHeader          : string;
  //  BannerWin,Infowin    : tnWindow;
  //  Menu                 : tnMenu;
  //
  //  procedure            BuildScreen;
  //  procedure            MainMenuSelect;
  //  procedure            ShowInformation;
  //  procedure            MenuAppliance;
  //  procedure            MenuNetwork;
  //  procedure            MenuLicence;
  //  procedure            ShowHelp;
  //  procedure            SystemRestart;
  //  procedure            SystemShutdown;
  //  procedure            ShowNetwork;
  //  procedure            ResetNetwork;
  //  procedure            UpdateLicence;
  //  procedure            ShowLicence;
  //  function             Confirm: boolean;




//procedure TFRE_HAL_FEED.BuildScreen;
//begin
//  cBannerHeader    :='FirmOS Firmbox StorageHypervisor Console';
//  cInfoHeader      :='Information';
//  cBannerCopyright :='FirmOS Business Solutions GmbH 2013';
//  cBannerVersion   :='Developer Edition V 0.9';
//
//  TextColor(White);
//  TextBackground(DarkGray);
////  ClrScr;
//  With BannerWin Do Begin
//     Init(1,1,nStdScr.Cols,5,31,true,cFrameBorder);
//     Show;
////     ClrScr;
//     TextColor(White);
//     TextBackground(Blue);
//     Fwrite(2,1,GetColor,0,cBannerHeader);
//     Fwrite(2,2,GetColor,0,cBannerCopyright);
//     Fwrite(2,3,GetColor,0,cBannerVersion);
//  End;
//
//  With Infowin Do Begin
//     Init(1,9,nStdScr.Cols,nstdScr.Rows,31,true,cFrameBorder);
//     Show;
////     ClrScr;
//     TextColor(White);
//     TextBackground(Blue);
//     FWrite(10,1,Getcolor,0,cInfoHeader);
//  End;
//
//  With Menu Do Begin
//    Init(3,7,nStdScr.Cols-4,1,5,cMenuBack*16,0,0,false,1);
//    Add('Information');
//    Add('Appliance');
//    Add('Network');
//    Add('Licence');
//    Add('Help');
//    Post;
//    SetColor(cMenuBack*16+DarkGray);
//    SetCursorColor(cMenuBack*16+white);
//    Show;
//  End;
//
//end;
//
//procedure TFRE_HAL_FEED.MainMenuSelect;
//begin
//  Menu.Start;
//  Infowin.FWrite(10,10,InfoWin.GetColor,0,inttostr(menu.Index));
//  case menu.Index of
//    1: ShowInformation;
//    2: MenuAppliance;
//    3: MenuNetwork;
//    4: MenuLicence;
//    5: ShowHelp;
//  else
//    with InfoWin do begin
//      ClrScr;
//    end;
//  end;
//end;
//
//procedure TFRE_HAL_FEED.ShowInformation;
//begin
//  with InfoWin do begin
//    ClrScr;
//    FWrite(5,3,GetColor,0,'Information');
//  end;
//end;
//
//procedure TFRE_HAL_FEED.MenuAppliance;
//var
//  SubMenu : tnMenu;
//begin
//  with InfoWin do begin
//    ClrScr;
//    FWrite(5,5,GetColor,0,'Restart for immediate restarting');
//    FWrite(5,7,GetColor,0,'Shutdown for immediate shutdown');
//  end;
//  with SubMenu do begin
//    Init(14,8,0,3,1,cMenuBack*16,79,8,true,cMenuFrame*16+cMenuFrame);
//    Add('Restart  ');
//    Add('Shutdown ');
//    Add('Cancel');
//    Post;
//    Start;
//    Case Index of
//       1 : SystemRestart;
//       2 : SystemShutdown;
//    End;
//    Hide;
//  End;
//  SubMenu.Done;
//end;
//
//procedure TFRE_HAL_FEED.MenuNetwork;
//var
//  SubMenu : tnMenu;
//begin
//  with InfoWin do begin
//    ClrScr;
//    FWrite(5,5,GetColor,0,'');
//    FWrite(5,7,GetColor,0,'');
//  end;
//  with SubMenu do begin
//    Init(26,8,0,3,1,cMenuBack*16,79,8,true,cMenuFrame*16+cMenuFrame);
//    Add('Show Configuration');
//    Add('Reset Configuration');
//    Add('Cancel');
//    Post;
//    Start;
//    Case Index of
//       1 : ShowNetwork;
//       2 : ResetNetwork;
//    End;
//    Hide;
//  End;
//  SubMenu.Done;
//end;
//
//procedure TFRE_HAL_FEED.MenuLicence;
//var
//  SubMenu : tnMenu;
//begin
//  with InfoWin do begin
//    ClrScr;
//    FWrite(5,5,GetColor,0,'');
//    FWrite(5,7,GetColor,0,'');
//  end;
//  with SubMenu do begin
//    Init(38,8,0,3,1,cMenuBack*16,79,8,true,cMenuFrame*16+cMenuFrame);
//    Add('Show Licence Information');
//    Add('Update Licence Information');
//    Add('Cancel');
//    Post;
//    Start;
//    Case Index of
//       1 : ShowLicence;
//       2 : UpdateLicence;
//    End;
//    Hide;
//  End;
//  SubMenu.Done;
//end;
//
//procedure TFRE_HAL_FEED.ShowHelp;
//begin
//  with InfoWin do begin
//    ClrScr;
//    FWrite(5,3,GetColor,0,'Ctrl+Alt+F1 StorageHypervisor Console');
//    FWrite(5,5,GetColor,0,'Ctrl+Alt+F2 System Log');
//    FWrite(5,7,GetColor,0,'Ctrl+Alt+F3 Shell Access');
//  end;
//end;
//
//procedure TFRE_HAL_FEED.SystemRestart;
//begin
//  if Confirm then begin
//    writeln('RESTART');
//  end;
//end;
//
//procedure TFRE_HAL_FEED.SystemShutdown;
//begin
//  if Confirm then begin
//    writeln('SHUTDOWN');
//  end;
//end;
//
//procedure TFRE_HAL_FEED.ShowNetwork;
//begin
//
//end;
//
//procedure TFRE_HAL_FEED.ResetNetwork;
//begin
//  Confirm;
//end;
//
//procedure TFRE_HAL_FEED.UpdateLicence;
//begin
//
//end;
//
//procedure TFRE_HAL_FEED.ShowLicence;
//begin
//
//end;
//
//function TFRE_HAL_FEED.Confirm: boolean;
//var
//  SecMenu : tnMenu;
//begin
//  result  :=false;
//  with SecMenu do begin
//    Init(30,14,0,1,2,cMenuBack*16,79,8,true,cMenuFrame*16+cMenuFrame);
//    Add('Confirm');
//    Add('Cancel');
//    Post;
//    Start;
//    Case Index of
//       1 : result :=true;
//    End;
//    Hide;
//  End;
//  SecMenu.Done;
//end;

  procedure TestNcurses;
  begin
    GFOS_CONSOLE.Test;
  end;

type


  TFRE_BOXCONSOLE_FEED = class(TFRE_BASEDATA_FEED)
  end;


var
  Application : TFRE_BOXCONSOLE_FEED;

begin
  TestNcurses;
  //Application:=TFRE_BOXCONSOLE_FEED.Create(nil,TFRE_BOX_FEED_CLIENT.Create);
  //Application.Run;
  //Application.Free;
end.

