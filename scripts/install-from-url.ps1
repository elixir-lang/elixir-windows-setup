$cd = (split-path $MyInvocation.MyCommand.Path -parent)

if ($args.length -eq 0)
{
	Write-Error "No URL Provided."
}
else
{	
	$zipOrigin = $args[0]
	$zipPath = $cd + "\Precompiled.zip"
	
	Write-Host " * Downloading $zipOrigin to $zipPath..." -foregroundcolor "green"
	(New-Object System.Net.WebClient).DownloadFile($zipOrigin, $zipPath)
	
	Write-Host " * Extracting files into $cd..." -foregroundcolor "green"
	$shell = New-Object -com Shell.Application
	$zipFile = $shell.NameSpace($zipPath)
	foreach($item in $zipFile.items())
	{
		$shell.Namespace($cd).copyhere($item)
	}
	
	Write-Host " * Removing Precompiled.zip..." -foregroundcolor "green"
	Remove-Item $zipPath
	
	Write-Host " * Finished!" -foregroundcolor "green"
}