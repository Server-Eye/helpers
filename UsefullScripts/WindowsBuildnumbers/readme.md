# Information provided without guarantee
CSV file information based on data form this link: https://docs.microsoft.com/en-us/windows/release-information/

# CheckWin10BuildNumber.ps1

This script will generate a list of all Windows 10 System based around the Windows Version.
It also will show will show End of Service Date based on the CSV File.
The script will look at all customers visible to the user used to authenticate against the Server-Eye API.

This script supports login via API key and via username and password. 

## PowerShell Helper Module
This script needs the Server-Eye Powershell helper. Please see https://github.com/Server-Eye/helpers/blob/master/ServerEye.Powershell.Helper/readme.md for details on how to install this module.

## Download

You can download the helper script with following powershell command:
```
iwr "https://raw.githubusercontent.com/Server-Eye/helpers/master/UsefullScripts/WindowsBuildnumbers/CheckWin10BuildNumber.ps1" -OutFile CheckWin10BuildNumber.ps1
```

## Execute

### With an API Key
```powershell
CheckWin10BuildNumber.ps1 -ApiKey yourApiKey 
```

### Via Login
```powershell
Connect-SESession | CheckWin10BuildNumber.ps1
```

## Output
The output is a standard PowerShell table and can be processed with any compatible cmdlet. The most common option is to create a Excel sheet. 
```powershell
# You only need to install the module once.
Install-Module -Name ImportExcel -Scope CurrentUser

# Show all sensors without a notification and save the result as Excel sheet
Connect-SESession | CheckWin10BuildNumber.ps1 | Export-Excel -Path "CheckWin10BuildNumber.xlsx" -Now
```