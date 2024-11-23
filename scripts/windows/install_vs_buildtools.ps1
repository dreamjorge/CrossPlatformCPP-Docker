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

# Universal URL for Visual Studio Build Tools
$vsBuildToolsUrl = "https://aka.ms/vs/15/release/vs_buildtools.exe"

# Define the installer download path
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"

# Ensure the C:\temp directory exists
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp" | Out-Null
    Log-Info "Created C:\temp directory."
}

# Function: Download File
function Download-File {
    param (
        [string]$Url,
        [string]$Destination
    )
    try {
        Log-Info "Downloading Visual Studio Build Tools from $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Log-Info "Downloaded Visual Studio Build Tools to $Destination."
    } catch {
        Log-Error ("Failed to download file: {0}" -f $_)
    }
}

# Function: Install Visual Studio Build Tools
function Install-BuildTools {
    param (
        [string]$InstallerPath,
        [string]$InstallArgs
    )
    if ([string]::IsNullOrWhiteSpace($InstallArgs)) {
        Log-Error "Installation arguments cannot be null or empty."
    }

    try {
        Log-Info "Installing Visual Studio Build Tools with arguments: $InstallArgs"
        Start-Process -FilePath $InstallerPath -ArgumentList $InstallArgs -NoNewWindow -Wait -ErrorAction Stop
        Log-Info "Visual Studio Build Tools installation completed successfully."
    } catch {
        Log-Error ("Failed to install Visual Studio Build Tools: {0}" -f $_)
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
            Log-Error ("Failed to validate {0}: {1}" -f $Tool, $_)
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

# Download the installer
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath

# Set installation arguments
$installArgs = @(
    "--quiet",
    "--norestart",
    "--wait",
    "--add", "Microsoft.VisualStudio.Workload.VCTools;includeRecommended"
) -join " "

# Install Visual Studio Build Tools
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs $installArgs

# Validate the installation
Validate-Installation -Tools @("msbuild", "cl")

# Clean up the installer file
Clean-Up -FilePath $buildToolsPath
