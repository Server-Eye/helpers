[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken,
    [string]
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

$customers = Get-SECustomer -AuthToken $AuthToken -all

#Write-Debug "Customer id "$customers.CustomerId

foreach ($customer in $customers) {

    if ($customer.CustomerId -eq $custID) {

        $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.CustomerId

        foreach ($container in $containers) {

            if ($container.subtype -eq "0") {

                foreach ($sensorhub in $containers) {

                    if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                        #Write-Debug $sensorhub.id

                        try {

                            $inventorys = Get-SeApiContainerInventory -AuthToken $AuthToken -CId $sensorhub.id -ErrorAction Stop -ErrorVariable x

                            Write-Debug $inventorys

                            foreach ($inventory in $inventorys){
                                for ($i = 0; $i -lt $inventory.PROGRAMS.Count; $i++) {
                                    [PSCustomObject]@{
                                        Sensorhub = $sensorhub.name
                                        Pos = ($i+1)
                                        Produkt = $inventory.PROGRAMS[$i].Produkt
                                        Version = $inventory.PROGRAMS[$i].SWVERSION
                                        Status = "Online"
                                    }
                                }
                            }
                        }
                        catch {
                            if($x[0].ErrorRecord.ErrorDetails.Message -match ('"message":"server_error","error":"not_connected"')  ){
                                [PSCustomObject]@{
                                    Sensorhub = $sensorhub.name
                                    Status = "is Offline."
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}