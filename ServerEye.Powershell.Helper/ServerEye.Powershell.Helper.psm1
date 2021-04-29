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
        if ($_[$key] -ne $null) {
            $result.Add($key, $_[$key])
        }
    }
    $result
  }
}
function Get-CachedContainer {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        $ContainerID,
        [parameter(Mandatory = $false)]
        $AuthToken
    ) 
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        if (!$global:ServerEyeMAC) {
            $global:ServerEyeMAC = @()
        }
        if (!$global:ServerEyeCC) {
            $global:ServerEyeCC = @()
        }
    }

    Process {
        if ($global:ServerEyeCC.cid -eq $ContainerID) {
            Write-Debug "CC Container Caching"
            $Container = $global:ServerEyeCC | Where-Object {$_.cid -eq $ContainerID}
        }elseif ($global:ServerEyeMAC.cid -eq $ContainerID) {
            Write-Debug "MAC Container Caching"
            $Container = $global:ServerEyeMAC | Where-Object {$_.cid -eq $ContainerID}
        }else {
            Write-Debug "Container API Call"
            $Container = Get-SeApiContainer -cid $ContainerID -AuthToken $AuthToken
            if ($Container.type -eq 0) {
                $global:ServerEyeMAC += $container
            }else {
                $global:ServerEyeCC += $container
            }
        }
        return $Container
    }
    end {

    }
}

function Get-CachedCustomer {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        $CustomerId,
        [parameter(Mandatory = $false)]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        if (!$Global:ServerEyeCustomer) {
            $Global:ServerEyeCustomer = @()
        }
    }

    Process {
        if ($global:ServerEyeCustomer.cid -contains $CustomerId) {
            Write-Debug "Customer Caching"
            $Customer = $global:ServerEyeCustomer | Where-Object { $_.cid -eq $CustomerId }

        }
        else {
            Write-Debug "Customer API Call"
            $Customer = Get-SeApiCustomer -cid $CustomerId -AuthToken $AuthToken
            $global:ServerEyeCustomer += $customer
        }
        return $customer
    }
    end {

    }
}



$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

"$moduleRoot/functions/*.ps1" | Resolve-Path | ForEach-Object { . $_.ProviderPath }


