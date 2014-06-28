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
  TStringTable = array of TStringList;

var
  PSelRelease: TWizardPage;
  PSelReleaseListBox: TNewCheckListBox;
  i: Integer;
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

function CSVToStringTable(Filename: String): TStringTable;
var
  Rows: TArrayOfString;                                                  
begin
  LoadStringsFromFile(Filename, Rows); 
  SetArrayLength(Result, GetArrayLength(Rows));

  for i := 0 to GetArrayLength(Result) - 1 do begin
    Result[i] := SplitString(Rows[i], ',');
  end;
end;

procedure PopulatePSelReleaseListBox(StringTable: TStringTable);
var
  PrereleaseLabel: String;
begin
  PSelReleaseListBox.Items.Clear;

  for i := 0 to GetArrayLength(StringTable) - 1 do begin
    if (StrToInt(StringTable[i][3]) = {#COMPAT_MASK}) then begin
      if StringTable[i][2] = 'true' then begin
        PrereleaseLabel := 'Prerelease';
      end else begin
        PrereleaseLabel := 'Release';
      end;
      PSelReleaseListBox.AddRadioButton('Elixir version ' + StringTable[i][0], PrereleaseLabel, 0, False, True, StringTable[i]);
    end;
  end;
end;

function GetSelectedReleaseValues(): TStrings;
begin
  for i := 0 to PSelReleaseListBox.Items.Count - 1 do begin
    if PSelReleaseListBox.Checked[i] then begin
      Result := TStrings(PSelReleaseListBox.ItemObject[i]);
      break;
    end;
  end;
end;

function GetSelectedReleaseVersion(Param: String): String;
begin
  Result := GetSelectedReleaseValues[0];
end;

function GetSelectedReleaseURL(): String;
begin
  Result := GetSelectedReleaseValues[1];
end;

function ErlangIsInstalled: Boolean;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, _int);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = PSelRelease.ID then begin
    if not FileExists(ExpandConstant('{tmp}\releases.csv')) then begin
      idpDownloadFile('http://elixir-lang.org/releases.csv', ExpandConstant('{tmp}\releases.csv'));
    end;
    PopulatePSelReleaseListBox(CSVToStringTable(ExpandConstant('{tmp}\releases.csv')));
  end;

  if CurPageID = wpReady then begin
    idpAddFile(GetSelectedReleaseURL, ExpandConstant('{tmp}\Precompiled.zip'));
    idpDownloadAfter(wpPreparing);
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
begin
  idpSetOption('DetailsButton', '0');
  
  PSelRelease := CreateCustomPage(wpWelcome, 'Select Elixir release', 'Setup will download and install the Elixir release you select.');
  PSelReleaseListBox := TNewCheckListBox.Create(PSelRelease);
  PSelReleaseListBox.Width := PSelRelease.SurfaceWidth;
  PSelReleaseListBox.Height := PSelRelease.SurfaceHeight - 10;
  PSelReleaseListBox.Parent := PSelRelease.Surface;
end;
