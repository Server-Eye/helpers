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

# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}

# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}

try {
    # Check for existing session
    $AuthToken = Test-SEAuth -AuthToken $AuthToken
}
catch {
    # There is no session - prompt for login
    $AuthToken = Connect-SESession
}

if (!$AuthToken) {
    $AuthToken = Connect-SESession
}

if (!$AuthToken) {
    Write-Error "Fehler beim Login!"
}

$diff = Get-ADComputer -Filter * -Property *

$ref = Get-SECustomer -CustomerId $CustomerID| Get-SESensorhub

$comp = Compare-Object -ReferenceObject $ref -DifferenceObject $diff -Property Name #| Select-Object -Property @{Name=("Systems with ServerEye but not in the AD:"); Expression={$_.Inputobject}}

if ($SECheck.IsPresent -eq $true){
Write-Host "Following Systems are in the Active Directory but are not Installed with Server-Eye:"
(($comp | Where-Object Sideindicator -eq "=>").Name)
}

if ($ADCheck.IsPresent -eq $true){
Write-Host "Following Systems are installed with Server-Eye but not found in the Active Directory:"
(($comp | Where-Object Sideindicator -eq "<=").Name)
}