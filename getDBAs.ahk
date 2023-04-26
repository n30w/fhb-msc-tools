NavigateCaps()
{
	Sleep 1500
	Click 276, 42
	Click 274, 105
	Click 30, 66
	return
}

SendClipboard(c)
{
	CoordMode "Mouse", "Window"
	; Sleep 200
	SendInput Format("{:s}", c)
	Click 168, 116
	Sleep 1000
	Click 55, 316
}

OpenCaps() 
{
	Run "C:\Users\ralabastro\AppData\Local\Apps\2.0\DJVY1VY9.CG0\M17B2GO8.4ME\caps..tion_57d36b76fd0aefc8_0004.0006_4976a6dff7a6e371\CAPS.exe"
	NavigateCaps()
	return
}

getDBA()
{
	CoordMode "Mouse", "Window"
	Sleep 500
	Click 160, 130
	Send "{Ctrl down}c"
	Sleep 100
	Send "{Ctrl up}"
	dba := Format("{:T}", A_Clipboard)
	A_Clipboard := ""
	Sleep 500
	return dba
}

merchants(m)
{
	Loop read, "mids.txt"
	{
		attr := StrSplit(A_LoopReadLine, A_Tab)
		merchant := {wpmid: attr[1], fdmid: attr[2], dba: ""}
		m.Push(merchant)
	}
	return
}

TEMPLATE_FOLDER := "2023.FDMS conversion"

^F9::
{	
	CoordMode "Mouse", "Window"
	data := Array()
	failed := false
	merchants(data) ; gets mids from text file and stores in array
	
	if WinExist("ahk_exe CAPS.exe")
	{
		WinActivate
		click 30, 66
		Sleep 500
;		MouseMove 170, 115
	}
	else
	{
		OpenCaps()
		Sleep 500
	}

	for merchant in data ; get corresponding DBA for each WP MID, create folder if it doesn't exist.
	{
		;WinActivate "CAPS"
		CoordMode "Mouse", "Window"
		Send Format("{1}", merchant.wpmid)
		Click 168, 116
		;SendEvent "{Click, 168, 116}"
		Sleep 2000
		merchant.dba := getDBA()
		Sleep 500
		
		p := Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}\2023.FDMS conversion\", merchant.dba)
		
		;MsgBox merchant.dba
		
		;MsgBox Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}", merchant.dba)
		; if there are no matching DBAs, make a new folder
		if not DirExist(Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}\2023.FDMS conversion", merchant.dba))
			DirCreate Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}\2023.FDMS conversion", merchant.dba)
			;MsgBox "Created " . Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}\2023.FDMS conversion", data[A_Index].dba)
		
		if not FileExist(Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}\2023.FDMS conversion\CAPS fees.pdf", merchant.dba))
		{
			;CoordMode "Mouse", "Window"
			SendEvent "{Click 52, 70}"
			;MouseMove 52, 70, 20
			;Click
			
			Sleep 3000
			
			SendEvent "{Click 52, 40}"
			
			Sleep 4000
			
			MouseMove 177, 78, 50
			Click
			
			Sleep 1000
			
			loop 3 {
				Send "{Up}"
				Sleep 100
			}
			
			Send "{Enter}"
			
			Sleep 500
			
			Send "{Enter}"
			
			Sleep 2000
			
			;Send "I:\Bus Serv Merch\01-MERCHANTS\" . merchant.dba . "\2023.FDMS conversion"
			
			Send "CAPS fees"
			Send "{Enter}"
			
			Sleep 2000
			
			Send "{Alt down}{F4}"
			Sleep 300
			Send "{Alt up}"
			
			Sleep 1000
			
			
			try FileMove "CAPS fees.pdf", p, 1
			catch 
			{
				failed := true
				FileAppend Format("{1:} {2:} {3:}`n - file already exists or cannot move", merchant.dba, merchant.wpmid, merchant.fdmid), "C:\Users\ralabastro\Desktop\scripts\toAudit\failed.txt"
				FileDelete "CAPS fees.pdf"
			}
			
			;MsgBox "a"
			Sleep 1000
		}
		
		if not FileExist(Format("C:\Users\ralabastro\Desktop\scripts\toAudit\{1}\2023.FDMS conversion\FDMID code listing.pdf", merchant.dba))
		{
			WinActivate "Copy of Account Fee code listing 04242023 - Excel"
			CoordMode "Mouse", "Window"
			Click 196, 338
			Sleep 800
			Send "{Tab 8}"
			Send merchant.fdmid
			Sleep 500
			Send "{Enter}"
			Sleep 1900
			Send "{Ctrl down}p"
			Sleep 300
			Send "{Ctrl up}"
			Sleep 1000
			Click 225, 143
			Sleep 2000
			A_Clipboard := "FDMID code listing"
			Sleep 500
			Send "{Ctrl down}v"
			Sleep 300
			Send "{Ctrl up}"
			Sleep 500
			A_Clipboard := ""
			Send "{Enter}"
			Sleep 1500
			try FileMove "FDMID code listing.pdf", p, 1
			catch
			{
				FileAppend "Failed to move FDMID - " . merchant.fdmid . " " . merchant.dba . "`n" , "C:\Users\ralabastro\Desktop\scripts\toAudit\failed.txt"
				try FileDelete "FDMID code listing.pdf"
				catch
				{
					FileAppend "Failed to delete, file does not exist. Looks like " . merchant.fdmid . " has no associated rows`n", "C:\Users\ralabastro\Desktop\scripts\toAudit\failed.txt"
					Sleep 500
					Send "{Esc}"
				}
				Sleep 200
			}
		}
		
		WinActivate "CAPS"
		SendEvent "{Click, 30, 66}"
		Sleep 1000
		A_Clipboard := ""
		;MsgBox "a"
	}
	Send "{Esc 2}"
	MsgBox "Operation Complete"
}

^!x:: ExitApp