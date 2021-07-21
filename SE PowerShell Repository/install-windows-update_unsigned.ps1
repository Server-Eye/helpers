#Requires -Version 5.0
#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install Update
        
    .DESCRIPTION
        Install newest Windows Update
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0

    .PARAMETER Reboot 
    Should the System be rebooted after the installation, 0 for not 1 for yes. default 0

    .Link
    https://docs.microsoft.com/en-us/windows/win32/api/_wua/
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateSet(0, 1)]
    [int]$Reboot = 0,
    [Parameter(Mandatory = $true)]
    [string]$Updatetoinstall
)

#region Internal Variables

#region Server-Eye Default
#Server-Eye Logs
$SEDataPath = "C:\programdata\ServerEye3"
$Logdir = Join-path -path $SEDataPath -childpath "\logs"
$EventLogName = "Application"
$EventSourceName = "ServerEye-Custom"
$script:_SilentOverride = $false
$script:_SilentEventlog = $true
$script:_LogFilePath = Join-path -path $Logdir -childpath "\ServerEye.InstallUpdate.log"
$resultcode = @{0 = "Not Started"; 1 = "In Progress"; 2 = "Succeeded"; 3 = "Succeeded With Errors"; 4 = "Failed" ; 5 = "Aborted" }
#endregion Server-Eye Default

#endregion Internal Variables

#region Register Eventlog Source
try { New-EventLog -Source $EventSourceName -LogName $EventLogName -ErrorAction Stop | Out-Null }
catch { }
#endregion Register Eventlog Source

If ((Test-Path $script:_LogFilePath) -eq $false) {
    New-Item $script:_LogFilePath -ItemType File
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

#Prozess Start
$exitcode = 0
try {
    $UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
    $Searcher = New-Object -ComObject Microsoft.Update.Searcher
    $Session = New-Object -ComObject Microsoft.Update.Session
    Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Will search for Updates" -SilentEventlog $true
    $searchResults = $Searcher.Search("IsInstalled=0")
    foreach ($update in $searchResults.Updates) {
        $isUpdate = $false;
        Write-Output $update.Title
        if ($update.Title -like "*$Updatetoinstall*") {
            $isUpdate = $true
            break
        }
    }
    if ($isUpdate) {
        $UpdateCollection.Add($update) | out-null
        $name = $UpdateCollection | Select-Object @{Name = "Title"; Expression = { $_.Title } }
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Updates found: $($Name.title)!" -SilentEventlog $true
    }
    
    $Updatecount = $UpdateCollection.Count

    if ($Updatecount -gt 0) {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Start Download." -SilentEventlog $true
        $Downloader = $Session.CreateUpdateDownloader()
        $Downloader.Updates = $UpdateCollection
        $Download = $Downloader.Download()
    }
    else {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Update: $Updatetoinstall not found!" -SilentEventlog $true
        exit $exitcode
    }

    if ($Download.ResultCode -ne 2) {
        Write-Log -Source $EventSourceName -EventID 3251 -EntryType Error -Message "Download failed with code $($download.ResultCode) ($($download.HResult))" -SilentEventlog $true
        $exitcode = 1
    }
    else {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Starting installation" -SilentEventlog $true
        $Installer = New-Object -ComObject Microsoft.Update.Installer
        $Installer.Updates = $UpdateCollection
        $installer.AllowSourcePrompts = $false
        $installer.ForceQuiet = $true
        $InstallResult = $Installer.Install()
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Installation finished with $($installResult.ResultCode) ($($installResult.HResult))" -SilentEventlog $true
    }

    if ($installResult.RebootRequired) {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Reboot is required." -SilentEventlog $true
        if ($reboot -ne 0) {
            Restart-Computer -Force
            Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Reboot was started." -SilentEventlog $true
        }else {
            Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "Reboot is required, but no reboot was set." -SilentEventlog $true
        }


    }
    else {
        Write-Log -Source $EventSourceName -EventID 3200 -EntryType Information -Message "No reboot is required!!"-SilentEventlog $true
    }

}
catch {
    Write-Log -Source $EventSourceName -EventID 3253 -EntryType Error -Message "Something went wrong $_ "
    $exitcode = 2
}
exit $exitcode
