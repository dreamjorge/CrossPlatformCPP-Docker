# escape=`

# Use the official Microsoft Windows Server Core image as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS vs_build

# Build Arguments
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# Set Environment Variables
ENV VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    # Predefine the installation directory for Visual Studio Build Tools
    VS_BUILDTOOLS_PATH="C:\BuildTools"

# Install Visual Studio Build Tools with C++ workload
SHELL ["cmd", "/S", "/C"]

# Download and install Visual Studio Build Tools
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath "%VS_BUILDTOOLS_PATH%" `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --includeRecommended `
    --includeOptional `
    --lang en-US `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Clean up the installer
RUN del /Q /F C:\TEMP\vs_buildtools.exe

# Install CMake
SHELL ["powershell", "-NoProfile", "-Command"]

RUN $ErrorActionPreference = 'Stop'; `
    Write-Host "Installing CMake version $env:CMAKE_VERSION"; `
    $cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v$($env:CMAKE_VERSION)/cmake-$($env:CMAKE_VERSION)-windows-x86_64.msi"; `
    $installerPath = "C:\\TEMP\\cmake.msi"; `
    Invoke-WebRequest -Uri $cmakeUrl -OutFile $installerPath; `
    Start-Process msiexec.exe -ArgumentList '/i', "`"$installerPath`"", '/quiet', '/qn', '/norestart' -Wait; `
    Remove-Item -Path $installerPath -Force; `
    [Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\\Program Files\\CMake\\bin', [EnvironmentVariableTarget]::Machine); `
    Write-Host "CMake installation completed successfully."

# Copy Scripts
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Set Working Directory
WORKDIR C:/app

# Default Command
CMD ["cmd.exe"]