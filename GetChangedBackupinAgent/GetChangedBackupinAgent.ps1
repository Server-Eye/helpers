$aid = "321e0ec2-526e-48a9-bfa3-2c2d1ed6a911"
$AuthToken = "84274380-cfcc-4859-a6da-d5bf12e6faa8"
Get-SeApiAgentSettingList -AId $aid -AuthToken $AuthToken
Get-SeApiAgentRemoteSetting -AId $aid -AuthToken $AuthToken -Key "selectedJobs" 
