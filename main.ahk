#Requires AutoHotkey v2.0

#Include "windows.ahk"
#Include "workflows.ahk"
#Include "routines.ahk"
#Include "log.ahk"

; initialize any external scripts needed for startup

lg := Logger("logs\")

Run("ps\mount.bat")

CoordMode "Mouse", "Window" ; Globally set CoordMode to Mouse and Window

DataHandler.BuildStore("resources\data.csv")

caps := CapsDB("CAPS", "resources\CAPS.appref-ms", "CAPS")
excel := MSExcel("ExcelDB", "resources\data.xlsm", "data - Excel")
npp := NotepadPP("Notepad++", "resources\notepad++.lnk", "ahk_exe notepad++.exe")
edge := MSEdge("Edge", "resources\edge.lnk", "ahk_exe msedge.exe")
sf := SalesforceDB("Salesforce", "", "")
ob := ObsidianVault("Obsidian", "resources\obsidian.lnk", "ahk_exe Obsidian.exe")

win := Windows(lg, caps, npp, edge, ob)
routine := Routines()

win.Initialize()

F5:: win.FocusWindow(ob)

F8:: routine.GetCAPSAccount(win, caps)

^F8:: routine.GetSalesforceAccount(win, edge, sf)

^+F8::  routine.GetCAPSAccount(win, caps).GetSalesforceAccount(win, edge, sf)

F9:: routine.GenerateOrder(win, caps, ob)

F10:: routine.DataStoreQuickLook()

^!x:: Reload