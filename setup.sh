#!/bin/bash

# NovintiX Smart Setup & Start Script
# Usage: ./setup.sh

set -e # Exit immediately if a command exits with a non-zero status

echo "====================================="
echo "NovintiX Development Environment"
echo "====================================="

# Helper Function for Checks
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ Error: '$1' is not installed or not in your PATH."
        echo "   Please install $1 to proceed."
        exit 1
    fi
    echo "✅ Found $1: $(command -v $1)"
}

# 1. Pre-flight Checks (Strict)
echo ""
echo "[1/5] Running Pre-flight Checks..."

# Enforce Git
check_command "git"

# Enforce Node & NPM (JSRNPM)
check_command "node"
check_command "npm"

echo "All required tools are present."

# 2. Environment Check & Auth
echo ""
echo "[2/5] Checking Cloudflare Authentication..."

if ! npx wrangler whoami > /dev/null 2>&1; then
    echo "⚠️  Not logged in. Starting first-time setup..."
    echo "Please log in to Cloudflare in the browser window that opens."
    npx wrangler login
else
    echo "✅  Cloudflare authenticated. Skipping login."
fi

# 3. Install Dependencies
echo ""
echo "[3/5] Verifying Dependencies..."
npm install

# 4. Build Project
echo ""
echo "[4/5] Building Project (Production Mode)..."
npm run build

# 5. Local Database Start & Init
echo ""
echo "[5/5] Checking Local Database..."

# Check if admin_users table exists
if ! npx wrangler d1 execute novintix-db --local --command "SELECT 1 FROM admin_users LIMIT 1" > /dev/null 2>&1; then
    echo "⚠️  Local database is empty. Initializing..."
    echo "   - Creating Tables (db/schema.sql)..."
    npx wrangler d1 execute novintix-db --local --file=./db/schema.sql > /dev/null
    
    echo "   - Seeding Admin User (db/seed.sql)..."
    npx wrangler d1 execute novintix-db --local --file=./db/seed.sql > /dev/null
    echo "✅ Database initialized with default admin."
else
    echo "✅ Local database already initialized."
fi

# 6. Start Server
echo ""
echo "[6/6] Starting Local Preview Server..."
echo "-------------------------------------"
echo "Local: http://localhost:8788"
echo "Mode:  Production Build (dist/)"
echo "DB:    Local D1 Binding (novintix-db)"
echo "-------------------------------------"

npx wrangler pages dev dist --d1 binding=DB --kv binding=VIEWS