<# 
    .SYNOPSIS
    This script will compare the current and the last Months Sensor Invoice.

    .DESCRIPTION
    This script will compare the current and the last Months Sensor Invoice.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell
    
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)


# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}

# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}

$authtoken = Test-SEAuth -authtoken $authtoken

$date = Get-Date
$lastmonth = $date.AddMonths(-1)

$currentInvoice = Get-SESensorInvoice -Year $date.Year -Month $date.Month | Select-Object  -Property * -ExcludeProperty Server, Workstation
$lastMonthInvoice = Get-SESensorInvoice -Year $lastmonth.Year -Month $lastmonth.Month | Select-Object -Property * -ExcludeProperty Server, Workstation
$objprops = $currentInvoice | Get-Member -MemberType Property,NoteProperty | Where-Object Name -NotLike "CustomerName" | ForEach-Object Name
$result = @()

for ($i = 0; $i -lt $currentInvoice.Count; $i++) {
    $out = New-Object psobject
    $out | Add-Member NoteProperty Kunde ($currentInvoice[$i].CustomerName)
    foreach ($objprop in $objprops) {
        #$out | Add-Member NoteProperty "CurrentMonth $objprop" ($currentInvoice[$i].$objprop)
        #$out | Add-Member NoteProperty "LastMonth $objprop" ($lastMonthInvoice[$i].$objprop)
        if ($currentInvoice[$i].$objprop -le $lastMonthInvoice[$i].$objprop) {
            $out | Add-Member NoteProperty "Change in $objprop" ($lastMonthInvoice[$i].$objprop - $currentInvoice[$i].$objprop)
        }
        else {
            $out | Add-Member NoteProperty "Change in $objprop" ($currentInvoice[$i].$objprop - $lastMonthInvoice[$i].$objprop)
        }
    }
    $result += $out

}
$result
