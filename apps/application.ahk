#Requires AutoHotkey v2.0

; wrapper for opening programs
Open(s)
{
	Run(s.Path)
}

class Application
{
	__New(name, pathDir?, fileName?, ref?)
	{
		this.Name := name ; internal name for program
		if not IsSet(fileName)
			fileName := "none"
		this.Path := ( IsSet(pathDir) ? pathDir . "\" . fileName : "resources\apps\" . fileName ) ; use default resource path
		this.Ref := ( IsSet(ref) ? ref : "none" ) ; reference by title or process name from AHK Window Spy
	}
	
	; generic start function that can be overriden with custom start
	Start() => Open(this)
	
	; minimize window to dock
	Shrink() => WinMinimize(this.Ref)
	
	Grow() => WinRestore(this.Ref)
}