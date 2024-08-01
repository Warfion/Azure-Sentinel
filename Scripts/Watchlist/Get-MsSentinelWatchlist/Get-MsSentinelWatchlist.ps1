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
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspaceName
)

function Write-ColorOutput
{
    [CmdletBinding()]
    Param(
         [Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][Object] $Object,
         [Parameter(Mandatory=$False,Position=2,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][ConsoleColor] $ForegroundColor,
         [Parameter(Mandatory=$False,Position=3,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][ConsoleColor] $BackgroundColor,
         [Switch]$NoNewline
    )    

    # Save previous colors
    $previousForegroundColor = $host.UI.RawUI.ForegroundColor
    $previousBackgroundColor = $host.UI.RawUI.BackgroundColor

    # Set BackgroundColor if available
    if($BackgroundColor -ne $null)
    { 
       $host.UI.RawUI.BackgroundColor = $BackgroundColor
    }

    # Set $ForegroundColor if available
    if($ForegroundColor -ne $null)
    {
        $host.UI.RawUI.ForegroundColor = $ForegroundColor
    }

    # Always write (if we want just a NewLine)
    if($null -eq $Object)
    {
        $Object = ""
    }

    if($NoNewline)
    {
        [Console]::Write($Object)
    }
    else
    {
        Write-Output $Object
    }

    # Restore previous colors
    $host.UI.RawUI.ForegroundColor = $previousForegroundColor
    $host.UI.RawUI.BackgroundColor = $previousBackgroundColor
}

Write-Verbose 'Starting "Get-MsSentinelWatchlist.ps1" script.'
Write-Verbose "Trying to connect to Azure..."
try {
    $context = Get-AzContext
    if (!$context) {
        Connect-AzAccount -UseDeviceAuthentication
        $context = Get-AzContext
    }
}
catch {
    Write-Error "Failed to get or connect to Azure context: $_" -ErrorAction Stop
}

$_context = @{
    'Account'         = $($context.Account)
    'Subscription Id' = $context.Subscription
    'Tenant'          = $context.Tenant
}

Write-ColorOutput "Connected to Azure with subscriptionId: "  Green Black -NoNewLine
Write-ColorOutput "$($context.Subscription)`n"

$workspace = Get-AzResource -Name $WorkspaceName -ResourceType 'Microsoft.OperationalInsights/workspaces'

if ($null -ne $workspace) {
    $apiVersion = '?api-version=2024-03-01'
    $baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
    $watchlistpath = '{0}/watchlists/{1}{2}' -f $baseUri, $AliasName, $apiVersion
}
else {
    Write-ColorOutput "[-] Unable to retrieve log Analytics workspace" Red Black -NoNewLine
}
Write-Verbose "Azure Connection Context - Details:"
Write-Verbose "----------------------------------------------------------------------------------------------"
Write-Verbose ($_context | ConvertTo-Json)

try {
    $webData = Invoke-AzRestMethod -Path $watchlistpath -Method GET
    if ($webData.StatusCode -eq 200) {
        $webData = ($webData.Content | ConvertFrom-Json).value
        
        $watchlists = [System.Collections.Generic.List[PSObject]]::new()
        foreach ($data in $webData) {
            $watchlist = [PSCustomObject]@{
                Watchlist = $data.name
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
    Write-Error "Unable to list all watchlists with error code: $($_.Exception.Message)" -ErrorAction Stop
    Write-Verbose $_
}

# https://github.com/SecureHats/SecureHacks/blob/main/scripts/Azure/Sentinel/New-MsSentinelWatchlist/New-MsSentinelWatchlist.ps1
# https://learn.microsoft.com/en-us/rest/api/securityinsights/watchlist-items/list?view=rest-securityinsights-2024-03-01&tabs=HTTP
