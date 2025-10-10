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
-- Revised version to solve mutable table error

CREATE OR REPLACE TRIGGER trg_decorator_update_sale
FOR INSERT OR UPDATE OR DELETE ON decorator_choice
COMPOUND TRIGGER 
  TYPE session_id_t IS TABLE OF decorator_session.decoratorsession_id%TYPE;
  g_session_ids session_id_t := session_id_t();

  AFTER EACH ROW IS
  BEGIN
    g_session_ids.EXTEND;
    g_session_ids(g_session_ids.LAST) := COALESCE(:NEW.decorator_session_id, :OLD.decorator_session_id);
  END AFTER EACH ROW;

  AFTER STATEMENT IS
    v_house_id house.house_id%TYPE;
  BEGIN
    FOR i IN 1..g_session_ids.COUNT LOOP
      
      BEGIN
        SELECT ht.house_house_id
        INTO v_house_id
        FROM housetask ht
        JOIN decorator_session ds ON ht.housetask_id = ds.housetask_housetask_id
        WHERE ds.decoratorsession_id = g_session_ids(i)
        AND ROWNUM = 1; 
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_house_id := NULL; 
      END;

      IF v_house_id IS NOT NULL THEN
        UPDATE sale s
        SET s.total_contract_price = fn_house_total_price(s.house_house_id)
        WHERE s.house_house_id = v_house_id;
      END IF;

    END LOOP;
  END AFTER STATEMENT;

END trg_decorator_update_sale;
/

-- Backfill existing sales
UPDATE sale
SET total_contract_price = fn_house_total_price(house_house_id)
WHERE total_contract_price IS NULL;

COMMIT;

PROMPT Denormalization complete. Run test_denormalization.sql to verify.