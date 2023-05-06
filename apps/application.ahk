#Requires AutoHotkey v2.0

; wrapper for opening programs
Open(s)
{
	Run(s.Path)
}

class Application
{
	__New(name, path, ref)
	{
		this.Name := name ; name for program
		this.Path := path ; location with file name
		this.Ref := ref ; reference by title or process name from AHK Window Spy
	}
	
	; generic start function that can be overriden with custom start
	Start() => Open(this)
	
	; minimize window to dock
	Shrink() => WinMinimize(this.Ref)
	
	Grow() => WinRestore(this.Ref)
}