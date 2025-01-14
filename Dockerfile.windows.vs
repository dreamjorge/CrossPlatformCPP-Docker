# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building and running CrossPlatformApp" `
      version="1.0.0"

#
# ------------------------------------------------------------------
# Build Arguments (one line each, no backticks needed)
# ------------------------------------------------------------------
ARG VS_VERSION=15
ARG CMAKE_VERSION=3.21.3

#
# ------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------
ENV BUILD_TOOLS_PATH="C:\BuildTools" `
    BUILD_DIR="C:\app" `
    TEMP_DIR="C:\TEMP" `
    ChocolateyInstall="C:\ProgramData\chocolatey" `
    PATH="%ChocolateyInstall%\bin;%PATH%"

#
# ------------------------------------------------------------------
# We stick with cmd.exe as shell, but Docker uses backticks (\`) for
# line continuation in Docker instructions (like RUN).
# ------------------------------------------------------------------
SHELL ["cmd", "/S", "/C"]

#
# ------------------------------------------------------------------
# 1) Create TEMP folder, download VS Build Tools + Chocolatey installer,
#    install CMake, install VS Build Tools, and clean up.
# ------------------------------------------------------------------
RUN mkdir %TEMP_DIR% `
 && powershell -NoProfile -ExecutionPolicy Bypass -Command `
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
     Invoke-WebRequest -Uri 'https://aka.ms/vs/%VS_VERSION%/release/channel' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; `
     Invoke-WebRequest -Uri 'https://aka.ms/vs/%VS_VERSION%/release/vs_buildtools.exe' -OutFile '%TEMP_DIR%\\vs_buildtools.exe'; `
     iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));" `
 && choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y `
 && %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri %TEMP_DIR%\VisualStudio.chman `
    --installChannelUri %TEMP_DIR%\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath %BUILD_TOOLS_PATH% `
 && rmdir /S /Q %TEMP_DIR% `
 && rmdir /S /Q C:\ProgramData\chocolatey\logs `
 && rmdir /S /Q C:\ProgramData\chocolatey\cache

#
# ------------------------------------------------------------------
# (Optional) Additional DISM Cleanup to reduce image size
# ------------------------------------------------------------------
# RUN dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

#
# ------------------------------------------------------------------
# Working Directory & Default Command
# ------------------------------------------------------------------
WORKDIR %BUILD_DIR%
CMD ["cmd.exe"]
