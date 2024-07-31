<#
.SYNOPSIS
    Helper function that lists all watchlists in Microsoft Sentinel
.DESCRIPTION
    This helper function lists all watchlists in Microsoft Sentinel
.NOTES
    Needed Modules Az.Resources - Install-Module Az.Resources -AllowClobber -Force
.EXAMPLE
    
Get-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -Context 'C:\users\securehats\highValueAsset.json'

#>

[CmdletBinding()]
[Alias()]
Param
(
    # Graph access token
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string]$WorkspaceName
)

$context = Get-AzContext

if (!$context) {
    Connect-AzAccount -UseDeviceAuthentication
    $context = Get-AzContext
}

$_context = @{
    'Account'         = $($context.Account)
    'Subscription Id' = $context.Subscription
    'Tenant'          = $context.Tenant
}
Clear-Host
Write-Output "Connected to Azure with subscriptionId: $($context.Subscription)`n"

$workspace = Get-AzResource -Name $WorkspaceName -ResourceType 'Microsoft.OperationalInsights/workspaces'

if ($null -ne $workspace) {
    $apiVersion = '?api-version=2024-03-01'
    $baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
    $watchlistpath = '{0}/watchlists/{1}{2}' -f $baseUri, $AliasName, $apiVersion
}
else {
    Write-Output "[-] Unable to retrieve log Analytics workspace"
}

Write-Verbose ($_context | ConvertTo-Json)

try {
    $webData = Invoke-AzRestMethod -Path $watchlistpath -Method GET
    if ($webData.StatusCode -eq 200) {
        $webData = Invoke-AzRestMethod -Path $watchlistpath -Method GET
        $webData = ($webData.Content | ConvertFrom-Json).value.name
        
        $watchlists = [System.Collections.Generic.List[object]]::new()
        
        foreach ($data in $webData){
            $watchlist = [PSCustomObject]@{
                
                watchlist = $data
            }
        $watchlists.Add($watchlist)
        }
        
        $watchlists
    }
    else {
        Write-Output $webData | ConvertFrom-Json
    }
}
catch {
    Write-Verbose $_
    Write-Error "Unable to list all watchlists with error code: $($_.Exception.Message)" -ErrorAction Stop
}
