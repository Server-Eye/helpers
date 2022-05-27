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

#>
#Requires -RunAsAdministrator

Param(
    [string]$targetVersion = "22H1" #set a future version, you can find it here: https://docs.microsoft.com/en-us/windows/release-health/release-information
)

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

$title = "Windows 11 prevent script?" 
$message = "This script will set three registry keys to prevent Windows 11 from installing. Do you want to set the registry keys?"
$set = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Set the registry keys to avoid Windows 11"    # 0
$abort = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Abort" # 1
$options = [System.Management.Automation.Host.ChoiceDescription[]]($set, $abort)
$choice=$host.ui.PromptForChoice($title, $message, $options, 1)

if($choice -eq 0 ){
    try{
        try{
            New-ItemProperty -Path $registryPath -Name TargetReleaseVersionInfo -PropertyType String -Value $targetVersion -ErrorAction Stop
        }catch{
            Write-Host "Key already exists, changing target version. "
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

        New-ItemProperty -Path $registryPath -Name ProductVersion -PropertyType String -Value "Windows 10" -ErrorAction SilentlyContinue # not so important
        Write-Host "Script finished, keys set. " -ForegroundColor Green
        Write-Host "Please restart your computer to activate the changes. " -ForegroundColor Green
        pause
        exit

    }catch{
        Write-Host "Could not set keys. Reason: " -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        pause
        exit
    }

}else{
    Write-Host "Nothing changed, script aborted " -ForegroundColor Green
    pause
    exit

}