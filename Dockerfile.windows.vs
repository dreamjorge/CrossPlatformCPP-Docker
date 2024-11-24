# escape=`

# Use Base Image
FROM crossplatformapp-windows-base AS vs_build

# Build Arguments
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    TEMP_DIR=C:/temp

# Separate ENV for paths with spaces
ENV CMAKE_PATH="C:/Program Files/CMake/bin/cmake.exe"

# Create Temp Directory
RUN powershell -Command `
    if (!(Test-Path -Path $env:TEMP_DIR)) { `
        New-Item -ItemType Directory -Path $env:TEMP_DIR; `
    }

# Copy Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Debugging Environment Variables
RUN echo "VS_YEAR=$VS_YEAR" && echo "VS_VERSION=$VS_VERSION" && echo "CMAKE_PATH=$CMAKE_PATH"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    $vsYear = $env:VS_YEAR; `
    $vsVersion = $env:VS_VERSION; `
    & "C:\\scripts\\install_vs_buildtools.ps1" `
        -VS_YEAR $vsYear `
        -VS_VERSION $vsVersion

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    $cmakeVersion = $env:CMAKE_VERSION; `
    & "C:\\scripts\\install_cmake_bypass.ps1" `
        -CMAKE_VERSION $cmakeVersion

# Set Working Directory
WORKDIR C:/app

# Default Command
CMD ["cmd.exe"]
