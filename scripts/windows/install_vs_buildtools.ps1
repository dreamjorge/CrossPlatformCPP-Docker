param (
    [string]$VsVersion = $env:VS_VERSION,
    [string]$VsYear = $env:VS_YEAR
)

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define Utility Functions
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
    $installLogPath = "C:\temp\vs_buildtools_install.log"
    if (-not (Test-Path "C:\temp")) {
        New-Item -ItemType Directory -Path "C:\temp" | Out-Null
    }
    Log-Info "Starting Build Tools installation..."
    & $InstallerPath $InstallArgs > $installLogPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Build Tools installation failed. Full Installation Log:"
        Get-Content $installLogPath | ForEach-Object { Write-Host $_ }
        throw "Failed to install Build Tools. Check the log: $installLogPath"
    }
    Log-Info "Build Tools installed successfully."
}

# Map Visual Studio Versions to URLs
Function Get-VsInstallerUrl {
    param([string]$VsVersion)
    switch ($VsVersion) {
        "15" { return "https://aka.ms/vs/15/release/vs_buildtools.exe" } # VS2017
        "16" { return "https://aka.ms/vs/16/release/vs_buildtools.exe" } # VS2019
        "17" { return "https://aka.ms/vs/17/release/vs_buildtools.exe" } # VS2022
        default { throw "Unsupported Visual Studio version: $VsVersion" }
    }
}

# Diagnostics
Log-Info "Checking for existing Visual Studio installations..."
$vswherePath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswherePath) {
    Log-Info "vswhere detected. Existing Visual Studio installations:"
    & $vswherePath -all -products * | ForEach-Object { Write-Host $_ }
} else {
    Log-Info "vswhere not found. No existing Visual Studio installations detected."
}

Log-Info "Checking for required Windows updates..."
(Get-HotFix).HotFixID | ForEach-Object { Write-Host "Installed HotFix: $_" }

# Start Setup
Log-Info "VsYear is $VsYear"
Log-Info "VsVersion is $VsVersion"

$vsBuildToolsUrl = Get-VsInstallerUrl -VsVersion $VsVersion
$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"

# Download and Install Build Tools
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath
$installArgs = "--quiet --wait --norestart `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 "
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs $installArgs

Log-Info "Visual Studio Build Tools setup completed successfully."