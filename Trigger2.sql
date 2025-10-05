-- ===========================================================
-- Trigger: trg_house_stage_autoadvance
-- Timing/Event: AFTER INSERT OR UPDATE ON task_progress (statement-level)
-- Purpose:
--   After task_progress changes, recompute the highest construction stage
--   for each house where all tasks in that stage are 100% (1.00), and
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
