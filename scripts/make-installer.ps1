#### Initializations
$cd = (Get-Item -Path ".\" -Verbose).FullName
$isccDefine = ""
$isccDir = ""
$elixirVersion = ""
$startInstaller = 0
$friendly = 0

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
function FriendlyPause ()
{
	Err("Something went wrong while making the offline installer.  Elixir was not installed to your computer.")
	Err("You can report this issue at https://github.com/chyndman/elixir-windows-setup/issues")
	Write-Host "         " -NoNewline
	pause
}
function ErrExit ($str)
{
	if ($friendly -eq 1)
	{
		FriendlyPause
	}
	exit
}

#### Script
Info("Current directory:")
Info("    $cd")

Info("Reading arguments...")
for ($i = 0; $i -lt $args.length; $i++)
{
	Info("    " + $args[$i])
	if ($args[$i] -eq "--friendly")
	{
		$friendly = 1
	}
	if ($args[$i] -eq "--skip-welcome")
	{
		$isccDefine += " /dSkipWelcome"
	}
	if ($args[$i] -eq "--no-compression")
	{
		$isccDefine += " /dNoCompression"
	}
	if ($args[$i] -eq "--start")
	{
		$startInstaller = 1
	}
	if ($args[$i] -eq "--isccdir")
	{
		$i++
		if ($args[$i] -ne $null)
		{
			Info("    " + $args[$i])
			$isccDir = $args[$i]
		}
		else
		{
			ErrExit("Invalid arguments")
		}
	}
}
Info("Finished reading arguments")

Info("Checking for ISCC.exe in:")
foreach ($dir in ($isccDir, $cd, "C:\Program Files (x86)\Inno Setup 5", $null))
{
	if ($dir -eq $null)
	{
		ErrExit("ISCC.exe not found")
	}
	if ($dir -ne "")
	{
		Info("    $dir")
		if (Test-Path $dir\ISCC.exe)
		{
			$isccDir = $dir
			Info("ISCC path: $isccDir\ISCC.exe")
			break;
		}
	}
}

Info("Checking for $cd\elixir...")
if (Test-Path $cd\elixir)
{
	Info("$cd\elixir exists")
}
else
{
	Info("Not found, checking for $cd\Precompiled.zip...")
	if (Test-Path $cd\Precompiled.zip)
	{
		Info("$cd\Precompiled.zip found")
		Info("Extracting $cd\Precompiled.zip to $cd\elixir...")
		scripts\extract-zip.ps1 $cd\Precompiled.zip $cd\elixir
	}
	else
	{
		ErrExit("$cd\Precompiled.zip not found")
	}
}

if ($elixirVersion -eq "")
{
	Info("Reading Elixir version from $cd\elixir\VERSION...")
	foreach ($line in (Get-Content $cd\elixir\VERSION))
	{
		$elixirVersion = $line
		break
	}
	Info("Elixir version: $elixirVersion")
}

$isccDefine = "`"/dElixirVersion=" + $elixirVersion + "`" " + $isccDefine

$isccDefine = $isccDefine.Trim()
Info("Running $isccDir\ISCC.exe $isccDefine /Q Elixir.iss")
& $isccDir\ISCC.exe $isccDefine /Q Elixir.iss

if ($LastExitCode -eq 0)
{
	Info("Installer compiled successfully to $cd\Output\elixir-v$elixirVersion-setup.exe")
}
else
{
	ErrExit("ISCC.exe failed with exit code $LastExitCode")
}

if ($startInstaller -eq 1)
{
	Info("Starting installer...")
	start "$cd\Output\elixir-v$elixirVersion-setup.exe"
}
