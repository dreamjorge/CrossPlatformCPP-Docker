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
ARG CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-windows-x86_64.zip

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
RUN echo "[LOG] Creating temporary directories..." && `
    mkdir %TEMP_DIR% && mkdir %CMAKE_DIR%

# ===================================================================
# Download and Install Tools
# ===================================================================
RUN echo "[LOG] Downloading Visual Studio installer and CMake..." && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri '%CHANNEL_URL%' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; `
    Invoke-WebRequest -Uri '%VS_BUILD_TOOLS_URL%' -OutFile '%TEMP_DIR%\\vs_buildtools.exe'; `
    Invoke-WebRequest -Uri '%CMAKE_URL%' -OutFile '%TEMP_DIR%\\cmake.zip'" && `
    echo "[LOG] Extracting CMake..." && `
    powershell -Command "Expand-Archive -Path '%TEMP_DIR%\\cmake.zip' -DestinationPath '%CMAKE_DIR%'" && `
    echo "[LOG] Adding CMake to PATH..." && `
    setx PATH "%CMAKE_DIR%\bin;%PATH%" && `
    echo "[LOG] Installing Visual Studio Build Tools silently..." && `
    "%TEMP_DIR%\\vs_buildtools.exe" --quiet --wait --norestart `
        --channelUri "%TEMP_DIR%\\VisualStudio.chman" `
        --installChannelUri "%TEMP_DIR%\\VisualStudio.chman" `
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
        --installPath "%BUILD_TOOLS_PATH%" `
        --noUpdateInstaller && `
    echo "[LOG] Verifying VsDevCmd.bat location..." && `
    dir "%BUILD_TOOLS_PATH%\VC\Auxiliary\Build\VsDevCmd.bat"

# ===================================================================
# Set System PATH
# ===================================================================
ENV PATH="C:\\CMake\\bin;%PATH%"


# ===================================================================
# Clean Up Temporary Files
# ===================================================================
RUN echo "[LOG] Cleaning up temporary files..." && `
    powershell -Command "Remove-Item -Recurse -Force '%TEMP_DIR%'"

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\app

# ===================================================================
# Copy Scripts Directory
# ===================================================================
COPY scripts/windows C:\app\scripts\windows

# ===================================================================
# Verify Copied Scripts
# ===================================================================
RUN echo "[LOG] Verifying copied scripts directory:" && `
    dir C:\app\scripts\windows

# ===================================================================
# Verify BUILD_DIR Environment Variable
# ===================================================================
RUN echo "[LOG] Verifying BUILD_DIR environment variable:" && `
    echo BUILD_DIR=%BUILD_DIR%

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]
