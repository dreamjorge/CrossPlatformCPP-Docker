param (
    [string]$VS_VERSION = $env:VS_VERSION,
    [string]$VS_YEAR = $env:VS_YEAR
)

# Validate that VS_VERSION and VS_YEAR are provided
if (-not $VS_VERSION) {
    Write-Error "VS_VERSION is not specified. Provide it as an argument or set it as an environment variable."
    exit 1
}

if (-not $VS_YEAR) {
    Write-Error "VS_YEAR is not specified. Provide it as an argument or set it as an environment variable."
    exit 1
}

# Construct the download URL based on VS_VERSION
if ($VS_VERSION -eq "16") {
    $vsBootstrapperUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe"
} elseif ($VS_VERSION -eq "17") {
    $vsBootstrapperUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
} else {
    Write-Error "Unsupported VS_VERSION: $VS_VERSION. Only 16 and 17 are supported."
    exit 1
}

$vsInstaller = "C:\TEMP\vs_buildtools.exe"

Write-Host "Downloading Visual Studio Build Tools version $VS_VERSION from $vsBootstrapperUrl..."
# Download the Visual Studio Build Tools bootstrapper
try {
    Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $vsInstaller -UseBasicParsing
    Write-Host "Download successful: $vsInstaller"
} catch {
    Write-Error "Failed to download Visual Studio Build Tools. Error: $($_.Exception.Message)"
    exit 1
}

Write-Host "Installing Visual Studio Build Tools version $VS_VERSION..."
$logPath = "C:\TEMP\vs_install_log.txt"

try {
    Start-Process -FilePath $vsInstaller -ArgumentList "--quiet", "--wait", "--norestart", "--nocache", `
        "--add", "Microsoft.VisualStudio.Workload.AzureBuildTools", `
        "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", `
        "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041", `
        "--installPath", "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools", `
        "--log", $logPath `
        -NoNewWindow -Wait
    Write-Host "Installation initiated. Logs at: $logPath"
} catch {
    Write-Error "Installation failed to start. Check logs at: $logPath"
    exit 1
}

# Wait until all installer processes are complete
Write-Host "Waiting for installer processes to complete..."
while (Get-Process -Name "vs_setup" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 10
}

Write-Host "Validating installation..."
$installPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools"

if (Test-Path $installPath) {
    Write-Host "Validation successful: Build Tools installed at $installPath"

    # Optionally, check for key executables
    $clPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe"
    $msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools\MSBuild\Current\Bin\MSBuild.exe"

    $clExists = Get-ChildItem -Path $clPath -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $msbuildExists = Test-Path $msbuildPath

    if ($clExists -and $msbuildExists) {
        Write-Host "Validation successful: cl.exe and MSBuild.exe found."
    } else {
        Write-Error "Validation failed: Required executables not found."
        Write-Host "Displaying installation log:"
        Get-Content -Path $logPath | Write-Host
        exit 1
    }
} else {
    Write-Error "Validation failed: Installation directory not found."
    Write-Host "Displaying installation log:"
    Get-Content -Path $logPath | Write-Host
    exit 1
}

Write-Host "Cleaning up..."
Remove-Item -Path $vsInstaller -Force -ErrorAction SilentlyContinue
Write-Host "Cleanup completed."