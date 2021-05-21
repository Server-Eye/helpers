<#
    .SYNOPSIS
    Create Vault
    
    .DESCRIPTION
    Create a new Server-Eye Password Vault

    .PARAMETER showPassword
    Is it possible to show the Password in plain text

    .PARAMETER authenticationMethod
    Which Method should be use to encrypt the Vault

    .PARAMETER showPassword
    Is it possible to show the Password in plain text

    .PARAMETER name
    Name of the Vault

    .PARAMETER description
    description of the Vault

    .PARAMETER userId
    ID of the User the Vault will be crated for, can not be used with customerId or distributorId

    .PARAMETER customerId
    ID of the Customer the Vault will be crated for, can not be used with userId or distributorId

    .PARAMETER distributorId
    ID of the distributor the Vault will be crated for, can not be used with userId or customerId

    .PARAMETER PathToSaveKey
    Path where the RestoreKey for the Vault should be stored
    
    .PARAMETER AuthToken
    Either a session or an API key. If no AuthToken is provided the global Server-Eye session will be used if available.

#>
function New-Vault {
    [CmdletBinding(DefaultParameterSetName = "byUserID")]
    Param ( 
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        [bool]$showPassword = $false,
        [Parameter(Mandatory = $true, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $true, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $true, ParameterSetName = "byDistributorId")]
        [ValidateSet("PASSWORD", "KEY_FILE")]
        $authenticationMethod,
        [Parameter(Mandatory = $true, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $true, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $true, ParameterSetName = "byDistributorId")]
        $name,
        [Parameter(Mandatory = $true, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $true, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $true, ParameterSetName = "byDistributorId")]
        $description,
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        $userId,
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        $customerId,
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        $distributorId,
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        $PathToSaveKey,
        [Parameter(Mandatory = $false, ParameterSetName = "byUserID")]
        [Parameter(Mandatory = $false, ParameterSetName = "byCustomerId")]
        [Parameter(Mandatory = $false, ParameterSetName = "byDistributorId")]
        [alias("ApiKey", "Session")]
        $AuthToken
    )

    begin {
        $AuthToken = Test-SEAuth -AuthToken $AuthToken
    }
    Process {
        $reqBody = @{  
            'showPassword'         = $showPassword
            'authenticationMethod' = $authenticationMethod
            'name'                 = $name
            'description'          = $description
            'userId'               = $userId
            'customerId'           = $customerId
            'distributorId'        = $distributorId

        }

        $url = "https://api-ms.server-eye.de/3/vault"

        $Result = Intern-PostJson -url $url -body $reqBody -authtoken $AuthToken

        $TypeName = if ($Result.distributorId) { 
            "distributor" 
        }
        elseif ($Result.customerId) { 
            "customer" 
        }
        elseif ($result.userId) { 
            "User" 
        }
        $ID = if ($Result.distributorId) { 
            $Result.distributorId 
        }
        elseif ($Result.customerId) {
            $Result.customerId 
        }
        elseif ($result.userId) { 
            $result.userId 
        }

        $type = [PSCustomObject]@{
            TypeName = $TypeName
            ID       = $ID
        }

        [PSCustomObject]@{
            Name                 = $result.Name
            VaultID              = $result.ID
            Description          = $Result.description
            AuthenticationMethod = $Result.authenticationMethod
            Users                = $Result.users
            Entries              = $Result.entries
            Type                 = $type
            ShowPassword         = $Result.showPassword
            restoreKey           = $Result.restoreKey
        }
        try {
            Out-File -FilePath "$PathToSaveKey\$name-Restorekey.txt"  -Encoding utf8 -InputObject $Result.restoreKey 
        }
        catch {
            Write-Error -Message "Something went wrong: $_"
        }
            

    }

    End {

    }



}
