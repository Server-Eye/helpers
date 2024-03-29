<#
    .SYNOPSIS
    Restart Service Event Action
 
    .DESCRIPTION
    Restart all Services based on the Event Actiondata

    .PARAMETER EventID
    ID of the Event, default is 1.

    .PARAMETER LogName
    Name of the Eventlog that should be checked, default is Server-Eye Client History

    .PARAMETER AgentID
    ID of a Sensor

    .PARAMETER AgentType
    ID of a Sensor Type

    .NOTES
    Author  : Server-Eye
    Version : 2.0
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false, HelpMessage = "ID of the Event, default is 1.")] 
    [int]$EventID = 1,
    [Parameter(Mandatory = $false, HelpMessage = "Name of the Eventlog that should be checked, default is Server-Eye Client History")] 
    [string]$LogName = "Server-Eye Client History",
    [Parameter(Mandatory = $false, HelpMessage = "ID of a Sensor")]
    [string]$AgentID,
    [Parameter(Mandatory = $false, HelpMessage = "ID of a Sensor Type")] 
    [alias("ServerEyeID")]
    [string]$AgentType
)
#region Internal
$SEPath = "C:\Program Files (x86)\Server-Eye"
$SEDataPath = Join-Path -Path $env:ProgramData -ChildPath "\ServerEye3\"
$SELogPath = Join-Path -Path $SEDataPath -ChildPath "logs\"
$script:_LogFilePath = Join-Path -Path $SELogPath -ChildPath "ServerEye.Tasks.Event.log"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $true

try { New-EventLog -Source $EventSourceName -LogName $EventLogName -ErrorAction Stop | Out-Null }
catch { }

#region WriteLog
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

    try { Add-Content -Path $LogFilePath -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") $EntryType  ServerEye.PowerShell.Logic.$EventID  $Message" -Encoding utf8 }
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
#endregion WriteLog

if (!$AgentID -and !$AgentType) {
    Write-Log -Source $EventSourceName -EventID 100 -EntryType Error -Message "Check Parameters, no AgentID or AgentType given."
    throw "Parameter AgentId or AgentType is missing"
    Exit 2
}
elseif ($AgentID) {
    $data = "||agentid||$AgentID" 
}
elseif ($AgentType) {
    $data = "||agenttype||$AgentType" 
}

$filter = @{
    LogName = $LogName
    Data    = $data
    ID      = $EventID
}

$Event = get-winevent -FilterHashtable $filter -MaxEvents 1
#Endregion Internal

$Eventdata = [PSCustomObject]@{
    Message    = ($Event.Properties[0].Value).Replace("||message||", "")
    agentid    = ($Event.Properties[1].Value).Replace("||agentid||", "")
    agenttype  = ($Event.Properties[2].Value).Replace("||agenttype||", "")
    eventid    = ($Event.Properties[3].Value).Replace("||eventid||", "")
    actiondata = ($Event.Properties[4].Value).Replace("||actiondata||servicesNotRunning=", "").Split(",")
}

try {
    foreach ($service in $Eventdata.actiondata) {
        if ($service -ne "") {
            try {
                Write-Log -Source $EventSourceName -EventID 100 -EntryType Information -Message "Restarting Service: $($service)"
                Start-Service -Name "$service"
            }
            catch {
                Write-Log -Source $EventSourceName -EventID 100 -EntryType Information -Message "Restart for Service: $($service) exited with Error: $_"
            }
        }
    }
}catch {
    Write-Log -Source $EventSourceName -EventID 101 -EntryType Error -Message "Restart for Service: $($Eventdata.actiondata) exited with Error: $_"
    Exit 1
}