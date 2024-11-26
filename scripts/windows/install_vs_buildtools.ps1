param(
    [Parameter(Mandatory = $false, HelpMessage = "Specify the version of Visual Studio Build Tools to install. Default is 16.")]
    [ValidateSet("16", "17", "18")]  # Adjust the set based on available versions
    [string]$Version = "16"
)

# Define URLs and paths
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$Version/release/vs_buildtools.exe"
$InstallerPath = "C:\TEMP\vs_buildtools.exe"
$LogPath = "C:\TEMP\vs_buildtools_install.log"
$InstallPath = "C:\BuildTools"

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
Write-Log "Downloading Visual Studio Build Tools version $Version from $VS_BUILD_TOOLS_URL..."
try {
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $InstallerPath -UseBasicParsing
    Write-Log "Download completed successfully."
} catch {
    Write-Log "Error downloading the installer: $_"
    exit 1
}

# Run the installer with specified arguments
Write-Log "Starting the installation of Visual Studio Build Tools version $Version..."
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

# Verify installation
if (Test-Path $InstallPath) {
    Write-Log "Visual Studio Build Tools version $Version installed successfully at $InstallPath."
} else {
    Write-Log "Installation may have failed. Check the log at $LogPath for details."
}

# Optional: Clean up the installer
# Write-Log "Removing installer file..."
# Remove-Item -Path $InstallerPath -Force
# Write-Log "Installer removed."

Write-Log "Script execution completed."