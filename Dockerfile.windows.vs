# Build Arguments
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.26.4
ARG CMAKE_DOWNLOAD_URL=https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-windows-x86_64.zip

# Set Environment Variables
ENV TEMP_DIR=C:\TEMP
ENV CMAKE_INSTALL_PATH="C:\Program Files\CMake"

# Download Visual Studio and CMake
RUN mkdir %TEMP_DIR% && \
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri ${VS_CHANNEL} -OutFile %TEMP_DIR%\VisualStudio.chman" && \
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri ${VS_BUILD_TOOLS_URL} -OutFile %TEMP_DIR%\vs_buildtools.exe" && \
    %TEMP_DIR%\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --channelUri %TEMP_DIR%\VisualStudio.chman \
    --installChannelUri %TEMP_DIR%\VisualStudio.chman \
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended \
    --installPath C:\BuildTools && \
    powershell -Command "
    Try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
        Invoke-WebRequest -Uri ${CMAKE_DOWNLOAD_URL} -OutFile %TEMP_DIR%\cmake.zip;
    } Catch {
        Write-Error 'Failed to download CMake. Check the URL or network connectivity.';
        Exit 1;
    }" && \
    powershell -Command "Expand-Archive -Path %TEMP_DIR%\cmake.zip -DestinationPath %TEMP_DIR%\cmake" && \
    move %TEMP_DIR%\cmake\cmake-${CMAKE_VERSION}-windows-x86_64\* %CMAKE_INSTALL_PATH% && \
    setx /M PATH "%PATH%;%CMAKE_INSTALL_PATH%\bin" && \
    rmdir /S /Q %TEMP_DIR%