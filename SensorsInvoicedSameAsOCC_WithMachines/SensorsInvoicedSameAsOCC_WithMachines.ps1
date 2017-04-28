<# SensorsInvoicedSameAsOCC_WithMachines
AUTOR: Mike Semlitsch
DATE: 28.04.2017
VERSION: V1.0
DESC: Creates an excel file with a report for invoiced sensors for a specified month
#>
param(
    [string]$apiKey,
	[string]$year,
    [string]$month

)



############################################
#Get Name Of File
############################################
function getNameOfFile($cId) {
    #$url = "https://api.server-eye.de/2/customer/$cId\?apiKey=$apiKey";
    $url = "https://api.server-eye.de/2/me?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    $date = Get-Date -format d;

    $retval = $jsonResponse.surname + " " + $jsonResponse.prename + " SensorsInvoicedSameAsOCC_WithMachines " + $year + " " + $month + ".xlsx";

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
    #$url = "https://api.server-eye.de/2/me/nodes?apiKey=$apiKey&filter=customer";
    $url = "https://api.server-eye.de/2/customer?apiKey=$apiKey";


    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}


############################################
#END Get Visible Customers
############################################


############################################
#Get Usage Of Customer
############################################
function getUsageOfCustomer() {
   
    $url = "https://api.server-eye.de/2/customer/usage?year=$year&month=$month&apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}


############################################
#END Get Usage Of Customer
############################################


############################################
#Get Customer Phone Number
############################################
function getCustomerPhoneNumber($cId) {
    $url = "https://api.server-eye.de/2/customer/$cId\?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse.phone;


}

############################################
#END Get Usage Of Customer
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
$Objworkbook.ActiveSheet.Cells.Item(1,1) = "Kundename";
$Objworkbook.ActiveSheet.Cells.Item(1,2) = "Systeme";
$Objworkbook.ActiveSheet.Cells.Item(1,3) = "Sensoren";
$Objworkbook.ActiveSheet.Cells.Item(1,4) = "NFR";
$Objworkbook.ActiveSheet.Cells.Item(1,5) = "Zwischensumme";
$Objworkbook.ActiveSheet.Cells.Item(1,6) = "Third party";
$Objworkbook.ActiveSheet.Cells.Item(1,7) = "Summe";
$Objworkbook.ActiveSheet.Cells.Item(1,8) = "Kostenlose Sensoren";
$Objworkbook.ActiveSheet.Cells.Item(1,9) = "Server";
$Objworkbook.ActiveSheet.Cells.Item(1,10) = "Workstations";

$arrayCustomers = getVisibleCustomers;

#getUsageOfCustomer;

$usages = getUsageOfCustomer;

$maxSensors = 0;
$maxAntivir = 0;
$maxPatch = 0;
$maxPCvisit = 0;

foreach($usage in $usages)
{
        
    $serverCounter=0;
    $workstationCounter=0;
    
    foreach($customer in $arrayCustomers)
    {
        if ($usage.customerNumberExtern -eq $customer.customerNumberExtern) {

            
            





            $customerId = $customer.cId;

            $arrayContainers = getContainersOfCustomer($customerId);

            :inner1 foreach($container in $arrayContainers)
            {

                #Write-Host "container ID: " $container.id " " $container.subtype;

                if ($container.subtype -eq "0") {
                #if ($false) {
            
                    #Write-Host "OCC-Connector: " $container.name ;

                    #Write-Host "container ID: " $container.id; 
                    #Write-Host "container Name: " $container.name;


                    :inner2 foreach($sensorhub in $arrayContainers)
                    {

                
                
                        if ( $sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                            #Write-Host "   Sensorhub: " $sensorhub.name $container.tags.id;


                            if ($container.tags.id -eq "server") {
                                $serverCounter++;
                            } else {
                                $workstationCounter++;
                            }
                            


                        }
                    }



        
                }


            }





            Write-Host "customer name: " $customer.companyName " server: " $serverCounter " workstations: " $workstationCounter ;


        }

    }
    


    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,1) = $usage.companyName;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,2).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,2) = "+"+$usage.container;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,3).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,3) = "+"+$usage.agents;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,4).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,4) = "-"+$usage.nfr;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,5).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,5) = $usage.subtotal;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,6).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,6) = "-"+$usage.thirdParty;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,7).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,7) = "-"+$usage.total;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,8).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,8) = "-"+$usage.free;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,9) = $serverCounter;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,10) = $workstationCounter;


    $global:actRow++;

        
}




    




$Objworkbook.ActiveSheet.Cells.Select() > $null;
$Objworkbook.ActiveSheet.Cells.EntireColumn.AutoFit() > $null;
$Objworkbook.ActiveSheet.Cells.Item(1,1).Select() > $null;

#$Objworkbook.ActiveSheet.FreezePanes = $true


#CLOSE/SAVE Excel File
$Objexcel.DisplayAlerts = $false
$Objworkbook.SaveAs($excelFileName)
$Objexcel.DisplayAlerts = $true
$Objworkbook.Close()
$Objexcel.Quit()
[void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Objexcel)

