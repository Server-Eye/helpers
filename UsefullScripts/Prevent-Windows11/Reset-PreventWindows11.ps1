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
    [switch]$backup
)

Write-Output "Will delete windows 11 prevent key in registry"

$title = "Reset Key or delete it?" 
$message = "You have the choice to delete the new set registry keys or to set TargetReleaseVersion=0"
$del = New-Object System.Management.Automation.Host.ChoiceDescription "&Delete Key", "Will delete registry key"    # 0
$zero = New-Object System.Management.Automation.Host.ChoiceDescription "&Set TargetReleaseVersion=0", "Will set Key TargetReleaseVersion to 0" # 1
$options = [System.Management.Automation.Host.ChoiceDescription[]]($del, $zero)
$choice=$host.ui.PromptForChoice($title, $message, $options, 1)

#Write-Host "Your choice: $($choice)"

# Backup Segment
$oldTargetReleaseVersion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersion -ErrorAction SilentlyContinue
$oldTargetReleaseVersionInfo = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersionInfo -ErrorAction SilentlyContinue
$oldProductVersion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name ProductVersion -ErrorAction SilentlyContinue

$pathForBackup = $env:ProgramData + "\\ServerEye3"
$pathForBackup = Join-Path -Path $pathForBackup -ChildPath "win11preventbackup.txt"

$backupContent = -Join($oldTargetReleaseVersion,"`n",  $oldTargetReleaseVersionInfo,"`n",  $oldProductVersion)

$fileExists=Test-Path $pathForBackup -PathType Leaf

if("False" -eq $fileExists){     
    try{       

        $backupContent | Out-File -Path $pathForBackup
        Write-Output "Registry entries backupped to $($pathForBackup)" -ForegroundColor Green

    }catch{
        Write-Output "Could not backup files" -ForegroundColor Red
        Write-Output $_.Exception.Message -ForegroundColor Red
        pause
        exit
    }
}
else        
{
    Write-Output "Could not backup files, file $($pathForBackup) already exists, please remove first" -ForegroundColor Red
    pause
    exit
}



# 0 selected: delete them
#  
# 
#
if($choice -eq 0 ){

    try{

            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersion #-ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersionInfo #-ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name ProductVersion #-ErrorAction SilentlyContinue
            Write-Host "Keys successfully removed" -ForegroundColor Green

    }catch{
        Write-Output "Error: " -BackgroundColor Red -ForegroundColor Black
        Write-Output $_.Exception.Message -ForegroundColor Red
    
    
    }


}
# 1 selected: Set TargetReleaseVersion to 0 and clear the other keys
elseif($choice -eq 1 ){

    try{

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersion -Value 0 -ErrorAction SilentlyContinue
        Write-Output "Key successfully reset" -ForegroundColor Green

    }catch{

        Write-Output "Could not reset keys " -BackgroundColor Red -ForegroundColor Black
        Write-Output $_.Exception.Message -ForegroundColor Red
        pause
        exit
    }


}else{
    Write-Output "Nothing selected! " -BackgroundColor Red -ForegroundColor Black
    pause
    exit
}
