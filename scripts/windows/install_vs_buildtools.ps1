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

# Universal URLs for Visual Studio Build Tools, Channel Manifest, and vswhere
$vsBuildToolsUrl = "https://aka.ms/vs/15/release/vs_buildtools.exe"
$channelManifestUrl = "https://aka.ms/vs/15/release/channel"
$vswhereUrl = "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe"

# Define download paths
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"
$channelManifestPath = "C:\temp\VisualStudio.chman"
$vswherePath = "C:\temp\vswhere.exe"

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

# Function: Validate Installation Using vswhere
function Validate-Installation {
    param ([string[]]$RequiredTools)

    # Download vswhere if not already downloaded
    if (-not (Test-Path $vswherePath)) {
        Download-File -Url $vswhereUrl -Destination $vswherePath
    }

    # Locate Visual Studio installations
    $vsInstallations = & $vswherePath -all -products '*' -requires Microsoft.VisualStudio.Workload.VCTools -format json | ConvertFrom-Json

    if (-not $vsInstallations) {
        Log-Error "No valid Visual Studio Build Tools installation found."
    }

    # Check if required tools exist in the detected installation
    foreach ($installation in $vsInstallations) {
        $installationPath = $installation.installationPath
        Log-Info "Found Visual Studio installation at $installationPath"

        foreach ($tool in $RequiredTools) {
            switch ($tool.ToLower()) {
                "cl.exe" {
                    # Check in VC\Tools\MSVC\*\bin\Hostx64\x64\
                    $toolPath = Join-Path -Path $installationPath -ChildPath "VC\Tools\MSVC\*\bin\Hostx64\x64\$tool"
                }
                "msbuild.exe" {
                    # Check in MSBuild\Current\Bin\
                    $toolPath = Join-Path -Path $installationPath -ChildPath "MSBuild\Current\Bin\$tool"
                }
                default {
                    $toolPath = ""
                }
            }

            $resolvedPath = Get-ChildItem -Path $toolPath -ErrorAction SilentlyContinue | Select-Object -First 1

            if (-not $resolvedPath) {
                Log-Error "$tool not found in Visual Studio installation at $installationPath."
            } else {
                Log-Info "$tool found at $($resolvedPath.FullName)"
            }
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

# Download the installer, channel manifest, and vswhere
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
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",
    "--add", "Microsoft.VisualStudio.Component.MSBuild", # Added MSBuild component
    "--includeRecommended",
    "--installPath", "C:\BuildTools"
) -join " "

# Install Visual Studio Build Tools
Install-BuildTools -InstallerPath $buildToolsPath -ChannelManifestPath $channelManifestPath -InstallArgs $installArgs

# Validate the installation using vswhere
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

# Clean up the installer, channel manifest, and vswhere files
Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $channelManifestPath
Clean-Up -FilePath $vswherePath