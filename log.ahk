#Requires AutoHotkey v2.0

class Logger
{
	logFilePath := ""
	
	GetFileDateTime() => FormatTime(,"yyyyMMdd-hhmmsstt")
	GetEntryDateTime() => FormatTime(,"hh:mm:ss tt")
	
	__New(filePath?)
    {
		if not IsSet(filePath)
		{
			DirCreate "logs"
			filePath := "logs\"
		}
		
		this.logFilePath := filePath . this.GetFileDateTime() . " log.txt"
		this.Append(,"System boot, logged in as " . StrUpper(A_Username))
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
	}
}

class Timer
{
	startTime := 0
	stopTime := 0

	StartTimer() => this.startTime := A_TickCount

	StopTimer() => this.stopTime := A_TickCount

	ElapsedTime()
	{
		tt := this.stopTime - this.startTime
		
		h := Round(tt/3600000)
		r := Mod(tt, 3600000)
		m := Round(r/60000)
		r := Mod(r, 60000)
		s := Round(r/1000)
		r := Mod(r, 1000)
		mi := r
		
		this.stopTime := 0
		this.startTime := 0

		return  ( (h != 0 ? h . "hrs " : "") . m . "min " . s . "." . mi . "sec" )
	}

}