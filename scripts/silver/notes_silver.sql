-- quality check bronze tables to identify necessary transformations during load into silver layer

-- crm_cust_info

  -- check for nulls or duplicates in primary key
  -- expectation: no results

  SELECT
  cst_id,
  COUNT(*)
  FROM bronze.crm_cust_info
  GROUP BY cst_id
  HAVING COUNT(*) > 1 OR cst_id IS NULL

  -- check for unwanted spaces in string values
  -- expectation: no results

  SELECT cst_key
  FROM bronze.crm_cust_info
  WHERE cst_key != TRIM(cst_key)

  SELECT cst_firstname
  FROM bronze.crm_cust_info
  WHERE cst_firstname != TRIM(cst_firstname)
  
  SELECT cst_lastname
  FROM bronze.crm_cust_info
  WHERE cst_lastname != TRIM(cst_lastname)
  
  SELECT cst_marital_status
  FROM bronze.crm_cust_info
  WHERE cst_marital_status != TRIM(cst_marital_status)
  
  SELECT cst_gndr
  FROM bronze.crm_cust_info
  WHERE cst_gndr != TRIM(cst_gndr)

  -- check the consistency of values in low cardinality columns
  
  SELECT DISTINCT cst_marital_status
  FROM bronze.crm_cust_info
  
  SELECT DISTINCT cst_gndr
  FROM bronze.crm_cust_info

-- crm_prd_info

  -- check for nulls or duplicates in primary key
  -- expectation: no results

  SELECT
  prd_id,
  COUNT(*)
  FROM bronze.crm_prd_info
  GROUP BY prd_id
  HAVING COUNT(*) > 1 OR prd_id IS NULL

  -- check for unwanted spaces in string values
  -- expectation: no results

  SELECT prd_key
  FROM bronze.crm_prd_info
  WHERE prd_key != TRIM(prd_key)

  SELECT prd_nm
  FROM bronze.crm_prd_info
  WHERE prd_nm != TRIM(prd_nm)
  
  SELECT prd_line
  FROM bronze.crm_prd_info
  WHERE prd_line != TRIM(prd_line)

  -- check for nulls or negative numbers
  -- expectation: no results

  SELECT prd_cost
  FROM bronze.crm_prd_info
  WHERE prd_cost < 0 OR prd_cost IS NULL

  -- check the consistency of values in low cardinality columns
  
  SELECT DISTINCT prd_line
  FROM bronze.crm_prd_info

  -- check for invalid date orders 
  -- (end date must not be earlier than start date)

  SELECT *
  FROM bronze.crm_prd_info
  WHERE prd_end_dt < prd_start_dt

-- check tables we are joining as we write transformations
-- adjust ddl as needed (add columns, change datatypes, etc.)
-- for complex transformations in SQL, narrow it down to a specific example and brainstorm multiple solution approaches

-- after truncate + insert, quality check silver tables to verify quality of data in the silver layer
-- replace 'bronze' with 'silver'
