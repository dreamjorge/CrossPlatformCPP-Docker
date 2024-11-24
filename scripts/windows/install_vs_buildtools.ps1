# Install Visual Studio Build Tools
param(
    [string]$env:VS_YEAR,
    [string]$env:VS_VERSION
)

Write-Host "Installing Visual Studio Build Tools for Year: $($env:VS_YEAR), Version: $($env:VS_VERSION)"

# Define the installer URL
$vsInstallerUrl = "https://aka.ms/vs/$($env:VS_YEAR)/release/vs_buildtools.exe"
$vsInstallerPath = "C:\temp\vs_buildtools.exe"

# Ensure the target directory exists
if (!(Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the installer
Invoke-WebRequest -Uri $vsInstallerUrl -OutFile $vsInstallerPath

# Run the installer
Start-Process -FilePath $vsInstallerPath -ArgumentList "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools" -NoNewWindow -Wait