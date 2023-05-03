NavigateCaps()
{
	Sleep 1500
	Click 274, 42
	Sleep 300
	Click 274 105
	Sleep 300
	Click 30, 66
}

SendClipboard(c)
{
	; Sleep 200
	Send c
	Sleep 400
	Send "{Enter}"
	Sleep 1000
}

OpenCaps() 
{
	Run("`"C:\Users\ralabastro\AppData\Local\Apps\2.0\DJVY1VY9.CG0\M17B2GO8.4ME\caps..tion_57d36b76fd0aefc8_0004.0006_4976a6dff7a6e371\CAPS.exe`"")
	NavigateCaps()
	return
}

F8:: OpenCaps()

^F8::
{
	CoordMode "Mouse", "Window"
	ClipSaved := A_Clipboard
	if WinExist("CAPS")
	{
		WinActivate
		Click 30, 66
		Sleep 500
	}
	else
	{
		OpenCaps()
	}
	
	Sleep 300
	SendClipboard(ClipSaved)
	;Sleep 1000
	;Click 55, 316
}


^!x::ExitApp
