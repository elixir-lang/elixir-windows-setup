#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=0.13
CreateAppDir=no
OutputBaseFilename=elixir-websetup
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite
Uninstallable=no

[CustomMessages]
NameAndVersion=the latest version of %1

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
Filename: "{tmp}\_offlineinstaller\ISCC.exe"; Parameters: "/dElixirVersion=0.14.1 /dSkipPages /dNoCompression Elixir.iss"; WorkingDir: "{tmp}\_offlineinstaller"; Flags: waituntilterminated runhidden; StatusMsg: "Preparing Elixir installer..."
Filename: "{tmp}\_offlineinstaller\Output\elixir-v0.14.1-setup.exe"; Flags: waituntilterminated; StatusMsg: "Running Elixir installer..."

[Code]
var
  PSelectVerPage: TWizardPage;
  PSelectVerFetchText: TNewStaticText;
  PSelectVerFetchProgress: TNewProgressBar;

procedure DoPSelectVer();
begin
  WizardForm.NextButton.Enabled := False;
    
  PSelectVerFetchProgress.Visible := True;
  MsgBox('Fetching version PLACEHOLDER', mbInformation, MB_OK);
  PSelectVerFetchProgress.Visible := False;
    
  WizardForm.NextButton.Enabled := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = PSelectVerPage.ID then
    DoPSelectVer;
end;

procedure CreatePages();
begin
  PSelectVerPage := CreateCustomPage(wpWelcome, 'Select Elixir version', 'Setup will download and install the Elixir version you select.');
  PSelectVerFetchProgress := TNewProgressBar.Create(PSelectVerPage);
  PSelectVerFetchProgress.Width := PSelectVerPage.SurfaceWidth;
  PSelectVerFetchProgress.Parent := PSelectVerPage.Surface;
  PSelectVerFetchProgress.Style := npbstMarquee;
end;

function ErlangIsInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;

procedure InitializeWizard();
begin
  CreatePages;
  idpAddFile('https://github.com/elixir-lang/elixir/releases/download/v0.14.1/Precompiled.zip', ExpandConstant('{tmp}\Precompiled.zip'));
  idpDownloadAfter(wpPreparing);
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

[Code]
procedure ExtractPrecompiled();
var
  ResultCode: Integer;
begin
  Exec('powershell.exe', ExpandConstant('-File {tmp}\extract-zip.ps1 {tmp}\Precompiled.zip {tmp}\Precompiled'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;
