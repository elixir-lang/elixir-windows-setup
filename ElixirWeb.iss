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
  TElixirReleaseType = (rtRelease, rtPrerelease, rtLatestRelease, rtLatestPrerelease, rtIncompatible);
  TElixirRelease = record
    Version: String;
    URL: String;
    ReleaseType: TElixirReleaseType;
    Ref: TObject;
  end;

  TErlangData = record
    OTPVersion: String;
    ERTSVersion: String;
    URL32: String;
    URL64: String;
    Exe32: String;
    Exe64: String;
    Name32: String;
    Name64: String;
  end;

var
  GlobalPageSelRelease: TInputOptionWizardPage;
  GlobalPageSelInstallType: TInputOptionWizardPage;

  GlobalElixirReleases: array of TElixirRelease;
  GlobalErlangData: TErlangData;

  CacheSelectedRelease: TElixirRelease;

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

function ReleaseTypeToString(ReleaseType: TElixirReleaseType): String;
begin
  Result := 'Unknown';
  if ReleaseType = rtRelease then
    Result := 'Release';
  if ReleaseType = rtPrerelease then
    Result := 'Prerelease';
  if ReleaseType = rtLatestRelease then
    Result := 'Latest Release';
  if ReleaseType = rtLatestPrerelease then
    Result := 'Latest Prerelease';
  if ReleaseType = rtIncompatible then
    Result := 'Incompatible';
end;

procedure CSVToElixirReleases(Filename: String; Releases: array of TElixirRelease);
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  i: Integer;
  LatestPrerelease: Boolean;
  LatestRelease: Boolean;                                                  
begin
  LatestPrerelease := True;
  LatestRelease := True;
  
  LoadStringsFromFile(Filename, Rows); 
  SetArrayLength(Releases, GetArrayLength(Rows));

  for i := 0 to GetArrayLength(Releases) - 1 do begin
    RowValues := SplitString(Rows[i], ',');

    with Releases[i] do begin
      Version := RowValues[0];
      URL := RowValues[1];

      if StrToInt(RowValues[3]) = {#COMPAT_MASK} then begin
        if RowValues[2] = 'prerelease' then begin
          if LatestPrerelease then begin
            ReleaseType := rtLatestPrerelease;
            LatestPrerelease := False;
          end else begin
            ReleaseType := rtPrerelease;
          end;
        end else begin
          if LatestRelease then begin
            ReleaseType := rtLatestRelease;
            LatestRelease := False;
          end else begin
            ReleaseType := rtRelease;
          end;
        end;
      end else begin
        ReleaseType := rtIncompatible;
      end;

      if Ref = Null then
        Ref := TObject.Create();
    end;
  end;
end;

procedure ElixirReleasesToListBox(Releases: array of TElixirRelease; ListBox: TNewCheckListBox);
var
  i: Integer;
begin
  PSelRelease.CheckListBox.Items.Clear;
  for i := 0 to GetArrayLength(Releases) - 1 do begin
    with Releases[i] do begin
      if ReleaseType <> rtIncompatible then begin
        PSelRelease.CheckListBox.AddRadioButton('Elixir version ' + Version, ReleaseTypeToString(ReleaseType), 0, (ReleaseType = rtLatestRelease), True, Ref);
      end;
    end
  end;
end;

procedure CSVToErlangData(Filename: String; Erlang: TErlangData);
var
  Rows: TArrayOfString;
begin
  LoadStringsFromFile(Filename, Rows);

  with Erlang do begin
    OTPVersion  := Rows[0][0];
    ERTSVersion := Rows[0][1];
    URL32       := Rows[0][2];
    URL64       := Rows[0][3];

    Exe32       := ExpandConstant('{tmp}\' + GetURLFilePart(URL32));
    Exe64       := ExpandConstant('{tmp}\' + GetURLFilePart(URL64));
    Name32      := 'OTP ' + OTPVersion + ' (32-bit)';
    Name64      := 'OTP ' + OTPVersion + ' (64-bit)';
  end;
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
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, KeyPath + '\' + ErlangInfo.ERTSVersion, '', Path) then begin
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
      idpAddFile(ErlangInfo.URL32, GetOTP32Exe);
    end;
    if IsTaskSelected('erlang\64') then begin
      idpAddFile(ErlangInfo.URL64, GetOTP64Exe);
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

function CheckToInstallErlang: Boolean; begin
  Result := (not ErlangInPath) and ((GetErlangPath(False) = '') or (GetErlangPath(True) = '')); end;
function CheckToAddErlangPath: Boolean; begin
  Result := not ErlangInPath; end;

function ConstGetOTP32Name(Param: String): String; begin Result := GetOTP32Name; end;
function ConstGetOTP64Name(Param: String): String; begin Result := GetOTP64Name; end;
function ConstGetOTP32Exe(Param: String): String;  begin Result := GetOTP32Exe; end;
function ConstGetOTP64Exe(Param: String): String;  begin Result := GetOTP64Exe; end;
function ConstGetSelectedReleaseVersion(Param: String): String; begin Result := GetVersion(GetSelectedRelease()); end;