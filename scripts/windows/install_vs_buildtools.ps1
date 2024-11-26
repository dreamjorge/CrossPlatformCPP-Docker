param(
    [Parameter(Mandatory = $false, HelpMessage = "Specify the version of Visual Studio Build Tools to install. Default is 16.")]
    [ValidateSet("16", "17", "18")]  # Adjust the set based on available versions
    [string]$VS_VERSION = "16",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the Visual Studio Year. Default is 2019.")]
    [string]$VS_YEAR = "2019",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the version of CMake to install. Default is 3.26.4.")]
    [string]$CMAKE_VERSION = "3.26.4"
)

# Define URLs and paths
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe"
$InstallerPath = "C:\TEMP\vs_buildtools.exe"
$LogPath = "C:\TEMP\vs_buildtools_install.log"
$InstallPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools"

# Function to display messages
function Write-Log {
    param ([string]$Message)
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

# Ensure TEMP directory exists
if (-Not (Test-Path "C:\TEMP")) {
    Write-Log "Creating TEMP directory at C:\TEMP."
    New-Item -Path "C:\TEMP" -ItemType Directory -Force
}

# Download the installer
Write-Log "Downloading Visual Studio Build Tools version $VS_VERSION from $VS_BUILD_TOOLS_URL..."
try {
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $InstallerPath -UseBasicParsing
    Write-Log "Download completed successfully."
} catch {
    Write-Log "Error downloading the installer: $_"
    exit 1
}

# Run the installer with specified arguments
Write-Log "Starting the installation of Visual Studio Build Tools version $VS_VERSION..."
$InstallerArguments = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--installPath `"$InstallPath`"",
    "--add Microsoft.VisualStudio.Workload.VCTools",
    "--includeRecommended",
    "--lang en-US",
    "--log `"$LogPath`""
)

try {
    Start-Process -FilePath $InstallerPath -ArgumentList $InstallerArguments -NoNewWindow -Wait -PassThru
    Write-Log "Installation process completed."
} catch {
    Write-Log "Error during installation: $_"
    exit 1
}

# Verify installation by checking the presence of cl.exe (C++ compiler)
$clPathPattern = "$InstallPath\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe"
$clExists = Get-ChildItem -Path $clPathPattern -ErrorAction SilentlyContinue | Select-Object -First 1

if ($clExists) {
    Write-Log "Visual Studio Build Tools version $VS_VERSION installed successfully at $InstallPath."
} else {
    Write-Log "Installation may have failed. Check the log at $LogPath for details."
    exit 1
}

# Optional: Clean up the installer
# Write-Log "Removing installer file..."
# Remove-Item -Path $InstallerPath -Force
# Write-Log "Installer removed."

Write-Log "Script execution completed."
