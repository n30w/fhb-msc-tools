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

	PasteURLAndGo(url)
	{
		Clippy.Shove(url)
		Send "^v"
		Sleep 100
		Send "{Enter}"
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