# Created with the help of ChatGPT
# Matches folder names
param (
    [Parameter(Mandatory=$true)]
    [string]$targetDir,

    [Parameter(Mandatory=$true)]
    [string]$folderName,

    [int]$openLimit = 3
)

# Get the folders in the targetDir that match the string (case insensitive)
$matchingFolders = Get-ChildItem -Path $targetDir -Directory | Where-Object { $_.Name -ilike "*$folderName*" }

$openCount = 0
# Iterate over the matching folders
foreach ($folder in $matchingFolders) {
    if ($openCount -lt $openLimit) {
        $folderPath = $folder.FullName
        Write-Host "Matching folder found: $($folder.Name)"
        Write-Host "Opening folder: $folderPath"
        Invoke-Item -Path $folderPath
        $openCount++
    }
    else {
        break
    }
}