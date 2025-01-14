# escape=`
# (This escape line ensures Docker understands the caret '^' as the line continuation in the Dockerfile.)

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

# ===================================================================
# Use cmd.exe Shell with ^ as the line continuation
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Download & Install Visual Studio Build Tools, CMake, Clean Up
# ===================================================================
RUN mkdir %TEMP_DIR% ` 
 && powershell -NoProfile -ExecutionPolicy Bypass -Command `
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
     Invoke-WebRequest -Uri '%CHANNEL_URL%' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; `
     Invoke-WebRequest -Uri '%VS_BUILD_TOOLS_URL%' -OutFile '%TEMP_DIR%\\vs_buildtools.exe'; `
     iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); `
    " `
 && choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y `
 && %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri %TEMP_DIR%\VisualStudio.chman `
    --installChannelUri %TEMP_DIR%\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath %BUILD_TOOLS_PATH% `
 && rmdir /S /Q %TEMP_DIR% `
 && rmdir /S /Q C:\ProgramData\chocolatey\logs `
 && rmdir /S /Q C:\ProgramData\chocolatey\cache

# ===================================================================
# (Optional) Additional DISM Cleanup
# ===================================================================
# RUN dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR %BUILD_DIR%

# ===================================================================
# Copy Scripts (If you have build.ps1, run.ps1, etc.)
# ===================================================================
COPY scripts/windows C:\scripts\windows

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]
