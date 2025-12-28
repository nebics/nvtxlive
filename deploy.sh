#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
PROJECT_NAME=""
SKIP_BUILD=false

usage() {
    echo -e "${YELLOW}Usage:${NC} ./deploy.sh <project-name> [options]"
    echo ""
    echo "Deploy Astro site to Cloudflare Pages with cache purge"
    echo ""
    echo -e "${YELLOW}Arguments:${NC}"
    echo "  project-name    Cloudflare Pages project name (e.g., novintix-v3)"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  --skip-build    Skip npm build step (use existing dist folder)"
    echo "  --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./deploy.sh novintix-v3"
    echo "  ./deploy.sh novintix-v3 --skip-build"
    exit 1
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --help)
            usage
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                echo -e "${RED}Error: Unexpected argument $1${NC}"
                usage
            fi
            shift
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    usage
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deploying to: ${PROJECT_NAME}.pages.dev${NC}"
echo -e "${GREEN}========================================${NC}"

# Step 1: Clean previous build
echo -e "\n${YELLOW}[1/5] Cleaning previous build...${NC}"
rm -rf dist
echo "✓ Cleaned dist folder"

# Step 2: Install dependencies (ensure fresh)
echo -e "\n${YELLOW}[2/5] Installing dependencies...${NC}"
npm ci
echo "✓ Dependencies installed"

# Step 3: Build
if [ "$SKIP_BUILD" = false ]; then
    echo -e "\n${YELLOW}[3/5] Building Astro site...${NC}"
    npm run build
    echo "✓ Build complete"
else
    echo -e "\n${YELLOW}[3/5] Skipping build (--skip-build)${NC}"
fi

# Step 4: Add Basic Auth Worker
echo -e "\n${YELLOW}[4/5] Adding HTTP Basic Auth worker...${NC}"
cat > dist/_worker.js << 'EOF'
const CREDENTIALS = {
  username: 'dev_env1',
  password: 'z7kws3mfl5e2y'
};

export default {
  async fetch(request, env) {
    const authorization = request.headers.get('Authorization');

    if (!authorization) {
      return new Response('Authentication required', {
        status: 401,
        headers: {
          'WWW-Authenticate': 'Basic realm="Protected Area"'
        }
      });
    }

    const [scheme, encoded] = authorization.split(' ');

    if (scheme !== 'Basic') {
      return new Response('Invalid authentication scheme', { status: 401 });
    }

    const decoded = atob(encoded);
    const [username, password] = decoded.split(':');

    if (username !== CREDENTIALS.username || password !== CREDENTIALS.password) {
      return new Response('Invalid credentials', {
        status: 401,
        headers: {
          'WWW-Authenticate': 'Basic realm="Protected Area"'
        }
      });
    }

    return env.ASSETS.fetch(request);
  }
};
EOF
echo "✓ Auth worker added"

# Step 5: Deploy to Cloudflare Pages
echo -e "\n${YELLOW}[5/5] Deploying to Cloudflare Pages...${NC}"

# Check if project exists, create if not
if ! npx wrangler pages project list 2>/dev/null | grep -q "$PROJECT_NAME"; then
    echo "Project '$PROJECT_NAME' not found. Creating..."
    npx wrangler pages project create "$PROJECT_NAME" --production-branch=main
fi

# Deploy
DEPLOY_OUTPUT=$(npx wrangler pages deploy dist --project-name="$PROJECT_NAME" --branch=main --commit-dirty=true 2>&1)
echo "$DEPLOY_OUTPUT"

# Extract deployment URL
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://[^[:space:]]*\.pages\.dev' | head -1)

# Step 6: Purge Cloudflare cache
echo -e "\n${YELLOW}[6/6] Purging Cloudflare cache...${NC}"

# Get zone ID for pages.dev (if custom domain, would need different approach)
# For pages.dev subdomains, we purge via the deployment which already invalidates cache
# But we can add cache-control headers via _headers file

cat > dist/_headers << EOF
/*
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  Expires: 0
EOF

# Redeploy with headers to ensure cache settings
npx wrangler pages deploy dist --project-name="$PROJECT_NAME" --branch=main --commit-dirty=true > /dev/null 2>&1
echo "✓ Cache headers applied"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}URL:${NC} https://${PROJECT_NAME}.pages.dev"
echo -e "${YELLOW}Auth:${NC} dev_env1 / z7kws3mfl5e2y"
echo ""
