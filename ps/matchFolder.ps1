# Created with the help of ChatGPT
# Matches folder names
param (
    [Parameter(Mandatory=$true)]
    [string]$folderName
)

$targetDir = "I:\Bus Serv Merch\01-MERCHANTS"
# Get the folders in the targetDir that match the string (case insensitive)
$matchingFolders = Get-ChildItem -Path $targetDir -Directory | Where-Object { $_.Name -ilike "*$folderName*" }

# Iterate over the matching folders
foreach ($folder in $matchingFolders) {
    $folderPath = $folder.FullName
    Write-Host "Matching folder found: $($folder.Name)"
    Write-Host "Opening folder: $folderPath"
    Invoke-Item -Path $folderPath
}