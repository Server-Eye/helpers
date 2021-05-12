<#
    .SYNOPSIS
    Get Vault
    
    .DESCRIPTION
     Setzt die Einstellungen für die Verzögerung und die Installation Tage im Smart Updates

    .PARAMETER CustomerId
    ID des Kunden bei dem die Einstellungen geändert werden sollen.

    .PARAMETER Filter
    Name der Gruppe die geändert werden soll
    
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
        Function Get-FileName($initialDirectory) {  
            [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null
            $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
            $OpenFileDialog.initialDirectory = $initialDirectory
            $OpenFileDialog.filter = "txt files (*.txt)|*.txt"
            $OpenFileDialog.ShowDialog() | Out-Null
            $OpenFileDialog.filename
        }    

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

        [PSCustomObject]@{
            Name = $result.Name
            VaultID = $result.ID
            Description = $Result.description
            AuthenticationMethod = $Result.authenticationMethod
            Users = $Result.users
            Entries = $Result.entries
            Type = [PSCustomObject]@{
                TypeName = if($Result.distributorId){"distributor"}elseif($Result.customerId) {"customer"}elseif ($result.userId) {"User"}
                ID = if($Result.distributorId){$Result.distributorId}elseif($Result.customerId) {$Result.customerId}elseif ($result.userId) {$result.userId}
            }
            ShowPassword = $Result.showPassword
            restoreKey = $Result.restoreKey
        }
        if ($PathToSaveKey) {
            Out-File -FilePath "$PathToSaveKey\$name-Restorekey.txt"  -Encoding utf8 -InputObject $Result.restoreKey
        }else {
            Write-Output "Please Save the Restore Key"
            $PathToSaveKey = Get-FileName -initialDirectory $PSScriptRoot
            Out-File -FilePath $PathToSaveKey -Encoding utf8 -InputObject $Result.restoreKey
        }

    }

    End {

    }



}
