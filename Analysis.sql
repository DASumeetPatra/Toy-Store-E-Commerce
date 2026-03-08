CREATE DATABASE MAVEN_ECOMMERCE;

# ---------------------------------- IMPORTING DATASETS ----------------------------
create table website_pageviews(
website_pageview_id INT PRIMARY KEY,
created_at DATETIME,
year INT,
month INT,
month_name VARCHAR(20),
website_session_id INT,
pageview_url VARCHAR(200) 
);

load data infile "D:/PROJECTS/Maven+Fuzzy+Factory(E-Commerce)/website_pageviews_cleaned.csv"
into table website_pageviews
fields terminated by ","
ignore 1 rows;

create table website_sessions (
website_session_id INT PRIMARY KEY,
created_at DATETIME,
year INT,
month INT,
month_name VARCHAR(20),
user_id INT,
is_repeat_session VARCHAR(20),
utm_source VARCHAR(20),
utm_campaign VARCHAR(20),
utm_content VARCHAR(20),
device_type VARCHAR(20),
http_referer VARCHAR(200)
);

load data infile "D:/PROJECTS/Maven+Fuzzy+Factory(E-Commerce)/website_sessions_cleaned.csv"
into table website_sessions
fields terminated by ","
ignore 1 rows;

SELECT * FROM order_item_refund;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM website_pageviews;
SELECT * FROM website_sessions;


# --------------------------- REVENUE ANALYSIS --------------------------------

# 1. Rank products by revenue within each month.
WITH CTE1 AS (
SELECT p.product_id, p.product_name, o.month, o.month_name, ROUND(SUM(o.price_usd),2) AS revenue
FROM products as p JOIN order_items as o ON p.product_id = o.product_id
GROUP BY o.month, o.month_name, p.product_id, p.product_name
)

SELECT product_id, product_name, month_name, revenue, 
DENSE_RANK() OVER(PARTITION BY month ORDER BY revenue DESC) AS product_Rank
FROM CTE1; 


# 2. Calculate Month-over-Month revenue growth
WITH monthly_rev AS (
SELECT year, month, month_name, ROUND(SUM(price_usd),2) AS total_revenue
FROM orders
GROUP BY year, month, month_name
)

SELECT year, month, month_name, total_revenue,
LAG(total_revenue) OVER(ORDER BY year, month) AS previous_month_revenue,
CONCAT(ROUND((total_revenue - LAG(total_revenue) OVER(ORDER BY year, month))/LAG(total_revenue) OVER(ORDER BY year, month)*100,2),"%") AS revenue_growth_ercent
FROM monthly_rev;


# 3. Identify top 10% revenue-generating customers
WITH revenue_per_customer AS(
SELECT user_id, ROUND(SUM(price_usd),2) AS total_revenue
FROM orders
GROUP BY user_id
),

customer_percentile AS (
SELECT user_id, total_revenue, 
NTILE(10) OVER(ORDER BY total_revenue DESC) AS revenue_decile
FROM revenue_per_customer
)

SELECT * 
FROM customer_percentile
WHERE revenue_decile = 1;


# 4. Calculate cumulative revenue over time
WITH daily_revenue AS (
SELECT DATE(created_at) AS order_date, ROUND(SUM(price_usd),2) AS revenue  
FROM orders 
GROUP BY DATE(created_at) 
)

SELECT order_date, revenue,
SUM(revenue) OVER(ORDER BY order_date) AS cumulative_revenue
FROM daily_revenue;


# 5. Find the contribution % of each product to total revenue
WITH product_wise_revenue AS (
SELECT product_id, ROUND(SUM(price_usd),2) AS revenue
FROM order_items
GROUP BY product_id
)

SELECT p.product_id, p.product_name, pr.revenue,
CONCAT(ROUND(revenue/SUM(pr.revenue) OVER()*100,2),"%") AS revenue_contribution
FROM products as p JOIN product_wise_revenue AS pr
ON p.product_id = pr.product_id;


# --------------------- CUSTOMER BEHAVIOUR ANALYSIS ---------------------
# 6. Calculate Customer Lifetime Value (CLV)
SELECT user_id,
       COUNT(order_id) AS total_orders,
       ROUND(SUM(price_usd),2) AS total_revenue,
       ROUND(AVG(price_usd),2) AS average_order_value
FROM orders
GROUP BY user_id
ORDER BY total_revenue DESC;


# 7. Identify repeat customers and calculate repeat purchase rate

# A. Identify Repeat Customers
SELECT user_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id
HAVING COUNT(order_id) > 1
ORDER BY total_orders DESC;

# B. Calculate Repeat Purchase Rate
WITH customer_orders AS (
SELECT user_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id
)
SELECT CONCAT(ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END)*100/ COUNT(*),2),"%") AS repeat_purchase_rate
FROM customer_orders;


# 8. Identify customers whose monthly spending trend is declining
WITH monthly_spending AS (
SELECT user_id, 
	DATE_FORMAT(created_at, "%Y-%M") AS order_month,
    SUM(price_usd) AS monthly_revenue
FROM orders
GROUP BY user_id, order_month
),

revenue_change AS(
SELECT user_id, order_month, monthly_revenue,
LAG(monthly_revenue) OVER(PARTITION BY user_id ORDER BY order_month) AS previous_month_revenue
FROM monthly_spending
)

SELECT * FROM revenue_change
WHERE monthly_revenue < previous_month_revenue;


