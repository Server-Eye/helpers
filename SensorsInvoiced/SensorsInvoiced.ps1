<# Sensors Invoiced
AUTOR: Mike Semlitsch
DATE: 03.06.2016
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

    $retval = $jsonResponse.surname + " " + $jsonResponse.prename + " InvoicedSensorsOfAllCustomers " + $year + " " + $month + ".xlsx";

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
#Get Usage Of Customer
############################################
function getUsageOfCustomer($cId) {
    $url = "https://api.server-eye.de/2/customer/$cId/usage?year=$year&month=$month&apiKey=$apiKey";

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
$Objworkbook.ActiveSheet.Cells.Item(1,2) = "Tel. Kunde";
$Objworkbook.ActiveSheet.Cells.Item(1,3) = "Monitoring";
$Objworkbook.ActiveSheet.Cells.Item(1,4) = "Antivir";
$Objworkbook.ActiveSheet.Cells.Item(1,5) = "Patch";
$Objworkbook.ActiveSheet.Cells.Item(1,6) = "PCvisit";




$arrayCustomers = getVisibleCustomers;



:outer foreach($customer in $arrayCustomers)
{

    #Write-Host "customer name: " $customer;

    $customerId = $customer.id;

    #getUsageOfCustomer $customerId;

    $usages = getUsageOfCustomer $customerId;

    $maxSensors = 0;
    $maxAntivir = 0;
    $maxPatch = 0;
    $maxPCvisit = 0;

    foreach($usage in $usages)
    {
        
        

        [int]$actVal = [convert]::ToInt32($usage.subtotal, 10);
        if ($actVal -gt $maxSensors) {
            $maxSensors = $actVal;
        }

        [int]$actVal = [convert]::ToInt32($usage.antivir, 10);
        if ($actVal -gt $maxAntivir) {
            $maxAntivir = $actVal;
        }

        [int]$actVal = [convert]::ToInt32($usage.patch, 10);
        if ($actVal -gt $maxPatch) {
            $maxPatch = $actVal;
        }

        [int]$actVal = [convert]::ToInt32($usage.pcvisit, 10);
        if ($actVal -gt $maxPCvisit) {
            $maxPCvisit = $actVal;
        }

        
    }

    $tel = getCustomerPhoneNumber $customerId;

    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,1) = $customer.name;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,2).NumberFormat = "@";
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,2) = ""+$tel;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,3) = $maxSensors;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,4) = $maxAntivir;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,5) = $maxPatch;
    $Objworkbook.ActiveSheet.Cells.Item($global:actRow,6) = $maxPCvisit;

    Write-Host $customer.name;
 

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

