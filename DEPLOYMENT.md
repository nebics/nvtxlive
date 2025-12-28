# NovintiX Static Site - Deployment Guide

## Overview

This is an Astro-based static site for NovintiX consulting. The build output is pure HTML/CSS/JS in the `dist/` folder, making it compatible with any static hosting provider.

## Build Commands

```bash
# Install dependencies
npm install

# Development server (http://localhost:4321)
npm run dev

# Production build (outputs to dist/)
npm run build

# Preview production build locally
npm run preview
```

---

## Deployment Options

### Option 1: Cloudflare Pages (Recommended)

**Why:** Free SSL, global CDN, DDoS protection, bot mitigation, unlimited bandwidth.

**Setup:**

1. Push code to GitHub/GitLab
2. Go to [Cloudflare Pages](https://pages.cloudflare.com/)
3. Connect your repository
4. Configure build settings:
   - Build command: `npm run build`
   - Build output directory: `dist`
   - Node version: 18 (set in Environment Variables: `NODE_VERSION=18`)
5. Deploy

**Custom Domain:**
1. Add domain in Cloudflare Pages settings
2. Update DNS to point to Cloudflare (if not already using Cloudflare DNS)
3. SSL certificate is automatic

**Bot Protection:**
- Enable "Bot Fight Mode" in Cloudflare dashboard (Security > Bots)
- Configure WAF rules if needed (free tier includes basic rules)

---

### Option 2: Netlify

**Why:** Free tier with 100GB bandwidth/month, automatic SSL, form handling.

**Setup:**

1. Push code to GitHub/GitLab/Bitbucket
2. Go to [Netlify](https://netlify.com/)
3. "Add new site" > "Import an existing project"
4. Configure:
   - Build command: `npm run build`
   - Publish directory: `dist`
5. Deploy

**Custom Domain:**
1. Site settings > Domain management > Add custom domain
2. Update DNS (CNAME to your-site.netlify.app)
3. SSL is automatic via Let's Encrypt

**Optional netlify.toml:**
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
```

---

### Option 3: Vercel

**Why:** Free tier, excellent performance, automatic SSL.

**Setup:**

1. Install Vercel CLI: `npm i -g vercel`
2. Run: `vercel`
3. Follow prompts to link to your Vercel account
4. Configure:
   - Framework: Astro
   - Build command: `npm run build`
   - Output directory: `dist`

**Or via Dashboard:**
1. Go to [Vercel](https://vercel.com/)
2. Import Git repository
3. Vercel auto-detects Astro settings
4. Deploy

---

### Option 4: GitHub Pages

**Why:** Free, simple, integrates with GitHub repos.

**Setup:**

1. Add to `astro.config.mjs`:
```js
export default defineConfig({
  site: 'https://yourusername.github.io',
  base: '/novintix-static', // if not using custom domain
});
```

2. Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: dist

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v4
        id: deployment
```

3. Enable GitHub Pages in repo settings (Settings > Pages > Source: GitHub Actions)

**Custom Domain:**
1. Add `CNAME` file to `public/` folder with your domain
2. Configure DNS to point to GitHub Pages

---

### Option 5: Manual Upload (cPanel/FTP)

**For traditional shared hosting:**

1. Build locally: `npm run build`
2. Upload contents of `dist/` folder to `public_html/`
3. Configure SSL via hosting panel (usually Let's Encrypt)

---

## Cloudflare as Proxy (For Any Hosting)

If using non-Cloudflare hosting but want Cloudflare's protection:

1. Sign up at [Cloudflare](https://cloudflare.com/)
2. Add your domain
3. Update nameservers at your registrar to Cloudflare's
4. In DNS settings, ensure the record pointing to your host is "Proxied" (orange cloud)
5. Enable in Security settings:
   - Bot Fight Mode
   - Security Level: Medium or High
   - Challenge Passage: 30 minutes

---

## Recommended Setup for NovintiX

**Primary: Cloudflare Pages**
- Zero cost
- Built-in DDoS protection
- Global CDN (fast worldwide)
- Automatic HTTPS
- Bot mitigation included
- No bandwidth limits

**Steps:**
1. Create GitHub repo for the project
2. Push code to GitHub
3. Connect to Cloudflare Pages
4. Configure custom domain (novintix.com)
5. Enable Bot Fight Mode
6. Done!

---

## Environment Checklist

Before deploying:
- [ ] All images use local paths (`/images/...`)
- [ ] No external dependencies on novintix.com
- [ ] Build succeeds locally (`npm run build`)
- [ ] Preview looks correct (`npm run preview`)
- [ ] Favicon and meta tags are set
- [ ] Contact form has proper action (or is static)

---

## DNS Configuration

When pointing novintix.com to new hosting:

| Type  | Name | Value                          | TTL  |
|-------|------|--------------------------------|------|
| A     | @    | (provided by host)             | Auto |
| CNAME | www  | novintix-static.pages.dev      | Auto |

Or if using Cloudflare Pages with full Cloudflare DNS, it's automatic.

---

## Rollback

All platforms support instant rollback:
- **Cloudflare Pages:** Deployments tab > select previous > "Rollback"
- **Netlify:** Deploys tab > click previous > "Publish deploy"
- **Vercel:** Deployments > ... menu > "Promote to Production"
