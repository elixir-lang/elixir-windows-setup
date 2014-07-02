$zipPath = $args[0]
$zipDest = $args[1]

if (!(Test-Path $zipDest))
{
	New-Item $zipDest -type directory -force
}

$shell = New-Object -com Shell.Application
$zipFile = $shell.NameSpace($zipPath)
foreach ($item in $zipFile.items())
{
	$shell.Namespace($zipDest).copyhere($item)
}