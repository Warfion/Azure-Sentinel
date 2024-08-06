Remove-MsSentinelWatchlist
The "Remove-MsSentinelWatchlist.ps1" 📄 file is a PowerShell script designed to delete a watchlist in Microsoft Sentinel. Here is a breakdown of its functionality:

Purpose: Deletes a watchlist in Microsoft Sentinel.

Dependencies:

Requires PowerShell 5.2 (or above).
Requires the Az.Accounts module.
Usage Example:

Remove-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -AliasName 'MyWatchlistAliasName'

Remove-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -AliasName 'MyWatchlistAliasName' -Verbose
Parameters
WorkspaceName (string): The name of the Azure workspace (mandatory).
AliasName (string): The alias name of the watchlist to delete (mandatory).
Functionality
Azure Connection:

Retrieves the current Azure context. If not connected, it prompts the user to connect using device authentication.
Outputs the subscription ID to confirm the connection.
Workspace Retrieval:

Retrieves the specified Azure workspace.
Constructs the API path for accessing the watchlist if the workspace exists.
Watchlist Deletion:

Constructs the API path for deleting the watchlist.
Uses Invoke-AzRestMethod to delete the watchlist via the constructed API path.
Provides feedback on the watchlist deletion status.
## Result
- Successfully deletes a watchlist and provides a confirmation message.
- Displays any errors encountered during the process.

## Links:

Created by: Thomas Bruend
