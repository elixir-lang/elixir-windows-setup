[Setup]
AppName=Elixir
AppVersion=0.14.1
DefaultDirName={sd}\Elixir
DefaultGroupName=Elixir

[Icons]
Name: "{group}\Elixir"; Filename: "{app}\bin\iex.bat"; WorkingDir: "{userdocs}"; IconFilename: "{app}\drop.ico"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"

[Files]
Source: "Precompiled\*"; DestDir: "{app}"; Flags: createallsubdirs recursesubdirs
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"

[Code]
function ErlangIsInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('erl.exe', '+V', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
end;
