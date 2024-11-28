# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Arguments for Visual Studio version and CMake version
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.26.4

# Set environment variables for Visual Studio paths
ENV INSTALL_PATH="C:\Program Files (x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools"
ENV PATH="$INSTALL_PATH\Common7\Tools;C:\Program Files\CMake\bin;$PATH"

# Copy the installation scripts to the container
COPY scripts/windows/install_vs_buildtools.ps1 C:\TEMP\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake.ps1 C:\TEMP\install_cmake.ps1

# Install Visual Studio Build Tools
RUN powershell -ExecutionPolicy Bypass -File C:\TEMP\install_vs_buildtools.ps1 -VS_VERSION ${VS_VERSION}

# Install CMake
RUN powershell -ExecutionPolicy Bypass -File C:\TEMP\install_cmake.ps1 -CMAKE_VERSION ${CMAKE_VERSION}

# Cleanup the temporary files
RUN del /q C:\TEMP\install_vs_buildtools.ps1 C:\TEMP\install_cmake.ps1

# Define the entry point for the Docker container
ENTRYPOINT ["cmd.exe", "/k", "C:\\Program Files (x86)\\Microsoft Visual Studio\\16\\BuildTools\\Common7\\Tools\\VsDevCmd.bat"]