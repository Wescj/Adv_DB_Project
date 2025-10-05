SET SERVEROUTPUT ON;

BEGIN
  pr_record_progress(
    p_task_id  => 10003,          -- existing task
    p_fraction => 0.75,           -- 75% complete
    p_est_date => SYSDATE         -- optional; could also omit
  );
END;
/

-- To Verify
SELECT progress_id,
       percentage_complete,
       estimatedcompletiondate,
       housetask_housetask_id
FROM task_progress
WHERE housetask_housetask_id = 10003
ORDER BY progress_id DESC;

-- You can also immediately check the house-level progress 
SELECT pkg_eggshell.house_progress_pct(8006) AS house_progress
FROM dual;