#Requires AutoHotkey v2.0

class Powershell extends Application
{
    cmd := "powershell.exe -ExecutionPolicy Bypass -File "
    psDir := "powershell\"
    ; Builds the powershell match params and command
    Match(psFile, targetDir, folderName) => (this.cmd . this.psDir . psFile . " -targetDir " . "`"" .  targetDir . "`"" . " -folderName " . "`"" .  folderName . "`"")

    ; Builds powershell openShared command
    OpenShared(psFile, targetDir, mountPath) => (this.cmd . this.psDir . psFile . " -mountPath " . "`"" . mountPath . "`"")

    ; Builds ViewAuditFolder command
    ShowAuditFolder(psFile, folderName) => (this.cmd . this.psDir . psFile . " -folderName " . "`"" .  folderName . "`"")

    EnvTest(targetDir) => ("powershell.exe -NoExit -ExecutionPolicy Bypass -File " . targetDir)
}