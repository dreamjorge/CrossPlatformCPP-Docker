# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Running build script"

# Set default Visual Studio year and version if not provided
if (-not $env:VS_YEAR) {
    Write-Host "INFO: VS_YEAR not set. Defaulting to 2019."
    $env:VS_YEAR = "2019"
    $env:VS_VERSION = "16"
} elseif ($env:VS_YEAR -eq "2017") {
    $env:VS_VERSION = "15"
} elseif ($env:VS_YEAR -eq "2022") {
    $env:VS_VERSION = "17"
} else {
    Write-Error "ERROR: Unsupported Visual Studio year: $env:VS_YEAR"
    exit 1
}

Write-Host "INFO: VS_YEAR=$env:VS_YEAR"
Write-Host "INFO: VS_VERSION=$env:VS_VERSION"
Write-Host "INFO: CONFIG=$env:CONFIG"

# Verify CMake installation
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: CMake is not installed or not in PATH!"
    exit 1
}

# Locate VsDevCmd.bat dynamically
$vsDevCmdPath = Get-ChildItem -Path "C:\Program Files (x86)\Microsoft Visual Studio\" -Recurse -Filter VsDevCmd.bat |
    Sort-Object -Property FullName -Descending |
    Select-Object -First 1

if (-not $vsDevCmdPath) {
    Write-Error "ERROR: VsDevCmd.bat not found."
    exit 1
}

# Start Visual Studio environment and build process
Write-Host "INFO: Starting build process for Visual Studio $env:VS_YEAR..."
& $vsDevCmdPath.FullName
cmake -S . -B build -G "Visual Studio $env:VS_VERSION $env:VS_YEAR" -A x64
cmake --build build --config $env:CONFIG

Write-Host "INFO: Build completed successfully."
