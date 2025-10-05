-- ===========================================================
-- Trigger: trg_decorator_choice_autoprice
-- Table:  DECORATOR_CHOICE
-- Timing: BEFORE INSERT OR UPDATE OF decorator_session_id, option_option_id
-- Purpose:
--   Auto-populate DECORATOR_CHOICE.PRICE based on the session's stage and
--   the latest price for that option at that stage (from v_current_option_price).
-- Business rules:
--   - Options are priced per construction stage.
--   - Use the most recent price revision for (option, stage).
--   - If no price exists -> block with ORA-20032.
-- ===========================================================
CREATE OR REPLACE TRIGGER trg_decorator_choice_autoprice
BEFORE INSERT OR UPDATE OF decorator_session_id, option_option_id ON decorator_choice
FOR EACH ROW
DECLARE
  v_stage decorator_session.stage%TYPE;
  v_price NUMBER(12,2);
BEGIN
  -- Get the stage from the linked decorator session
  SELECT stage
    INTO v_stage
    FROM decorator_session
   WHERE decoratorsession_id = :NEW.decorator_session_id;

  -- Get the latest effective price for (option, stage)
  SELECT v.current_cost
    INTO v_price
    FROM v_current_option_price v
   WHERE v.option_option_id = :NEW.option_option_id
     AND v.stage            = v_stage;

  -- Write price into the row being inserted/updated
  :NEW.price := v_price;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(
      -20032,
      'No valid price for this option at the session''s stage (define OPTION_STAGE_PRICE).'
    );
END;
/
