#Get the Release info from Github and shorten the Buildnumber to a usefull format
#Example from 18363.535 to 18363
$releaseCSV = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Server-Eye/helpers/master/UsefullScripts/WindowsBuildnumbers/Windows10Release.csv' | ConvertFrom-Csv -Delimiter "," | ForEach-Object -Process {$_."OS Build" = ($_."OS Build").Remove(5);$_}
#Get all Windows 10 System form all Customers and shorten the Buildnumber to a usefull format
#Example form 10.0.18363 to 18363
$Sensorhubs = Get-SECustomer | Get-SESensorhub | Where-object {$_.OSName -like "*10*" -and $_.IsServer -eq $false} | ForEach-Object -Process {$_.OsVersion = ($_.OsVersion).Remove(0,5);$_}

#Loop through all found Sensorhubs 
foreach($Sensorhub in $Sensorhubs){
    #Get the right Release infomatuon
    $myrelase = $releaseCSV | Where-Object {$_."OS Build" -like $Sensorhub.OsVersion}
    #Create custom object with only the nessesary informations
    [PSCustomObject]@{
        Customer = $Sensorhub.Customer
        Name = $sensorhub.Name
        "OCC-Connector" = $Sensorhub.'OCC-Connector'
        OSName = $Sensorhub.OsName
        Version = $myrelase.Version
        "End of Service Home or Pro" = if ($myrelase.'End of service: Home; Pro; Pro Education; Pro for Workstations and IoT Core' -eq "") {$myrelase."Mainstream support end date"}else {$myrelase.'End of service: Home; Pro; Pro Education; Pro for Workstations and IoT Core'}
        "End of Service Enterprise/Extendent Support" = if ($myrelase."End of service: Enterprise; Education and IoT Enterprise" -eq "") { $myrelase."Extended support end date"} else{$myrelase.'End of service: Enterprise; Education and IoT Enterprise'}
    }
}