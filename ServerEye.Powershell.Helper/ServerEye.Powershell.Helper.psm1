function Intern-DeleteJson($url, $session, $apiKey) {
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Delete -Headers @{"x-api-key" = $authtoken } );
    }
    else {
        return (Invoke-RestMethod -Uri $url -Method Delete -WebSession $authtoken );
    }
}
function Intern-GetJson($url, $authtoken) {
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Get -Headers @{"x-api-key" = $authtoken } );
    }
    else {
        return (Invoke-RestMethod -Uri $url -Method Get -WebSession $authtoken );
    }
}

function Intern-PostJson($url, $authtoken, $body) {
    $body = $body | Remove-Null | ConvertTo-Json
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -Headers @{"x-api-key" = $authtoken } );
    }
    else {
        return (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -WebSession $authtoken );
    }
}

function Intern-PutJson ($url, $authtoken, $body) {
    $body = $body | Remove-Null | ConvertTo-Json
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -Headers @{"x-api-key" = $authtoken } );
    }
    else {
        return (Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -WebSession $authtoken );
    }
}

function Remove-Null {

    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        $obj
    )

    Process {
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
            $Container = $global:ServerEyeCC | Where-Object { $_.cid -eq $ContainerID }
        }
        elseif ($global:ServerEyeMAC.cid -eq $ContainerID) {
            Write-Debug "MAC Container Caching"
            $Container = $global:ServerEyeMAC | Where-Object { $_.cid -eq $ContainerID }
        }
        else {
            Write-Debug "Container API Call"
            $Container = Get-SeApiContainer -cid $ContainerID -AuthToken $AuthToken
            if ($Container.type -eq 0) {
                $global:ServerEyeMAC += $container
            }
            else {
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

function Get-CachedAgent {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        $AgentID,
        [parameter(Mandatory = $false)]
        $AuthToken
    )
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        CachedSensorTypes -AuthToken $AuthToken
        if (!$Global:ServerEyeAgent) {
            $Global:ServerEyeAgent = @()
        }
    }

    Process {
        if ($global:ServerEyeAgent.aid -contains $AgentID) {
            Write-Debug "Agent Caching"
            $Agent = $global:ServerEyeAgent | Where-Object { $_.aid -eq $AgentID }

        }
        else {
            Write-Debug "Agent API Call"
            $Agent = Get-SeApiAgent -AId $AgentID -AuthToken $AuthToken
            $global:ServerEyeAgent += $Agent
        }
        return $Agent
    }
    end {

    }
}

function CachedSensorTypes {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $false)]
        $AuthToken
    )
    if (!$Global:ServerEyeSensorTypes) {
        $Global:ServerEyeSensorTypes = @{}
        Write-Debug "Type API Call"
        $types = Get-SeApiAgentTypeList -AuthToken $AuthToken
        foreach ($type in $types) {
            $Global:ServerEyeSensorTypes.add($type.agentType, $type)
        }

        $avType = New-Object System.Object
        $avType | Add-Member -type NoteProperty -name agentType -value "72AC0BFD-0B0C-450C-92EB-354334B4DAAB"
        $avType | Add-Member -type NoteProperty -name defaultName -value "Managed Antivirus"
        $avType | Add-Member -type NoteProperty -name forFree -value $true
        $Global:ServerEyeSensorTypes.add($avType.agentType, $avType)

        $pmType = New-Object System.Object
        $pmType | Add-Member -type NoteProperty -name agentType -value "9537CBB5-9023-4248-AFF3-F1ACCC0CE7A4"
        $pmType | Add-Member -type NoteProperty -name defaultName -value "Patchmanagement"
        $pmType | Add-Member -type NoteProperty -name forFree -value $true
        $Global:ServerEyeSensorTypes.add($pmType.agentType, $pmType)

        $suType = New-Object System.Object
        $suType | Add-Member -type NoteProperty -name agentType -value "ECD47FE1-36DF-4F6F-976D-AC26BA9BFB7C"
        $suType | Add-Member -type NoteProperty -name defaultName -value "Smart Updates"
        $suType | Add-Member -type NoteProperty -name forFree -value $true
        $Global:ServerEyeSensorTypes.add($suType.agentType, $suType)
    
    }
    else {
        Write-Debug "Type Caching"
    }
}



$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

"$moduleRoot/functions/*.ps1" | Resolve-Path | ForEach-Object { . $_.ProviderPath }


