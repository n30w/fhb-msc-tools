#Requires AutoHotkey v2.0

; wrapper for opening programs
Open(s)
{
	Run(s.Path)
}

Close(s)
{
	WinClose(s.Ref)
}

class Application
{
	Name := ""
	__New(name?, pathDir?, fileName?, ref?)
	{
		if not IsSet(name)
			name := "none"
		else
			this.Name := name
		if not IsSet(fileName)
			fileName := "none"
		this.Path := ( IsSet(pathDir) ? pathDir . "\" . fileName : "resources\apps\" . fileName ) ; use default resource path
		this.Ref := ( IsSet(ref) ? ref : "none" ) ; reference by title or process name from AHK Window Spy
	}
	
	; Generic start function that can be overridden with custom start.
	Start() => Open(this)

	; Generic stop function that can be overridden with custom stop.
	Stop() => Close(this)
}