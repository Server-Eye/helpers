#Requires -Module ServerEye.PowerShell.helper
 <#
    .SYNOPSIS
    Setzt die Einstellungen für die Verzögerung und die Installation Tage im Smart Updates
    
    .DESCRIPTION
     Setzt die Einstellungen für die Verzögerung und die Installation Tage im Smart Updates

    .PARAMETER CustomerId
    ID des Kunden bei dem die Einstellungen geändert werden sollen.

    .PARAMETER ViewfilterName
    Name der Gruppe die geändert werden soll

    .PARAMETER UpdateDelay
    Tage für die Update Verzögerung.

    .PARAMETER installDelay
    Tage für die Installation

    .PARAMETER categories
    Kategorie die in einer Gruppe enthalten sein soll
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    .\ChangeSUSettings.ps1 -AuthToken "ApiKey" -CustomerId "ID des Kunden" -UpdateDelay "Tage für die Verzögerung" -installDelay "Tage für die Installation"

    .EXAMPLE 
    .\ChangeSUSettings.ps1 -AuthToken "ApiKey" -CustomerId "ID des Kunden" -UpdateDelay "Tage für die Verzögerung" -installDelay "Tage für die Installation" -categories MICROSOFT

    .EXAMPLE 
    .\ChangeSUSettings.ps1 -AuthToken "ApiKey" -CustomerId "ID des Kunden" -UpdateDelay "Tage für die Verzögerung" -installDelay "Tage für die Installation" -ViewfilterName "Name einer Gruppe"

    .EXAMPLE 
    Get-SECustomer -AuthToken $authtoken| %{.\ChangeSUSettings.ps1 -AuthToken $authtoken -CustomerId $_.CustomerID -ViewfilterName "ThirdParty Server" -UpdateDelay 30 -installDelay 7}


#>
Param ( 
    [Parameter(Mandatory = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [parameter(ValueFromPipelineByPropertyName,Mandatory = $true)]
    $CustomerId,
    [Parameter(Mandatory = $false)]
    $ViewfilterName,
    [Parameter(Mandatory = $true)]
    [ValidateRange(0, 30)]
    $UpdateDelay,
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 60)]
    $installDelay,
    [ValidateSet("DOT_NET_FRAMEWORK_3_5","DOT_NET_FRAMEWORK_4_0","DOT_NET_FRAMEWORK_4_5","DOT_NET_FRAMEWORK_4_6","DOT_NET_FRAMEWORK_4_7","ADOBE_AIR","ADOBE_FLASH_PLAYER","ADOBE_READER","ADOBE_SHOCKWAVE_PLAYER","CD_BURNER_XP","GOOGLE_CHROME","GPL_GHOSTSCRIPT","INTERNET_EXPLORER","IPHONE_CONFIGURATION_UTILITY","ITUNES","KEEPASS","LIBREOFFICE","MOZILLA_FIREFOX","MOZILLA_THUNDERBIRD","NOTEPAD_PLUS_PLUS","OFFICE_VIEWER","OPEN_OFFICE","OPERA","PDF_ARCHITECT","QUICKTIME","SILVER_LIGHT","SKYPE","VIRTUALBOX","VISUAL_C_PLUS_PLUS_REDISTRIBUTABLE","VLC","VMWARE_VSPHERE_CLIENT","WINDOWS_AIK","WINRAR","WINSCP","FILEZILLA","MICROSOFT")]
    $categories
)

function Get-SEViewFilters {
    param (
        $AuthToken,
        $CustomerID
    )
    $CustomerViewFilterURL = "https://pm.server-eye.de/patch/$($CustomerID)/viewFilters"

    if ($authtoken -is [string]) {
        try {
            $ViewFilters = Invoke-RestMethod -Uri $CustomerViewFilterURL -Method Get -Headers @{"x-api-key" = $authtoken }
            return $ViewFilters
        }
        catch {
            Write-Error "$_"
        }
    
    }
    else {
        try {
            $ViewFilters = Invoke-RestMethod -Uri $CustomerViewFilterURL -Method Get -WebSession $authtoken
            return $ViewFilters


        }
        catch {
            Write-Error "$_"
        }
    }
}

