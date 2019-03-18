<#
    .SYNOPSIS
    Get the Inventory for a System.

    .DESCRIPTION
    Get the Inventory for a System, shows CPU, RAM, HDD Name, HDD Capacity, HDD Free Space, OS and OS Procuktkey.

    .PARAMETER SensorhubId
    The sensorhub id for which the Inventory will be displayed.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SECustomer -Filter "*Support" | Get-SESensorhub | Get-SEInventory

    Customer      : Server-Eye Support
    OCC Connector : kraemerit.de
    Sensorhub     : NB-RT-NEW
    CPU           : Core i5-7300U
    RAM           : 8117
    HDD Name      : C
    HDD Kap.      : 241958
    HDD Free      : 158953
    OS            : Windows 10
    OS Procuktkey : *****************************


    .LINK 
    https://api.server-eye.de/docs/2/
    
#>

function Get-Inventory {
    [CmdletBinding(DefaultParameterSetName = "bySensorhub")]
    Param(
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "bySensorhub", Mandatory = $True)]
        $SensorhubId,
        [Parameter(Mandatory = $false)]
        $AuthToken
    )
    Begin{
    $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process{
        if ($SensorhubId) {
            formatInvetoryBySensorhub -SensorhubID $SensorhubId -Auth $AuthToken
        }
        
    }
    End {
        
    }
}


function formatInvetoryBySensorhub ($SensorhubId, $auth) {
    $inventory      = Get-SeApiContainerInventory -AuthToken $Auth -CId $SensorhubId -Format json
    $sensorhub      = Get-SESensorhub -SensorhubID $Sensorhubid
    [PSCustomObject]@{
        Customer        = $sensorhub.Customer
        "OCC Connector" = $sensorhub."OCC-Connector"
        Sensorhub       = $sensorhub.name
        CPU             = $inventory.cpu.CPUName
        RAM             = $inventory.Memory.PHYSICALTOTAL 
        "HDD Name"      = $(if ($inventory.disk.FILESYSTEM -eq "NTFS") {$inventory.disk.Disk})
        "HDD Capacity."      = $(if (($inventory.disk.FILESYSTEM) -eq "NTFS") {$inventory.disk.Capacity}) 
        "HDD Free"      = $(if (($inventory.disk.FILESYSTEM) -eq "NTFS") {$inventory.disk.Freespace})
        OS              = $inventory.Os.OSname
        "OS Procuktkey" = $inventory.OS.PRODUCTKEY
    }
}