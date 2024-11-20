# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Ensure Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey is already installed."
}

# Define the required CMake version
$RequiredCMakeVersion = $env:CMAKE_VERSION

# Check if the desired version of CMake is already installed
$InstalledCMakeVersion = (cmake --version 2>$null | Select-String -Pattern '^cmake version (\d+\.\d+\.\d+)' | ForEach-Object { $_.Matches.Groups[1].Value })

if ($InstalledCMakeVersion -eq $RequiredCMakeVersion) {
    Write-Host "CMake $RequiredCMakeVersion is already installed."
} else {
    Write-Host "Installing CMake $RequiredCMakeVersion via Chocolatey..."
    choco install cmake --version=$RequiredCMakeVersion --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress

    # Add CMake to PATH manually if not automatically added
    $CMakePath = "C:\Program Files\CMake\bin"
    if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $CMakePath })) {
        Write-Host "Adding CMake to system PATH..."
        [System.Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$CMakePath", [System.EnvironmentVariableTarget]::Machine)
    }
}

# Verify installation
Write-Host "Verifying CMake installation..."
cmake --version