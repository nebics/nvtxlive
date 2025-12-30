# Cloudflare Edge Explorer Plan: "NovintiX Edge Lab"

This plan outlines a sub-application to explore Cloudflare's free-tier serverless ecosystem. Build hands-on demos to understand the power of edge computing.

---

## 🎯 Objective

Create an `/edge-lab` section on your site that demonstrates Cloudflare's edge services:
- **Workers** - Serverless functions at the edge
- **D1** - SQLite database at the edge
- **KV** - Key-value storage
- **Workers AI** - LLM inference at the edge
- **R2** - Object storage (S3-compatible)
- **Durable Objects** - Stateful serverless
- **Queues** - Message queues

All running on Cloudflare's edge network, globally distributed, with generous free tiers.

---

## 📊 Free Tier Limits (as of 2025)

| Service | Free Tier |
|---------|-----------|
| **Workers** | 100,000 requests/day |
| **D1** | 5GB storage, 5M rows read/day |
| **KV** | 100,000 reads/day, 1,000 writes/day |
| **Workers AI** | 10,000 neurons/day (~100-200 requests) |
| **R2** | 10GB storage, 1M Class A ops, 10M Class B ops |
| **Queues** | 1M operations/month |
| **Pages** | Unlimited static sites, 500 builds/month |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     NovintiX Edge Lab                           │
│                    /edge-lab page                                │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   Demo 1:     │    │   Demo 2:     │    │   Demo 3:     │
│   D1 Database │    │   Workers AI  │    │   KV Counter  │
│   Lead Form   │    │   Text Gen    │    │   Page Views  │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   Demo 4:     │    │   Demo 5:     │    │   Demo 6:     │
│   R2 Upload   │    │   Edge Geo    │    │   Real-time   │
│   Image Store │    │   Location    │    │   Chat (DO)   │
└───────────────┘    └───────────────┘    └───────────────┘
```

---

## 🛠 Demo Projects

### Demo 1: D1 Database - "Smart Lead Capture"
**Learn:** SQL at the edge, database bindings, CRUD operations

```
Endpoint: POST /api/leads
Function: Insert lead into D1, return confirmation
UI: Form with name, email, company, interest
```

**Schema:**
```sql
CREATE TABLE leads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  company TEXT,
  interest TEXT,
  metadata TEXT,  -- JSON with geo, timestamp
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**What you'll see:**
- Sub-millisecond database writes
- Query results in Cloudflare dashboard
- Global replication

---

### Demo 2: Workers AI - "Bio-Tech Insight Generator"
**Learn:** LLM inference at the edge, streaming responses

```
Endpoint: POST /api/generate
Function: Call Llama 3.1 model, stream response
UI: Prompt input, streaming output display
```

**Available Models (Free):**
- `@cf/meta/llama-3.1-8b-instruct` - General text
- `@cf/meta/llama-3.2-3b-instruct` - Faster, smaller
- `@cf/baai/bge-base-en-v1.5` - Embeddings
- `@cf/openai/whisper` - Speech-to-text
- `@cf/stabilityai/stable-diffusion-xl-base-1.0` - Image generation

**Sample prompts:**
- "Generate a futuristic bio-tech product idea for medical devices"
- "Summarize the benefits of edge computing for healthcare"
- "Write a tagline for a life sciences consulting company"

---

### Demo 3: KV Storage - "Global Page View Counter"
**Learn:** Key-value storage, atomic operations, global consistency

```
Endpoint: GET /api/views
Function: Increment counter in KV, return total
UI: Live counter showing global page views
```

**Code:**
```typescript
export async function onRequest(context) {
  const { env } = context;

  // Atomic increment
  const current = parseInt(await env.VIEWS.get('page_views') || '0');
  const newCount = current + 1;
  await env.VIEWS.put('page_views', newCount.toString());

  return new Response(JSON.stringify({ views: newCount }));
}
```

---

### Demo 4: R2 Storage - "Edge Image Gallery"
**Learn:** S3-compatible storage, presigned URLs, file uploads

```
Endpoint: POST /api/upload - Get presigned URL
Endpoint: GET /api/images - List uploaded images
UI: Drag-drop upload, image gallery
```

**Features:**
- Direct upload to R2 (no server bandwidth)
- Public/private bucket access
- Image transformations (via Images product)

---

### Demo 5: Edge Geo - "Connection Intelligence"
**Learn:** Request metadata, `request.cf` object, personalization

```
Endpoint: GET /api/geo
Function: Return user's location, ISP, device info
UI: Dashboard showing connection details
```

**Available data from `request.cf`:**
```json
{
  "country": "US",
  "region": "California",
  "city": "San Francisco",
  "postalCode": "94107",
  "latitude": "37.7749",
  "longitude": "-122.4194",
  "timezone": "America/Los_Angeles",
  "asn": 13335,
  "asOrganization": "Cloudflare, Inc.",
  "colo": "SJC",
  "httpProtocol": "HTTP/2",
  "tlsVersion": "TLSv1.3",
  "tlsCipher": "AEAD-AES128-GCM-SHA256",
  "botManagement": { "score": 99 }
}
```

---

### Demo 6: Durable Objects - "Real-time Chat Room" (Advanced)
**Learn:** Stateful serverless, WebSockets, coordination

