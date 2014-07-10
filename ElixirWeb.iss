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

[Setup]
AppName=Elixir
AppVersion=0.56
ChangesEnvironment=yes
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
Filename: "{tmp}\{code:ConstGetOTP32Exe}"; Flags: hidewizard; StatusMsg: "Installing {code:ConstGetOTP32Name}..."; Tasks: erlang\32; AfterInstall: AppendErlangPathIfTaskSelected(False)
Filename: "{tmp}\{code:ConstGetOTP64Exe}"; Flags: hidewizard; StatusMsg: "Installing {code:ConstGetOTP64Name}..."; Tasks: erlang\64; AfterInstall: AppendErlangPathIfTaskSelected(True)
Filename: "{tmp}\7za.exe"; Parameters: "x -oelixir Precompiled.zip"; WorkingDir: "{tmp}"; StatusMsg: "Extracting Precompiled.zip archive..."
Filename: "{tmp}\ISCC.exe"; Parameters: "/dElixirVersion={code:ConstGetSelectedReleaseVersion} /dSkipWelcome /dNoCompression Elixir.iss"; WorkingDir: "{tmp}"; StatusMsg: "Compiling Elixir installer..."
Filename: "{tmp}\Output\elixir-v{code:ConstGetSelectedReleaseVersion}-setup.exe"; Flags: nowait; StatusMsg: "Starting Elixir installer..."

[Tasks]
Name: "erlang"; Description: "Install Erlang"; GroupDescription: "Erlang"; Check: CheckToInstallErlang
Name: "erlang\32"; Description: "{code:ConstGetOTP32Name}"; GroupDescription: "Erlang"; Flags: exclusive
Name: "erlang\64"; Description: "{code:ConstGetOTP64Name}"; GroupDescription: "Erlang"; Flags: exclusive; Check: IsWin64
Name: "erlpath"; Description: "Append Erlang directory to Path environment variable"; GroupDescription: "Erlang"; Check: CheckToAddErlangPath

[Code]
type
  TStringTable = array of TStringList;

var
  PSelRelease: TInputOptionWizardPage;
  PSelInstallType: TInputOptionWizardPage;
  ErlangCSVInfo: TStrings;
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

function GetURLFilePartRec(URL: String): String;
var
  SlashPos: Integer;
begin
  SlashPos := Pos('/', URL);
  if SlashPos = 0 then begin
    Result := URL;
  end else begin;
    Delete(URL, 1, SlashPos);
    Result := GetURLFilePartRec(URL);
  end;
end;

function GetURLFilePart(URL: String): String;
begin
  Delete(URL, 1, Pos('://', URL) + 2);
  Result := GetURLFilePartRec(URL);
end;

