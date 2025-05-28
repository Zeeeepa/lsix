# ============================================================================
# lsix Deployment Script
# Comprehensive PowerShell script for building and deploying lsix
# ============================================================================

param(
    [Parameter(HelpMessage="Build target: 'local', 'all', 'windows', 'linux', 'darwin'")]
    [ValidateSet("local", "all", "windows", "linux", "darwin")]
    [string]$Target = "local",
    
    [Parameter(HelpMessage="Clean build directory before building")]
    [switch]$Clean,
    
    [Parameter(HelpMessage="Skip dependency checks")]
    [switch]$SkipDeps,
    
    [Parameter(HelpMessage="Run the application after building (local only)")]
    [switch]$Run,
    
    [Parameter(HelpMessage="Create deployment package")]
    [switch]$Package,
    
    [Parameter(HelpMessage="Output directory for builds")]
    [string]$OutputDir = "./bin",
    
    [Parameter(HelpMessage="Enable verbose output")]
    [switch]$Verbose
)

# Set error handling
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Configuration
$BINARY_NAME = "jetbra-free"
$GO_MODULE = "jetbra-free"
$REQUIRED_GO_VERSION = "1.19"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    Magenta = "Magenta"
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "🔄 $Message" $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" $Colors.Green
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" $Colors.Red
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" $Colors.Yellow
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Get-GoVersion {
    try {
        $version = go version 2>$null
        if ($version -match "go(\d+\.\d+)") {
            return $matches[1]
        }
        return $null
    }
    catch {
        return $null
    }
}

function Test-GoVersion {
    param([string]$RequiredVersion)
    $currentVersion = Get-GoVersion
    if (-not $currentVersion) {
        return $false
    }
    
    $required = [version]$RequiredVersion
    $current = [version]$currentVersion
    
    return $current -ge $required
}

# ============================================================================
# Dependency Checks
# ============================================================================

function Test-Dependencies {
    Write-Step "Checking dependencies..."
    
    $allGood = $true
    
    # Check Go installation
    if (-not (Test-Command "go")) {
        Write-Error "Go is not installed or not in PATH"
        Write-Host "Please install Go from: https://golang.org/dl/"
        $allGood = $false
    } else {
        $goVersion = Get-GoVersion
        Write-Success "Go $goVersion found"
        
        if (-not (Test-GoVersion $REQUIRED_GO_VERSION)) {
            Write-Warning "Go version $goVersion is older than recommended $REQUIRED_GO_VERSION"
        }
    }
    
    # Check go-bindata
    if (-not (Test-Command "go-bindata")) {
        Write-Warning "go-bindata not found, will install it..."
        try {
            Write-Step "Installing go-bindata..."
            go install github.com/go-bindata/go-bindata/v3/go-bindata@latest
            
            # Add GOPATH/bin to PATH if not already there
            $goPath = go env GOPATH
            $goBin = Join-Path $goPath "bin"
            if ($env:PATH -notlike "*$goBin*") {
                $env:PATH = "$env:PATH;$goBin"
                Write-Success "Added $goBin to PATH for this session"
            }
            
            if (Test-Command "go-bindata") {
                Write-Success "go-bindata installed successfully"
            } else {
                Write-Error "Failed to install go-bindata"
                $allGood = $false
            }
        }
        catch {
            Write-Error "Failed to install go-bindata: $_"
            $allGood = $false
        }
    } else {
        Write-Success "go-bindata found"
    }
    
    # Check if we're in the right directory
    if (-not (Test-Path "go.mod")) {
        Write-Error "go.mod not found. Please run this script from the lsix project root directory"
        $allGood = $false
    } else {
        Write-Success "Project structure validated"
    }
    
    return $allGood
}

# ============================================================================
# Build Functions
# ============================================================================

function New-OutputDirectory {
    if ($Clean -and (Test-Path $OutputDir)) {
        Write-Step "Cleaning output directory..."
        Remove-Item $OutputDir -Recurse -Force
        Write-Success "Output directory cleaned"
    }
    
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        Write-Success "Created output directory: $OutputDir"
    }
}

