-- =====================================================================
-- TEST FILE: test_denormalization.sql
-- PURPOSE: Validate denormalization of sale.total_contract_price
-- TESTS: Accuracy, trigger functionality, and performance
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 150
SET PAGESIZE 50

PROMPT =====================================================================
PROMPT TEST SUITE: Denormalization - sale.total_contract_price
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify Column Exists
-- =====================================================================
-- Purpose: Confirm the denormalized column was added successfully
-- Expected: One row showing TOTAL_CONTRACT_PRICE column
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Column Existence ======

SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'SALE'
  AND column_name = 'TOTAL_CONTRACT_PRICE';

PROMPT Expected: 1 row with NUMBER(12,2) data type
PROMPT 

-- =====================================================================
-- Test 2: Accuracy Verification
-- =====================================================================
-- Purpose: Compare stored denormalized values vs. calculated values
-- Expected: All values should match (difference = 0.00)
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Accuracy Verification ======

SELECT s.sale_id,
       s.house_house_id,
       s.total_contract_price AS stored_value,
       fn_house_total_price(s.house_house_id) AS calculated_value,
       ROUND(s.total_contract_price - fn_house_total_price(s.house_house_id), 2) AS difference
FROM sale s
ORDER BY s.sale_id;

PROMPT Expected: All differences should be 0.00
PROMPT 

-- Automated accuracy check with summary
DECLARE
  v_total_sales NUMBER;
  v_accurate_sales NUMBER;
  v_max_diff NUMBER;
