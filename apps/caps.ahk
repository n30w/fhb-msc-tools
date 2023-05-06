#Requires AutoHotkey v2.0

; actions for CAPS
class CapsDB extends Application
{
	WPMID := Field(180, 100)
	DBA := Field(160, 130)
	StoreAddr1 := Field(600, 195)
	StoreAddr2 := Field(600, 225)
	StoreCity := Field(600, 250)
	StoreState := Field(750, 250)
	StoreZip := Field(750, 283)
	
	; clicks the info and contact via top menu bar
	goToInfoAndContact()
	{
		Sleep 4000
		Click 280, 40
		Sleep 600
		Click 280, 105
		Sleep 500
		Click 60, 315
	}

	; clicks the binoculars to search and enters a search value and clicks enter
	clickBinocularAndSearch(mid)
	{
		Click 30, 66 ; binocular button
		Sleep 300
		Send mid
		Sleep 400
		Send "{Enter}"
	}
	
	Start()
	{
		Open(this)
		this.goToInfoAndContact() ; accesses CAPS shortcut in working dir
	}
}

