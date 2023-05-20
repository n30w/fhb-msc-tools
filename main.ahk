#Requires AutoHotkey v2.0

#Include "windows.ahk"
#Include "workflows.ahk"
#Include "routines.ahk"
#Include "log.ahk"

; globally set CoordMode to Mouse and Window
CoordMode "Mouse", "Window"

fo := FileHandler()
lg := Logger()
ps := Powershell("Powershell",,,)

LogStopReason(ExitReason, ExitCode)
{
	lg.Append(, "===== Stopping due to " . ExitReason . " =====")
}

; initialize shared drive
{
	sharedDrive := fo.Config("Paths", "SharedDrive")
	mountPath := fo.Config("Paths", "MountPath")
	acnamagent := ProcessWait("acnamagent.exe", 18) ; wait to get on local network
	loadShared := True

	if not acnamagent ; local network VPN connection not on
	{
		MsgBox "Unable to load shared drive, check network connection"
		lg.Append(, "Unable to load shared drive, check network connection")
		loadShared := False
	}

	if loadShared && DriveGetStatus(sharedDrive) = "Invalid" ; we're connected and there's no drive available
		Run(ps.OpenShared("openShared.ps1", sharedDrive, mountPath))
}

; build the DataStore for RAM access
DataHandler.BuildStore("resources\data.csv")

; initialize all applications
{
	caps := CapsDB("CAPS",, "CAPS.appref-ms", "CAPS")
	excel := MSExcel("ExcelDB",, "data.xlsm", "data - Excel")
	ol := OutlookMail("Outlook", "C:\Program Files\Microsoft Office\root\Office16", "OUTLOOK.exe", "ahk_exe OUTLOOK.exe")
	aa := AdobeAcrobat("Adobe Acrobat",,, "ahk_exe AcroRd32.exe")
	npp := NotepadPP("Notepad++",, "notepad++.lnk", "ahk_exe notepad++.exe")
	edge := MSEdge("Edge",, "edge.lnk", "ahk_exe msedge.exe")
	sf := SalesforceDB("Salesforce",,,)
	ob := ObsidianVault("Obsidian",, "obsidian.lnk", "ahk_exe Obsidian.exe")
}

; Windows to initalize on script startup
win := Windows(lg, edge, ob, caps, ol)

; initialize routines
routine := Routines(lg, fo)

; open windows if not already open
win.Initialize()

lg.Append(, "System is ready and good to go...")

; Hotkeys
{
	F3::routine.ConvertMIDToCaseID()
	F4:: routine.ViewAuditFolder(win, caps, edge, sf, ps)
	^F4:: routine.GetSalesforceConversionCase(win, edge, sf).OpenAuditFolder(win, caps, edge, sf, ps).ViewAuditPDFs(win, aa)
	F5:: win.FocusWindow(ob)
	^F6:: routine.AddFDMIDToSalesforce(win, edge, sf)
	^F7:: routine.PrepareClosureFormEmail(win, caps, ol)
	^+F7:: routine.PrepareConversionEmail(win, caps, ol)
	F8:: routine.GetCAPSAccount(win, caps)
	^F8:: routine.GetSalesforceConversionCase(win, edge, sf)
	^+F8:: routine.GetCAPSAccount(win, caps).GetSalesforceAccount(win, edge, sf)
	F9:: routine.GenerateOrder(win, caps, ob)
	F10:: routine.DataStoreQuickLook()
	^F11:: routine.ExportPDFSToAudit(win, caps, excel)
}

; Emergency brakes
F12:: ExitApp
^!x:: Reload

OnExit LogStopReason