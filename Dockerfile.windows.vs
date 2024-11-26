# escape=`

# Base Image
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
COPY ./scripts/windows/build.vs19.cmd C:\app\scripts\windows\build.vs19.cmd
COPY ./scripts/windows/run.cmd C:\app\scripts\windows\run.cmd

# ===================================================================
# Install Visual Studio Build Tools
# ===================================================================
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1" || `
    (type C:\\TEMP\\vs_buildtools_install.log && exit 1)

# ===================================================================
# Check Installation Logs (Optional)
# ===================================================================
RUN if exist C:\\TEMP\\vs_buildtools_install.log type C:\\TEMP\\vs_buildtools_install.log

# ===================================================================
# Install CMake (Inline Installation)
# ===================================================================
RUN powershell -Command "`
    $ErrorActionPreference = 'Stop'; `
    Write-Host 'Installing CMake version: $env:CMAKE_VERSION'; `
    $url = 'https://github.com/Kitware/CMake/releases/download/v' + $env:CMAKE_VERSION + '/cmake-' + $env:CMAKE_VERSION + '-windows-x86_64.msi'; `
    Write-Host 'Constructed URL: ' + $url; `
    $output = 'C:\\cmake_installer.msi'; `
    Write-Host 'Downloading CMake from ' + $url; `
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing; `
    Write-Host 'Installing CMake...'; `
    Start-Process msiexec.exe -ArgumentList '/i', $output, '/quiet', '/norestart' -NoNewWindow -Wait; `
    if (!(Test-Path 'C:\\Program Files\\CMake\\bin\\cmake.exe')) { `
        throw 'CMake installation failed. Executable not found.'; `
    } `
    Write-Host 'CMake installed successfully.'; `
    Remove-Item 'C:\\cmake_installer.msi' -Force"

# ===================================================================
# Add CMake to PATH Correctly
# ===================================================================
ENV PATH="C:\\Program Files\\CMake\\bin;${PATH}"

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