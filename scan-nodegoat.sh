#!/bin/bash

# 2ms Scanning Script for NodeGoat
# This script performs comprehensive secret scanning on the NodeGoat project

set -e

echo "========================================="
echo "2ms Secret Scanning for NodeGoat"
echo "========================================="
echo ""

# Create reports directory if it doesn't exist
mkdir -p reports

# Get current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "[1/3] Scanning filesystem for secrets..."
2ms filesystem --path ./NodeGoat \
  --config .2ms.yaml \
  --report-path "reports/filesystem-${TIMESTAMP}.yaml" \
  --report-path "reports/filesystem-${TIMESTAMP}.json" \
  --report-path "reports/filesystem-${TIMESTAMP}.sarif" \
  --project-name "NodeGoat-Filesystem"

FILESYSTEM_EXIT=$?

echo ""
echo "[2/3] Scanning Git history for secrets..."
2ms git ./NodeGoat \
  --depth 200 \
  --project-name "NodeGoat-Git" \
  --report-path "reports/git-${TIMESTAMP}.yaml" \
  --report-path "reports/git-${TIMESTAMP}.json" \
  --report-path "reports/git-${TIMESTAMP}.sarif" \
  --ignore-on-exit results || true

GIT_EXIT=$?

echo ""
echo "[3/3] Generating summary report..."
echo "========================================="
echo "Scan Summary:"
echo "========================================="
echo "Filesystem scan exit code: $FILESYSTEM_EXIT"
echo "Git scan exit code: $GIT_EXIT"
echo ""
echo "Reports generated in ./reports/ directory:"
ls -lh reports/*${TIMESTAMP}* 2>/dev/null || echo "No reports found"
echo ""
echo "========================================="

# Exit with non-zero if filesystem scan found secrets
if [ $FILESYSTEM_EXIT -ne 0 ]; then
  echo "⚠️  WARNING: Secrets detected in filesystem scan!"
  exit $FILESYSTEM_EXIT
fi

echo "✅ Scanning complete!"
exit 0

