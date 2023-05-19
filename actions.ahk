#Requires AutoHotkey v2.0

; import actions for each application

#Include "apps\application.ahk"
#Include "apps\caps.ahk"
#Include "apps\edge.ahk"
#Include "apps\excel.ahk"
#Include "apps\notepad++.ahk"
#Include "apps\salesforce.ahk"
#Include "apps\obsidian.ahk"
#Include "apps\outlook.ahk"
#Include "apps\adobeacrobat.ahk"
#Include "apps\powershell.ahk"

YesNoBox(t)
{
	return MsgBox(t,, "YesNo")
}

DoesNotExist(n, l, v)
{
	m := v . " does not exist in DataStore. Check WP or SF."
	l.Append(n, m)
	return MsgBox(m,, "IconX")
}

psMatch(psFile, targetDir, folderName) => "powershell.exe -ExecutionPolicy Bypass -File " . psFile . " -folderName " . "`"" .  folderName . "`""

; pause script
pauseScript()
{
	MsgBox "script paused"
}

class Action
{
	then(fn)
	{
		fn()
		return this
	}
}