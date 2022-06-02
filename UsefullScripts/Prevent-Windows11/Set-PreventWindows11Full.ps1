<# 
.SYNOPSIS
    Will set a few registry keys to prevent Windows 11 from installing

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
    [switch]$set, 
    [switch]$silent
)

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$check = false

if((Get-ItemProperty -Path $registryPath -Name TargetReleaseVersion).TargetReleaseVersion -ne 1){   # Should be 1
    Write-Output "Key TargetReleaseVersion not set."
    $check = $true
}  

if((Get-ItemProperty -Path $registryPath -Name TargetReleaseVersionInfo).TargetReleaseVersionInfo -ne $targetVersion){ # Should be 22H1
    Write-Output "Key TargetReleaseVersionInfo not set."
    $check = $true
}

if ((Get-ItemProperty -Path $registryPath -Name ProductVersion).ProductVersion -ne $WindowsVersionString){  # Should be Windows 10 after using script
    Write-Output "Key ProductVersion not set. "
    $check = $true
}

if($set){
    try{
        try{
            New-ItemProperty -Path $registryPath -Name TargetReleaseVersionInfo -PropertyType String -Value $targetVersion -ErrorAction Stop
        }catch{
            Write-Output "Key already exists, changing target version."
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
        Write-Output "Script finished, keys set. "
        Write-Output "Please restart your computer to activate the changes. "

    }catch{        
        Write-Output "Could not set keys. Reason: "
        Write-Output $_.Exception.Message

    }
}else{
    if($check -eq $true){
        Write-Output "Nothing changed! "
        Write-Output "Registry Keys not set, please run the script again with parameter -set "
    }
}