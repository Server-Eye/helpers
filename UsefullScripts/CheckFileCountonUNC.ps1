<#
    .SYNOPSIS
    Checks Files in UNC PAth
    
    .DESCRIPTION
    Checks if File Count is 0 in the UNCPath<
    
    .PARAMETER UNCPath
    UNC Path, example "\\192.168.1.0"

    .PARAMETER credentialXML
    If Credential XML should be used set this to 1
    Create an XMl with. GET-CREDENTIAL | EXPORT-CLIXML C:\Scriptfolder\NAS.xml

    .PARAMETER PathToXML
    Path to Credential XML

    .PARAMETER credentialManager
    If Credential Manager should be used set this to 1

    .PARAMETER Name
    Name of the Credential form the Manager to be used

#>
<#
<version>2</version>
<description>Checks if File Count is 0 in the UNCPath</description>
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $UNCPath,

    [Parameter(Mandatory = $false)]
    [int]
    [ValidateSet(0, 1)]
    $credentialXML = 0 ,

    [Parameter(Mandatory = $false)]
    [string]
    $PathToXML,

    [Parameter(Mandatory = $false)]
    [int]
    [ValidateSet(0, 1)]
    $credentialManager = 0,

    [Parameter(Mandatory = $false)]
    [string]
    $Name
)
#region CreateStaticVariables
[pscredential]$cred
#endregion CreateStaticVariables


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

#region LoadLogin
#Create an XMl with. GET-CREDENTIAL | EXPORT-CLIXML C:\Scriptfolder\Cred.xml
if ($credentialXML -eq 1) {
    try {
        # Check if XML file is present
        $cred = Import-Clixml $PathToXML 
    }
    catch {
        $msg.AppendLine("Check Path for XML: $_")
        $exitCode = 5
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 

        #api adding 
        $api.setMessage($msg)  

        #write our api stuff to the console. 
        Write-Host $api.toJson() 
        exit $exitCode
    }
 
}
if ($credentialManager -eq 1) {
    try {
        # Check if Credentials are present
        $cred = Get-StoredCredential -Target $credentialName   
    }
    catch {
        $msg.AppendLine("Check stored Credential Name: $_")
        $exitCode = 5
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
                
        #api adding 
        $api.setMessage($msg)  

        #write our api stuff to the console. 
        Write-Host $api.toJson() 
        exit $exitCode
    }
      
}
#endregion LoadLogin

#region DoStuff
#Connect Drives
$drive = New-PSDrive -Name "SE-Drive" -PSProvider FileSystem -Root $UNCPath -Credential $cred

#Check if no Drive was connectet.
if ($null -eq $drive) {
    $msg.AppendLine("Kein Laufwerk gefunden oder Benutzerdaten falsch")
    $exitCode = 4
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 

}
#Check if file is on Drive
else {
    $File = (Get-ChildItem -Path $drive.Root)
    #Check if file is older than Hours Parameter
    if (!$File) {
        $msg.AppendLine("Keine Datei im Ordner $UNCPath")
        $exitCode = 0
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        $api.setMeasurementValue("File Count",[double]0)
        $api.setChartErrorLine(1)
        Remove-PSDrive "SE-Drive"
    }
    else {
        $msg.AppendLine("Datei im im Ordner $UNCPath gefunden, Anzahl: $($file.count)")
        $exitCode = 4
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR)
        $api.setMeasurementValue("File Count",[double]$file.count)
        $api.setChartErrorLine(1)
        Remove-PSDrive "SE-Drive"
    }
}

#endregion DoStuff

#api adding 
$api.setMessage($msg)  
#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode