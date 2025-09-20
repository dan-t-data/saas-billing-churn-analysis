/* ============================================================================
   Final tables created (used in Tableau):
     - customers
     - subscriptions
     - invoices

   Summary of steps performed:
     1) Customers: trim IDs/names, standardize casing, remove blanks.
     2) Subscriptions: normalize plan/billing info, parse booleans/dates,
        clean payment type, derive churn flag.
     3) Invoices: recompute days late, create delay buckets & codes,
        clean payment outcomes, add boolean flags.
     4) Export clean tables to CSV for Tableau.
     5) Quick data checks to validate results.
   ============================================================================ */

-- =========================
-- 1) CUSTOMERS
-- =========================
-- Clean org/customer details: trim text, standardize casing, remove blanks.
DROP TABLE IF EXISTS customers;
CREATE TABLE customers AS
SELECT DISTINCT
  TRIM(customer_id)                      AS customer_id,
  NULLIF(INITCAP(TRIM(org_name)),'')     AS org_name,
  NULLIF(UPPER(TRIM(state)),'')          AS state,
  NULLIF(INITCAP(TRIM(region)),'')       AS region,
  NULLIF(INITCAP(TRIM(org_type)),'')     AS org_type
FROM raw_customers
WHERE TRIM(customer_id) <> '';

CREATE INDEX IF NOT EXISTS idx_customers_customer_id ON customers(customer_id);


-- =========================
-- 2) SUBSCRIPTIONS
-- =========================
-- Standardize plan info, parse booleans/dates, normalize payment type.
-- Add churn flag based on status and end_date.
DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions AS
SELECT DISTINCT
  TRIM(subscription_id)                        AS subscription_id,
  TRIM(customer_id)                            AS customer_id,
  INITCAP(TRIM(plan_type))                     AS plan_type,

  CASE
    WHEN LOWER(TRIM(billing_frequency)) IN ('monthly','month','m') THEN 'monthly'
    WHEN LOWER(TRIM(billing_frequency)) IN ('annual','yearly','yr','y') THEN 'annual'
    WHEN LOWER(TRIM(billing_frequency)) IN ('quarterly','qtr','q') THEN 'quarterly'
    ELSE LOWER(TRIM(billing_frequency))
  END                                          AS billing_frequency,

  CASE
    WHEN LOWER(TRIM(auto_renew)) IN ('true','t','yes','y','1') THEN TRUE
    WHEN LOWER(TRIM(auto_renew)) IN ('false','f','no','n','0') THEN FALSE
    ELSE FALSE
  END                                          AS auto_renew,

  COALESCE(TRY_CAST(start_date AS DATE),
           TO_DATE(NULLIF(TRIM(start_date),''),'MM/DD/YYYY')) AS start_date,

  COALESCE(TRY_CAST(end_date AS DATE),
           TO_DATE(NULLIF(TRIM(end_date),''),'MM/DD/YYYY'))   AS end_date,

  INITCAP(TRIM(status))                        AS status,

  CASE
    WHEN LOWER(TRIM(payment_type)) LIKE 'credit%' THEN 'Credit Card'
    WHEN LOWER(TRIM(payment_type)) =  'ach'       THEN 'ACH'
    WHEN LOWER(TRIM(payment_type)) =  'wire'      THEN 'Wire'
    WHEN LOWER(TRIM(payment_type)) =  'check'     THEN 'Check'
    ELSE INITCAP(TRIM(payment_type))
  END                                          AS payment_type,

  NULLIF(REPLACE(REPLACE(TRIM(mrr), '$',''), ',',''), '')::NUMERIC AS mrr,
  NULLIF(REPLACE(REPLACE(TRIM(acv), '$',''), ',',''), '')::NUMERIC AS acv,

  CASE
    WHEN LOWER(TRIM(is_enterprise)) IN ('true','t','yes','y','1') THEN TRUE
    WHEN LOWER(TRIM(is_enterprise)) IN ('false','f','no','n','0') THEN FALSE
    ELSE FALSE
  END                                          AS is_enterprise,

  CASE
    WHEN LOWER(TRIM(status)) IN ('canceled','cancelled','terminated') THEN TRUE
    WHEN COALESCE(TRY_CAST(end_date AS DATE),
                  TO_DATE(NULLIF(TRIM(end_date),''),'MM/DD/YYYY')) < CURRENT_DATE THEN TRUE
    ELSE FALSE
  END                                          AS is_churned
FROM raw_subscriptions
WHERE TRIM(subscription_id) <> '';

