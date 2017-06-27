<#
AUTOR: Andreas Behr <andreas.behr@server-eye.de>
DATE: 23.06.2017
VERSION: V1.0
DESC: Modules enables easier access to the PowerShell API
#>

function Connect-ServerEyeSession($cred, $code) {
    if (-not $cred) {
        $cred = Get-Credential
    }
    $reqBody = @{
        'email' = $cred.UserName
        'password' = $cred.GetNetworkCredential().Password
        'code' = $code
    } | ConvertTo-Json
    try {
         $res = Invoke-WebRequest -Uri https://api.server-eye.de/2/auth/login -Body $reqBody `
         -ContentType "application/json" -Method Post -SessionVariable session

    } catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 420) {
            $secondFactor = Read-Host -Prompt "Second Factor"
            return Connect-ServerEyeSession -cred $cred -code $secondFactor
        } else {
            throw "Could not login. Please check username and password."
            return
        }
    }
    return $session
}

function Disconnect-ServerEyeSession ($Session) {
    Invoke-WebRequest -Uri https://api.server-eye.de/2/auth/logout -WebSession $Session | Out-Null


}

function Intern-GetJson($url, $session, $apiKey) {
    if ($apiKey) {
        return (Invoke-RestMethod -Uri $url -Method Get -Headers @{"x-api-key"=$apiKey} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Get -WebSession $session );
    }
}


function Get-VisibleCustomers($Session, $ApiKey) {
    return Intern-GetJson -url "https://api.server-eye.de/2/me/nodes?filter=customer" -session $Session -apiKey $ApiKey;
}

function Get-ContainerForCustomer($CustomerId, $Session, $ApiKey) {
    return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CustomerId/containers" -session $Session -apiKey $ApiKey;
}

function Get-AgentsForContainer($ContainerId, $Session, $ApiKey) {
    return Intern-GetJson -url "https://api.server-eye.de/2/container/$ContainerId/agents" -session $Session -apiKey $ApiKey;
}

function Get-NotificationForAgent($AgentId, $Session, $ApiKey) {
    return Intern-GetJson -url "https://api.server-eye.de/2/agent/$AgentId/notification" -session $Session -apiKey $ApiKey;
}

function Get-UsageForCustomer ($CustomerId, $year, $month, $Session, $ApiKey) {
    return Intern-GetJson -url "https://api.server-eye.de/2/customer/$CustomerId/usage?year=$year&month=$month" -session $Session -apiKey $ApiKey;
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
