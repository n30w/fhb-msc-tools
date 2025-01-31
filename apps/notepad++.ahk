#Requires AutoHotkey v2.0

class NotepadPP extends Application
{
	templateText := "
	(
	## {1}
	IF THEY DONT WANT TO DO BUSINESS WITH US ANYMORE, RETRIEVE FAX OR EMAIL FOR CLOSE FORMS.

	~
	
	DBA NAME: {1}
	FDMS MID: {3}
	WP MID: {2}
	TERMINAL ORDER/QTY: [FD150] [Qty]
	PIN PAD: [Qty]
	TERMINAL FEATURES: [IP or Dial Up (cannot be both)]
	PAYMENT SELECTION: [all up front/installment: 3/130, 6/65, 12/32.50]
	ENTITLEMENTS: [MC/VISA/DISC/AMEX/PIN DEBIT/EBT/Other]
	TIP: [yes/no]
	EMAIL: [required!]
	ACCOUNT UPDATES: [new address, contact, phone, etc]
	SHIPPING ADDRESS:
	)"
	
	NewFile()
	{
		Send "^n"
		Sleep 200
		return this
	}
	
	; sets file to Markdown syntax option
	ChangeSyntaxLang()
	{
		Sleep 100
		Click 80, 824, "Right"
		Sleep 100
		Click 140, 740
		return this
	}
}