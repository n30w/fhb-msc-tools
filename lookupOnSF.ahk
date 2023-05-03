; algorithm from: https://help.salesforce.com/s/articleView?id=000383751&type=1
; I rewrote it in AHK
sf15to18(s)
{
	Sleep 500
	addon := ""
	block := 0
	A := Ord("A")
	Z := Ord("Z")
	
	loop 3
	{
		loo := 0
		position := 1
		loop 5
		{
			p := SubStr(s, (block * 5) + position, 1)
			current := Ord(p)
			
			if current >= A and current <= Z
				loo += Integer(1 << position-1) ; position-1 because the bitshift would overshoot into the hundreds
			position++
		}
		addon .= SubStr("ABCDEFGHIJKLMNOPQRSTUVWXYZ012345", loo+1, 1) ; loo+1 since index in AHK starts at 1
		block++
	}
	
	return addon
}

SendClipboard(c)
{
	Sleep 200
	Send c
	Sleep 400
	Send "{Enter}"
	Sleep 75
}

; assumes that caps is in WorldPay info mode and "contact" tab is selected
SearchCaps(c)
{
	WinActivate("CAPS")
	Click 30, 66
	Sleep 200
	Send c
	Sleep 400
	Send "{Enter}"
	Sleep 300
}

; reformats date into mm/dd/yyyy
reformatDate(months) 
{
	Sleep 400
	dateObj := StrSplit(A_Clipboard, "-")
	return months[dateObj[2]] . "/" . dateObj[1] . "/" . "20" . dateObj[3]
}

^F5::
{	
	caseUrl := "https://fhbank.lightning.force.com/lightning/r/Case/"
	
	; if we're copying from excel, remove the `r`n
	wpMID := (StrLen(A_Clipboard) > 13 ? SubStr(A_Clipboard, 1, -2) : A_Clipboard)
	
	CoordMode "Mouse", "Window"
	SearchCaps(wpMID)
	
	WinActivate "WPMID_FDMID_CASEID - Excel"
	Sleep 100
	Send "^+l"
	Sleep 100
	Send wpMID
	Sleep 100
	Send "{Enter}"
	Sleep 200
	clip := A_Clipboard
	parsed := SubStr(clip, 1, -2)
	A_Clipboard := caseUrl . parsed . sf15to18(parsed) . "/view"
	WinMinimize "WPMID_FDMID_CASEID - Excel"
	WinActivate "ahk_exe msedge.exe"
	Sleep 50
	Send "^l"
	Sleep 50
	Send "^v"
	Sleep 100
	Send "{Enter}"
	A_Clipboard := wpMID
}

F5::
{
	accountUrl := "https://fhbank.lightning.force.com/lightning/r/Account/"
	months := Map(
		"JAN", "1",
		"FEB", "2",
		"MAR", "3",
		"APR", "4",
		"MAY", "5",
		"JUN", "6",
		"JUL", "7",
		"AUG", "8",
		"SEP", "9",
		"OCT", "10",
		"NOV", "11",
		"DEC", "12"
	)
	
	; if we're copying from excel, remove the `r`n
	wpMID := (StrLen(A_Clipboard) > 13 ? SubStr(A_Clipboard, 1, -2) : A_Clipboard)
	
	CoordMode "Mouse", "Window"
	SearchCaps(wpMID)
	Sleep 1000
	Click 730, 437
	Sleep 200
	Send "^c"
	Sleep 100
	
	if A_Clipboard = ""
	{
		MsgBox wpMID . " has not been closed on WorldPay yet"
		WinActivate("CAPS")
		return
	}
	
	formattedDate := reformatDate(months)
	
	WinActivate "WPMID_FDMID_CASEID - Excel"
	Sleep 100
	Send "^+k"
	Sleep 100
	Send wpMID
	Sleep 100
	Send "{Enter}"
	Sleep 200
	clip := A_Clipboard
	parsed := SubStr(clip, 1, -2)
	A_Clipboard := accountUrl . parsed . sf15to18(parsed) . "/view"
	WinMinimize "WPMID_FDMID_CASEID - Excel"
	
	WinActivate "ahk_exe msedge.exe"
	Sleep 50
	Send "^l"
	Sleep 50
	Send "^v"
	Sleep 100
	Send "{Enter}"
	A_Clipboard := formattedDate
	
	Sleep 9000
	Click 181, 92
	Sleep 1000
	Click 248, 88
	Sleep 400
	Send "^v"
	Sleep 500
	Send "{Enter}"	
}

^!x:: Reload
