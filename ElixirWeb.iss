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
#define PATH_TO_7ZA "C:\Users\Chris\Documents\7za920"
#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=0.55
CreateAppDir=no
DisableFinishedPage=yes
OutputBaseFilename=elixir-websetup
SetupIconFile=assets\drop.ico
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite
Uninstallable=no

[CustomMessages]
NameAndVersion=%1

[Files]
; Offline installer files
Source: "Elixir.iss"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "assets\*"; DestDir: "{tmp}\assets"; Flags: deleteafterinstall
Source: "modpath.iss"; DestDir: "{tmp}"; Flags: deleteafterinstall
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
Filename: "{tmp}\7za.exe"; Parameters: "x -oelixir Precompiled.zip"; WorkingDir: "{tmp}"; StatusMsg: "Extracting Precompiled.zip archive..."
Filename: "{tmp}\ISCC.exe"; Parameters: "/dElixirVersion={code:ConstGetSelectedReleaseVersion} /dSkipWelcome /dNoCompression Elixir.iss"; WorkingDir: "{tmp}"; StatusMsg: "Compiling Elixir installer..."
Filename: "{tmp}\Output\elixir-v{code:ConstGetSelectedReleaseVersion}-setup.exe"; Flags: nowait; StatusMsg: "Starting Elixir installer..."

[Tasks]
Name: "erlang"; Description: "Install Erlang"; GroupDescription: "Erlang"
Name: "erlang\32"; Description: "OTP 17.1 (32-bit)"; GroupDescription: "Erlang"; Flags: exclusive
Name: "erlang\64"; Description: "OTP 17.1 (64-bit)"; GroupDescription: "Erlang"; Flags: exclusive; Check: IsWin64
Name: "erlpath"; Description: "Append Erlang directory to Path environment variable"; GroupDescription: "Erlang"

[Code]
type
  TStringTable = array of TStringList;

var
  PSelRelease: TInputOptionWizardPage;
  PSelInstallType: TInputOptionWizardPage;
  _int: Integer;

function SplitStringRec(Str: String; Delim: String; StrList: TStringList): TStringList;
var
  StrHead: String;
  StrTail: String;
  DelimPos: Integer;
begin
  DelimPos := Pos(Delim, Str);
  if (DelimPos = 0) then begin
    StrList.Add(Str);
    Result := StrList;
  end else begin
    StrHead := Str;
    StrTail := Str;

    Delete(StrHead, DelimPos, Length(StrTail));
    Delete(StrTail, 1, DelimPos);   

    StrList.Add(StrHead);
    Result := SplitStringRec(StrTail, Delim, StrList);
  end;
end;

function SplitString(Str: String; Delim: String): TStringList;
begin
  Result := SplitStringRec(Str, Delim, TStringList.Create);
end;

function GetVersion(Release: TStrings): String;
begin
  Result := Release[0];
end;

function GetURL(Release: TStrings): String;
begin
  Result := Release[1];
end;

function IsPrerelease(Release: TStrings): Boolean;
begin
  Result := (Release[2] = 'prerelease');
end;

