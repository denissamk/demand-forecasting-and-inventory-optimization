/*
=========================================================
2_exploratory_analysis.sql
Project : Retail Supply Chain Analytics
Purpose : Explore business performance and identify
          key insights before advanced analytics.
=========================================================
*/

---------------------------------------------------------
-- 1. Business Overview
---------------------------------------------------------

SELECT
    ROUND(SUM(net_sales), 2) AS total_revenue,
    ROUND(SUM(order_profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id) AS total_products
FROM supply_chain;


---------------------------------------------------------
-- 2. Sales Performance
---------------------------------------------------------

-- Top 10 Products

SELECT
    product_name,
    SUM(order_quantity) AS quantity_sold,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM supply_chain
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;


-- Category Performance

SELECT
    category_name,
    SUM(order_quantity) AS quantity_sold,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM supply_chain
GROUP BY category_name
ORDER BY revenue DESC;


---------------------------------------------------------
-- 3. Customer Analysis
---------------------------------------------------------

-- Customer Segment Performance

SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM supply_chain
GROUP BY customer_segment
ORDER BY revenue DESC;


-- Top 10 Customers

SELECT
    customer_id,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM supply_chain
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;


---------------------------------------------------------
-- 4. Geographic Analysis
---------------------------------------------------------

-- Revenue by Market

SELECT
    market,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM supply_chain
GROUP BY market
ORDER BY revenue DESC;


-- Top 10 Countries

SELECT
    order_country,
    ROUND(SUM(net_sales), 2) AS revenue
FROM supply_chain
GROUP BY order_country
ORDER BY revenue DESC
LIMIT 10;


---------------------------------------------------------
-- 5. Time Analysis
---------------------------------------------------------

-- Monthly Sales Trend

SELECT
    order_year,
    order_month,
    order_month_name,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM fact_sales
GROUP BY
    order_year,
    order_month,
    order_month_name
ORDER BY
    order_year,
    order_month;


-- Weekday Performance

SELECT
    weekday_number,
    weekday_name,
    ROUND(SUM(net_sales), 2) AS revenue,
    ROUND(SUM(order_profit), 2) AS profit
FROM fact_sales
GROUP BY
    weekday_number,
    weekday_name
ORDER BY
    weekday_number;


---------------------------------------------------------
-- 6. Supply Chain Performance
---------------------------------------------------------

-- Shipping Performance

SELECT
    shipping_performance,
    COUNT(*) AS total_orders,
    ROUND(AVG(shipping_days_actual), 2) AS avg_shipping_days,
    ROUND(AVG(shipping_delay_days), 2) AS avg_delay_days
FROM fact_sales
GROUP BY shipping_performance
ORDER BY total_orders DESC;


-- Shipping Mode Performance

SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    ROUND(AVG(shipping_days_actual), 2) AS avg_shipping_days
FROM supply_chain
GROUP BY shipping_mode
ORDER BY total_orders DESC;