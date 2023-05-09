#Requires AutoHotkey v2.0

; handles the storing and movement of data
class DataHandler
{
	; map of (string : object)
	static DataStore := Map()
	
	; create the store and keep it in memory
	static BuildStore(path)
	{
		col := Array()
		Loop read, path
		{
			i := A_Index
			line := A_LoopReadLine
			Loop parse, line, "CSV"
			{
				k := A_LoopField
				v := {}
				if i = 1 ; first line of CSV is column names, so add columns names to col for future ref
				{
					col.Push(k)
				}
				else
				{
					Loop parse, line, "CSV"
					{
						f := A_LoopField
						if k = f
							continue
						else
							v.%col[A_Index]% := f
					}
					DataHandler.Store(k, v)
				}
			}
		}
	}
	
	; stores a key and value into global DataStore
	static Store(k ,v) => DataHandler.DataStore.Set(k ,v)
	
	; retrieves value given key from DataStore
	static Retrieve(k) => DataHandler.DataStore.Get(k)
	
	; updates if k exists in DataStore
	static Update(k, v) => (DataHandler.DataStore.Has(k) ? DataHandler.DataStore[k] := v : "")
	
	; deletes a k from DataStore
	static Erase(k) => DataHandler.DataStore.Delete(k)
	
	; wipes all data in DataStore
	static ClearDataStore() => DataHandler.DataStore.Clear()
	
	; gets rid of `r`n if we were copying from Excel
	static Sanitize(v) => RegExReplace(v, "`r`n$", "")
	
	; frees the memory for parameter vars
	static Free(vars*)
	{
		for v in vars
		{
			v := ""
		}
	}
	
	cb := Clippy()
	
	; given a variadic parameter of fields, go through them and set their values
	CopyFields(fields*)
	{
		this.cb.Clean()
		for f in fields
		{
			f.val := this.cb.ClickAndCopy(f.X, f.Y)
		}
	}
}

; abstracts away A_Clipboard
class Clippy
{
	; access A_Clipboard directly. Shove a value into it!
	static Shove(v) => A_Clipboard := v
	
	Board := ""
	
	emptyA_Clipboard() => A_Clipboard := ""
	
	; cleans clipboard to have nothing on it
	Clean()
	{
		this.Board := ""
		this.emptyA_Clipboard()
	}
	
	Attach(s)
	{
		this.Board := s
		this.emptyA_Clipboard()
	}
	
	; updates Clippy to new Clipboard
	Update()
	{
		this.Board := A_Clipboard
		this.emptyA_Clipboard()
		return this.Board
	}
	
	Copy()
	{
		Sleep 50
		Send "^c"
		Sleep 50
		this.Board := A_Clipboard
		this.emptyA_Clipboard()
		return this
	}
	
	Paste()
	{
		A_Clipboard := this.Board
		Send "^v"
		Sleep 100
		this.emptyA_Clipboard()
		return this
	}
	
	ClickAndCopy(x, y)
	{
		Click(x, y)
		Sleep 100
		this.Copy()
		return this.Board
	}
	
	SendEnter() => Send "{Enter}"
}

; generic Field value, can be for CAPS, browser, Excel, etc. Every window has a field.
class Field
{
	val := "" ; field's value, set to nothing on init
	
	__New(x, y)
	{
		this.X := x
		this.Y := y
	}
}