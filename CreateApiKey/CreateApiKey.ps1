<# CREATE API KEY
AUTOR: patrick schmidt
DATE: 31.07.2015
VERSION: V1.0

DESC: Crates an api key for server-eye!

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
    $uri = New-Object "System.Uri" "https://api.server-eye.de/2/auth/key"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $data = "email=$email&password=$pass&name=$apiKeyName"
    $postbuffer = [System.Text.Encoding]::UTF8.GetBytes($data)
    $request.Method = "POST"
    $request.ContentType = "application/x-www-form-urlencoded"
    $request.ContentLength = $postbuffer.Length;

     $requestStream = $request.GetRequestStream()
     $requestStream.Write($postbuffer, 0, $postbuffer.Length)
     $requestStream.Flush()
     $requestStream.Close()

    [System.Net.HttpWebResponse] $webResponse = $request.GetResponse()
    $reader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
    $result = $reader.ReadToEnd()

    Write-Host -ForegroundColor Green "API Key was created successfully!"
    Write-Host "API Key Data: $result"  
}catch{
    Write-Host "I am sorry, but i could not get that api key for you :(. I tried my best. Would you please give this message to the guys who created me? Thanks!" -ForegroundColor Red
    $exData = $Error

    Write-Host "Message: $exData"
}