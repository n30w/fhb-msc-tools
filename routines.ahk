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
		this.data.cb.Clean()
	}
	
	; searches CAPS for a single MID
	GetCAPSAccount(win, caps)
	{
		mid := this.data.cb.Update()
		mid := DataHandler.SanitizeID(mid)
		win.FocusWindow(caps)
		caps.clickBinocularAndSearch(mid)
		Sleep 200
		return this
	}
	
	; pulls up account view on Salesforce
	GetSalesforceAccount(win, edge, sf)
	{
		mid := this.data.cb.Update()
		mid := DataHandler.SanitizeID(mid)
		win.FocusWindow(edge)
		edge.FocusURLBar()
		this.data.cb.Board := sf.AccountURL(DataHandler.Retrieve(mid).AccountID)
		this.data.cb.Paste()
		Send "{Enter}"
		this.data.cb.Clean()
		DataHandler.Free(mid)
		return this
	}
	
	; gets data from CAPS and puts it into email order template
	GenerateOrder(win, caps, npp)
	{	
		tt := npp.templateText
		
		; copy stuff from CAPS
		this.GetCAPSAccount(win, caps)
		wp := DataHandler.SanitizeID(this.data.cb.Board)
		
		Sleep 1300
		
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
			DataHandler.Retrieve(wp).AccountName, 
			wp,
			DataHandler.Retrieve(wp).FDMID ;( fdmid = "" ? "no FDMID found" : fdmid )
		)
		
		; create shipping address, varies if StoreAddr2 has val
		formattedTemplate .= Format( ( not (caps.StoreAddr2.val = "") ? ("
		(
		`t{1}
		`t{2}
		`t{3}, {4}
		`t{5}
		)") : "
		(
		`t{1}
		`t{3}, {4}
		`t{5}
		)"), caps.StoreAddr1.val, caps.StoreAddr2.val, caps.StoreCity.val, caps.StoreState.val, caps.StoreZip.val)
		
		; import that formatted data into npp
		win.FocusWindow(npp)
		npp.NewFile()
		this.AttachAndPaste(formattedTemplate)
		;npp.ChangeSyntaxLang()
		return this
	}
	
	DataStoreQuickLook()
	{
		c := this.data.cb.Update()
		r := DataHandler.Retrieve(c)
		s := ""
		for k, v in r.OwnProps()
		{
			s .= k . ": " . v . "`n" 
		}
		
		MsgBox(s, "Lookup " . c)
	}
}

