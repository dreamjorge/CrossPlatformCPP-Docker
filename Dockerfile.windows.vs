# ===================================================================
# Base Image
# ===================================================================
FROM base AS vs19

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CHANNEL_URL=https://aka.ms/vs/${VS_YEAR}/release/channel
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION}

# ===================================================================
# Copy Installation Scripts
# ===================================================================
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake.ps1 C:\scripts\install_cmake.ps1
COPY scripts/windows/build.vs19.cmd C:\app\scripts\windows\build.vs19.cmd
COPY scripts/windows/run.cmd C:\app\scripts\windows\run.cmd

# ===================================================================
# Install Visual Studio Build Tools
# ===================================================================
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1" -VS_YEAR $env:VS_YEAR -VS_VERSION $env:VS_VERSION

# ===================================================================
# Install CMake
# ===================================================================
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake.ps1" -CMAKE_VERSION $env:CMAKE_VERSION

# ===================================================================
# Verify CMake Installation
# ===================================================================
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Verifying CMake installation...'; cmake --version"

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\app

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]
