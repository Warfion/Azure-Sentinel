<#
.SYNOPSIS
    Helper function that get the retention settings of a specific tabel in Microsoft Sentinel

.EXAMPLE
Get-MsSentinelTableRetention -WorkspaceName 'MyWorkspace'
Get-MsSentinelTableRetention -WorkspaceName 'MyWorkspace' -Verbose
#>

[CmdletBinding()]
[Alias()]
Param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Subscription,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$TableName,

    [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 3)]
    [ValidateSet($true, $false, IgnoreCase = $false)]
    [string]$Automation = $false

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

Write-Verbose '[-] Starting "Get-MsSentinelTableRetention.ps1" script.'
Write-Verbose "[-] Trying to connect to Azure..."
# Connect to Azure with device authentication
try {
    $context = Get-AzContext
    if (!$context) {
        if($Automation -eq "False"){Connect-AzAccount -Identity -Subscription $Subscription}
        else {Connect-AzAccount -UseDeviceAuthentication -Subscription $Subscription }
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
    $apiVersion = '?api-version=2023-09-01'
    $baseUri = '{0}/Tables/{1}' -f $workspace.ResourceId,$TableName
    $tablelistpath = '{0}/{1}' -f $baseUri,$apiVersion
    Write-Verbose "API-Request Address:`r`n$tablelistpath`r`n"
    }
else {
    Write-ColorOutput "[-] Unable to retrieve log Analytics workspace" Red Black -NoNewLine
}

Write-Verbose "`r`nAzure Connection Context - Details:"
Write-Verbose ($_context | ConvertTo-Json)

try {
    $webData = Invoke-AzRestMethod -Path $tablelistpath -Method GET
    if ($webData.StatusCode -eq 200) {
        Write-ColorOutput "[+] Table successfully retrieved." Green Black
        # Convert JSON content to PowerShell object
        $webData = ($webData.Content | ConvertFrom-Json)

        # Initialize a list to store watchlists
        $table = [System.Collections.Generic.List[PSObject]]::new()
        
            $table = [PSCustomObject]@{
                TableName = $webdata.name
                RetentionInDays = $webdata.properties.retentionInDays
                ArchiveRetentionInDays = $webdata.properties.archiveRetentionInDays
                TotalRetentionInDays = $webdata.properties.totalRetentionInDays
        }
        
        # Return the list of watchlists
        return $table
    }
    else {
        # Output the error response
        Write-Output ($webData.Content | ConvertFrom-Json)
    }
}
catch {
    # Log the error message and stop execution
    Write-Verbose $_
    Write-Error "Unable to list the table with error code: $($_.Exception.Message)" -ErrorAction Stop
}
