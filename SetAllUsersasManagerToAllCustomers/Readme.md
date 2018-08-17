SetAllUsersasManagerToAllCustomers.ps1

This script will add all Users as Manager to all Customers.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/SetAllUsersasManagerToAllCustomers/SetAllUsersasManagerToAllCustomers.ps1" -OutFile SetAllUsersasManagerToAllCustomers.ps1
```

## Execute
There are several ways to run this script. 

### With an API Key
```powershell
SetAllUsersasManagerToAllCustomers.ps1 -AuthToken "yourApiKey"
```

### Via Login
```powershell
Connect-SESession | SetAllUsersasManagerToAllCustomers.ps1
```