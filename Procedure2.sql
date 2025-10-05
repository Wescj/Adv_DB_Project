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
