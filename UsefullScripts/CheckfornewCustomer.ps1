<#
.SYNOPSIS
  Name: CheckfornewCustomer.ps1
  The purpose of this script is to find new Customer
#>
<#
<version>2</version>
<description>Checks if new Customer are added.</description>
#>

Param ( 
    [Parameter()] 
    $CSVFile
)

#load the libraries from the Server Eye directory
$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent

$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)

$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-object System.Text.StringBuilder

# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}
# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}

#Define the exit Code
$exitCode = -1

#APIKey needed for the Checks
$AuthToken = "ApiKey"

$AuthToken = Test-SEAuth -AuthToken $AuthToken

#Check if Parameter is given
if (!$path) {
    $msg.AppendLine("Please fill out all params needed for this script.")
    $exitCode = 5
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
}
#Check if CSV file existed
elseif (!(Test-Path -Path $path)) {
    $msg.AppendLine("CSV File not Found, maybe first Run will create a new CSV")
    $exitCode = 1
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
    Get-SECustomer -all -AuthToken $AuthToken | Export-Csv -Path $CSVFile -Delimiter ";"
}
else {
        $result = Compare-Object -DifferenceObject ($currentcustomer = Get-SECustomer -all -AuthToken $AuthToken) -ReferenceObject (Import-Csv -Path $CSVFile -Delimiter ";") -Property CustomerNumber | Where-Object { $_.SideIndicator -eq "=>" }
        if ($result) {
            #Create Variable with all Data for new Customer
            $newcustomer = $currentcustomer | Where-Object { $_.CustomerNumber -in $result.CustomerNumber } | Out-String
            #Export the current Customers to the CSV
            $currentcustomer | Export-Csv -Path $CSVFile -Delimiter ";"
            $msg.AppendLine($newcustomer)
            $exitCode = 6
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
        }
        else {
            #No new Customers so all is fine
            $msg.AppendLine("No new Customer Found")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }
}
#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode