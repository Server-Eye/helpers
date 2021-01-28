#Requires -Modules ServerEye.PowerShell.Helper
#Requires -Modules importexcel
<# 
    .SYNOPSIS
    Get a List of all created Sensorhub and OCC-Connector in the last x Days.

    .DESCRIPTION
    Get a List of all created Sensorhub and OCC-Connector in the last x Days.
    Required Modules "ServerEye.PowerShell.Helper" and "importexcel"
    Install in an elevated PowerShell:
    Install-Module -Name "ServerEye.powershell.helper","importexcel" -Scope AllUsers

    .PARAMETER Days
    Show New Sensorhubs for the last Days.

    .PARAMETER CustomerID
    The Customer from where the Sensors should be shown

    .PARAMETER PathtoExcelfile
    Path were the Excel File should be created

    .PARAMETER authtoken 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell
    
#>

[CmdletBinding()]
Param(
    [parameter(Mandatory = $true,HelpMessage = "Show New Sensorhubs for the last Days.")]
    [Int]
    $Days,

    [Parameter(Mandatory = $false,HelpMessage = "ID OF the Customer")]
    $CustomerID,

    [Parameter(Mandatory = $false,HelpMessage = "Path were the Excel File should be created")]
    $PathtoExcelfile,

    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken
)

$result = @()
$authtoken = Test-SEAuth -authtoken $authtoken
$DateToCheck = (Get-Date).AddDays(-$Days)

if ($CustomerID) {
    $Customers = Get-SeApiCustomer -CId $CustomerID -AuthToken $AuthToken
}
else {
    $Customers = Get-SeApiCustomerList -AuthToken $AuthToken
}

foreach ($Customer in $Customers) {
    Write-Debug $Customer.Companyname
    $ContainersCreated = Get-SeApiActionlogList -Of $Customer.cid -AuthToken $authtoken -Type "102" -Limit 100 -IncludeRawData "true" -MessageFormat "md"

    $Containers = $ContainersCreated | Where-Object { $_.changedate -ge $DateToCheck }

    foreach ($Container in $Containers) {
       $ContainerToAdd = [PSCustomObject]@{
            Customer        = $Container.customer.Name
            CustomerID      = $Container.customer.ID
            'OCC-Connector' = if($Container.parent.ID -eq $Container.customer.ID){$Container.target.Name}else{$Container.parent.name}
            Sensorhub       = if($Container.parent.ID -eq $Container.customer.ID){"OCC-Conenctor"}else{$Container.target.Name}
            SensorhubId     = if($Container.parent.ID -eq $Container.customer.ID){"OCC-Conenctor"}else{$Container.target.ID}
            "Created On"    = $Container.changeDate
        }
        $result += $ContainerToAdd 
    }
}

if($result){
Export-Excel -Path $PathtoExcelfile -InputObject $result -AutoFilter -AutoSize -FreezeTopRow -BoldTopRow -KillExcel
}

      

