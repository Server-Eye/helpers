 <#
    .SYNOPSIS
    Get a list of all OCC-Connector for the given customer. 

    .PARAMETER Filter
    Filter the list to show only matching OCC-Connector. OCC-Connector are filterd based on the name of the OCC-Connector.

    .PARAMETER CustomerId
    The customer id for which the OCC-Connector will be displayed.

    .PARAMETER ConnectorID
    The OCC-Connector with this ID will be displayed.
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.
    
#>
function Get-OCCConnector {
    [CmdletBinding(DefaultParameterSetName="byCustomer")]
    Param(
        [Parameter(Mandatory=$false,ParameterSetName="byCustomer",Position=0)]
        [string]$Filter,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="byCustomer")]
        $CustomerId,
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="bySensorhub")]
        $ConnectorId,
        [Parameter(Mandatory=$false,ParameterSetName="byCustomer")]
        [Parameter(Mandatory=$false,ParameterSetName="bySensorhub")]
        $AuthToken
    )

    Begin{
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {

    if($customerID){
    getOCCConnectorByCustomer -customerId $CustomerId -filter $Filter -AuthToken $AuthToken
    }elseif($ConnectorId){
    getOCCConnectorById -ConnectorId $ConnectorId -auth $AuthToken
    }

    }

    End {

    }
}

function getOCCConnectorById($ConnectorId, $auth) {
    $connector = Get-SeApiContainer -CId $ConnectorId -AuthToken $authtoken
    $customer = Get-SECustomer -customerId $connector.customerId

    [PSCustomObject]@{
        Customer = $customer.name
        Name = $connector.name
        ConnectorID = $connector.cId
        MachineName = $connector.machineName
    }
}
function getOCCConnectorByCustomer ($customerId, $filter, $authtoken) {
$containers = Get-SeApiCustomerContainerList -AuthToken $authtoken -CId $customerId
    foreach ($Connector in $containers) {
        if ($Connector.subtype -eq "0") {
            if ((-not $filter) -or ($Connector.name -like $filter)) {
                getConnectorById -ConnectorId $Connector.id -auth $authtoken
            }
        }
    }
}