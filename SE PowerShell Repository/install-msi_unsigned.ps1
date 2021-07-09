<#
    .SYNOPSIS
        Download and install MSIFile
        
    .DESCRIPTION
        Download and install MSIFile

    .PARAMETER InstallTestPath 
    Path to the Software, will be tested before installation."

    .PARAMETER Arguments 
    Arguments for the Installation, /i with MSI Path is set in the script

    .PARAMETER URL 
    URL to Download the MSI File

    .PARAMETER URL 
    How long should the File be saved in the Filedepot, default 1 Day.

    .NOTES
        Author  : Server-Eye
        Version : 1.0

#>

[CmdletBinding()]
Param(
    [parameter(Mandatory = $false, HelpMessage = "Path to the Software, will be tested before installation.")]
    [string]
    $InstallTestPath,

    [parameter(Mandatory = $false, HelpMessage = "Arguments for the Installation, /i with MSI Path is set in the script")]
    [string]
    $arguments,

    [parameter(Mandatory = $false,HelpMessage = "URL to Download the MSI File")]
    [string]
    $URL,

    [parameter(Mandatory = $false,HelpMessage = "How long should the File be saved in the Filedepot, default 1 Day.")]
    [string]
    $MaxAge = 86400000

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
$OCCFile = "service_cc.connector"

#Server-Eye Logs
$Logdir = "{0}\logs" -f $SEDataPath
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $true
$script:_SilentEventlog = $false
$script:_LogFilePath = "{0}\ServerEye.Custom.MSIInstall.log" -f $Logdir
$MSILogFilePath = "{0}\ServerEye.Custom.MSI.log" -f $Logdir
#endregion Server-Eye Default

#region Script specific

$FileToRunpath = "msiexec.exe"
$Downloaddir = "{0}\downloads" -f $SEDataPath
$Filepath = "{0}\{1}" -f $Downloaddir, $Filename

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
        Write-Host @splat
    }
}
function Get-SEFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Base64DownloadURL,
        [Parameter(Mandatory = $true)]
        [uri]
        $URL,
        [Parameter(Mandatory = $true)]
        [int]
        $MaxAge,
        [Parameter(Mandatory = $true)]
        [string]
        $Filename,
        [Parameter(Mandatory = $true)]
        [string]
        $Filepath
    )
    Write-Output "Test"
    try {
        $SensorhubID = Find-ContainerID -Path "$SEInstPath\$SEConfigFolder\$CCConf"
        Write-Output "SensorhubID $SensorhubID"
        $Connector = Get-Content "$SEDataPath\$OCCFile" | ConvertFrom-Json
        Write-Output $Connector.url
        $FiledepotFindURL = "{0}2/container/{1}/filedepot" -f $Connector.url, $SensorhubID
        Write-Output $FiledepotFindURL
        try {
            $Filedepot = Invoke-WebRequest -URI $FiledepotFindURL -SkipCertificateCheck -erroraction Stop | ConvertFrom-Json
            Write-Output $Filedepot.url
            $downloadUrl = "{0}/download?url={1}&maxAgeMs={2}&fileName={3}" -f $Filedepot.url, $Base64DownloadURL, $MaxAge, $Filename
        }
        catch {
            $downloadUrl = $URL
        }
        try {
            Invoke-WebRequest -URI $downloadUrl -OutFile $Filepath  
        }
        catch {
            Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
        }

    }
    catch {
        Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
    }
    
}

#endregion Internal Function

#region Download
# Download der aktuellen Version
try {
    [System.Uri]$URL = $URL.ToString()
}
catch {
    Write-Log -Source $EventSourceName -EventID 5001 -EntryType Error -Message "$URl is not valid."
    Exit
}
$DownloadFile = "{0}\{1}" -f $Downloaddir, $url.Segments[-1]
if (!(Test-Path $DownloadFile)) {
    Write-Debug "Download is needed"
    $URLTMP = [System.Text.Encoding]::UTF8.GetBytes($URL.AbsoluteUri)
    $Base64DownloadURL = [Convert]::ToBase64String($URLTMP)
    try {
    Get-SEFile -Base64DownloadURL $Base64DownloadURL -URL $URL.AbsoluteUri -MaxAge $MaxAge -Filename $url.Segments[-1] -Filepath $DownloadFile
    }
    catch {
        Write-Log -Source $EventSourceName -EventID 5010 -EntryType Error -Message "Something went wrong: $_ "
    exit
    }

}
else {
    Write-Debug "No Download is needed"
}
#endregion Download

#Erstellen der Prozess Argument
$argument = "/i {0} {1} /l*v {2}" -f $DownloadFile,$arguments,$MSILogFilePath
Write-Log -Source $EventSourceName -EventID 5003 -EntryType Information -Message "Agrument: $argument"
#region Arguments
$startProcessParams = @{
    FilePath     = $FileToRunpath
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
    #Remove-Item -Path $DownloadFile
}
catch {
    Write-Log -Source $EventSourceName -EventID 5010 -EntryType Error -Message "Something went wrong $_ "
}