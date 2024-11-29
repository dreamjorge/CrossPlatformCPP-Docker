# Ensure C:\TEMP exists
if (-not (Test-Path "C:\TEMP")) {
    Write-Host "Creating C:\TEMP directory..."
    New-Item -ItemType Directory -Path "C:\TEMP" | Out-Null
}

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
switch ($VS_VERSION) {
    "16" { $vsBootstrapperUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe" }
    "17" { $vsBootstrapperUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe" }
    default {
        Write-Error "Unsupported VS_VERSION: $VS_VERSION. Only 16 and 17 are supported."
        exit 1
    }
}

$vsInstaller = "C:\TEMP\vs_buildtools.exe"
$logPath = "C:\TEMP\vs_install_log.txt"
$installerOutputLog = "C:\TEMP\installer_output.log"
$installerErrorLog = "C:\TEMP\installer_error.log"

Write-Host "Downloading Visual Studio Build Tools version $VS_VERSION from $vsBootstrapperUrl..."
# Download the Visual Studio Build Tools bootstrapper
try {
    Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $vsInstaller -UseBasicParsing -Verbose
    Write-Host "Download successful: $vsInstaller"
} catch {
    Write-Error "Failed to download Visual Studio Build Tools. Error: $($_.Exception.Message)"
    exit 1
}

Write-Host "Installing Visual Studio Build Tools version $VS_VERSION..."
$installerArguments = @(
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--add", "Microsoft.VisualStudio.Workload.AzureBuildTools",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",
    "--installPath", "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools",
    "--log", $logPath
)

Write-Host "Running installer with arguments: $installerArguments"

# Run the installer and capture output and errors
try {
    Start-Process -FilePath $vsInstaller -ArgumentList $installerArguments -NoNewWindow -Wait -RedirectStandardOutput $installerOutputLog -RedirectStandardError $installerErrorLog
    Write-Host "Installer process completed."
} catch {
    Write-Error "Failed to run installer: $($_.Exception.Message)"
    exit 1
}

# Check if log file was created
if (Test-Path $logPath) {
    Write-Host "Installation log created at $logPath"
} else {
    Write-Host "Installation log not found at $logPath. Checking for installer output log..."
    if (Test-Path $installerOutputLog) {
        Write-Host "Installer output log found at $installerOutputLog. Checking for errors..."
        $outputLogContent = Get-Content -Path $installerOutputLog
        if ($outputLogContent -match "Error") {
            Write-Error "Installer output log contains errors. Installation failed."
            exit 1
        } else {
            Write-Host "Installer output log does not contain errors. Installation successful."
        }
    } else {
        Write-Error "Installer output log not found at $installerOutputLog. Installation failed."
        exit 1
    }
}

# Validate installation path
Write-Host "Validating installation..."
$installPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools"

if (Test-Path $installPath) {
    Write-Host "Validation successful: Build Tools installed at $installPath"
    
    # Check for key executables
    $clPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe"
    $msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    
    $clExists = Get-ChildItem -Path $clPath -Recurse -
