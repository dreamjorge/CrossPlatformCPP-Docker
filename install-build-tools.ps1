# install-build-tools.ps1

# Create TEMP directory for downloads; use -Force to avoid errors if it exists
New-Item -ItemType Directory -Path C:\TEMP -Force

# Download Visual Studio channel manifest and Build Tools installer
Invoke-WebRequest -Uri $env:CHANNEL_URL -OutFile C:\TEMP\VisualStudio.chman
Invoke-WebRequest -Uri $env:VS_BUILD_TOOLS_URL -OutFile C:\TEMP\vs_buildtools.exe

# Install Visual Studio Build Tools with the C++ workload
C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --includeRecommended `
    --installPath "C:\BuildTools"

# Download CMake ZIP installer
Invoke-WebRequest -Uri $env:CMAKE_INSTALLER_URL -OutFile C:\TEMP\cmake.zip

# Extract CMake ZIP to "C:\Program Files"
Expand-Archive -Path C:\TEMP\cmake.zip -DestinationPath "C:\Program Files" -Force

# Add CMake to PATH
$env:PATH = "C:\Program Files\cmake-${env:CMAKE_VERSION}-windows-x86_64\bin;" + $env:PATH

# Clean up TEMP directory and CMake ZIP installer
Remove-Item -Recurse -Force C:\TEMP

# Verify that VsDevCmd.bat exists at the expected path
if (-Not (Test-Path "C:\BuildTools\Common7\Tools\VsDevCmd.bat")) {
    Write-Error "VsDevCmd.bat not found at C:\BuildTools\Common7\Tools\VsDevCmd.bat"
}