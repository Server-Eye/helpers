[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [int]$Year,
    [Parameter(Mandatory=$true)]
    [ValidateSet(1,2,3,4,5,6,7,8,9,10,11,12)]
    [int]$Month,
    [Parameter(ValueFromPipeline=$false)]
    [alias("ApiKey","Session")]
    $AuthToken
)
$AuthToken = Test-SEAuth -AuthToken $AuthToken

Write-Warning "The count for server and workstation is evaluated now. It has no relation to the Month and Year given."

$customers = Get-SECustomer -AuthToken $AuthToken
$usage = Get-SeApiCustomerUsageList -Year $year -Month $Month -AuthToken $AuthToken

foreach ($customer in $customers) {
    $serverCount = (Get-SeApiCustomerContainerList -CId $customer.CustomerId -AuthToken $AuthToken | Where-Object isServer -eq $true | Measure-Object).Count
    $workstationCount = (Get-SeApiCustomerContainerList -CId $customer.CustomerId -AuthToken $AuthToken | Where-Object isServer -eq $false | Measure-Object).Count


    $usageCustomer = $usage | Where-Object customerNumberExtern -eq $customer.CustomerNumber
    [PSCustomObject]@{ 
        CustomerName = $customer.Name
        Container = $usageCustomer.container
        Sensors = $usageCustomer.agents
        NFR = $usageCustomer.nfr
        Subtotal = $usageCustomer.subtotal
        Antivirus = $usageCustomer.antivir
        Patchmanagement = $usageCustomer.patch
        Remotecontrol = $usageCustomer.pcvisit
        'Free Sensors' = $usageCustomer.free
        Total = $usageCustomer.total
        Server = $serverCount
        Workstation = $workstationCount
    }
}