BEGIN
  SELECT COUNT(*),
         SUM(CASE WHEN ABS(s.total_contract_price - fn_house_total_price(s.house_house_id)) < 0.01 
                  THEN 1 ELSE 0 END),
         NVL(MAX(ABS(s.total_contract_price - fn_house_total_price(s.house_house_id))), 0)
  INTO v_total_sales, v_accurate_sales, v_max_diff
  FROM sale s;

  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('ACCURACY TEST SUMMARY');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('Total sales records: ' || v_total_sales);
  DBMS_OUTPUT.PUT_LINE('Accurate records: ' || v_accurate_sales);
  DBMS_OUTPUT.PUT_LINE('Accuracy rate: ' || ROUND(v_accurate_sales/v_total_sales * 100, 2) || '%');
  DBMS_OUTPUT.PUT_LINE('Max difference: -- =====================================================================
-- TEST FILE: test_denormalization.sql
-- PURPOSE: Validate denormalization of sale.total_contract_price
-- TESTS: Accuracy, trigger functionality, and performance
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 150
SET PAGESIZE 50

PROMPT =====================================================================
PROMPT TEST SUITE: Denormalization - sale.total_contract_price
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify Column Exists
-- =====================================================================
-- Purpose: Confirm the denormalized column was added successfully
-- Expected: One row showing TOTAL_CONTRACT_PRICE column
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Column Existence ======

SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'SALE'
  AND column_name = 'TOTAL_CONTRACT_PRICE';

PROMPT Expected: 1 row with NUMBER(12,2) data type
PROMPT 

-- =====================================================================
-- Test 2: Accuracy Verification
-- =====================================================================
-- Purpose: Compare stored denormalized values vs. calculated values
-- Expected: All values should match (difference = 0.00)
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Accuracy Verification ======

SELECT s.sale_id,
       s.house_house_id,
       s.total_contract_price AS stored_value,
       fn_house_total_price(s.house_house_id) AS calculated_value,
       ROUND(s.total_contract_price - fn_house_total_price(s.house_house_id), 2) AS difference
FROM sale s
ORDER BY s.sale_id;

PROMPT Expected: All differences should be 0.00
PROMPT 

-- Automated accuracy check with summary
DECLARE
  v_total_sales NUMBER;
  v_accurate_sales NUMBER;
  v_max_diff NUMBER;
BEGIN
  SELECT COUNT(*),
         SUM(CASE WHEN ABS(s.total_contract_price - fn_house_total_price(s.house_house_id)) < 0.01 
                  THEN 1 ELSE 0 END),
         NVL(MAX(ABS(s.total_contract_price - fn_house_total_price(s.house_house_id))), 0)
  INTO v_total_sales, v_accurate_sales, v_max_diff
  FROM sale s;

  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('ACCURACY TEST SUMMARY');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('Total sales records: ' || v_total_sales);
  DBMS_OUTPUT.PUT_LINE('Accurate records: ' || v_accurate_sales);
  DBMS_OUTPUT.PUT_LINE(' || ROUND(v_max_diff, 2));
  DBMS_OUTPUT.PUT_LINE('');

  IF v_accurate_sales = v_total_sales THEN
    DBMS_OUTPUT.PUT_LINE('RESULT: PASS - All values accurate');
  ELSE
    DBMS_OUTPUT.PUT_LINE('RESULT: FAIL - ' || (v_total_sales - v_accurate_sales) || ' discrepancies found');
  END IF;
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- =====================================================================
-- Test 3: Trigger Test - Auto-calculation on INSERT
-- =====================================================================
-- Purpose: Verify trigger auto-populates price on new sale insert
-- Expected: total_contract_price should be calculated automatically
-- =====================================================================
PROMPT 
PROMPT ====== Test 3: Trigger Test - INSERT ======

-- Insert test sale (price column not specified)
INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, 
                  estimatedcompletion, receivedsubdivision, 
                  receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, 
                  employee_employee_id, house_house_id, bank_worker_worker_id)
VALUES (99001, SYSDATE, 'Mortgage', 50000, DATE '2026-12-01',
        'Y', 'Y', 'Y', 24001, 28001, 26001, 8003, 32001);

COMMIT;

-- Verify auto-calculation worked
SELECT sale_id, 
       house_house_id,
       total_contract_price AS auto_calculated,
       fn_house_total_price(house_house_id) AS expected_value,
       CASE 
         WHEN ABS(total_contract_price - fn_house_total_price(house_house_id)) < 0.01 
         THEN 'PASS' 
         ELSE 'FAIL' 
       END AS test_result
FROM sale
WHERE sale_id = 99001;

PROMPT Expected: test_result = PASS
PROMPT 

-- Cleanup test data
DELETE FROM sale WHERE sale_id = 99001;
COMMIT;

-- =====================================================================
-- Test 4: Performance Comparison
-- =====================================================================
-- Purpose: Compare query speed: denormalized vs. calculated
-- Expected: Denormalized query should be significantly faster
-- =====================================================================
PROMPT 
PROMPT ====== Test 4: Performance Benchmark ======
PROMPT Running 100 iterations of each query type...
PROMPT 

DECLARE
  v_time_denorm NUMBER;
  v_time_calc NUMBER;
  v_price NUMBER;
  v_start NUMBER;
  v_end NUMBER;
BEGIN
  -- Benchmark 1: Query using denormalized column
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..100 LOOP
    SELECT total_contract_price
    INTO v_price
    FROM sale
    WHERE sale_id = 34001;
  END LOOP;
  v_end := DBMS_UTILITY.GET_TIME;
  v_time_denorm := v_end - v_start;

  -- Benchmark 2: Query using calculated function
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..100 LOOP
    SELECT fn_house_total_price(house_house_id)
    INTO v_price
    FROM sale
    WHERE sale_id = 34001;
  END LOOP;
  v_end := DBMS_UTILITY.GET_TIME;
  v_time_calc := v_end - v_start;

  -- Display results
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PERFORMANCE BENCHMARK (100 runs)');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('Denormalized query: ' || v_time_denorm || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('Calculated query:   ' || v_time_calc || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('');
  
  IF v_time_calc > 0 AND v_time_denorm < v_time_calc THEN
    DBMS_OUTPUT.PUT_LINE('Speedup: ' || ROUND(v_time_calc / v_time_denorm, 2) || 'x faster');
    DBMS_OUTPUT.PUT_LINE('Improvement: ' || ROUND((1 - v_time_denorm/v_time_calc) * 100, 1) || '%');
    DBMS_OUTPUT.PUT_LINE('RESULT: PASS - Denormalized is faster');
  ELSIF v_time_denorm = v_time_calc THEN
    DBMS_OUTPUT.PUT_LINE('RESULT: INCONCLUSIVE - Times are equal (dataset may be too small)');
  ELSE
    DBMS_OUTPUT.PUT_LINE('RESULT: FAIL - Calculated is faster (unexpected)');
  END IF;
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- =====================================================================
-- Test 5: Business Query Example
-- =====================================================================
-- Purpose: Demonstrate real-world usage of denormalized column
-- Expected: Query executes quickly and uses denormalized value
-- =====================================================================
PROMPT 
PROMPT ====== Test 5: Business Query - Revenue by Subdivision ======

SELECT 
    sd.name AS subdivision,
    COUNT(s.sale_id) AS num_sales,
    TO_CHAR(SUM(s.total_contract_price), '$999,999,999.99') AS total_revenue,
    TO_CHAR(AVG(s.total_contract_price), '$999,999,999.99') AS avg_sale_price
FROM subdivision sd
LEFT JOIN lot l ON sd.subdivision_id = l.subdivision_subdivision_id
LEFT JOIN house h ON l.lot_id = h.lot_lot_id
LEFT JOIN sale s ON h.house_id = s.house_house_id
GROUP BY sd.name
ORDER BY SUM(s.total_contract_price) DESC NULLS LAST;

PROMPT Expected: Fast execution using denormalized column
PROMPT 

SET TIMING OFF

PROMPT 
PROMPT =====================================================================
PROMPT TEST SUMMARY
PROMPT =====================================================================
PROMPT All 5 tests completed. Review results above:
PROMPT 1. Column exists - Should show NUMBER(12,2) type
PROMPT 2. Accuracy - All differences should be 0.00
PROMPT 3. Trigger INSERT - Should auto-populate and PASS
PROMPT 4. Performance - Denormalized should be faster
PROMPT 5. Business query - Should execute efficiently
PROMPT =====================================================================
-- =====================================================================
-- TEST FILE: test_denormalization.sql
-- PURPOSE: Validate denormalization of sale.total_contract_price
-- TESTS: Accuracy, trigger functionality, and performance
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 150
SET PAGESIZE 50

PROMPT =====================================================================
PROMPT TEST SUITE: Denormalization - sale.total_contract_price
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify Column Exists
-- =====================================================================
-- Purpose: Confirm the denormalized column was added successfully
-- Expected: One row showing TOTAL_CONTRACT_PRICE column
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Column Existence ======

SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'SALE'
  AND column_name = 'TOTAL_CONTRACT_PRICE';

PROMPT Expected: 1 row with NUMBER(12,2) data type
PROMPT 

-- =====================================================================
-- Test 2: Accuracy Verification
-- =====================================================================
-- Purpose: Compare stored denormalized values vs. calculated values
-- Expected: All values should match (difference = 0.00)
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Accuracy Verification ======

SELECT s.sale_id,
       s.house_house_id,
       s.total_contract_price AS stored_value,
       fn_house_total_price(s.house_house_id) AS calculated_value,
       ROUND(s.total_contract_price - fn_house_total_price(s.house_house_id), 2) AS difference
FROM sale s
ORDER BY s.sale_id;

PROMPT Expected: All differences should be 0.00
PROMPT 

-- Automated accuracy check with summary
DECLARE
  v_total_sales NUMBER;
  v_accurate_sales NUMBER;
  v_max_diff NUMBER;
BEGIN
  SELECT COUNT(*),
         SUM(CASE WHEN ABS(s.total_contract_price - fn_house_total_price(s.house_house_id)) < 0.01 
                  THEN 1 ELSE 0 END),
         NVL(MAX(ABS(s.total_contract_price - fn_house_total_price(s.house_house_id))), 0)
  INTO v_total_sales, v_accurate_sales, v_max_diff
  FROM sale s;

  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('ACCURACY TEST SUMMARY');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('Total sales records: ' || v_total_sales);
  DBMS_OUTPUT.PUT_LINE('Accurate records: ' || v_accurate_sales);
  DBMS_OUTPUT.PUT_LINE('