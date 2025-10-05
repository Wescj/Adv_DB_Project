--1) Quick sanity check: current house progress (before changes)
SET SERVEROUTPUT ON;

BEGIN
  FOR r IN (SELECT house_id FROM house ORDER BY house_id) LOOP
    DBMS_OUTPUT.PUT_LINE(
      'House '||r.house_id||' progress = '||
      pkg_eggshell.house_progress_pct(r.house_id)||'%'
    );
  END LOOP;
END;
/

-- 2a) Add progress for 8006’s foundation task (housetask_id = 10001)
DECLARE
  v_progress_id task_progress.progress_id%TYPE;
BEGIN
  pkg_eggshell.record_task_progress(
    p_housetask_id => 10001,
    p_fraction     => 0.60,                -- update to 60%
    p_est_date     => DATE '2026-02-10',
    p_progress_id  => v_progress_id
  );
  DBMS_OUTPUT.PUT_LINE('Inserted task_progress.progress_id = '||v_progress_id);
END;
/


-- Verify latest row is used by the function (should now report 60% for 8006)
BEGIN
  DBMS_OUTPUT.PUT_LINE(
    'House 8006 progress = '||pkg_eggshell.house_progress_pct(8006)||'%'
  );
END;
/

-- 2b) Add progress for 8007’s foundation task (housetask_id = 10002)
DECLARE
  v_progress_id task_progress.progress_id%TYPE;
BEGIN
  pkg_eggshell.record_task_progress(
    p_housetask_id => 10002,
    p_fraction     => 0.80,                 -- update to 80%
    p_est_date     => DATE '2026-03-20',
    p_progress_id  => v_progress_id
  );
  DBMS_OUTPUT.PUT_LINE('Inserted task_progress.progress_id = '||v_progress_id);
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(
    'House 8007 progress = '||pkg_eggshell.house_progress_pct(8007)||'%'
  );
END;
/


--3) Negative test: invalid fraction should raise error -20031
-- Expect: ORA-20031: Progress must be a fraction between 0.00 and 1.00
BEGIN
  pkg_eggshell.record_task_progress(
    p_housetask_id => 10001,
    p_fraction     => 1.20,      -- invalid
    p_est_date     => SYSDATE,
    p_progress_id  => 18005     
  );
END;
/

--4) Test add_decorator_choice
--4a) Show the expected failure first (no price for session’s stage)


-- Expect: ORA-20030: No price found for option ... at stage 2
DECLARE
  v_choice_id decorator_choice.decoratorchoice_id%TYPE;
BEGIN
  pkg_eggshell.add_decorator_choice(
    p_session_id  => 14001,            -- stage = 2
    p_option_id   => 16001,            -- Granite Countertops (only priced at stage 3 so far)
    p_item        => 'Granite - Absolute Black',
    p_description => 'Stage-2 test (should fail before we add pricing)',
    p_choice_id   => v_choice_id
  );
  DBMS_OUTPUT.PUT_LINE('New decorator_choice id = '||v_choice_id);
END;
/

--4b) Insert stage 2 pricing so the procedure can succeed
-- Add "current" pricing at stage 2 for both options we’ll test
INSERT INTO option_stage_price (osp_id, cost, revision_date, stage, option_option_id)
VALUES (18005, 5200, DATE '2026-02-01', 2, 16001);  -- Granite Countertops (stage 2)

INSERT INTO option_stage_price (osp_id, cost, revision_date, stage, option_option_id)
VALUES (18006, 6800, DATE '2026-03-01', 2, 16003);  -- Jacuzzi Tub (stage 2)

COMMIT;

--4c) Now call add_decorator_choice again (should succeed)
DECLARE
  v_choice_id decorator_choice.decoratorchoice_id%TYPE;
BEGIN
  pkg_eggshell.add_decorator_choice(
    p_session_id  => 14001,           -- stage = 2 (now priced)
    p_option_id   => 16001,           -- Granite Countertops
    p_item        => 'Granite - Absolute Black',
    p_description => 'Stage-2 priced test (should succeed)',
    p_choice_id   => v_choice_id
  );
  DBMS_OUTPUT.PUT_LINE('New decorator_choice id = '||v_choice_id);
END;
/

-- Another one for the other session/option pair:
DECLARE
  v_choice_id decorator_choice.decoratorchoice_id%TYPE;
BEGIN
  pkg_eggshell.add_decorator_choice(
    p_session_id  => 14002,           -- stage = 2 (priced)
    p_option_id   => 16003,           -- Jacuzzi Tub
    p_item        => 'Jacuzzi - Deluxe',
    p_description => 'Stage-2 Jacuzzi pricing test',
    p_choice_id   => v_choice_id
  );
  DBMS_OUTPUT.PUT_LINE('New decorator_choice id = '||v_choice_id);
END;
/

--5) Verify inserts and prices
-- Check what the package just inserted into DECORATOR_CHOICE
SELECT decoratorchoice_id, decorator_session_id, option_option_id, price, item, description
FROM decorator_choice
WHERE decorator_session_id IN (14001, 14002)
ORDER BY decoratorchoice_id;

SELECT o.option_id,
       o.option_name,
       p.stage,
       p.cost,
       p.revision_date
FROM "Option" o
JOIN option_stage_price p ON p.option_option_id = o.option_id
WHERE o.option_id IN (16001,16003)
ORDER BY o.option_id, p.stage, p.revision_date DESC;

-- Final progress snapshot across all houses after updates
BEGIN
  FOR r IN (SELECT house_id FROM house ORDER BY house_id) LOOP
    DBMS_OUTPUT.PUT_LINE(
      'House '||r.house_id||' progress = '||
      pkg_eggshell.house_progress_pct(r.house_id)||'%'
    );
  END LOOP;
END;
/

--6)Add a second task to a house to show averaging
-- New housetask for house 8006 (stage 2 framing)
INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend, notes, 
                       house_house_id, employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (10003, 2, 'Y', DATE '2026-02-01', DATE '2026-03-01', 'Framing work', 8006, 26002, 30000, 0, 0);

-- Record 20% on the new task
DECLARE
  v_progress_id task_progress.progress_id%TYPE;
BEGIN
  pkg_eggshell.record_task_progress(
    p_housetask_id => 10003,
    p_fraction     => 0.20,
    p_est_date     => DATE '2026-02-25',
    p_progress_id  => v_progress_id
  );
  DBMS_OUTPUT.PUT_LINE('Inserted task_progress.progress_id = '||v_progress_id);
END;
/

-- Now the house-level progress is the average of latest(10001)=0.60 and latest(10003)=0.20 => 40%
BEGIN
  DBMS_OUTPUT.PUT_LINE(
    'House 8006 progress (with 2 tasks) = '||pkg_eggshell.house_progress_pct(8006)||'%'
  );
END;
/