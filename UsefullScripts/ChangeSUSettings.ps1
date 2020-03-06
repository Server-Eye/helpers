#Requires -Module ServerEye.PowerShell.helper
 <#
    .SYNOPSIS
    Setzt die Einstellungen für die Verzögerung und die Installation Tage im Smart Updates
    
    .DESCRIPTION
     Setzt die Einstellungen für die Verzögerung und die Installation Tage im Smart Updates

    .PARAMETER CustomerId
    ID des Kunden bei dem die Einstellungen geändert werden sollen.

    .PARAMETER UpdateDelay
    Tage für die Update Verzögerung.

    .PARAMETER installDelay
    Tage für die Installation
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    # Shows a Sensorhub. 
    .\ChangeSUSettings.ps1 -AuthToken "ApiKey" -CustomerId "ID des Kunden" -UpdateDelay "Tage für die Verzögerung" -installDelay "Tage für die Installation"


#>
Param ( 
    [Parameter()]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [parameter(ValueFromPipelineByPropertyName)]
    $CustomerId,
    [ValidateRange(0, 30)]
    $UpdateDelay,
    [ValidateRange(1, 60)]
    $installDelay
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
        $ViewFilterID
    )
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
    $ViewFilterSetting.installWindowInDays = $installDelay
    $ViewFilterSetting.delayInstallByDays = $UpdateDelay
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


$Groups = Get-SEViewFilters -AuthToken $AuthToken -CustomerID $CustomerID

foreach ($Group in $Groups) {

    $GroupSettings = Get-SEViewFilterSettings -AuthToken $AuthToken -CustomerID $CustomerID -ViewFilterID $Group.vfid
    foreach ($GroupSetting in $GroupSettings) {

        Set-SEViewFilterSetting -AuthToken $AuthToken -ViewFilterSetting $GroupSetting -UpdateDelay $UpdateDelay -installDelay $installDelay
  
    }
}
    








