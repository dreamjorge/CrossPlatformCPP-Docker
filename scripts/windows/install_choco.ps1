# Exit immediately if a command fails
$ErrorActionPreference = "Stop"

# Check if Chocolatey is already installed
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey is already installed at $(Get-Command choco)."
} else {
    Write-Host "Installing Chocolatey..."

    # Ensure TLS 1.2 for secure downloads
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Download and execute Chocolatey installation script
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Verify installation
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey installed successfully."
    } else {
        Write-Error "Chocolatey installation failed!"
        exit 1
    }
}

# Optional: Upgrade Chocolatey to the latest version
Write-Host "Ensuring Chocolatey is up-to-date..."
choco upgrade chocolatey -y --no-progress

# Verify Chocolatey version
Write-Host "Chocolatey version:"
choco --version