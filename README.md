# elixir-windows-setup

Part of the Elixir on Windows Google Summer of Code 2014 project, this installer sets up [Elixir](http://elixir-lang.org/) on a Windows machine.

## Features

* Installs the latest Elixir version, or another version the user selects
* Offers to installer Erlang and add the Erlang directory to the system's Path variable
* Downloads and extracts the selected Elixir package to your favorite directory (or mine)
* Adds Elixir to the system's Path variable
* Creates shortcuts to IEx and the uninstaller

## Build Instructions

First, download the Unicode version of Inno Setup (isetup-X.Y.Z-unicode.exe from [jrsoftware.org](http://www.jrsoftware.org/isdl.php#stable)) and install it, making sure to keep the "Install Inno Setup Preprocessor" checkbox checked when asked (the other choices are optional.)  Then, clone this repo (`elixir-windows-setup`) to your system.

To build the web installer (which offers to install any release of Elixir as well as install Erlang), follow these steps:
1. Download and install the [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/).
2. Open ElixirWeb.iss in the Inno Setup Compiler.
3. Click "Compile" to build an installer in `elixir-windows-setup/Output`.

To build the offline installer (which installs a specific release of Elixir and nothing else), follow these steps:

1. Extract the Precompiled.zip of the desired [Elixir Release](https://github.com/elixir-lang/elixir/releases/) into `elixir-windows-setup\elixir`
2. Open either a PowerShell or Command Prompt in `elixir-windows-setup`.
3. In the directory, run `#INNOSETUPPATH#\ISCC.exe /dElixirVersion=#ELIXIRVERSION# Elixir.iss`, where `#INNOSETUPPATH#` is probably "C:\Program Files (x86)\Inno Setup 5" and `#ELIXIRVERSION#` is the version of Elixir you're building the installer for.

## Acknowledgements

#### [Inno Setup](http://www.jrsoftware.org/isinfo.php)
Copyright (C) 1997-2013 Jordan Russell. All rights reserved.
Portions Copyright (C) 2000-2013 Martijn Laan. All rights reserved.

#### [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/)
Copyright (c) 2013-2014 Mitrich Software

#### [modpath.iss](http://legroom.net/software/modpath)
Copyright (c) Jared Breland

#### [7-Zip](http://www.7-zip.org/)
Copyright (C) 1999-2010 Igor Pavlov

#### [Elixir](http://elixir-lang.org/)
"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.
