<#
    .SYNOPSIS
    Copy all agents of a template onto this container.

    .PARAMETER TemplateID
    The id of the template.

    .PARAMETER SensorhubID
    The id of the container.

    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Set-Template {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $AuthToken,
        [parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        $SensorhubID,
        [Parameter(Mandatory=$true,Position=0)]
        $TemplateID
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }

    Process {
        try{
            Set-SeApiTemplate -AuthToken $AuthToken -cId $SensorhubID -Tid $TemplateID -ErrorAction Stop -ErrorVariable x
        }
            Catch{
                if($x[0].ErrorRecord.ErrorDetails.Message -match ('"message":"container_not_found"')  ){
                    Write-host "Please check the SensorhubID, its not in den Database."
                }
                if ($x[0].ErrorRecord.ErrorDetails.Message -match ('"message":"unauthorized","requiredRole":["architect"]"')) {
                    Write-host "The User needs the Role Achritect to set the template."
                }
            }        
    }

    End {

    }
}
