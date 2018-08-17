# Server-Eye GPO Install
# Version 2.0
# Author: Thomas Krammes
# Author: Andreas Behr
#
# Weitere Informationen zu diesem Skript finden Sie hier:
# https://servereye.freshdesk.com/support/solutions/articles/14000062437

# Die folgenden Werte muessen angepasst werden
$customer=""
$secret=""
$templateid=""
$apikey=""
$parentGuid=""
$logdatei="c:\se_install_log.txt"
$remoteLog="\\fileserver\se_install\$env:computername.txt"
# Ändern auf $true wenn keine Log bei bestehender Installtion gewünscht sind
$noinstallLog = $false

#
# Aendern Sie bitte nichts unterhalb dieser Zeile
#

# Download der aktuellen Version
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://occ.server-eye.de/download/se/Deploy-ServerEye.ps1","$env:windir\temp\ServerEye.ps1")


# Installation Server-Eye
Set-Location "$env:windir\temp"

If ($noinstallLog -eq $true){
    .\ServerEye.ps1 -Download -Install -Deploy SensorhubOnly -ParentGuid $parentGuid -Customer $customer -Secret $secret -ApplyTemplate -TemplateId $templateid -ApiKey $apikey -DeployPath "$env:windir\temp" -LogFile $logdatei -Silent -SkipLogInstalledCheck
}
else {
    .\ServerEye.ps1 -Download -Install -Deploy SensorhubOnly -ParentGuid $parentGuid -Customer $customer -Secret $secret -ApplyTemplate -TemplateId $templateid -ApiKey $apikey -DeployPath "$env:windir\temp" -LogFile $logdatei -Silent
}


Copy-Item $logdatei $remoteLog 
