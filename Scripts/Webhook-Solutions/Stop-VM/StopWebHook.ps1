### Load Dependencies
Add-Type -AssemblyName "System.Windows.Forms"
### Send WebRequest
$WebRequest = Invoke-WebRequest -Method Post -Uri <URL + Token>
If (($WebRequest.StatusCode) -eq "202"){$Checkbox = [System.Windows.Forms.MessageBox]::Show("VM Stop Prozedur erfolgreich uebermittelt!","Info",0,[System.Windows.Forms.MessageBoxIcon]::Information)}
Else {$Checkbox = [System.Windows.Forms.MessageBox]::Show("VM Stop Prozedur fehlgeschlagen!","Info",0,[System.Windows.Forms.MessageBoxIcon]::Error)}
