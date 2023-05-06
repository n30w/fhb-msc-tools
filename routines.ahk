#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "windows.ahk"
#Include "data.ahk"

class Routines
{
	data := DataHandler()
	
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
	
	GenerateOrder(mid, npp)
	{
		
	}
}

