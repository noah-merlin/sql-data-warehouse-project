-- quality check bronze tables to identify necessary transformations during load into silver layer

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

-- after, quality check silver tables to verify quality of data in the silver layer
