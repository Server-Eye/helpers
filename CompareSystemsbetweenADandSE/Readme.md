# GetSensorhubWhereSensorIsNotAdded.ps1

Shows all System where the given Sensor is not appled.

Sensortype must be provided in English see this link for more Informations.
https://servereye.freshdesk.com/support/solutions/articles/14000082889-auflistung-aller-sensor-in-der-powershell

## Download

Please download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/CompareSystemsbetweenADandSE/CompareSystemsbetweenADandSE.ps1" -OutFile CompareSystemsbetweenADandSE.ps1
```

## Call with Session via Connect-SESession and Active Directory Check
```
Connect-SESession | CompareSystemsbetweenADandSE.ps1 -CustomerID "ID of the Customer"
```

## Call with API Key
```
CompareSystemsbetweenADandSE.ps1 -apiKey yourApiKey 
```

## Parameters

### AuthToken
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

### CustomerID
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

### ADCheck
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

### SECheck
The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

