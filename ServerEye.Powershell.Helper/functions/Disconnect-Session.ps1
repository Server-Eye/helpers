<# 
    .SYNOPSIS
    Disconnects the Server-Eye session.

    .DESCRIPTION
    Ends a Server-Eye session. If no session is passed as parameter, the global session will be terminated.

    .PARAMETER Session 
    If passed the cmdlet will end that session.
#>

function Disconnect-Session ($Session) {
    $Session = Test-Auth -AuthToken $Sessions
    Invoke-WebRequest -Uri https://api.server-eye.de/2/auth/logout -WebSession $Session | Out-Null

    Remove-Variable -Name ServerEyeGlobalSession -Scope Global -ErrorAction SilentlyContinue | Out-Null

    Write-Output "The Server-Eye session has been closed."
}

