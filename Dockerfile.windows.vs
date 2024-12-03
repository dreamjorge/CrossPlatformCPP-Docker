# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

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
ARG VS_VERSION=17
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
ENV BUILD_TOOLS_PATH=C:\BuildTools
ENV BUILD_DIR=C:\app
ENV TEMP_DIR=C:\TEMP
ENV CMAKE_DIR=C:\CMake

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
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command " `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

# ===================================================================
# Install CMake via Chocolatey
# ===================================================================
RUN choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y

# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
RUN echo "[LOG] Downloading Visual Studio installer..." && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri '%CHANNEL_URL%' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; `
    Invoke-WebRequest -Uri '%VS_BUILD_TOOLS_URL%' -OutFile '%TEMP_DIR%\\vs_buildtools.exe'" && `
    echo "[LOG] Installing Visual Studio Build Tools silently..." && `
    "%TEMP_DIR%\\vs_buildtools.exe" --quiet --wait --norestart `
        --channelUri "%TEMP_DIR%\\VisualStudio.chman" `
        --installChannelUri "%TEMP_DIR%\\VisualStudio.chman" `
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --includeRecommended `
        --installPath "%BUILD_TOOLS_PATH%" `
        --noUpdateInstaller && `
    echo "[LOG] Verifying VsDevCmd.bat location..." && `
    dir "%BUILD_TOOLS_PATH%\VC\Auxiliary\Build\VsDevCmd.bat" || (echo "VsDevCmd.bat not found!" && exit /b 1)

# ===================================================================
# Clean Up Temporary Files
# ===================================================================
RUN rmdir /S /Q %TEMP_DIR%

# ===================================================================
# Set PATH to include CMake and Build Tools
# ===================================================================
ENV PATH="C:\\ProgramData\\chocolatey\\bin;C:\\CMake\\bin;%PATH%"

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\app

# ===================================================================
# Copy Scripts Directory
# ===================================================================
COPY scripts/windows C:\scripts\windows

# ===================================================================
# Verify BUILD_DIR Environment Variable
# ===================================================================
RUN echo BUILD_DIR=%BUILD_DIR%

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]
