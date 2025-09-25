
-- 0) Connect to DB
\c saas_churn

-- 1) Raw staging tables (flexible text types; we cast/clean in views)
CREATE TABLE IF NOT EXISTS customers (
  customer_id        text,
  name               text,
  region             text,
  state              text,
  organization_type  text
);

CREATE TABLE IF NOT EXISTS subscriptions (
  subscription_id     text,
  customer_id         text,
  status              text,
  payment_type        text,
  plan_type           text,
  mrr                 text,
  billing_frequency   text,
  auto_renew          text,
  start_date          text,
  end_date            text,
  acv                 text
);

CREATE TABLE IF NOT EXISTS invoices (
  invoice_id       text,
  subscription_id  text,
  invoice_date     text,
  due_date         text,
  payment_date     text,
  amount           text
);

-- 2) Load CSVs into staging
\copy customers     FROM './customers.csv'     CSV HEADER;
\copy subscriptions FROM './subscriptions.csv' CSV HEADER;
\copy invoices      FROM './invoices.csv'      CSV HEADER;

BEGIN;

-- 3) Parameter block (point-in-time churn)
WITH params AS (SELECT DATE '2025-03-31' AS as_of_date)
SELECT * FROM params LIMIT 1;  -- anchor CTE (no-op)

-- 4) Reference maps (normalize categories)
CREATE SCHEMA IF NOT EXISTS ref;

CREATE TABLE IF NOT EXISTS ref.payment_type_map (
  raw   text PRIMARY KEY,
  clean text NOT NULL
);
INSERT INTO ref.payment_type_map (raw, clean) VALUES
  ('ACH','ACH'), ('AC H','ACH'), ('A.C.H.','ACH'),
  ('Card','Card'), ('Crd','Card'), ('Credit Card','Card'),
  ('Check','Check'), ('Cheque','Check'),
  ('Wire','Wire'), ('Wrie','Wire')
ON CONFLICT (raw) DO NOTHING;

CREATE TABLE IF NOT EXISTS ref.plan_type_map (
  raw   text PRIMARY KEY,
  clean text NOT NULL
);
INSERT INTO ref.plan_type_map (raw, clean) VALUES
  ('Enterprise','Enterprise'), ('Entrprise','Enterprise'),
  ('Standard','Standard'),     ('Stndard','Standard'),
  ('Basic','Basic'),           ('Baisc','Basic')
ON CONFLICT (raw) DO NOTHING;

-- 5) Clean entity views
DROP VIEW IF EXISTS vw_customers_clean CASCADE;
CREATE OR REPLACE VIEW vw_customers_clean AS
SELECT
  btrim(replace(c.customer_id, chr(160), ''))                  AS customer_id,
  initcap(btrim(replace(c.name,        chr(160), '')))         AS name,
  COALESCE(NULLIF(btrim(replace(c.region, chr(160), '')), ''), 'Unknown') AS region,
  COALESCE(NULLIF(btrim(replace(c.state,  chr(160), '')), ''), 'Unknown') AS state,
  c.organization_type
FROM customers c;

DROP VIEW IF EXISTS vw_subscriptions_clean CASCADE;
CREATE OR REPLACE VIEW vw_subscriptions_clean AS
WITH base AS (
  SELECT
    btrim(replace(s.subscription_id, chr(160), '')) AS subscription_id,
    btrim(replace(s.customer_id,    chr(160), ''))  AS customer_id,
    initcap(btrim(replace(s.status, chr(160), ''))) AS status,
    initcap(btrim(replace(s.payment_type, chr(160), ''))) AS payment_type_raw,
    initcap(btrim(replace(s.plan_type,    chr(160), ''))) AS plan_type_raw,
    CAST(
      regexp_replace(
        regexp_replace(btrim(replace(s.mrr, chr(160), '')), '[$]', '', 'g'),
        ',', '', 'g'
      ) AS numeric
    ) AS mrr,
    s.billing_frequency,
    s.auto_renew,
    (s.start_date)::date AS start_date,
    (s.end_date)::date   AS end_date,
    s.acv
  FROM subscriptions s
)
SELECT
  b.subscription_id,
  b.customer_id,
  b.status,
  COALESCE(pt.clean, b.payment_type_raw) AS payment_type,
  COALESCE(pl.clean, b.plan_type_raw)    AS plan_type,
  b.mrr,
  (b.mrr * 12)::numeric                  AS arr,
  b.billing_frequency,
  b.auto_renew,
  b.start_date,
  b.end_date,
  b.acv
