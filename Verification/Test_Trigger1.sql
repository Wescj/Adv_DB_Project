-- 1. Insert with missing fields (trigger should auto-fill)
INSERT INTO task_progress (progress_id, housetask_housetask_id)
VALUES (99903, 10001);

SELECT progress_id, percentage_complete, estimatedcompletiondate
FROM task_progress
WHERE progress_id = 99903;

--2. Try invalid fraction (should raise error)
BEGIN
  INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
  VALUES (99904, 1.5, SYSDATE, 10001);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
END;
/