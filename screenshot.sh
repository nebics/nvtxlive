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
PAGES_JSON="pages.json"
WIDTH="1920"
DEV_SERVER_PID=""

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
    echo "  --width <px>    Viewport width (default: 1920)"
    echo "  --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./screenshot.sh"
    echo "  ./screenshot.sh screenshots/v3"
    echo "  ./screenshot.sh docs/images --url https://dev_env1:z7kws3mfl5e2y@novintix-v3.pages.dev"
    echo "  ./screenshot.sh screenshots --width 1440"
    exit 1
}

cleanup() {
    if [ -n "$DEV_SERVER_PID" ]; then
        echo -e "\n${YELLOW}Stopping dev server...${NC}"
        kill $DEV_SERVER_PID 2>/dev/null || true
        wait $DEV_SERVER_PID 2>/dev/null || true
    fi
}

trap cleanup EXIT

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            BASE_URL="$2"
            shift 2
            ;;
        --width)
            WIDTH="$2"
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

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Full-Page Screenshot Capture${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if pages.json exists
if [ ! -f "$PAGES_JSON" ]; then
    echo -e "${RED}Error: $PAGES_JSON not found${NC}"
    exit 1
fi

# Check/install pageres-cli
echo -e "\n${YELLOW}[1/4] Checking dependencies...${NC}"
if ! command -v pageres &> /dev/null; then
    echo "Installing pageres-cli..."
    npm install -g pageres-cli
fi
echo "✓ pageres-cli ready"

# Check/install jq for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    brew install jq
fi
echo "✓ jq ready"

# Start dev server if no URL provided
if [ -z "$BASE_URL" ]; then
    echo -e "\n${YELLOW}[2/4] Starting dev server...${NC}"
    npm run dev > /dev/null 2>&1 &
    DEV_SERVER_PID=$!

    # Wait for server to start
    echo -n "Waiting for server"
    for i in {1..30}; do
        if curl -s http://localhost:4321 > /dev/null 2>&1; then
            echo ""
            echo "✓ Dev server running on http://localhost:4321"
            break
        fi
        echo -n "."
        sleep 1
    done

    if ! curl -s http://localhost:4321 > /dev/null 2>&1; then
        echo -e "\n${RED}Error: Dev server failed to start${NC}"
        exit 1
    fi

    BASE_URL=$(jq -r '.baseUrl' "$PAGES_JSON")
else
    echo -e "\n${YELLOW}[2/4] Using remote URL: $BASE_URL${NC}"
fi

# Create output directory
echo -e "\n${YELLOW}[3/4] Creating output directory...${NC}"
mkdir -p "$OUTPUT_DIR"
echo "✓ Output: $OUTPUT_DIR/"

# Capture screenshots
echo -e "\n${YELLOW}[4/4] Capturing screenshots...${NC}"

PAGES=$(jq -r '.pages[]' "$PAGES_JSON")
TOTAL=$(echo "$PAGES" | wc -l | tr -d ' ')
COUNT=0

for page in $PAGES; do
    COUNT=$((COUNT + 1))

    # Create filename from path
    if [ "$page" = "/" ]; then
        FILENAME="index"
    else
        # Remove leading slash, replace remaining slashes with underscores
        FILENAME=$(echo "$page" | sed 's|^/||' | sed 's|/|_|g')
    fi

    FULL_URL="${BASE_URL}${page}"
    OUTPUT_PATH="${OUTPUT_DIR}/${FILENAME}.png"

    echo -e "[$COUNT/$TOTAL] Capturing: $page"

    # Remove existing file
    rm -f "$OUTPUT_PATH"

    # Capture screenshot
    pageres "$FULL_URL" "${WIDTH}x800" \
        --filename="<%= url %>" \
        --overwrite \
        --crop \
        --delay=2 \
        2>/dev/null || true

    # Move and rename the file
    GENERATED_FILE=$(ls -t *.png 2>/dev/null | head -1)
    if [ -n "$GENERATED_FILE" ]; then
        mv "$GENERATED_FILE" "$OUTPUT_PATH"
        echo "   ✓ Saved: $OUTPUT_PATH"
    else
        echo -e "   ${RED}✗ Failed to capture${NC}"
    fi
done

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Screenshots complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nCaptured $COUNT pages to: ${OUTPUT_DIR}/"
echo ""
ls -la "$OUTPUT_DIR"/*.png 2>/dev/null || echo "No screenshots found"
