#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=@@VERSION
ChangesEnvironment=yes
DefaultDirName={pf}\Elixir
DefaultGroupName=Elixir
OutputBaseFilename=elixir-v@@VERSION-websetup
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite

[Dirs]
Name: "{tmp}\Precompiled"; Flags: deleteafterinstall

[Files]
Source: "scripts\extract-zip.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "scripts\set-env.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"
Source: "{tmp}\Precompiled\*"; DestDir: "{app}"; Flags: recursesubdirs external createallsubdirs; BeforeInstall: ExtractPrecompiled

[Icons]
Name: "{group}\Elixir"; Filename: "werl.exe"; WorkingDir: "%userprofile%"; IconFilename: "{app}\drop.ico"; IconIndex: 0; Parameters: "-env ERL_LIBS ""{app}\lib"" -s elixir start_cli -user Elixir.IEx.CLI -extra --no-halt"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"; IconIndex: 0

[Run]
Filename: "powershell.exe"; Parameters: "-File {tmp}\set-env.ps1 {app}"; Flags: waituntilterminated runhidden; StatusMsg: "Setting environment variables..."

[Code]
function ErlangIsInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;

procedure InitializeWizard();
begin
  idpAddFile('@@URL', ExpandConstant('{tmp}\Precompiled.zip'));
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

procedure ExtractPrecompiled();
var
  ResultCode: Integer;
begin
  Exec('powershell.exe', ExpandConstant('-File {tmp}\extract-zip.ps1 {tmp}\Precompiled.zip {tmp}\Precompiled'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;
