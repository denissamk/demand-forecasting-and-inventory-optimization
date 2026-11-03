# 📦 Demand Forecasting & Inventory Optimization Analysis

## Introduction

This project is an end-to-end **Retail Supply Chain Analytics** project that demonstrates how historical supply chain data can be transformed into actionable insights for demand forecasting and inventory planning using **PostgreSQL, Python, and Power BI**.

The project combines **demand forecasting** with **inventory optimization** to support data-driven replenishment planning through metrics such as **Safety Stock**, **Lead Time Demand**, **Reorder Point**, and **ABC–XYZ inventory classification**.

**Workflow:** PostgreSQL → Python → Power BI

The report consists of **two dashboard pages**:

1. **Demand Forecast** – predicts future product demand using Holt-Winters Exponential Smoothing method and highlights demand trends.
2. **Inventory Optimization** – converts forecast results into inventory planning metrics including Safety Stock, Reorder Point, and ABC–XYZ classification.

---

# Background

Balancing inventory availability with inventory cost is one of the biggest challenges in retail and supply chain management. Excess inventory increases holding costs, while insufficient inventory leads to stockouts and lost sales.

This project uses historical demand and statistical forecasting to estimate future demand and support inventory replenishment decisions.

The project addresses the following business questions:

- Which products are expected to grow?
- Which products are expected to decline?
- How much safety stock should be maintained?
- What should the reorder point be?
- Which products deserve the highest inventory priority?

---

# Tools Used

## PostgreSQL

- Data cleaning
- Data validation
- Exploratory analysis
- Feature engineering
- Daily demand aggregation
- Inventory metric preparation

## Python (Pandas & Statsmodels)

- Holt-Winters Exponential Smoothing forecasting
- Demand trend segmentation
- ABC Classification
- XYZ Classification (Coefficient of Variation)
- Safety Stock calculation
- Lead Time Demand calculation
- Reorder Point calculation
- Export analytical datasets

## Power BI

- Data modeling
- Interactive dashboards
- KPI reporting
- Business visualization

## DAX

- KPI measures
- Dynamic calculations
- Time intelligence

---

# Project Workflow

```text
DataCo Global Supply Chain Dataset
            │
            ▼
        PostgreSQL
(Data Cleaning & Feature Engineering)
            │
            ├── fact_daily_demand
            └── fact_inventory
            │
            ▼
          Python
(Holt-Winters Forecasting &
 Inventory Planning)
            │
            ├── fact_forecast
            └── fact_inventory_analysis
            │
            ▼
         Power BI
```

---

# Analysis

## 1. Data Preparation

The raw supply chain dataset was cleaned, validated, and transformed in PostgreSQL. Daily demand and inventory metrics were prepared before exporting the processed data to Python for forecasting and inventory planning.

<details>
<summary><b>Click to View SQL: Fact Daily Demand (BigQuery)</b></summary>

```sql
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
```

</details>

## 2. Demand Forecasting

<p align="center">
  <img src="3_reports/images/Page%201%20(Demand%20Forecasting).png" width="80%">
</p>

Historical daily demand for each product was modeled using **Holt-Winters Exponential Smoothing** with an additive trend and weekly seasonality.

The model generates a **30-day demand forecast** for each product.

The Demand Forecast dashboard provides:

- Total 30-Day Forecast Demand
- Average Daily Forecast Demand
- Number of Products Forecasted
- Average Demand Change
- Top Demand Categories
- Top Demand Growth Categories
- Product-level Forecast Comparison

Interactive filtering allows users to analyze products with **Increasing**, **Stable**, or **Declining** demand trends.

<details>
<summary><b>Click to View Python: Demand Forecasting</b></summary>

Calculated 30-day demand forecasts for each product using Holt-Winters Exponential Smoothing.

```python
# Forecast every product separately
FORECAST_DAYS = 30

forecast_rows = []


# Loop through products
for product_id, group in df.groupby("product_id"):

    group = (
        group.sort_values("order_date")
             .set_index("order_date")
    )

    demand = group["daily_demand"]


    # Skip products with insufficient history
    if len(demand) < 14:
        continue

    try:

        model = ExponentialSmoothing(
            demand,
            trend="add",
            seasonal="add",
            seasonal_periods=7
        )

        fit = model.fit(optimized=True)

        forecast = fit.forecast(FORECAST_DAYS)

    except:
        continue


    # Calculate statistics
    avg_daily_demand = demand.mean()

    demand_std = demand.std()

    historical_30d = demand.tail(30).sum()

    last_sale_date = demand.index.max()

    forecast_total = forecast.sum()

    demand_change_pct = (
        (forecast_total - historical_30d)
        / historical_30d
    ) * 100 if historical_30d > 0 else 0


    # Demand trend
    if demand_change_pct >= 10:
        trend = "Increasing"

    elif demand_change_pct <= -10:
        trend = "Declining"

    else:
        trend = "Stable"


    # Product info
    info = group.iloc[-1]


    # Create Future Dates
    future_dates = pd.date_range(
        last_sale_date + pd.Timedelta(days=1),
        periods=FORECAST_DAYS,
        freq="D"
    )


    # Create forecast rows
    for date, prediction in zip(future_dates, forecast):

        forecast_rows.append({

            "forecast_date": date,

            "product_id": product_id,

            "product_name": info["product_name"],

            "category_name": info["category_name"],

            "department_name": info["department_name"],

            "last_sale_date": last_sale_date,

            "avg_daily_demand": round(avg_daily_demand,2),

            "historical_30d_demand": int(historical_30d),

            "forecast_demand": max(round(prediction),0),

            "forecast_30d_total": round(forecast_total),

            "demand_change_pct": round(demand_change_pct,2),

            "demand_trend": trend,

            "forecast_method": "Holt-Winters"

        })
```

