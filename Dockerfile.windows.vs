# escape=`

# Use the official Microsoft Windows Server Core image as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS vs_build

# Build Arguments
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# Set Environment Variables
ENV VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    VS_BUILDTOOLS_PATH="C:\BuildTools"

# Install Visual Studio Build Tools with C++ workload
SHELL ["cmd", "/S", "/C"]

# Download Visual Studio Build Tools and vswhere.exe
ADD https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
ADD https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe C:\TEMP\vswhere.exe

# Install Visual Studio Build Tools
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache ^
    --installPath "%VS_BUILDTOOLS_PATH%" ^
    --add Microsoft.VisualStudio.Workload.VCTools ^
    --includeRecommended ^
    --includeOptional ^
    --lang en-US ^
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Verify Visual Studio Build Tools installation
RUN C:\TEMP\vswhere.exe -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath || (echo "Visual Studio Build Tools installation failed" & exit 1)

# Clean up the installer
RUN del /Q /F C:\TEMP\vs_buildtools.exe
RUN del /Q /F C:\TEMP\vswhere.exe

# Change the shell back to PowerShell for the rest of the Dockerfile
SHELL ["powershell", "-NoProfile", "-Command"]

# Copy Scripts
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Install CMake using the existing script
RUN $ErrorActionPreference = 'Stop'; `
    .\scripts\install_cmake_bypass.ps1

# Set Working Directory
WORKDIR C:/app

# Default Command
CMD ["cmd.exe"]