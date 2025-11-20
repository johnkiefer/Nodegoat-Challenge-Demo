# KICS (Keeping Infrastructure as Code Secure) Scan Results

## Overview

KICS (Keeping Infrastructure as Code Secure) by Checkmarx has been successfully installed and configured to scan both NodeGoat and cfngoat repositories independently.

**KICS Version:** 1.5.1  
**Installation Method:** Homebrew  
**Queries Path:** `/opt/homebrew/opt/kics/share/kics/assets/queries`

---

## NodeGoat Scan Results

**Scan Date:** $(date)  
**Repository:** [OWASP/NodeGoat](https://github.com/OWASP/NodeGoat)  
**Files Scanned:** 5  
**Queries Loaded:** 331  
**Scan Duration:** 3.5 seconds

### Summary
- **HIGH:** 0
- **MEDIUM:** 0
- **LOW:** 2
- **INFO:** 0
- **TOTAL:** 2

### Findings

#### 1. Healthcheck Instruction Missing (LOW)
- **Severity:** LOW
- **Platform:** Dockerfile
- **Location:** `NodeGoat/Dockerfile:1`
- **Description:** Ensure that HEALTHCHECK is being used. The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working.
- **Recommendation:** Add a HEALTHCHECK instruction to monitor container health.

#### 2. Chown Flag Exists (LOW)
- **Severity:** LOW
- **Platform:** Dockerfile
- **Location:** `NodeGoat/Dockerfile:13`
- **Description:** It is considered a best practice for every executable in a container to be owned by the root user even if it is executed by a non-root user, only execution permissions are required on the file, not ownership.
- **Recommendation:** Review the use of `--chown` flag in COPY instruction.

### Reports Generated
- `kics-reports/nodegoat/results.json`
- `kics-reports/nodegoat/results.html`
- `kics-reports/nodegoat/results.sarif`

---

## Cfngoat Scan Results

**Scan Date:** $(date)  
**Repository:** [bridgecrewio/cfngoat](https://github.com/bridgecrewio/cfngoat)  
**Files Scanned:** 4  
**Queries Loaded:** 772  
**Scan Duration:** 6.2 seconds

### Summary
- **HIGH:** 30
- **MEDIUM:** 31
- **LOW:** 17
- **INFO:** 2
- **TOTAL:** 80

### Critical Findings (HIGH Severity)

#### Security Groups & Network Issues
1. **Security Groups With Exposed Admin Ports** - SSH and other admin ports exposed
2. **Security Group With Unrestricted Access To SSH** - Port 22 open to all traffic
3. **HTTP Port Open** - HTTP port open in Security Group
4. **Unrestricted Security Group Ingress** - Security Group CIDR open to the world (3 instances)
5. **DB Security Group with Public Scope** - Database security group allows public access

#### S3 Bucket Security Issues
6. **S3 Static Website Host Enabled** - 5 buckets with public access
7. **S3 Bucket Without Server-side-encryption** - 4 buckets unencrypted
8. **S3 Bucket SSE Disabled** - 4 buckets without encryption configuration
9. **S3 Bucket Without SSL In Write Actions** - 5 buckets without SSL enforcement
10. **S3 Bucket ACL Allows Read to All Users** - Public read access enabled

#### Database Security Issues
11. **RDS Storage Not Encrypted** - RDS instance without encryption
12. **DB Instance Publicly Accessible** - RDS database publicly accessible
13. **CMK Unencrypted Storage** - Storage not encrypted by KMS (2 instances)
14. **IAM Database Auth Not Enabled** - IAM authentication disabled

#### Secrets & Credentials
15. **Passwords And Secrets - AWS Secret Key** - Hardcoded AWS secret key in EC2 user data
16. **Passwords And Secrets - AWS Access Key** - Hardcoded AWS access key in EC2 user data

#### VPC & Network Configuration
17. **VPC Without Network Firewall** - 2 VPCs without network firewall
18. **Instance With No VPC** - 2 EC2 instances not in VPC
19. **EC2 Instance Has Public IP** - 2 subnets with MapPublicIpOnLaunch enabled
20. **EC2 Instance Has No IAM Role** - EC2 instance without IAM role

### Medium Severity Findings (31 total)

Key issues include:
- **S3 Bucket Without Versioning** (2 instances)
- **S3 Bucket Should Have Bucket Policy** (5 instances)
- **RouterTable with Default Routing** (6 instances)
- **RDS With Backup Disabled**
- **RDS Multi-AZ Deployment Disabled**
- **Low RDS Backup Retention Period**
- **KMS Key Rotation Disabled**
- **EBS Volume Encryption Disabled**
- **EBS Volume Without KmsKeyId**
- **IAM User Without Password Reset**
- **Automatic Minor Upgrades Disabled**

### Low Severity Findings (17 total)

Includes:
- **VPC FlowLogs Disabled**
- **Shield Advanced Not In Use** (2 instances)
- **Security Group Rule Without Description** (4 instances)
- **S3 Bucket Logging Disabled** (4 instances)
- **RDS With Deletion Protection Disabled**
- **Lambda Functions Without X-Ray Tracing** (2 instances)
- **Lambda Function Without Dead Letter Queue** (2 instances)
- **IAM User With No Group**

### Info Findings (2 total)
- **EC2 Not EBS Optimized** (2 instances)

### Reports Generated
- `kics-reports/cfngoat/results.json`
- `kics-reports/cfngoat/results.html`
- `kics-reports/cfngoat/results.sarif`

---

## Key Insights

### NodeGoat
- **Low Risk Profile:** Only 2 low-severity Dockerfile best practice issues
- **No Critical Vulnerabilities:** No high or medium severity findings
- **Focus Areas:** Docker container health monitoring and file permissions

### Cfngoat
- **High Risk Profile:** 30 high-severity vulnerabilities detected
- **Intentional Vulnerabilities:** This is a "Vulnerable by Design" project for learning
- **Common Issues:**
  - Hardcoded AWS credentials in EC2 user data
  - Unencrypted S3 buckets and RDS instances
  - Publicly accessible resources
  - Missing security configurations
  - Insecure network configurations

---

## Comparison with 2ms Results

### Overlapping Findings
Both KICS and 2ms detected:
- **Hardcoded AWS credentials** in `cfngoat.yaml` (lines 69-70)
  - AWS Access Key ID: `AKIAIOSFODNN7EXAMAAA`
  - AWS Secret Access Key: `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`

### Complementary Coverage
- **2ms:** Focuses on secrets and credentials detection
- **KICS:** Focuses on Infrastructure as Code misconfigurations and security best practices

---

## Recommendations

### For NodeGoat
1. Add HEALTHCHECK instruction to Dockerfile
2. Review and optimize file ownership in container

### For Cfngoat (Learning/Training)
1. ✅ Use as educational material for IaC security
2. ✅ Practice remediation of identified vulnerabilities
3. ✅ Understand security best practices for AWS resources
4. ❌ **DO NOT deploy in production** - This is intentionally vulnerable

### For Production Environments
1. Enable encryption for all storage (S3, RDS, EBS)
2. Restrict security group access (no public SSH/HTTP)
3. Use IAM roles instead of hardcoded credentials
4. Enable VPC Flow Logs and network firewalls
5. Implement proper backup and retention policies
6. Use secrets management (AWS Secrets Manager, Parameter Store)
7. Enable versioning and logging for S3 buckets
8. Configure multi-AZ deployments for RDS

---

## Usage Commands

### Scan NodeGoat
```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
kics scan -p ./NodeGoat --report-formats json,html,sarif -o ./kics-reports/nodegoat
```

### Scan Cfngoat
```bash
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries
kics scan -p ./cfngoat --report-formats json,html,sarif -o ./kics-reports/cfngoat
```

### Scan with Specific Severities
```bash
kics scan -p ./cfngoat --fail-on high,medium -o ./kics-reports/cfngoat
```

### Exclude Specific Paths
```bash
kics scan -p ./NodeGoat --exclude-paths "node_modules/**,*.log" -o ./kics-reports/nodegoat
```

---

## Next Steps

1. Review detailed HTML reports in `kics-reports/` directories
2. Integrate KICS into CI/CD pipelines
3. Set up automated scanning on code commits
4. Create remediation plans for identified issues
5. Compare results with other IaC scanning tools (Checkov, Bridgecrew)

---

## Resources

- [KICS Documentation](https://docs.kics.io/)
- [KICS GitHub Repository](https://github.com/Checkmarx/kics)
- [KICS Supported Platforms](https://docs.kics.io/latest/platforms/)
- [KICS Query Catalog](https://docs.kics.io/develop/queries/all-queries/)

