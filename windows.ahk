#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "log.ahk"

class Windows
{
	static WinExists(app)
	{
		if WinExist(app.Ref)
			return True
		else
			return False
	}

	static FocusWindow(app)
	{
		if Windows.WinExists(app)
		{
			WinActivate
		}
		else if WinWaitActive(app.Ref, , 5)
		{
			WinActivate app.Ref
		}
		else
		{
			if YesNoBox(app.Name . " is not running. Would you like to start it?") = "Yes"
				app.Start()
			else
				MsgBox "Unable to start " . app.Name . ". Exiting routine..."
				return
		}
	}

	ProcessList := Array()
	
	__New(processes*) ; append processes to ProcessList
	{
		for app in processes
		{
			this.ProcessList.Push(app)
		}
	}
	
	; Initialize all necessary windows 
	Initialize()
	{
		Logger.Append(,"Initializing windows...")
		for app in this.ProcessList
		{
			if not this.WinExists(app)
				app.Start()
		}
		Logger.Append(,"Successfully initialized windows")
	}
	
	WinExists(app)
	{
		if WinExist(app.Ref)
			return True
		else
			return False
	}

	FocusWindow(app)
	{
		if this.WinExists(app)
		{
			WinActivate
		}
		else if WinWaitActive(app.Ref, , 5)
		{
			WinActivate app.Ref
		}
		else
		{
			if YesNoBox(app.Name . " is not running. Would you like to start it?") = "Yes"
				app.Start()
			else
				MsgBox "Unable to start " . app.Name . ". Exiting routine..."
				return
		}
	}

	MoveToLeftScreen(app)
	{
		this.FocusWindow(app)
		Send "{LWin down}{Shift down}{Left down}"
		Sleep 500
		Send "{LWin up}{Shift up}{Left up}"
	}

	MoveToRightScreen(app)
	{
		this.FocusWindow(app)
		Send "{LWin down}{Shift down}{Right down}"
		Sleep 500
		Send "{LWin up}{Shift up}{Right up}"
	}

	; Minimize window to taskbar.
	Shrink() => WinMinimize(this.Ref)
	
	; Show app again when in the taskbar.
	Grow() => WinRestore(this.Ref)
}

