# Revenue at Risk: Uncovering Churn Drivers in SaaS Billing  
*(Built with synthetic data to protect confidentiality, modeled on real work at Vastian)*  

---

## Business Problem  
At Vastian, leadership noticed a troubling pattern: **recurring revenue was falling short of forecasts during contract renewals**, even though product adoption and customer satisfaction remained strong.  

The cause wasn’t clear — was it product usage, pricing, or something in the billing process?  
As a **Billing Specialist**, I was tasked with leading an investigation from the billing standpoint to **quantify ARR at risk, identify the drivers of churn, and uncover why so many enterprise customers were not renewing.**  

---

## Executive Summary  
Through this analysis, I uncovered that the issue wasn’t product adoption at all — it was **billing friction**.  
Enterprise accounts paying by **Check and Wire** churned at the highest rates, especially when combined with **late invoices** and **regional concentration in the South & Midwest**.  
Churn spikes also aligned with **contract renewal cycles**, when manual-payment enterprise accounts chose not to renew.  

To ensure rigor, I built an end-to-end workflow across **Excel, SQL, and Tableau**:  

- **Excel** → cleaned and validated a 10k-row sample to stress-test KPI logic.  
- **SQL** → scaled those rules to the full dataset, joining customers, subscriptions, and invoices, and creating churn flags, delay buckets, and renewal indicators.  
- **Tableau** → designed an interactive dashboard with KPIs, filters, and visuals to surface churn drivers, renewal cycles, and ARR loss.  

The analysis revealed that **$380M ARR (11.9% of the base)** was lost to churn — concentrated in a small number of high-value enterprise accounts still tied to manual billing processes.  

---

## Dataset Structure  
The dataset consisted of three entities: **customers**, **subscriptions**, and **invoices**.   
<img width="1084" height="765" alt="schema-diagram" src="https://github.com/user-attachments/assets/9a489c1b-2ebd-4da8-83c1-d8d300f30e92" />

---

## Tools, Skills & Methodology  

### 1. Excel → Data Cleaning & Validation  
- Cleaned raw CSVs with formulas (`TRIM`, `PROPER`, `IFERROR`) and lookup tables.  
- Standardized values in **payment_type** and **plan_type**.  
- Built QA checks using:  
  - `COUNTIFS` → churned customer counts.  
  - `SUMIFS` → churned ARR by method and delay.  
- Used pivot tables to reconcile churn metrics before scaling to SQL.  

### 2. SQL → Data Cleaning, Joins, and Export  
- Replicated Excel logic with SQL (`btrim`, `initcap`, `regexp_replace`).  
- Joined **customers ↔ subscriptions ↔ invoices** on IDs.  
- Created **churn flags** (`is_churned`) and **delay buckets** (`0–5`, `6–15`, `16–30`, `30+`).  
- Added **renewal indicators** to flag accounts with upcoming contract expirations.  
- Exported a single clean dataset (`vw_billing_enriched`) for Tableau.  

### 3. Tableau → Visualization & Storytelling  
- Built an **interactive dashboard** with filters for region, plan type, payment method, and year.  
- Added KPI cards for churn % (customers & ARR) and total ARR lost.  
- Visuals included:  
  - **Payment Method Pie** → manual vs automated churn share.  
  - **Delay Buckets** → how late payments drive higher churn.  
  - **Regional Heatmap** → South & Midwest enterprise churn exposure.  
  - **Churned ARR Over Time (by Payment Type)** → churn spikes at renewal cycles.  
  - **State-Level Map** → geographic prioritization for retention.  

---

## Insights Summary  

From a **billing perspective**, the analysis uncovered **systemic revenue risk** at Vastian:  

### 1. Manual Payments Are the Core Churn Driver  
- **Check & Wire customers account for ~$348M (91%) of churned ARR**, despite being a smaller share of the base.  
- In contrast, **ACH/Card customers only lost ~$31M ARR**.  
- Manual billing created the biggest friction at renewal.  

