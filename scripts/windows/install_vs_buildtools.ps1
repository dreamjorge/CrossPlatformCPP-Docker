# Script with improved functions and error handling
param (
    [string]$VsVersion = $env:VS_VERSION,
    [string]$VsYear = $env:VS_YEAR
)

if (-not $VsVersion) { $VsVersion = "15" }
if (-not $VsYear) { $VsYear = "2017" }

Log-Info "VsYear is $VsYear"
Log-Info "VsVersion is $VsVersion"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$vsBuildToolsUrl = Get-VsInstallerUrl -VsVersion $VsVersion

$buildToolsPath = "C:\temp\vs_buildtools_$VsVersion.exe"
$vswherePath = "C:\temp\vswhere.exe"

Download-File -Url $vsBuildToolsUrl -Destination $buildToolsPath
Install-BuildTools -InstallerPath $buildToolsPath -InstallArgs "--quiet --norestart"

if (-not (Test-Path $vswherePath)) {
    $vswhereUrl = "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe"
    Download-File -Url $vswhereUrl -Destination $vswherePath
}

$vswhereOutput = & $vswherePath -products '*' -version "[15.0,16.0)" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vswhereOutput) {
    throw "Visual Studio Build Tools installation not found."
}

Log-Info "Found Visual Studio Build Tools at $vswhereOutput"
Validate-Installation -RequiredTools @("cl.exe", "msbuild.exe")

Clean-Up -FilePath $buildToolsPath
Clean-Up -FilePath $vswherePath
Log-Info "Setup completed successfully."