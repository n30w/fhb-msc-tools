param (
    [Parameter(Mandatory=$true)]
    [string]$mountPath
)

New-PSDrive -Name "I" -PSProvider "FileSystem" -Root $mountPath -Scope 'Global' -Persist