$cd = (split-path $MyInvocation.MyCommand.Path -parent)

$elixirVersion = $args[0]
$elixirURL = $args[1]

$newScriptPath = $cd + "\elixir-v" + $elixirVersion + "-setup.iss"
$newScript = [System.IO.StreamWriter] $newScriptPath
foreach ($line in (Get-Content .\Elixir.iss)) {
    $line = $line.Replace("@@VERSION", $elixirVersion)
    $line = $line.Replace("@@URL", $elixirURL)
    $newScript.WriteLine($line)
}
$newScript.close()
& 'C:\Program Files (x86)\Inno Setup 5\Compil32.exe' /cc $newScriptPath