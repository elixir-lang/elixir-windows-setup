#### Output functions
function Err ($str)
{
	Write-Host " Error | " -foregroundcolor "red" -NoNewline
	Write-Host "$str"
}
function Info ($str)
{
	Write-Host "  Info | " -foregroundcolor "green" -NoNewline
	Write-Host "$str"
}
function ExitMsg ()
{
	Err("Something went wrong while making the offline installer.  Elixir was not installed to your computer.")
	Err("You can report this issue at https://github.com/chyndman/elixir-windows-setup/issues")
	Write-Host "         " -NoNewline
	pause
	exit
}

#### Initializations
$cd = (Get-Item -Path ".\" -Verbose).FullName
$isccDefine = ""
$isccDir = $cd
$elixirVersion = ""
$startInstaller = 0

#### Script
Info("Current directory:")
Info("    $cd")

Info("Reading arguments...")
foreach ($arg in $args)
{
	Info("    $arg")
	if ($arg = "--innoelixirweb")
	{
		$isccDefine = "/dSkipPages /dNoCompression"
		$startInstaller = 1
	}
}
Info("Finished reading arguments")

Info("Checking for ISCC.exe in $isccDir...")
if (Test-Path $isccDir\ISCC.exe)
{
	Info("ISCC path: $isccDir\ISCC.exe")
}
else
{
	Err("ISCC.exe not found in $isccDir")
	ExitMsg
}

Info("Checking for elixir directory...")
if (Test-Path .\elixir)
{
	Info("elixir directory exists")
}
else
{
	Info("Not found, checking for Precompiled.zip...")
	if (Test-Path .\Precompiled.zip)
	{
		Info("Precompiled.zip found")
		Info("Extracting Precompiled.zip to .\elixir...")
		scripts\extract-zip.ps1 $cd\Precompiled.zip $cd\elixir
	}
	else
	{
		Err("Precompiled.zip not found")
		ExitMsg
	}
}

if ($elixirVersion -eq "")
{
	Info("Reading Elixir version from elixir\VERSION...")
	foreach ($line in (Get-Content $cd\elixir\VERSION))
	{
		$elixirVersion = $line
		break
	}
	Info("Elixir version: $elixirVersion")
}

$isccDefine = "`"/dElixirVersion=" + $elixirVersion + "`" " + $isccDefine

Info("Running $isccDir\ISCC.exe $isccDefine /Q Elixir.iss")
& $isccDir\ISCC.exe $isccDefine /Q Elixir.iss
if ($LastExitCode -eq 0)
{
	Info("Installer compiled successfully to .\Output\elixir-v$elixirVersion-setup.exe")
}
else
{
	Err("ISCC.exe failed with exit code $LastExitCode")
	ExitMsg
}

if ($startInstaller -eq 1)
{
	Info("Starting installer...")
	start ".\Output\elixir-v$elixirVersion-setup.exe"
}
