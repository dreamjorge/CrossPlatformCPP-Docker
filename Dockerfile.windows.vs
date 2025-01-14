# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building and running CrossPlatformApp" `
      version="1.0.0"

ARG VS_VERSION=17
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

ENV BUILD_TOOLS_PATH=C:\BuildTools
ENV BUILD_DIR=C:\app
ENV TEMP_DIR=C:\TEMP

# Setting these environment variables ensures that any new shell session in subsequent layers
# will automatically know about Chocolatey.
ENV ChocolateyInstall="C:\ProgramData\chocolatey"
ENV PATH="%ChocolateyInstall%\bin;%PATH%"

SHELL ["cmd", "/S", "/C"]

# 1) Create temp folder and download files
RUN mkdir %TEMP_DIR% ` 
 && powershell -NoProfile -ExecutionPolicy Bypass -Command `
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
     Invoke-WebRequest -Uri '%CHANNEL_URL%' -OutFile '%TEMP_DIR%\\VisualStudio.chman'; `
     Invoke-WebRequest -Uri '%VS_BUILD_TOOLS_URL%' -OutFile '%TEMP_DIR%\\vs_buildtools.exe';"

# 2) Install Chocolatey (and set up environment)
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command- `
    "[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
     iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));"

# 3) Install CMake via Chocolatey
RUN choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y

# 4) Install Visual Studio Build Tools
RUN %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri %TEMP_DIR%\VisualStudio.chman `
    --installChannelUri %TEMP_DIR%\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath %BUILD_TOOLS_PATH%

# 5) Cleanup
RUN rmdir /S /Q %TEMP_DIR% ` 
 && rmdir /S /Q C:\ProgramData\chocolatey\logs ` 
 && rmdir /S /Q C:\ProgramData\chocolatey\cache

# (Optional) More cleanup with DISM
# RUN dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

WORKDIR %BUILD_DIR%
CMD ["cmd.exe"]
