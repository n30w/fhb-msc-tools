#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"
#Include "log.ahk"

class Routines
{
	__New(logger, fileOps)
	{
		this.logger := logger
		this.fileOps := fileOps
		this.clock := Timer()
		this.data := DataHandler()
		this.RoutineList := Array()
		this.sharedDrive := this.fileOps.Config("Paths", "SharedDrive")
	}

	; Load routines into RoutineList
	Load(routines*)
	{
		for routine in routines
		{
			this.RoutineList.Push(routine)
		}
	}

	StopAll()
	{
		for routine in this.RoutineList
		{
			if routine.IsActive()
				routine.Butcher()
		}
	}

	; Attaches something to clippy and pastes it.
	AttachAndPaste(s)
	{
		this.data.cb.Attach(s)
		Sleep 250
		this.data.cb.Paste()
	}
	
	; Searches CAPS for a single MID.
	GetCAPSAccount(win, caps)
	{
		mid := this.data.cb.Update()
		mid := DataHandler.Sanitize(mid)

		if Clippy.IsEmpty(mid)
			return this

		win.FocusWindow(caps)
		caps.clickBinocularAndSearch(mid)
		Sleep 200
		Clippy.Shove(mid)
		return this
	}
	
	; Pulls up account view on Salesforce.
	GetSalesforceAccount(win, edge, sf)
	{
		mid := this.data.cb.Update()
		mid := DataHandler.Sanitize(mid)
		
		if Clippy.IsEmpty(mid)
			return this

		try
		{
			this.data.cb.Board := sf.AccountURL(DataHandler.Retrieve(mid).AccountID)
		}
		catch
		{
			DoesNotExist(this.GetSalesforceAccount.Name, this.logger, mid)
			return
		}
		
		win.FocusWindow(edge)
		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		edge.FocusURLBar()
		this.data.cb.Paste()
		Send "{Enter}"
		this.data.cb.Clean()
		return this
	}

	; Pulls up account view on Salesforce.
	GetSalesforceConversionCase(win, edge, sf)
	{
		mid := ""
		if IsSet(m)
			mid := m
		else
		{
			mid := DataHandler.Sanitize(A_Clipboard)
		}
		
		try
		{
			this.data.cb.Board := sf.CaseURL(DataHandler.Retrieve(mid).CaseID)
		}
		catch
		{
			DoesNotExist(this.GetSalesforceConversionCase.Name, this.logger, mid)
			return
		}
		Sleep 500
		win.FocusWindow(edge)
		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		else
			edge.FocusURLBar()
		this.data.cb.Paste()
		Send "{Enter}"
		Clippy.Shove(mid)
		Sleep 500
		return this
	}

	; From a text file, add FDMID to Salesforce if it doesn't exist.
	AddFDMIDToSalesforce(win, edge, sf)
	{
		this.data.cb.Clean()
		merchants := FileHandler.TextToMerchantArray("addfdmidtosf.txt")
		au := ""
		fdmid := ""
		
		win.FocusWindow(edge)
		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		for m in merchants
		{
			try
			{
				au := sf.AccountURL(DataHandler.Retrieve(m.wpmid).AccountID)
			}
			catch
			{
				this.logger.Append(this.ConvertMIDToCaseID.Name, "ERROR: Unable to retrieve merchant AccountID => " . m.wpmid . " does not exist in DataStore")
				continue
			}
			
			fdmid := DataHandler.Retrieve(m.wpmid).FDMID

			edge.FocusURLBar()
			Clippy.Shove(au)
			Send "^v"
			Sleep 100
			Send "{Enter}"
			this.data.cb.Clean()
			Sleep 4000
			sf.UpdateFDMID(fdmid)
			Sleep 1700
		}

		MsgBox "FDMIDs all have been added to Salesforce"
	}

