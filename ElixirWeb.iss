; ElixirWeb.iss - Elixir Web Installer
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

#define COMPAT_MASK 1
#define ELIXIR_CSV_URL 'http://elixir-lang.org/elixir.csv'
#define ERLANG_CSV_URL 'http://elixir-lang.org/erlang.csv'

#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=2.0
OutputBaseFilename=elixir-websetup
SolidCompression=yes

; This installer doesn't install anything itself, it just runs other installers
CreateAppDir=no
Uninstallable=no

; The user will see the offline installer's finished page instead
DisableFinishedPage=yes

; Visual
SetupIconFile=assets\drop.ico
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
DisableWelcomePage=no

[CustomMessages]
; The version string shouldn't show the version of this installer (AppVersion)
NameAndVersion=%1

[Files]
; Offline installer files
Source: "Elixir.iss"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "assets\drop.ico"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "assets\drop_banner.bmp"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "assets\null.bmp"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "src\Util.iss"; DestDir: "{tmp}\src"; Flags: deleteafterinstall
Source: "src\Path.iss"; DestDir: "{tmp}\src"; Flags: deleteafterinstall
Source: "src\ErlangInstall.iss"; DestDir: "{tmp}\src"; Flags: deleteafterinstall
; 7-Zip portable extractor
Source: "bin\7za.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
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
; Run the Erlang installer if task is selected
Filename: "{tmp}\{code:GetScriptString|ErlangExe32}"; Flags: hidewizard; StatusMsg: "Installing {code:GetScriptString|ErlangName32}..."; Tasks: erlang\32
Filename: "{tmp}\{code:GetScriptString|ErlangExe64}"; Flags: hidewizard; StatusMsg: "Installing {code:GetScriptString|ErlangName64}..."; Tasks: erlang\64
; Extract the downloaded Precompiled.zip archive
Filename: "{tmp}\7za.exe"; Parameters: "x -oelixir Precompiled.zip"; WorkingDir: "{tmp}"; StatusMsg: "Extracting Precompiled.zip archive..."
; Compile the offline installer
Filename: "{tmp}\ISCC.exe"; Parameters: "/dSkipWelcome /dNoCompression Elixir.iss"; WorkingDir: "{tmp}"; StatusMsg: "Compiling Elixir installer..."
; Run the offline installer
Filename: "{tmp}\Output\elixir-v{code:GetScriptString|ElixirVersion}-setup.exe"; Flags: nowait postinstall; StatusMsg: "Starting Elixir installer..."

[Tasks]
Name: "unins_previous"; Description: "Uninstall previous version at {code:GetScriptString|ElixirPreviousPath} (Recommended)"; Check: CheckPreviousVersionExists
Name: "erlang"; Description: "Install Erlang"; Check: CheckToInstallErlang
Name: "erlang\32"; Description: "{code:GetScriptString|ErlangName32}"; Flags: exclusive
Name: "erlang\64"; Description: "{code:GetScriptString|ErlangName64}"; Flags: exclusive; Check: IsWin64

[Code]
#include "src\Util.iss"
#include "src\Path.iss"
#include "src\TErlangData.iss"
#include "src\TElixirRelease.iss"
#include "src\ErlangInstall.iss"
#include "src\ElixirInstall.iss"

var
  GlobalPageSelRelease: TInputOptionWizardPage;
  GlobalPageSelInstallType: TInputOptionWizardPage;

  GlobalElixirReleases: array of TElixirRelease;
  GlobalErlangData: TErlangData;

  GlobalElixirCSVFilePath: String;
  GlobalErlangCSVFilePath: String;

  CacheSelectedRelease: TElixirRelease;
  
function GetScriptString(Param: String): String;
begin
  Result := '';
  
  case (Param) of
    'ErlangExe32': Result := GlobalErlangData.Exe32;
    'ErlangExe64': Result := GlobalErlangData.Exe64;
    'ErlangName32': Result := GlobalErlangData.Name32;
    'ErlangName64': Result := GlobalErlangData.Name64;
    'ElixirVersion': Result := CacheSelectedRelease.Version;
    'ElixirPreviousPath': Result := GetPreviousAppPath();
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  ListBoxesToCheck: array[0..1] of TNewCheckListBox;
  _int: Integer;
