# Use a base image with Windows and PowerShell
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables
ARG VS_VERSION
ARG CMAKE_VERSION
ENV TEMP_DIR=C:\\temp
ENV BUILD_TOOLS_PATH=C:\\BuildTools
ENV CMAKE_INSTALL_PATH=C:\\CMake
ENV BUILD_DIR=C:\\build

# Create temporary directory
RUN mkdir %TEMP_DIR%

# Install Visual Studio Build Tools
RUN powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri %VS_CHANNEL% -OutFile %TEMP_DIR%\\VisualStudio.chman" && \
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri %VS_BUILD_TOOLS_URL% -OutFile %TEMP_DIR%\\vs_buildtools.exe" && \
    %TEMP_DIR%\\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --channelUri %TEMP_DIR%\\VisualStudio.chman \
    --installChannelUri %TEMP_DIR%\\VisualStudio.chman \
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended \
    --installPath %BUILD_TOOLS_PATH%

# Download and install CMake
RUN powershell -Command " \
    Try { \
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
        Write-Host 'Downloading CMake from ${CMAKE_DOWNLOAD_URL}'; \
        Invoke-WebRequest -Uri ${CMAKE_DOWNLOAD_URL} -OutFile %TEMP_DIR%\\cmake.zip; \
    } Catch { \
        Write-Error 'Failed to download CMake. Check URL or network connectivity.'; \
        Exit 1; \
    }" && \
    powershell -Command "Expand-Archive -Path %TEMP_DIR%\\cmake.zip -DestinationPath %TEMP_DIR%\\cmake" && \
    move %TEMP_DIR%\\cmake\\cmake-${CMAKE_VERSION}-windows-x86_64\\* %CMAKE_INSTALL_PATH% && \
    setx /M PATH "%PATH%;%CMAKE_INSTALL_PATH%\\bin" && \
    rmdir /S /Q %TEMP_DIR%

# Set Working Directory
WORKDIR %BUILD_DIR%

# Copy Project Files
COPY . .

# Default Command
CMD ["cmd.exe"]