param (
    [string]$CHANNEL_URL = "https://aka.ms/vs/16/release/channel",
    [string]$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe",
    [string]$BUILD_TOOLS_PATH = "C:\BuildTools",
    [string]$TEMP_DIR = "C:\TEMP",
    [string]$LOG_PATH = "C:\TEMP\vs_install_log.txt"
)

# Ensure TEMP_DIR exists
if (-not (Test-Path $TEMP_DIR)) {
    Write-Host "Creating $TEMP_DIR directory..."
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
}

# Download Visual Studio Channel Manifest
Write-Host "Downloading Visual Studio Channel Manifest from $CHANNEL_URL..."
try {
    Invoke-WebRequest -Uri $CHANNEL_URL -OutFile "$TEMP_DIR\VisualStudio.chman" -UseBasicParsing -Verbose
    Write-Host "Channel Manifest downloaded successfully."
} catch {
    Write-Error "Failed to download Visual Studio Channel Manifest. Error: $($_.Exception.Message)"
    exit 1
}

# Download Visual Studio Build Tools Installer
Write-Host "Downloading Visual Studio Build Tools from $VS_BUILD_TOOLS_URL..."
try {
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "$TEMP_DIR\vs_buildtools.exe" -UseBasicParsing -Verbose
    Write-Host "Visual Studio Build Tools downloaded successfully."
} catch {
    Write-Error "Failed to download Visual Studio Build Tools. Error: $($_.Exception.Message)"
    exit 1
}

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
    "--includeRecommended",
    "--installPath", $BUILD_TOOLS_PATH,
    "--log", $LOG_PATH
)

# Install Visual Studio Build Tools
Write-Host "Installing Visual Studio Build Tools..."
try {
    Start-Process -FilePath "$TEMP_DIR\vs_buildtools.exe" -ArgumentList $installerArguments -NoNewWindow -Wait -PassThru | Out-Null
    Write-Host "Installer process completed successfully."
} catch {
    Write-Error "Failed to run Visual Studio Build Tools installer. Error: $($_.Exception.Message)"
    exit 1
}

# Check for Installation Log
if (-not (Test-Path $LOG_PATH)) {
    Write-Error "Installation log not found at $LOG_PATH."
    exit 1
} else {
    Write-Host "Displaying installation log:"
    Get-Content -Path $LOG_PATH | Write-Host
}

# Verify Installation
Write-Host "Verifying Visual Studio Build Tools installation..."
$clPath = Get-ChildItem -Path "$BUILD_TOOLS_PATH\VC\Tools\MSVC" -Directory | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { "$($_.FullName)\bin\Hostx64\x64\cl.exe" }
$msbuildPath = "$BUILD_TOOLS_PATH\MSBuild\Current\Bin\MSBuild.exe"

if (Test-Path $clPath -and Test-Path $msbuildPath) {
    Write-Host "Validation successful: cl.exe and MSBuild.exe found."
} else {
    Write-Error "Validation failed: Required executables not found."
    exit 1
}

# Clean Up Installer Files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path "$TEMP_DIR\VisualStudio.chman" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$TEMP_DIR\vs_buildtools.exe" -Force -ErrorAction SilentlyContinue
Write-Host "Cleanup completed successfully."