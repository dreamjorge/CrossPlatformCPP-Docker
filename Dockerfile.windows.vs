# escape=`

# Use the latest Windows Server Core 2019 image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Restore the default Windows shell for batch processing
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Build Arguments
# ===================================================================
# Allow parameterized installation of Visual Studio and CMake
ARG VS_VERSION=16
ARG VS_WORKLOAD=Microsoft.VisualStudio.Workload.VCTools
ARG VS_INSTALL_PATH="C:\\BuildTools"
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
# Define environment variables for consistency
ENV TEMP_DIR="C:\\TEMP" `
    VS_VERSION=${VS_VERSION} `
    VS_WORKLOAD=${VS_WORKLOAD} `
    VS_INSTALL_PATH=${VS_INSTALL_PATH} `
    CMAKE_VERSION=${CMAKE_VERSION}

# ===================================================================
# Create TEMP Directory
# ===================================================================
RUN mkdir "%TEMP_DIR%"

# ===================================================================
# Download and Install Visual Studio Build Tools
# ===================================================================
RUN echo "Downloading Visual Studio Build Tools version %VS_VERSION%" && `
    curl -SL --output "%TEMP_DIR%\\vs_buildtools.exe" "https://aka.ms/vs/%VS_VERSION%/release/vs_buildtools.exe" && `
    echo "Installing Visual Studio Build Tools with workload %VS_WORKLOAD%" && `
    "%TEMP_DIR%\\vs_buildtools.exe" --quiet --wait --norestart `
        --nocache `
        --installPath "%VS_INSTALL_PATH%" `
        --add %VS_WORKLOAD% `
        --lang en-US `
        --log "%TEMP_DIR%\\vs_buildtools_install.log" `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0 && `
    del /q "%TEMP_DIR%\\vs_buildtools.exe"

# ===================================================================
# Download and Install CMake
# ===================================================================
RUN echo "Downloading CMake version %CMAKE_VERSION%" && `
    curl -SL --output "%TEMP_DIR%\\cmake.msi" `
        "https://github.com/Kitware/CMake/releases/download/v%CMAKE_VERSION%/cmake-%CMAKE_VERSION%-windows-x86_64.msi" && `
    echo "Installing CMake version %CMAKE_VERSION%" && `
    start /wait msiexec /i "%TEMP_DIR%\\cmake.msi" /quiet /qn /norestart && `
    del /q "%TEMP_DIR%\\cmake.msi"

# ===================================================================
# Verify Installation
# ===================================================================
# Verify that Visual Studio Build Tools and CMake are installed correctly
RUN "%VS_INSTALL_PATH%\\Common7\\Tools\\VsDevCmd.bat" && `
    cmake --version

# ===================================================================
# Set Working Directory
# ===================================================================
# Define the working directory for the application
WORKDIR "C:\\app"

# ===================================================================
# Copy Application Files
# ===================================================================
# (Optional) Copy application files if required
COPY . .

# ===================================================================
# Define Entry Point
# ===================================================================
# Start Developer Command Prompt with PowerShell
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]