	; From a text file, update every FDMID conversion date on Salesforce.
	AddConversionDateToSalesforce(win, edge, sf)
	{
		funcName := this.getFuncName(A_ThisFunc)

		stopwatch := Timer()
		statBar := StatusBar()
		
		str := ""
		inPath := FileHandler.Config("Paths", "TempCSV")
		outPath := FileHandler.Config("Resources", funcName)
		routineLogfile := Logger(FileHandler.Config("Paths", "RoutineLogs") . funcName . "\")
		
		csv := FileHandler(inPath, outPath, funcName)

		merchants := FileHandler.TextToMerchantAndDateArray("addconvdatetosf.txt")
		accountIDs := DataHandler(FileHandler.Config("Resources", "AccountIDs"))
		parseMap := DataHandler(outPath)
		
		this.logger.Append(funcName, "Started")
		
		stopwatch.StartTimer()
		
		win.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		for m in merchants
		{
			this.data.cb.Clean()

			statBar.Show("Merchant: " . A_Index . "/" . merchants.length . "`r`n" . "Total: " . parseMap.Retrieve(m.wpmid).OrderIndex . "/" . parseMap.DsLength//parsemap.Cols.length)

			sfUpdated := parseMap.IsParsed(m.wpmid)

			if sfUpdated
				continue

			urlExists := sf.HasURL(this.logger, m, accountIDs)
			
			if urlExists
			{
				edge.FocusURLBar()
				edge.PasteURLAndGo(sf.FullURL)

				Clippy.Shove("none")

				sf.UpdateConversionDate(m.newDate)
				orderIndex := parseMap.Retrieve(m.wpmid).OrderIndex
				parseMap.SetParsed(orderIndex)
				
				this.logger.Append(funcName, m.wpmid . " updated")

				Sleep 2000
			}
			else
			{
				routineLogfile.Append(, m.wpmid . " does not exist on Salesforce")
				continue
			}
			str := parseMap.DataStoreToFileString(csv.Scheme)
			csv.StringToCSV(str)
		}

		stopwatch.StopTimer()

		this.logger.Timer(merchants.length . " merchant account closed dates checked and/or updated.", stopwatch)

		statBar.Reset()

		this.PrepareAndSendNotificationEmail(win, ol, funcName, stopwatch.ElapsedTime())

		MsgBox "Conversion dates updated"
	}

	; From a text file, update every account's closed date on Salesforce.
	AddClosedDateToSalesforce(win, edge, sf)
	{
		funcName := this.getFuncName(A_ThisFunc)

		stopwatch := Timer()
		statBar := StatusBar()
		
		str := ""
		inPath := FileHandler.Config("Paths", "TempCSV")
		outPath := FileHandler.Config("Resources", funcName)
		routineLogfile := Logger(FileHandler.Config("Paths", "RoutineLogs") . funcName . "\")
		
		csv := FileHandler(inPath, outPath, funcName)

		merchants := FileHandler.TextToMerchantAndDateArray("addcloseddatetosf.txt")
		accountIDs := DataHandler(FileHandler.Config("Resources", "AccountIDs"))
		parseMap := DataHandler(outPath)
		
		this.logger.Append(funcName, "Started")
		
		stopwatch.StartTimer()
		
		win.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		for m in merchants
		{
			this.data.cb.Clean()

			statBar.Show("Merchant: " . A_Index . "/" . merchants.length . "`r`n" . "Total: " . parseMap.Retrieve(m.wpmid).OrderIndex . "/" . parseMap.DsLength//parsemap.Cols.length)

			sfUpdated := parseMap.IsParsed(m.wpmid)

			if sfUpdated
				continue

			urlExists := sf.HasURL(this.logger, m, accountIDs)
			
			if urlExists
			{
				edge.FocusURLBar()
				edge.PasteURLAndGo(sf.FullURL)

				Clippy.Shove("none")

				sf.UpdateClosedDate(m.newDate)
				orderIndex := parseMap.Retrieve(m.wpmid).OrderIndex
				parseMap.SetParsed(orderIndex)
				
				this.logger.Append(funcName, m.wpmid . " updated")

				Sleep 2000
			}
			else
			{
				routineLogfile.Append(, m.wpmid . " does not exist on Salesforce")
				continue
			}
			str := parseMap.DataStoreToFileString(csv.Scheme)
			csv.StringToCSV(str)
		}

		stopwatch.StopTimer()

		this.logger.Timer(merchants.length . " merchant account closed dates checked and/or updated.", stopwatch)

		statBar.Reset()

		this.PrepareAndSendNotificationEmail(win, ol, funcName, stopwatch.ElapsedTime())

		MsgBox "Closed dates updated"
	}

	; From a text file, update every account's closed date on Salesforce.
	AddOpenDateToSalesforce(win, edge, sf)
	{
		funcName := this.getFuncName(A_ThisFunc)

		stopwatch := Timer()
		statBar := StatusBar()
		
		str := ""
		idx := 0
		realTotal := 0

		inPath := FileHandler.Config("Paths", "TempCSV")
		outPath := FileHandler.Config("Resources", funcName)
		routineLogfile := Logger(FileHandler.Config("Paths", "RoutineLogs") . funcName . "\")
		
		csv := FileHandler(inPath, outPath, funcName)

		merchants := FileHandler.TextToMerchantAndDateArrayRetainYear("addopendatetosf.txt")
		accountIDs := DataHandler(FileHandler.Config("Resources", "AccountIDs"))
		parseMap := DataHandler(outPath)
		
		this.logger.Append(funcName, "Started")
		
		stopwatch.StartTimer()
		
		win.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		for m in merchants
		{
			this.data.cb.Clean()
			
			idx := parseMap.Retrieve(m.wpmid).OrderIndex
			realTotal := parseMap.DsLength//parsemap.Cols.length

			statBar.Show("Merchant: " . A_Index . "/" . merchants.length . "`r`n" . "Total: " . idx . "/" . realTotal)

			sfUpdated := parseMap.IsParsed(m.wpmid)

			if sfUpdated
				continue

			urlExists := sf.HasURL(this.logger, m, accountIDs)
			
			if urlExists
			{
				edge.FocusURLBar()
				edge.PasteURLAndGo(sf.FullURL)

				Clippy.Shove("none")

				sf.UpdateOpenDate(m.newDate)
				orderIndex := parseMap.Retrieve(m.wpmid).OrderIndex
				parseMap.SetParsed(orderIndex)
				
				this.logger.Append(funcName, m.wpmid . " updated")

				Sleep 2000
			}
			else
			{
				routineLogfile.Append(, m.wpmid . " does not exist on Salesforce")
				continue
			}
			str := parseMap.DataStoreToFileString(csv.Scheme)
			csv.StringToCSV(str)
		}

		stopwatch.StopTimer()

		this.logger.Timer(merchants.length . " merchant account closed dates checked and/or updated.", stopwatch)

		statBar.Reset()

		body := "Total converted: " . idx . " of " . realTotal . "`r`nTime Elapsed: " .  stopwatch.ElapsedTime()
		this.PrepareAndSendNotificationEmail(win, ol, funcName, stopwatch.ElapsedTime(), body)

		MsgBox "Open dates updated"
	}
	
	; Gets data from CAPS and puts it into email order template.
	GenerateOrder(win, caps, ob)
	{
		wp := DataHandler.Sanitize(this.data.cb.Update())

		if Clippy.IsEmpty(wp)
			return this

		dba := ""
		fdmid := ""
		fileExists := False
		dbaExistsInDataStore := True
		fdmidExistsInDataStore := True

		try
		{
			; retrieve dba from DataStore
			dba := DataHandler.Retrieve(wp).AccountName
		}
		catch
		{
			; if not in DataStore open caps and get the DBA from there
			dbaExistsInDataStore := False
		}

		try
		{
			; retrieve fdmid from DataStore
			fdmid := DataHandler.Retrieve(wp).FDMID ;( fdmid = "" ? "no FDMID found" : fdmid )
		}
		catch
		{
			fdmidExistsInDataStore := False
		}
		
		; first check if the file even exists in merchant dir
		fileName := FileHandler.RetrievePath("..\merchants", dba, "md")
		if not (fileName = "none")
			fileExists := True
			
		if fileExists
		{
			win.FocusWindow(ob)
			ob.OpenOpenMenu(dba)
		}
		else
		{	
			tt := ob.templateText
			
			; copy stuff from CAPS
			Clippy.Shove(wp)
			
			this.GetCAPSAccount(win, caps)
			wp := DataHandler.Sanitize(this.data.cb.Board)
			
			Sleep 2100
			

			if not fdmidExistsInDataStore
				fdmid := "=== check salesforce ==="

			this.data.CopyFields(
				caps.DBA,
				caps.StoreAddr1,
				caps.StoreAddr2,
				caps.StoreCity,
				caps.StoreState,
				caps.StoreZip
			)

			if not dbaExistsInDataStore
				dba := caps.DBA.val

			; format data into a string
			formattedTemplate := Format(
				tt, 
				dba,
				wp,
				fdmid
			)
			
			; create shipping address, varies if StoreAddr2 has val
			formattedTemplate .= Format( ( not (caps.StoreAddr2.val = "") ? ("
			(
			`n`t{1}
			`t{2}
			`t{3}, {4}
			`t{5}

			---`n
			)") : "
			(
			`n`t{1}
			`t{3}, {4}
			`t{5}

			---`n
			)"), caps.StoreAddr1.val, caps.StoreAddr2.val, caps.StoreCity.val, caps.StoreState.val, caps.StoreZip.val) . ( caps.StoreState.val = "HI" ? "#Hawaii" : "#Guam-Saipan" ) . "`r`n"
			
			; import that formatted data into obsidian onto new document
			win.FocusWindow(ob)
			ob.OpenOpenMenu(( caps.StoreState.val = "HI" ? "Hawaii/" : "Guam-Saipan/" ) . dba)
			this.AttachAndPaste(formattedTemplate)
		}
		Clippy.Shove(wp)
		return this
	}

	; Exports CAPS and Excel PDFs to corresponding folders for auditing purposes.
	ExportPDFsToAudit(win, caps, excel)
	{
		if YesNoBox("Is CAPS print to PDF setup to the correct folder?") = "No"
		 	return

		if win.WinExists(caps)
			caps.Stop()

		statBar := StatusBar()

		accountNames := DataHandler("resources\accountNames.csv")
		outFile := Format(this.fileOps.Config("Paths", "RoutineLogs") . "ExportPDFSToAudit-{1}.txt", this.logger.getFileDateTime())
		LoadingZone := this.fileOps.Config("Paths", "IOOutputPath") . "auditing\"
		merchants := FileHandler.TextToMerchantArray("midtopdf.txt")

		funcName := this.getFuncName(A_ThisFunc)

		this.logger.append(funcName, "Starting export...")		
		
		stopwatch := Timer()
		stopwatch.StartTimer()
		
		for merchant in merchants
		{
			try merchant.dba := DataHandler.Retrieve(merchant.wpmid).AccountName
			catch
				merchant.dba := accountNames.Retrieve(merchant.wpmid).AccountName
			
			statdba := merchant.dba
			msg := "
			(
			{1}/{2}: {3}
			{4}
			)"
			
			statBar.Show(Format(msg, A_Index, merchants.length, statdba, "Processing"))

			MerchantDir := Format(LoadingZone . "directories\{1}\2023.FDMS conversion\", StrReplace(merchant.dba, "."))
			
			CAPSPDFName := "CAPS fees - " . merchant.wpmid
			FDMIDPDFName := "FDMID code listing - " . merchant.wpmid
			
			currentCAPSPDFPath := LoadingZone . CAPSPDFName . ".pdf"
			currentFDMSPDFPath := LoadingZone . FDMIDPDFName . ".pdf"
			
			; If there are no matching DBAs, make a new folder.
			if not DirExist(MerchantDir)
				DirCreate MerchantDir
			
			; If CAPS fee doesn't exist, access CAPS and create pdf.
			CAPSFeePDFDoesNotExist := !(FileExist(MerchantDir . CAPSPDFName . ".pdf"))
			if CapsFeePDFDoesNotExist
			{
				Clippy.Shove(merchant.wpmid)
				win.FocusWindow(caps)
				caps.clickBinocularAndSearch(merchant.wpmid)
				caps.SaveCAPSFeesPDF(CAPSPDFName)
				try FileMove currentCAPSPDFPath, MerchantDir, 1
				catch as e
				{
					this.logger.Append(caps, Format("{1} {2} {3} - ERROR: {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
					FileDelete currentCAPSPDFPath
				}
				Sleep 1000
			}
			
			Clippy.Shove("")
			
			; Generate PDF from Account Fee code listing document.
			FDMIDFeePDFDoesNotExist := !(FileExist(MerchantDir . FDMIDPDFName . ".pdf"))
			if FDMIDFeePDFDoesNotExist
			{
				noteName := merchant.wpmid . " " . merchant.fdmid . " has no FDMID listed"
				if not FileExist(MerchantDir . noteName . ".txt")
				{
					win.FocusWindow(excel)
					excel.FilterColumnMacro(merchant.fdmid)
					
					; "`r`n" is a value returned from the Excel Macro
					if A_Clipboard = "`r`n" ; current FDMID is not in the list
					{
						;updateStatusBar("Current merchant has no fee codes... making note of that")
						FileAppend(noteName, MerchantDir . "\" . noteName . ".txt")
						this.logger.Append(excel, merchant.dba . " " . merchant.fdmid . " has no listings in Account Fee Code Listings")
						Clippy.Shove("")
						Sleep 300
					}
					else
					{
						;updateStatusBar("Exporting FDMID Fee Codes PDF")
						Clippy.Shove(FDMIDPDFName)
						excel.DefaultPDFSaveMacro()
						try FileMove currentFDMSPDFPath, MerchantDir, 1
						catch as e
						{
							this.logger.Append(caps, Format("{1} {2} {3} - ERROR: {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
							FileDelete currentFDMSPDFPath
						}
						Sleep 1200
					}
				}
			}
			
			this.logger.Append(funcName, "Export of " .  merchant.dba . " " . merchant.wpmid . " " . merchant.fdmid . " completed")
			FileAppend(merchant.wpmid . "`t" . merchant.fdmid . "`r`n", outFile)

			Clippy.Shove("")
		}
		
		Send "{Esc 1}"

		statBar.Reset()

		stopwatch.StopTimer()
		this.logger.Timer(merchants.length . " merchants exported.", stopwatch)
		
		MsgBox "PDF Export Complete"
	}
	
	; Creates a closure email in Outlook given a MID.
	PrepareClosureFormEmail(win, caps, ol)
	{
		wpmid := A_Clipboard
		
		if Clippy.IsEmpty(wpmid)
			return this

		dba := ""
		mdPath := ""
		email := "Not Found"

		; Regex pattern for emails, kindly given by ChatGPT
		emailPattern := "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"

		try
		{
			dba := DataHandler.Retrieve(wpmid).AccountName
		}
		catch
		{
			; if it doesn't exist in DS, go to CAPS to get it
			win.FocusWindow(caps)
			this.data.CopyFields(caps.DBA)
			dba := caps.DBA.val
		}
		
		; get email from .md file
		; get name of .md file
		mdPath := FileHandler.RetrievePath("..\merchants", dba, "md")
		email := FileHandler.MatchPatternInFile(mdPath, emailPattern)

		win.FocusWindow(ol)
		Sleep 100
		ol.AccessMenuItem("y")
		ol.SendClosureMacro()
		Sleep 100
		
		; email[] because the brackets return the sub pattern
		; https://www.autohotkey.com/docs/v2/lib/RegExMatch.htm#MatchObject
		ol.To(email[]).CC().Subject("Close Account Request Form - " . dba . " (" . wpmid . ")").Body()
	}

	; Creates a conversion email in Outlook given a MID.
	PrepareConversionEmail(win, caps, ol)
	{
		wpmid := A_Clipboard

		if Clippy.IsEmpty(wpmid)
			return this

		dba := ""
		mdPath := ""
		order := ""

		try
		{
			dba := DataHandler.Retrieve(wpmid).AccountName
		}
		catch
		{
			; if it doesn't exist in DS, go to CAPS to get it
			win.FocusWindow(caps)
			Sleep 300
			this.data.CopyFields(caps.DBA)
			dba := caps.DBA.val
		}
		
		; Find the correct md file to read
		mdPath := FileHandler.RetrievePath(FileHandler.Config("Paths", "MerchantMDs"), dba, "md")
		
		if mdPath = "none"
		{
			MsgBox "Unable to retrieve .md path"
		}
		else
		{
			order := this.fileOps.ReadOrder(mdPath)		
		}
		
		win.FocusWindow(ol)
		Sleep 100
		ol.AccessMenuItem("y").SendOrderMacro()

		WinWaitActive "Ready For Conversion -  - Message (Rich Text) "

		ol.GoToSubjectLineFromBody()
		Send "{End}"
		Send dba . " (" . wpmid . ")"
		ol.GoToMiddleOfBodyFromSubjectLine()
		
		Send order
	}

	; Prepares and sends a notification email about a routine that has finished, or anything for that matter.
	PrepareAndSendNotificationEmail(win, ol, routineName, elapsedTime, customText?)
	{
		subject := "[ROUTINE COMPLETE] " . routineName .  " - " . Logger.GetFileDateTime()
		body := routineName . " finished in " . elapsedTime

		if IsSet(customText)
			body := customText

		win.FocusWindow(ol)
		ol.CreateNewEmail().To(FileHandler.Config("Fields", "MyEmail")).CC().Subject(subject).Body(body)
		Sleep 1000
		ol.SendEmail()
		this.logger.Append(this.getFuncName(A_ThisFunc), "Email notification sent!")
	}

	; Opens the PDFs in an audit folder given MID.
	OpenAuditFolder(win, caps, edge, sf, ps, wpmid?)
	{
		mid := ""
		if IsSet(wpmid)
			mid := wpmid
		else
		{
			mid := this.data.cb.Update()
			mid := DataHandler.Sanitize(mid)
			if Clippy.IsEmpty(mid)
				return this
		}
		
		folderName := this.tryGetDBA(win, caps, this.data, mid)
		
		Run(ps.ShowAuditFolder("matchThenOpenPDF.ps1", folderName))

		return this
	}

	; Opens a folder from shared drive using MID. 
	ViewAuditFolder(win, caps, edge, sf, ps, wpmid?)
	{
		mid := ""
		if IsSet(wpmid)
			mid := wpmid
		else
		{
			mid := this.data.cb.Update()
			mid := DataHandler.Sanitize(mid)
			if Clippy.IsEmpty(mid)
				return this
		}
		
		psFile := A_WorkingDir . "\powershell\matchFolder.ps1"
		
		folderName := this.tryGetDBA(win, caps, this.data, mid)

		Run(ps.Match(psFile, this.sharedDrive, folderName))

		return this
	}

	; Moves already open Audit Fee PDFs to corresponding spaces on the screen.
	ViewAuditPDFs(win, aa)
	{
		WinWaitActive aa.Ref
		Sleep 2000
		win.FocusWindow(aa)
		wx := 0
		WinGetPos(&wx,,,,WinGetTitle("A"))
		if WinWaitActive("ahk_class AcrobatSDIWindow",,5)
		{
			if wx > 1920
			win.MoveToLeftScreen(aa)
			else
				win.MoveToRightScreen(aa)
			aa.GoToFinalPage()
		}
		return this
	}

	ConvertMIDToCaseID()
	{
		this.logger.Append(this.ConvertMIDToCaseID.Name, "Started!")
		outFile := Format(this.fileOps.Config("Paths", "OutputPath") . "GetMIDCaseID-{1}.txt", this.logger.getFileDateTime())
		ci := ""
		merchants := FileHandler.TextToMerchantArray("midtocaseid.txt")

		for m in merchants 
		{
			try
			{
				ci := DataHandler.Retrieve(DataHandler.Sanitize(m.wpmid)).CaseID
			}
			catch
			{
				this.logger.Append(this.ConvertMIDToCaseID.Name, "ERROR: Unable to retrieve merchant caseID => " . m.wpmid . " does not exist in DataStore")
				continue
			}
			FileAppend(ci . "`r`n", outFile)
		}
		this.logger.Append(this.ConvertMIDToCaseID.Name, "Completed!")
		MsgBox "Convert Mid to Case ID complete"
	}

	; Given any merchant attribute, opens a small window with fields from that entry point.
	DataStoreQuickLook()
	{
		c := this.data.cb.Update()
		if Clippy.IsEmpty(c)
			return this
		try
		{
			r := DataHandler.Retrieve(DataHandler.Sanitize(c))
		}
		catch
		{
			DoesNotExist(this.DataStoreQuickLook.Name, this.logger, c)
			return
		}
		
		s := ""
		for k, v in r.OwnProps()
		{
			s .= k . ": " . v . "`n" 
		}
		
		MsgBox(s, "Lookup " . c)
	}

	tryGetDBA(win, caps, data, wpmid?)
	{
		mid := ""
		if IsSet(wpmid)
			mid := wpmid
		else
		{
			mid := this.data.cb.Update()
			mid := DataHandler.Sanitize(mid)
		}

		try
		{
			dba := DataHandler.Retrieve(mid).AccountName
		}
		catch
		{
			; if it doesn't exist in DS, go to CAPS to get it
			win.FocusWindow(caps)
			caps.clickBinocularAndSearch(mid)
			dba := data.CopyFields(caps.DBA)
			Sleep 200
		}
		return dba
	}

	getFuncName(str)
	{
		arr := StrSplit(str, ".")
		return arr[arr.length]
	}
}

; class RoutineObject
; {
; 	active := False
; 	paused := False
; 	uptime := Timer()
; 	process := Timer()

; 	__New(logger)
; 	{
; 		this.logger := logger
; 	}

; 	IsActive() => this.active

; 	IsPaused() => this.paused

; 	Do()
; 	{
; 		this.Begin()
; 		; ...
; 	}

; 	Begin()
; 	{
; 		this.active := True
; 		this.paused := False
; 		this.uptime.StartTimer()
; 		this.process.StartTimer()
; 	}

; 	Hold()
; 	{
; 		this.paused := True
; 		this.process.StopTimer()
; 	}

; 	Resume()
; 	{
; 		this.paused := False
; 		this.process.StartTimer()
; 	}

; 	Butcher()
; 	{
; 		this.active := False
; 		this.paused := False
; 		this.process.StopTimer()
; 		this.uptime.StopTimer()
; 	}

; 	Stop()
; 	{
; 		this.Butcher()
; 	}
; }

; class UpdateSalesforceFields extends RoutineObject
; {
; 	__New(logger, apps, name, file)
; 	{
; 		this.logger := logger
; 		this.apps := apps
; 		this.name := name
		
; 		this.statBar := StatusBar()
; 		this.routineLogFile := Logger(FileHandler.Config("Paths", "RoutineLogs") . this.name . "\")
; 		this.inPath := FileHandler.Config("Paths", "TempCSV")
; 		this.outPath := FileHandler.Config("Resources", this.name)
; 		this.csv := FileHandler(inPath, outPath, this.name)
; 		this.merchants := FileHandler.TextToMerchantAndDateArrayRetainYear(file)
; 		this.accountIDs := DataHandler(FileHandler.Config("Resources", "AccountIDs"))
; 		this.parseMap := DataHandler(outPath)
; 		this.realTotal := parseMap.DsLength//parsemap.Cols.length
; 	}

; 	Do()
; 	{
; 		this.Begin()

; 		this.logger.Append(funcName, "Started")
		
; 		this.apps.win.FocusWindow(this.apps.edge)

; 		if not edge.TabTitleContains("Salesforce")
; 			edge.NewTab()
		
; 		for m in merchants
; 		{
			
; 			idx := parseMap.Retrieve(m.wpmid).OrderIndex

; 			statBar.Show("Merchant: " . A_Index . "/" . merchants.length . "`r`n" . "Total: " . idx . "/" . realTotal)

; 			Clippy.Shove("")

; 			sfUpdated := parseMap.IsParsed(m.wpmid)

; 			if sfUpdated
; 				continue

; 			urlExists := sf.HasURL(this.logger, m, accountIDs)
			
; 			if urlExists
; 			{
; 				edge.FocusURLBar()
; 				edge.PasteURLAndGo(sf.FullURL)

; 				Clippy.Shove("none")

; 				sf.UpdateOpenDate(m.newDate)
; 				orderIndex := parseMap.Retrieve(m.wpmid).OrderIndex
; 				parseMap.SetParsed(orderIndex)
				
; 				this.logger.Append(funcName, m.wpmid . " updated")

; 				Sleep 2000
; 			}
; 			else
; 			{
; 				routineLogfile.Append(, m.wpmid . " does not exist on Salesforce")
; 				continue
; 			}
; 			str := parseMap.DataStoreToFileString(csv.Scheme)
; 			csv.StringToCSV(str)
; 		}

; 		this.logger.Timer(merchants.length . " merchant account closed dates checked and/or updated.", this.process)

; 		statBar.Reset()

; 		body := "Total converted: " . idx . " of " . realTotal . "`r`nTime Elapsed: " .  this.process.ElapsedTime()
; 		this.PrepareAndSendNotificationEmail(win, ol, this.name, this.process.ElapsedTime(), body)
		
; 		this.Stop()
		
; 		MsgBox "Open dates updated"
; 	}
; }