# We do not need `# escape=` here because we are NOT using cmd.exe for line escapes.

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

LABEL maintainer="jorge-kun@live.com" `
      description="Docker image for building and running CrossPlatformApp" `
      version="1.0.0"

# -----------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------
ARG VS_VERSION=17
ARG CHANNEL_URL="https://aka.ms/vs/${VS_VERSION}/release/channel"
ARG VS_BUILD_TOOLS_URL="https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe"
ARG CMAKE_VERSION=3.21.3

# -----------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------
ENV BUILD_TOOLS_PATH="C:\BuildTools"
ENV BUILD_DIR="C:\app"
ENV TEMP_DIR="C:\TEMP"

# Preemptively define Chocolatey env so subsequent layers see 'choco' on PATH
ENV ChocolateyInstall="C:\ProgramData\chocolatey"
ENV PATH="$Env:ChocolateyInstall\bin;$Env:PATH"

# -----------------------------------------------------------------
# Switch the default Dockerfile shell to PowerShell
# -----------------------------------------------------------------
SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# -----------------------------------------------------------------
# 1) Create TEMP folder
# -----------------------------------------------------------------
RUN New-Item -ItemType Directory -Path $Env:TEMP_DIR -Force | Out-Null

# -----------------------------------------------------------------
# 2) Download Visual Studio Channel Manifest & Installer
# -----------------------------------------------------------------
RUN `
    [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri $Env:CHANNEL_URL -OutFile "$Env:TEMP_DIR\VisualStudio.chman"; `
    Invoke-WebRequest -Uri $Env:VS_BUILD_TOOLS_URL -OutFile "$Env:TEMP_DIR\vs_buildtools.exe"

# -----------------------------------------------------------------
# 3) Install Chocolatey
# -----------------------------------------------------------------
RUN `
    [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# -----------------------------------------------------------------
# 4) Install CMake via Chocolatey
# -----------------------------------------------------------------
RUN choco install cmake --version=$Env:CMAKE_VERSION --installargs 'ADD_CMAKE_TO_PATH=System' -y

# -----------------------------------------------------------------
# 5) Install Visual Studio Build Tools
# -----------------------------------------------------------------
RUN & "$Env:TEMP_DIR\vs_buildtools.exe" --quiet --wait --norestart --nocache `
    --channelUri "$Env:TEMP_DIR\VisualStudio.chman" `
    --installChannelUri "$Env:TEMP_DIR\VisualStudio.chman" `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath $Env:BUILD_TOOLS_PATH

# -----------------------------------------------------------------
# 6) Clean up
# -----------------------------------------------------------------
RUN Remove-Item -Recurse -Force $Env:TEMP_DIR -ErrorAction Ignore; `
    Remove-Item -Recurse -Force 'C:\ProgramData\chocolatey\logs' -ErrorAction Ignore; `
    Remove-Item -Recurse -Force 'C:\ProgramData\chocolatey\cache' -ErrorAction Ignore

# (Optional) Further reduce image size:
# RUN dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

# -----------------------------------------------------------------
# Set working directory and default command
# -----------------------------------------------------------------
WORKDIR $Env:BUILD_DIR
CMD ["powershell.exe"]
