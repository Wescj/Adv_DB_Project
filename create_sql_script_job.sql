-- ===========================================================
-- FILE: create_sql_script_job.sql
-- PURPOSE: Create a DBMS_SCHEDULER job to run a SQL script.
-- NOTE: Run this script as a privileged user (e.g., SYS or SYSTEM)
--       in SQL Developer or SQLcl. Requires Oracle 12c or higher.
-- ===========================================================
SET SERVEROUTPUT ON;

BEGIN
  -- Drop the job if it already exists 
  BEGIN
    DBMS_SCHEDULER.drop_job('RUN_EGGSHELL_PROJECT_SQL', force => TRUE);
    DBMS_OUTPUT.put_line('Dropped existing job: RUN_EGGSHELL_PROJECT_SQL');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -27475 THEN 
        DBMS_OUTPUT.put_line('Job did not exist, don't need to drop.');
      ELSE
        RAISE;
      END IF;
  END;

  -- Create the job to run a SQL script
  DBMS_SCHEDULER.create_job (
    job_name        => 'RUN_EGGSHELL_PROJECT_SQL',
    job_type        => 'SQL_SCRIPT',
    job_action      => '
      -- This is an inline SQL Script that the scheduler will execute.',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=3; BYMINUTE=0',
    enabled         => TRUE,
    auto_drop       => FALSE,
    comments        => 'Job to clean, install, and test the Eggshell project using a SQL script.'
  );

  DBMS_OUTPUT.put_line('Job RUN_EGGSHELL_PROJECT_SQL created and enabled.');

END;
/

-- === Verification and Management ===

PROMPT Verifying job status
SELECT job_name, enabled, state
FROM user_scheduler_jobs
WHERE job_name = 'RUN_EGGSHELL_PROJECT_SQL';