function Build-BinData {
    Write-Step "Generating embedded assets..."
    
    try {
        $bindataArgs = @(
            "-o", "internal/util/access.go",
            "-pkg", "util",
            "static/...",
            "templates/..."
        )
        
        & go-bindata @bindataArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Assets embedded successfully"
        } else {
            throw "go-bindata failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-Error "Failed to generate embedded assets: $_"
        throw
    }
}

function Build-Binary {
    param(
        [string]$OS,
        [string]$Arch,
        [string]$OutputName
    )
    
    $originalGOOS = $env:GOOS
    $originalGOARCH = $env:GOARCH
    
    try {
        $env:GOOS = $OS
        $env:GOARCH = $Arch
        
        $outputPath = Join-Path $OutputDir $OutputName
        
        Write-Step "Building for ${OS}/${Arch}..."
        
        $buildArgs = @(
            "build",
            "-ldflags", "-s -w",
            "-o", $outputPath,
            "cmd/main.go"
        )
        
        if ($Verbose) {
            $buildArgs += "-v"
        }
        
        & go @buildArgs
        
        if ($LASTEXITCODE -eq 0) {
            $size = (Get-Item $outputPath).Length
            $sizeKB = [math]::Round($size / 1KB, 2)
            Write-Success "Built $OutputName ($sizeKB KB)"
            return $outputPath
        } else {
            throw "Build failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-Error "Failed to build for ${OS}/${Arch}: $($_.Exception.Message)"
        throw
    }
    finally {
        $env:GOOS = $originalGOOS
        $env:GOARCH = $originalGOARCH
    }
}

function Build-AllTargets {
    $builds = @()
    
    switch ($Target) {
        "local" {
            $os = if ($IsWindows) { "windows" } elseif ($IsLinux) { "linux" } elseif ($IsMacOS) { "darwin" } else { "windows" }
            $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
            $ext = if ($os -eq "windows") { ".exe" } else { "" }
            $outputName = "$BINARY_NAME-$os-$arch$ext"
            
            $builds += Build-Binary $os $arch $outputName
        }
        
        "windows" {
            $builds += Build-Binary "windows" "amd64" "$BINARY_NAME-windows-amd64.exe"
            $builds += Build-Binary "windows" "arm64" "$BINARY_NAME-windows-arm64.exe"
        }
        
        "linux" {
            $builds += Build-Binary "linux" "amd64" "$BINARY_NAME-linux-amd64"
            $builds += Build-Binary "linux" "arm64" "$BINARY_NAME-linux-arm64"
        }
        
        "darwin" {
            $builds += Build-Binary "darwin" "amd64" "$BINARY_NAME-darwin-amd64"
            $builds += Build-Binary "darwin" "arm64" "$BINARY_NAME-darwin-arm64"
        }
        
        "all" {
            # Windows
            $builds += Build-Binary "windows" "amd64" "$BINARY_NAME-windows-amd64.exe"
            $builds += Build-Binary "windows" "arm64" "$BINARY_NAME-windows-arm64.exe"
            
            # Linux
            $builds += Build-Binary "linux" "amd64" "$BINARY_NAME-linux-amd64"
            $builds += Build-Binary "linux" "arm64" "$BINARY_NAME-linux-arm64"
            
            # macOS
            $builds += Build-Binary "darwin" "amd64" "$BINARY_NAME-darwin-amd64"
            $builds += Build-Binary "darwin" "arm64" "$BINARY_NAME-darwin-arm64"
        }
    }
    
    return $builds
}

# ============================================================================
# Packaging Functions
# ============================================================================

function New-DeploymentPackage {
    param([string[]]$BuiltFiles)
    
    Write-Step "Creating deployment package..."
    
    $packageDir = Join-Path $OutputDir "package"
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $packageName = "lsix-deployment-$timestamp"
    $packagePath = Join-Path $packageDir $packageName
    
    # Create package directory
    New-Item -ItemType Directory -Path $packagePath -Force | Out-Null
    
    # Copy binaries
    $binDir = Join-Path $packagePath "bin"
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    
    foreach ($file in $BuiltFiles) {
        Copy-Item $file $binDir -Force
    }
    
    # Copy documentation and assets
    $docsToInclude = @("README.md", "LICENSE")
    foreach ($doc in $docsToInclude) {
        if (Test-Path $doc) {
            Copy-Item $doc $packagePath -Force
        }
    }
    
    # Create deployment instructions
    $instructions = @"
# lsix Deployment Instructions

## Quick Start
1. Extract this package to your desired location
2. Navigate to the bin/ directory
3. Run the appropriate binary for your platform:
   - Windows: jetbra-free-windows-amd64.exe
   - Linux: ./jetbra-free-linux-amd64
   - macOS: ./jetbra-free-darwin-amd64 (Intel) or ./jetbra-free-darwin-arm64 (Apple Silicon)

## Web Interface
The application will start a web server at http://127.0.0.1:8123
Your browser should open automatically.

## Important Notes
- This tool modifies JetBrains IDE configuration files
- Backups are created automatically before modifications
- Use the "UnCrack" option to restore original settings
- Keep this directory intact after activation (IDEs reference these files)

## Troubleshooting
- Ensure JetBrains IDEs are closed before running
- Run as administrator/sudo if permission errors occur
- Check firewall settings if web interface doesn't load

Generated: $(Get-Date)
"@
    
    Set-Content -Path (Join-Path $packagePath "DEPLOYMENT.md") -Value $instructions
    
    # Create archive
    $archivePath = "$packagePath.zip"
    try {
        Compress-Archive -Path "$packagePath\*" -DestinationPath $archivePath -Force
        Write-Success "Package created: $archivePath"
        
        # Clean up temporary directory
        Remove-Item $packagePath -Recurse -Force
        
        return $archivePath
    }
    catch {
        Write-Error "Failed to create package archive: $_"
        throw
    }
}

# ============================================================================
# Main Execution
# ============================================================================

function Main {
    Write-ColorOutput "🚀 lsix Deployment Script" $Colors.Cyan
    Write-ColorOutput "=========================" $Colors.Cyan
    
    try {
        # Check dependencies
        if (-not $SkipDeps) {
            if (-not (Test-Dependencies)) {
                Write-Error "Dependency check failed. Use -SkipDeps to bypass."
                exit 1
            }
        }
        
        # Prepare output directory
        New-OutputDirectory
        
        # Generate embedded assets
        Build-BinData
        
        # Build targets
        Write-Step "Building target: $Target"
        $builtFiles = Build-AllTargets
        
        Write-Success "Build completed successfully!"
        Write-ColorOutput "Built files:" $Colors.Green
        foreach ($file in $builtFiles) {
            Write-Host "  📦 $file"
        }
        
        # Create package if requested
        if ($Package) {
            $packagePath = New-DeploymentPackage $builtFiles
            Write-Success "Deployment package ready: $packagePath"
        }
        
        # Run if requested (local builds only)
        if ($Run -and $Target -eq "local" -and $builtFiles.Count -eq 1) {
            Write-Step "Starting application..."
            Write-ColorOutput "🌐 Web interface will be available at: http://127.0.0.1:8123" $Colors.Cyan
            Write-ColorOutput "Press Ctrl+C to stop the application" $Colors.Yellow
            
            & $builtFiles[0]
        }
        
        Write-Success "Deployment script completed successfully! 🎉"
        
    }
    catch {
        Write-Error "Deployment failed: $_"
        exit 1
    }
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Show help if requested
if ($args -contains "-h" -or $args -contains "--help" -or $args -contains "/?") {
    Write-Host @"
lsix Deployment Script

USAGE:
    .\deploy-lsix.ps1 [OPTIONS]

OPTIONS:
    -Target [string]     Build target: 'local', 'all', 'windows', 'linux', 'darwin' (default: local)
    -Clean              Clean build directory before building
    -SkipDeps           Skip dependency checks
    -Run                Run the application after building (local only)
    -Package            Create deployment package
    -OutputDir [string] Output directory for builds (default: ./bin)
    -Verbose            Enable verbose output
    -h, --help, /?      Show this help message

EXAMPLES:
    .\deploy-lsix.ps1                           # Build for current platform
    .\deploy-lsix.ps1 -Target all -Package      # Build all platforms and create package
    .\deploy-lsix.ps1 -Target local -Run        # Build and run locally
    .\deploy-lsix.ps1 -Target windows -Clean    # Clean build Windows binaries
    .\deploy-lsix.ps1 -Target linux -Verbose    # Build Linux with verbose output

"@
    exit 0
}

# Run main function
Main
