getFDMID(wpmid)
{
	; Ctrl+Shift+H opens the custom Macro I have for the excel sheet which retrieves the FDMID from a table
	Sleep 200
	Send "^+h"
	Sleep 200
	A_Clipboard := wpmid
	Sleep 200
	Send "^v"
	Sleep 200
	Send "{Enter}"
	Sleep 800
	fdmid := A_Clipboard
	A_Clipboard := ""
	return fdmid
}

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
	Send c
	Sleep 400
	Send "{Enter}"
	Sleep 1000
}

F9::
{
	CoordMode "Mouse", "Window"
	ClipSaved := A_Clipboard
	
	; Open Excel DB if it isn't already open
	if not WinExist("WPMID_FDMID_CASEID - Excel")
	{
		Run("WPMID_FDMID_CASEID.xlsm", , )
	}
	
	Sleep 1000
	
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
	
	Sleep 500
	SendClipboard(ClipSaved)
	Sleep 1000
	Click 55, 316
	
	templateText := "
	(
	## {1}
	IF THEY DONT WANT TO DO BUSINESS WITH US ANYMORE, RETRIEVE FAX OR EMAIL FOR CLOSE FORMS.

	BEST CONTACT: 
	BEST PHONE #: 
	BEST DAY/TIME TO CALL: 
	EMAIL: 
	NOTES:
	PRIOR NOTES: none

	DBA NAME: {1}
	FDMS MID: {3}
	WP MID: {2}
	TERMINAL ORDER/QTY: [FD150] [Qty]
	PIN PAD: [Qty]
	TERMINAL FEATURES: [IP or Dial Up (cannot be both)]
	PAYMENT SELECTION: [all up front/installment: 3/130, 6/65, 12/32.50]
	ENTITLEMENTS: [MC/VISA/DISC/AMEX/PIN DEBIT/EBT/Other]
	TIP: [yes/no]
	EMAIL: [required!]
	ACCOUNT UPDATES: [new address, contact, phone, etc]
	SHIPPING ADDRESS:

	)"
	
	Sleep 1000
	
	; Basic info
	coords := [
		{x: 160, y:130}, 
		{x: 180, y:100}
	]
	
	entries := CopyInfo(coords)
	
	; Get FDMID, which is not on CAPS
	focusExcelDB()
	entries.Push(Substr(getFDMID(entries[2]),1,-2)) ; Remove `r`n from Excel copy
	
	;MsgBox "a"
	formatted := Format(templateText, entries[1], entries[2], ( entries[3] = "" ? "no FDMID found" : entries[3]))
	
	; Address info
	coords := [
		{x: 253, y: 196}, 
		{x: 200, y: 220},
		{x: 150, y: 250},
		{x: 332, y: 250},
		{x: 350, y: 280}
	]
	
	WinActivate("CAPS")
	Sleep 500
	
	address := CopyInfo(coords)
	

	; Append shipping address
	formatted .= Format( ( not (address[2] == "") ? ("
	(
	`t{1}
	`t{2}
	`t{3}, {4}
	`t{5}
	)") : "
	(
	`t{1}
	`t{3}, {4}
	`t{5}
	)"), address*)

	

	if WinExist("ahk_exe notepad++.exe")
	{
		WinActivate()
	}
	else
	{
		OpenNotepad()
		Sleep(500)
	}
	
	

	A_Clipboard := formatted

	Send "^n"
	Sleep 200
	Send "^v"

	Sleep 100
	Click 80, 824, "Right"
	Sleep 100
	Click 140, 740
	A_Clipboard := ""

}