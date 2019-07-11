[CmdletBinding()]
Param(
    [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(ValueFromPipelineByPropertyName)]
    [alias("CustomerId")]
    $custID
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

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $custID

foreach ($sensorhub in $containers) {

    if ($sensorhub.subtype -eq "2") {

        $inventory = Get-SeApiContainerInventory -AuthToken $AuthToken -CId $sensorhub.id -ErrorAction Stop -ErrorVariable x
        [PSCustomObject]@{
            Sensorhub = $sensorhub.name
            Status    = "Online"
            Software  = for ($i = 0; $i -lt $inventory.PROGRAMS.Count; $i++) {
                [PSCustomObject]@{
                    Pos     = ($i + 1)
                    Produkt = $inventory.PROGRAMS[$i].Produkt
                    Version = $inventory.PROGRAMS[$i].SWVERSION
                }
            }
        }

    }
}