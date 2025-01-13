# escape=

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

# ===================================================================
# Metadata
# ===================================================================
LABEL maintainer="jorge-kun@live.com" \
      description="Docker image for building and running CrossPlatformApp" \
      version="1.0.0" \
      repository="https://github.com/dreamjorge/CrossPlatformCPP-Docker" \
      documentation="https://github.com/dreamjorge/CrossPlatformCPP-Docker#readme" \
      issues="https://github.com/dreamjorge/CrossPlatformCPP-Docker/issues" \
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

# ===================================================================
# Set Shell to cmd
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Install Dependencies & Cleanup in One Layer
# ===================================================================
RUN mkdir C:\TEMP && \
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
         Invoke-WebRequest -Uri %CHANNEL_URL% -OutFile C:\TEMP\VisualStudio.chman; ^
         Invoke-WebRequest -Uri %VS_BUILD_TOOLS_URL% -OutFile C:\TEMP\vs_buildtools.exe; ^
         [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; ^
         iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && ^
    choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y && ^
    C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache ^
       --channelUri C:\TEMP\VisualStudio.chman ^
       --installChannelUri C:\TEMP\VisualStudio.chman ^
       --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended ^
       --installPath %BUILD_TOOLS_PATH% && ^
    rem -- Cleanup: remove installers, caches, logs, etc. -- && ^
    rmdir /S /Q C:\TEMP && ^
    rmdir /S /Q C:\ProgramData\chocolatey\logs && ^
    rmdir /S /Q C:\ProgramData\chocolatey\cache && ^
    powershell Remove-Item -Recurse -Force $env:TMP\* || echo "No TMP files" && ^
    powershell Remove-Item -Recurse -Force $env:TEMP\* || echo "No TEMP files"

# ===================================================================
# (Optional) Further Cleanup with DISM (test carefully)
# ===================================================================
# RUN dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR %BUILD_DIR%

# ===================================================================
# Copy Scripts
# ===================================================================
COPY scripts/windows C:\scripts\windows

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]
