# Created with the help of ChatGPT
# Matches folder names
param (
    [Parameter(Mandatory=$true)]
    [string]$folderName
)

$targetDir = "I:\Bus Serv Merch\01-MERCHANTS"
# Get the folders in the targetDir that match the string (case insensitive)
$matchingFolders = Get-ChildItem -Path $targetDir -Directory | Where-Object { $_.Name -ilike "*$folderName*" }
$convName = "2023.FDMS"
# Iterate over the matching folders
foreach ($folder in $matchingFolders) {
    $conversionFolder = Get-ChildItem -Path $folder.FullName | Where-Object { $_.Name -ilike "*$convName*" }
    $folderPath = $folder.FullName + "\" + $conversionFolder.Name
    Write-Host "Matching folder found: $($folder.Name)"
    Write-Host "Opening folder: $folderPath"
    Invoke-Item -Path $folderPath
}