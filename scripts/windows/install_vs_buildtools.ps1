param (
    [string]$CHANNEL_URL = "https://aka.ms/vs/16/release/channel",
    [string]$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe",
    [string]$INSTALL_PATH = "C:\BuildTools",
    [string]$TEMP_DIR = "C:\TEMP",
    [string]$LOG_PATH = "C:\TEMP\vs_buildtools_install.log"
)

# Function to log messages
function Log-Message {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Type] $Message" | Out-File -FilePath $LOG_PATH -Append
}

# Start Logging
Log-Message "Starting Visual Studio Build Tools installation."

# Ensure TEMP directory exists
if (-not (Test-Path -Path $TEMP_DIR)) {
    Log-Message "Creating TEMP directory at $TEMP_DIR."
    try {
        New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
    } catch {
        Log-Message "Failed to create TEMP directory: $_" "ERROR"
        exit 1
    }
} else {
    Log-Message "TEMP directory already exists at $TEMP_DIR."
}

# Download Visual Studio Channel Manifest
Log-Message "Downloading Visual Studio Channel Manifest from $CHANNEL_URL."
try {
    Invoke-WebRequest -Uri $CHANNEL_URL -OutFile "$TEMP_DIR\VisualStudio.chman" -UseBasicParsing -ErrorAction Stop
    Log-Message "Successfully downloaded Visual Studio Channel Manifest."
} catch {
    Log-Message "Failed to download Visual Studio Channel Manifest: $_" "ERROR"
    exit 1
}

# Download Visual Studio Build Tools Installer
Log-Message "Downloading Visual Studio Build Tools from $VS_BUILD_TOOLS_URL."
try {
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "$TEMP_DIR\vs_buildtools.exe" -UseBasicParsing -ErrorAction Stop
    Log-Message "Successfully downloaded Visual Studio Build Tools."
} catch {
    Log-Message "Failed to download Visual Studio Build Tools: $_" "ERROR"
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
    "--add", "Microsoft.VisualStudio.Workload.VCTools",                 # Core VC++ build tools
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",       # x86 and x64 compilers
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",     # Windows 10 SDK
    "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",        # CMake support
    "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",    # VC++ Redistributable
    "--add", "Microsoft.VisualStudio.Component.MSBuild",                # MSBuild
    "--includeRecommended",
    "--installPath", $INSTALL_PATH,
    "--log", $LOG_PATH
)

# Install Visual Studio Build Tools
Log-Message "Starting installation of Visual Studio Build Tools."
try {
    Start-Process -FilePath "$TEMP_DIR\vs_buildtools.exe" -ArgumentList $installerArguments -NoNewWindow -Wait -ErrorAction Stop
    Log-Message "Visual Studio Build Tools installation process completed."
} catch {
    Log-Message "Visual Studio Build Tools installation failed: $_" "ERROR"
    exit 1
}

# Verify Installation
Log-Message "Validating Visual Studio Build Tools installation."

# Check if MSVC directory exists
$vcToolsPath = Join-Path -Path $INSTALL_PATH -ChildPath "VC\Tools\MSVC"
if (-not (Test-Path -Path $vcToolsPath)) {
    Log-Message "MSVC tools directory not found at $vcToolsPath. Check the installation log at $LOG_PATH for details." "ERROR"
    exit 1
} else {
    Log-Message "MSVC tools directory exists at $vcToolsPath."
}

# Find cl.exe
$clPath = Get-ChildItem -Path $vcToolsPath -Directory | Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { Join-Path $_.FullName "bin\Hostx64\x64\cl.exe" }

if (-not (Test-Path -Path $clPath)) {
    Log-Message "cl.exe not found at $clPath. Ensure the required components are installed." "ERROR"
    exit 1
} else {
    Log-Message "cl.exe found at $clPath."
}

# Check MSBuild.exe
$msbuildPath = Join-Path -Path $INSTALL_PATH -ChildPath "MSBuild\Current\Bin\MSBuild.exe"
if (-not (Test-Path -Path $msbuildPath)) {
    Log-Message "MSBuild.exe not found at $msbuildPath. Ensure the required components are installed." "ERROR"
    exit 1
} else {
    Log-Message "MSBuild.exe found at $msbuildPath."
}

Log-Message "Validation successful: cl.exe and MSBuild.exe are present."

# Clean Up Installer Files
Log-Message "Cleaning up temporary files."
try {
    Remove-Item -Path "$TEMP_DIR\VisualStudio.chman" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TEMP_DIR\vs_buildtools.exe" -Force -ErrorAction SilentlyContinue
    Log-Message "Temporary installer files removed."
} catch {
    Log-Message "Failed to clean up some installer files: $_" "WARNING"
}

Log-Message "Visual Studio Build Tools installation completed successfully."