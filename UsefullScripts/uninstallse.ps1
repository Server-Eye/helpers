#Requires -Version 5.0
#Requires -RunAsAdministrator

<# 
    .SYNOPSIS
    Uninstall Server-Eye

    .DESCRIPTION
    This Script will Uninstall Server-Eye and deletes all Server-Eye Data from the System.

    
#>

Param ( 
    [Parameter()] 
    [String]$Apikey 
)

$services = Get-Service -DisplayName Server-Eye* | Where-Object Status -EQ "Running"

if ($services) {
    Stop-Service $services
}


if ((Test-Path "C:\Program Files (x86)\Server-Eye") -eq $true) {
    if ($Apikey) {
        try {
            $CId = (Get-Content 'C:\Program Files (x86)\Server-Eye\config\se3_cc.conf' | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=","")
            Invoke-RestMethod -Uri "https://api.server-eye.de/2/container/$CId" -Method Delete -Headers @{"x-api-key"=$Apikey}
            Write-Output "Sensorhub was removed" 
        }
        catch {
            Write-Output "Error: $_"
        }
        
    }
    Write-Output "Server-Eye is installed on the System"
    $progs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
    $sesetup = $progs | Where-Object { ($_.Displayname -eq "Server-Eye") -and ($_.QuietUninstallString -like '"C:\ProgramData\Package Cache\*\ServerEyeSetup.exe" /uninstall /quiet') }
    $sevendors = $progs | Where-Object { ($_.Displayname -eq "Server-Eye Vendor Package") }
    $seservereye = $progs | Where-Object { ($_.Displayname -eq "Server-Eye") }
    if ($sesetup) {
        Write-Output "Performing uninstallation of Server-Eye via Setup"
        Start-Process -FilePath $sesetup.BundleCachePath -Wait -ArgumentList "/uninstall /quiet"
        Remove-Item -Path "C:\ProgramData\ServerEye3" -Recurse
    }
    elseif ($sevendors) {
        Write-Host "Performing uninstallation of Server-Eye via MSI"
        foreach ($sevendor in $sevendors) {
            $sechildname = $sevendor.pschildname
            Start-Process msiexec.exe -Wait -ArgumentList "/x $sechildname /q"
        }  
        $sechildname = $seservereye.pschildname
        Start-Process msiexec.exe -Wait -ArgumentList "/x $sechildname /q"
        Remove-Item -Path "C:\ProgramData\ServerEye3" -Recurse
    }
}
elseif (((Test-Path "C:\ProgramData\ServerEye3") -eq $true)) {
    if ($Apikey) {
        try {
            $CId = (Get-Content 'C:\ProgramData\ServerEye3\se3_cc.conf'| Select-String -Pattern "\bguid=\b").ToString().Replace("guid=","")
            Invoke-RestMethod -Uri "https://api.server-eye.de/2/container/$CId" -Method Delete -Headers @{"x-api-key"=$Apikey}
            Write-Output "Sensorhub was removed"
        }
        catch {
            Write-Output "Error: $_"
        }
        
    }    
    Write-Output "Server-Eye Data on the System, will be deleted."
    Remove-Item -Path "C:\ProgramData\ServerEye3" -Recurse
}
else {
    Write-Output "No Server-Eye Installation was found"
}