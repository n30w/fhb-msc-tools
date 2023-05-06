#Requires AutoHotkey v2.0

#Include "actions.ahk"

WinExists(app)
{
	if WinExist(app.Ref)
		return True
	else
		return False
}

class Windows
{
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
		for app in this.ProcessList
		{
			if not WinExists(app)
				app.Start()
		}
	}
	
	FocusWindow(app)
	{
		if WinExists(app)
		{
			WinActivate
		}
		else
		{
			if YesNoBox(app.Name . " is not running. Would you like to start it?") = "No"
				return
			else
				app.Start()
		}
	}
}

