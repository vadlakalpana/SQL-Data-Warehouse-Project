/*
=========================================================
 Silver Layer Table Creation Script
=========================================================

Purpose:
---------
This script builds the Silver layer tables in the data warehouse.
The Silver layer stores cleaned, standardized, and business-ready
data transformed from the Bronze (raw) layer.

Key Features:
--------------
• Drops existing Silver tables to allow idempotent re-runs.
• Creates structured, typed tables for CRM and ERP domains.
• Applies consistent naming conventions.
• Includes a data warehouse audit column (dwh_create_date) to track
  when each record was loaded into the Silver layer.

Tables Created:
----------------
1. silver.crm_cust_info
   - Stores cleaned customer master data.
   - Standardizes names, gender, marital status, and dates.

2. silver.crm_prd_info
   - Stores product master data.
   - Includes category extraction, pricing, lifecycle dates, and product lines.

3. silver.crm_sales_details
   - Stores transactional sales data.
   - Contains order, shipping, due dates, quantities, pricing, and revenue.

4. silver.erp_loc_a101
   - Stores standardized customer location and country information.

5. silver.erp_cust_az12
   - Stores customer demographic data including birth date and gender.

Audit Column:
--------------
All tables include:
   dwh_create_date DATETIME DEFAULT NOW()
to capture the record creation timestamp in the warehouse.

This layer prepares trusted, high-quality data for downstream Gold layer
analytics, reporting, and business intelligence use cases.
=========================================================
*/




# Building the silver layer
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info
(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_FirstName VARCHAR(50),
	cst_LastName VARCHAR(50),
	cst_maritial_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE,
    dwh_create_date DATETIME default now()
);

DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info
(
	prd_id INT,
	cat_id VARCHAR(50),
    prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_Start_dt DATE,
	prd_End_dt DATE,
    dwh_create_date DATETIME default now()
);

DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details
(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_Cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
    dwh_create_date DATETIME default now()
);

DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101(
	c_id VARCHAR(50),
	cntry VARCHAR(50),
    dwh_create_date DATETIME default now()
);

DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12
(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50),
    dwh_create_date DATETIME default now()
);
