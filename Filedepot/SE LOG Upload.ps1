#Pfad fuer temporaere ZIP
$zippath = "c:\temp"
#Absender Email Adresse
$from = ""
#Mail Betreff
$subject = ""
#SMTP-Server
$smtp = ""

if ((Test-Path C:\Temp) -eq $false ){
    New-Item -Path C:\ -Name "Temp" -ItemType Directory
}

#Log erstellen und hochladen
$output = & "C:\Program Files (x86)\Server-Eye\tools\ServerEye.ErrorReport.exe" -nogui $zippath -upload | Select-String -Pattern "https://share.server-eye.de/download/"

#Mail an Support schicken
send-mailmessage -to "support@server-eye.de" -from "$from" -Subject "$subject" -body "$output" -SmtpServer $smtp
