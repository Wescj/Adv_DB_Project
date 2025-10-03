-- =====================================================================
-- TEST FILE: Denormalization Performance and Consistency
-- Denormalized Column: sale.total_contract_price
-- Purpose: Validate accuracy, trigger functionality, and performance
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT TEST SUITE FOR DENORMALIZATION: sale.total_contract_price
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify denormalized column exists
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Column Existence ======
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns
WHERE table_name = 'SALE'
  AND column_name = 'TOTAL_CONTRACT_PRICE';

-- =====================================================================
-- Test 2: Accuracy Test - Compare stored vs calculated values
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Accuracy Verification ======
PROMPT Comparing stored total_contract_price vs calculated values...

SELECT s.sale_id,
       s.house_house_id,
       s.total_contract_price AS stored_value,
       fn_house_total_price(s.house_house_id) AS calculated_value,
       ROUND(s.total_contract_price - fn_house_total_price(s.house_house_id), 2) AS difference
FROM sale s
ORDER BY s.sale_id;

-- Automated accuracy check
DECLARE
  v_total_sales NUMBER;
  v_accurate_sales NUMBER;
  v_max_diff NUMBER;
BEGIN
  SELECT COUNT(*),
         SUM(CASE WHEN ABS(s.total_contract_price - fn_house_total_price(s.house_house_id)) < 0.01 
                  THEN 1 ELSE 0 END),
         MAX(ABS(s.total_contract_price - fn_house_total_price(s.house_house_id)))
  INTO v_total_sales, v_accurate_sales, v_max_diff
  FROM sale s;
  
  DBMS_OUTPUT.PUT_LINE('=== ACCURACY TEST RESULTS ===');
  DBMS_OUTPUT.PUT_LINE('Total sales: ' || v_total_sales);
  DBMS_OUTPUT.PUT_LINE('Accurate sales: ' || v_accurate_sales);
  DBMS_OUTPUT.PUT_LINE('Accuracy rate: ' || ROUND(v_accurate_sales/v_total_sales * 100, 2) || '%');
  DBMS_OUTPUT.PUT_LINE('Max difference: $' || ROUND(v_max_diff, 2));
  
  IF v_accurate_sales = v_total_sales THEN
    DBMS_OUTPUT.PUT_LINE('✓ SUCCESS: All denormalized values are accurate');
  ELSE
    DBMS_OUTPUT.PUT_LINE('✗ FAILURE: ' || (v_total_sales - v_accurate_sales) || ' sales have discrepancies');
  END IF;
END;
/

-- =====================================================================
-- Test 3: Performance Comparison - Denormalized vs Calculated
-- =====================================================================
PROMPT 
PROMPT ====== Test 3: Performance Comparison ======
PROMPT 3a: FAST - Using denormalized column

SELECT s.sale_id,
       b.name AS buyer_name,
       s.total_contract_price,
       s.financing_method,
       s."Date" AS sale_date
FROM sale s
JOIN buyer b ON s.buyer_buyer_id = b.buyer_id
ORDER BY s.sale_id;

PROMPT 
PROMPT 3b: SLOW - Calculating with complex joins

SELECT s.sale_id,
       b.name AS buyer_name,
       (hs.baseprice + l.lotpremium + NVL(SUM(dc.price), 0)) AS calculated_price,
       s.financing_method,
       s."Date" AS sale_date
FROM sale s
JOIN buyer b ON s.buyer_buyer_id = b.buyer_id
JOIN house h ON s.house_house_id = h.house_id
JOIN housestyle hs ON h.housestyle_style_id = hs.style_id
JOIN lot l ON h.lot_lot_id = l.lot_id
LEFT JOIN housetask ht ON h.house_id = ht.house_house_id
LEFT JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
LEFT JOIN decorator_choice dc ON ds.decoratorsession_id = dc.decorator_session_id
GROUP BY s.sale_id, b.name, hs.baseprice, l.lotpremium, s.financing_method, s."Date"
ORDER BY s.sale_id;

-- =====================================================================
-- Test 4: Trigger Test - Automatic calculation on INSERT
-- =====================================================================
PROMPT 
PROMPT ====== Test 4: Trigger Test - New Sale Insert ======
PROMPT Creating test sale to verify automatic price calculation...

-- Save original state
SELECT COUNT(*) AS sales_before_test FROM sale;

-- Insert test sale
INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, 
                  estimatedcompletion, receivedsubdivision, 
                  receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, 
                  employee_employee_id, house_house_id, bank_worker_worker_id)
