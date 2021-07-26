<#
    .SYNOPSIS
        Get Server-Eye Version
 
    .DESCRIPTION
        Get Server-Eye Version, Version.txt
 
    .NOTES
        Author  : Server-Eye
        Version : 1.0

    <version>2</version> <<< THIS IS REQUIRED for using the Server-Eye powershell API!!!
#>
[CmdletBinding()]
Param(
)

Begin {

    #LOAD PowerShellAPI and dependencies from the correct local path. 
    [System.IO.DirectoryInfo]$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent
    $pathToApi = Join-path -Path $scriptDir -childpath "ServerEye.PowerShell.API.dll"
    $pathToJson = Join-path -Path $scriptDir -childpath "Newtonsoft.Json.dll"
    [Reflection.Assembly]::LoadFrom($pathToApi) 
    [Reflection.Assembly]::LoadFrom($pathToJson) 

    #init api variables.., api is needed for creating the sensor data, msg is used to capture all relevant output later used in the sensor message.
    $api = new-Object ServerEye.PowerShell.API.PowerShellAPI
    $msg = new-object System.Text.StringBuilder

    $msg.AppendLine("`nScript started")
    $ExitCode = 0   
    # 0 = everything is ok

    #region internals
    [uri]$versionurl = "https://update.server-eye.de/download/se/currentVersion"
}

Process {
    try {

        $msg.AppendLine("Doing lot's of work here`n")
        # do all work right here
        $pathToVersionTXT = Join-Path -Path $scriptDir -ChildPath "Version.txt"
        [int]$LocalVersion = Get-Content -Path $pathToVersionTXT
        $wc = new-object system.net.webclient
        [int]$onlineversion = $wc.DownloadString($versionurl)

        if ($LocalVersion -lt $OnlineVersion) {
            $msg.AppendLine("Old Server-Eye Version found.`nInstalled Server-Eye Version is: $localversion but newest Version is: $onlineversion`n")
            $ExitCode = 1
        }
        else {
            $msg.AppendLine("Newest or Beta Server-Eye Version found.`nInstalled Server-Eye Version is: $localversion`n")
        }

    }
    catch {
        $msg.AppendLine("Something went wrong")
        $msg.AppendLine($_)# This prints the actual error
        $ExitCode = 2
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}

End {
    $msg.AppendLine("Script ended`n")
    $api.setMessage($msg) #sets the script output shown in the OCC
    Write-Host $api.toJson() #this generates an output for our powershell interface to capture all relevant data
    exit $ExitCode
}