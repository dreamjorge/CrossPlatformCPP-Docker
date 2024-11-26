# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM base AS vs19

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.26.4

# ===================================================================
# Environment Variables
# ===================================================================
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    LOG_PATH=C:\\TEMP\\vs_buildtools_install.log

# ===================================================================
# Copy Installation Scripts
# ===================================================================
COPY ./scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY ./scripts/windows/build.ps1 C:\app\scripts\windows\build.ps1
COPY ./scripts/windows/run.ps1 C:\app\scripts\windows\run.ps1

# ===================================================================
# Install Visual Studio Build Tools and CMake
# ===================================================================
RUN C:\scripts\install_vs_buildtools.ps1 -VS_VERSION $env:VS_VERSION -VS_YEAR $env:VS_YEAR -CMAKE_VERSION $env:CMAKE_VERSION


# ===================================================================
# Check Installation Logs (Optional)
# ===================================================================
RUN if exist C:\\TEMP\\vs_buildtools_install.log type C:\\TEMP\\vs_buildtools_install.log


# ===================================================================
# Check Installation Logs (Optional)
# ===================================================================
RUN if exist C:\\TEMP\\vs_buildtools_install.log type C:\\TEMP\\vs_buildtools_install.log

# # ===================================================================
# # Install CMake Using External Script
# # ===================================================================
# # Copy the CMake installation script into the container
# COPY ./scripts/windows/install_cmake.ps1 C:\scripts\install_cmake.ps1

# # Execute the CMake installation script
# RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake.ps1" || `
#     (Write-Host "CMake installation failed." && exit 1)

# # ===================================================================
# # Add CMake to PATH Correctly
# # ===================================================================
# ENV PATH "C:\\Program Files\\CMake\\bin;C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\;C:\\Windows\\System32\\;${PATH}"

# ===================================================================
# Verify PATH and PowerShell Availability
# ===================================================================
RUN echo %PATH%
RUN where powershell

# ===================================================================
# Verify CMake Installation
# ===================================================================
RUN powershell -Command "& 'C:\\Program Files\\CMake\\bin\\cmake.exe' --version"

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\\app

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]