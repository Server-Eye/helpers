<# Sensors Invoiced
AUTOR: Mike Semlitsch
DATE: 03.06.2016
VERSION: V1.0
DESC: Creates an excel file with a report for invoiced sensors for a month
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

    $retval = $jsonResponse.surname + " " + $jsonResponse.prename + " SensorsInvoicedSameAsOCC " + $year + " " + $month + ".xlsx";

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




getUsageOfCustomer;

$usages = getUsageOfCustomer;

$maxSensors = 0;
$maxAntivir = 0;
$maxPatch = 0;
$maxPCvisit = 0;

foreach($usage in $usages)
{
        
        

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

