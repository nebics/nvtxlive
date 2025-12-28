# Contact Form Implementation Guide

## Overview

This document explains how to implement contact form submission handling for a static site. Since static sites have no server-side processing, form submissions must be handled by external services.

---

## Option 1: Formspree (Recommended for Simplicity)

**Best for:** Quick setup, no backend needed, free tier available (50 submissions/month)

### Setup

1. Go to [Formspree](https://formspree.io/) and create a free account
2. Create a new form and get your form endpoint (e.g., `https://formspree.io/f/xyzabc123`)
3. Update the contact form:

```html
<form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
  <input type="text" name="firstName" required />
  <input type="text" name="lastName" required />
  <input type="email" name="email" required />
  <input type="text" name="company" />
  <input type="text" name="subject" required />
  <textarea name="message" required></textarea>
  <button type="submit">Send Message</button>
</form>
```

### Where Data is Stored
- Formspree dashboard at formspree.io
- Email notifications to your inbox
- Export as CSV available

### Pricing
- Free: 50 submissions/month
- Gold ($10/month): 1,000 submissions/month
- Platinum ($40/month): 5,000 submissions/month

---

## Option 2: Netlify Forms

**Best for:** If hosting on Netlify, zero configuration needed

### Setup

1. Deploy to Netlify
2. Add `data-netlify="true"` to your form:

```html
<form name="contact" method="POST" data-netlify="true">
  <input type="hidden" name="form-name" value="contact" />
  <input type="text" name="firstName" required />
  <input type="text" name="lastName" required />
  <input type="email" name="email" required />
  <input type="text" name="company" />
  <input type="text" name="subject" required />
  <textarea name="message" required></textarea>
  <button type="submit">Send Message</button>
</form>
```

### Where Data is Stored
- Netlify dashboard: Site > Forms
- Email notifications configurable
- Webhook integrations available

### Spam Protection
Add honeypot field:
```html
<form name="contact" method="POST" data-netlify="true" netlify-honeypot="bot-field">
  <p class="hidden">
    <label>Don't fill this out: <input name="bot-field" /></label>
  </p>
  <!-- rest of form -->
</form>
```

### Pricing
- Free: 100 submissions/month
- Pro ($19/month): 1,000 submissions/month

---

## Option 3: Cloudflare Workers (For Cloudflare Pages)

**Best for:** Hosting on Cloudflare Pages, want full control

### Setup

1. Create a Worker in Cloudflare dashboard
2. Add the following code:

```javascript
// workers/contact-form.js
export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    const formData = await request.formData();
    const data = {
      firstName: formData.get('firstName'),
      lastName: formData.get('lastName'),
      email: formData.get('email'),
      company: formData.get('company'),
      subject: formData.get('subject'),
      message: formData.get('message'),
      timestamp: new Date().toISOString()
    };

    // Option A: Store in KV
    await env.CONTACT_SUBMISSIONS.put(
      `submission_${Date.now()}`,
      JSON.stringify(data)
    );

    // Option B: Send email via Mailgun/SendGrid
    // await sendEmail(data);

    // Option C: Send to webhook (Slack, Discord, etc.)
    // await fetch('https://hooks.slack.com/...', {
    //   method: 'POST',
    //   body: JSON.stringify({ text: `New contact: ${data.email}` })
    // });

    return Response.redirect('https://novintix.com/contact-us?success=true', 302);
  }
};
```

3. Bind KV namespace in wrangler.toml:
```toml
kv_namespaces = [
  { binding = "CONTACT_SUBMISSIONS", id = "your-kv-id" }
]
```

4. Update form action:
```html
<form action="https://contact.novintix.com" method="POST">
```

### Where Data is Stored
- Cloudflare KV (key-value store)
- Access via Workers dashboard or API

### Pricing
- Workers free tier: 100,000 requests/day
- KV free tier: 1GB storage, 100,000 reads/day

---

## Option 4: Google Sheets (Free Storage)

**Best for:** Non-technical users who want spreadsheet access

### Setup using Google Apps Script

1. Create a Google Sheet
2. Go to Extensions > Apps Script
3. Add this code:

```javascript
function doPost(e) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  const data = JSON.parse(e.postData.contents);

  sheet.appendRow([
    new Date(),
    data.firstName,
    data.lastName,
    data.email,
    data.company,
    data.subject,
    data.message
  ]);

  return ContentService.createTextOutput(
    JSON.stringify({ result: 'success' })
  ).setMimeType(ContentService.MimeType.JSON);
}
```

4. Deploy as web app (Execute as: Me, Who has access: Anyone)
5. Get the web app URL

6. Add JavaScript to form:
```html
<form id="contact-form">
  <!-- form fields -->
  <button type="submit">Send Message</button>
</form>

<script>
document.getElementById('contact-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const formData = new FormData(e.target);
  const data = Object.fromEntries(formData);

  await fetch('YOUR_GOOGLE_SCRIPT_URL', {
    method: 'POST',
    body: JSON.stringify(data)
  });

  alert('Thank you! Your message has been sent.');
  e.target.reset();
});
</script>
```

### Where Data is Stored
- Google Sheets (shareable, exportable)
- Free unlimited storage

---

## Option 5: Airtable

**Best for:** Team collaboration, structured data management

### Setup

1. Create an Airtable base with fields matching your form
2. Get API key from Airtable account
3. Use form submission with JavaScript:

```javascript
const AIRTABLE_API_KEY = 'your_api_key';
const AIRTABLE_BASE_ID = 'your_base_id';
const AIRTABLE_TABLE = 'Contacts';

async function submitToAirtable(data) {
  await fetch(`https://api.airtable.com/v0/${AIRTABLE_BASE_ID}/${AIRTABLE_TABLE}`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${AIRTABLE_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      fields: {
        'First Name': data.firstName,
        'Last Name': data.lastName,
        'Email': data.email,
        'Company': data.company,
        'Subject': data.subject,
        'Message': data.message
      }
    })
  });
}
```

**Note:** Exposing API key in client-side code is not secure. Use a serverless function (Cloudflare Worker, Netlify Function) as proxy.

### Pricing
- Free: 1,000 records/base
- Plus ($10/user/month): 5,000 records/base

---

## Recommended Implementation for NovintiX

### If using Cloudflare Pages (Primary Recommendation):

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Contact    │────>│  Cloudflare      │────>│  Cloudflare │
│  Form       │     │  Worker          │     │  KV Store   │
└─────────────┘     └──────────────────┘     └─────────────┘
                            │
                            v
                    ┌──────────────────┐
                    │  Email via       │
                    │  Resend/Mailgun  │
                    └──────────────────┘
```

