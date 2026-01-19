/*
====================================================================================================================
Successfully loaded data from two source files into six Bronze layer tables according to the defined DDL structures. 

The loading process includes data type validation, handling of invalid or missing values by converting them to NULL, 
  and enforcement of schema integrity.
                 -------------------------------------------------------------
This ensures accurate raw data ingestion while maintaining consistency with source formats and preparing 
    the data for downstream transformation in the Silver and Gold layers.

===================================================================================================================
*/


SELECT'Start Time Bronze Layer--------';
SET @Batch_start_time=NOW();

SELECT '-------------------------------------------------------------';
SELECT 'Loading Data to CRM Tables';
SELECT '-------------------------------------------------------------';


SELECT '>> Truncating table bronze.crm_cust_info ';
SELECT'>> Inserting Data into bronze.crm_cust_info';
SELECT'Start Time--------';
SET @start_time=NOW();
TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@cst_id, cst_key, @cst_FirstName, @cst_Lastname,cst_maritial_status,cst_gndr,@cst_create_date)
SET
cst_id = IF(@cst_id REGEXP '^[0-9]+$', @cst_id, NULL),
cst_FirstName = NULLIF(@cst_FirstName, ''),
cst_LastName = NULLIF(@cst_LastName, ''),
cst_create_date = IF(@cst_create_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}',
			   STR_TO_DATE(@cst_create_date, '%Y-%m-%d'),
			   NULL);
SELECT 'END Time------------------';
SET @End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS load_time_seconds;


#select count(*) from  bronze.crm_cust_info;
# Loading the second crm file
SELECT'Start Time--------';
SET @start_time=NOW();
SELECT '>> Truncating table bronze.crm_prd_info ';
TRUNCATE TABLE bronze.crm_prd_info;
SELECT'>> Inserting Data into bronze.crm_prd_info';
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@prd_id, prd_key, prd_nm, @prd_cost,prd_line,@prd_Start_dt,@prd_End_dt)
SET
prd_id = IF(@prd_id REGEXP '^[0-9]+$', @prd_id, NULL),
prd_cost=IF(@prd_cost REGEXP '^[0-9]+$',@prd_cost, NULL),
prd_Start_dt = IF(
  @prd_Start_dt REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$',
  STR_TO_DATE(@prd_Start_dt, '%Y-%m-%d %H:%i:%s'),
  NULL),
prd_End_dt = IF(
  @prd_End_dt REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$',
  STR_TO_DATE(@prd_End_dt, '%Y-%m-%d %H:%i:%s'),
  NULL
);
SELECT 'END Time------------------';
SET @End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS load_time_seconds;

SELECT'Start Time--------';
SET @start_time=NOW();
SELECT '>> Truncating table bronze.crm_sales_details ';
TRUNCATE TABLE bronze.crm_sales_details;

SELECT'>> Inserting Data into bronze.crm_sales_details';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@sls_ord_num,sls_prd_Key,sls_cust_id,sls_order_dt, sls_ship_dt,sls_due_dt,@sls_sales,sls_quantity,@sls_price)
SET
sls_ord_num = IF(@sls_ord_num REGEXP '^[0-9]+$', @sls_ord_num, NULL),
sls_sales = IF(@sls_sales REGEXP '^[0-9]+$', @sls_sales, NULL),
sls_price=IF(@sls_price REGEXP '^[0-9]+$',@sls_price, NULL);
SELECT 'END Time------------------';
SET @End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS load_time_seconds;

SELECT '-------------------------------------------------------------';
SELECT 'Loading Data to ERP Tables';
SELECT '-------------------------------------------------------------';

SELECT '>> Truncating table bronze.erp_cust_az12 ';
TRUNCATE TABLE bronze.erp_cust_az12;

SELECT'>> Inserting Data into bronze.erp_cust_az12';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@cid,@bdate,@gen)
SET
cid = IF(@cid REGEXP '^[0-9]+$', @cid, NULL),
bdate = IF(@bdate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}',
			   STR_TO_DATE(@bdate, '%Y-%m-%d'),
			   NULL),
gen = IF(@gen REGEXP '^[0-9]+$', @gen, NULL);
SELECT 'END Time------------------';
SET @End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS load_time_seconds;

SELECT'Start Time--------';
SET @start_time=NOW();
SELECT '>> Truncating table  bronze.erp_loc_a101 ';
TRUNCATE TABLE bronze.erp_loc_a101;

SELECT'>> Inserting Data into bronze.erp_loc_a101';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SELECT 'END Time------------------';
SET @End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS load_time_seconds;

SELECT'Start Time--------';
SET @start_time=NOW();
SELECT '>> Truncating table  bronze.erp_px_cat_g1v2 ';
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT'>> Inserting Data into bronze.erp_px_cat_g1v2';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT 'END Time------------------';
SET @End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS load_time_seconds;

SELECT 'END Time BronZe layer------------------';
SET @Batch_End_time=NOW();
SELECT TIMESTAMPDIFF(SECOND, @Batch_start_time, @Batch_End_time) AS load_time_seconds_Bronze;
