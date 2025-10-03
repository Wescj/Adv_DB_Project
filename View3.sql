-- ===========================================================
-- View: v_construction_progress_details
-- Purpose:
--   To create a comprehensive view that displays all information required
--   by the "Construction Progress" form in Figure 4 of the case study.
--   This version shows the OVERALL progress from the HOUSETASK, and
--   lists each individual TASK_PROGRESS record as a detail line item.
-- Tables Involved:
--   - HOUSETASK: Provides the overall stage and percent complete.
--   - HOUSE, LOT, SUBDIVISION, EMPLOYEE: Provide location and manager details.
--   - TASK_PROGRESS: Provides the list of progress updates (as "Tasks") and the latest estimated completion date.
--   - PHOTO: Provides the photo associated with the latest progress update.
-- ===========================================================
CREATE OR REPLACE VIEW v_construction_progress_details AS
WITH latest_progress_info AS (
    -- Step 1: Find the ID of the most recent progress record for each housetask
    -- This is used to get the single, most recent estimated completion date and photo.
    SELECT
        housetask_housetask_id,
        MAX(progress_id) AS latest_progress_id
    FROM
        task_progress
    GROUP BY
        housetask_housetask_id
)
SELECT
    s.city,
    s.name AS subdivision_name,
    l.lot_id,
    e.name AS construction_manager,
    ht.stage,
    -- Get the OVERALL percent complete from the parent HOUSETASK
    ht.percent_complete,
    -- Get the LATEST estimated completion date and photo
    latest_tp.estimatedcompletiondate AS est_completion,
    p.date_uploaded AS progress_date,
    p.url AS photo_url,
    -- List each TASK_PROGRESS record as a "Task"
    tp.progress_id AS task,
    tp.percentage_complete AS task_percent_complete
FROM
    housetask ht
-- Base joins for location and manager
JOIN
    house h ON ht.house_house_id = h.house_id
JOIN
    lot l ON h.lot_lot_id = l.lot_id
JOIN
    subdivision s ON l.subdivision_subdivision_id = s.subdivision_id
JOIN
    employee e ON ht.employee_employee_id = e.employee_id
-- Join to get ALL task_progress records for this housetask
JOIN
    task_progress tp ON ht.housetask_id = tp.housetask_housetask_id
-- Join to find the latest progress ID for the header info
LEFT JOIN
    latest_progress_info lpi ON ht.housetask_id = lpi.housetask_housetask_id
-- Join to the task_progress table again using the LATEST ID to get correct header details
LEFT JOIN
    task_progress latest_tp ON lpi.latest_progress_id = latest_tp.progress_id
-- Join to the photo table using the LATEST progress ID to ensure the correct photo is retrieved
LEFT JOIN
    photo p ON latest_tp.progress_id = p.task_progress_progress_id
/


SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- --- Test Data Setup ---
-- NOTE: This script assumes that a base set of records already exists, specifically:
-- - A house with house_id = 8001, which is on lot_id = 2001.
-- - An employee with employee_id = 26001 to act as the manager.

-- 1) Create a parent HOUSETASK for the house with an overall completion percentage
INSERT INTO housetask (housetask_id, stage, house_house_id, employee_employee_id, percent_complete)
VALUES (41001, 1, 8001, 26001, 0.75); -- Overall progress is 75%

-- 2) Add multiple TASK_PROGRESS entries, which will be listed as individual "Tasks"
INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (5001, 0.50, DATE '2025-10-15', 41001); -- Earlier progress
INSERT INTO task_progress (progress_id, percentage_complete, estimatedcompletiondate, housetask_housetask_id)
VALUES (5002, 0.75, DATE '2025-10-20', 41001); -- THIS IS THE LATEST PROGRESS

-- 3) Add a photo LINKED TO THE LATEST PROGRESS RECORD
INSERT INTO photo (photo_id, date_uploaded, url, housetask_housetask_id, task_progress_progress_id)
VALUES (6001, DATE '2025-10-20', 'house8001_progress_5002.jpg', 41001, 5002);

COMMIT;


-- --- Query the View for Verification ---
-- Query all progress details for the house on Lot 2001.
-- This should now return 2 rows (one for each task_progress entry).
-- The main percent_complete (0.75) should be repeated, and the task list
-- should show progress IDs 5001 and 5002.
SELECT *
  FROM v_construction_progress_details
 WHERE lot_id = 2001;


-- --- Cleanup Script (Optional) ---
DELETE FROM photo WHERE housetask_housetask_id = 41001;
DELETE FROM task_progress WHERE housetask_housetask_id = 41001;
DELETE FROM housetask WHERE housetask_id = 41001;
COMMIT;

