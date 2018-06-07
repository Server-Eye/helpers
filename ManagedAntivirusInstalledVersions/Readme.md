# ManagedAntivirusInstalledVersions.ps1

Creates an excel file with a report of all Manged Antivirus Sensors for all Customers the user has been assigned to, and displays the installed version.

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/ManagedAntivirusInstalledVersions/ManagedAntivirusInstalledVersions.ps1" -OutFile ManagedAntivirusInstalledVersions.ps1
```

## Call with Session via Connect-SESession
```
ManagedAntivirusInstalledVersions.ps1
```

## Call with API Key
```
ManagedAntivirusInstalledVersions.ps1 -apiKey yourApiKey 
```

## Parameters

### apiKey
The api-Key of the user.



# AllManagedAntivirusInstalledVersions.ps1

Creates an excel file with a report of all Manged Antivirus Sensors for all Customers, and displays the installed version.

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/ManagedAntivirusInstalledVersions/AllManagedAntivirusInstalledVersions.ps1" -OutFile AllManagedAntivirusInstalledVersions.ps1
```
## Call with Session via Connect-SESession
```
AllManagedAntivirusInstalledVersions.ps1
```

## Call with API Key
```
AllManagedAntivirusInstalledVersions.ps1 -apiKey yourApiKey 
```

## Parameters

### apiKey
The api-Key of the user.
