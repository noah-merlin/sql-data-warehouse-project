-- quality check bronze tables to identify necessary transformations during load into silver layer

-- crm_cust_info

  -- check for nulls or duplicates in primary key
    -- cst_id
  -- expectation: no results

  SELECT
  cst_id,
  COUNT(*)
  FROM bronze.crm_cust_info
  GROUP BY cst_id
  HAVING COUNT(*) > 1 OR cst_id IS NULL

  -- check for unwanted spaces in string values
    -- cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr
  -- expectation: no results

  SELECT cst_key
  FROM bronze.crm_cust_info
  WHERE cst_key != TRIM(cst_key)

  -- check the consistency of values in low cardinality columns
    -- cst_marital_status, cst_gndr
  
  SELECT DISTINCT cst_marital_status
  FROM bronze.crm_cust_info

-- crm_prd_info

  -- check for nulls or duplicates in primary key
    -- prd_id
  -- expectation: no results

  SELECT
  prd_id,
  COUNT(*)
  FROM bronze.crm_prd_info
  GROUP BY prd_id
  HAVING COUNT(*) > 1 OR prd_id IS NULL

  -- check for unwanted spaces in string values
    -- prd_key, prd_nm, prd_line
  -- expectation: no results

  SELECT prd_key
  FROM bronze.crm_prd_info
  WHERE prd_key != TRIM(prd_key)

  -- check for nulls or negative numbers
    -- prd_cost
  -- expectation: no results

  SELECT prd_cost
  FROM bronze.crm_prd_info
  WHERE prd_cost < 0 OR prd_cost IS NULL

  -- check the consistency of values in low cardinality columns
    -- prd_line
  
  SELECT DISTINCT prd_line
  FROM bronze.crm_prd_info

  -- check for invalid date orders 
  -- (end date must not be earlier than start date)

  SELECT *
  FROM bronze.crm_prd_info
  WHERE prd_end_dt < prd_start_dt

-- crm_sales_details

  -- check for nulls in primary keys (duplicates expected for sales data)
    -- sls_prd_key, sls_cust_id
  -- expectation: no results

  SELECT sls_prd_key
  FROM bronze.crm_sales_details
  GROUP BY sls_prd_key
  HAVING sls_prd_key IS NULL

  -- check integrity of primary keys as they relate to other tables
  
  SELECT sls_prd_key
  FROM bronze.crm_sales_details
  WHERE sls_prd_key NOT IN (
  	SELECT prd_key FROM silver.crm_prd_info)
  
  SELECT sls_cust_id
  FROM bronze.crm_sales_details
  WHERE sls_cust_id NOT IN (
  	SELECT cst_id FROM silver.crm_cust_info)

  -- check for unwanted spaces in string values
    -- sls_ord_num, sls_prd_key
  -- expectation: no results

  SELECT sls_ord_num
  FROM bronze.crm_sales_details
  WHERE sls_ord_num != TRIM(sls_ord_num)

  -- check for nulls or negative numbers
    -- sls_cust_id
  -- expectation: no results

  SELECT sls_cust_id
  FROM bronze.crm_sales_details
  WHERE sls_cust_id < 0 OR sls_cust_id IS NULL
    
  -- check for invalid dates
    -- sls_order_dt, sls_ship_dt, sls_due_dt
  -- (negative numbers or 0s can't be cast to a date)
  -- (in this scenario, length of date must be 8)
  -- (check for outliers by validating the boundaries of the date range)

  SELECT sls_order_dt
  -- NULLIF(sls_order_dt, 0) AS sls_order_dt - convert 0s to NULL
  FROM bronze.crm_sales_details
  WHERE sls_order_dt <= 0 
	OR  LEN(sls_order_dt) != 8
	OR  sls_order_dt < 19000101 -- business start date
	OR  sls_order_dt > 20500101 -- future date (case by case)

  -- check for invalid date orders
  -- (order date must always be before the shipping or due date)

  SELECT *
  FROM bronze.crm_sales_details
  WHERE sls_order_dt > sls_ship_dt
	OR  sls_order_dt > sls_due_dt
  
  -- business rule: sales = quantity * price
  -- negative, 0, NULL not allowed
	  -- sls_sales, sls_quantity, sls_price

  SELECT *
  FROM bronze.crm_sales_details
  WHERE sls_sales != sls_quantity * sls_price

  SELECT *
  FROM bronze.crm_sales_details
  WHERE sls_sales <= 0
	OR sls_sales IS NULL


-- check tables we are joining as we write transformations
-- adjust ddl as needed (add columns, change datatypes, etc.)
-- for complex transformations in SQL, narrow it down to a specific example and brainstorm multiple solution approaches

-- after truncate + insert, quality check silver tables to verify quality of data in the silver layer
-- replace 'bronze' with 'silver'
