-- ===========================================================
-- Trigger: trg_choice_set_price
-- Table:  DECORATOR_CHOICE
-- Timing: BEFORE INSERT
-- Purpose:
--   To automatically populate the PRICE for a new DECORATOR_CHOICE record.
--   The price is determined by looking up the cost for the chosen option
--   at the construction stage specified in the parent decorator session.
-- Business rules:
--   - Each option's cost is dependent on the construction stage.
--   - If multiple prices exist for the same option and stage (due to
--     revisions), the price with the most recent revision_date must be used.
--   - If no price is defined in OPTION_STAGE_PRICE for the given
--     option and stage, the insert must be blocked with an error.
-- ===========================================================
CREATE OR REPLACE TRIGGER trg_choice_set_price
BEFORE INSERT ON decorator_choice
FOR EACH ROW
DECLARE
  v_stage decorator_session.stage%TYPE;
  v_price option_stage_price.cost%TYPE;
BEGIN
  -- 1. Get the construction stage from the parent decorator session
  SELECT stage
    INTO v_stage
    FROM decorator_session
   WHERE decoratorsession_id = :NEW.decorator_session_id;

  -- 2. Find the most recent price for the given option at that stage
  SELECT cost
    INTO v_price
    FROM option_stage_price
   WHERE option_option_id = :NEW.option_option_id
     AND stage            = v_stage
     AND revision_date = (
       SELECT MAX(revision_date)
         FROM option_stage_price
        WHERE option_option_id = :NEW.option_option_id
          AND stage            = v_stage
     );

  -- 3. Set the price on the new decorator_choice record
  :NEW.price := v_price;

EXCEPTION
  -- Handle cases where no price is defined for the option at that stage
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(
      -20010,
      'Operation failed: No price has been defined for option ID ' || :NEW.option_option_id || ' at stage ' || v_stage || '.'
    );
END;
/

