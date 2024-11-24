# Use the correct base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS crossplatformapp-windows-base

# Install dependencies
RUN powershell -Command \
    Install-WindowsFeature -Name NET-Framework-45-ASPNET; \
    Install-WindowsFeature -Name Web-Asp-Net45

# Build arguments
ARG VS_YEAR=2017
ARG VS_VERSION=15
ARG CMAKE_VERSION=3.21.3

# Environment variables
ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION}

# Install Visual Studio Build Tools and CMake
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1

RUN powershell -ExecutionPolicy Bypass -File C:/scripts/install_vs_buildtools.ps1
RUN powershell -ExecutionPolicy Bypass -File C:/scripts/install_cmake_bypass.ps1

# Copy the source code and scripts
COPY . C:/app

# Configure the build with CMake
RUN powershell -Command `
    mkdir C:\build; `
    cd C:\build; `
    cmake -G "Visual Studio $($env:VS_VERSION) Win64" -DCMAKE_BUILD_TYPE=Release C:/app

# Compile the project
RUN powershell -Command `
    cd C:\build; `
    cmake --build . --config Release

# Set the default command to run the application
CMD ["powershell", "C:/app/scripts/windows/run.ps1"]