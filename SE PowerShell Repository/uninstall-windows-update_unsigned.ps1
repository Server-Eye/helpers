#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Uninstall Windows Update
        
    .DESCRIPTION
       Uninstall a Windows Update
 
    .PARAMETER KB 
        ID/KB name of the Windows Update to Uninstall
 
    .NOTES
        Author  : Server-Eye
        Version : 1.0
 
    .Link
    https://support.microsoft.com/de-de/topic/9-m%C3%A4rz-2021-kb5000802-betriebssystembuilds-19041-867-und-19042-867-63552d64-fe44-4132-8813-ef56d3626e14
#>
 
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    $KB
)
 
#region Internal Variables
 
#region Server-Eye Default
 
#Server-Eye Data Path
$SEDataPath = "$env:ProgramData\ServerEye3"
#Server-Eye Logs
$Logdir = "{0}\logs" -f $SEDataPath
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $false
$script:_SilentEventlog = $true
$script:_LogFilePath = "{0}\ServerEye.Custom.UninstallUpdate.log" -f $Logdir
#endregion Server-Eye Default
 
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
        Write-Host @splat
    }
 
}
 
#endregion Internal Function
 
try {
    $update = Get-WindowsPackage -Online -PackageName "*$KB*" -ErrorAction Stop
    if ($update) {
        Remove-WindowsPackage -Online -PackageName $update.PackageName -NoRestart -LogLevel 2 -LogPath $script:_LogFilePath -ErrorAction Stop
    }
    else {
        Write-Log -Source $EventSourceName -EventID 3000 -Message "Update $KB not found." -SilentEventlog $true
        Exit
    }
   
}
catch {
    Write-Log -Source $EventSourceName -EventID 3002 -EntryType Error -Message "Something went wrong $_ "
    Exit
}