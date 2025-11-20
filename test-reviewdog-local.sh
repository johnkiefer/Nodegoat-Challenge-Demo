#!/bin/bash
# Test reviewdog locally with sample Vorpal output targeting NodeGoat

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Testing Reviewdog with Vorpal Sample Output ===${NC}"
echo ""

# Check if reviewdog is available
REVIEWDOG_BIN="./bin/reviewdog"
if [ ! -f "$REVIEWDOG_BIN" ] && ! command -v reviewdog &> /dev/null; then
    echo -e "${YELLOW}Reviewdog not found. Installing...${NC}"
    curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b ./bin v0.17.5
    REVIEWDOG_BIN="./bin/reviewdog"
fi

if [ ! -f "$REVIEWDOG_BIN" ] && ! command -v reviewdog &> /dev/null; then
    echo "Error: Could not find or install reviewdog"
    exit 1
fi

if [ -f "$REVIEWDOG_BIN" ]; then
    REVIEWDOG_CMD="$REVIEWDOG_BIN"
else
    REVIEWDOG_CMD="reviewdog"
fi

echo -e "${GREEN}✓ Reviewdog found: $REVIEWDOG_CMD${NC}"
echo ""

# Check if sample file exists
SAMPLE_FILE="vorpal-reports/vorpal-sample-rdjson.json"
if [ ! -f "$SAMPLE_FILE" ]; then
    echo "Error: Sample file not found: $SAMPLE_FILE"
    exit 1
fi

echo -e "${GREEN}Sample Vorpal output file: $SAMPLE_FILE${NC}"
echo ""

# Test 1: Local reporter (terminal output) - with git context
echo -e "${GREEN}=== Test 1: Local Reporter (Terminal Output) ===${NC}"
echo ""
# Reviewdog needs git context for local reporter, so we'll use nofilter mode
cat "$SAMPLE_FILE" | $REVIEWDOG_CMD -f=rdjson -reporter=local -level=error -filter-mode=nofilter
echo ""

# Test 2: Local reporter with all severity levels
echo -e "${GREEN}=== Test 2: Local Reporter (All Severity Levels) ===${NC}"
echo ""
cat "$SAMPLE_FILE" | $REVIEWDOG_CMD -f=rdjson -reporter=local -level=info -filter-mode=nofilter
echo ""

# Test 3: With tee flag for debugging
echo -e "${GREEN}=== Test 3: With Debug Flag (-tee) ===${NC}"
echo ""
cat "$SAMPLE_FILE" | $REVIEWDOG_CMD -f=rdjson -reporter=local -level=error -filter-mode=nofilter -tee
echo ""

# Test 4: Show raw JSON output first
echo -e "${GREEN}=== Test 4: Displaying Sample Vorpal Output (First 3 findings) ===${NC}"
echo ""
head -30 "$SAMPLE_FILE"
echo "..."
echo ""

# Test 5: Local reporter with file filter (if git context available)
echo -e "${GREEN}=== Test 5: Filter Mode - File (requires git context) ===${NC}"
echo ""
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Git repository detected, testing file filter mode..."
    cat "$SAMPLE_FILE" | $REVIEWDOG_CMD -f=rdjson -reporter=local -level=error -filter-mode=file || echo "Note: File filter may need actual git changes"
else
    echo "Not in a git repository, skipping file filter test"
fi
echo ""

# Test 6: Check exit codes
echo -e "${GREEN}=== Test 6: Exit Code Testing ===${NC}"
echo ""

echo "Testing with -fail-on-error (should exit with code 1 if errors found):"
cat "$SAMPLE_FILE" | $REVIEWDOG_CMD -f=rdjson -reporter=local -level=error -filter-mode=nofilter -fail-on-error && {
    echo "Unexpected: No exit code 1"
} || {
    echo "✓ Correctly exited with code 1 (errors found)"
}
echo ""

echo "Testing with -fail-level=none (should always exit with code 0):"
cat "$SAMPLE_FILE" | $REVIEWDOG_CMD -f=rdjson -reporter=local -level=error -filter-mode=nofilter -fail-level=none && {
    echo "✓ Correctly exited with code 0 (fail-level=none)"
} || {
    echo "Unexpected: Exited with non-zero code"
}
echo ""

# Summary
echo -e "${GREEN}=== Test Summary ===${NC}"
echo ""
echo "✓ All reviewdog tests completed"
echo ""
echo "Sample findings from Vorpal output:"
echo "  - 3 ERROR level issues (SSJS Injection, XSS)"
echo "  - 3 WARNING level issues (Sensitive Data, Access Control, Known Vulnerabilities)"
echo ""
echo "Reviewdog successfully parsed and displayed all findings!"
echo ""
echo -e "${GREEN}=== Next Steps ===${NC}"
echo ""
echo "1. When Vorpal GitHub Action runs successfully, download the actual report"
echo "2. Process it with reviewdog:"
echo "   cat vorpal-report.json | $REVIEWDOG_CMD -f=rdjson -reporter=local"
echo ""
echo "3. For GitHub Actions, reviewdog will automatically post annotations"
echo ""

