#Requires AutoHotkey v2.0

#Include "windows.ahk"
#Include "workflows.ahk"
#Include "routines.ahk"
#Include "log.ahk"

; globally set CoordMode to Mouse and Window
CoordMode "Mouse", "Window"

fo := FileHandler()
lg := Logger(fo.Config("Paths", "SystemLogs"))
ps := Powershell("Powershell",,,)

Logger.SetFilePath(fo.Config("Paths", "SystemLogs"))

LogStopReason(ExitReason, ExitCode)
{
	Routines.Cease()
	Logger.Append(, "===== Stopping due to " . ExitReason . " =====")
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
		Logger.Append(, "Unable to load shared drive, check network connection")
		loadShared := False
	}

	if loadShared && DriveGetStatus(sharedDrive) = "Invalid" ; we're connected and there's no drive available
		Run(ps.OpenShared("openShared.ps1", sharedDrive, mountPath))
}

; build the DataStore for RAM access
DataHandler.BuildStore("resources\data\data.csv")

; initialize all applications
{
	caps := CapsDB("CAPS",, "CAPS.appref-ms", "ahk_exe CAPS.exe")
	excel := MSExcel("ExcelDB", fo.Config("Paths", "IOInputPath"), "feecodes.xlsm", "feecodes - Excel")
	ol := OutlookMail("Outlook", "C:\Program Files\Microsoft Office\root\Office16", "OUTLOOK.exe", "ahk_exe OUTLOOK.exe")
	aa := AdobeAcrobat("Adobe Acrobat",,, "ahk_exe AcroRd32.exe")
	npp := NotepadPP("Notepad++",, "notepad++.lnk", "ahk_exe notepad++.exe")
	edge := MSEdge("Edge",, "edge.lnk", "ahk_exe msedge.exe")
	sf := SalesforceDB()
	ob := ObsidianVault("Obsidian",, "obsidian.lnk", "ahk_exe Obsidian.exe")
}

; windows to initialize on script startup
win := Windows(lg, ob, caps, ol)

; initialize routines
routine := Routines(lg, fo)

getCAPSPage := GetCAPSAccount().Init("GetCAPSAccount", apps := {caps: caps})
updateAccountFields := UpdateSalesforceFields().Init("UpdateSalesforceFields", apps := {fub: fub := FieldUpdaterBookmarklet(), edge: edge, ol: ol})
getSFConversionCase := GetSalesforcePage().Init("GetSalesforcePage", apps := {sf: sf})
updateCaseFields := UpdateSalesforceCaseFields().Init("SFUpdate2", apps := {cub: cub := CaseUpdaterBookmarklet(), edge: edge, ol: ol})

Routines.Load(updateAccountFields, getCAPSPage, getSFConversionCase, updateCaseFields)

; open windows if not already open
win.Initialize()

Logger.Append(, "Session started! Time to make money...")

; Hotkeys
{	
	F3::routine.ConvertMIDToCaseID()
	
	F4:: routine.ViewAuditFolder(win, caps, edge, sf, ps)
	^F4:: routine.GetSalesforceConversionCase(win, edge, sf).OpenAuditFolder(win, caps, edge, sf, ps).ViewAuditPDFs(win, aa)
	
	F5:: Windows.FocusWindow(ob)
	
	^+F6:: updateAccountFields.Do()
	;^+F6:: updateCaseFields.Do()
	
	^F7:: routine.PrepareClosureFormEmail(win, caps, ol)
	^+F7:: routine.PrepareConversionEmail(win, caps, ol)
	
	F8:: getCAPSPage.Do()
	^F8:: getSFConversionCase.Do()
	^+F8:: routine.GetCAPSAccount(win, caps).GetSalesforceAccount(win, edge, sf)
	
	F9:: routine.GenerateOrder(win, caps, ob)
	
	F10:: routine.DataStoreQuickLook()
	
	^F11:: routine.ExportPDFsToAudit(win, caps, excel)
	F11:: caps.Start()
}

; Emergency brakes
F12::
{
	Critical
	ExitApp
}
^!x::
{
	Critical
	Reload
}

OnExit LogStopReason