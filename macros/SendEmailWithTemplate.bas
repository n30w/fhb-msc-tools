' Created with the help of ChatGPT
Sub SendEmailWithTemplate()
    Dim oMail As Outlook.MailItem
    Dim oRecip As Outlook.Recipient
    Dim oInspector As Outlook.Inspector
    Dim TemplatePath As String
    
    ' Set the path to your email template
    TemplatePath = ThisWorkbook.Path & "\readyforconversion.oft"
    
    ' Create a new email using the template
    Set oMail = Application.CreateItemFromTemplate(TemplatePath)
    
    ' Add recipients
    Set oRecip = oMail.Recipients.Add("mthach@fhb.com")
    oRecip.Type = olTo ' Change to olCC or olBCC if needed
    
    Set oRecip = oMail.Recipients.Add("aimee.lyssenko@fiserv.com")
    ORecip.Type = olTo
    
    ' Display the email for editing
    oMail.Display
    
    ' Automatically send the email
    ' oMail.Send
    
    ' Uncomment the line above to automatically send the email without displaying it
    
    ' Clean up objects
    Set oMail = Nothing
    Set oRecip = Nothing
    Set oInspector = Nothing
End Sub

