[Setup]
AppName=Elixir
AppVersion={#ElixirVersion}
ChangesEnvironment=yes
DefaultDirName={pf}\Elixir
DefaultGroupName=Elixir
OutputBaseFilename=elixir-v{#ElixirVersion}-setup
#ifdef SkipPages
DisableWelcomePage=True
DisableFinishedPage=True
#endif
WizardImageFile=assets\drop_banner.bmp
WizardSmallImageFile=assets\null.bmp
WizardImageBackColor=clWhite

[Files]
Source: "scripts\set-env.ps1"; DestDir: "{tmp}\scripts"; Flags: deleteafterinstall
Source: "assets\drop.ico"; DestDir: "{app}"
Source: "assets\drop_gs.ico"; DestDir: "{app}"
Source: "elixir\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Elixir"; Filename: "werl.exe"; WorkingDir: "%userprofile%"; IconFilename: "{app}\drop.ico"; IconIndex: 0; Parameters: "-env ERL_LIBS ""{app}\lib"" -s elixir start_cli -user Elixir.IEx.CLI -extra --no-halt"
Name: "{group}\Uninstall Elixir"; Filename: "{uninstallexe}"; IconFilename: "{app}\drop_gs.ico"; IconIndex: 0

[Run]
Filename: "powershell.exe"; Parameters: "-File {tmp}\scripts\set-env.ps1 {app}"; Flags: waituntilterminated runhidden; StatusMsg: "Setting environment variables..."
