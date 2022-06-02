<# 
.SYNOPSIS
    Will delete HKEY_CLASSES_ROOT\ms-msdt keys according to https://mecm365.com/solution-to-disable-msdt-url-protocol-via-configuration-manager-sccm/ 

.DESCRIPTION
    Will delete HKEY_CLASSES_ROOT\ms-msdt keys according to https://mecm365.com/solution-to-disable-msdt-url-protocol-via-configuration-manager-sccm/ 

.PARAMETER deleteKey
    Will delete HKEY_CLASSES_ROOT\ms-msdt keys according to https://mecm365.com/solution-to-disable-msdt-url-protocol-via-configuration-manager-sccm/ 
    to disable MSDT URL protocol

.PARAMETER backup
    Will backup registry HKEY_CLASSES_ROOT\ms-msdt

.Example
    Disable-MsdtUrl.ps1 # Checks if there is a key
    Disable-MsdtUrl.ps1 -deleteKey # Will delete key HKEY_CLASSES_ROOT\ms-msdt
    Disable-MsdtUrl.ps1 -deleteKey -backup # Will backup keys and delete key HKEY_CLASSES_ROOT\ms-msdt

#>
#Requires -RunAsAdministrator

Param(
    [switch]$deleteKey,
    [switch]$backup
)

if ((Test-Path REGISTRY::HKEY_CLASSES_ROOT\ms-msdt) -eq $true) {
    Write-Output "Key found!"
    if($deleteKey -eq $true){
        Write-Output "Try to delete key... "
        $backupSuccess = $true
        if($backup -eq $true){
            try{
                Write-Output "Creating Backup... "
                $pathForBackup = $env:ProgramData + "\\ServerEye3"
                $pathForBackup = Join-Path -Path $pathForBackup -ChildPath "ms-msdt-backup.reg"   

                Invoke-Command {reg export 'HKEY_CLASSES_ROOT\ms-msdt' $pathForBackup}

                Write-Output "Backup created in " $pathForBackup

            }catch{
                Write-Output "Could not backup Key."
                Write-Output $_
                $backupSuccess = $false
            }
        }
        try{
            if($backupSuccess -eq $true){
                Remove-Item REGISTRY::HKEY_CLASSES_ROOT\ms-msdt -Recurse -Force
                Write-Output "Key deleted."
            }else{
                Write-Output "Key not deleted - backup wasn't successful."
            }
        }catch{
            Write-Output "Could not delete Key."
            Write-Output $_
        }

        
    }else{
        Write-Output "Critical ms-msdt-Key found, no action performed"
    }
} else {
    Write-Output "System clean, no ms-msdt keys found"
}
