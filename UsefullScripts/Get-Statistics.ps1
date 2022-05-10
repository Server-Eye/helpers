[CmdletBinding()]
<#
    .SYNOPSIS
    Get the number of all servers and workstations from the customers
    
    .DESCRIPTION
    Get the number of all servers and workstations from the customers

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
    .PARAMETER asPDF
    Set this to get the output as a pdf file. Will only work on Windows 10, Windows Server 2016 or later via Microsoft pdf printer
    Will prompt for the destination path

    .PARAMETER asExcel
    Set this parameter to get the output as a Excel-File - Please use additonally parameter -Path - if not it will use a generic filename

    .PARAMETER Path 
    If asExcel is used provide a export path. 

    .EXAMPLE 
    Get-Statistics.ps1 -AuthToken aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee -asExcel -Path "C:\test\outputfile.xlsx"

    Get-Statistics.ps1 -AuthToken aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee -asPdf

    Get-Statistics.ps1 -AuthToken aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee 
    Customer                                          Server Workstations
    --------                                          ------ ------------
    CustomerA                                              0           12
    CustomerB                                              5           15
    CustomerC                                              5           17
    CustomerD                                              0            0

    .NOTES
    Author: Server-Eye
    Version: 1.0
#>


Param(
    [Parameter(ValueFromPipeline=$true)]
    [alias("ApiKey","Session")]
    $AuthToken, 
    [switch]$asPDF, 
    [switch]$asExcel, 
    $Path
)

# Check if module is installed, if not install it
if (!(Get-Module -ListAvailable -Name "ServerEye.Powershell.Helper")) {
    Write-Host "ServerEye PowerShell Module is not installed. Installing it..." -ForegroundColor Red
    Install-Module "ServerEye.Powershell.Helper" -Scope CurrentUser -Force
}

# Check if module is loaded, if not load it
if (!(Get-Module "ServerEye.Powershell.Helper")) {
    Import-Module ServerEye.Powershell.Helper
}

if($asExcel -eq $true){
    # Check if module is installed, if not install it
    if (!(Get-Module -ListAvailable -Name "ImportExcel")) {
        Write-Host "Excel Module is not installed. Installing it..." -ForegroundColor Red
        Install-Module "ImportExcel" -Scope CurrentUser -Force
    }

    # Check if module is loaded, if not load it
    if (!(Get-Module "ImportExcel")) {
        Import-Module ImportExcel
    }
}



$AuthToken = Test-SEAuth -AuthToken $AuthToken
$customers = Get-SeApiMyNodesList -Filter customer -AuthToken $AuthToken

$result = @()

foreach($customer in $customers){
    $containers = Get-SeApiCustomerContainerList -AuthToken $AuthToken -CId $customer.id
    $serverCounter = 0
    $clientCounter = 0 
    
    foreach($container in $containers){

        foreach ($sensorhub in $container) {

            if ($sensorhub.subtype -eq "2"){

                if($sensorhub.isServer -eq $true){             
                    $serverCounter = $serverCounter + 1
                }

                else{                    
                    $clientCounter = $clientCounter + 1
                }
            }
        }    
    }

    $out = New-Object psobject
    $out | Add-Member NoteProperty Customer ($customer.name)
    $out | Add-Member NoteProperty Server ($serverCounter)
    $out | Add-Member NoteProperty Workstations ($clientCounter)
    $result += $out
}

if($asExcel -eq $true){
    try{
        if($null -eq $Path){
            $date = Get-Date -Format "dd-MM-yyyy-HH-mm"
            $Path = "scriptOutput_" + $date + ".xlsx"
        }

        Write-Output $result  | Export-Excel -Path $Path

    }catch{
        Write-Error "Could not write file: $_"
    }
}

if($asPDF -eq $true){
    try{
    Write-Output $result | Out-Printer -Name "Microsoft Print to PDF"
    }catch{
        Write-Error "Could not write file: $_"
    }
}

if($asPDF -ne $true -and $asExcel -ne $true){
    Write-Output $result
}


