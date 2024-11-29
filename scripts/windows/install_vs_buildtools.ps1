# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Install PowerShell
RUN curl -SL --output PowerShell-7.3.6-win-x64.msi https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/PowerShell-7.3.6-win-x64.msi `
    && start /wait msiexec /i PowerShell-7.3.6-win-x64.msi /quiet `
    && del PowerShell-7.3.6-win-x64.msi

# Set PowerShell path in the environment
ENV PATH="C:\\Program Files\\PowerShell\\7;$PATH"

# Arguments for build-time
ARG VS_VERSION=16
ARG VS_YEAR=2019
ARG CMAKE_VERSION=3.26.4

# Environment variables for runtime
ENV VS_VERSION=${VS_VERSION}
ENV VS_YEAR=${VS_YEAR}
ENV CMAKE_VERSION=${CMAKE_VERSION}

# Set environment variables for Visual Studio paths
ENV INSTALL_PATH="C:\Program Files (x86)\Microsoft Visual Studio\${VS_YEAR}\BuildTools"
ENV PATH="$INSTALL_PATH\Common7\Tools;C:\Program Files\CMake\bin;$PATH"

# Copy the installation scripts to the container
COPY scripts/windows/install_vs_buildtools.ps1 C:\TEMP\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake.ps1 C:\TEMP\install_cmake.ps1

# Install Visual Studio Build Tools
RUN pwsh -ExecutionPolicy Bypass -File C:\TEMP\install_vs_buildtools.ps1

# Install CMake
RUN pwsh -ExecutionPolicy Bypass -File C:\TEMP\install_cmake.ps1 -CMAKE_VERSION ${CMAKE_VERSION}

# Cleanup the temporary files
RUN del /q C:\TEMP\install_vs_buildtools.ps1 C:\TEMP\install_cmake.ps1

# Define the entry point for the Docker container
ENTRYPOINT ["cmd.exe", "/k", "C:\\Program Files (x86)\\Microsoft Visual Studio\\${VS_YEAR}\\BuildTools\\Common7\\Tools\\VsDevCmd.bat"]