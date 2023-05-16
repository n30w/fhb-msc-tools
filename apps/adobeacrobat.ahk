#Requires AutoHotkey v2.0

class AdobeAcrobat extends Application
{
    GoToFinalPage()
    {
        Send "{End}"
    }
}