# escape=`

# ===================================================================
# Base Image
# ===================================================================
# Use the official Microsoft Windows Server Core image as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS base

# ===================================================================
# Stage: Visual Studio 2019 Build Environment
# ===================================================================
FROM base AS vs19

# ===================================================================
# Build Arguments
# ===================================================================
# These arguments specify Visual Studio and CMake versions,
# as well as the URLs for downloading necessary tools.
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
# Set environment variables for consistent setup.
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    CHANNEL_URL=${CHANNEL_URL} `
    VS_BUILD_TOOLS_URL=${VS_BUILD_TOOLS_URL} `
    VS_BUILDTOOLS_PATH="C:\\BuildTools"

# ===================================================================
# Copy Installation Scripts
# ===================================================================
# Copy PowerShell scripts for installing Visual Studio Build Tools and CMake,
# and additional scripts for building and running applications.
COPY scripts/windows/install_vs_buildtools.ps1 C:\\scripts\\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:\\scripts\\install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:\\app\\scripts\\windows\\build.ps1
COPY scripts/windows/run.ps1 C:\\app\\scripts\\windows\\run.ps1

# ===================================================================
# Debugging: Verify Environment Variables
# ===================================================================
# Output environment variables for debugging and validation.
RUN echo "CHANNEL_URL=${CHANNEL_URL}" && echo "VS_BUILD_TOOLS_URL=${VS_BUILD_TOOLS_URL}" && echo "CMAKE_VERSION=${CMAKE_VERSION}"

# ===================================================================
# Install Visual Studio Build Tools
# ===================================================================
# Install Visual Studio 2019 Build Tools with the C++ workload.
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1"

# ===================================================================
# Install CMake
# ===================================================================
# Install CMake using the provided PowerShell script.
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake_bypass.ps1"

# ===================================================================
# Verify CMake Installation
# ===================================================================
# Run a quick check to ensure CMake is installed and available in the PATH.
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    Write-Host "Verifying CMake installation..."; `
    cmake --version

# ===================================================================
# Set Working Directory
# ===================================================================
# Set the working directory to where application code will be copied and executed.
WORKDIR C:\\app

# ===================================================================
# Default Command
# ===================================================================
# Start a PowerShell prompt when the container runs.
CMD ["powershell.exe"]