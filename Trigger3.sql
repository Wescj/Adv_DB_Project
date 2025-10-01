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


SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- --- Setup: session @ stage 1, an option, and two price revisions ---
-- 1) Minimal housetask just to anchor the session
INSERT INTO housetask (housetask_id, stage, required, house_house_id, employee_employee_id, plannedcost, percent_complete)
VALUES (41001, 1, 'Y', 6001, 9201, 1000, 0);

-- 2) Decorator session at stage 1
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (501, SYSDATE, 1, 41001, 'Y');

-- 3) Category + Option
INSERT INTO optioncategory (category_id, categoryname) VALUES (81, 'Plumbing');

INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (9010, 'Garage Sink', 'Utility sink in garage', 81, 3001);

-- 4) Two price revisions for (9010, stage 1) – latest should win
INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (99001, 9010, 1, 450, DATE '2024-01-01');

INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (99002, 9010, 1, 500, DATE '2024-09-01'); -- latest

COMMIT;

-- --- Test A: INSERT should auto-price to 500 ---
INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
VALUES (70001, 'Garage Sink', 'Deep-basin utility sink', NULL, 501, 9010);

SELECT decoratorchoice_id, decorator_session_id, option_option_id, price
FROM decorator_choice
WHERE decoratorchoice_id = 70001;

-- Expect: PRICE = 500.00

-- --- Test B: Update session to stage 4 and add a stage-4 price to show reprice ---
-- Make another session at stage 4
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (502, SYSDATE, 4, 41001, 'Y');

-- Add a price for (9010, stage 4)
INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (99003, 9010, 4, 650, DATE '2024-10-01');

COMMIT;

-- Now move the same choice from session 501 (stage 1) to session 502 (stage 4)
UPDATE decorator_choice
   SET decorator_session_id = 502
 WHERE decoratorchoice_id = 70001;

SELECT decoratorchoice_id, decorator_session_id, option_option_id, price
FROM decorator_choice
WHERE decoratorchoice_id = 70001;

-- Expect: PRICE = 650.00 (recalculated by trigger because session_id changed)

-- --- Test C: Error path (no price for that stage) ---
-- Make a new session at stage 7 without defining a stage-7 price
INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (503, SYSDATE, 7, 41001, 'Y');

-- Try to insert a choice for (9010, stage 7) – should fail with ORA-20032
BEGIN
  INSERT INTO decorator_choice (decoratorchoice_id, item, description, price, decorator_session_id, option_option_id)
  VALUES (70002, 'Garage Sink', 'Stage 7 attempt without price', NULL, 503, 9010);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Expected failure: '||SQLERRM);
END;
/

-- Clean up (optional for re-runs)
-- DELETE FROM decorator_choice WHERE decoratorchoice_id IN (70001,70002);
-- DELETE FROM option_stage_price WHERE osp_id IN (99001,99002,99003);
-- DELETE FROM "Option" WHERE option_id = 9010;
-- DELETE FROM optioncategory WHERE category_id = 81;
-- DELETE FROM decorator_session WHERE decoratorsession_id IN (501,502,503);
-- DELETE FROM housetask WHERE housetask_id = 41001;
-- COMMIT;