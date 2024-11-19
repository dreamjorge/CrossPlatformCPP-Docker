# Exit immediately if any command fails
$ErrorActionPreference = "Stop"

# Validate that required environment variables are set
if (-not $env:CHANNEL_URL) {
    Write-Error "CHANNEL_URL environment variable is not set."
    exit 1
}

if (-not $env:VS_BUILD_TOOLS_URL) {
    Write-Error "VS_BUILD_TOOLS_URL environment variable is not set."
    exit 1
}

# Download Visual Studio Channel
Invoke-WebRequest -Uri $env:CHANNEL_URL -OutFile "$env:TEMP_DIR\VisualStudioChannel.json"

# Download Visual Studio Build Tools
Invoke-WebRequest -Uri $env:VS_BUILD_TOOLS_URL -OutFile "$env:TEMP_DIR\vs_buildtools.exe"

# Install Visual Studio Build Tools
Start-Process -FilePath "$env:TEMP_DIR\vs_buildtools.exe" -ArgumentList `
    '--quiet', '--wait', '--norestart', '--nocache', `
    '--channelUri', "$env:TEMP_DIR\VisualStudioChannel.json", `
    '--installPath', "$env:BUILD_TOOLS_PATH", `
    '--add', 'Microsoft.VisualStudio.Workload.VCTools', `
    '--includeRecommended' -Wait