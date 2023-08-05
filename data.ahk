#Requires AutoHotkey v2.0

; handles the storing and movement of data
class DataHandler
{
	; map of (string : object)
	static DataStore := Map()
	
	; create the persistent store and keep it in memory
	static BuildStore(path)
	{
		Logger.Append(, "Building system DataStore...")
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
					col.Push(k)
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
		Logger.Append(, "DataStore built")
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

	; CopyFields receives a variadic parameter of fields, and goes through each item in it setting the field's respective value.
	static CopyFields(fields*)
	{
		Clippy.Shove("")
		for f in fields
		{
			f.val := Clippy.ClickAndCopy(f.X, f.Y)
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
	
	; BuildStore creates a store to keep in memory
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
	
	; Store stores a key and value into LocalDataStore
	Store(k ,v) => this.LocalDataStore.Set(k ,v)
	
	; Retrieve returns a value given key from LocalDataStore
	Retrieve(k) => this.LocalDataStore.Get(k)
	
	; Update updates if k exists in LocalDataStore
	Update(k, v) => (this.LocalDataStore.Has(k) ? this.LocalDataStore[k] := v : "")
	
	; Erase deletes a k from LocalDataStore
	Erase(k) => this.LocalDataStore.Delete(k)
	
	; IsParsed returns true or false if a value is already parsed or not. "Parsed" in this context refers to a row's column value given from a routine's TSV or CSV file located in the "resources/routines" folder. This folder serves as a type of memory on disk, so that if the program reloads, it can pick up where it left off, in other words, it knows whether it has already parsed a value or not.
	IsParsed(k)
	{
		p := false
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

	; SetParsed sets a value in DataStore to Parsed, meaning it has been processed in some routine or workflow. By default, calling without v sets it to True.
	SetParsed(k, v := true)
	{
		this.Retrieve(k).Parsed := ( v ? "TRUE" : "FALSE" )
	}

	; ResetParsed changes all TRUE values to FALSE in the parse map.
	SetAllParsedValues(v := false)
	{
		for k in this.LocalDataStore
		{
			this.SetParsed(k, v)
		}
	}

	; ClearDataStore wipes all data in LocalDataStore.
	ClearDataStore() => this.LocalDataStore.Clear()
	
	cb := Clippy()

	; DataStoreToFileString turns the DataStore back into a comma separated string.
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
					{
						v := this.Retrieve(String(orderIdx)).%this.Cols[colIdx]% . ","
					}
					else if A_Index = this.Cols.length
					{
						v := orderIdx . (lineNumber = fileLen ? "" : "`r`n" )
					}
					else
					{
						try
						{
							v := this.Retrieve(String(orderIdx)).wpmid . ","
						}
						catch
						{
							Logger.Append(, "Failed to create file string using wpmid")
						}

						try
						{
							v := this.Retrieve(String(orderIDX)).fdmid . ","
						}
						catch
						{
							logger.Append(, "Failed to create file string using fdmid")
						}
					}
					lineString .= v
				}
			}
			fileString .= lineString
		}
		return fileString
	}
	
	; CopyFields receives a variadic parameter of fields, and goes through each item in it setting the field's respective value.
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

	static Board := ""

	; access A_Clipboard directly. Shove a value into it!
	static Shove(v) => A_Clipboard := v
	
	static Copy()
	{
		Sleep 50
		Send "^c"
		Sleep 50
		return A_Clipboard
	}

	static Paste()
	{
		Send "^v"
		Sleep 100
		Clippy.emptyA_Clipboard()
		return this
	}

	static Attach(s)
	{
		Clippy.Board := s
		Clippy.emptyA_Clipboard()
	}

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

	static emptyA_Clipboard() => A_Clipboard := ""

	static ClickAndCopy(x, y)
	{
		Click(x, y)
		Sleep 100
		return Clippy.Copy()
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

; Field is a generic field value, can be for CAPS, browser, Excel, etc. Every window has a field.
class Field
{	
	; x and y values do not need to be set when instantiated.
	__New(x := 0, y := 0, val := "")
	{
		this.X := x
		this.Y := y
		this.val := val
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

	__New(inPath?, outPath?, callerName := "Defaults", schemeField := "Scheme") ; schemeField refers to the config.ini scheme's field for a routine.
	{
		this.callerName := callerName

		if IsSet(inPath)
			this.inPath := inPath

		if IsSet(outPath)
		{
			this.outPath := outPath
			this.Scheme := FileHandler.Config(callerName, schemeField) ; Scheme of the CSV, aka its columns.
		}
		
	}
	
	Config(s, k) => IniRead("config.ini", s, k)

	StringToCSV(str)
	{
		newFileName := this.tmpPath . this.callerName . ".csv"

		FileAppend str, this.inPath

		try FileMove this.inPath, newFileName
		try FileMove this.inPath, this.outPath, 1
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

class Scheme extends Array
{

}

class Merchant
{
	; Scheme for columns (abc, xyz, ...).
	scheme := Array()
	
	; General merchant information.
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
	fdCorpID := "none"
	fdChainID := "none"
	closureReason := "none"

	class ConversionCase
	{
		scheme := Scheme()

		caseStatus := ""
		caseOrigin := ""
		caseType := ""
		caseReason := ""
		caseDueDate := ""
		caseOpportunity := ""
		casePriority := ""
	}

	; CreateJSParseString assembles a string that the fieldUpdater.js code consumes. "sep" is the symbol that separates values. "link" is the symbol that joins two arrays together.
	CreateJSParseString(sep, link)
	{
		; Assemble the string to be delivered to Javascript via clipboard.
		headers := Array()
		values := Array()

		for f, v in this.OwnProps()
		{
			if f = "scheme"
				continue
			if v != "none" ; Omits "none" headers from string.
			{
				headers.Push(f)
				values.Push((SubStr(f, -4) = "Date" ? this.SalesforceDateFormat(v) : v))
			}
		}

		return StrJoin(values, sep) . link . StrJoin(headers, sep)
	}

	; SalesforceDateFormat receives a date in the form of a string, then turns it into a date that is accepted by Salesforce fields.
	SalesforceDateFormat(s)
	{
		if s = "none"
			return s
		
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

; Abstract Data Structures

class AbstractDataStructure
{
	__New()
	{
		this.arr := Array()
	}

	; Enum tutorial AHK v2: https://www.autohotkey.com/boards/viewtopic.php?t=88725
	; as well as https://github.com/ahk-v2-kb/internals/tree/master/Enumerator
	; and more specifically https://github.com/ahk-v2-kb/internals/blob/master/Enumerator/04_Enumerator_Collection.ahk
	__Enum(vars)
	{
		i := 1
		
		enumerate(&elm)
		{
			if i > this.Length()
				return False
			elm := this.arr[i]
			i++
			return True
		}

		return enumerate
	}

	Length() => this.arr.length
}

class Queue extends AbstractDataStructure
{
	; Enqueue adds an element to the queue, from the front.
	Enqueue(el) => this.arr.Push(el)

	; Dequeue removes an element form the queue, from the front.
	Dequeue()
	{
		firstElm := this.arr[1]
		this.arr.RemoveAt(1)
		return firstElm
	}
}

class Stack extends AbstractDataStructure
{
	; Push puts an element onto the top of the stack.
	Push(el) => this.arr.Push(el)

	; Pop removes an element from the top of the stack.
	Pop() => this.arr.Pop()
}