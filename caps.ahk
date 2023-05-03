OpenCAPS() 
{
	Run "CAPS.appref-ms" ; runs a shortcut to CAPS
	CoordMode "Mouse", "Window"
	Sleep 5000
	Click 280, 40
	Sleep 600
	Click 280, 105
	Sleep 500
	Click 60, 315
}

SearchCAPS(v)
{
	CoordMode "Mouse", "Window"
	if WinExist("CAPS")
	{
		WinActivate
	}
	else
	{
		if MsgBox("CAPS not running. Would you like to activate it?",, "YesNo") = "No"
			return
		else
			OpenCAPS()
	}
	Sleep 400
	Click 30, 66
	Sleep 300
	Send v
	Sleep 400
	Send "{Enter}"
	Sleep 1000
}

; Opens CAPS when the script is run
OpenCAPS()

F8:: SearchCAPS(A_Clipboard)

^!x:: ExitApp