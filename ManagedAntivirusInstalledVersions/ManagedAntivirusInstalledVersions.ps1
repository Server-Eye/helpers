[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
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

$AuthToken = Test-SEAuth -AuthToken $AuthToken
$Sensortype = "72AC0BFD-0B0C-450C-92EB-354334B4DAAB"

$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken
foreach ($customer in $customers) {
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id
    
    foreach ($container in $containers) {

        if ($container.subtype -eq "0") {

            foreach ($sensorhub in $containers) {

                if ($sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {
                    
                    $Senorhubinfo = Get-SeApiContainer -AuthToken $AuthToken -CId $sensorhub.id
                    $agents = Get-SeApiContainerAgentList -AuthToken $AuthToken -CId $sensorhub.id
                                       
                        foreach ($agent in $agents) {
                        
                        if ($agent.subtype -like $Sensortype){
                            $version = Get-SeApiAgentStateList -AuthToken $AuthToken -AId $agent.id -IncludeRawData "true"
                            [PSCustomObject]@{

                            Kunde = $customer.name
                            Netzwerk = $container.name
                            System = $sensorhub.name
                            OSName = $Senorhubinfo.osName
                            OSVersion = $Senorhubinfo.osVersion
                            Sensor = $agent.name
                            Version = $version.raw.data.productVersion.version 
                            }
                            }
                        }
                    }
                }
            }
        }
    }

