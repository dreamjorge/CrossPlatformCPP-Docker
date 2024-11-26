<#
.SYNOPSIS
    Installs Visual Studio Build Tools and CMake on a Windows environment.

.DESCRIPTION
    This script automates the download and installation of Visual Studio Build Tools (VS2019) and CMake using Chocolatey.
    It logs all operations to C:\TEMP\vs_buildtools_install.log for troubleshooting purposes.

.PARAMETER VS_VERSION
    The version of Visual Studio Build Tools to install (e.g., 16 for VS2019).

.PARAMETER VS_YEAR
    The corresponding year of the Visual Studio version (e.g., 2019 for VS16).

.PARAMETER CMAKE_VERSION
    The version of CMake to install.

.EXAMPLE
    .\install_vs_buildtools.ps1 -VS_VERSION 16 -VS_YEAR 2019 -CMAKE_VERSION 3.26.4
#>

param(
    [Parameter(Mandatory = $false, HelpMessage = "Specify the Visual Studio version to install. Default is 16.")]
    [ValidateSet("16", "17", "18")]  # Adjust based on available versions
    [string]$VS_VERSION = "16",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the Visual Studio year. Default is 2019.")]
    [string]$VS_YEAR = "2019",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the version of CMake to install. Default is 3.26.4.")]
    [string]$CMAKE_VERSION = "3.26.4"
)

# Define URLs and paths
$CHANNEL_URL = "https://aka.ms/vs/$VS_VERSION/release/channel"
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe"
$CMAKE_DOWNLOAD_URL = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"

$TEMP_DIR = "C:\TEMP"
$INSTALL_DIR = "C:\BuildTools"
$LOG_PATH = "$TEMP_DIR\vs_buildtools_install.log"
$CMAKE_INSTALL_PATH = "C:\Program Files\CMake\bin"

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

Write-Log "Starting installation of Visual Studio Build Tools version $VS_VERSION ($VS_YEAR) and CMake version $CMAKE_VERSION."

# Download Visual Studio Channel
Write-Log "Downloading Visual Studio channel file from $CHANNEL_URL..."
try {
    Invoke-WebRequest -Uri $CHANNEL_URL -OutFile "$TEMP_DIR\VisualStudio.channel" -UseBasicParsing
    Write-Log "Downloaded Visual Studio channel file successfully."
} catch {
    Write-Log "Failed to download Visual Studio channel file: $_"
    exit 1
}

# Download Visual Studio Build Tools Installer
Write-Log "Downloading Visual Studio Build Tools installer from $VS_BUILD_TOOLS_URL..."
try {
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "$TEMP_DIR\vs_buildtools.exe" -UseBasicParsing
    Write-Log "Downloaded Visual Studio Build Tools installer successfully."
} catch {
    Write-Log "Failed to download Visual Studio Build Tools installer: $_"
    exit 1
}

# Install Chocolatey Package Manager
Write-Log "Installing Chocolatey Package Manager..."
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Log "Chocolatey installed successfully."
} catch {
    Write-Log "Failed to install Chocolatey: $_"
    exit 1
}

# Install CMake via Chocolatey
Write-Log "Installing CMake version $CMAKE_VERSION via Chocolatey..."
try {
    choco install cmake --version=$CMAKE_VERSION --installargs 'ADD_CMAKE_TO_PATH=System' -y
    Write-Log "CMake installed successfully at $CMAKE_INSTALL_PATH."
} catch {
    Write-Log "Failed to install CMake: $_"
    exit 1
}

# Install Visual Studio Build Tools with C++ Workload
Write-Log "Installing Visual Studio Build Tools with C++ workload..."
try {
    Start-Process -FilePath "$TEMP_DIR\vs_buildtools.exe" -ArgumentList "--quiet", "--wait", "--norestart", "--nocache",
        "--channelUri", "$TEMP_DIR\VisualStudio.channel",
        "--installChannelUri", "$TEMP_DIR\VisualStudio.channel",
        "--add", "Microsoft.VisualStudio.Workload.VCTools",
        "--includeRecommended",
        "--installPath", "$INSTALL_DIR" -NoNewWindow -Wait -PassThru
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
    Remove-Item -Path $TEMP_DIR -Recurse -Force
    Write-Log "Temporary files removed successfully."
} catch {
    Write-Log "Failed to remove temporary files: $_"
    # Not exiting since cleanup failure is non-critical
}

Write-Log "Visual Studio Build Tools and CMake installation completed successfully."
