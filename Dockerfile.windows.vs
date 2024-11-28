# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Copy the CMake installation script to the container
COPY scripts/windows/install_cmake.ps1 C:\TEMP\install_cmake.ps1

# Argument to specify the CMake version
ARG CMAKE_VERSION="3.26.4"

RUN `
    # Download the Build Tools bootstrapper for VS 2019.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/16/release/vs_buildtools.exe `
    `
    # Install Build Tools with the required workloads for Visual Studio 2019.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --add Microsoft.VisualStudio.Workload.AzureBuildTools `
        --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
        --includeRecommended `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
        --remove Microsoft.VisualStudio.Component.Windows81SDK `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Run the CMake installation script with the specified version.
    && powershell -ExecutionPolicy Bypass -File C:\TEMP\install_cmake.ps1 -CMAKE_VERSION $Env:CMAKE_VERSION `
    `
    # Cleanup temporary files.
    && del /q vs_buildtools.exe `
    && del /q C:\TEMP\install_cmake.ps1

# Set up environment variables for the developer command prompt.
ENV PATH="%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools\Common7\Tools;%PATH%"
ENV VS_INSTALL_PATH="%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools"

# Define the entry point for the Docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["%ProgramFiles(x86)%\\Microsoft Visual Studio\\2019\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]