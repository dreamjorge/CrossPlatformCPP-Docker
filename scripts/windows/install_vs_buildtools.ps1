param(
    [string]$VS_YEAR,
    [string]$VS_VERSION
)

Write-Host "Installing Visual Studio Build Tools for Year: $VS_YEAR, Version: $VS_VERSION"

# Define the installer URL
$vsInstallerUrl = "https://aka.ms/vs/$VS_YEAR/release/vs_buildtools.exe"
$vsInstallerPath = "C:\temp\vs_buildtools.exe"

# Ensure the directory exists
if (!(Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the installer
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "Downloading Visual Studio Build Tools... Attempt $i"
        Invoke-WebRequest -Uri $vsInstallerUrl -OutFile $vsInstallerPath
        if (Test-Path $vsInstallerPath) {
            Write-Host "Download successful!"
            break
        }
    } catch {
        Write-Host "Download failed. Retrying..."
        if ($i -eq $retryCount) {
            throw "Failed to download Visual Studio Build Tools after $retryCount attempts."
        }
    }
}

# Run the installer
if (Test-Path $vsInstallerPath) {
    Write-Host "Starting Visual Studio Build Tools installation..."
    Start-Process -FilePath $vsInstallerPath -ArgumentList "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools" -NoNewWindow -Wait
} else {
    throw "Installer file not found at $vsInstallerPath."
}