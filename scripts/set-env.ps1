$elixirRoot = $args[0]
$elixirBin = ($elixirRoot + "\bin").Replace("\\", "\")

Write-Host " * Appending $elixirBin to Path variable..." -foregroundcolor "green"
if (!($env:Path.Contains($elixirBin)))
{
	[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $elixirBin, "Machine")
}