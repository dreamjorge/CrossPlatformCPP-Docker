# install_vs_buildtools.ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $env:CHANNEL_URL -OutFile "$env:TEMP_DIR\VisualStudio.chman"
Invoke-WebRequest -Uri $env:VS_BUILD_TOOLS_URL -OutFile "$env:TEMP_DIR\vs_buildtools.exe"
Start-Process -FilePath "$env:TEMP_DIR\vs_buildtools.exe" -ArgumentList `
    '--quiet', '--wait', '--norestart', '--nocache', `
    '--channelUri', "$env:TEMP_DIR\VisualStudio.chman", `
    '--installChannelUri', "$env:TEMP_DIR\VisualStudio.chman", `
    '--add', 'Microsoft.VisualStudio.Workload.VCTools', '--includeRecommended', `
    '--installPath', "$env:BUILD_TOOLS_PATH" `
    -NoNewWindow -Wait
Remove-Item -Path "$env:TEMP_DIR" -Recurse -Force