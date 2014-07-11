# elixir-windows-setup

Part of the Elixir on Windows Google Summer of Code 2014 project, this installer sets up [Elixir](http://elixir-lang.org/) on a Windows machine.

## Features

* Installs the latest Elixir version, or another version the user selects
* Offers to installer Erlang and add the Erlang directory to the system's Path variable
* Downloads and extracts the selected Elixir package to your favorite directory (or mine)
* Adds Elixir to the system's Path variable
* Creates shortcuts to IEx and the uninstaller

## Build Instructions

First, download the [Unicode Inno Setup QuickStart Pack](http://www.jrsoftware.org/isdl.php#qsp) and install it, making sure to keep the "Install Inno Setup Preprocessor" checkbox checked when asked.  Then, follow these steps to build an offline installer (a single executable which only installs Elixir itself):

1. Clone this repo (`elixir-windows-setup`) to your system.
2. Extract the Precompiled.zip of the desired [Elixir Release](https://github.com/elixir-lang/elixir/releases/) into `elixir-windows-setup\elixir`
3. Open either a PowerShell or Command Prompt in `elixir-windows-setup`.
4. In the directory, run `#INNOSETUPPATH#\ISCC.exe /dElixirVersion=#ELIXIRVERSION# Elixir.iss`, where `#INNOSETUPPATH#` is probably "C:\Program Files (x86)\Inno Setup 5" and `#ELIXIRVERSION#` is the version of Elixir you're building the installer for.

And that's it!  As an alternative to step 2, you could clone Elixir into `elixir-windows-setup` and build an installer for that repo.

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
