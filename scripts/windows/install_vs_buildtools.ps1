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

# Map Visual Studio version to corresponding Build Tools and channel manifest URLs
$vsInstallers = @{
    "15" = @{
        BuildToolsUrl = "https://aka.ms/vs/15/release/vs_buildtools.exe" # VS2017
        ChannelManifestUrl = "https://aka.ms/vs/15/release/channel"
    }
    "16" = @{
        BuildToolsUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe" # VS2019
        ChannelManifestUrl = "https://aka.ms/vs/16/release/channel"
    }
    "17" = @{
        BuildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe" # VS2022
        ChannelManifestUrl = "https://aka.ms/vs/17/release/channel"
    }
}

# Check if the provided VsVersion is supported
if (-not $vsInstallers.ContainsKey($VsVersion)) {
    Log-Error "Unsupported Visual Studio version: $VsVersion. Supported versions: 15 (2017), 16 (2019), 17 (2022)."
}

# Get the installer and channel manifest URLs based on VsVersion
$vsBuildToolsUrl = $vsInstallers[$VsVersion].BuildToolsUrl
$channelManifestUrl = $vsInstallers[$VsVersion].ChannelManifestUrl

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
        $logPath = "C:\temp\vs_buildtools_install.log"
        Log-Info "Installing Visual Studio Build Tools with arguments: $InstallArgs"
        # Install with logging
        Start-Process -FilePath $InstallerPath -ArgumentList $InstallArgs -NoNewWindow -Wait -PassThru | Out-Null
        Log-Info "Visual Studio Build Tools installation completed successfully. Log at $logPath"
    } catch {
        Log-Error ("Failed to install Visual Studio Build Tools: {0}" -f $_)
    }
}

# Function: Validate Installation Using vswhere
function Validate-Installation {
    param ([string[]]$RequiredTools)

    # Download vswhere if not already downloaded
    if (-not (Test-Path $vswherePath)) {
        $vswhereUrl = "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe"
        Download-File -Url $vswhereUrl -Destination $vswherePath
    }

    # Use vswhere to locate installations with the required component
    $vswhereOutput = & $vswherePath -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json

    if ([string]::IsNullOrWhiteSpace($vswhereOutput)) {
        Log-Error "vswhere did not return any installations with the required components."
    } else {
        Log-Info "vswhere output: $vswhereOutput"
        $vsInstallations = $vswhereOutput | ConvertFrom-Json

        # Exclude Test Agent installations
        $vsInstallations = $vsInstallations | Where-Object { $_.productId -ne 'Microsoft.VisualStudio.Product.TestAgent' }

        if ($vsInstallations.Count -eq 0) {
            Log-Error "No valid Visual Studio installations with required components found."
        }

        # Proceed with checking for required tools
        $allToolsFound = $true
        foreach ($installation in $vsInstallations) {
            $installationPath = $installation.installationPath
            Log-Info "Found Visual Studio installation at $installationPath"

            foreach ($tool in $RequiredTools) {
                # Define specific search paths for cl.exe
                if ($tool -eq "cl.exe") {
                    $toolPaths = Get-ChildItem -Path "$installationPath\VC\Tools\MSVC" -Recurse -Filter $tool -ErrorAction SilentlyContinue
                } else {
                    $toolPaths = Get-ChildItem -Path "$installationPath" -Recurse -Filter $tool -ErrorAction SilentlyContinue
                }

                if (-not $toolPaths) {
                    Log-Warning "$tool not found in Visual Studio installation at $installationPath."
                    $allToolsFound = $false
                } else {
                    foreach ($toolPath in $toolPaths) {
                        Log-Info "$tool found at $($toolPath.FullName)"
                    }
                }
            }
        }

        if (-not $allToolsFound) {
            Log-Error "Not all required tools were found in the Visual Studio installations."
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

# Download the installer and channel manifest
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath
Download-File -Url $channelManifestUrl -Destination $channelManifestPath

# Set installation arguments with necessary components
$installArgs = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--channelUri", $channelManifestPath,
    "--installChannelUri", $channelManifestPath,
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
Install-BuildTools -InstallerPath $buildToolsPath -ChannelManifestPath $channelManifestPath -InstallArgs $installArgs

# Validate the installation using vswhere
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

# Clean up the installer, channel manifest, and vswhere files
Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $channelManifestPath
Clean-Up -FilePath $vswherePath

Log-Info "Visual Studio Build Tools setup completed successfully."