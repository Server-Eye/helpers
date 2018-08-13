<# 
.SYNOPSIS
Connect to a new Server-Eye API session.

.DESCRIPTION
Creates a new session for interacting with the Server-Eye cloud. Two-Factor authentication is supported.

.PARAMETER Credentials 
If passed the cmdlet will use this credential object instead of asking for username and password.

.PARAMETER Code
This is the second factor authentication code.

.PARAMETER Persist
This will store the session in the global variable $ServerEyeGlobalSession. 
Cmdlets in the namespace SE will try to use the global session if no session or API key is passed to them.

.EXAMPLE 
$session = Connect-Session

.LINK 
https://api.server-eye.de/docs/2/

#>
function Connect-Session {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)] 
        $Apikey,

        [Parameter(Mandatory=$false)] 
        $Credentials,

        [Parameter(Mandatory=$false)] 
        [string] $Code,

        [Parameter(Mandatory=$false)] 
        [switch] $Persist
        

    )

    Process {
        if ($Apikey) {
            $Global:Authtokentest = $Apikey
            Return
        }

        if (-not $Credentials) {
            $Credentials = Get-Credential -Message 'Server-Eye Login'
        }
        $reqBody = @{
            'email' = $Credentials.UserName
            'password' = $Credentials.GetNetworkCredential().Password
            'code' = $Code
        } | ConvertTo-Json
        try {
            $res = Invoke-WebRequest -Uri https://api.server-eye.de/2/auth/login -Body $reqBody `
            -ContentType "application/json" -Method Post -SessionVariable session

        } catch {
            if ($_.Exception.Response.StatusCode.Value__ -eq 420) {
                $secondFactor = Read-Host -Prompt "Second Factor"
                if ($Persist) {
                    return Connect-Session -Credentials $Credentials -Code $secondFactor -Persist
                } else {
                    return Connect-Session -Credentials $Credentials -Code $secondFactor
                }
            } else {
                Write-Output "The server send the error code: $($_.Exception.Response.StatusCode.Value__)"  
                throw "Could not login. Please check username and password."
                return
            }
        }
        if ($Persist) {
            Write-Output "The session has been stored in this Powershell. It will remain active until you close it!"
            $Global:ServerEyeGlobalSession=$session
            return
        }
        return $session
    }
}
