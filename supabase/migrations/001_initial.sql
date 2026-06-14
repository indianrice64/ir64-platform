-- IR64 Export Platform — Initial Database Schema
-- Run in Supabase SQL Editor

-- ────────────────────────────────────────────
-- USERS & AUTH
-- ────────────────────────────────────────────

CREATE TABLE users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       TEXT UNIQUE NOT NULL,
    full_name   TEXT,
    role        TEXT NOT NULL DEFAULT 'buyer'
                  CHECK (role IN ('super_admin','admin','sales','operations','finance','buyer','agent')),
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- COMPANIES & BUYERS (CRM)
-- ────────────────────────────────────────────

CREATE TABLE companies (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL,
    website      TEXT,
    country      TEXT,
    city         TEXT,
    address      TEXT,
    tax_number   TEXT,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE buyers (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id   UUID REFERENCES companies(id),
    contact_name TEXT NOT NULL,
    email        TEXT,
    whatsapp     TEXT,
    designation  TEXT,
    buyer_type   TEXT DEFAULT 'importer'
                   CHECK (buyer_type IN ('importer','distributor','wholesaler','government','retail_chain','food_processor','feed_manufacturer')),
    lead_score   INTEGER DEFAULT 0 CHECK (lead_score BETWEEN 0 AND 100),
    lead_grade   TEXT DEFAULT 'C' CHECK (lead_grade IN ('A+','A','B','C')),
    status       TEXT DEFAULT 'new'
                   CHECK (status IN ('new','qualified','quoted','negotiation','won','lost')),
    notes        TEXT,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- PRODUCTS
-- ────────────────────────────────────────────

CREATE TABLE product_categories (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL
);

CREATE TABLE products (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id  UUID REFERENCES product_categories(id),
    sku          TEXT UNIQUE NOT NULL,
    product_name TEXT NOT NULL,
    slug         TEXT UNIQUE NOT NULL,
    description  TEXT,
    hs_code      TEXT,
    moq_mt       NUMERIC DEFAULT 25,
    active       BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE product_specifications (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id     UUID REFERENCES products(id),
    moisture       TEXT,
    broken_pct     TEXT,
    grain_length   TEXT,
    foreign_matter TEXT,
    damaged_grains TEXT,
    chalky_grains  TEXT,
    crop_year      TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE packaging_options (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id       UUID REFERENCES products(id),
    weight_kg        NUMERIC,
    packaging_code   TEXT,
    bags_per_20ft    INTEGER,
    bags_per_40ft    INTEGER,
    bags_per_40hc    INTEGER
);

-- ────────────────────────────────────────────
-- RFQ & QUOTATIONS
-- ────────────────────────────────────────────

CREATE TABLE rfqs (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id         UUID REFERENCES buyers(id),
    company_name     TEXT NOT NULL,
    contact_name     TEXT NOT NULL,
    email            TEXT NOT NULL,
    whatsapp         TEXT,
    country          TEXT,
    product_id       TEXT,
    product_name     TEXT,
    quantity_mt      NUMERIC,
    packaging        TEXT,
    incoterm         TEXT DEFAULT 'FOB' CHECK (incoterm IN ('FOB','CFR','CIF','EXW')),
    destination_port TEXT,
    target_price     TEXT,
    message          TEXT,
    lead_score       INTEGER DEFAULT 0,
    lead_grade       TEXT DEFAULT 'C',
    status           TEXT DEFAULT 'submitted'
                       CHECK (status IN ('submitted','reviewing','quoted','converted','closed')),
    source           TEXT DEFAULT 'website',
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE quotations (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_id            UUID REFERENCES rfqs(id),
    quotation_number  TEXT UNIQUE,
    buyer_id          UUID REFERENCES buyers(id),
    currency          TEXT DEFAULT 'USD',
    incoterm          TEXT,
    fob_price_mt      NUMERIC,
    freight_mt        NUMERIC,
    total_amount      NUMERIC,
    validity_date     DATE,
    payment_terms     TEXT,
    notes             TEXT,
    status            TEXT DEFAULT 'draft'
                        CHECK (status IN ('draft','sent','accepted','rejected','expired')),
    created_by        UUID REFERENCES users(id),
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- ORDERS & SHIPMENTS
-- ────────────────────────────────────────────

CREATE TABLE orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number    TEXT UNIQUE,
    quotation_id    UUID REFERENCES quotations(id),
    buyer_id        UUID REFERENCES buyers(id),
    product_id      UUID REFERENCES products(id),
    quantity_mt     NUMERIC,
    packaging       TEXT,
    incoterm        TEXT,
    destination_port TEXT,
    total_amount    NUMERIC,
    currency        TEXT DEFAULT 'USD',
    status          TEXT DEFAULT 'confirmed'
                      CHECK (status IN ('confirmed','production','packed','shipped','delivered','cancelled')),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE shipments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id         UUID REFERENCES orders(id),
    vessel_name      TEXT,
    voyage_number    TEXT,
    etd              DATE,
    eta              DATE,
    pol              TEXT DEFAULT 'Chennai',
    pod              TEXT,
    shipping_line    TEXT,
    bl_number        TEXT UNIQUE,
    status           TEXT DEFAULT 'scheduled'
                       CHECK (status IN ('scheduled','loaded','departed','in_transit','arrived','delivered')),
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE containers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id      UUID REFERENCES shipments(id),
    container_number TEXT,
    seal_number      TEXT,
    container_type   TEXT CHECK (container_type IN ('20FT','40FT','40HC'))
);

CREATE TABLE shipment_events (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id  UUID REFERENCES shipments(id),
    status       TEXT NOT NULL,
    location     TEXT,
    notes        TEXT,
    event_time   TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- DOCUMENTS
-- ────────────────────────────────────────────

CREATE TABLE documents (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id   UUID REFERENCES shipments(id),
    order_id      UUID REFERENCES orders(id),
    document_type TEXT NOT NULL
                    CHECK (document_type IN (
                      'proforma_invoice','commercial_invoice','duplicate_invoice',
                      'packing_list','bill_of_lading','certificate_of_origin',
                      'sgs_certificate','fumigation_certificate','phytosanitary',
                      'insurance','lr_copy','shipping_instructions'
                    )),
    file_url      TEXT,
    file_name     TEXT,
    uploaded_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- SAMPLE ORDERS
-- ────────────────────────────────────────────

CREATE TABLE sample_orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id        UUID REFERENCES buyers(id),
    product_id      UUID REFERENCES products(id),
    product_name    TEXT,
    contact_name    TEXT NOT NULL,
    email           TEXT NOT NULL,
    whatsapp        TEXT,
    shipping_address TEXT,
    amount_usd      NUMERIC DEFAULT 250,
    payment_method  TEXT,
    payment_status  TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','refunded')),
    tracking_number TEXT,
    courier         TEXT,
    status          TEXT DEFAULT 'pending'
                      CHECK (status IN ('pending','paid','warehouse_notified','dispatched','delivered')),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- PAYMENTS
-- ────────────────────────────────────────────

CREATE TABLE payments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id         UUID REFERENCES orders(id),
    amount           NUMERIC,
    currency         TEXT DEFAULT 'USD',
    payment_method   TEXT CHECK (payment_method IN ('lc','tt','advance','stripe','razorpay','wise')),
    payment_status   TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending','received','cleared','overdue')),
    reference_number TEXT,
    notes            TEXT,
    paid_at          TIMESTAMPTZ,
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- CRM ACTIVITIES
-- ────────────────────────────────────────────

CREATE TABLE crm_activities (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id      UUID REFERENCES buyers(id),
    rfq_id        UUID REFERENCES rfqs(id),
    activity_type TEXT CHECK (activity_type IN ('call','email','whatsapp','meeting','note','follow_up','quotation_sent')),
    notes         TEXT,
    created_by    UUID REFERENCES users(id),
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- AI CHAT SESSIONS
-- ────────────────────────────────────────────

CREATE TABLE ai_chat_sessions (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id   UUID REFERENCES buyers(id),
    session_id TEXT UNIQUE NOT NULL,
    source     TEXT DEFAULT 'website',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE ai_messages (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id TEXT NOT NULL,
    role       TEXT CHECK (role IN ('user','assistant')),
    content    TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────
-- INDEXES
-- ────────────────────────────────────────────

CREATE INDEX idx_rfqs_created_at    ON rfqs(created_at DESC);
CREATE INDEX idx_rfqs_country       ON rfqs(country);
CREATE INDEX idx_rfqs_lead_grade    ON rfqs(lead_grade);
CREATE INDEX idx_rfqs_status        ON rfqs(status);
CREATE INDEX idx_buyers_email       ON buyers(email);
CREATE INDEX idx_buyers_status      ON buyers(status);
CREATE INDEX idx_products_slug      ON products(slug);
CREATE INDEX idx_shipments_status   ON shipments(status);
CREATE INDEX idx_ai_messages_session ON ai_messages(session_id);

-- ────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ────────────────────────────────────────────

ALTER TABLE buyers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE rfqs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotations      ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders          ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipments       ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents       ENABLE ROW LEVEL SECURITY;
ALTER TABLE sample_orders   ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments        ENABLE ROW LEVEL SECURITY;

-- Staff can see all records
CREATE POLICY staff_all_rfqs ON rfqs FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('super_admin','admin','sales','operations','finance'))
);

-- Buyers see only their own RFQs (matched by email)
CREATE POLICY buyer_own_rfqs ON rfqs FOR SELECT USING (
    email = (SELECT email FROM users WHERE id = auth.uid())
);

CREATE POLICY buyer_own_orders ON orders FOR SELECT USING (
    buyer_id IN (SELECT id FROM buyers WHERE email = (SELECT email FROM users WHERE id = auth.uid()))
);

CREATE POLICY buyer_own_shipments ON shipments FOR SELECT USING (
    order_id IN (
        SELECT o.id FROM orders o
        JOIN buyers b ON b.id = o.buyer_id
        WHERE b.email = (SELECT email FROM users WHERE id = auth.uid())
    )
);

-- Products are publicly readable
CREATE POLICY products_public_read ON products FOR SELECT USING (TRUE);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- ────────────────────────────────────────────
-- SEED: Product Categories
-- ────────────────────────────────────────────

INSERT INTO product_categories (name, slug) VALUES
    ('IR64 Rice',       'ir64-rice'),
    ('Broken Rice',     'broken-rice'),
    ('Long Grain Rice', 'long-grain-rice'),
    ('Sona Masoori',    'sona-masoori'),
    ('Pooni Rice',      'pooni-rice'),
    ('Idly Rice',       'idly-rice');

-- ────────────────────────────────────────────
-- SEED: Products (all 15 SKUs)
-- ────────────────────────────────────────────

WITH cats AS (SELECT id, slug FROM product_categories)
INSERT INTO products (category_id, sku, product_name, slug, hs_code, moq_mt) VALUES
    ((SELECT id FROM cats WHERE slug = 'ir64-rice'),       'IR64-RAW-05',  'IR64 Raw Rice 5% Broken',              'ir64-raw-rice-5-broken',              '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'ir64-rice'),       'IR64-RAW-25',  'IR64 Raw Rice 25% Broken',             'ir64-raw-rice-25-broken',             '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'ir64-rice'),       'IR64-PB-05',   'IR64 Parboiled Rice 5% Broken',        'ir64-parboiled-rice-5-broken',        '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'ir64-rice'),       'IR64-DPB-05',  'IR64 Double Parboiled Rice 5% Broken', 'ir64-double-parboiled-rice-5-broken', '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'broken-rice'),     'IR64-D2',      'IR64 Broken Rice D2',                  'ir64-broken-rice-d2',                 '1006.40', 25),
    ((SELECT id FROM cats WHERE slug = 'broken-rice'),     'BRK-100',      '100% Broken Rice',                     '100-broken-rice',                     '1006.40', 25),
    ((SELECT id FROM cats WHERE slug = 'long-grain-rice'), 'LG-WHITE',     'Long Grain White Rice',                'long-grain-white-rice',               '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'long-grain-rice'), 'LG-SELLA',     'Long Grain Sella Rice',                'long-grain-sella-rice',               '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'long-grain-rice'), 'LG-GSELLA',    'Long Grain Golden Sella Rice',         'long-grain-golden-sella-rice',        '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'sona-masoori'),    'SM-STEAM',     'Sona Masoori Steam Rice',              'sona-masoori-steam-rice',             '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'sona-masoori'),    'SM-PB',        'Sona Masoori Parboiled Rice',          'sona-masoori-parboiled-rice',         '1006.30', 25),
    ((SELECT id FROM cats WHERE slug = 'pooni-rice'),      'PN-RAW',       'Pooni Raw Rice',                       'pooni-raw-rice',                      '1006.30', 10),
    ((SELECT id FROM cats WHERE slug = 'pooni-rice'),      'PN-STEAM',     'Pooni Steam Rice',                     'pooni-steam-rice',                    '1006.30', 10),
    ((SELECT id FROM cats WHERE slug = 'pooni-rice'),      'PN-PB',        'Pooni Parboiled Rice',                 'pooni-parboiled-rice',                '1006.30', 10),
    ((SELECT id FROM cats WHERE slug = 'idly-rice'),       'IDLY-001',     'Idly Rice',                            'idly-rice',                           '1006.30', 10);
