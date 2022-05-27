<#
<description>Will check and maybe set some registry keys to prevent Windows 11 from installing</description>
<version>2</version>
#>

<# 
.SYNOPSIS
    Will set a few registry keys to prevent Windows 11 from installing - !For use with PowerShell Script Agent!

.DESCRIPTION
    Will set the following registry keys to prevent Windows 11 from installing: 
    Registry-Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    Keys:   TargetReleaseVersionInfo as String for TargetVersion (see https://docs.microsoft.com/en-us/windows/release-health/release-information)            
            TargetReleaseVersion as DWord, if set to 1 it activates the target release version
            ProductVersion optional as String, set to Windows 10
    IMPORTANT NOTE: Microsoft will override this setting after end of life of this version!
    IMPORTANT: You will have to change the TargetReleaseVersionInfo to the next version if a new half-annual update is released
    

.PARAMETER targetVersion
    Release-Version, find more here: https://docs.microsoft.com/en-us/windows/release-health/release-information

.PARAMETER WindowsVersionString
    Windows Version String, should be "Windows 10", set by default

.PARAMETER set
    Will set the registry keys

.Example
    Set-PreventWindows11.ps -set
    Set-PreventWindows11.ps -set -targetVersion "23H2"    # Please see https://docs.microsoft.com/en-us/windows/release-health/release-information

#>
#Requires -RunAsAdministrator

Param(
    [string]$targetVersion = "22H1", #set a future version, you can find it here: https://docs.microsoft.com/en-us/windows/release-health/release-information
    [string]$WindowsVersionString = "Windows 10",
    [switch]$set
)

#load the libraries from the Server Eye directory
$scriptDir = $MyInvocation.MyCommand.Definition |Split-Path -Parent |Split-Path -Parent
$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)

$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-Object System.Text.StringBuilder

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$check = false

if((Get-ItemProperty -Path $registryPath -Name TargetReleaseVersion).TargetReleaseVersion -ne 1){   # Should be 1
    $msg.AppendLine("Key TargetReleaseVersion not set.")
    $check = $true
}  

if((Get-ItemProperty -Path $registryPath -Name TargetReleaseVersionInfo).TargetReleaseVersionInfo -ne $targetVersion){ # Should be 22H1
    $msg.AppendLine("Key TargetReleaseVersionInfo not set.")
    $check = $true
}

if ((Get-ItemProperty -Path $registryPath -Name ProductVersion).ProductVersion -ne $WindowsVersionString){  # Should be Windows 10 after using script
    $msg.AppendLine("Key ProductVersion not set. ")
    $check = $true
}




if($set){
    try{
        try{
            New-ItemProperty -Path $registryPath -Name TargetReleaseVersionInfo -PropertyType String -Value $targetVersion -ErrorAction Stop
        }catch{
            $msg.AppendLine("Key already exists, changing target version.")
            Set-ItemProperty -Path $registryPath -Name TargetReleaseVersionInfo -Value $targetVersion
        }

        try{
            New-ItemProperty -Path $registryPath -Name TargetReleaseVersion -PropertyType DWORD -Value 1 -ErrorAction Stop #most important key
        }catch{
            # check if it's already set, if yes nevermind. If no throw exception, important key
            $buf = (Get-ItemProperty -Path $registryPath -Name TargetReleaseVersion).TargetReleaseVersion            
            if($buf -ne 1){
                throw "Could not set Key TargetReleaseVersion to activate this feature"
            }
        
        }

        New-ItemProperty -Path $registryPath -Name ProductVersion -PropertyType String -Value $WindowsVersionString -ErrorAction SilentlyContinue # not so important
        $msg.AppendLine("Script finished, keys set. ")
        $msg.AppendLine("Please restart your computer to activate the changes. ")
        [ServerEye.PowerShell.API.PowerShellStatus]::OK
        $exitCode = 0

    }catch{
        [ServerEye.PowerShell.API.PowerShellStatus]::ERROR
        $msg.AppendLine("Could not set keys. Reason: ")
        $msg.AppendLine($_.Exception.Message)

        $exitCode = 1
    }
}else{
    if($check -eq $true){
        $msg.AppendLine("Nothing changed! ")
        $msg.AppendLine("Registry Keys not set, please run the script again with parameter -set ")
    }
}


$api.setMessage($msg)
Write-Host $api.toJson()
exit $exitCode
