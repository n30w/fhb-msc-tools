#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"
#Include "log.ahk"

class Routines
{
	data := DataHandler()
	
	__New(logger)
	{
		this.logger := logger
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
		edge.FocusURLBar()
		this.data.cb.Paste()
		Send "{Enter}"
		this.data.cb.Clean()
		return this
	}
	
	; gets data from CAPS and puts it into email order template
	GenerateOrder(win, caps, ob)
	{	
		fileExists := false
		wp := DataHandler.Sanitize(this.data.cb.Update())
		
		try
		{
			dba := DataHandler.Retrieve(wp).AccountName
		}
		catch
		{
			DoesNotExist(this.GenerateOrder.Name, this.logger, wp)
			Clippy.Shove(wp)
			return
		}
		
		path := "..\merchants\*.md"
		fileName := ""
		
		; first check if the file even exists in merchant dir
		Loop Files, path, "R"
		{
			SplitPath(A_LoopFileName, &fileName)
			if fileName = dba . ".md"
			{
				fileExists := true
				break
			}
		}
			
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
				DataHandler.Retrieve(wp).FDMID ;( fdmid = "" ? "no FDMID found" : fdmid )
			)
			
			; create shipping address, varies if StoreAddr2 has val
			formattedTemplate .= Format( ( not (caps.StoreAddr2.val = "") ? ("
			(
			`n`t{1}
			`t{2}
			`t{3}, {4}
			`t{5}
			)") : "
			(
			`n`t{1}
			`t{3}, {4}
			`t{5}
			)"), caps.StoreAddr1.val, caps.StoreAddr2.val, caps.StoreCity.val, caps.StoreState.val, caps.StoreZip.val)
			
			; import that formatted data into obsidian onto new document
			win.FocusWindow(ob)
			ob.OpenOpenMenu(( caps.StoreState.val = "HI" ? "Hawaii/" : "Guam-Saipan/" ) . dba)
			this.AttachAndPaste(formattedTemplate)
		}
		return this
	}
	
	ExportPDFSToAudit(win, caps, excel)
	{
		tempRef := excel.Ref ; store current ref in temp var
		excel.Ref := "fdms fee code list - Excel"
		
		localCAPSPDF := "auditing\CAPS fees.pdf"
		localFDMSPDF := "auditing\FDMID code listing.pdf"
		
		this.logger.append(this.ExportPDFSToAudit,"starting export...")
		
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
			
			; if there are no matching DBAs, make a new folder
			if not DirExist(MerchantDir)
				DirCreate MerchantDir
			
			; if CAPS fee doesn't exist, access CAPS and create pdf
			if not FileExist(MerchantDir . "CAPS fees - " . merchant.wpmid . ".pdf")
			{
				Clippy.Shove(merchant.wpmid)
				win.FocusWindow(caps)
				this.GetCAPSAccount(win, caps)
				caps.SaveCAPSFeesPDF("CAPS fees - " . merchant.wpmid)
				
				localCAPSPDF := "auditing\CAPS fees - " . merchant.wpmid . ".pdf"
				
				try FileMove localCAPSPDF, MerchantDir, 1
				catch as e
				{
					this.logger.Append(caps, Format("{1} {2} {3} - {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
					FileDelete localCAPSPDF
				}
				
				Sleep 1000
			}
			
			Clippy.Shove("")
			
			; generate PDF from Account Fee code listing document
			if not FileExist(MerchantDir . "FDMID code listing - " . merchant.wpmid . ".pdf")
			{
				win.FocusWindow(excel)
				excel.FilterColumnMacro(merchant.fdmid)
				
				if A_Clipboard = "`r`n" ; current FDMID is not in the list
				{
					FileAppend(merchant.WPMID . " " . merchant.FDMID . " has no FDMID listed", MerchantDir . merchant.WPMID . " " . merchant.FDMID . " has no FDMID listed" . ".txt")
					this.logger.Append(excel, merchant.dba . " " . merchant.fdmid . " has no listings in Account Fee Code Listings")
					Clippy.Shove("")
					Sleep 800
				}
				else
				{
					excel.DefaultPDFSaveMacro()
					
					; Wait for publish window to pull up and wait for its closure
					WinWait "Publishing..." 
					WinWaitClose
					FileMove(localCAPSPDF, "auditing\FDMID code listing - " . merchant.wpmid . ".pdf")
					
					localCAPSPDF := "auditing\FDMID code listing - " . merchant.wpmid . ".pdf"
					
					try FileMove localFDMSPDF, MerchantDir, 1
					catch as e
					{
						this.logger.Append(caps, Format("{1} {2} {3} - {4}", merchant.dba, merchant.wpmid, merchant.fdmid, e.What))
						FileDelete localFDMSPDF
					}
					Sleep 200
				}
			}
			
			this.logger.Append(this.ExportPDFSToAudit.Name, "Export of " .  merchant.dba . " " . merchant.wpmid . " " . merchant.fdmid . " completed")
			
			FileAppend(merchant.wpmid . A_Tab . merchant.fdmid . "`n", "auditing\completed.txt")
			
			Clippy.Shove("")	
			
			Sleep 1000
			;MsgBox "a"
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
}

