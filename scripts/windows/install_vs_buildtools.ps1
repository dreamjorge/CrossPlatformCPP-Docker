param (
    [string]$CHANNEL_URL = "https://aka.ms/vs/16/release/channel",
    [string]$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe",
    [string]$BUILD_TOOLS_PATH = "C:\BuildTools",
    [string]$TEMP_DIR = "C:\TEMP",
    [string]$LOG_PATH = "$TEMP_DIR\vs_install_log.txt"
)

# Ensure TEMP_DIR exists
if (-not (Test-Path $TEMP_DIR)) {
    Write-Host "Creating $TEMP_DIR directory..."
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
}

# Download Visual Studio Channel Manifest
Write-Host "Downloading Visual Studio Channel Manifest from $CHANNEL_URL..."
Invoke-WebRequest -Uri $CHANNEL_URL -OutFile "$TEMP_DIR\VisualStudio.chman" -UseBasicParsing

# Download Visual Studio Build Tools Installer
Write-Host "Downloading Visual Studio Build Tools from $VS_BUILD_TOOLS_URL..."
Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "$TEMP_DIR\vs_buildtools.exe" -UseBasicParsing

# Define Installer Arguments
$installerArguments = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--channelUri", "$TEMP_DIR\VisualStudio.chman",
    "--installChannelUri", "$TEMP_DIR\VisualStudio.chman",
    "--add", "Microsoft.VisualStudio.Workload.VCTools",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",
    "--add", "Microsoft.VisualStudio.Component.MSBuild",
    "--add", "Microsoft.VisualStudio.Component.VC.CoreBuildTools",
    "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",
    "--includeRecommended",
    "--installPath", $BUILD_TOOLS_PATH,
    "--log", $LOG_PATH
)

# Install Visual Studio Build Tools
Write-Host "Installing Visual Studio Build Tools..."
Start-Process -FilePath "$TEMP_DIR\vs_buildtools.exe" -ArgumentList $installerArguments -NoNewWindow -Wait

# Verify Installation
Write-Host "Verifying installation..."
$clPath = Get-ChildItem -Path "$BUILD_TOOLS_PATH\VC\Tools\MSVC" -Directory | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { "$($_.FullName)\bin\Hostx64\x64\cl.exe" }
$msbuildPath = "$BUILD_TOOLS_PATH\MSBuild\Current\Bin\MSBuild.exe"

if ((Test-Path $clPath) -and (Test-Path $msbuildPath)) {
    Write-Host "Validation successful: cl.exe and MSBuild.exe found."
} else {
    Write-Error "Validation failed: Required executables not found."
    exit 1
}

# Clean Up Installer Files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path "$TEMP_DIR\VisualStudio.chman" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TEMP_DIR\vs_buildtools.exe" -Force -ErrorAction SilentlyContinue