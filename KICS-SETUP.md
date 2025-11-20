# KICS (Keeping Infrastructure as Code Secure) Setup Guide

## Installation Status

✅ **KICS is installed** via Homebrew (version 1.5.1)

### Installation Details
- **Method:** Homebrew (`brew install Checkmarx/tap/kics`)
- **Queries Path:** `/opt/homebrew/opt/kics/share/kics/assets/queries`
- **Location:** `/opt/homebrew/Cellar/kics/1.5.1`

## Configuration

### Environment Variable
To use KICS default queries, set the environment variable:

```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
```

To make this permanent, add to your `~/.zshrc`:
```bash
echo 'export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries' >> ~/.zshrc
source ~/.zshrc
```

## Supported Platforms

KICS can scan the following Infrastructure as Code formats:
- ✅ **Terraform**
- ✅ **CloudFormation** (AWS)
- ✅ **Kubernetes**
- ✅ **Docker** / Docker Compose
- ✅ **Ansible**
- ✅ **Helm**
- ✅ **OpenAPI**
- ✅ **Azure Resource Manager**
- ✅ **Google Deployment Manager**
- ✅ **CDK** (Cloud Development Kit)
- ✅ **SAM** (Serverless Application Model)
- ✅ **Knative**
- ✅ **Crossplane**

## Usage

### Quick Scan
```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
kics scan -p ./path/to/project --report-formats json,html,sarif -o ./reports
```

### Automated Scanning Script
Use the provided script to scan both repositories:
```bash
./scan-with-kics.sh
```

### Individual Repository Scans

#### Scan NodeGoat
```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
kics scan -p ./NodeGoat --report-formats json,html,sarif -o ./kics-reports/nodegoat
```

#### Scan Cfngoat
```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
kics scan -p ./cfngoat --report-formats json,html,sarif -o ./kics-reports/cfngoat
```

## Command Options

### Report Formats
- `json` - Machine-readable JSON format
- `html` - Human-readable HTML report
- `sarif` - SARIF format for security tools integration
- `pdf` - PDF report (if available)

### Filtering Options
```bash
# Scan only high severity issues
kics scan -p ./cfngoat --fail-on high

# Exclude specific paths
kics scan -p ./NodeGoat --exclude-paths "node_modules/**,*.log"

# Exclude specific severities
kics scan -p ./cfngoat --exclude-severities info,low

# Exclude specific categories
kics scan -p ./cfngoat --exclude-categories "Best practices"
```

### Cloud Provider Filtering
```bash
# Scan only AWS resources
kics scan -p ./cfngoat --cloud-provider aws

# Scan multiple cloud providers
kics scan -p ./project --cloud-provider aws,azure,gcp
```

## Scan Results

### NodeGoat Results
- **Files Scanned:** 5 (Dockerfile, docker-compose.yml, etc.)
- **Total Issues:** 2 (LOW severity)
- **Focus:** Docker best practices

### Cfngoat Results
- **Files Scanned:** 4 (CloudFormation templates)
- **Total Issues:** 80
  - HIGH: 30
  - MEDIUM: 31
  - LOW: 17
  - INFO: 2
- **Focus:** AWS infrastructure misconfigurations

## Report Locations

All reports are saved in the `kics-reports/` directory:
- **NodeGoat:** `kics-reports/nodegoat/results.{json,html,sarif}`
- **Cfngoat:** `kics-reports/cfngoat/results.{json,html,sarif}`

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: KICS Scan
on: [push, pull_request]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run KICS scan
        uses: checkmarx/kics-github-action@v1.0.0
        with:
          path: '.'
          output_path: './kics-results'
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: './kics-results/results.sarif'
```

## Updating KICS

To update to the latest version:
```bash
brew upgrade kics
```

**Note:** A newer version (v2.1.16) is available. Consider updating for latest features and security improvements.

## Resources

- [KICS Official Documentation](https://docs.kics.io/)
- [KICS GitHub Repository](https://github.com/Checkmarx/kics)
- [KICS Query Catalog](https://docs.kics.io/develop/queries/all-queries/)
- [KICS Supported Platforms](https://docs.kics.io/latest/platforms/)

## Troubleshooting

### Queries Not Found
If you see errors about missing queries:
```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
```

### Custom Queries Path
You can specify a custom queries path:
```bash
kics scan -p ./project --queries-path /path/to/custom/queries
```

### Verbose Output
For detailed scan information:
```bash
kics scan -p ./project --verbose
```

