#Requires AutoHotkey v2.0

class ObsidianVault extends Application
{
	templateText := "
	(
	#todo
	~
	
	
	
	---

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
	
	; opens the open file menu and sends a string
	OpenOpenMenu(s)
	{
		Sleep 50
		Send "^o"
		Send s
		Sleep 100
		Send "{Enter}"
		Sleep 300
	}
}