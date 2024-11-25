# ===================================================================
# Set Strict Error Handling
# ===================================================================
$ErrorActionPreference = 'Stop';
$ProgressPreference = 'SilentlyContinue';

# ===================================================================
# Environment Variables (Passed from Docker Build Arguments)
# ===================================================================
$VS_VERSION = $env:VS_VERSION;
$CMAKE_VERSION = $env:CMAKE_VERSION;
$VS_BUILDTOOLS_PATH = 'C:\BuildTools';
$TEMP_DIR = 'C:\TEMP';

# ===================================================================
# Create TEMP Directory if it Doesn't Exist
# ===================================================================
if (-not (Test-Path -Path $TEMP_DIR)) {
    New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
}

# ===================================================================
# Download Visual Studio Build Tools Installer
# ===================================================================
Write-Host "Downloading Visual Studio Build Tools from https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe";
$vsBuildToolsUrl = "https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe";
$installerPath = Join-Path -Path $TEMP_DIR -ChildPath 'vs_buildtools.exe';
try {
    Invoke-WebRequest -Uri $vsBuildToolsUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop;
} catch {
    throw "Failed to download Visual Studio Build Tools installer: $_"
}

# ===================================================================
# Verify Installer Download
# ===================================================================
$installerSize = (Get-Item $installerPath).Length;
if ($installerSize -lt 1MB) {
    throw "Downloaded Visual Studio Build Tools installer is too small ($installerSize bytes). Download may have failed."
} else {
    Write-Host "Visual Studio Build Tools installer downloaded successfully! File size: $([Math]::Round($installerSize / 1MB, 2)) MB"
}

# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
Write-Host "Installing Visual Studio Build Tools...";

$installArgs = @(
    '--quiet',
    '--wait',
    '--norestart',
    '--installPath', "`"$VS_BUILDTOOLS_PATH`"",
    '--add', 'Microsoft.VisualStudio.Workload.VCTools',
    '--lang', 'en-US',
    '--log', "`"$(Join-Path -Path $TEMP_DIR -ChildPath 'vs_buildtools_install.log')`""
);

Write-Host "Installer Arguments: $($installArgs -join ' ')";

$process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -NoNewWindow -Wait -PassThru;

switch ($process.ExitCode) {
    0 { Write-Host "Visual Studio Build Tools installed successfully." }
    3010 {
        Write-Host "Visual Studio Build Tools installation completed with exit code 3010 (restart required). Continuing without restart..."
    }
    default {
        Write-Host "Visual Studio Build Tools installer failed with exit code $($process.ExitCode).";
        Write-Host "Installer log contents:";
        $logPath = Join-Path -Path $TEMP_DIR -ChildPath 'vs_buildtools_install.log';
        if (Test-Path $logPath) {
            Get-Content $logPath | Write-Host;
        } else {
            Write-Host "Installer log not found at $logPath.";
        }
        throw "Visual Studio