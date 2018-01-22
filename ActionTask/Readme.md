# Action Task

Executes an user defined action based on the state of a given sensor.

This script should be used as an automated windows task. It polls the state of a given sensor and executes a custom action based on the state of the sensor or other criteria.

## Configure script
The following parameters can be passed via command line or hardcoded into the script. They are both mandatory.

### AuthToken 
The api key required for the request. Can be created via the ServerEye Powershell helpers and the function New-SeApiApiKey

### SensorId
The sensor ID represents the sensor of which the state will be monitored. You can find the ID in the settings panel of a sensor in your OCC.

## Running the script as task
Follow [these instructions](https://social.technet.microsoft.com/wiki/contents/articles/38580.configure-to-run-a-powershell-script-into-task-scheduler.aspx) to learn how to configure a scheduled windows task and how to execute a powershell script as windows task.

## Which actions are possible?
Starting at line 62 of the script, you can program a custom action, which will be executed when the monitored agent switches it's state to ERROR.

In the script you can find examples for restarting services, processes, the system itself and anything else you want to do.