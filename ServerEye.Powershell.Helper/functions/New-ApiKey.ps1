<#
    .SYNOPSIS
    Creates an API key.
    
    .DESCRIPTION
    Creates an API key.
    
    .PARAMETER credential
    Email and Password of the user to login as PSCredential.

    .PARAMETER code
    If the user has two-factor enabled you have to send the 6-digit code during the auth process. 

    .PARAMETER Name
    Give the key a name.

    .PARAMETER validUntil
    Do you want this key to expire in x Hours?

    .PARAMETER maxUses
    Is this key meant to be used only a couple of times?

    .LINK 
    https://api.server-eye.de/docs/2/#/auth/post_api_key
#>

function New-APIKEY {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [PSCredential]$credential,

        [Parameter(Mandatory = $false)]
        [int]$code,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        $validUntil,

        [Parameter(Mandatory = $false)]
        [int]$maxUses
    )
    Begin {
        if (!$code) {
            $Session = Connect-SESession -Credentials $credential
        }else {
            $Session = Connect-SESession -Credentials $credential -code $code
        }
        $validUntil = ([DateTimeOffset](((Get-Date).addhours($validUntil)).ToUniversalTime())).ToUnixTimeMilliseconds() 
    }

    Process {
        if (!$validUntil -and !$maxUses) {
            $APIKEy = New-SeApiApiKey -AuthToken $Session -Name $Name -Type user -Email $credential.UserName -Password $credential.GetNetworkCredential().Password
        }elseif (!$maxUses) {
            $APIKEy = New-SeApiApiKey -AuthToken $Session -Name $Name -Type user -Email $credential.UserName -Password $credential.GetNetworkCredential().Password -ValidUntil $validUntil
        }elseif (!$validUntil) {
            $APIKEy = New-SeApiApiKey -AuthToken $Session -Name $Name -Type user -Email $credential.UserName -Password $credential.GetNetworkCredential().Password -MaxUses $maxUses
        }else {
            $APIKEy = New-SeApiApiKey -AuthToken $Session -Name $Name -Type user -Email $credential.UserName -Password $credential.GetNetworkCredential().Password -MaxUses $maxUses -ValidUntil $validUntil
        }
        [PSCustomObject]@{
            Name = $Name
            apiKey = $apiKey.apiKey
            email = $apiKey.email
        }
    }
    end {
        
    }
}


