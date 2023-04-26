GetDBA(e)
{
	Click, 160, 130
	Send ^c
	e.Push(Clipboard)
	Clipboard :=
	return
}

GetWPMID(e)
{
	Click, 180, 100
	Send ^c
	e.Push(Clipboard)
	Clipboard :=
	return
}

GetStoreAddr1(a)
{
	Click, 253, 196
	Send ^c
	a.Push(Clipboard)
	Clipboard :=
	return 
}

GetStoreAddr2(a) 
{
	Click, 200, 220
	Send ^c
	a.Push(Clipboard)
	Clipboard :=
	return 
}

GetBillCity(a)
{
	Click, 150, 250
	Send ^c
	a.Push(Clipboard)
	Clipboard :=
	return
}

GetBillState(a)
{
	Click, 332, 250
	Send ^c
	a.Push(Clipboard)
	Clipboard :=
	return
}

GetBillZip(a)
{
	Click, 350, 280
	Send ^c
	a.Push(Clipboard)
	Clipboard :=
	return 
}

GetFDMID(e)
{
	Send ^c
	e.Push(Clipboard)
	Clipboard :=
	return 
}

; Given an array of coordinates, copys and appends the data it finds.
CopyInfo(a, b) 
{
	Clipboard :=
	for p in a 
	{
		MsgBox %p%[1] p.x
		Click p.x p.y
		Send ^c
		b.Push(Clipboard)
		Clipboard :=
	}
	return
}


OpenNotepad()
{
	Run "C:\Users\ralabastro\Desktop\npp.8.5.2.portable\notepad++.exe"
	Sleep 200
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
	SendInput %c%
	Click, 168, 116
	Sleep 1000
	Click, 55, 316
}

OpenCaps() 
{
	Run "C:\Users\ralabastro\AppData\Local\Apps\2.0\DJVY1VY9.CG0\M17B2GO8.4ME\caps..tion_57d36b76fd0aefc8_0004.0006_4976a6dff7a6e371\CAPS.exe"
	NavigateCaps()
	return
}

F9::
ClipSaved := Clipboard
entries := Array()
address := Array()
if WinExist("ahk_exe CAPS.exe")
{
	WinActivate
	Click, 30, 66
	MouseMove, 170, 115
	SendClipboard(ClipSaved)
}
else
{
	OpenCaps()
	Sleep 500
	SendClipboard(ClipSaved)
	Sleep 1000
}

templateText := "
(
## {1:s}
IF THEY DONT WANT TO DO BUSINESS WITH US ANYMORE, RETRIEVE FAX OR EMAIL FOR CLOSE FORMS.

BEST CONTACT: 
BEST PHONE #: 
BEST DAY/TIME TO CALL: 
EMAIL: 
NOTES:
PRIOR NOTES: none

DBA NAME: {1:s}
FDMS MID: 
WP MID: {2:s}
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

; Basic info
;coords := [{x: 160, y:130}, {x: 180, y:100}]
;coords := [ a := [160, 130], b:= [180, 100]]
;CopyInfo(coords, entries)
GetDBA(entries)
GetWPMID(entries)

formatted := Format(templateText, entries*)

; Address info
GetStoreAddr1(address)
GetStoreAddr2(address)
GetBillCity(address)
GetBillState(address)
GetBillZip(address)

; Append shipping address
formatted .= Format( ( not (address[2] == "") ? ("
(
`t{1:s}
`t{2:s}
`t{3:s}, {4:s}
`t{5:s}
)") : "
(
`t{1:s}
`t{3:s}, {4:s}
`t{5:s}
)"), address*)

if WinExist("ahk_exe notepad++.exe")
{
	WinActivate
}
else
{
	OpenNotepad()
	Sleep 500
}

Send ^n
A_Clipboard = %formatted%
Send ^v

Click 80 824 Right
Click 140 740

return

^!x::ExitApp