# New-MsSentinelWatchlist
The "New-MsSentinelWatchlist.ps1" 📄 file is a PowerShell script designed to create a watchlist in Microsoft Sentinel based on a specific CSV - file. Here is a breakdown of its functionality:

***Purpose***: Create a CSV-based watchlists in Microsoft Sentinel.

***Dependencies***: 
- Requires Powershell 5.2 (or above).
- Requires the Az.Accounts module.

***Usage Example***: 

```New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -WatchlistName 'MyWatchlistName' -AliasName "MyAliasBame" -itemsSearchKey "MyWatchlistSearchKey" -csvFile "MyWatchlistImportFile.csv"```

```New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -WatchlistName 'MyWatchlistName' -AliasName "MyAliasBame" -itemsSearchKey "MyWatchlistSearchKey" -csvFile "MyWatchlistImportFile.csv" -Verbose```
