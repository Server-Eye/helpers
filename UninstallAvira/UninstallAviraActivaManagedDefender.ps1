#Requires -PSEdition Desktop
<# 
    .SYNOPSIS
    Uninstall Avira Antivirus and the Avira Launcher.

    .DESCRIPTION
    This Script will Uninstall Avira Antivirus and the Avira Launcher form the System and remove Avira Sensor and also add Managed Defender Sensor.

    .PARAMETER Restart
    Set to something other then 0 to Restart after Avira uninstall.

    .PARAMETER AddDefender
    Set to something other then 0 to add the Server-Eye Managed Windows Defender Sensor.

    .PARAMETER Apikey
    API Key mandatory to remove or add Sensors.
    
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false,
        HelpMessage = "Set to something other then 0 to Restart after Avira uninstall")]
    [int]$Restart = 0,
    [Parameter(Mandatory = $false,
        HelpMessage = "Set to something other then 0 to add the Server-Eye Managed Windows Defender Sensor")]
    [int]$AddDefender = 0,
    [Parameter(Mandatory = $false,
        HelpMessage = "API Key to remove or add Sensors")] 
    [String]$Apikey
)

Begin {
    Write-Host "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
    #region Register Eventlog Source
    try { New-EventLog -Source "Server-EyeManagedAntivirus" -LogName "Application" -ErrorAction Stop | Out-Null }
    catch { }
    #endregion Register Eventlog Source
    Checkpoint-Computer -Description "Pre Server-Eye MAV Uninstall" -RestorePointType "APPLICATION_UNINSTALL"
}
 
Process {
    try {
        Write-Output "Doing lot's of work here"
        if ($Apikey) {
            try {
                Write-Output "Removing Avira Sensor"
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Removing Avira Sensor"
                $CId = (Get-Content 'C:\Program Files (x86)\Server-Eye\config\se3_cc.conf' | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=", "")
                $Sensors = Invoke-RestMethod -Uri "https://api.server-eye.de/2/container/$cid/agents" -Method Get -Headers @{"x-api-key" = $Apikey } 
                $MAVSensor = $Sensors | Where-Object { $_.subtype -eq "72AC0BFD-0B0C-450C-92EB-354334B4DAAB" }
                $DAVSensor = $Sensors | Where-Object { $_.subtype -eq "0000CBF2-63AA-4911-B26D-924C9FC7ABA6" }
                if ($MAVSensor) {
                    try {
                        Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent/$($MAVSensor.ID)" -Method Delete -Headers @{"x-api-key" = $Apikey }
                        Write-Output "Avira Sensor was removed"  
                        Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Avira Sensor was removed"  
                    }
                    catch {
                        Write-Host "Something went wrong"
                        Write-Host $_ # This prints the actual error
                        Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                        $ExitCode = 2
                    }

                }
                if ($AddDefender -ne 0 -and !($DAVSensor)) {
                    Write-Output "Adding Managed Defender Sensor"  
                    Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Adding Managed Defender Sensor"
                    $body = [PSCustomObject]@{
                        type     = "0000CBF2-63AA-4911-B26D-924C9FC7ABA6"
                        parentId = $CId
                        name     = "Managed Windows Defender"
                    }
                    $body = $body | ConvertTo-Json
                    try {
                        Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Adding Managed Defender Sensor"
                        Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent" -Method Post -Body $body -ContentType "application/json"  -Headers @{"x-api-key" = $Apikey } -ErrorAction Stop
                    }
                    catch {
                        Write-Host "Something went wrong"
                        Write-Host $_ # This prints the actual error
                        Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                        $ExitCode = 2
                    }
                
                
                }            
            }catch {
                Write-Host "Something went wrong"
                Write-Host $_ # This prints the actual error
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                $ExitCode = 2 
            }

        }
        if ((Test-Path "C:\Program Files\Avira\Antivirus\presetup.exe") -eq $true) {
            try {
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Antivirus"
                Write-Output "Performing uninstallation of Avira Antivirus"
                Start-Process -FilePath "C:\Program Files\Avira\Antivirus\presetup.exe"  -ArgumentList "/remsilentnoreboot" -ErrorAction Stop
                $avira = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { ($_.Displayname -eq "Avira") -and ($_.QuietUninstallString -like '"C:\ProgramData\Package Cache\*\Avira.OE.Setup.Bundle.exe" /uninstall /quiet') }
                Write-Output "Performing uninstallation of Avira Launcher"
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Launcher"
                Start-Process -FilePath $avira.BundleCachePath -Wait -ArgumentList "/uninstall /quiet" -ErrorAction Stop
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Antivirus"
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3000 -EntryType Information -Message "Uninstallation of Avira successful."
                $ExitCode = 1
       
            }
            catch {
                Write-Host "Something went wrong"
                Write-Host $_ # This prints the actual error
                Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                $ExitCode = 2
            }

            If ($Restart -ne 0) {
                Restart-Computer -Force
            }
        
        }else {
            Write-Host "No Avira installation found."
            Write-EventLog -LogName "Application" -Source "Server-Eye-ManagedAntivirus" -EventID 3003 -EntryType Information -Message "No Avira installation found."
            $ExitCode = 3
        }
    }
    catch {
        Write-Host "Something went wrong"
        Write-Host $_ # This prints the actual error
        $ExitCode = 2
        
    }
}
 
End {
    Write-Host "Script ended"
    exit $ExitCode
}