-- Enable DBMS_OUTPUT for the PUT_LINE to show
SET SERVEROUTPUT ON;
SET DEFINE OFF;

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