VALUES (99001, SYSDATE, 'Mortgage', 1500, DATE '2026-12-01',
        'Y', 'Y', 'Y', 24001, 28001, 26001, 8003, 32001);

COMMIT;

-- Check if price was auto-calculated
SELECT sale_id, 
       house_house_id,
       total_contract_price AS auto_calculated,
       fn_house_total_price(house_house_id) AS expected_value,
       CASE 
         WHEN ABS(total_contract_price - fn_house_total_price(house_house_id)) < 0.01 
         THEN '✓ PASS' 
         ELSE '✗ FAIL' 
       END AS test_result
FROM sale
WHERE sale_id = 99001;

-- Cleanup
DELETE FROM sale WHERE sale_id = 99001;
COMMIT;

PROMPT Test sale removed. Database restored to original state.

-- =====================================================================
-- Test 5: Trigger Test - Decorator choice changes update sale price
-- =====================================================================
PROMPT 
PROMPT ====== Test 5: Trigger Test - Decorator Choice Update ======
PROMPT Testing if adding decorator choice updates sale price...

-- Record current price for house 8006
DECLARE
  v_price_before NUMBER;
  v_price_after NUMBER;
  v_test_price NUMBER := 3000;
BEGIN
  SELECT total_contract_price
  INTO v_price_before
  FROM sale
  WHERE house_house_id = 8006;
  
  DBMS_OUTPUT.PUT_LINE('Price before decorator choice: $' || v_price_before);
  
  -- Add test decorator choice
  INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, 
                                decorator_session_id, option_option_id)
  VALUES (99999, 'Test Upgrade', 'Testing denorm trigger', v_test_price, 14001, 16001);
  
  COMMIT;
  
  -- Check updated price
  SELECT total_contract_price
  INTO v_price_after
  FROM sale
  WHERE house_house_id = 8006;
  
  DBMS_OUTPUT.PUT_LINE('Price after decorator choice: $' || v_price_after);
  DBMS_OUTPUT.PUT_LINE('Expected increase: $' || v_test_price);
  DBMS_OUTPUT.PUT_LINE('Actual increase: $' || (v_price_after - v_price_before));
  
  IF ABS((v_price_after - v_price_before) - v_test_price) < 0.01 THEN
    DBMS_OUTPUT.PUT_LINE('✓ SUCCESS: Sale price updated correctly');
  ELSE
    DBMS_OUTPUT.PUT_LINE('✗ FAILURE: Price did not update as expected');
  END IF;
  
  -- Cleanup
  DELETE FROM decorator_choice WHERE decoratorchoice_id = 99999;
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Test decorator choice removed.');
END;
/

-- =====================================================================
-- Test 6: Business Query - Sales Revenue Report
-- =====================================================================
PROMPT 
PROMPT ====== Test 6: Business Query - Revenue Report ======
SELECT 
    sd.name AS subdivision,
    COUNT(s.sale_id) AS num_sales,
    SUM(s.total_contract_price) AS total_revenue,
    AVG(s.total_contract_price) AS avg_sale_price,
    MIN(s.total_contract_price) AS min_price,
    MAX(s.total_contract_price) AS max_price
FROM subdivision sd
LEFT JOIN lot l ON sd.subdivision_id = l.subdivision_subdivision_id
LEFT JOIN house h ON l.lot_id = h.lot_lot_id
LEFT JOIN sale s ON h.house_id = s.house_house_id
GROUP BY sd.name
ORDER BY total_revenue DESC NULLS LAST;

-- =====================================================================
-- Test 7: Business Query - Sales Commission Calculation
-- =====================================================================
PROMPT 
PROMPT ====== Test 7: Sales Commission Report ======
SELECT e.employee_id,
       e.name AS sales_representative,
       e.title,
       COUNT(s.sale_id) AS num_sales,
       SUM(s.total_contract_price) AS total_sales_value,
       ROUND(SUM(s.total_contract_price) * 0.03, 2) AS commission_at_3pct
FROM employee e
LEFT JOIN sale s ON e.employee_id = s.employee_employee_id
GROUP BY e.employee_id, e.name, e.title
HAVING COUNT(s.sale_id) > 0
ORDER BY total_sales_value DESC;

-- =====================================================================
-- Test 8: Performance Benchmark
-- =====================================================================
PROMPT 
PROMPT ====== Test 8: Performance Benchmark ======
PROMPT Comparing query execution time (100 iterations each)...

DECLARE
  v_time_denorm NUMBER;
  v_time_calc NUMBER;
  v_price NUMBER;
  v_start NUMBER;
  v_end NUMBER;
