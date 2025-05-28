# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest| :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in lsix, please report it responsibly:

### How to Report

1. **Do NOT** create a public GitHub issue for security vulnerabilities
2. Send an email to the maintainers with details about the vulnerability
3. Include steps to reproduce the issue if possible
4. Allow reasonable time for the issue to be addressed before public disclosure

### What to Include

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes or mitigations

### Response Timeline

- **Initial Response**: Within 48 hours of report
- **Status Update**: Within 7 days with preliminary assessment
- **Resolution**: Security fixes will be prioritized and released as soon as possible

### Responsible Disclosure

We follow responsible disclosure practices:
- We will acknowledge receipt of your report
- We will provide regular updates on our progress
- We will credit you for the discovery (unless you prefer to remain anonymous)
- We will coordinate the disclosure timeline with you

## Security Considerations

### General Security Notes

- This tool modifies system files and IDE configurations
- Always run from trusted sources
- Review code before building from source
- Use in isolated environments when possible

### Best Practices

- Keep the application updated to the latest version
- Run with minimal required privileges when possible
- Backup important data before using the tool
- Verify checksums of downloaded binaries

## Security Features

- **Backup Creation**: Automatic backup of original files before modification
- **Reversible Operations**: Complete restore functionality
- **Minimal Permissions**: Requests only necessary system access
- **Local Operation**: No network communication during normal operation

Thank you for helping keep lsix secure!

