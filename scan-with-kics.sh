#!/bin/bash

# KICS Scanning Script for NodeGoat and Cfngoat
# This script performs Infrastructure as Code security scanning using KICS

set -e

# Set KICS queries path
export KICS_QUERIES_PATH=/opt/homebrew/opt/kics/share/kics/assets/queries

echo "========================================="
echo "KICS Infrastructure as Code Scanning"
echo "========================================="
echo ""

# Create reports directory if it doesn't exist
mkdir -p kics-reports

# Get current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "[1/2] Scanning NodeGoat repository..."
kics scan -p ./NodeGoat \
  --report-formats json,html,sarif \
  --output-path kics-reports/nodegoat-${TIMESTAMP} \
  --verbose || true

NODEGOAT_EXIT=$?

echo ""
echo "[2/2] Scanning Cfngoat repository..."
kics scan -p ./cfngoat \
  --report-formats json,html,sarif \
  --output-path kics-reports/cfngoat-${TIMESTAMP} \
  --verbose || true

CFNGOAT_EXIT=$?

echo ""
echo "========================================="
echo "Scan Summary:"
echo "========================================="
echo "NodeGoat scan exit code: $NODEGOAT_EXIT"
echo "Cfngoat scan exit code: $CFNGOAT_EXIT"
echo ""
echo "Reports generated in ./kics-reports/ directory:"
ls -lh kics-reports/*${TIMESTAMP}* 2>/dev/null || echo "No timestamped reports found"
echo ""
echo "Latest reports:"
ls -lh kics-reports/nodegoat/ 2>/dev/null || echo "No NodeGoat reports"
ls -lh kics-reports/cfngoat/ 2>/dev/null || echo "No Cfngoat reports"
echo ""
echo "========================================="

# Exit with non-zero if either scan found high severity issues
if [ $NODEGOAT_EXIT -ne 0 ] || [ $CFNGOAT_EXIT -ne 0 ]; then
  echo "⚠️  WARNING: High or medium severity issues detected!"
  exit 1
fi

echo "✅ Scanning complete!"
exit 0

