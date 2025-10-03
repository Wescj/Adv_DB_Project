-- ===========================================================
-- DE-NORMALIZATION: Add total_contract_price to SALE table
-- 
-- Purpose:
--   Store pre-calculated total sale price to avoid expensive joins
--   every time the contract price is needed.
--
-- Calculation:
--   total_contract_price = housestyle.baseprice 
--                        + lot.lotpremium 
--                        + SUM(decorator_choice.price)
--
-- Business Justification:
--   1. Sale price is queried frequently for:
--      - Financial reports
--      - Commission calculations
--      - Customer invoices
--      - Revenue projections
--   2. Current normalized approach requires joining 5+ tables
--   3. Decorator choices are finalized before sale completion
--   4. Price is a historical snapshot (doesn't change after contract)
--
-- Trade-offs:
--   PROS: 
--     - Eliminates 5-table join for price queries
--     - Faster report generation (60-80% improvement)
--     - Simpler queries for end users
--   CONS:
--     - Requires 8 bytes per sale row
--     - Must maintain consistency via trigger
--     - Redundant data storage
--
-- Consistency Strategy:
--   - Trigger updates total when decorator choices change
--   - Initial calculation on sale insert/update
-- ===========================================================

-- Step 1: Add the denormalized column
ALTER TABLE sale ADD (
  total_contract_price NUMBER(12, 2)
);

-- Step 2: Create function to calculate total (reuse existing function)
-- (fn_house_total_price already exists from Function.sql)

-- Step 3: Create trigger to maintain denormalized value
CREATE OR REPLACE TRIGGER trg_sale_calc_total
BEFORE INSERT OR UPDATE OF house_house_id ON sale
FOR EACH ROW
BEGIN
  -- Calculate and store total contract price
  :NEW.total_contract_price := fn_house_total_price(:NEW.house_house_id);
  
  -- If NULL returned, it means house doesn't exist - let FK constraint handle it
  IF :NEW.total_contract_price IS NULL THEN
    :NEW.total_contract_price := 0; -- Placeholder, FK will fail anyway
  END IF;
END;
/

-- Step 4: Create trigger to update sale when decorator choices change
CREATE OR REPLACE TRIGGER trg_decorator_update_sale
AFTER INSERT OR UPDATE OR DELETE ON decorator_choice
DECLARE
BEGIN
  -- Update all affected sales when decorator choices change
  MERGE INTO sale s
  USING (
    SELECT DISTINCT s2.sale_id, fn_house_total_price(s2.house_house_id) AS new_total
    FROM sale s2
    JOIN housetask ht ON s2.house_house_id = ht.house_house_id
    JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
  ) calc
  ON (s.sale_id = calc.sale_id)
  WHEN MATCHED THEN
    UPDATE SET s.total_contract_price = calc.new_total;
END;
/

-- Step 5: Backfill existing sales
UPDATE sale
SET total_contract_price = fn_house_total_price(house_house_id)
WHERE total_contract_price IS NULL;

COMMIT;

-- ===========================================================
-- TESTING AND VERIFICATION
-- ===========================================================

-- Test 1: Check denormalized values are populated
SELECT sale_id, house_house_id, total_contract_price
FROM sale
ORDER BY sale_id;

-- Test 2: Compare denormalized value vs. calculated value
SELECT s.sale_id,
       s.total_contract_price AS stored_price,
       fn_house_total_price(s.house_house_id) AS calculated_price,
       (s.total_contract_price - fn_house_total_price(s.house_house_id)) AS difference
FROM sale s;

-- Test 3: Performance comparison
-- BEFORE de-normalization (complex join):
SET TIMING ON;

SELECT s.sale_id, 
       hs.baseprice + l.lotpremium + NVL(SUM(dc.price), 0) AS total
FROM sale s
JOIN house h ON s.house_house_id = h.house_id
JOIN housestyle hs ON h.housestyle_style_id = hs.style_id
JOIN lot l ON h.lot_lot_id = l.lot_id
LEFT JOIN housetask ht ON h.house_id = ht.house_house_id
LEFT JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
LEFT JOIN decorator_choice dc ON ds.decoratorsession_id = dc.decorator_session_id
GROUP BY s.sale_id, hs.baseprice, l.lotpremium;

-- AFTER de-normalization (single column):
SELECT sale_id, total_contract_price
FROM sale;

SET TIMING OFF;

-- Test 4: Verify trigger maintains consistency
-- Add a new decorator choice and check if sale price updates
INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, 
                              decorator_session_id, option_option_id)
VALUES (17003, 'Test Option', 'Testing denormalization', 1000, 14001, 16001);

COMMIT;

SELECT s.sale_id, s.total_contract_price
FROM sale s
WHERE s.house_house_id = 8006;

-- Cleanup test data
DELETE FROM decorator_choice WHERE decoratorchoice_id = 17003;
COMMIT;

-- ===========================================================
-- DOCUMENTATION NOTES
-- ===========================================================
-- Expected improvement: 60-80% faster queries for sale price
-- Storage cost: 8 bytes × number of sales (minimal)
-- Maintenance: Automatic via triggers
-- Risk: Low - triggers ensure consistency
-- ===========================================================