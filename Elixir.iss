; Elixir.iss - Elixir "Offline" Installer
; Copyright (c) Chris Hyndman
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

#define ELIXIR_PATH '{app}\bin'
#define ESCRIPT_PATH '%USERPROFILE%\.mix\escripts'

[Setup]
AppName=Elixir
AppPublisher=ElixirLang
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
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
UninstallDisplayIcon={app}\drop.ico

[Files]
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "elixir\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Elixir"; Filename: "{code:GetScriptString|ErlangBinPath}\werl.exe"; WorkingDir: "%userprofile%"; IconFilename: "{app}\drop.ico"; IconIndex: 0; Parameters: "-env ERL_LIBS ""{app}\lib"" -user Elixir.IEx.CLI -extra --no-halt"

[Tasks]
Name: erlangpath; Description: "Append {code:GetScriptString|ErlangBinPath} to system PATH"; Check: CheckToAppendErlangPath
Name: elixirpath; Description: "Append {#ELIXIR_PATH} to system PATH"; Check: CheckToAppendElixirPath
Name: escriptpath; Description: "Append {#ESCRIPT_PATH} to system PATH"; Check: CheckToAppendEscriptPath

[Code]
#include "src\Util.iss"
#include "src\Path.iss"
#include "src\ErlangInstall.iss"

var
  GlobalPageErlangDir: TInputDirWizardPage;

function GetScriptString(Param: String): String;
begin
  Result := '';
  if Param = 'ErlangBinPath' then
    Result := GlobalPageErlangDir.Values[0] + '\bin';
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
	if CurStep = ssPostInstall then begin
    if IsTaskSelected('erlangpath') then
      AppendPath(GetScriptString('ErlangBinPath'));
		if IsTaskSelected('elixirpath') then
			AppendPath(ExpandConstant('{#ELIXIR_PATH}'));
    if IsTaskSelected('escriptpath') then
      AppendPath(ExpandConstant('{#ESCRIPT_PATH}'));
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
	SelTaskString: String;
begin
	if CurUninstallStep = usUninstall then begin
		SelTaskString := '';
    RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\Elixir_is1', 'Inno Setup: Selected Tasks', SelTaskString);

		if Pos('elixirpath', SelTaskString) <> 0 then
			DeletePath(ExpandConstant('{#ELIXIR_PATH}'));
    
    if Pos('escriptpath', SelTaskString) <> 0 then
      DeletePath(ExpandConstant('{#ESCRIPT_PATH}'));
	end;
end;

procedure InitializeWizard();
begin
  GlobalPageErlangDir := CreateInputDirPage(
    wpWelcome,
    'Confirm Erlang Directory',
    'Confirm the location of your Erlang installation, then click Next.',
    'Setup will configure Elixir to use the following Erlang installation path.',
    False, ''
  );
  
  GlobalPageErlangDir.Add('');
  GlobalPageErlangDir.Values[0] := GetLatestErlangPath();
end;

function CheckToAppendErlangPath: Boolean; begin
  Result := not ContainsPath(GetScriptString('ErlangBinPath')); end;

function CheckToAppendElixirPath: Boolean; begin
  Result := not ContainsPath(ExpandConstant('{#ELIXIR_PATH}')); end;

function CheckToAppendEscriptPath: Boolean; begin
  Result := not ContainsPath(ExpandConstant('{#ESCRIPT_PATH}')); end;
