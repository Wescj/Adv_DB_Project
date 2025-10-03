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


SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- --- Setup: Create a HouseTask currently at stage 3 ---

-- 1) A HouseTask for this house
INSERT INTO housetask (housetask_id, stage, required, house_house_id, employee_employee_id)
VALUES (42001, 3, 'Y', 8004, 26003);

COMMIT;

-- --- Test A: Attempt to create a session for stage 1 (should FAIL) ---
-- This should be blocked by the trigger because 1 < 3.
BEGIN
  INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
  VALUES (54001, SYSDATE, 1, 42001, 'N');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Expected failure: ' || SQLERRM);
END;
/

-- --- Test B: Attempt to create a session for stage 3 (should SUCCEED) ---
-- This should be allowed because 3 is not less than 3.
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (54005, SYSDATE, 3, 42001, 'N');

SELECT decoratorsession_id, stage
FROM decorator_session
WHERE decoratorsession_id = 54005;

-- Expect: Row returned for decoratorsession_id 54005 with stage 3.

-- --- Test C: Attempt to create a session for stage 4 (should SUCCEED) ---
-- This should be allowed because 4 is not less than 3.
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (54006, SYSDATE, 4, 42001, 'N');

SELECT decoratorsession_id, stage
FROM decorator_session
WHERE decoratorsession_id = 54006;

-- Expect: Row returned for decoratorsession_id 54006 with stage 4.

COMMIT;


-- Clean up (optional for re-runs)
DELETE FROM decorator_session WHERE decoratorsession_id IN (54001, 54005, 54006);
DELETE FROM housetask WHERE housetask_id = 42001;
COMMIT;
