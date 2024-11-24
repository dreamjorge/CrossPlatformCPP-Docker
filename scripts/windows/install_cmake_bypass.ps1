param(
    [string]$CMAKE_VERSION
)

Write-Host "Installing CMake version: $CMAKE_VERSION"

# Define the download URL and path
$cmakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
$installerPath = "C:\temp\cmake_installer.msi"

# Download the installer
$retryCount = 3
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        Write-Host "Downloading CMake... Attempt $i"
        Invoke-WebRequest -Uri $cmakeInstallerUrl -OutFile $installerPath
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

# Add CMake to the PATH
Write-Host "Adding CMake to system PATH"
[Environment]::SetEnvironmentVariable("Path", $Env:Path + ";C:\Program Files\CMake\bin", [EnvironmentVariableTarget]::Machine)
