# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building and running CrossPlatformApp" `
      version="1.0.0"

# ------------------------------------------------------------------
# Build Arguments (keep each ARG on a single line)
# ------------------------------------------------------------------
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# ------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------
ENV BUILD_TOOLS_PATH="C:\BuildTools" `
    BUILD_DIR="C:\app" `
    TEMP_DIR="C:\TEMP" `
    ChocolateyInstall="C:\ProgramData\chocolatey" `
    PATH="%ChocolateyInstall%\bin;%PATH%"

# ------------------------------------------------------------------
# We'll continue using cmd.exe as our Docker shell
# and use '^' for line continuation.
# ------------------------------------------------------------------
SHELL ["cmd", "/S", "/C"]

# ------------------------------------------------------------------
# 1) Create TEMP folder, download vs_buildtools.exe & channel, 
#    install Chocolatey + CMake, install Build Tools, cleanup.
#    Key Fix: call PowerShell by full path.
# ------------------------------------------------------------------
RUN mkdir %TEMP_DIR% ^
 && C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
     Invoke-WebRequest -Uri 'https://aka.ms/vs/%VS_VERSION%/release/channel' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; ^
     Invoke-WebRequest -Uri 'https://aka.ms/vs/%VS_VERSION%/release/vs_buildtools.exe' -OutFile '%TEMP_DIR%\\vs_buildtools.exe'; ^
     iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));" ^
 && choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y ^
 && %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache ^
    --channelUri %TEMP_DIR%\VisualStudio.chman ^
    --installChannelUri %TEMP_DIR%\VisualStudio.chman ^
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended ^
    --installPath %BUILD_TOOLS_PATH% ^
 && rmdir /S /Q %TEMP_DIR% ^
 && rmdir /S /Q C:\ProgramData\chocolatey\logs ^
 && rmdir /S /Q C:\ProgramData\chocolatey\cache

# (Optional) Additional DISM Cleanup
# RUN dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

# ------------------------------------------------------------------
# Set Working Directory & Default Command
# ------------------------------------------------------------------
WORKDIR %BUILD_DIR%
CMD ["cmd.exe"]
