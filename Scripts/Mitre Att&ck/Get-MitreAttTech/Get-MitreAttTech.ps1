<#
.SYNOPSIS
The function uses the GitHub API to load the Mitre Att&ck Enterprise Attack Pattern / Techniques and export the results to CSV or JSON.

.EXAMPLE
Get-MitreAttTech
Get-MitreAttTech -Verbose
Get-MitreAttTech -OutputFormat CSV -OutputPath "techniques.csv"
Get-MitreAttTech -OutputFormat JSON -OutputPath "techniques.json"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 0)]
    [string]$BaseUrl = "https://github.com/mitre/cti/tree/master/enterprise-attack/attack-pattern",

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 1)]
    [string]$OutputFormat = "None", # Options: None, CSV, JSON

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 2)]
    [string]$OutputPath = ""
)

function Write-ProgressHelper {
    param (
        [string]$Title,
        [int]$StepNumber,
        [string]$Message,
        [int]$TotalSteps
    )

    Write-Progress -Activity $Title -Status $Message -PercentComplete (($StepNumber / $TotalSteps) * 100)
}

try {
    $listsites = Invoke-WebRequest -Uri $BaseUrl -ErrorAction Stop
} catch {
    Write-Error "Failed to retrieve the list of sites: $_"
    return
}

$subsites = ([regex]::Matches($listsites.Content, '(?<=("path":")).*?(?=")').Value) -match "enterprise-attack/attack-pattern/attack-pattern-"
$techniques = [System.Collections.Generic.List[object]]::new()
$steps = $subsites.Count
$stepCounter = 0

foreach ($subsite in $subsites) {
    $uri = "https://raw.githubusercontent.com/mitre/cti/master/"+$subsite
    Write-Verbose $uri
    try {
        $webData = Invoke-WebRequest -Uri $uri -ErrorAction Stop
        $technique = ConvertFrom-Json $webData.Content
    } catch {
        Write-Error "Failed to retrieve or parse data from $($uri): $_"
        continue
    }

    Write-ProgressHelper -Title 'Mitre Att&ck Enterprise Attack Pattern / Techniques' -Message $technique.objects.name -StepNumber ($stepCounter++) -TotalSteps $steps

    $id = if ($technique.objects.external_references.external_id -is [System.Array]) {
        $technique.objects.external_references.external_id[0]
    } else {
        $technique.objects.external_references.external_id
    }

    $tactics = (Get-Culture).TextInfo.ToTitleCase("$(($technique.objects.kill_chain_phases.phase_name) -join ",")").Replace("-", " ")

    # Add the technique to the list

    $techniques.Add([PSCustomObject]@{
        id = $id
        name = $technique.objects.name
        tactics = $tactics
    })
}

# Return all the Mitre Att&ck Enterprise Attack Pattern / Techniques
return $techniques

if ($OutputFormat -eq "CSV") {
    $techniques | Export-Csv -Path $OutputPath -NoTypeInformation
} elseif ($OutputFormat -eq "JSON") {
    $techniques | ConvertTo-Json | Set-Content -Path $OutputPath
} elseif ($OutputFormat -ne "None") {
    Write-Error "Invalid output format specified. Use 'None', 'CSV', or 'JSON'."
}
