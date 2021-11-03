<#
    .SYNOPSIS
    Get a Vault
    
    .DESCRIPTION
    Get a specific Vault

    .PARAMETER VaultID
    ID of the Vault

    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function Get-ScheduledTask {
    [OutputType("ServerEye.Get-ScheduledTask")]
    [CmdletBinding(DefaultParameterSetName = "byCustomer")]
    Param ( 
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "byCustomer")]
        $customerid,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "byContainer")]
        $ContainerID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "byID")]
        $taskId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "byReference")]
        $referenceId,
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomer")]
        [Parameter(Mandatory = $false, ParameterSetName = "byContainer")]
        [Parameter(Mandatory = $false, ParameterSetName = "byID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byReference")]
        [alias("ApiKey", "Session")]
        $AuthToken

    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
        $urlbase = "https://api-ms.server-eye.de/3"
        if (!(Get-Typedata "ServerEye.ScheduledTask")) {
            $SECustomerTypeData = @{
                TypeName                  = "ServerEye.ScheduledTask"
                DefaultDisplayPropertySet = "Name", "description", "category", "taskId","ContainerID","customerid","referenceId","triggers"
            }
            Update-TypeData @SECustomerTypeData
        }
    }
    Process {
        if ($customerid) {
            $url = "$urlbase/scheduled/task/customer/$customerid"
        }
        elseif ($ContainerID) {
            $url = "$urlbase/scheduled/task/container/$ContainerID"
        }
        elseif ($taskId) {
            $url = "$urlbase/scheduled/task/$taskId"
        }
        elseif ($referenceId) {
            $url = "$urlbase/scheduled/task/reference/$referenceId"
        }
        else {
            Write-Error -Message "Unsupported input"
        }


        $result = Intern-GetJson -url $url -authtoken $AuthToken

        foreach ($Task in $result) {
            [PSCustomObject]@{
                PSTypeName  = "ServerEye.ScheduledTask"
                name        = $Task.name
                arguments   = $Task.arguments
                containerId = $Task.containerId
                customerId  = $Task.customerId
                description = $Task.description
                history     = $Task.history    
                referenceId = $Task.referenceId
                scriptData  = $Task.scriptData
                taskId      = $Task.taskId  
                triggers    = $Task.triggers
                xmlTask     = $Task.xmlTask
            }
        }


    }

    End {

    }
}