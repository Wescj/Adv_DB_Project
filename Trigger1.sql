-- ===========================================================
-- Trigger: trg_taskprog_validate
-- Table:  task_progress
-- Event:  BEFORE INSERT OR UPDATE (row-level)
-- Purpose:
--   1. Enforce valid percentage values (0.00–1.00).
--   2. Default NULL percentage_complete to 0.
--   3. Default NULL estimatedcompletiondate to SYSDATE.
-- Business Rule Supported:
--   - Construction task progress must be expressed as a
--     fraction between 0.0 (0%) and 1.0 (100%).
--   - Progress rows must always carry a valid date.
-- ===========================================================

CREATE OR REPLACE TRIGGER trg_taskprog_validate
BEFORE INSERT OR UPDATE ON task_progress
FOR EACH ROW
BEGIN
  IF :NEW.percentage_complete IS NULL THEN
    :NEW.percentage_complete := 0;
  END IF;

  IF :NEW.percentage_complete < 0 OR :NEW.percentage_complete > 1 THEN
    RAISE_APPLICATION_ERROR(-20001, 'percentage_complete must be between 0.00 and 1.00');
  END IF;

  IF :NEW.estimatedcompletiondate IS NULL THEN
    :NEW.estimatedcompletiondate := SYSDATE;
  END IF;
END;
/
