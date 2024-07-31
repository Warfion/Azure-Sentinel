$listsites = Invoke-WebRequest "https://github.com/mitre/cti/tree/master/enterprise-attack/x-mitre-tactic"

$subsites=([regex]::Matches($listsites, '(?<=("path":")).*?(?=")').Value) -match "enterprise-attack/x-mitre-tactic/x-mitre-tactic--"

$tactics = [System.Collections.Generic.List[object]]::new()

foreach($subsite in $subsites){

    $uri = "https://raw.githubusercontent.com/mitre/cti/master/"+$subsite
    $webData=Invoke-WebRequest -Uri $uri
    $tactic = ConvertFrom-Json $webData
    
    $tactic = [PSCustomObject]@{
        Name = $tactic.objects.name
        ID = $tactic.objects.external_references.external_id
        Description = $tactic.objects.description
    } 
    $tactics.Add($tactic)
}

$tactics
#$tactics | Export-Csv -NoTypeInformation "tactics.csv"
#$tactics | ConvertTo-Json -depth 100 | Out-File "tactics.json"
