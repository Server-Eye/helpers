<# 
    .SYNOPSIS
    Uninstall Avira Antivirus and the Avira Launcher.

    .DESCRIPTION
    This Script will Uninstall Avira Antivirus and the Avira Launcher form the System.

    .PARAMETER Restart
    Will Restart the System after the uninstall is finished.
    
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [switch]$Restart
)

Write-Host "Performing uninstallation of Avira Antivirus"
Start-Process -FilePath "C:\Program Files\Avira\Antivirus\presetup.exe" -ArgumentList "/remsilent"

$avira = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {($_.Displayname -eq "Avira") -and ($_.QuietUninstallString -like '"C:\ProgramData\Package Cache\*\Avira.OE.Setup.Bundle.exe" /uninstall /quiet')}
Write-Host "Performing uninstallation of Avira Launcher"

Start-Process -FilePath $avira.BundleCachePath -Wait -ArgumentList "/uninstall /quiet"

If ($Restart.IsPresent -eq $true){
    Restart-Computer -Force
}

