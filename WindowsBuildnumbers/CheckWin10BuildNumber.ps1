#Requires -Module ServerEye.Powershell.helper
<#
    .SYNOPSIS
        Check Windows 10 Build
        
    .DESCRIPTION
        This script will generate a list of all Windows 10 System based around the Windows Version.
        It also will show will show End of Service Date based on the CSV File.
        The script will look at all customers visible to the user used to authenticate against the Server-Eye API.
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.    

    .Link
    https://docs.microsoft.com/en-us/windows/win32/api/_wua/
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false)]
    [alias("ApiKey", "Session")]
    $AuthToken
)

try {
    # Check for existing session
    $AuthToken = Test-SEAuth -AuthToken $AuthToken
}
catch {
    # There is no session - prompt for login
    $AuthToken = Connect-SESession -Persist
}

if (!$AuthToken) {
    $AuthToken = Connect-SESession -Persist
}

if (!$AuthToken) {
    Write-Error "Fehler beim Login!"
    exit 1
}

#Get the Release info from Github and shorten the Buildnumber to a usefull format
#Example from 18363.535 to 18363
$releaseCSV = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Server-Eye/helpers/master/WindowsBuildnumbers/Windows10Release.csv' | ConvertFrom-Csv -Delimiter "," | ForEach-Object -Process {$_."OS Build" = ($_."OS Build").Remove(5);$_}
#Get all Windows 10 System form all Customers and shorten the Buildnumber to a usefull format
#Example form 10.0.18363 to 18363

$data = Get-SeApiMyNodesList -Filter customer,container -AuthToken $AuthToken -listType object
$customers = $Data.managedCustomers
$customers += $Data.customer
$containers = $data.container
$Connectors = $containers | Where-Object {$_.subtype -eq 0}
$Sensorhubs = $containers | Where-Object {$_.subtype -eq 2}

foreach ($customer in $customers) {
    $Customerhubs = $Sensorhubs | Where-Object {($_.customerId -eq $customer.id) -and ($_.isServer -eq $false)}
    foreach($Sensorhub in $Customerhubs){
        #Get the right Release infomatuon
        $TMPHub = Get-SEAPIContainer -CId $Sensorhub.id -AuthToken $AuthToken
        $myrelase = $releaseCSV | Where-Object {$_."OS Build" -like ($TMPHub.osVersion).Remove(0,5)}
        #Create custom object with only the nessesary informations
        [PSCustomObject]@{
            Customer = $customer.name
            Name = $TMPHub.Name
            "OCC-Connector" = ($Connectors| Where-Object {$_.id -eq $TMPHub.parentid}).name
            OSName = $TMPHub.OsName
            Version = if ($myrelase.Version){$myrelase.Version}else {
                ($TMPHub.osVersion).Remove(0,5)
            }
            'Servicing option' = $myrelase.'Servicing option'
            "End of Service Home or Pro" = if ($myrelase.Default -eq "") {$myrelase.Mainstream}else {$myrelase.Default}
            "End of Service Enterprise/Extendent Support" = if ($myrelase.Enterprise -eq "") { $myrelase.Extended} else{$myrelase.Enterprise}
        }
    }
}


$customers| Where-object {$_.OSName -like "*10*" -and $_.IsServer -eq $false} | ForEach-Object -Process {$_.OsVersion = ($_.OsVersion).Remove(0,5);$_}

#Loop through all found Sensorhubs 
