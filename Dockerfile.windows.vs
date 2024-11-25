# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS base

# ===================================================================
# Stage: Visual Studio 2019 Build Environment
# ===================================================================
FROM base AS vs19

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    VS_BUILDTOOLS_PATH="C:\BuildTools" `
    TEMP_DIR="C:\TEMP"

# ===================================================================
# Copy and Execute PowerShell Script
# ===================================================================
COPY scripts/windows/install-tools.ps1 C:\TEMP\install-tools.ps1

RUN powershell -NoProfile -ExecutionPolicy Bypass -File C:\TEMP\install-tools.ps1

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\app

# ===================================================================
# Default Command
# ===================================================================
CMD ["powershell.exe"]