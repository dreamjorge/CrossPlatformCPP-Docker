# escape=`

# ===================================================================
# Base Image
# ===================================================================
ARG BASE_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022
FROM ${BASE_IMAGE}

# ===================================================================
# Metadata
# ===================================================================
LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building and running CrossPlatformApp using Visual Studio" `
      version="1.0.0"

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_VERSION=16
ARG VS_CHANNEL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.26.4
ARG CMAKE_DOWNLOAD_URL=https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-windows-x86_64.zip

# ===================================================================
# Environment Variables
# ===================================================================
ENV TEMP_DIR=C:\TEMP
ENV BUILD_TOOLS_PATH=C:\BuildTools
ENV CMAKE_INSTALL_PATH="C:\Program Files\CMake"
ENV BUILD_DIR=C:\app

# ===================================================================
# Set Shell to cmd
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Download and Install Visual Studio Build Tools and CMake
# ===================================================================
RUN mkdir %TEMP_DIR% && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %VS_CHANNEL% -OutFile %TEMP_DIR%\VisualStudio.chman" && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %VS_BUILD_TOOLS_URL% -OutFile %TEMP_DIR%\vs_buildtools.exe" && `
    %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri %TEMP_DIR%\VisualStudio.chman `
    --installChannelUri %TEMP_DIR%\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath %BUILD_TOOLS_PATH% && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri ${CMAKE_DOWNLOAD_URL} -OutFile %TEMP_DIR%\cmake.zip" && `
    powershell -Command "Expand-Archive -Path %TEMP_DIR%\cmake.zip -DestinationPath %TEMP_DIR%\cmake" && `
    move %TEMP_DIR%\cmake\cmake-${CMAKE_VERSION}-windows-x86_64\* %CMAKE_INSTALL_PATH% && `
    setx /M PATH "%PATH%;%CMAKE_INSTALL_PATH%\bin" && `
    rmdir /S /Q %TEMP_DIR%

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR %BUILD_DIR%

# ===================================================================
# Copy Project Files
# ===================================================================
COPY . .

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]