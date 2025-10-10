-- ===========================================================
-- FILE: test_alternate_index.sql
-- PURPOSE: Test alternate indexes
--
-- JUSTIFICATION:
-- Indexes improve query performance but must be verified to ensure:
-- (1) they exist and are valid, and (2) queries can use them effectively.
-- Without testing, indexes waste space without providing benefits.
-- ===========================================================

SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT ALTERNATE INDEX TESTING
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify index existence and status
-- =====================================================================
PROMPT 
PROMPT Test 1: Verify all indexes exist and are VALID
PROMPT ----------------------------------------------------------------

SELECT 
    index_name,
    table_name,
    status,
    CASE 
        WHEN status = 'VALID' THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM user_indexes
WHERE index_name IN (
    'IDX_HOUSETASK_HOUSE_STAGE',
    'IDX_SALE_EMPLOYEE_DATE',
    'IDX_DECORATOR_CHOICE_SESSION'
)
ORDER BY table_name, index_name;

-- =====================================================================
-- Test 2: Test queries using the indexes
-- =====================================================================
PROMPT 
PROMPT Test 2: Run queries that should use the indexes
PROMPT ----------------------------------------------------------------

PROMPT Query 1: Find tasks by house and stage (uses IDX_HOUSETASK_HOUSE_STAGE)
SELECT ht.housetask_id, ht.house_house_id, ht.stage, ht.notes
FROM housetask ht
WHERE ht.house_house_id = 8006 AND ht.stage = 1;

PROMPT Query 2: Find sales by employee (uses IDX_SALE_EMPLOYEE_DATE)
SELECT s.sale_id, s.employee_employee_id, s."Date", s.financing_method
FROM sale s
WHERE s.employee_employee_id = 26001;

PROMPT Query 3: Find decorator choices by session (uses IDX_DECORATOR_CHOICE_SESSION)
SELECT dc.decoratorchoice_id, dc.decorator_session_id, dc.item, dc.price
FROM decorator_choice dc
WHERE dc.decorator_session_id = 14001;

PROMPT =====================================================================