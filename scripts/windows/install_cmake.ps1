param(
    [string]$CMAKE_VERSION
)

Write-Host "Installing CMake version: $CMAKE_VERSION"

# Define the installer URL
$cmakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
$installerPath = "C:\temp\cmake_installer.msi"

# Ensure the temp directory exists
if (!(Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the installer
Write-Host "Downloading CMake from $cmakeInstallerUrl"
Invoke-WebRequest -Uri $cmakeInstallerUrl -OutFile $installerPath -UseBasicParsing

# Install CMake
Write-Host "Installing CMake..."
Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet /norestart" -NoNewWindow -Wait

# Verify Installation
$cmakePath = "C:\Program Files\CMake\bin\cmake.exe"
if (Test-Path $cmakePath) {
    Write-Host "CMake installed successfully at $cmakePath"
} else {
    throw "CMake installation failed. Executable not found at $cmakePath."
}
