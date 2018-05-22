# GetSensorState.ps1

Shows all Sensors in an Error State.

If -All Parameter is set, all Sensor States are Shown


## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetSensorState/GetSensorState.ps1" -OutFile GetSensorState.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | GetSensorState.ps1 -all
```

## Call with Session via Connect-SESession, show all Sensors
```
Connect-SESession | GetSensorState.ps1 -all
```

## Call with API Key
```
GetSensorState.ps1 -apiKey yourApiKey
```

## Call with API Key, show all Sensors
```
GetSensorState.ps1 -apiKey yourApiKey -all
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary im no Server-Eye Session exists in den Powershell

### all
Also shows Sensor were not Error is present
