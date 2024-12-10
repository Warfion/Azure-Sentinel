# Get-MsSentinelTableRetention.ps1

## Description

The `Get-MsSentinelTableRetention.ps1` script retrieves the retention settings for tables in Microsoft Sentinel. This script is useful for managing and auditing table retention policies in your Sentinel environment.

## Prerequisites

- Azure PowerShell module
- Permissions to read Microsoft Sentinel table settings

## Parameters

- `-WorkspaceName` (Required): The name of the Log Analytics workspace.
- `-ResourceGroupName` (Required): The name of the resource group containing the Log Analytics workspace.
- `-SubscriptionId` (Required): The Azure subscription.

## Examples

### Example 1

```powershell
.\Get-MsSentinelTableRetention -Subscription 'MySubscriptionName' -WorkspaceName 'MyWorkspace' -TableName 'MyTableName'
```

This example retrieves the retention settings for a specific table in the specified Log Analytics workspace.

### Example 2

```powershell
.\Get-MsSentinelTableRetention -Subscription 'MySubscriptionName' -WorkspaceName 'MyWorkspace' -TableName 'MyTableName' -Verbose
```

This example retrieves the retention settings for a specific table in the specified Log Analytics workspace (in Verbose Mode)

## Output

The script outputs the retention settings for a specific table in the specified Log Analytics workspace. The output includes the table name, the retention period, the archive retention period  and the total retenteion.

## Notes

- Ensure you have the necessary permissions to access the Log Analytics workspace and read table settings.
- The script requires the Azure PowerShell module to be installed and configured.

## Author

Created by: Thomas Bruend