</details>

## 3. Demand Trend Segmentation

Forecast demand for the next 30 days is compared with the previous 30-day historical period.

Products are classified into three demand trend categories:

- **Increasing**
- **Stable**
- **Declining**

This segmentation helps planners quickly identify products that may require inventory expansion or reduction.

## 4. Inventory Optimization

<p align="center">
  <img src="3_reports/images/Page%202%20(Inventory%20Optimization).png" width="80%">
</p>

Forecast demand is combined with historical demand variability and supplier lead time to calculate key inventory planning metrics, including:

- Forecast Daily Demand
- Lead Time Demand
- Safety Stock
- Reorder Point

The Inventory Optimization dashboard summarizes these metrics while also presenting inventory prioritization through ABC–XYZ segmentation.

The original dataset does not include current inventory levels. Therefore, metrics such as **Inventory Status**, **Products to Reorder**, and **Days of Inventory** were excluded to ensure all reported metrics are fully supported by the available data.

## 5. ABC Classification

Products are classified according to their contribution to total demand.

- **A** – Highest inventory priority
- **B** – Medium inventory priority
- **C** – Lower inventory priority

Following the Pareto principle, a relatively small number of products contributes the majority of total demand and should receive the greatest management attention.


<details>
<summary><b>Click to View Python: ABC Classification</b></summary>

```python
# 2. Classify products into ABC categories


# Sort products by demand.
df = df.sort_values(
    "total_demand",
    ascending=False
).reset_index(drop=True)


# Demand percentage
df["demand_share_pct"] = (
    df["total_demand"]
    / df["total_demand"].sum()
) * 100


# Cumulative demand percentage
df["cumulative_share_pct"] = (
    df["demand_share_pct"]
    .cumsum()
)


# Classify products into ABC categories based on cumulative demand percentage
def classify_abc(x):

    if x <= 80:
        return "A"

    elif x <= 95:
        return "B"

    else:
        return "C"

df["ABC_Class"] = (
    df["cumulative_share_pct"]
    .apply(classify_abc)
)

df.head()
```

</details>

## 6. XYZ Classification

XYZ analysis measures historical demand variability using the **Coefficient of Variation (CV)**.

- **X** – Stable demand
- **Y** – Moderate variability
- **Z** – High variability

While ABC classification measures business importance, XYZ classification evaluates demand consistency, allowing planners to distinguish between predictable and highly variable products.

<details>
<summary><b>Click to View Python: XYZ Classification</b></summary>

```python
# 3. Classify products into XYZ categories


z_threshold = df["coefficient_of_variation"].quantile(0.90)

def classify_xyz(cv):

    if cv >= z_threshold:
        return "Z"
    
    elif cv >= 0.5:
        return "Y"
    
    else:
        return "X"
    
df["XYZ_Class"] = (df["coefficient_of_variation"].apply(classify_xyz))

df.head()
```

</details>

## 7. ABC–XYZ Inventory Segmentation

The final inventory planning dataset combines:

- Forecast Daily Demand
- Lead Time
- Lead Time Demand
- Safety Stock
- Reorder Point
- ABC Classification
- XYZ Classification
- ABC–XYZ Category

This combined approach enables inventory prioritization based on both product importance and demand stability, supporting more informed replenishment decisions.

---

# What I Learned

This project strengthened both my technical and business understanding of retail supply chain analytics.

### Technical skills strengthened

- Data preparation and feature engineering using PostgreSQL
- Building forecasting models with Holt-Winters Exponential Smoothing in Python
- Implementing Safety Stock and Reorder Point calculations
- Applying ABC and XYZ inventory segmentation techniques
- Designing interactive dashboards in Power BI
- Creating dynamic KPIs using DAX
- Integrating SQL, Python, and Power BI into a complete analytics workflow

### Business concepts reinforced

- Demand forecasting
- Inventory planning
- Lead Time Demand
- Safety Stock
- Reorder Point planning
- Inventory prioritization using ABC–XYZ segmentation
- Data-driven replenishment planning

---

# Key Insights

- Most products exhibit stable demand patterns, while a smaller group shows significant growth or decline.
- A relatively small group of products contributes the majority of total demand, reflecting the Pareto principle.
- High-demand categories are not always the fastest-growing categories, highlighting the importance of analyzing both demand volume and growth.
- Combining demand forecasting with ABC–XYZ classification enables inventory decisions based on both business importance and demand variability.
- Safety Stock and Reorder Point calculations transform forecast results into actionable inventory planning metrics that support proactive replenishment decisions.

---

# Conclusion

This project demonstrates how PostgreSQL, Python, and Power BI can be integrated into an end-to-end retail supply chain analytics workflow.

Rather than only reporting historical performance, the project applies statistical forecasting and inventory optimization techniques to support proactive, data-driven replenishment decisions.

By combining demand forecasting with ABC–XYZ inventory segmentation, the solution provides practical insights for prioritizing products, optimizing inventory levels, and improving supply chain planning.

Overall, this project showcases an end-to-end analytics workflow that integrates SQL, Python, and Power BI to solve a real-world retail inventory planning problem.
