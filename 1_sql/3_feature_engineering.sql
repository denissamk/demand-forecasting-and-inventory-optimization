/*
=========================================================
3_feature_engineering.sql
Project : Retail Supply Chain Analytics
Purpose : Prepare daily product demand data for
          forecasting and inventory analysis.
=========================================================
*/

DROP VIEW IF EXISTS fact_daily_demand;

CREATE VIEW fact_daily_demand AS

SELECT

    order_date::DATE AS order_date,

    product_id,

    product_name,

    category_name,

    department_name,

    SUM(order_quantity) AS daily_demand,

    ROUND(SUM(net_sales), 2) AS daily_sales,

    ROUND(SUM(order_profit), 2) AS daily_profit

FROM supply_chain

GROUP BY

    order_date::DATE,
    product_id,
    product_name,
    category_name,
    department_name

ORDER BY

    order_date,
    product_id;