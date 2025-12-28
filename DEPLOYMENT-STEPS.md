# Deployment Guide

This guide covers deploying the Novintix static site to Cloudflare Pages with HTTP Basic Authentication.

## Deployment Options

| Method | Use Case |
|--------|----------|
| **Local Script** | Quick manual deployments from any branch |
| **GitHub Actions** | Automated deployments on push to `release/novintix-*` branches |

---

## Local Deployment (Manual)

### Prerequisites

1. Node.js 20+ installed
2. Cloudflare account with Wrangler authenticated:
   ```bash
   npx wrangler login
   ```

### Usage

```bash
./deploy.sh <project-name> [options]
```

### Examples

```bash
# Deploy to novintix-v3.pages.dev
./deploy.sh novintix-v3

# Deploy to a new site (novintix-demo.pages.dev)
./deploy.sh novintix-demo

# Skip build if dist folder is already up to date
./deploy.sh novintix-v3 --skip-build
```

### What the Script Does

1. Cleans previous build (`dist/` folder)
2. Installs fresh dependencies (`npm ci`)
3. Builds Astro site (`npm run build`)
4. Injects HTTP Basic Auth worker
5. Deploys to Cloudflare Pages
6. Applies cache-control headers
7. Creates project if it doesn't exist

---

## Automated Deployment (GitHub Actions)

### How It Works

Push to any branch matching `release/novintix-*` triggers automatic deployment:

| Branch | Cloudflare Project | URL |
|--------|-------------------|-----|
| `release/novintix-v3` | novintix-v3 | https://novintix-v3.pages.dev |
| `release/novintix-v4` | novintix-v4 | https://novintix-v4.pages.dev |
| `release/novintix-demo` | novintix-demo | https://novintix-demo.pages.dev |

### Initial Setup (One-Time)

#### 1. Create Cloudflare API Token

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click **Create Token** → **Custom token**
3. Add permissions:
   - **Account** → Cloudflare Pages → **Edit**
   - **Zone** → Zone → **Read** (optional, for custom domains)
4. Save the token

#### 2. Configure GitHub Secrets

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:

| Secret | Value | Required |
|--------|-------|----------|
| `CLOUDFLARE_ACCOUNT_ID` | `775cda1f8655ad744432a83e98b7d304` | Yes |
| `CLOUDFLARE_API_TOKEN` | Your API token from step 1 | Yes |
| `HTTP_AUTH_USER` | `dev_env1` | Yes |
| `HTTP_AUTH_PASS` | `z7kws3mfl5e2y` | Yes |
| `CLOUDFLARE_ZONE_ID` | Your zone ID (for custom domains only) | No |

#### 3. Create Cloudflare Pages Project

Before first deployment to a new branch, create the project:

```bash
npx wrangler pages project create novintix-v3 --production-branch=main
```

### Triggering Deployment

```bash
# Create and push a release branch
git checkout -b release/novintix-v3
git push origin release/novintix-v3

# Or push changes to existing release branch
git checkout release/novintix-v3
git add .
git commit -m "Update content"
git push
```

### Workflow Features

- **Clean builds**: Removes `node_modules`, `dist`, and `.astro` cache
- **Fresh dependencies**: Reinstalls all packages
- **HTTP Basic Auth**: Injects authentication worker
- **Cache headers**: Sets `no-cache` headers on all files
- **Cache purge**: Attempts to purge Cloudflare cache (requires Zone ID for custom domains)

---

## HTTP Basic Authentication

All deployments are protected with HTTP Basic Auth:

| | |
|---|---|
| **Username** | `dev_env1` |
| **Password** | `z7kws3mfl5e2y` |

When visiting the site, browsers will prompt for credentials.

### Changing Credentials

**Local deployments**: Edit `deploy.sh` and update the `CREDENTIALS` object in the `_worker.js` section.

**GitHub Actions**: Update the `HTTP_AUTH_USER` and `HTTP_AUTH_PASS` secrets in GitHub.

---

## Cache Management

### Preventing Stale Content

Both deployment methods apply these strategies:

1. **`_headers` file**: Sets `Cache-Control: no-cache` on all files
2. **Fresh builds**: Clears local caches before building
3. **Cache purge**: Attempts API-based cache purge (custom domains only)

### Manual Cache Purge

For `pages.dev` domains, Cloudflare automatically invalidates cache on new deployments.

For custom domains, purge via Cloudflare Dashboard:
1. Go to https://dash.cloudflare.com
2. Select your zone → **Caching** → **Configuration**
3. Click **Purge Everything**

---

## Troubleshooting

### "Project not found" Error

Create the project first:
```bash
npx wrangler pages project create <project-name> --production-branch=main
```

### "Invalid project name" Error

Project names must be:
- 1-58 characters
- Lowercase letters, numbers, and dashes only
- Cannot start or end with a dash

### Authentication Not Working

1. Verify `_worker.js` exists in `dist/` after build
2. Check credentials match in secrets/script
3. Clear browser cache and cookies

### Stale Content After Deployment

1. Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
2. Open in incognito/private window
3. Wait 1-2 minutes for edge cache propagation

---

## File Structure

```
novintix-static/
├── .github/
│   └── workflows/
│       └── deploy-cloudflare.yml   # GitHub Actions workflow
├── deploy.sh                        # Local deployment script
├── DEPLOYMENT-STEPS.md             # This file
├── dist/                           # Build output (generated)
│   ├── _worker.js                  # Auth worker (injected)
│   └── _headers                    # Cache headers (injected)
└── src/                            # Source files
```
