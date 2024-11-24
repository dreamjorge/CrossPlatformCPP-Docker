# Use a base Windows image with PowerShell
FROM crossplatformapp-windows-base AS vs_build

# Arguments for Visual Studio and CMake versions
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CMAKE_VERSION=3.21.3

# Set environment variables
ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION}

# Copy installation scripts into the image
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Debugging environment variables
RUN powershell -Command `
    echo "VS_VERSION is $env:VS_VERSION"; `
    echo "VS_YEAR is $env:VS_YEAR"; `
    echo "CMAKE_VERSION is $env:CMAKE_VERSION"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:/scripts/install_vs_buildtools.ps1"

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:/scripts/install_cmake_bypass.ps1"

# Detect MSVC version and set as an environment variable
RUN powershell -Command `
    try { `
        $msvcPath = "C:\Program Files (x86)\Microsoft Visual Studio\$env:VS_YEAR\BuildTools\VC\Tools\MSVC"; `
        $msvcDirs = Get-ChildItem -Directory -Path $msvcPath -ErrorAction Stop; `
        if ($msvcDirs.Count -gt 0) { `
            $msvcVersion = $msvcDirs[0].Name; `
            echo "Detected MSVC Version: $msvcVersion"; `
            [System.Environment]::SetEnvironmentVariable('MSVC_VERSION', $msvcVersion, 'Machine'); `
        } else { `
            echo "Available directories in MSVC path:"; `
            Get-ChildItem -Directory -Path $msvcPath; `
            throw "MSVC directory not found."; `
        } `
    } catch { `
        echo "Error detecting MSVC Version: $_"; `
        throw; `
    }

# Specify the default command for the container
CMD ["cmd"]