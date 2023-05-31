#Requires AutoHotkey v2.0

class Logger
{
	logFilePath := ""
	
	static GetFileDateTime() => FormatTime(,"yyyyMMdd-hhmmsstt")

	GetFileDateTime() => FormatTime(,"yyyyMMdd-hhmmsstt")
	GetEntryDateTime() => FormatTime(,"hh:mm:ss tt")
	
	__New(filePath?)
    {
		if IsSet(filePath)
		{
			this.logFilePath := filePath . this.GetFileDateTime() . " log.txt"
			if InStr(filePath, "logs\system")
				this.Append(,"System boot, logged in as " . StrUpper(A_Username))
		}
		else
		{
			DirCreate "logs"
			this.logFilePath := "logs\"
		}
    }
	
    Append(app?, msg := "")
    {
        timestamp := this.GetEntryDateTime()
        logEntry := "[" . timestamp . "] "
        
		if IsSet(app)
			logEntry .= "@" . StrUpper(( IsObject(app) ? app.Name : app )) . " => "
		
		FileAppend(logEntry . msg "`n", this.logFilePath)
    }

	Timer(msg, t)
	{
		this.Append(, "===== " . msg . " [" . t.ElapsedTime() . "]" . " =====")
		t.Reset()
	}
}

class Timer
{
	__New()
	{
		this.startTime := 0
		this.stopTime := 0
		this.total := 0 ; total time if doing multiple stop/start
	}

	addToTotalTime() => this.total += this.stopTime - this.startTime

	; Starts timer.
	StartTimer() => this.startTime := A_TickCount

	; Stops and updates timer's total time ran.
	StopTimer()
	{
		this.stopTime := A_TickCount
		this.addToTotalTime()
		this.Reset()
	}

	; Creates and returns a formatted hour, minute, second, millisecond string
	ElapsedTime(t?)
	{
		et := 0
		if IsSet(t)
			et := t
		else
			et := this.total
		
		h := et//3600000
		r := Mod(et, 3600000)
		m := r//60000
		r := Mod(r, 60000)
		s := r//1000
		r := Mod(r, 1000)
		mi := r
		
		this.Reset()

		return  ( (h != 0 ? h . "hrs " : "") . m . "min " . s . "." . mi . "sec" )
	}

	Reset()
	{
		this.startTime := 0
		this.stopTime := 0
	}

	TotalTime() => this.total
}

class StatusBar
{
	xPos := 0
	yPos := 0
	
	__New(x := 2020, y := 945)
	{
		CoordMode "Tooltip", "Screen"
		this.xPos := x
		this.yPos := y
	}

	Reset()
	{
		ToolTip
	}

	Show(msg)
	{
		ToolTip msg, this.xPos, this.yPos
	}
}

class Statistics
{
	
}