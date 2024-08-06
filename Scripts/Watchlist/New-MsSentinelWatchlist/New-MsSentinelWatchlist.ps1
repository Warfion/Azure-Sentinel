<#
.SYNOPSIS
   Helper function that creates a watchlist in Microsoft Sentinel

.EXAMPLE
   New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace'
   New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -Verbose
#>

[CmdletBinding()]
[Alias()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
    [string]$WatchlistName,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 2)]
    [string]$AliasName,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 3)]
    [string]$itemsSearchKey,

    [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 4)]
    [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.csv') })]
    [System.IO.FileInfo]$csvFile
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

Write-Verbose '[-] Starting "New-MsSentinelWatchlist.ps1" script.'
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
    Write-Verbose "API-Request Address:`r`n$watchlistpath`r`n"
}
else {
    Write-ColorOutput "[-] Unable to retrieve log Analytics workspace" Red Black -NoNewLine
}
Write-Verbose "`r`nAzure Connection Context - Details:"
Write-Verbose ($_context | ConvertTo-Json)

if ($null -ne $csvFile) {
    try {
        Write-Verbose "[-] Trying to read CSV content"
        $content = Get-Content $csvFile | ConvertFrom-Csv
        if (($content.$itemsSearchKey).count -eq 0) {
            Write-Host "[-] Invalid 'itemsSearchKey' value provided, check the input file for the correct header.`n"
            exit
        }
        else {
            Write-Verbose "[-] Selected CSV file contains $($($content.$itemsSearchKey).count) items"
        }
    }
    catch {
        Write-Error 'Unable to process CSV file'
        exit
    }

    try {
        Write-Verbose "[-] Converting file file content for [$($csvFile.Name)]"
        foreach ($line in [System.IO.File]::ReadLines($csvFile.FullName)) {
            $rawContent += "$line`r`n"
        }
    }
    catch {
        Write-Error "Unable to process file content"
    }
}

#Process csv

$argHash = @{}
$argHash.properties = @{
    displayName    = "$WatchlistName"
    source         = "$($csvFile.Name)"
    description    = "Watchlist from $($csvFile.Extension) content"
    contentType    = 'text/csv'
    itemsSearchKey = $itemsSearchKey
    rawContent     = "$($rawContent)"
    provider       = 'SecureHats'
}

try {
    $result = Invoke-AzRestMethod -Path $watchlistpath -Method PUT -Payload ($argHash | ConvertTo-Json)
    if ($result.StatusCode -eq 200) {
        Write-Output "[+] Watchlist with alias [$($AliasName)] has been created."
        Write-Output "[+] It can take a while before the results are visible in Log Analytics.`n"
    }
    else {
        Write-Output $result | ConvertFrom-Json
    }
}
catch {
    Write-Verbose $_
    Write-Error "Unable to create the watchlist with error code: $($_.Exception.Message)" -ErrorAction Stop
}
