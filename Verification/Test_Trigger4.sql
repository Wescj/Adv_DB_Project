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

SELECT housetask_id, decoratorsession_id, housetask.stage as house_task_stage, decorator_session.stage as decorator_session_stage
FROM housetask
join decorator_session on decorator_session.housetask_housetask_id = housetask.housetask_id
WHERE housetask_id = 42001;

-- Clean up (optional for re-runs)
DELETE FROM decorator_session WHERE decoratorsession_id IN (54001, 54005, 54006);
DELETE FROM housetask WHERE housetask_id = 42001;
COMMIT;
