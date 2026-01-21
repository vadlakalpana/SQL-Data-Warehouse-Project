/*
---------------------------------------------------------------------------------------------------------------
Gold Layer Views Creation

This commit creates the core Gold layer views for the data warehouse, implementing a star schema design:

gold.dim_customers: Builds a customer dimension with surrogate keys, enriched demographic attributes, and cleaned gender logic.

gold.dim_products: Creates a product dimension with category, subcategory, cost, and product lifecycle attributes, filtering only active products.

gold.fact_sales: Constructs the sales fact table by linking transactional data to customer and product dimensions using surrogate keys.

These views provide a clean, analytics-ready semantic layer for reporting and business intelligence use cases.
----------------------------------------------------------------------------------------------------------------------
*/

-------------------------------------------------------------------------------------
CREATE VIEW gold.dim_customers AS 
SELECT DISTINCT
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_FirstName AS first_name,
ci.cst_LastName AS last_name,
la.cntry as country,
ci.cst_maritial_status AS marital_status,
CASE 
WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
ELSE COALESCE(ca.gen,'n/a')
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.c_id;

--------------------------------------------------------------------------------
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, 
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id As category_id,
pc.cat AS category,
pc.subcat As subcategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id=pc.id
WHERE prd_end_dt is null;

---------------------------------------------------------------------
CREATE VIEW gold.fact_sales AS
SELECT 
sd.sls_ord_num AS  order_number,
pr.product_key ,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS ship_date,
sd.sls_due_dt AS due_date,
sd.sls_sales As sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price Asprice
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON
TRIM(sd.sls_prd_key) = TRIM(pr.product_number)
LEFT JOIN gold.dim_customers cu
ON TRIM(sd.sls_cust_id) = TRIM(cu.customer_id);


