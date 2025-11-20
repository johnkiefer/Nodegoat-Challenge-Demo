# 2ms (Too Many Secrets) Setup for NodeGoat

This document describes the 2ms secret scanning solution configuration for the NodeGoat project.

## Overview

2ms is an open-source CLI tool from Checkmarx that helps detect exposed credentials, API keys, tokens, and other sensitive data. It's configured to scan both the filesystem and Git history of the NodeGoat project.

## Installation Status

✅ **2ms is installed** via Homebrew (version v4.7.0)

## Configuration Files

### `.2ms.yaml`
Main configuration file that defines:
- Log level and output formats
- Report paths (YAML, JSON, SARIF)
- Filesystem scan settings
- Ignore patterns for common directories

### `scan-nodegoat.sh`
Automated scanning script that:
- Performs filesystem scan
- Performs Git history scan
- Generates timestamped reports
- Provides summary output

## Usage

### Quick Scan (Filesystem Only)
```bash
2ms filesystem --path ./NodeGoat --config .2ms.yaml
```

### Quick Scan (Git History Only)
```bash
2ms git ./NodeGoat --depth 200 --project-name "NodeGoat-Git"
```

### Comprehensive Scan (Both Filesystem and Git)
```bash
./scan-nodegoat.sh
```

### Custom Scan with Validation
```bash
2ms filesystem --path ./NodeGoat --validate --report-path reports/custom-scan.json
```

## Scan Results

### Filesystem Scan Findings
The initial scan detected **3 secrets**:
1. **Private Key** (CVSS: 8.2) - `NodeGoat/artifacts/cert/server.key`
2. **Generic API Key** (CVSS: 8.2) - `NodeGoat/config/env/development.js`
3. **Generic API Key** (CVSS: 8.2) - `NodeGoat/config/env/test.js`

### Git History Scan Findings
The Git scan detected **2 secrets**:
1. **Authenticated URL** (CVSS: 8.2) - MongoDB credentials in `config/env/all.js` (historical commits)

## Reports

Reports are generated in the `reports/` directory in multiple formats:
- **YAML** - Human-readable format
- **JSON** - Machine-readable format for automation
- **SARIF** - Standard format for security tools (GitHub Advanced Security, etc.)

### Report Locations
- Filesystem scans: `reports/2ms-report.*` or `reports/filesystem-*.{yaml,json,sarif}`
- Git scans: `reports/git-scan.*` or `reports/git-*.{yaml,json,sarif}`

## Advanced Configuration

### Enable Secret Validation
To validate if discovered secrets are still active (requires API access):
```bash
2ms filesystem --path ./NodeGoat --validate
```

### Custom Rule Filtering
```bash
# Scan only specific rules
2ms filesystem --path ./NodeGoat --rule private-key --rule generic-api-key

# Exclude specific rules
2ms filesystem --path ./NodeGoat --ignore-rule generic-api-key
```

### List Available Rules
```bash
2ms rules
```

### Custom Regex Patterns
```bash
2ms filesystem --path ./NodeGoat --regex "password\s*=\s*['\"](.*)['\"]"
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run 2ms scan
  run: |
    2ms filesystem --path . \
      --stdout-format sarif \
      --report-path artifacts/2ms.sarif \
      --ignore-on-exit results
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: artifacts/2ms.sarif
```

## Exit Codes

- `0` - No secrets found
- `2` - Secrets detected
- Other - Errors occurred

Use `--ignore-on-exit results` to prevent exit code 2 when secrets are found (useful in CI/CD).

## Resources

- [2ms GitHub Repository](https://github.com/checkmarx/2ms)
- [2ms Documentation](https://github.com/checkmarx/2ms#readme)
- [List of Detection Rules](https://github.com/checkmarx/2ms/blob/master/docs/list-of-rules.md)

## Next Steps

1. Review the generated reports in `reports/` directory
2. Address the detected secrets in NodeGoat
3. Set up automated scanning in your CI/CD pipeline
4. Configure secret validation if needed
5. Customize ignore patterns based on your needs

