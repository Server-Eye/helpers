#Requires -Module ServerEye.PowerShell.Helper
#Requires -Module ImportExcel

[CmdletBinding(DefaultParameterSetName="ADCheck")]
Param(
    [Parameter(ValueFromPipeline = $true)]
    [alias("ApiKey", "Session")]
    $AuthToken,
    [Parameter(Mandatory = $True)]
    $CustomerID,
    [Parameter(Mandatory = $true,ParameterSetName="ADCheck")]
    [Switch]$ADCheck,
    [Parameter(Mandatory = $true,ParameterSetName="SECheck")]
    [Switch]$SECheck
)

$AuthToken = Test-SEAuth -AuthToken $AuthToken

$diff = Get-ADComputer -Filter * -Property *
$reftmp = Get-SeApiMyNodesList -filter container -AuthToken $AuthToken | Where-Object {$_.customerId -eq $CustomerID -and $_.Subtype -eq 2}

$ref = $reftmp| Select-Object –unique -Property Name

$double = Compare-object –referenceobject $ref –differenceobject $reftmp -Property Name

$comp = Compare-Object -ReferenceObject $ref -DifferenceObject $diff -Property Name

if ($double) {
    Write-Output "Duplicate Systems in Server-Eye:"
(($double | Where-Object Sideindicator -eq "=>").Name)
}

if ($SECheck.IsPresent -eq $true){
Write-Output "`nFollowing Systems are in the Active Directory but are not Installed with Server-Eye:"
(($comp | Where-Object Sideindicator -eq "=>").Name)
}

if ($ADCheck.IsPresent -eq $true){
Write-Output "`nFollowing Systems are installed with Server-Eye but not found in the Active Directory:"
(($comp | Where-Object Sideindicator -eq "<=").Name)
}