#Requires -Module ServerEye.powershell.helper
<#
    .SYNOPSIS
        Check if given Update is installed
 
    .DESCRIPTION
        Check if given Update is installed
 
    .EXAMPLE
        get-installedupdateviaSEInventory.ps1
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    $updates,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
    $CustomerID,
    [Parameter(Mandatory=$true)]
    [alias("ApiKey","Session")]
    $AuthToken
)
 
Begin {
    Write-Host "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
}
 
Process {
    try{
        $containers = Get-SeApiMyNodesList -Filter container -AuthToken $AuthToken| Where-Object {($_.SubType -eq 2) -and ($_.customerId -eq $CustomerID) -and ($_.IsServer -eq $true)}
        foreach ($container in $containers) {
            $inventory = Get-SEContainerInventory -ContainerID $container.ID -AuthToken $AuthToken
            $contains = ($inventory.OS_HOTFIX).Where({($_.Hotfix_ID) -in $updates})
            if ($contains) {
                [PSCustomObject]@{
                    Customer = $inventory.Customer
                    "OCC Connector" = $inventory."OCC Connector"
                    Sensorhub = $inventory.Sensorhub
                    "Update installed" = "Yes"
                } 
            }else {
                [PSCustomObject]@{
                    Customer = $inventory.Customer
                    "OCC Connector" = $inventory."OCC Connector"
                    Sensorhub = $inventory.Sensorhub
                    "Update installed" = "No"
                } 
            }
            Start-Sleep -Seconds 2
        }
 
    } catch {
        Write-Host "Something went wrong"
        Write-Host $_ # This prints the actual error
        $ExitCode = 1 
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}
 
End {
    Write-Host "Script ended"
    exit $ExitCode
}

