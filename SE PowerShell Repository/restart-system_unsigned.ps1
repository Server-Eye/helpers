<#
    .SYNOPSIS
        Forces a system restart
 
    .DESCRIPTION
        Execution of this script forces an system restart after 10 seconds.

    .PARAMETER Comment 
        Comment for the restart, default is "Neustart über die Aufgabenplanung".

    .PARAMETER reason 
        Reason for the system restart, can either be "P" or "U", default "P".

    .PARAMETER major 
        Specifies the major reason number (a positive integer, less than 256), default is 0.

    .PARAMETER minor 
        Specifies the minor reason number (a positive integer, less than 65536), default is 0.

    .PARAMETER Time 
        Time before the restart should occur, default is 10 seconds.
        
    .NOTES
        Author  : Server-Eye
        Version : 1.1

    .Link
        https://docs.microsoft.com/de-de/windows-server/administration/windows-commands/shutdown

        Reasons, major and minor settings:
        https://servereye.freshdesk.com/a/solutions/articles/14000128892
#>

[CmdletBinding()]
Param(
    [parameter(Mandatory = $false, HelpMessage = "Comment for the restart ")]
    [string]
    $Comment = "Neustart über die Aufgabenplanung",
    [parameter(Mandatory = $false, HelpMessage = "Reason for the system restart")]
    [ValidateSet("P", "U")]
    [string]
    $reason = "P",
    [parameter(Mandatory = $false, HelpMessage = "Specifies the major reason number (a positive integer, less than 256)")]
    [Int]
    $major = 0,
    [parameter(Mandatory = $false, HelpMessage = "Specifies the minor reason number (a positive integer, less than 65536)")]
    [Int]
    $minor = 0,
    [parameter(Mandatory = $false, HelpMessage = "Time before the restart should occur, default 10 seconds.")]
    [Int]
    $Time = 10
)
 
Begin {
    $SELogPath = Join-Path -Path $env:ProgramData -ChildPath "\ServerEye3\logs\"
    $SEInstallLog = Join-Path -Path $SELogPath -ChildPath "ServerEye.Task.RestartShutdown.log"
    $FileToRunpath = "C:\WINDOWS\system32\shutdown.exe"
    Write-Host "Script started"
    $ExitCode = 0   
    $argument = '/r /t {0} /c "{1}" /d {2}:{3}:{4}' -f $Time, $Comment, $reason, $major, $minor
    #region Arguments
    $startProcessParams = @{
        FilePath     = $FileToRunpath
        ArgumentList = $argument       
        NoNewWindow  = $true
    }
    # 0 = everything is ok
}


 
Process {
    try {
        Add-Content -Path $SEInstallLog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO  ServerEye.Task.Logic.PowerShell - Trigger system restart with Arguments: $($startProcessParams.ArgumentList)" 
        Start-Process @startProcessParams
 
    }
    catch {
        Add-Content -Path $SEInstallLog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") ERROR  ServerEye.Task.Logic.PowerShell - Something went wrong: $_" # This prints the actual error
        $ExitCode = 1 
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}
 
End {
    Add-Content -Path $SEInstallLog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO  ServerEye.Task.Logic.PowerShell - Script ended with $exitcode"
    exit $ExitCode
}