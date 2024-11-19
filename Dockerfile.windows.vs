# escape=`

# ===================================================================
# Build Image
# ===================================================================
FROM base AS vs_build

# ===================================================================
# Build Arguments
# ===================================================================
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
ENV VS_YEAR=${VS_YEAR}
ENV VS_VERSION=${VS_VERSION}
ENV CMAKE_VERSION=${CMAKE_VERSION}

# ===================================================================
# Copy Installation Scripts
# ===================================================================
# Copy scripts into the container for installing CMake and Visual Studio Build Tools
COPY scripts/windows/install_choco_cmake.ps1 C:\scripts\install_choco_cmake.ps1
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1

# ===================================================================
# Debugging: Verify Files Are Copied
# ===================================================================
# List the copied files to confirm they exist in the container
RUN dir C:\scripts

# ===================================================================
# Install Chocolatey Package Manager and CMake
# ===================================================================
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_choco_cmake.ps1"

# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1"

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\app

# ===================================================================
# Default Command
# ===================================================================
CMD ["cmd.exe"]
