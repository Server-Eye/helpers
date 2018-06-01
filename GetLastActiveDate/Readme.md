# GetLastActiveDate.ps1

Shows all System with no connection and the time of the last activity.

Shows time based on the TimeZone of the System on which the Script was executed.

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetLastActiveDate/GetLastActiveDate.ps1" -OutFile GetLastActiveDate.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | GetLastActiveDate.ps1
```

## Call with API Key
```
GetLastActiveDate.ps1 -apiKey yourApiKey
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell
