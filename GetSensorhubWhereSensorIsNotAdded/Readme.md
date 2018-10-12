# GetSensorhubWhereSensorIsNotAdded.ps1

Shows all System where the given Sensor is not appled.

Sensortype must be provided in English see this link for more Informations.
https://servereye.freshdesk.com/support/solutions/articles/14000082889-auflistung-aller-sensor-in-der-powershell

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetSensorhubWhereSensorIsNotAdded/GetSensorhubWhereSensorIsNotAdded.ps1" -OutFile GetSensorhubWhereSensorIsNotAdded.ps1
```

## Call with Session via Connect-SESession
```
Connect-SESession | GetSensorhubWhereSensorIsNotAdded.ps1 -Sensortype "Sensortype in English"
```

## Call with API Key
```
GetSensorhubWhereSensorIsNotAdded.ps1 -apiKey yourApiKey -Sensortype "Sensortype in English"
```

## Parameters

### apiKey
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell
