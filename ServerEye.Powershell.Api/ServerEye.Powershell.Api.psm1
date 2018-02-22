function Intern-DeleteJson($url, $session, $apiKey) {
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Delete -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Delete -WebSession $authtoken );
    }
}
function Intern-GetJson($url, $authtoken) {
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Get -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Get -WebSession $authtoken );
    }
}

function Intern-PostJson($url, $authtoken, $body) {
    $body = $body | Remove-Null | ConvertTo-Json
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -WebSession $authtoken );
    }
}

function Intern-PutJson ($url, $authtoken, $body) {
    $body = $body | Remove-Null | ConvertTo-Json
    if ($authtoken -is [string]) {
        return (Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -Headers @{"x-api-key"=$authtoken} );
    } else {
        return (Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -WebSession $authtoken );
    }
}

function Remove-Null {

    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        $obj
  )

  Process  {
    $result = @{}
    foreach ($key in $_.Keys) {
        if ($_[$key] -ne $null) {
            $result.Add($key, $_[$key])
        }
    }
    $result
  }
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

"$moduleRoot/functions/*.ps1" | Resolve-Path | ForEach-Object { . $_.ProviderPath }
