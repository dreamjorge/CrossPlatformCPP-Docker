param()

$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe"
$InstallerPath = "C:\TEMP\vs_buildtools.exe"
$LogPath = "C:\TEMP\vs_buildtools_install.log"

# Download the installer
Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $InstallerPath

# Run the installer
Start-Process -FilePath $InstallerPath -ArgumentList @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--installPath C:\BuildTools",
    "--add Microsoft.VisualStudio.Workload.VCTools",
    "--includeRecommended",
    "--lang en-US",
    "--log $LogPath"
) -NoNewWindow -Wait
