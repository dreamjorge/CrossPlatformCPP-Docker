param (
    [string]$VsVersion = "16" # Default to Visual Studio 2019 (VS Version 16)
)

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function: Log Information
function Log-Info {
    param ([string]$Message)
    Write-Host "INFO: $Message"
}

# Function: Log Error
function Log-Error {
    param ([string]$Message)
    Write-Error "ERROR: $Message" -ErrorAction Stop
}

# Function: Validate Visual Studio Version
function Validate-VsVersion {
    param ([string]$Version, [hashtable]$Installers)
    if (-not $Installers.ContainsKey($Version)) {
        Log-Error "Unsupported Visual Studio version: $Version. Supported versions: 15 (2017), 16 (2019), 17 (2022)."
    }
}

# Function: Download File
function Download-File {
    param (
        [string]$Url,
        [string]$Destination
    )
    try {
        Log-Info "Downloading file from $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Log-Info "Downloaded file to $Destination."
    } catch {
        Log-Error "Failed to download file: $_"
    }
}

# Function: Install Visual Studio Build Tools
function Install-BuildTools {
    param (
        [string]$InstallerPath,
        [string]$Args
    )
    try {
        Log-Info "Installing Visual Studio Build Tools..."
        Start-Process -FilePath $InstallerPath -ArgumentList $Args -NoNewWindow -Wait -ErrorAction Stop
        Log-Info "Visual Studio Build Tools installation completed successfully."
    } catch {
        Log-Error "Failed to install Visual Studio Build Tools: $_"
    }
}

# Function: Validate Installation
function Validate-Installation {
    param ([string[]]$Tools)
    foreach ($Tool in $Tools) {
        try {
            $ToolPath = Get-Command $Tool -ErrorAction SilentlyContinue
            if (-not $ToolPath) {
                Log-Error "$Tool not found in PATH. Installation validation failed."
            } else {
                Log-Info "$Tool found at $ToolPath."
            }
        } catch {
            Log-Error "Failed to validate $Tool: $_"
        }
    }
    Log-Info "All required tools validated successfully."
}

# Function: Clean Up Temporary Files
function Clean-Up {
    param ([string]$FilePath)
    try {
        Remove-Item -Force $FilePath -ErrorAction SilentlyContinue
        Log-Info "Temporary file removed: $FilePath."
    } catch {
        Write-Warning "WARNING: Failed to remove $FilePath. You may need to delete it manually."
    }
}

# Map Visual Studio version to corresponding installer URLs
$vsInstallers = @{
    "15" = "https://download.visualstudio.microsoft.com/download/pr/11810035/f742a4d4-75b6-4704-8171-97bb89b15be6/vs_buildtools.exe" # Visual Studio 2017
    "16" = "https://aka.ms/vs/16/release/vs_buildtools.exe" # Visual Studio 2019
    "17" = "https://aka.ms/vs/17/release/vs_buildtools.exe" # Visual Studio 2022
}

# Validate Visual Studio version
Validate-VsVersion -Version $VsVersion -Installers $vsInstallers

# Define installer URL and download path
$buildToolsUrl = $vsInstallers[$VsVersion]
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"

# Ensure the C:\temp directory exists
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp" | Out-Null
    Log-Info "Created C:\temp directory."
}

# Download the installer
Download-File -Url $buildToolsUrl -Destination $buildToolsPath

# Install Visual Studio Build Tools
$installArgs = "--quiet --norestart --wait --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended"
Install-BuildTools -InstallerPath $buildToolsPath -Args $installArgs

# Validate the installation
Validate-Installation -Tools @("msbuild", "cl")

# Clean up the installer file
Clean-Up -FilePath $buildToolsPath