# Contact Form & Admin Panel Development Plan

## Overview

Build a contact form submission system using Cloudflare D1 (SQLite) database with an admin panel to view messages.

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Contact Form   │────▶│  Cloudflare      │────▶│  D1 Database    │
│  (Astro Page)   │     │  Worker/Function │     │  (novintix-db)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                          │
┌─────────────────┐     ┌──────────────────┐              │
│  Admin Panel    │────▶│  Auth Worker     │◀─────────────┘
│  (Astro Page)   │     │  (Session/JWT)   │
└─────────────────┘     └──────────────────┘
```

---

## Database Schema

### Table 1: `contact_messages`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Primary key, auto-increment |
| `first_name` | TEXT | Sender's first name (required) |
| `last_name` | TEXT | Sender's last name (required) |
| `email` | TEXT | Sender's email (required) |
| `phone` | TEXT | Phone number (optional) |
| `company` | TEXT | Company name (optional) |
| `inquiry_type` | TEXT | What can we help with? (required) |
| `message` | TEXT | Message body (required) |
| `metadata` | TEXT | JSON - extra data (location, user agent, IP, referrer, etc.) |
| `status` | TEXT | 'unread', 'read', 'archived' |
| `created_at` | DATETIME | Submission timestamp |
| `read_at` | DATETIME | When marked as read |

#### Form Fields (from UI)

| Field | Required | Maps to |
|-------|----------|---------|
| First Name | ✓ | `first_name` |
| Last Name | ✓ | `last_name` |
| Email Address | ✓ | `email` |
| Company | | `company` |
| Phone Number | | `phone` |
| What can we help with? | ✓ | `inquiry_type` |
| Message | ✓ | `message` |

#### Metadata JSON Structure

```json
{
  "ip": "192.168.1.1",
  "user_agent": "Mozilla/5.0...",
  "referrer": "https://google.com",
  "page_url": "/contact-us",
  "location": {
    "country": "US",
    "region": "CA",
    "city": "San Francisco",
    "timezone": "America/Los_Angeles"
  },
  "utm": {
    "source": "google",
    "medium": "cpc",
    "campaign": "brand"
  },
  "submitted_at_local": "2024-01-15T10:30:00-08:00"
}
```

### Table 2: `admin_users`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Primary key, auto-increment |
| `email` | TEXT | Admin email (unique) |
| `password_hash` | TEXT | bcrypt hashed password |
| `name` | TEXT | Display name |
| `role` | TEXT | 'super_admin', 'admin', 'viewer' |
| `last_login` | DATETIME | Last login timestamp |
| `created_at` | DATETIME | Account creation date |

### Table 3: `sessions` (optional, for session-based auth)

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Session token (UUID) |
| `user_id` | INTEGER | Foreign key to admin_users |
| `expires_at` | DATETIME | Session expiry |
| `created_at` | DATETIME | Session creation |

---

## Development Phases

### Phase 1: Database Setup
- [ ] Create D1 database `novintix-db` in Cloudflare
- [ ] Create SQL migration files
- [ ] Run migrations to create tables
- [ ] Seed initial admin user

### Phase 2: Contact Form API
- [ ] Create Cloudflare Function for form submission (`/api/contact`)
- [ ] Add form validation (email, required fields)
- [ ] Add rate limiting (prevent spam)
- [ ] Add CSRF protection
- [ ] Update contact form page to use API

### Phase 3: Admin Authentication
- [ ] Create login page (`/admin/login`)
- [ ] Implement password hashing (bcrypt)
- [ ] Create session management
- [ ] Add logout functionality
- [ ] Protect admin routes with middleware

### Phase 4: Admin Dashboard
- [ ] Create admin layout component
- [ ] Build messages list page (`/admin/messages`)
- [ ] Build single message view (`/admin/messages/[id]`)
- [ ] Add mark as read/archive functionality
- [ ] Add delete functionality
- [ ] Add search/filter by status

### Phase 5: Admin-Only Version Info in Footer
- [ ] Hide deploy timestamp and commit hash from regular users
- [ ] Show version info only when admin is logged in
- [ ] Add admin session check to Footer component
- [ ] Add subtle admin indicator/badge when logged in

### Phase 6: Testing & Polish
- [ ] Local testing with Wrangler
- [ ] Integration tests
- [ ] Security review
- [ ] Mobile responsive admin UI

---

## File Structure

```
novintix-static/
├── src/
│   ├── pages/
│   │   ├── contact-us.astro          # Updated with API form
│   │   └── admin/
│   │       ├── login.astro           # Admin login page
│   │       ├── index.astro           # Dashboard redirect
│   │       └── messages/
│   │           ├── index.astro       # Messages list
│   │           └── [id].astro        # Single message view
│   ├── components/
│   │   └── admin/
│   │       ├── AdminLayout.astro     # Admin layout wrapper
│   │       ├── MessageCard.astro     # Message list item
│   │       └── Sidebar.astro         # Admin navigation
│   └── middleware/
│       └── auth.ts                   # Auth middleware
├── functions/
│   └── api/
│       ├── contact.ts                # POST /api/contact
│       └── admin/
│           ├── login.ts              # POST /api/admin/login
│           ├── logout.ts             # POST /api/admin/logout
│           ├── verify.ts             # GET /api/admin/verify (session check for footer)
│           ├── messages.ts           # GET /api/admin/messages
│           └── messages/
│               └── [id].ts           # GET/PATCH/DELETE message
├── db/
│   ├── schema.sql                    # Database schema
│   └── seed.sql                      # Initial admin user
└── wrangler.toml                     # D1 binding config
```

---

## Implementation Details

### 1. Create D1 Database

```bash
# Create database
npx wrangler d1 create novintix-db

