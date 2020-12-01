<#
    .SYNOPSIS
        Rename the SoftwareDistribution Folder

    .DESCRIPTION
        Renames the SoftwareDistribution Folder to fix some problem with Windows Updates

    .INPUTS
     None. You cannot pipe objects to this Script.

    .OUTPUTS
        System.String. This Script will Output success and error messages.
        
    .NOTES
        Author  : Server-Eye
        Version : 1.0
#>
[CmdletBinding()]
Param(

)

Begin {
    Write-Output "Script started"
    $ExitCode = 0   
    # 0 = everything is ok
}

Process {
    try {
        Write-Output "Doing lot's of work here"
        # do all work right here
        Write-Verbose "Checking if Windows Update Service is running"
        $wuauserv = Get-Service -ServiceName wuauserv
        if ($wuauserv.Status -eq "Running") {
            Write-Verbose "Stopping Windows Update Service"
            Stop-Service -ServiceName $wuauserv 
        }
        Write-Verbose "Renaming SoftwareDistribution Folder to SoftwareDistribution_old"
        Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "C:\Windows\SoftwareDistribution_old"
        Write-Verbose "Starting Windows Update Service"
        Start-Service -ServiceName $wuauserv

    }
    catch {
        Write-Output "Something went wrong"
        Write-Output $_ # This prints the actual error
        $ExitCode = 1 
        # if something goes wrong set the exitcode to something else then 0
        # this way we know that there was an error during execution
    }
}

End {
    Write-Output "Script ended"
    exit $ExitCode
}

