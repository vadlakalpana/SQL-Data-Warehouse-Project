-- ============================================================
-- Advanced Analytics
-- Purpose: Analyze trends, performance, contribution, and
--          customer/product segmentation.
-- ============================================================


-- ============================================================
-- 1. Change Over Time (Trend Analysis)
-- ============================================================

-- Analyze sales, customers, and quantity by year and month
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Same analysis using formatted date (Year-Month)
SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%b')
ORDER BY DATE_FORMAT(order_date, '%Y-%b');


-- ============================================================
-- 2. Cumulative Analysis
-- ============================================================

-- Calculate yearly sales and running total over time
SELECT 
    order_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales
FROM (
    SELECT 
        YEAR(order_date) AS order_year,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
) t;


-- ============================================================
-- 3. Moving Average Analysis
-- ============================================================

-- Calculate yearly average sales and moving average over time
SELECT 
    order_year,
    avg_sales,
    AVG(avg_sales) OVER (ORDER BY order_year) AS moving_avg_sales
FROM (
    SELECT 
        YEAR(order_date) AS order_year,
        AVG(sales_amount) AS avg_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
) t;


-- ============================================================
-- 4. Performance Analysis
-- ============================================================

-- Analyze yearly product performance compared to:
-- 1) Overall average sales
-- 2) Previous year's sales
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
    order_year,
    product_name,
    current_total_sales,

    -- Compare with overall average sales
    AVG(current_total_sales) OVER () AS avg_sales,
    current_total_sales - AVG(current_total_sales) OVER () AS avg_diff,
    CASE 
        WHEN current_total_sales > AVG(current_total_sales) OVER () THEN 'Above Average'
        WHEN current_total_sales < AVG(current_total_sales) OVER () THEN 'Below Average'
        ELSE 'Average'
    END AS avg_performance,

    -- Compare with previous year's sales
    LAG(current_total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
    current_total_sales - LAG(current_total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_change,
    CASE 
        WHEN current_total_sales > LAG(current_total_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increased'
        WHEN current_total_sales < LAG(current_total_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decreased'
        ELSE 'No Change'
    END AS yearly_trend
FROM yearly_product_sales;


-- ============================================================
-- 5. Part-to-Whole Analysis
-- ============================================================

-- Find which product categories contribute most to total sales
WITH category_sales AS (
    SELECT 
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND(total_sales / SUM(total_sales) OVER () * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;


-- ============================================================
-- 6. Data Segmentation
-- ============================================================

-- Segment products based on cost ranges
USE DataWarehouse;

WITH product_segment AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;


-- ============================================================
-- 7. Customer Segmentation Based on Spending Behavior
-- ============================================================

/*
Customer Segments:
- VIP     : At least 12 months history and spending > 5000
- Regular : At least 12 months history and spending <= 5000
- New     : Less than 12 months history
*/

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spend,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spend > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;
