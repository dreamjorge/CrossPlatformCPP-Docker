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
    CMAKE_VERSION=${CMAKE_VERSION}

# Copy Installation Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:\scripts\install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:\app\scripts\windows\build.ps1
COPY scripts/windows/run.ps1 C:\app\scripts\windows\run.ps1

# Debugging: Verify Environment Variables
RUN powershell -Command "Write-Host 'VS_VERSION is' $env:VS_VERSION"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\install_vs_buildtools.ps1"

# Install CMake using the PowerShell script
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\install_cmake_bypass.ps1"

# Update PATH to include CMake
ENV PATH="C:\\cmake\\bin;${PATH}"

# Verify CMake Installation
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    cmake --version

# Set Working Directory
WORKDIR C:\app

# Default Command
CMD ["cmd.exe"]