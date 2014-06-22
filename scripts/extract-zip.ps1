$cd = (split-path $MyInvocation.MyCommand.Path -parent)
$zipPath = $args[0]
Write-Host " * Extracting files into $cd..." -foregroundcolor "green"
$shell = New-Object -com Shell.Application
$zipFile = $shell.NameSpace($zipPath)
foreach($item in $zipFile.items())
{
	$shell.Namespace($cd).copyhere($item)
}