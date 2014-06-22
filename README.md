# elixir-windows-setup

Part of the Elixir on Windows Google Summer of Code 2014 project, this installer sets up [Elixir](http://elixir-lang.org/) on a Windows machine.

Currently, it will:
* (Suggest that the user) install Erlang first
* Download the precompiled Elixir package
* Extract the package to your favorite directory (or mine)
* Create shortcuts to IEx and the uninstaller

Currently, it won't:
* Download the LATEST version of Elixir (currently hardcoded to v0.14.1)
* Append the user's Path variable

## Acknowledgements
* Jordan Russell's [Inno Setup](http://www.jrsoftware.org/isinfo.php)
* Mitrich Software's [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/)

"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.
