-- =========================================================
-- Procedure Name : silver.load_silver
-- Purpose        : Load and transform data from Bronze layer
--                  into Silver layer tables.
-- Description    :
--   1. Deduplicates customer records based on latest create date.
--   2. Standardizes product keys, categories, and product lines.
--   3. Cleans and converts sales date fields and recalculates
--      sales and price values where required.
--   4. Cleans ERP customer, location, and product category data.
--   5. Ensures consistent, analytics-ready data in Silver layer.
--
-- Author         : Kalpana Vadla
-- Created On     : 20-Jan-2026
-- =========================================================



DELIMITER &&
DROP PROCEDURE IF EXISTS silver.load_silver &&
CREATE PROCEDURE silver.load_silver()
BEGIN
	TRUNCATE TABLE  silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info
	(
	cst_id,
	cst_key,
	cst_FirstName,
	cst_LastName,
	cst_maritial_status,
	cst_gndr,
	cst_create_date
	)
	SELECT cst_id,
		   cst_key,
		   TRIM(cst_FirstName) as cst_FirstName,
		   TRIM(cst_LastName) as cst_LastName,
		   CASE WHEN UPPER(TRIM(cst_maritial_status))='S' THEN 'Single'
				WHEN UPPER(TRIM(cst_maritial_status)) ='M' THEN 'Married'
		   ELSE 'N/A'
		   END cst_maritial_status,
		   CASE WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'Male'
		   ELSE 'N/A'
		   END cst_gndr,
		   cst_create_date
	FROM
	(
	SELECT * ,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_latest
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT  NULL
	)t
	WHERE flag_latest=1;


	# Transforming the table 2
	TRUNCATE TABLE  silver.crm_prd_info;
	INSERT INTO silver.crm_prd_info
	(prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	SELECT prd_id,
	REPLACE(LEFT (TRIM(prd_key),5),'-','_') as cat_id,
	RIGHT (TRIM(prd_key),7) as prd_key,
	TRIM(prd_nm) as prd_nm,
	IFNULL(prd_cost,0) as prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'T' THEN 'Touring'
		WHEN 'S' THEN 'Other Sales'
		ELSE 'N/A'
		END as prd_line,
	CAST(prd_start_dt AS DATE) as prd_start_dt,
	CAST(
			DATE_SUB(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
				INTERVAL 1 DAY
			) AS DATE
		) AS prd_end_dt 
	FROM bronze.crm_prd_info;

	# Transforming the Table 3
	TRUNCATE TABLE  silver.crm_sales_details;
	INSERT INTO silver.crm_sales_details
	(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)
	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt =0 OR LENGTH(sls_order_dt)!=8 THEN null
		 ELSE STR_TO_DATE(TRIM(sls_order_dt), '%Y%m%d')
		 END AS sls_order_dt,
	CASE WHEN sls_ship_dt =0 OR LENGTH(sls_ship_dt)!=8 THEN null
		 ELSE STR_TO_DATE(TRIM(sls_ship_dt), '%Y%m%d')
		 END AS sls_ship_dt,
	CASE WHEN sls_due_dt =0 OR LENGTH(sls_due_dt)!=8 THEN null
		 ELSE STR_TO_DATE(TRIM(sls_due_dt), '%Y%m%d')
		 END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_sales= sls_quantity * ABS(sls_price)
	 ELSE sls_sales
	 END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <=0  
	 THEN sls_price= sls_sales / NULLIF(sls_quantity,0)
	 ELSE sls_price
	 END AS sls_price
	FROM bronze.crm_sales_details;

	# Transforming the table 4
	TRUNCATE TABLE  silver.erp_cust_az12;
	INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
	SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
	  ELSE cid
	END AS cid,
	CASE WHEN bdate > NOW() THEN NULL
		 ELSE bdate
		 END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
		 ELSE 'N/A'
		 END AS gen
	FROM bronze.erp_cust_az12;

	# Transforming the table 5
	TRUNCATE TABLE silver.erp_loc_a101;
	INSERT INTO silver.erp_loc_a101(c_id,cntry)
	SELECT 
	REPLACE(c_id,'-','') as c_id,
	CASE WHEN TRIM(cntry)='DE' Then 'Gerrmany'
		 WHEN TRIM(cntry) IN('US','USA') THEN 'United States'
		 WHEN TRIM(cntry)='' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
		 END AS cntry
	FROM bronze.erp_loc_a101;

	# Transforming the table 6
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	INSERT INTO silver.erp_px_cat_g1v2
	(id,cat,subcat,maintenance)
	SELECT
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_px_cat_g1v2;
END &&
Delimiter ;


CALL silver.load_silver();



