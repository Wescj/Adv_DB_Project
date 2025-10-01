-- =========================================
-- Role 1: SALES_ROLE
-- For staff who handle buyers, sales, escrow, and banks
-- =========================================
CREATE ROLE sales_role;

-- Grant privileges needed for managing sales workflow
GRANT SELECT, INSERT, UPDATE ON buyer       TO sales_role;
GRANT SELECT, INSERT, UPDATE ON sale        TO sales_role;
GRANT SELECT, INSERT, UPDATE ON escrowagent TO sales_role;
GRANT SELECT, INSERT, UPDATE ON bank        TO sales_role;
GRANT SELECT, INSERT, UPDATE ON bank_worker TO sales_role;

-- =========================================
-- Role 2: CONSTRUCTION_ROLE
-- For staff who manage construction tasks, houses, lots, and decorator choices
-- =========================================
CREATE ROLE construction_role;

-- Grant privileges needed for construction operations
GRANT SELECT, INSERT, UPDATE ON house              TO construction_role;
GRANT SELECT, INSERT, UPDATE ON lot                TO construction_role;
GRANT SELECT, INSERT, UPDATE ON housetask          TO construction_role;
GRANT SELECT, INSERT, UPDATE ON construction_task  TO construction_role;
GRANT SELECT, INSERT, UPDATE ON decorator_session  TO construction_role;
GRANT SELECT, INSERT, UPDATE ON decorator_choice   TO construction_role;
GRANT SELECT, INSERT, UPDATE ON task_progress      TO construction_role;
GRANT SELECT, INSERT, UPDATE ON photo              TO construction_role;
