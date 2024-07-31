# Get-MsSentinelWatchlist
This script can be used to list all watchlists by name in Microsoft Sentinel through PowerShell + Microsoft Sentinel REST API.

## Functionality:
Establishes a connection to Azure.
Retrieves the specified Azure Log Analytics workspace.
Sends a REST request to list all watchlists in the specified workspace in Microsoft Sentinel.
Outputs the watchlists or an error message if the operation fails.

## Usage
The script has 1 required parameters.

### WorkspaceName
- The name of the Log Analytics workspace

## Result

<div style="text-align: right"><img src="https://github.com/Warfion/Sentinel/blob/main/Scripts/Watchlist/Get-MsSentinelWatchlist/Images/image_1.png"</div>

## Links:

https://learn.microsoft.com/en-us/rest/api/securityinsights/watchlists/list?view=rest-securityinsights-2024-03-01&tabs=HTTP

                                 
Created by: Thomas Bruend
