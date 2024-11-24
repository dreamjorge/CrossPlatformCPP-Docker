# Use the correct base image for Windows Server 2022
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS base

# Install required Windows features
RUN powershell -Command `
    Install-WindowsFeature -Name NET-Framework-45-ASPNET; `
    Install-WindowsFeature -Name Web-Asp-Net45

# Define build arguments
ARG VS_YEAR=2017
ARG VS_VERSION=15
ARG CMAKE_VERSION=3.21.3

# Set environment variables
ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION} \
    TEMP_DIR=C:\\temp \
    CMAKE_PATH="C:\\Program Files\\CMake\\bin\\cmake.exe"

# Create a temporary directory for downloads
RUN powershell -Command `
    if (!(Test-Path -Path $env:TEMP_DIR)) { `
        New-Item -ItemType Directory -Path $env:TEMP_DIR; `
    }

# Copy installation scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1

# Install Visual Studio Build Tools
RUN powershell -ExecutionPolicy Bypass -File C:/scripts/install_vs_buildtools.ps1 `
    -VS_YEAR $env:VS_YEAR `
    -VS_VERSION $env:VS_VERSION

# Install CMake
RUN powershell -ExecutionPolicy Bypass -File C:/scripts/install_cmake_bypass.ps1 `
    -CMAKE_VERSION $env:CMAKE_VERSION

# Copy the application source code
COPY . C:/app

# Configure the build with CMake
RUN powershell -Command `
    mkdir C:\build; `
    cd C:\build; `
    & "$env:CMAKE_PATH" `
        -G "Visual Studio $env:VS_VERSION Win64" `
        -DCMAKE_BUILD_TYPE=Release `
        -S C:\app `
        -B C:\build

# Build the project
RUN powershell -Command `
    cd C:\build; `
    & "$env:CMAKE_PATH" `
        --build C:\build `
        --config Release

# Set the default command to execute the built application
CMD ["powershell", "C:/app/scripts/windows/run.ps1"]