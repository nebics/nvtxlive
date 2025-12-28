# NovintiX Static Site - Maintenance Guide

## Project Structure

```
novintix-static/
├── public/                 # Static assets (copied as-is to dist/)
│   ├── images/            # All images
│   ├── favicon.png        # Browser favicon
│   └── favicon-192.png    # PWA icon
├── src/
│   ├── components/        # Reusable Astro components
│   │   ├── Header.astro   # Site navigation
│   │   └── Footer.astro   # Site footer
│   ├── layouts/
│   │   └── BaseLayout.astro  # HTML wrapper (head, body structure)
│   ├── pages/             # Each file = one route
│   │   ├── index.astro    # Homepage (/)
│   │   ├── industries.astro
│   │   ├── digital-solutions.astro
│   │   ├── careers.astro
│   │   ├── contact-us.astro
│   │   └── services/      # Service pages (/services/*)
│   │       ├── product-engineering.astro
│   │       ├── supply-chain.astro
│   │       ├── manufacturing.astro
│   │       ├── quality-regulatory-compliance.astro
│   │       └── clinical-affairs.astro
│   └── styles/
│       └── global.css     # Global styles and CSS variables
├── astro.config.mjs       # Astro configuration
├── package.json           # Dependencies and scripts
└── tsconfig.json          # TypeScript config
```

---

## Common Tasks

### Adding a New Page

1. Create a new `.astro` file in `src/pages/`:

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
---

<BaseLayout title="Page Title" currentPage="/page-url">
  <section class="hero-section" style="background-image: url('/images/your-hero.jpg')">
    <div class="hero-overlay"></div>
    <div class="hero-content">
      <h1>Page Title</h1>
      <p>Page description</p>
    </div>
  </section>

  <section class="content-section">
    <div class="container">
      <!-- Your content here -->
    </div>
  </section>
</BaseLayout>

<style>
  /* Page-specific styles */
</style>
```

2. Add navigation link in `src/components/Header.astro`:

```astro
// In the navItems array:
{ href: '/page-url', label: 'Page Name' },
```

3. Build and test: `npm run dev`

---

### Adding a New Service Page

1. Create file in `src/pages/services/your-service.astro`
2. Add to Header.astro dropdown:

```astro
// In the Services children array:
{ href: '/services/your-service', label: 'Your Service Name' },
```

---

### Adding a New Component

1. Create in `src/components/YourComponent.astro`:

```astro
---
// Props interface
interface Props {
  title: string;
  description?: string;
}

const { title, description = 'Default description' } = Astro.props;
---

<div class="your-component">
  <h3>{title}</h3>
  <p>{description}</p>
</div>

<style>
  .your-component {
    /* Component styles - scoped by default */
  }
</style>
```

2. Use in any page:

```astro
---
import YourComponent from '../components/YourComponent.astro';
---

<YourComponent title="Hello" description="World" />
```

---

### Adding Images

1. Place image in `public/images/`
2. Reference in pages: `src="/images/filename.jpg"`

For hero backgrounds:
```html
<section style="background-image: url('/images/your-image.jpg')">
```

For inline images:
```html
<img src="/images/your-image.jpg" alt="Description" />
```

---

### Modifying Global Styles

Edit `src/styles/global.css`:

**CSS Variables (colors, fonts):**
```css
:root {
  --color-primary: #7C7C7D;      /* Gray text */
  --color-secondary: #1E2128;    /* Dark background */
  --color-teal: #003C59;         /* Teal accent */
  --color-orange: #F5A302;       /* Orange accent */
  --font-heading: 'Rubik', sans-serif;
  --font-body: 'Inter', sans-serif;
}
```

---

### Updating Header Navigation

Edit `src/components/Header.astro`:

```astro
const navItems = [
  { href: '/', label: 'Home' },
  { href: '/industries', label: 'Industries' },
  {
    label: 'Services',
    href: '#',
    children: [
      { href: '/services/product-engineering', label: 'Product Engineering & Discovery' },
      // Add more services here
    ]
  },
  { href: '/digital-solutions', label: 'Digital Solutions' },
  { href: '/careers', label: 'Careers' },
  { href: '/contact-us', label: 'Contact Us' },
];
```

---

### Updating Footer

Edit `src/components/Footer.astro`:
- Company info in left column
- Quick links in middle columns
- Contact info in right column

---

### Changing Meta Tags / SEO

Edit the page's frontmatter:

```astro
<BaseLayout
  title="Page Title"
  description="SEO description for this page"
  currentPage="/page-url"
>
```

The `BaseLayout.astro` handles the `<title>` and meta description.

---

## Development Commands

```bash
# Start dev server with hot reload
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Check for issues
npm run astro check
```

---

## Page-Specific Styles

Each `.astro` file can have its own `<style>` block at the bottom. These styles are **scoped by default** (only apply to that component/page).

For global styles within a component, use `:global()`:

```css
<style>
  /* Scoped to this page */
  .my-class { color: red; }

  /* Global (affects all pages) */
  :global(.some-global-class) { color: blue; }
</style>
```

---

## Troubleshooting

**Build fails:**
- Check for syntax errors in `.astro` files
- Ensure all imports exist
- Run `npm run astro check`

**Images not loading:**
- Verify file exists in `public/images/`
- Check path starts with `/images/` (not `./images/`)
- Check case sensitivity (Linux/deployment is case-sensitive)

**Styles not applying:**
- Styles in `<style>` are scoped by default
- Use `:global()` or put in `global.css` for global styles

**Changes not showing:**
- Hard refresh browser (Ctrl+Shift+R / Cmd+Shift+R)
- Clear browser cache
- Restart dev server

---

## Deployment Workflow

1. Make changes locally
2. Test with `npm run dev`
3. Build with `npm run build`
4. Preview with `npm run preview`
5. Commit and push to Git
6. Auto-deploys via Cloudflare Pages/Netlify/Vercel

---

## Contact Form Note

The contact form in `contact-us.astro` currently has `action="#"`. For production:

**Option 1: Netlify Forms**
```html
<form name="contact" method="POST" data-netlify="true">
```

**Option 2: Formspree**
```html
<form action="https://formspree.io/f/yourformid" method="POST">
```

**Option 3: Custom API**
```html
<form action="https://your-api.com/contact" method="POST">
```
