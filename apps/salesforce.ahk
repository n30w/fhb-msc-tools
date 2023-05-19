#Requires AutoHotkey v2.0

; actions for Salesforce
class SalesforceDB extends Application
{
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

	UpdateFDMID(fdmid)
	{
		altShiftB()
		{
			Send "{Alt down}{Shift down}b"
			Sleep 150
			Send "{Alt up}{Shift up}"
			Sleep 150
		}
		
		altShiftB()
		Send{"Enter"}
		Sleep 200
		
		altShiftB()
		Send {"Right 1"}
		Send{"Enter"}
		Sleep 200

		Clippy.Shove(fdmid)
		Sleep 100
		Send "^v"
		Sleep 100
		Send "{Enter}"
		Sleep 400

		altShiftB()
		Send {"Right 2"}
		Send{"Enter"}
		Sleep 200

	}
}