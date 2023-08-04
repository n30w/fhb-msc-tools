#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"
#Include "log.ahk"

class Routines
{
	static RoutineList := Queue()

	; Load wanted routines into the Singleton RoutineList.
	static Load(rs*)
	{
		Logger.Append(, "Loading Routines...")
		Loop rs.length
		{
			Routines.RoutineList.Enqueue(rs[A_Index])
		}
		Logger.Append(, "Routines ready to go")
	}

	; Cease destroys all current running routines.
	static Cease()
	{
		while Routines.RoutineList.Length() > 0
		{
			elm := Routines.RoutineList.Dequeue()
			if elm.IsActive()
			{
				elm.Butcher()
				Logger.Append(, "///BUTCHERED/// " . elm.className . " => process time " . elm.ElapsedTime())
			}
		}
	}

	; Exports CAPS and Excel PDFs to corresponding folders for auditing purposes.
	ExportPDFsToAudit(win, caps, excel)
	{
		if YesNoBox("Is CAPS print to PDF setup to the correct folder?") = "No"
		 	return

		if win.WinExists(caps)
			caps.Stop()

		statBar := StatusBar()

		accountNames := DataHandler(FileHandler.Config("Resources", "AccountNames"))
		outFile := Format(FileHandler.Config("Paths", "RoutineLogs") . "ExportPDFSToAudit-{1}.txt", Logger.GetFileDateTime())
		LoadingZone := FileHandler.Config("Paths", "IOOutputPath") . "auditing\"
		merchants := FileHandler.CreateMerchantArray("midtopdf.txt", "wpmid", "fdmid", "dba")

		funcName := this.getFuncName(A_ThisFunc)

		exportCAPS := FileHandler.Config("ExportPDFsToAudit", "ExportCAPS")
		exportFDMS := FileHandler.Config("ExportPDFsToAudit", "ExportFDMS")

		if exportCAPS = "true"
			exportCAPS := true
		else
			exportCAPS := false
		
		if exportFDMS := "true"
			exportFDMS := true
		else
			exportFDMS := false

		Logger.Append(funcName, "Starting export...")		
		
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
			if CapsFeePDFDoesNotExist and exportCAPS
			{
				Clippy.Shove(merchant.wpmid)
				win.FocusWindow(caps)
				caps.clickBinocularAndSearch(merchant.wpmid)
				caps.SaveCAPSFeesPDF(CAPSPDFName)
				try FileMove currentCAPSPDFPath, MerchantDir, 1
				catch as e
				{
					Logger.Append(caps, Format("{1} {2} {3} - ERROR: {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
					FileDelete currentCAPSPDFPath
				}
				Sleep 1000
			}
			
			Clippy.Shove("")
			
			; Generate PDF from Account Fee code listing document.
			FDMIDFeePDFDoesNotExist := !(FileExist(MerchantDir . FDMIDPDFName . ".pdf"))
			if FDMIDFeePDFDoesNotExist and exportFDMS
			{
				noteName := merchant.wpmid . " " . merchant.fdmid . " has no FDMID listed"
				if not FileExist(MerchantDir . noteName . ".txt")
				{
					;win.FocusWindow(excel)
					excel.FilterColumnMacro(merchant.fdmid)
					
					; "`r`n" is a value returned from the Excel Macro
					if A_Clipboard = "`r`n" ; current FDMID is not in the list
					{
						;updateStatusBar("Current merchant has no fee codes... making note of that")
						FileAppend(noteName, MerchantDir . "\" . noteName . ".txt")
						Logger.Append(excel, merchant.dba . " " . merchant.fdmid . " has no listings in Account Fee Code Listings")
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
							Logger.Append(caps, Format("{1} {2} {3} - ERROR: {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
							FileDelete currentFDMSPDFPath
						}
						Sleep 1200
					}
				}
			}
			
			Logger.Append(funcName, "Export of " .  merchant.dba . " " . merchant.wpmid . " " . merchant.fdmid . " completed")
			FileAppend(merchant.wpmid . "`t" . merchant.fdmid . "`r`n", outFile)

			Clippy.Shove("")
		}
		
		Send "{Esc 1}"

		statBar.Reset()

		stopwatch.StopTimer()
		Logger.Timer(merchants.length . " merchants exported.", stopwatch)
		
		MsgBox "PDF Export Complete"
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

	ConvertMIDToCaseID()
	{
		this.logger.Append(this.ConvertMIDToCaseID.Name, "Started!")
		outFile := Format(this.fileOps.Config("Paths", "OutputPath") . "GetMIDCaseID-{1}.txt", this.logger.getFileDateTime())
		ci := ""
		merchants := FileHandler.TextToMerchantArray("midtocaseid.txt")

		for m in merchants 
		{
			try ci := DataHandler.Retrieve(DataHandler.Sanitize(m.wpmid)).CaseID
			catch
			{
				this.logger.Append(this.ConvertMIDToCaseID.Name, "ERROR: Unable to retrieve merchant caseID => " . m.wpmid . " does not exist in DataStore")
				continue
			}
			FileAppend(ci . "`r`n", outFile)
		}
		this.logger.Append(this.ConvertMIDToCaseID.Name, "Completed!")
		MsgBox "Convert MID to Case ID complete"
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

		try dba := DataHandler.Retrieve(mid).AccountName
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

class RoutineObject
{
	active := False
	paused := False
	
	uptime := Timer()
	process := Timer()
	statBar := StatusBar()
	
	className := ""
	apps := {}

	thisClassName()
	{
		str := StrSplit(A_ThisFunc, ".")
		return str[1] . str[2] . str[3]
	}

	Init(className, apps)
	{
		this.className := className
		this.apps := apps
		
		; Add initializations here...

		return this
	}

	IsActive() => this.active

	IsPaused() => this.paused

	Do()
	{
		this.Begin()
		
		; ...

		this.Stop()
	}

	Begin()
	{
		this.active := True
		this.paused := False
		this.uptime.StartTimer()
		this.process.StartTimer()
	}

	Hold()
	{
		this.paused := True
		this.process.StopTimer()
	}

	Resume()
	{
		this.paused := False
		this.process.StartTimer()
	}

	Butcher()
	{
		this.active := False
		this.paused := False
		this.process.StopTimer()
		this.uptime.StopTimer()
	}

	Stop()
	{
		this.Butcher()
	}

	ElapsedTime() => this.process.ElapsedTime()

	YesNoCancelBox(msg, title)
	{
		return MsgBox(msg, title, "YesNoCancel Icon? Default3")
	}

	PrepareAndSendNotificationEmail(ol, customText?)
	{
		subject := "[ROUTINE COMPLETE] " . this.className .  " - " . Logger.GetFileDateTime()
		body := this.className . " finished in " . this.process.ElapsedTime()

		if IsSet(customText)
			body := customText
		
		Windows.FocusWindow(ol)
		Sleep 100
		ol.AccessMenuItem("y").SendComposeEmailWithFontMacro()
		
		WinWaitActive "Untitled - Message (HTML) "

		Send subject
		Sleep 100
		Send "{Tab}"
		Sleep 100
		Send "{Ctrl down}"
		Sleep 100
		Send "a"
		Sleep 70
		Send "{Ctrl up}"
		Sleep 100
		Send body
		Sleep 1000
		ol.SendEmail2()
	}

	; Attaches something to clippy and pastes it.
	AttachAndPaste(s)
	{
		Clippy.Shove(s)
		Sleep 250
		Clippy.Paste()
	}
}

; ROUTINE OBJECTS ;

class OpenAuditFolder extends RoutineObject
{
	Do()
	{
		mid := DataHandler.Sanitize(A_Clipboard)
		if Clippy.IsEmpty(mid)
			return
		
		folderName := this.tryGetDBA(win, caps, this.data, mid)
		
		Run(ps.ShowAuditFolder("matchThenOpenPDF.ps1", folderName))
	}
}

class ViewAuditPDFs extends RoutineObject
{
	Do()
	{
		aa := this.apps.aa
		win := Windows() ; New windows object because its app specific.

		WinWaitActive aa.Ref
		Sleep 2000
		Windows.FocusWindow(aa)
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
	}
}

class PrepareClosureFormEmail extends RoutineObject
{
	Do()
	{
		caps := this.apps.caps
		ol := this.apps.ol

		wpmid := A_Clipboard
		
		if Clippy.IsEmpty(wpmid)
			return this

		dba := ""
		mdPath := ""
		email := "Not Found"

		; Regex pattern for emails, kindly given by ChatGPT
		emailPattern := "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"

		try dba := DataHandler.Retrieve(wpmid).AccountName
		catch ; if it doesn't exist in DS, go to CAPS to get it
		{
			Windows.FocusWindow(caps)
			DataHandler.CopyFields(caps.DBA)
			dba := caps.DBA.val
		}
		
		; get name of .md file
		mdPath := FileHandler.RetrievePath("..\merchants", dba, "md")

		; get email from .md file
		email := FileHandler.MatchPatternInFile(mdPath, emailPattern)

		Windows.FocusWindow(ol)
		
		Sleep 100
		
		ol.AccessMenuItem("y")
		ol.SendClosureMacro()
		
		Sleep 100
		
		; email[] because the brackets return the sub pattern
		; https://www.autohotkey.com/docs/v2/lib/RegExMatch.htm#MatchObject
		ol.To(email[]).CC().Subject("Close Account Request Form - " . dba . " (" . wpmid . ")").Body()
	}
}

class PrepareConversionEmail extends RoutineObject
{
	Do()
	{
		caps := this.apps.caps
		ol := this.apps.ol

		wpmid := A_Clipboard

		if Clippy.IsEmpty(wpmid)
			return this

		dba := ""
		mdPath := ""
		order := ""

		try dba := DataHandler.Retrieve(wpmid).AccountName
		catch
		{
			; if it doesn't exist in DS, go to CAPS to get it
			win.FocusWindow(caps)
			Sleep 300
			DataHandler.CopyFields(caps.DBA)
			dba := caps.DBA.val
		}
		
		; Find the correct md file to read
		mdPath := FileHandler.RetrievePath(FileHandler.Config("Paths", "MerchantMDs"), dba, "md")
		
		if mdPath = "none"
			MsgBox "Unable to retrieve .md path"
		else
			order := this.fileOps.ReadOrder(mdPath)

		Windows.FocusWindow(ol)
		Sleep 100
		ol.AccessMenuItem("y").SendOrderMacro()

		WinWaitActive "Ready For Conversion -  - Message (Rich Text) "

		ol.GoToSubjectLineFromBody()
		Send "{End}"
		Send dba . " (" . wpmid . ")"
		ol.GoToMiddleOfBodyFromSubjectLine()
		
		Send order
	}
}

; GenerateOrder creates a Markdown file and fills it with corresponding merchant data for an order.
class GenerateOrder extends RoutineObject
{
	Do()
	{
		ob := this.apps.ob
		caps := this.apps.caps
		gca := this.apps.gca

		wp := A_Clipboard

		if Clippy.IsEmpty(wp)
			return this

		dba := ""
		fdmid := ""
		fileExists := False
		dbaExistsInDataStore := True
		fdmidExistsInDataStore := True

		this.Begin()

		try dba := DataHandler.Retrieve(wp).AccountName
		catch 
			dbaExistsInDataStore := False ; if not in DataStore open caps and get the DBA from there

		try fdmid := DataHandler.Retrieve(wp).FDMID ;( fdmid = "" ? "no FDMID found" : fdmid )
		catch 
			fdmidExistsInDataStore := False
		
		; first check if the file even exists in merchant dir
		fileName := FileHandler.RetrievePath("..\merchants", dba, "md")
		if not (fileName = "none")
			fileExists := True
			
		if fileExists
		{
			Windows.FocusWindow(ob)
			ob.OpenOpenMenu(dba)
		}
		else
		{	
			tt := ob.templateText
			
			; copy stuff from CAPS
			Clippy.Shove(wp)
			
			gca.Do() ; GetCAPSAccount
			wp := DataHandler.Sanitize(A_Clipboard)
			
			Sleep 2100
			
			if not fdmidExistsInDataStore
				fdmid := "=== check salesforce ==="

			DataHandler.CopyFields(
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
			Windows.FocusWindow(ob)
			ob.OpenOpenMenu(( caps.StoreState.val = "HI" ? "Hawaii/" : "Guam-Saipan/" ) . dba)
			this.AttachAndPaste(formattedTemplate)
		}

		this.Stop()

		Clippy.Shove(wp)
	}
}

; DataStoreQuickLookup means DataStore Quick Look, letting the user lookup any MID in the DataStore and see its information.
class DataStoreQuickLookup extends RoutineObject
{
	Do()
	{
		className := this.className

		this.Begin()

		c := A_Clipboard
		if Clippy.IsEmpty(c)
			return this
		
		try r := DataHandler.Retrieve(DataHandler.Sanitize(c))
		catch
		{
			DoesNotExist(className, c)
			return
		}
		
		s := ""
		for k, v in r.OwnProps()
			s .= k . ": " . v . "`n"
		
		this.Stop()

		MsgBox(s, "Lookup " . c)
	}
}

; GetCAPSAccount pulls up CAPS and searches it for a single MID.
class GetCAPSAccount extends RoutineObject
{
	Do()
	{
		className := this.className
		caps := this.apps.caps

		this.Begin()

		mid := DataHandler.Sanitize(A_Clipboard)
		if Clippy.IsEmpty(mid)
			Logger.Append(className, "Clipboard empty! Exiting...")
		else
		{
			Windows.FocusWindow(caps)
			caps.clickBinocularAndSearch(mid)
			Sleep 200
			Clippy.Shove(mid)
		}

		this.Stop()
	}
}

class GetSalesforcePage extends RoutineObject
{
	Do()
	{
		className := this.className
		sf := this.apps.sf
		edge := this.apps.edge
		
		mid := ""

		this.Begin()

		if IsSet(m)
			mid := m
		else
			mid := DataHandler.Sanitize(A_Clipboard)
		
		try Clippy.Shove(sf.CaseURL(DataHandler.Retrieve(mid).CaseID))
		catch
		{
			DoesNotExist(className, mid)
			return this
		}

		Sleep 500
		
		Windows.FocusWindow(edge)
		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		else
			edge.FocusURLBar()
		Clippy.Paste()
		Send "{Enter}"

		Clippy.Shove(mid)
		
		Sleep 500

		this.Stop()
	}
}

class UpdateSalesforceCaseFields extends RoutineObject
{
	Do()
	{
		prompt := this.YesNoCancelBox("Would you like to send a notification email when routine is complete?", this.className)

		this.Begin()

		cub := this.apps.cub ; cub means Case Updater Bookmarklet.
		edge := this.apps.edge
		ol := this.apps.ol

		rlf := Logger(FileHandler.Config("Paths", "RoutineLogs"), this.className)
		
		Logger.Append(this.className, "Started")

		tally := Map("INACCESSIBLE", 0, "CHANGED", 0, "EQUAL", 0)
		totalParsed := 1
		merchants := FileHandler.CreateMerchantArray(FileHandler.Config("Functions", this.className))
		merchantLength := merchants.length
		
		Windows.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()

		while totalParsed < merchants.length
		{
			m := merchants[totalParsed]
			urlExists := cub.HasCaseURL(m)
			
			Sleep 700
			
			if urlExists
			{
				edge.FocusURLBar()
				Sleep 250
				edge.PasteURLAndGo(cub.FullURL)

				fieldsAlreadyUpdated := cub.UpdateFields("waiting")
				
				Sleep 1000

				if (fieldsAlreadyUpdated = "CHANGED") or (fieldsAlreadyUpdated = "EQUAL")
				{
					Logger.Append(this.className, m.wpmid . (fieldsAlreadyUpdated = "CHANGED" ? " updated" : " already up to date"))
					
					if fieldsAlreadyUpdated = "CHANGED"
					{
						tally["CHANGED"] += 1
						Sleep 700
					}
					else
					{
						tally["EQUAL"] += 1
					}
				}
				else if fieldsAlreadyUpdated = "INACCESSIBLE"
				{
					Logger.Append(this.className, m.wpmid . " something went wrong accessing the Javascript for this webpage")
					tally["INACCESSIBLE"] += 1
					encounteredJSError := True
				}

				Sleep 1000
			}
			else
			{
				rlf.Append(, m.wpmid . " does not have an existing account on Salesforce")
			}

			totalParsed += 1

		}

		this.Stop()

		Logger.Timer(totalParsed . " merchant accounts updated on Salesforce", this.process)

		temp := "
		(
		TIME ELAPSED: {1}
		TOTAL SIZE:   {2}

		EQUAL:        {3}
		CHANGED:      {4}
		INACCESSIBLE: {5}

		)"

		msgLines := Array(
			this.process.ElapsedTime(),
			merchantLength,
			tally["EQUAL"],
			tally["CHANGED"],
			tally["INACCESSIBLE"]
		)

		body := Format(temp, msgLines*)
		
		if prompt = "Yes"
		{
			this.PrepareAndSendNotificationEmail(ol, body)
			Logger.Append(this.className, "Email notification sent!")
		}

		MsgBox body
	}
}

; UpdateSalesforceFields is a RoutineObject that allows the user to update fields on Salesforce when it is given a custom Salesforce object. It uses that object to execute the updates on Salesforce via the Salesforce "UpdateFields" method.
class UpdateSalesforceFields extends RoutineObject
{
	scheme := Array()
	Init(className, apps, scheme?)
	{
		if IsSet(scheme)
			this.scheme := this.schemeFromObject(scheme)

		this.className := className

		return this
	}

	schemeFromObject(obj)
	{
		s := Array()
		for attr in obj.OwnProps()
		{
			s.Push(attr)
		}
		return s
	}

	Do(passIndex := 1)
	{
		prompt := ""

		if passIndex = 1
			prompt := this.YesNoCancelBox("Would you like to send a notification email when routine is complete?", this.className)
		
		if passIndex > 10
		{
			Logger.Append(this.className, "Too many passes - " . passIndex . ". Something is consistently inaccessible => stopping...")
			return
		}
		
		if prompt = "Cancel"
			return
		
		fub := this.apps.fub ; fub means Field Updater Bookmarklet. Its a class that updates bookmark fields, extended from SalesforceDB.
		edge := this.apps.edge
		ol := this.apps.ol

		str := ""
		idx := 0
		realTotal := 0
		fieldsAlreadyUpdated := False
		encounteredJSError := False

		memoryInputFilePath := FileHandler.Config(this.className, "MemoryInputFile")
		memoryOutputFilePath := FileHandler.Config(this.className, "MemoryOutputFile") ; This is where the "memory" is written to.
		
		csv := FileHandler(memoryInputFilePath, memoryOutputFilePath, this.className, "RoutineScheme")
		
		rlf := Logger(FileHandler.Config("Paths", "RoutineLogs"), this.className) ; RLF = Routine Log File.
		rlf.Append(, "ACCOUNTS THAT DON'T HAVE SALESFORCE FDMID")

		merchants := FileHandler.CreateMerchantArray(FileHandler.Config(this.className, "RoutineData"), this.scheme*)
		parseMap := DataHandler(memoryOutputFilePath) ; Create a DataStore from the routine's CSV "memory" file stored in resources directory.
		tally := Map("INACCESSIBLE", 0, "CHANGED", 0, "EQUAL", 0)

		this.Begin()
		
		Logger.Append(this.className, "Started")
		
		Windows.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		fieldsAlreadyUpdated := "START"
		jsParseString := "START"
		totalParsed := 1
		totalComplete := 0
		merchantLength := merchants.length
		sessionBatchAmount := Integer(FileHandler.Config(this.className, "SessionBatchAmount"))
		sessionBatchAmount := (sessionBatchAmount > 0 ? sessionBatchAmount - 1 : sessionBatchAmount)

		while (totalParsed <= merchantLength) and (totalComplete <= sessionBatchAmount)
		{
			m := merchants[totalParsed]
			
			Clippy.Shove("")
			
			idx := parseMap.Retrieve(m.fdmid).OrderIndex
			realTotal := parseMap.DsLength//parsemap.Cols.length
			
			this.statBar.Show("Merchant: " . totalParsed . "/" . merchants.length . "`r`n" . "Total: " . idx . "/" . realTotal . "`r`n" . "Completed in Session Batch: " . totalComplete . "/" . sessionBatchAmount . "`r`n" . "Payload: " . jsParseString . "`r`n" . "Last Received Word: " . fieldsAlreadyUpdated . "`r`n" . "Pass: " . passIndex)

			sfUpdated := parseMap.IsParsed(m.fdmid) ; Checks memory to see if it had already done this merchant on previous runs.

			if sfUpdated
			{
				totalParsed += 1
				continue
			}

			urlExists := fub.HasURL(m, "FDMID", "AccountID")
			
			if urlExists
			{
				edge.FocusURLBar()
				Sleep 250
				edge.PasteURLAndGo(fub.FullURL)
				
				Clippy.Shove("none")

				jsParseString := m.CreateJSParseString(",", "+")

				this.statBar.Show("Merchant: " . totalParsed . "/" . merchants.length . "`r`n" . "Total: " . idx . "/" . realTotal . "`r`n" . "Completed in Session Batch: " . totalComplete . "/" . sessionBatchAmount . "`r`n" . "Payload: " . jsParseString . "`r`n" . "Last Received Word: " . fieldsAlreadyUpdated . "`r`n" . "Pass: " . passIndex)
				
				Sleep 1000

				; Updates the fields, if there is a need to do that.
				fieldsAlreadyUpdated := fub.UpdateFields(jsParseString)

				orderIndex := parseMap.Retrieve(m.fdmid).OrderIndex
				
				if (fieldsAlreadyUpdated = "CHANGED") or (fieldsAlreadyUpdated = "EQUAL")
				{
					Logger.Append(this.className, m.fdmid . (fieldsAlreadyUpdated = "CHANGED" ? " updated" : " already up to date"))
					parseMap.SetParsed(orderIndex)
					if fieldsAlreadyUpdated = "CHANGED"
					{
						tally["CHANGED"] += 1
						Sleep 1500
					}
					else
					{
						tally["EQUAL"] += 1
					}
				}
				else if fieldsAlreadyUpdated = "INACCESSIBLE"
				{
					Logger.Append(this.className, m.fdmid . " something went wrong accessing the Javascript for this webpage")
					tally["INACCESSIBLE"] += 1
					encounteredJSError := True
				}

				Sleep 800

				; Write changes to routine file. This is the routine's "memory".
				str := parseMap.DataStoreToFileString(csv.Scheme)
				csv.StringToCSV(str)
			}
			else
				rlf.Append(m.fdmid)

			totalParsed += 1
			if sessionBatchAmount != 0 ; when the batch amount is 0, that means keep parsing til the very end, no limit.
				totalComplete += 1

		}

		this.Stop()

		Logger.Timer(totalComplete . " merchant accounts updated on Salesforce", this.process)

		this.statBar.Reset()

		if encounteredJSError
		{
			this.Do(passIndex + 1)
		}
		else if !encounteredJSError and passIndex > 1
		{
			return
		}

		temp := "
		(
		TIME ELAPSED: {1}
		TOTAL PASSES: {2}
		TOTAL SIZE:   {3}
		BATCH SIZE:   {4}

		EQUAL:        {5}
		CHANGED:      {6}
		INACCESSIBLE: {7}

		)"

		msgLines := Array(
			this.process.ElapsedTime(),
			passIndex,
			idx . " of " . realTotal - 1,
			sessionBatchAmount,
			tally["EQUAL"],
			tally["CHANGED"],
			tally["INACCESSIBLE"]
		)

		body := Format(temp, msgLines*)
		
		if prompt = "Yes"
		{
			this.PrepareAndSendNotificationEmail(ol, body)
			Logger.Append(this.className, "Email notification sent!")
		}

		MsgBox body
	}
}