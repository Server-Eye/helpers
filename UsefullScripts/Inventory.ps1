#Requires -Module ServerEye.Powershell.Helper
#Requires -Module importExcel

<#
    .SYNOPSIS
    Get Inventory
    
    .DESCRIPTION
    Create a Excel File per Customer with all Inventorydata from all Sensorhubs.

    .PARAMETER Path
    Path were the Excel File should be created, default is the root of the Script in the directory inventory.
    
    .PARAMETER CustomerID
    Id of the Customer that should be checked

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>

param (
    [Parameter(Mandatory = $false)][string]$Path = $psscriptroot + '\inventory',

    [Parameter(Mandatory = $false)][string]$CustomerID,

    [Parameter(Mandatory = $false)]
    [Alias("ApiKey", "Session")]
    [string]
    $AuthToken
)

$NoConversion = "SCANIP", "VERSION", "NEGATIVECURRENCYMODE", "ODBC", "BDE", "DAO", "ADO", "OPENGL", "IE", "NET", "DIRECTX", "MSI", "QT", "DRIVERVERSION", "IPADDRESSES", "DNSSERVERS", "ADDRESS", "IPADDRESS", "IPADDRESSMASK", "DHCP_IPADDRESS", "GATEWAY_IPADDRESS", "PRIMARYWINS_IPADDRESS", "SECONDARYWINS_IPADDRESS", "REVISIONNUMBER", "PCSCANVER", "SCANIP"

$Data = Get-SeApiMyNodesList -Filter Customer, container -AuthToken $AuthToken

if ($CustomerID) {
    $customers = $Data | Where-Object { $_.Type -eq 1 -and $_.id -eq $CustomerID } | Sort-Object -Property Name
    
}
else {
    $customers = $Data | Where-Object { $_.Type -eq 1 } | Sort-Object -Property Name

}

if (!(test-path $Path)) {
    New-Item -Path $Path -ItemType "directory" | out-null
}


foreach ($customer in $customers) {
    $hubs = $Data | Where-Object { $_.Type -eq 2 -and $_.subtype -eq 2 -and $_.customerId -eq $customer.id }

    $xlsfile = $Path + "\$($customer.name).xlsx"

    $initfile = $true

    foreach ($hub in $hubs) {        
        $state = Get-SeApiContainerStateListbulk -AuthToken $AuthToken -CId $hub.id
        if ($state.lastdate -lt ([datetime]'01.01.2020') -or $state.message -eq 'OCC Connector hat die Verbindung zum Sensorhub verloren') {
            write-host $hub.name 'keine Daten'
            continue
        }
        else {
            $inventory = Get-SeApiContainerInventory -AuthToken $AuthToken -CId $hub.id
        }
        
        $objects = (($inventory | Get-Member) | Where-Object { $_.membertype -eq 'NoteProperty' }).name
        
        foreach ($object in $objects) {
            $subobject = $inventory.$object | Select-Object -property host, * -ExcludeProperty hash
            if ($subobject.count -gt 1) {
                $count = $subobject.count
                for ($a = 0; $a -le $count - 1; $a++) {
                    $subobject[$a].host = $hub.name
                }
            }
            elseif (!$subobject) {
            }
            else {
                $subobject.host = $hub.name
            }

            if ((test-path $xlsfile) -and $initfile) {
                export-excel -path $xlsfile -KillExcel
                remove-item $xlsfile                
            }
            $initfile = $false
            $subobject | export-excel -path $xlsfile -WorksheetName $object -Append -AutoFilter -AutoSize -FreezeTopRow -BoldTopRow -NoNumberConversion $NoConversion -KillExcel
            Clear-Variable subobject
        }
    }
}