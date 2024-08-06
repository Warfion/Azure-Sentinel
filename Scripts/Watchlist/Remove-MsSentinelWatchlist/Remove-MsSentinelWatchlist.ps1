<#
.SYNOPSIS
   Helper function that delete a watchlist in Microsoft Sentinel

.EXAMPLE
   Remove-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -AliasName 'MyWatchlistAliasName'
   Remove-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -AliasName 'MyWatchlistAliasName' -Verbose
#>

[CmdletBinding()]
[Alias()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
    [string]$AliasName
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

Write-Verbose '[-] Starting "Remove-MsSentinelWatchlist.ps1" script.'
Write-Verbose "[-] Trying to connect to Azure..."
# Connect to Azure with device authentication
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
    Write-Verbose "API-Request Address:`r`n$watchlistpath`r`n"}
else {
    Write-ColorOutput "[-] Unable to retrieve log Analytics workspace" Red Black -NoNewLine
}
Write-Verbose "`r`nAzure Connection Context - Details:"
Write-Verbose ($_context | ConvertTo-Json)

try {
    $result = Invoke-AzRestMethod -Path $watchlistpath -Method DELETE -Verbose
    if ($result.StatusCode -eq 200) {
        Write-Output "[+] Watchlist with alias [$($AliasName)] has been deleted."
    }
    else {
        Write-Output $result | ConvertFrom-Json
    }
}
catch {
    Write-Verbose $_
    Write-Error "Unable to delete the watchlist with error code: $($_.Exception.Message)" -ErrorAction Stop
}
