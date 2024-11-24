# escape=`

# Use the official Microsoft .NET Framework SDK image as the base image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS vs_build

# Build Arguments
ARG CMAKE_VERSION=3.21.3

# Set Environment Variables
ENV CMAKE_VERSION=${CMAKE_VERSION}

# Copy Scripts
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake_bypass.ps1"

# Set Working Directory
WORKDIR C:/app

# Default Command
CMD ["cmd.exe"]