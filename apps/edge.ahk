#Requires AutoHotkey v2.0

class MSEdge extends Application
{
	FocusURLBar()
	{
		Sleep 50
		Send "^l"
		Sleep 50
	}
}