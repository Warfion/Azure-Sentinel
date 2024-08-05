# Get-MitreAttTech
The "Get-MitreAttTech.ps1" 📄 uses the GitHub API to load the MITRE ATT&CK Enterprise Attack Pattern / Techniques and export the results to CSV or JSON.

***Purpose***: Lists all watchlists in Microsoft Sentinel.

***Dependencies***: Requires ***Powershell 5.2*** (or above)

***Usage Example***: 

`Get-MitreAttTech`

`Get-MitreAttTech -Verbose`

`Get-MitreAttTech -OutputFormat CSV -OutputPath "techniques.csv"`

`Get-MitreAttTech -OutputFormat JSON -OutputPath "techniques.json"`

## Parameters
- BaseUrl (string): The base URL for the MITRE ATT&CK data. Default is "https://github.com/mitre/cti/tree/master/enterprise-attack/attack-pattern".
- OutputFormat (string): The format for outputting the data. Options are None, CSV, or JSON. Default is None.
- OutputPath (string): The path to save the output file. Default is the current directory with the filename techniques.csv.

## Functionality


