# GetLastActiveDate.ps1

Shows all System with no connection and the time of the last activity or Systems that were not connected for 14 Days or more.

Shows time based on the TimeZone of the System on which the Script was executed.

## Prerequisite
PowerShell Modules needed:
Servereye.PowerShell.Helper
ImportExcel 

Install via, as Administrator:
```
Install-Module -Name ModuleName -Scope AllUsers 
```

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetLastActiveDate/GetLastActiveDate.ps1" -OutFile GetLastActiveDate.ps1
```

## Call with API Key
```
.\GetLastActiveDate.ps1 -apiKey yourApiKey
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell

### LastActiveDays
Last Active Days, default is 14

### PathtoExcelFile
Excel File if one should be created


# GetLastActiveDatewithShutdown.ps1

Shows all System with no connection and are shutdown and the time of the last activity or Systems that were not connected for 14 Days or more.

Shows time based on the TimeZone of the System on which the Script was executed.

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetLastActiveDate/GetLastActiveDatewithShutdown.ps1" -OutFile GetLastActiveDatewithShutdown.ps1
```

## Call with API Key
```
.\GetLastActiveDatewithShutdown.ps1 -apiKey yourApiKey
```

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell

### LastActiveDays
Last Active Days, default is 14

### PathtoExcelFile
Excel File if one should be created