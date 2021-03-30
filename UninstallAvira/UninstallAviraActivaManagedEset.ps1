<# 
    .SYNOPSIS
    Uninstall Avira Antivirus and the Avira Launcher.

    .DESCRIPTION
    This Script will Uninstall Avira Antivirus and the Avira Launcher form the System and remove Avira Sensor and also add Managed ESET Sensor.

    .PARAMETER Restart
    Set to something other then 0 to Restart after Avira uninstall.

    .PARAMETER AddEset
    Set to something other then 0 to add the Server-Eye Managed Windows ESET Sensor.

    .PARAMETER Apikey
    API Key mandatory to remove or add Sensors.

    .NOTES
    When the CoreVersion of PowerShell is used no Eventlogs will be written.
    
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false,
        HelpMessage = "Set to something other then 0 to Restart after Avira uninstall")]
    [int]$Restart = 0,
    [Parameter(Mandatory = $false,
        HelpMessage = "Set to something other then 0 to add the Server-Eye Managed Windows ESET Sensor")]
    [int]$AddEset = 0,
    [Parameter(Mandatory = $false,
        HelpMessage = "API Key to remove or add Sensors")] 
    [String]$Apikey
)

Begin {
    Write-Host "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
    $eset = [PSCustomObject]@{
        Type = "56E5A518-AFFD-4FA4-99F9-6CFB92EF38CD"
        Name = "Managed ESET"
    }
    #region Register Eventlog Source
    try { New-EventLog -Source "ServerEyeManagedAntivirus" -LogName "Application" -ErrorAction Stop | Out-Null }
    catch { }
    #endregion Register Eventlog Source
    Checkpoint-Computer -Description "Pre Server-Eye MAV Uninstall" -RestorePointType "APPLICATION_UNINSTALL"
    #region WriteLog
    $script:_SilentOverride = $true
    $script:_LogFilePath = "C:\ProgramData\ServerEye3\logs\ServerEye.Extension.MAV.Uninstall.log"
    #region WriteLog
    function Write-Log
    {
        <#
            .SYNOPSIS
                A swift logging function.
            
            .DESCRIPTION
                A simple way to produce logs in various formats.
                Log-Types:
                - Eventlog (Application --> ServerEyeDeployment)
                - LogFile (Includes timestamp, EntryType, EventID and Message)
                - Screen (Includes only the message)
            
            .PARAMETER Message
                The message to log.
            
            .PARAMETER Silent
                Whether anything should be written to host. Is controlled by the closest scoped $_SilentOverride variable, unless specified.
            
            .PARAMETER ForegroundColor
                In what color messages should be written to the host.
                Ignored if silent is set to true.
            
            .PARAMETER NoNewLine
                Prevents output to host to move on to the next line.
                Ignored if silent is set to true.
            
            .PARAMETER EventID
                ID of the event as logged to both the eventlog as well as the logfile.
                Defaults to 1000
            
            .PARAMETER EntryType
                The type of event that is written.
                By default an information event is written.
            
            .PARAMETER LogFilePath
                The path to the file (including filename) that is written to.
                Is controlled by the closest scoped $_LogFilePath variable, unless specified.
            
            .EXAMPLE
                PS C:\> Write-Log 'Test Message'
        
                Writes the string 'Test Message' with EventID 1000 as an information event into the application eventlog, into the logfile and to the screen.
            
            .NOTES
                Supported Interfaces:
                ------------------------
                
                Author:       Friedrich Weinmann
                Company:      die netzwerker Computernetze GmbH
                Created:      12.05.2016
                LastChanged:  12.05.2016
                Version:      1.0
        
                EventIDs:
                1000 : All is well
                4*   : Some kind of Error
                666  : Terminal Error
        
                10   : Started Download
                11   : Finished Download
                12   : Started Installation
                13   : Finished Installation
                14   : Started Configuring Sensorhub
                15   : Finished Configuriong Sensorhub
                16   : Started Configuring OCC Connector
                17   : Finished Configuring Sensorhub
                
        #>
        [CmdletBinding()]
        Param (
            [Parameter(Position = 0)]
            [string]
            $Message,
            
            [bool]
            $Silent = $_SilentOverride,
            
            [System.ConsoleColor]
            $ForegroundColor,
            
            [switch]
            $NoNewLine,
            
            [Parameter(Position = 1)]
            [int]
            $EventID = 1000,

            [Parameter(Position = 1)]
            [string]
            $Source,

            
            [Parameter(Position = 3)]
            [System.Diagnostics.EventLogEntryType]
            $EntryType = ([System.Diagnostics.EventLogEntryType]::Information),
            
            [string]
            $LogFilePath = $_LogFilePath
        )
        
        # Log to Eventlog
        try { Write-EventLog -Message $message -LogName 'Application' -Source $Source -Category 0 -EventId $EventID -EntryType $EntryType -ErrorAction Stop }
        catch { }
        
        # Log to File
        try { "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss");$EntryType;$EventID;$Message" | Out-File -FilePath $LogFilePath -Append -Encoding UTF8 -ErrorAction Stop }
        catch { }
        
        # Write to screen
        if (-not $Silent)
        {
            $splat = @{ }
            $splat['Object'] = $Message
            if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $splat['ForegroundColor'] = $ForegroundColor }
            if ($PSBoundParameters.ContainsKey('NoNewLine')) { $splat['NoNewLine'] = $NoNewLine }
            
            Write-Host @splat
        }
    }
    #endregion WriteLog
}
 
