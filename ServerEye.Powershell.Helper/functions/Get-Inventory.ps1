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

    Customer          : SE Landheim
    OCC Connector     : SE Landheim (OCC-Connector: NUC-SE3)
    Sensorhub         : NUC-SE3
    CPU               : Core i3-4010U
    RAM               : 4021
    HDD Name          : {C, D}
    HDD Capacity (GB) : {235,48, 931,32}
    HDD Free (GB)     : {176,95, 595,91}
    OS                : Windows 10
    OS Procuktkey     : **************************
    Office            :
    Office Key        :

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
    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        if ($SensorhubId) {
            formatInvetoryBySensorhub -SensorhubID $SensorhubId -Auth $AuthToken
        }
        
    }
    End {
        
    }
}


function formatInvetoryBySensorhub ($SensorhubId, $auth) {
    $inventory = Get-SeApiContainerInventory -AuthToken $Auth -CId $SensorhubId -Format json
    $sensorhub = Get-SESensorhub -SensorhubID $Sensorhubid
    [PSCustomObject]@{
        Customer        = $sensorhub.Customer
        "OCC Connector" = $sensorhub."OCC-Connector"
        Sensorhub       = $sensorhub.name
        CPU             = $inventory.cpu.CPUName
        RAM             = $inventory.Memory.PHYSICALTOTAL 
        "HDD Name"      = ($inventory.DISK | Where-Object {$_.Filesystem -eq "NTFS"}).Disk
        "HDD Capacity (GB)" = ($inventory.DISK | Where-Object {$_.Filesystem -eq "NTFS"}) | ForEach-Object -Process {[math]::round(([int]($_.Capacity)/1024),2)}
        "HDD Free (GB)" = ($inventory.DISK | Where-Object {$_.Filesystem -eq "NTFS"}) | ForEach-Object -Process {[math]::round(([int]($_.FREESPACE)/1024),2)}
        OS              = $inventory.Os.OSname
        "OS Procuktkey" = $inventory.OS.PRODUCTKEY
        Office          = ($inventory.MSPRODUKT | Where-Object { $_.ProduktName -like "Microsoft Office*"} | Select-Object -Unique).produktName
        "Office Key "   = ($inventory.MSPRODUKT | Where-Object { $_.ProduktName -like "Microsoft Office*"} | Select-Object -Unique).PRODUKTKEY
    }
}