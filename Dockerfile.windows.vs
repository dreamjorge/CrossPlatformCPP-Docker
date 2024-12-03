# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# ===================================================================
# Metadata
# ===================================================================
LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building and running CrossPlatformApp" `
      version="1.0.0" `
      repository="https://github.com/dreamjorge/CrossPlatformCPP-Docker" `
      documentation="https://github.com/dreamjorge/CrossPlatformCPP-Docker#readme" `
      issues="https://github.com/dreamjorge/CrossPlatformCPP-Docker/issues" `
      license="MIT"

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_VERSION=16
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
ENV BUILD_TOOLS_PATH=C:\BuildTools
ENV TEMP_DIR=C:\TEMP
ENV CMAKE_DIR=C:\CMake
ENV PATH="C:\\Windows\\System32;C:\\Program Files\\PowerShell;C:\\ProgramData\\chocolatey\\bin;C:\\CMake\\bin;%BUILD_TOOLS_PATH%\\VC\\Auxiliary\\Build;%PATH%"

# ===================================================================
# Set Shell to cmd
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Create Temporary Directory for Downloads
# ===================================================================
RUN mkdir %TEMP_DIR%

# ===================================================================
# Install Chocolatey Package Manager
# ===================================================================
RUN "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command " `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

# ===================================================================
# Install CMake via Chocolatey
# ===================================================================
RUN choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y

# ===================================================================
# Download and Install Visual Studio Build Tools
# ===================================================================
RUN "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" -NoProfile -Command " `
    Write-Output '[LOG] Downloading Visual Studio installer...'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri '%CHANNEL_URL%' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; `
    Invoke-WebRequest -Uri '%VS_BUILD_TOOLS_URL%' -OutFile '%TEMP_DIR%\\vs_buildtools.exe'; `
    Write-Output '[LOG] Installing Visual Studio Build Tools silently...'; `
    switch ('%VS_VERSION%') { `
        '15' { $sdk = 'Microsoft.VisualStudio.Component.Windows10SDK.17763' } `
        '16' { $sdk = 'Microsoft.VisualStudio.Component.Windows10SDK.18362' } `
        '17' { $sdk = 'Microsoft.VisualStudio.Component.Windows10SDK.19041' } `
        default { Write-Error 'Invalid VS_VERSION'; exit 1 } `
    }; `
    & '%TEMP_DIR%\\vs_buildtools.exe' --quiet --wait --norestart `
        --channelUri '%TEMP_DIR%\\VisualStudio.chman' `
        --installChannelUri '%TEMP_DIR%\\VisualStudio.chman' `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add $sdk `
        --installPath '%BUILD_TOOLS_PATH%' `
        --noUpdateInstaller; `
    if (-Not (Test-Path '%BUILD_TOOLS_PATH%\VC\Auxiliary\Build\VsDevCmd.bat')) { `
        Write-Error 'VsDevCmd.bat not found!'; exit 1 }"

# ===================================================================
# Clean Up Temporary Files
# ===================================================================
RUN rmdir /S /Q %TEMP_DIR%

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\app

# ===================================================================
# Copy Scripts Directory
# ===================================================================
COPY scripts/windows C:\scripts\windows

# ===================================================================
# Default Command
# ===================================================================
ENTRYPOINT ["cmd.exe", "/C", "C:\\BuildTools\\VC\\Auxiliary\\Build\\VsDevCmd.bat && cmd"]