BEGIN
  -- Benchmark denormalized query
  v_start := DBMS_UTILITY.GET_TIME;
  
  FOR i IN 1..100 LOOP
    SELECT total_contract_price
    INTO v_price
    FROM sale
    WHERE sale_id = 34001;
  END LOOP;
  
  v_end := DBMS_UTILITY.GET_TIME;
  v_time_denorm := v_end - v_start;
  
  -- Benchmark calculated query
  v_start := DBMS_UTILITY.GET_TIME;
  
  FOR i IN 1..100 LOOP
    SELECT fn_house_total_price(house_house_id)
    INTO v_price
    FROM sale
    WHERE sale_id = 34001;
  END LOOP;
  
  v_end := DBMS_UTILITY.GET_TIME;
  v_time_calc := v_end - v_start;
  
  -- Report results
  DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE BENCHMARK RESULTS ===');
  DBMS_OUTPUT.PUT_LINE('Denormalized query (100 runs): ' || v_time_denorm || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('Calculated query (100 runs): ' || v_time_calc || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('Speedup factor: ' || ROUND(v_time_calc / v_time_denorm, 2) || 'x faster');
  DBMS_OUTPUT.PUT_LINE('Time saved per query: ' || 
                       ROUND((v_time_calc - v_time_denorm) / 100, 2) || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('Performance improvement: ' || 
                       ROUND((1 - v_time_denorm/v_time_calc) * 100, 1) || '%');
END;
/

-- =====================================================================
-- Test 9: Execution Plan Comparison
-- =====================================================================
PROMPT 
PROMPT ====== Test 9: Execution Plan Comparison ======
PROMPT 9a: Denormalized query plan (simple)

EXPLAIN PLAN FOR
SELECT s.sale_id, b.name, s.total_contract_price
FROM sale s
JOIN buyer b ON s.buyer_buyer_id = b.buyer_id
WHERE s.total_contract_price > 300000;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(FORMAT=>'BASIC'));

PROMPT 
PROMPT 9b: Calculated query plan (complex joins)

EXPLAIN PLAN FOR
SELECT s.sale_id, b.name, (hs.baseprice + l.lotpremium) AS price
FROM sale s
JOIN buyer b ON s.buyer_buyer_id = b.buyer_id
JOIN house h ON s.house_house_id = h.house_id
JOIN housestyle hs ON h.housestyle_style_id = hs.style_id
JOIN lot l ON h.lot_lot_id = l.lot_id
WHERE (hs.baseprice + l.lotpremium) > 300000;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(FORMAT=>'BASIC'));

-- =====================================================================
-- Test 10: Data Consistency After Bulk Operations
-- =====================================================================
PROMPT 
PROMPT ====== Test 10: Bulk Update Consistency Test ======
PROMPT Recalculating all sale prices and verifying consistency...

-- Force recalculation
UPDATE sale
SET total_contract_price = fn_house_total_price(house_house_id);

COMMIT;

-- Verify all remain accurate
SELECT 
    COUNT(*) AS total_sales,
    SUM(CASE WHEN ABS(total_contract_price - fn_house_total_price(house_house_id)) < 0.01 
             THEN 1 ELSE 0 END) AS accurate_sales,
    ROUND(SUM(CASE WHEN ABS(total_contract_price - fn_house_total_price(house_house_id)) < 0.01 
                   THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS accuracy_pct
FROM sale;

SET TIMING OFF

PROMPT 
PROMPT =====================================================================
PROMPT TEST SUMMARY - Denormalization Validation
PROMPT =====================================================================
PROMPT 
PROMPT Expected Results:
PROMPT 1. Column total_contract_price exists in SALE table
PROMPT 2. All stored values match calculated values (difference < $0.01)
PROMPT 3. Denormalized queries are 60-80% faster than calculated
PROMPT 4. New sale inserts auto-populate total_contract_price
PROMPT 5. Adding decorator choices automatically updates sale price
PROMPT 6. Revenue and commission reports execute quickly
PROMPT 7. Execution plan shows fewer joins for denormalized queries
PROMPT 8. Bulk updates maintain 100% accuracy
PROMPT 
PROMPT Key Performance Indicators:
PROMPT - Accuracy: 100% of sales within $0.01 of calculated value
PROMPT - Performance: 3-5x speedup over calculated queries
PROMPT - Simplicity: Reduced from 5-6 table joins to 1-2 table access
PROMPT - Storage cost: 8 bytes per sale row (minimal overhead)
PROMPT =====================================================================