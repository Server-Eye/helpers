<# 
    .SYNOPSIS
    Shows all deleted Containers.

    .DESCRIPTION
    Shows all deleted Containers for each customer within the given timeframe.

    .PARAMETER customerID 
    ID of the Customer that should be checked, if no given all Customers will be checked.

    .PARAMETER TimeToAdd 
    Time that should be added to the Date or subtracted. Example -1 would be back in time.

    .PARAMETER TimeFrame 
    Length of the frame set with TimetoAdd, Years, Months Days etc.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell
    
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [string]
    $customerID,
    [Parameter(Mandatory = $true)]
    [ValidateRange("Negative")]
    [int]
    $TimeToAdd,
    [Parameter(Mandatory = $true)]
    [ValidateSet("AddYears", "AddMonths", "AddDays", "AddHours")]
    $TimeFrame,
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken

)

#region internal variables
$Type = 103
$start = (Get-Date).($TimeFrame)($TimeToAdd)
$end = Get-Date
$startMS = (([DateTimeOffset](($start).ToUniversalTime())).ToUnixTimeMilliseconds())
$endMS = (([DateTimeOffset](($end).ToUniversalTime())).ToUnixTimeMilliseconds())
Write-Debug $start
Write-Debug $end
#endregion internal variables

#region internal function
#endregion internal function


$authtoken = Test-SEAuth -authtoken $authtoken

$timespan = New-TimeSpan -Start $start -End $end

if ($customerID) {
    $customers = Get-SeApiCustomerList -authtoken $authtoken | Where-Object {$_.cid -eq $customerID}
}else {
    $customers = Get-SeApiCustomerList -authtoken $authtoken
}

foreach ($customer in $customers) {
    Write-Verbose "Deleted Sensorhubs in the last $($timespan.Days) Days for Customer $($customer.Companyname)"
    try {
        $Containers = Get-SeApiActionlogList -AuthToken $authtoken -Type $Type -Start $startms -End $endMS -Of $customer.cid

        if ($Containers) {
            foreach ($Container in $Containers) {
                Write-Debug $Container
                [PSCustomObject]@{
                    Kunde         = $customer.Companyname
                    ContainerID   = if($Container.target.cid){$Container.target.cid}else {$Container.target.id} 
                    ContainerName = $Container.target.name
                    Date = $Container.changedate
                } 
            } 
        }
    }
    catch {
        Write-Error $_
    }
}



