# Contributing to lsix

Thank you for your interest in contributing to lsix! This document provides guidelines and information for contributors.

## 🚀 Quick Start

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/lsix.git
   cd lsix
   ```
3. **Install dependencies**:
   ```bash
   go mod download
   go install github.com/go-bindata/go-bindata/v3/go-bindata@latest
   ```
4. **Build and test**:
   ```bash
   # Using PowerShell script (recommended)
   .\deploy-lsix.ps1 -Target local -Run
   
   # Or manually
   make run
   ```

## 🛠️ Development Setup

### Prerequisites
- **Go 1.19+** - [Download here](https://golang.org/dl/)
- **go-bindata** - For embedding static assets
- **Git** - For version control

### Project Structure
```
lsix/
├── cmd/                    # Application entry point
├── internal/
│   ├── certificate/        # Certificate generation logic
│   ├── core/               # Core application logic
│   └── util/               # Utility functions and embedded assets
├── static/                 # Static web assets (CSS, JS, icons)
├── templates/              # HTML templates
├── deploy-lsix.ps1        # PowerShell deployment script
└── Makefile               # Build automation
```

### Building from Source

#### Using PowerShell Script (Recommended)
```powershell
# Build for current platform
.\deploy-lsix.ps1 -Target local

# Build all platforms
.\deploy-lsix.ps1 -Target all -Package

# Build and run locally
.\deploy-lsix.ps1 -Target local -Run

# Clean build
.\deploy-lsix.ps1 -Target all -Clean
```

#### Using Make
```bash
# Install go-bindata if needed
make install-bindata

# Build for current platform
make build

# Build all platforms
make build-all

# Run locally
make run

# Clean build artifacts
make clean
```

## 📝 Code Guidelines

### Go Code Style
- Follow standard Go formatting (`gofmt`)
- Use meaningful variable and function names
- Add comments for exported functions and complex logic
- Handle errors appropriately
- Use Go modules for dependency management

### Commit Messages
Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Examples:
- `feat: add support for new IDE version`
- `fix: resolve license generation issue`
- `docs: update installation instructions`
- `refactor: improve error handling in core module`

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the code guidelines

3. **Test your changes**:
   ```bash
   # Test building
   .\deploy-lsix.ps1 -Target local
   
   # Test functionality
   .\deploy-lsix.ps1 -Target local -Run
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub

### Pull Request Requirements
- [ ] Code builds successfully on all platforms
- [ ] Changes are tested locally
- [ ] Commit messages follow conventional format
- [ ] PR description explains the changes and motivation
- [ ] No breaking changes (unless discussed)

## 🧪 Testing

### Manual Testing
1. Build the application using the deployment script
2. Run the application and verify the web interface loads
3. Test IDE activation/deactivation functionality
4. Verify backup and restore operations work correctly

### Automated Testing
The project uses GitHub Actions for automated testing:
- Builds are tested on multiple platforms
- Go tests are run automatically
- Release artifacts are generated for tags

## 🐛 Reporting Issues

When reporting issues, please include:
- **Operating System** and version
- **Go version** (`go version`)
- **JetBrains IDE** version and type
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Error messages** or logs if applicable

## 💡 Feature Requests

We welcome feature requests! Please:
1. Check existing issues to avoid duplicates
2. Clearly describe the feature and its benefits
3. Provide use cases and examples
4. Consider implementation complexity

## 📄 License

By contributing to lsix, you agree that your contributions will be licensed under the MIT License.

## 🤝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain a positive environment

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Code Review**: All contributions are reviewed for quality and security

Thank you for contributing to lsix! 🎉

