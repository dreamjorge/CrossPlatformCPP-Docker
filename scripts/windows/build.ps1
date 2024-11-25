param(
    [string]$CONFIG = "Release",
    [string]$VS_VERSION = "16"
)

# Validate required parameters
if (-not $VS_VERSION) {
    throw "Visual Studio version is not specified. Please provide -VS_VERSION parameter or set the VS_VERSION environment variable."
}

Write-Host "Configuring and Building project with Visual Studio $VS_VERSION"

# Set the generator name based on VS_VERSION
switch ($VS_VERSION) {
    "16" { $generatorName = "Visual Studio 16 2019" }
    "17" { $generatorName = "Visual Studio 17 2022" }
    default { throw "Unsupported Visual Studio version: $VS_VERSION" }
}

Write-Host "Using CMake generator: $generatorName"

# Create build directory
$buildDir = "C:\build"
if (-not (Test-Path -Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Navigate to build directory
Set-Location $buildDir

# Run CMake to configure the project
cmake -G "$generatorName" -A x64 -DCMAKE_BUILD_TYPE=$CONFIG C:\app

# Build the project
cmake --build . --config $CONFIG