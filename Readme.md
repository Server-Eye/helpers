# Server-Eye/helpers

This is the Server-Eye Powershell repository. 

These script offer additional functions not present in the Server-Eye web interface. 

## Helper Scripts

Most scripts in this repository require the Server-Eye Powershell Helper module. It must be installed first.

### PowerShell 5 or higher
```powershell
Install-Module -Name ServerEye.Powershell.Helper -Scope CurrentUser
```

### PowerShell 3 + 4
_We strongly recommend upgrading to PowerShell 5._

If upgrading to PowerShell 5 is not an option, you can install the module management system separately at http://go.microsoft.com/fwlink/?LinkID=746217.

You can then use the same ```Install-Module``` cmdlet.
```powershell
Install-Module -Name ServerEye.Powershell.Helper -Scope CurrentUser
```

### PowerShell 1 + 2 
These versions are not supported.

### Output as Excel
Previous version of our scripts created Excel sheets as output. Our new scripts output more flexible PowerShell objects. To generate an Excel sheet you should use the PowerShell Module [ImportExcel](https://www.powershellgallery.com/packages/ImportExcel).

#### Example
```powershell
# You only need to install the module once.
Install-Module -Name ImportExcel -Scope CurrentUser

# Show all sensors without a notification and save the result as Excel sheet
Connect-SESession | SensorsOfCustomersWithoutNotifications.ps1 | Export-Excel -Path "noNotification.xslx" -Show
```

## Support
We provides these scripts as-is. We cannot guarantee that the scripts will work for you. For more information please contact our [support](https://support.server-eye.de).

