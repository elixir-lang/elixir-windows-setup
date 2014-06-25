# elixir-windows-setup

Part of the Elixir on Windows Google Summer of Code 2014 project, this installer sets up [Elixir](http://elixir-lang.org/) on a Windows machine.

Currently, it will:
* Suggest that the user install Erlang first
* Download the precompiled Elixir package
* Extract the package to your favorite directory (or mine)
* Append the user's Path variable
* Create shortcuts to IEx and the uninstaller

Currently, it won't:
* Download the LATEST version of Elixir (currently hardcoded to v0.14.1)

## Acknowledgements

#### [Inno Setup](http://www.jrsoftware.org/isinfo.php)
Copyright (C) 1997-2013 Jordan Russell. All rights reserved.
Portions Copyright (C) 2000-2013 Martijn Laan. All rights reserved.

#### [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/)
Copyright (c) 2013-2014 Mitrich Software

#### [Elixir](http://elixir-lang.org/)
"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.
