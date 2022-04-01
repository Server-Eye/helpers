<# 
    .SYNOPSIS
    Uninstall Kaspersky.

    .DESCRIPTION
    This script will uninstall Kaspersky Products from the System.
	In the case the uninstall dont work, try to stop the processes before starting the script.

    .PARAMETER Restart
    if the system should restart after uninstall is finished.
    
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
		[switch]$Restart,
	[Parameter(Mandatory=$false)]
		[string]$kasperskyuser,
	[Parameter(Mandatory=$false)]
		[string]$kasperskypwd
)

Write-Host "Performing uninstallation of Kaspersky Products"

try{

$name = '%%Kaspersky%%'                
gwmi win32_product -filter "Vendor LIKE '$name'" -namespace root/cimv2| foreach {
    if ($_.uninstall().returnvalue -eq 0) { 
        write-host "Successfully uninstalled $_.Name" 
    }
    else { 
        write-warning "Failed to uninstall $_.Name" 
    }

}
Start-Process "msiexec.exe" -ArgumentList "/x {60BB97EB-61BD-4FF3-8506-F155850CC6B5} KLLOGIN=$kasperskyuser KLPASSWD=$kasperskypwd /qn"

}catch{
    Write-Host "An error occured: $_" -ForegroundColor Red

}
    
If ($Restart.IsPresent -eq $true){
    Restart-Computer -Force
}




