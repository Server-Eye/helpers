# GetSensorState.ps1

Shows all Sensors with Creation date.

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetSensorWithCreationdate/GetSensorWithCreationdate.ps1" -OutFile GetSensorWithCreationdate.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | GetSensorWithCreationdate.ps1 -CustomerID "ID of the Customer"
```

## Call with API Key
```
GetSensorWithCreationdate.ps1 -apiKey yourApiKey -CustomerID "ID of the Customer"
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell

### CustomerID
The Customer from where the Sensors should be shown
