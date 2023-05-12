#Requires AutoHotkey v2.0

#Include "windows.ahk"
#Include "workflows.ahk"
#Include "routines.ahk"
#Include "log.ahk"

lg := Logger()

Stopped(ExitReason, ExitCode)
{
	lg.Append(, "===== Stopping due to " . ExitReason . " =====")
}

; initialize any external scripts needed for startup

Run("ps\mount.bat")

CoordMode "Mouse", "Window" ; globally set CoordMode to Mouse and Window

; build the DataStore for RAM access

DataHandler.BuildStore("resources\data.csv")

caps := CapsDB("CAPS",, "CAPS.appref-ms", "CAPS")
excel := MSExcel("ExcelDB",, "data.xlsm", "data - Excel")
ol := OutlookMail("Outlook",, "outlook.lnk", "ahk_exe OUTLOOK.exe")
npp := NotepadPP("Notepad++",, "notepad++.lnk", "ahk_exe notepad++.exe")
edge := MSEdge("Edge",, "edge.lnk", "ahk_exe msedge.exe")
sf := SalesforceDB("Salesforce",,,)
ob := ObsidianVault("Obsidian",, "obsidian.lnk", "ahk_exe Obsidian.exe")

; Windows to initalize on script startup
win := Windows(lg, edge, ob, caps)

; Routine gets its own logger
routine := Routines(lg)

win.Initialize() ; open windows if not already open

; Hotkeys

F5:: win.FocusWindow(ob)

^F7:: routine.PrepareClosureFormEmail(win, caps, ol)

F8:: routine.GetCAPSAccount(win, caps)

^F8:: routine.GetSalesforceConversionCase(win, edge, sf)

^+F8:: routine.GetCAPSAccount(win, caps).GetSalesforceAccount(win, edge, sf)

F9:: routine.GenerateOrder(win, caps, ob)

F10:: routine.DataStoreQuickLook()

^F11:: routine.ExportPDFSToAudit(win, caps, excel)

; Emergency brakes

F12:: ExitApp

OnExit Stopped

^!x:: Reload