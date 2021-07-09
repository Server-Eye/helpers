<#
    .SYNOPSIS
        Remove Tempfiles
 
    .DESCRIPTION
        Remove all Tempfiles from this Path “C:\Windows\Temp\*”, “C:\Windows\Prefetch\*”, “C:\Documents and Settings\*\Local Settings\temp\*”, “C:\Users\*\Appdata\Local\Temp\*”
 
    .EXAMPLE
        Remove-Tempfile.ps1
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0
#>
[CmdletBinding()]
Param(
    $tempfolders = @( "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*")
)

Begin {
    Write-Host "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
}
 
Process {
    Write-Host "Doing lot's of work here"
    Remove-Item $tempfolders -force -recurse -ErrorAction SilentlyContinue

}
 
End {
    Write-Host "Script ended"
    exit $ExitCode
}