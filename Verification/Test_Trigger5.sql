
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
DELETE FROM decorator_choice WHERE decoratorchoice_id = 70011;
DELETE FROM decorator_session WHERE housetask_housetask_id = 44881;
DELETE FROM housetask WHERE housetask_id = 44881;
COMMIT;
