#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Cloudflare D1 & KV Setup Script     ${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if wrangler is logged in
echo -e "\n${YELLOW}[1/6] Checking Wrangler authentication...${NC}"
if ! npx wrangler whoami > /dev/null 2>&1; then
    echo -e "${RED}Not logged in. Running wrangler login...${NC}"
    npx wrangler login
fi
echo "✓ Authenticated with Cloudflare"

# Create D1 Database
echo -e "\n${YELLOW}[2/6] Creating D1 Database...${NC}"
D1_OUTPUT=$(npx wrangler d1 create novintix-db 2>&1 || true)

if echo "$D1_OUTPUT" | grep -q "already exists"; then
    echo "✓ Database 'novintix-db' already exists"
    # Get existing database ID from list (first column is UUID)
    D1_ID=$(npx wrangler d1 list 2>&1 | grep "novintix-db" | awk '{print $2}')
else
    echo "$D1_OUTPUT"
    # Extract database ID from JSON output - look for the UUID pattern
    D1_ID=$(echo "$D1_OUTPUT" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1)
    echo "✓ Created database with ID: $D1_ID"
fi

if [ -z "$D1_ID" ]; then
    echo -e "${RED}ERROR: Could not extract D1 database ID${NC}"
    echo "Please check manually: npx wrangler d1 list"
    exit 1
fi

# Create KV Namespace
echo -e "\n${YELLOW}[3/6] Creating KV Namespace...${NC}"
KV_OUTPUT=$(npx wrangler kv namespace create VIEWS 2>&1 || true)

if echo "$KV_OUTPUT" | grep -q "already exists"; then
    echo "✓ KV namespace 'VIEWS' already exists"
    # Get existing namespace ID from list
    KV_ID=$(npx wrangler kv namespace list 2>&1 | grep -oE '"id": "[^"]+"' | grep -oE '[0-9a-f]{32}' | head -1)
else
    echo "$KV_OUTPUT"
    # Extract KV ID from output - look for 32-char hex ID
    KV_ID=$(echo "$KV_OUTPUT" | grep -oE '[0-9a-f]{32}' | head -1)
    echo "✓ Created KV namespace with ID: $KV_ID"
fi

if [ -z "$KV_ID" ]; then
    echo -e "${RED}ERROR: Could not extract KV namespace ID${NC}"
    echo "Please check manually: npx wrangler kv namespace list"
    exit 1
fi

# Create wrangler.toml if it doesn't exist or update it
echo -e "\n${YELLOW}[4/6] Creating/Updating wrangler.toml...${NC}"

cat > wrangler.toml << EOF
name = "novintix-static"
compatibility_date = "2024-12-01"
pages_build_output_dir = "dist"

# D1 Database binding
[[d1_databases]]
binding = "DB"
database_name = "novintix-db"
database_id = "${D1_ID}"

# KV Namespace binding (for page views, sessions cache, etc.)
[[kv_namespaces]]
binding = "VIEWS"
id = "${KV_ID}"

# AI binding (Workers AI)
[ai]
binding = "AI"

# Environment variables
[vars]
ENVIRONMENT = "production"
EOF

echo "✓ wrangler.toml created/updated"
echo "  D1 ID: $D1_ID"
echo "  KV ID: $KV_ID"

# Create db directory and schema (only if schema.sql doesn't exist)
echo -e "\n${YELLOW}[5/6] Checking database schema...${NC}"
mkdir -p db

if [ ! -f db/schema.sql ]; then
    echo "Creating schema.sql..."
    cat > db/schema.sql << 'EOF'
-- Contact Messages Table
CREATE TABLE IF NOT EXISTS contact_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  company TEXT,
  inquiry_type TEXT NOT NULL,
  message TEXT NOT NULL,
  metadata TEXT,
  status TEXT DEFAULT 'unread',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  read_at DATETIME
);

-- Admin Users Table
CREATE TABLE IF NOT EXISTS admin_users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'admin',
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sessions Table
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES admin_users(id)
);

-- Edge Lab Leads Table (for Cloudflare Explorer demos)
CREATE TABLE IF NOT EXISTS leads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  company TEXT,
  interest TEXT,
  metadata TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_messages_status ON contact_messages(status);
CREATE INDEX IF NOT EXISTS idx_messages_created ON contact_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
EOF
    echo "✓ Schema file created at db/schema.sql"
else
    echo "✓ Schema file already exists at db/schema.sql"
fi

# Run migrations
echo -e "\n${YELLOW}[6/6] Running database migrations...${NC}"

# Run locally first
echo "Running local migrations..."
npx wrangler d1 execute novintix-db --local --file=db/schema.sql 2>&1 || echo "  (local migration skipped or failed - this is OK for remote-only setup)"

# Run remote migrations
echo "Running remote migrations..."
npx wrangler d1 execute novintix-db --remote --file=db/schema.sql 2>&1

echo "✓ Migrations complete"

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Cloudflare Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Resources Created:${NC}"
echo "  • D1 Database: novintix-db ($D1_ID)"
echo "  • KV Namespace: VIEWS ($KV_ID)"
echo "  • Config: wrangler.toml"
echo "  • Schema: db/schema.sql"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Create seed data:  npx wrangler d1 execute novintix-db --remote --file=db/seed.sql"
echo "  2. Test locally:      npx wrangler pages dev dist"
echo "  3. Deploy:            ./deploy.sh novintix-v4"
echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "  • Query messages:     npx wrangler d1 execute novintix-db --remote --command=\"SELECT * FROM contact_messages\""
echo "  • Query admins:       npx wrangler d1 execute novintix-db --remote --command=\"SELECT id,email,name,role FROM admin_users\""
echo "  • Local dev server:   npx wrangler pages dev dist"
echo ""
