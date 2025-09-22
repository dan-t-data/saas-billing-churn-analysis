# SaaS Billing Churn Analysis  
*(Built with synthetic data to protect confidentiality, modeled on real work at Vastian)*  

---

## Executive Summary  
At Vastian, I conducted a churn analysis to quantify recurring revenue loss and uncover billing-driven churn risks. To ensure rigor, I built an end-to-end workflow across SQL, Excel, and Tableau:

- **SQL** to join Salesforce and NetSuite datasets (customers, subscriptions, invoices) and calculate churn drivers.

- **Excel** to clean, validate, and stress-test KPIs before visualization.

- **Tableau** to design an interactive dashboard for executive decision-making.

This analysis revealed that enterprise accounts on manual payment methods (Check/Wire) had the highest churn, worsened by late payments and regional concentration in the South & Midwest. Recommendations to migrate customers to automated billing and strengthen collections could protect ~$380M ARR.

---
## Dataset Structure
The dataset consisted of three tables, including information about customers, subscriptions, and invoices. 
<img width="1160" height="1312" alt="schema-diagram" src="https://github.com/user-attachments/assets/9a489c1b-2ebd-4da8-83c1-d8d300f30e92" />

---

## Tools, Skills & Methodology  
- **SQL** → Queried Salesforce & NetSuite data, joined customer/subscription/invoice tables, cleaned fields, and created churn flags.  
- **Excel** → Modeled and validated KPIs (Customer Churn %, ARR Churn %, ARR Loss by method), stress-tested formulas.  
- **Tableau** → Built interactive dashboards with filters (region, plan type, payment method), KPI cards, churn vs. delay visuals, and customer-level drilldowns.  
- **Methodology:**  
  - Defined churn KPIs: Customer Churn %, ARR Churn %, ARR Loss by payment type.  
  - Segmented customers by **payment method, delay buckets, region, and plan type**.  
  - Designed dashboard layers: **executive KPIs, churn drivers, and customer drilldowns**.  
- **Core Skills:** Data wrangling, joining disparate systems, KPI design, churn modeling, visualization, financial impact analysis, and data storytelling.  

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
This project demonstrates my ability to work end-to-end as a data analyst:

- **Excel** → Cleaned and validated 100K+ rows of billing data, reconciled KPIs with formulas and pivots.

- **SQL** → Modeled customer/subscription/invoice relationships, created churn drivers, and built aggregate metrics.

- **Tableau** → Delivered an interactive dashboard that transformed raw data into strategic recommendations.

By surfacing that manual payments and late invoices eroded nearly $380M ARR, I provided leadership with actionable insights to reduce churn and protect revenue

---

## Dashboard  
The completed interactive dashboard can be found on Tableau Public [here]( https://public.tableau.com/views/SaaSChurnAnalysisDashboard/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link).  

This dashboard enables users to filter by **region, plan type, payment method, and state**, and highlights key insights on **ARR loss, churn rates, payment delays, and high-risk customer segments**.  
<img width="1084" height="765" alt="image" src="https://github.com/user-attachments/assets/dcc316ab-f693-4288-945d-babf582a4c0d" />


