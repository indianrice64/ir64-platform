# IR64 Export Platform

**India's most technologically advanced rice export platform.**

Built on Next.js 15, Supabase, Tailwind CSS, and a full GEO layer for AI discoverability.

---

## Stack

| Layer     | Technology                                           |
|-----------|------------------------------------------------------|
| Frontend  | Next.js 15, React 19, TypeScript, Tailwind CSS, ShadCN |
| Animation | Framer Motion, GSAP, Three.js, D3.js                 |
| Backend   | Supabase, PostgreSQL, Node.js                        |
| Business  | Odoo ERP, Metabase, n8n, HubSpot                    |
| AI        | LangChain, Qdrant, Flowise, Dify                    |
| Deploy    | Vercel, Cloudflare                                   |

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/your-org/ir64-export-platform.git
cd ir64-export-platform

# 2. Install
npm install

# 3. Environment
cp .env.example .env.local
# Fill in NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY

# 4. Database
# Go to supabase.com/dashboard → SQL Editor
# Run: supabase/migrations/001_initial.sql

# 5. Dev server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## Project Structure

```
src/
├── app/                  Next.js App Router pages
│   ├── page.tsx          Homepage
│   ├── products/[slug]/  15 product pages (static)
│   ├── export/[country]/ 11 country pages (static)
│   ├── rfq/              RFQ submission page
│   └── api/
│       ├── rfq/          Lead capture API
│       └── geo/          AI retrieval endpoints
├── components/
│   ├── layout/           Header, Footer
│   ├── home/             Hero, Tickers, ProductExplorer, ExportMap…
│   ├── rfq/              RFQForm
│   └── seo/              OrganizationSchema, ProductSchema
├── data/
│   ├── products.ts       All 15 SKUs — single source of truth
│   └── countries.ts      11 export markets
├── lib/
│   ├── supabase/         Client + server clients
│   ├── validations/      Zod schemas
│   └── crm/              Lead scoring
└── services/
    ├── rfq.service.ts    RFQ insert + n8n trigger
    └── whatsapp.service.ts WhatsApp Business API
```

---

## GEO Layer (AI Discoverability)

| URL                         | Purpose                          |
|-----------------------------|----------------------------------|
| `/llms.txt`                 | AI discovery manifest            |
| `/api/geo/company`          | Organization facts (JSON-LD)     |
| `/api/geo/products`         | All 15 SKUs with specs           |
| `/api/geo/faqs`             | 10 canonical Q&A pairs           |
| `/api/geo/countries`        | 11 export markets with rules     |
| `/api/geo/certifications`   | APEDA, IEC, SGS, FSSAI, ISO      |

All GEO endpoints are:
- Publicly accessible (no auth)
- Cached at Cloudflare edge (1hr)
- CORS open (`*`)
- Included in `sitemap.xml`

---

## RFQ Automation Flow

```
Website Form
     ↓
Zod Validation
     ↓
Supabase Insert (rfqs table)
     ↓
Lead Score (0–100) + Grade (A+/A/B/C)
     ↓
WhatsApp Alert → Sales Team
     ↓
n8n Webhook → HubSpot CRM → Email Sequence
```

---

## Deployment

### Vercel (Frontend)
1. Push to GitHub
2. Import to [vercel.com](https://vercel.com)
3. Add environment variables from `.env.example`
4. Connect `ir64.com` domain

### Cloudflare (DNS + CDN)
1. Add `ir64.com` to Cloudflare
2. Set `CNAME` → Vercel deployment URL
3. Enable Cloudflare WAF
4. Cache rules for `/api/geo/*` (1hr TTL)

### Supabase (Database)
1. Create project at [supabase.com](https://supabase.com)
2. Run `supabase/migrations/001_initial.sql` in SQL Editor
3. Enable Email Auth
4. Copy URL + Anon Key to env vars

---

## Phase Roadmap

| Phase | Deliverable                         | Status      |
|-------|-------------------------------------|-------------|
| 1     | Homepage + 15 Product Pages + RFQ   | ✅ Built     |
| 1     | GEO Layer + 11 Country Pages        | ✅ Built     |
| 2     | Buyer Portal + Shipment Tracking    | 🔲 Next     |
| 2     | Odoo ERP Integration                | 🔲 Next     |
| 3     | AI RiceBot (LangChain + Qdrant)     | 🔲 Phase 3  |
| 4     | n8n Full Automation                 | 🔲 Phase 4  |

---

## License

Private — IR64 Global Rice Exporter. All rights reserved.
