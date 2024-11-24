# Install CMake using bypass method
param(
    [string]$env:CMAKE_VERSION
)

Write-Host "Installing CMake version: $($env:CMAKE_VERSION)"

# Define the installer URL
$cmakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$($env:CMAKE_VERSION)/cmake-$($env:CMAKE_VERSION)-windows-x86_64.msi"
$installerPath = "C:\temp\cmake_installer.msi"

# Download the installer
Invoke-WebRequest -Uri $cmakeInstallerUrl -OutFile $installerPath

# Install CMake
Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet /norestart" -NoNewWindow -Wait

# Add CMake to the PATH
[Environment]::SetEnvironmentVariable("Path", $Env:Path + ";C:\Program Files\CMake\bin", [EnvironmentVariableTarget]::Machine)