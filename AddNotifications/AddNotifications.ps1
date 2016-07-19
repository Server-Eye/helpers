<# Sensors Of Customers
AUTOR: Mike Semlitsch
DATE: 19.07.2016
VERSION: V1.0
DESC: Adds a notification to all agents of the specified customer. ATTENTION: Multiple executions of this script add multiple notifications to each agent.
#>

param(
    [string]$apiKey,
    [string]$customerId,
    [string]$userId    
)




############################################
#Get Visible Customers
############################################
function getVisibleCustomers() {
    $url = "https://api.server-eye.de/2/me/nodes?apiKey=$apiKey&filter=customer";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Visible Customers
############################################






############################################
#Get Containers Of Customer
############################################
function getContainersOfCustomer($cId) {
    $url = "https://api.server-eye.de/2/customer/$cId/containers?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Containers Of Customer
############################################


############################################
#Get Agents Of Container
############################################
function getAgentsOfContainer($cId) {
    $url = "https://api.server-eye.de/2/container/$cId/agents?apiKey=$apiKey";

    $jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);

    return $jsonResponse;


}

############################################
#END Get Agents Of Container
############################################

############################################
#Add Notification 
############################################

function addNotification($aId, $uId) {
    
    $url = "https://api.server-eye.de/2/agent/$aId/notification?apiKey=$apiKey";
    #$url = "https://api.server-eye.de/2/agent/$aId/notification?apiKey=$apiKey&aId=$aId&userId=$uId";

    #Write-Host $url

    $body = @{
        #aId=$aId
        userId=$uId
    }

    $response = (Invoke-RestMethod -Uri $url -Method Post -Body $body);
    #$jsonResponse = (Invoke-RestMethod -Uri $url -Method Get);
}
############################################
#END Add Notification 
############################################




$customerFound = $false;

$arrayCustomers = getVisibleCustomers;

:outer foreach($customer in $arrayCustomers)
{

    $custId = $customer.id;
    
    if ($customerId -eq $custId) {

        $customerFound = $true;

        Write-Host "customer name: " $customer.name;

    

        $arrayContainers = getContainersOfCustomer($custId);

        :inner1 foreach($container in $arrayContainers)
        {

            #Write-Host "container ID: " $container.id " " $container.subtype;

            if ($container.subtype -eq "0") {
            
                Write-Host "OCC-Connector: " $container.name ;

                #Write-Host "container ID: " $container.id; 
                #Write-Host "container Name: " $container.name;


                :inner2 foreach($sensorhub in $arrayContainers)
                {

                
                
                    if ( $sensorhub.subtype -eq "2" -And $sensorhub.parentId -eq $container.id) {

                        Write-Host "   Sensorhub: " $sensorhub.name;

                        $arrayAgents = getAgentsOfContainer($sensorhub.id);

            
                        :inner3 foreach($agent in $arrayAgents)
                        {

                            #break inner3;
                
                            #Write-Host "agent subtype: " $agent.subtype;
                             Write-Host "      SensorName: " $agent.name;
                            #showAgentState $agent.id $container.name;

                            addNotification $agent.id $userId
                        

                        #    break outer;
                        }

                    }
                }



        
            }


        }


    }
}

if (!$customerFound) {
    Write-Host "Customer NOT found!";
}
