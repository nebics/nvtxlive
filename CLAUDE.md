# NovintiX Static Site - Agent Instructions

## Project Overview

This is a static marketing website for **NovintiX**, a life sciences consulting company. Built with Astro framework, it replaces a compromised WordPress site with a clean, static implementation.

**Tech Stack:**
- Framework: Astro 5.x
- Styling: Vanilla CSS with CSS variables
- Build output: Static HTML/CSS/JS
- No JavaScript frameworks (pure Astro components)

---

## Important Rules

### DO NOT:
- Add dependencies on external domains (especially novintix.com - the old compromised site)
- Use inline JavaScript unless absolutely necessary
- Add npm packages without explicit user approval
- Modify the deployment configuration without asking
- Change the color scheme or branding without approval
- Add tracking scripts or analytics without permission

### ALWAYS:
- Use local images from `/public/images/`
- Keep styles scoped to components when possible
- Maintain the existing file structure
- Test with `npm run build` after changes
- Use semantic HTML
- Maintain mobile responsiveness

---

## File Locations

| Purpose | Location |
|---------|----------|
| Pages | `src/pages/*.astro` |
| Service pages | `src/pages/services/*.astro` |
| Components | `src/components/*.astro` |
| Layout | `src/layouts/BaseLayout.astro` |
| Global styles | `src/styles/global.css` |
| Images | `public/images/` |
| Favicons | `public/favicon.png`, `public/favicon-192.png` |

---

## Current Pages

| Route | File | Description |
|-------|------|-------------|
| `/` | `index.astro` | Homepage with hero, about, clients, services |
| `/industries` | `industries.astro` | Industries served (Medical Devices, Pharma, etc.) |
| `/digital-solutions` | `digital-solutions.astro` | Digital transformation services |
| `/careers` | `careers.astro` | Career opportunities |
| `/careers/apply` | `careers/apply.astro` | Job listings (CEIPAL widget) |
| `/contact-us` | `contact-us.astro` | Contact form and info |
| `/services/product-engineering` | `services/product-engineering.astro` | Product Engineering service |
| `/services/supply-chain` | `services/supply-chain.astro` | Supply Chain service |
| `/services/manufacturing` | `services/manufacturing.astro` | Manufacturing service |
| `/services/quality-regulatory-compliance` | `services/quality-regulatory-compliance.astro` | Quality & Regulatory service |
| `/services/clinical-affairs` | `services/clinical-affairs.astro` | Clinical Affairs service |

---

## Components

### Header.astro
- Main navigation with logo
- Dropdown menu for Services
- Mobile hamburger menu
- Props: none (uses `currentPage` from Astro.url)

### Footer.astro
- Company description
- Quick links
- Service links
- Contact information
- Social media placeholders

### BaseLayout.astro
- HTML document structure
- Meta tags and SEO
- Imports Header, Footer, global.css
- Props: `title`, `description`, `currentPage`

### PageHero.astro
- Compact hero banner for inner pages
- Smaller height than homepage hero
- Props: `title`, `description` (optional), `backgroundImage` (optional)

---

## Design System

### Colors (CSS Variables)
```css
--color-primary: #7C7C7D      /* Gray - body text */
--color-secondary: #1E2128    /* Dark - backgrounds, headings */
--color-teal: #003C59         /* Teal - accents, links */
--color-teal-alt: #033C59     /* Teal variant */
--color-orange: #F5A302       /* Orange - CTAs, highlights */
--color-light-bg: #f8f8f9     /* Light gray - section backgrounds */
--color-border: #D3D3DC       /* Border color */
```

### Fonts
- Headings: Rubik (Google Fonts)
- Body: Inter (Google Fonts)

### Common Classes
- `.container` - Max-width wrapper with padding
- `.btn` - Primary button style (orange background)
- `.section-header` - Centered section title with h6 + h2
- `.hero-section` - Full-width hero with overlay
- `.hero-overlay` - Gradient overlay for hero images

---

## Image Assets

All images in `public/images/`:

| File | Used In | Purpose |
|------|---------|---------|
| `Untitled-5-1.jpg` | Homepage | Hero background |
| `Corporate_Differentiator.jpg` | Homepage | About section |
| `B-braun.png` | Homepage | Client logo |
| `dentsply.png` | Homepage | Client logo |
| `janseen.png` | Homepage | Client logo |
| `johnson.png` | Homepage | Client logo |
| `medtronic.png` | Homepage | Client logo |
| `stryker.png` | Homepage | Client logo |
| `careers-bg.jpg` | Careers | Hero background |
| `contact-bg.jpg` | Contact Us | Hero background |
| `contact-hero.jpg` | (backup) | Alternative contact hero |
| `digital-solutions-bg.jpg` | Digital Solutions | Hero background |
| `industry-bg.jpg` | Industries | Hero background |
| `pattern.png` | Footer | Circuit pattern background |
| `favicon.png` | All pages | Browser favicon |
| `favicon-192.png` | All pages | PWA icon |

---

## Common Patterns

### Hero Section
```astro
<section class="hero-section" style="background-image: url('/images/hero.jpg')">
  <div class="hero-overlay"></div>
  <div class="hero-content">
    <h1>Title</h1>
    <p>Description</p>
  </div>
</section>
```

### Section Header
```astro
<div class="section-header">
  <h6>Subtitle</h6>
  <h2>Main Title</h2>
</div>
```

### Service Card Grid
```astro
<div class="services-grid">
  <div class="service-card">
    <div class="service-icon"><!-- SVG --></div>
    <h5>Service Name</h5>
    <p>Description</p>
    <a href="/services/..." class="service-link">Learn More</a>
  </div>
</div>
```

### CTA Section
```astro
<section class="cta-section">
  <div class="container">
    <div class="cta-content">
      <h2>Call to Action</h2>
      <p>Supporting text</p>
      <a href="/contact-us" class="btn">Contact Us</a>
    </div>
  </div>
</section>
```

---

## Build & Deploy

```bash
npm run dev      # Development server at localhost:4321
npm run build    # Production build to dist/
npm run preview  # Preview production build
```

**Deployment:** Configured for Cloudflare Pages (or any static host)
- Build command: `npm run build`
- Output directory: `dist`

---

## Known Considerations

1. **Contact Form:** Currently static (`action="#"`). Needs backend integration for production (Formspree, Netlify Forms, or custom API).

2. **No CMS:** Content is in `.astro` files. For frequent updates, consider adding a headless CMS later.

3. **Google Fonts:** External dependency on fonts.googleapis.com. Could be self-hosted if needed for full independence.

4. **Mobile Menu:** JavaScript in Header.astro handles mobile toggle. Keep it minimal.

---

## Security Notes

This site was created to replace a **compromised WordPress installation**. The previous site had:
- Malware redirecting Google visitors to malicious domains
- Cloaked redirects based on HTTP Referer header

This static site:
- Has NO server-side code
- Has NO database
- Has NO external dependencies on novintix.com
- Cannot be compromised in the same way

**Keep it static and simple.**
