param(
    [string]$CMAKE_VERSION = "3.26.4"  # Default version of CMake to install
)

# Stop on all errors
$ErrorActionPreference = 'Stop'

# Construct the download URL
$url = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
$output = "C:\TEMP\cmake_installer.msi"

Write-Host "Installing CMake version: $CMAKE_VERSION"
Write-Host "Constructed URL: $url"

# Retry logic for downloading CMake
$maxRetries = 3
$retryCount = 0
$downloadSuccess = $false

while (-not $downloadSuccess -and $retryCount -lt $maxRetries) {
    try {
        $retryCount++
        Write-Host "Attempt $retryCount: Downloading CMake from $url..."
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        $downloadSuccess = $true
    } catch {
        Write-Warning "Attempt $retryCount failed: $($_.Exception.Message)"
        Start-Sleep -Seconds 5
    }
}

if (-not $downloadSuccess) {
    throw "Failed to download CMake after $maxRetries attempts. Exiting."
}

Write-Host "CMake downloaded successfully to $output."

# Install CMake
Write-Host "Installing CMake..."
Start-Process msiexec.exe -ArgumentList "/i", $output, "/quiet", "/norestart" -NoNewWindow -Wait

# Verify installation
if (!(Test-Path "C:\Program Files\CMake\bin\cmake.exe")) {
    throw "CMake installation failed. Executable not found."
}

Write-Host "CMake installed successfully."

# Clean up installer
Remove-Item $output -Force

# Add CMake to the system PATH
$env:Path += ";C:\Program Files\CMake\bin"

# Output the updated PATH to verify
Write-Host "Updated PATH: $env:Path"

# Verify the CMake installation by checking its version
& "C:\Program Files\CMake\bin\cmake.exe" --version