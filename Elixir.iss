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

[Setup]
AppName=Elixir
AppVersion={#ElixirVersion}
ChangesEnvironment=yes
DefaultDirName={pf}\Elixir
DefaultGroupName=Elixir
OutputBaseFilename=elixir-v{#ElixirVersion}-setup
SetupIconFile=assets\drop.ico
UninstallDisplayIcon={app}\drop.ico
#ifdef SkipWelcome
DisableWelcomePage=yes
#endif
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite
#ifdef NoCompression
Compression=none
#endif

[Files]
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"
Source: "elixir\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Elixir"; Filename: "werl.exe"; WorkingDir: "%userprofile%"; IconFilename: "{app}\drop.ico"; IconIndex: 0; Parameters: "-env ERL_LIBS ""{app}\lib"" -s elixir start_cli -user Elixir.IEx.CLI -extra --no-halt"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"; IconIndex: 0

[Tasks]
Name: modifypath; Description: Append the system's Path environment variable

[Code]
const 
    ModPathName = 'modifypath'; 
    ModPathType = 'system'; 

function ModPathDir(): TArrayOfString; 
begin 
    setArrayLength(Result, 1) 
    Result[0] := ExpandConstant('{app}\bin'); 
end;
 
#include "src\modpath.iss"