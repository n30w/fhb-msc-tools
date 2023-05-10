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
	StartTime := A_TickCount
	prevFDMID := ""
	LogString := A_Now . " Conversion PDF Extract Log.txt"
	
	CoordMode "Mouse", "Window"
	data := Array()
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
		CoordMode "Mouse", "Window"
		Send Format("{1}", merchant.wpmid)
		Click 168, 116
		Sleep 2000
		merchant.dba := getDBA()
		Sleep 500
		
		p := Format("C:\Users\ralabastro\Desktop\scripts\toAudit\list\{1}\2023.FDMS conversion\", merchant.dba)
		
		; if there are no matching DBAs, make a new folder
		if not DirExist(Format("C:\Users\ralabastro\Desktop\scripts\toAudit\list\{1}\2023.FDMS conversion", merchant.dba))
			DirCreate Format("C:\Users\ralabastro\Desktop\scripts\toAudit\list\{1}\2023.FDMS conversion", merchant.dba)
		
		; if CAPS fee doesn't exist, access CAPS and create pdf
		if not FileExist(Format("C:\Users\ralabastro\Desktop\scripts\toAudit\list\{1}\2023.FDMS conversion\CAPS fees.pdf", merchant.dba))
		{
			SendEvent "{Click 52, 70}"
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
			
			Send "CAPS fees"
			Send "{Enter}"
			Sleep 2500
			
			Send "{Alt down}{F4}"
			Sleep 300
			Send "{Alt up}"
			
			Sleep 1000
			
			try FileMove "CAPS fees.pdf", p, 1
			catch 
			{
				FileAppend Format("{1:} {2:} {3:}`n - file already exists or cannot move", merchant.dba, merchant.wpmid, merchant.fdmid), "C:\Users\ralabastro\Desktop\scripts\toAudit\failed.txt"
				FileDelete "CAPS fees.pdf"
			}
			
			;MsgBox "a"
			Sleep 1000
		}
		
		A_Clipboard := ""
		
		; generate PDF from Account Fee code listing document
		if not FileExist(Format("C:\Users\ralabastro\Desktop\scripts\toAudit\list\{1}\2023.FDMS conversion\FDMID code listing.pdf", merchant.dba))
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
			
			Send "{Esc 2}"
			Sleep 500
			Click 120, 360
			Sleep 500
			Send "{Ctrl down}c"
			Sleep 300
			Send "{Ctrl up}"
			
			; https://www.autohotkey.com/board/topic/62646-convert-clipboard-to-integer/
			; copying from excel always has `r`n, so must remove it
			if (Substr(A_Clipboard,1,-2) = prevFDMID) ; current FDMID is not in the list
			{
				FileAppend merchant.dba . " " . merchant.fdmid . " has no listings in Account Fee Code Listings`n", "C:\Users\ralabastro\Desktop\scripts\toAudit\logs\" . LogString
				A_Clipboard := ""
				Sleep 2000
			}
			else
			{
				Send "{Ctrl down}p"
				Sleep 300
				Send "{Ctrl up}"
				Sleep 1000
				Click 225, 143
				If WinWait("Save Print Output As", , 4)
				{
					;Sleep 3700
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
						FileAppend "Failed to move FDMID - " . merchant.fdmid . " " . merchant.dba . "`n" , "C:\Users\ralabastro\Desktop\scripts\toAudit\logs\" . LogString
						try FileDelete "FDMID code listing.pdf"
						catch
						{
							FileAppend "Failed to delete, file does not exist. Looks like " . merchant.fdmid . " has no associated rows`n", "C:\Users\ralabastro\Desktop\scripts\toAudit\logs\" . LogString
							Sleep 500
							Send "{Esc}"
						}
						Sleep 200
					}
				}
				else
				{
					MsgBox "Print to PDF not selected, press OK to reload"
					Sleep 1000
					Reload
				}
			}
		}
		
		prevFDMID := merchant.fdmid
		A_Clipboard := ""		
		
		WinActivate "CAPS"
		Sleep 800
		SendEvent "{Click, 30, 66}"
		Sleep 1000
		;MsgBox "a"
	}
	Send "{Esc 2}"
	ElapsedTime := A_TickCount - StartTime
	
	; Convert to Minutes, Seconds, And Milliseconds here.
	m := Round(ElapsedTime/60000)
	r := Mod(ElapsedTime, 60000)
	s := Round(r/1000)
	r := Mod(r, 1000)
	mi := r
	
	MsgBox "Operation complete in " . m . "m" . s . "s" . mi . "ms"
}

^!x:: ExitApp