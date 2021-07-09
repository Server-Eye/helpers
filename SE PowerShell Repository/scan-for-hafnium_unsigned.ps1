#Requires -Version 5.0
#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Check for HAFNIUM
        
    .DESCRIPTION
        Check for HAFNIUM

    .PARAMETER argument 
        Arguments the MSert.exe should be Run with, default is '/Q /F'

    .NOTES
        Author  : Server-Eye
        Version : 1.0
        Arguments:
        /Q - quietmode; if Set no UI is shown
        /N - detect-only mode
        /F - force full scan
        /F:Y - same as /F, but automatically clean infected files and removes potentially unwanted software
        /H - detect high and severe threat only

    .Link
    https://news.microsoft.com/de-de/hafnium-sicherheitsupdate-zum-schutz-vor-neuem-nationalstaatlichem-angreifer-verfuegbar/
    https://docs.microsoft.com/de-de/windows/security/threat-protection/intelligence/safety-scanner-download
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [string]
    $argument = '/Q /F'

)

#region Internal Variables
#region Server-Eye Default
#Server-Eye Install Path
if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
    $SEInstPath = "$env:ProgramFiles\Server-Eye"
}else{
    $SEInstPath = "${env:ProgramFiles(x86)}\Server-Eye"
}
#Server-Eye Data Path
$SEDataPath = "$env:ProgramData\ServerEye3"
#Server-Eye Configs
$SEConfigFolder = "config"
$CCConf = "se3_cc.conf"
#$MACConf = "se3_mac.conf"
#Server-Eye Logs
$Logdir = "{0}\logs" -f $SEDataPath
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $true
$script:_SilentEventlog = $false
$script:_LogFilePath = "{0}\ServerEye.Custom.CheckHAFNIUM.log" -f $Logdir
#endregion Server-Eye Default

#region Script specific

$MSertLog = "C:\Windows\debug\msert.log"
$pattern = '^Return\scode:\s\d{1,2}\s\((?<hexcode>.*)\)'
$regex = New-Object Regex($pattern) 
$OCCFile = "service_cc.connector"
$Downloaddir = "{0}\downloads" -f $SEDataPath
$Filename = "MSERT.exe"
$Filepath = "{0}\{1}" -f $Downloaddir, $Filename
[System.Uri]$URL = "https://go.microsoft.com/fwlink/?LinkId=212732"
$URLTMP = [System.Text.Encoding]::UTF8.GetBytes($URL.AbsoluteUri)
$Base64DownloadURL = [Convert]::ToBase64String($URLTMP)
$MaxAge = 604800000
#endregion Script specific
#endregion Internal Variables

#region Register Eventlog Source
if (-not $script:_SilentEventlog) {
    try {
    New-EventLog -Source $EventSourceName -LogName $EventLogName -ErrorAction Stop | Out-Null 
    }
    catch { }
}

#endregion Register Eventlog Source

#region Internal Function
Function Find-ContainerID {
    [cmdletbinding(
    )]
    Param (
        [Parameter(Mandatory = $true)]
        $Path
    )

    Return (Get-Content $Path | Select-String -Pattern "\bguid=\b").ToString().Replace("guid=", "")

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

            .PARAMETER SilentEventlog
            Whether anything should be written to the Eventlog. Is controlled by the closest scoped $_SilentEventlog variable, unless specified.
            
            .PARAMETER ForegroundColor
                In what color messages should be written to the host.
                Ignored if silent is set to true.
            
            .PARAMETER NoNewLine
                Prevents Debug to host to move on to the next line.
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

        #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [string]
        $Message,
            
        [bool]
        $Silent = $_SilentOverride,

        [bool]
        $SilentEventlog = $_SilentEventlog,
        
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
    if (-not $SilentEventlog) {
        try { Write-EventLog -Message $message -LogName 'Application' -Source $Source -Category 0 -EventId $EventID -EntryType $EntryType -ErrorAction Stop }
        catch { }
    }

        
    # Log to File
    try { "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $EntryType $EventID - $Message" | Out-File -FilePath $LogFilePath -Append -Encoding UTF8 -ErrorAction Stop }
    catch { }
        
    # Write to screen
    if (-not $Silent) {
        $splat = @{ }
        $splat['Object'] = $Message
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $splat['ForegroundColor'] = $ForegroundColor }
        if ($PSBoundParameters.ContainsKey('NoNewLine')) { $splat['NoNewLine'] = $NoNewLine }
        Write-Output @splat
    }
}
#endregion Internal Function

#region Assistent Download
# Download der aktuellen Version
if (!(Test-Path $Filepath)) {
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
            $downloadUrl = $URL
        }
        Invoke-WebRequest -URI $downloadUrl -OutFile $Filepath 
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
$startProcessParams = @{
    FilePath     = $Filepath
    ArgumentList = $argument       
    Wait         = $true
    NoNewWindow  = $true
}
Write-Debug "Finished Argument construction"
#endregion Arguments

#Run MSErt
try {
    Write-Debug "Start Process"
    Start-Process @startProcessParams
    Remove-Item -Path $Filepath
    $Return = Get-Content $MSertLog | Select-String -Pattern $pattern -AllMatches
    $ReturnCode = (($Return[-1].Matches).groups | Where-Object {$_.Name -eq ($regex.GetGroupNames()[-1])}).Value
    Write-Log -Source $EventSourceName -EventID 3000 -EntryType Information -Message "Return Code is $ReturnCode"
    Exit $ReturnCode
}
catch {
    Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
}
