# Get-MsSentinelTableRetention.ps1

## Description

The `Get-MsSentinelTableRetention.ps1` script retrieves the retention settings for tables in Microsoft Sentinel. This script is useful for managing and auditing table retention policies in your Sentinel environment.

## Prerequisites

- Azure PowerShell module
- Permissions to read Microsoft Sentinel table settings

## Parameters

- `-WorkspaceName` (Required): The name of the Log Analytics workspace.
- `-ResourceGroupName` (Required): The name of the resource group containing the Log Analytics workspace.
- `-SubscriptionId` (Optional): The Azure subscription ID. If not provided, the default subscription will be used.

## Examples

### Example 1

```powershell
.\Get-MsSentinelTableRetention.ps1 -WorkspaceName "MyWorkspace" -ResourceGroupName "MyResourceGroup"
```

This example retrieves the retention settings for all tables in the specified Log Analytics workspace.

### Example 2

```powershell
.\Get-MsSentinelTableRetention.ps1 -WorkspaceName "MyWorkspace" -ResourceGroupName "MyResourceGroup" -SubscriptionId "00000000-0000-0000-0000-000000000000"
```

This example retrieves the retention settings for all tables in the specified Log Analytics workspace within the specified subscription.

## Output

The script outputs the retention settings for each table in the specified Log Analytics workspace. The output includes the table name, retention period, and other relevant details.

## Notes

- Ensure you have the necessary permissions to access the Log Analytics workspace and read table settings.
- The script requires the Azure PowerShell module to be installed and configured.

## Author

Thomas Brndl

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
