<#
    .SYNOPSIS
    a short description

    .DESCRIPTION
    this description can be much longer and contains more details

    .PARAMETER First
    this is the first parameter
    it can take a string

    .PARAMETER Second
    this is the second parameter
    it can take an integer number

    .EXAMPLE
    thisScript.ps1 -First Test
    passes Test to $First

    .EXAMPLE
    thisScript.ps1 -First Test -Second 17
    passes Test to $First
    passes 17 to $Second

    .NOTES
    Author  : Server-Eye
    Version : 1.0

    <version>2</version> <<< THIS IS REQUIRED for using the Server-Eye powershell API!!!
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)] # this parameter has to be used
    [String]
    $First, # you can name the parameters anything you want

    [Int]
    $Second
)

Begin {

    #LOAD PowerShellAPI and dependencies from the correct local path. 
    [System.IO.DirectoryInfo]$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent | Split-Path -Parent
    $pathToApi = Join-path -Path $scriptDir -childpath "ServerEye.PowerShell.API.dll"
    $pathToJson = Join-path -Path $scriptDir -childpath "Newtonsoft.Json.dll"
    [Reflection.Assembly]::LoadFrom($pathToApi) 
    [Reflection.Assembly]::LoadFrom($pathToJson) 

    #init api variables.., api is needed for creating the sensor data, msg is used to capture all relevant output later used in the sensor message.
    $api = new-Object ServerEye.PowerShell.API.PowerShellAPI
    $msg = new-object System.Text.StringBuilder

    $msg.AppendLine("Script started")
    $ExitCode = 0   
    # 0 = everything is ok
}

Process {
    try{
        $msg.AppendLine("Doing lot's of work here")
        # do all work right here

        $api.setChartErrorLine(80) #set red error line in OCC chart, for example 80%
        $api.setMeasurementValue("LoadData","22.2")#measurement that will be added with name and DOUBLE value to the OCC chart

    } catch {
        $msg.AppendLine("Something went wrong")
        $msg.AppendLine($_)# This prints the actual error
        $ExitCode = 1 
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}

End {
    $msg.AppendLine("Script ended")
    $api.setMessage($msg) #sets the script output shown in the OCC
    Write-Host $api.toJson() #this generates an output for our powershell interface to capture all relevant data
    exit $ExitCode
}