-- -- ===========================================================
-- -- Trigger: trg_choice_set_price
-- -- Table:  DECORATOR_CHOICE
-- -- Timing: BEFORE INSERT (row-level)
-- -- Purpose:
-- --   Automatically populate the PRICE for a new DECORATOR_CHOICE record
-- --   before it is inserted into the table.
-- --
-- -- Business Rules:
-- --   - Each option’s cost depends on the construction stage.
-- --   - If multiple costs exist for the same option/stage due to revisions,
-- --     use the one with the most recent REVISION_DATE.
-- --   - If no cost exists for the specified option/stage combination,
-- --     block the insert and raise an application error.
-- -- ===========================================================
-- CREATE OR REPLACE TRIGGER trg_choice_set_price
-- BEFORE INSERT ON decorator_choice
-- FOR EACH ROW
-- DECLARE
--   v_stage decorator_session.stage%TYPE;
--   v_price option_stage_price.cost%TYPE;
-- BEGIN
--   -- 1. Retrieve the construction stage from the parent decorator session
--   SELECT stage
--     INTO v_stage
--     FROM decorator_session
--    WHERE decoratorsession_id = :NEW.decorator_session_id;

--   -- 2. Retrieve the most recent price for the given option and stage
--   SELECT cost
--     INTO v_price
--     FROM option_stage_price
--    WHERE option_option_id = :NEW.option_option_id
--      AND stage            = v_stage
--      AND revision_date = (
--        SELECT MAX(revision_date)
--          FROM option_stage_price
--         WHERE option_option_id = :NEW.option_option_id
--           AND stage            = v_stage
--      );

--   -- 3. Assign the retrieved price to the new record
--   :NEW.price := v_price;

-- EXCEPTION
--   WHEN NO_DATA_FOUND THEN
--     RAISE_APPLICATION_ERROR(
--       -20010,
--       'Operation failed: No price has been defined for option ID '
--       || :NEW.option_option_id || ' at stage ' || v_stage || '.'
--     );
-- END;
-- /
-- -- ===========================================================



-- -- ===========================================================
-- -- Trigger: trg_choice_refresh_sale
-- -- Table:  DECORATOR_CHOICE
-- -- Timing: AFTER INSERT (statement-level)
-- -- Purpose:
-- --   To safely refresh or recalculate related SALE totals
-- --   after new DECORATOR_CHOICE records are inserted.
-- --
-- -- Rationale:
-- --   - Avoids mutating table errors caused by row-level triggers
-- --     that attempt to read from or write to DECORATOR_CHOICE
-- --     during the same transaction.
-- --   - Ensures total updates occur only once after all rows are inserted.
-- --
-- -- Implementation:
-- --   - Collects all affected DECORATOR_SESSION_ID values.
-- --   - For each session, updates the associated SALE total by calling
-- --     the FN_HOUSE_TOTAL_PRICE function (used by existing logic).
-- -- ===========================================================
-- CREATE OR REPLACE TRIGGER trg_choice_refresh_sale
-- AFTER INSERT ON decorator_choice
-- DECLARE
-- BEGIN
--   FOR rec IN (
--     SELECT DISTINCT dc.decorator_session_id
--       FROM decorator_choice dc
--      WHERE dc.price IS NOT NULL
--   )
--   LOOP
--     BEGIN
--       UPDATE sale s
--          SET s.total_price = fn_house_total_price(rec.decorator_session_id)
--        WHERE s.decoratorsession_id = rec.decorator_session_id;
--     EXCEPTION
--       WHEN OTHERS THEN
--         -- Prevent a single failure from blocking the entire insert operation
--         DBMS_OUTPUT.PUT_LINE(
--           'Warning: Failed to refresh SALE total for decorator_session_id = '
--           || rec.decorator_session_id || '. ' || SQLERRM
--         );
--     END;
--   END LOOP;
-- END;
-- /


-- ===========================================================
-- Trigger: trg_choice_set_price
-- Table:  DECORATOR_CHOICE
-- Timing: BEFORE INSERT
-- Purpose:
--   To automatically populate the PRICE for a new DECORATOR_CHOICE record.
--   The price is determined by looking up the cost for the chosen option
--   at the construction stage specified in the parent decorator session.
-- Business rules:
--   - Each option's cost is dependent on the construction stage.
--   - If multiple prices exist for the same option and stage (due to
--     revisions), the price with the most recent revision_date must be used.
--   - If no price is defined in OPTION_STAGE_PRICE for the given
--     option and stage, the insert must be blocked with an error.
-- ===========================================================
CREATE OR REPLACE TRIGGER trg_choice_set_price
BEFORE INSERT ON decorator_choice
FOR EACH ROW
DECLARE
  v_stage decorator_session.stage%TYPE;
  v_price option_stage_price.cost%TYPE;
BEGIN
  -- 1. Get the construction stage from the parent decorator session
  SELECT stage
    INTO v_stage
    FROM decorator_session
   WHERE decoratorsession_id = :NEW.decorator_session_id;

  -- 2. Find the most recent price for the given option at that stage
  SELECT cost
    INTO v_price
    FROM option_stage_price
   WHERE option_option_id = :NEW.option_option_id
     AND stage            = v_stage
     AND revision_date = (
       SELECT MAX(revision_date)
         FROM option_stage_price
        WHERE option_option_id = :NEW.option_option_id
          AND stage            = v_stage
     );

  -- 3. Set the price on the new decorator_choice record
  :NEW.price := v_price;

EXCEPTION
  -- Handle cases where no price is defined for the option at that stage
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(
      -20010,
      'Operation failed: No price has been defined for option ID ' || :NEW.option_option_id || ' at stage ' || v_stage || '.'
    );
END;
/

