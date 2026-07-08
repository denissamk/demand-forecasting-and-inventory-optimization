/*
=========================================================
1_data_quality.sql
Project : Retail Supply Chain Analytics
Purpose : Validate data quality before analysis.
=========================================================
*/

---------------------------------------------------------
-- 1. Total Records
---------------------------------------------------------

SELECT COUNT(*) AS total_rows
FROM supply_chain;


---------------------------------------------------------
-- 2. Time Period
---------------------------------------------------------

SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    MIN(shipping_date) AS first_shipping,
    MAX(shipping_date) AS last_shipping
FROM supply_chain;


---------------------------------------------------------
-- 3. Missing Value
---------------------------------------------------------

SELECT

COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,

COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulls,

COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_nulls,

COUNT(*) FILTER (WHERE product_id IS NULL) AS product_nulls,

COUNT(*) FILTER (WHERE order_quantity IS NULL) AS quantity_nulls,

COUNT(*) FILTER (WHERE gross_sales IS NULL) AS sales_nulls,

COUNT(*) FILTER (WHERE order_profit IS NULL) AS profit_nulls

FROM supply_chain;


---------------------------------------------------------
-- 4. Duplicate Order ID's
---------------------------------------------------------

SELECT
    order_id,
    COUNT(*) AS total_records
FROM supply_chain
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


---------------------------------------------------------
-- 5. Duplicate Order Items
---------------------------------------------------------

SELECT
    order_item_id,
    COUNT(*)
FROM supply_chain
GROUP BY order_item_id
HAVING COUNT(*) > 1;


---------------------------------------------------------
-- 6. Invalid Quantities
---------------------------------------------------------

SELECT *
FROM supply_chain
WHERE order_quantity <= 0;


---------------------------------------------------------
-- 7. Invalid Sales
---------------------------------------------------------

SELECT *
FROM supply_chain
WHERE gross_sales <= 0 OR net_sales <= 0;


---------------------------------------------------------
-- 8. Discount Validation
---------------------------------------------------------

SELECT *
FROM supply_chain
WHERE discount_rate < 0
   OR discount_rate > 1;


---------------------------------------------------------
-- 9, Shipping Days Validation
---------------------------------------------------------

SELECT *
FROM supply_chain
WHERE shipping_days_actual < 0
   OR shipping_days_scheduled < 0;


---------------------------------------------------------
-- 10. Shipping Consistency
---------------------------------------------------------

SELECT
    order_id,
    order_date,
    shipping_date,
    shipping_days_actual,
    (shipping_date::date - order_date::date) AS calculated_days
FROM supply_chain
WHERE shipping_days_actual <>
      (shipping_date::date - order_date::date);


---------------------------------------------------------
-- 11. Order Status Distribution
---------------------------------------------------------

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM supply_chain
GROUP BY order_status
ORDER BY total_orders DESC;


---------------------------------------------------------
-- 12. Delivery Status Distribution 
---------------------------------------------------------

SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM supply_chain
GROUP BY delivery_status
ORDER BY total_orders DESC;


---------------------------------------------------------
-- 13. Shipping Mode Distribution
---------------------------------------------------------

SELECT
    shipping_mode,
    COUNT(*) AS total_orders
FROM supply_chain
GROUP BY shipping_mode
ORDER BY total_orders DESC;