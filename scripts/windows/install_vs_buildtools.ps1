param (
    [string]$VsVersion = "16" # Default to Visual Studio 2019 (VS Version 16)
)

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Map Visual Studio version to corresponding installer URLs
$vsInstallers = @{
    "15" = "https://download.visualstudio.microsoft.com/download/pr/11810035/f742a4d4-75b6-4704-8171-97bb89b15be6/vs_buildtools.exe" # Visual Studio 2017
    "16" = "https://aka.ms/vs/16/release/vs_buildtools.exe" # Visual Studio 2019
    "17" = "https://aka.ms/vs/17/release/vs_buildtools.exe" # Visual Studio 2022
}

if (-not $vsInstallers.ContainsKey($VsVersion)) {
    Write-Error "Unsupported Visual Studio version: $VsVersion. Supported versions: 15 (2017), 16 (2019), 17 (2022)." -ErrorAction Stop
}

$buildToolsUrl = $vsInstallers[$VsVersion]
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"

# Download the Visual Studio Build Tools installer
try {
    Invoke-WebRequest -Uri $buildToolsUrl -OutFile $buildToolsPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Error "Failed to download Visual Studio Build Tools: $_" -ErrorAction Stop
}

# Install Visual Studio Build Tools in silent mode
$installArgs = "--quiet --norestart --wait --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended"
try {
    Start-Process -FilePath $buildToolsPath -ArgumentList $installArgs -NoNewWindow -Wait -ErrorAction Stop
} catch {
    Write-Error "Failed to install Visual Studio Build Tools: $_" -ErrorAction Stop
}

# Clean up installer file
Remove-Item -Force $buildToolsPath -ErrorAction SilentlyContinue
