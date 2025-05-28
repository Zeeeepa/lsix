# Simple Windows Deployment Script for lsix
# Build, deploy and start service

$ErrorActionPreference = "Stop"

# Configuration
$BINARY_NAME = "jetbra-free"
$OUTPUT_DIR = "./bin"
$SERVICE_URL = "http://127.0.0.1:8123"

# Create output directory
if (-not (Test-Path $OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path $OUTPUT_DIR -Force | Out-Null
}

# Check dependencies
if (-not (Get-Command "go" -ErrorAction SilentlyContinue)) {
    Write-Host "Go not found. Install from https://golang.org/dl/"
    exit 1
}

if (-not (Get-Command "go-bindata" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing go-bindata..."
    go install github.com/go-bindata/go-bindata/v3/go-bindata@latest
    $goPath = go env GOPATH
    $goBin = Join-Path $goPath "bin"
    $env:PATH = "$env:PATH;$goBin"
}

if (-not (Test-Path "go.mod")) {
    Write-Host "go.mod not found. Run from project root directory."
    exit 1
}

# Generate embedded assets
Write-Host "Generating assets..."
& go-bindata -o "internal/util/access.go" -pkg "util" "static/..." "templates/..."
if ($LASTEXITCODE -ne 0) {
    Write-Host "Asset generation failed"
    exit 1
}

# Build binary
Write-Host "Building Windows binary..."
$env:GOOS = "windows"
$env:GOARCH = "amd64"
$outputPath = Join-Path $OUTPUT_DIR "$BINARY_NAME-windows-amd64.exe"

& go build -ldflags "-s -w" -o $outputPath "cmd/main.go"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed"
    exit 1
}

Write-Host "Build completed: $outputPath"

# Start service
Write-Host "Starting service at $SERVICE_URL"
Start-Process $outputPath

# Wait a moment for service to start
Start-Sleep -Seconds 2

# Open browser
Start-Process $SERVICE_URL

Write-Host "Service started and browser opened"
