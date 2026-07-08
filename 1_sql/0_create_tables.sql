/*
=========================================================
0_create_tables.sql
Project : Retail Supply Chain Analytics
Purpose : Create the proper ready-to-analysis tables.
=========================================================
*/

---------------------------------------------------------
-- 1. Inspect Raw Data
---------------------------------------------------------

SELECT *
FROM supply_chain_raw
LIMIT 5;


---------------------------------------------------------
-- 2. Inspect Schema Information
---------------------------------------------------------

SELECT *
FROM information_schema.columns
WHERE table_name = 'supply_chain_raw'
ORDER BY ordinal_position;


---------------------------------------------------------
-- 3, Create the Analytical Table
---------------------------------------------------------

CREATE TABLE supply_chain AS
SELECT

    /*====================================================
      ORDER INFORMATION
    ====================================================*/

    "Order Id"::INT AS order_id,

    "Order Item Id"::INT AS order_item_id,

    TO_TIMESTAMP(
        "order date (DateOrders)",
        'MM/DD/YYYY HH24:MI'
    ) AS order_date,

    TO_TIMESTAMP(
        "shipping date (DateOrders)",
        'MM/DD/YYYY HH24:MI'
    ) AS shipping_date,

    "Order Status"::VARCHAR(30) AS order_status,

    "Delivery Status"::VARCHAR(30) AS delivery_status,

    "Shipping Mode"::VARCHAR(30) AS shipping_mode,

    "Days for shipping (real)"::SMALLINT AS shipping_days_actual,

    "Days for shipment (scheduled)"::SMALLINT AS shipping_days_scheduled,

    late_delivery_risk::SMALLINT,

    /*====================================================
      CUSTOMER
    ====================================================*/

    "Customer Id"::INT AS customer_id,

    "Customer Segment"::VARCHAR(30) AS customer_segment,

    "Customer City"::VARCHAR(100) AS customer_city,

    "Customer State"::VARCHAR(100) AS customer_state,

    "Customer Country"::VARCHAR(100) AS customer_country,

    /*====================================================
      PRODUCT
    ====================================================*/

    "Product Card Id"::INT AS product_id,

    "Product Name"::VARCHAR(255) AS product_name,

    "Category Id"::INT AS category_id,

    "Category Name"::VARCHAR(100) AS category_name,

    "Department Id"::INT AS department_id,

    "Department Name"::VARCHAR(100) AS department_name,

    /*====================================================
      GEOGRAPHY
    ====================================================*/

    market::VARCHAR(50),

    "Order City"::VARCHAR(100) AS order_city,

    "Order State"::VARCHAR(100) AS order_state,

    "Order Country"::VARCHAR(100) AS order_country,

    "Order Region"::VARCHAR(100) AS order_region,

    /*====================================================
      SALES & FINANCIALS
    ====================================================*/

    sales::NUMERIC(12,2) AS gross_sales,

    "Sales per customer"::NUMERIC(12,2) AS sales_per_customer,

    "Order Item Quantity"::INT AS order_quantity,

    "Product Price"::NUMERIC(12,2) AS product_price,

    "Order Item Total"::NUMERIC(12,2) AS net_sales,

    "Order Item Discount"::NUMERIC(12,2) AS discount_amount,

    "Order Item Discount Rate"::NUMERIC(6,4) AS discount_rate,

    "Order Profit Per Order"::NUMERIC(12,2) AS order_profit

FROM supply_chain_raw;


---------------------------------------------------------
-- 4. Verify Table
---------------------------------------------------------

SELECT *
FROM supply_chain
LIMIT 5;


---------------------------------------------------------
-- 5. Check the Data Types
---------------------------------------------------------

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'supply_chain'
ORDER BY ordinal_position;


---------------------------------------------------------
-- 6. Create a Fact View that Adds Derived Time Attributes
---------------------------------------------------------

CREATE VIEW fact_sales AS

SELECT

    sc.*,

    /*=========================
      DATE DIMENSIONS
    =========================*/

    EXTRACT(YEAR FROM order_date)::INT AS order_year,

    EXTRACT(QUARTER FROM order_date)::INT AS order_quarter,

    EXTRACT(MONTH FROM order_date)::INT AS order_month,

    TO_CHAR(order_date, 'FMMonth') AS order_month_name,

    EXTRACT(WEEK FROM order_date)::INT AS order_week,

    EXTRACT(DAY FROM order_date)::INT AS order_day,

    TO_CHAR(order_date, 'FMDay') AS weekday_name,

    EXTRACT(ISODOW FROM order_date)::INT AS weekday_number,

    CASE
        WHEN EXTRACT(ISODOW FROM order_date) IN (6,7)
        THEN TRUE
        ELSE FALSE
    END AS is_weekend,

    /*=========================
      SHIPPING METRICS
    =========================*/

    (shipping_date::date - order_date::date) AS calculated_shipping_days,

    shipping_days_actual - shipping_days_scheduled
        AS shipping_delay_days,

    CASE

        WHEN shipping_days_actual < shipping_days_scheduled
            THEN 'Early'

        WHEN shipping_days_actual = shipping_days_scheduled
            THEN 'On Time'

        ELSE 'Late'

    END AS shipping_performance,

    /*=========================
      SALES METRICS
    =========================*/

    gross_sales / NULLIF(order_quantity,0)
        AS average_selling_price,

    order_profit / NULLIF(net_sales,0)
        AS profit_margin

FROM supply_chain sc;


---------------------------------------------------------
-- 7. Verify the View
---------------------------------------------------------

SELECT *
FROM fact_sales
LIMIT 5;