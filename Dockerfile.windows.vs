# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

# ===================================================================
# Metadata
# ===================================================================
LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building CrossPlatformApp with Visual Studio" `
      version="1.0.0"

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.26.4
ARG CMAKE_DOWNLOAD_URL=https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-windows-x86_64.zip
ARG VS_CHANNEL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe

# ===================================================================
# Environment Variables
# ===================================================================
ENV TEMP_DIR=C:\TEMP
ENV CMAKE_INSTALL_PATH="C:\Program Files\CMake"
ENV BUILD_TOOLS_PATH=C:\BuildTools
ENV BUILD_DIR=C:\app

# ===================================================================
# Set Shell to cmd
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Debug Arguments and Validate Inputs
# ===================================================================
# Print ARG values for debugging
RUN echo "CMAKE_VERSION=${CMAKE_VERSION}" && \
    echo "CMAKE_DOWNLOAD_URL=${CMAKE_DOWNLOAD_URL}" && \
    echo "VS_CHANNEL=${VS_CHANNEL}" && \
    echo "VS_BUILD_TOOLS_URL=${VS_BUILD_TOOLS_URL}"

# Validate ARG values to prevent empty inputs
RUN if "%CMAKE_DOWNLOAD_URL%"=="" (echo "Error: CMAKE_DOWNLOAD_URL is not set" && exit 1) && \
    if "%VS_CHANNEL%"=="" (echo "Error: VS_CHANNEL is not set" && exit 1) && \
    if "%VS_BUILD_TOOLS_URL%"=="" (echo "Error: VS_BUILD_TOOLS_URL is not set" && exit 1)

# ===================================================================
# Download and Install Visual Studio Build Tools and CMake
# ===================================================================
RUN mkdir %TEMP_DIR% && \
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %VS_CHANNEL% -OutFile %TEMP_DIR%\VisualStudio.chman" && \
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %VS_BUILD_TOOLS_URL% -OutFile %TEMP_DIR%\vs_buildtools.exe" && \
    %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri %TEMP_DIR%\VisualStudio.chman `
    --installChannelUri %TEMP_DIR%\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath %BUILD_TOOLS_PATH% && \
    powershell -Command "
    Try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
        Write-Host 'Downloading CMake from ${CMAKE_DOWNLOAD_URL}';
        Invoke-WebRequest -Uri ${CMAKE_DOWNLOAD_URL} -OutFile %TEMP_DIR%\cmake.zip;
    } Catch {
        Write-Error 'Failed to download CMake. Check URL or network connectivity.';
        Exit 1;
    }" && \
    powershell -Command "Expand-Archive -Path %TEMP_DIR%\cmake.zip -DestinationPath %TEMP_DIR%\cmake" && \
    move %TEMP_DIR%\cmake\cmake-${CMAKE_VERSION}-windows-x86_64\* %CMAKE_INSTALL_PATH% && \
    setx /M PATH "%PATH%;%CMAKE_INSTALL_PATH%\bin" && \
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
