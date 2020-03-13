#Requires -Module ServerEye.PowerShell.Helper
#Requires -Module ImportExcel

[CmdletBinding(DefaultParameterSetName="ADCheck")]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    $CustomerID,
    [Parameter(Mandatory = $true,ParameterSetName="ADCheck")]
    [Switch]$ADCheck,
    [Parameter(Mandatory = $true,ParameterSetName="SECheck")]
    [Switch]$SECheck
)

if ($authoken -eq [String]) {
    Connect-SESession -apikey $AuthToken    
}
$AuthToken = Test-SEAuth -AuthToken $AuthToken



$diff = Get-ADComputer -Filter * -Property *

$ref = Get-SECustomer -CustomerId $CustomerID | Get-SESensorhub

$comp = Compare-Object -ReferenceObject $ref -DifferenceObject $diff -Property Name #| Select-Object -Property @{Name=("Systems with ServerEye but not in the AD:"); Expression={$_.Inputobject}}

if ($SECheck.IsPresent -eq $true){
Write-Host "Following Systems are in the Active Directory but are not Installed with Server-Eye:"
(($comp | Where-Object Sideindicator -eq "=>").Name)
}

if ($ADCheck.IsPresent -eq $true){
Write-Host "Following Systems are installed with Server-Eye but not found in the Active Directory:"
(($comp | Where-Object Sideindicator -eq "<=").Name)
}