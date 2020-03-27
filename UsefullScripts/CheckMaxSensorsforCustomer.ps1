#Requires -Modules ServerEye.PowerShell.Helper
<#
    .SYNOPSIS
    Checks if Customer has more Sensor added 
    
    .DESCRIPTION
    Checks if Customer exceed max Agent Count
    
    .PARAMETER NameoftheCustomerProperty
    name of the Agent Count Property

    .PARAMETER CustomerName
    name of the Customer to check

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.    
#>

<#
.SYNOPSIS
  Name: CheckMaxSensorsforCustomer.ps1
  The purpose of this script is to compare the given Customer Property with the Agent Count.
#>
<#
<version>2</version>
<description>Checks if Customer exceed max Agent Count.</description>
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    $NameoftheCustomerProperty,
    [Parameter(Mandatory = $true)]
    $CustomerName,
    [Parameter()]
    $AuthToken
)
$scriptDir = 'C:\Program Files (x86)\Server-Eye\service\934'
#$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent

$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)

$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-object System.Text.StringBuilder

#Define the exit Code
$exitCode = -1
#endregion LoadScript

#Check if Login is there
$AuthToken = Test-SEAuth -AuthToken $AuthToken 

$now = Get-Date

#region MainFuntion

#Search for Customer
try {
    $Customer = Get-SECustomer -Filter $CustomerName -AuthToken $AuthToken -ErrorAction Stop
}
catch {
    if ($_.Exception.Response.StatusCode -eq "AUnauthorized") {
        $msg.AppendLine("Unauthorized please review Login or APIKey")
        $exitCode = 4
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
    }else{
        $msg.AppendLine("Unknown Error: $($_.Exception)")
        $exitCode = 4
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
    }

}

#endregion MainFuntion

#region Output
#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode
#endregion Output

#Check if Customer is found
if ((!$Customer)) {
    $msg.AppendLine("No Customer found.")
    $exitCode = 5
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
}
else {
        #Check for Agent Package
        $CustomerAgentPackage = Get-SECustomerProperties -CustomerId $Customer.CustomerId -AuthToken $AuthToken | Where-Object { $_.Properties -match $NameoftheCustomerProperty }
        if (!$CustomerAgentPackage) {
            $msg.AppendLine("Package not set in Customer $($Customer.Name)")
            $exitCode = 6
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 

        }
        else { 
            #Get Agent Count ogf the Customer for the last Day/Count
            $Invoice = Get-SeApiCustomerUsage -cid $Customer.CustomerID -year $now.Year -Month $now.Month -AuthToken $AuthToken
            $AgentCount = ($Invoice[-1].agents - $Invoice[-1].nfr)

            If ($AgentCount -gt $CustomerAgentPackage.Properties.$NameoftheCustomerProperty) {
                $msg.AppendLine("Customer reach limit of $($CustomerAgentPackage.Properties.$NameoftheCustomerProperty) Agents, Customer is at $($Agentcount) Agents")
                $exitCode = 7
                $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
            }
            else {
                $msg.AppendLine("Customer has not reach limit of $($CustomerAgentPackage.Properties.$NameoftheCustomerProperty) Agents, Customer is at $($Agentcount) Agents")
                $exitCode = 0
                $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
            }
        }

}
#endregion MainFuntion

#region Output
#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode
#endregion Output

    






