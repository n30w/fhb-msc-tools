#Requires AutoHotkey v2.0

#Include "windows.ahk"
#Include "workflows.ahk"
#Include "routines.ahk"
#Include "log.ahk"

; Globally set CoordMode to Mouse and Window.
CoordMode "Mouse", "Window"

; Set where the system logs will be stored.
Logger.SetFilePath(FileHandler.Config("Paths", "SystemLogs"))

; Build the DataStore for RAM access.
DataHandler.BuildStore("resources\data\data.csv")

; Initialize all applications.
{
	caps := CapsDB("CAPS",, "CAPS.appref-ms", "ahk_exe CAPS.exe")
	excel := MSExcel("ExcelDB", FileHandler.Config("Paths", "IOInputPath"), "feecodes.xlsm", "feecodes - Excel")
	ol := OutlookMail("Outlook", "C:\Program Files\Microsoft Office\root\Office16", "OUTLOOK.exe", "ahk_exe OUTLOOK.exe")
	aa := AdobeAcrobat("Adobe Acrobat",,, "ahk_exe AcroRd32.exe")
	npp := NotepadPP("Notepad++",, "notepad++.lnk", "ahk_exe notepad++.exe")
	edge := MSEdge("Edge",, "edge.lnk", "ahk_exe msedge.exe")
	sf := SalesforceDB()
	ob := ObsidianVault("Obsidian",, "obsidian.lnk", "ahk_exe Obsidian.exe")
	ps := Powershell("Powershell",,,)
}

; Initialize shared drive.
{
	Logger.Append(,"Attempting connection to shared drive...")
	sharedDrive := FileHandler.Config("SharedDrive", "LocalWindowsPath")
	mountPath := FileHandler.Config("SharedDrive", "NetworkMountPath")
	acnamagent := ProcessWait("acnamagent.exe", 18) ; wait to get on local network
	loadShared := True

	if not acnamagent ; local network VPN connection not on
	{
		MsgBox "Unable to load shared drive, check network connection"
		Logger.Append(, "Unable to load shared drive, check network connection")
		loadShared := False
	}

	if loadShared && DriveGetStatus(sharedDrive) = "Invalid" ; we're connected and there's no drive available
	{
		Run(ps.OpenShared("openShared.ps1", sharedDrive, mountPath))
		Logger.Append("Shared drive ready to go")
	}
}

; Initialize routines.
{
	dsQuickLookup := DataStoreQuickLookup().Init("DataStoreQuickLookup", apps := {})
	getCAPSPage := GetCAPSAccount().Init("GetCAPSAccount", apps := {caps: caps})
	getSFConversionCase := GetSalesforcePage().Init("GetSalesforcePage", apps := {sf: sf, edge: edge})
	updateAccountFields := UpdateSalesforceFields().Init("UpdateSalesforceFields", 
	apps := {
		fub: fub := FieldUpdaterBookmarklet(), 
		edge: edge, 
		ol: ol
	})
	updateCaseFields := UpdateSalesforceCaseFields().Init("SFUpdate2", 
	apps := {
		cub: cub := CaseUpdaterBookmarklet(), 
		edge: edge, 
		ol: ol
	})
	generateMerchantOrder := GenerateOrder().Init("GenerateOrder",
	apps := {
		ob: ob,
		caps: caps,
		gca: getCAPSPage
	})
}

Routines.Load(updateAccountFields, getCAPSPage, getSFConversionCase, updateCaseFields, dsQuickLookup, generateMerchantOrder)

; Open applications if aren't already open.
Windows.Init(ob, caps, ol)

Logger.Append(, "Session started! Time to make money...")

; Hotkeys
{	
	; F4:: routine.ViewAuditFolder(win, caps, edge, sf, ps)
	; ^F4:: routine.GetSalesforceConversionCase(win, edge, sf).OpenAuditFolder(win, caps, edge, sf, ps).ViewAuditPDFs(win, aa)
	
	F5:: Windows.FocusWindow(ob)
	
	^+F6:: updateAccountFields.Do()
	;^+F6:: updateCaseFields.Do()
	
	; ^F7:: routine.PrepareClosureFormEmail(win, caps, ol)
	; ^+F7:: routine.PrepareConversionEmail(win, caps, ol)
	
	F8:: getCAPSPage.Do()
	^F8:: getSFConversionCase.Do()
	^+F8::
	{
		getCAPSPage.Do()
		getSFConversionCase.Do()
	}
	
	F9:: generateMerchantOrder.Do()
	
	F10:: dsQuickLookup.Do()
	
	; ^F11:: routine.ExportPDFsToAudit(win, caps, excel)
	F11:: caps.Start()
	
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
}

OnExit LogStopReason

LogStopReason(ExitReason, ExitCode)
{
	Routines.Cease()
	Logger.Append(, "===== Stopping due to " . ExitReason . " =====")
}