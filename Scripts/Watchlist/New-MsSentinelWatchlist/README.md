# New-MsSentinelWatchlist
The "New-MsSentinelWatchlist.ps1" 📄 file is a PowerShell script designed to create a watchlist in Microsoft Sentinel based on a specific CSV - file. Here is a breakdown of its functionality:

***Purpose***: Create a CSV-based watchlists in Microsoft Sentinel.

***Dependencies***: 
- Requires Powershell 5.2 (or above).
- Requires the Az.Accounts module.

***Usage Example***: 

```New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -WatchlistName 'MyWatchlistName' -AliasName "MyAliasBame" -itemsSearchKey "MyWatchlistSearchKey" -csvFile "MyWatchlistImportFile.csv"```

```New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -WatchlistName 'MyWatchlistName' -AliasName "MyAliasBame" -itemsSearchKey "MyWatchlistSearchKey" -csvFile "MyWatchlistImportFile.csv" -Verbose```

## Parameters
- WorkspaceName (string): The name of the Azure workspace (mandatory).
- WatchlistName (string): The name of the watchlist to create (mandatory).
- AliasName (string): The alias name for the watchlist (mandatory).
- itemsSearchKey (string): The key for searching items in the watchlist (mandatory).
- csvFile ([System.IO.FileInfo]): The CSV file containing watchlist items (mandatory).
- 
## Functionality
- ***Azure Connection***:
    - Retrieves the current Azure context. If not connected, it prompts the user to connect using device authentication.
    - Outputs the subscription ID to confirm the connection.
 
- ***Workspace Retrieval***:
    - Retrieves the specified Azure workspace.
    - Constructs the API path for accessing the watchlist if the workspace exists.


## Result
<img src="https://github.com/Warfion/Sentinel/blob/main/Scripts/Watchlist/New-MsSentinelWatchlist/image/image.png">

## Links:
https://learn.microsoft.com/en-us/rest/api/securityinsights/watchlists/create-or-update?view=rest-securityinsights-2024-03-01&tabs=HTTP
                             
Created by: Thomas Bruend
