# Install CMake using bypass method
param(
    [string]$env:CMAKE_VERSION
)

Write-Host "Installing CMake version: $($env:CMAKE_VERSION)"

# Example installation logic
$cmakeInstallerUrl = "https://cmake.org/files/v$($env:CMAKE_VERSION.Substring(0, 4))/cmake-$($env:CMAKE_VERSION)-win64-x64.msi"
$installerPath = "C:\temp\cmake_installer.msi"

Invoke-WebRequest -Uri $cmakeInstallerUrl -OutFile $installerPath
Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet" -NoNewWindow -Wait