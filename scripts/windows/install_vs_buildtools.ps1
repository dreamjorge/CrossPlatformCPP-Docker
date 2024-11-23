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
$channelManifestUrl = "https://aka.ms/vs/15/release/channel"

# Define download paths
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"
$channelManifestPath = "C:\temp\VisualStudio.chman"

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
        Log-Info "Downloading file from $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Log-Info "Downloaded file to $Destination."
    } catch {
        Log-Error ("Failed to download file: {0}" -f $_)
    }
}

# Function: Install Visual Studio Build Tools
function Install-BuildTools {
    param (
        [string]$InstallerPath,
        [string]$ChannelManifestPath,
        [string]$InstallArgs
    )
    if ([string]::IsNullOrWhiteSpace($InstallArgs)) {
        Log-Error "Installation arguments cannot be null or empty."
    }

    try {
        $errorFile = "C:\temp\vs_buildtools_error.log"
        Log-Info "Installing Visual Studio Build Tools with arguments: $InstallArgs"
        Start-Process -FilePath $InstallerPath -ArgumentList $InstallArgs -NoNewWindow -Wait `
            -RedirectStandardOutput "NUL" -RedirectStandardError $errorFile
        Log-Info "Visual Studio Build Tools installation completed successfully."
        if (Test-Path $errorFile) {
            Remove-Item -Force $errorFile
        }
    } catch {
        Log-Error ("Failed to install Visual Studio Build Tools: {0}" -f $_)
    }
}

# Function: Validate Installation
function Validate-Installation {
    param ([string[]]$Tools)
    # Refresh the environment to ensure new PATH entries are loaded
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    
    foreach ($Tool in $Tools) {
        try {
            $ToolPath = Get-Command $Tool -ErrorAction SilentlyContinue
            if (-not $ToolPath) {
                # If not found in PATH, look in the default Visual Studio installation directories
                $possiblePaths = @(
                    "C:\Program Files (x86)\Microsoft Visual Studio\*\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64",
                    "C:\Program Files\Microsoft Visual Studio\*\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64"
                )
                $found = $false
                foreach ($path in $possiblePaths) {
                    $resolvedPath = Get-ChildItem -Path $path -Filter "cl.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($resolvedPath) {
                        $found = $true
                        Log-Info "$Tool found at $($resolvedPath.FullName)"
                        break
                    }
                }
                if (-not $found) {
                    Log-Error "$Tool not found in PATH or default directories. Installation validation failed."
                }
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

# Download the installer and channel manifest
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath
Download-File -Url $channelManifestUrl -Destination $channelManifestPath

# Set installation arguments
$installArgs = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--channelUri", $channelManifestPath,
    "--installChannelUri", $channelManifestPath,
    "--add", "Microsoft.VisualStudio.Workload.VCTools",
    "--includeRecommended",
    "--installPath", "C:\BuildTools"
) -join " "

# Install Visual Studio Build Tools
Install-BuildTools -InstallerPath $buildToolsPath -ChannelManifestPath $channelManifestPath -InstallArgs $installArgs

# Validate the installation
Validate-Installation -Tools @("msbuild", "cl")

# Clean up the installer and channel manifest files
Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $channelManifestPath
