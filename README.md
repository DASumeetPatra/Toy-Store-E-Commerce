# E-Commerce Data Analysis (Python + SQL)

## Project Highlights

* Built an end-to-end **data analytics project** using Python for data cleaning and MySQL for analysis.
* Analyzed the **complete Toy Store E-commerce customer journey** from website visit to purchase and refunds.
* Solved **real business problems** related to revenue growth, customer behavior, marketing performance, and operational risk.
* Used **advanced SQL techniques** including CTEs, window functions, ranking functions, and time-series analysis.
* Generated actionable insights that could help businesses improve **customer retention, marketing efficiency, and product performance**.

---

# Project Overview

This project analyzes an e-commerce dataset to uncover insights about revenue trends, customer behavior, marketing performance, and refund patterns. The analysis simulates real-world business problems faced by e-commerce companies and demonstrates how SQL can be used to transform raw data into actionable insights.

The workflow of this project follows a typical data analytics pipeline:

```
Raw Data → Data Cleaning (Python) → Database Setup (MySQL) → SQL Analysis → Business Insights
```

The objective of this project is to demonstrate practical SQL skills and business-oriented thinking required for a **Data Analyst role**.

---

# Dataset Description

The dataset represents an e-commerce platform that tracks user activity from website visits to purchases and refunds.

The dataset includes six main tables:

| Table             | Description                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------------- |
| website_sessions  | Information about website visits including marketing source, device type, and session details |
| website_pageviews | Tracks individual pages viewed during each session                                            |
| orders            | Order-level information including purchase time and order value                               |
| order_items       | Product-level details within each order                                                       |
| order_item_refund | Records refund transactions for returned items                                                |
| products          | Product catalog information                                                                   |

### Customer Journey Modeled in the Dataset

```
Website Session → Page View → Order → Order Item → Refund
```

This structure enables analysis of the **complete customer lifecycle**, from traffic acquisition to purchase and post-purchase behavior.

---

# Data Cleaning Process (Python)

Before performing SQL analysis, the dataset was cleaned using **Python (Pandas)** to ensure accuracy and consistency.

### Key Data Cleaning Steps

1. **Handling Missing Values**

   * Checked for missing values across datasets and handled them appropriately.

2. **Date Formatting**

   * Converted timestamp columns into datetime format.

3. **Feature Engineering**

   * Extracted additional time-based features:

     * Year
     * Month
     * Month name

4. **Data Consistency Checks**

   * Verified primary keys.
   * Checked and removed duplicate records if present.

5. **Exporting Cleaned Data**

   * Cleaned datasets were exported as CSV files and imported into MySQL.

These steps ensured the dataset was reliable and ready for SQL-based analysis.

---

# Database Setup

The cleaned datasets were imported into **MySQL** and structured into relational tables. Relationships between tables allow tracking the entire customer journey from website interaction to purchase and refunds.

---

# Business Problems Addressed

The analysis focuses on solving key business problems in four main areas.

### Revenue Analysis

* Rank products by revenue within each month.
* Analyze month-over-month revenue growth.
* Calculate cumulative revenue trends.
* Identify revenue contribution of each product.
* Identify top 10% revenue - generating customers.

### Customer Behavior Analysis

* Calculate Customer Lifetime Value (CLV).
* Identify repeat customers and repeat purchase rate.
* Detect customers with declining spending patterns.
* Identify top 3 customers each month.

### Marketing Performance Analysis

* Calculate conversion rate by traffic source.
* Identify revenue per session for marketing channels.
* Analyze conversion rate across device types.
* Measure time taken from first website visit to purchase.

### Refund & Risk Analysis

* Analyze monthly refund trends.
* Calculate total revenue lost due to refunds.

### Advanced Business Intelligence

* Calculate running total revenue per product category
* Identify peak purchasing hour per day
* Identify top-performing product per traffic source

---

# SQL Techniques Used

The analysis demonstrates several SQL techniques commonly used by data analysts.

### Joins

Combining multiple tables to analyze the full customer journey.

### Common Table Expressions (CTEs)

Used to break complex queries into logical steps.

### Window Functions

Used for advanced analytics and ranking.

Functions used include:

```
DENSE_RANK()
LAG()
NTILE()
SUM() OVER()
AVG() OVER()
```

### Time-Series Analysis

Used to analyze trends in revenue and refunds over time.

---

# Key Insights

### Revenue Insights

* Total revenue generated during the analysis period was **$ 1,938,509.75**.
* **The Original Mr. Fuzzy** generated approximately **$ 1211057.74 in revenue**, contributing about **62.47% of total sales**.
* Highest monthly revenue recorded in **December 2014 at $144823.02**.

---

### Customer Behavior Insights

* The **highest spending customer(user_id - 281298) generated $219.96 in total revenue**.
* Some customers showed **declining monthly spending trends**, which may indicate potential churn risk.

---

### Operational Insights

* Total revenue lost due to refunds was approximately **$85,338.69**.
* The **highest refund month(September 2014) recorded $11773.63 in refunded transactions**.

---

### Business Impact

These insights help businesses understand:

* Which products generate the most revenue
* Which marketing channels drive profitable traffic
* Customer purchasing behavior and retention patterns
* Operational risks such as refunds impacting revenue

This information can help decision-makers improve **marketing strategies, customer retention efforts, and product performance monitoring**.


---

# Business Recommendations

Based on the analysis, the following strategies could improve business performance.

**Improve Marketing Efficiency**
Focus marketing spend on traffic sources with higher conversion rates.

**Customer Retention**
Identify declining customers and target them with promotional campaigns.

**Product Strategy**
Monitor top-performing products and optimize inventory planning.

**Refund Reduction**
Investigate products with higher refund levels to improve product descriptions or quality.

---

# Conclusion

This project demonstrates how SQL can be used to transform raw e-commerce data into meaningful business insights. By combining Python for data cleaning and SQL for analysis, the project replicates a real-world data analytics workflow.

The analysis highlights important patterns in revenue growth, customer behavior, marketing performance, and operational risks. These insights can help businesses make data-driven decisions to improve overall performance.

---

# Tools Used

* Python (Pandas)
* MySQL
* Data Analysis
