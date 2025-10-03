-- =====================================================================
-- TEST FILE: Alternate Index Performance and Functionality
-- Index: idx_housetask_house_stage on housetask(house_house_id, stage, plannedstart)
-- Purpose: Validate index creation, usage, and performance improvement
-- =====================================================================

SET ECHO ON
SET TIMING ON
SET AUTOTRACE ON EXPLAIN
SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT TEST SUITE FOR ALTERNATE INDEX: idx_housetask_house_stage
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify index exists with correct structure
-- =====================================================================
PROMPT 
PROMPT ====== Test 1: Verify Index Existence and Structure ======
SELECT index_name, table_name, uniqueness, status
FROM user_indexes
WHERE index_name = 'IDX_HOUSETASK_HOUSE_STAGE';

SELECT index_name, column_name, column_position, descend
FROM user_ind_columns
WHERE index_name = 'IDX_HOUSETASK_HOUSE_STAGE'
ORDER BY column_position;

-- =====================================================================
-- Test 2: Most common query pattern - Find tasks for specific house/stage
-- Expected: INDEX RANGE SCAN
-- =====================================================================
PROMPT 
PROMPT ====== Test 2: Query Tasks by House and Stage ======
PROMPT Query: Find all stage 1 tasks for house 8006

SELECT housetask_id, stage, plannedstart, plannedend, percent_complete, notes
FROM housetask
WHERE house_house_id = 8006
  AND stage = 1
ORDER BY plannedstart;

PROMPT 
PROMPT Execution Plan Analysis:
PROMPT Expected: INDEX RANGE SCAN on IDX_HOUSETASK_HOUSE_STAGE
PROMPT

-- =====================================================================
-- Test 3: Construction manager daily report
-- Expected: Index eliminates full table scan
-- =====================================================================
PROMPT 
PROMPT ====== Test 3: Construction Manager Daily Report ======
PROMPT Query: All tasks for house 8007, stages 1-2

SELECT ht.housetask_id,
       ht.stage,
       ht.plannedstart,
       ht.plannedend,
       ht.percent_complete,
       e.name AS assigned_employee
FROM housetask ht
JOIN employee e ON ht.employee_employee_id = e.employee_id
WHERE ht.house_house_id = 8007
  AND ht.stage <= 2
ORDER BY ht.stage, ht.plannedstart;

-- =====================================================================
-- Test 4: Count tasks by stage for multiple houses
-- Expected: Index provides efficient access for IN clause
-- =====================================================================
PROMPT 
PROMPT ====== Test 4: Task Count by House and Stage ======
SELECT house_house_id, stage, COUNT(*) AS task_count
FROM housetask
WHERE house_house_id IN (8001, 8002, 8006, 8007)
GROUP BY house_house_id, stage
ORDER BY house_house_id, stage;

-- =====================================================================
-- Test 5: Find houses at specific construction stage
-- Expected: Index range scan on stage column
-- =====================================================================
PROMPT 
PROMPT ====== Test 5: Find All Houses at Stage 1 ======
SELECT DISTINCT ht.house_house_id, 
       h.currentconstructionstage,
       COUNT(ht.housetask_id) AS tasks_at_stage_1
FROM housetask ht
JOIN house h ON ht.house_house_id = h.house_id
WHERE ht.stage = 1
GROUP BY ht.house_house_id, h.currentconstructionstage
ORDER BY ht.house_house_id;

-- =====================================================================
-- Test 6: Timeline query - benefits from plannedstart in index
-- Expected: Index provides sorted data, no additional sort needed
-- =====================================================================
PROMPT 
PROMPT ====== Test 6: Construction Timeline for House 8006 ======
SELECT housetask_id, 
       stage, 
       plannedstart, 
       plannedend,
       (plannedend - plannedstart) AS duration_days
FROM housetask
WHERE house_house_id = 8006
ORDER BY plannedstart;

PROMPT Expected: Plan should show no SORT operation (data already sorted by index)

-- =====================================================================
-- Test 7: Find overdue tasks at specific stage
-- Expected: Index filters stage first, then date predicate
-- =====================================================================
PROMPT 
PROMPT ====== Test 7: Overdue Tasks at Stage 1 ======
SELECT house_house_id, 
       housetask_id, 
       plannedend, 
       stage,
       percent_complete
