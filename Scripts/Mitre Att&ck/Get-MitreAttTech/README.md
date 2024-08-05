# Get-MitreAttTech
The "Get-MitreAttTech.ps1" 📄 uses the GitHub API to load the MITRE ATT&CK Enterprise Attack Pattern / Techniques and export the results (optional to CSV or JSON).

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

- Parameter Setup (see Paramter Sektion oben)

- Write-ProgressHelper Function:
    - Displays a progress bar with the title, step number, message, and total steps to provide feedback to the user during execution.

- Data Retrieval:
    - Uses Invoke-WebRequest to fetch the list of attack patterns from the specified BaseUrl.
    - Handles errors if the request fails, displaying an error message.

- Data Processing:
    - Extracts relevant URLs for attack patterns using regular expressions.
    - Iterates through each URL to fetch and parse JSON data for individual attack techniques.
    - Uses ConvertFrom-Json to convert the JSON data into PowerShell objects.

- Progress Updates:
    - Uses Write-ProgressHelper to update the progress bar during the processing of each attack technique.

- Data Compilation:
    - Extracts the technique ID, name, and associated tactics from the JSON data.
    - Creates a list of techniques, storing each technique as a PSCustomObject with properties for ID, name, and tactics.

- Data Export:
    - Depending on the specified OutputFormat, the script exports the compiled list of techniques:
      - CSV: Uses Export-Csv to save the data to the specified OutputPath.
      - JSON: Converts the list to JSON format and saves it to the specified OutputPath.
      - None: If OutputFormat is None, no export is performed.

- Error Handling:
    - Handles errors during data fetching and parsing, displaying appropriate error messages without stopping the entire script.

## Result
<img src="https://github.com/Warfion/Sentinel/blob/main/Scripts/Mitre Att&ck/Get-MitreAttTech/image/image_1.png">
                             
Created by: Thomas Bruend
