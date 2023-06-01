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

	DsLength := 0

	Cols := Array()
	
	; create a store and keep it in memory
	BuildStore(path)
	{
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
					this.Cols.Push(k)
				}
				else
				{
					Loop parse, line, "CSV"
					{
						f := A_LoopField
						if k = f
							continue
						else
							v.%this.Cols[A_Index]% := f
					}
					this.Store(k, v)
				}
				this.DsLength += 1
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
	
	; Returns true or false if a value is parsed or not.
	IsParsed(k)
	{
		p := False
		try 
		{
			p := this.Retrieve(k).Parsed
		}
		catch
		{
			p := "FALSE"
		}
		if p = "TRUE"
			return true
		return false
	}

	; Sets a value in DataStore to Parsed, meaning it has been processed. By default, calling without v sets it to True.
	SetParsed(k, v := true)
	{
		this.Retrieve(k).Parsed := ( v ? "TRUE" : "FALSE" )
	}

	; wipes all data in LocalDataStore
	ClearDataStore() => this.LocalDataStore.Clear()
	
	cb := Clippy()

	; Turns the DataStore back into a comma separated string.
	DataStoreToFileString(scheme)
	{
		fileString := scheme . "`r`n"
		fileLen := this.DsLength/this.Cols.length ; divide by the amount of columns there are, since each column is assigned a value
		loop (fileLen)
		{
			lineString := ""
			lineNumber := A_Index
			if lineNumber != 1
			{
				orderIdx := lineNumber - 1
				for col in this.Cols
				{
					colIdx := A_Index
					v := ""
					if A_Index != this.Cols.length and colIdx != 1
						v := this.Retrieve(String(orderIdx)).%this.Cols[colIdx]% . ","
					else if A_Index = this.Cols.length
						v := orderIdx . (lineNumber = fileLen ? "" : "`r`n" )
					else
						v := this.Retrieve(String(orderIdx)).WPMID . ","
					lineString .= v
				}
			}
			fileString .= lineString
		}
		return fileString
	}
	
	; Given a variadic parameter of fields, go through them and set their values.
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
	; Access .ini config file
	static Config(s, k) => IniRead("config.ini", s, k)

	static IOInputPath := FileHandler.Config("Paths", "IOInputPath")
	static IOOutputPath := FileHandler.Config("Paths", "IOOutputPath")

	; Recursively compares every file to a target file name in a directory; if match, returns path of a target file.
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

	; Extracts a file's name from a path.
	static FileNameFromPath(path)
	{
		splitPath := StrSplit(path, "\")
		return splitPath[splitPath.length]
	}

	; Reads all the words in a file, returns the first match of a pattern.
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

	; Reads a CSV file line-by-line. If it encounters a word or char sequence equal to target, it returns its index on the line.
	static ReadCSVForColMatch(fileName, target)
	{
		Loop read, fileName
		{
			Loop parse, A_LoopReadLine, "CSV"
			{
				if A_LoopField = target
				{
					return A_LoopReadLine
				}
			}
		}
	}

	; Creates a new file title/path with a timestamp.
	static NewTimestampedFile(title, path?, ext?) => Format("{1}{2}-{3}.{4}", ( IsSet(path) ? path : FileHandler.Config("Paths", "OutputPath") ), title, Logger.GetFileDateTime(), ( IsSet(ext) ? ext : "txt") )

	; Creates an array of merchant objects from a CSV or TSV file. If the user wants to use a text file, provide a scheme.
	static CreateMerchantArray(file, scheme*)
	{
		merchants := Array()
		cols := Array()
		schemeLength := scheme.length
		
		if schemeLength > 0
		{
			for s in scheme
			{
				cols.Push(s)
			}
		}

		ext := StrSplit(file, ".")[2]
		attr := ""

		if ext = "tsv" and schemeLength = 0
		{
			Loop read, FileHandler.IOInputPath . file
			{
				i := A_Index
				attr := StrSplit(A_LoopReadLine, A_Tab)
				m := Merchant()
				for a in attr
				{
					j := A_Index
					if i = 1
					{
						cols.Push(a)
					}
					else
					{
						m.%cols[j]% := a
					}
				}
				if i != 1
				{
					m.scheme := cols
					merchants.Push(m)
				}
			}
		}
		else if ext = "csv" and schemeLength = 0
		{
			Loop read, FileHandler.IOInputPath . file
			{
				i := A_Index
				line := A_LoopReadLine
				m := Merchant()
				Loop parse, line, "CSV"
				{
					j := A_Index
					k := A_LoopField
					if i = 1 ; first line of CSV is column names, so add columns names to col for future ref
					{
						cols.Push(k)
					}
					else
					{
						m.%cols[j]% := A_LoopField
					}
				}
				if i != 1
				{
					m.scheme := cols
					merchants.Push(m)
				}
			}
		}
		else if ext = "txt" and schemeLength > 0
		{
			Loop read, FileHandler.IOInputPath . file
			{
				i := A_Index
				attr := StrSplit(A_LoopReadLine, A_Tab)
				m := Merchant()
				for a in attr
				{
					j := A_Index
					m.%cols[j]% := a
				}
				merchants.Push(m)
			}
		}
		else if ext = "txt" and schemeLength = 0
		{
			return -1
		}
	
		return merchants
	}

	tmpPath := FileHandler.Config("Paths", "TempFiles")

	__New(inPath?, outPath?, callerName?)
	{
		; getScheme(path)
		; {
		; 	file := FileOpen(path, "r")
		; 	return file.ReadLine()
		; }
		if IsSet(inPath)
			this.inPath := inPath
		if IsSet(outPath)
		{
			this.outPath := outPath
			; this.Scheme := getScheme(outPath)
			this.Scheme := FileHandler.Config("Defaults", "Scheme")
		}
		if IsSet(callerName)
			this.callerName := callerName
	}
	
	Config(s, k) => IniRead("config.ini", s, k)

	StringToCSV(str)
	{
		newFileName := this.tmpPath . this.callerName . ".csv"
		;try FileRecycle newFileName
		FileAppend str, this.inPath

		try FileMove this.inPath, newFileName
		try FileMove this.inPath, this.outPath, 1
		;try FileRecycle newFileName
	}

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

	RemoveTemp(path)
	{
		Try FileRecycle this.inPath
	}
}

class Merchant
{
	; Scheme for columns (abc, xyz, ...).
	scheme := Array()
	
	; General merchant information
	dba := "none"
	wpmid := "none"
	fdmid := "none"
	chain := "none"
	superChain := "none"
	tin := "none"
	dda := "none"
	openDate := "none"
	closedDate := "none"
	conversionDate := "none"

	; SalesforceDateFormat receives a date in the form of a string, then turns it into a date that is accepted by Salesforce fields.
	SalesforceDateFormat(s)
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
		
		newFormat .= SubStr(s, -4)

		return newFormat
	}
}