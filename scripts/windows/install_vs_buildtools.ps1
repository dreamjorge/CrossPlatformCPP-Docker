param (
    [string]$VsVersion = $env:VS_VERSION
)

if ([string]::IsNullOrWhiteSpace($VsVersion)) {
    $VsVersion = "15" # Default to Visual Studio 2017 (VS Version 15)
}

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

# Rest of your script continues here...