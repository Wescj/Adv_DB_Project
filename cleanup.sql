-- ===========================================================
-- FILE: cleanup.sql
-- PURPOSE: Drop all Eggshell database objects in reverse dependency order
-- USE CASE: Run before fresh installation or when resetting database
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

PROMPT =====================================================================
PROMPT EGGSHELL DATABASE - CLEANUP SCRIPT
PROMPT Dropping all objects in reverse dependency order...
PROMPT =====================================================================

-- =====================================================================
-- Phase 1: Drop Security Objects
-- =====================================================================
PROMPT 
PROMPT Phase 1: Dropping roles...
DROP ROLE construction_role;
DROP ROLE sales_role;

-- =====================================================================
-- Phase 2: Drop Performance Objects
-- =====================================================================
PROMPT 
PROMPT Phase 2: Dropping indexes...
DROP INDEX idx_housetask_house_stage;
DROP INDEX idx_sale_employee_date;
DROP INDEX idx_decorator_choice_session;

-- =====================================================================
-- Phase 3: Drop Views
-- =====================================================================
PROMPT 
PROMPT Phase 3: Dropping views...
DROP VIEW v_house_style_details;
DROP VIEW v_construction_progress;
DROP VIEW v_sales_summary;
DROP VIEW v_current_option_price;

-- =====================================================================
-- Phase 4: Drop Triggers
-- =====================================================================
PROMPT 
PROMPT Phase 4: Dropping triggers...
DROP TRIGGER trg_decorator_update_sale;
DROP TRIGGER trg_sale_calc_total;
DROP TRIGGER trg_session_validate_stage;
DROP TRIGGER trg_choice_set_price;
DROP TRIGGER buyer_bir;
DROP TRIGGER trg_decorator_choice_autoprice;
DROP TRIGGER trg_house_stage_autoadvance;
DROP TRIGGER trg_taskprog_validate;

-- =====================================================================
-- Phase 5: Drop Packages and Functions
-- =====================================================================
PROMPT 
PROMPT Phase 5: Dropping packages and functions...
DROP PACKAGE pkg_eggshell;
DROP FUNCTION fn_house_total_price;

-- =====================================================================
-- Phase 6: Drop Procedures
-- =====================================================================
PROMPT 
PROMPT Phase 6: Dropping procedures...
DROP PROCEDURE pr_record_progress;
DROP PROCEDURE pr_add_choice;

-- =====================================================================
-- Phase 7: Drop Sequences
-- =====================================================================
PROMPT 
PROMPT Phase 7: Dropping sequences...
DROP SEQUENCE buyer_seq;

-- =====================================================================
-- Phase 8: Drop Tables (Reverse Dependency Order)
-- =====================================================================
PROMPT 
PROMPT Phase 8: Dropping tables...
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

PROMPT 
PROMPT =====================================================================
PROMPT CLEANUP COMPLETE
PROMPT All Eggshell database objects have been dropped.
PROMPT Database is ready for fresh setup.
PROMPT =====================================================================