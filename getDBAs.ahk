OpenCaps() 
{
	Run "C:\Users\ralabastro\AppData\Local\Apps\2.0\DJVY1VY9.CG0\M17B2GO8.4ME\caps..tion_57d36b76fd0aefc8_0004.0006_4976a6dff7a6e371\CAPS.exe"
	NavigateCaps()
	return
}

NavigateCaps()
{
	Sleep 1500
	Click, 274 42
	Click, 274 105
	Click, 30, 66
	return
}

SendClipboard(c)
{
	; Sleep 200
	SendInput %clipboard%
	Click, 168, 116
	Sleep 1000
	Click, 55, 316
}

getDBA()
{
	Click 160 130
	Send ^c
	dba := Format("{:T}", A_Clipboard)
	A_Clipboard :=
	return dba
}

merchants(m)
{
	Loop, Read, % "mids.txt"
	{
		attr := StrSplit(A_LoopReadLine, A_Tab)
		merchant := {wpmid: attr.1, fdmid: attr.2, dba: ""}
		m.Push(merchant)
	}
	return
}

TEMPLATE_FOLDER := "2023.FDMS conversion"

^F9::

data := Array()
merchants(data) ; gets mids from text file and stores in array

if WinExist("ahk_exe CAPS.exe")
{
	WinActivate
	Click, 30, 66
	MouseMove, 170, 115
}
else
{
	OpenCaps()
	Sleep 500
}

for v in data ; get corresponding DBA for each WP MID, create folder if it doesn't exist.
{
	Send % data[A_Index].wpmid
	Click 168 116
	Sleep 2000
	data[A_Index].dba := getDBA()
	Click 30 66
	if not FileExist(Format("I:\Bus Serv Merch\01-MERCHANTS\{:s}", data[A_Index].dba))
		n := Format("I:\Bus Serv Merch\01-MERCHANTS\{:s}\2023.FDMS conversion", data[A_Index].dba)
		FileCreateDir, % n
}

; get list of folders in directory
;dir := Map()

; if there are no matching DBAs, make a new folder



return

^!x:: ExitApp