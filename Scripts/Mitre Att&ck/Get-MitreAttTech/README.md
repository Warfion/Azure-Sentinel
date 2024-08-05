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

It looks like I couldn't retrieve the specific contents of the Get-MitreAttTech.ps1 file. However, I can help explain what a PowerShell script file typically contains:

Functions and Cmdlets: PowerShell scripts often include custom functions or cmdlets to perform specific tasks.
Parameters: Scripts can accept parameters to customize their execution.
Pipeline Processing: Scripts may process input from the PowerShell pipeline.
Error Handling: There might be mechanisms to handle errors gracefully.
Comments and Documentation: Scripts should include comments to explain what each part of the script does.
If you can provide more details or context about the script, I can help with a more specific explanation.