Process {
    try {
        if ($Apikey) {
            try {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Removing Avira Sensor"
                $CId = (Get-Content 'C:\Program Files (x86)\Server-Eye\config\se3_cc.conf' | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=", "")
                $Sensors = Invoke-RestMethod -Uri "https://api.server-eye.de/2/container/$cid/agents" -Method Get -Headers @{"x-api-key" = $Apikey } 
                $MAVSensor = $Sensors | Where-Object { $_.subtype -eq "72AC0BFD-0B0C-450C-92EB-354334B4DAAB" }
                $DAVSensor = $Sensors | Where-Object { $_.subtype -eq $Eset.Type }
                if ($MAVSensor) {
                    try {
                        Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent/$($MAVSensor.ID)" -Method Delete -Headers @{"x-api-key" = $Apikey }
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Avira Sensor was removed"
                    }
                    catch {
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                        $ExitCode = 2
                    }

                }else {
                    Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Avira Sensor not found"
                }
                if ($AddEset -ne 0 -and !($DAVSensor)) {
                    Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Adding Managed ESET Sensor"
                    $body = [PSCustomObject]@{
                        type     = $Eset.Type
                        parentId = $CId
                        name     = $Eset.Name
                    }
                    $body = $body | ConvertTo-Json
                    try {
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Adding Managed ESET Sensor"
                        Invoke-RestMethod -Uri "https://api.server-eye.de/2/agent" -Method Post -Body $body -ContentType "application/json"  -Headers @{"x-api-key" = $Apikey } -ErrorAction Stop
                    }
                    catch {
                        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                        $ExitCode = 2
                    }
                
                
                }            
            }
            catch {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                $ExitCode = 2 
            }

        }
        Get-ChildItem -Path $path -Filter avlicense -Recurse | Remove-Item
        if ((Test-Path "C:\Program Files\Avira\Antivirus\presetup.exe") -eq $true) {
            try {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Antivirus"
                Start-Process -FilePath "C:\Program Files\Avira\Antivirus\presetup.exe"  -ArgumentList "/remsilentnoreboot" -ErrorAction Stop
                $avira = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { ($_.Displayname -eq "Avira") -and ($_.QuietUninstallString -like '"C:\ProgramData\Package Cache\*\Avira.OE.Setup.Bundle.exe" /uninstall /quiet') }
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Launcher"
                Start-Process -FilePath $avira.BundleCachePath -Wait -ArgumentList "/uninstall /quiet" -ErrorAction Stop
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Performing uninstallation of Avira Antivirus"
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3000 -EntryType Information -Message "Uninstallation of Avira successful."
                $ExitCode = 1
       
            }
            catch {
                Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
                $ExitCode = 2
            }

            If ($Restart -ne 0) {
                Restart-Computer -Force
            }
        
        }
        else {
            Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3003 -EntryType Information -Message "No Avira installation found."
            $ExitCode = 3
        }
    }
    catch {
        Write-Log -Source "ServerEyeManagedAntivirus" -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
        $ExitCode = 2
        
    }
}
 
End {
    exit $ExitCode
}