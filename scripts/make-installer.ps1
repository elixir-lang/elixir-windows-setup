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
$isccDir = (Get-Item -Path ".\" -Verbose).FullName
$elixirVersion = ""

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
		$zipPath = .\Precompiled.zip
		$zipDest = .\elixir
		
		Info("Creating $zipDest...")
		New-Item $zipDest -type directory -force

		Info("Extracting files into $zipDest...")
		$shell = New-Object -com Shell.Application
		$zipFile = $shell.NameSpace($zipPath)
		foreach ($item in $zipFile.items())
		{
			$shell.Namespace($zipDest).copyhere($item)
		}
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
	$versionFile = Get-Content .\elixir\VERSION
	$elixirVersion = $versionFile[0]
	Info("Elixir version: $elixirVersion")
}

$isccDefine += " /dElixirVersion=" + $elixirVersion

Info("Running $iscc $isccDefine Elixir.iss")
& $iscc $isccDefine Elixir.iss
if ($LastExitCode -eq 0)
{
	Info("Installer compiled successfully to .\Output")
}
else
{
	Err("ISCC.exe failed with exit code $LastExitCode")
	ExitMsg
}