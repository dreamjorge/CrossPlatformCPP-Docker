# install_choco.ps1

# Ensure TLS 1.2 is enabled
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "TLS 1.2 enabled."

# Check if Chocolatey is already installed
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey is already installed at $(Get-Command choco)."
} else {
    Write-Host "Installing Chocolatey..."
    try {
        # Download and execute Chocolatey installation script
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installation script executed successfully."
    } catch {
        Write-Error "Failed to execute Chocolatey installation script: $_"
        exit 1
    }

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