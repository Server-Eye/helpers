<# Sensors Of Customers
AUTOR: Mike Semlitsch
DATE: 03.06.2016
VERSION: V1.0
DESC: Creates an excel file with a report of all OCC-Connectors, SensorHubs and Sensors for all customers
#>

Param(
    [string]$apiKey
)

Import-Module ServerEye.Powershell.Helper;

function getNameOfFile($cId) {
    $me = Get-Me -AuthToken $apiKey;
    $date = Get-Date -format d;

    $retval = $me.surname + " " + $me.prename + " AllSensorsOfAllCustomers " + $date + ".xlsx";

    $retval = $PSScriptRoot + "\" + $retval -replace '\s', '_'
    
    return $retval;
}

function getVisibleCustomers() {
    return Get-MyNodesList -AuthToken $apiKey -Filter "customer";
}

function getContainersOfCustomer($cId) {
    return Get-CustomerContainerList -AuthToken $apiKey -CId $cId;
}

function getAgentsOfContainer($cId) {
    return Get-ContainerAgentList -AuthToken $apiKey -CId $cId;
}

$global:isFirstSheet = $true;
$global:actRow = 2;

$excelFileName = getNameOfFile($customerId);

#OPEN Excel File
$SheetName1 = "Excel Sheet"
$ObjExcel = New-Object -ComObject Excel.Application
$Objexcel.Visible = $false
$Objworkbook = $ObjExcel.Workbooks.Add()
#$Objworkbook.Worksheets(1).Delete > $null;
#$Objworkbook.ActiveSheet.Name = $containerName;
$Objworkbook.ActiveSheet.Cells.Item(1, 1) = "Kunde";
$Objworkbook.ActiveSheet.Cells.Item(1, 2) = "OCC-Connector";
$Objworkbook.ActiveSheet.Cells.Item(1, 3) = "Sensorhub";
$Objworkbook.ActiveSheet.Cells.Item(1, 4) = "SensorName";
$Objworkbook.ActiveSheet.Cells.Item(1, 5) = "tags";


$arrayCustomers = getVisibleCustomers;

:outer foreach ($customer in $arrayCustomers) {

    Write-Host "customer name: " $customer.name;

    $customerId = $customer.id;

    $arrayContainers = getContainersOfCustomer($customerId);

    :inner1 foreach ($container in $arrayContainers) {

        #Write-Host "container ID: " $container.id " " $container.subtype;

        if ($container.subtype -eq "0") {
            #if ($false) {
            
            Write-Host "OCC-Connector: " $container.name ;

            #Write-Host "container ID: " $container.id; 
            #Write-Host "container Name: " $container.name;


            :inner2 foreach ($sensorhub in $arrayContainers) {

                
                
                if ( $sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                    Write-Host "   Sensorhub: " $sensorhub.name;

                    #getAgentsOfContainer($sensorhub.id);



                    $arrayAgents = getAgentsOfContainer($sensorhub.id);
                    #getAgentsOfContainer($container.id);

            
                    :inner3 foreach ($agent in $arrayAgents) {

                        #break inner3;
                
                        #Write-Host "agent subtype: " $agent.subtype;
                        Write-Host "      SensorName: " $agent.name;
                        #showAgentState $agent.id $container.name;

                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow, 1) = $customer.name;
                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow, 2) = $container.name;
                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow, 3) = $sensorhub.name;
                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow, 4) = $agent.name;
                        $Objworkbook.ActiveSheet.Cells.Item($global:actRow, 5) = $container.tags.id + ";" + $container.tags.name;

                        $global:actRow++;

                        #    break outer;
                    }

                }
            }



        
        }


    }

}

$Objworkbook.ActiveSheet.Cells.Select() > $null;
$Objworkbook.ActiveSheet.Cells.EntireColumn.AutoFit() > $null;
$Objworkbook.ActiveSheet.Cells.Item(1, 1).Select() > $null;


#CLOSE/SAVE Excel File
$Objexcel.DisplayAlerts = $false
$Objworkbook.SaveAs($excelFileName)
$Objexcel.DisplayAlerts = $true
$Objworkbook.Close()
$Objexcel.Quit()
[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Objexcel)

