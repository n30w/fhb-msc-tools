#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"
#Include "log.ahk"

class Routines
{
	data := DataHandler()
	
	__New(logger, fileOps)
	{
		this.logger := logger
		this.fileOps := fileOps
	}
	
	; attaches something to clippy and pastes it
	AttachAndPaste(s)
	{
		this.data.cb.Attach(s)
		Sleep 250
		this.data.cb.Paste()
	}
	
	; searches CAPS for a single MID
	GetCAPSAccount(win, caps)
	{
		mid := this.data.cb.Update()
		mid := DataHandler.Sanitize(mid)
		win.FocusWindow(caps)
		caps.clickBinocularAndSearch(mid)
		Sleep 200
		return this
	}
	
	; pulls up account view on Salesforce
	GetSalesforceAccount(win, edge, sf)
	{
		mid := this.data.cb.Update()
		mid := DataHandler.Sanitize(mid)
		
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

	; pulls up account view on Salesforce
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
	
	; gets data from CAPS and puts it into email order template
	GenerateOrder(win, caps, ob)
	{	
		fileExists := false
		wp := DataHandler.Sanitize(this.data.cb.Update())
		dba := ""
		fdmid := ""
		dbaExistsInDataStore := true
		fdmidExistsInDataStore := true

		try
		{
			; retrieve dba from DataStore
			dba := DataHandler.Retrieve(wp).AccountName
		}
		catch
		{
			; if not in DataStore open caps and get the DBA from there
			dbaExistsInDataStore := false
		}

		try
		{
			; retrieve fdmid from DataStore
			fdmid := DataHandler.Retrieve(wp).FDMID ;( fdmid = "" ? "no FDMID found" : fdmid )
		}
		catch
		{
			fdmidExistsInDataStore := false
		}
		
		; first check if the file even exists in merchant dir
		fileName := FileHandler.RetrievePath("..\merchants", dba, "md")
		if not (fileName = "none")
			fileExists := true
			
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
			if not dbaExistsInDataStore
				dba := this.data.CopyFields(caps.DBA)

			if not fdmidExistsInDataStore
				fdmid := "=== check salesforce ==="

			this.data.CopyFields(
				caps.StoreAddr1,
				caps.StoreAddr2,
				caps.StoreCity,
				caps.StoreState,
				caps.StoreZip
			)

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
		return this
	}
	
	GenerateOrderFromCAPSOnly(win, caps, ob)
	{

	}

	ExportPDFSToAudit(win, caps, excel)
	{
		tempRef := excel.Ref ; store current ref in temp var
		excel.Ref := "fdms fee code list  -  Repaired - Excel"

		this.logger.append(this.ExportPDFSToAudit,"Starting export...")
		
		merchants(m)
		{
			Loop read, "auditing\mids.txt"
			{
				attr := StrSplit(A_LoopReadLine, A_Tab)
				merchant := {wpmid: attr[1], fdmid: attr[2], dba: ""}
				m.Push(merchant)
			}
		}
		
		StartTime := A_TickCount
		
		FolderPath := "auditing\directories\{1}\2023.FDMS conversion\"
		
		data := Array()
		merchants(data) ; gets mids from text file and stores in array
		
		for merchant in data ; get corresponding DBA for each WP MID, create folder if it doesn't exist.
		{
			merchant.dba := DataHandler.Retrieve(merchant.wpmid).AccountName
			
			MerchantDir := Format(FolderPath, merchant.dba)
			
			CAPSPDFName := "CAPS fees - " . merchant.wpmid
			FDMIDPDFName := "FDMID code listing - " . merchant.wpmid
			
			currentCAPSPDFPath := ""
			currentFDMSPDFPath := ""

			; if there are no matching DBAs, make a new folder
			if not DirExist(MerchantDir)
				DirCreate MerchantDir
			
			; if CAPS fee doesn't exist, access CAPS and create pdf
			if not FileExist(MerchantDir . CAPSPDFName . ".pdf")
			{
				Clippy.Shove(merchant.wpmid)
				win.FocusWindow(caps)
				this.GetCAPSAccount(win, caps)
				caps.SaveCAPSFeesPDF(CAPSPDFName)
				
				currentCAPSPDFPath := "auditing\" . CAPSPDFName . ".pdf"
				
				try FileMove currentCAPSPDFPath, MerchantDir, 1
				catch as e
				{
					this.logger.Append(caps, Format("{1} {2} {3} - {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
					FileDelete currentCAPSPDFPath
				}
				Sleep 1000
			}
			
			Clippy.Shove("")
			
			; generate PDF from Account Fee code listing document
			if not FileExist(MerchantDir . FDMIDPDFName . ".pdf")
			{
				win.FocusWindow(excel)
				excel.FilterColumnMacro(merchant.fdmid)
				
				; "`r`n" is a value returned from the Excel Macro
				if A_Clipboard = "`r`n" ; current FDMID is not in the list
				{
					FileAppend(merchant.WPMID . " " . merchant.FDMID . " has no FDMID listed", MerchantDir . merchant.WPMID . " " . merchant.FDMID . " has no FDMID listed" . ".txt")
					this.logger.Append(excel, merchant.dba . " " . merchant.fdmid . " has no listings in Account Fee Code Listings")
					Clippy.Shove("")
					Sleep 300
				}
				else
				{
					Clippy.Shove(FDMIDPDFName)
					excel.DefaultPDFSaveMacro()
					currentFDMSPDFPath := "auditing\" . FDMIDPDFName . ".pdf"
					try FileMove currentFDMSPDFPath, MerchantDir, 1
					catch as e
					{
						this.logger.Append(caps, Format("{1} {2} {3} - ERROR: {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
						FileDelete currentFDMSPDFPath
					}
					Sleep 200
				}
			}
			
			this.logger.Append(this.ExportPDFSToAudit.Name, "Export of " .  merchant.dba . " " . merchant.wpmid . " " . merchant.fdmid . " completed")
			
			FileAppend(merchant.wpmid . A_Tab . merchant.fdmid . "`n", "auditing\completed.txt")
			
			Clippy.Shove("")	
			
			Sleep 1000
		}
		
		excel.Ref := tempRef
		
		Send "{Esc 1}"
		FinishTime := A_TickCount
		TotalTime := FinishTime - StartTime
		
		m := Round(TotalTime/60000)
		r := Mod(TotalTime, 60000)
		s := Round(r/1000)
		r := Mod(r, 1000)
		mi := r
		
		this.logger.Append(, "===== " . data.length . " PDFs exported in " . m . "m " . s . "." . mi . "s" . " =====")
		
		MsgBox "PDF Export Complete"
	}
	
	PrepareClosureFormEmail(win, caps, ol)
	{
		wpmid := A_Clipboard
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
			dba := this.data.CopyFields(caps.DBA)
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
			dba := this.data.CopyFields(caps.DBA)
		}
		
		; Find the correct md file to read
		mdPath := FileHandler.RetrievePath("..\merchants", dba, "md")
		order := this.fileOps.ReadOrder(mdPath)
		MsgBox order
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

	OpenAuditFolder(win, caps, edge, sf, wpmid?)
	{
		mid := ""
		if IsSet(wpmid)
			mid := wpmid
		else
		{
			mid := this.data.cb.Update()
			mid := DataHandler.Sanitize(mid)
		}
		
		psFile := A_WorkingDir . "\ps\matchThenOpenPDF.ps1"
		
		folderName := this.tryGetDBA(win, caps, this.data, mid)

		Run "powershell.exe -ExecutionPolicy Bypass -File " . psFile . " -folderName " . "`"" .  folderName . "`""

		return this
	}

	ViewAuditFolder(win, caps, edge, sf, wpmid?)
	{
		mid := ""
		if IsSet(wpmid)
			mid := wpmid
		else
		{
			mid := this.data.cb.Update()
			mid := DataHandler.Sanitize(mid)
		}
		
		psFile := A_WorkingDir . "\ps\matchFolder.ps1"
		
		folderName := this.tryGetDBA(win, caps, this.data, mid)

		Run "powershell.exe -ExecutionPolicy Bypass -File " . psFile . " -folderName " . "`"" .  folderName . "`""

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

	DataStoreQuickLook()
	{
		c := this.data.cb.Update()
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

