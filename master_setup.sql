-- ===========================================================
-- FILE: master_setup.sql
-- PURPOSE: Execute all Eggshell database components in correct order
-- DEPENDENCY: Runs all component scripts in proper sequence
-- ===========================================================

SET ECHO ON
SET SERVEROUTPUT ON SIZE 1000000
SET TIMING ON
SET LINESIZE 200
SET PAGESIZE 100
WHENEVER SQLERROR CONTINUE

PROMPT =====================================================================
PROMPT EGGSHELL HOME BUILDER - MASTER SETUP SCRIPT
PROMPT Installing all database components in dependency order...
PROMPT =====================================================================

-- =====================================================================
-- Phase 1: Core Schema (Tables and Constraints)
-- =====================================================================
PROMPT 
PROMPT Phase 1: Creating tables and constraints...
@/Users/msj/Adv_DB_Project/DDL_Script_1.0.ddl

-- =====================================================================
-- Phase 2: Initial Data Load
-- =====================================================================
PROMPT 
PROMPT Phase 2: Loading initial data...
@/Users/msj/Adv_DB_Project/data_init.sql

-- =====================================================================
-- Phase 3: Views (Read-Only Components)
-- =====================================================================
PROMPT 
PROMPT Phase 3: Creating views...
@/Users/msj/Adv_DB_Project/View.sql
@/Users/msj/Adv_DB_Project/View2.sql
@/Users/msj/Adv_DB_Project/View3.sql

-- =====================================================================
-- Phase 4: Functions (Reusable Logic)
-- =====================================================================
PROMPT 
PROMPT Phase 4: Creating functions...
@Function.sql

-- =====================================================================
-- Phase 5: Triggers (Data Integrity and Automation)
-- =====================================================================
PROMPT 
PROMPT Phase 5: Creating triggers...
@/Users/msj/Adv_DB_Project/Trigger1.sql
@/Users/msj/Adv_DB_Project/Trigger2.sql
@/Users/msj/Adv_DB_Project/Trigger3.sql
@/Users/msj/Adv_DB_Project/Trigger4.sql
@/Users/msj/Adv_DB_Project/Trigger5.sql

-- =====================================================================
-- Phase 6: Surrogate Key Implementation
-- =====================================================================
PROMPT 
PROMPT Phase 6: Implementing surrogate keys...
@/Users/msj/Adv_DB_Project/buyer_surrogate.sql

-- =====================================================================
-- Phase 7: Packages and Procedures
-- =====================================================================
PROMPT 
PROMPT Phase 7: Creating packages and procedures...
@/Users/msj/Adv_DB_Project/Package.sql
@/Users/msj/Adv_DB_Project/Procedure1.sql
@/Users/msj/Adv_DB_Project/Procedure2.sql

-- =====================================================================
-- Phase 8: Performance Optimizations
-- =====================================================================
PROMPT 
PROMPT Phase 8: Creating indexes and denormalization...
@/Users/msj/Adv_DB_Project/alternate_index.sql
@/Users/msj/Adv_DB_Project/denormalization.sql

-- =====================================================================
-- Phase 9: Security (Roles and Permissions)
-- =====================================================================
PROMPT 
PROMPT Phase 9: Creating roles and permissions...
@/Users/msj/Adv_DB_Project/roles.sql

PROMPT 
PROMPT =====================================================================
PROMPT SETUP COMPLETE
PROMPT =====================================================================
PROMPT All components have been installed.
PROMPT Run verify_eggshell.sql to check installation status.
PROMPT =====================================================================

SET TIMING OFF