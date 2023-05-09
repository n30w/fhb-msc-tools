#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"

class Routines
{
	data := DataHandler()
	
	; attaches something to clippy and pastes it
	AttachAndPaste(s)
	{
		this.data.cb.Attach(s)
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
			DoesNotExist(mid)
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
		dba := DataHandler.Retrieve(wp).AccountName
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
	
	DataStoreQuickLook()
	{
		c := this.data.cb.Update()
		try
		{
			r := DataHandler.Retrieve(DataHandler.Sanitize(c))
		}
		catch
		{
			DoesNotExist(c)
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

