# Revenue at Risk: Uncovering Churn Drivers in SaaS Billing 
*(Built with synthetic data to protect confidentiality, modeled on real work at Vastian)*  

---
## Executive Summary  
At Vastian, a Software-as-a-Service (SaaS) company, I conducted a churn analysis to quantify recurring revenue loss and uncover billing-driven churn risks. To ensure rigor, I built an end-to-end workflow across **Excel, SQL, and Tableau**:  

- **Excel** → cleaned and validated a 10k-row sample to spot inconsistencies and stress-test KPI logic.  
- **SQL** → scaled those cleaning rules to the full dataset, joined customers/subscriptions/invoices, and created churn flags and delay buckets. Exported one enriched dataset.  
- **Tableau** → designed an interactive dashboard with KPIs, filters, and visuals to surface churn drivers and ARR loss.  

The analysis revealed that **enterprise accounts on manual payment methods (Check/Wire)** churned at the highest rates, worsened by **late payments** and **regional concentration in the South & Midwest**. Overall, this equated to an estimated **$380M ARR lost to churn**, representing **11.9% of total revenue base**.  

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
- Exported a single clean dataset (`vw_billing_enriched`) for Tableau.  

### 3. Tableau → Visualization & Storytelling  
- Built an **interactive dashboard** with filters for region, plan type, payment method, and year.  

---

## Insights Summary  

The analysis uncovered **clear patterns of revenue loss**, revealing how billing practices directly impacted churn:  

### 1. Manual Payments Are the Core Churn Driver  
- **Check & Wire customers account for ~$348M (91%) of churned ARR**, despite being a smaller share of the base.  
- In contrast, **ACH/Card customers only lost ~$31M ARR**.  
- This confirms that **billing friction is not evenly distributed — it’s concentrated in manual methods**.  

### 2. Late Payments Predict Churn  
- Customers paying **30+ days late churned at nearly 30%**, versus **<1% churn for on-time (0–5 days) payers**.  
- This shows a **direct cause-effect link**: payment delays aren’t just a symptom — they are a leading indicator of churn risk.  

### 3. Regional & Segment Concentration  
- The **South & Midwest regions** carried the heaviest losses, with enterprise and multi-site healthcare customers disproportionately exposed.  
- These accounts often rely on **check/wire billing**, combining regional behavior with manual process risk.  

### 4. Churned ARR Over Time Peaks in Mid-2025  
- Churn **spiked to ~$35M ARR in mid-2025**, almost entirely driven by **Check and Wire customers**.  
- ACH/Card churn remained flat, reinforcing that **automated payments stabilize revenue over time**.  
- The time series highlights **when and how churn risks materialize**, not just total loss.  

### 5. Enterprise Accounts = High Impact, Low Volume  
- Only **10.6% of customers churned**, but this translated into **11.9% of total ARR lost**.  
- The imbalance shows churn is **not spread evenly** — large enterprise accounts drive outsized financial risk.  

---

**Key Takeaway:**  
Churn in this dataset isn’t random — it’s systemic. It clusters in **manual payment methods**, **late payers**, and **enterprise accounts in specific regions**. By addressing billing friction, the company could protect nearly **$380M ARR** and stabilize growth.  
---

## Recommendations  

1. **Migrate Customers to Automated Billing**  
   - Focus on Check/Wire enterprise accounts first.  
   - Incentivize ACH/Card adoption through discounts or flexible terms.  

2. **Strengthen Collections (Billing Ops)**  
   - Deploy automated dunning: reminders, retry logic, SLAs.  
   - Focus on **16–30+ day delay buckets**, where churn risk is highest.  

3. **Customer Success Retention Plays**  
   - Prioritize **South & Midwest enterprise accounts**.  
   - Assign executive sponsors and proactive support to top churn-risk customers.  

4. **Executive & Sales Engagement**  
   - Build **at-risk account playbooks** for high-value churn drivers.  
   - Use revenue-at-risk data to align **Sales, CS, and Finance** on proactive outreach.  

---

## Next Steps  
- **Phase 1 (Quick Wins):** Publish churn KPIs monthly, flag top 50 high-risk manual accounts.  
- **Phase 2 (Billing Ops):** Automate collections in NetSuite and roll out ACH adoption campaigns.  
- **Phase 3 (Retention & Monitoring):** Track ARR saved and churn reduction post-migration.  

---

## Impact  
By surfacing that **manual payments and late invoices eroded ~$380M ARR**, I provided leadership with **cross-functional actions**:  
- Sales/CS: Target at-risk enterprise accounts in South & Midwest.  
- Finance/Billing: Lead ACH/Card migration, automate retries, strengthen dunning.  
- Execs: Sponsor high-value churn prevention programs.  

The impact was not just quantifying churn, but providing a **roadmap to protect revenue** and reduce reliance on manual billing.  

---

## Dashboard  
The completed interactive dashboard is published on Tableau Public [here]( https://public.tableau.com/views/SaaSChurnAnalysisDashboard/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link).  

The dashboard enables filtering by **region, plan type, payment method, and year**. It surfaces insights on **payment delays, churn rates, ARR loss, regional exposure, and time-based churn patterns**.  
<img width="1084" height="765" alt="image" src="https://github.com/user-attachments/assets/dcc316ab-f693-4288-945d-babf582a4c0d" />


