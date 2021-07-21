#Requires -Version 5.0
#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Repair Windows Image
        
    .DESCRIPTION
        Repair Windows Image after COMPONENT file restore from Backup
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0

    .PARAMETER RemoteWinSXS 
    Path to a winsxs foulder, UNC Path possible.

    .Link
    https://docs.microsoft.com/en-us/powershell/module/dism/repair-windowsimage?view=windowsserver2019-ps
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [string]$RemoteWinSXS
)

#region Internal Variables

#region Server-Eye Default
#Server-Eye Logs
$Logdir = "C:\ServerEye"
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $false
$script:_SilentEventlog = $true
$script:_LogFilePath = Join-path -path $Logdir -childpath "\ServerEye.Repair.log"
$CBSLog = "C:\windows\logs\cbs\CBS.log"

$2016 = [PSCustomObject]@{
    Name = "2016"
    Link = "https://cloud.server-eye.de/s/DStdjDPNSEKCgyT/download"
}
$2019 = [PSCustomObject]@{
    Name = "2019"
    Link = "https://cloud.server-eye.de/s/DAXiymzATtEJf4d/download"
}
#endregionn Server-Eye Default

#endregion Internal Variables

#region Register Eventlog Source
try { New-EventLog -Source $EventSourceName -LogName $EventLogName -ErrorAction Stop | Out-Null }
catch { }
#endregion Register Eventlog Source

If ((Test-Path $script:_LogFilePath) -eq $false) {
    New-Item $script:_LogFilePath -ItemType File -Force
}

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
        Write-Output @splat
    }
}

#endregion Internal Function

$exitcode = 0
$OSName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\" -Name ProductName).ProductName -replace "[^0-9]" , ''
$Produkt = Get-Variable -Name $OSName 
$HV = (Get-WindowsFeature -Name Hyper-V).installed
$DownloadFile = Join-path -Path $Logdir -ChildPath "$($Produkt.Value.Name).zip"

#region Download
if (!$RemoteWinSXS) {
    try {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Startig Download for $OSName" -SilentEventlog $true
        Start-BitsTransfer -Destination $DownloadFile -Source $Produkt.Value.Link
        Expand-Archive -Path $DownloadFile -DestinationPath $Logdir
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Download and expanding complete" -SilentEventlog $true
    }
    catch {
        Write-Log -Source $EventSourceName -EventID 3201 -EntryType Error -Message "Something went wrong with the Download or expanding: $_" -SilentEventlog $false
        $exitcode = 1
       
    }  
}
#endregion Download

try {
    if (!$RemoteWINSXS) {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Starting repair with Source: $env:TEMP\$($Produkt.Value.Name)" -SilentEventlog $false
        $Repair = Repair-WindowsImage -Online -RestoreHealth -Source "C:\Windows\WinSxS","$Logdir\$($Produkt.Value.Name)" -LimitAccess
    }else {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Starting repair with Source: $RemoteWINSXS" -SilentEventlog $false
        $Repair = Repair-WindowsImage -Online -RestoreHealth -Source "C:\Windows\WinSxS",$RemoteWINSXS -LimitAccess
    }

}
catch {
    Write-Log -Source $EventSourceName -EventID 3201 -EntryType Error -Message "Something went wrong with the repair: $_" -SilentEventlog $false
    Copy-item -Path $CBSLog -Destination $Logdir
    $exitcode = 2
}

if ($Repair) {
    Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "$Repair" -SilentEventlog $false
}

exit $exitcode