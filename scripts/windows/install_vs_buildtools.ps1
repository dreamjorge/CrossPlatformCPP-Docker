param (
    [string]$CHANNEL_URL = "https://aka.ms/vs/16/release/channel",
    [string]$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe",
    [string]$INSTALL_PATH = "C:\BuildTools",
    [string]$LOG_PATH = "C:\TEMP\vs_install_log.txt"
)

# Create TEMP directory if not exists
if (-not (Test-Path -Path "C:\TEMP")) {
    New-Item -ItemType Directory -Path "C:\TEMP" | Out-Null
}

# Download Visual Studio Channel Manifest
Write-Host "Downloading Visual Studio Channel Manifest..."
Invoke-WebRequest -Uri $CHANNEL_URL -OutFile "C:\TEMP\VisualStudio.chman" -UseBasicParsing

# Download Visual Studio Build Tools
Write-Host "Downloading Visual Studio Build Tools..."
Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "C:\TEMP\vs_buildtools.exe" -UseBasicParsing

# Install Visual Studio Build Tools
Write-Host "Installing Visual Studio Build Tools..."
$installerArguments = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--channelUri", "C:\TEMP\VisualStudio.chman",
    "--installChannelUri", "C:\TEMP\VisualStudio.chman",
    "--add", "Microsoft.VisualStudio.Workload.VCTools", # Core VC++ tools
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", # Compilers for x86 and x64
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041", # Windows SDK
    "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest", # VC++ Redistributable
    "--add", "Microsoft.VisualStudio.Component.MSBuild", # MSBuild tools
    "--installPath", $INSTALL_PATH,
    "--log", $LOG_PATH
)

Start-Process -FilePath "C:\TEMP\vs_buildtools.exe" -ArgumentList $installerArguments -Wait -NoNewWindow

# Validate Installation
Write-Host "Validating Visual Studio Build Tools installation..."
$vcToolsPath = Join-Path -Path $INSTALL_PATH -ChildPath "VC\Tools\MSVC"
if (-not (Test-Path $vcToolsPath)) {
    Write-Error "MSVC tools directory not found. Ensure Visual Studio Build Tools installed correctly."
    exit 1
}

Write-Host "Visual Studio Build Tools installed successfully."