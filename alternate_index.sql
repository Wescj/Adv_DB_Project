-- ===========================================================
-- ALTERNATE INDEX: idx_housetask_house_stage
-- Table: HOUSETASK
-- Purpose:
--   Improve query performance for construction managers who
--   frequently need to view tasks by house and filter/sort by stage.
--   This is a common operation when:
--   - Checking current stage tasks for a specific house
--   - Generating construction progress reports
--   - Validating stage completion before advancing
--
-- Justification:
--   The primary key (housetask_id) doesn't help queries that search by
--   house_house_id and stage. Foreign key indexes exist for house_house_id,
--   but adding stage to a composite index significantly improves performance
--   for the common query pattern:
--     "Find all tasks for house X at stage Y"
--
-- Performance Impact:
--   - BEFORE: Full table scan or index scan + filter on stage
--   - AFTER: Direct index access using both columns
--   - Expected improvement: 50-80% faster for construction reports
-- ===========================================================

CREATE INDEX idx_housetask_house_stage 
ON housetask(house_house_id, stage, plannedstart);

-- Test query to demonstrate index usage
SET AUTOTRACE ON EXPLAIN;

-- Common query pattern: Find all stage 2 tasks for a house
SELECT housetask_id, stage, plannedstart, plannedend, percent_complete
FROM housetask
WHERE house_house_id = 8001
  AND stage = 2
ORDER BY plannedstart;

-- Query to find houses at a specific stage
SELECT h.house_id, ht.housetask_id, ht.stage, ht.percent_complete
FROM house h
JOIN housetask ht ON h.house_id = ht.house_house_id
WHERE ht.stage = 1
  AND h.currentconstructionstage = 1;

SET AUTOTRACE OFF;

-- Verification: Check index exists
SELECT index_name, table_name, column_name, column_position
FROM user_ind_columns
WHERE index_name = 'IDX_HOUSETASK_HOUSE_STAGE'
ORDER BY column_position;

COMMIT;