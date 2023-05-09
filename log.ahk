#Requires AutoHotkey v2.0

class Logger
{
	logFilePath := ""
	
	getFileDateTime() => FormatTime(,"yyyyMMdd-hhmmsstt")
	getEntryDateTime() => FormatTime(,"Time")
	
	__New(lfp)
    {
        this.logFilePath := lfp . this.getFileDateTime() . " log.txt"
    }
	
    Append(message)
    {
        timestamp := this.getEntryDateTime()
        logEntry := "[" . timestamp . "] " . message
        
        FileAppend(logEntry . "`n", this.logFilePath)
    }
}