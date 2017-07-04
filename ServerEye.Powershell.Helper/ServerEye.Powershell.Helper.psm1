<#
AUTOR: Andreas Behr <andreas.behr@server-eye.de>
DATE: 23.06.2017
VERSION: V1.2
DESC: Modules enables easier access to the PowerShell API
#>



<# 
.SYNOPSIS
Connect to a new Server-Eye API session.

.PARAMETER Credentials 
If passed the cmdlet will use this credential object instead of asking for username and password.

.PARAMETER Code
This is the second factor authentication code.


.EXAMPLE 
$session = Connect-ServerEyeSession

.LINK 
https://api.server-eye.de/docs/2/

#>
function Connect-ServerEyeSession {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)] 
        $Credentials,

        [Parameter(Mandatory=$false)] 
        [string] $Code

    )

    Process {
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
                return Connect-ServerEyeSession -Credentials $Credentialscred -Code $secondFactor
            } else {
                throw "Could not login. Please check username and password."
                return
            }
        }
        return $session
    }
}

function Disconnect-ServerEyeSession ($Session) {
    Invoke-WebRequest -Uri https://api.server-eye.de/2/auth/logout -WebSession $Session | Out-Null
}

function Intern-DeleteJson($url, $session, $apiKey) {
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Delete -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Delete -WebSession $authtoken );
    }
}
function Intern-GetJson($url, $authtoken) {
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Get -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Get -WebSession $authtoken );
    }
}

function Intern-PostJson($url, $authtoken, $body) {
    $body = $body | Remove-Null | ConvertTo-Json
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -WebSession $authtoken );
    }
}

function Intern-PutJson ($url, $authtoken, $body) {
    $body = $body | Remove-Null | ConvertTo-Json
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -WebSession $authtoken );
    }
}

function Remove-Null {

    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        $obj
  )

  Process  {
    $result = @{}
    foreach ($key in $_.Keys) {
        if ($_[$key]) {
            $result.Add($key, $_[$key])
        }
    }
    $result
  }
}

function Get-AllVisibleAgents($Session, $ApiKey) {
    $result = @()


    $customers = Get-VisibleCustomers -Session $Session -ApiKey $ApiKey
    foreach ($customer in $customers) {

        $containers = Get-ContainerForCustomer -Session $Session -ApiKey $ApiKey -CustomerId $customer.id

        foreach ($container in $containers) {

            if ($container.subtype -eq "2") {
                $agents = Get-AgentsForContainer -Session $Session -ApiKey $ApiKey -ContainerId $container.id

                foreach ($agent in $agents) {
                    $result += $agent
                }
            }
        }
    }
    return $result
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path
$global:DirectorySeparatorChar = [io.path]::DirectorySeparatorChar

"$moduleRoot/functions/*.ps1" | Resolve-Path | Write-Host

"$moduleRoot/functions/*.ps1" | Resolve-Path | ForEach-Object { . $_.ProviderPath }
