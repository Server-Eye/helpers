param (
    [Parameter(Mandatory=$true)][string]$ApiKey,
    [Parameter(Mandatory=$false)][string]$CustomerID
)



function status{
    param (
        [Parameter(Mandatory=$true)][string]$activity,
        [Parameter(Mandatory=$true)][int]$counter,
        [Parameter(Mandatory=$true)][int]$max,
        [Parameter(Mandatory=$true)][string]$status,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$false)][int]$parentid
    )
    $percentcomplete = (($counter*100)/$max)
    if ($percentcomplete -gt 100){
        $percentcomplete = 100
    }
    $status = "$([math]::Round($($percentcomplete)))% - "+$status
    if ($parentid){
        Write-Progress -Activity $activity -PercentComplete $percentcomplete -status $status -id $id -ParentId $parentid
    }
    else{
        Write-Progress -Activity $activity -PercentComplete $percentcomplete -status $status -id $id
    }
}

#install-module servereye.powershell.helper -Force
Import-Module ServerEye.Powershell.Helper

if (!$customerid){
    $customers = Get-SECustomer -AuthToken $apikey
    $customercount = $customers.count
}
else{
    $customers = @((Get-SECustomer -authtoken $apikey|where-object {$_.customerId -eq $customerid}))
    $customercount = 1
}

$inventoryroot = $psscriptroot+'\inventory'
if (!(test-path $inventoryroot)){
    New-Item -Path $inventoryroot -ItemType "directory"|out-null
}

$countC = 0

foreach ($customer in $customers){
    $countC++
    status -activity "$($countC)/$($customercount) Inventarisiere" -max $customercount -counter $countC -status $customer.name -id 1
    
    $hubs = Get-SeApiCustomerContainerList -AuthToken $apikey -CId $customer.customerid|where-object {$_.subtype -eq 2}
    #$customername = (get-seapicustomer -CId $customer -AuthToken $apikey).companyname
    $xlsfile = $psscriptroot+"\inventory\$($customer.name).xlsx"
   

    $countH = 0
    $hubcount = $hubs.count
    $initfile = $true

    foreach ($hub in $hubs){
        $countH++
        status -activity "$($countH)/$($hubcount) Inventarisiere $($customer.name)" -max $hubcount -counter $countH -status $hub.name -id 2 -parentid 1
        
        $state = (Get-SeApiContainerStateListbulk -AuthToken $apikey -CId $hub.id)
        $lastdate = [datetime]$state.lastdate
        if ($lastdate -lt ([datetime]'01.01.2020') -or $state.message -eq 'OCC Connector hat die Verbindung zum Sensorhub verloren'){
            write-host $hub.name 'keine Daten'
            continue
        }
        else{
            $inventory = Get-SeApiContainerInventory -AuthToken $apikey -CId $hub.id
        }
        
        $objects = (($inventory|Get-Member)|Where-Object {$_.membertype -eq 'NoteProperty'}).name
        
        foreach ($object in $objects){
            $subobject = $inventory.$object|Select-Object host,*
            #$object
            if ($subobject.count -gt 1){
                $count = $subobject.count
                for ($a=0;$a -le $count-1;$a++){
                    $subobject[$a].host = $inventory.system.hostname
                }
            }
            elseif(!$subobject){
            }
            else{
                $subobject.host = $hub.name
            }
            
            if ((test-path $xlsfile) -and $initfile){
                export-excel -path $xlsfile -KillExcel
                remove-item $xlsfile                
            }
            $initfile = $false
            $subobject|export-excel -path $xlsfile -WorksheetName $object -Append -AutoFilter -AutoSize -FreezeTopRow -BoldTopRow -KillExcel
            Clear-Variable subobject
        }
    }
}