# 9. Identify top 3 customers per month
WITH monthly_customer_revenue AS (
SELECT DATE_FORMAT(created_at,"%Y-%M") AS order_month, user_id,
SUM(price_usd) AS revenue
FROM orders
GROUP BY order_month, user_id
)

SELECT * 
FROM (
      SELECT order_month, 
      user_id, 
      revenue,
      DENSE_RANK() OVER(PARTITION BY order_month
				  ORDER BY revenue DESC) AS customer_rank
	  FROM monthly_customer_revenue
      ) ranked
WHERE customer_rank <=3;



# ----------------------- REFUND & RISK ANALYSIS ------------------------

# 10. Calculate rolling 3-month refund trend
WITH monthly_refund AS (
SELECT DATE_FORMAT(created_at, "%Y-%M") AS refund_month,
	   ROUND(SUM(refund_amount_usd),2) AS refund_amount
FROM order_item_refund
GROUP BY refund_month
)

SELECT refund_month, 
       refund_amount,
       ROUND(AVG(refund_amount) OVER(
       ORDER BY refund_month
       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_3_month_refund
FROM monthly_refund;


# 11. Calculate revenue lost due to refunds by month
SELECT DATE_FORMAT(created_at, "%Y-%M") AS refund_month,
       ROUND(SUM(refund_amount_usd),2) AS revenue_lost
FROM order_item_refund
GROUP BY refund_month
ORDER BY refund_month;


# --------------------- MARKETING ANALYSIS --------------------------

# 12. Calculate conversion rate by traffic source
WITH session_orders AS (
SELECT ws.website_session_id, ws.utm_source, o.order_id
FROM website_sessions ws LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
)

SELECT utm_source, 
       COUNT(DISTINCT website_session_id) AS total_sessions,
       COUNT(DISTINCT order_id) AS total_orders,
       CONCAT(ROUND(
             COUNT(DISTINCT order_id) * 100 / COUNT(DISTINCT website_session_id),2),"%") AS conversion_rate
FROM session_orders
GROUP BY utm_source;


# 13. Rank traffic sources by revenue efficiency (Revenue per Session)
WITH traffic_revenue AS (
SELECT ws.utm_source,
       COUNT(DISTINCT ws.website_session_id) AS sessions,
       ROUND(SUM(o.price_usd),2) AS revenue
FROM website_sessions ws LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
)

SELECT utm_source, sessions, revenue,
ROUND(revenue/sessions,2) AS revenue_per_session,
DENSE_RANK() OVER(ORDER BY revenue/sessions DESC) AS efficiency_rank
FROM traffic_revenue;


# 14. Calculate conversion rate by device type
WITH device_session AS (
SELECT ws.device_type,
       ws.website_session_id,
       o.order_id
FROM website_sessions ws LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
)

SELECT device_type,
       COUNT(DISTINCT website_session_id) AS total_sessions,
       COUNT(DISTINCT order_id) AS total_orders,
       CONCAT(ROUND(COUNT(DISTINCT order_id)*100/COUNT(DISTINCT website_session_id),2),"%") AS conversion_rate
FROM device_session
GROUP BY device_type;


# 15. Calculate time taken from first session to first purchase
WITH first_session AS (
SELECT user_id,
       MIN(created_at) AS first_session_time
FROM website_sessions
GROUP BY user_id
),

first_order AS (
SELECT user_id,
       MIN(created_at) AS first_order_time
FROM orders
GROUP BY user_id
)

SELECT fs.user_id,
       DATEDIFF(fo.first_order_time, fs.first_session_time) AS days_to_first_purchase
FROM first_session fs JOIN first_order fo 
ON fs.user_id = fo.user_id;


# ------------------------ ADVANCED BUSINESS INTELLIGENCE -------------------------

# 16. Calculate running total revenue per product category
WITH category_revenue aS (
SELECT p.product_id,
       p.product_name,
       o.year,
       o.month,
       ROUND(SUM(oi.price_usd),2) AS revenue
FROM order_items oi JOIN orders o 
ON oi.order_id = o.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, o.year, o.month
)

SELECT product_id, product_name, year, month, revenue,
       ROUND(SUM(revenue) OVER(
       PARTITION BY product_id ORDER BY year, month),2
       ) AS running_total_revenue
FROM category_revenue;


# 17. Identify peak purchasing hour per day
WITH hourly_order AS (
SELECT DATE(created_at) AS order_date,
       HOUR(created_at) AS order_hour,
       COUNT(order_id) AS orders
FROM orders
GROUP BY order_date, order_hour
)
SELECT * 
FROM (
SELECT order_date, order_hour, orders, 
       DENSE_RANK() OVER(PARTITION BY order_date ORDER BY orders DESC) AS rank_hour
FROM hourly_order) ranked
WHERE rank_hour = 1;


# 18. Identify top-performing product per traffic source
WITH source_revenue AS (
SELECT ws.utm_source,
	   oi.product_id,
       ROUND(SUM(oi.price_usd),2) AS revenue
FROM website_sessions ws JOIN orders o
ON ws.website_session_id = o.website_session_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY ws.utm_source, oi.product_id
)

SELECT *
FROM (
      SELECT utm_source, product_id, revenue,
			DENSE_RANK() OVER(PARTITION BY utm_source ORDER BY revenue DESC) AS product_rank
      FROM source_revenue) ranked
WHERE product_rank =1;


