-- ===========================================================
-- FILE: denormalization.sql
-- PURPOSE: Add denormalized total_contract_price to SALE table
-- FORMULA: total_contract_price = housestyle.baseprice + lot.lotpremium + SUM(decorator_choice.price)
-- ===========================================================

-- Add denormalized column
ALTER TABLE sale ADD (
  total_contract_price NUMBER(12, 2)
);

-- Trigger 1: Auto-calculate price on sale INSERT/UPDATE
CREATE OR REPLACE TRIGGER trg_sale_calc_total
BEFORE INSERT OR UPDATE OF house_house_id ON sale
FOR EACH ROW
BEGIN
  :NEW.total_contract_price := fn_house_total_price(:NEW.house_house_id);
  
  IF :NEW.total_contract_price IS NULL THEN
    :NEW.total_contract_price := 0;
  END IF;
END;
/

-- Trigger 2: Recalculate price when decorator choices change
CREATE OR REPLACE TRIGGER trg_decorator_update_sale
AFTER INSERT OR UPDATE OR DELETE ON decorator_choice
FOR EACH ROW
DECLARE
  v_sale_id sale.sale_id%TYPE;
BEGIN
  SELECT s.sale_id 
  INTO v_sale_id
  FROM sale s
  JOIN housetask ht ON s.house_house_id = ht.house_house_id
  JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
  WHERE ds.decoratorsession_id = COALESCE(:NEW.decorator_session_id, :OLD.decorator_session_id);
  
  UPDATE sale
  SET total_contract_price = fn_house_total_price(house_house_id)
  WHERE sale_id = v_sale_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN TOO_MANY_ROWS THEN
    UPDATE sale s
    SET s.total_contract_price = fn_house_total_price(s.house_house_id)
    WHERE s.house_house_id IN (
      SELECT ht.house_house_id
      FROM housetask ht
      JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
      WHERE ds.decoratorsession_id = COALESCE(:NEW.decorator_session_id, :OLD.decorator_session_id)
    );
END;
/

-- Backfill existing sales
UPDATE sale
SET total_contract_price = fn_house_total_price(house_house_id)
WHERE total_contract_price IS NULL;

COMMIT;

PROMPT Denormalization complete. Run test_denormalization.sql to verify.