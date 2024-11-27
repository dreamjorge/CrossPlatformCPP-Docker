<#
.SYNOPSIS
    Installs Visual Studio Build Tools on a Windows environment.

.DESCRIPTION
    Automates the download and installation of Visual Studio Build Tools (VS2019) silently.
    Logs all operations to C:\TEMP\vs_buildtools_install.log for troubleshooting purposes.

.PARAMETER VS_VERSION
    The version of Visual Studio Build Tools to install (e.g., 16 for VS2019).

.PARAMETER VS_YEAR
    The corresponding year of the Visual Studio version (e.g., 2019 for VS16).

.EXAMPLE
    .\install_vs_buildtools.ps1 -VS_VERSION 16 -VS_YEAR 2019
#>

param(
    [Parameter(Mandatory = $false, HelpMessage = "Specify the Visual Studio version to install. Default is 16.")]
    [ValidateSet("16", "17", "18")]  # Adjust based on available versions
    [string]$VS_VERSION = "16",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the Visual Studio year. Default is 2019.")]
    [string]$VS_YEAR = "2019"
)

# Define URLs and paths
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe"
$TEMP_DIR = "C:\TEMP"
$INSTALL_DIR = "C:\BuildTools"
$LOG_PATH = "$TEMP_DIR\vs_buildtools_install.log"

# Ensure TEMP directory exists
if (-Not (Test-Path -Path $TEMP_DIR)) {
    New-Item -Path $TEMP_DIR -ItemType Directory -Force | Out-Null
}

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Write-Host $logMessage
    Add-Content -Path $LOG_PATH -Value $logMessage
}

Write-Log "Starting installation of Visual Studio Build Tools version $VS_VERSION ($VS_YEAR)."

# Download Visual Studio Build Tools Installer
Write-Log "Downloading Visual Studio Build Tools installer from $VS_BUILD_TOOLS_URL..."
try {
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "$TEMP_DIR\vs_buildtools.exe" -UseBasicParsing
    Write-Log "Downloaded Visual Studio Build Tools installer successfully."
} catch {
    Write-Log "Failed to download Visual Studio Build Tools installer: $_"
    exit 1
}

# Install Visual Studio Build Tools with C++ Workload
Write-Log "Installing Visual Studio Build Tools with C++ workload..."
try {
    Start-Process -FilePath "$TEMP_DIR\vs_buildtools.exe" -ArgumentList "--quiet", "--wait", "--norestart", "--nocache",
        "--installPath", "`"$INSTALL_DIR`"",
        "--add", "Microsoft.VisualStudio.Workload.VCTools",
        "--includeRecommended" -NoNewWindow -Wait -PassThru | Out-Null
    Write-Log "Visual Studio Build Tools installed successfully at $INSTALL_DIR."
} catch {
    Write-Log "Failed to install Visual Studio Build Tools: $_"
    exit 1
}

# Verify Installation by Checking for cl.exe
Write-Log "Verifying Visual Studio Build Tools installation by checking for cl.exe..."
$clPathPattern = "$INSTALL_DIR\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe"
$clExists = Get-ChildItem -Path $clPathPattern -ErrorAction SilentlyContinue | Select-Object -First 1

if ($clExists) {
    Write-Log "Verification successful: cl.exe found at $($clExists.FullName)."
} else {
    Write-Log "Verification failed: cl.exe not found. Installation may have failed."
    exit 1
}

# Clean Up Temporary Files
Write-Log "Cleaning up temporary files..."
try {
    Remove-Item -Path "$TEMP_DIR\vs_buildtools.exe" -Force
    Write-Log "Temporary installer removed successfully."
} catch {
    Write-Log "Failed to remove temporary installer: $_"
    # Not exiting since cleanup failure is non-critical
}

Write-Log "Visual Studio Build Tools installation completed successfully."