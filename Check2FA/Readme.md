# Check2FA.ps1

This script will check the 2 Faktor Authentication for all Users.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/Check2FA/Check2FA.ps1" -OutFile Check2FA.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
Check2FA.ps1 -ApiKey "yourApiKey" 
```

### Via Login
```powershell
Connect-SESession | Check2FA.ps1
```