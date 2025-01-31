#Requires Autohotkey v2.0

class OutlookMail extends Application
{
    CreateNewEmail()
    {
        Send "^n"
        WinWaitActive "Untitled - Message (Rich Text) "
        return this
    }

    To(t?)
    {
        if IsSet(t)
            Send t
        Send "{Tab}"
        return this
    }

    CC(t?)
    {
        if IsSet(t)
            Send t
        Send "{Tab}"
        return this
    }

    Subject(t?)
    {
        if IsSet(t)
            Send t
        Send "{Tab}"
        return this
    }

    Body(t?)
    {
        if IsSet(t)
            Send t
    }

    SendEmail()
    {
        Sleep 1000
        Send "{Esc}"
        Sleep 500
        Send "{Ctrl down}"
		Sleep 200
		Send "{Enter}"
        Sleep 200
		Send "{Ctrl up}"
        Sleep 200
        return this
    }

    SendEmail2()
    {
        Send "{Ctrl down}"
		Sleep 200
		Send "{Enter}"
        Sleep 200
		Send "{Ctrl up}"
        Sleep 200
        return this
    }

    SendOrderMacro()
    {
        Send "y"
        Sleep 100
        Send "1"
    }

    SendClosureMacro()
    {
        Send "y"
        Sleep 50
        Send "2"
    }

    SendComposeEmailWithFontMacro()
    {
        Send "y"
        Sleep 50
        Send "3"
    }

    AccessMenuItem(key)
    {
        Send "{Alt}" . key
        Sleep 100
        return this
    }

    GoToSubjectLineFromBody()
    {
        Send "{Shift down}{Tab down}"
		Sleep 200
		Send "{Shift up}{Tab up}"
    }

    GoToMiddleOfBodyFromSubjectLine()
    {
        Send "{Tab down}"
		Sleep 300
		Send "{Tab up}"
		Send "{Down 3}"
    }
}