#Requires AutoHotkey v2.0

; handles the storing and movement of data
class DataHandler
{
	; map of (string : object)
	static DataStore := Map()
	
	; create the peristent store and keep it in memory
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

	; Code below is for instance specific datastores, and may be used when a routine requires ephemeral input k/v storage

	__New(path?)
	{
		if IsSet(path)
			this.BuildStore(path)
	}
	
	; map of (string : object)
	LocalDataStore := Map()
	
	; create a store and keep it in memory
	BuildStore(path)
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
					this.Store(k, v)
				}
			}
		}
	}
	
	; stores a key and value into LocalDataStore
	Store(k ,v) => this.LocalDataStore.Set(k ,v)
	
	; retrieves value given key from LocalDataStore
	Retrieve(k) => this.LocalDataStore.Get(k)
	
	; updates if k exists in LocalDataStore
	Update(k, v) => (this.LocalDataStore.Has(k) ? this.LocalDataStore[k] := v : "")
	
	; deletes a k from LocalDataStore
	Erase(k) => this.LocalDataStore.Delete(k)
	
	; wipes all data in LocalDataStore
	ClearDataStore() => this.LocalDataStore.Clear()
	
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
	
	static IsEmpty(m)
	{
		if StrLen(m) < 1
		{
			MsgBox "No MID on Clipboard"
			return True
		}
		else
		{
			return False
		}
	}

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

class FileHandler
{

	Config(s, k) => IniRead("config.ini", s, k)

	__New()
	{
		this.ip := this.Config("Paths", "InputPath")
		this.op := this.Config("Paths", "OutputPath")
	}

	;  Recursively compares every file to a target file name in a directory; if match, returns path of a target file.
	static RetrievePath(dir, name, ext)
	{
		fileName := ""
		ext := "." . ext
		Loop Files, dir . "\*" . ext, "R"
		{
			SplitPath(A_LoopFileName, &fileName)
			if fileName = name . ext
			{
				foundPath := A_LoopFileFullPath
				return foundPath
			}
		}
		return "none"
	}

	; Reads all the words in a file, returns the first match of a pattern
	static MatchPatternInFile(path, pattern)
	{
		; array position of found match
		foundPos := 0

		match := ""

		; parse it line by line, word by word
		Loop read, path
		{
			words := StrSplit(A_LoopReadLine, A_Space, ".")
			for word in words
			{
				word := DataHandler.Sanitize(word)
				
				foundPos := RegExMatch(word, pattern, &match)

				if foundPos != 0
					return match
			}
		}
	}
	
	; Adds a new line to a specified file. Appends `r`n to the end of the line.
	static AddLineToFile(msg, f)
	{
		FileAppend(msg . "`r`n", f)
	}

	; Creates a new file title/path with a timestamp.
	static NewTimestampedFile(title, path?, ext?) => Format("{1}{2}-{3}.{4}", ( IsSet(path) ? path : this.Config("Paths", "OutputPath") ), title, Logger.GetFileDateTime(), ( IsSet(ext) ? ext : "txt") )

	; Captures order from a file
	ReadOrder(path)
	{
		div := False ; checks for divider ---
		order := ""

		; Only copy the order
		Loop read, path
		{
			line := A_LoopReadLine 
			if (line = "---") and (div = True)
				break
			if (line = "---")
			{
				div := True
				continue
			}
			if div
				order .= line . "`n"
		}

		return order
	}

	TextToMerchantArray(path)
	{
		merchants := Array()
		Loop read, this.ip . path
		{
			attr := StrSplit(A_LoopReadLine, A_Tab)
			merchant := { wpmid: attr[1], fdmid: attr[2], dba: "" }
			merchants.Push(merchant)
		}
		return merchants
	}

	TextToMerchantAndDateArray(path)
	{
		; remove 0's in date
		newDateFormat(s)
		{
			newFormat := ""

			if SubStr(s, 1, 1) = 0 ; 0 in months place
			{
				newFormat .= SubStr(s, 2, 2)
			}
			else
			{
				newFormat .= SubStr(s, 1, 3)
			}

			if SubStr(s, 4, 1) = 0 ; 0 in days place
			{
				newFormat .= SubStr(s, 5, 2)
			}
			else
			{
				newFormat .= SubStr(s, 4, 3)
			}
			
			newFormat .= "20" . SubStr(s, -2)

			return newFormat
		}

		merchants := Array()

		Loop read, this.ip . path
		{
			attr := StrSplit(A_LoopReadLine, A_Tab)
			merchant := { wpmid: attr[1], newDate: newDateFormat(attr[2]) }
			merchants.Push(merchant)
		}

		return merchants
	}

	TextToMerchantAccountIDArray(path)
	{
		merchants := Array()

		Loop read, this.ip . path
		{
			attr := StrSplit(A_LoopReadLine, A_Tab)
		}
	}
}