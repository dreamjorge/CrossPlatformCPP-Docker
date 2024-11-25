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
    '--nocache',
    '--installPath', $VS_BUILDTOOLS_PATH,
    '--add', 'Microsoft.VisualStudio.Workload.VCTools',
    '--includeRecommended',
    '--lang', 'en-US',
    '--log', (Join-Path -Path $TEMP_DIR -ChildPath 'vs_buildtools_install.log')
);
$process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -NoNewWindow -Wait -PassThru;
switch ($process.ExitCode) {
    0 { Write-Host "Visual Studio Build Tools installed successfully." }
    3010 {
        Write-Host "Visual Studio Build Tools installation completed with exit code 3010 (restart required). Continuing without restart..."
    }
    default {
        Write-Host "Visual Studio Build Tools installer failed with exit code $($process.ExitCode).";
        Write-Host "Installer log contents:";
        Get-Content (Join-Path -Path $TEMP_DIR -ChildPath 'vs_buildtools_install.log') | Write-Host;
        throw "Visual Studio Build Tools installation failed. Check the log at $TEMP_DIR\vs_buildtools_install.log"
    }
}

# ===================================================================
# Clean Up Visual Studio Build Tools Installer and Log
# ===================================================================
Remove-Item -Path $installerPath -Force;
Remove-Item -Path (Join-Path -Path $TEMP_DIR -ChildPath 'vs_buildtools_install.log') -Force;

# ===================================================================
# Download and Install CMake
# ===================================================================
Write-Host "Downloading CMake version $CMAKE_VERSION...";
$cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi";
$cmakeInstaller = Join-Path -Path $TEMP_DIR -ChildPath 'cmake.msi';
try {
    Invoke-WebRequest -Uri $cmakeUrl -OutFile $cmakeInstaller -UseBasicParsing -ErrorAction Stop
} catch {
    throw "Failed to download CMake installer: $_"
}

# ===================================================================
# Verify CMake Installer Download
# ===================================================================
$cmakeInstallerSize = (Get-Item $cmakeInstaller).Length;
if ($cmakeInstallerSize -lt 500KB) {
    throw "Downloaded CMake installer is too small ($cmakeInstallerSize bytes). Download may have failed."
} else {
    Write-Host "CMake installer downloaded successfully! File size: $([Math]::Round($cmakeInstallerSize / 1MB, 2)) MB"
}

# ===================================================================
# Install CMake Silently
# ===================================================================
Write-Host "Installing CMake...";
Start-Process msiexec.exe -ArgumentList "/i `"$cmakeInstaller`" /quiet /qn /norestart" -Wait;

# ===================================================================
# Add CMake to System PATH
# ===================================================================
$cmakePath = 'C:\Program Files\CMake\bin';
Write-Host "Adding CMake to system PATH...";
[Environment]::SetEnvironmentVariable("Path", "$env:Path;$cmakePath", "Machine");

# ===================================================================
# Verify CMake Installation
# ===================================================================
Write-Host "Verifying CMake installation...";
cmake --version;

# ===================================================================
# Clean Up CMake Installer
# ===================================================================
Remove-Item -Path $cmakeInstaller -Force;

# ===================================================================
# Verify Visual Studio Build Tools Installation
# ===================================================================
Write-Host "Verifying Visual Studio Build Tools installation...";
$vswherePath = Join-Path -Path $VS_BUILDTOOLS_PATH -ChildPath 'Common7\Tools\vswhere.exe';
if (-Not (Test-Path $vswherePath)) {
    throw "vswhere.exe not found at $vswherePath. Visual Studio Build Tools may not be installed correctly."
} else {
    $installationPath = & $vswherePath -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath;
    if ([string]::IsNullOrEmpty($installationPath)) {
        throw "Visual Studio Build Tools installation not found by vswhere.exe."
    } else {
        Write-Host "Visual Studio Build Tools installed at: $installationPath"
    }
}