FROM base b
LEFT JOIN ref.payment_type_map pt ON pt.raw = b.payment_type_raw
LEFT JOIN ref.plan_type_map    pl ON pl.raw = b.plan_type_raw;

DROP VIEW IF EXISTS vw_invoices_clean CASCADE;
CREATE OR REPLACE VIEW vw_invoices_clean AS
SELECT
  btrim(replace(i.invoice_id,      chr(160),'') ) AS invoice_id,
  btrim(replace(i.subscription_id, chr(160),'') ) AS subscription_id,
  (i.invoice_date)::date AS invoice_date,
  (i.due_date)::date     AS due_date,
  (i.payment_date)::date AS payment_date,
  CAST(i.amount AS numeric) AS amount
FROM invoices i;

-- 6) Enriched join view (joins + churn + delay)
DROP VIEW IF EXISTS vw_billing_enriched CASCADE;
CREATE OR REPLACE VIEW vw_billing_enriched AS
WITH params AS (SELECT DATE '2025-03-31' AS as_of_date)
SELECT
  c.customer_id,
  c.name,
  c.region,
  c.state,
  s.subscription_id,
  s.status             AS sub_status,
  s.payment_type,
  s.plan_type,
  s.billing_frequency,
  s.auto_renew,
  s.mrr,
  s.arr,
  s.acv,
  s.start_date,
  s.end_date,
  i.invoice_id,
  i.invoice_date,
  i.due_date,
  i.payment_date,
  i.amount,
  CASE
    WHEN lower(s.status) = 'churned' THEN 1
    WHEN s.end_date IS NOT NULL AND s.end_date < (SELECT as_of_date FROM params) THEN 1
    ELSE 0
  END AS is_churned,
  CASE
    WHEN i.payment_date IS NULL OR i.due_date IS NULL THEN NULL
    ELSE (i.payment_date - i.due_date)
  END::int AS days_late,
  CASE
    WHEN i.payment_date IS NULL OR i.due_date IS NULL THEN NULL
    WHEN (i.payment_date - i.due_date) <= 5   THEN '0–5'
    WHEN (i.payment_date - i.due_date) <= 15  THEN '6–15'
    WHEN (i.payment_date - i.due_date) <= 30  THEN '16–30'
    ELSE '30+'
  END AS delay_bucket
FROM vw_invoices_clean i
JOIN vw_subscriptions_clean s ON s.subscription_id = i.subscription_id
JOIN vw_customers_clean    c ON c.customer_id    = s.customer_id;

-- 7) Advanced analysis views (window functions)
DROP VIEW IF EXISTS vw_top_enterprise_churn CASCADE;
CREATE OR REPLACE VIEW vw_top_enterprise_churn AS
WITH churned AS (
  SELECT
    b.customer_id, b.name, b.region, b.state,
    b.subscription_id, b.plan_type, b.payment_type,
    b.arr, b.is_churned
  FROM vw_billing_enriched b
  WHERE b.is_churned = 1 AND lower(b.plan_type) LIKE 'enterprise%'
)
SELECT
  customer_id, name, region, state,
  SUM(arr) AS arr_lost,
  RANK() OVER (ORDER BY SUM(arr) DESC) AS arr_lost_rank
FROM churned
GROUP BY customer_id, name, region, state;

DROP VIEW IF EXISTS vw_payment_method_rollup CASCADE;
CREATE OR REPLACE VIEW vw_payment_method_rollup AS
WITH churned AS (
  SELECT payment_type, arr
  FROM vw_billing_enriched
  WHERE is_churned = 1
)
SELECT
  payment_type,
  SUM(arr) AS arr_lost,
  SUM(SUM(arr)) OVER () AS arr_lost_total,
  ROUND(100.0 * SUM(arr) / NULLIF(SUM(SUM(arr)) OVER (),0), 2) AS pct_of_total
FROM churned
GROUP BY payment_type
ORDER BY arr_lost DESC;

-- 8) Optional DQ checks (uncomment to run)
-- -- Orphan subscriptions (no customer)
-- SELECT s.subscription_id
-- FROM vw_subscriptions_clean s
-- WHERE NOT EXISTS (SELECT 1 FROM vw_customers_clean c WHERE c.customer_id = s.customer_id);
-- -- Orphan invoices (no subscription)
-- SELECT i.invoice_id
-- FROM vw_invoices_clean i
-- WHERE NOT EXISTS (SELECT 1 FROM vw_subscriptions_clean s WHERE s.subscription_id = i.subscription_id);

COMMIT;

-- 9) (Optional) Export a single joined CSV for Tableau
\copy (SELECT * FROM vw_billing_enriched) TO './billing_enriched.csv' CSV HEADER;
