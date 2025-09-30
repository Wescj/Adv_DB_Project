-- Enable DBMS_OUTPUT for the PUT_LINE to show
SET SERVEROUTPUT ON;
SET DEFINE OFF;

-- 1) Create a simple task and a session at STAGE = 1 
INSERT INTO housetask (housetask_id, stage, required, house_house_id, employee_employee_id, plannedcost, percent_complete)
VALUES (1, 1, 'Y', 6001, 9201, 1000, 0);

INSERT INTO decorator_session (decoratorsession_id, "Date", stage, housetask_housetask_id, approval)
VALUES (1, SYSDATE, 1, 1, 'Y');

-- 2) Ensure a Plumbing category exists
INSERT INTO optioncategory (category_id, categoryname) VALUES (20, 'Plumbing');

-- 3) Create the Option I want to use (ID 2010)
INSERT INTO "Option" (option_id, option_name, description, optioncategory_category_id, housestyle_style_id)
VALUES (2010, 'Garage Sink', 'Utility sink in garage', 20, 3001);

-- 4) Price history for (option=2010, stage=1): two revisions to test the view
INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (8001, 2010, 1, 450, DATE '2024-01-01');

INSERT INTO option_stage_price (osp_id, option_option_id, stage, cost, revision_date)
VALUES (8002, 2010, 1, 500, DATE '2024-09-01');  -- latest; the view should pick this

COMMIT;



CREATE OR REPLACE PACKAGE pkg_eggshell AS
  -- Returns overall progress for a house in percent (0..100, integer)
  FUNCTION house_progress_pct(
    p_house_id IN house.house_id%TYPE
  ) RETURN NUMBER;

  -- Adds a decorator choice and auto-prices it from v_current_option_price
  PROCEDURE add_decorator_choice(
    p_session_id   IN  decorator_session.decoratorsession_id%TYPE,
    p_option_id    IN  "Option".option_id%TYPE,
    p_item         IN  VARCHAR2,
    p_description  IN  VARCHAR2,
    p_choice_id    OUT decorator_choice.decoratorchoice_id%TYPE
  );

  -- Records task progress as a FRACTION (0.00..1.00). Est date optional.
  PROCEDURE record_task_progress(
    p_housetask_id IN task_progress.housetask_housetask_id%TYPE,
    p_fraction     IN NUMBER,
    p_est_date     IN DATE DEFAULT NULL,
    p_progress_id  OUT task_progress.progress_id%TYPE
  );
END pkg_eggshell;
/

CREATE OR REPLACE PACKAGE BODY pkg_eggshell AS

  FUNCTION house_progress_pct(p_house_id IN house.house_id%TYPE)
  RETURN NUMBER IS
    v_cnt_tasks NUMBER := 0;
    v_avg_frac  NUMBER := 0;
  BEGIN
    -- Average of the latest progress row per task (treat percentage as fraction 0..1)
    SELECT COUNT(*), NVL(AVG(lat.frac),0)
    INTO   v_cnt_tasks, v_avg_frac
    FROM (
      SELECT ht.housetask_id,
             -- latest progress row per task
             (SELECT tp.percentage_complete
                FROM task_progress tp
               WHERE tp.housetask_housetask_id = ht.housetask_id
               ORDER BY tp.estimatedcompletiondate DESC NULLS LAST, tp.progress_id DESC
              FETCH FIRST 1 ROWS ONLY) AS frac
      FROM housetask ht
      WHERE ht.house_house_id = p_house_id
    ) lat
    WHERE lat.frac IS NOT NULL;

    IF v_cnt_tasks = 0 THEN
      RETURN 0;
    ELSE
      RETURN ROUND(100 * v_avg_frac); -- convert fraction to %
    END IF;
  END house_progress_pct;


  PROCEDURE add_decorator_choice(
      p_session_id   IN  decorator_session.decoratorsession_id%TYPE,
      p_option_id    IN  "Option".option_id%TYPE,
      p_item         IN  VARCHAR2,
      p_description  IN  VARCHAR2,
      p_choice_id    OUT decorator_choice.decoratorchoice_id%TYPE
  ) IS
    v_stage   decorator_session.stage%TYPE;
    v_price   NUMBER(12,2);
  BEGIN
    -- Get the session stage
    SELECT stage INTO v_stage
    FROM decorator_session
    WHERE decoratorsession_id = p_session_id;

    -- Validate stage is allowed for this option and get the latest price
    SELECT v.current_cost INTO v_price
    FROM v_current_option_price v
    WHERE v.option_option_id = p_option_id
      AND v.stage = v_stage;

    -- Generate a new id (keeps your current numeric keys approach)
    SELECT NVL(MAX(decoratorchoice_id),0) + 1
    INTO   p_choice_id
    FROM   decorator_choice;

    INSERT INTO decorator_choice(
      decoratorchoice_id, item, description, price,
      decorator_session_id, option_option_id
    ) VALUES (
      p_choice_id, p_item, p_description, v_price,
      p_session_id, p_option_id
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- No price defined for this (option, stage)
      RAISE_APPLICATION_ERROR(-20030,
        'No price found for option '||p_option_id||' at stage '||v_stage||
        ' (define OPTION_STAGE_PRICE first).');
  END add_decorator_choice;


  PROCEDURE record_task_progress(
      p_housetask_id IN task_progress.housetask_housetask_id%TYPE,
      p_fraction     IN NUMBER,
      p_est_date     IN DATE DEFAULT NULL,
      p_progress_id  OUT task_progress.progress_id%TYPE
  ) IS
  BEGIN
    IF p_fraction < 0 OR p_fraction > 1 THEN
      RAISE_APPLICATION_ERROR(-20031, 'Progress must be a fraction between 0.00 and 1.00');
    END IF;

    SELECT NVL(MAX(progress_id),0) + 1
    INTO   p_progress_id
    FROM   task_progress;

    INSERT INTO task_progress(progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
    VALUES (p_progress_id, p_fraction, p_est_date, p_housetask_id);
  END record_task_progress;

END pkg_eggshell;
/


-- Example: add a decorator choice (auto-priced by session's stage)
DECLARE
  v_choice_id NUMBER;
BEGIN
  pkg_eggshell.add_decorator_choice(
    p_session_id  => 1,
    p_option_id   => 2010,
    p_item        => 'Garage Sink',
    p_description => 'Deep-basin utility sink',
    p_choice_id   => v_choice_id
  );
  DBMS_OUTPUT.PUT_LINE('Added decorator_choice_id='||v_choice_id);
END;
/

-- Example: record progress (40% = 0.40 fraction)
DECLARE
  v_pid NUMBER;
BEGIN
  pkg_eggshell.record_task_progress(
    p_housetask_id => 1,
    p_fraction     => 0.40,
    p_est_date     => SYSDATE + 14,
    p_progress_id  => v_pid
  );
  DBMS_OUTPUT.PUT_LINE('Added task_progress_id='||v_pid);
END;
/

-- Example: compute a house's overall % progress
SELECT pkg_eggshell.house_progress_pct(6001) AS house_6001_pct FROM dual;