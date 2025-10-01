# Revenue at Risk: Uncovering Churn Drivers in SaaS Billing 
*(Built with synthetic data to protect confidentiality, modeled on real work at Vastian)*  

---

## Executive Summary  
At Vastian, a Software-as-a-Service (SaaS) company, I conducted a churn analysis to quantify recurring revenue loss and uncover billing-driven churn risks. To ensure rigor, I built an end-to-end workflow across **Excel, SQL, and Tableau**:

- **Excel** → cleaned and validated a 10k-row sample to spot inconsistencies and stress-test KPI logic.

- **SQL** → scaled those cleaning rules to the full dataset, joined customers/subscriptions/invoices, and added churn flags and delay buckets. Exported one clean enriched CSV.

- **Tableau** → built an interactive dashboard to surface churn drivers and deliver actionable insights.

The analysis revealed that enterprise accounts on manual payment methods (Check/Wire) had the highest churn, worsened by late payments and regional concentration in the South & Midwest. Recommendations to migrate customers to automated billing and strengthen collections could protect ~$380M ARR.

---
## Dataset Structure
The dataset consisted of three entities: **customers**, **subscriptions**, and **invoices**.   
<img width="1084" height="765" alt="schema-diagram" src="https://github.com/user-attachments/assets/9a489c1b-2ebd-4da8-83c1-d8d300f30e92" />

---

## Tools, Skills & Methodology

### 1. Excel → Data Cleaning & Validation  
- Imported a 10k-row sample of the raw CSVs.  
- Used formulas (`TRIM`, `PROPER`, `IFERROR`, `ISTEXT`, `ISBLANK`) to clean fields.  
- Fixed misspellings in **payment_type** and **plan_type** with lookup logic.  
- Built cross-check models with:  
  - `COUNTIFS` → distinct churned customers.  
  - `SUMIFS` → ARR churn by method and delay bucket.  
- Created pivot tables to reconcile totals.  
- Purpose: act as a **QA sandbox** before scaling to SQL.  

### 2. SQL → Data Cleaning, Joins, and Export  
- Translated Excel cleaning rules into PostgreSQL (`btrim`, `initcap`, `regexp_replace`).  
- Standardized categories using **mapping tables**.  
- Joined **customers ↔ subscriptions ↔ invoices** on keys.  
- Created **churn flags** (`is_churned`) and **delay buckets** (`0–5`, `6–15`, `16–30`, `30+`).  
- Produced a single enriched dataset (`vw_billing_enriched`) for Tableau.  

### 3. Tableau → Visualization & Storytelling  
- Connected Tableau to the clean enriched CSV.  
- Designed an **interactive dashboard** with filters (region, plan type, payment method).  
- Added KPI cards for **Customer Churn %**, **ARR Churn %**, and **ARR Loss**.  
- Visualized **payment delays vs churn risk**, **regional hotspots**, and **enterprise account exposure**.  
- Built **drilldowns** for customer-level insights.  

---

## Insights Summary  
In order to evaluate churn and ARR loss, I focused on the following key metrics:  

- **Customer Churn Rate (10.6%)** → Percent of customers lost across all payment methods.  
- **ARR Churn Rate (11.9%)** → Percent of total revenue base lost to churn.  
- **ARR Loss by Payment Method** → Churned ARR split across manual (Check/Wire) vs automated (ACH/Card).  
- **Churn by Payment Delay** → How late payments (0–5 days, 6–15 days, 16–30 days, 30+ days) correlate with churn rates.  
- **Regional & Segment Patterns** → Churned ARR by region and plan type.  

**ARR Loss**  
- ~$380M lost to churn → **11.9% of total revenue base**, but only **10.6% of customers**.  
- This indicates churn is concentrated in **large, high-value enterprise accounts**.  

**Payment Method**  
- **Manual methods (Check/Wire)** drove ~$348M churned ARR.  
- **Automated methods (ACH/Card)** drove only ~$31M.  
- Manual payment friction is the single strongest churn driver.  

**Payment Delays**  
- Customers paying **30+ days late churn at ~30%**, compared to <1% churn for those paying on time (0–5 days).  
- Delays are a clear predictor of churn risk.  

**Regional Hotspots**  
- Churn is highest in the **South & Midwest**, especially among **enterprise and multi-site hospitals/clinics**.  
- A small number of large enterprise accounts drove disproportionate churned ARR.  

---

## Recommendations  
1. **Migrate Customers to Automated Billing (ACH/Card)**  
   - Prioritize **enterprise and multi-site accounts** on Check/Wire to reduce payment friction.  

2. **Strengthen Collections (Dunning)**  
   - Implement **automated payment reminders, retry logic, and SLAs** for overdue invoices.  
   - Target customers in the **16–30+ day delay buckets**, where churn risk is highest.  

3. **Targeted Retention Efforts**  
   - Focus Customer Success and Account Management on **South & Midwest enterprise accounts**.  
   - Provide incentives or dedicated support for high-value accounts to migrate to automated billing.  

4. **Executive Engagement**  
   - Develop **playbooks for top at-risk enterprise customers**.  
   - Offer custom terms, executive outreach, or migration pilots for high-churn-value accounts.  

---

## Next Steps  
- **Phase 1 (Quick Wins):** Publish churn KPIs monthly, flag top 50 manual-payment enterprise accounts, and begin migration outreach.  
- **Phase 2 (Process):** Automate collections in NetSuite, run ACH/Card adoption campaigns with incentives.  
- **Phase 3 (Monitoring):** Track ARR saved, churn reduction, and migration adoption rates.  

---

## Impact  
By surfacing that manual payments and late invoices eroded nearly **$380M ARR**, I provided leadership with **targeted recommendations**:  
- Customer Success and Sales should **prioritize enterprise and multi-site accounts** in the **South and Midwest**, where churn was concentrated.  
- Finance should drive the **migration from Check/Wire to ACH/Card** and strengthen dunning with **automated reminders, retry logic, and SLAs**.  
- At the same time, I raised the need to dig deeper with Product and Pricing teams to see if churn in these regions was also linked to **usage behavior, contract terms, or pricing sensitivity**.  

The impact was not only quantifying churn, but also equipping leadership with a **cross-functional playbook** to address both the **billing friction immediately** and the **underlying business drivers long-term**. 

---

## Dashboard  
The completed interactive dashboard can be found on Tableau Public [here]( https://public.tableau.com/views/SaaSChurnAnalysisDashboard/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link).  

This dashboard enables users to filter by **region, plan type, payment method, and state**, and highlights key insights on **ARR loss, churn rates, payment delays, and high-risk customer segments**.  
<img width="1084" height="765" alt="image" src="https://github.com/user-attachments/assets/dcc316ab-f693-4288-945d-babf582a4c0d" />


