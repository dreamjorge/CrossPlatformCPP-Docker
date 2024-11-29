param (
    [string]$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe",
    [string]$INSTALL_PATH = "C:\BuildTools",
    [string]$TEMP_DIR = "C:\TEMP",
    [string]$LOG_PATH = "C:\TEMP\vs_buildtools_install.log"
)

# Function to log messages with timestamps and severity levels
function Log-Message {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Type] $Message" | Out-File -FilePath $LOG_PATH -Append
}

# Start Logging
Log-Message "===== Starting Visual Studio Build Tools Installation ====="

# Ensure TEMP directory exists
if (-not (Test-Path -Path $TEMP_DIR)) {
    Log-Message "Creating TEMP directory at $TEMP_DIR."
    try {
        New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
        Log-Message "TEMP directory created successfully."
    } catch {
        Log-Message "Failed to create TEMP directory: $_" "ERROR"
        exit 1
    }
} else {
    Log-Message "TEMP directory already exists at $TEMP_DIR."
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

# Define Installer Arguments with Correct Component IDs
$installerArguments = @(
    "--quiet",                              # Silent installation
    "--wait",                               # Wait for completion
    "--norestart",                          # Do not restart after installation
    "--nocache",                            # Do not cache downloaded files
    "--installPath", $INSTALL_PATH,         # Installation directory
    "--add", "Microsoft.VisualStudio.Workload.VCTools",                   # Core VC++ build tools
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",         # x86 and x64 compilers
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",       # Windows 10 SDK
    "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",          # CMake support
    "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",      # VC++ Redistributable
    "--add", "Microsoft.VisualStudio.Component.MSBuild",                  # MSBuild tools
    "--includeRecommended",                                                    # Include recommended components
    "--log", $LOG_PATH                                                        # Log file path
)

# Install Visual Studio Build Tools
Log-Message "Initiating Visual Studio Build Tools installation."
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
    # Optionally, output the log content for debugging
    Get-Content $LOG_PATH | Out-String | Write-Host
    exit 1
} else {
    Log-Message "MSVC tools directory exists at $vcToolsPath."
}

# Locate cl.exe
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
Log-Message "Cleaning up temporary installer files."
try {
    Remove-Item -Path "$TEMP_DIR\vs_buildtools.exe" -Force -ErrorAction SilentlyContinue
    Log-Message "Removed vs_buildtools.exe."
} catch {
    Log-Message "Failed to remove vs_buildtools.exe: $_" "WARNING"
}

Log-Message "===== Visual Studio Build Tools Installation Completed Successfully ====="