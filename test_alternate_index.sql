-- =====================================================================
-- TEST FILE: test_alternate_index.sql
-- PURPOSE: Validate alternate index creation and usage
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 150
SET PAGESIZE 50

PROMPT =====================================================================
PROMPT TEST SUITE: Alternate Indexes
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify Index Creation
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Index Existence ======

SELECT index_name, table_name, status
FROM user_indexes
WHERE index_name IN ('IDX_HOUSETASK_HOUSE_STAGE', 
                     'IDX_SALE_EMPLOYEE_DATE',
                     'IDX_DECORATOR_CHOICE_SESSION')
ORDER BY table_name, index_name;

PROMPT Expected: 3 rows with STATUS = VALID
PROMPT 

-- =====================================================================
-- Test 2: Verify Index Structure
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Verify Column Order ======

SELECT index_name, column_name, column_position
FROM user_ind_columns
WHERE index_name IN ('IDX_HOUSETASK_HOUSE_STAGE', 
                     'IDX_SALE_EMPLOYEE_DATE',
                     'IDX_DECORATOR_CHOICE_SESSION')
ORDER BY index_name, column_position;

PROMPT 

-- =====================================================================
-- Test 3: Construction Query
-- =====================================================================
PROMPT 
PROMPT ====== Test 3: Construction Manager Query ======

SELECT housetask_id, stage, plannedstart, plannedend
FROM housetask
WHERE house_house_id = 8006
  AND stage = 1;

PROMPT 

-- =====================================================================
-- Test 4: Sales Query
-- =====================================================================
PROMPT 
PROMPT ====== Test 4: Employee Sales Report ======

SELECT employee_employee_id, 
       COUNT(*) AS num_sales,
       SUM(escrowdeposit) AS total_deposits
FROM sale
WHERE employee_employee_id IN (26001, 26002, 26003)
  AND "Date" >= DATE '2025-01-01'
GROUP BY employee_employee_id
ORDER BY employee_employee_id;

PROMPT 

-- =====================================================================
-- Test 5: Decorator Query
-- =====================================================================
PROMPT 
PROMPT ====== Test 5: Decorator Session Summary ======

SELECT decoratorchoice_id, item, price
FROM decorator_choice
WHERE decorator_session_id = 14001;

SELECT SUM(price) AS session_total
FROM decorator_choice
WHERE decorator_session_id = 14001;

PROMPT 

-- =====================================================================
-- Test 6: Execution Plan
-- =====================================================================
PROMPT 
PROMPT ====== Test 6: Execution Plan Check ======

SET AUTOTRACE ON EXPLAIN

SELECT housetask_id, stage
FROM housetask
WHERE house_house_id = 8006
  AND stage = 1;

SET AUTOTRACE OFF

PROMPT Expected: INDEX RANGE SCAN on IDX_HOUSETASK_HOUSE_STAGE
PROMPT 

SET TIMING OFF

PROMPT 
PROMPT =====================================================================
PROMPT TEST COMPLETE
PROMPT =====================================================================