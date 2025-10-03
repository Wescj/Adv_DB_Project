-- =====================================================================
-- TEST FILE: test_alternate_index.sql
-- PURPOSE: Validate alternate index creation and usage
-- TESTS: Index existence, structure, and execution plan usage
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
-- Test 1: Verify All Indexes Exist
-- =====================================================================
-- Purpose: Confirm all three indexes were created successfully
-- Expected: 3 rows, all with STATUS = VALID
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Index Existence ======

SELECT index_name, table_name, uniqueness, status
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
-- Purpose: Confirm correct columns and column order for each index
-- Expected: Correct columns in proper sequence
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Verify Index Column Structure ======

SELECT index_name, column_name, column_position
FROM user_ind_columns
WHERE index_name IN ('IDX_HOUSETASK_HOUSE_STAGE', 
                     'IDX_SALE_EMPLOYEE_DATE',
                     'IDX_DECORATOR_CHOICE_SESSION')
ORDER BY index_name, column_position;

PROMPT Expected column order:
PROMPT - IDX_HOUSETASK_HOUSE_STAGE: (1) HOUSE_HOUSE_ID, (2) STAGE
PROMPT - IDX_SALE_EMPLOYEE_DATE: (1) EMPLOYEE_EMPLOYEE_ID, (2) Date
PROMPT - IDX_DECORATOR_CHOICE_SESSION: (1) DECORATOR_SESSION_ID, (2) PRICE
PROMPT 

-- =====================================================================
-- Test 3: Query Using idx_housetask_house_stage
-- =====================================================================
-- Purpose: Test typical construction manager query pattern
-- Expected: Fast execution, uses index
-- =====================================================================
PROMPT 
PROMPT ====== Test 3: Construction Manager Query ======
PROMPT Query: Find all stage 1 tasks for house 8006

SELECT housetask_id, stage, plannedstart, plannedend, notes
FROM housetask
WHERE house_house_id = 8006
  AND stage = 1
ORDER BY plannedstart;

PROMPT Expected: Should return tasks for house 8006 at stage 1
PROMPT 

-- =====================================================================
-- Test 4: Query Using idx_sale_employee_date
-- =====================================================================
-- Purpose: Test sales performance report pattern
-- Expected: Fast execution, uses index
-- =====================================================================
PROMPT 
PROMPT ====== Test 4: Employee Sales Report ======
PROMPT Query: Sales by employee for date range

SELECT employee_employee_id, 
       COUNT(*) AS num_sales,
       TO_CHAR(SUM(escrowdeposit), '$999,999,999.99') AS total_deposits
FROM sale
WHERE employee_employee_id IN (26001, 26002, 26003)
  AND "Date" >= DATE '2025-01-01'
GROUP BY employee_employee_id
ORDER BY employee_employee_id;

PROMPT Expected: Summary of sales by employee
PROMPT 

-- =====================================================================
-- Test 5: Query Using idx_decorator_choice_session
-- =====================================================================
-- Purpose: Test decorator session lookup pattern
-- Expected: Fast execution, uses index for aggregation
-- =====================================================================
PROMPT 
PROMPT ====== Test 5: Decorator Session Summary ======
PROMPT Query: All choices and total for session 14001

SELECT decoratorchoice_id, item, 
       TO_CHAR(price, '$999,999.99') AS price
FROM decorator_choice
WHERE decorator_session_id = 14001;

SELECT TO_CHAR(SUM(price), '$999,999.99') AS session_total
FROM decorator_choice
WHERE decorator_session_id = 14001;

PROMPT Expected: List of choices and total price for session
PROMPT 

-- =====================================================================
-- Test 6: Execution Plan Check
-- =====================================================================
-- Purpose: Verify optimizer is using the indexes
-- Expected: INDEX RANGE SCAN operations (not FULL TABLE SCAN)
-- =====================================================================
PROMPT 
PROMPT ====== Test 6: Execution Plan Analysis ======
PROMPT Checking if optimizer uses idx_housetask_house_stage...

SET AUTOTRACE ON EXPLAIN

SELECT housetask_id, stage
FROM housetask
WHERE house_house_id = 8006
  AND stage = 1;

SET AUTOTRACE OFF

PROMPT Expected: Execution plan should show INDEX RANGE SCAN
PROMPT           on IDX_HOUSETASK_HOUSE_STAGE
PROMPT 

-- =====================================================================
-- Test 7: Index Statistics
-- =====================================================================
-- Purpose: Review basic index health metrics
-- Expected: Reasonable values for leaf_blocks and clustering_factor
-- =====================================================================
PROMPT 
PROMPT ====== Test 7: Index Statistics ======

SELECT index_name, 
       num_rows AS table_rows,
       distinct_keys,
       leaf_blocks,
       clustering_factor,
       status
FROM user_indexes
WHERE index_name IN ('IDX_HOUSETASK_HOUSE_STAGE', 
                     'IDX_SALE_EMPLOYEE_DATE',
                     'IDX_DECORATOR_CHOICE_SESSION')
ORDER BY index_name;

PROMPT Review: 
PROMPT - STATUS should be VALID
PROMPT - CLUSTERING_FACTOR should be relatively low (good data locality)
PROMPT 

SET TIMING OFF

PROMPT 
PROMPT =====================================================================
PROMPT TEST SUMMARY
PROMPT =====================================================================
PROMPT All 7 tests completed. Review results above:
PROMPT 1. Index existence - All 3 indexes should exist with VALID status
PROMPT 2. Index structure - Verify correct column order
PROMPT 3. Construction query - Should return house 8006 tasks
PROMPT 4. Sales report - Should show employee sales summary
PROMPT 5. Decorator session - Should show choices and total
PROMPT 6. Execution plan - Should use INDEX RANGE SCAN
PROMPT 7. Statistics - Indexes should be healthy (VALID status)
PROMPT =====================================================================