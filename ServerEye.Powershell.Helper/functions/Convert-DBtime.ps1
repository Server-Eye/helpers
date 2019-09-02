<# 
.SYNOPSIS
Convert a Date into a Human readable form.

.DESCRIPTION
Convert a Server-Eye Database Date into a Human readable form.

.PARAMETER Date 
The date to convert, format of the Date 2019-09-02T14:59:49.000Z.

.EXAMPLE 
Convert-SEDBTime -Date $Date

#>

function Convert-DBTime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $date
    )
    
    begin {
        $culture = [Globalization.cultureinfo]::GetCultureInfo("de-DE")
        $format = "yyyy-MM-ddHH:mm:ss"
        Function Get-LocalTime($UTC)
        {
        $strCurrentTimeZone = (Get-TimeZone).id
        $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
        $LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTC, $TZ)
        Return $LocalTime
        }
    }
    
    process {
        $realdate = ($date -replace ("[a-zA-Z]", "")).Remove(18)
        $utc = [datetime]::ParseExact($realdate, $format, $culture)
        $time = Get-LocalTime $utc
        Write-Output $time
    }
    
    end {
    }
}