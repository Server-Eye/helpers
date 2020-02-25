 <# 
    .SYNOPSIS
    Executes an user defined action based on the condition of a given agent.

    .DESCRIPTION
    Creates a new session for interacting with the Server-Eye cloud. Then the state of an given agent will be received
    and if the agent is in an error state a defined action will be executed.

    .PARAMETER AuthToken 
    The neccessary api key required for the request. Can be created via the ServerEye Powershell helpers and the function New-SeApiApiKey
    
    .PARAMETER SensorId
    This neccessary agent ID, representing the agent you want to be monitored.You can find the ID in the settings panel of an agent (OCC)
#>

#Requires -Version 5.0
 
Param(
    [Parameter(Mandatory=$true)] 
    $AuthToken,

    [Parameter(Mandatory=$true)] 
    $SensorId
 )

Begin{
         
    $exitCode = -1
    $requirementsFullfilled = $false

    if( Get-Module -ListAvailable -Name ServerEye.PowerShell.Helper) {
     
        if( !(Get-Module -Name ServerEye.PowerShell.Helper) ){
            Import-Module -Name ServerEye.Powershell.Helper
        }
    
        Write-Host "Helpers found..Continue with script"
        $requirementsFullfilled=$true
    
    }else{
    
        try{
    
            Install-Module -Name ServerEye.Powershell.Helper -Scope CurrentUser -SkipPublisherCheck $true
            Write-Host "Helpers not found..installed module!"
            $requirementsFullfilled=$true
    
        }catch{
            $exitCode = -3
            Write-Error -Message "Helpers not found and could not be installed. Please refer to https://github.com/Server-Eye/helpers/tree/master/ServerEye.Powershell.Helper for more information" -ErrorId 3
            exit $exitCode
        }
    }

    $AuthToken = Test-SEAuth -AuthToken $AuthToken
}

Process {

    if($requirementsFullfilled){
        try{
            $sensorData = Get-SESensorState -AuthToken $apiKey -SensorId $SensorId
     
            if($sensorData.Error){
                Write-Host "Sensor state is ERROR..executing user defined option"
                 <# specify option you want to do! 
                     Examples are 
                     Stop-Service "Servicename"
                     Restart-Service "Servicename"
                     Start-Service "Servicename"
     
                     Stop-Process "processname"
                     Start-Process -FilePath "test.exe" -WorkingDirectory -C:\temp"
     
                     Restart-Computer
     
                     Anything you want to do
                 #>
     
                Restart-Service wmiApSrv
                $exitCode = 0
    
            }else{  
                $exitCode = 0
                Write-Host "Sensor state is OK"
            }
     
        }catch{ 
            Write-Error "Could not receive sensor state: $_."
            $exitCode = -4             
         }
     }
     
    exit $exitCode
 }