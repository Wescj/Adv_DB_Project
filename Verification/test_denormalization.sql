-- ===========================================================
-- FILE: test_denormalization.sql
-- PURPOSE: Test denormalized total_contract_price
-- 
-- JUSTIFICATION:
-- Denormalization stores calculated values to avoid expensive joins.
-- We must verify: (1) initial calculation is correct, and 
-- (2) triggers update the value when decorator choices change.
-- ===========================================================

SET LINESIZE 200
SET PAGESIZE 100

PROMPT =====================================================================
PROMPT DENORMALIZATION TESTING - TOTAL CONTRACT PRICE
PROMPT =====================================================================

-- =====================================================================
-- Test 1: Verify denormalized values match function calculations
-- =====================================================================
PROMPT 
PROMPT Test 1: Verify denormalized price = calculated price
PROMPT ----------------------------------------------------------------

SELECT 
    s.sale_id,
    s.total_contract_price AS denormalized_price,
    fn_house_total_price(s.house_house_id) AS calculated_price,
    CASE 
        WHEN s.total_contract_price = fn_house_total_price(s.house_house_id) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END AS test_result
FROM sale s
ORDER BY s.sale_id;

-- =====================================================================
-- Test 2: Show price breakdown
-- =====================================================================
PROMPT 
PROMPT Test 2: Show price components breakdown
PROMPT ----------------------------------------------------------------

SELECT 
    s.sale_id,
    hs.baseprice AS base_price,
    l.lotpremium AS lot_premium,
    NVL(SUM(dc.price), 0) AS options_total,
    s.total_contract_price AS denormalized_total
FROM sale s
JOIN house h ON s.house_house_id = h.house_id
JOIN housestyle hs ON h.housestyle_style_id = hs.style_id
JOIN lot l ON h.lot_lot_id = l.lot_id
LEFT JOIN housetask ht ON h.house_id = ht.house_house_id
LEFT JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
LEFT JOIN decorator_choice dc ON ds.decoratorsession_id = dc.decorator_session_id
GROUP BY s.sale_id, hs.baseprice, l.lotpremium, s.total_contract_price
ORDER BY s.sale_id;

PROMPT =====================================================================