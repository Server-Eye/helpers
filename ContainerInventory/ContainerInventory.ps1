<# Sensors Of Customers
AUTOR: Mike Semlitsch
DATE: 13.06.2016
VERSION: V1.0
DESC: Creates an excel file with a report of the inventory of each sensorhub of each customer.
#>

param(
    [string]$apiKey
)


############################################
#Get Name Of File
############################################
function getNameOfFile($cId) {
    #$url = "https://api.server-eye.de/2/customer/$cId\?apiKey=$apiKey";
    $url = "https://api.server-eye.de/2/me?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    $date = Get-Date -format d;

    $retval = $jsonResponse.surname + " " + $jsonResponse.prename + " Inventory " + $date + ".xlsx";

    $retval = $PSScriptRoot + "\" + $retval -replace '\s','_'
    
    return $retval;


}

############################################
#END Name Of File
############################################


############################################
#Get Visible Customers
############################################
function getVisibleCustomers() {
    $url = "https://api.server-eye.de/2/me/nodes?apiKey=$apiKey&filter=customer";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Visible Customers
############################################






############################################
#Get Containers Of Customer
############################################
function getContainersOfCustomer($cId) {
    $url = "https://api.server-eye.de/2/customer/$cId/containers?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Containers Of Customer
############################################


############################################
#Get Agents Of Container
############################################
function getAgentsOfContainer($cId) {
    $url = "https://api.server-eye.de/2/container/$cId/agents?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Agents Of Container
############################################


############################################
#Get Inventory Of Container
############################################
function getInventoryOfContainer($cId) {
    $url = "https://api.server-eye.de/2/container/$cId/inventory?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Inventory Of Container







$global:isFirstSheet = $true;
$global:actRow = 2;



$excelFileName = getNameOfFile($customerId);


#OPEN Excel File
$SheetName1 = "Employee Accounts"
$ObjExcel = New-Object -ComObject Excel.Application
$Objexcel.Visible = $false
$Objworkbook=$ObjExcel.Workbooks.Add()
#$Objworkbook.Worksheets(1).Delete > $null;
#$Objworkbook.ActiveSheet.Name = $containerName;
$Objworkbook.ActiveSheet.Cells.Item(1,1) = "Kunde";
$Objworkbook.ActiveSheet.Cells.Item(1,2) = "OCC-Connector";
$Objworkbook.ActiveSheet.Cells.Item(1,3) = "Sensorhub";
$Objworkbook.ActiveSheet.Cells.Item(1,4) = "CPU";
$Objworkbook.ActiveSheet.Cells.Item(1,5) = "RAM";
$Objworkbook.ActiveSheet.Cells.Item(1,6) = "HDD Name";
$Objworkbook.ActiveSheet.Cells.Item(1,7) = "HDD Kap.";
$Objworkbook.ActiveSheet.Cells.Item(1,8) = "HDD Free";
$Objworkbook.ActiveSheet.Cells.Item(1,9) = "Betriebssystem";
$Objworkbook.ActiveSheet.Cells.Item(1,10) = "Betriebssystem-Key";
$Objworkbook.ActiveSheet.Cells.Item(1,11) = "Office";
$Objworkbook.ActiveSheet.Cells.Item(1,12) = "Office-Key";



$arrayCustomers = getVisibleCustomers;

:outer foreach($customer in $arrayCustomers)
{

    Write-Host "customer name: " $customer.name;

    $customerId = $customer.id;

    $arrayContainers = getContainersOfCustomer($customerId);

    :inner1 foreach($container in $arrayContainers)
    {
        
        #Write-Host "Name: " $container.name ;

        
        
        #$inventory = getInventoryOfContainer($container.id);




        

        #Write-Host "container ID: " $containcder.id " " $container.subtype;

        if ($container.subtype -eq "0") {
        #if ($false) {
            
            Write-Host "OCC-Connector: " $container.name ;

            #Write-Host "container ID: " $container.id; 
            #Write-Host "container Name: " $container.name;


            $maxRowsOfSensorhub = 0;


            :inner2 foreach($sensorhub in $arrayContainers)
            {

                
                
                if ( $sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    
                    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,1) = $customer.name;
                    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,2) = $container.name;
                    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,3) = $sensorhub.name;
                    
                    Write-Host "   Sensorhub: " $sensorhub.name;

                    $inventory = getInventoryOfContainer($sensorhub.id);

                    $rows = 0;
                    foreach($cpu in $inventory.CPU) {

                         Write-Host "      CPU: " $cpu.POS ". " $cpu.CPUNAME;

                         $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,4) = $cpu.CPUNAME;

                         $rows++;
                    }

                    if ($rows -gt $maxRowsOfSensorhub) {
                        $maxRowsOfSensorhub = $rows;
                    }


                    $rows = 0;
                    foreach($ram in $inventory.MEMORY) {

                         Write-Host "      RAM: " $ram.POS ". " $ram.PHYSICALTOTAL;

                         $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,5) = $ram.PHYSICALTOTAL;

                         $rows++;
                    }

                    if ($rows -gt $maxRowsOfSensorhub) {
                        $maxRowsOfSensorhub = $rows;
                    }


                    $rows = 0;
                    foreach($disk in $inventory.DISK) {
                         
                         if ($disk.FILESYSTEM -eq "NTFS") {
                            Write-Host "      HDD: " $disk.DISK " CAPACITY:" $disk.CAPACITY " FREE:" $disk.FREESPACE;




                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,6) = $disk.DISK;
                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,7) = $disk.CAPACITY;
                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,8) = $disk.FREESPACE;

                            $rows++;
                         }
                    }

                    if ($rows -gt $maxRowsOfSensorhub) {
                        $maxRowsOfSensorhub = $rows;
                    }


                    $rows = 0;
                    foreach($os in $inventory.OS) {
       
                        Write-Host "      Betriebssystem: " $os.OSNAME;
                        Write-Host "      Betr.Syst.-Key: " $os.PRODUCTKEY;

                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,9) = $os.OSNAME;
                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,10) = $os.PRODUCTKEY;

                        $rows++;

                    }

                    if ($rows -gt $maxRowsOfSensorhub) {
                        $maxRowsOfSensorhub = $rows;
                    }


                    $rows = 0;
                    foreach($program in $inventory.PROGRAMS) {
                         
                         if ($program.PRODUKT.IndexOf("Microsoft Office") -gt -1 `                             -and $program.PRODUKT.IndexOf("Update") -lt 0 `
                             -and $program.PRODUKT.IndexOf("Service Pack") -lt 0 `
                              -and $program.LIZENZKEY -ne ""
                             ) {
                            Write-Host "      Office: " $program.PRODUKT;
                            Write-Host "      Office-Key: " $program.LIZENZKEY;

                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,11) = $program.PRODUKT;
                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow+$rows,12) = $program.LIZENZKEY;

                            $rows++;
                         }
                    }

                    if ($rows -gt $maxRowsOfSensorhub) {
                        $maxRowsOfSensorhub = $rows;
                    }


                    
                    


                    $global:actRow = $global:actRow + $maxRowsOfSensorhub;
 
                    #$arrayAgents = getAgentsOfContainer($sensorhub.id);
                    

                    #break outer;


                    if ($false) {
                        :inner3 foreach($agent in $arrayAgents)
                        {

                            #break inner3;
                
                            #Write-Host "agent subtype: " $agent.subtype;
                             Write-Host "      SensorName: " $agent.name;
                            #showAgentState $agent.id $container.name;

                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow,1) = $customer.name;
                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow,2) = $container.name;
                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow,3) = $sensorhub.name;
                            $Objworkbook.ActiveSheet.Cells.Item($global:actRow,4) = $agent.name;

                            $global:actRow++;

                        #    break outer;
                        }
                    }
                }
            }



        
        }


    }

}

$Objworkbook.ActiveSheet.Cells.Select() > $null;
$Objworkbook.ActiveSheet.Cells.EntireColumn.AutoFit() > $null;
$Objworkbook.ActiveSheet.Cells.Item(1,1).Select() > $null;


#CLOSE/SAVE Excel File
$Objexcel.DisplayAlerts = $false
$Objworkbook.SaveAs($excelFileName)
$Objexcel.DisplayAlerts = $true
$Objworkbook.Close()
$Objexcel.Quit()
[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Objexcel)

