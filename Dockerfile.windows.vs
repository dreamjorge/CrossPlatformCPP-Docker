# Use the correct base image for the host operating system
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS crossplatformapp-windows-base

# Install required features
RUN powershell -Command \
    Install-WindowsFeature -Name NET-Framework-45-ASPNET; \
    Install-WindowsFeature -Name Web-Asp-Net45

# Add build arguments
ARG VS_YEAR=2017
ARG VS_VERSION=15
ARG CMAKE_VERSION=3.21.3

# Set environment variables
ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION}

# Copy necessary scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Print environment variables for debugging