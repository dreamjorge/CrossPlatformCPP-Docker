param(
    [string]$CMAKE_VERSION = "3.26.4"  # Default version of CMake to install
)

# Stop on all errors
$ErrorActionPreference = 'Stop'

# Construct the download URL
$url = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
Write-Host "Installing CMake version: $CMAKE_VERSION"
Write-Host "Constructed URL: $url"

# Download destination
$output = "C:\cmake_installer.msi"

# Download the installer
Write-Host "Downloading CMake from $url"
Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing

# Install CMake
Write-Host "Installing CMake..."
Start-Process msiexec.exe -ArgumentList "/i", $output, "/quiet", "/norestart" -NoNewWindow -Wait

# Check if the installation was successful
if (!(Test-Path "C:\Program Files\CMake\bin\cmake.exe")) {
    throw "CMake installation failed. Executable not found."
}

Write-Host "CMake installed successfully."

# Clean up installer
Remove-Item "C:\cmake_installer.msi" -Force

# Add CMake to the system PATH
$env:Path += ";C:\Program Files\CMake\bin"

# Output the updated PATH to verify
Write-Host "Updated PATH: $env:Path"

# Verify the CMake installation by checking its version
& "C:\Program Files\CMake\bin\cmake.exe" --version