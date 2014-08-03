; Elixir.iss - Elixir "Offline" Installer
; Copyright 2014 Chris Hyndman
;
;   Licensed under the Apache License, Version 2.0 (the "License");
;   you may not use this file except in compliance with the License.
;   You may obtain a copy of the License at
;
;       http://www.apache.org/licenses/LICENSE-2.0
;
;   Unless required by applicable law or agreed to in writing, software
;   distributed under the License is distributed on an "AS IS" BASIS,
;   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;   See the License for the specific language governing permissions and
;   limitations under the License.
;
; "Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.

; Determine version of Elixir from elixir\VERSION
#ifndef ElixirVersion
  #if FileExists('elixir\VERSION')
    #define VersionFileHandle = FileOpen('elixir\VERSION')
    #define ElixirVersion = FileRead(VersionFileHandle)
    #expr FileClose(VersionFileHandle)
  #else
    #error elixir\VERSION not found
  #endif
#endif

[Setup]
AppName=Elixir
AppPublisher=Plataformatec
AppPublisherURL=http://elixir-lang.org/
AppVersion={#ElixirVersion}
ChangesEnvironment=yes
DefaultDirName={pf}\Elixir
DefaultGroupName=Elixir
OutputBaseFilename=elixir-v{#ElixirVersion}-setup

; Web installer: the user sees the welcome page as part of the web installer
#ifdef SkipWelcome
DisableWelcomePage=yes
#endif

; Web installer: no need to compress, since the installer is built directly on the machine
#ifdef NoCompression
Compression=none
#endif

; Visual
SetupIconFile=assets\drop.ico
WizardImageBackColor=clWhite
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
UninstallDisplayIcon={app}\drop.ico

[Files]
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"
Source: "elixir\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Elixir"; Filename: "werl.exe"; WorkingDir: "%userprofile%"; IconFilename: "{app}\drop.ico"; IconIndex: 0; Parameters: "-env ERL_LIBS ""{app}\lib"" -s elixir start_cli -user Elixir.IEx.CLI -extra --no-halt"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"; IconIndex: 0

[Tasks]
Name: modifypath; Description: "Append {app}\bin to Path environment variable"

[Code]
// All of this code is used by modpath.iss to determine which path(s) to add and the corresponding task
const 
    ModPathName = 'modifypath'; 
    ModPathType = 'system'; 

function ModPathDir(): TArrayOfString; 
begin 
    setArrayLength(Result, 1) 
    Result[0] := ExpandConstant('{app}\bin'); 
end;
 
#include "src\legroom\modpath.iss"
