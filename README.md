# elixir-windows-setup

Part of the Elixir on Windows Google Summer of Code 2014 project, this installer sets up [Elixir](http://elixir-lang.org/) on a Windows machine.

## Features

Currently, it will:
* Suggest that the user install Erlang first
* Download the precompiled Elixir package
* Extract the package to your favorite directory (or mine)
* Append the user's Path variable
* Create shortcuts to IEx and the uninstaller

Currently, it won't:
* Download the LATEST version of Elixir (currently hardcoded to v0.14.1)

## Build Instructions

First, download the [Unicode Inno Setup QuickStart Pack](http://www.jrsoftware.org/isdl.php#qsp) and install it, making sure to keep the "Install Inno Setup Preprocessor" checkbox checked when asked.  Then, follow these steps to build an offline installer (a single executable which packages a particular Elixir release):

1. Clone this repo to your system.  We'll call the resulting directory `elixir-windows-setup`.
2. Download the precompiled zip archive corresponding with the [Elixir Release](https://github.com/elixir-lang/elixir/releases/) you wish to build the installer for.
3. Extract the contents of the zip archive into `elixir-windows-setup\elixir`.
4. Open either a Command Prompt or PowerShell in `elixir-windows-setup`.
5. In the directory, run `#PathToInnoSetup#\ISCC.exe /dElixirVersion=#Version# Elixir.iss` where `#PathToInnoSetup#` is probably "C:\Program Files (x86)\Inno Setup 5" and where `#Version#` is the Elixir version number (ex. 0.14.1).

And that's it!  The installer will be in `elixir-windows-setup\Output`.  Note that instead of steps 2 and 3, you could clone Elixir in `elixir-windows-setup`, though this isn't recommended.

## Acknowledgements

#### [Inno Setup](http://www.jrsoftware.org/isinfo.php)
Copyright (C) 1997-2013 Jordan Russell. All rights reserved.
Portions Copyright (C) 2000-2013 Martijn Laan. All rights reserved.

#### [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/)
Copyright (c) 2013-2014 Mitrich Software

#### [Elixir](http://elixir-lang.org/)
"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.
