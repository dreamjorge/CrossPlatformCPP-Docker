param(
    [string]$VS_YEAR,
    [string]$VS_VERSION,
    [string]$CHANNEL_URL,
    [string]$VS_BUILD_TOOLS_URL
)

Write-Host "Installing Visual Studio Build Tools for Year: $VS_YEAR, Version: $VS_VERSION"
Write-Host "Channel URL: $CHANNEL_URL"
Write-Host "Build Tools URL: $VS_BUILD_TOOLS_URL"

# Download and install
$vsInstallerPath = "C:\temp\vs_buildtools.exe"
Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $vsInstallerPath
Start-Process -FilePath $vsInstallerPath -ArgumentList `
    "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools" `
    -NoNewWindow -Wait