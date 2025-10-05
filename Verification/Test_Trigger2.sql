-- 1. current stage (before)
SELECT house_id, currentconstructionstage
FROM house
WHERE house_id = 8006;

-- 2) Create a stage-2 task for this house
INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend, notes,
house_house_id, employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (99001, 2, 'Y', DATE '2026-03-01', DATE '2026-03-31', 'Framing walls (test)', 8006, 26001, 10000, 0, 0);


-- 3) Mark task 10003 as complete
DECLARE
  v_progress_id NUMBER;
BEGIN
  pkg_eggshell.record_task_progress(
    p_housetask_id => 10003,
    p_fraction     => 1.00,
    p_est_date     => SYSDATE,
    p_progress_id  => v_progress_id
  );
END;
/

-- 4. After these inserts, the trigger fires automatically and advance the house’s currentconstructionstage to 2.

SELECT house_id, currentconstructionstage
FROM house
WHERE house_id = 8006;