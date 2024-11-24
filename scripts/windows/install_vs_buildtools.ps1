param (
    [string]$Config = "Release",
    [string]$BuildDir = "C:\app\build\Release"
)

function Log-Info {
    param ([string]$Message)
    Write-Host "INFO: $Message"
}

function Log-Error {
    param ([string]$Message)
    Write-Error "ERROR: $Message"
}

# Set the generator name based on VS_VERSION
$vsVersion = $env:VS_VERSION
switch ($vsVersion) {
    "15" { $generator = "Visual Studio 15 2017" }
    "16" { $generator = "Visual Studio 16 2019" }
    "17" { $generator = "Visual Studio 17 2022" }
    default { Log-Error "Unsupported VS_VERSION: $vsVersion" }
}

# Ensure the build directory exists
if (-not (Test-Path -Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
    Log-Info "Created build directory at $BuildDir"
}

# Run CMake to generate build files
Log-Info "Running CMake to generate build files..."
cmake -S "C:\app" -B $BuildDir -G "$generator" -A x64

# Build the project
Log-Info "Building the project..."
cmake --build $BuildDir --config $Config

Log-Info "Build process completed successfully."