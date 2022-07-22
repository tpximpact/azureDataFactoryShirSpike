Write-Host "Installing Microsoft Edge..." -ForegroundColor Cyan

Write-Host "Downloading..."
$msiPath = "$env:TEMP\MicrosoftEdgeEnterpriseX64.msi"
(New-Object Net.WebClient).DownloadFile('http://dl.delivery.mp.microsoft.com/filestreamingservice/files/c39f1d27-cd11-495a-b638-eac3775b469d/MicrosoftEdgeEnterpriseX64.msi', $msiPath)

Write-Host "Installing..."
cmd /c start /wait msiexec /i "$msiPath" /qn /norestart
Remove-Item $msiPath

Set-Service edgeupdate -StartupType Manual -ErrorAction SilentlyContinue
Set-Service edgeupdatem -StartupType Manual -ErrorAction SilentlyContinue

Unregister-ScheduledTask -TaskName MicrosoftEdgeUpdateTaskMachineCore -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName MicrosoftEdgeUpdateTaskMachineUA -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "Installed Microsoft Edge" -ForegroundColor Green
exit 0