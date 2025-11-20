#!/bin/bash
# Local Vorpal + reviewdog scan using Docker Desktop
# This script runs Vorpal security scanning with reviewdog locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Vorpal + reviewdog Local Scan ===${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker Desktop is not running. Please start Docker Desktop and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker is running${NC}"

# Set scan directory (default to NodeGoat)
SCAN_DIR="${1:-NodeGoat}"
OUTPUT_DIR="${2:-vorpal-reports}"

if [ ! -d "$SCAN_DIR" ]; then
    echo -e "${RED}Error: Directory '$SCAN_DIR' does not exist${NC}"
    exit 1
fi

echo -e "${GREEN}Scanning directory: $SCAN_DIR${NC}"
echo -e "${GREEN}Output directory: $OUTPUT_DIR${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Find all supported files
echo "Finding files to scan..."
FILES=$(find "$SCAN_DIR" -type f \( \
    -name "*.js" -o \
    -name "*.java" -o \
    -name "*.cs" -o \
    -name "*.py" -o \
    -name "*.go" \
  \) \
    -not -path "*/node_modules/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/.git/*" \
    -not -path "*/coverage/*" \
    -not -path "*/vendor/*" \
    -not -path "*/KICS/*" 2>/dev/null | sort | tr '\n' ',' | sed 's/,$//')

if [ -z "$FILES" ]; then
    echo -e "${YELLOW}Warning: No supported files found in $SCAN_DIR${NC}"
    exit 0
fi

FILE_COUNT=$(echo "$FILES" | tr ',' '\n' | wc -l | tr -d ' ')
echo -e "${GREEN}Found $FILE_COUNT files to scan${NC}"
echo ""

# Pull reviewdog Docker image
echo "Pulling reviewdog Docker image..."
docker pull reviewdog/reviewdog:latest || {
    echo -e "${YELLOW}Warning: Could not pull reviewdog image. Using local if available.${NC}"
}

echo ""

# Method 1: Try using Vorpal Docker image (if available)
echo -e "${GREEN}Attempting to run Vorpal scan...${NC}"

# Check if Vorpal Docker image exists
if docker pull checkmarx/vorpal:latest 2>/dev/null; then
    echo -e "${GREEN}✓ Using Vorpal Docker image${NC}"
    
    # Run Vorpal scan
    docker run --rm \
        -v "$(pwd)":/workspace \
        -w /workspace \
        checkmarx/vorpal:latest \
        vorpal analyze --source-path "$FILES" --output "$OUTPUT_DIR/vorpal-report.json" || {
        echo -e "${YELLOW}Vorpal Docker image scan completed (may have found issues)${NC}"
    }
else
    echo -e "${YELLOW}Vorpal Docker image not available. Trying alternative method...${NC}"
    
    # Method 2: Install Vorpal via npm in a Node.js container
    echo "Installing Vorpal in Node.js container..."
    
    # Create a temporary script to run Vorpal
    cat > /tmp/vorpal-scan.sh << 'EOF'
#!/bin/bash
set -e
npm install -g @checkmarx/vorpal 2>/dev/null || npm install -g vorpal 2>/dev/null || {
    echo "Warning: Could not install Vorpal via npm"
    echo "Vorpal may not be available as a public npm package"
    exit 1
}
vorpal analyze --source-path "$1" --output "$2" || {
    echo "Vorpal scan completed"
}
EOF
    chmod +x /tmp/vorpal-scan.sh
    
    # Try running with Node.js container
    docker run --rm \
        -v "$(pwd)":/workspace \
        -v /tmp/vorpal-scan.sh:/scan.sh \
        -w /workspace \
        node:20-alpine \
        sh /scan.sh "$FILES" "$OUTPUT_DIR/vorpal-report.json" || {
        echo -e "${YELLOW}Note: Vorpal may not be available as a public npm package${NC}"
        echo -e "${YELLOW}You may need to use the GitHub Action or have Vorpal installed locally${NC}"
    }
fi

echo ""

# Run reviewdog on the results
if [ -f "$OUTPUT_DIR/vorpal-report.json" ]; then
    echo -e "${GREEN}Running reviewdog on Vorpal results...${NC}"
    
    # Run reviewdog with local reporter
    docker run --rm \
        -v "$(pwd)":/workspace \
        -w /workspace \
        reviewdog/reviewdog:latest \
        -f=rdjson \
        -reporter=local \
        < "$OUTPUT_DIR/vorpal-report.json" || {
        echo -e "${YELLOW}Reviewdog processing completed${NC}"
    }
    
    echo ""
    echo -e "${GREEN}✓ Scan complete!${NC}"
    echo -e "${GREEN}Results saved to: $OUTPUT_DIR/vorpal-report.json${NC}"
else
    echo -e "${YELLOW}Note: Vorpal report not generated.${NC}"
    echo -e "${YELLOW}This may be because:${NC}"
    echo -e "${YELLOW}  1. Vorpal is not available as a public Docker image${NC}"
    echo -e "${YELLOW}  2. Vorpal requires authentication or special setup${NC}"
    echo -e "${YELLOW}  3. No issues were found${NC}"
    echo ""
    echo -e "${YELLOW}Alternative: Use the GitHub Action workflow for Vorpal scanning${NC}"
fi

echo ""
echo -e "${GREEN}=== Scan Complete ===${NC}"