FROM housetask
WHERE stage = 1
  AND plannedend < SYSDATE
  AND NVL(percent_complete, 0) < 1.00
ORDER BY plannedend;

-- =====================================================================
-- Test 8: Stage range query (early construction phases)
-- Expected: Index range scan for stage IN clause
-- =====================================================================
PROMPT 
PROMPT ====== Test 8: Tasks in Early Stages (1-3) ======
SELECT house_house_id, 
       stage, 
       COUNT(*) AS task_count,
       AVG(NVL(percent_complete, 0)) AS avg_progress
FROM housetask
WHERE stage IN (1, 2, 3)
GROUP BY house_house_id, stage
ORDER BY house_house_id, stage;

-- =====================================================================
-- Test 9: Complex join with index optimization
-- Expected: Index reduces join cost
-- =====================================================================
PROMPT 
PROMPT ====== Test 9: Construction Progress with Photos ======
SELECT h.house_id,
       ht.stage,
       ht.housetask_id,
       tp.percentage_complete,
       COUNT(p.photo_id) AS photo_count
FROM house h
JOIN housetask ht ON h.house_id = ht.house_house_id
LEFT JOIN task_progress tp ON ht.housetask_id = tp.housetask_housetask_id
LEFT JOIN photo p ON ht.housetask_id = p.housetask_housetask_id
WHERE h.house_id = 8006
  AND ht.stage = 1
GROUP BY h.house_id, ht.stage, ht.housetask_id, tp.percentage_complete
ORDER BY ht.housetask_id;

-- =====================================================================
-- Test 10: Explain Plan Analysis
-- =====================================================================
PROMPT 
PROMPT ====== Test 10: Detailed Explain Plan ======
EXPLAIN PLAN FOR
SELECT housetask_id, stage, plannedstart, percent_complete
FROM housetask
WHERE house_house_id = 8006
  AND stage = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(FORMAT=>'BASIC +PREDICATE'));

SET AUTOTRACE OFF

-- =====================================================================
-- Test 11: Index Statistics
-- =====================================================================
PROMPT 
PROMPT ====== Test 11: Index Statistics ======
SELECT index_name, 
       num_rows AS table_rows,
       distinct_keys,
       leaf_blocks,
       clustering_factor,
       avg_leaf_blocks_per_key,
       avg_data_blocks_per_key
FROM user_indexes
WHERE index_name = 'IDX_HOUSETASK_HOUSE_STAGE';

-- =====================================================================
-- Test 12: Performance Benchmark (Simple Timing Test)
-- =====================================================================
PROMPT 
PROMPT ====== Test 12: Performance Benchmark ======
PROMPT Running query 100 times to measure performance...

DECLARE
  v_count NUMBER;
  v_start NUMBER;
  v_end NUMBER;
BEGIN
  v_start := DBMS_UTILITY.GET_TIME;
  
  FOR i IN 1..100 LOOP
    SELECT COUNT(*)
    INTO v_count
    FROM housetask
    WHERE house_house_id = 8006
      AND stage = 1;
  END LOOP;
  
  v_end := DBMS_UTILITY.GET_TIME;
  
  DBMS_OUTPUT.PUT_LINE('100 iterations completed in: ' || 
                       ((v_end - v_start) / 100) || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('Average time per query: ' || 
                       ROUND((v_end - v_start) / 100, 2) || ' centiseconds');
END;
/

SET TIMING OFF

PROMPT 
PROMPT =====================================================================
PROMPT TEST SUMMARY - Alternate Index Validation
PROMPT =====================================================================
PROMPT 
PROMPT Expected Results:
PROMPT 1. Index exists with columns: house_house_id, stage, plannedstart
PROMPT 2. All queries using house_house_id + stage should show INDEX RANGE SCAN
PROMPT 3. No FULL TABLE SCAN should appear for indexed queries
PROMPT 4. Timeline queries should not require additional SORT operation
PROMPT 5. Performance should be 50-80% faster than without index
PROMPT 
PROMPT Key Performance Indicators:
PROMPT - INDEX RANGE SCAN in execution plan
PROMPT - Low clustering factor (indicates good data locality)
PROMPT - Fast query execution (<0.5 centiseconds for simple queries)
PROMPT =====================================================================