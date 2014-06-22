#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=@@VERSION
DefaultDirName={sd}\Elixir
DefaultGroupName=Elixir
OutputBaseFilename=elixir-v@@VERSION-setup
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite

[Dirs]
Name: "{tmp}\Precompiled"; Flags: deleteafterinstall

[Files]
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"
Source: "scripts\extract-zip.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "{tmp}\Precompiled\*"; DestDir: "{app}"; Flags: recursesubdirs external createallsubdirs; BeforeInstall: ExtractPrecompiled

[Icons]
Name: "{group}\Elixir"; Filename: "{app}\bin\iex.bat"; WorkingDir: "{userdocs}"; IconFilename: "{app}\drop.ico"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"

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
  idpDownloadAfter(wpReady);
end;

procedure ExtractPrecompiled();
var
  ResultCode: Integer;
begin
  Exec('powershell.exe', ExpandConstant('-File {tmp}\extract-zip.ps1 {tmp}\Precompiled.zip {tmp}\Precompiled'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;
