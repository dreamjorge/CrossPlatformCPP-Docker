# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for batch processing
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3
ARG TEMP_DIR="C:\\TEMP"

# ===================================================================
# Environment Variables
# ===================================================================
ENV TEMP_DIR=${TEMP_DIR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    VS_BUILDTOOLS_PATH="C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\BuildTools"

# ===================================================================
# Create TEMP Directory
# ===================================================================
RUN mkdir "%TEMP_DIR%"

# ===================================================================
# Install Visual Studio Build Tools
# ===================================================================
RUN echo "Downloading Visual Studio Build Tools version %VS_VERSION%" && `
    curl -SL --output "%TEMP_DIR%\\vs_buildtools.exe" `
        "https://aka.ms/vs/%VS_VERSION%/release/vs_buildtools.exe" && `
    echo "Installing Visual Studio Build Tools..." && `
    start /wait "%TEMP_DIR%\\vs_buildtools.exe" `
        --quiet --wait --norestart `
        --nocache `
        --installPath "%VS_BUILDTOOLS_PATH%" `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --add Microsoft.VisualStudio.Component.VC.CMake.Project `
        --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
        --lang en-US `
        --log "%TEMP_DIR%\\vs_buildtools_install.log" `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0 && `
    del /q "%TEMP_DIR%\\vs_buildtools.exe"

# ===================================================================
# Install CMake
# ===================================================================
RUN echo "Downloading CMake version %CMAKE_VERSION%" && `
    set "CMAKE_INSTALLER=%TEMP_DIR%\\cmake.msi" && `
    curl -SL --output "%CMAKE_INSTALLER%" `
        "https://github.com/Kitware/CMake/releases/download/v%CMAKE_VERSION%/cmake-%CMAKE_VERSION%-windows-x86_64.msi" && `
    echo "Installing CMake version %CMAKE_VERSION%" && `
    start /wait msiexec /i "%CMAKE_INSTALLER%" /quiet /qn /norestart && `
    del /q "%CMAKE_INSTALLER%"

# ===================================================================
# Verify Installations
# ===================================================================
# Verify Visual Studio installation
RUN if exist "%VS_BUILDTOOLS_PATH%\\Common7\\Tools\\VsDevCmd.bat" ( `
        echo "Visual Studio Build Tools installed successfully." `
    ) else ( `
        echo "Error: Visual Studio Build Tools not found at %VS_BUILDTOOLS_PATH%\\Common7\\Tools\\VsDevCmd.bat" && exit /b 1 `
    )

# Verify CMake installation
RUN cmake --version

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR "C:\\app"

# ===================================================================
# Define Entry Point
# ===================================================================
ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
