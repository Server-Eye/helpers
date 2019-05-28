SyncSensorhubsNamewithHostname.ps1

Compares the Sensorhubname with the Hostname, if they dont match the Sensorhubname will be changed.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/SyncSensorhubsNamewithHostname/SyncSensorhubsNamewithHostname.ps1" -OutFile SyncSensorhubsNamewithHostname.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
SyncSensorhubsNamewithHostname.ps1 -ApiKey "yourApiKey" -SensorhubID "IDofTheSensorhub"
```

### Via Login
```powershell
Connect-SESession | SyncSensorhubsNamewithHostname.ps1 -SensorhubID "IDofTheSensorhub"
```


### With the Helper
```powershell
Connect-SESession -persist
Get-SECustomer | Get-SESensorhub | .\SyncSensorhubsNamewithHostname.ps1 -SensorhubID "IDofTheSensorhub"
```