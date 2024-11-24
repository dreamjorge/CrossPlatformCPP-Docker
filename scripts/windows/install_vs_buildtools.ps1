param (
    [string]$VsVersion = $env:VS_VERSION
)

if ([string]::IsNullOrWhiteSpace($VsVersion)) {
    $VsVersion = "17" # Default to Visual Studio 2022 (VS Version 17)
}

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function: Log Information
function Log-Info {
    param ([string]$Message)
    Write-Host "INFO: $Message"
}

# Function: Log Warning
function Log-Warning {
    param ([string]$Message)
    Write-Warning "WARNING: $Message"
}

# Function: Log Error
function Log-Error {
    param ([string]$Message)
    Write-Error "ERROR: $Message" -ErrorAction Stop
}

# Map Visual Studio version to corresponding Build Tools URLs
$vsInstallers = @{
    "15" = @{
        BuildToolsUrl = "https://aka.ms/vs/15/release/vs_buildtools.exe" # VS2017
    }
    "16" = @{
        BuildToolsUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe" # VS2019
    }
    "17" = @{
        BuildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe" # VS2022
    }
}

# Check if the provided VsVersion is supported
if (-not $vsInstallers.ContainsKey($VsVersion)) {
    Log-Error "Unsupported Visual Studio version: $VsVersion. Supported versions: 15 (2017), 16 (2019), 17 (2022)."
}

# Get the installer URL based on VsVersion
$vsBuildToolsUrl = $vsInstallers[$VsVersion].BuildToolsUrl

# Define download paths
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"
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
        [string]$InstallArgs
    )
    if ([string]::IsNullOrWhiteSpace($InstallArgs)) {
        Log-Error "Installation arguments cannot be null or empty."
    }

    try {
        $logPath = "C:\temp\vs_buildtools_install.log"
        Log-Info "Installing Visual Studio Build Tools with arguments: $InstallArgs"
        # Install with logging
        Start-Process -FilePath $InstallerPath -ArgumentList $InstallArgs -NoNewWindow -Wait -PassThru | Out-Null
        Log-Info "Visual Studio Build Tools installation completed successfully. Log at $logPath"
    } catch {
        Log-Error ("Failed to install Visual Studio Build Tools: {0}" -f $_)
    }
}

# Function: Validate Installation
function Validate-Installation {
    param ([string[]]$RequiredTools)

    # Define the default installation path
    $installationPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

    if (-not (Test-Path -Path $installationPath)) {
        Log-Error "Visual Studio Build Tools installation not found at $installationPath."
    } else {
        Log-Info "Found Visual Studio Build Tools installation at $installationPath"

        # Proceed with checking for required tools
        $allToolsFound = $true
        foreach ($tool in $RequiredTools) {
            # Define specific search paths for cl.exe
            if ($tool -eq "cl.exe") {
                $toolPaths = Get-ChildItem -Path "$installationPath\VC\Tools\MSVC" -Recurse -Filter $tool -ErrorAction SilentlyContinue
            } else {
                $toolPaths = Get-ChildItem -Path "$installationPath" -Recurse -Filter $tool -ErrorAction SilentlyContinue
            }

            if (-not $toolPaths) {
                Log-Warning "$tool not found in Visual Studio Build Tools installation at $installationPath."
                $allToolsFound = $false
            } else {
                foreach ($toolPath in $toolPaths) {
                    Log-Info "$tool found at $($toolPath.FullName)"
                }
            }
        }

        if (-not $allToolsFound) {
            Log-Error "Not all required tools were found in the Visual Studio Build Tools installation."
        } else {
            Log-Info "All required tools validated successfully."
        }
    }
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

# Set installation arguments with necessary components
$installArgs = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--add", "Microsoft.VisualStudio.Workload.VCTools",                    # C++ Build Tools workload
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",          # C++ x86/x64 compilers
    "--add", "Microsoft.VisualStudio.Component.VC.CoreBuildTools",         # Visual C++ core build tools
    "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",       # Latest C++ Redistributable
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",        # Windows 10 SDK (version 19041)
    "--includeRecommended",
    "--includeOptional",
    "--log", "C:\temp\vs_buildtools_install.log"
) -join " "

# Install Visual Studio Build Tools
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs $installArgs

# Validate the installation
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

# Clean up the installer and vswhere files
Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $vswherePath

Log-Info "Visual Studio Build Tools setup completed successfully."