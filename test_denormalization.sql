-- =====================================================================
-- TEST FILE: test_denormalization.sql
-- PURPOSE: Validate denormalization of sale.total_contract_price
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 150
SET PAGESIZE 50

PROMPT =====================================================================
PROMPT TEST SUITE: Denormalization
PROMPT =====================================================================

-- Test 1: Verify column exists
PROMPT 
PROMPT ====== Test 1: Column Existence ======

SELECT column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name = 'SALE'
  AND column_name = 'TOTAL_CONTRACT_PRICE';

PROMPT 

-- Test 2: Accuracy check
PROMPT 
PROMPT ====== Test 2: Accuracy Verification ======

SELECT s.sale_id,
       s.total_contract_price AS stored,
       fn_house_total_price(s.house_house_id) AS calculated,
       ROUND(s.total_contract_price - fn_house_total_price(s.house_house_id), 2) AS diff
FROM sale s
ORDER BY s.sale_id;

PROMPT 

-- Test 3: Trigger test
PROMPT 
PROMPT ====== Test 3: Trigger Auto-Calculation ======

INSERT INTO sale (sale_id, "Date", financing_method, escrowdeposit, 
                  estimatedcompletion, receivedsubdivision, 
                  receiveddisclosureform, receivedcontractcopy,
                  buyer_buyer_id, escrowagent_escrowagent_id, 
                  employee_employee_id, house_house_id, bank_worker_worker_id)
VALUES (99001, SYSDATE, 'Mortgage', 50000, DATE '2026-12-01',
        'Y', 'Y', 'Y', 24001, 28001, 26001, 8003, 32001);

COMMIT;

SELECT sale_id, 
       total_contract_price AS auto_calc,
       fn_house_total_price(house_house_id) AS expected,
       CASE 
         WHEN ABS(total_contract_price - fn_house_total_price(house_house_id)) < 0.01 
         THEN 'PASS' 
         ELSE 'FAIL' 
       END AS result
FROM sale
WHERE sale_id = 99001;

DELETE FROM sale WHERE sale_id = 99001;
COMMIT;

PROMPT 

-- Test 4: Performance comparison
PROMPT 
PROMPT ====== Test 4: Performance Benchmark (100 runs) ======

DECLARE
  v_time_denorm NUMBER;
  v_time_calc NUMBER;
  v_price NUMBER;
  v_start NUMBER;
  v_end NUMBER;
BEGIN
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..100 LOOP
    SELECT total_contract_price INTO v_price FROM sale WHERE sale_id = 34001;
  END LOOP;
  v_end := DBMS_UTILITY.GET_TIME;
  v_time_denorm := v_end - v_start;

  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..100 LOOP
    SELECT fn_house_total_price(house_house_id) INTO v_price FROM sale WHERE sale_id = 34001;
  END LOOP;
  v_end := DBMS_UTILITY.GET_TIME;
  v_time_calc := v_end - v_start;

  DBMS_OUTPUT.PUT_LINE('Denormalized: ' || v_time_denorm || ' cs');
  DBMS_OUTPUT.PUT_LINE('Calculated: ' || v_time_calc || ' cs');
  
  IF v_time_calc > 0 AND v_time_denorm < v_time_calc THEN
    DBMS_OUTPUT.PUT_LINE('Speedup: ' || ROUND(v_time_calc / v_time_denorm, 2) || 'x');
    DBMS_OUTPUT.PUT_LINE('PASS - Denormalized is faster');
  ELSE
    DBMS_OUTPUT.PUT_LINE('INCONCLUSIVE');
  END IF;
END;
/

-- Test 5: Business query
PROMPT 
PROMPT ====== Test 5: Revenue by Subdivision ======

SELECT 
    sd.name AS subdivision,
    COUNT(s.sale_id) AS num_sales,
    SUM(s.total_contract_price) AS total_revenue,
    AVG(s.total_contract_price) AS avg_price
FROM subdivision sd
LEFT JOIN lot l ON sd.subdivision_id = l.subdivision_subdivision_id
LEFT JOIN house h ON l.lot_id = h.lot_lot_id
LEFT JOIN sale s ON h.house_id = s.house_house_id
GROUP BY sd.name
ORDER BY total_revenue DESC NULLS LAST;

SET TIMING OFF

PROMPT 
PROMPT =====================================================================
PROMPT TEST COMPLETE
PROMPT =====================================================================