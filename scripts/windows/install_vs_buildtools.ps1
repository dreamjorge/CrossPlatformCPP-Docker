# Validate URLs
if (-not $BuildToolsUrl -or -not $ChannelUrl) {
    Write-Error "ERROR: BuildToolsUrl or ChannelUrl is empty. Ensure the values are passed correctly."
    exit 1
}

if (-not ($BuildToolsUrl -match "^https?:\/\/")) {
    Write-Error "ERROR: Invalid BuildToolsUrl format: $BuildToolsUrl"
    exit 1
}

if (-not ($ChannelUrl -match "^https?:\/\/")) {
    Write-Error "ERROR: Invalid ChannelUrl format: $ChannelUrl"
    exit 1
}

Write-Host "INFO: BuildToolsUrl=$BuildToolsUrl"
Write-Host "INFO: ChannelUrl=$ChannelUrl"