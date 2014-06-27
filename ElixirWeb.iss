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
#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=0.13
CreateAppDir=no
OutputBaseFilename=elixir-websetup
WizardImageFile=assets\drop_banner_hd.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite
Uninstallable=no

[CustomMessages]
NameAndVersion=%1

[Files]
; Zip extraction helper
Source: "scripts\extract-zip.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
; Offline installer files
Source: "Elixir.iss"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "scripts\set-env.ps1"; DestDir: "{tmp}\_offlineinstaller\scripts"; Flags: deleteafterinstall
Source: "assets\*"; DestDir: "{tmp}\_offlineinstaller\assets"; Flags: deleteafterinstall
; Compiler files
Source: "compiler:Default.isl"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "compiler:ISCC.exe"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "compiler:ISCmplr.dll"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "compiler:islzma.dll"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "compiler:ISPP.dll"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "compiler:Setup.e32"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
Source: "compiler:SetupLdr.e32"; DestDir: "{tmp}\_offlineinstaller"; Flags: deleteafterinstall
; For debugging offline.
; Source: "C:\Users\Chris\Downloads\Precompiled.zip"; DestDir: "{tmp}"; Flags: external deleteafterinstall

[Run]
Filename: "powershell.exe"; Parameters: "-File {tmp}\extract-zip.ps1 {tmp}\Precompiled.zip {tmp}\_offlineinstaller\elixir"; Flags: waituntilterminated runhidden; StatusMsg: "Extracting precompiled package..."
Filename: "{tmp}\_offlineinstaller\ISCC.exe"; Parameters: "/dElixirVersion={code:GetSelectedReleaseVersion} /dSkipPages /dNoCompression Elixir.iss"; WorkingDir: "{tmp}\_offlineinstaller"; Flags: waituntilterminated runhidden; StatusMsg: "Preparing Elixir installer..."
Filename: "{tmp}\_offlineinstaller\Output\elixir-v0.14.1-setup.exe"; Flags: waituntilterminated; StatusMsg: "Running Elixir installer..."

[Code]
type
  TElixirRelease = record
    Version: String;
    URL: String;
    ReleaseType: String;
    CompatMask: Integer;
  end;
  TArrayOfElixirRelease = array of TElixirRelease;

var
  PSelectVerPage: TWizardPage;
  PSelectVerListBox: TNewCheckListBox;
  ReleasesProcessed: Boolean;
  ElixirReleases: TArrayOfElixirRelease;

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
var
  StrList: TStringList;
begin
  StrList := TStringList.Create;
  Result := SplitStringRec(Str, Delim, StrList)
end;

procedure ParseReleasesCSV;
var
  ReleaseStrings: TArrayOfString;
  NumReleases: Integer;
  i: Integer;                                                   
  LineValues: TStringList;
begin
  LoadStringsFromFile(ExpandConstant('{tmp}\releases.csv'), ReleaseStrings);
  NumReleases := GetArrayLength(ReleaseStrings); 
  SetArrayLength(ElixirReleases, NumReleases);

  for i := 0 to NumReleases - 1 do begin
    LineValues := SplitString(ReleaseStrings[i], ',');
    ElixirReleases[i].Version := LineValues.Strings[0];
    ElixirReleases[i].URL := LineValues.Strings[1];
    ElixirReleases[i].ReleaseType := LineValues.Strings[2];
    ElixirReleases[i].CompatMask := StrToInt(LineValues.Strings[3]);
  end;
end;

procedure PopulateListOfReleases();
var
  LatestRelease: Boolean;
  MatchesCompatMask: Boolean;
  VersionLabel: String;
  i: Integer;
begin
  LatestRelease := True;
  for i := 0 to GetArrayLength(ElixirReleases) - 1 do begin
    VersionLabel := 'Version ' + ElixirReleases[i].Version;
    if LatestRelease then
      VersionLabel := VersionLabel + ' (Latest)';
    
    MatchesCompatMask := (ElixirReleases[i].CompatMask = {#COMPAT_MASK});  
    PSelectVerListBox.AddRadioButton(VersionLabel, ElixirReleases[i].ReleaseType, 0, LatestRelease, MatchesCompatMask, nil);
    
    if MatchesCompatMask then
      LatestRelease := False;
  end;
end;

function GetSelectedRelease(): TElixirRelease;
var
  i: Integer;
begin
  for i := 0 to GetArrayLength(ElixirReleases) - 1 do begin
    if PSelectVerListBox.Checked[i] then begin
      Result := ElixirReleases[i];
    end;
  end;
end;

function GetSelectedReleaseVersion(Param: String): String;
begin
  Result := GetSelectedRelease().Version;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = PSelectVerPage.ID then begin
    if not ReleasesProcessed then begin
      idpDownloadFile('http://elixir-lang.org/releases.csv', ExpandConstant('{tmp}\releases.csv'));
      ParseReleasesCSV;
      PopulateListOfReleases;

      ReleasesProcessed := True;
    end;
  end;

  if CurPageID = wpReady then begin
    idpAddFile(GetSelectedRelease().URL, ExpandConstant('{tmp}\Precompiled.zip'));
    idpDownloadAfter(wpPreparing);
  end;
end;

procedure CreatePages();
begin
  PSelectVerPage := CreateCustomPage(wpWelcome, 'Select Elixir version', 'Setup will download and install the Elixir version you select.');

  PSelectVerListBox := TNewCheckListBox.Create(PSelectVerPage);
  PSelectVerListBox.Width := PSelectVerPage.SurfaceWidth;
  PSelectVerListBox.Height := PSelectVerPage.SurfaceHeight - 10;
  PSelectVerListBox.Parent := PSelectVerPage.Surface;
end;

function ErlangIsInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;

procedure InitializeWizard();
begin
  ReleasesProcessed := False;
  CreatePages;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ErrorMsg: String;
begin
  if ErlangIsInstalled then begin
    Result := '';
  end else begin
    ErrorMsg := 'Warning: Erlang does not seem to be installed.' + #13#10#13#10 +
                'In order for Elixir to run, you will need to install Erlang from http://www.erlang.org/ and then add it to your Path environment variable.' + #13#10#13#10 +
                'Proceed anyway?';
    if MsgBox(ErrorMsg, mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then begin
      Result := '';
    end else begin
      Result := 'Erlang not installed.';
    end;
  end;  
end;

procedure ExtractPrecompiled();
var
  ResultCode: Integer;
begin
  Exec('powershell.exe', ExpandConstant('-File {tmp}\extract-zip.ps1 {tmp}\Precompiled.zip {tmp}\Precompiled'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;
