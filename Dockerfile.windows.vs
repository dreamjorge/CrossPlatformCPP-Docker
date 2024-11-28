# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Copy the CMake installation script to the container
COPY scripts/windows/install_cmake.ps1 C:\TEMP\install_cmake.ps1

# Argument to specify the CMake version
ARG CMAKE_VERSION="3.26.4"

# Commented out Visual Studio Build Tools installation for testing only CMake installation
# RUN `
#     curl -SL --output vs_buildtools.exe https://aka.ms/vs/16/release/vs_buildtools.exe `
#     && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
#         --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" `
#         --add Microsoft.VisualStudio.Workload.VCTools `
#         --add Microsoft.VisualStudio.Workload.AzureBuildTools `
#         --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools `
#         --includeRecommended `
#         --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
#         --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
#         --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
#         --remove Microsoft.VisualStudio.Component.Windows81SDK `
#         || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
#     && del /q vs_buildtools.exe

# Step 1: Install CMake
RUN powershell -ExecutionPolicy Bypass -File C:\TEMP\install_cmake.ps1 -CMAKE_VERSION "${CMAKE_VERSION}" `
    && del /q C:\TEMP\install_cmake.ps1

# Set up environment variables for the developer command prompt.
ENV PATH="C:\Program Files\CMake\bin;%PATH%"

# Define the entry point for the Docker container.
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]