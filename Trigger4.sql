-- ===========================================================
-- Trigger: trg_session_validate_stage
-- Table:  DECORATOR_SESSION
-- Timing: BEFORE INSERT
-- Purpose:
--   Prevent the creation of a decorator session for a construction stage
--   that the house has already surpassed.
-- Business rules:
--   - A house's current construction stage is stored in HOUSE.CURRENTCONSTRUCTIONSTAGE.
--   - A decorator session cannot be created for a stage that is less than
--     the house's current stage.
--   - If the rule is violated, block the operation with ORA-20001.
-- ===========================================================
CREATE OR REPLACE TRIGGER trg_session_validate_stage
BEFORE INSERT ON decorator_session
FOR EACH ROW
DECLARE
  v_house_stage house.currentconstructionstage%TYPE;
BEGIN
  -- Find the current construction stage of the house linked to this session
  SELECT h.currentconstructionstage
    INTO v_house_stage
    FROM house h
    JOIN housetask ht ON h.house_id = ht.house_house_id
   WHERE ht.housetask_id = :NEW.housetask_housetask_id;

  -- Block if the session's stage is for a past phase of construction
  IF :NEW.stage < v_house_stage THEN
    RAISE_APPLICATION_ERROR(
      -20001,
      'Cannot create a decorator session for a past construction stage. House is at stage ' ||
      v_house_stage || ', session is for stage ' || :NEW.stage || '.'
    );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- This handles the case where the housetask_id is invalid.
    -- The foreign key constraint would catch this anyway, but this provides a clearer error.
    RAISE_APPLICATION_ERROR(
        -20002,
        'Invalid housetask_id provided; cannot find associated house.'
        );
END;
/
