-- ===========================================================
-- CLEANUP SCRIPT - Drop all objects in reverse order
-- ===========================================================

SET ECHO ON
WHENEVER SQLERROR CONTINUE

-- Drop roles
DROP ROLE construction_role;
DROP ROLE sales_role;

-- Drop views
DROP VIEW v_construction_progress;
DROP VIEW v_sales_summary;
DROP VIEW v_current_option_price;

-- Drop triggers
DROP TRIGGER trg_decorator_update_sale;
DROP TRIGGER trg_sale_calc_total;
DROP TRIGGER buyer_bir;
DROP TRIGGER trg_decorator_choice_autoprice;
DROP TRIGGER trg_house_stage_autoadvance;
DROP TRIGGER trg_taskprog_validate;

-- Drop packages
DROP PACKAGE pkg_eggshell;

-- Drop functions
DROP FUNCTION fn_house_total_price;

-- Drop sequences
DROP SEQUENCE buyer_seq;

-- Drop index
DROP INDEX idx_housetask_house_stage;

-- Drop tables (in dependency order)
DROP TABLE photo CASCADE CONSTRAINTS;
DROP TABLE task_progress CASCADE CONSTRAINTS;
DROP TABLE construction_task CASCADE CONSTRAINTS;
DROP TABLE decorator_choice CASCADE CONSTRAINTS;
DROP TABLE decorator_session CASCADE CONSTRAINTS;
DROP TABLE option_stage_price CASCADE CONSTRAINTS;
DROP TABLE "Option" CASCADE CONSTRAINTS;
DROP TABLE optioncategory CASCADE CONSTRAINTS;
DROP TABLE sale CASCADE CONSTRAINTS;
DROP TABLE housetask CASCADE CONSTRAINTS;
DROP TABLE rooms CASCADE CONSTRAINTS;
DROP TABLE house CASCADE CONSTRAINTS;
DROP TABLE elevation CASCADE CONSTRAINTS;
DROP TABLE housestyle CASCADE CONSTRAINTS;
DROP TABLE lot CASCADE CONSTRAINTS;
DROP TABLE school CASCADE CONSTRAINTS;
DROP TABLE subdivision CASCADE CONSTRAINTS;
DROP TABLE bank_worker CASCADE CONSTRAINTS;
DROP TABLE bank CASCADE CONSTRAINTS;
DROP TABLE escrowagent CASCADE CONSTRAINTS;
DROP TABLE employee CASCADE CONSTRAINTS;
DROP TABLE buyer CASCADE CONSTRAINTS;

PROMPT All objects dropped. Ready for fresh setup.s