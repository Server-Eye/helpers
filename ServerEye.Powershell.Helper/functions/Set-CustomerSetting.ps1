<#
    .SYNOPSIS
    Get all settings for a Customer. 
    
    .DESCRIPTION
    This will list all settings for a Customer.
    
    .PARAMETER CustomerId
    The id of the Customer for which the settings should be listed.

    .PARAMETER tanssUrl
    The URL of an instance of TANSS.

    .PARAMETER defaultLanguage
    The language of this customers reports and other automatically generated stuff. ValidateSet = de or en  

    .PARAMETER timezone
    The timezone this customer is based.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Set-SECustomerSetting -CustomerId "3e2c14de-c28f-4297-826a-cc645b725be2" -TANSSURL "https://tanss.kraemer-it.de"

    CustomerId      : 3e2c14de-c28f-4297-826a-cc645b725be2
    CustomerName    : Wortmann Demo (gesponsert)
    TANSSURL        : https://tanss.kraemer-it.de
    defaultLanguage : de
    timezone        : Europe/Berlin

    .EXAMPLE 
    Get-SECustomer -Filter "Wortmann*"| Set-SECustomerSetting -TANSSURL "https://tanss.kraemer-it.de"

    CustomerId      : 3e2c14de-c28f-4297-826a-cc645b725be2
    CustomerName    : Wortmann Demo (gesponsert)
    TANSSURL        : https://tanss.kraemer-it.de
    defaultLanguage : de
    timezone        : Europe/Berlin

    .EXAMPLE 
    Get-SECustomer -Filter "Wortmann*"| Set-SECustomerSetting -defaultLanguage en

    CustomerId      : 3e2c14de-c28f-4297-826a-cc645b725be2
    CustomerName    : Wortmann Demo (gesponsert)
    TANSSURL        : https://tanss.kraemer-it.de
    defaultLanguage : en
    timezone        : Europe/Berlin


    .LINK 
    https://api.server-eye.de/docs/2/
#>
function Set-CustomerSetting {
    [CmdletBinding()]
    Param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $true)]
        $CustomerId,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        $tanssUrl,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        [ValidateSet('de','en')]
        $defaultLanguage,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
        $timezone,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {
        if (!$tanssUrl -and !$defaultLanguage -and !$timezone) {
            Write-Error -Message "No Parameter to change was given. Please provide on of the following Parameters tanssUrl, defaultLanguage or timezone" -ErrorAction Stop -Category InvalidArgument

        }else{
            SetSettingByCustomer -customerId $CustomerId -auth $AuthToken -tanssUrl $tanssUrl -defaultLanguage $defaultLanguage -timezone $timezone
        }
   
        
    }

    End {

    }
}

function SetSettingByCustomer ($customerId, $auth, $tanssUrl, $defaultLanguage, $timezone) {
    $currentSetting = Get-SECustomerSetting -AuthToken $AuthToken -customerId $customerID
    if (!$tanssUrl) {
       $tanssUrl = $currentSetting.TANSSURL
   }
   If (!$defaultLanguage){
      $defaultLanguage = $currentSetting.defaultLanguage
   }
   If (!$timezone){
       $timezone = $currentSetting.timezone
   }

    $setting = Set-SeApiCustomerSetting -cId $customerId -AuthToken $auth -tanssUrl $tanssUrl -defaultLanguage $defaultLanguage -timezone $timezone
    $Customer = Get-SECustomer -CustomerId $customerId

    [PSCustomObject]@{
        CustomerId      = $setting.cid
        CustomerName    = $Customer.Name
        TANSSURL        = $setting.TANSSURL
        defaultLanguage = $setting.defaultLanguage
        timezone        = $setting.timezone

    
    }
}