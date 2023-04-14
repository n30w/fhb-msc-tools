OpenCaps() 
{
	Run "C:\Users\ralabastro\AppData\Local\Apps\2.0\DJVY1VY9.CG0\M17B2GO8.4ME\caps..tion_57d36b76fd0aefc8_0004.0006_4976a6dff7a6e371\CAPS.exe"
	Sleep 1500
	Click, 274 42
	Click, 274 105
	Click, 30, 66
	MouseMove, 170, 115
	return
}

F8::
OpenCaps()
return

^F8::
ClipSaved := Clipboard
OpenCaps()
Sleep 500
SendInput %ClipSaved%
Click, 168, 116
Sleep 1000
Click, 55, 316
return

