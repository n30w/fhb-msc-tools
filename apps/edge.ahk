#Requires AutoHotkey v2.0

class MSEdge extends Application
{
	FocusURLBar()
	{
		Sleep 50
		Send "^l"
		Sleep 50
	}

	NewTab()
	{
		Sleep 50
		Send "^t"
		Sleep 50
	}

	GetTabTitle() => WinGetTitle("A")
}