<#
.SYNOPSIS
  Name: CheckVSSonAllVolumes.ps1
  The purpose of this script is to check ShadowCopies on all Volumes in the last 24 Hours
#>

<#
<version>2</version>
<description>Checks the if a Shadow Copie was made in the Last 24 Hours on every Volume</description>
#>

#region LoadScript
#load the libraries from the Server Eye directory

$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent

$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)

$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-object System.Text.StringBuilder

#Define the exit Code
$exitCode = -1
#endregion LoadScript

#region MainFuntion
#Get all ShadowCopies on the System
$ShadowCopies = Get-CimInstance Win32_ShadowCopy

#Get all Volumes with Driveletter and form Drivetype 3 (Local Disk)
$volumes = Get-CimInstance win32_volume | Where-Object {($_.DriveLetter -ne $null) -and ($_.DriveType -eq "3")}

#Check if there is a Volume to Use
if ((!$volumes)) {
    $msg.AppendLine("No useable Volumes found.")
    $exitCode = 5
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 

#Check if there are more then 0 Shadow Copies
}elseif ($ShadowCopies.Count -eq 0) {
    $msg.AppendLine("No Shadows found.")
    $exitCode = 6
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 

#When there are more the 0 Shadow Copies go on
}else{
    #Get Volumes with Shadow Copies
    $withShadow = $volumes | Where-Object {($ShadowCopies.VolumeName -contains $_.DeviceID)}

    #Get Volumes without Shadow Copies
    $withoutShadow = $volumes | Where-Object {($ShadowCopies.VolumeName -notcontains $_.DeviceID)}

    #Get shadow Copies created in the last 24 hours on Volumes with Shadow Copies
    $shadow24 = $ShadowCopies | Where-Object {($withShadow.DeviceID -contains $_.VolumeName) -and ($_.InstallDate -gt (Get-Date).AddHours(-24))}

    #Check if one Volume have no Shadow Copie
    if(($withoutShadow | Measure-Object).Count -gt 0){
    $message = "No Shadows found on " + $withoutShadow.DriveLetter
    $msg.AppendLine($message)
    $exitCode = 7
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
    
    #Check if there are Shadow Copies in the last 24 Hours on all Volumes
    }elseif(!$shadow24){
    $message = "No Shadows found in the last 24 Hours on all Volumes"
    $msg.AppendLine($message)
    $exitCode = 8
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 

    #Check if there are Shadow Copies in the last 24 Hours on one Volumes
    }elseif($shadow24.count -ne $volumes.Count){
        $message = "No Shadows found in the last 24 Hours on Volumes " + ($volumes | Where-Object {$shadow24.VolumeName -ne $_.DeviceID}).Driveletter
        $msg.AppendLine($message)
        $exitCode = 9
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 


        #All Volumes have Shadow Copies from the Last 24 Hours.
    }else{
        $msg.AppendLine("Shadows found on all Volumes in the last 24 Hours.")
        $exitCode = 0
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
    }
}
#endregion MainFuntion

#region Output
#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode
#endregion Output