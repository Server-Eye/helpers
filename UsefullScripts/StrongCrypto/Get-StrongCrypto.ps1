    <#
        .SYNOPSIS
        Checks the registry if the strong crypto keys for TLS1.2 are set. 

        .DESCRIPTION
        Checks the registry if the strong crypto keys for TLS1.2 are set. 

        .EXAMPLE
        PS> Get-StrongCrypto.ps1
        
        .LINK
        You can find the origin script here: https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-tls-enforcement 
        More information: https://docs.microsoft.com/de-de/mem/configmgr/core/plan-design/security/enable-tls-1-2-client#update-and-configure-the-net-framework-to-support-tls-12

    #>


Function Get-StrongCryptoKey
{
    [CmdletBinding()]
    Param
    (
        # Registry Path
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $RegPath,

        # Registry Name
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $RegName
    )
    $regItem = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Ignore
    $output = "" | Select-Object Path,Name,Value
    $output.Path = $RegPath
    $output.Name = $RegName

    If ($null -eq $regItem)
    {
        $output.Value = "Not Found"
    }
    Else
    {
        $output.Value = $regItem.$RegName
    }
    $output
}

Write-Host "Checking the registry..."

$regSettings = @()
$regKey = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319'
$regSettings += Get-StrongCryptoKey $regKey 'SystemDefaultTlsVersions'
$regSettings += Get-StrongCryptoKey $regKey 'SchUseStrongCrypto'

$regKey = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319'
$regSettings += Get-StrongCryptoKey $regKey 'SystemDefaultTlsVersions'
$regSettings += Get-StrongCryptoKey $regKey 'SchUseStrongCrypto'

$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
$regSettings += Get-StrongCryptoKey $regKey 'Enabled'
$regSettings += Get-StrongCryptoKey $regKey 'DisabledByDefault'

$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
$regSettings += Get-StrongCryptoKey $regKey 'Enabled'
$regSettings += Get-StrongCryptoKey $regKey 'DisabledByDefault'

$regSettings