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
    Log-Info "Starting Build Tools installation..."
    $installLogPath = "C:\temp\vs_buildtools_install.log"
    & $InstallerPath $InstallArgs > $installLogPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install Build Tools. Check the log: $installLogPath"
    }
    Log-Info "Build Tools installed successfully."
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

# Download and install Visual Studio Build Tools
Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath
$installArgs = "--quiet --wait --norestart `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.17763 `
    --add Microsoft.VisualStudio.Component.NuGet.BuildTools"
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs $installArgs

Log-Info "Visual Studio Build Tools setup completed successfully."