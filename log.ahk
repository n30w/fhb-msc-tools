#Requires AutoHotkey v2.0

class Logger
{
	logFilePath := ""
	
	getFileDateTime() => FormatTime(,"yyyyMMdd-hhmmsstt")
	getEntryDateTime() => FormatTime(,"hh:mm:ss tt")
	
	__New(filePath?)
    {
		if not IsSet(filePath)
		{
			DirCreate "logs"
			filePath := "logs\"
		}
		
		this.logFilePath := filePath . this.getFileDateTime() . " log.txt"
		this.Append(,"System boot, logged in as " . StrUpper(A_Username))
    }
	
    Append(app?, message := "")
    {
        timestamp := this.getEntryDateTime()
        logEntry := "[" . timestamp . "] "
        
		if IsSet(app)
			logEntry .= "@" . StrUpper(( IsObject(app) ? app.Name : app )) . " => "
		
		FileAppend(logEntry . message "`n", this.logFilePath)
    }
}