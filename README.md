# elixir-windows-setup

![elixir-websetup](assets/screenshot.png)

## Features

* Downloads and installs the latest Elixir version, or another version the user selects
* Offers to install Erlang and add the Erlang directory to the system's Path variable
* Adds Elixir to the system's Path variable
* Creates Start Menu shortcuts

## Structure

The **offline installer** ([Elixir.iss](Elixir.iss)) packages a specific Elixir release to install, and also can append the system's Path variable appropriately.  This kind of installer is currently not distributed in binary form.

The **web installer** ([ElixirWeb.iss](ElixirWeb.iss)) is what's currently distributed (see [Releases](https://github.com/chyndman/elixir-windows-setup/releases)). The **web installer** itself does not install Elixir.  It packages the files necessary to download, compile, and run the **offline installer** for the selected Elixir release.  It also handles installing Erlang and adding it to the system's Path variable.

### Offline Installation

If you need to install Elixir on a system without internet access, follow these steps:

1. Install Erlang on to the system.
2. On another system with internet access, run `elixir-websetup.exe`.
3. When prompted, check the box for "Defer installation (advanced)" and uncheck all other options.
4. Proceed with the installation wizard.  Once complete, `elixir-vX.Y.Z-setup.exe` will be placed in the same folder as `elixir-websetup.exe`.
5. Use `elixir-vX.Y.Z-setup.exe` to install Elixir on to the system.  (Note: You may wish to uninstall previous versions of Elixir before doing this.)

## Build Instructions

First, download the Unicode version of Inno Setup (`isetup-X.Y.Z-unicode.exe` from [jrsoftware.org](http://www.jrsoftware.org/isdl.php#stable)) and install it, making sure to keep the "Install Inno Setup Preprocessor" checkbox checked when asked.  Then, clone this repo (`elixir-windows-setup`) to your system.

To build the **web installer**, follow these steps:

1. Download and install the [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/).
2. Open `elixir-windows-setup\ElixirWeb.iss` in the Inno Setup Compiler.
3. Click "Compile" to build an installer in `elixir-windows-setup/Output`.

To build the **offline installer** follow these steps:

1. Extract Precompiled.zip of the desired [Elixir Release](https://github.com/elixir-lang/elixir/releases/) into `elixir-windows-setup\elixir`
2. Open `elixir-windows-setup\Elixir.iss` in the Inno Setup Compiler.
3. Click "Compile" to build an installer in `elixir-windows-setup/Output`.

## Acknowledgements

#### [Inno Setup](http://www.jrsoftware.org/isinfo.php)
Copyright (C) 1997-2013 Jordan Russell. All rights reserved.
Portions Copyright (C) 2000-2013 Martijn Laan. All rights reserved.

#### [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/)
Copyright (c) 2013-2016 Mitrich Software

#### [7-Zip](http://www.7-zip.org/)
Copyright (C) 1999-2010 Igor Pavlov

#### [Elixir](http://elixir-lang.org/)
"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.
