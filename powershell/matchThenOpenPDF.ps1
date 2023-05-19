# Created with the help of ChatGPT
# Matches folder names
param (
    [Parameter(Mandatory=$true)]
    [string]$folderName
)

$targetDir = "I:\Bus Serv Merch\01-MERCHANTS"
# Get the folders in the targetDir that match the string (case insensitive)
$matchingFolders = Get-ChildItem -Path $targetDir -Directory | Where-Object { $_.Name -ilike "*$folderName*" }
$convName = "2023."

# Iterate over the matching folders
foreach ($folder in $matchingFolders) {
    $conversionFolder = Get-ChildItem -Path $folder.FullName | Where-Object { $_.Name -ilike "*$convName*" }
    $folderPath = $folder.FullName + "\" + $conversionFolder.Name
    Write-Host "Matching folder found: $($folder.Name)"
    Write-Host "Opening folder: $folderPath"
    Invoke-Item -Path $folderPath
    # Get all PDF files in the target directory
    
    $pdfFiles = Get-ChildItem -Path $folderPath -Filter "*.pdf" -File

    # Iterate over the PDF files and open them
    foreach ($file in $pdfFiles) {
        $filePath = $file.FullName
        Write-Host "Opening PDF file: $filePath"
        Invoke-Item -Path $filePath
    }
}