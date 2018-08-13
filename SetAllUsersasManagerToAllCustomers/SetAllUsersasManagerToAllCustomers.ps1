[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)

# Check if module is installed, if not install it, or Update the Moduls
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}else{
    Update-SEHelper
}



#Auth Test
$AuthToken = Test-SEAuth -AuthToken $AuthToken

$Users = Get-SEUser
$Customers = Get-SECustomer -all

Foreach($customer in $customers){
    foreach ($user in $users){
    Set-SEManager -CustomerId $customer.CustomerId -email $user.EMail
    }
}