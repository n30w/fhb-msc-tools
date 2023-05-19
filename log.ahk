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
	
    Append(app?, message := "")
    {
        timestamp := this.GetEntryDateTime()
        logEntry := "[" . timestamp . "] "
        
		if IsSet(app)
			logEntry .= "@" . StrUpper(( IsObject(app) ? app.Name : app )) . " => "
		
		FileAppend(logEntry . message "`n", this.logFilePath)
    }
}