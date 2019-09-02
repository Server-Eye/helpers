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

    .EXAMPLE 
    Get-SECustomer -Filter "Systemmanager*" | Get-SEOCCConnector

    Customer         Name                 ConnectorID                          MachineName
    --------         ----                 -----------                          -----------
    Systemmanager IT kraemerit.de         e7ef5c26-7f76-4a51-94a7-0e5046a85d55 NB-RP-T460S
    Systemmanager IT kraemerit.de         e408d8fa-a4e1-46d5-9a11-a449e130e6d2 NB-STS
    Systemmanager IT lab.server-eye.local a3738817-4b84-4418-8629-ce2c11f13678 DC
    Systemmanager IT Roadshow AiO 2017    b933bac0-954c-4b4e-958b-06d05d20e8ea AIO-1248...
    Systemmanager IT WORKGROUP            918c8ec3-d879-46c2-81a6-6b5ed9156899 NUC-1309...

    .EXAMPLE
    Get-SEOCCConnector -ConnectorId "e7ef5c26-7f76-4a51-94a7-0e5046a85d55"

    Customer         Name         ConnectorID                          MachineName
    --------         ----         -----------                          -----------
    Systemmanager IT kraemerit.de e7ef5c26-7f76-4a51-94a7-0e5046a85d55 NB-RP-T460S
    
    .EXAMPLE
    Get-SECustomer -Filter "Systemmanager*" | Get-SEOCCConnector -Filter "lab*"

    Customer         Name                 ConnectorID                          MachineName
    --------         ----                 -----------                          -----------
    Systemmanager IT lab.server-eye.local a3738817-4b84-4418-8629-ce2c11f13678 DC

    .LINK 
    https://api.server-eye.de/docs/2/
    
#>
function Get-OCCConnector {
    [CmdletBinding(DefaultParameterSetName = "byCustomer")]
    Param(
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomer", Position = 0)]
        [string]$Filter,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "byCustomer")]
        $CustomerId,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "byOCCConnector")]
        $ConnectorId,
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomer")]
        [Parameter(Mandatory = $false, ParameterSetName = "byOCCConnector")]
        $AuthToken
    )

    Begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    
    Process {

        if ($customerID) {

            getOCCConnectorByCustomer -customerId $CustomerId -filter $Filter -auth $AuthToken

        }
        elseif ($ConnectorId) {

            Get-SEContainer -containerid $ConnectorId

        }
        else {
            Write-Error "Please provide a ConnectorId or a CustomerId."
        }

    }

    End {

    }
}

function getOCCConnectorByCustomer ($customerId, $filter, $auth) {

    $containers = Get-SeApiCustomerContainerList -AuthToken $auth -CId $customerId | Where-Object { $_.Subtype -eq 0 }

    foreach ($Connector in $containers) {
        if ((-not $filter) -or ($Connector.name -like $filter)) {
            Get-SEContainer -containerid $Connector.id
        }
    }
}