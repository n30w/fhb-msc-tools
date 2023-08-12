#Requires AutoHotkey v2.0

class MSEdge extends Application
{
	FocusURLBar()
	{
		Sleep 50
		Send "{Ctrl down}l"
		Sleep 150
		Send "{Ctrl up}"
	}

	NewTab()
	{
		Sleep 50
		Send "^t"
		Sleep 50
	}

	PasteURLAndGo(url)
	{
		Clippy.Shove(url)
		Send "^v"
		Sleep 200
		Send "{Enter down}"
		Sleep 75
		Send "{Enter up}"
		Sleep 300
	}

	GetTabTitle() => WinGetTitle("A")

	; Returns true if there is a word in the title of a tab
	TabTitleContains(word)
	{
		title := this.GetTabTitle()
		words := StrSplit(title, A_Space)
		hasWord := False
		for w in words
		{
			if w = word
			{
				return True
			}
		}
		return False
	}
}