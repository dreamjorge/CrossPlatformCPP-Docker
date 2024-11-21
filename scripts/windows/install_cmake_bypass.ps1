# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "TLS 1.2 enabled."

# Ensure Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    try {
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed successfully."
    } catch {
        Write-Error "Failed to install Chocolatey: $($_)"
        exit 1
    }
} else {
    Write-Host "Chocolatey is already installed."
}

# Define the required CMake version
$RequiredCMakeVersion = $env:CMAKE_VERSION
$CMakePath = "C:\Program Files\CMake\bin\cmake.exe"

# Fallback URL for manual download
$CMakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$RequiredCMakeVersion/cmake-$RequiredCMakeVersion-windows-x86_64.msi"
$CMakeInstallerPath = "$env:TEMP\cmake-installer.msi"

# Install CMake using Chocolatey
try {
    Write-Host "Installing CMake $RequiredCMakeVersion via Chocolatey..."
    choco install cmake --version=$RequiredCMakeVersion --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress --ignore-checksums --force
} catch {
    Write-Warning "Chocolatey installation of CMake failed. Falling back to manual download..."
}

# Verify CMake installation
if (-not (Test-Path $CMakePath)) {
    Write-Host "CMake executable not found. Attempting manual installation..."
    try {
        # Download CMake manually
        Write-Host "Downloading CMake installer from $CMakeInstallerUrl..."
        Invoke-WebRequest -Uri $CMakeInstallerUrl -OutFile $CMakeInstallerPath

        # Install CMake
        Write-Host "Installing CMake using the MSI installer..."
        Start-Process msiexec.exe -ArgumentList "/i $CMakeInstallerPath /quiet /norestart ADD_CMAKE_TO_PATH=System" -NoNewWindow -Wait

        # Cleanup
        Remove-Item -Path $CMakeInstallerPath -Force
        Write-Host "CMake installed successfully."
    } catch {
        Write-Error "Manual installation of CMake failed: $($_)"
        exit 1
    }
}

# Verify final installation
Write-Host "Verifying CMake installation..."
if (-not (Test-Path $CMakePath)) {
    Write-Error "CMake executable not found at $CMakePath."
    exit 1
}

try {
    & "$CMakePath" --version
    Write-Host "CMake installation verified successfully."
} catch {
    Write-Error "CMake installation verification failed: $($_)"
    exit 1
}
