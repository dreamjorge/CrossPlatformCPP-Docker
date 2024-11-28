# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Copy the CMake installation script to the container.
COPY scripts/windows/install_cmake.ps1 C:\TEMP\install_cmake.ps1

# Argument to specify the CMake version.
ARG CMAKE_VERSION="3.26.4"
ENV CMAKE_VERSION=${CMAKE_VERSION}

# Step 1: Run the CMake installation script.
RUN powershell -ExecutionPolicy Bypass -File C:\TEMP\install_cmake.ps1

# Step 2: Clean up the installation script.
RUN del /q C:\TEMP\install_cmake.ps1

# Set up environment variables for the developer command prompt.
ENV PATH="C:\Program Files\CMake\bin;%PATH%"

# Define the entry point for the Docker container.
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]