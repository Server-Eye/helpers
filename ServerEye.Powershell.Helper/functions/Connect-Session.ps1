<# 
.SYNOPSIS
Connect to a new Server-Eye API session.

.DESCRIPTION
Creates a new session for interacting with the Server-Eye cloud. Two-Factor authentication is supported.

.PARAMETER Apikey 
If passed the cmdlet will use this APIKey instead of asking for username and password.

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
    [CmdletBinding(DefaultParameterSetName = "Credential")]
    Param(
        [Parameter(Mandatory = $true,
            ParameterSetName = "APIKey",
            HelpMessage = "A valid API key. If this is provided, any other parameter is ignored!")] 
        [string]$Apikey,

        [Parameter(Mandatory = $false,
            ParameterSetName = "Credential",
            HelpMessage = "Email address and Password of the user to logincls.")] 
        [pscredential] $Credentials = (Get-Credential -Message 'Server-Eye Login'),

        [Parameter(Mandatory = $false,
            ParameterSetName = "Credential",
            HelpMessage = "If the user has two-factor enabled you have to send the 6-digit code during the auth process. The HTTP code 420 will tell you that two-factor is enabled.")] 
        [string] $Code,

        [Parameter(Mandatory = $false,
            ParameterSetName = "Credential",
            HelpMessage = "This will store the session in the global variable ServerEyeGlobalSession.")] 
        [switch] $Persist       

    )

    Process {
        if ($Apikey) {
            $Global:ServerEyeGlobalApiKey = $Apikey
            Return
        }
        $reqBody = @{
            'email'    = $Credentials.UserName
            'password' = $Credentials.GetNetworkCredential().Password
            'code'     = $Code
        } | ConvertTo-Json
        try {
            $res = Invoke-WebRequest -Uri https://api.server-eye.de/2/auth/login -Body $reqBody `
                -ContentType "application/json" -Method Post -SessionVariable session

        }
        catch {
            if ($_.Exception.Response.StatusCode.Value__ -eq 420) {
                $secondFactor = Read-Host -Prompt "Second Factor"
                if ($Persist) {
                    return Connect-Session -Credentials $Credentials -Code $secondFactor -Persist
                }
                else {
                    return Connect-Session -Credentials $Credentials -Code $secondFactor
                }
            }
            elseif ($_.Exception.Response.StatusCode.Value__ -eq 401) {
                throw "Please check username or password."
                return
            }
            else {
                Write-Output $_
                return
            }
        }
        if ($Persist) {
            Write-Output "The session has been stored in this Powershell. It will remain active until you close it!"
            $Global:ServerEyeGlobalSession = $session
            return
        }
        return $session
    }
}
