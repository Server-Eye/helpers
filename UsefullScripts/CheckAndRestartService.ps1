<#
.SYNOPSIS
  Name: CheckAndRestartService.ps1
  The purpose of this script is to restart a Service if needed in combination with the Server-Eye PowerShell Sensor

#>

<#
<version>2</version>
<description>Checks the given Services an will restart them when necessary</description>
#>

Param ( 
[Parameter()] 
[String[]]$ServiceNames 
)

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

#Check if Parameter is given
if(!$ServiceNames){
    $msg.AppendLine("Please fill out all params needed for this script.")
    $exitCode = 5
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
}else {
    try {
        #Split Servicename on Comma
        $ServiceNames = $ServiceNames.Split(",")
        #Get all given Services
        $Services = Get-Service -Name $ServiceNames -ErrorAction Stop 
        #Check if all Services are running
        $ServicesToStart =  $Services | Where-Object {($_.Status -eq "Stopped")}
        #Check if no Service is stopped
        if (!$ServicesToStart) {
            $msg.AppendLine("No Service need a Restart.")
            $exitCode = 0
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
        }else {
            #Foreach Service try to Start it
            foreach($service in $ServicesToStart){
                try {
                    #If Start is possible all is well
                    Restart-Service -Name $service.Name -ErrorAction Stop
                    $msg.AppendLine($service.Name +" was Restarted")
                    $exitCode = 1
                    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK) 
                }
                catch {
                    #If start is not possible call Exeption
                    $msg.AppendLine("$_")
                    $exitCode = 6
                    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
                }
            }
        }

    }
    catch {
        #Services can not be checked call Exeption
        $msg.AppendLine("$_")
        $exitCode = 7
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR) 
    }    
}
#api adding 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode