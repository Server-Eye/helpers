<# CREATE API KEY
AUTOR: Mike Semlitsch
DATE: 03.06.2016
VERSION: V1.1
DESC: Creates an api key for server-eye!
#>

param(
    [string]$email,
	[string]$pass,
    [string]$apiKeyName

)


if( [string]::IsNullOrEmpty($apiKeyName)){
    $apiKeyName = "APIKeyForConcentrator"
}


Try
 {

    $url = "https://api.server-eye.de/2/auth/key";

    $body = @{
        email=$email
        password=$pass
        name=$apiKeyName
    }

    $response = (Invoke-RestMethod -Uri $url -Method Post -Body $body);


    Write-Host -ForegroundColor Green "API Key was created successfully!"
    Write-Host "API Key: "  $response.apiKey
}catch{
    Write-Host "I am sorry, but i could not get that api key for you :(. I tried my best. Would you please give this message to the guys who created me? Thanks!" -ForegroundColor Red
    $exData = $Error

    Write-Host "Message: $exData"
}