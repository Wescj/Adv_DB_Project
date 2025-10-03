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


SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- --- Setup: Create prerequisite data for testing ---
INSERT INTO housetask (housetask_id, stage, required, house_house_id, employee_employee_id) VALUES (44881, 3, 'Y', 8004, 26001);

-- 4) A decorator session at Stage 1
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (15510, SYSDATE, 3, 44881, 'Y');

COMMIT;


-- --- Test A: INSERT a choice, expect price to be auto-populated ---
INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
VALUES (70010, 'Tile Upgrade', 'Standard ceramic tile for foyer', NULL, 15510, 16001); -- Price is NULL

COMMIT;

SELECT decoratorchoice_id, price
  FROM decorator_choice
 WHERE decoratorchoice_id = 70010;
-- Expected result: 5000


-- --- Test B: Error path (no price defined for the stage) ---
-- 1) Create a session for a different stage (e.g., Stage 2)
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (15511, SYSDATE, 2, 44881, 'Y');
COMMIT;

-- 2) Try to insert the choice. This should fail because no price is defined for option 16001 at stage 2.
BEGIN
  INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
  VALUES (70011, 'Tile Upgrade Fail', 'Attempt at stage 2', NULL, 15511, 16001);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Expected failure occurred: ' || SQLERRM);
END;
/


-- --- Clean up script (for re-running tests) ---
DELETE FROM decorator_choice WHERE decoratorchoice_id IN (70010, 70011);
DELETE FROM decorator_session WHERE decoratorsession_id IN (510, 511);
DELETE FROM housetask WHERE housetask_id = 44001;
COMMIT;