CREATE INDEX IF NOT EXISTS idx_subscriptions_subscription_id ON subscriptions(subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_customer_id     ON subscriptions(customer_id);


-- =========================
-- 3) INVOICES
-- =========================
-- Recompute days_late from due_date/payment_date.
-- Bucket invoices into delay ranges, assign numeric codes.
-- Clean payment outcome and create boolean flags for analysis.
DROP TABLE IF EXISTS invoices;
CREATE TABLE invoices AS
WITH base AS (
  SELECT DISTINCT
    TRIM(invoice_id)                         AS invoice_id,
    TRIM(customer_id)                        AS customer_id,
    TRIM(subscription_id)                    AS subscription_id,

    COALESCE(TRY_CAST(invoice_date AS DATE),
             TO_DATE(NULLIF(TRIM(invoice_date),''),'MM/DD/YYYY')) AS invoice_date,
    COALESCE(TRY_CAST(due_date AS DATE),
             TO_DATE(NULLIF(TRIM(due_date),''),'MM/DD/YYYY'))     AS due_date,
    COALESCE(TRY_CAST(payment_date AS DATE),
             TO_DATE(NULLIF(TRIM(payment_date),''),'MM/DD/YYYY')) AS payment_date,

    INITCAP(TRIM(status))                    AS status,
    NULLIF(REPLACE(REPLACE(TRIM(amount), '$',''), ',',''), '')::NUMERIC AS amount,

    NULLIF(TRIM(days_late),'')::INT          AS days_late_src,
    INITCAP(TRIM(delay_bucket))              AS delay_bucket_src,
    NULLIF(TRIM(payment_attempts),'')::INT   AS payment_attempts_src,
    NULLIF(TRIM(delay_bucket_code),'')::INT  AS delay_bucket_code_src,
    INITCAP(TRIM(payment_outcome))           AS payment_outcome_src
  FROM raw_invoices
  WHERE TRIM(invoice_id) <> ''
),
calc AS (
  -- Calculate lateness directly from due_date vs. payment_date
  SELECT
    b.*,
    GREATEST(
      0,
      COALESCE((b.payment_date - b.due_date), (CURRENT_DATE - b.due_date))
    )::INT AS days_late_calc
  FROM base b
)
SELECT
  c.invoice_id                                AS invoice_id,
  c.customer_id                               AS customer_id,
  c.subscription_id                           AS subscription_id,
  c.invoice_date                              AS invoice_date,
  c.due_date                                  AS due_date,
  c.payment_date                              AS payment_date,
  c.status                                    AS status,
  c.amount                                    AS amount,

  c.days_late_calc                            AS days_late,

  CASE
    WHEN c.days_late_calc BETWEEN 0 AND 5   THEN '0–5 days'
    WHEN c.days_late_calc BETWEEN 6 AND 15  THEN '6–15 days'
    WHEN c.days_late_calc BETWEEN 16 AND 30 THEN '16–30 days'
    WHEN c.days_late_calc > 30              THEN '30+ days'
    ELSE NULL
  END                                         AS delay_bucket,

  COALESCE(c.payment_attempts_src, 0)         AS payment_attempts,

  CASE
    WHEN c.days_late_calc BETWEEN 0 AND 5   THEN 1
    WHEN c.days_late_calc BETWEEN 6 AND 15  THEN 2
    WHEN c.days_late_calc BETWEEN 16 AND 30 THEN 3
    WHEN c.days_late_calc > 30              THEN 4
    ELSE NULL
  END                                         AS delay_bucket_code,

  COALESCE(
    c.payment_outcome_src,
    CASE
      WHEN c.payment_date IS NULL AND CURRENT_DATE > c.due_date THEN 'Unpaid'
      WHEN c.days_late_calc = 0 THEN 'Paid On Time'
      ELSE 'Paid Late'
    END
  )                                           AS payment_outcome,

  (CASE WHEN c.payment_date IS NULL AND CURRENT_DATE > c.due_date THEN TRUE ELSE FALSE END) AS is_failed,
  (CASE WHEN c.payment_date IS NOT NULL AND c.days_late_calc > 0 THEN TRUE ELSE FALSE END)  AS is_late,
  (CASE WHEN c.payment_date IS NOT NULL AND c.days_late_calc = 0 THEN TRUE ELSE FALSE END)  AS is_paid_on_time
FROM calc c;

CREATE INDEX IF NOT EXISTS idx_invoices_invoice_id      ON invoices(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoices_subscription_id ON invoices(subscription_id);
CREATE INDEX IF NOT EXISTS idx_invoices_customer_id     ON invoices(customer_id);


-- =========================
-- 4) EXPORT TO CSV (run these in psql)
-- =========================
-- Export clean tables as CSV files for Tableau dashboard.
-- \copy customers     TO './customers.csv'     CSV HEADER
-- \copy subscriptions TO './subscriptions.csv' CSV HEADER
-- \copy invoices      TO './invoices.csv'      CSV HEADER


-- =========================
-- 5) QUICK DATA CHECKS
-- =========================
-- Validate the cleaned tables before/after export.

-- Row counts
SELECT 'customers'     AS table, COUNT(*) FROM customers
UNION ALL
SELECT 'subscriptions' AS table, COUNT(*) FROM subscriptions
UNION ALL
SELECT 'invoices'      AS table, COUNT(*) FROM invoices;

-- Churn distribution by status
SELECT status, COUNT(*) AS subs, SUM(is_churned::int) AS churned
FROM subscriptions
GROUP BY status
ORDER BY subs DESC;

-- Delay bucket distribution
SELECT delay_bucket, COUNT(*) AS invoices, MIN(days_late) AS min_days, MAX(days_late) AS max_days
FROM invoices
GROUP BY delay_bucket
ORDER BY MIN(days_late);

-- Spot-check late invoices
SELECT invoice_id, customer_id, subscription_id, days_late, delay_bucket, payment_outcome
FROM invoices
WHERE is_late = TRUE
ORDER BY days_late DESC
LIMIT 10;

-- Spot-check enterprise subs
SELECT customer_id, subscription_id, plan_type, is_enterprise, is_churned
FROM subscriptions
WHERE is_enterprise = TRUE
LIMIT 10;