### 2. Late Payments Predict Churn  
- Customers paying **30+ days late churned at nearly 30%**, versus **<1% churn for on-time (0–5 days) payers**.  
- From a billing ops lens, **collections delays were a leading indicator of churn risk**.  

### 3. Regional & Segment Concentration  
- The **South & Midwest regions** carried the heaviest losses, with enterprise and multi-site healthcare customers disproportionately exposed.  
- These accounts often relied on **check/wire billing**, compounding billing friction and renewal risk.  

### 4. Churned ARR Over Time Peaks in Mid-2025  
- Churn **spiked to ~$35M ARR in mid-2025**, led almost entirely by **Check and Wire customers**.  
- These peaks aligned with **contract renewal cycles**, when manual-payment accounts dropped off.  
- ACH and Card remained stable, reinforcing that **automated billing supports smoother renewals**.  

### 5. Enterprise Accounts = High Impact, Low Volume  
- Only **10.6% of customers churned**, but this translated into **11.9% of total ARR lost**.  
- The imbalance shows churn was **concentrated in a handful of high-value enterprise accounts with billing inefficiencies**.  

---

**Key Takeaway:**  
The root cause of Vastian’s ARR erosion wasn’t product adoption — it was **billing friction at renewal**.  
Manual payments, late invoices, and regional patterns combined to create nearly **$380M in preventable ARR loss**.  

---

## Recommendations  

From a billing operations standpoint, I recommended:  

1. **Migrate Customers to Automated Billing**  
   - Focus on Check/Wire enterprise accounts first.  
   - Incentivize ACH/Card adoption through discounts or flexible terms.  

2. **Strengthen Collections (Billing Ops)**  
   - Deploy automated dunning: reminders, retry logic, SLAs.  
   - Focus on **16–30+ day delay buckets**, where churn risk is highest.  

3. **Customer Success Retention Plays**  
   - Partner with CS to prioritize **South & Midwest enterprise accounts** still on manual billing.  
   - Assign executive sponsors for renewal conversations.  

4. **Executive & Sales Engagement**  
   - Build **at-risk account playbooks** for high-value churn drivers.  
   - Use revenue-at-risk data to align **Sales, CS, and Finance** on proactive outreach.  

5. **Renewal Risk Management**  
   - Proactively flag enterprise accounts with **upcoming contract renewals** still on Check/Wire.  
   - Partner Billing + CS to migrate them ahead of renewal dates to avoid churn spikes.    

---

## Next Steps  
- **Phase 1 (Quick Wins):** Publish churn KPIs monthly, flag top 50 high-risk manual accounts, and identify enterprise contracts set to renew within the next 6–12 months.  
- **Phase 2 (Billing Ops):** Automate collections in NetSuite, launch ACH/Card adoption campaigns, and roll out renewal-migration incentives for customers still on Check/Wire.  
- **Phase 3 (Retention & Monitoring):** Track ARR saved, churn reduction, and renewal conversion rates to measure the impact of proactive interventions.  

---

## Impact  
As a **Billing Specialist**, I quantified how **manual payments, late invoices, and renewal drop-offs eroded ~$380M ARR** and provided leadership with a roadmap to act.  

- **Sales/CS:** Target at-risk enterprise accounts in the South & Midwest, and build renewal playbooks for customers still on manual payment methods.  
- **Finance/Billing:** Lead ACH/Card migration, automate retries, strengthen dunning, and align renewal timelines with billing improvements.  
- **Executives:** Sponsor high-value churn prevention programs, ensuring renewals aren’t lost due to billing inefficiencies.  

The impact was not just quantifying churn, but providing a **forward-looking plan to protect revenue** — combining **billing automation, collections improvements, and renewal risk management** to stabilize long-term ARR.  

---

## Dashboard  
The completed interactive dashboard is published on Tableau Public [here](https://public.tableau.com/views/SaaSBillingChurnDashboard/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link).  

The dashboard enables filtering by **region, plan type, payment method, and year**. 
<img width="1115" height="849" alt="image" src="https://github.com/user-attachments/assets/14d1a610-fcaa-4440-b87e-66089cf75f40" />




