#Requires -RunAsAdministrator
<#
    .SYNOPSIS
        User-logoff
 
    .DESCRIPTION
        User-logoff

    .PARAMETER Username
    Username of the user to be logged off
         
    .NOTES
        Author  : Server-Eye
        Version : 1.0
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    $Username
)
 
Begin {
    Write-Host "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
}
 
Process {
    $ErrorActionPreference = 'Stop'

    try {
        ## Find all sessions matching the specified username
        $sessions = quser | Where-Object {$_ -match $Username}
        ## Parse the session IDs from the output
        $sessionIds = ($sessions -split ' +')[3]
        Write-Output "Found $(@($sessionIds).Count) login(s) for $Username on this computer."
        ## Loop through each session ID and pass each to the logoff command
        foreach ($sessionId in $sessionIds) {
            Write-Output  "Logging off session id [$sessionId]..."
            Start-Process logoff -ArgumentList "$sessionId /v"
        }
    } catch {
        if ($_.Exception.Message -match 'No user exists') {
            Write-Output  "The user is not logged in."
        } else {
            throw $_.Exception.Message
        }
    }
}
 
End {
    Write-Host "Script ended"
    exit $ExitCode
}