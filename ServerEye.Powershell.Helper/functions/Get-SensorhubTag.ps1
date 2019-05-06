 <#
    .SYNOPSIS
    Get a list of all Tags from a Sensorhub.

    .DESCRIPTION
    List a container's tags.

    .PARAMETER SensorhubId
    The id of the container.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

    .EXAMPLE 
    Get-SESensorhubtag -SensorhubId cea93445-1330-4598-8d8c-075baf3c3f09

    Sensorhub     : NB-RT-NEW
    SensorhubId   : cea93445-1330-4598-8d8c-075baf3c3f09
    OCC-Connector : kraemerit.de
    Customer      : Server-Eye Support
    Tag           : {workstation, RT, ThirdParty, Demo...}


    .EXAMPLE 
    Get-SECustomer -Filter "Server-Eye*"| Get-SESensorhub | Get-SESensorhubtag

    Sensorhub     : NB-RT-NEW
    SensorhubId   : cea93445-1330-4598-8d8c-075baf3c3f09
    OCC-Connector : kraemerit.de
    Customer      : Server-Eye Support
    Tag           : {workstation, RT, ThirdParty, Demo...}

    Sensorhub     : NBTW-Surface
    SensorhubId   : c8b8e041-f99d-4544-8375-a0f4fbee70c2
    OCC-Connector : landheim.server-eye.de
    Customer      : Server-Eye Support
    Tag           : {workstation, TestSensoren, ThirdParty, Demo...}

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Get-Sensorhubtag {
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
            $Tags = Get-SeApiContainerTagList -cid $SensorhubId -AuthToken $authtoken
            $sensorhub = Get-SESensorhub -SensorhubId $SensorhubId -AuthToken $AuthToken
        
                [PSCustomObject]@{
                    Sensorhub = $sensorhub.name
                    SensorhubId = $sensorhub.SensorhubId
                    'OCC-Connector' = $sensorhub.'OCC-Connector'
                    Customer = $sensorhub.customer
                    Tag = $tags.Name
                }
            
    }
}




