$releaseCSV = Invoke-WebRequest -Uri "https://server-eye.saar-storage.de/s/IhifETEiFQZcHFK/download" | ConvertFrom-Csv -Delimiter ";"

$Sensorhub = Get-SECustomer -Filter "wortmann*" | Get-SESensorhub -Filter "Win*"

$Sensorhub.OsVersion