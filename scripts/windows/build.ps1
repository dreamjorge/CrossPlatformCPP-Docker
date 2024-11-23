param (
    [Parameter(Mandatory = $true)]
    [string]$Config,
    [Parameter(Mandatory = $true)]
    [string]$BuildDir
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Starting build process with configuration: $Config"

# Create the build directory if it doesn't exist
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
    Write-Host "INFO: Created build directory at $BuildDir"
}

# Run CMake to generate build files
Write-Host "INFO: Running CMake to generate build files..."
cmake -S . -B $BuildDir -G "Visual Studio $env:VS_VERSION" -A x64 -DCMAKE_BUILD_TYPE=$Config

# Build the project
Write-Host "INFO: Building the project..."
cmake --build $BuildDir --config $Config

Write-Host "INFO: Build process completed successfully."