param(
    [string]$VS_YEAR,
    [string]$VS_VERSION
)

Write-Host "Installing Visual Studio Build Tools for Year: $VS_YEAR, Version: $VS_VERSION"

# Define URLs and paths
$CHANNEL_URL = "https://aka.ms/vs/$VS_YEAR/release/channel"
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_YEAR/release/vs_buildtools.exe"
$vsInstallerPath = "C:\temp\vs_buildtools.exe"

Write-Host "Channel URL: $CHANNEL_URL"
Write-Host "Build Tools URL: $VS_BUILD_TOOLS_URL"

# Download the installer with retries
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "Downloading Visual Studio Build Tools... Attempt $i"
        Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $vsInstallerPath -UseBasicParsing
        if ((Test-Path $vsInstallerPath) -and ((Get-Item $vsInstallerPath).Length -gt 0)) {
            Write-Host "Download successful!"
            break
        } else {
            throw "File appears to be empty or invalid."
        }
    } catch {
        Write-Host "Download failed. Retrying..."
        if ($i -eq $retryCount) {
            throw "Failed to download Visual Studio Build Tools after $retryCount attempts."
        }
    }
}

# Verify and run the installer
if (Test-Path $vsInstallerPath) {
    Write-Host "Starting Visual Studio Build Tools installation..."
    Start-Process -FilePath $vsInstallerPath -ArgumentList `
        "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools" `
        -NoNewWindow -Wait
} else {
    throw "Installer file not found at $vsInstallerPath."
}
