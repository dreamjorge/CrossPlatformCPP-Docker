param (
    [string]$VsVersion = $env:VS_VERSION
)

if ([string]::IsNullOrWhiteSpace($VsVersion)) {
    $VsVersion = "15" # Default to Visual Studio 2017 (VS Version 15)
}

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Functions: Log-Info and Log-Error (same as before)

# Map Visual Studio version to corresponding Build Tools and channel manifest URLs
# (Same as before)

# Check if the provided VsVersion is supported
if (-not $vsInstallers.ContainsKey($VsVersion)) {
    Log-Error "Unsupported Visual Studio version: $VsVersion. Supported versions: 15 (2017), 16 (2019), 17 (2022)."
}

# Get the installer and channel manifest URLs based on VsVersion
# (Same as before)

# Ensure the C:\temp directory exists
# (Same as before)

# Functions: Download-File, Install-BuildTools, Validate-Installation, Clean-Up
# (Same as before, but modify Validate-Installation as follows)

function Validate-Installation {
    param ([string[]]$RequiredTools)

    # Download vswhere if not already downloaded
    if (-not (Test-Path $vswherePath)) {
        $vswhereUrl = "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe"
        Download-File -Url $vswhereUrl -Destination $vswherePath
    }

    # Use vswhere to locate installations
    Log-Info "Executing vswhere to locate Visual Studio installations..."
    $vswhereCommand = "& `$vswherePath -all -products '*' -format json"
    Log-Info "vswhere command: $vswhereCommand"
    $vswhereOutput = & $vswherePath -all -products '*' -format json

    if ([string]::IsNullOrWhiteSpace($vswhereOutput)) {
        Log-Error "vswhere did not return any installations."
    } else {
        Log-Info "vswhere output: $vswhereOutput"
        $vsInstallations = $vswhereOutput | ConvertFrom-Json

        # Proceed with checking for required tools
        foreach ($installation in $vsInstallations) {
            $installationPath = $installation.installationPath
            Log-Info "Found Visual Studio installation at $installationPath"

            foreach ($tool in $RequiredTools) {
                # Tool checking logic (same as before)
            }
        }
    }

    Log-Info "All required tools validated successfully."
}

# Download the installer and channel manifest
# (Same as before)

# Set installation arguments (update component IDs and remove custom installPath)
$installArgs = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--channelUri", $channelManifestPath,
    "--installChannelUri", $channelManifestPath,
    "--add", "Microsoft.VisualStudio.Workload.VCTools",
    "--add", "Microsoft.VisualStudio.Workload.MSBuildTools",
    "--includeRecommended",
    "--log", "C:\temp\vs_buildtools_install.log"
) -join " "

# Install Visual Studio Build Tools
# (Same as before)

# Validate the installation using vswhere
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

# Clean up the installer, channel manifest, and vswhere files
# (Same as before, but remember to uncomment Clean-Up if you had commented it out)

Log-Info "Visual Studio Build Tools setup completed successfully."