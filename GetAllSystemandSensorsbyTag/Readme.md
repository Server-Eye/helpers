# GetAllSystemandSensorwithTag.ps1

This script will generate a list of all system and sensors with the specifided tag. The script will look at all customers visible to the user used to authenticate against the Server-Eye API.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetAllSystemandSensorsbyTag/GetAllSystemandSensorwithTag.ps1" -OutFile GetAllSystemandSensorwithTag.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
GetAllSystemandSensorwithTag.ps1.ps1 -ApiKey yourApiKey -Tag "name of the tag"
```

### Via Login
```powershell
Connect-SESession | GetAllSystemandSensorwithTag.ps1 -Tag "name of the tag"
```

## Output
The output is a standard PowerShell table and can be processed with any compatible cmdlet. The most common option is to create a Excel sheet. 
```powershell
# You only need to install the module once.
Install-Module -Name ImportExcel -Scope CurrentUser

# Show all sensors without a notification and save the result as Excel sheet
Connect-SESession | GetAllSystemandSensorwithTag.ps1 | Export-Excel -Path "withTag.xlsx" -Show
```


# GetAllSystemandSensorwithoutTag.ps1

This script will generate a list of all system and sensors without the specifided tag. The script will look at all customers visible to the user used to authenticate against the Server-Eye API.

This script supports login via API key and via username and password. 

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/GetAllSystemandSensorsbyTag/GetAllSystemandSensorwithoutTag.ps1" -OutFile GetAllSystemandSensorwithoutTag.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
GetAllSystemandSensorwithoutTag.ps1 -ApiKey yourApiKey -Tag "name of the tag"
```

### Via Login
```powershell
Connect-SESession | GetAllSystemandSensorwithoutTag.ps1 -Tag "name of the tag"
```

## Output
The output is a standard PowerShell table and can be processed with any compatible cmdlet. The most common option is to create a Excel sheet. 
```powershell
# You only need to install the module once.
Install-Module -Name ImportExcel -Scope CurrentUser

# Show all sensors with a notification and save the result as Excel sheet
Connect-SESession | GetAllSystemandSensorwithoutTag.ps1 | Export-Excel -Path "withoutTag.xlsx" -Show
```
