#Requires AutoHotkey v2.0

class MSExcel extends Application
{
	Start()
	{
		Open(this)
		if WinWait(this.Ref, , 3)
			WinMinimize ; Use the window found by WinWait.
		else
			MsgBox "WinWait timed out looking for Excel..."
	}
}