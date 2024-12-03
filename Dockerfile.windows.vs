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
ARG VS_VERSION=17
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3
ARG CMAKE_DOWNLOAD_URL=https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-windows-x86_64.zip

# ===================================================================
# Environment Variables
# ===================================================================
ENV BUILD_TOOLS_PATH=C:\BuildTools
ENV BUILD_DIR=C:\app
ENV TEMP_DIR=C:\TEMP
ENV CMAKE_HOME=C:\CMake

# ===================================================================
# Set Shell to cmd
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Create Temporary Directory for Downloads
# ===================================================================
RUN mkdir %TEMP_DIR%

# ===================================================================
# Download Visual Studio Channel and Installer
# ===================================================================
RUN powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %CHANNEL_URL% -OutFile %TEMP_DIR%\VisualStudio.chman" && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %VS_BUILD_TOOLS_URL% -OutFile %TEMP_DIR%\vs_buildtools.exe"

# ===================================================================
# Download and Install CMake
# ===================================================================
RUN powershell -Command "`
    $ErrorActionPreference = 'Stop'; `
    Invoke-WebRequest -Uri %CMAKE_DOWNLOAD_URL% -OutFile %TEMP_DIR%\cmake.zip" && `
    powershell -Command "`
    Expand-Archive -Path %TEMP_DIR%\cmake.zip -DestinationPath %CMAKE_HOME%" && `
    setx /M PATH "%PATH%;%CMAKE_HOME%\bin"

# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
RUN %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri %TEMP_DIR%\VisualStudio.chman `
    --installChannelUri %TEMP_DIR%\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath %BUILD_TOOLS_PATH%

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
# Verify BUILD_DIR Environment Variable
# ===================================================================
RUN echo BUILD_DIR=%BUILD_DIR%

# ===================================================================
# Default Command
# ===================================================================
#ENTRYPOINT ["cmd.exe", "/C", "C:\BuildTools\Common7\Tools\VsDevCmd.bat && cmd"]
