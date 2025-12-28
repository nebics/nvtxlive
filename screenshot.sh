#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
OUTPUT_DIR="screenshots"
BASE_URL=""

usage() {
    echo -e "${YELLOW}Usage:${NC} ./screenshot.sh [output-folder] [options]"
    echo ""
    echo "Capture full-page screenshots of all pages defined in pages.json"
    echo ""
    echo -e "${YELLOW}Arguments:${NC}"
    echo "  output-folder   Target folder for screenshots (default: screenshots)"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  --url <url>     Use remote URL instead of local dev server"
    echo "  --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./screenshot.sh"
    echo "  ./screenshot.sh screenshots/v3"
    echo "  ./screenshot.sh screenshots/v3 --url https://dev_env1:z7kws3mfl5e2y@novintix-v3.pages.dev"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            BASE_URL="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
        *)
            OUTPUT_DIR="$1"
            shift
            ;;
    esac
done

# Check if pages.json exists
if [ ! -f "pages.json" ]; then
    echo -e "${RED}Error: pages.json not found${NC}"
    exit 1
fi

# Check if playwright is installed
if ! npm list playwright > /dev/null 2>&1; then
    echo -e "${YELLOW}Installing playwright...${NC}"
    npm install --save-dev playwright
    npx playwright install chromium
fi

# Run the capture script
if [ -z "$BASE_URL" ]; then
    node capture-screenshots.cjs "$OUTPUT_DIR"
else
    node capture-screenshots.cjs "$OUTPUT_DIR" "$BASE_URL"
fi
