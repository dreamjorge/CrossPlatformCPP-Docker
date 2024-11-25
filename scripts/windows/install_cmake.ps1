param(
    [string]$CMAKE_VERSION
)

Write-Host "Installing CMake version: $CMAKE_VERSION"

# Define the installer URL
$cmakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
$installerPath = "C:\temp\cmake_installer.msi"

# Ensure the directory exists
if (!(Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Download the installer
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "Downloading CMake... Attempt $i"
        Invoke-WebRequest -Uri $cmakeInstallerUrl -OutFile $installerPath
        if (Test-Path $installerPath) {
            Write-Host "Download successful!"
            break
        }
    } catch {
        Write-Host "Download failed. Retrying..."
        if ($i -eq $retryCount) {
            throw "Failed to download CMake after $retryCount attempts."
        }
    }
}

# Install CMake
if (Test-Path $installerPath) {
    Write-Host "Installing CMake..."
    Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet /norestart" -NoNewWindow -Wait
} else {
    throw "In