function IsCompatibleForInstall(Release: TStrings): Boolean;
begin
  Result := (StrToInt(Release[3]) = {#COMPAT_MASK});
end;

function CSVToStringTable(Filename: String): TStringTable;
var
  Rows: TArrayOfString;
  i: Integer;                                                  
begin
  LoadStringsFromFile(Filename, Rows); 
  SetArrayLength(Result, GetArrayLength(Rows));

  for i := 0 to GetArrayLength(Result) - 1 do begin
    Result[i] := SplitString(Rows[i], ',');
  end;
end;

procedure PopulatePSelReleaseListBox(StringTable: TStringTable);
var
  SelectFirst: Boolean;
  ReleaseDesc: String;
  i: Integer;
begin
  PSelRelease.CheckListBox.Items.Clear;
  SelectFirst := True;
  for i := 0 to GetArrayLength(StringTable) - 1 do begin
    if IsCompatibleForInstall(StringTable[i]) then begin
      if IsPrerelease(StringTable[i]) then begin
        ReleaseDesc := 'Prerelease';
      end else begin
        ReleaseDesc := 'Release';
      end;
      PSelRelease.CheckListBox.AddRadioButton('Elixir version ' + GetVersion(StringTable[i]), ReleaseDesc, 0, SelectFirst, True, StringTable[i]);
      SelectFirst := False;
    end;
  end;
end;

function GetListBoxSelectedRelease(): TStrings;
var
  i: Integer;
begin
  for i := 0 to PSelRelease.CheckListBox.Items.Count - 1 do begin
    if PSelRelease.CheckListBox.Checked[i] then begin
      Result := TStrings(PSelRelease.CheckListBox.ItemObject[i]);
      break;
    end;
  end;
end;

function GetListBoxLatestRelease(Prerelease: Boolean): TStrings;
var
  i: Integer;
begin
  for i := 0 to PSelRelease.CheckListBox.Items.Count - 1 do begin
    if Prerelease = IsPrerelease(TStrings(PSelRelease.CheckListBox.ItemObject[i])) then begin
      Result := TStrings(PSelRelease.CheckListBox.ItemObject[i]);
      break;
    end;
  end; 
end;

function GetSelectedRelease(): TStrings;
var
  i: Integer;
begin
  for i := 0 to PSelInstallType.CheckListBox.Items.Count - 1 do begin
    if PSelInstallType.CheckListBox.Checked[i] then begin
      if not (PSelInstallType.CheckListBox.ItemObject[i] = nil) then begin
        Result := TStrings(PSelInstallType.CheckListBox.ItemObject[i]);
      end else begin
        Result := GetListBoxSelectedRelease();
      end;
      break;
    end;
  end;
end;

function ConstGetSelectedReleaseVersion(Param: String): String;
begin
  Result := GetVersion(GetSelectedRelease());
end;

function GetErlangPath: String;
var
  Versions: TArrayOfString;
  Path: String;
begin
  Result := '';

  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, 'SOFTWARE\Ericsson\Erlang', Versions) then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Ericsson\Erlang\' + Versions[GetArrayLength(Versions) - 1], '', Path);
    Result := Path;
  end;

  if IsWin64 then begin
    if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Ericsson\Erlang', Versions) then begin
      RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Ericsson\Erlang\' + Versions[GetArrayLength(Versions) - 1], '', Path);
      Result := Path;
    end;
  end;
end;

function ErlangIsInstalled: Boolean;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, _int);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpPreparing then begin
    idpAddFile(GetURL(GetSelectedRelease()), ExpandConstant('{tmp}\Precompiled.zip'));
    idpDownloadAfter(wpPreparing);
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if PageID = PSelRelease.ID then begin
    Result := not (PSelInstallType.CheckListBox.ItemObject[PSelInstallType.SelectedValueIndex] = nil);
  end else begin
    Result := False;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if not ErlangIsInstalled then begin
    if MsgBox('Warning: Erlang does not seem to be installed.' + #13#10#13#10 +
              'In order for Elixir to run, you will need to install Erlang from http://www.erlang.org/ and then add it to your Path environment variable.' + #13#10#13#10 +
              'Proceed anyway?', mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDNO then begin
      Result := 'Erlang not installed.';
    end;
  end;  
end;

procedure InitializeWizard();
var
  LatestRelease, LatestPrerelease: TStrings;
begin
  idpSetOption('DetailsButton', '0');
  
  PSelInstallType := CreateInputOptionPage(wpWelcome, 'Select Elixir installation type', 'Select which installation type you want to perform, then click Next.', 'I want to:', True, False);

  PSelRelease := CreateInputOptionPage(PSelInstallType.ID, 'Select Elixir release', 'Setup will download and install the Elixir release you select.', 'All releases available to install are listed below, from newest to oldest.', True, True);

  PopulatePSelReleaseListBox(CSVToStringTable(ExpandConstant('{tmp}\releases.csv')));
  LatestRelease := GetListBoxLatestRelease(False);
  LatestPrerelease := GetListBoxLatestRelease(True);

  PSelInstallType.CheckListBox.AddRadioButton('Install the latest stable release (v' + GetVersion(LatestRelease) + ')', '', 0, True, True, LatestRelease);
  if not (LatestPrerelease = nil) then begin
    PSelInstallType.CheckListBox.AddRadioButton('Install the latest prerelease (v' + GetVersion(LatestPrerelease) + ')', '', 0, False, True, LatestPrerelease);
  end;
  PSelInstallType.CheckListBox.AddRadioButton('Select another release to install', '', 0, False, True, nil);
end;

function InitializeSetup(): Boolean;
begin
  if not idpDownloadFile('http://elixir-lang.org/releases.csv', ExpandConstant('{tmp}\releases.csv')) then begin
    MsgBox('Error: Downloading http://elixir-lang.org/releases.csv failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
  end else begin
    Result := True;
  end;
end;
