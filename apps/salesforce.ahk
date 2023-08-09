#Requires AutoHotkey v2.0

; actions for Salesforce
class SalesforceDB extends Application
{
	FullURL := ""

	; SalesforceDateFormat receives a date in the form of a string, then turns it into a date that is accepted by Salesforce fields.
	static SalesforceDateFormat(s)
	{
		if s = "none"
			return s
		
		newFormat := ""

		if SubStr(s, 1, 1) = 0 ; 0 in months place
			newFormat .= SubStr(s, 2, 2)
		else
			newFormat .= SubStr(s, 1, 3)

		if SubStr(s, 4, 1) = 0 ; 0 in days place
			newFormat .= SubStr(s, 5, 2)
		else
			newFormat .= SubStr(s, 4, 3)
		
		newFormat .= SubStr(s, -4)

		return newFormat
	}

	; On Microsoft Edge, the bookmark bar can be accessed using the keyboard with the "alt" key. This focuses the bookmark bar and selects the first item on it.
	altShiftB()
	{
		Send "{Alt down}{Shift down}b"
		Sleep 200
		Send "{Alt up}{Shift up}"
		; Send "!+a"
		Sleep 200
	}
	
	months := Map(
		"JAN", "1",
		"FEB", "2",
		"MAR", "3",
		"APR", "4",
		"MAY", "5",
		"JUN", "6",
		"JUL", "7",
		"AUG", "8",
		"SEP", "9",
		"OCT", "10",
		"NOV", "11",
		"DEC", "12"
	)
	
	; AccountURL returns a URL that directs to the merchant's account page on Salesforce.
	AccountURL(s) => "https://fhbank.lightning.force.com/lightning/r/Account/" . this.urlID(s) . "/view"
	
	; CaseURL returns a URL that directs to the merchant's conversion case page on Salesforce.
	CaseURL(s) => "https://fhbank.lightning.force.com/lightning/r/Case/" . this.urlID(s) . "/view"

	; urlID builds a URL ID
	urlID(s) => (s . this.convert15to18(s))

	; HasURL checks if a merchant has a corresponding AccountID in the local DataStore(s). It returns True or False. The "merchant" parameter is a merchant object, "key" is the lookup to retrieve the corresponding object in the DataStore, "value" is the value to retrieve from the retrieved object, and the "d" is an optional DataStore that the user provides.
	HasURL(merchant, key, value, d?)
	{
		try
		{
			if IsSet(d)
				this.FullURL := this.AccountURL(d.Retrieve(merchant.%key%).%value%)
			else
				this.FullURL := this.AccountURL(DataHandler.Retrieve(merchant.%key%).%value%)
		}
		catch
		{
			Logger.Append(this.HasURL.Name, "ERROR: Unable to retrieve merchant AccountID => " . merchant.%key% . " does not exist in DataStore")
			return False
		}
		return True
	}

	HasCaseURL(m, d?)
	{
		try
		{
			if IsSet(d)
				this.FullURL := this.CaseURL(d.Retrieve(m.wpmid).CaseID)
			else
				this.FullURL := this.CaseURL(DataHandler.Retrieve(m.wpmid).CaseID)
		}
		catch
		{
			Logger.Append(this.HasURL.Name, "ERROR: Unable to retrieve merchant CaseID => " . m.wpmid . " does not exist in DataStore")
			return False
		}
		return True
	}

	; algorithm from: https://help.salesforce.com/s/articleView?id=000383751&type=1
	; I rewrote it in AHK
	convert15to18(s)
	{
		Sleep 500
		addon := ""
		block := 0
		A := Ord("A")
		Z := Ord("Z")
		
		loop 3
		{
			loo := 0
			position := 1
			loop 5
			{
				current := Ord(SubStr(s, (block * 5) + position, 1))
				if current >= A and current <= Z
					loo += Integer(1 << position-1) ; position-1 because the bitshift would overshoot into the hundreds
				position++
			}
			addon .= SubStr("ABCDEFGHIJKLMNOPQRSTUVWXYZ012345", loo+1, 1) ; loo+1 since index in AHK starts at 1
			block++
		}
		return addon
	}
	
	; reformats date into mm/dd/yyyy
	reformatDate(dateField)
	{
		dateObj := StrSplit(dateField, "-")
		return this.months[dateObj[2]] . "/" . dateObj[1] . "/" . "20" . dateObj[3]
	}

