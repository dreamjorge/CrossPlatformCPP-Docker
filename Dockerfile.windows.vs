# escape=`

# Use Base Image
FROM crossplatformapp-windows-base AS vs_build

# Build Arguments
ARG VS_YEAR=2017
ARG VS_VERSION=15
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    TEMP_DIR=C:/temp `
    CMAKE_PATH="C:/Program Files/CMake/bin/cmake.exe"

# Create Temp Directory
RUN powershell -Command `
    if (!(Test-Path -Path $env:TEMP_DIR)) { `
        New-Item -ItemType Directory -Path $env:TEMP_DIR; `
    }

# Copy Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1

# Debugging Environment Variables
RUN echo "VS_YEAR=$VS_YEAR" && echo "VS_VERSION=$VS_VERSION" && echo "CMAKE_PATH=$CMAKE_PATH"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1" `
    -VS_YEAR $env:VS_YEAR `
    -VS_VERSION $env:VS_VERSION

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake_bypass.ps1" `
    -CMAKE_VERSION $env:CMAKE_VERSION