```
Endpoint: WebSocket /api/chat
Function: Durable Object manages chat room state
UI: Live chat with multiple users
```

**Note:** Durable Objects require paid plan ($5/mo) but worth understanding.

---

## 📁 File Structure

```
novintix-static/
├── functions/
│   └── api/
│       ├── leads.ts          # D1 - Save leads
│       ├── generate.ts       # AI - Text generation
│       ├── views.ts          # KV - Page counter
│       ├── upload.ts         # R2 - File upload
│       ├── images.ts         # R2 - List images
│       └── geo.ts            # Edge - Location data
├── src/
│   └── pages/
│       └── edge-lab/
│           ├── index.astro   # Main lab page
│           ├── d1-demo.astro # Database demo
│           ├── ai-demo.astro # AI demo
│           └── kv-demo.astro # KV demo
├── db/
│   └── schema.sql            # D1 schema
└── wrangler.toml             # Bindings config
```

---

## ⚙️ Configuration

### wrangler.toml
```toml
name = "novintix-static"
compatibility_date = "2024-12-01"

# D1 Database binding
[[d1_databases]]
binding = "DB"
database_name = "novintix-db"
database_id = "your-database-id"

# KV Namespace binding
[[kv_namespaces]]
binding = "VIEWS"
id = "your-kv-namespace-id"

# R2 Bucket binding
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "novintix-assets"

# AI binding (no config needed, just use)
[ai]
binding = "AI"

# Environment variables
[vars]
ENVIRONMENT = "production"
```

---

## 🚀 Implementation Phases

### Phase 1: Setup & D1 Demo
- [ ] Create D1 database: `npx wrangler d1 create novintix-db`
- [ ] Create KV namespace: `npx wrangler kv:namespace create VIEWS`
- [ ] Update wrangler.toml with bindings
- [ ] Create schema.sql and run migrations
- [ ] Build leads form and API endpoint
- [ ] Test locally with `npx wrangler pages dev`

### Phase 2: KV & Geo Demos
- [ ] Build page view counter with KV
- [ ] Create geo endpoint exposing `request.cf`
- [ ] Build UI to display connection info

### Phase 3: Workers AI Demo
- [ ] Create AI generation endpoint
- [ ] Implement streaming responses
- [ ] Build interactive prompt UI
- [ ] Test different models

### Phase 4: R2 Storage Demo
- [ ] Create R2 bucket: `npx wrangler r2 bucket create novintix-assets`
- [ ] Build upload endpoint with presigned URLs
- [ ] Create image gallery UI

### Phase 5: Polish & Deploy
- [ ] Create unified Edge Lab landing page
- [ ] Add documentation/explanations for each demo
- [ ] Deploy to production
- [ ] Monitor usage in Cloudflare dashboard

---

## 🧪 Testing Commands

```bash
# Create D1 database
npx wrangler d1 create novintix-db

# Run migrations locally
npx wrangler d1 execute novintix-db --local --file=db/schema.sql

# Run migrations remotely
npx wrangler d1 execute novintix-db --file=db/schema.sql

# Create KV namespace
npx wrangler kv:namespace create VIEWS

# Create R2 bucket
npx wrangler r2 bucket create novintix-assets

# Local development with all bindings
npx wrangler pages dev dist --d1=DB=novintix-db --kv=VIEWS

# Query D1 data
npx wrangler d1 execute novintix-db --command="SELECT * FROM leads"

# Test AI locally
curl -X POST http://localhost:8788/api/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Generate a bio-tech insight"}'
```

---

## 💡 Learning Outcomes

After completing this lab, you'll understand:

1. **Edge Computing** - Code runs in 300+ data centers worldwide
2. **Zero Cold Starts** - Workers start in <1ms vs 100ms+ for Lambda
3. **Global Data** - D1 replicates automatically, KV is eventually consistent
4. **AI at the Edge** - Run LLMs without managing GPUs
5. **Serverless Storage** - R2 for files, D1 for SQL, KV for fast reads
6. **Request Context** - Rich metadata available at the edge

---

## 🔗 Resources

- [Workers Documentation](https://developers.cloudflare.com/workers/)
- [D1 Documentation](https://developers.cloudflare.com/d1/)
- [Workers AI Models](https://developers.cloudflare.com/workers-ai/models/)
- [KV Documentation](https://developers.cloudflare.com/kv/)
- [R2 Documentation](https://developers.cloudflare.com/r2/)
- [Pages Functions](https://developers.cloudflare.com/pages/functions/)

---

## 🎯 Quick Start

Ready to begin? Run these commands:

```bash
# 1. Create the database
npx wrangler d1 create novintix-db

# 2. Create KV namespace
npx wrangler kv:namespace create VIEWS

# 3. Note the IDs and update wrangler.toml

# 4. Create schema
mkdir -p db
cat > db/schema.sql << 'EOF'
CREATE TABLE IF NOT EXISTS leads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  company TEXT,
  interest TEXT,
  metadata TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
EOF

# 5. Run migrations
npx wrangler d1 execute novintix-db --local --file=db/schema.sql

# 6. Start local dev
npx wrangler pages dev dist --d1=DB=novintix-db --kv=VIEWS
```

Ready to start Phase 1?
