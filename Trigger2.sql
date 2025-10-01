-- Drop any previous version
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER trg_house_stage_autoadvance';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4080 THEN RAISE; END IF;  -- ignore "trigger does not exist"
END;
/

-- ===========================================================
-- Trigger: trg_house_stage_autoadvance
-- Timing/Event: AFTER INSERT OR UPDATE ON task_progress (statement-level)
-- Purpose:
--   After task_progress changes, recompute the highest construction stage
--   for each house where *all* tasks in that stage are 100% (1.00), and
--   advance house.currentconstructionstage to that value (never decreases).
-- ===========================================================
CREATE OR REPLACE TRIGGER trg_house_stage_autoadvance
AFTER INSERT OR UPDATE ON task_progress
DECLARE
BEGIN
  /* For every house, find the maximum stage where ALL tasks are complete.
     We consider a task complete if its latest progress row (by max progress_id)
     has percentage_complete >= 1.00.
  */
  MERGE INTO house h
  USING (
    SELECT t.house_id,
           MAX(CASE WHEN t.all_tasks_done = 1 THEN t.stage ELSE 0 END) AS max_completed_stage
    FROM (
      /* For each (house, stage), compute the minimum of the latest progress
         across tasks in that stage: if the min >= 1.00, then all tasks are done.
      */
      SELECT ht.house_house_id AS house_id,
             ht.stage,
             CASE
               WHEN MIN(
                      NVL((
                        SELECT tp.percentage_complete
                        FROM task_progress tp
                        WHERE tp.housetask_housetask_id = ht.housetask_id
                          AND tp.progress_id = (
                                SELECT MAX(tp2.progress_id)
                                FROM task_progress tp2
                                WHERE tp2.housetask_housetask_id = ht.housetask_id
                              )
                      ), 0)
                    ) >= 1
               THEN 1
               ELSE 0
             END AS all_tasks_done
      FROM housetask ht
      GROUP BY ht.house_house_id, ht.stage
    ) t
    GROUP BY t.house_id
  ) s
  ON (h.house_id = s.house_id)
  WHEN MATCHED THEN UPDATE
    SET h.currentconstructionstage = GREATEST(NVL(h.currentconstructionstage,0), s.max_completed_stage);
END;
/

SET SERVEROUTPUT ON;
-- 0) Check current stage
SELECT house_id, currentconstructionstage FROM house WHERE house_id = 6001;

-- 1) Create two tasks at stage 2
INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend,
                       house_house_id, employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (30001, 2, 'Y', SYSDATE, SYSDATE+7, 6001, 9201, 1000, NULL, 0);

INSERT INTO housetask (housetask_id, stage, required, plannedstart, plannedend,
                       house_house_id, employee_employee_id, plannedcost, actualcost, percent_complete)
VALUES (30002, 2, 'Y', SYSDATE, SYSDATE+7, 6001, 9201, 1500, NULL, 0);

COMMIT;

-- 2) Complete the first task (house stage should not advance yet)
INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (92001, 1.00, SYSDATE, 30001);
COMMIT;

SELECT house_id, currentconstructionstage FROM house WHERE house_id = 6001;

-- 3) Complete the second task (now all stage-2 tasks are done → house stage should advance to 2)
INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (92002, 1.00, SYSDATE, 30002);
COMMIT;

DELETE FROM task_progress WHERE housetask_housetask_id IN (20001, 20002);
DELETE FROM housetask      WHERE housetask_id IN (20001, 20002);
COMMIT;

-- nudge a row to fire the trigger
UPDATE task_progress
SET percentage_complete = percentage_complete
WHERE housetask_housetask_id IN (30001, 30002);
COMMIT;

SELECT house_id, currentconstructionstage
FROM house
WHERE house_id = 6001;

