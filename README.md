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

# Install dependencies
npm install
```

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
- **Fonts:** Google Fonts (Inter, Manrope)
- **Output:** Static HTML/CSS/JS
- **SEO:** @astrojs/sitemap integration

---

## SEO Features

The site is optimized for search engines with the following features:

| Feature | Implementation |
|---------|----------------|
| **Sitemap** | Auto-generated via `@astrojs/sitemap` at `/sitemap-index.xml` |
| **Robots.txt** | Configured for full crawling at `/robots.txt` |
| **Meta Tags** | Title, description, keywords on all pages |
| **Open Graph** | Facebook/LinkedIn sharing optimization |
| **Twitter Cards** | Twitter sharing with large image cards |
| **Canonical URLs** | Proper canonical link handling |
| **Structured Data** | Organization schema (JSON-LD) |
| **Semantic HTML** | Proper heading hierarchy and landmarks |

### SEO Configuration

The site URL is configured in `astro.config.mjs`:

```javascript
export default defineConfig({
  site: 'https://novintix.com',
  integrations: [sitemap()],
});
```

Each page can override default meta tags via the BaseLayout props:

```astro
<BaseLayout
  title="Page Title"
  description="Page description for search results"
  keywords="custom, keywords, here"
/>
```

---

## Documentation Files

| File | Purpose |
|------|---------|
| [CLAUDE.md](./CLAUDE.md) | AI agent instructions, design system, component docs |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Deployment guides for Cloudflare, Netlify, Vercel, GitHub Pages |
| [MAINTENANCE.md](./MAINTENANCE.md) | How to add pages, components, modify navigation |
| [CONTACT-FORM.md](./CONTACT-FORM.md) | Contact form implementation options for static hosting |

---

## Pages Overview

### Main Pages

| Route | Description |
|-------|-------------|
| `/` | Homepage - Hero, services overview, value proposition |
| `/industries` | Industries served: MedTech (IoMT, remote monitoring, VR/AR, AI diagnostics), Pharmaceutical (digital transformation, AI drug discovery), Healthcare, Biotechnology, Digital Health |
| `/digital-solutions` | Technology offerings: Connected Healthcare, Intelligent Automation, IoMT, Data Analytics & Data Science, AR/VR Services, Telemedicine |
| `/careers` | Life at NovintiX - Company culture, team values, job opportunities |
| `/contact-us` | Contact form and company info (Email: connect@novintix.com, Phone: +(1) 302-306-1115) |

### Service Pages

| Route | Description |
|-------|-------------|
| `/services/product-engineering` | Product Engineering & Discovery - R&D transformation, smart connected products, embedded devices, IoT, Drug Discovery & Development (AI/ML, high-throughput screening, target validation) |
| `/services/supply-chain` | Supply Chain - Value engineering, product obsolescence, technology transfer, asset tracking, supplier optimization, master data management |
| `/services/manufacturing` | Manufacturing - Digital twin, augmented reality, IoT platforms, edge computing, OEE optimization, Industry 4.0, autonomous factories |
| `/services/quality-regulatory-compliance` | Quality & Regulatory Compliance - Quality management systems, regulatory compliance, FDA 21 CFR Part 820, EU MDR/IVDR, ISO 13485, MDSAP |
| `/services/clinical-affairs` | Clinical Affairs - Stakeholder value communication, clinical strategy, HTA bodies, regulatory submissions, IDE, 510(k), PMA, CE marking |

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