# Add to wrangler.toml
[[d1_databases]]
binding = "DB"
database_name = "novintix-db"
database_id = "<your-database-id>"
```

### 2. Schema SQL

```sql
-- db/schema.sql

CREATE TABLE IF NOT EXISTS contact_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  company TEXT,
  inquiry_type TEXT NOT NULL,
  message TEXT NOT NULL,
  metadata TEXT,  -- JSON field for extra data (location, user agent, IP, etc.)
  status TEXT DEFAULT 'unread',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  read_at DATETIME
);

CREATE TABLE IF NOT EXISTS admin_users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'admin',
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES admin_users(id)
);

CREATE INDEX idx_messages_status ON contact_messages(status);
CREATE INDEX idx_messages_created ON contact_messages(created_at DESC);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);
```

### 3. Contact Form API

```typescript
// functions/api/contact.ts

export async function onRequestPost(context) {
  const { request, env } = context;

  try {
    const data = await request.json();

    // Validation - required fields
    if (!data.first_name || !data.last_name || !data.email || !data.inquiry_type || !data.message) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
      return new Response(JSON.stringify({ error: 'Invalid email address' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Build metadata object
    const metadata = {
      ip: request.headers.get('CF-Connecting-IP') || request.headers.get('X-Forwarded-For'),
      user_agent: request.headers.get('User-Agent'),
      referrer: request.headers.get('Referer'),
      page_url: data.page_url || null,
      location: {
        country: request.cf?.country || null,
        region: request.cf?.region || null,
        city: request.cf?.city || null,
        timezone: request.cf?.timezone || null,
      },
      utm: data.utm || null,
      submitted_at_local: data.submitted_at_local || null
    };

    // Insert into D1
    await env.DB.prepare(`
      INSERT INTO contact_messages (first_name, last_name, email, phone, company, inquiry_type, message, metadata)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(
      data.first_name,
      data.last_name,
      data.email,
      data.phone || null,
      data.company || null,
      data.inquiry_type,
      data.message,
      JSON.stringify(metadata)
    ).run();

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    console.error('Contact form error:', error);
    return new Response(JSON.stringify({ error: 'Server error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

### 3b. Contact Form Frontend (JavaScript)

```javascript
// Add to contact-us.astro <script>

document.getElementById('contact-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  const form = e.target;
  const submitBtn = form.querySelector('button[type="submit"]');
  const originalText = submitBtn.innerHTML;

  // Disable button and show loading
  submitBtn.disabled = true;
  submitBtn.innerHTML = 'Sending...';

  // Collect form data
  const formData = {
    first_name: form.first_name.value,
    last_name: form.last_name.value,
    email: form.email.value,
    phone: form.phone.value || null,
    company: form.company.value || null,
    inquiry_type: form.inquiry_type.value,
    message: form.message.value,
    page_url: window.location.pathname,
    submitted_at_local: new Date().toISOString(),
    utm: {
      source: new URLSearchParams(window.location.search).get('utm_source'),
      medium: new URLSearchParams(window.location.search).get('utm_medium'),
      campaign: new URLSearchParams(window.location.search).get('utm_campaign')
    }
  };

  try {
    const response = await fetch('/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    });

    const result = await response.json();

    if (response.ok) {
      // Show success message
      form.innerHTML = `
        <div class="success-message">
          <h3>Thank you!</h3>
          <p>Your message has been sent. We'll get back to you shortly.</p>
        </div>
      `;
    } else {
      alert(result.error || 'Something went wrong. Please try again.');
      submitBtn.disabled = false;
      submitBtn.innerHTML = originalText;
    }
  } catch (error) {
    alert('Network error. Please check your connection and try again.');
    submitBtn.disabled = false;
    submitBtn.innerHTML = originalText;
  }
});
```

### 4. Admin Login

```typescript
// functions/api/admin/login.ts

import { compare } from 'bcryptjs';

export async function onRequestPost(context) {
  const { request, env } = context;
  const { email, password } = await request.json();

  // Find user
  const user = await env.DB.prepare(
    'SELECT * FROM admin_users WHERE email = ?'
  ).bind(email).first();

  if (!user || !await compare(password, user.password_hash)) {
    return new Response(JSON.stringify({ error: 'Invalid credentials' }), {
      status: 401
    });
  }

  // Create session
  const sessionId = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

  await env.DB.prepare(`
    INSERT INTO sessions (id, user_id, expires_at)
    VALUES (?, ?, ?)
  `).bind(sessionId, user.id, expiresAt.toISOString()).run();

  // Update last login
  await env.DB.prepare(
    'UPDATE admin_users SET last_login = CURRENT_TIMESTAMP WHERE id = ?'
  ).bind(user.id).run();

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: {
      'Set-Cookie': `session=${sessionId}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=604800`
    }
  });
}
```

### 5. Admin-Only Version Info (Footer)

The deploy timestamp and commit hash in the footer should only be visible to logged-in admins.

#### Current Footer (lines 72-80):
```astro
{
  deployTime && (
    <span class="deploy-info">
      <span class="separator">|</span>
      Deployed: {deployTime}
      {shortHash && <span class="commit-hash">({shortHash})</span>}
    </span>
  )
}
```

#### Implementation Approach:

**Option A: Client-side check (simpler)**
```astro
<!-- Footer.astro -->
---
const currentYear = new Date().getFullYear();
const deployTime = import.meta.env.PUBLIC_DEPLOY_TIMESTAMP;
const commitHash = import.meta.env.PUBLIC_COMMIT_HASH;
const shortHash = commitHash ? commitHash.substring(0, 7) : null;
---

<!-- In the footer-copyright div -->
<div class="footer-copyright">
  &copy; {currentYear} NovintiX. All rights reserved.
  <span class="deploy-info admin-only" style="display: none;">
    <span class="separator">|</span>
    Deployed: {deployTime}
    {shortHash && <span class="commit-hash">({shortHash})</span>}
  </span>
</div>

<script>
  // Check if admin is logged in (has valid session cookie)
  // This calls a lightweight API to verify session
  async function checkAdminStatus() {
    try {
      const res = await fetch('/api/admin/verify', { credentials: 'include' });
      if (res.ok) {
        const adminInfo = document.querySelectorAll('.admin-only');
        adminInfo.forEach(el => el.style.display = 'inline');
      }
    } catch (e) {
      // Not logged in, keep hidden
    }
  }
  checkAdminStatus();
</script>
```

**Option B: Server-side check via middleware (more secure)**
```typescript
// functions/api/admin/verify.ts
export async function onRequestGet(context) {
  const { request, env } = context;

  const cookie = request.headers.get('Cookie');
  const sessionId = cookie?.match(/session=([^;]+)/)?.[1];

  if (!sessionId) {
    return new Response(JSON.stringify({ admin: false }), { status: 401 });
  }

  const session = await env.DB.prepare(
    'SELECT * FROM sessions WHERE id = ? AND expires_at > datetime("now")'
  ).bind(sessionId).first();

  if (!session) {
    return new Response(JSON.stringify({ admin: false }), { status: 401 });
  }

  return new Response(JSON.stringify({ admin: true }), { status: 200 });
}
```

#### Admin Badge (optional)
When logged in, show a subtle indicator:
```html
<span class="admin-only admin-badge" style="display: none;">
  🔐 Admin
</span>
```

```css
.admin-badge {
  font-size: 0.625rem;
  background: rgba(245, 163, 2, 0.15);
  color: #f5a302;
  padding: 0.125rem 0.5rem;
  border-radius: 2px;
  margin-left: 0.5rem;
}
```

---

## Testing Plan

### Local Testing

```bash
# 1. Start local D1 database
npx wrangler d1 execute novintix-db --local --file=db/schema.sql

# 2. Seed admin user (generate hash first)
npx wrangler d1 execute novintix-db --local --file=db/seed.sql

# 3. Run dev server with D1 binding
npx wrangler pages dev dist --d1=DB=novintix-db

# 4. Test contact form submission
curl -X POST http://localhost:8788/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","message":"Hello"}'

# 5. Test admin login
curl -X POST http://localhost:8788/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@novintix.com","password":"your-password"}'
```

### Integration Tests

```bash
# Test contact form
curl -X POST https://novintix-v4.pages.dev/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","subject":"Test","message":"Test message"}'

# Verify in admin panel
# Login at https://novintix-v4.pages.dev/admin/login
# Check messages at https://novintix-v4.pages.dev/admin/messages
```

### Test Cases

| Test | Expected Result |
|------|-----------------|
| Submit valid contact form | 200 OK, message saved |
| Submit without email | 400 Bad Request |
| Submit without name | 400 Bad Request |
| Login with valid credentials | 200 OK, session cookie set |
| Login with invalid password | 401 Unauthorized |
| Access admin without session | Redirect to login |
| View messages as admin | List of messages displayed |
| Mark message as read | Status updated, read_at set |
| Delete message | Message removed from DB |

---

## Security Considerations

1. **Password Storage**: Use bcrypt with cost factor 12
2. **Session Security**: HttpOnly, Secure, SameSite cookies
3. **CSRF Protection**: Include CSRF token in forms
4. **Rate Limiting**: Limit contact form to 5 submissions per IP per hour
5. **Input Sanitization**: Sanitize all user inputs
6. **SQL Injection**: Use parameterized queries (prepared statements)
7. **XSS Prevention**: Escape output in templates

---

## Wrangler Configuration

```toml
# wrangler.toml

name = "novintix-static"
compatibility_date = "2024-01-01"

[[d1_databases]]
binding = "DB"
database_name = "novintix-db"
database_id = "<will-be-generated>"

[vars]
ENVIRONMENT = "production"
```

---

## Commands Reference

```bash
# Create D1 database
npx wrangler d1 create novintix-db

# Run migrations (remote)
npx wrangler d1 execute novintix-db --file=db/schema.sql

# Run migrations (local)
npx wrangler d1 execute novintix-db --local --file=db/schema.sql

# Query database (remote)
npx wrangler d1 execute novintix-db --command="SELECT * FROM contact_messages"

# Query database (local)
npx wrangler d1 execute novintix-db --local --command="SELECT * FROM admin_users"

# Local development with D1
npx wrangler pages dev dist --d1=DB=novintix-db
```

---

## Timeline Estimate

| Phase | Tasks |
|-------|-------|
| Phase 1 | Database setup, schema, migrations |
| Phase 2 | Contact form API, validation, rate limiting |
| Phase 3 | Admin auth, login, sessions |
| Phase 4 | Admin dashboard UI, messages CRUD |
| Phase 5 | Testing, security review, polish |

---

## Next Steps

1. Create the D1 database in Cloudflare
2. Set up wrangler.toml with D1 binding
3. Create and run schema migrations
4. Implement contact form API
5. Build admin authentication
6. Create admin dashboard pages

Ready to start Phase 1?
