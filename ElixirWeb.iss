; ElixirWeb.iss - Elixir Web Installer
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

#define COMPAT_MASK 1
#define PATH_TO_7ZA 'C:\Users\Chris\Documents\7za920'

#define ELIXIR_CSV_URL 'http://elixir-lang.org/elixir.csv'
#define ERLANG_CSV_URL 'http://elixir-lang.org/erlang.csv'

#include <idp.iss>
#include "src\ispp_inspect.iss"

[Setup]
AppName=Elixir
AppVersion=0.58
ChangesEnvironment=yes
CreateAppDir=no
DisableFinishedPage=yes
OutputBaseFilename=elixir-websetup
SetupIconFile=assets\drop.ico
SolidCompression=yes
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite
Uninstallable=no

[CustomMessages]
NameAndVersion=%1

[Files]
; Offline installer files
Source: "Elixir.iss"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "assets\drop.ico"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "assets\drop_gs.ico"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "assets\drop_banner.bmp"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "assets\null.bmp"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "src\legroom\modpath.iss"; DestDir: "{tmp}\src\legroom"; Flags: deleteafterinstall
; 7-Zip portable extractor
Source: "{#PATH_TO_7ZA}\7za.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
; Compiler files
Source: "compiler:Default.isl"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:ISCC.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:ISCmplr.dll"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:islzma.dll"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:ISPP.dll"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:ISPPBuiltins.iss"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:Setup.e32"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "compiler:SetupLdr.e32"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "{tmp}\{#StrInspectScriptConst('GlobalErlangData.Exe32')}"; Flags: hidewizard; StatusMsg: "Installing {#StrInspectScriptConst('GlobalErlangData.Name32')}..."; Tasks: erlang\32
Filename: "{tmp}\{#StrInspectScriptConst('GlobalErlangData.Exe64')}"; Flags: hidewizard; StatusMsg: "Installing {#StrInspectScriptConst('GlobalErlangData.Name64')}..."; Tasks: erlang\64
Filename: "{tmp}\7za.exe"; Parameters: "x -oelixir Precompiled.zip"; WorkingDir: "{tmp}"; StatusMsg: "Extracting Precompiled.zip archive..."
Filename: "{tmp}\ISCC.exe"; Parameters: "/dElixirVersion={#StrInspectScriptConst('CacheSelectedRelease.Version')} /dSkipWelcome /dNoCompression Elixir.iss"; WorkingDir: "{tmp}"; StatusMsg: "Compiling Elixir installer..."
Filename: "{tmp}\Output\elixir-v{#StrInspectScriptConst('CacheSelectedRelease.Version')}-setup.exe"; Flags: nowait; StatusMsg: "Starting Elixir installer..."

[Tasks]
Name: "erlang"; Description: "Install Erlang"; Check: CheckToInstallErlang
Name: "erlang\32"; Description: "{#StrInspectScriptConst('GlobalErlangData.Name32')}"; Flags: exclusive
Name: "erlang\64"; Description: "{#StrInspectScriptConst('GlobalErlangData.Name64')}"; Flags: exclusive; Check: IsWin64
Name: "erlang\newpath"; Description: "Append Erlang directory to Path environment variable"
Name: "existingpath"; Description: "Append {#StrInspectScriptConst('GetLatestErlangPath')}\bin to Path environment variable"; Check: CheckToAddExistingErlangPath

[Code]
#include "src\util.iss"
#include "src\registry.iss"
#include "src\elixir_release.iss"
#include "src\elixir_lookup.iss"
#include "src\erlang_data.iss"
#include "src\erlang_env.iss"

var
  GlobalPageSelRelease: TInputOptionWizardPage;
  GlobalPageSelInstallType: TInputOptionWizardPage;

  GlobalElixirReleases: array of TElixirRelease;
  GlobalErlangData: TErlangData;

  GlobalElixirCSVFilePath: String;
  GlobalErlangCSVFilePath: String;

  CacheSelectedRelease: TElixirRelease;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then begin
    if IsTaskSelected('erlang\newpath') or IsTaskSelected('existingpath') then
      AppendPath(GetLatestErlangPath + '\bin');
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  ListBoxesToCheck: array[0..1] of TNewCheckListBox;
begin
  if CurPageID = wpPreparing then begin
    with GlobalErlangData do begin
      if IsTaskSelected('erlang\32') then
        idpAddFile(URL32, Exe32);
      if IsTaskSelected('erlang\64') then
        idpAddFile(URL64, Exe64);
    end;

    ListBoxesToCheck[0] := GlobalPageSelInstallType.CheckListBox;
    ListBoxesToCheck[1] := GlobalPageSelRelease.CheckListBox;

    CacheSelectedRelease := FindSelectedRelease(ListBoxesToCheck, GlobalElixirReleases);
    idpAddFile(CacheSelectedRelease.URL, ExpandConstant('{tmp}\Precompiled.zip'));
    idpDownloadAfter(wpPreparing);
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if PageID = GlobalPageSelRelease.ID then begin
    Result := not (GlobalPageSelInstallType.CheckListBox.ItemObject[GlobalPageSelInstallType.SelectedValueIndex] = nil);
  end else begin
    Result := False;
  end;
end;

procedure InitializeWizard();
begin
  GlobalPageSelInstallType := CreateInputOptionPage(
    wpWelcome,
    'Select Elixir installation type',
    'Select which installation type you want to perform, then click Next.',
    'I want to:',
    True, False
  );

  GlobalPageSelRelease := CreateInputOptionPage(
    GlobalPageSelInstallType.ID,
    'Select Elixir release',
    'Setup will download and install the Elixir release you select.',
    'All releases available to install are listed below, from newest to oldest.',
    True, True
  );

  GlobalElixirReleases := CSVToElixirReleases(GlobalElixirCSVFilePath);
  ElixirReleasesToListBox(GlobalElixirReleases, GlobalPageSelRelease.CheckListBox);

  with FindFirstReleaseOfType(GlobalElixirReleases, rtLatestRelease) do begin
    GlobalPageSelInstallType.CheckListBox.AddRadioButton(
      'Install the latest stable release (v' + Version + ')',
      '', 0, True, True, Ref
    );
  end;
  GlobalPageSelInstallType.CheckListBox.AddRadioButton(
    'Select another release to install',
    '', 0, False, True, nil
  );

  GlobalErlangData := CSVToErlangData(GlobalErlangCSVFilePath);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;

  GlobalElixirCSVFilePath := ExpandConstant('{tmp}\' + GetURLFilePart('{#ELIXIR_CSV_URL}'));
  GlobalErlangCSVFilePath := ExpandConstant('{tmp}\' + GetURLFilePart('{#ERLANG_CSV_URL}'));

  if not idpDownloadFile('{#ELIXIR_CSV_URL}', GlobalElixirCSVFilePath) then begin
    MsgBox('Error: Downloading {#ELIXIR_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
  if not idpDownloadFile('{#ERLANG_CSV_URL}', GlobalErlangCSVFilePath) then begin
    MsgBox('Error: Downloading {#ERLANG_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
end;

function CheckToInstallErlang: Boolean; begin
  Result := (GetLatestErlangPath = ''); end;
function CheckToAddExistingErlangPath: Boolean; begin
  Result := not (CheckToInstallErlang or ErlangInPath); end;
  
{#StrInspectAllFuncs}