	UpdateConversionDate(cd)
	{
		accessConvDate()
		{
			Send "{Right 1}"
			Sleep 200
			Send "{Enter}"
			Sleep 200
		}

		this.altShiftB()
		accessConvDate()
		Sleep 400
		Send "{Enter}"
		Sleep 100

		t := 0
	 	i := 10

	 	; wait for page to load and check clipboard, or else it times out
	 	while (A_Clipboard = "none") and (t < 15000)
	 	{
	 		; wait
	 		Sleep i
	 		t += i
	 	}

		if t > 15000
	 		throw Error("Can't access webpage", -1)
		
		if (A_Clipboard != cd) or (A_Clipboard = "null")
		{	
			; ClickEdit
			this.altShiftB()
			accessConvDate()
			Send "{Down 1}"
			Sleep 400
			Send "{Enter}"
			Sleep 1400

			Clippy.Shove(cd)

			; ChangeDate
			this.altShiftB()
			accessConvDate()
			Send "{Down 2}"
			Sleep 400
			Send "{Enter}"
			Sleep 1100

			; SaveEdit
			this.altShiftB()
			Send "{Right 4}"
			Sleep 400
			Send "{Enter}"
			Sleep 1000
		}
	}

	; UpdateFields updates field data on Salesforce, like FD Conversion Dates, DBAs, or anything of that matter. It should receive a merchant object. It uses that merchant object to call the "SalesforceDateFormat" method.
	UpdateFields(m)
	{
		; Put code here...
	}

	UpdateFDMID(fdmid)
	{
		; checks if SF account has FDMID
		this.altShiftB()
		Send "{Enter}"
		Sleep 200
		Send "{Enter}"
		Sleep 200
		
		if A_Clipboard = "null"
		{
			this.altShiftB()
			Send "{Down 1}"
			Sleep 200
			Send "{Enter}"
			Sleep 200

			
			this.altShiftB()
			Send "{Down 2}"
			Sleep 200
			Send "{Enter}"
			Sleep 200

			Clippy.Shove(fdmid)
			Sleep 100
			Send "^v"
			Sleep 100
			Send "{Enter}"
			Sleep 400

			this.altShiftB()
			Send "{Down 3}"
			Sleep 200
			Send "{Enter}"
			Sleep 200
		}
	}
}

class CaseUpdaterBookmarklet extends SalesforceDB
{
	UpdateFields(jsParseString)
	{
		Clippy.Shove(jsParseString)
		
		this.altShiftB()
		Sleep 300
		Send "{Right 1}"
		Sleep 100
		Send "{Right 1}"
		Sleep 100
		Send "{Enter down}"
		Sleep 100
		Send "{Enter up}"
		Sleep 400

		t := 0
	 	i := 50
		tMax := 12000

	 	; wait for page to load and check clipboard, or else it times out
	 	while (A_Clipboard = jsParseString) and (t <= tMax)
	 	{
	 		; wait
	 		Sleep i
	 		t += i
	 	}

		if t >= tMax
	 		return "INACCESSIBLE" ; If this is returned, something went wrong doing the bookmarklet.

		Sleep 200

		if A_Clipboard = "equal"
		{
			return "EQUAL"
		}

		if A_Clipboard = "changed"
		{
			return "CHANGED"
		}
	}
}

class FieldUpdaterBookmarklet extends SalesforceDB
{
	UpdateFields(jsParseString)
	{
		Clippy.Shove(jsParseString)
		
		this.altShiftB()
		Sleep 300
		Send "{Right 1}"
		Sleep 100
		Send "{Enter down}"
		Sleep 160
		Send "{Enter up}"
		Sleep 400

		t := 0
	 	i := 50
		tMax := 12000

	 	; wait for page to load and check clipboard, or else it times out
	 	while (A_Clipboard = jsParseString) and (t <= tMax)
	 	{
	 		; wait
	 		Sleep i
	 		t += i
	 	}

		if t >= tMax
	 		return "INACCESSIBLE" ; If this is returned, something went wrong doing the bookmarklet.

		Sleep 200

		if A_Clipboard = "equal"
		{
			return "EQUAL"
		}

		if A_Clipboard = "changed"
		{
			return "CHANGED"
		}
	}
}