function Is-Match($directory) {
    $match = $directory -match '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].\w*'
    return $match
}

function Get-Match($directory) {
    $root = "C:\Users\ralabastro\Desktop\" + $directory
    $subDir = Get-ChildItem $directory -Directory
    $hasAnySubDir = (Get-ChildItem -Force -Directory "$directory").Count -gt 0
    
    if ($hasAnySubDir) {
            foreach ($dir in $subDir) {
            $matched = Is-Match $dir
            if(!($matched)) { # Checks if something is a sub-folder
                Get-Match($directory + "\" + $dir)                               
            }
        }
    } else {
        Write-Host "$directory"
    }
    
}

$user = $env:UserName
$root = "C:\Users\$user\Desktop\01-MERCHANTS"

Start-Transcript -Path "C:\Users\$user\Desktop\log.txt"
foreach ($dir in $root) {
    Get-Match "$dir"
}
Stop-Transcript
