/*
=========================================================
4_inventory_metrics.sql
Project : Retail Supply Chain Analytics
Purpose : Create inventory metrics for Python analysis.
=========================================================
*/

DROP VIEW IF EXISTS fact_inventory;

CREATE VIEW fact_inventory AS

WITH daily_stats AS (

    SELECT
        product_id,
        product_name,
        category_name,
        department_name,

        AVG(daily_demand) AS avg_daily_demand,
        STDDEV(daily_demand) AS demand_stddev,
        SUM(daily_demand) AS total_demand

    FROM fact_daily_demand

    GROUP BY
        product_id,
        product_name,
        category_name,
        department_name

),

sales_velocity AS (

    SELECT
        product_id,

        ROUND(
            SUM(order_quantity)::NUMERIC
            /
            COUNT(DISTINCT order_date),
            2
        ) AS units_per_day

    FROM supply_chain

    GROUP BY product_id

),

shipping_metrics AS (

    SELECT
        product_id,

        ROUND(AVG(shipping_days_actual),2) AS avg_shipping_days,

        ROUND(
            AVG(shipping_days_actual - shipping_days_scheduled),
            2
        ) AS avg_shipping_delay,

        SUM(late_delivery_risk) AS late_deliveries

    FROM supply_chain

    GROUP BY product_id

)

SELECT

    d.product_id,
    d.product_name,
    d.category_name,
    d.department_name,

    ROUND(d.avg_daily_demand,2) AS avg_daily_demand,

    ROUND(d.demand_stddev,2) AS demand_stddev,

    ROUND(
        d.demand_stddev
        /
        NULLIF(d.avg_daily_demand,0),
        3
    ) AS coefficient_of_variation,

    d.total_demand,

    v.units_per_day,

    s.avg_shipping_days,
    s.avg_shipping_delay,
    s.late_deliveries

FROM daily_stats d

LEFT JOIN sales_velocity v
    ON d.product_id = v.product_id

LEFT JOIN shipping_metrics s
    ON d.product_id = s.product_id;