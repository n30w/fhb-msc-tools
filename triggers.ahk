#Requires AutoHotkey v2.0

#Include "workflows.ahk"

; class for key triggers or hotkeys, in order to switch workflows

class Triggers
{
	SetHotkey(t, r)
	{
		Hotkey t, r
	}
}