### Quick Start (Formspree)

For immediate functionality, update `src/pages/contact-us.astro`:

```astro
<form class="contact-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
```

Replace `YOUR_FORM_ID` with your Formspree form ID.

---

## Email Notifications

All options can send email notifications:

| Service | Email Provider |
|---------|---------------|
| Formspree | Built-in |
| Netlify Forms | Built-in |
| Cloudflare Worker | Resend, Mailgun, SendGrid |
| Google Sheets | Google Apps Script (MailApp) |
| Airtable | Automations (built-in) |

---

## Spam Protection

### Honeypot Field (Recommended)
Add hidden field that bots fill but humans don't:

```html
<div style="display:none">
  <input type="text" name="_gotcha" />
</div>
```

Server-side: reject if `_gotcha` has value.

### reCAPTCHA
Add Google reCAPTCHA for high-traffic sites:

```html
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<div class="g-recaptcha" data-sitekey="YOUR_SITE_KEY"></div>
```

### Cloudflare Turnstile (Recommended for Cloudflare)
Free, privacy-friendly alternative to reCAPTCHA:

```html
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
<div class="cf-turnstile" data-sitekey="YOUR_SITE_KEY"></div>
```

---

## Success/Error Handling

Add success page or inline feedback:

```astro
---
const success = Astro.url.searchParams.get('success');
---

{success && (
  <div class="success-message">
    Thank you! Your message has been sent successfully.
  </div>
)}

<form action="https://formspree.io/f/YOUR_ID" method="POST">
  <input type="hidden" name="_next" value="https://novintix.com/contact-us?success=true" />
  <!-- form fields -->
</form>
```

---

## Data Access & Export

| Service | Dashboard | API Access | Export |
|---------|-----------|------------|--------|
| Formspree | Yes | Yes (paid) | CSV |
| Netlify Forms | Yes | Yes | CSV |
| Cloudflare KV | Yes | Yes | JSON |
| Google Sheets | Yes | Yes | CSV, XLSX |
| Airtable | Yes | Yes | CSV, JSON |

---

## Summary: Choosing the Right Option

| Criteria | Best Option |
|----------|-------------|
| Quickest setup | Formspree |
| Hosting on Netlify | Netlify Forms |
| Hosting on Cloudflare | Cloudflare Workers + KV |
| Need spreadsheet access | Google Sheets |
| Team collaboration | Airtable |
| Full control & privacy | Self-hosted (Cloudflare Workers) |
| Zero cost | Google Sheets or Netlify (100/month) |
