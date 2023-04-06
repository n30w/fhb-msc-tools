#!/usr/bin/env powershell
$user = $env:UserName

Write-Host "mounting shared drive to I:\"

& "C:\Users\$user\Desktop\scripts\openShared.ps1"

$currentDate = Get-Date -Format "yyyyMMdd"

Write-Host "DBA:"
$dba = Read-Host

Write-Host "action:"

$action = Read-Host

$workingPath = $dba + "\" + $currentDate + "." + $action
$fullPath = "C:\Users\$user\Desktop\"+$workingPath

New-Item -ItemType Directory -Path $fullPath

Invoke-Item -Path $fullPath