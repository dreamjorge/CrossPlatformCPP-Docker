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

# Install CMake if not already installed
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
    choco install cmake --version=$RequiredCMakeVersion --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress

    # Add CMake to the current PATH (for the running session)
    $CMakePath = "C:\Program Files\CMake\bin"
    if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $CMakePath })) {
        Write-Host "Adding CMake to PATH for the current session..."
        $env:PATH = "$env:PATH;$CMakePath"
    }
}

# Verify installation
Write-Host "Verifying CMake installation..."
cmake --version
