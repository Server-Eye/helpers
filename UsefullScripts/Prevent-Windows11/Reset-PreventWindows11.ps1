#
# Will backup registry entries and delete or reset them in the second step
#
#
#Requires -RunAsAdministrator
Write-Host "Will delete windows 11 prevent key in registry"

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
        Write-Host "Registry entries backupped to $($pathForBackup)" -ForegroundColor Green

    }catch{
        Write-Host "Could not backup files" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        pause
        exit
    }
}
else        
{
    Write-Host "Could not backup files, file $($pathForBackup) already exists, please remove first" -ForegroundColor Red
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
        Write-Host "Error: " -BackgroundColor Red -ForegroundColor Black
        Write-Host $_.Exception.Message -ForegroundColor Red
    
    
    }


}
# 1 selected: Set TargetReleaseVersion to 0 and clear the other keys
elseif($choice -eq 1 ){

    try{

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersion -Value 0 -ErrorAction SilentlyContinue
        Write-Host "Key successfully reset" -ForegroundColor Green

    }catch{

        Write-Host "Could not reset keys " -BackgroundColor Red -ForegroundColor Black
        Write-Host $_.Exception.Message -ForegroundColor Red
        pause
        exit
    }


}else{
    Write-Host "Nothing selected! " -BackgroundColor Red -ForegroundColor Black
    pause
    exit
}
