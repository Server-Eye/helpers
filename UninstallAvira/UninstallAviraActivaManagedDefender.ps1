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
}
 
Process {
    try {
        Write-Output "Doing lot's of work here"
        if ((Test-Path "C:\Program Files\Avira\Antivirus\presetup.exe") -eq $true) {
            Write-Output "Performing uninstallation of Avira Antivirus"
            Start-Process -FilePath "C:\Program Files\Avira\Antivirus\presetup.exe" -ArgumentList "/remsilent"
            Wait-Process -Name "presetup"
            $avira = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { ($_.Displayname -eq "Avira") -and ($_.QuietUninstallString -like '"C:\ProgramData\Package Cache\*\Avira.OE.Setup.Bundle.exe" /uninstall /quiet') }
            Write-Output "Performing uninstallation of Avira Launcher"
            Start-Process -FilePath $avira.BundleCachePath -Wait -ArgumentList "/uninstall /quiet"
            if ($Apikey) {
                Write-Output "Removing Avira Sensor"
                $CId = (Get-Content 'C:\Program Files (x86)\Server-Eye\config\se3_cc.conf' | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=", "")
                $Sensors = Invoke-RestMethod -Uri "https://api.server-eye.de/2/container/$cid/agents" -Method Get -Headers @{"x-api-key" = $Apikey } 
                $AvSensor = $Sensors | Where-Object { $_.subtype -eq "72AC0BFD-0B0C-450C-92EB-354334B4DAAB" }
                Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent/$($AvSensor.ID)" -Method Delete -Headers @{"x-api-key" = $Apikey }
                Write-Output "Avira Sensor was removed"
                if ($AddDefender -ne 0) {
                    Write-Output "Adding Managed Defender Sensor"  
                    $body = [PSCustomObject]@{
                        type     = "0000CBF2-63AA-4911-B26D-924C9FC7ABA6"
                        parentId = $CId
                        name     = "Managed Windows Defender"
                    }
                    $body = $body | ConvertTo-Json
                    Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent" -Method Post -Body $body -ContentType "application/json"  -Headers @{"x-api-key" = $Apikey }
                } 
    
            }
            If ($Restart -ne 0) {
                Restart-Computer -Force
            }
        
        }
    }
    catch {
        Write-Host "Something went wrong"
        Write-Host $_ # This prints the actual error
        $ExitCode = 1 
        
    }
}
 
End {
    Write-Host "Script ended"
    exit $ExitCode
}