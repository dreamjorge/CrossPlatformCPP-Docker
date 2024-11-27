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

#
# ===================================================================
# Download Visual Studio Build Tools Installer
# ===================================================================
RUN Write-Host "Downloading Visual Studio Build Tools installer..." `
    ; Invoke-WebRequest -Uri "https://aka.ms/vs/$($env:VS_VERSION)/release/vs_buildtools.exe" -OutFile "$env:TEMP_DIR\vs_buildtools.exe" `
    ; Write-Host "Downloaded Visual Studio Build Tools installer successfully."

# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
RUN Write-Host "Installing Visual Studio Build Tools..." `
    ; Start-Process -FilePath "$env:TEMP_DIR\vs_buildtools.exe" -ArgumentList "--quiet", "--wait", "--norestart", "--nocache", `
        "--installPath", "`"$env:BUILD_TOOLS_PATH`"", `
        "--add", "Microsoft.VisualStudio.Workload.VCTools", `
        "--includeRecommended", `
        "--log", "`"$env:LOG_PATH`"" -NoNewWindow -Wait `
    ; Write-Host "Visual Studio Build Tools installation completed."

# ===================================================================
# Verify Installation by Checking for cl.exe
# ===================================================================
RUN Write-Host "Verifying Visual Studio Build Tools installation..." `
    ; $clPathPattern = "$env:BUILD_TOOLS_PATH\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe" `
    ; $clExists = Get-ChildItem -Path $clPathPattern -ErrorAction SilentlyContinue | Select-Object -First 1 `
    ; if ($clExists) { `
        Write-Host "Verification successful: cl.exe found at $($clExists.FullName)." `
    } else { `
        Write-Host "Verification failed: cl.exe not found. Installation may have failed." `
        exit 1 `
    }


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