begin
  if CurPageID = wpPreparing then begin
    // We're on the page after the "Ready To Install" page but before [Files] and [Run] are processed
    
    if IsTaskSelected('unins_previous') then
      ExecAsOriginalUser(GetPreviousUninsExe, '/SILENT', '', SW_SHOW, ewWaitUntilTerminated, _int);

    with GlobalErlangData do begin
      if IsTaskSelected('erlang\32') then
        // 32-bit OTP needs to be downloaded before it's installed
        idpAddFile(URL32, Tmp(Exe32));
      if IsTaskSelected('erlang\64') then
        // 64-bit OTP needs to be downloaded before it's installed
        idpAddFile(URL64, Tmp(Exe64));
    end;
    
    // Look in these two listboxes for the selected release to install
    ListBoxesToCheck[0] := GlobalPageSelInstallType.CheckListBox;
    ListBoxesToCheck[1] := GlobalPageSelRelease.CheckListBox;
    
    // Store the selected release for use during the installation process
    CacheSelectedRelease := FindSelectedRelease(ListBoxesToCheck, GlobalElixirReleases);
    
    // Download the Precompiled.zip archive for the selected release
    idpAddFile(CacheSelectedRelease.URL, Tmp('Precompiled.zip'));
    
    // Put the downloader page directly after this page
    idpDownloadAfter(wpPreparing);
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if PageID = GlobalPageSelRelease.ID then begin
    // We should skip the page for selecting an Elixir release if the install type selection page
    // has some Elixir release set (such as the latest stable release)
    Result := not (GlobalPageSelInstallType.CheckListBox.ItemObject[GlobalPageSelInstallType.SelectedValueIndex] = nil);
  end else begin
    Result := False;
  end;
end;

procedure InitializeWizard();
begin
  // Define the installation type page
  GlobalPageSelInstallType := CreateInputOptionPage(
    wpWelcome,
    'Select Elixir installation type',
    'Select which installation type you want to perform, then click Next.',
    'I want to:',
    True, False // (Use Radio Buttons), (Don't put them in a scrollable list box)
  );
  
  // Define the custom release selection page
  GlobalPageSelRelease := CreateInputOptionPage(
    GlobalPageSelInstallType.ID,
    'Select Elixir release',
    'Setup will download and install the Elixir release you select.',
    'All releases available to install are listed below, from newest to oldest.',
    True, True // (Use Radio Buttons), (Put them in a scrollable list box)
  );
  
  // Use the global Elixir release array to populate the custom Elixir release list box
  ElixirReleasesToListBox(GlobalElixirReleases, GlobalPageSelRelease.CheckListBox);
  
  // Find the latest release and put it as a selection on the installation type page
  with FindFirstReleaseOfType(GlobalElixirReleases, rtLatestRelease) do begin
    GlobalPageSelInstallType.CheckListBox.AddRadioButton(
      'Install the latest stable release (v' + Version + ')',
      '', 0, True, True, Ref
    );
  end;
  
  // Create a selection which will allow the custom Elixir release page to show up next
  GlobalPageSelInstallType.CheckListBox.AddRadioButton(
    'Select another release to install',
    '', 0, False, True, nil
  );
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  
  // Store the paths to elixir.csv, erlang.csv in global variables
  GlobalElixirCSVFilePath := Tmp(GetURLFilePart('{#ELIXIR_CSV_URL}'));
  GlobalErlangCSVFilePath := Tmp(GetURLFilePart('{#ERLANG_CSV_URL}'));

  // Download elixir.csv; show an error message and exit the installer if downloading fails
  if not idpDownloadFile('{#ELIXIR_CSV_URL}', GlobalElixirCSVFilePath) then begin
    MsgBox('Error: Downloading {#ELIXIR_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
  // Download erlang.csv; show an error message and exit the installer if downloading fails
  if not idpDownloadFile('{#ERLANG_CSV_URL}', GlobalErlangCSVFilePath) then begin
    MsgBox('Error: Downloading {#ERLANG_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
  
  // Create an array of TElixirRelease records from elixir.csv and store them in a global variable
  GlobalElixirReleases := CSVToElixirReleases(GlobalElixirCSVFilePath);
  
  // Check if above didn't work
  if GetArrayLength(GlobalElixirReleases) = 0 then begin
    MsgBox('Error: Parsing {#ELIXIR_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
  
  // Create an TErlangData from erlang.csv record and store it in a global variable
  GlobalErlangData := CSVToErlangData(GlobalErlangCSVFilePath);
  
  // Check if above didn't work
  if GlobalErlangData.OTPVersion = '' then begin
    MsgBox('Error: Parsing {#ERLANG_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
end;

function CheckToInstallErlang: Boolean; begin
  // Erlang should be installed if there's no Erlang path in the registry
  Result := (GetLatestErlangPath = ''); end;
