# install_cmake.ps1

# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "TLS 1.2 enabled."

# Ensure Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    try {
        # Bypass SSL certificate validation for this operation
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { param($sender, $certificate, $chain, $sslPolicyErrors) $true }
        
        # Download and install Chocolatey
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed successfully."
    } catch {
        Write-Error "Failed to install Chocolatey: $_"
        exit 1
    } finally {
        # Reset SSL certificate validation to default
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
    }
} else {
    Write-Host "Chocolatey is already installed."
}

# Define the required CMake version
$RequiredCMakeVersion = $env:CMAKE_VERSION

# Check if CMake is already installed and at the required version
$InstalledCMakeVersion = ""
try {
    $InstalledCMakeVersion = (cmake --version 2>$null | Select-String -Pattern '^cmake version (\d+\.\d+\.\d+)' | ForEach-Object { $_.Matches.Groups[1].Value })
} catch {
    Write-Host "CMake is not currently available."
}

if ($InstalledCMakeVersion -eq $RequiredCMakeVersion) {
    Write-Host "CMake $RequiredCMakeVersion is already installed."
} else {
    Write-Host "Installing CMake $RequiredCMakeVersion via Chocolatey..."
    try {
        # Bypass SSL certificate validation for this operation
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { param($sender, $certificate, $chain, $sslPolicyErrors) $true }
        
        choco install cmake --version=$RequiredCMakeVersion --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress
        Write-Host "CMake $RequiredCMakeVersion installation completed successfully."
    } catch {
        Write-Error "Failed to install CMake $RequiredCMakeVersion: $_"
        exit 1
    } finally {
        # Reset SSL certificate validation to default
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
    }

    # Add CMake to the current PATH (for the running session)
    $CMakePath = "C:\Program Files\CMake\bin"
    if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $CMakePath })) {
        Write-Host "Adding CMake to PATH for the current session..."
        $env:PATH = "$env:PATH;$CMakePath"
    }
}

# Verify installation
Write-Host "Verifying CMake installation..."
try {
    cmake --version
    Write-Host "CMake installation verified successfully."
} catch {
    Write-Error "CMake installation verification failed: $_"
    exit 1
}
