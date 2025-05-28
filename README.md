# lsix - JetBrains IDE Activation Tool

<img src="image.gif" alt="lsix Demo" width="600">

[![Build Status](https://github.com/Zeeeepa/lsix/workflows/Build%20and%20Release/badge.svg)](https://github.com/Zeeeepa/lsix/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.19+-blue.svg)](https://golang.org/dl/)

**lsix** is a comprehensive JetBrains IDE activation tool with a user-friendly web interface. It provides one-click activation for JetBrains IDEs including IntelliJ IDEA, PyCharm, WebStorm, and more.

## ✨ Features

- **🎯 One-click activation**: Automatically inject activation components and license keys
- **🌐 Web interface**: Clean, intuitive web UI running on `http://127.0.0.1:8123`
- **🔄 Reversible**: Complete backup and restore functionality
- **🛡️ Safe**: Creates backups before any modifications
- **🖥️ Cross-platform**: Supports Windows, macOS, and Linux
- **📦 Portable**: Single binary with embedded assets

## 🚀 Quick Start

### Option 1: Using PowerShell Script (Recommended)
```powershell
# Download and extract the latest release
# Navigate to the project directory

# Build and run locally
.\deploy-lsix.ps1 -Target local -Run

# Build all platforms
.\deploy-lsix.ps1 -Target all -Package
```

### Option 2: Using Make
```bash
# Install dependencies
make install-bindata

# Build and run
make run

# Build all platforms
make build-all
```

### Option 3: Manual Build
```bash
# Install go-bindata
go install github.com/go-bindata/go-bindata/v3/go-bindata@latest

# Generate embedded assets
go-bindata -o internal/util/access.go -pkg util static/... templates/...

# Build
go build -o bin/jetbra-free cmd/main.go

# Run
./bin/jetbra-free
```

## 📋 Requirements

- **Go 1.19+** for building from source
- **JetBrains IDE** (any version)
- **Administrator/sudo privileges** may be required for IDE configuration modifications

## 🛠️ Usage

1. **Start the application**:
   ```bash
   ./jetbra-free  # Linux/macOS
   jetbra-free.exe  # Windows
   ```

2. **Open web interface**: Your browser should automatically open `http://127.0.0.1:8123`

3. **Select your IDE**: Click on the IDE card you want to activate

4. **Activate**: Click "Crack" to inject activation components

5. **Restart IDE**: Close and restart your JetBrains IDE

## 🔧 Advanced Usage

### PowerShell Deployment Script Options
```powershell
# Show help
.\deploy-lsix.ps1 -h

# Build specific platform
.\deploy-lsix.ps1 -Target windows -Verbose

# Clean build with packaging
.\deploy-lsix.ps1 -Target all -Clean -Package

# Skip dependency checks
.\deploy-lsix.ps1 -Target local -SkipDeps
```

### Environment Variables
- `DEBUG=1`: Enable debug logging for troubleshooting

## 🏗️ Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed development setup and contribution guidelines.

### Quick Development Setup
```bash
# Clone repository
git clone https://github.com/Zeeeepa/lsix.git
cd lsix

# Install dependencies
go mod download
go install github.com/go-bindata/go-bindata/v3/go-bindata@latest

# Build and run
.\deploy-lsix.ps1 -Target local -Run
```

## 📁 Project Structure

```
lsix/
├── cmd/main.go              # Application entry point
├── internal/
│   ├── certificate/         # Certificate generation
│   ├── core/               # Core activation logic
│   └── util/               # Utilities and embedded assets
├── static/                 # Web assets (CSS, JS, icons)
├── templates/              # HTML templates
├── deploy-lsix.ps1        # PowerShell deployment script
└── Makefile               # Build automation
```

## ⚠️ Important Notes

- **Educational Purpose**: This tool is for educational and research purposes
- **Backup**: Always creates backups before modifications
- **Reversible**: Use "UnCrack" to restore original settings
- **Keep Directory**: Don't delete the application directory after activation

## 🔄 Restore Original Settings

To restore your IDE to its original state:
1. Open the web interface
2. Select your IDE
3. Click "UnCrack"
4. Restart your IDE

## 🐛 Troubleshooting

### Common Issues
- **Permission denied**: Run as administrator/sudo
- **Web interface not loading**: Check firewall settings
- **Build failures**: Ensure Go 1.19+ and go-bindata are installed

### Debug Mode
Enable debug logging:
```bash
DEBUG=1 ./jetbra-free
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## ⭐ Star History

[![Stargazers over time](https://starchart.cc/Zeeeepa/lsix.svg?variant=adaptive)](https://starchart.cc/Zeeeepa/lsix)
