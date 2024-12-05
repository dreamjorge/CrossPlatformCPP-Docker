Param (
    [string]$CONFIG
)

# Use CONFIG from environment variable if parameter is not provided
if (-not $CONFIG) {
    $CONFIG = $env:CONFIG
}

if (-not $CONFIG) {
    "ERROR: Missing CONFIG parameter (Debug/Release)"
    exit 1
}

"Running application in $CONFIG mode."

# Determine BUILD_TYPE based on CONFIG
$BUILD_TYPE = $CONFIG

"BUILD_TYPE is $BUILD_TYPE"

# Specify the absolute path to the executable based on the build type
$EXEC_PATH = "$env:APP_WORKDIR\build\$BUILD_TYPE\CrossPlatformApp.exe"

"Executing: $EXEC_PATH"

# Execute the application
& "$EXEC_PATH"
$exitCode = $LASTEXITCODE

# Handle the exit code
if ($exitCode -ne 0) {
    "ERROR: Application execution failed with exit code $exitCode."
    exit $exitCode
} else {
    "Application executed successfully."
}
