# NovintiX Static Site

A static marketing website for NovintiX, a life sciences consulting company. Built with Astro framework as a secure replacement for a previously compromised WordPress site.

## Quick Start

### Prerequisites

- Node.js 18 or higher
- npm

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd novintix-static

# Run Smart Start Script (Handles Auth, Dependencies, Database, and Server)
./setup.sh
```

### Manual Deployment

To deploy manually to Cloudflare Pages (Production):
```bash
./deploy.sh <project-name> --public

# Example:
./deploy.sh v2-novintix --public
```
This script handles building, authenticating, and deploying using the current branch to the primary environment.

### Development

```bash
# Start development server
npm run dev
```

Open http://localhost:4321 in your browser. The dev server supports hot reload.

### Production Build

```bash
# Build for production
npm run build
```

Output is generated in the `dist/` folder.

### Test Production Build Locally

```bash
# Preview production build
npm run preview
```

This serves the `dist/` folder locally to verify the production build works correctly.

---

## Project Structure

```
novintix-static/
├── public/                    # Static assets (copied as-is)
│   ├── images/               # All images
│   ├── favicon.png           # Browser favicon
│   └── favicon-192.png       # PWA icon
├── src/
│   ├── components/           # Reusable components
│   │   ├── Header.astro      # Site navigation
│   │   ├── Footer.astro      # Site footer
│   │   └── PageHero.astro    # Compact hero for inner pages
│   ├── layouts/
│   │   └── BaseLayout.astro  # HTML document wrapper
│   ├── pages/                # Each file = one route
│   │   ├── index.astro       # Homepage (/)
│   │   ├── industries.astro
│   │   ├── digital-solutions.astro
│   │   ├── careers.astro
│   │   ├── careers/
│   │   │   └── apply.astro   # Job listings
│   │   ├── contact-us.astro
│   │   └── services/         # Service pages
│   └── styles/
│       └── global.css        # Global styles & CSS variables
├── dist/                     # Production build output
├── astro.config.mjs          # Astro configuration
└── package.json
```

---

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Start dev server at localhost:4321 |
| `npm run build` | Build production site to `./dist/` |
| `npm run preview` | Preview production build locally |
| `npm run astro check` | Check for Astro errors |

---

## Tech Stack

- **Framework:** Astro 5.x
- **Styling:** Vanilla CSS with CSS variables
- **Fonts:** Google Fonts (Rubik, Inter)
- **Output:** Static HTML/CSS/JS

---

## Documentation Files

| File | Purpose |
|------|---------|
| [CLAUDE.md](./CLAUDE.md) | AI agent instructions, design system, component docs |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Deployment guides for Cloudflare, Netlify, Vercel, GitHub Pages |
| [MAINTENANCE.md](./MAINTENANCE.md) | How to add pages, components, modify navigation |
| [CONTACT-FORM.md](./CONTACT-FORM.md) | Contact form implementation options for static hosting |

---

## Pages

| Route | Description |
|-------|-------------|
| `/` | Homepage |
| `/industries` | Industries served |
| `/digital-solutions` | Digital transformation services |
| `/careers` | Career opportunities |
| `/careers/apply` | Job listings (CEIPAL widget) |
| `/contact-us` | Contact form |
| `/services/*` | Individual service pages |

---

## Deployment

The site can be deployed to any static hosting provider.

**Recommended:** Cloudflare Pages (free, global CDN, DDoS protection)

```bash
# Build command
npm run build

# Output directory
dist
```

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

---

## Security Notes

This static site was created to replace a compromised WordPress installation. It has:

- No server-side code
- No database
- No external dependencies on the old domain
- Pure static HTML/CSS/JS output

---

## License

Private - NovintiX Consulting
