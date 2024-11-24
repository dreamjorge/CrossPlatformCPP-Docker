# escape=`

# Base Image
FROM crossplatformapp-windows-base AS vs_build

# Build Arguments
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION}

# Copy Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:\scripts\install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:\app\scripts\windows\build.ps1
COPY scripts/windows/run.ps1 C:\app\scripts\windows\run.ps1

# Debugging: Verify Environment Variables
RUN powershell -Command `
    Write-Host "VS_VERSION is $env:VS_VERSION"; `
    Write-Host "VS_YEAR is $env:VS_YEAR"; `
    Write-Host "CMAKE_VERSION is $env:CMAKE_VERSION"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\install_vs_buildtools.ps1"

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\install_cmake_bypass.ps1"

# Detect MSVC Version and Set Environment Variable
RUN powershell -Command `
    try