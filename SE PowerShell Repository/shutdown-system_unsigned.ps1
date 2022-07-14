<#
    .SYNOPSIS
        Forces a system shutdown
 
    .DESCRIPTION
        Execution of this script forces an system shutdown after 10 seconds.
 
    .PARAMETER Comment 
        Comment for the shutdown, default is "Herunterfahren über die Aufgabenplanung".
 
    .PARAMETER reason 
        Reason for the system restart, can either be "P" or "U", default "P".
 
    .PARAMETER major 
        Specifies the major reason number (a positive integer, less than 256), default is 0.
 
    .PARAMETER minor 
        Specifies the minor reason number (a positive integer, less than 65536), default is 0.
 
    .PARAMETER Time 
        Time before the shutdown should occur, default is 10 seconds.
        
    .NOTES
        Author  : Server-Eye
        Version : 1.3
 
    .Link
        https://docs.microsoft.com/de-de/windows-server/administration/windows-commands/shutdown
 
        Reasons, major and minor settings:
        https://servereye.freshdesk.com/a/solutions/articles/14000128892
#>
 
[CmdletBinding()]
Param(
    [parameter(Mandatory = $false, HelpMessage = "Comment for the restart ")]
    [string]
    $Comment = "Herunterfahren über die Aufgabenplanung",
    [parameter(Mandatory = $false, HelpMessage = "Reason for the system restart, can either be 'P' or 'U', default 'P'.")]
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
    $SELog = Join-Path -Path $SELogPath -ChildPath "ServerEye.Task.RestartShutdown.log"
    $FileToRunpath = "C:\WINDOWS\system32\shutdown.exe"
    Write-Host "Script started"
    $ExitCode = 0   
    $argument = '/s /t {0} /c "{1}" /d {2}:{3}:{4}' -f $Time, $Comment, $reason, $major, $minor
    #region Arguments
    $startProcessParams = @{
        FilePath     = $FileToRunpath
        ArgumentList = $argument       
        NoNewWindow  = $true
        PassThru = $true
    }
    # 0 = everything is ok
}
 
Process {
    try {        
        $gpos = Get-ChildItem -Path "Registry::\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown"
 
        foreach($gpo in $gpos){
            $gpoLocation = "Registry::\" + $gpo.Name
            $subGpos = Get-ChildItem -Path $gpoLocation
        
            foreach($subGpo in $subGpos){
                    $gpoScript = ""
                    [string]$gpoScript = $subGpo.GetValue("Script")

                    if($gpoScript.Contains("triggerPatchRun.cmd")){
						Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO ServerEye.Task.Logic.PowerShell - Write force parameter to gpo registry"
						Set-Itemproperty -path $subGpo.PSPath -Name 'Parameters' -value 'force'
                    }
            }
        }
		
        Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO  ServerEye.Task.Logic.PowerShell - Trigger system shutdown with Arguments: $($startProcessParams.ArgumentList)" 
		$ShutdownProcess = Start-Process @startProcessParams
 
    } catch {
        Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") ERROR  ServerEye.Task.Logic.PowerShell - Something went wrong: $_" # This prints the actual error
        $ExitCode = 1 
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}
 
End {
    Add-Content -Path $SELog -Value "$(Get-Date -Format "yy.MM.dd hh:mm:ss") INFO  ServerEye.Task.Logic.PowerShell - Script ended with $exitcode"
    exit $ExitCode
}
 