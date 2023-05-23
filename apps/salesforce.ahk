#Requires AutoHotkey v2.0

; actions for Salesforce
class SalesforceDB extends Application
{
	FullURL := ""

	altShiftB()
	{
		Send "{Alt down}{Shift down}b"
		Sleep 150
		Send "{Alt up}{Shift up}"
		Sleep 150
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
	
	AccountURL(s) => "https://fhbank.lightning.force.com/lightning/r/Account/" . this.urlID(s) . "/view"
	
	CaseURL(s) => "https://fhbank.lightning.force.com/lightning/r/Case/" . this.urlID(s) . "/view"

	; build URL ID
	urlID(s) => (s . this.convert15to18(s))

	HasURL(l, m)
	{
		try
		{
			this.FullURL := this.AccountURL(DataHandler.Retrieve(m.wpmid).AccountID)
		}
		catch
		{
			l.Append(this.ConvertMIDToCaseID.Name, "ERROR: Unable to retrieve merchant AccountID => " . m.wpmid . " does not exist in DataStore")
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
		Clippy.Shove("none")

		t := 0
		i := 100

		; wait for page to load and check clipboard, or else it times out
		while (A_Clipboard = "none") and (t < 15000)
		{
			; wait
			Sleep i
			t += i
		}
		
		if t > 15000
			throw Error("Can't access webpage", -1)

		if (A_Clipboard = "null") or (A_Clipboard != cd)
			Clippy.Shove(cd)
		
		if A_Clipboard = cd
			return

		Sleep 300

		t := 0

		c := DataHandler.Sanitize(A_Clipboard)
		while (c != "finished") and (t < 15000)
		{
			; wait
			Sleep i
			t += i
		}

		Clippy.Shove("")

		if t > 15000
			throw Error("Can't access webpage", -1)
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