function Get-SEViewFilterSettings {
    param (
        $AuthToken,
        $CustomerID,
        $ViewFilter
    )
    $vi
    $GetCustomerViewFilterSettingURL = "https://pm.server-eye.de/patch/$($customerId)/viewFilter/$($ViewFilterID)/settings"
    if ($authtoken -is [string]) {
        try {
            $ViewFilterSettings = Invoke-RestMethod -Uri $GetCustomerViewFilterSettingURL -Method Get -Headers @{"x-api-key" = $authtoken }
            Return $ViewFilterSettings
        }
        catch {
            Write-Error "$_"
        }
    
    }
    else {
        try {
            $ViewFilterSettings = Invoke-RestMethod -Uri $GetCustomerViewFilterSettingURL -Method Get -WebSession $authtoken
            Return $ViewFilterSettings

        }
        catch {
            Write-Error "$_"
        }
    }
}

function Set-SEViewFilterSetting {
    param (
        $AuthToken,
        $ViewFilterSetting,
        $UpdateDelay,
        $installDelay
    )
    if ($installDelay) {
        $ViewFilterSetting.installWindowInDays = $installDelay
    }else {
        $ViewFilterSetting.installWindowInDays = $ViewFilterSetting.installWindowInDays
    }
    if ($UpdateDelay) {
        $ViewFilterSetting.delayInstallByDays = $UpdateDelay
    }else {
        $ViewFilterSetting.delayInstallByDays = $ViewFilterSetting.delayInstallByDays
    }
    $body = $ViewFilterSetting | Select-Object -Property installWindowInDays, delayInstallByDays, categories, downloadStrategy, maxScanAgeInDays, enableRebootNotify, maxRebootNotifyIntervalInHours | ConvertTo-Json

    $SetCustomerViewFilterSettingURL = "https://pm.server-eye.de/patch/$($ViewFilterSetting.customerId)/viewFilter/$($ViewFilterSetting.vfId)/settings"
    if ($authtoken -is [string]) {
        try {
            Invoke-RestMethod -Uri $SetCustomerViewFilterSettingURL -Method Post -Body $body -ContentType "application/json"  -Headers @{"x-api-key" = $authtoken } | Out-Null
            Write-Output "Alle Einstellungen erfogreich gesetzt."
        }
        catch {
            Write-Error "$_"
        }
    
    }
    else {
        try {
            Invoke-RestMethod -Uri $SetCustomerViewFilterSettingURL -Method Post -Body $body -ContentType "application/json" -WebSession $authtoken | Out-Null
            Write-Output "Alle Einstellungen erfogreich gesetzt."
        }
        catch {
            Write-Error "$_"
        }
    }
}


$AuthToken = Test-SEAuth -AuthToken $AuthToken

if ($ViewfilterName) {
    $Groups = Get-SEViewFilters -AuthToken $AuthToken -CustomerID $CustomerID | Where-Object {$_.name -eq $ViewfilterName}
}else {
    $Groups = Get-SEViewFilters -AuthToken $AuthToken -CustomerID $CustomerID
}


foreach ($Group in $Groups) {
    Write-Debug "$categories before If"
    if ($categories) {
    Write-Debug "$categories in IF"
    $GroupSettings = Get-SEViewFilterSettings -AuthToken $AuthToken -CustomerID $CustomerID -ViewFilterID $Group.vfid | Where-Object {$_.categories.ID -contains $categories}
    Write-Debug "$GroupSettings categories"
    }else {
    $GroupSettings = Get-SEViewFilterSettings -AuthToken $AuthToken -CustomerID $CustomerID -ViewFilterID $Group.vfid
    Write-Debug "$GroupSettings not categories"
    }
    
    foreach ($GroupSetting in $GroupSettings) {

        Set-SEViewFilterSetting -AuthToken $AuthToken -ViewFilterSetting $GroupSetting -UpdateDelay $UpdateDelay -installDelay $installDelay
  
    }
}
    








