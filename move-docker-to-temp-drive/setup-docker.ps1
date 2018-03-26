$content = @'
{
    "data-root": "D:\\"
}
'@

$encoding = new-object System.Text.UTF8Encoding -ArgumentList @($false)
[System.IO.File]::WriteAllText('C:\ProgramData\docker\config\daemon.json', $content, $encoding)

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {if ((get-service docker).Status -ne ''Running'') { Start-Sleep -Seconds 1 }; docker pull microsoft/windowsservercore:latest; docker pull microsoft/nanoserver:latest}"'
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -LogonType S4U -UserId 'NT AUTHORITY\SYSTEM'
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "docker-pull" -Description "Pull server core and nanoserver base images" -Principal $principal

[System.Environment]::SetEnvironmentVariable('TEMP', 'D:\Temp', 'Machine')
[System.Environment]::SetEnvironmentVariable('TMP', 'D:\Temp', 'Machine')

Add-MpPreference -ExclusionPath D:\

restart-service docker
docker pull microsoft/windowsservercore:latest
docker pull microsoft/nanoserver:latest
