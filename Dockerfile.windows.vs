# escape=`

# Use Base Image
FROM base AS vs_build

# Build Arguments
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    CHANNEL_URL=${CHANNEL_URL} `
    VS_BUILD_TOOLS_URL=${VS_BUILD_TOOLS_URL} `
    TEMP_DIR=C:\temp `
    CMAKE_PATH=C:\Program Files\CMake\bin\cmake.exe

# Create a temporary directory for downloads
RUN powershell -Command `
    if (!(Test-Path -Path $env:TEMP_DIR)) { `
        New-Item -ItemType Directory -Path $env:TEMP_DIR; `
    }

# Copy Installation Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake.ps1 C:\scripts\install_cmake.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Debugging: Verify Environment Variables
RUN echo "CHANNEL_URL=$CHANNEL_URL" && echo "VS_BUILD_TOOLS_URL=$VS_BUILD_TOOLS_URL"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1" `
    -VS_YEAR $env:VS_YEAR `
    -VS_VERSION $env:VS_VERSION `
    -CHANNEL_URL $env:CHANNEL_URL `
    -VS_BUILD_TOOLS_URL $env:VS_BUILD_TOOLS_URL

# Install CMake using the PowerShell script
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake.ps1" `
    -CMAKE_VERSION $env:CMAKE_VERSION

# Verify CMake Installation
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    Write-Host "Verifying CMake installation..."; `
    cmake --version

# Set Working Directory
WORKDIR C:\app

# Configure and Build with CMake
RUN powershell -Command `
    mkdir C:\build; `
    cd C:\build; `
    & "$env:CMAKE_PATH" `
        -G "Visual Studio $env:VS_VERSION Win64" `
        -DCMAKE_BUILD_TYPE=Release `
        -S C:\app `
        -B C:\build

RUN powershell -Command `
    cd C:\build; `
    & "$env:CMAKE_PATH" `
        --build C:\build `
        --config Release

# Default Command
CMD ["cmd.exe"]