#Requires AutoHotkey v2.0

#Include "actions.ahk"
#Include "log.ahk"

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
	
	__New(logger, processes*) ; append processes to ProcessList
	{
		this.logger := logger
		for app in processes
		{
			this.ProcessList.Push(app)
		}
	}
	
	; Initialize all necessary windows 
	Initialize()
	{
		this.logger.Append("Initializing windows...")
		for app in this.ProcessList
		{
			if not WinExists(app)
				app.Start()
		}
		this.logger.Append("Successfully initialized windows")
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

