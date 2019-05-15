<#
    .SYNOPSIS
    Get all settings for a Customer. 
    
    .DESCRIPTION
    This will list all settings for a Customer.
    
    .PARAMETER CustomerId
    The id of the Customer for which the settings should be listed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomerSetting -CustomerId "4028e08a2e0ed329012e4ca526f705b1"

    CustomerId      : 4028e08a2e0ed329012e4ca526f705b1
    CustomerName    : Systemmanager IT
    TANSSURL        : https://tanss.kraemer-it.de
    TANSSVersion    :
    defaultLanguage : de
    pcvSupporterId  :
    timezone        : Europe/Berlin

    .LINK 
    https://api.server-eye.de/docs/2/
#>
function Get-CustomerSetting {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
        $CustomerId,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        getSettingByCustomer -customerId $CustomerId -auth $AuthToken
    }

    End {

    }
}

function getSettingByCustomer ($customerId, $auth) {
    $settings = Get-SeApiCustomerSettingList -cId $customerId -AuthToken $auth

    $Customer = Get-SeApiCustomer -cid $customerId -AuthToken $auth

    [PSCustomObject]@{
        CustomerId      = $settings.cid
        CustomerName    = $Customer.companyName
        TANSSURL        = $settings.TANSSURL
        TANSSVersion    = $settings.TANSSVersion
        defaultLanguage = $settings.defaultLanguage
        pcvSupporterId  = $settings.pcvSupporterId
        timezone        = $settings.timezone

    
    }
}

