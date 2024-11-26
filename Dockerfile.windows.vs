# ===================================================================
# Base Image
# ===================================================================
FROM base AS vs19

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.26.4

# ===================================================================
# Environment Variables
# ===================================================================
ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION}

# ===================================================================
# Install Visual Studio Build Tools
# ===================================================================
COPY ./scripts/windows/install_vs_buildtools.ps1 /scripts/install_vs_buildtools.ps1
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1"

# ===================================================================
# Install CMake
# ===================================================================
RUN powershell -Command `
    $ErrorActionPreference = 'Stop'; `
    Invoke-WebRequest -Uri "https://github.com/Kitware/CMake/releases/download/v$env:CMAKE_VERSION/cmake-$env:CMAKE_VERSION-windows-x86_64.msi" -OutFile "C:\\cmake_installer.msi"; `
    Start-Process msiexec.exe -ArgumentList "/i C:\\cmake_installer.msi /quiet /norestart" -NoNewWindow -Wait; `
    if (!(Test-Path "C:\\Program Files\\CMake\\bin\\cmake.exe")) { `
        throw "CMake installation failed. Executable not found."; `
    } `
    Write-Host "CMake installed successfully."

# ===================================================================
# Verify CMake Installation
# ===================================================================
RUN powershell -Command "C:\\Program Files\\CMake\\bin\\cmake.exe --version"

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\\app

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]