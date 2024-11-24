# Build the project using CMake and Visual Studio
param(
    [string]$env:VS_YEAR,
    [string]$env:VS_VERSION
)

Write-Host "Configuring and Building project with Visual Studio $($env:VS_YEAR), Version $($env:VS_VERSION)"

# Create a build directory
$buildDir = "C:\build"
if (!(Test-Path -Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir
}

# Run CMake configuration
cmake -G "Visual Studio $($env:VS_VERSION) Win64" -DCMAKE_BUILD_TYPE=Release -S "C:\app" -B $buildDir

# Build the project
cmake --build $buildDir --config Release