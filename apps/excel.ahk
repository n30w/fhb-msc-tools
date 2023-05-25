#Requires AutoHotkey v2.0

class MSExcel extends Application
{
	
	; fee sequence codes:
	; 164,170,800,804,10P,10J,10A,10D,018,18E,0AZ,10Q,10K,10B,10E
	
	OpenColumnAFilterDropdown(fdmid)
	{
		Click 196, 338
		Sleep 800
		Send "{Tab 8}"
		Send fdmid
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
	}
	
	SaveToPDFMacro(n)
	{
		Send "^+p"
		; wait for Save As window to pull up and wait for its closure before continuing
		WinWaitActive "Save As"
		Send n
		Send "{Enter}"
		; Wait for publish window to pull up and wait for its closure before continuing
		WinWait "Publishing..." 
		WinWaitClose
	}
	
	DefaultPDFSaveMacro()
	{
		Sleep 400
		Send "^+d"
		Sleep 300
		
		; Wait for publish window to pull up and wait for its closure before continuing
		WinWait "Publishing..."
		WinWaitClose
	}
	
	FilterColumnMacro(fdmid)
	{
		Send "^+f"
		Sleep 300
		Send fdmid
		Sleep 100
		Send "{Enter}"
		Sleep 3000
	}
	
	Start()
	{
		Open(this)
		if WinWait(this.Ref,, 3)
			WinMinimize ; Use the window found by WinWait.
		else
			MsgBox "WinWait timed out looking for Excel..."
	}
}