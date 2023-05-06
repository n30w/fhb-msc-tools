#Requires AutoHotkey v2.0

; import actions for each application

#Include "apps\application.ahk"
#Include "apps\caps.ahk"
#Include "apps\edge.ahk"
#Include "apps\excel.ahk"
#Include "apps\notepad++.ahk"
#Include "apps\salesforce.ahk"

YesNoBox(t)
{
	return MsgBox(t,, "YesNo")
}

class Action
{
	then(fn)
	{
		fn()
		return this
	}
}