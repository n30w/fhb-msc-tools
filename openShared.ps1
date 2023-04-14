$sharedDrive = "\\fhb\dfs\kic-bsd"

if (!(Test-Path I:)) {
    New-PSDrive -Name I -PSProvider FileSystem -Root $sharedDrive -Persist
    Invoke-Item -Path "I:\"
} else {
    Write-Host "I:\ is already mounted"
}
