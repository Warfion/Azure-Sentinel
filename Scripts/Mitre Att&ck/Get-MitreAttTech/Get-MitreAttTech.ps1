<#
.SYNOPSIS
The function uses the GitHub API to load the Mitre Att&ck Enterprise Attack Pattern / Techniques and export the results to CSV or JSON.

.EXAMPLE
Get-MitreAttTech
Get-MitreAttTech -Verbose
Get-MitreAttTech -OutputFormat CSV -OutputPath "c:\temp"
Get-MitreAttTech -OutputFormat JSON -OutputPath "c:\temp" -Update $true
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 0)]
    [string]$BaseUrl = "https://github.com/mitre/cti/tree/master/enterprise-attack/attack-pattern",

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 1)]
    [ValidateSet("All","None", "CSV", "JSON", IgnoreCase = $false)]
    [string]$OutputFormat = "None", # Options: All, None, CSV, JSON
    
    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 2)]
    [string]$OutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 3)]
    [string]$Update = $false
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
# Check if the outputformat is set
if ($OutputFormat -eq "None") {
    Write-Verbose "No Output-Format specified. Result is not exported.`n"
}

#  Check if the update flag is set
if ($Update -eq $false) {
    # Check if the output files already exist
    switch ($OutputFormat) {
        CSV {$filesToCheck = @("techniques.csv")}
        JSON {$filesToCheck = @("techniques.json")}
        All {$filesToCheck = @("techniques.csv", "techniques.json")}
        None {$filesToCheck = $null}
    }

    if($filesToCheck){
        foreach ($file in $filesToCheck) {
            $filePath = Join-Path -Path $OutputPath -ChildPath $file
            if (Test-Path -Path $filePath) {
                Write-Verbose "File $filePath already exists. Please remove it or specify a different output path.`n"
            } else {
                Write-Verbose "File $filePath does not exist. Proceeding......`n"
                $Update = $true
            }
        }
    }else {
        $Update = $true
    }
}

#  Check if the update flag is set
if ($Update -eq $true) {
     Write-Verbose "Retrieving Mitre Att&ck Enterprise Attack Pattern / Techniques.....`n"
    # Retrieve the list of sites
    try {
        $listsites = Invoke-WebRequest -Uri $BaseUrl -ErrorAction Stop
    } catch {
        Write-Error "Failed to retrieve the list of sites: $_"
        return
    }
    
    # Get the list of subsites
    $subsites = ([regex]::Matches($listsites.Content, '(?<=("path":")).*?(?=")').Value) -match "enterprise-attack/attack-pattern/attack-pattern-"
    
    # Initialize the list of techniques
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
    # Export the results to CSV or JSON
    if ($OutputFormat -eq "CSV") {
        Write-Verbose "Exporting Results to CSV...."
        $techniques | Export-Csv -Path ($OutputPath + "\techniques.csv")
    } elseif ($OutputFormat -eq "JSON") {
        Write-Verbose "Exporting Results to JSON...."
        $techniques | ConvertTo-Json | Set-Content -Path ($OutputPath + "\techniques.json")
    } elseif ($OutputFormat -eq "All") {
        Write-Verbose "Exporting Results to JSON & CSV...."
            $techniques | ConvertTo-Json | Set-Content -Path ($OutputPath + "\techniques.json")
            $techniques | Export-Csv -Path ($OutputPath + "\techniques.csv")
    } elseif ($OutputFormat -eq "None") {
        Write-Verbose "No Exportoption assigned."
    } else{
        Write-Error "Invalid output format specified. Use 'All', 'None', 'CSV', or 'JSON'."
    }
    # Return all the Mitre Att&ck Enterprise Attack Pattern / Techniques
    return $techniques
}
