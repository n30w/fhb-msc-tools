^F1::

b := Array()

loop 3 { ; 116
	;Click 253 121
	
	A_Clipboard :=
	Send ^c
	ClipWait
	n := A_Clipboard
	;MsgBox % Format("{:s}", n)
	
	Send {Right}
	
	A_Clipboard :=
	Send ^c
	ClipWait
	d := A_Clipboard
	
	Send {Left}
	Send {Down}
	
	Sleep 500
	Send {Alt down}
	Sleep 200
	Send {Tab}{Alt up}
	
	Sleep 500
	Click 552 104
	Sleep 500
	Send ^a
	A_Clipboard = %n%
	Send ^v
	Send {Enter}
	Sleep 1000
	Send {Tab}
	Sleep 500
	Send {Enter}
	
	Sleep 2000
	
	Send {Tab 46}
	Send {Enter}
	
	Sleep 500
	Send ^a
	A_Clipboard = %d%
	Send ^v
	Click 726 841
	
	Sleep 200
}

return

^!x:: ExitApp