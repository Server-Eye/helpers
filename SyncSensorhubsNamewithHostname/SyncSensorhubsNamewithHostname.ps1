<# 
    .SYNOPSIS
    Sets the Sensorhubname to the Hostname

    .DESCRIPTION
    Compares the Sensorhubname with the Hostname, if they dont match the Sensorhubname will be changed.

    .PARAMETER Apikey 
    The api-Key of the user. ATTENTION only nessesary if no Server-Eye Session exists in den Powershell

    .PARAMETER SensorhubId
    The id of the sensorhub.
    
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
    $SensorhubId,
    [Parameter(Mandatory = $false)]
    $AuthToken

)

function Set-SensorhubNameLikeHostname {
    [CmdletBinding(DefaultParameterSetName='byFilter')]
    Param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorhubId,
        [Parameter(Mandatory=$false)]
        $AuthToken
    )
    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        $sensorhub = Get-SESensorhub -SensorhubId $SensorhubId -AuthToken $AuthToken
        if ($sensorhub.Hostname -ne $sensorhub.Name) {
            Set-SeApiContainer -cid $Sensorhub.Sensorhubid -AuthToken $AuthToken -Name $sensorhub.Hostname | Out-Null
            Write-host $sensorhub.Name "changed to " $sensorhub.Hostname
        }else {
            Write-Host "no changes were made."
        }
            
    }
}

Set-SensorhubNameLikeHostname -SensorhubId $SensorhubId -AuthToken $AuthToken