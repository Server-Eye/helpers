#Requires -Version 5.0
#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install Upgrade
        
    .DESCRIPTION
        Install newest Windows 10 Upgrade

    .PARAMETER Reboot 
        Should the System be rebooted after the installation, 0 for not 1 for yes. default 0
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0

    .Link
    https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/windows-setup-command-line-options
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateSet(0, 1)]
    [int]$Reboot = 0
)

#region Internal Variables

#region Server-Eye Default
#Server-Eye Install Path
if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
    $SEInstPath = "$env:ProgramFiles\Server-Eye"
}
else {
    $SEInstPath = "${env:ProgramFiles(x86)}\Server-Eye"
}
#Server-Eye Data Path
$SEDataPath = "$env:ProgramData\ServerEye3"
#Server-Eye Configs
$SEConfigFolder = "config"
$CCConf = "se3_cc.conf"
$MACConf = "se3_mac.conf"
#Server-Eye Logs
$Logdir = "{0}\logs" -f $SEDataPath
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $true
$script:_LogFilePath = "{0}\ServerEye.Patchmanagement.Upgrade.log" -f $Logdir

#endregion Server-Eye Default

#region Script specific
$OCCFile = "service_cc.connector"
$Downloaddir = "{0}\downloads" -f $SEDataPath
$Filename = "Win10Upgrade.exe"
$SetupPath = "{0}\{1}" -f $Downloaddir, $Filename
[System.Uri]$AssistantURL = "https://go.microsoft.com/fwlink/?LinkID=799445"
$AssistantURLTMP = [System.Text.Encoding]::UTF8.GetBytes($AssistantURL)
$Base64DownloadURL = [Convert]::ToBase64String($AssistantURLTMP)
$MaxAge = 604800000
#endregion Script specific
#endregion Internal Variables

#region Register Eventlog Source
try { New-EventLog -Source $EventSourceName -LogName $EventLogName -ErrorAction Stop | Out-Null }
catch { }
#endregion Register Eventlog Source

#region Internal Function

Function Find-ContainerID {
    [cmdletbinding(
    )]
    Param (
        [Parameter(Mandatory = $true)]
        $Path
    )

    Write-Output (Get-Content $Path | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=", "")

}
function Write-Log {
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
    if (-not $Silent) {
        $splat = @{ }
        $splat['Object'] = $Message
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $splat['ForegroundColor'] = $ForegroundColor }
        if ($PSBoundParameters.ContainsKey('NoNewLine')) { $splat['NoNewLine'] = $NoNewLine }
            
        Write-Host @splat
    }
}
#endregion Internal Function

#region Assistent Download
# Download der aktuellen Version
Write-Debug "Check if Download is needed"
if (!(Test-Path $SetupPath)) {
    Write-Debug "Download is needed"
    try {
        $SensorhubID = Find-ContainerID -Path "$SEInstPath\$SEConfigFolder\$CCConf"
        $Connector = Get-Content "$SEDataPath\$OCCFile" | ConvertFrom-Json
        $FiledepotFindURL = "{0}2/container/{1}/filedepot" -f $Connector.url, $SensorhubID
        try {
            $Filedepot = Invoke-WebRequest -URI $FiledepotFindURL -SkipCertificateCheck -erroraction Stop | ConvertFrom-Json
            $downloadUrl = "{0}/download?url={1}&maxAgeMs={2}&fileName={3}" -f $Filedepot.url, $Base64DownloadURL, $MaxAge, $Filename
        }
        catch {
            $downloadUrl = $AssistantURL
        }
        Invoke-WebRequest -URI $downloadUrl -OutFile $SetupPath 
    }
    catch {
        Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
    }

}
else {
    Write-Debug "No Download is needed"
}
#endregion Assistent Download

#Erstellen der Prozess Argument
#region Arguments

if ($Reboot -eq 1) {
    $argument = '/quietinstall /skipeula /auto upgrade /UninstallUponUpgrade /NoReboot /copylogs {0}' -f $_LogFilePath
}
else {
    $argument = '/quietinstall /skipeula /auto upgrade /UninstallUponUpgrade /copylogs {0}' -f $_LogFilePath
}


$startProcessParams = @{
    FilePath     = $SetupPath
    ArgumentList = $argument       
    Wait         = $true;
    NoNewWindow  = $true;
}
Write-Debug "Finished Argument construction"
#endregion Arguments


# Installation Server-Eye
try {
    Start-Process @startProcessParams
    Remove-Item -Path $SetupPath
}
catch {
    Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
}
