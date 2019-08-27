<# 
    .SYNOPSIS
    This script will check if the given Certifikat is valid.

    .DESCRIPTION
    This script will check if the given Certifikat is valid.

    .PARAMETER Thumbprint 
    The Thumbprint of the Certifikat.

    .PARAMETER days 
    Days until the Certifikat should expire.
#>

[CmdletBinding()]
Param(
    [Parameter()]
    $Thumbprint,
    [Parameter()]
    $days

)

#load the libraries from the Server Eye directory
$scriptDir = $MyInvocation.MyCommand.Definition |Split-Path -Parent |Split-Path -Parent

$pathToApi = $scriptDir + "\ServerEye.PowerShell.API.dll"
$pathToJson = $scriptDir + "\Newtonsoft.Json.dll"
[Reflection.Assembly]::LoadFrom($pathToApi)
[Reflection.Assembly]::LoadFrom($pathToJson)

$api = new-Object ServerEye.PowerShell.API.PowerShellAPI
$msg = new-object System.Text.StringBuilder

$exitCode = -1

if( [string]::IsNullOrEmpty($Thumbprint) -or !$days){
    $msg.AppendLine("Please fill out all params needed for this script")
    $exitCode = 5
    $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR)
}else {
    $Thumbprint = $Thumbprint.ToUpper()
    $certificats = Get-ChildItem -Path Cert:\ -Recurse

    $CertToCheck = $certificats | Where-Object -Property PSChildName -EQ -Value $Thumbprint | Select-Object -Unique

    if ($CertToCheck -eq $null){
        $exitCode = 2
        $msg.AppendLine("Error: No Certifikat with name $thumbprint was found!" )
        $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR)
    }else{
        $time = New-TimeSpan -End $CertToCheck.notAfter
        if ( $time.days -le $days) {
            $msg.AppendLine("Error: Certifikat "+$CertToCheck.Subject+" will expire in "+$time.days + " days." )
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::ERROR)
            $Exitcode = 3
        }else {
            $msg.AppendLine("OK: Certifikat "+$CertToCheck.Subject+" is valid." )
            $api.setStatus([ServerEye.PowerShell.API.PowerShellStatus]::OK)
            $Exitcode = 0
        }

    }

}
<#api adding #> 
$api.setMessage($msg)  

#write our api stuff to the console. 
Write-Host $api.toJson() 
exit $exitCode