#include <idp.iss>

[Setup]
AppName=Elixir
AppVersion=0
DefaultDirName={sd}\Elixir
DefaultGroupName=Elixir

[CustomMessages]
NameAndVersion=%1

[Icons]
Name: "{group}\Elixir"; Filename: "{app}\bin\iex.bat"; WorkingDir: "{userdocs}"; IconFilename: "{app}\drop.ico"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"

[Files]
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"
Source: "extract-zip.ps1"; DestDir: "{app}"; Flags: deleteafterinstall

[Run]
Filename: "powershell.exe"; Parameters: "-File .\extract-zip.ps1 {tmp}\Precompiled.zip"; WorkingDir: "{app}"; Flags: waituntilterminated runhidden; StatusMsg: "Extracting..."

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function ErlangIsInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;

procedure InitializeWizard();
begin
  idpAddFile('https://github.com/elixir-lang/elixir/releases/download/v0.14.1/Precompiled.zip', ExpandConstant('{tmp}\Precompiled.zip'));
  idpDownloadAfter(wpReady);
end;
