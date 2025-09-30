-- ===========================================================
-- Procedure: pr_record_progress
-- Purpose:
--   Wrapper for pkg_eggshell.record_task_progress.
--   Simplifies recording task progress for a housetask by
--   hiding the OUT parameter and printing the generated ID.
--
-- Parameters:
--   p_task_id   - The HOUSETASK_ID for which progress is being recorded.
--   p_fraction  - Progress as a fraction between 0.00 and 1.00
--                 (1.00 = 100% complete). Checked by triggers.
--   p_est_date  - Estimated completion date for this progress entry.
--                 Defaults to SYSDATE if not provided.
--
-- Behavior:
--   - Calls the pkg_eggshell procedure to insert a new row into TASK_PROGRESS.
--   - pkg_eggshell validates that p_fraction is in [0,1].
--   - A new PROGRESS_ID is generated inside the package.
--   - Prints a confirmation message with the new PROGRESS_ID.
--
-- Business Rule Supported:
--   Task progress must always be stored as a fraction between 0 and 1,
--   and each housetask may have multiple dated progress entries.
-- ===========================================================
CREATE OR REPLACE PROCEDURE pr_record_progress(
  p_task_id   IN NUMBER,
  p_fraction  IN NUMBER,
  p_est_date  IN DATE DEFAULT NULL
) AS
  v_pid NUMBER;  
BEGIN
  -- Call the package procedure that does validation + insert
  pkg_eggshell.record_task_progress(p_task_id, p_fraction, p_est_date, v_pid);

  -- Print confirmation message 
  DBMS_OUTPUT.PUT_LINE('Task progress inserted with id='||v_pid);
END;
/


SET SERVEROUTPUT ON;

-- Step 1: Create a dummy housetask
INSERT INTO housetask (housetask_id, stage, required,
                       house_house_id, employee_employee_id,
                       plannedcost, percent_complete)
VALUES (60010, 1, 'Y', 6001, 9201, 1000, 0);
COMMIT;

-- Step 2: Call the wrapper procedure to insert progress
BEGIN
  pr_record_progress(
    p_task_id  => 60010,
    p_fraction => 0.50,          -- 50% done
    p_est_date => SYSDATE+7      -- due in a week
  );
END;
/

-- Expected: prints "Task progress inserted with id=<new id>"

-- Step 3: Verify row in TASK_PROGRESS
SELECT progress_id,
       housetask_housetask_id,
       percentage_complete,
       estimatedcompletiondate
FROM task_progress
WHERE housetask_housetask_id = 60010
ORDER BY progress_id DESC;