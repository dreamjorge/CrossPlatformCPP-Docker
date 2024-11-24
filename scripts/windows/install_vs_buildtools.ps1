param (
    [string]$VsVersion = $env:VS_VERSION,
    [string]$VsYear = $env:VS_YEAR
)

# Default values if environment variables are not set
if (-not $VsVersion) { $VsVersion = "15" }
if (-not $VsYear) { $VsYear = "2017" }

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define utility functions
Function Log-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

Function Log-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Function Download-File {
    param(
        [string]$Url,
        [string]$Destination
    )
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
}

Function Install-BuildTools {
    param(
        [string]$InstallerPath,
        [string]$InstallArgs
    )
    & $InstallerPath $InstallArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install Build Tools."
    }
}

Function Validate-Installation {
    param([string[]]$RequiredTools)
    foreach ($tool in $RequiredTools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "$tool not found in PATH."
        }
    }
}

Function Clean-Up {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        Remove-Item -Path $FilePath -Force
    }
}

# Map Visual Studio versions to their respective URLs
Function Get-VsInstallerUrl {
    param([string]$VsVersion)
    switch ($VsVersion) {
        "15" { return "https://aka.ms/vs/15/release/vs_buildtools.exe" } # VS2017
        "16" { return "https://aka.ms/vs/16/release/vs_buildtools.exe" } # VS2019
        "17" { return "https://aka.ms/vs/17/release/vs_buildtools.exe" } # VS2022
        default { throw "Unsupported Visual Studio version: $VsVersion" }
    }
}

# Start the setup process
Log-Info "VsYear is $VsYear"
Log-Info "VsVersion is $VsVersion"

$vsBuildToolsUrl = Get-VsInstallerUrl -VsVersion $VsVersion
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"
$vswherePath = "C:\temp\vswhere.exe"

# Download and install Visual Studio Build Tools
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs "--quiet --norestart"

# Download and use `vswhere` to locate the installation
if (-not (Test-Path $vswherePath)) {
    $vswhereUrl = "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe"
    Download-File -Url $vswhereUrl -Destination $vswherePath
}

$vswhereOutput = & $vswherePath -products '*' -version "[15.0,16.0)" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($vswhereOutput) {
    Log-Info "Found Visual Studio Build Tools installation at $vswhereOutput"
} else {
    throw "Visual Studio Build Tools installation not found."
}

# Validate installation
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

# Clean up temporary files
Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $vswherePath

Log-Info "Visual Studio Build Tools setup completed successfully."