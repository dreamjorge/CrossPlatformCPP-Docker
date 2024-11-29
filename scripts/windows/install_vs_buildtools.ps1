param (
    [string]$CHANNEL_URL = "https://aka.ms/vs/16/release/channel",
    [string]$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/16/release/vs_buildtools.exe",
    [string]$BUILD_TOOLS_PATH = "C:\BuildTools",
    [string]$LOG_PATH = "C:\TEMP\vs_install_log.txt"
)

# Ensure TEMP directory exists
$TEMP_DIR = "C:\TEMP"
if (-not (Test-Path $TEMP_DIR)) {
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
}

# Download Visual Studio Channel Manifest
Write-Host "Downloading Visual Studio Channel Manifest..."
Invoke-WebRequest -Uri $CHANNEL_URL -OutFile "$TEMP_DIR\VisualStudio.chman" -UseBasicParsing

# Download Visual Studio Build Tools
Write-Host "Downloading Visual Studio Build Tools..."
Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile "$TEMP_DIR\vs_buildtools.exe" -UseBasicParsing

# Define installation arguments
$installerArguments = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--channelUri", "$TEMP_DIR\VisualStudio.chman",
    "--installChannelUri", "$TEMP_DIR\VisualStudio.chman",
    "--add", "Microsoft.VisualStudio.Workload.VCTools",  # Core VC++ build tools
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", # x86 and x64 compilers
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041", # Windows SDK
    "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest", # VC++ redistributable
    "--add", "Microsoft.VisualStudio.Component.MSBuild", # MSBuild
    "--installPath", $BUILD_TOOLS_PATH,
    "--log", $LOG_PATH
)

# Install Visual Studio Build Tools
Write-Host "Installing Visual Studio Build Tools..."
Start-Process -FilePath "$TEMP_DIR\vs_buildtools.exe" -ArgumentList $installerArguments -NoNewWindow -Wait

# Verify installation
Write-Host "Verifying installation..."
$vcToolsPath = Join-Path -Path $BUILD_TOOLS_PATH -ChildPath "VC\Tools\MSVC"
if (-not (Test-Path $vcToolsPath)) {
    Write-Error "MSVC tools directory not found. Ensure Visual Studio Build Tools installed correctly."
    exit 1
}

$clPath = Get-ChildItem -Path $vcToolsPath -Directory | Sort-Object Name -Descending | Select-Object -First 1 |
    ForEach-Object { Join-Path -Path $_.FullName -ChildPath "bin\Hostx64\x64\cl.exe" }

if (-not (Test-Path $clPath)) {
    Write-Error "cl.exe not found. Installation incomplete."
    exit 1
}

Write-Host "Validation successful: MSVC tools and cl.exe found."