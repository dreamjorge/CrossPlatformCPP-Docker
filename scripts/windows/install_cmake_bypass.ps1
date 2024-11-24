param(
    [string]$CMAKE_VERSION
)

# Resolve environment variable if argument is not provided
if (-not $CMAKE_VERSION) {
    $CMAKE_VERSION = $env:CMAKE_VERSION
}

Write-Host "Installing CMake version: $CMAKE_VERSION"

# Define download URL and path
$cmakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
$installerPath = "C:\temp\cmake_installer.msi"

Write-Host "CMake download URL: $cmakeInstallerUrl"

# Download the installer with retries
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "Downloading CMake... Attempt $i"
        Invoke-WebRequest -Uri $cmakeInstallerUrl -OutFile $installerPath -UseBasicParsing
        if ((Test-Path $installerPath) -and ((Get-Item $installerPath).Length -gt 0)) {
            Write-Host "Download successful!"
            break
        } else {
            throw "File appears to be empty or invalid."
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
    Start-Process msiexec.exe -ArgumentList `
        "/i $installerPath /quiet /norestart" `
        -NoNewWindow -Wait
} else {
    throw "Installer file not found at $installerPath."
}
