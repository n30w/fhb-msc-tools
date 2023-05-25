#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"
#Include "log.ahk"

class Routines
{
	data := DataHandler()
	currentRoutine := ""

	__New(logger, fileOps)
	{
		this.logger := logger
		this.fileOps := fileOps
		this.clock := Timer()
		this.sharedDrive := this.fileOps.Config("Paths", "SharedDrive")
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
		merchants := this.fileOps.TextToMerchantArray("addfdmidtosf.txt")
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
		name := this.AddConversionDateToSalesforce.Name
		
		this.data.cb.Clean()

		this.logger.Append(name, "Started")

		this.clock.StartTimer()
		
		merchants := this.fileOps.TextToMerchantAndDateArray("updatesfdate.txt")
		
		win.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		for m in merchants
		{
			this.data.cb.Clean()
			
			urlExists := sf.HasURL(this.logger, m)
			
			if urlExists
			{
				edge.FocusURLBar()
				Clippy.Shove(sf.FullURL)
				Send "^v"
				Sleep 100
				Send "{Enter}"
				Sleep 300

				Clippy.Shove("none")

				sf.UpdateConversionDate(m.newDate)
				
				this.logger.Append(name, m.wpmid . " conversion date updated")

				Sleep 2000
			}
			else
			{
				continue
			}
		}

		this.clock.StopTimer()

		this.logger.Timer(merchants.length . " merchant account conversion dates checked and/or updated.", this.clock)

		MsgBox "Conversion dates updated"
	}

	; From a text file, update every account's closed date on Salesforce.
	AddClosedDateToSalesforce(win, edge, sf)
	{
		stopwatch := Timer()
		statBar := StatusBar()

		name := this.AddClosedDateToSalesforce.Name
		outputFile := FileHandler.NewTimestampedFile(name, FileHandler.Config("Paths", "RoutineLogs"))
		
		localDS := DataHandler("resources\accountIDs.csv")
		merchants := this.fileOps.TextToMerchantAndDateArray("addcloseddatetosf.txt")
		
		this.logger.Append(name, "Started")
		
		stopwatch.StartTimer()
		
		win.FocusWindow(edge)

		if not edge.TabTitleContains("Salesforce")
			edge.NewTab()
		
		for m in merchants
		{
			this.data.cb.Clean()

			statBar.Show(A_Index . "/" . merchants.length . " completed")

			urlExists := sf.HasURL(this.logger, m, localDS)
			
			if urlExists
			{
				edge.FocusURLBar()
				Clippy.Shove(sf.FullURL)
				Send "^v"
				Sleep 100
				Send "{Enter}"
				Sleep 300

				Clippy.Shove("none")

				sf.UpdateClosedDate(m.newDate)
				
				this.logger.Append(name, m.wpmid . " updated")

				Sleep 2000
			}
			else
			{
				FileHandler.AddLineToFile(m.wpmid . " does not exist on Salesforce", outputFile)
				continue
			}
		}

		stopwatch.StopTimer()

		this.logger.Timer(merchants.length . " merchant account closed dates checked and/or updated.", stopwatch)

		statBar.Reset()

		MsgBox "Closed dates updated"
	}
	
	; gets data from CAPS and puts it into email order template
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

	ExportPDFSToAudit(win, caps, excel)
	{
		if YesNoBox("Is CAPS print to PDF setup to the correct folder?") = "No"
			return

		statBar := StatusBar()

		accountNames := DataHandler("resources\accountNames.csv")
		outFile := Format(this.fileOps.Config("Paths", "RoutineLogs") . "ExportPDFSToAudit-{1}.txt", this.logger.getFileDateTime())
		LoadingZone := this.fileOps.Config("Paths", "OutputPath") . "auditing\"
		merchants := this.fileOps.TextToMerchantArray("midtopdf.txt")

		this.logger.append(this.ExportPDFSToAudit,"Starting export...")		
		
		stopwatch := Timer()
		stopwatch.StartTimer()
		
		for merchant in merchants ; get corresponding DBA for each WP MID, create folder if it doesn't exist.
		{
			try merchant.dba := DataHandler.Retrieve(merchant.wpmid).AccountName
			catch
				merchant.dba := accountNames.Retrieve(merchant.wpmid).AccountName
			statdba := merchant.dba
			updateStatusBar(state)
			{
				msg := "
				(
				{1}/{2}: {3}
				{4}
				)"
				
				statBar.Show(Format(msg, A_Index, merchants.length, statdba, state))
			}

			updateStatusBar("Processing")

			MerchantDir := Format(LoadingZone . "directories\{1}\2023.FDMS conversion\", merchant.dba)
			
			CAPSPDFName := "CAPS fees - " . merchant.wpmid
			FDMIDPDFName := "FDMID code listing - " . merchant.wpmid
			
			currentCAPSPDFPath := LoadingZone . CAPSPDFName . ".pdf"
			currentFDMSPDFPath := LoadingZone . FDMIDPDFName . ".pdf"

			; if there are no matching DBAs, make a new folder
			if not DirExist(MerchantDir)
			{
				updateStatusBar("Creating Merchant Directory")
				DirCreate MerchantDir
			}
			
			; if CAPS fee doesn't exist, access CAPS and create pdf
			if not FileExist(MerchantDir . CAPSPDFName . ".pdf")
			{
				updateStatusBar("Exporting CAPS PDF")
				; MsgBox MerchantDir . CAPSPDFName . ".pdf" . " does not exist"
				Clippy.Shove(merchant.wpmid)
				win.FocusWindow(caps)
				this.GetCAPSAccount(win, caps)
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
			
			; generate PDF from Account Fee code listing document
			if not FileExist(MerchantDir . FDMIDPDFName . ".pdf")
			{
				noteName := merchant.wpmid . " " . merchant.fdmid . " has no FDMID listed"
				if not FileExist(MerchantDir . noteName . ".txt")
				{
					win.FocusWindow(excel)
					excel.FilterColumnMacro(merchant.fdmid)
					
					; "`r`n" is a value returned from the Excel Macro
					if A_Clipboard = "`r`n" ; current FDMID is not in the list
					{
						updateStatusBar("Current merchant has no fee codes... making note of that")
						FileAppend(noteName, MerchantDir . "\" . noteName . ".txt")
						this.logger.Append(excel, merchant.dba . " " . merchant.fdmid . " has no listings in Account Fee Code Listings")
						Clippy.Shove("")
						Sleep 300
					}
					else
					{
						updateStatusBar("Exporting FDMID Fee Codes PDF")
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
			
			this.logger.Append(this.ExportPDFSToAudit.Name, "Export of " .  merchant.dba . " " . merchant.wpmid . " " . merchant.fdmid . " completed")
			FileAppend(merchant.wpmid . "`t" . merchant.fdmid . "`r`n", outFile)

			Clippy.Shove("")
		}
		
		Send "{Esc 1}"

		statBar.Reset()

		stopwatch.StopTimer()
		this.logger.Timer(merchants.length . " merchants exported.", stopwatch)
		
		MsgBox "PDF Export Complete"
	}
	
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
		mdPath := FileHandler.RetrievePath("..\merchants", dba, "md")
		
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
		merchants := this.fileOps.TextToMerchantArray("midtocaseid.txt")

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
}