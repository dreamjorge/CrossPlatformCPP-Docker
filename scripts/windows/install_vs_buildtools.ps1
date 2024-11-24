param (
    [string]$VsVersion = $env:VS_VERSION,
    [string]$VsYear = $env:VS_YEAR
)

if ([string]::IsNullOrWhiteSpace($VsVersion)) {
    $VsVersion = "15" # Default to Visual Studio version 15
}

if ([string]::IsNullOrWhiteSpace($VsYear)) {
    $VsYear = "2017" # Default to Visual Studio 2017
}

# Log the VsYear and VsVersion
Log-Info "VsYear is $VsYear"
Log-Info "VsVersion is $VsVersion"

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Functions (Log-Info, Log-Warning, Log-Error, Download-File) remain the same...

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

# Rest of the script...

# Define download paths
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"
$vswherePath = "C:\temp\vswhere.exe"

# Download the installer
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath

# Install Visual Studio Build Tools
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs $installArgs

# Download vswhere and locate installation
if (-not (Test-Path $vswherePath)) {
    $vswhereUrl = "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe"
    Download-File -Url $vswhereUrl -Destination $vswherePath
}

$vswhereOutput = & $vswherePath -products '*' -version "[15.0,16.0)" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($vswhereOutput) {
    $installationPath = $vswhereOutput
    Log-Info "Found Visual Studio Build Tools installation at $installationPath"
} else {
    Log-Error "Visual Studio Build Tools installation not found."
}

# Validate the installation
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

# Clean up
Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $vswherePath

Log-Info "Visual Studio Build Tools setup completed successfully."