function GetElixirCSVFilePath: String;
begin
  Result := ExpandConstant('{tmp}\' + GetURLFilePart('{#ELIXIR_CSV_URL}'));
end;

function GetErlangCSVFilePath: String;
begin
  Result := ExpandConstant('{tmp}\' + GetURLFilePart('{#ERLANG_CSV_URL}'));
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

function GetOTP32Name: String;
begin
  Result := 'OTP ' + ErlangCSVInfo[0] + ' (32-bit)'
end;

function GetOTP64Name: String;
begin
  Result := 'OTP ' + ErlangCSVInfo[0] + ' (64-bit)'
end;

function ConstGetOTP32Name(Param: String): String;
begin
  Result := GetOTP32Name;
end;

function ConstGetOTP64Name(Param: String): String;
begin
  Result := GetOTP64Name;
end;

function GetERTSVersion: String;
begin
  Result := ErlangCSVInfo[1];
end;

function GetOTP32URL: String;
begin
  Result := ErlangCSVInfo[2];
end;

function GetOTP64URL: String;
begin
  Result := ErlangCSVInfo[3];
end;

function GetOTP32Exe: String;
begin
  Result := ExpandConstant('{tmp}\' + GetURLFilePart(GetOTP32URL));
end;

function GetOTP64Exe: String;
begin
  Result := ExpandConstant('{tmp}\' + GetURLFilePart(GetOTP64URL));
end;

function ConstGetOTP32Exe(Param: String): String;
begin
  Result := GetOTP32Exe;
end;

function ConstGetOTP64Exe(Param: String): String;
begin
  Result := GetOTP64Exe;
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

function GetErlangPath(Of64Bit: Boolean): String;
var
  Versions: TArrayOfString;
  Path: String;
  KeyPath: String;
begin
  Result := '';

  if Of64Bit then begin
    KeyPath := 'SOFTWARE\Wow6432Node\Ericsson\Erlang';
  end else begin
    KeyPath := 'SOFTWARE\Ericsson\Erlang';
  end;

  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, KeyPath, Versions) then begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, KeyPath + '\' + GetERTSVersion, '', Path) then begin
      Result := Path;
    end else if RegQueryStringValue(HKEY_LOCAL_MACHINE, KeyPath + '\' + Versions[GetArrayLength(Versions) - 1], '', Path) then begin
      Result := Path;
    end;
  end;
end;

function ErlangInPath: Boolean;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, _int);
end;

function CheckToInstallErlang: Boolean;
begin
  Result := (not ErlangInPath) and ((GetErlangPath(False) = '') or (GetErlangPath(True) = ''));
end;

function CheckToAddErlangPath: Boolean;
begin
  Result := not ErlangInPath;
end;

procedure AppendErlangPathIfTaskSelected(Of64Bit: Boolean);
var
  Path: String;
  RegValue: String;
begin
  if IsTaskSelected('erlpath') then begin
    Path := GetErlangPath(Of64Bit);
    if not (Path = '') then begin
      RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', RegValue);
      if Pos(Path, RegValue) = 0 then begin
        RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', RegValue + ';' + Path + '\bin');
      end;
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpPreparing then begin
    if IsTaskSelected('erlang\32') then begin
      idpAddFile(GetOTP32URL, GetOTP32Exe);
    end;
    if IsTaskSelected('erlang\64') then begin
      idpAddFile(GetOTP64URL, GetOTP64Exe);
    end;
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

procedure InitializeWizard();
var
  LatestRelease, LatestPrerelease: TStrings;
  ErlangFile: TArrayOfString;
begin
  PSelInstallType := CreateInputOptionPage(wpWelcome, 'Select Elixir installation type', 'Select which installation type you want to perform, then click Next.', 'I want to:', True, False);

  PSelRelease := CreateInputOptionPage(PSelInstallType.ID, 'Select Elixir release', 'Setup will download and install the Elixir release you select.', 'All releases available to install are listed below, from newest to oldest.', True, True);

  PopulatePSelReleaseListBox(CSVToStringTable(GetElixirCSVFilePath));
  LatestRelease := GetListBoxLatestRelease(False);
  LatestPrerelease := GetListBoxLatestRelease(True);

  PSelInstallType.CheckListBox.AddRadioButton('Install the latest stable release (v' + GetVersion(LatestRelease) + ')', '', 0, True, True, LatestRelease);
  if not (LatestPrerelease = nil) then begin
    PSelInstallType.CheckListBox.AddRadioButton('Install the latest prerelease (v' + GetVersion(LatestPrerelease) + ')', '', 0, False, True, LatestPrerelease);
  end;
  PSelInstallType.CheckListBox.AddRadioButton('Select another release to install', '', 0, False, True, nil);

  LoadStringsFromFile(GetErlangCSVFilePath, ErlangFile);
  ErlangCSVInfo := SplitString(ErlangFile[0], ',');
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if not idpDownloadFile('{#ELIXIR_CSV_URL}', GetElixirCSVFilePath) then begin
    MsgBox('Error: Downloading {#ELIXIR_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
  if not idpDownloadFile('{#ERLANG_CSV_URL}', GetErlangCSVFilePath) then begin
    MsgBox('Error: Downloading {#ERLANG_CSV_URL} failed.  Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
end;
