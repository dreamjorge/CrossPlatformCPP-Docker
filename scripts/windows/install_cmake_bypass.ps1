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
        Write-Error "Failed to install Chocolatey: $(${_})"
        exit 1
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
    Write-Host "CMake ${RequiredCMakeVersion} is already installed."
} else {
    Write-Host "Installing CMake ${RequiredCMakeVersion} via Chocolatey..."
    try {
        choco install cmake --version=$RequiredCMakeVersion --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress --ignore-checksums --force
        Write-Host "CMake ${RequiredCMakeVersion} installation completed successfully."
    } catch {
        Write-Host "Failed to install CMake via Chocolatey. Falling back to manual installation..."
        
        $CMakeInstallerUrl = "https://github.com/Kitware/CMake/releases/download/v$RequiredCMakeVersion/cmake-$RequiredCMakeVersion-windows-x86_64.msi"
        $CMakeInstallerPath = "$env:TEMP\cmake-installer.msi"

        try {
            Invoke-WebRequest -Uri $CMakeInstallerUrl -OutFile $CMakeInstallerPath
            Start-Process msiexec.exe -ArgumentList "/i $CMakeInstallerPath /quiet /norestart ADD_CMAKE_TO_PATH=System" -NoNewWindow -Wait
            Remove-Item -Path $CMakeInstallerPath -Force
            Write-Host "CMake manually installed successfully."
        } catch {
            Write-Error "Failed to install CMake manually: $(${_})"
            exit 1
        }
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
$CMakePath = "C:\Program Files\CMake\bin\cmake.exe"

if (-not (Test-Path $CMakePath)) {
    Write-Error "CMake executable not found at $CMakePath."
    exit 1
}

try {
    & "$CMakePath" --version
    Write-Host "CMake installation verified successfully."
} catch {
    Write-Error "CMake installation verification failed: $(${_})"
    exit 1
}
