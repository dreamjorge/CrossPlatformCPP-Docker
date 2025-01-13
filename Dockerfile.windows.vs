# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS builder

# ===================================================================
# Metadata
# ===================================================================
LABEL maintainer="jorge-kun@live.com" `
      description="Minimal Docker image for building C++ projects" `
      version="1.0.0"

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
ENV TEMP_DIR=C:\TEMP

# ===================================================================
# Set Shell to cmd
# ===================================================================
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Install Visual Studio Build Tools and CMake
# ===================================================================
RUN mkdir %TEMP_DIR% && `
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri %CHANNEL_URL% -OutFile %TEMP_DIR%\VisualStudio.chman; `
    Invoke-WebRequest -Uri %VS_BUILD_TOOLS_URL% -OutFile %TEMP_DIR%\vs_buildtools.exe" && `
    %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache `
        --channelUri %TEMP_DIR%\VisualStudio.chman `
        --installChannelUri %TEMP_DIR%\VisualStudio.chman `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --installPath %BUILD_TOOLS_PATH% && `
    powershell -NoProfile -ExecutionPolicy Bypass -Command " `
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; `
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && `
    choco install cmake --version=%CMAKE_VERSION% --installargs 'ADD_CMAKE_TO_PATH=System' -y && `
    rmdir /S /Q %TEMP_DIR%

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\build

# ===================================================================
# Copy Project Files
# ===================================================================
COPY . .

# Generate Visual Studio solution file
RUN cmake -G "Visual Studio 17 2022" -A x64 . && `
    if not exist MyProject.sln ( echo ERROR: MyProject.sln not generated && exit /b 1 )

# ===================================================================
# Build C++ Project
# ===================================================================
RUN "C:\BuildTools\VC\Auxiliary\Build\vcvars64.bat" && `
    msbuild /p:Configuration=Release /p:Platform=x64 MyProject.sln

# ===================================================================
# Runtime Stage
# ===================================================================
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS runtime

# Copy compiled binaries from the build stage
COPY --from=builder C:\build\bin\Release C:\app

# Set working directory and default command
WORKDIR C:\app
CMD ["MyProject.exe"]
