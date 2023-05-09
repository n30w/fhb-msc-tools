#Requires AutoHotkey v2.0

; import actions for each application

#Include "apps\application.ahk"
#Include "apps\caps.ahk"
#Include "apps\edge.ahk"
#Include "apps\excel.ahk"
#Include "apps\notepad++.ahk"
#Include "apps\salesforce.ahk"
#Include "apps\obsidian.ahk"

YesNoBox(t)
{
	return MsgBox(t,, "YesNo")
}

DoesNotExist(v)
{
	return MsgBox v . " does not exist in DataStore. Check WP or SF.",, "IconX"
}

class Action
{
	then(fn)
	{
		fn()
		return this
	}
}