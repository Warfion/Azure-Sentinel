<#
.SYNOPSIS
    Helper script that get the retention settings of a specific table in Microsoft Sentinel / Log Analytics Workspace

.EXAMPLE
Get-MsSentinelTableRetention -Subscription 'MySubscriptionName' -WorkspaceName 'MyWorkspace' -TableName 'MyTableName'
Get-MsSentinelTableRetention -Subscription 'MySubscriptionName' -WorkspaceName 'MyWorkspace' -TableName 'MyTableName' -Verbose
#>


[CmdletBinding()]
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
    [string]$TableName

)

function Write-ColorOutput
{
    [CmdletBinding()]
    Param(
         [Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][Object] $Object,
         [Parameter(Mandatory = $False, Position = 2, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)][ConsoleColor] $ForegroundColor,
         [Parameter(Mandatory = $False, Position = 3, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)][ConsoleColor] $BackgroundColor,
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

Write-Verbose '[*] Starting "Get-MsSentinelTableRetention.ps1" script.'
Write-Verbose "[*] Trying to connect to Azure..."

# Connect to Azure
try {
    $context = Get-AzContext
    if (!$context) {
        Write-ColorOutput "[~] No Azure context found. Trying to connect..." Yellow Black
        Connect-AzAccount -UseDeviceAuthentication -Subscription $Subscription
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

Write-ColorOutput "[+] Connected to Azure with $($Subscription)"  Green Black

Write-Verbose "[*] Trying to get Log Analytics Workspace with name [$WorkspaceName]"

$workspace = Get-AzResource -Name $WorkspaceName -ResourceType 'Microsoft.OperationalInsights/workspaces'

if ($null -ne $workspace) {
    Write-ColorOutput "[+] Log Analytics Workspace [$($WorkspaceName)] successfully retrieved." Green Black
    # Define the API version and construct the request URL
    $apiVersion = '?api-version=2023-09-01'
    $baseUri = '{0}/Tables/{1}' -f $workspace.ResourceId,$TableName
    $tablelistpath = '{0}/{1}' -f $baseUri,$apiVersion
    Write-Verbose "Constructed API request URL: $tablelistpath"
    }
else {
    Write-ColorOutput "[-] Unable to retrieve Log Analytics Workspace" Red Black
}

Write-Verbose "`r`nAzure Connection Context - Details:"
Write-Verbose ($_context | ConvertTo-Json)

try {
    $webData = Invoke-AzRestMethod -Path $tablelistpath -Method GET
    if ($webData.StatusCode -eq 200) {
        Write-ColorOutput "[+] Table $($TableName) successfully retrieved." Green Black
        # Convert JSON content to PowerShell object
        $webData = ($webData.Content | ConvertFrom-Json)

        # Create a new list to store the table object
        $table = [System.Collections.Generic.List[PSObject]]::new()
        
            $table = [PSCustomObject]@{
                TableName = $webdata.name
                RetentionInDays = $webdata.properties.retentionInDays
                ArchiveRetentionInDays = $webdata.properties.archiveRetentionInDays
                TotalRetentionInDays = $webdata.properties.totalRetentionInDays
        }
        
        # Return the table object
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
    Write-Error "Unable to list the table [$($TableName)] with error code: $($_.Exception.Message)" -ErrorAction Stop
}
